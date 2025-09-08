module mReg (
    input         clk,
    input [31:0]  rs1,
    input [3:0]   mode, // ALUctr
    input [31:0]  imm,
    input [31:0]  pc,
    input         mRegwr, // 写使能
    
    output [31:0] mretPc,
    output        mpcWr,
    output [31:0] mRegData // 给通用寄存器
  
);

    reg [31:0] mcause_r;
    reg [31:0] mepc_r;
    reg [31:0] mstatus_r;
    reg [31:0] mtvec_r;

    reg [31:0] mRegData_r;
    reg [31:0] data_wr;
    reg [31:0] mretPc_r;
    reg        mpcWr_r;

    assign mRegData = mRegData_r;
    assign mretPc = mretPc_r;
    assign mpcWr = mpcWr_r;

    always @(*) begin // 给通用寄存器
        case (imm)
            32'h00000341: mRegData_r = mepc_r;
            32'h00000342: mRegData_r = mcause_r;
            32'h00000300: mRegData_r = mstatus_r;
            32'h00000305: mRegData_r = mtvec_r;
            default: mRegData_r = 32'hffffffff;
        endcase
    end

    always @(*) begin
        if(mRegwr == 1'b1 && mode == 4'b0001)begin
            data_wr = mRegData_r | rs1;
        end
        else begin
            data_wr = rs1;
        end
    end

    always @(posedge clk) begin // 写mReg
        if(mRegwr == 1'b1) begin
            if(mode == 4'b0001 || mode == 4'b0000) begin
                if(imm == 32'h00000341) begin
                    mepc_r <= data_wr;
                end
                else if(imm == 32'h00000342) begin
                    mcause_r <= data_wr;
                end
                else if(imm == 32'h00000300) begin
                    mstatus_r <= data_wr;
                end
                else if(imm == 32'h00000305) begin
                    mtvec_r <= data_wr;
                end
            end
            else if(mode == 4'b1111) begin // ecall
                mcause_r <= 32'h0000000b;
                mepc_r <= pc;
            end
        end
    end

    always @(*) begin // mretPc_r
        if(mode == 4'b1111) begin // ecall
            mretPc_r = mtvec_r;
            mpcWr_r = 1'b1;
        end
        else if(mode == 4'b1011) begin // mret
            mretPc_r = mepc_r;
            mpcWr_r = 1'b1;
        end
        else begin
            mretPc_r = 32'hffffffff;
            mpcWr_r = 1'b0;
        end
    end

endmodule
