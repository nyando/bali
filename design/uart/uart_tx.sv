`timescale 10ns / 10ns

module uart_tx #(
    parameter CYCLES_PER_BIT = 10400
) (
    input clk,
    input [7:0] in,
    input send,
    output tx,
    output done
);

    const logic [1:0] IDLE  = 2'b00;
    const logic [1:0] START = 2'b01;
    const logic [1:0] DATA  = 2'b10;
    const logic [1:0] STOP  = 2'b11;

    logic tx_value;     // assigned to "tx" output
    logic tx_done;      // assigned to "done" output; set to HI for one clock cycle when transmission is done
    logic [7:0] value;  // byte value to transmit
    logic [1:0] state;  // internal representation of FSM state
    logic [15:0] cycles; // counter for number of cycles per transmitted bit
    logic [2:0] index;  // counter for bit index to transmit
    
    initial begin
        state <= IDLE;
        tx_value <= 1;
        cycles <= 0;
    end

    always @ (posedge clk)
    begin
        case (state)
            START: begin
                if (cycles > CYCLES_PER_BIT - 1)
                    begin
                        state <= DATA;
                        cycles <= 0;
                    end
                else
                    begin
                        state <= START;
                        tx_value <= 0;
                        cycles <= cycles + 1;
                        tx_done <= 0;
                        value <= in;
                        index <= 0;
                    end
            end
            DATA: begin
                if (cycles > CYCLES_PER_BIT - 1)
                    begin
                        if (index < 7)
                            begin
                                index <= index + 1;
                                tx_value <= value[index];
                                cycles <= 0;
                            end
                        else
                            begin
                                state <= STOP;
                                cycles <= 0;
                            end
                    end
                else
                    begin
                        tx_value <= value[index];
                        cycles <= cycles + 1;
                    end
            end
            STOP: begin
                if (cycles > CYCLES_PER_BIT - 1)
                    begin
                        state <= IDLE;
                        tx_done <= 1;
                        index <= 0;
                    end
                else
                    begin
                        tx_value <= 1;
                        cycles <= cycles + 1;
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
                tx_done <= 0;
                tx_value <= 1;
                cycles <= 0;
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end

    assign tx = tx_value;
    assign done = tx_done;

endmodule
