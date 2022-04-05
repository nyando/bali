`timescale 10ns / 10ns

module test_sampleprogs();

    logic rst;

    test_cpu_prog #(.PROG("tests/progs/intreverse.mem")) intreversetest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/primesieve.mem")) primesievetest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/quicksort.mem")) quicksorttest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/recursivemath.mem")) recursivemathtest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/towers.mem")) towerstest(.rst(rst));

    logic [31:0] expected;
    logic [31:0] found;

    initial begin
        rst = 0;
        #1;
        rst = 1;
        #1;
        rst = 0;
        #1000;
        $finish;
    end

endmodule