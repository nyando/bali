`include "control/headers/opcodes.vh"

`timescale 10ns / 10ns

module cpu(
    input clk,
    input rst,
    input [7:0] op_code,            // current opcode
    input [7:0] arg1,               // (optional) first argument to the current opcode
    input [7:0] arg2,               // (optional) second argument to the current opcode
    input [31:0] dataparams,        // 32-bit data segment containing either method invocation parameters or constants
    output [15:0] dataindex,        // index of data segment to load into dataparams
    output [15:0] program_counter   // memory address of current/next opcode
);

    logic arrwrite;
    logic arrtrigger;
    logic [15:0] arraddr;
    logic [31:0] arrwritevalue;
    logic [31:0] arrreadvalue;
    logic arrdone;

    arrayblock #(
        .ARR_SIZE(65_536)
    ) staticarray (
        .clk(clk),
        .write(arrwrite),
        .trigger(arrtrigger),
        .addr(arraddr),
        .writevalue(arrwritevalue),
        .readvalue(arrreadvalue),
        .done(arrdone)
    );

    logic lva_write;                // hi if writing to LVA, lo if reading/idle
    logic [31:0] lva_in;            // value to write to LVA
    logic [7:0] lva_addr;           // address of LVA to read from or write to
    logic [31:0] lva_out;           // value at current lva_addr
    logic lva_trigger;              // hi for one clock cycle when reading/writing
    logic lva_done;                 // hi for one clock cycle when read/write done

    // local variable array holds variables for all methods that have not returned yet
    arrayblock #(
        .ARR_SIZE(256)
    ) localvars (
        .clk(clk),
        .write(lva_write),
        .trigger(lva_trigger),
        .addr(lva_addr),
        .writevalue(lva_in),
        .readvalue(lva_out),
        .done(lva_done)
    );

    // lva I/O for control module
    logic [7:0] lva_index;          // method-local index of local variable to read/write
    logic [7:0] lva_offset;         // absolute address in the LVA is LVA offset - index
    logic op_done;                  // hi for one clock cycle when instruction finishes execution
    logic [15:0] offset;            // offset of next instruction to current pc value
    
    // constant load register for passing program int constants to control unit
    logic [31:0] ldconst;

    // output register for method return values
    logic [31:0] retval;
    
    // method eval stack I/O for control module
    logic evalpush;                 // hi if pushing value to stack, lo if popping
    logic evaltrigger;              // set to hi for one clock cycle to initiate push or pop operation
    logic [31:0] evalread;          // contains last value popped from stack
    logic [31:0] evalwrite;         // contains value to push to stack
    logic evaldone;                 // set to hi for one clock cycle when push or pop operation is complete
    
    // control unit I/O for method invocation
    logic lvamove;                  // trigger to move top of eval stack to lva
    logic [7:0] lvamoveindex;       // index of lva to move eval stack element to
    logic lvamovedone;              // hi for one clock cycle when lva move done

    // control unit executes the code within a method
    control control_unit (
        .clk(clk),
        .op_code(op_code),
        .arg1(arg1),
        .arg2(arg2),
        .ldconst(ldconst),
        .lvadone(lva_done),
        .lvaread(lva_out),
        .lvawrite(lva_in),
        .lvaindex(lva_index),
        .lvaop(lva_write),
        .lvatrigger(lva_trigger),
        .lvamove(lvamove),
        .lvamoveindex(lvamoveindex),
        .lvamovedone(lvamovedone),
        .arrop(arrwrite),
        .arrtrigger(arrtrigger),
        .arraddr(arraddr),
        .arrwritevalue(arrwritevalue),
        .arrreadvalue(arrreadvalue),
        .arrdone(arrdone),
        .evalpush(evalpush),
        .evaltrigger(evaltrigger),
        .evalread(evalread),
        .evalwrite(evalwrite),
        .evaldone(evaldone),
        .offset(offset),
        .op_done(op_done)
    );

    // call stack I/O, controlled only by CPU module
    logic callpush;                 // hi for write, lo for read
    logic calltrigger;              // hi for one clock cycle to trigger read/write
    logic [31:0] callwrite;         // value to write to callstack
    logic [31:0] callread;          // value to read from callstack
    logic calldone;                 // hi for one clock cycle when read/write done

    stack #(
        .STACKDATA(32),
        .STACKSIZE(256)
    ) callstack (
        .clk(clk),
        .push(callpush),
        .trigger(calltrigger),
        .write_value(callwrite),
        .read_value(callread),
        .done_out(calldone)
    );

    // method eval stack instance
    stack #(
        .STACKDATA(32),
        .STACKSIZE(32)
    ) eval_stack (
        .clk(clk),
        .push(evalpush),
        .trigger(evaltrigger),
        .write_value(evalwrite),
        .read_value(evalread),
        .done_out(evaldone)
    );
    
    // procedure for method invocation:
    // - load parameters from memory (method address, number of arguments, number of local variables)
    // - transfer values on eval stack to new method's local variable array
    // - push calling method's return address (pc + 1 from invoke instruction) and LVA offset onto call stack
    // - on return instruction, pop callstack and assign return address to PC, set LVA offset back
    logic [3:0] invoke_state;
    const logic [3:0] IDLE        = 4'b0000;
    const logic [3:0] LOADPARAMS  = 4'b0001;
    const logic [3:0] PARAMWAIT   = 4'b0010;
    const logic [3:0] FETCHPARAMS = 4'b0011;
    const logic [3:0] LVALOAD     = 4'b0100;
    const logic [3:0] LVAMOVE     = 4'b0101;
    const logic [3:0] LVAWAIT     = 4'b0110;
    const logic [3:0] LVADONE     = 4'b0111;
    const logic [3:0] CS_PUSH     = 4'b1000;
    const logic [3:0] CS_WAIT     = 4'b1001;
    const logic [3:0] INVOKE      = 4'b1010;
    const logic [3:0] RET         = 4'b1011;
    const logic [3:0] INVOKEDONE  = 4'b1100;

    logic [15:0] pc;                // program counter register, holds address of current instruction
    logic [15:0] data_index;        // index of program memory data segment to read (memory address = 4 * data_index)

    logic [15:0] codeaddr;          // address of the method to invoke next
    logic [7:0] argcount;           // number of arguments of invoked method (i. e. number of elements to transfer from stack to LVA)
    logic [7:0] lvamax;             // maximum number of local variables of invoked method, argcount <= lvamax

    initial begin
        pc <= 8'h00;
    end

    always @ (posedge clk) begin
        if (op_done) begin
            // increase program counter by offset
            pc <= pc + offset;
        end
        
        if (op_code != INVOKESTATIC) begin
            lva_addr <= lva_offset - lvamax + lva_index;
        end

        if (op_code == LDC) begin
            // control unit takes at least 2 clock cycles to read ldconst,
            // so just read it out here
            data_index[15:0] <= { arg1, arg2 };
            ldconst[31:0] <= dataparams[31:0];
        end
        
        case (invoke_state)
            IDLE: begin
                invoke_state <= IDLE;
            end
            LOADPARAMS: begin
                data_index[15:0] <= { arg1, arg2 };
                invoke_state <= PARAMWAIT;
            end
            PARAMWAIT: begin
                invoke_state <= FETCHPARAMS;
            end
            FETCHPARAMS: begin
                // { codeaddr[15:0], argcount[7:0], lvamax[7:0] } <= dataparams[31:0];
                codeaddr[15:0] <= dataparams[31:16];
                argcount[7:0] <= dataparams[15:8];
                lvamoveindex[7:0] <= dataparams[15:8];
                lvamax[7:0] <= dataparams[7:0];
                invoke_state <= LVALOAD;
            end
            LVALOAD: begin
                lva_offset <= lva_offset + lvamax;
                invoke_state <= LVAMOVE;
            end
            LVAMOVE: begin
                if (argcount > 0) begin
                    lvamove <= 1;
                    lva_addr <= lva_offset - lvamoveindex;
                    lvamoveindex <= lvamoveindex - 1;
                    invoke_state <= LVAWAIT;
                end
                else begin
                    invoke_state <= LVADONE;
                end
            end
            LVAWAIT: begin
                if (lvamovedone) begin
                    argcount <= argcount - 1;
                    invoke_state <= LVAMOVE;
                end
                lvamove <= 0;
            end
            LVADONE: begin
                invoke_state <= CS_PUSH;
            end
            CS_PUSH: begin
                callwrite[31:16] = pc + 3;
                callwrite[15:0] = { 8'b00, lva_offset - lvamax };
                callpush <= 1;
                calltrigger <= 1;
                invoke_state <= CS_WAIT;
            end
            CS_WAIT: begin
                if (calldone) begin
                    callpush <= 0;
                    invoke_state <= INVOKE;
                end
                calltrigger <= 0;
            end
            INVOKE: begin
                // jump to invoked function's code address
                pc <= codeaddr;
                invoke_state <= INVOKEDONE;
            end
            RET: begin
                if (calldone) begin
                    pc <= callread[31:16];
                    lva_offset <= callread[7:0];
                    invoke_state <= IDLE;
                end
                calltrigger <= 0;
            end
            INVOKEDONE: begin
                invoke_state <= IDLE;
            end
            default: begin
            end
        endcase
        
        if (op_code == INVOKESTATIC) begin
            if (invoke_state == IDLE) begin
                invoke_state <= LOADPARAMS;
            end
        end
        
        if (op_code == IRETURN || op_code == ARETURN || op_code == RETURN) begin
            callpush <= 0;
            calltrigger <= 1;
            invoke_state <= RET;
        end     
        
        if (rst) begin
            data_index <= 16'b0000;
            lva_offset <= 8'b00;
            invoke_state <= PARAMWAIT;
        end
        
    end

    assign program_counter = pc;
    assign dataindex = data_index;

endmodule