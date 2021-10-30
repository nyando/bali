`timescale 100ns / 10ns

module uart_rx (
    input clock,
    input rx,
    output rx_done_out,
    output [7:0] byte_out
    );
    
    // assuming 1 MHz clock frequency and 9600 baud/s, modify this as needed
    parameter ticks_per_bit = 104; 

    parameter idle  = 3'b00;
    parameter start = 3'b01;
    parameter data  = 3'b10;
    parameter stop  = 3'b11;

    reg rx_done;
    reg [1:0] state;
    reg [7:0] clk_count;
    reg [2:0] data_index;
    reg [7:0] data_value;

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
    always @ (posedge clock)
        begin
            case (state)
                idle: begin
                    clk_count <= 8'h00;
                    data_index <= 3'b000;
                    rx_done <= 0;
                    
                    if (rx == 0)
                        state <= start;
                    else
                        state <= idle;

                end
                start: begin
                    if (clk_count == (ticks_per_bit - 1) / 2) begin
                        if (rx == 0) begin
                            clk_count <= 8'h00;
                            state <= data;
                        end
                        else
                            state <= idle;
                    end
                    else 
                        begin
                            clk_count <= clk_count + 1;
                            state <= start;
                        end
                end
                data: begin
                    if (clk_count > ticks_per_bit - 1) begin
                        clk_count <= 8'h00;
                        data_value[data_index] <= rx;
                        
                        if (data_index < 7) begin
                            data_index <= data_index + 1;
                            state <= data;
                        end
                        else
                            begin
                                data_index <= 3'b000;
                                state <= stop;
                            end
                    end
                    else
                        begin
                            clk_count <= clk_count + 1;
                            state <= data;
                        end
                end
                stop: begin
                    if (clk_count > ticks_per_bit - 1) begin
                        clk_count <= 8'h00;
                        state <= idle;
                        rx_done <= 1;
                    end
                    else
                        begin
                            clk_count <= clk_count + 1;
                            state <= stop;
                        end
                end
                default: begin
                    state <= idle;
                end
            endcase
        end

    assign rx_done_out = rx_done;
    assign byte_out    = data_value;

endmodule