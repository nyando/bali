`timescale 10ns / 10ns

module arrayblock #(
    parameter ARR_SIZE = 1024,
    localparam ADDR = $clog2(ARR_SIZE)
) (
    input clk,
    input rst,
    input write,
    input trigger,
    input [ADDR - 1:0] addr,
    input [31:0] writevalue,
    output [31:0] readvalue,
    output done
);

    logic [31:0] read_out;
    logic [31:0] write_in;
    logic [ADDR - 1:0] mem_addr;
    logic writing;

    block_ram #(
        .DATA(32),
        .SIZE(ARR_SIZE)
    ) arrmem (
        .clk(clk),
        .write_enable(writing),
        .data(write_in),
        .addr(mem_addr),
        .data_out(read_out)
    );

    logic [1:0] state;
    const logic [1:0] IDLE  = 2'b00;
    const logic [1:0] READ  = 2'b01;
    const logic [1:0] WRITE = 2'b10;

    logic is_done;

    always @ (posedge clk) begin
        
        if (rst) begin
            state <= IDLE;
            write_in <= 32'h0000_0000;
            writing <= 0;
            is_done <= 0;
        end

        case (state)
            IDLE: begin
                writing <= 0;
                is_done <= 0;
            end
            WRITE: begin
                state <= IDLE;
                is_done <= 1;
            end
            READ: begin
                state <= IDLE;
                is_done <= 1;
            end
            default: begin end
        endcase

        if (trigger) begin
            mem_addr <= addr;
            if (write) begin
                writing <= 1;
                state <= WRITE;
                write_in <= writevalue;
            end
            else begin
                writing <= 0;
                state <= READ;
            end
        end
    end

    assign readvalue[31:0] = read_out[31:0];
    assign done = is_done;

endmodule