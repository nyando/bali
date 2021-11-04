`timescale 1ns / 1ns

/*
 * test_uart - Test transmit-receive interaction of UART modules.
 * uart_tx, connected to byte_in register, transmits byte_in at 9600 baud/s.
 * uart_rx rx_input wire is connected to tx_output of uart_tx, begins receiving byte_in from uart_tx.
 * Both components set their respective "done" outputs to HI for one clock cycle. 
 * Then transmission of the byte is complete and byte_in matches byte_out.
 */
module test_uart();

    logic [7:0] byte_in;
    logic send;

    wire clock;
    wire divclock;

    wire tx2rx;
    wire tx_done;
    wire rx_done;
    wire [7:0] byte_out;

    // generate 100 MHz clock signal
    sim_clk arty_clock(clock);
    
    // divide clock signal to 1 MHz
    clkdiv clkdivider(clock, divclock);
    
    // transmitter module
    uart_tx test_uart_tx(.clk(divclock),
                         .data_in(byte_in),
                         .send(send),
                         .tx_out(tx2rx),
                         .tx_done(tx_done));

    // receiver module
    uart_rx test_uart_rx(.clk(divclock),
                         .rx(tx2rx),
                         .rx_done_out(rx_done),
                         .data_out(byte_out));

    initial begin
        byte_in = 8'h99;
        send = 0;
        #2000;
        send = 1;
        #2000;
        send = 0;
    end
    
endmodule
