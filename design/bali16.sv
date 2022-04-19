`timescale 10ns / 10ns

module bali16(
    input clk,
    input rst,
    input rx,
    output tx,
    output [1:0] exec
);
    
    logic [7:0] opcode, arg1, arg2;

    logic [15:0] pc;
    logic [7:0] dataindex;
    logic [31:0] dataparams;

    logic rxdone;
    logic [7:0] rxout;

    uart_rx #(
        .CYCLES_PER_BIT(10400)
    ) bali_uart_rx (
        .clk(clk),
        .rx(rx),
        .done(rxdone),
        .out(rxout)
    );

    logic [7:0] txin;
    logic txsend, txdone;

    uart_tx #(
        .CYCLES_PER_BIT(10400)
    ) bali_uart_tx (
        .clk(clk),
        .in(txin),
        .send(txsend),
        .tx(tx),
        .done(txdone)
    );

    logic progwrite;
    logic [15:0] progmemaddr;
    logic [7:0] progmemvalue;

    progmem #(
        .SIZE(2048)
    ) bali_mem (
        .clk(clk),
        .write(progwrite),
        .writeaddr(progmemaddr),
        .writevalue(progmemvalue),
        .constindex(dataindex),
        .constparams(dataparams),
        .programcounter(pc),
        .opcode(opcode),
        .arg1(arg1),
        .arg2(arg2)
    );

    logic cpurst;

    cpu bali_cpu (
        .clk(clk),
        .rst(cpurst),
        .op_code(opcode),
        .arg1(arg1),
        .arg2(arg2),
        .dataparams(dataparams),
        .dataindex(dataindex),
        .program_counter(pc)
    );

    logic [1:0] state;
    const logic [1:0] IDLE     = 2'b00;
    const logic [1:0] LOADPROG = 2'b01;
    const logic [1:0] EXECUTE  = 2'b10;
    const logic [1:0] DONE     = 2'b11;

    logic [15:0] proglength;
    logic fstbyte;

    logic [63:0] cycles;
    logic rwstate;
    logic [2:0] bytecount;

    always @ (posedge clk) begin
        if (cpurst) begin
            cpurst <= 0;
            fstbyte <= 0;
        end

        if (rst) begin
            state <= IDLE;
            progmemaddr <= 8'h00;
            cpurst <= 1;
        end

        case (state)
            IDLE: begin
                txsend <= 0;
                state <= IDLE;
                if (rxdone) begin
                    if (fstbyte) begin
                        proglength[15:8] <= rxout[7:0];
                        progmemaddr <= 16'h0000;
                        txin <= rxout;
                        txsend <= 1;
                        state <= LOADPROG;
                    end else begin
                        proglength[7:0] <= rxout[7:0];
                        txin <= rxout;
                        txsend <= 1;
                        fstbyte <= 1;
                    end
                end
            end
            LOADPROG: begin
                txsend <= 0;
                fstbyte <= 0;
                if (progmemaddr == proglength) begin
                    cycles <= 64'h0000_0000_0000_0000;
                    cpurst <= 1;
                    if (txdone) begin
                        state <= EXECUTE;
                    end
                end
                if (rwstate) begin
                    rwstate <= 0;
                    progwrite <= 0;
                    progmemaddr <= progmemaddr + 1;
                    txsend <= 0;
                end
                if (rxdone) begin
                    rwstate <= 1;
                    progwrite <= 1;
                    progmemvalue <= rxout;
                    txin <= progmemaddr;
                    txsend <= 1;
                end
            end
            EXECUTE: begin
                if (opcode == 8'hff) begin
                    state <= DONE;
                    txin <= cycles[7:0];
                    bytecount <= 3'b001;
                    txsend <= 1;
                end
                cpurst <= 0;
                cycles <= cycles + 1;
            end
            DONE: begin
                txsend <= 0;
                if (txdone) begin
                    case (bytecount)
                        3'b001: begin
                            txin <= cycles[15:8];
                            txsend <= 1;
                        end
                        3'b010: begin
                            txin <= cycles[23:16];
                            txsend <= 1;
                        end
                        3'b011: begin
                            txin <= cycles[31:24];
                            txsend <= 1;
                        end
                        3'b100: begin
                            txin <= cycles[39:32];
                            txsend <= 1;
                        end
                        3'b101: begin
                            txin <= cycles[47:40];
                            txsend <= 1;
                        end
                        3'b110: begin
                            txin <= cycles[55:48];
                            txsend <= 1;
                        end
                        3'b111: begin
                            txin <= cycles[63:56];
                            txsend <= 1;
                            state <= IDLE;
                        end
                        default: begin end
                    endcase
                    bytecount <= bytecount + 1;
                end
            end
            default: begin end
        endcase
    end

    assign exec = state;

endmodule