`timescale 10ns / 10ns

module test_control();

    sim_clk clock (
        .clk(clk)
    );

    logic [7:0] op_code;

    control ctrl (
        .clk(clk),
        .op_code(op_code)
    );

    initial begin
        op_code <= 8'h00;
        #20;
        op_code <= 8'h02; // push -1 to stack
        #8;
        op_code <= 8'h03; // push 0 to stack
        #8;
        op_code <= 8'h04; // push 1 to stack
        #8;
        op_code <= 8'h60; // add two topmost stack elements and push result
        #32;
        op_code <= 8'h00;
        #20;
        $finish;
    end

endmodule