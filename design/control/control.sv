`include "headers/comp_types.vh"

`timescale 10ns / 10ns

module control(
    input clk,
    input [7:0] op_code,
    input [7:0] arg1,
    input [7:0] arg2,
    input [31:0] stackread,
    input stackdone,
    output [31:0] stackwrite,
    output stackpush,
    output stacktrigger,
    output [1:0] argcount,
    output jmp,
    output [15:0] jmpaddr,
    output op_done
);

    logic done;                     // set to HI for 1 clock cycle when fetch-execute cycle is completed

    logic [3:0] aluop;              // operation code to pass to ALU
    logic isaluop;                  // 1 if operation uses the ALU, 0 otherwise
    logic iscmp;
    logic [3:0] cmptype;
    logic isargpush;
    logic [1:0] argc;               // number of arguments in code (max 2)
    logic [1:0] stackargs;          // number of elements to pop from stack
    logic stackwb;
    logic stack_constpush;
    logic [31:0] stack_constval;

    decoder decoder (
        .opcode(op_code),
        .aluop(aluop),
        .isaluop(isaluop),
        .iscmp(iscmp),
        .cmptype(cmptype),
        .isargpush(isargpush),
        .argc(argc),
        .stackargs(stackargs),
        .stackwb(stackwb),
        .constpush(stack_constpush),
        .constval(stack_constval)
    );

    // stack control
    logic stack_push;
    logic stack_trigger;
    logic [31:0] stack_read;
    logic [31:0] stack_write;
    logic stack_done;

    // ALU integration
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [31:0] result_lo;
    logic [31:0] result_hi;
    
    alu alu (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .op_select(aluop),
        .result_lo(result_lo),
        .result_hi(result_hi)
    );

    // number of arguments to pop from the stack
    logic [1:0] stackarg_counter;

    // internal state of the control module
    logic [2:0] state;
    const logic [2:0] IDLE   = 3'b000;
    const logic [2:0] FETCH  = 3'b001;
    const logic [2:0] DECODE = 3'b010;
    const logic [2:0] S_LOAD = 3'b011;
    const logic [2:0] COMP   = 3'b100;
    const logic [2:0] EXEC   = 3'b101;
    const logic [2:0] WRITE  = 3'b110;

    // jump ops
    logic [15:0] addr;
    logic jump;

    initial begin
        state <= IDLE;
        stack_trigger <= 0;
    end

    always @ (posedge clk) begin
        case (state)
            IDLE: begin
                done <= 0;
                jump <= 0;
                if (op_code != 8'h00) begin
                    state <= FETCH;
                end
                else begin
                    state <= IDLE;
                end
            end
            FETCH: begin
                if (stack_constpush || isargpush) begin
                    state <= DECODE;
                end
                if (isaluop || iscmp) begin
                    state <= DECODE;
                    stackarg_counter <= stackargs;
                end
            end
            DECODE: begin
                if (stack_constpush || isargpush) begin
                    state <= EXEC;
                end
                if (isaluop || iscmp) begin
                    stack_push <= 0;
                    stack_trigger <= 1;
                    stackarg_counter <= stackarg_counter - 1;
                    state <= S_LOAD;
                end
            end
            S_LOAD: begin
                if (stackdone) begin
                    case (stackarg_counter)
                        2'b11: begin
                            stackarg_counter <= stackarg_counter - 1;
                        end
                        2'b10: begin
                            // three arguments to pop from stack
                            stack_push <= 0;
                            stack_trigger <= 1;
                            stackarg_counter <= stackarg_counter - 1;
                        end
                        2'b01: begin
                            // two arguments to pop from stack
                            if (isaluop || iscmp) begin
                                operand_b[31:0] <= stackread[31:0];
                            end
                            stack_push <= 0;
                            stack_trigger <= 1;
                            stackarg_counter <= stackarg_counter - 1;
                        end
                        2'b00: begin
                            // one argument to pop from stack
                            if (isaluop || iscmp) begin
                                operand_a[31:0] <= stackread[31:0];
                            end
                            if (iscmp) begin
                                state <= COMP;
                            end
                            else begin
                                state <= EXEC;
                            end
                        end
                        default: begin end
                    endcase
                end
                else begin
                    stack_trigger <= 0;
                end
            end
            COMP: begin // comparison operation
                // jump to this address if comparison is true
                addr <= {arg1, arg2};
                // int32 comparison, two stack arguments
                case (cmptype[2:0])
                    EQ: begin
                        jump <= operand_a == (cmptype[3] ? operand_b : 32'h0000_0000);
                    end
                    NE: begin
                        jump <= operand_a != (cmptype[3] ? operand_b : 32'h0000_0000);
                    end
                    LT: begin
                        jump <= operand_a < (cmptype[3] ? operand_b : 32'h0000_0000);
                    end
                    LE: begin
                        jump <= operand_a <= (cmptype[3] ? operand_b : 32'h0000_0000);
                    end
                    GE: begin
                        jump <= operand_a >= (cmptype[3] ? operand_b : 32'h0000_0000);
                    end
                    GT: begin
                        jump <= operand_a > (cmptype[3] ? operand_b : 32'h0000_0000);
                    end
                    default: begin end
                endcase
                state <= EXEC;
            end
            EXEC: begin
                if (stack_constpush) begin
                    stack_write[31:0] <= stack_constval[31:0];
                end
                if (isaluop) begin
                    stack_write[31:0] <= result_lo[31:0];
                end
                if (isargpush) begin
                    if (argc == 2'b01) begin
                        stack_write[7:0] = arg1;
                        // sign extension
                        if (arg1[7]) begin
                            stack_write[31:8] = 24'hffff_ff;
                        end
                        else begin
                            stack_write[31:8] = 24'h0000_00;
                        end
                    end
                    else if (argc == 2'b10) begin
                        stack_write[15:0] = {arg1, arg2};
                        // sign extension
                        if (arg1[7]) begin
                            stack_write[31:16] = 16'hffff;
                        end
                        else begin
                            stack_write[31:16] = 16'h0000;
                        end
                    end
                end
                // write value to stack if stackwb bit is set
                if (stackwb) begin
                    stack_push <= 1;
                    state <= WRITE;
                    stack_trigger <= 1;
                end
                else begin
                    state <= IDLE;
                    done <= 1;
                end
            end
            WRITE: begin
                if (stackwb) begin
                    if (stackdone) begin
                        state <= IDLE;
                        done <= 1;
                    end
                    else begin
                        stack_trigger <= 0;
                    end
                end
            end
            default: begin end
        endcase
    end

    assign op_done = done;
    assign argcount = argc;
    assign stackwrite = stack_write;
    assign stackpush = stack_push;
    assign stacktrigger = stack_trigger;
    assign jmp = jump;
    assign jmpaddr = addr;

endmodule