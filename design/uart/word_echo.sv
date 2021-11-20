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
        .done(uart_rx_done),
        .out(wordrx_byte_in)
    );
 
    logic word_rx_done;
    logic [31:0] word_rx_out;

    word_rx word_receiver(
        .clk(clock),
        .in(wordrx_byte_in),
        .byte_done(uart_rx_done),
        .out(word_rx_out),
        .done(word_rx_done)
    );

    logic byte_sent;
    logic [7:0] tx_data_in;
    logic tx_send;
    logic word_sent;

    word_tx result_transmitter(
        .clk(clock),
        .in(word_rx_out),
        .send_in(word_rx_done),
        .sent(byte_sent),
        .out(tx_data_in),
        .send_out(tx_send),
        .done(word_sent)
    );

    uart_tx #(.CYCLES_PER_BIT(104))
    uart_transmitter(
        .clk(clock),
        .in(tx_data_in),
        .send(tx_send),
        .tx(uart_out),
        .done(byte_sent)
    );

endmodule