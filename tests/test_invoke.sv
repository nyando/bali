module test_invoke();

    logic clk;

    sim_clk simclk (
        .clk(clk)
    );

    logic lvaop;
    logic lvatrigger;
    logic [7:0] lvaindex;
    logic [31:0] lvaread;
    logic [31:0] lvawrite;
    logic lvadone;

    lva #(
        .LVA_SIZE(8)
    ) uut_lva (
        .clk(clk),
        .write(lvaop),
        .trigger(lvatrigger),
        .addr(lvaindex),
        .writevalue(lvawrite),
        .readvalue(lvaread),
        .done(lvadone)
    );

    logic evalpush;
    logic evaltrigger;
    logic [31:0] evalwrite;
    logic [31:0] evalread;
    logic evaldone;

    stack #(
        .STACKDATA(32),
        .STACKSIZE(16)
    ) uut_stack (
        .clk(clk),
        .push(evalpush),
        .trigger(evaltrigger),
        .write_value(evalwrite),
        .read_value(evalread),
        .done_out(evaldone)
    );

    logic lvamove;
    logic [7:0] lvamoveindex;
    logic lvamovedone;

    control uut_control (
        .clk(clk),
        .op_code(op_code),
        .arg1(),
        .arg2(),
        .ldconst(),
        .lvadone(lvadone),
        .lvaread(lvaread),
        .lvawrite(lvawrite),
        .lvaindex(lvaindex),
        .lvaop(lvaop),
        .lvatrigger(lvatrigger),
        .lvamove(lvamove),
        .lvamoveindex(lvamoveindex),
        .lvamovedone(lvamovedone),
        .evalpush(evalpush),
        .evaltrigger(evaltrigger),
        .evalread(evalread),
        .evalwrite(evalwrite),
        .evaldone(evaldone),
        .offset(),
        .op_done()
    );


endmodule