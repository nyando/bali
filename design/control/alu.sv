`timescale 10ns / 10ns

module alu(
    input [31:0] operand_a,
    input [31:0] operand_b,
    input [3:0] op_select,
    output logic [31:0] result
);

    const logic [3:0] IADD = 4'b0000;
    const logic [3:0] ISUB = 4'b0001;
    const logic [3:0] IMUL = 4'b0010;
    const logic [3:0] INEG = 4'b0101;
    const logic [3:0] ISHL = 4'b1100;
    const logic [3:0] ISHR = 4'b1101;
    const logic [3:0] IAND = 4'b1111;
    const logic [3:0] IOR  = 4'b1000;
    const logic [3:0] IXOR = 4'b1001;

    always_comb
        begin
            case (op_select)
                // iadd: add two integers
                IADD: begin
                    result = operand_a + operand_b;
                end
                // isub: subtract two integers
                ISUB: begin
                    result = operand_a - operand_b;
                end
                // imul: multiply two integers
                IMUL: begin
                    result = operand_a[15:0] * operand_b[15:0];
                end
                // iand: bitwise AND of two integers
                IAND: begin
                    result = operand_a & operand_b;
                end
                // ior: bitwise OR of two integers
                IOR: begin
                    result = operand_a | operand_b;
                end
                // ixor: bitwise XOR of two integers
                IXOR: begin
                    result = operand_a ^ operand_b;
                end
                // ineg: two's complement additive inverse of an integer
                INEG: begin
                    result = ~operand_a + 1;
                end
                // ishl: shift integer left
                ISHL: begin
                    result = operand_a << (operand_b & 32'h0000_001f);
                end
                // ishr: shift integer right
                ISHR: begin
                    result = operand_a >> (operand_b & 32'h0000_001f);
                end
                default: begin
                    result = 32'hXXXX;
                end
            endcase
        end

endmodule
