`timescale 100ns / 10ns

/*
 * uart_echo - Echo module for UART testing. 
 * Receives byte values on uart_rx input, writes them back on uart_tx afterward.
 *
 * Module interface:
 *  - clk requires 100 MHz clock input.
 *  - uart_in connects to UART RX pin of the Arty A7 board.
 *  - uart_out connects to UART TX pin of the Arty A7 board.
 *
 * See uart_echo design constraint file (uart_echo.xdc) for pin IDs.
 */
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

    uart_rx receiver(.clk(clock),
                     .rx(uart_in),
                     .rx_done_out(rx_done),
                     .data_out(rx_byte));

    uart_tx transmitter(.clk(clock),
                        .data_in(rx_byte),
                        .send(rx_done),
                        .tx_out(uart_out),
                        .tx_done(tx_done));

endmodule
