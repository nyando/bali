`timescale 10ns / 10ns

module stack #(
    parameter STACKDATA = 32,
    parameter STACKSIZE = 65_536
) (
    input clk,
    input rst,
    input push,
    input trigger,
    input [STACKDATA - 1:0] write_value,
    output [STACKDATA - 1:0] read_value,
    output done_out
);

    logic [31:0] read;
    logic [31:0] word_in;
    logic done;

    logic [1:0] state;
    logic [15:0] top_of_stack;
    logic [31:0] word_out;
    logic [15:0] addr;
    logic writing;

    block_ram #(
        .DATA(STACKDATA),
        .SIZE(STACKSIZE)
    ) memory (
        .clk(clk),
        .write_enable(writing),
        .data(word_in),
        .addr(addr),
        .data_out(word_out)
    );

    const logic [1:0] IDLE  = 2'b00;
    const logic [1:0] WRITE = 2'b01;
    const logic [1:0] READ  = 2'b10;

    initial begin
        top_of_stack <= 0;
        state <= IDLE;
        writing <= 0;
        done <= 0;
    end

    always @ (posedge clk) begin

        if (rst) begin
            state <= IDLE;
            addr <= 16'h0000;
            top_of_stack <= 16'h0000;
            word_in <= 32'h0000_0000;
            writing <= 0;
            done <= 0;
        end

        case (state)
            IDLE: begin
                writing <= 0;
                done <= 0;
            end
            WRITE: begin
                top_of_stack <= top_of_stack + 1;
                state <= IDLE;
                done <= 1;
            end
            READ: begin
                top_of_stack <= top_of_stack - 1;
                state <= IDLE;
                done <= 1;
            end
            default: begin end
        endcase

        if (trigger) begin
            if (push) begin
                writing <= 1;
                state <= WRITE;
                word_in <= write_value;
                addr <= top_of_stack;
            end
            else begin
                writing <= 0;
                state <= READ;
                addr <= top_of_stack - 1;
            end
        end

    end
    
    assign read_value[STACKDATA - 1:0] = word_out[STACKDATA - 1:0];
    assign done_out = done;

endmodule