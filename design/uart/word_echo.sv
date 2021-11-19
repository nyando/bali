`timescale 100ns / 10ns

module word_echo(
    input clk,
    input uart_in,
    output uart_out
);

    logic clock;
    clkdiv clkdivider(clk, clock);

    logic uart_rx_done;
    logic [7:0] wordrx_byte_in;

    uart_rx #(.CYCLES_PER_BIT(104))
    uart_receiver(
        .clk(clock),
        .rx(uart_in),
        .rx_done_out(uart_rx_done),
        .data_out(wordrx_byte_in)
    );
 
    logic word_rx_done;
    logic [31:0] word_rx_out;

    word_rx word_receiver(
        .clk(clock),
        .byte_in(wordrx_byte_in),
        .rx_done(uart_rx_done),
        .word_out(word_rx_out),
        .word_done(word_rx_done)
    );

    logic byte_sent;
    logic [7:0] tx_data_in;
    logic tx_send;
    logic word_sent;

    word_tx result_transmitter(
        .clk(clock),
        .word_in(word_rx_out),
        .word_send(word_rx_done),
        .byte_sent(byte_sent),
        .byte_out(tx_data_in),
        .uart_send(tx_send),
        .send_done(word_sent)
    );

    uart_tx #(.CYCLES_PER_BIT(104))
    uart_transmitter(
        .clk(clock),
        .data_in(tx_data_in),
        .send(tx_send),
        .tx_out(uart_out),
        .tx_done(byte_sent)
    );

endmodule