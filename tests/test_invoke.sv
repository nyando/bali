`timescale 10ns / 10ns

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

    logic [7:0] op_code;

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
        .arrop(),
        .arraddr(),
        .arrreadvalue(),
        .arrwritevalue(),
        .arrtrigger(),
        .arrdone(),
        .evalpush(evalpush),
        .evaltrigger(evaltrigger),
        .evalread(evalread),
        .evalwrite(evalwrite),
        .evaldone(evaldone),
        .offset(),
        .op_done()
    );

    initial begin
        op_code = 8'h04;
        #6;
        op_code = 8'h05;
        #6;

        // set opcode to invokestatic
        op_code = 8'hb8;
        #10;

        // trigger first lva move
        lvamoveindex = 8'h00;
        lvamove = 1;
        #1;
        lvamove = 0;
        #10;

        // trigger second lva move
        lvamoveindex = 8'h01;
        lvamove = 1;
        #1;
        lvamove = 0;
        #10;

        $finish;

    end


endmodule