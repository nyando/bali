`timescale 10ns / 10ns

module test_recursivemath();

    logic rst;

    test_cpu_prog #(.PROG("tests/progs/recursivemath.mem")) recursivemathtest(.rst(rst));

    logic [31:0] expected;
    logic [31:0] found;

    initial begin
        rst = 0;
        #1;
        rst = 1;
        #1;
        rst = 0;
        #10000;
        $finish;
    end

endmodule