`timescale 1ns / 1ns

/*
 * clk - Clock simulation module for testing.
 * Invert signal every 5 ns (timescale 1 ns) for a clock period of 10 ns => 100 MHz (Arty A7 clock speed).
 * Scale this down as needed.
 */
module clk(output reg clk);
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
endmodule


/*
 * test_uart - Test transmit-receive interaction of UART modules.
 * uart_tx, connected to byte_in register, transmits byte_in at 9600 baud/s.
 * uart_rx rx_input wire is connected to tx_output of uart_tx, begins receiving byte_in from uart_tx.
 * Both components set their respective "done" outputs to HI for one clock cycle. 
 * Then transmission of the byte is complete and byte_in matches byte_out.
 */
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
