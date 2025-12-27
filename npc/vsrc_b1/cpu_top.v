import "DPI-C" function void call_ebreak();

module cpu_top(
    input               clk,
    input               reset,

    output  [31:0]      Next_pc,
    output  [31:0]      pc

    // input               io_master_awready,
    // output              io_master_awvalid, 
    // output  [31:0]      io_master_awaddr,  
    // output  [3:0]       io_master_awid,    
    // output  [7:0]       io_master_awlen,   
    // output  [2:0]       io_master_awsize,  
    // output  [1:0]       io_master_awburst, 
    // input               io_master_wready,  
    // output              io_master_wvalid,  
    // output  [31:0]      io_master_wdata,   
    // output  [3:0]       io_master_wstrb,   
    // output              io_master_wlast,   
    // output              io_master_bready,  
    // input               io_master_bvalid,  
    // input   [1:0]       io_master_bresp,   
    // input   [3:0]       io_master_bid,     
    // input               io_master_arready, 
    // output              io_master_arvalid, 
    // output  [31:0]      io_master_araddr,  
    // output  [3:0]       io_master_arid,    
    // output  [7:0]       io_master_arlen,   
    // output  [2:0]       io_master_arsize,  
    // output  [1:0]       io_master_arburst, 
    // output              io_master_rready,  
    // input               io_master_rvalid,  
    // input   [1:0]       io_master_rresp,   
    // input   [31:0]      io_master_rdata,   
    // input               io_master_rlast,   
    // input   [3:0]       io_master_rid     

);

    wire    [4:0]       Ra;
    wire    [4:0]       Rb;
    wire    [4:0]       Rw;


    // output declaration of module IFU_ysyx
    wire    [31:0]      inst;
    wire                inst_valid;
    wire                inst_ready;

    // IFU AXI-lite
    wire   [31:0]       ifu_araddr; 
    wire                ifu_arvalid;
    wire                ifu_arready;
    wire   [31:0]       ifu_rdata;
    wire   [1:0]        ifu_rresp; 
    wire                ifu_rvalid; 
    wire                ifu_rready;
    wire   [31:0]       ifu_awaddr;
    wire                ifu_awvalid;
    wire                ifu_awready;
    wire   [31:0]       ifu_wdata;
    wire   [3:0]        ifu_wstrb; 
    wire                ifu_wvalid; 
    wire                ifu_wready;
    wire   [1:0]        ifu_bresp;
    wire                ifu_bvalid; 
    wire                ifu_bready;

    wire   [31:0]       pc_wb_if;

    assign  pc          = pc_wb_if;

    wire                ifu_ready;

    wire                ifu_valid;
    
    
    IFU_ysyx u_IFU_ysyx(
        .clk        	    (clk            ),
        .reset      	    (reset          ),
        .inst       	    (inst           ),
        .pc_out             (pc_if_id       ),
        .pc         	    (pc_wb_if       ),
        .pc_valid   	    (ifu_valid      ), // WBU
        .pc_ready   	    (ifu_ready      ), // WBU
        .inst_ready 	    (inst_ready     ),
        .inst_valid 	    (inst_valid     ),
        .m_araddr   	    (ifu_araddr     ),
        .m_arvalid  	    (ifu_arvalid    ),
        .m_arready  	    (ifu_arready    ),
        .m_rdata    	    (ifu_rdata      ),
        .m_rresp    	    (ifu_rresp      ),
        .m_rvalid   	    (ifu_rvalid     ),
        .m_rready   	    (ifu_rready     ),
        .m_awaddr   	    (ifu_awaddr     ),
        .m_awvalid  	    (ifu_awvalid    ),
        .m_awready  	    (ifu_awready    ),
        .m_wdata    	    (ifu_wdata      ),
        .m_wstrb    	    (ifu_wstrb      ),
        .m_wvalid   	    (ifu_wvalid     ),
        .m_wready   	    (ifu_wready     ),
        .m_bresp    	    (ifu_bresp      ),
        .m_bvalid   	    (ifu_bvalid     ),
        .m_bready   	    (ifu_bready     )
    );

    always @(posedge clk) begin
        if(inst == 32'b00000000000100000000000001110011) begin
            call_ebreak();
        end
    end

    
    SRAM u_SRAM_ifu(
        .clk       	        (clk            ),
        .reset     	        (reset          ),
        .s_araddr  	        (ifu_araddr     ),
        .s_arvalid 	        (ifu_arvalid    ),
        .s_arready 	        (ifu_arready    ),
        .s_rdata   	        (ifu_rdata      ),
        .s_rresp   	        (ifu_rresp      ),
        .s_rvalid  	        (ifu_rvalid     ),
        .s_rready  	        (ifu_rready     ),
        .s_awaddr  	        (ifu_awaddr     ),
        .s_awvalid 	        (ifu_awvalid    ),
        .s_awready 	        (ifu_awready    ),
        .s_wdata   	        (ifu_wdata      ),
        .s_wstrb   	        (ifu_wstrb      ),
        .s_wvalid  	        (ifu_wvalid     ),
        .s_wready  	        (ifu_wready     ),
        .s_bresp   	        (ifu_bresp      ),
        .s_bvalid  	        (ifu_bvalid     ),
        .s_bready  	        (ifu_bready     )
    );

    wire [31:0] pc_if_id;

    // output declaration of module IDU_ysyx
    wire inst_ready;
    wire decode_valid;
    wire [31:0] imm;
    wire RegWr;
    wire [2:0] Branch;
    wire [1:0] MemtoReg;
    wire MemWr;
    wire [2:0] MemOp;
    wire ALUAsrc;
    wire [1:0] ALUBsrc;
    wire [3:0] ALUctr;
    wire [1:0] mRegWr;
    wire [3:0] csr_mode;
    wire [4:0] Ra;
    wire [4:0] Rb;
    wire [4:0] Rw;
    
    IDU_ysyx u_IDU_ysyx(
        .clk          	(clk           ),
        .reset        	(reset         ),
        .pc           	(pc_if_id      ),
        .pc_out       	(pc_id_ex      ),
        .inst_valid   	(inst_valid    ),
        .inst_ready   	(inst_ready    ),
        .decode_ready 	(decode_ready  ),
        .decode_valid 	(decode_valid  ),
        .inst         	(inst          ),
        .imm          	(imm           ),
        .RegWr        	(RegWr         ),
        .Branch       	(Branch        ),
        .MemtoReg     	(MemtoReg      ),
        .MemWr        	(MemWr         ),
        .MemOp        	(MemOp         ),
        .ALUAsrc      	(ALUAsrc       ),
        .ALUBsrc      	(ALUBsrc       ),
        .ALUctr       	(ALUctr        ),
        .mRegWr       	(mRegWr        ),
        .csr_mode     	(csr_mode      ),
        .Ra           	(Ra            ),
        .Rb           	(Rb            ),
        .Rw           	(Rw            )
    );
    
    wire    [31:0]  pc_id_ex;


    wire    [31:0]      rs1;
    wire    [31:0]      rs2;
    
    RegisterFile #(5, 32) u_register
    (
        .clk                (clk            ),
        .busW               (result_reg     ),
        .Ra                 (Ra             ),
        .Rb                 (Rb             ),
        .Rw                 (Rw_reg         ),
        .Regwr              (regwr_reg      ),
        .busA               (rs1            ),
        .busB               (rs2            )
    );

    // output declaration of module EXU_ysyx
    wire decode_ready;
    wire lsu_valid;

    wire [31:0] lsu_addr;
    wire [31:0] lsu_data;
    wire [1:0] lsu_mode;
    wire [2:0] lsu_op;

    wire [31:0] Next_pc_ex_ls;
    wire [4:0] Rw_ex_ls;
    wire [31:0] result_ex_ls;
    wire regwr_ex_ls;

    assign  Next_pc     = Next_pc_ex_ls;


    wire        lsu_ready;
    
    EXU_ysyx u_EXU_ysyx(
        .clk          	(clk           ),
        .reset        	(reset         ),
        .pc           	(pc_id_ex      ),
        .rs1          	(rs1           ),
        .rs2          	(rs2           ),

        .decode_valid 	(decode_valid  ),
        .decode_ready 	(decode_ready  ),
        .lsu_ready    	(lsu_ready     ),
        .lsu_valid    	(lsu_valid     ),
        // lsu ctrl
        .lsu_addr     	(lsu_addr      ),
        .lsu_data     	(lsu_data      ),
        .lsu_mode     	(lsu_mode      ),
        .lsu_op       	(lsu_op        ),
        // reg ctrl
        .Next_pc      	(Next_pc_ex_ls ),
        .Rw_out       	(Rw_ex_ls      ),
        .result_out   	(result_ex_ls  ),
        .regwr_out    	(regwr_ex_ls   ),

        .imm          	(imm           ),
        .mRegWr       	(mRegWr        ),
        .csr_mode     	(csr_mode      ),
        .RegWr        	(RegWr         ),
        .branch       	(Branch        ),
        .MemtoReg     	(MemtoReg      ),
        .MemWr        	(MemWr         ),
        .MemOp        	(MemOp         ),
        .ALUAsrc      	(ALUAsrc       ),
        .ALUBsrc      	(ALUBsrc       ),
        .ALUctr       	(ALUctr        ),
        .Rw           	(Rw            )
    );

    // lsu AXI_lite
    // Address Read
    wire    [31:0]      lsu_araddr;
    wire                lsu_arvalid;
    wire                lsu_arready;

    // Data Read 
    wire    [31:0]      lsu_rdata;
    wire    [1:0]       lsu_rresp;
    wire                lsu_rvalid;
    wire                lsu_rready;

    // Address Write
    wire    [31:0]      lsu_awaddr;
    wire                lsu_awvalid;
    wire                lsu_awready;

    // Data Write
    wire    [31:0]      lsu_wdata;
    wire    [3:0]       lsu_wstrb;
    wire                lsu_wvalid;
    wire                lsu_wready;

    // B
    wire    [1:0]       lsu_bresp;
    wire                lsu_bvalid;
    wire                lsu_bready;


    wire    [31:0]      Next_pc_ls_wb;
    wire    [4:0]       Rw_ls_wb;
    wire    [31:0]      result_ls_wb;
    wire                regwr_ls_wb;

    
    LSU_ysyx u_LSU_ysyx(
        .clk         	(clk            ),
        .reset       	(reset          ),
        // lsu ctrl
        .lsu_addr    	(lsu_addr       ),
        .lsu_data    	(lsu_data       ),
        .lsu_mode    	(lsu_mode       ),
        .lsu_op      	(lsu_op         ),
        // reg ctrl
        .Next_pc     	(Next_pc_ex_ls  ),
        .Rw          	(Rw_ex_ls       ),
        .result      	(result_ex_ls   ),
        .regwr       	(regwr_ex_ls    ),
        .Next_pc_out 	(Next_pc_ls_wb  ),
        .Rw_out      	(Rw_ls_wb       ),
        .result_out  	(result_ls_wb   ),
        .regwr_out   	(regwr_ls_wb    ),

        .lsu_valid   	(lsu_valid      ),
        .lsu_ready   	(lsu_ready      ),
        .wbu_ready   	(wbu_ready      ),
        .wbu_valid   	(wbu_valid      ),

        .m_araddr    	(lsu_araddr     ),
        .m_arvalid   	(lsu_arvalid    ),
        .m_arready   	(lsu_arready    ),
        .m_rdata     	(lsu_rdata      ),
        .m_rresp     	(lsu_rresp      ),
        .m_rvalid    	(lsu_rvalid     ),
        .m_rready    	(lsu_rready     ),
        .m_awaddr    	(lsu_awaddr     ),
        .m_awvalid   	(lsu_awvalid    ),
        .m_awready   	(lsu_awready    ),
        .m_wdata     	(lsu_wdata      ),
        .m_wstrb     	(lsu_wstrb      ),
        .m_wvalid    	(lsu_wvalid     ),
        .m_wready    	(lsu_wready     ),
        .m_bresp     	(lsu_bresp      ),
        .m_bvalid    	(lsu_bvalid     ),
        .m_bready    	(lsu_bready     )
    );

    
    SRAM u_SRAM_LSU(
        .clk       	(clk                ),
        .reset     	(reset              ),
        .s_araddr  	(lsu_araddr         ),
        .s_arvalid 	(lsu_arvalid        ),
        .s_arready 	(lsu_arready        ),
        .s_rdata   	(lsu_rdata          ),
        .s_rresp   	(lsu_rresp          ),
        .s_rvalid  	(lsu_rvalid         ),
        .s_rready  	(lsu_rready         ),
        .s_awaddr  	(lsu_awaddr         ),
        .s_awvalid 	(lsu_awvalid        ),
        .s_awready 	(lsu_awready        ),
        .s_wdata   	(lsu_wdata          ),
        .s_wstrb   	(lsu_wstrb          ),
        .s_wvalid  	(lsu_wvalid         ),
        .s_wready  	(lsu_wready         ),
        .s_bresp   	(lsu_bresp          ),
        .s_bvalid  	(lsu_bvalid         ),
        .s_bready  	(lsu_bready         )
    );
    

    // output declaration of module WBU_ysyx

    wire            wbu_valid;
    wire            wbu_ready;

    WBU_ysyx u_WBU_ysyx(
        .clk         	(clk            ),
        .reset       	(reset          ),
        .lsu_valid   	(wbu_valid      ),
        .lsu_ready   	(wbu_ready      ),
        .ifu_ready   	(ifu_ready      ),
        .ifu_valid   	(ifu_valid      ),
        .Next_pc     	(Next_pc_ls_wb  ),
        .Rw          	(Rw_ls_wb       ),
        .result      	(result_ls_wb   ),
        .regwr       	(regwr_ls_wb    ),
        .Next_pc_out 	(pc_wb_if       ),
        .Rw_out      	(Rw_reg         ),
        .result_out  	(result_reg     ),
        .regwr_out   	(regwr_reg      )
    );

    wire    [4:0]       Rw_reg;
    wire    [31:0]      result_reg;
    wire                regwr_reg;
    
endmodule
