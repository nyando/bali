`timescale 100ns / 10ns

module uart_tx(
    input clk,
    input [7:0] data_in,
    input send,
    output tx_out,
    output tx_done
    );

    parameter CYCLES_PER_BIT = 104;

    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;

    logic [1:0] state;
    logic [7:0] counter;
    logic tx_value;
    logic done;
    logic [7:0] data_value;
    logic [2:0] data_index;
    
    initial begin
        state <= IDLE;
        tx_value <= 1;
        counter <= 0;
    end

    always @ (posedge clk)
    begin
        case (state)
            START: begin
                if (counter > CYCLES_PER_BIT - 1)
                    begin
                        state <= DATA;
                        counter <= 0;
                    end
                else
                    begin
                        state <= START;
                        tx_value <= 0;
                        counter <= counter + 1;
                        done <= 0;
                        data_value <= data_in;
                        data_index <= 0;
                    end
            end
            DATA: begin
                if (counter > CYCLES_PER_BIT - 1)
                    begin
                        if (data_index < 7)
                            begin
                                data_index <= data_index + 1;
                                tx_value <= data_value[data_index];
                                counter <= 0;
                            end
                        else
                            begin
                                state <= STOP;
                                counter <= 0;
                            end
                    end
                else
                    begin
                        tx_value <= data_value[data_index];
                        counter <= counter + 1;
                    end
            end
            STOP: begin
                if (counter > CYCLES_PER_BIT - 1)
                    begin
                        state <= IDLE;
                        done <= 1;
                        data_index <= 0;
                    end
                else
                    begin
                        tx_value <= 1;
                        counter <= counter + 1;
                    end
            end
            IDLE: begin
                if (send == 1)
                    begin
                        state <= START;
                    end
                else
                    begin
                        state <= IDLE;
                    end
                done <= 0;
                tx_value <= 1;
                counter <= 0;
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end

    assign tx_out = tx_value;
    assign tx_done = done;

endmodule
