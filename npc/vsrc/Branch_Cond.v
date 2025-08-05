module Branch_Cond(
    input   [2:0]   branch,
    input           less,
    input           zero,

    output          PCAsrc,
    output          PCBsrc
);

    reg     [1:0]   val;
    reg     [4:0]   key;

    assign key = {branch,less,zero};
    assign {PCAsrc, PCBsrc} = val;

    // MuxKeyWithDefault #(8, 5, 2) u_branch
    // (
    //     val,
    //     key,
    //     2'b01,               // default     s -> dnpc = pc + 4
    //     {
    //         5'b001??, 2'b11, // jar         R(rd) = s -> pc + 4; s -> dnpc += imm - 4;
    //         5'b010??, 2'b10, // jalr        R(rd) = s -> pc + 4; s -> dnpc = (src1 + imm) & ~1
    //         5'b10001, 2'b11, // beq         s -> dnpc += (src1 == src2) ? (imm - 4) : 0
    //         5'b101?0, 2'b11, // bne         s -> dnpc += (src1 == src2) ? 0 : (imm - 4)
    //         5'b11010, 2'b11, // blt         s -> dnpc += ((int32_t)src1 < (int32_t)src2) ? (imm - 4) : 0
    //         5'b1110?, 2'b11, // bge         s -> dnpc += ((int32_t)src1 >= (int32_t)src2) ? (imm - 4) : 0
    //         5'b11010, 2'b11, // bltu        s -> dnpc += ((uint32_t)src1 < (uint32_t)src2) ? (imm - 4) : 0
    //         5'b1110?, 2'b11  // bgeu        s -> dnpc += ((uint32_t)src1 >= (uint32_t)src2) ? (imm - 4) : 0
    //     }
    // );


    always @(key) begin
        casez (key)
            5'b001??: val = 2'b11; // jar         R(rd) = s -> pc + 4; s -> dnpc += imm - 4;
            5'b010??: val = 2'b10; // jalr        R(rd) = s -> pc + 4; s -> dnpc = (src1 + imm) & ~1
            5'b10001: val = 2'b11; // beq         s -> dnpc += (src1 == src2) ? (imm - 4) : 0
            5'b101?0: val = 2'b11; // bne         s -> dnpc += (src1 == src2) ? 0 : (imm - 4)
            5'b11010: val = 2'b11; // blt         s -> dnpc += ((int32_t)src1 < (int32_t)src2) ? (imm - 4) : 0
            5'b1110?: val = 2'b11; // bge         s -> dnpc += ((int32_t)src1 >= (int32_t)src2) ? (imm - 4) : 0
            // 5'b11010: val = 2'b11; // bltu        s -> dnpc += ((uint32_t)src1 < (uint32_t)src2) ? (imm - 4) : 0
            // 5'b1110?: val = 2'b11; // bgeu        s -> dnpc += ((uint32_t)src1 >= (uint32_t)src2) ? (imm - 4) : 0
            default: val = 2'b01;
        endcase
    end



endmodule
