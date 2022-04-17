`timescale 10ns / 10ns

module divmod #(
    parameter WIDTH = 32
) (
    input clk,
    input trigger,
    output done,
    input [WIDTH - 1:0] a,
    input [WIDTH - 1:0] b,
    output [WIDTH - 1:0] q,
    output [WIDTH - 1:0] r
);

    logic calc, is_done;

    logic [WIDTH - 1:0] divisor;
    logic [WIDTH - 1:0] quot, rem, quot_next;
    logic [WIDTH:0] acc, acc_next;
    logic [$clog2(WIDTH) - 1:0] iter;

    always_comb begin
        if (acc >= { 1'b0, divisor }) begin
            acc_next = acc - divisor;
            { acc_next, quot_next } = { acc_next[WIDTH - 1:0], quot, 1'b1 };
        end else begin
            { acc_next, quot_next } = { acc, quot } << 1;
        end
    end

    always @ (posedge clk) begin
        if (is_done) begin
            is_done <= 0;
        end
        
        if (calc) begin
            if (iter == WIDTH - 1) begin
                is_done <= 1;
                calc <= 0;
                quot <= quot_next;
                rem <= acc_next[WIDTH:1];
            end else begin
                iter <= iter + 1;
                acc <= acc_next;
                quot <= quot_next;
            end
        end
        
        if (trigger) begin
            calc <= 1;
            iter <= 0;
            divisor <= b;
            { acc, quot } <= { { WIDTH { 1'b0 } }, a, 1'b0 };
        end
    end

    assign q = quot;
    assign r = rem;
    assign done = is_done;

endmodule