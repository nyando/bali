`timescale 10ns / 10ns

module test_intreverse();

    logic rst;

    test_cpu_prog #(.PROG("tests/progs/intreverse.mem")) intreversetest(.rst(rst));

    logic [31:0] expected;
    logic [31:0] found;

    initial begin
        rst = 0;
        #1;
        rst = 1;
        #1;
        rst = 0;
        #1300;

        expected = 32'h0000_d431;
        found = intreversetest.uut_cpu.eval_stack.memory.mem[0];
        assert (expected == found) else $fatal(1, "int reverse has wrong result, expected %8h, got %8h", expected, found);

        $finish;
    end

endmodule