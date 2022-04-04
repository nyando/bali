`ifndef _OPCODES_H_
`define _OPCODES_H_

/*
 * OPCODES - This header file contains the values for
 * the subset of the JVM instruction set implemented by the Bali processor.
 * They're only needed in the decoder unit, but were moved to this header file
 * for better readability and accessibility.
 */

// nop - no operation
localparam NOP = 8'h00;

/* STACK PUSH OPERATIONS */

// iconst_n - push constant integer to stack
localparam ICONST_M1 = 8'h02;
localparam ICONST_0  = 8'h03;
localparam ICONST_1  = 8'h04;
localparam ICONST_2  = 8'h05;
localparam ICONST_3  = 8'h06;
localparam ICONST_4  = 8'h07;
localparam ICONST_5  = 8'h08;

// bipush - push byte integer to top of stack
localparam BIPUSH = 8'h10;

// sipush - push short integer to top of stack
localparam SIPUSH = 8'h11;

// ldc - push constant from constant pool to top of stack
localparam LDC = 8'h12;

/* LOCAL/ARRAY LOAD INSTRUCTIONS */

// iload - load integer from local variable
localparam ILOAD = 8'h15;

// iload_n - load integer from local variable
localparam ILOAD_0 = 8'h1a;
localparam ILOAD_1 = 8'h1b;
localparam ILOAD_2 = 8'h1c;
localparam ILOAD_3 = 8'h1d;

// aload_n - load array reference from local variable
localparam ALOAD_0 = 8'h2a;
localparam ALOAD_1 = 8'h2b;
localparam ALOAD_2 = 8'h2c;
localparam ALOAD_3 = 8'h2d;

// iaload - load integer from array
localparam IALOAD = 8'h2e;

// baload - load byte or boolean from array
localparam BALOAD = 8'h33;

/* LOCAL/ARRAY STORE INSTRUCTIONS */

// istore - store top of stack to local variable
localparam ISTORE = 8'h36;

// istore_n - store constant integer in local variable
localparam ISTORE_0 = 8'h3b;
localparam ISTORE_1 = 8'h3c;
localparam ISTORE_2 = 8'h3d;
localparam ISTORE_3 = 8'h3e;

// astore_n - store array reference to local variable
localparam ASTORE_0 = 8'h4b;
localparam ASTORE_1 = 8'h4c;
localparam ASTORE_2 = 8'h4d;
localparam ASTORE_3 = 8'h4e;

// iastore - store integer to array
localparam IASTORE = 8'h4f;

// bastore - store byte or boolean to array
localparam BASTORE = 8'h54;

/* SPECIAL STACK OPERATIONS */

// pop - remove top of stack
localparam POP = 8'h57;

// dup - duplicate top of stack
localparam DUP = 8'h59;

/* ARITHMETIC-LOGIC OPERATIONS */

// arithmetic and logical instructions for integer types (implemented in ALU)
localparam IADD = 8'h60; // aluop: 0000
localparam ISUB = 8'h64; //        0001
localparam IMUL = 8'h68; //        0010
localparam IDIV = 8'h6c; //        0011
localparam IREM = 8'h70; //        0100
localparam INEG = 8'h74; //        0101
localparam ISHL = 8'h78; //        1100
localparam ISHR = 8'h7a; //        1101
localparam IAND = 8'h7e; //        1111
localparam IOR  = 8'h80; //        1000
localparam IXOR = 8'h82; //        1001
localparam IINC = 8'h84; //        1010

/* COMPARISON BRANCH OPERATIONS */

// if - branch on successful comparison with zero
localparam IFEQ = 8'h99;
localparam IFNE = 8'h9a;
localparam IFLT = 8'h9b;
localparam IFGE = 8'h9c;
localparam IFGT = 8'h9d;
localparam IFLE = 8'h9e;

// if_icmp - branch on successful integer comparison
localparam IF_ICMPEQ = 8'h9f;
localparam IF_ICMPNE = 8'ha0;
localparam IF_ICMPLT = 8'ha1;
localparam IF_ICMPGE = 8'ha2;
localparam IF_ICMPGT = 8'ha3;
localparam IF_ICMPLE = 8'ha4;

/* UNCONDITIONAL JUMP OPERATIONS */

// goto - branch always (unconditional jump)
localparam GOTO = 8'ha7;

// ireturn - return integer from method
localparam IRETURN = 8'hac;

// areturn - return reference (array) type from method
localparam ARETURN = 8'hb0;

// return - return void from method
localparam RETURN  = 8'hb1;

// invokestatic - invoke new static method
localparam INVOKESTATIC = 8'hb8;

/* ARRAY CREATION OPERATIONS */

// newarray - this is a NOP in bali
localparam NEWARRAY = 8'hbc;

`endif