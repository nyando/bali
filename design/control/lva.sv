`timescale 10ns / 10ns

module lva #(
    parameter LVA_SIZE = 1024,
    localparam ADDR = $clog2(LVA_SIZE)
) (
    input clk,
    input write,
    input trigger,
    input [ADDR - 1:0] addr,
    input [31:0] writevalue,
    output [31:0] readvalue,
    output done
);

    block_ram #(
        .DATA(32),
        .SIZE(LVA_SIZE)
    ) lvamem (
        .clk(clk),
        .write_enable(write),
        .data(writevalue),
        .addr(addr),
        .data_out(readvalue)
    );

    const logic [1:0] IDLE  = 2'b00;
    const logic [1:0] READ  = 2'b01;
    const logic [1:0] WRITE = 2'b10;
    const logic [1:0] OUT   = 2'b11;

    logic [1:0] state;
    logic is_done;

    always @ (posedge clk) begin
        case (state)
            IDLE: begin
                is_done <= 0;
                if (trigger) begin
                    if (write) begin
                        state <= WRITE;
                    end
                    else begin
                        state <= READ;
                    end
                end
            end
            READ: begin
                state <= OUT;
            end
            WRITE: begin
                state <= OUT;
            end
            OUT: begin
                is_done <= 1;
                state <= IDLE;
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end

    assign done = is_done;

endmodule