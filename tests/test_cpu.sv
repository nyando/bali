`timescale 10ns / 10ns

module test_cpu();

    logic clk;

    sim_clk clock (
        .clk(clk)
    );

    // instruction memory
    logic [7:0] mem [255:0];
    
    // opcode is input to cpu
    logic [7:0] opcode;
    
    // always assign two following bytes to arg1 and arg2, but only use when necessary
    logic [7:0] arg1;
    logic [7:0] arg2;
    
    // cpu outputs new program counter after executing
    logic [7:0] pc;

    cpu uut_cpu (
        .clk(clk),
        .op_code(opcode),
        .arg1(arg1),
        .arg2(arg2),
        .program_counter(pc)
    );

    initial begin
        $readmemh("tests/progs/push_and_alu.txt", mem);
        opcode <= 8'h00;
        #200;
        $finish(0, "test done");
    end

    always @ (negedge clk) begin
        opcode <= mem[pc];
        arg1 <= mem[pc + 1];
        arg2 <= mem[pc + 2];
    end

endmodule