`include "headers/opcodes.vh"
`include "headers/cmptypes.vh"

`timescale 10ns / 10ns

module decoder(
    input [7:0] opcode,
    output [3:0] aluop,
    output isaluop,
    output iscmp,
    output [3:0] cmptype,
    output isargpush,
    output isgoto,
    output [1:0] argc,       // number of arguments in program code
    output [1:0] stackargs,  // number of arguments on stack
    output stackwb,          // 1 if result is written back onto stack (as with ALU ops), 0 otherwise
    output constpush,
    output [31:0] constval
);

    logic [3:0] alu_op;
    logic is_aluop;
    logic is_cmp;
    logic [3:0] cmp_type;
    logic is_argpush;
    logic is_goto;
    logic [1:0] arg_c;
    logic [1:0] stack_args;
    logic stack_wb;
    logic const_push;
    logic [31:0] const_val;

    initial begin
        alu_op <= 4'h0;
        is_aluop <= 0;
        is_cmp <= 0;
        cmp_type <= 0;
        is_argpush <= 0;
        is_goto <= 0;
        arg_c <= 2'b00;
        stack_args <= 2'b00;
        stack_wb <= 0;
        const_push <= 0;
        const_val <= 32'h0000_0000;
    end

    always @ (opcode) begin
        // initialize default values for each output
        alu_op <= 4'h0;
        is_aluop <= 0;
        is_cmp <= 0;
        cmp_type <= 0;
        is_argpush <= 0;
        is_goto <= 0;
        arg_c <= 2'b00;
        stack_args <= 2'b00;
        stack_wb <= 0;
        const_push <= 0;
        const_val <= 32'h0000_0000;

        casez (opcode)
            NOP: begin
                // NOP
                arg_c <= 2'b00;
                stack_args <= 2'b00;
                stack_wb <= 0;
            end
            /* ICONST_N */ 8'h0?: begin
                case (opcode[3:0])
                    4'h2: begin
                        // push -1
                        const_val <= 32'hffff_ffff;
                    end
                    4'h3: begin
                        // push 0
                        const_val <= 32'h0000_0000;
                    end
                    4'h4: begin
                        // push 1
                        const_val <= 32'h0000_0001;
                    end
                    4'h5: begin
                        // push 2
                        const_val <= 32'h0000_0002;
                    end
                    4'h6: begin
                        // push 3
                        const_val <= 32'h0000_0003;
                    end
                    4'h7: begin
                        // push 4
                        const_val <= 32'h0000_0004;
                    end
                    4'h8: begin
                        // push 5
                        const_val <= 32'h0000_0005;
                    end
                    default: begin end
                endcase
                arg_c <= 2'b00;
                stack_args <= 2'b00;
                stack_wb <= 1;
                const_push <= 1;
            end
            SIPUSH: begin
                // SIPUSH (3 byte)
                arg_c <= 2'b10;
                stack_args <= 2'b00;
                stack_wb <= 1;
                is_argpush <= 1;
            end
            BIPUSH: begin
                // BIPUSH (2 byte)
                arg_c <= 2'b01;
                stack_args <= 2'b00;
                stack_wb <= 1;
                is_argpush <= 1;
            end
            LDC: begin
                // LDC (2 byte)
                arg_c <= 2'b01;
                stack_args <= 2'b00;
                stack_wb <= 1;
            end
            ILOAD: begin
                // ILOAD (2 byte)
                arg_c <= 2'b01;
                stack_args <= 2'b00;
                stack_wb <= 1;
            end
            /* ILOAD_N */ 8'h1?: begin
                case (opcode[3:0])
                    4'ha: begin
                        // load 0
                    end
                    4'hb: begin
                        // load 1
                    end
                    4'hc: begin
                        // load 2
                    end
                    4'hd: begin
                        // load 3
                    end
                    default: begin end
                endcase
                arg_c <= 2'b00;
                stack_args <= 2'b00;
                stack_wb <= 1;
            end
            IALOAD: begin
                // IALOAD
                arg_c <= 2'b00;
                stack_args <= 2'b10;
                stack_wb <= 1;
            end
            /* ALOAD_N */ 8'h2?: begin
                case (opcode[3:0])
                    4'ha: begin
                        // load 0
                    end
                    4'hb: begin
                        // load 1
                    end
                    4'hc: begin
                        // load 2
                    end
                    4'hd: begin
                        // load 3
                    end
                    default: begin end
                endcase
                arg_c <= 2'b00;
                stack_args <= 2'b00;
                stack_wb <= 1;
            end
            BALOAD: begin
                // BALOAD
                arg_c <= 2'b00;
                stack_args <= 2'b10;
                stack_wb <= 1;
            end
            ISTORE: begin
                // ISTORE (2 byte)
                arg_c <= 2'b01;
                stack_args <= 2'b01;
                stack_wb <= 0;
            end
            /* ISTORE_N */ 8'h3?: begin
                case (opcode[3:0])
                    4'hb: begin
                        // store 0
                    end
                    4'hc: begin
                        // store 1
                    end
                    4'hd: begin
                        // store 2
                    end
                    4'he: begin
                        // store 3
                    end
                    default: begin end
                endcase
                arg_c <= 2'b00;
                stack_args <= 2'b01;
                stack_wb <= 0;
            end
            IASTORE: begin
                // IASTORE
                arg_c <= 2'b00;
                stack_args <= 2'b11;
                stack_wb <= 0;
            end
            /* ASTORE_N */ 8'h4?: begin
                case (opcode[3:0])
                    4'hb: begin
                        // astore 0
                    end
                    4'hc: begin
                        // astore 1
                    end
                    4'hd: begin
                        // astore 2
                    end
                    4'he: begin
                        // astore 3
                    end
                    default: begin end
                endcase
                arg_c <= 2'b00;
                stack_args <= 2'b01;
                stack_wb <= 0;
            end
            BASTORE: begin
                // BASTORE
                arg_c <= 2'b00;
                stack_args <= 2'b11;
                stack_wb <= 0;
            end
            POP: begin
                // POP
                arg_c <= 2'b00;
                stack_args <= 2'b01;
                stack_wb <= 0;
            end
            DUP: begin
                // DUP
                arg_c <= 2'b00;
                stack_args <= 2'b01;
                stack_wb <= 0;
            end
            /* IADD, ISUB, IMUL, IDIV */ 8'h6?: begin
                alu_op <= {opcode[7], opcode[4], opcode[3], opcode[2]};
                is_aluop <= 1;
                arg_c <= 2'b00;
                stack_args <= 2'b10;
                stack_wb <= 1;
            end
            INEG: begin
                // INEG
                alu_op <= 4'b0101;
                is_aluop <= 1;
                stack_args <= 2'b01;
                stack_wb <= 1;
            end
            /* IREM, ISHL, ISHR, IAND */ 8'h7?: begin
                if (opcode[3]) begin /* ISHL, ISHR, IAND */
                    alu_op <= {~opcode[7], opcode[4], opcode[2], opcode[1]};
                end
                else begin /* IREM */
                    alu_op <= {opcode[7], opcode[4], opcode[3], opcode[2]};
                end
                is_aluop <= 1;
                arg_c <= 2'b00;
                stack_args <= 2'b10;
                stack_wb <= 1;
            end
            IINC: begin
                // IINC (3 byte)
                is_aluop <= 1;
                arg_c <= 2'b10;
                stack_args <= 2'b00;
                stack_wb <= 0;
            end
            /* IOR, IXOR */ 8'h8?: begin
                alu_op <= {opcode[7], opcode[4], opcode[2], opcode[1]};
                is_aluop <= 1;
                stack_args <= 2'b10;
                stack_wb <= 1;
            end
            GOTO: begin
                // GOTO (3 byte)
                arg_c <= 2'b10;
                stack_args <= 2'b00;
                stack_wb <= 0;
                is_goto <= 1;
            end
            IRETURN: begin
                // IRETURN
                arg_c <= 2'b00;
                stack_args <= 2'b01;
                stack_wb <= 0;
            end
            ARETURN: begin
                // ARETURN
                arg_c <= 2'b00;
                stack_args <= 2'b01;
                stack_wb <= 0;
            end
            RETURN: begin
                // RETURN
                arg_c <= 2'b00;
                stack_args <= 2'b00;
                stack_wb <= 0;
            end
            /* IFCOND, IF_ICMPCOND (3 byte) */ 8'b10??????: begin
                case (opcode[3:0])
                    4'h9: begin
                        // IFEQ
                        stack_args <= 2'b01;
                        stack_wb <= 0;
                        cmp_type[3] <= 0;
                        cmp_type[2:0] <= EQ;
                    end
                    4'ha: begin
                        // IFNE
                        stack_args <= 2'b01;
                        stack_wb <= 0;
                        cmp_type[3] <= 0;
                        cmp_type[2:0] <= NE;
                    end
                    4'hb: begin
                        // IFLT
                        stack_args <= 2'b01;
                        stack_wb <= 0;
                        cmp_type[3] <= 0;
                        cmp_type[2:0] <= LT;
                    end
                    4'hc: begin
                        // IFGE
                        stack_args <= 2'b01;
                        stack_wb <= 0;
                        cmp_type[3] <= 0;
                        cmp_type[2:0] <= GE;
                    end
                    4'hd: begin
                        // IFGT
                        stack_args <= 2'b01;
                        stack_wb <= 0;
                        cmp_type[3] <= 0;
                        cmp_type[2:0] <= GT;
                    end
                    4'he: begin
                        // IFLE
                        stack_args <= 2'b01;
                        stack_wb <= 0;
                        cmp_type[3] <= 0;
                        cmp_type[2:0] <= LE;
                    end
                    4'hf: begin
                        // IF_ICMPEQ
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                        cmp_type[3] <= 1;
                        cmp_type[2:0] <= EQ;
                    end
                    4'h0: begin
                        // IF_ICMPNE
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                        cmp_type[3] <= 1;
                        cmp_type[2:0] <= NE;
                    end
                    4'h1: begin
                        // IF_ICMPLT
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                        cmp_type[3] <= 1;
                        cmp_type[2:0] <= LT;
                    end
                    4'h2: begin
                        // IF_ICMPGE
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                        cmp_type[3] <= 1;
                        cmp_type[2:0] <= GE;
                    end
                    4'h3: begin
                        // IF_ICMPGT
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                        cmp_type[3] <= 1;
                        cmp_type[2:0] <= GT;
                    end
                    4'h4: begin
                        // IF_ICMPLE
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                        cmp_type[3] <= 1;
                        cmp_type[2:0] <= LE;
                    end
                    default: begin end
                endcase
                is_cmp <= 1;
                arg_c <= 2'b10;
            end
            default: begin
                alu_op <= 4'hX;
            end
        endcase
    end

    assign aluop = alu_op;
    assign isaluop = is_aluop;
    assign iscmp = is_cmp;
    assign cmptype = cmp_type;
    assign isargpush = is_argpush;
    assign isgoto = is_goto;
    assign argc = arg_c;
    assign stackargs = stack_args;
    assign stackwb = stack_wb;
    assign constpush = const_push;
    assign constval = const_val;

endmodule