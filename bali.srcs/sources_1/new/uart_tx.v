`timescale 100ns / 10ns

module uart_tx(
    input clk,
    input [7:0] data_in,
    input send,
    output tx_out,
    output tx_done
    );

    parameter ticks_per_bit = 104;

    parameter idle  = 2'b00;
    parameter start = 2'b01;
    parameter data  = 2'b10;
    parameter stop  = 2'b11;

    reg [1:0] state;
    reg [7:0] counter;
    reg tx_value;
    reg done;
    reg [7:0] data_value;
    reg [2:0] data_index;
    
    initial begin
        state <= idle;
        tx_value <= 1;
        counter <= 0;
    end

    always @ (posedge clk && send)
    begin
        if (state == idle)
            begin
                state <= start;
                tx_value <= 0;
                done <= 0;
                data_value <= data_in;
                data_index <= 0;
                counter <= 0;
            end
    end

    always @ (posedge clk)
    begin
        case (state)
            start: begin
                if (counter > ticks_per_bit - 1)
                    begin
                        state <= data;
                        counter <= 0;
                    end
                else
                    begin
                        tx_value <= 0;
                        counter <= counter + 1;
                    end
            end
            data: begin
                if (counter > ticks_per_bit - 1)
                    begin
                        if (data_index < 7)
                            begin
                                data_index <= data_index + 1;
                                tx_value <= data_value[data_index];
                                counter <= 0;
                            end
                        else
                            begin
                                state <= stop;
                                counter <= 0;
                            end
                    end
                else
                    begin
                        tx_value <= data_value[data_index];
                        counter <= counter + 1;
                    end
            end
            stop: begin
                if (counter > ticks_per_bit - 1)
                    begin
                        state <= idle;
                        done <= 1;
                        data_index <= 0;
                    end
                else
                    begin
                        tx_value <= 1;
                        counter <= counter + 1;
                    end
            end
            idle: begin
                done <= 0;
                state <= idle;
                tx_value <= 1;
                counter <= 0;
            end
        endcase
    end

    assign tx_out = tx_value;
    assign tx_done = done;

endmodule
