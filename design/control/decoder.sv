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
    output isconstpush,
    output [2:0] constval,
    output isgoto,
    output islvaread,
    output islvawrite,
    output [1:0] lvaindex,
    output isnewarray,
    output isarrread,
    output isarrwrite,
    output ispop,
    output isdup,
    output isldc,
    output isiinc,
    output [1:0] argc,       // number of arguments in program code
    output [1:0] stackargs,  // number of arguments on stack
    output stackwb           // 1 if result is written back onto stack (as with ALU ops), 0 otherwise
);

    logic [3:0] alu_op;
    logic is_aluop;
    logic is_cmp;
    logic [3:0] cmp_type;
    logic is_constpush;
    logic [31:0] const_val;
    logic is_argpush;
    logic is_goto;
    logic is_lvaread;
    logic is_lvawrite;
    logic [1:0] lva_index;
    logic is_newarray;
    logic is_arrread;
    logic is_arrwrite;
    logic is_pop;
    logic is_dup;
    logic is_ldc;
    logic is_iinc;
    logic [1:0] arg_c;
    logic [1:0] stack_args;
    logic stack_wb;

    always @ (opcode) begin
        // initialize default values for each output
        alu_op <= 4'h0;
        is_aluop <= 0;
        is_cmp <= 0;
        cmp_type <= 4'h0;
        is_argpush <= 0;
        is_goto <= 0;
        is_lvaread <= 0;
        is_lvawrite <= 0;
        lva_index <= 2'b00;
        is_newarray <= 0;
        is_arrread <= 0;
        is_arrwrite <= 0;
        is_pop <= 0;
        is_dup <= 0;
        is_ldc <= 0;
        is_iinc <= 0;
        arg_c <= 2'b00;
        stack_args <= 2'b00;
        stack_wb <= 0;
        is_constpush <= 0;
        const_val <= 3'b000;

        casez (opcode)
            NOP: begin end // NOP
            /* ICONST_N */ 8'h0?: begin
                is_constpush <= 1;
                case (opcode[3:0])
                    4'h2: begin const_val <= 3'b111; end // push -1
                    4'h3: begin const_val <= 3'b000; end // push 0
                    4'h4: begin const_val <= 3'b001; end // push 1
                    4'h5: begin const_val <= 3'b010; end // push 2
                    4'h6: begin const_val <= 3'b011; end // push 3
                    4'h7: begin const_val <= 3'b100; end // push 4
                    4'h8: begin const_val <= 3'b101; end // push 5
                    default: begin end
                endcase
                stack_wb <= 1;
            end
            SIPUSH: begin
                // SIPUSH (3 byte)
                is_argpush <= 1;
                arg_c <= 2'b10;
                stack_wb <= 1;
            end
            BIPUSH: begin
                // BIPUSH (2 byte)
                is_argpush <= 1;
                arg_c <= 2'b01;
                stack_wb <= 1;
            end
            LDC: begin
                // LDC (2 byte)
                is_ldc <= 1;
                arg_c <= 2'b01;
                stack_wb <= 1;
            end
            ILOAD: begin
                // ILOAD (2 byte)
                is_lvaread <= 1;
                arg_c <= 2'b01;
                stack_wb <= 1;
            end
            /* ILOAD_N */ 8'h1?: begin
                is_lvaread <= 1;
                case (opcode[3:0])
                    4'ha: begin lva_index <= 2'b00; end // lva index 0
                    4'hb: begin lva_index <= 2'b01; end // lva index 1
                    4'hc: begin lva_index <= 2'b10; end // lva index 2
                    4'hd: begin lva_index <= 2'b11; end // lva index 3
                    default: begin end
                endcase
                stack_wb <= 1;
            end
            IALOAD: begin
                // IALOAD
                is_arrread <= 1;
                stack_args <= 2'b10;
                stack_wb <= 1;
            end
            /* ALOAD_N */ 8'h2?: begin
                // array reference is always 0
                is_lvaread <= 1;
                case (opcode[3:0])
                    4'ha: begin lva_index <= 2'b00; end // lva index 0
                    4'hb: begin lva_index <= 2'b01; end // lva index 1
                    4'hc: begin lva_index <= 2'b10; end // lva index 2
                    4'hd: begin lva_index <= 2'b11; end // lva index 3
                    default: begin end
                endcase
                stack_wb <= 1;
            end
            BALOAD: begin
                // BALOAD
                is_arrread <= 1;
                stack_args <= 2'b10;
                stack_wb <= 1;
            end
            ISTORE: begin
                // ISTORE (2 byte)
                is_lvawrite <= 1;
                arg_c <= 2'b01;
                stack_args <= 2'b01;
            end
            /* ISTORE_N */ 8'h3?: begin
                is_lvawrite <= 1;
                case (opcode[3:0])
                    4'hb: begin lva_index <= 2'b00; end // lva index 0
                    4'hc: begin lva_index <= 2'b01; end // lva index 1
                    4'hd: begin lva_index <= 2'b10; end // lva index 2
                    4'he: begin lva_index <= 2'b11; end // lva index 3
                    default: begin end
                endcase
                stack_args <= 2'b01;
            end
            IASTORE: begin
                // IASTORE
                is_arrwrite <= 1;
                stack_args <= 2'b11;
            end
            /* ASTORE_N */ 8'h4?: begin
                // array reference is always 0
                is_lvawrite <= 1;
                case (opcode[3:0])
                    4'hb: begin lva_index <= 2'b00; end // lva index 0
                    4'hc: begin lva_index <= 2'b01; end // lva index 1
                    4'hd: begin lva_index <= 2'b10; end // lva index 2
                    4'he: begin lva_index <= 2'b11; end // lva index 3
                    default: begin end
                endcase
                stack_args <= 2'b01;
            end
            BASTORE: begin
                // BASTORE
                is_arrwrite <= 1;
                stack_args <= 2'b11;
            end
            POP: begin
                // POP
                is_pop <= 1;
                stack_args <= 2'b01;
            end
            DUP: begin
                // DUP
                is_dup <= 1;
                stack_args <= 2'b01;
            end
            /* IADD, ISUB, IMUL, IDIV */ 8'h6?: begin
                alu_op <= {opcode[7], opcode[4], opcode[3], opcode[2]};
                is_aluop <= 1;
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
                stack_args <= 2'b10;
                stack_wb <= 1;
            end
            IINC: begin
                // IINC (3 byte)
                is_iinc <= 1;
                arg_c <= 2'b10;
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
                is_goto <= 1;
            end
            IRETURN: begin end
            ARETURN: begin end
            RETURN: begin end
            NEWARRAY: begin
                is_newarray <= 1;
                arg_c <= 2'b01;
                stack_args <= 2'b01;
                stack_wb <= 1;
            end
            /* IFCOND, IF_ICMPCOND (3 byte) */ 8'b10??????: begin
                if (opcode >= 8'h99 || opcode <= 8'ha4) begin
                    is_cmp <= 1;
                    case (opcode[3:0])
                        4'h9: begin
                            // IFEQ
                            stack_args <= 2'b01;
                            cmp_type[2:0] <= EQ;
                        end
                        4'ha: begin
                            // IFNE
                            stack_args <= 2'b01;
                            cmp_type[2:0] <= NE;
                        end
                        4'hb: begin
                            // IFLT
                            stack_args <= 2'b01;
                            cmp_type[2:0] <= LT;
                        end
                        4'hc: begin
                            // IFGE
                            stack_args <= 2'b01;
                            cmp_type[2:0] <= GE;
                        end
                        4'hd: begin
                            // IFGT
                            stack_args <= 2'b01;
                            cmp_type[2:0] <= GT;
                        end
                        4'he: begin
                            // IFLE
                            stack_args <= 2'b01;
                            cmp_type[2:0] <= LE;
                        end
                        4'hf: begin
                            // IF_ICMPEQ
                            stack_args <= 2'b10;
                            cmp_type[3] <= 1;
                            cmp_type[2:0] <= EQ;
                        end
                        4'h0: begin
                            // IF_ICMPNE
                            stack_args <= 2'b10;
                            cmp_type[3] <= 1;
                            cmp_type[2:0] <= NE;
                        end
                        4'h1: begin
                            // IF_ICMPLT
                            stack_args <= 2'b10;
                            cmp_type[3] <= 1;
                            cmp_type[2:0] <= LT;
                        end
                        4'h2: begin
                            // IF_ICMPGE
                            stack_args <= 2'b10;
                            cmp_type[3] <= 1;
                            cmp_type[2:0] <= GE;
                        end
                        4'h3: begin
                            // IF_ICMPGT
                            stack_args <= 2'b10;
                            cmp_type[3] <= 1;
                            cmp_type[2:0] <= GT;
                        end
                        4'h4: begin
                            // IF_ICMPLE
                            stack_args <= 2'b10;
                            cmp_type[3] <= 1;
                            cmp_type[2:0] <= LE;
                        end
                        default: begin end
                    endcase
                    arg_c <= 2'b10;
                end
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
    assign islvaread = is_lvaread;
    assign islvawrite = is_lvawrite;
    assign lvaindex = lva_index;
    assign isnewarray = is_newarray;
    assign isarrread = is_arrread;
    assign isarrwrite = is_arrwrite;
    assign ispop = is_pop;
    assign isdup = is_dup;
    assign isldc = is_ldc;
    assign isiinc = is_iinc;
    assign argc = arg_c;
    assign stackargs = stack_args;
    assign stackwb = stack_wb;
    assign isconstpush = is_constpush;
    assign constval = const_val;

endmodule