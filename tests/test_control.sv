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
        
        
    end

endmodule