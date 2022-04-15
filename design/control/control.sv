`include "headers/cmptypes.vh"
`include "headers/opcodes.vh"

`timescale 10ns / 10ns

module control(
    input clk,
    input rst,
    input [7:0] op_code,            // current opcode to execute
    input [7:0] arg1,               // first argument to opcode (pc + 1)
    input [7:0] arg2,               // second argument to opcode (pc + 2)
    output [15:0] offset,           // offset of next instruction's address to current address
    output op_done,                 // signals completion of fetch-execute cycle

    input [31:0] ldconst,           // input for loaded constant

    output lvaop,                   // LVA: hi if write, lo if read operation
    output lvatrigger,              // LVA: start read/write operation
    output [7:0] lvaindex,          // LVA: method-local index of local variable to read/write
    input [31:0] lvaread,           // LVA: value read from local variable array
    output [31:0] lvawrite,         // LVA: value to write to local variable array
    input lvadone,                  // LVA: hi if read/write operation is done

    input lvamove,                  // invoke: initiate moving top of stack to LVA
    output lvamovedone,             // invoke: moved top of stack to LVA

    output arrop,                   // static array: hi to write, lo to read
    output arrtrigger,              // static array: start read/write procedure
    output [15:0] arraddr,          // static array: address to read/write
    input [31:0] arrreadvalue,      // static array: value to read
    output [31:0] arrwritevalue,    // static array: value to write
    input arrdone,                  // static array: read/write done

    output evalpush,                // eval stack: read/write bit
    output evaltrigger,             // eval stack: trigger output for read/write start
    input [31:0] evalread,          // eval stack: value to read
    output [31:0] evalwrite,        // eval stack: value to write
    input evaldone                  // eval stack: trigger input for read/write done
);

    logic done;                     // set to HI for 1 clock cycle when fetch-execute cycle is completed

    // decoder output declaration
    logic [3:0] aluop;              // operation code to pass to ALU
    logic isaluop;                  // operation uses the ALU
    logic iscmp;                    // operation is a conditional jump
    logic [3:0] cmptype;            // differentiates EQ/NE/LT/LE/GE/GT
    logic isconstpush;              // operation pushes constant to stack
    logic [2:0] constval;           // value of constant to push to stack
    logic isargpush;                // operation pushes byte or short literal to stack
    logic isgoto;                   // operation is unconditional jump
    logic islvaread;                // operation reads from LVA
    logic islvawrite;               // operation writes to LVA
    logic [1:0] lvadecodedindex;    // index of local variable to read from or write to
    logic isnewarray;               // operation creates a new array reference
    logic isarrread;                // operation reads from static array
    logic isarrwrite;               // operation writes to static array
    logic ispop;                    // operation pops topmost stack value
    logic isdup;                    // operation duplicates topmost stack value
    logic isldc;                    // operation loads constant from const pool
    logic islvainc;                 // operation increments local variable by argument
    logic [1:0] argc;               // number of arguments in code (max 2)
    logic [1:0] stackargs;          // number of elements to pop from stack
    logic stackwb;                  // operation writes to stack

    decoder decoder (
        .opcode(op_code),
        .aluop(aluop),
        .isaluop(isaluop),
        .iscmp(iscmp),
        .cmptype(cmptype),
        .isconstpush(isconstpush),
        .constval(constval),
        .isargpush(isargpush),
        .isgoto(isgoto),
        .islvaread(islvaread),
        .islvawrite(islvawrite),
        .lvaindex(lvadecodedindex),
        .isnewarray(isnewarray),
        .isarrread(isarrread),
        .isarrwrite(isarrwrite),
        .ispop(ispop),
        .isdup(isdup),
        .isldc(isldc),
        .isiinc(islvainc),
        .argc(argc),
        .stackargs(stackargs),
        .stackwb(stackwb)
    );

    // ALU integration
    logic [31:0] operand_a;         // first operand of ALU operation
    logic [31:0] operand_b;         // second operand of ALU operation (if binary operation)
    logic [31:0] result;         // low 32 bits of ALU result
    
    alu alu (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .op_select(aluop),
        .result(result)
    );

    logic [1:0] stackarg_counter;   // number of arguments to pop from the stack
    logic [1:0] stackwrite_counter; // number of arguments to write to stack

    // internal state of the control module
    logic [3:0] state;
    const logic [3:0] IDLE        = 4'b0000;
    const logic [3:0] FETCH       = 4'b0001;
    const logic [3:0] DECODE      = 4'b0010;
    const logic [3:0] S_LOAD      = 4'b0011;
    const logic [3:0] LVA_START   = 4'b0100;
    const logic [3:0] LVA_WAIT    = 4'b0101;
    const logic [3:0] LVA_INC     = 4'b0110;
    const logic [3:0] LVA_INCWAIT = 4'b0111;
    const logic [3:0] ARR_START   = 4'b1000;
    const logic [3:0] ARR_WAIT    = 4'b1001;
    const logic [3:0] DUP_START   = 4'b1010;
    const logic [3:0] DUP_WAIT    = 4'b1011;
    const logic [3:0] COMP        = 4'b1100;
    const logic [3:0] EXEC        = 4'b1101;
    const logic [3:0] WRITE       = 4'b1110;

    // after done signal, wait while CPU fetches next instruction
    const logic [1:0] FETCH_WAIT = 2'b11;
    logic [1:0] fetch_wait;

    // execution flow control outputs
    logic [15:0] pc_offset;         // offset between target address and jump instruction address
    logic [31:0] compvalue;         // comparison value, either operand_b or zero
    logic jump;                     // hi if jump instruction, lo otherwise

    // eval stack outputs
    logic stack_push;               // indicate push/pop operation on stack
    logic [31:0] stack_write;       // value to push to stack
    logic stack_trigger;            // trigger push/pop operation on stack

    // local variable array outputs
    logic lva_op;                   // indicate read/write operation on LVA
    logic [7:0] lva_index;          // index of local variable to read/write to
    logic [31:0] lva_write;         // value to write to LVA
    logic lva_trigger;              // trigger read/write operation on LVA

    // static array outputs
    logic arr_op;                   // indicate read/write operation on static array
    logic [15:0] arr_addr;          // address in static array to read/write
    logic [31:0] arr_write;         // value to write to static array
    logic arr_trigger;              // trigger read/write operation on static array

    // transfer method arguments on the eval stack to the LVA
    logic [2:0] lvamove_state;
    const logic [2:0] LVAMOVE_IDLE      = 3'b000;
    const logic [2:0] LVAMOVE_STACKLOAD = 3'b001;
    const logic [2:0] LVAMOVE_STACKWAIT = 3'b010;
    const logic [2:0] LVAMOVE_WRITE     = 3'b011;
    const logic [2:0] LVAMOVE_WAIT      = 3'b100;
    logic lvamove_done;

    always @ (posedge clk) begin
        if (rst) begin
            state <= IDLE;

            pc_offset <= 16'h0000;
            compvalue <= 32'h0000_0000;
            jump <= 0;

            operand_a <= 32'h0000_0000;
            operand_b <= 32'h0000_0000;

            lvamove_state <= LVAMOVE_IDLE;
            lvamove_done <= 0;

            arr_op <= 0;
            arr_addr <= 16'h0000;
            arr_write <= 32'h0000_0000;
            arr_trigger <= 0;
            
            lva_op <= 0;
            lva_index <= 16'h0000;
            lva_write <= 32'h0000_0000;
            lva_trigger <= 0;

            stack_push <= 0;
            stack_write <= 32'h0000_0000;
            stack_trigger <= 0;

            fetch_wait <= FETCH_WAIT;
        end

        // ---- STACK TO LVA MOVE SECTION ----
        if (lvamove) begin
            lvamove_state <= LVAMOVE_STACKLOAD;
        end

        if (lvamove_state != LVAMOVE_IDLE) begin
            case (lvamove_state)
                LVAMOVE_STACKLOAD: begin
                    stack_push <= 0;
                    stack_trigger <= 1;
                    lvamove_state <= LVAMOVE_STACKWAIT;
                end
                LVAMOVE_STACKWAIT: begin
                    if (evaldone) begin
                        lva_op <= 1;
                        lvamove_state <= LVAMOVE_WRITE;
                        lva_write[31:0] <= evalread[31:0];
                    end
                    stack_trigger <= 0;
                end
                LVAMOVE_WRITE: begin
                    lva_trigger <= 1;
                    lvamove_state <= LVAMOVE_WAIT;
                end
                LVAMOVE_WAIT: begin
                    if (lvadone) begin
                        lvamove_done <= 1;
                        lvamove_state <= LVAMOVE_IDLE;
                    end
                    lva_op <= 0;
                    lva_trigger <= 0;
                end
                default: begin
                end
            endcase
        end
        else begin
            lvamove_done <= 0;
        end
        // ---- END STACK TO LVA MOVE SECTION ----
        
        case (state)
            IDLE: begin
                done <= 0;
                jump <= 0;
                if (fetch_wait == 0) begin
                    if (op_code != NOP &&
                        op_code != INVOKESTATIC &&
                        op_code != IRETURN && 
                        op_code != ARETURN && 
                        op_code != RETURN) 
                    begin
                        state <= FETCH;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                fetch_wait <= fetch_wait - 1;
            end
            FETCH: begin
                // opcodes that do not require popping stack values
                if (isconstpush || isargpush || isgoto || islvaread || isldc || islvainc) begin
                    state <= DECODE;
                end
                // opcodes that require reading from stack
                else if (isaluop || iscmp || islvawrite || isnewarray || isarrread || isarrwrite || ispop || isdup) begin
                    state <= DECODE;
                    stackarg_counter <= stackargs;
                end
            end
            DECODE: begin
                // push constant or goto
                if (isconstpush || isargpush || isgoto || isldc) begin
                    state <= EXEC;
                end
                // alu operation or comparison
                if (isaluop || iscmp || ispop || isdup) begin
                    stack_push <= 0;
                    stack_trigger <= 1;
                    stackarg_counter <= stackarg_counter - 1;
                    state <= S_LOAD;
                end
                // unconditional jump
                if (isgoto) begin
                    jump <= 1;
                end
                // local variable load
                if (islvaread || islvawrite) begin
                    // LVA index is argument of opcode
                    if (argc == 2'b01) begin
                        lva_index <= arg1;
                    end
                    else begin
                        lva_index <= { { 6 { 1'b0 } }, lvadecodedindex };
                    end
                    if (islvaread) begin
                        lva_op <= 0;
                        state <= LVA_START;
                    end
                    if (islvawrite) begin
                        stack_push <= 0;
                        stack_trigger <= 1;
                        stackarg_counter <= stackarg_counter - 1;
                        state <= S_LOAD;
                    end
                end
                if (islvainc) begin
                    lva_op <= 0;
                    lva_index <= arg1;
                    state <= LVA_START;
                end
                if (isnewarray || isarrread || isarrwrite) begin
                    stack_push <= 0;
                    stack_trigger <= 1;
                    stackarg_counter <= stackarg_counter - 1;
                    state <= S_LOAD;
                end
            end
            S_LOAD: begin
                if (evaldone) begin
                    case (stackarg_counter)
                        2'b11: begin
                            stackarg_counter <= stackarg_counter - 1;
                        end
                        2'b10: begin
                            // three arguments to pop from stack
                            if (isarrwrite) begin
                                operand_b[31:0] <= evalread[31:0];
                            end
                            stack_push <= 0;
                            stack_trigger <= 1;
                            stackarg_counter <= stackarg_counter - 1;
                        end
                        2'b01: begin
                            // two arguments to pop from stack
                            if (isaluop || iscmp) begin
                                operand_b[31:0] <= evalread[31:0];
                            end
                            if (isarrread || isarrwrite) begin
                                operand_a[15:0] <= evalread[15:0];
                            end
                            stack_push <= 0;
                            stack_trigger <= 1;
                            stackarg_counter <= stackarg_counter - 1;
                        end
                        2'b00: begin
                            // one argument to pop from stack
                            if (isaluop || iscmp) begin
                                operand_a[31:0] <= evalread[31:0];
                            end
                            if (iscmp) begin
                                // if cmptype[3] is set, operation is ICMP, otherwise compare with zero
                                compvalue[31:0] <= cmptype[3] ? operand_b : 32'h0000_0000;
                                state <= COMP;
                            end
                            else if (islvawrite) begin
                                lva_op <= 1;
                                operand_a[31:0] <= evalread[31:0];
                                state <= LVA_START;
                            end
                            else if (isarrread || isarrwrite) begin
                                arr_op <= isarrwrite;
                                state <= ARR_START;
                            end
                            else if (isnewarray) begin
                                stack_write[31:0] <= 32'h0000_0000;
                                state <= EXEC;
                            end
                            else if (isdup) begin
                                operand_a[31:0] <= evalread[31:0];
                                stackwrite_counter <= 2'b10;
                                state <= DUP_START;
                            end
                            else begin
                                state <= EXEC;
                            end
                        end
                        default: begin end
                    endcase
                end
                else begin
                    stack_trigger <= 0;
                end
            end
            LVA_START: begin
                lva_trigger <= 1;
                if (islvaread || islvainc) begin
                    state <= LVA_WAIT;
                end
                else if (islvawrite) begin
                    lva_write[31:0] <= operand_a[31:0];
                    state <= LVA_WAIT;
                end
            end
            LVA_WAIT: begin
                if (lvadone) begin
                    if (islvaread || islvawrite) begin
                        state <= EXEC;
                    end
                    else if (islvainc) begin
                        lva_write[31:0] <= lvaread[31:0] + arg2[7:0];
                        lva_op <= 1;
                        state <= LVA_INC;
                    end
                end
                lva_trigger <= 0;
            end
            LVA_INC: begin
                lva_trigger <= 1;
                state <= LVA_INCWAIT;
            end
            LVA_INCWAIT: begin
                if (lvadone) begin
                    lva_op <= 0;
                    state <= EXEC;
                end
                lva_trigger <= 0;
            end
            ARR_START: begin
                arr_write[31:0] <= operand_b[31:0];
                arr_addr[15:0] <= operand_a[15:0];
                arr_trigger <= 1;
                state <= ARR_WAIT;
            end
            ARR_WAIT: begin
                if (arrdone) begin
                    arr_op <= 0;
                    state <= EXEC;
                end
                arr_trigger <= 0;
            end
            DUP_START: begin
                if (stackwrite_counter == 2'b00) begin
                    state <= IDLE;
                    done <= 1;
                    fetch_wait <= FETCH_WAIT;
                end
                else begin
                    stack_push <= 1;
                    stack_write[31:0] <= operand_a[31:0];
                    stack_trigger <= 1;
                    state <= DUP_WAIT;
                end
            end
            DUP_WAIT: begin
                if (evaldone) begin
                    stackwrite_counter <= stackwrite_counter - 1;
                    state <= DUP_START;
                end
                stack_trigger <= 0;
            end
            COMP: begin // comparison operation
                case (cmptype[2:0])
                    EQ: begin
                        jump <= operand_a == compvalue;
                    end
                    NE: begin
                        jump <= operand_a != compvalue;
                    end
                    LT: begin
                        // a negative, b nonnegative
                        if (operand_a[31] == 1 && compvalue[31] == 0) begin
                            jump <= 1;
                        end
                        // a nonnegative, b negative
                        else if (operand_a[31] == 0 && compvalue[31] == 1) begin
                            jump <= 0;
                        end
                        else begin
                            jump <= operand_a < compvalue;
                        end
                    end
                    LE: begin
                        // a negative, b nonnegative
                        if (operand_a[31] == 1 && compvalue[31] == 0) begin
                            jump <= 1;
                        end
                        // a nonnegative, b negative
                        else if (operand_a[31] == 0 && compvalue[31] == 1) begin
                            jump <= 0;
                        end
                        else begin
                            jump <= operand_a <= compvalue;
                        end
                    end
                    GE: begin
                        // a negative, b nonnegative
                        if (operand_a[31] == 1 && compvalue[31] == 0) begin
                            jump <= 0;
                        end
                        // a nonnegative, b negative
                        else if (operand_a[31] == 0 && compvalue[31] == 1) begin
                            jump <= 1;
                        end
                        else begin
                            jump <= operand_a >= compvalue;
                        end
                    end
                    GT: begin
                        // a negative, b nonnegative
                        if (operand_a[31] == 1 && compvalue[31] == 0) begin
                            jump <= 0;
                        end
                        // a nonnegative, b negative
                        else if (operand_a[31] == 0 && compvalue[31] == 1) begin
                            jump <= 1;
                        end
                        else begin
                            jump <= operand_a > compvalue;
                        end
                    end
                    default: begin end
                endcase
                state <= EXEC;
            end
            EXEC: begin
                // push constant to stack
                if (isconstpush) begin
                    if (constval[2:0] == 3'b111) begin
                        stack_write[31:0] <= 32'hffff_ffff;
                    end
                    else begin
                        stack_write[31:0] <= { { 29 { 1'b0 } }, constval[2:0] };
                    end
                end
                // write alu operation result to stack
                if (isaluop) begin
                    stack_write[31:0] <= result[31:0];
                end
                // push byte or short literal to stack
                if (isargpush) begin
                    // sign extend literal to 32 bit length
                    if (argc == 2'b01) begin
                        stack_write[31:0] <= { { 24 { arg1[7] } }, arg1[7:0] };
                    end
                    else if (argc == 2'b10) begin
                        stack_write[31:0] <= { { 16 { arg1[7] } }, arg1[7:0], arg2[7:0] };
                    end
                end
                if (islvaread) begin
                    stack_write[31:0] <= lvaread[31:0];
                end
                if (isarrread) begin
                    stack_write[31:0] <= arrreadvalue[31:0];
                end
                if (isldc) begin
                    stack_write[31:0] <= ldconst[31:0];
                end
                // write value to stack if stackwb bit is set
                if (stackwb) begin
                    stack_push <= 1;
                    state <= WRITE;
                    stack_trigger <= 1;
                end
                else begin
                    state <= IDLE;
                    done <= 1;
                    fetch_wait <= FETCH_WAIT;
                end
            end
            WRITE: begin
                if (stackwb) begin
                    if (evaldone) begin
                        state <= IDLE;
                        done <= 1;
                        fetch_wait <= FETCH_WAIT;
                    end
                    else begin
                        stack_trigger <= 0;
                    end
                end
            end
            default: begin end
        endcase

        // when jumping, set next instruction to offset in code
        // otherwise, next instruction is (number of args of current opcode + 1)
        if (jump) begin
            pc_offset <= {arg1, arg2};
        end
        else begin
            pc_offset <= argc + 1;
        end
    end

    assign op_done = done;
    assign lvaindex = lva_index;
    assign lvaop = lva_op;
    assign lvawrite = lva_write;
    assign lvatrigger = lva_trigger;
    assign lvamovedone = lvamove_done;
    assign arrop = arr_op;
    assign arrtrigger = arr_trigger;
    assign arraddr = arr_addr;
    assign arrwritevalue = arr_write;
    assign evalpush = stack_push;
    assign evaltrigger = stack_trigger;
    assign evalwrite = stack_write;
    assign offset = pc_offset;

endmodule