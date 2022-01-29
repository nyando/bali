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
    
    // cpu outputs new program counter after executing
    logic [7:0] pc;

    cpu cpu_under_test (
        .clk(clk),
        .op_code(opcode),
        .program_counter(pc)
    );

    initial begin
        $readmemh("tests/memory.txt", mem);
        opcode <= 8'h00;
        #100;
        $finish(0, "test done");
    end

    always @ (negedge clk) begin
        opcode <= mem[pc];
    end

endmodule