`timescale 10ns / 10ns

module test_cpu_prog #(parameter PROG = "tests/progs/array_ops.mem");

    logic clk;
    logic rst;

    sim_clk simclock (
        .clk(clk)
    );

    logic write;
    logic [7:0] writeaddr;
    logic [7:0] writevalue;
    logic [7:0] constindex;
    logic [31:0] constparams;
    logic [15:0] pc;
    logic [7:0] opcode;
    logic [7:0] arg1;
    logic [7:0] arg2;

    progmem #(
        .SIZE(256)
    ) uut_progmem (
        .clk(clk),
        .write(write),
        .writeaddr(writeaddr),
        .writevalue(writevalue),
        .constindex(constindex),
        .constparams(constparams),
        .programcounter(pc),
        .opcode(opcode),
        .arg1(arg1),
        .arg2(arg2)
    );

    cpu uut_cpu (
        .clk(clk),
        .rst(rst),
        .op_code(opcode),
        .arg1(arg1),
        .arg2(arg2),
        .dataparams(constparams),
        .dataindex(constindex),
        .program_counter(pc)
    );

    initial begin
        $readmemh(PROG, uut_progmem.mem);
        rst = 0;
        #1;
        rst = 1;
        #1;
        rst = 0;
        #250;
        $finish;
    end

endmodule