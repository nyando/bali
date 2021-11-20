`timescale 100ns / 10ns

module test_uart_calc();

    logic clock;

    logic uart_in;
    logic uart_out;

    bit [31:0] a_value;
    bit [31:0] b_value;
    bit [3:0] op_value;
    
    // generate 100 MHz clock signal
    sim_clk arty_clock(clock);

    uart_calc calc(
        .clk(clk),
        .uart_in(uart_in),
        .uart_out(uart_out),
        .debug_out(debug_out),
        .state(state)
    );
    
    initial begin
        uart_in = 1;
        a_value = $random;
        b_value = $random;
        op_value = 4'b0110; // IAND
        #10;

        // send 4 bytes over UART (32-bit integer A)
        for (int i = 0; i < 4; i++) begin
            uart_in = 0;
            #1040;
            for (int j = 0; j < 8; j++) begin
                uart_in = a_value[i * 8 + j];
                #1040;
            end
            uart_in = 1;
            #10000;
        end
        #10000;
        // finish receiving operand A
        
        // send 4 bytes over UART (32-bit integer B)
        for (int i = 0; i < 4; i++) begin
            uart_in = 0;
            #1040;
            for (int j = 0; j < 8; j++) begin
                uart_in = b_value[i * 8 + j];
                #1040;
            end
            uart_in = 1;
            #10000;
        end
        #10000;
        // finish receiving operand B

        // third word determines ALU operation
        uart_in = 0; // first op byte start
        #1040;
        for (int i = 0; i < 8; i++) begin
            uart_in = op_value[i];
            #1040;
        end
        uart_in = 1; // first op byte end
        
        #10000;

        for (int i = 0; i < 3; i++) begin
            uart_in = 0;
            #1040;
            for (int j = 0; j < 8; j++) begin
                uart_in = 0;
                #1040;
            end
            uart_in = 1;
            #10000;
        end
        // finish receiving ALU op instruction

        #400000;

        $finish;
    end

endmodule