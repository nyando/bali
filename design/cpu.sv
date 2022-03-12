`timescale 10ns / 10ns

module cpu(
    input clk,
    input [7:0] op_code,            // current opcode
    input [7:0] arg1,               // (optional) first argument to the current opcode
    input [7:0] arg2,               // (optional) second argument to the current opcode
    input [31:0] dataparams,        // 32-bit data segment containing either method invocation parameters or constants
    output [15:0] dataindex,        // index of data segment to load into dataparams
    output [15:0] program_counter   // memory address of current/next opcode
);

    logic lva_write;                // hi if writing to LVA, lo if reading/idle
    logic [31:0] lva_in;            // value to write to LVA
    logic [7:0] lva_addr;           // address of LVA to read from or write to
    logic [31:0] lva_out;           // value at current lva_addr
    logic lva_trigger;              // hi for one clock cycle when reading/writing
    logic lva_done;                 // hi for one clock cycle when read/write done

    // local variable array holds variables for all methods that have not returned yet
    lva #(
        .LVA_SIZE(256)
    ) localvars (
        .clk(clk),
        .write(lva_write),
        .trigger(lva_trigger),
        .addr(lva_addr),
        .writevalue(lva_in),
        .readvalue(lva_out),
        .done(lva_done)
    );

    logic [7:0] lva_index;          // method-local index of local variable to read/write
    logic [7:0] stack_offset;       // absolute address in the LVA is call stack offset + index 
    logic op_done;                  // hi for one clock cycle when instruction finishes execution
    logic [15:0] offset;            // offset of next instruction to current pc value

    // control unit executes the code within a method
    control control_unit (
        .clk(clk),
        .op_code(op_code),
        .arg1(arg1),
        .arg2(arg2),
        .lvadone(lva_done),
        .lvaread(lva_out),
        .lvawrite(lva_in),
        .lvaindex(lva_index),
        .lvaop(lva_write),
        .lvatrigger(lva_trigger),
        .offset(offset),
        .op_done(op_done)
    );

    logic lvastack_push;
    logic lvastack_trigger;
    logic [31:0] lvastack_write;
    logic [31:0] lvastack_read;
    logic lvastack_done;

    stack32 lvaoffsets (
        .clk(clk),
        .push(lvastack_push),
        .trigger(lvastack_trigger),
        .write_value(lvastack_write),
        .read_value(lvastack_read),
        .done_out(lvastack_done)
    );

    logic callstack_push;
    logic callstack_trigger;
    logic [31:0] callstack_write;
    logic [31:0] callstack_read;
    logic callstack_done;

    stack32 callstack (
        .clk(clk),
        .push(callstack_push),
        .trigger(callstack_trigger),
        .write_value(callstack_write),
        .read_value(callstack_read),
        .done_out(callstack_done)
    );

    const logic [7:0] INVOKESTATIC = 8'hb8;

    const logic [1:0] IDLE   = 2'b00;
    const logic [1:0] STORE  = 2'b01;
    const logic [1:0] INVOKE = 2'b10;

    logic [15:0] pc;                // program counter register, holds address of current instruction
    logic [15:0] data_index;
    logic [1:0] invoke_state;
    
    initial begin
        pc <= 8'h00;
    end

    always @ (posedge clk) begin
        if (op_done) begin
            // increase program counter by offset
            pc <= pc + offset;
        end
        lva_addr <= lva_index;

        if (op_code == INVOKESTATIC) begin
            invoke_state <= STORE;
        end
        
        case (invoke_state)
            IDLE: begin
                invoke_state <= IDLE;
            end
            STORE: begin
                data_index[15:0] <= {arg1, arg2} * 4;
            end
            default: begin
            end
        endcase
    end

    assign program_counter = pc;

endmodule