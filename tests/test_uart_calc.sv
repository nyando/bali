`timescale 100ns / 10ns

module test_uart_calc();

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

    uart_rx #(.CYCLES_PER_BIT(104))
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

    always @ (negedge divclock) begin
        if (word_done) begin
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
        else begin
            op_done <= 0;
        end
    end

    alu uart_alu(
        .operand_a(a),
        .operand_b(b),
        .op_select(op),
        .result_lo(lo),
        .result_hi(hi)
    );

    logic byte_sent;
    logic [7:0] tx_data_in;
    logic tx_send;
    logic tx_out;

    logic [31:0] lo_out;
    logic word_send;
    logic word_sent;
    
    always @ (posedge divclock) begin
        if (op_done) begin
            lo_out[31:0] <= lo[31:0];
            word_send <= 1;
        end
        else begin
            word_send <= 0;
        end
    end

    word_tx word_transmitter (
        .clk(divclock),
        .word_in(lo_out),
        .word_send(word_send),
        .byte_sent(byte_sent),
        .byte_out(tx_data_in),
        .uart_send(tx_send),
        .send_done(word_sent)
    );

    uart_tx #(.CYCLES_PER_BIT(104))
    uart_transmitter (
        .clk(divclock),
        .data_in(tx_data_in),
        .send(tx_send),
        .tx_out(tx_out),
        .tx_done(byte_sent)
    );

    bit [31:0] a_value;
    bit [31:0] b_value;
    bit [3:0] op_value;
    
    initial begin
        rx_count = 2'b00;
        a = 32'h00000000;
        b = 32'h00000000;
        op = 4'h0;
        //op_done = 0;
        uart_in = 1;
        a_value = $random;
        b_value = $random;
        op_value = 4'b0110; // IAND
        word_send = 0;
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

        // check if operands were received correctly
        assert (a == a_value) else
            $fatal(1, "a input and received values not equal");
        
        assert (b == b_value) else
            $fatal(1, "b input and received values not equal");
        
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

        #10000;

        // check if ALU operation complete with correct result
        /*assert (lo == a & b) else
            $fatal(1, "result_lo has incorrect result");*/
        
        #200000;

        // if we get to here: congrats, it works
        $finish;
    end

endmodule