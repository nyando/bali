`timescale 10ns / 10ns

task automatic push_value (input bit [31:0] value,
                           ref logic [31:0] data_in, 
                           ref logic push,
                           ref logic trigger);
    data_in = value;
    push = 1;
    trigger = 1;
    #10;
    push = 0;
    trigger = 0;
    #100;
endtask

task automatic pop_value (ref logic push, ref logic trigger);
    push = 0;
    trigger = 1;
    #10;
    trigger = 0;
    push = 0;
    #100;
endtask

module test_stack();

    logic clk;

    sim_clk clock (.clk(clk));

    logic push;
    logic trigger;
    logic [31:0] data_in;
    logic [31:0] data_out;
    logic done_out;

    stack #(
        .STACKDATA(32),
        .STACKSIZE(16)
    ) stack_instance(
        .clk(clk),
        .rst(),
        .push(push),
        .trigger(trigger),
        .write_value(data_in),
        .read_value(data_out),
        .done_out(done_out)
    );

    initial begin
        push_value(32'hcafe_babe, data_in, push, trigger);
        pop_value(push, trigger);
        assert (data_out == 32'hcafe_babe) else $fatal(1, "incorrect value popped from stack, expected %8h, got %8h", 32'hcafe_babe, data_out);

        push_value(32'hdead_beef, data_in, push, trigger);
        push_value(32'hb105_f00d, data_in, push, trigger);
        pop_value(push, trigger);
        assert (data_out == 32'hb105_f00d) else $fatal(1, "incorrect value popped from stack, expected %8h, got %8h", 32'hb105_f00d, data_out);

        pop_value(push, trigger);
        assert (data_out == 32'hdead_beef) else $fatal(1, "incorrect value popped from stack, expected %8h, got %8h", 32'hdead_beef, data_out);

        $finish;
    end

endmodule