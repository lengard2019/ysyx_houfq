module mReg (
    input           clk,
    // input   [31:0]  rs1,
    input   [3:0]   mode, // csr_mode
    input   [31:0]  imm,
    input   [31:0]  pc,
    input           mRegwr, // 写使能
    input   [31:0]  wrData, // write this mreg

    output  [31:0]  mretPc,
    output          mpcWr,
    output  [31:0]  mRegData // to reg
    // output  [31:0]  mWr_Data  // to mReg
);

    reg     [31:0]  mcause_r;
    reg     [31:0]  mepc_r;
    reg     [31:0]  mstatus_r;
    reg     [31:0]  mtvec_r;

    reg     [31:0]  mRegData_r;
    // reg     [31:0]  data_wr;
    reg     [31:0]  mretPc_r;
    reg             mpcWr_r;

    // assign  mWr_Data        = data_wr;
    assign  mRegData        = mRegData_r;
    assign  mretPc          = mretPc_r;
    assign  mpcWr           = mpcWr_r;


    // read
    always @(*) begin // 给通用寄存器
        case (imm)
            32'h00000341: mRegData_r = mepc_r;
            32'h00000342: mRegData_r = mcause_r;
            32'h00000300: mRegData_r = mstatus_r;
            32'h00000305: mRegData_r = mtvec_r;
            default: mRegData_r = 32'hffffffff;
        endcase
    end

    // always @(*) begin
    //     if(mode == 4'b0001)begin
    //         data_wr = mRegData_r | rs1;
    //     end
    //     else begin
    //         data_wr = rs1;
    //     end
    // end


    // write
    always @(posedge clk) begin // 写mReg
        if(mRegwr == 1'b1) begin
            if(mode == 4'b0001 || mode == 4'b0010) begin
                if(imm == 32'h00000341) begin
                    mepc_r      <= wrData;
                end
                else if(imm == 32'h00000342) begin
                    mcause_r    <= wrData;
                end
                else if(imm == 32'h00000300) begin
                    mstatus_r   <= wrData;
                end
                else if(imm == 32'h00000305) begin
                    mtvec_r     <= wrData;
                end
            end
            else if(mode == 4'b1111) begin // ecall
                mcause_r        <= 32'h0000000b;
                mepc_r          <= pc;
            end
        end
    end

    // read next_pc
    always @(*) begin // mretPc_r
        if(mode == 4'b1111) begin       // ecall
            mretPc_r = mtvec_r;
            mpcWr_r = 1'b1;
        end
        else if(mode == 4'b1011) begin  // mret
            mretPc_r = mepc_r;
            mpcWr_r = 1'b1;
        end
        else begin
            mretPc_r = 32'hffffffff;
            mpcWr_r = 1'b0;
        end
    end

endmodule
