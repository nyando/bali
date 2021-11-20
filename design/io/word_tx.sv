`timescale 100ns / 10ns

module word_tx(
    input clk,
    input [31:0] in,
    input send_in,
    input sent,
    output [7:0] out,
    output send_out,
    output done
);

    const logic [1:0] IDLE = 2'b00;
    const logic [1:0] SEND = 2'b01;
    const logic [1:0] DONE = 2'b10;

    logic [7:0] tx_byte; // set to output "out"; byte to send via uart_tx module
    logic uart_send;     // set to output "send_out"; trigger uart_tx transmission
    logic tx_done;       // set to output "done"; set to HI for one clock cycle when word transmitted
    logic [1:0] state;
    logic [2:0] count;   // count index of byte to send
    logic [31:0] word;   // 32 bit word to send via uart_tx

    initial begin
        state <= IDLE;
        uart_send <= 0;
        word[31:0] <= 32'h00000000;
        tx_byte[7:0] <= 8'h00;
        count[2:0] <= 3'b000;
        tx_done <= 0;
    end

    always @ (negedge clk) begin
        if (uart_send) begin
            uart_send <= 0;
        end

        if (state == IDLE && send_in) begin
            state <= SEND;
            count <= 3'b001;
            word[31:0] <= in[31:0];
            uart_send <= 1;
        end

        if (state == DONE) begin
            state <= IDLE;
            count <= 3'b000;
            tx_done <= 0;
        end

        if (state == SEND) begin
            case (count)
                3'b001: begin
                    tx_byte[7:0] <= word[7:0];
                end
                3'b010: begin
                    tx_byte[7:0] <= word[15:8];
                end
                3'b011: begin
                    tx_byte[7:0] <= word[23:16];
                end
                3'b100: begin
                    tx_byte[7:0] <= word[31:24];
                end
                default: begin
                    tx_byte <= 8'hXX;
                end
            endcase
        end
        
        if (state == SEND && sent) begin
            if (count == 3'b100) begin
                state <= DONE;
                tx_done <= 1;
            end
            else begin
                count <= count + 1;
                uart_send <= 1;
            end
        end
    end

    assign send_out = uart_send;
    assign out = tx_byte;
    assign done = tx_done;

endmodule