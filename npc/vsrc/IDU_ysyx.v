module IDU_ysyx(
    input  [31:0]   instr,

    output [2:0]    ExtOp, // 指令类型
    output [31:0]   imm,
    output          RegWr,
    output [2:0]    Branch,
    output          MemtoReg,
    output          MemWr,
    output [2:0]    MemOp,
    output          ALUAsrc,
    output [1:0]    ALUBsrc,
    output [3:0]    ALUctr
);

    localparam N_TYPE = 3'b000;
    localparam R_TYPE = 3'b001;
    localparam I_TYPE = 3'b010;
    localparam S_TYPE = 3'b011;
    localparam B_TYPE = 3'b100;
    localparam U_TYPE = 3'b101;
    localparam J_TYPE = 3'b110;

    reg [6:0]       op; // 操作码
    // reg [2:0]       func3; 
    // reg [6:0]       func7; // 操作码

    reg [31:0]      immU;
    reg [31:0]      immI;
    reg [31:0]      immS;
    reg [31:0]      immB;
    reg [31:0]      immJ;

    reg [8:0]       key;
    reg [15:0]      val;

    assign key = {instr[6:2], instr[14:12], instr[30]};
    assign {RegWr, Branch[2:0], MemtoReg, MemWr, MemOp[2:0], ALUAsrc, ALUBsrc[1:0], ALUctr[3:0] } = val ;

    assign op = instr[6:0];
    // assign func3 = instr[14:12];
    // assign func7 = instr[31:25];

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
            7'b1110011, N_TYPE
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

    MuxKeyWithDefault #(37, 9, 16) u_out_gen
    (
        val,
        key,
        16'h0000,
        {//         
            9'b01101????, 16'b1000000000010011, // lui
            9'b00101????, 16'b1000000001010000, // auipc
            9'b00100000?, 16'b1000000000010000, // addi
            9'b00100010?, 16'b1000000000010010, // slti
            9'b00100011?, 16'b1000000000011010, // sltiu
            9'b00100100?, 16'b1000000000010100, // xori
            9'b00100110?, 16'b1000000000010110, // ori
            9'b00100111?, 16'b1000000000010111, // addi
            9'b001000010, 16'b1000000000010001, // slli
            9'b001001010, 16'b1000000000010101, // srli
            9'b001001011, 16'b1000000000011101, // srai
            9'b011000000, 16'b1000000000000000, // add
            9'b011000001, 16'b1000000000001000, // sub
            9'b011000010, 16'b1000000000000001, // sll
            9'b011000100, 16'b1000000000000010, // slt
            9'b011000110, 16'b1000000000001010, // sltu
            9'b011001000, 16'b1000000000000100, // xor
            9'b011001010, 16'b1000000000000101, // srl
            9'b011001011, 16'b1000000000001101, // sra
            9'b011001100, 16'b1000000000000110, // or
            9'b011001110, 16'b1000000000000111, // and
            9'b11011????, 16'b1001000001100000, // jal
            9'b11001000?, 16'b1010000001100000, // jalr
            9'b11000000?, 16'b0100000000000010, // beq
            9'b11000001?, 16'b0101000000000010, // bne
            9'b11000100?, 16'b0110000000000010, // blt
            9'b11000101?, 16'b0111000000000010, // bge
            9'b11000110?, 16'b0110000000001010, // bltu
            9'b11000111?, 16'b0111000000001010, // bgeu
            9'b00000000?, 16'b1000100000010000, // lb
            9'b00000001?, 16'b1000100010010000, // lh
            9'b00000010?, 16'b1000100100010000, // lw
            9'b00000100?, 16'b1000101000010000, // lbu
            9'b00000101?, 16'b1000101010010000, // lhb
            9'b01000000?, 16'b0000010000010000, // sb
            9'b01000001?, 16'b0000010010010000, // sh
            9'b01000010?, 16'b0000010100010000  // sw            
        }
    );



endmodule
