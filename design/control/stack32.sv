`timescale 10ns / 10ns

module stack32(
    input clk,
    input push,
    input trigger,
    input [31:0] write_value,
    output [31:0] read_value,
    output done_out
);

    logic [31:0] read;
    logic [31:0] data;
    logic done;

    logic [1:0] state;
    logic [15:0] top_of_stack;
    logic [15:0] addr;
    logic writing;

    block_ram #(
        .DATA(32),
        .SIZE(65_536)
    ) memory (
        .clk(clk),
        .write_enable(writing),
        .data(data),
        .addr(addr),
        .data_out(byte_out)
    );

    const logic [1:0] IDLE  = 2'b00;
    const logic [1:0] WRITE = 2'b01;
    const logic [1:0] READ  = 2'b10;

    always @ (posedge clk) begin
        case (state)
            IDLE: begin
            end
            WRITE: begin
                data <= write_value;
                addr <= top_of_stack;
                top_of_stack <= top_of_stack + 1;
            end
            READ: begin
            end
            default: begin
            end
        endcase
    end

endmodule