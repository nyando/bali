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
        #11000;

        assert (intreversetest.uut_cpu.op_code == 8'h00) else $fatal(1, "opcode in integer reverse test not NOP, program did not terminate correctly");
        assert (primesievetest.uut_cpu.op_code == 8'h00) else $fatal(1, "opcode in prime sieve test not NOP, program did not terminate correctly");
        assert (quicksorttest.uut_cpu.op_code == 8'h00) else $fatal(1, "opcode in quicksort test not NOP, program did not terminate correctly");
        assert (recursivemathtest.uut_cpu.op_code == 8'h00) else $fatal(1, "opcode in recursive math test not NOP, program did not terminate correctly");
        assert (towerstest.uut_cpu.op_code == 8'h00) else $fatal(1, "opcode in towers of hanoi test not NOP, program did not terminate correctly");

        $finish;
    end

endmodule