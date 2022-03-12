`timescale 10ns / 10ns

module progmem #(
    parameter SIZE = 65_536,
    localparam PC_LEN = $clog2(SIZE)
) (
    input clk,
    input write,
    input [15:0] writeaddr,
    input [7:0] writevalue,
    input [7:0] constindex,
    output [31:0] constparams,
    input [PC_LEN - 1:0] programcounter,
    output [7:0] opcode,
    output [7:0] arg1,
    output [7:0] arg2
);

    logic [7:0] mem [SIZE - 1:0];
    logic [31:0] const_params;
    logic [7:0] op_code;
    logic [7:0] arg_1;
    logic [7:0] arg_2;
    
    always @ (posedge clk) begin
        if (write) begin
            mem[writeaddr] <= writevalue;
        end

        const_params <= { mem[constindex * 4],
                          mem[constindex * 4 + 1],
                          mem[constindex * 4 + 2],
                          mem[constindex * 4 + 3] };
        op_code <= mem[programcounter];
        arg_1 <= mem[programcounter + 1];
        arg_2 <= mem[programcounter + 2];
    end

    assign constparams = const_params;
    assign opcode = op_code;
    assign arg1 = arg_1;
    assign arg2 = arg_2;

endmodule