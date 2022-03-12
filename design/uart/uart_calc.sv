`timescale 10ns / 10ns

module uart_calc(
    input clk,
    input uart_in,
    output uart_out,
    output debug_out,
    output [1:0] state
);

    logic uart_rx_done;
    logic [7:0] wordrx_byte_in;

    uart_rx #(.CYCLES_PER_BIT(104))
    uart_receiver(
        .clk(clk),
        .rx(uart_in),
        .done(uart_rx_done),
        .out(wordrx_byte_in)
    );

    logic word_rx_done;
    logic [31:0] word_rx_out;

    word_rx word_receiver(
        .clk(clk),
        .in(wordrx_byte_in),
        .byte_done(uart_rx_done),
        .out(word_rx_out),
        .done(word_rx_done)
    );

    // begin calculator logic
    // receive three 32-bit integers
    logic [1:0] rx_count;
    logic [31:0] a, b;
    logic [3:0] op;
    logic [31:0] lo;
    logic [31:0] hi;
    logic op_done;

    initial begin
        rx_count <= 2'b00;
    end

    always @ (negedge clk) begin
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

    logic [31:0] lo_out;
    logic word_send;
    logic word_sent;
    
    always @ (posedge clk) begin
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
        .clk(clk),
        .in(lo_out),
        .send_in(word_send),
        .sent(byte_sent),
        .out(tx_data_in),
        .send_out(tx_send),
        .done(word_sent)
    );

    logic uart_out_wire;

    uart_tx #(.CYCLES_PER_BIT(104))
    uart_transmitter(
        .clk(clk),
        .in(tx_data_in),
        .send(tx_send),
        .tx(uart_out_wire),
        .done(byte_sent)
    );

    assign uart_out = uart_out_wire;
    assign debug_out = uart_out_wire;
    assign state[1:0] = rx_count[1:0];

endmodule