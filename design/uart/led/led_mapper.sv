`timescale 10ns / 10ns

module led_mapper(
    input write_done,
    input [7:0] byte_in,
    output [7:0] led_out
);

    logic [7:0] led;

    always @ (write_done)
    begin
        led[0] <= byte_in[0];
        led[1] <= byte_in[1];
        led[2] <= byte_in[2];
        led[3] <= byte_in[3];
        led[4] <= byte_in[4];
        led[5] <= byte_in[5];
        led[6] <= byte_in[6];
        led[7] <= byte_in[7];
    end

    assign led_out[0] = led[0];
    assign led_out[1] = led[1];
    assign led_out[2] = led[2];
    assign led_out[3] = led[3];
    assign led_out[4] = led[4];
    assign led_out[5] = led[5];
    assign led_out[6] = led[6];
    assign led_out[7] = led[7];

endmodule
