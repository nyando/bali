`timescale 10ns / 10ns

module test_towers();

    logic rst;

    test_cpu_prog #(.PROG("tests/progs/towers.mem")) towerstest(.rst(rst));

    logic [31:0] expected;
    logic [31:0] found;

    initial begin
        rst = 0;
        #1;
        rst = 1;
        #1;
        rst = 0;
        #20000;
        $finish;
    end

endmodule