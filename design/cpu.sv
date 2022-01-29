`timescale 10ns / 10ns

module cpu(
    input clk,
    input [7:0] op_code,
    output [7:0] program_counter
);

    logic [7:0] pc;
    logic [1:0] argc;
    logic op_done;

    control control_unit (
        .clk(clk),
        .op_code(op_code),
        .argcount(argc),
        .op_done(op_done)
    );

    initial begin
        pc <= 8'h00;
    end

    always @ (negedge clk) begin
        if (op_done) begin
            pc <= pc + 1 + argc;
        end
    end

    assign program_counter = pc;

endmodule