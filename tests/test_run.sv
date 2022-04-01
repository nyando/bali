`timescale 10ns / 10ns

module test_run();

    logic rst;

    test_cpu_prog #(.PROG("tests/progs/arrayops.mem"))   arraytest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/localvars.mem"))  lvatest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/jumps.mem"))      jumptest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/alustack.mem"))   alutest(.rst(rst));
    test_cpu_prog #(.PROG("tests/progs/invoketest.mem")) invoketest(.rst(rst));

    logic [31:0] expected;
    logic [31:0] found;
    logic [15:0] top_of_stack;
    
    initial begin
        // trigger reset on cpu
        rst = 0;
        #1;
        rst = 1;
        #1;
        rst = 0;
        
        // let programs run to completion
        #250;

        // test terminal conditions of each program
        assert (arraytest.uut_cpu.op_code == 8'h00) else $fatal(1, "opcode in arraytest not NOP, program did not terminate correctly");
        expected = 32'hffff_cafe;
        found = arraytest.uut_cpu.staticarray.arrmem.mem[0];
        assert (expected == found) else $fatal(1, "expected %8h in array entry 0, found %8h", expected, found);
        found = arraytest.uut_cpu.eval_stack.memory.mem[0];
        assert (expected == found) else $fatal(1, "expected %8h on stack entry 0, found %8h", expected, found);
        expected = 32'hffff_babe;
        found = arraytest.uut_cpu.staticarray.arrmem.mem[1];
        assert (expected == found) else $fatal(1, "expected %8h in array entry 1, found %8h", expected, found);
        found = arraytest.uut_cpu.eval_stack.memory.mem[1];
        assert (expected == found) else $fatal(1, "expected %8h in stack entry 1, found %8h", expected, found);
        top_of_stack = arraytest.uut_cpu.eval_stack.top_of_stack;
        assert (top_of_stack == 16'h0002) else $fatal(1, "expected 2 entries on stack, found %4h", top_of_stack);

        assert (lvatest.uut_cpu.op_code == 8'h00) else $fatal(1, "opcode in lvatest not NOP, program did not terminate correctly");
        expected = 32'hffff_babe;
        found = lvatest.uut_cpu.localvars.arrmem.mem[0];
        assert (expected == found) else $fatal(1, "expected %8h in LVA entry 0, found %8h", expected, found);
        found = lvatest.uut_cpu.eval_stack.memory.mem[0];
        assert (expected == found) else $fatal(1, "expected %8h in stack entry 0, found %8h", expected, found);
        expected = 32'hffff_cafe;
        found = lvatest.uut_cpu.localvars.arrmem.mem[1];
        assert (expected == found) else $fatal(1, "expected %8h in LVA entry 1, found %8h", expected, found);
        found = lvatest.uut_cpu.eval_stack.memory.mem[1];
        assert (expected == found) else $fatal(1, "expected %8h in stack entry 1, found %8h", expected, found);
        top_of_stack = lvatest.uut_cpu.eval_stack.top_of_stack;
        assert (top_of_stack == 16'h0002) else $fatal(1, "expected 2 entries on stack, found %4h", top_of_stack);

        assert (jumptest.uut_cpu.op_code == 8'h00) else $fatal(1, "opcode in jump test not NOP, program did not terminate correctly");
        top_of_stack = jumptest.uut_cpu.eval_stack.top_of_stack;
        assert (top_of_stack == 16'h0000) else $fatal(1, "expected empty stack, found %4h entries", top_of_stack);
        
        assert (alutest.uut_cpu.op_code == 8'h00) else $fatal(1, "opcode in ALU and stack test not NOP, program did not terminate correctly");
        top_of_stack = alutest.uut_cpu.eval_stack.top_of_stack;
        assert (top_of_stack == 16'h0001) else $fatal(1, "expected one stack entry, found %4h entries", top_of_stack);
        expected = 32'hcafe_babe;
        found = alutest.uut_cpu.eval_stack.memory.mem[0];
        assert (expected == found) else $fatal(1, "expected %8h in stack entry 0, found %8h", expected, found);

        assert (invoketest.uut_cpu.op_code == 8'h00) else $fatal(1, "opcode in invoke test not NOP, program did not terminate correctly");
        
        $finish;
    end

endmodule