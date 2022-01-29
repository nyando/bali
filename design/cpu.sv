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
    logic jmp;
    logic [15:0] jmpaddr;

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
        .jmp(jmp),
        .jmpaddr(jmpaddr),
        .op_done(op_done)
    );

    initial begin
        pc <= 8'h00;
    end

    always @ (posedge clk) begin
        if (op_done) begin
            if (jmp) begin
                pc[7:0] <= jmpaddr[7:0];
            end
            else begin
                // program counter increases by 1 more than the number of arguments in the bytecode
                pc <= pc + 1 + argc;
            end
        end
    end

    assign program_counter = pc;

endmodule