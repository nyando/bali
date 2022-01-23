`timescale 10ns / 10ns

module control(
    input clk,
    input [7:0] op_code
);

    logic [7:0] pc;                 // max. 256 simple instructions, expand this as needed

    // class memory area
    block_ram #(
        .DATA(8),
        .SIZE(256)
    ) class_area (
        .clk(clk),
        .write_enable(),            // read-only memory area
        .data(),                    // no writing data
        .addr(pc),
        .data_out(data_out)
    );

    // static object area

    logic [3:0] aluop;              // operation code to pass to ALU
    logic isaluop;                  // 1 if operation uses the ALU, 0 otherwise
    logic [1:0] argc;               // number of arguments in code
    logic [1:0] stackargs;
    logic stackwb;
    logic stack_constpush;
    logic [31:0] stack_constval;

    decoder decoder (
        .opcode(op_code),
        .aluop(aluop),
        .isaluop(isaluop),
        .argc(argc),
        .stackargs(stackargs),
        .stackwb(stackwb),
        .constpush(stack_constpush),
        .constval(stack_constval)
    );

    logic [7:0] arg1;
    logic [7:0] arg2;

    // stack memory area
    logic stack_push;
    logic stack_trigger;
    logic [31:0] stack_read;
    logic [31:0] stack_write;
    logic stack_done;

    stack8 stack8 (
        .clk(clk),
        .push(stack_push),
        .trigger(stack_trigger),
        .write_value(stack_write),
        .read_value(stack_read),
        .done_out(stack_done)
    );
    
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

    logic [1:0] stackarg_counter;
    logic [2:0] state;

    const logic [2:0] IDLE   = 3'b000;
    const logic [2:0] FETCH  = 3'b001;
    const logic [2:0] S_LOAD = 3'b010;
    const logic [2:0] EXEC   = 3'b011;
    const logic [2:0] WRITE  = 3'b100;

    initial begin
        state <= IDLE;
        stack_trigger <= 0;
        pc <= 8'h00;
    end

    always @ (posedge clk) begin
        case (state)
            IDLE: begin
                if (op_code != 8'h00) begin
                    state <= FETCH;
                    stackarg_counter <= stackargs;
                end
                else begin
                    state <= IDLE;
                end
            end
            FETCH: begin
                if (stack_constpush) begin
                    state <= EXEC;
                end
                if (isaluop) begin
                    state <= S_LOAD;
                    stack_push <= 0;
                    stack_trigger <= 1;
                    stackarg_counter <= stackarg_counter - 1;
                end
            end
            S_LOAD: begin
                if (stack_done) begin
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
                            if (isaluop) begin
                                operand_b[31:0] <= stack_read[31:0];
                            end
                            stack_push <= 0;
                            stack_trigger <= 1;
                            stackarg_counter <= stackarg_counter - 1;
                        end
                        2'b00: begin
                            // one argument to pop from stack
                            if (isaluop) begin
                                operand_a[31:0] <= stack_read[31:0];
                            end
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
                if (stack_constpush) begin
                    stack_write[31:0] <= stack_constval[31:0];
                end
                if (isaluop) begin
                    stack_write[31:0] <= result_lo[31:0];
                end
                stack_push <= 1;
                state <= WRITE;
                stack_trigger <= 1;
            end
            WRITE: begin
                if (stackwb) begin
                    if (stack_done) begin
                        state <= IDLE;
                        pc <= pc + 1;
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