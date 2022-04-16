`timescale 10ns / 10ns

module test_alu();

    logic [31:0] a, b, result;
    logic [3:0] op_select;
    
    alu testunit(
        .operand_a(a),
        .operand_b(b),
        .op_select(op_select),
        .result(result)
    );

    initial begin
        // iadd: ff + ff
        a = (b = 32'h000000FF);
        //b = 32'h000000FF;
        op_select = 4'b0000;
        #10;
        assert (result == 32'h000001FE) else
            $fatal(1, "Addition result incorrect");
        $display("Addition works");
        // idiv: ff / ff
        a = 32'h000000FF;
        b = 32'h000000FF;
        op_select = 4'b0011;
        #10;
        assert (result == 32'h00000001) else
            $fatal(1, "Division result incorrect");
        $display("Division works");
        // iand: ff & ff
        a = 32'h000000FF;
        b = 32'h000000FF;
        op_select = 4'b1111;
        #10;
        assert (result == 32'h000000FF) else
            $fatal(1, "Logical AND result incorrect");
        $display("Logical AND works");
        $display("Testbench completed");
        $finish;
    end

endmodule
