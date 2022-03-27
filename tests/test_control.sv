`timescale 10ns / 10ns

module test_control();

    sim_clk clock (
        .clk(clk)
    );

    logic [7:0] op_code;
    logic [7:0] arg1;
    logic [7:0] arg2;
    logic [15:0] offset;
    logic opdone;

    control uut_ctrl (
        .clk(clk),
        .op_code(op_code),
        .arg1(arg1),
        .arg2(arg2),
        .lvadone(),
        .lvaread(),
        .lvawrite(),
        .lvaindex(),
        .lvaop(),
        .lvatrigger(),
        .lvamove(),
        .lvamoveindex(),
        .lvamovedone(),
        .evalpush(),
        .evaltrigger(),
        .evalread(),
        .evalwrite(),
        .evaldone(),
        .ldconst(),
        .offset(offset),
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
        #14;
        op_code <= 8'h60;
        #14;
        op_code <= 8'h00;
        #20;
        $finish;
    end

endmodule