`timescale 10ns / 10ns

task automatic send_u8 (input bit [7:0] in, time hold, ref uart);
        uart = 0;
        #hold;
        for (int j = 0; j < 8; j++) begin
            uart = in[j];
            #hold;
        end
        uart = 1;
        #hold;
endtask;

module test_bali_program();

    logic clk;
    logic rst;
    logic rx;
    logic tx;
    logic [7:0] addr;
    logic [1:0] exec;

    sim_clk clock(
        .clk(clk)
    );

    bali uut_bali(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .exec(exec)
    );

    initial begin
        rst = 0;
        rx = 1;
        #1;
        rst = 1;
        #1;
        rst = 0;
        send_u8(8'h07, 10400, rx);
        #1000;
        send_u8(8'h00, 10400, rx);
        #1000;
        send_u8(8'h04, 10400, rx);
        #1000;
        send_u8(8'h00, 10400, rx);
        #1000;
        send_u8(8'h02, 10400, rx);
        #1000;
        send_u8(8'h06, 10400, rx);
        #1000;
        send_u8(8'h3c, 10400, rx);
        #1000;
        send_u8(8'hff, 10400, rx);
        #1000000;
        $finish;
    end

endmodule