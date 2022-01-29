`timescale 10ns / 10ns

module cpu(
    input clk,
    input [7:0] op_code,
    input [7:0] arg1,
    input [7:0] arg2,
    output [7:0] program_counter
);

    logic stackpush;
    logic stacktrigger;
    logic [31:0] stackwrite;
    logic [31:0] stackread;
    logic stackdone;

    stack32 eval_stack (
        .clk(clk),
        .push(stackpush),
        .trigger(stacktrigger),
        .write_value(stackwrite),
        .read_value(stackread),
        .done_out(stackdone)
    );

    logic [7:0] pc;
    logic [1:0] argc;
    logic op_done;

    control control_unit (
        .clk(clk),
        .op_code(op_code),
        .arg1(arg1),
        .arg2(arg2),
        .stackread(stackread),
        .stackdone(stackdone),
        .stackwrite(stackwrite),
        .stackpush(stackpush),
        .stacktrigger(stacktrigger),
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