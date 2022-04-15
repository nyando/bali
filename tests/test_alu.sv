`timescale 10ns / 10ns

module test_alu();

    // inputs: operands and operator
    logic [31:0] a;
    logic [31:0] b;
    logic [3:0] op_select;
    // outputs: result
    wire [31:0] result;
    
    alu testunit(
        .operand_a(a),
        .operand_b(b),
        .op_select(op_select),
        .result(result)
    );

    initial begin
        // iinc: ff
        a = 32'h000000FF;
        b = 32'h000000FF;
        op_select = 4'b0000;
        #10;
        assert (result == 32'h00000100) else
            $fatal(1, "Increment result incorrect");
        $display("Increment works");
        // iadd: ff + ff
        a = 32'h000000FF;
        b = 32'h000000FF;
        op_select = 4'b0001;
        #10;
        assert (result == 32'h000001FE) else
            $fatal(1, "Addition result incorrect");
        $display("Addition works");
        // idiv: ff / ff
        a = 32'h000000FF;
        b = 32'h000000FF;
        op_select = 4'b0100;
        #10;
        assert (result == 32'h00000001) else
            $fatal(1, "Division result incorrect");
        $display("Division works");
        // iand: ff & ff
        a = 32'h000000FF;
        b = 32'h000000FF;
        op_select = 4'b0110;
        #10;
        assert (result == 32'h000000FF) else
            $fatal(1, "Logical AND result incorrect");
        $display("Logical AND works");
        $display("Testbench completed");
        $finish;
    end

endmodule
