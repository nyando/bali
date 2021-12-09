`timescale 10ns / 10ns

module control(
    input clk,
    input [31:0] op_code
);

    logic [7:0] opcode;
    logic [3:0] aluop;
    logic [1:0] argc;
    logic [1:0] stackargs;
    logic stackwb;
    logic stack_constpush;
    logic [31:0] stack_constval;

    decoder decoder (
        .opcode(opcode),
        .aluop(aluop),
        .argc(argc),
        .stackargs(stackargs),
        .stackwb(stackwb),
        .constpush(stack_constpush),
        .constval(stack_constval)
    );

    logic [7:0] arg1;
    logic [7:0] arg2;

    logic stack_push;
    logic stack_trigger;
    logic [31:0] stack_read;
    logic [31:0] stack_write;
    logic stack_done;

    stack stack (
        .clk(clk),
        .push(stack_push),
        .trigger(stack_trigger),
        .write_value(stack_write),
        .read_value(stack_read),
        .done_out(stack_done)
    );
    
    logic [31:0] operand_a;
    logic [31:0] operand_b;
    
    alu alu (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .op_select(aluop),
        .result_lo(stack_write),
        .result_hi(result_hi)
    );

    logic [1:0] stackarg_counter;
    logic [1:0] state;

    const logic [2:0] IDLE   = 3'b000;
    const logic [2:0] FETCH  = 3'b001;
    const logic [2:0] S_LOAD = 3'b010;
    const logic [2:0] EXEC   = 3'b011;
    const logic [2:0] WRITE  = 3'b100;

    always @ (posedge clk) begin
        case (state)
            IDLE: begin
                if (opcode != 0) begin
                    state <= FETCH;
                    stackarg_counter <= stackargs;
                end
            end
            FETCH: begin
                state <= STACK_LOAD;
                if (stack_constpush) begin
                    if (stack_done) begin
                        state <= IDLE;
                    end
                end
            end
            S_LOAD: begin
                if (stack_done) begin
                    case (stackarg_counter)
                        2'b11: begin
                            stackarg_counter <= stackarg_counter - 1;
                        end
                        2'b10: begin
                            stack_push <= 0;
                            stack_trigger <= 1;
                            stackarg_counter <= stackarg_counter - 1;
                        end
                        2'b01: begin
                            operand_b[31:0] <= stack_read[31:0];
                            stack_push <= 0;
                            stack_trigger <= 1;
                            stackarg_counter <= stackarg_counter - 1;
                        end
                        2'b00: begin
                            operand_a[31:0] <= stack_read[31:0];
                            state <= EXEC;
                        end
                        default: begin end
                    endcase
                end
                else begin
                    stack_trigger <= 0;
                end
            end
            EXEC: begin
                state <= WRITE;
                stack_trigger <= 1;
            end
            WRITE: begin
                if (stackwb) begin
                    if (stack_done) begin
                        state <= IDLE;
                    end
                    else begin
                        stack_trigger <= 0;
                    end
                end
            end
            default: begin end
        endcase
    end

endmodule