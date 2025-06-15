module PC_ysyx(
    // input           clk,
    input   [31:0]  imm,
    input   [31:0]  pc,
    input   [31:0]  rs1,
    input           PCAsrc,
    input           PCBsrc,

    output  [31:0]  result
);

    reg     [31:0]  PCA;
    reg     [31:0]  PCB;

    // reg     [31:0]  result;


    // output declaration of module MuxKeyWithDefault
    // wire [DATA_LEN-1:0] out;
    
    MuxKeyWithDefault #(2, 1, 32) u_pca(
        PCA,
        PCAsrc,
        32'h00000000,
        {
            1'b0, 32'h00000004, // 4
            1'b1, imm
        }
    );

    MuxKeyWithDefault #(2, 1, 32) u_pcb(
        PCB,
        PCBsrc,
        pc,
        {
            1'b0, rs1,
            1'b1, pc
        }
    );


    assign result = PCA + PCB;

    // Reg #(32, 32'h80000000) u_nextpc
    // (
    //     clk,
    //     1'b0,
    //     result,
    //     NextPc,
    //     1'b1
    // );
    
endmodule
