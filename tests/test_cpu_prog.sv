`timescale 10ns / 10ns

task automatic write_mem(
    input string memfilepath,
    ref logic write,
    ref logic [7:0] writeaddr,
    ref logic [7:0] writevalue
);
    logic [7:0] mem [100:0];
    
    $readmemh(memfilepath, mem);
    
    write = 1;
    for (int i = 0; i < 50; i++) begin
        writeaddr = i;
        writevalue = mem[i];
        #1;
    end
    write = 0;

endtask

module test_cpu_prog();

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
        write_mem(
            "tests/progs/array_ops.mem",
            write,
            writeaddr,
            writevalue
        );
        rst = 0;
        #10;
        rst = 1;
        #1;
        rst = 0;
        #250;
        $finish;
    end

endmodule