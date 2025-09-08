module PC_ysyx(

    input   [31:0]  imm,
    input   [31:0]  pc,
    input           mpcWr,
    input   [31:0]  mretPc,
    input   [31:0]  rs1,
    input           PCAsrc,
    input           PCBsrc,

    output  [31:0]  result
    
);

    reg     [31:0]  PCA;
    reg     [31:0]  PCB;

    reg     [31:0]  result_r;

    assign result = result_r;

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

    // assign result = PCA + PCB;

    always @(*) begin
        if(mpcWr == 1'b1)begin
            result_r = mretPc;
        end
        else begin
            result_r = PCA + PCB;
        end
    end
    
endmodule
