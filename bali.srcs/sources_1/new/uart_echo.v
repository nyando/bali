`timescale 100ns / 10ns

module uart_echo(
    input clk,
    input uart_in,
    output uart_out
    );

    wire clock;
    wire rx_done;
    wire tx_done;
    wire [7:0] rx_byte;

    clkdiv divider(clk, clock);
    uart_rx receiver(clock, uart_in, rx_done, rx_byte);
    uart_tx transmitter(clock, rx_byte, rx_done, uart_out, tx_done);

endmodule
