`timescale 10ns / 10ns

module bali(
    input clk,
    input rst,
    input rx,
    output tx,
    output executing
);
    
    logic [7:0] opcode;
    logic [7:0] arg1;
    logic [7:0] arg2;

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
    logic txsend;
    logic txdone;

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
    logic [7:0] progmemaddr;
    logic [7:0] progmemvalue;

    progmem #(
        .SIZE(256)
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

    logic [7:0] proglength;

    logic [31:0] cycles;
    logic rwstate;
    logic [1:0] bytecount;

    always @ (posedge clk) begin
        if (cpurst) begin
            cpurst <= 0;
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
                    proglength <= rxout;
                    progmemaddr <= 8'h00;
                    txin <= rxout;
                    txsend <= 1;
                    state <= LOADPROG;
                end
            end
            LOADPROG: begin
                txsend <= 0;
                if (progmemaddr == proglength) begin
                    cycles <= 32'h0000_0000;
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
                    bytecount <= 2'b01;
                    txsend <= 1;
                end
                cpurst <= 0;
                cycles <= cycles + 1;
            end
            DONE: begin
                txsend <= 0;
                if (txdone) begin
                    case (bytecount)
                        2'b01: begin
                            txin <= cycles[15:8];
                            txsend <= 1;
                        end
                        2'b10: begin
                            txin <= cycles[23:16];
                            txsend <= 1;
                        end
                        2'b11: begin
                            txin <= cycles[31:24];
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

    assign executing = state[1];

endmodule