`timescale 10ns / 10ns

function bit isprime(input int x);
    for (int i = 2; i < x; i++) begin
        if (x % i == 0) return 0;
    end
    return 1;
endfunction

module test_sampleprogs();

    logic rst;

    test_cpu_prog #(.PROG("tests/progs/IntReverse.mem")) intreversetest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/PrimeSieve.mem")) primesievetest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/QuickSort.mem")) quicksorttest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/RecursiveMath.mem")) recursivemathtest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/TowersOfHanoi.mem")) towerstest(.rst(rst));

    logic [31:0] expected;
    logic [31:0] found;

    const int primesieve_size = 20;
    int mem [8] = '{ 1, 2, 3, 4, 6, 7, 8, 9 };

    initial begin
        rst = 0;
        #1;
        rst = 1;
        #1;
        rst = 0;
        #11000;

        assert (intreversetest.uut_cpu.op_code == 8'hff) else $fatal(1, "opcode in integer reverse test not NOP, program did not terminate correctly");
        expected = 32'd321;
        found = intreversetest.uut_cpu.eval_stack.memory.mem[0];
        assert (expected == found) else $fatal(1, "expected final value %8h on stack, found %8h", expected, found);

        assert (primesievetest.uut_cpu.op_code == 8'hff) else $fatal(1, "opcode in prime sieve test not NOP, program did not terminate correctly");
        for (int i = 2; i < primesieve_size; i++) begin
            expected = isprime(i);
            found = primesievetest.uut_cpu.staticarray.arrmem.mem[i] > 0;
            assert (expected == found) else $fatal(1, "expected primality value of %8h to be %8h, found %8h", i, expected, found);
        end
        
        assert (quicksorttest.uut_cpu.op_code == 8'hff) else $fatal(1, "opcode in quicksort test not NOP, program did not terminate correctly");
        for (int i = 0; i < $size(mem); i++) begin
            expected = mem[i];
            found = quicksorttest.uut_cpu.staticarray.arrmem.mem[i]; 
            assert (expected == found) else $fatal(1, "expected %8h in sorted array at %d, found %8h", expected, i, found);
        end

        assert (recursivemathtest.uut_cpu.op_code == 8'hff) else $fatal(1, "opcode in recursive math test not NOP, program did not terminate correctly");
        expected = 32'h9;
        found = recursivemathtest.uut_cpu.eval_stack.memory.mem[0];
        assert (expected == found) else $fatal(1, "expected final value %8h on stack, found %8h", expected, found);

        assert (towerstest.uut_cpu.op_code == 8'hff) else $fatal(1, "opcode in towers of hanoi test not NOP, program did not terminate correctly");
        expected = 32'h1;
        found = towerstest.uut_cpu.callstack.top_of_stack;
        assert (expected == found) else $fatal(1, "expected final top of callstack value %8h, found %8h", expected, found);

        $finish;
    end

endmodule