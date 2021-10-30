`timescale 100ns / 10ns

/*
 * uart_to_led - Small UART test module that connects a 9600-baud UART receiver
 * to the Arty A7 FPGA board's LED array.
 * Send it a byte via UART to make it display the values on the eight LEDs.
 */
module uart_to_led(
    input clk,
    input tx,
    output [7:0] led
    );

    wire divclock;
    wire done;
    wire [7:0] byte;

    clkdiv divider(clk, divclock);
    uart_rx receiver(divclock, tx, done, byte);
    led_mapper mapper(done, byte, led);

endmodule
