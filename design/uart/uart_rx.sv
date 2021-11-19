`timescale 100ns / 10ns

module uart_rx (
    input clk,
    input rx,
    output rx_done_out,
    output [7:0] data_out
    );
    
    // assuming 1 MHz clock frequency and 9600 baud/s, modify this as needed
    parameter CYCLES_PER_BIT = 104; 

    parameter IDLE  = 3'b00;
    parameter START = 3'b01;
    parameter DATA  = 3'b10;
    parameter STOP  = 3'b11;

    logic rx_done;
    logic [1:0] state;
    logic [7:0] clk_count;
    logic [2:0] data_index;
    logic [7:0] data_value;

    /*
     * --- UART RX STATE MACHINE ---
     *
     * the durations in the following description assume a baudrate of 9600 baud/s
     *
     * on rising clock edge and idle state:
     *   - rx high -> do nothing, stay in idle
     *   - rx low  -> move to start state
     * on rising clock edge and start state:
     *   - if rx still low after ~50 us -> start bit recognized, move to data state
     *   - if rx high -> back to idle
     * on rising clock edge and data state:
     *   - sample rx at half of ticks per baud -> add sampled value to data_value and increment data_index
     *   - if data_index == 8 -> move to stop
     * on rising clock edge and stop state:
     *   - if rx high after ~50 us -> stop bit recognized, move to idle
     */
    initial begin
        state <= IDLE;
        data_value <= 8'h00;
    end

    always @ (posedge clk)
        begin
            case (state)
                IDLE: begin
                    clk_count <= 8'h00;
                    data_index <= 3'b000;
                    rx_done <= 0;
                    
                    if (rx == 0)
                        state <= START;
                    else
                        state <= IDLE;

                end
                START: begin
                    if (clk_count == (CYCLES_PER_BIT - 1) / 2) begin
                        if (rx == 0) begin
                            clk_count <= 8'h00;
                            state <= DATA;
                        end
                        else
                            state <= IDLE;
                    end
                    else 
                        begin
                            clk_count <= clk_count + 1;
                            state <= START;
                        end
                end
                DATA: begin
                    if (clk_count > CYCLES_PER_BIT - 1) begin
                        clk_count <= 8'h00;
                        data_value[data_index] <= rx;
                        
                        if (data_index < 7) begin
                            data_index <= data_index + 1;
                            state <= DATA;
                        end
                        else
                            begin
                                data_index <= 3'b000;
                                state <= STOP;
                            end
                    end
                    else
                        begin
                            clk_count <= clk_count + 1;
                            state <= DATA;
                        end
                end
                STOP: begin
                    if (clk_count > CYCLES_PER_BIT - 1) begin
                        clk_count <= 8'h00;
                        state <= IDLE;
                        rx_done <= 1;
                    end
                    else
                        begin
                            clk_count <= clk_count + 1;
                            state <= STOP;
                        end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end

    assign rx_done_out = rx_done;
    assign data_out    = data_value;

endmodule