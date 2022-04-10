`timescale 10ns / 10ns

module bali(
    input clk,
    input rst,
    input rx,
    output tx,
    output [7:0] addr
);
    
    logic divclk;

    clkdiv #(
        .CLKDIV_FACTOR(100)
    ) clkdiv_instance (
        .clk(clk),
        .divclk(divclk)
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
        .CYCLES_PER_BIT(104)
    ) bali_uart_rx (
        .clk(divclk),
        .rx(rx),
        .done(rxdone),
        .out(rxout)
    );

    logic [7:0] txin;
    logic txsend;
    logic txdone;

    uart_tx #(
        .CYCLES_PER_BIT(104)
    ) bali_uart_tx (
        .clk(divclk),
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

    cpu bali_cpu (
        .clk(clk),
        .rst(rst),
        .op_code(opcode),
        .arg1(arg1),
        .arg2(arg2),
        .dataparams(dataparams),
        .dataindex(dataindex),
        .program_counter(pc)
    );

    logic rwstate;

    always @ (posedge clk) begin
        if (rst) begin
            rwstate <= 0;
            progmemaddr <= 8'h00;
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

    assign addr = progmemaddr;

endmodule