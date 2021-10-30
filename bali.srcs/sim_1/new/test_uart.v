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

    reg tx;

    wire clock;
    wire divclock;
    wire done;
    wire [7:0] byte_out;

    // generate 100 MHz clock signal
    clk my_clock(clock);
    // divide clock signal to 1 MHz
    clkdiv clkdivider(clock, divclock);
    
    uart_rx test_uart(divclock, tx, done, byte_out);

    initial begin
        tx = 1;
        #208000;
        tx = 0;
        #104000;
        tx = 1;
        #104000;
        tx = 0;
        #104000;
        tx = 0;
        #104000;
        tx = 1;
        #104000;
        tx = 1;
        #104000;
        tx = 0;
        #104000;
        tx = 0;
        #104000;
        tx = 1;
        #104000;
        tx = 1;
        #208000;
    end
    
endmodule
