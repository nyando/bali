`timescale 10ns / 10ns

module test_run();

    test_cpu_prog #(.PROG("tests/progs/arrayops.mem"))     arraytest();
    test_cpu_prog #(.PROG("tests/progs/localvars.mem"))    lvatest();
    test_cpu_prog #(.PROG("tests/progs/jumps.mem"))        jumptest();
    test_cpu_prog #(.PROG("tests/progs/push_and_alu.mem")) alutest();

    initial begin
        arraytest.rst = 0;
        lvatest.rst = 0;
        jumptest.rst = 0;
        alutest.rst = 0;
        #1;
        arraytest.rst = 1;
        lvatest.rst = 1;
        jumptest.rst = 1;
        alutest.rst = 1;
        #1;
        arraytest.rst = 0;
        lvatest.rst = 0;
        jumptest.rst = 0;
        alutest.rst = 0;
        #250;
    end

endmodule