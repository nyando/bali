`timescale 100ns / 10ns

/*
 * clkdiv - Clock divider with a factor of 100.
 * TODO: Extend this so that clock scale factor is parametrizable in the module constructor.
 */
module clkdiv(
    input clk,
    output divclk
    );

    logic [7:0] counter;
    logic clk_out;

    initial begin
        counter <= 1;
        clk_out <= 0;
    end

    always @ (posedge clk)
    begin
        counter <= counter + 1;
        if (counter == 50) begin
            counter <= 1;
            clk_out <= ~clk_out;
        end
    end

    assign divclk = clk_out;

endmodule
