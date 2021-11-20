`timescale 100ns / 10ns

task automatic send_i32 (input bit [31:0] in, time hold, ref uart);
    for (int i = 0; i < 4; i++) begin
        uart = 0;
        #hold;
        for (int j = 0; j < 8; j++) begin
            uart = in[i * 8 + j];
            #hold;
        end
        uart = 1;
        #hold;
    end
endtask;

module test_uart_calc();

    logic clk;
    logic divclk;

    logic uart_in;
    logic uart_out;

    logic debug_out;
    logic [1:0] state;

    // generate 100 MHz clock signal
    sim_clk arty_clock(clk);

    clkdiv clock_divider(clk, divclk);

    uart_calc calc(
        .clk(divclk),
        .uart_in(uart_in),
        .uart_out(uart_out),
        .debug_out(debug_out),
        .state(state)
    );

    logic byte_done;
    logic word_done;
    logic [7:0] rx_byte;
    logic [31:0] calc_result;

    uart_rx #(.CYCLES_PER_BIT(104))
    test_calc_receiver(
        .clk(divclk),
        .rx(uart_out),
        .done(byte_done),
        .out(rx_byte)
    );

    word_rx test_word_receiver(
        .clk(divclk),
        .in(rx_byte),
        .byte_done(byte_done),
        .out(calc_result),
        .done(word_done)
    );
    
    bit [31:0] a_value;
    bit [31:0] b_value;
    bit [3:0] op_value;

    initial begin
        uart_in = 1;
        a_value = $random;
        b_value = $random;
        op_value = 4'b0110; // IAND

        send_i32(a_value, 1040, uart_in);
        send_i32(b_value, 1040, uart_in);
        send_i32(op_value, 1040, uart_in);

        while (~word_done) begin
            #10;
        end

        assert (calc_result == (a_value & b_value)) else begin
            $display("error: expected %8h, got %8h", a_value & b_value, calc_result);
            $fatal(1, "calc result is incorrect");
        end
        $finish;
    end

endmodule