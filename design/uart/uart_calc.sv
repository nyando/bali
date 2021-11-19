`timescale 100ns / 10ns

module uart_calc(
    input clk,
    input uart_in,
    output uart_out,
    output debug_out,
    output [1:0] state
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

    // begin calculator logic
    // receive three 32-bit integers
    logic [1:0] rx_count;
    logic [31:0] a, b;
    logic [3:0] op;
    logic [31:0] lo;
    logic [31:0] hi;
    logic op_done;

    always @ (negedge clock) begin
        if (word_rx_done) begin
            case (rx_count)
                2'b00: begin
                    a[31:0] <= word_rx_out[31:0];
                    rx_count <= rx_count + 1;
                end
                2'b01: begin
                    b[31:0] <= word_rx_out[31:0];
                    rx_count <= rx_count + 1;
                end
                2'b10: begin
                    op[3:0] <= word_rx_out[3:0];
                    op_done <= 1;
                    rx_count <= 2'b00;
                end
                default: begin
                    a <= 32'hXXXXXXXX;
                    b <= 32'hXXXXXXXX;
                    op <= 4'hX;
                    rx_count <= 2'b00;
                end
            endcase
        end
        else begin
            op_done <= 0;
        end
    end
    // end calculator logic

    alu calc_alu(
        .operand_a(a),
        .operand_b(b),
        .op_select(op),
        .result_lo(lo),
        .result_hi(hi)
    );

    // begin UART TX output logic
    logic byte_sent;
    logic [7:0] tx_data_in;
    logic tx_send;
    logic tx_out;

    logic [31:0] lo_out;
    logic word_send;
    logic word_sent;
    
    always @ (posedge clock) begin
        if (op_done) begin
            lo_out[31:0] <= lo[31:0];
            word_send <= 1;
        end
        else begin
            word_send <= 0;
        end
    end
    // end UART TX output logic

    word_tx result_transmitter(
        .clk(clock),
        .word_in(lo_out),
        .word_send(word_send),
        .byte_sent(byte_sent),
        .byte_out(tx_data_in),
        .uart_send(tx_send),
        .send_done(word_sent)
    );

    logic uart_out_wire;

    uart_tx #(.CYCLES_PER_BIT(104))
    uart_transmitter(
        .clk(clock),
        .data_in(tx_data_in),
        .send(tx_send),
        .tx_out(uart_out_wire),
        .tx_done(byte_sent)
    );

    assign uart_out = uart_out_wire;
    assign debug_out = uart_out_wire;
    assign state[1:0] = rx_count[1:0];

endmodule