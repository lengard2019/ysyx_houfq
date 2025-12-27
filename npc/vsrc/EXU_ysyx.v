module EXU_ysyx(
    input               clk,
    input               reset,

    input   [31:0]      pc,

    input   [31:0]      rs1,
    input   [31:0]      rs2,

    input               decode_valid,
    output              decode_ready,

    input               lsu_ready,
    output              lsu_valid,

    // lsu ctrl
    output  [31:0]      lsu_addr, // 内存操作地址
    output  [31:0]      lsu_data, // 写内存数据
    output  [1:0]       lsu_mode, // 00不访存，01 load，11 store，10 mdata
    output  [2:0]       lsu_op,   // memop,指示字节

    // // mreg ctrl
    // output  [3:0]       mreg_mode, // ALU_ctrl 
    // output  [31:0]      pc_out,
    // output  [31:0]      imm_out,
    // output  [31:0]      mreg_data,
    // output              mReg_wr,

    output  [31:0]      Next_pc,
    
    // reg ctrl
    output  [4:0]       Rw_out,
    output  [31:0]      result_out,
    output              regwr_out,


    // input   [31:0]      mretPc, // 异常的next_pc
    // input               mpcWr,  // 指示pc
    input   [31:0]      imm,
    input   [1:0]       mRegWr,
    input   [3:0]       csr_mode, 
    input               RegWr,  
    input   [2:0]       branch,
    input   [1:0]       MemtoReg, // load
    input               MemWr,
    input   [2:0]       MemOp,
    input               ALUAsrc, 
    input   [1:0]       ALUBsrc, 
    input   [3:0]       ALUctr,
    input   [4:0]       Rw       // to reg
    // input   [31:0]      mWr_Data, // to mreg
);

    reg     [31:0]      rs1_r;
    reg     [31:0]      rs2_r;

    // 
    wire    [31:0]      mretPc_r; // from mReg 
    wire                mpcWr_r;
    reg     [1:0]       mRegWr_r; // 写mReg使能
    wire                csr_wr;
    reg     [3:0]       csr_mode_r; //
    
    reg     [31:0]      imm_r; 
    reg                 RegWr_r;  // 写通用寄存器使能
    reg     [2:0]       branch_r;
    reg     [1:0]       MemtoReg_r; // load
    reg                 MemWr_r; // store
    reg     [2:0]       MemOp_r;
    reg                 ALUAsrc_r; 
    reg     [1:0]       ALUBsrc_r; 
    reg     [3:0]       ALUctr_r;
    reg     [31:0]      pc_r;
    reg     [4:0]       Rw_r;

    reg     [3:0]       current_state;
    reg     [3:0]       next_state;

    localparam IDLE             = 0;
    localparam WAIT_DEVALID     = 1;
    localparam WAIT_LSUREADY    = 2;


    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1) begin
            current_state       <= IDLE;
        end
        else begin
            current_state       <= next_state;
        end
    end

    always @(*) begin
        
        case(current_state)

            IDLE: begin
                next_state = WAIT_DEVALID;
            end

            WAIT_DEVALID: begin
                if(decode_valid == 1'b1) begin
                    next_state = WAIT_LSUREADY;
                end
                else begin
                    next_state = WAIT_DEVALID;
                end
            end

            WAIT_LSUREADY: begin
                if(lsu_ready == 1'b1) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = WAIT_LSUREADY;
                end
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    assign  decode_ready    = (current_state == WAIT_DEVALID) ? 1'b1 : 1'b0;
    assign  lsu_valid       = (current_state == WAIT_LSUREADY) ? 1'b1 : 1'b0;

    assign  lsu_addr        = result;
    assign  lsu_data        = rs2_r;
    assign  lsu_mode        = (MemWr_r == 1'b1) ? 2'b11 : MemtoReg_r;
    assign  lsu_op          = MemOp_r;

    // // mreg
    // assign  mreg_mode       = ALUctr_r;
    // assign  pc_out          = pc_r;
    // assign  imm_out         = imm_r;
    // assign  mReg_wr         = mRegWr_r;

    // assign  
    assign  Rw_out          = Rw_r;
    assign  result_out      = (mRegWr_r == 2'b11) ? mreg_data : result; // to reg
    assign  regwr_out       = RegWr_r | mRegWr_r[0];


    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1) begin
            rs1_r           <= 0;  
            rs2_r           <= 0;  
            // mretPc_r        <= 0;
            // mpcWr_r         <= 0;
            imm_r           <= 0;  
            mRegWr_r        <= 0;
            csr_mode_r      <= 0;      
            RegWr_r         <= 0;  
            branch_r        <= 0;      
            MemtoReg_r      <= 0;      
            MemWr_r         <= 0;  
            MemOp_r         <= 0;  
            ALUAsrc_r       <= 0;      
            ALUBsrc_r       <= 0;      
            ALUctr_r        <= 0;
            pc_r            <= 0;
            Rw_r            <= 0;
        end
        else begin
            if(decode_valid == 1'b1 && decode_ready == 1'b1) begin
                rs1_r           <= rs1;
                rs2_r           <= rs2;
                // mretPc_r        <= mretPc;
                // mpcWr_r         <= mpcWr;
                imm_r           <= imm;
                mRegWr_r        <= mRegWr;
                csr_mode_r      <= csr_mode;
                RegWr_r         <= RegWr;
                branch_r        <= branch;
                MemtoReg_r      <= MemtoReg;
                MemWr_r         <= MemWr;
                MemOp_r         <= MemOp;
                ALUAsrc_r       <= ALUAsrc;
                ALUBsrc_r       <= ALUBsrc;
                ALUctr_r        <= ALUctr;
                pc_r            <= pc;
                Rw_r            <= Rw;
            end
            else begin
                
            end
        end
    end


    // output declaration of module ALU_ysyx
    wire        less;
    wire        zero;
    wire [31:0] result;
    
    ALU_ysyx u_ALU_ysyx(
        .pc      	(pc_r     ),
        .rs1     	(rs1_r    ),
        .rs2     	(rs2_r    ),
        .imm     	(imm_r    ),
        .ALUctr  	(ALUctr_r ),
        .ALUAsrc 	(ALUAsrc_r),
        .ALUBsrc 	(ALUBsrc_r),
        .less    	(less     ),
        .zero    	(zero     ),
        .result  	(result   )
    );
    

    // output declaration of module Branch_Cond
    wire PCAsrc;
    wire PCBsrc;
    
    Branch_Cond u_Branch_Cond(
        .branch 	(branch_r ),
        .less   	(less     ),
        .zero   	(zero     ),
        .PCAsrc 	(PCAsrc   ),
        .PCBsrc 	(PCBsrc   )
    );
    

    // output declaration of module PC_ysyx
    // wire [31:0] result;
    
    PC_ysyx u_PC_ysyx(
        .imm    	(imm_r    ),
        .pc     	(pc_r     ),
        .mpcWr  	(mpcWr_r  ),
        .mretPc 	(mretPc_r ),
        .rs1    	(rs1_r    ),
        .PCAsrc 	(PCAsrc   ),
        .PCBsrc 	(PCBsrc   ),
        .result 	(Next_pc  )
    );

    reg     [31:0]      wrData;


    wire    [31:0]      mreg_data;

    always @(*) begin
        if(csr_mode_r == 4'b0001) begin
            wrData      = rs1_r;
        end
        else if(csr_mode_r == 4'b0010) begin
            wrData      = mreg_data | rs1_r;
        end
        else begin
            wrData      = 32'h0000;
        end
    end

    assign  csr_wr      = (current_state == WAIT_LSUREADY) ? mRegWr_r[1] : 1'b0;

    mReg u_mReg(
        .clk        (clk        ),
        .imm        (imm_r      ),
        .mode       (csr_mode_r ), // csr操作
        .mpcWr      (mpcWr_r    ), // to PC_ysyx
        .mRegData   (mreg_data  ), // to reg
        .mRegwr     (csr_wr     ), // write en
        .mretPc 	(mretPc_r   ), // to PC_ysyx
        .pc         (pc_r       ), // pc
        .wrData     (wrData     )  // write data
    );


endmodule
