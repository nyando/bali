`timescale 10ns / 10ns

// task automatic write_mem(
//     input string memfilepath,
//     ref logic write,
//     ref logic [15:0] writeaddr,
//     ref logic [7:0] writevalue
// );
//     logic [7:0] mem [100:0];
    
//     $readmemh(memfilepath, mem);
    
//     write = 1;
//     for (int i = 0; i < 50; i++) begin
//         writeaddr = i;
//         writevalue = mem[i];
//         #1;
//     end
//     write = 0;

// endtask

module test_progmem();

    // logic clk;

    // sim_clk simclk (
    //     .clk(clk)
    // );

    // logic write;
    // logic [15:0] writeaddr;
    // logic [7:0] writevalue;
    // logic [7:0] constindex;
    // logic [31:0] constparams;
    // logic [15:0] pc;
    // logic [7:0] opcode;
    // logic [7:0] arg1;
    // logic [7:0] arg2;

    // progmem uut_mem_module(
    //     .clk(clk),
    //     .write(write),
    //     .writeaddr(writeaddr),
    //     .writevalue(writevalue),
    //     .constindex(constindex),
    //     .constparams(constparams),
    //     .programcounter(pc),
    //     .opcode(opcode),
    //     .arg1(arg1),
    //     .arg2(arg2)
    // );


    // initial begin
    //     write_mem(
    //         "tests/progs/int_reverse.mem",
    //         write,
    //         writeaddr,
    //         writevalue
    //     );

    //     #100;

    //     constindex = 8'h00;
    //     #10;
    //     assert (constparams == 32'h000c_0001) else $fatal(1, "incorrect header function params");

    //     constindex = 8'h01;
    //     #10;
    //     assert (constparams == 32'h0013_0002) else $fatal(1, "incorrect header function params");
        
    //     constindex = 8'h02;
    //     #10;
    //     assert (constparams == 32'h0001_e240) else $fatal(1, "incorrect header constant");

    //     pc = 16'h000c;
    //     #10;
    //     assert (opcode == 8'h12) else $fatal(1, "opcode incorrect");
    //     assert (arg1 == 8'h02) else $fatal(1, "arg1 incorrect");

        
    //     $finish;
    // end

endmodule