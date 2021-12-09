`timescale 10ns / 10ns

module stack(
    input clk,
    input push,
    input trigger,
    input [31:0] write_value,
    output [31:0] read_value,
    output done_out
);

    logic [31:0] read;
    logic done;

    logic [15:0] top_of_stack;
    logic [15:0] addr;
    logic [7:0] byte_out;
    logic [7:0] data;

    logic [1:0] byte_count;
    logic writing;
    logic reading;

    logic [1:0] state;
    const logic [1:0] IDLE = 2'b00;
    const logic [1:0] WRITE = 2'b01;
    const logic [1:0] READ = 2'b10;

    logic read_phase;

    block_ram #(
        .DATA(8),
        .SIZE(65_536)
    ) memory (
        .clk(clk),
        .write_enable(writing),
        .data(data),
        .addr(addr),
        .data_out(byte_out)
    );

    initial begin
        top_of_stack <= 0;
        byte_count <= 2'b00;
        state <= IDLE;
        writing <= 0;
        reading <= 0;
    end

    always @ (posedge clk) begin
        
        if (state == IDLE) begin
            writing <= 0;
            reading <= 0;
            done <= 0;
        end
        
        if (trigger) begin
            if (push) begin
                reading <= 0;
                writing <= 1;
                state <= WRITE;
            end
            else begin
                reading <= 1;
                writing <= 0;
                state <= READ;
                read_phase <= 0;
            end
        end

        if (state == WRITE) begin
            case (byte_count)
                2'b00: begin
                    addr <= top_of_stack;
                    data <= write_value[7:0];
                    byte_count <= byte_count + 1;
                end
                2'b01: begin
                    addr <= top_of_stack + 1;
                    data <= write_value[15:8];
                    byte_count <= byte_count + 1;
                end
                2'b10: begin
                    addr <= top_of_stack + 2;
                    data <= write_value[23:16];
                    byte_count <= byte_count + 1;
                end
                2'b11: begin
                    addr <= top_of_stack + 3;
                    data <= write_value[31:24];
                    byte_count <= 2'b00;
                    top_of_stack <= top_of_stack + 4;
                    state <= IDLE;
                    done <= 1;
                end
                default: begin end
            endcase
        end

        if (state == READ) begin
            case (byte_count)
                2'b00: begin
                    if (read_phase) begin
                        read[31:24] <= byte_out[7:0];
                        byte_count <= byte_count + 1;
                        read_phase <= 0;
                    end
                    else begin
                        addr <= top_of_stack - 1;
                        read_phase <= 1;
                    end
                end
                2'b01: begin
                    if (read_phase) begin
                        read[23:16] <= byte_out[7:0];
                        byte_count <= byte_count + 1;
                        read_phase <= 0;
                    end
                    else begin
                        addr <= top_of_stack - 2;
                        read_phase <= 1;
                    end
                end
                2'b10: begin
                    if (read_phase) begin
                        read[15:8] <= byte_out[7:0];
                        byte_count <= byte_count + 1;
                        read_phase <= 0;
                    end
                    else begin
                        addr <= top_of_stack - 3;
                        read_phase <= 1;
                    end
                end
                2'b11: begin
                    if (read_phase) begin
                        read[7:0] <= byte_out[7:0];
                        byte_count <= 2'b00;
                        read_phase <= 0;
                        state <= IDLE;
                        top_of_stack <= top_of_stack - 4;
                        done <= 1;
                    end
                    else begin
                        addr <= top_of_stack - 4;
                        read_phase <= 1;
                    end
                end
                default: begin end
            endcase
        end
    end

    assign read_value[31:0] = read[31:0];
    assign done_out = done;

endmodule