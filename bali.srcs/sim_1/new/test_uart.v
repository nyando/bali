`timescale 1ns / 1ns

module clk(output reg clk);
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
endmodule

module test_uart();

    reg [7:0] byte_in;
    reg send;

    wire clock;
    wire divclock;

    wire tx2rx;
    wire tx_done;
    wire rx_done;
    wire [7:0] byte_out;

    // generate 100 MHz clock signal
    clk arty_clock(clock);
    
    // divide clock signal to 1 MHz
    clkdiv clkdivider(clock, divclock);
    
    // transmitter module
    uart_tx test_uart_tx(divclock, byte_in, send, tx2rx, tx_done);

    // receiver module
    uart_rx test_uart_rx(divclock, tx2rx, rx_done, byte_out);

    initial begin
        byte_in = 8'h99;
        send = 0;
        #2000;
        send = 1;
        #2000;
        send = 0;
    end
    
endmodule
