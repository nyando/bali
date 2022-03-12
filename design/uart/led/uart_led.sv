`timescale 10ns / 10ns

/*
 * uart_to_led - Small UART test module that connects a 9600-baud UART receiver
 * to the Arty A7 FPGA board's LED array.
 * Send it a byte via UART to make it display the values on the eight LEDs.
 */
module uart_led(
    input clk,
    input tx,
    output [7:0] led
);

    wire divclock;
    wire done;
    wire [7:0] byte_out;

    clkdiv divider(clk, divclock);

    uart_rx receiver(.clk(divclock),
                     .rx(tx),
                     .done(done),
                     .out(byte_out));

    led_mapper mapper(done, byte_out, led);

endmodule
