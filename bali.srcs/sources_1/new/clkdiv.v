`timescale 100ns / 10ns

module clkdiv(
    input clk,
    output divclk
    );

    reg [7:0] counter;
    reg clk_out;

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
