`timescale 100ns / 10ns

module uart_rx (
    input clk,
    input rx,
    output done,
    output [7:0] out
);
    
    // assuming 1 MHz clock frequency and 9600 baud/s, modify this as needed
    parameter CYCLES_PER_BIT = 104; 

    const logic [1:0] IDLE  = 2'b00;
    const logic [1:0] START = 2'b01;
    const logic [1:0] DATA  = 2'b10;
    const logic [1:0] STOP  = 2'b11;

    logic [7:0] value;  // assigned to "out" output; accumulator for received byte value
    logic rx_done;      // assigned to "done" output; set to HI for one cycle when byte received
    logic [1:0] state;  // internal representation of FSM state
    logic [7:0] cycles; // counter for clock cycles per received bit
    logic [2:0] index;  // counter for bit indices received

    initial begin
        state <= IDLE;
        value <= 8'h00;
    end

    always @ (posedge clk)
        begin
            case (state)
                IDLE: begin
                    // idle state: wait until rx is driven low
                    cycles <= 8'h00;
                    index <= 3'b000;
                    rx_done <= 0;
                    
                    if (rx == 0)
                        state <= START;
                    else
                        state <= IDLE;

                end
                START: begin
                    // start bit: wait until we reach the "middle" of the bit transmission
                    if (cycles == (CYCLES_PER_BIT - 1) / 2) begin
                        if (rx == 0) begin
                            cycles <= 8'h00;
                            state <= DATA;
                        end
                        else
                            state <= IDLE;
                    end
                    else 
                        begin
                            cycles <= cycles + 1;
                            state <= START;
                        end
                end
                DATA: begin
                    // data bits: sample in the middle of the transmission
                    if (cycles > CYCLES_PER_BIT - 1) begin
                        cycles <= 8'h00;
                        value[index] <= rx;
                        
                        if (index < 7) begin
                            index <= index + 1;
                            state <= DATA;
                        end
                        else
                            begin
                                index <= 3'b000;
                                state <= STOP;
                            end
                    end
                    else
                        begin
                            cycles <= cycles + 1;
                            state <= DATA;
                        end
                end
                STOP: begin
                    // set rx_done in the middle of the stop bit, hold for one clock cycle
                    if (cycles > CYCLES_PER_BIT - 1) begin
                        cycles <= 8'h00;
                        state <= IDLE;
                        rx_done <= 1;
                    end
                    else
                        begin
                            cycles <= cycles + 1;
                            state <= STOP;
                        end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end

    assign done = rx_done;
    assign out = value;

endmodule