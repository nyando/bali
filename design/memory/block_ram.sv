`timescale 100ns / 10ns

module block_ram #(
    parameter DATA = 8,
    parameter SIZE = 65_536,
    localparam ADDR = $clog2(SIZE)
) (
    input clk,
    input write_enable,
    input [DATA - 1:0] data,
    input [ADDR - 1:0] addr,
    output [DATA - 1:0] data_out
);

    logic [DATA - 1:0] mem [SIZE - 1:0];
    logic [DATA - 1:0] out;

    always @ (posedge clk) begin
        if (write_enable) begin
            mem[addr] <= data;
        end
        out <= mem[addr];
    end

    assign data_out = out;

endmodule