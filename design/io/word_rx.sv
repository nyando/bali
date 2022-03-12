`timescale 10ns / 10ns

module word_rx(
    input clk,
    input [7:0] in,
    input byte_done,
    output [31:0] out,
    output done
);

    logic [31:0] acc;  // set to "out"; accumulates four received bytes
    logic rx_done;     // set to "done" output; HI for one clock cycle when 32-bit word received
    logic [1:0] index; // index of received byte

    initial begin
        index <= 0;
        acc <= 32'h00000000;
        rx_done <= 0;
    end

    always @ (negedge clk) begin
        if (rx_done) begin
            rx_done <= 0;
        end
        if (byte_done) begin
            case (index)
                2'b00: begin
                    index <= index + 1;
                    acc[7:0] <= in[7:0];
                end
                2'b01: begin
                    index <= index + 1;
                    acc[15:8] <= in[7:0];
                end
                2'b10: begin
                    index <= index + 1;
                    acc[23:16] <= in[7:0];
                end
                2'b11: begin
                    index <= 2'b00;
                    rx_done <= 1;
                    acc[31:24] <= in[7:0];
                end
                default: begin
                    index <= 2'b00;
                end
            endcase
        end
    end

    assign out = acc;
    assign done = rx_done;

endmodule