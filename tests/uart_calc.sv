`timescale 100ns / 10ns

module uart_calc();

    logic clock;
    logic divclock;

    logic [7:0] byte_in;
    logic uart_in;
    logic rx_done;

    logic [31:0] word;
    logic word_done;

    // generate 100 MHz clock signal
    sim_clk arty_clock(clock);
    
    // divide clock signal to 1 MHz
    clkdiv clkdivider(clock, divclock);

    uart_rx #(.ticks_per_bit(104))
    uart_receiver(
        .clk(divclock),
        .rx(uart_in),
        .rx_done_out(rx_done),
        .data_out(byte_in)
    );

    word_rx word_receiver (
        .clk(divclock),
        .byte_in(byte_in),
        .rx_done(rx_done),
        .word_out(word),
        .word_done(word_done)
    );

    logic [1:0] rx_count;
    logic [31:0] a, b;
    logic [3:0] op;
    logic [31:0] lo;
    logic [31:0] hi;
    logic op_done;

    always @ (posedge word_done) begin
        case (rx_count)
            2'b00: begin
                a[31:0] <= word[31:0];
                rx_count <= rx_count + 1;
            end
            2'b01: begin
                b[31:0] <= word[31:0];
                rx_count <= rx_count + 1;
            end
            2'b10: begin
                op[3:0] <= word[3:0];
                op_done <= 1;
                rx_count <= rx_count + 1;
            end
            2'b11: begin
                rx_count <= 2'b00;
            end
            default: begin
                a <= 32'hXXXXXXXX;
                b <= 32'hXXXXXXXX;
                op <= 4'hX;
                rx_count <= 2'b00;
            end
        endcase
    end

    alu uart_alu(
        .operand_a(a),
        .operand_b(b),
        .op_select(op),
        .result_lo(lo),
        .result_hi(hi)
    );

    always @ (posedge op_done) begin
        lo_out <= lo;
        word_send <= 1;
    end

    logic byte_sent;
    logic tx_data_in;
    logic tx_send;
    logic tx_out;

    word_tx word_transmitter (
        .clk(divclock),
        .word_in(lo_out),
        .word_send(word_send),
        .byte_sent(byte_sent),
        .byte_out(tx_data_in),
        .uart_send(tx_send)
    );

    uart_tx #(.ticks_per_bit(104))
    uart_transmitter (
        .clk(divclock),
        .data_in(tx_data_in),
        .send(tx_send),
        .tx_out(tx_out),
        .tx_done(byte_sent)
    );

    initial begin
        rx_count = 2'b00;
        a = 31'h00000000;
        b = 32'h00000000;
        op = 4'h0;
        op_done = 0;
        uart_in = 1;
        #10;

        for (int i = 0; i < 4; i++) begin
            uart_in = 0;
            #1040;
            for (int j = 0; j < 8; j++) begin
                uart_in = 1;
                #1040;
            end
            uart_in = 1;
            #10000;
        end
        #10000;
        
        for (int i = 0; i < 4; i++) begin
            uart_in = 0;
            #1040;
            for (int j = 0; j < 8; j++) begin
                uart_in = 1;
                #1040;
            end
            uart_in = 1;
            #10000;
        end
        #10000;

        assert (a == 32'hFFFFFFFF) else
            $fatal(1, "a should be all 1s");
        
        assert (b == 32'hFFFFFFFF) else
            $fatal(1, "b should be all 1s");
        
        uart_in = 0;
        #1040;
        uart_in = 0;
        #1040;
        uart_in = 1;
        #1040;
        uart_in = 0;
        #1040;
        uart_in = 0;
        #1040;
        uart_in = 0;
        #1040;
        uart_in = 0;
        #1040;
        uart_in = 0;
        #1040;
        uart_in = 0;
        #1040;
        uart_in = 1;
        
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

        assert (op_done == 1) else
            $fatal(1, "alu did not complete operation");
        
        #200000;
        
        $finish;
    end

endmodule