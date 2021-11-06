`timescale 100ns / 10ns

module word_rx(
    input clk,
    input [7:0] byte_in,
    input rx_done,
    output [31:0] word_out,
    output word_done
    );

    logic [31:0] acc;
    logic [1:0] byte_count;
    logic rx_complete;

    initial begin
        byte_count <= 0;
        acc <= 32'h00000000;
        rx_complete <= 0;
    end

    always @ (posedge rx_done or posedge clk) begin
        if (rx_complete) begin
            rx_complete <= 0;
        end
        if (rx_done) begin
            case (byte_count)
                2'b00: begin
                    byte_count <= byte_count + 1;
                    acc[7:0] <= byte_in[7:0];
                end
                2'b01: begin
                    byte_count <= byte_count + 1;
                    acc[15:8] <= byte_in[7:0];
                end
                2'b10: begin
                    byte_count <= byte_count + 1;
                    acc[23:16] <= byte_in[7:0];
                end
                2'b11: begin
                    byte_count <= 2'b00;
                    rx_complete <= 1;
                    acc[31:24] <= byte_in[7:0];
                end
                default: begin
                    byte_count <= 2'b00;
                end
            endcase
        end
    end

    assign word_out = acc;
    assign word_done = rx_complete;

endmodule