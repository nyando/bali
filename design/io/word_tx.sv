`timescale 100ns / 10ns

module word_tx(
    input clk,
    input [31:0] word_in,
    input word_send,
    input byte_sent,
    output [7:0] byte_out,
    output uart_send,
    output send_done
    );

    parameter IDLE = 2'b00;
    parameter SEND = 2'b01;
    parameter DONE = 2'b10;

    logic [1:0]  state;
    logic [2:0]  byte_count;
    logic [7:0]  current_byte;
    logic [31:0] word_to_send;
    logic send_byte;
    logic word_sent;

    initial begin
        state <= IDLE;
        send_byte <= 0;
        word_to_send[31:0] <= 32'h00000000;
        current_byte[7:0] <= 8'h00;
        byte_count[2:0] <= 3'b000;
        word_sent <= 0;
    end

    always @ (negedge clk) begin
        if (send_byte) begin
            send_byte <= 0;
        end

        if (state == IDLE && word_send) begin
            state <= SEND;
            byte_count <= 3'b001;
            word_to_send[31:0] <= word_in[31:0];
            send_byte <= 1;
        end

        if (state == DONE) begin
            state <= IDLE;
            byte_count <= 3'b000;
            word_sent <= 0;
        end

        if (state == SEND) begin
            case (byte_count)
                3'b001: begin
                    current_byte[7:0] <= word_to_send[7:0];
                end
                3'b010: begin
                    current_byte[7:0] <= word_to_send[15:8];
                end
                3'b011: begin
                    current_byte[7:0] <= word_to_send[23:16];
                end
                3'b100: begin
                    current_byte[7:0] <= word_to_send[31:24];
                end
                default: begin
                    current_byte <= 8'hXX;
                end
            endcase
        end
        
        if (state == SEND && byte_sent) begin
            if (byte_count == 3'b100) begin
                state <= DONE;
                word_sent <= 1;
            end
            else begin
                byte_count <= byte_count + 1;
                send_byte <= 1;
            end
        end
    end

    assign uart_send = send_byte;
    assign byte_out = current_byte;
    assign send_done = word_sent;

endmodule