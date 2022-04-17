`timescale 10ns / 10ns

module test_divmod();

    logic clk;

    sim_clk simclk (
        .clk(clk)
    );

    logic [31:0] operand_a, operand_b, quot, rem;
    logic trigger, done;

    divmod #(
        .WIDTH(32)
    ) divider (
        .clk(clk),
        .trigger(trigger),
        .done(done),
        .a(operand_a),
        .b(operand_b),
        .q(quot),
        .r(rem)
    );

    initial begin
        operand_a = 12345;
        operand_b = 10;
        trigger = 0;
        #1;
        trigger = 1;
        #1;
        trigger = 0;
        #50;
        assert (quot == 1234) else $fatal(1, "expected quotient %d, got %d", 1234, quot);
        assert (rem == 5) else $fatal(1, "expected remainder %d, got %d", 5, rem);
        $finish;
    end

endmodule