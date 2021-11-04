`timescale 1ns / 1ps

module alu_test();

    // inputs: operands and operator
    logic [31:0] a;
    logic [31:0] b;
    logic [3:0] op_select;
    // outputs: result
    wire [31:0] result_lo;
    wire [31:0] result_hi;
    
    alu testunit(.operand_a(a),
                 .operand_b(b),
                 .op_select(op_select),
                 .result_lo(result_lo),
                 .result_hi(result_hi));

    initial begin
        // iinc: ff
        a = 32'h000000FF;
        b = 32'h000000FF;
        op_select = 4'b0000;
        #10;
        // iadd: ff + ff
        a = 32'h000000FF;
        b = 32'h000000FF;
        op_select = 4'b0001;
        #10;
        // idiv: ff / ff
        a = 32'h000000FF;
        b = 32'h000000FF;
        op_select = 4'b0100;
        #10;
        // iand: ff & ff
        a = 32'h000000FF;
        b = 32'h000000FF;
        op_select = 4'b0110;
    end

endmodule
