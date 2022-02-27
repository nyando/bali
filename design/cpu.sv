`timescale 10ns / 10ns

module cpu(
    input clk,
    input [7:0] op_code,
    input [7:0] arg1,
    input [7:0] arg2,
    output [15:0] program_counter
);

    logic lva_write;
    logic [31:0] lva_in;
    logic [7:0] lva_addr;
    logic [31:0] lva_out;
    logic lva_trigger;
    logic lva_done;

    lva #(
        .LVA_SIZE(256)
    ) localvars (
        .clk(clk),
        .write(lva_write),
        .trigger(lva_trigger),
        .addr(lva_addr),
        .writevalue(lva_in),
        .readvalue(lva_out),
        .done(lva_done)
    );

    logic [7:0] lva_index;
    logic op_done;
    logic [15:0] offset;

    control control_unit (
        .clk(clk),
        .op_code(op_code),
        .arg1(arg1),
        .arg2(arg2),
        .lvadone(lva_done),
        .lvaread(lva_out),
        .lvawrite(lva_in),
        .lvaindex(lva_index),
        .lvaop(lva_write),
        .lvatrigger(lva_trigger),
        .offset(offset),
        .op_done(op_done)
    );

    logic [15:0] pc;
    
    initial begin
        pc <= 8'h00;
    end

    always @ (posedge clk) begin
        if (op_done) begin
            // increase program counter by offset
            pc <= pc + offset;
        end
        lva_addr <= lva_index;
    end

    assign program_counter = pc;

endmodule