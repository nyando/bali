`timescale 10ns / 10ns

module decoder(
    input [7:0] opcode,
    output [3:0] aluop,
    output isaluop,
    output [1:0] argc,       // number of arguments in program code
    output [1:0] stackargs,  // number of arguments on stack
    output stackwb,          // 1 if result is written back onto stack (as with ALU ops), 0 otherwise
    output constpush,
    output [31:0] constval
);

    // nop - no operation
    const logic [7:0] NOP = 8'h00;

    /* STACK PUSH OPERATIONS */

    // iconst_n - push constant integer to stack
    const logic [7:0] ICONST_M1 = 8'h02;
    const logic [7:0] ICONST_0  = 8'h03;
    const logic [7:0] ICONST_1  = 8'h04;
    const logic [7:0] ICONST_2  = 8'h05;
    const logic [7:0] ICONST_3  = 8'h06;
    const logic [7:0] ICONST_4  = 8'h07;
    const logic [7:0] ICONST_5  = 8'h08;

    // bipush - push byte integer to top of stack
    const logic [7:0] BIPUSH = 8'h10;

    // sipush - push short integer to top of stack
    const logic [7:0] SIPUSH = 8'h11;

    // ldc - push constant from constant pool to top of stack
    const logic [7:0] LDC = 8'h12;

    /* LOCAL/ARRAY LOAD INSTRUCTIONS */

    // iload - load integer from local variable
    const logic [7:0] ILOAD = 8'h15;
    
    // iload_n - load integer from local variable
    const logic [7:0] ILOAD_0 = 8'h1a;
    const logic [7:0] ILOAD_1 = 8'h1b;
    const logic [7:0] ILOAD_2 = 8'h1c;
    const logic [7:0] ILOAD_3 = 8'h1d;

    // aload_n - load array reference from local variable
    const logic [7:0] ALOAD_0 = 8'h2a;
    const logic [7:0] ALOAD_1 = 8'h2b;
    const logic [7:0] ALOAD_2 = 8'h2c;
    const logic [7:0] ALOAD_3 = 8'h2d;

    // iaload - load integer from array
    const logic [7:0] IALOAD = 8'h2e;

    // baload - load byte or boolean from array
    const logic [7:0] BALOAD = 8'h33;

    /* LOCAL/ARRAY STORE INSTRUCTIONS */

    // istore - store top of stack to local variable
    const logic [7:0] ISTORE = 8'h36;

    // istore_n - store constant integer in local variable
    const logic [7:0] ISTORE_0 = 8'h3b;
    const logic [7:0] ISTORE_1 = 8'h3c;
    const logic [7:0] ISTORE_2 = 8'h3d;
    const logic [7:0] ISTORE_3 = 8'h3e;

    // astore_n - store array reference to local variable
    const logic [7:0] ASTORE_0 = 8'h4b;
    const logic [7:0] ASTORE_1 = 8'h4c;
    const logic [7:0] ASTORE_2 = 8'h4d;
    const logic [7:0] ASTORE_3 = 8'h4e;
    
    // iastore - store integer to array
    const logic [7:0] IASTORE = 8'h4f;

    // bastore - store byte or boolean to array
    const logic [7:0] BASTORE = 8'h54;

    /* SPECIAL STACK OPERATIONS */

    // pop - remove top of stack
    const logic [7:0] POP = 8'h57;

    // dup - duplicate top of stack
    const logic [7:0] DUP = 8'h59;

    /* ARITHMETIC-LOGIC OPERATIONS */

    // arithmetic and logical instructions for integer types (implemented in ALU)
    const logic [7:0] IADD = 8'h60; // aluop: 0000
    const logic [7:0] ISUB = 8'h64; //        0001
    const logic [7:0] IMUL = 8'h68; //        0010
    const logic [7:0] IDIV = 8'h6c; //        0011
    const logic [7:0] IREM = 8'h70; //        0100
    const logic [7:0] INEG = 8'h74; //        0101
    const logic [7:0] ISHL = 8'h78; //        1100
    const logic [7:0] ISHR = 8'h7a; //        1101
    const logic [7:0] IAND = 8'h7e; //        1111
    const logic [7:0] IOR  = 8'h80; //        1000
    const logic [7:0] IXOR = 8'h82; //        1001
    const logic [7:0] IINC = 8'h84; //        1010

    /* COMPARISON BRANCH OPERATIONS */

    // if - branch on successful comparison with zero
    const logic [7:0] IFEQ = 8'h99;
    const logic [7:0] IFNE = 8'h9a;
    const logic [7:0] IFLT = 8'h9b;
    const logic [7:0] IFGE = 8'h9c;
    const logic [7:0] IFGT = 8'h9d;
    const logic [7:0] IFLE = 8'h9e;

    // if_icmp - branch on successful integer comparison
    const logic [7:0] IF_ICMPEQ = 8'h9f;
    const logic [7:0] IF_ICMPNE = 8'ha0;
    const logic [7:0] IF_ICMPLT = 8'ha1;
    const logic [7:0] IF_ICMPGE = 8'ha2;
    const logic [7:0] IF_ICMPGT = 8'ha3;
    const logic [7:0] IF_ICMPLE = 8'ha4;
    
    /* UNCONDITIONAL JUMP OPERATIONS */
    
    // goto - branch always (unconditional jump)
    const logic [7:0] GOTO = 8'ha7;

    // ireturn - return integer from method
    const logic [7:0] IRETURN = 8'hac;

    // areturn - return reference (array) type from method
    const logic [7:0] ARETURN = 8'hb0;

    // return - return void from method
    const logic [7:0] RETURN  = 8'hb1;

    logic [3:0] alu_op;
    logic is_aluop;
    logic [1:0] arg_c;
    logic [1:0] stack_args;
    logic stack_wb;
    logic const_push;
    logic [31:0] const_val;

    initial begin
        alu_op <= 4'h0;
        is_aluop <= 0;
        arg_c <= 2'b00;
        stack_args <= 2'b00;
        stack_wb <= 0;
        const_push <= 0;
        const_val <= 32'h0000_0000;
    end

    always @ (opcode) begin
        alu_op <= 4'h0;
        is_aluop <= 0;
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
            end
            BIPUSH: begin
                // BIPUSH (2 byte)
                arg_c <= 2'b01;
                stack_args <= 2'b00;
                stack_wb <= 1;
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
                    end
                    4'ha: begin
                        // IFNE
                        stack_args <= 2'b01;
                        stack_wb <= 0;
                    end
                    4'hb: begin
                        // IFLT
                        stack_args <= 2'b01;
                        stack_wb <= 0;
                    end
                    4'hc: begin
                        // IFGE
                        stack_args <= 2'b01;
                        stack_wb <= 0;
                    end
                    4'hd: begin
                        // IFGT
                        stack_args <= 2'b01;
                        stack_wb <= 0;
                    end
                    4'he: begin
                        // IFLE
                        stack_args <= 2'b01;
                        stack_wb <= 0;
                    end
                    4'hf: begin
                        // IF_ICMPEQ
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                    end
                    4'h0: begin
                        // IF_ICMPNE
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                    end
                    4'h1: begin
                        // IF_ICMPLT
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                    end
                    4'h2: begin
                        // IF_ICMPGE
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                    end
                    4'h3: begin
                        // IF_ICMPGT
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                    end
                    4'h4: begin
                        // IF_ICMPLE
                        stack_args <= 2'b10;
                        stack_wb <= 0;
                    end
                    default: begin end
                endcase
                arg_c <= 2'b10;
            end
            default: begin
                alu_op <= 4'hX;
            end
        endcase
    end

    assign aluop = alu_op;
    assign isaluop = is_aluop;
    assign argc = arg_c;
    assign stackargs = stack_args;
    assign stackwb = stack_wb;
    assign constpush = const_push;
    assign constval = const_val;

endmodule