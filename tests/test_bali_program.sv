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

    sim_clk clock(
        .clk(clk)
    );

    bali uut_bali(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx),
        .addr(addr)
    );

    initial begin
        rst = 0;
        rx = 1;
        #1;
        rst = 1;
        #1;
        rst = 0;
        send_u8(8'h00, 10400, rx);
        #1000;
        send_u8(8'h01, 10400, rx);
        #1000;
        send_u8(8'h02, 10400, rx);
        #1000;
        $finish;
    end

endmodule