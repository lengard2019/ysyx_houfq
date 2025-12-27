module IDU_ysyx(
    input           clk,
    input           reset,

    input  [31:0]   pc,
    output [31:0]   pc_out,

    input           inst_valid,
    output          inst_ready,

    input           decode_ready,
    output          decode_valid,

    input  [31:0]   inst,

    // output [2:0]    ExtOp, // 指令类型
    output [31:0]   imm,
    
    output          RegWr,
    output [2:0]    Branch,
    output [1:0]    MemtoReg,
    output          MemWr,
    output [2:0]    MemOp,
    output          ALUAsrc,
    output [1:0]    ALUBsrc,
    output [3:0]    ALUctr,
    
    // mreg
    output [1:0]    mRegWr,
    output [3:0]    csr_mode,

    output [4:0]    Ra,
    output [4:0]    Rb,
    output [4:0]    Rw
);


    assign Ra           = instr[19:15];
    assign Rb           = instr[24:20];
    assign Rw           = instr[11:7];

    localparam N_TYPE = 3'b000;
    localparam R_TYPE = 3'b001;
    localparam I_TYPE = 3'b010;
    localparam S_TYPE = 3'b011;
    localparam B_TYPE = 3'b100;
    localparam U_TYPE = 3'b101;
    localparam J_TYPE = 3'b110;

    reg     [6:0]       op;

    reg     [31:0]      immU;
    reg     [31:0]      immI;
    reg     [31:0]      immS;
    reg     [31:0]      immB;
    reg     [31:0]      immJ;

    reg     [31:0]      pc_out_r;


    reg     [16:0]      val;

    reg     [5:0]       val_m;


    reg     [31:0]      instr;

    wire    [2:0]       ExtOp;


    assign {RegWr, Branch[2:0], MemtoReg[1:0], MemWr, MemOp[2:0], ALUAsrc, ALUBsrc[1:0], ALUctr[3:0] } = val;

    assign {mRegWr, csr_mode} = val_m;

    assign op   = instr[6:0];

    assign immU = {{instr[31:12]}, 12'h000};
    assign immI = {{20{instr[31]}}, instr[31:20]};
    assign immS = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign immB = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    assign immJ = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};


    MuxKeyWithDefault #(10, 7, 3) u_extop // 通过操作码识别指令类型
    (
        ExtOp,
        op,
        N_TYPE,
        {
            7'b0110111, U_TYPE,
            7'b0010111, U_TYPE,
            7'b1101111, J_TYPE,
            7'b1100111, I_TYPE,
            7'b0000011, I_TYPE,
            7'b0010011, I_TYPE,
            7'b0110011, R_TYPE,
            7'b1100011, B_TYPE,
            7'b0100011, S_TYPE,
            7'b1110011, I_TYPE
        }
    );

    MuxKeyWithDefault #(5, 3, 32) u_imm_gen // 生成立即数
    (
        imm,
        ExtOp,
        32'h00000000,
        {
            U_TYPE, immU,
            J_TYPE, immJ,
            I_TYPE, immI,
            B_TYPE, immB,
            S_TYPE, immS
        }
    );

    // 特权
    // mRegwr  11表示与寄存器交换，10表示只写csr不写通用寄存器，00表示mret
    always @(*) begin

        casez (instr)
            32'b?????????????????001?????1110011: val_m = 6'b110001; // csrrw
            32'b?????????????????010?????1110011: val_m = 6'b110010; // csrrs |=
            32'b00000000000000000000000001110011: val_m = 6'b101111; // ecall
            32'b00110000001000000000000001110011: val_m = 6'b001011; // mret
            default: val_m = 6'h00;
        endcase
    end

    // 非特权
    always @(*) begin
        casez (instr)
            32'b?????????????????????????0110111: val = 17'b10000000000010011; // lui 
            32'b?????????????????????????0010111: val = 17'b10000000001010000; // auipc
            32'b?????????????????000?????0010011: val = 17'b10000000000010000; // addi
            32'b?????????????????010?????0010011: val = 17'b10000000000010010; // slti
            32'b?????????????????011?????0010011: val = 17'b10000000000011010; // sltiu
            32'b?????????????????100?????0010011: val = 17'b10000000000010100; // xori
            32'b?????????????????110?????0010011: val = 17'b10000000000010110; // ori
            32'b?????????????????111?????0010011: val = 17'b10000000000010111; // andi
            32'b0000000??????????001?????0010011: val = 17'b10000000000010001; // slli
            32'b0000000??????????101?????0010011: val = 17'b10000000000010101; // srli
            32'b0100000??????????101?????0010011: val = 17'b10000000000011101; // srai
            32'b0000000??????????000?????0110011: val = 17'b10000000000000000; // add
            32'b0100000??????????000?????0110011: val = 17'b10000000000001000; // sub
            32'b0000000??????????001?????0110011: val = 17'b10000000000000001; // sll
            32'b0000000??????????010?????0110011: val = 17'b10000000000000010; // slt
            32'b0000000??????????011?????0110011: val = 17'b10000000000001010; // sltu
            32'b0000000??????????100?????0110011: val = 17'b10000000000000100; // xor
            32'b0000000??????????101?????0110011: val = 17'b10000000000000101; // srl
            32'b0100000??????????101?????0110011: val = 17'b10000000000001101; // sra
            32'b0000000??????????110?????0110011: val = 17'b10000000000000110; // or
            32'b0000000??????????111?????0110011: val = 17'b10000000000000111; // and
            32'b?????????????????????????1101111: val = 17'b10010000001100000; // jal
            32'b?????????????????000?????1100111: val = 17'b10100000001100000; // jalr
            32'b?????????????????000?????1100011: val = 17'b01000000000000010; // beq
            32'b?????????????????001?????1100011: val = 17'b01010000000000010; // bne
            32'b?????????????????100?????1100011: val = 17'b01100000000000010; // blt
            32'b?????????????????101?????1100011: val = 17'b01110000000000010; // bge
            32'b?????????????????110?????1100011: val = 17'b01100000000001010; // bltu
            32'b?????????????????111?????1100011: val = 17'b01110000000001010; // bgeu
            32'b?????????????????000?????0000011: val = 17'b10000100000010000; // lb
            32'b?????????????????001?????0000011: val = 17'b10000100010010000; // lh
            32'b?????????????????010?????0000011: val = 17'b10000100100010000; // lw
            32'b?????????????????100?????0000011: val = 17'b10000101000010000; // lbu
            32'b?????????????????101?????0000011: val = 17'b10000101010010000; // lhu
            32'b?????????????????000?????0100011: val = 17'b00000010000010000; // sb
            32'b?????????????????001?????0100011: val = 17'b00000010010010000; // sh
            32'b?????????????????010?????0100011: val = 17'b00000010100010000; // sw
            // 32'b?????????????????001?????1110011: val = 17'b10001000000000000; // csrrw
            // 32'b?????????????????010?????1110011: val = 17'b10001000000000001; // csrrs |=
            // 32'b00000000000000000000000001110011: val = 17'b00000000000001111; // ecall
            // 32'b00110000001000000000000001110011: val = 17'b00000000000001011; // mret
            default: val = 17'h0000;

            // assign {RegWr, Branch[2:0], MemtoReg[1:0], MemWr, MemOp[2:0], ALUAsrc, ALUBsrc[1:0], ALUctr[3:0] } = val;
        endcase
    end

    localparam IDLE                 = 0;
    localparam WAIT_INST_VALID      = 1;
    localparam WAIT_DECODE_READY    = 2;

    reg     [1:0]       current_state;
    reg     [1:0]       next_state;


    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case(current_state)

            IDLE: begin
                next_state = WAIT_INST_VALID;
            end

            WAIT_INST_VALID: begin
                if(inst_valid == 1'b1) begin
                    next_state = WAIT_DECODE_READY;
                end
                else begin
                    next_state = WAIT_INST_VALID;
                end
            end

            WAIT_DECODE_READY: begin
                 if(decode_ready == 1'b1) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = WAIT_DECODE_READY;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    assign  inst_ready      = (current_state == WAIT_INST_VALID) ? 1'b1 : 1'b0;
    assign  decode_valid    = (current_state == WAIT_DECODE_READY) ? 1'b1 : 1'b0;

    assign  pc_out          = pc_out_r;


    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1) begin
            instr       <= 32'hffffffff;
            pc_out_r    <= 32'hffffffff;
        end
        else begin
            if(inst_valid == 1'b1 && inst_ready == 1'b1) begin
                instr       <= inst;
                pc_out_r    <= pc;
            end
        end
    end


endmodule
