`timescale 10ns / 10ns

module alu(
    input [31:0] operand_a,
    input [31:0] operand_b,
    input [3:0] op_select,
    output logic [31:0] result_lo,
    output logic [31:0] result_hi
);

    const logic [3:0] IADD = 4'b0000;
    const logic [3:0] ISUB = 4'b0001;
    const logic [3:0] IMUL = 4'b0010;
    const logic [3:0] IDIV = 4'b0011;
    const logic [3:0] IREM = 4'b0100;
    const logic [3:0] INEG = 4'b0101;
    const logic [3:0] ISHL = 4'b1100;
    const logic [3:0] ISHR = 4'b1101;
    const logic [3:0] IAND = 4'b1111;
    const logic [3:0] IOR  = 4'b1000;
    const logic [3:0] IXOR = 4'b1001;

    always @ (op_select or operand_a or operand_b)
        begin
            case (op_select)
                // iadd: add two integers
                IADD: begin
                    result_lo = operand_a + operand_b;
                end
                // isub: subtract two integers
                ISUB: begin
                    result_lo = operand_a - operand_b;
                end
                // imul: multiply two integers
                /*IMUL: begin
                    {result_hi, result_lo} = operand_a * operand_b;
                end
                // idiv: divide two integers
                IDIV: begin
                    result_lo = operand_a / operand_b;
                end
                // irem: modulo of two integers
                IREM: begin
                    result_lo = operand_a % operand_b;
                end*/
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
                    result_lo = operand_a << (operand_b & 32'h0000_001f);
                end
                // ishr: shift integer right
                ISHR: begin
                    result_lo = operand_a >> (operand_b & 32'h0000_001f);
                end
                default: begin
                    result_lo = 32'hXXXX;
                    result_hi = 32'hXXXX;
                end
            endcase
        end

endmodule
