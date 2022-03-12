`timescale 10ns / 10ns

// clkdiv - Clock divider with parametrizable factor.
// Setting CLKDIV_FACTOR to number N will output one clock cycle for every N input clock cycles.
module clkdiv(
    input clk,
    output divclk
);

    parameter CLKDIV_FACTOR = 100;

    logic [7:0] counter;
    logic clk_out;

    initial begin
        counter <= 1;
        clk_out <= 0;
    end

    always @ (posedge clk)
    begin
        counter <= counter + 1;
        if (counter == CLKDIV_FACTOR / 2) begin
            counter <= 1;
            clk_out <= ~clk_out;
        end
    end

    assign divclk = clk_out;

endmodule
