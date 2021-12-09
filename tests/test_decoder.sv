`timescale 10ns / 10ns

module test_decoder();

    int aluop_decode[int];

    logic [7:0] opcode;
    wire [3:0] aluop;
    wire [1:0] argc;

    decoder uut_decoder (
        .opcode(opcode),
        .aluop(aluop),
        .argc()
    );

    initial begin
        
        aluop_decode[8'h60] = 4'b0000;
        aluop_decode[8'h64] = 4'b0001;
        aluop_decode[8'h68] = 4'b0010;
        aluop_decode[8'h6c] = 4'b0011;
        aluop_decode[8'h70] = 4'b0100;
        aluop_decode[8'h74] = 4'b0101;
        aluop_decode[8'h78] = 4'b1100;
        aluop_decode[8'h7a] = 4'b1101;
        aluop_decode[8'h7e] = 4'b1111;
        aluop_decode[8'h80] = 4'b1000;
        aluop_decode[8'h82] = 4'b1001;
        aluop_decode[8'h84] = 4'b1010;

        opcode = 8'h00;
        #10;
        foreach (aluop_decode[i]) begin
            opcode = i;
            #10;
            assert (aluop == aluop_decode[i]) else
                $fatal(1, "decode to aluop failed");
        end

        opcode = 8'h02;
        #10;

        $finish;

    end

endmodule