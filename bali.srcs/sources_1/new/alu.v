`timescale 1ns / 1ps

module alu(
    input [31:0] operand_a,
    input [31:0] operand_b,
    input [3:0] op_select,
    output reg [31:0] result_lo,
    output reg [31:0] result_hi
    );

    parameter IINC = 4'b0000;
    parameter IADD = 4'b0001;
    parameter ISUB = 4'b0010;
    parameter IMUL = 4'b0011;
    parameter IDIV = 4'b0100;
    parameter IREM = 4'b0101;
    parameter IAND = 4'b0110;
    parameter IOR  = 4'b0111;
    parameter IXOR = 4'b1000;
    parameter INEG = 4'b1001;
    parameter ISHL = 4'b1010;
    parameter ISHR = 4'b1011;

    always @ (operand_a, operand_b, op_select)
        begin
            case (op_select)
                // iinc: increment integer (unary, use operand_a)
                IINC: begin
                    result_lo = operand_a + 1;
                end
                // iadd: add two integers
                IADD: begin
                    result_lo = operand_a + operand_b;
                end
                // isub: subtract two integers
                ISUB: begin
                    result_lo = operand_a - operand_b;
                end
                // imul: multiply two integers
                IMUL: begin
                    {result_hi, result_lo} = operand_a * operand_b;
                end
                // idiv: divide two integers
                IDIV: begin
                    result_lo = operand_a / operand_b;
                end
                // irem: modulo of two integers
                IREM: begin
                    result_lo = operand_a % operand_b;
                end
                // iand: bitwise AND of two integers
                IAND: begin
                    result_lo = operand_a & operand_b;
                end
                // ior: bitwise OR of two integers
                IOR: begin
                    result_lo = operand_a | operand_b;
                end
                // ixor: bitwise XOR of two integers
                IXOR: begin
                    result_lo = operand_a ^ operand_b;
                end
                // ineg: bitwise negation of two integers
                INEG: begin
                    result_lo = ~operand_a;
                end
                // ishl: shift integer left
                ISHL: begin
                    result_lo = operand_a << 1;
                end
                // ishr: shift integer right
                ISHR: begin
                    result_lo = operand_a >> 1;
                end
                default: begin
                    result_lo = 32'hXXXX;
                    result_hi = 32'hXXXX;
                end
            endcase
        end

endmodule
