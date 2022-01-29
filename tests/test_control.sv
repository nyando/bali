`timescale 10ns / 10ns

module test_control();

    sim_clk clock (
        .clk(clk)
    );

    logic [7:0] op_code;
    logic [1:0] argcount;
    logic opdone;

    logic [7:0] progmem [31:0];
    logic [7:0] pc;

    control ctrl (
        .clk(clk),
        .op_code(op_code),
        .argcount(argcount),
        .op_done(opdone)
    );

    initial begin
        op_code <= 8'h00;
        #20;
        op_code <= 8'h02; // push -1 to stack
        #6;
        op_code <= 8'h05; // push 2 to stack
        #6;
        op_code <= 8'h05; // push 2 to stack
        #6;
        op_code <= 8'h60; // add two topmost stack elements and push result
        #12;
        op_code <= 8'h60;
        #12;
        op_code <= 8'h00;
        #20;
        $finish;
    end

endmodule