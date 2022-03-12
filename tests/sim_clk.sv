`timescale 10ns / 10ns

/*
* clk - Clock simulation module for testing.
* Invert signal every 5 ns (timescale 1 ns) for a clock period of 10 ns => 100 MHz (Arty A7 clock speed).
* Scale this down as needed.
*/
module sim_clk(output logic clk);

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

endmodule