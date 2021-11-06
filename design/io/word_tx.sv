`timescale 100ns / 10ns

module word_tx(
    input clk,
    input [31:0] word_in,
    input word_send,
    input byte_sent,
    output [7:0] byte_out,
    output uart_send
    );

    logic [7:0] current_byte;
    logic [1:0] byte_count;
    logic idle_status;
    logic [31:0] word_to_send;

    always @ (word_send) begin
        idle_status <= 1;
        word_to_send <= word_in;
    end

    always @ (posedge byte_sent) begin
        if (~idle_status) begin
            byte_count <= byte_count + 1;
        end
        else begin
            byte_count <= 2'b00;
        end
    end

    always @ (posedge clk) begin
        if (~idle_status) begin
            case (byte_count)
                2'b00: begin
                    current_byte[7:0] <= word_to_send[7:0];
                end
                2'b01: begin
                    current_byte[7:0] <= word_to_send[15:8];
                end
                2'b10: begin
                    current_byte[7:0] <= word_to_send[23:16];
                end
                2'b11: begin
                    current_byte[7:0] <= word_to_send[31:24];
                end
                default: begin
                    current_byte <= 8'hXX;
                end
            endcase
        end
    end

endmodule