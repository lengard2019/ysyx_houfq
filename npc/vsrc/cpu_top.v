import "DPI-C" function void call_ebreak();

module cpu_top(
    input               clock,
    input               reset,

    input               io_interrupt,

    // output  [31:0]      Next_pc,
    // output  [31:0]      pc,

    input               io_master_awready,
    output              io_master_awvalid, 
    output  [31:0]      io_master_awaddr,  
    output  [3:0]       io_master_awid,    
    output  [7:0]       io_master_awlen,   
    output  [2:0]       io_master_awsize,  
    output  [1:0]       io_master_awburst, 
    input               io_master_wready,  
    output              io_master_wvalid,  
    output  [31:0]      io_master_wdata,   
    output  [3:0]       io_master_wstrb,   
    output              io_master_wlast,   
    output              io_master_bready,  
    input               io_master_bvalid,  
    input   [1:0]       io_master_bresp,   
    input   [3:0]       io_master_bid,     
    input               io_master_arready, 
    output              io_master_arvalid, 
    output  [31:0]      io_master_araddr,  
    output  [3:0]       io_master_arid,    
    output  [7:0]       io_master_arlen,   
    output  [2:0]       io_master_arsize,  
    output  [1:0]       io_master_arburst, 
    output              io_master_rready,  
    input               io_master_rvalid,  
    input   [1:0]       io_master_rresp,   
    input   [31:0]      io_master_rdata,   
    input               io_master_rlast,   
    input   [3:0]       io_master_rid,

    output              io_slave_awready, 
    input               io_slave_awvalid, 
    input   [31:0]      io_slave_awaddr,  
    input   [3:0]       io_slave_awid,    
    input   [7:0]       io_slave_awlen,   
    input   [2:0]       io_slave_awsize,  
    input   [1:0]       io_slave_awburst, 
    output              io_slave_wready,  
    input               io_slave_wvalid,  
    input   [31:0]      io_slave_wdata,   
    input   [3:0]       io_slave_wstrb,   
    input               io_slave_wlast,   
    input               io_slave_bready,  
    output              io_slave_bvalid,  
    output  [1:0]       io_slave_bresp,   
    output  [3:0]       io_slave_bid,     
    output              io_slave_arready, 
    input               io_slave_arvalid, 
    input   [31:0]      io_slave_araddr,  
    input   [3:0]       io_slave_arid,    
    input   [7:0]       io_slave_arlen,   
    input   [2:0]       io_slave_arsize,  
    input   [1:0]       io_slave_arburst, 
    input               io_slave_rready,  
    output              io_slave_rvalid,  
    output  [1:0]       io_slave_rresp,   
    output  [31:0]      io_slave_rdata,   
    output              io_slave_rlast,   
    output  [3:0]       io_slave_rid    

);

    assign  io_slave_awready    = 0;
    assign  io_slave_wready     = 0;
    assign  io_slave_bvalid     = 0;
    assign  io_slave_bresp      = 0;
    assign  io_slave_bid        = 0;
    assign  io_slave_arready    = 0;
    assign  io_slave_rvalid     = 0;   
    assign  io_slave_rresp      = 0;  
    assign  io_slave_rdata      = 0;  
    assign  io_slave_rlast      = 0;  
    assign  io_slave_rid        = 0;


    wire    [4:0]       Ra;
    wire    [4:0]       Rb;
    wire    [4:0]       Rw;


    // output declaration of module IFU_ysyx
    wire    [31:0]      inst;
    wire                inst_valid;
    wire                inst_ready;

    // IFU AXI-lite
    wire                ifu_awready;
    wire                ifu_awvalid; 
    wire    [31:0]      ifu_awaddr;  
    wire    [3:0]       ifu_awid;    
    wire    [7:0]       ifu_awlen;   
    wire    [2:0]       ifu_awsize;  
    wire    [1:0]       ifu_awburst; 
    wire                ifu_wready;  
    wire                ifu_wvalid;  
    wire    [31:0]      ifu_wdata;   
    wire    [3:0]       ifu_wstrb;   
    wire                ifu_wlast;   
    wire                ifu_bready;  
    wire                ifu_bvalid;  
    wire    [1:0]       ifu_bresp;   
    wire    [3:0]       ifu_bid;     
    wire                ifu_arready; 
    wire                ifu_arvalid;
    wire    [31:0]      ifu_araddr;  
    wire    [3:0]       ifu_arid;    
    wire    [7:0]       ifu_arlen;   
    wire    [2:0]       ifu_arsize;  
    wire    [1:0]       ifu_arburst; 
    wire                ifu_rready;  
    wire                ifu_rvalid;  
    wire    [1:0]       ifu_rresp;   
    wire    [31:0]      ifu_rdata;   
    wire                ifu_rlast;   
    wire    [3:0]       ifu_rid;

    wire    [31:0]      pc_wb_if;

    // assign  pc          = pc_wb_if;

    wire                ifu_ready;

    wire                ifu_valid;
    
    
    IFU_ysyx u_IFU_ysyx(
        .clk        	    (clock          ),
        .reset      	    (reset          ),
        .inst       	    (inst           ),
        .pc_out             (pc_if_id       ),
        .pc         	    (pc_wb_if       ),
        .pc_valid   	    (ifu_valid      ), // WBU
        .pc_ready   	    (ifu_ready      ), // WBU
        .inst_ready 	    (inst_ready     ),
        .inst_valid 	    (inst_valid     ),
        .master_awready     (ifu_awready    ),     
        .master_awvalid     (ifu_awvalid    ),     
        .master_awaddr      (ifu_awaddr     ),    
        .master_awid        (ifu_awid       ),  
        .master_awlen       (ifu_awlen      ),   
        .master_awsize      (ifu_awsize     ),    
        .master_awburst     (ifu_awburst    ),     
        .master_wready      (ifu_wready     ),    
        .master_wvalid      (ifu_wvalid     ),    
        .master_wdata       (ifu_wdata      ),   
        .master_wstrb       (ifu_wstrb      ),   
        .master_wlast       (ifu_wlast      ),   
        .master_bready      (ifu_bready     ),    
        .master_bvalid      (ifu_bvalid     ),    
        .master_bresp       (ifu_bresp      ),   
        .master_bid         (ifu_bid        ), 
        .master_arready     (ifu_arready    ),    
        .master_arvalid     (ifu_arvalid    ),    
        .master_araddr      (ifu_araddr     ),   
        .master_arid        (ifu_arid       ), 
        .master_arlen       (ifu_arlen      ),  
        .master_arsize      (ifu_arsize     ),   
        .master_arburst     (ifu_arburst    ),    
        .master_rready      (ifu_rready     ),   
        .master_rvalid      (ifu_rvalid     ),   
        .master_rresp       (ifu_rresp      ),  
        .master_rdata       (ifu_rdata      ),  
        .master_rlast       (ifu_rlast      ),  
        .master_rid         (ifu_rid        )
    );

    always @(posedge clock) begin
        if(inst == 32'h00100073) begin
            call_ebreak();
            $display("call ebreak\n");
        end
    end


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
        .clk          	    (clock         ),
        .reset        	    (reset         ),
        .pc           	    (pc_if_id      ),
        .pc_out       	    (pc_id_ex      ),
        .inst_valid   	    (inst_valid    ),
        .inst_ready   	    (inst_ready    ),
        .decode_ready 	    (decode_ready  ),
        .decode_valid 	    (decode_valid  ),
        .inst         	    (inst          ),
        .imm          	    (imm           ),
        .RegWr        	    (RegWr         ),
        .Branch       	    (Branch        ),
        .MemtoReg     	    (MemtoReg      ),
        .MemWr        	    (MemWr         ),
        .MemOp        	    (MemOp         ),
        .ALUAsrc      	    (ALUAsrc       ),
        .ALUBsrc      	    (ALUBsrc       ),
        .ALUctr       	    (ALUctr        ),
        .mRegWr       	    (mRegWr        ),
        .csr_mode     	    (csr_mode      ),
        .Ra           	    (Ra            ),
        .Rb           	    (Rb            ),
        .Rw           	    (Rw            )
    );
    
    wire    [31:0]  pc_id_ex;


    wire    [31:0]      rs1;
    wire    [31:0]      rs2;
    
    RegisterFile #(5, 32) u_register
    (
        .clk                (clock          ),
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

    // assign  Next_pc     = Next_pc_ex_ls;


    wire        lsu_ready;
    
    EXU_ysyx u_EXU_ysyx(
        .clk          	    (clock         ),
        .reset        	    (reset         ),
        .pc           	    (pc_id_ex      ),
        .rs1          	    (rs1           ),
        .rs2          	    (rs2           ),

        .decode_valid 	    (decode_valid  ),
        .decode_ready 	    (decode_ready  ),
        .lsu_ready    	    (lsu_ready     ),
        .lsu_valid    	    (lsu_valid     ),
        // lsu ctrl
        .lsu_addr     	    (lsu_addr      ),
        .lsu_data     	    (lsu_data      ),
        .lsu_mode     	    (lsu_mode      ),
        .lsu_op       	    (lsu_op        ),
        // reg ctrl
        .Next_pc      	    (Next_pc_ex_ls ),
        .Rw_out       	    (Rw_ex_ls      ),
        .result_out   	    (result_ex_ls  ),
        .regwr_out    	    (regwr_ex_ls   ),

        .imm          	    (imm           ),
        .mRegWr       	    (mRegWr        ),
        .csr_mode     	    (csr_mode      ),
        .RegWr        	    (RegWr         ),
        .branch       	    (Branch        ),
        .MemtoReg     	    (MemtoReg      ),
        .MemWr        	    (MemWr         ),
        .MemOp        	    (MemOp         ),
        .ALUAsrc      	    (ALUAsrc       ),
        .ALUBsrc      	    (ALUBsrc       ),
        .ALUctr       	    (ALUctr        ),
        .Rw           	    (Rw            )
    );

    // lsu AXI4
    // Address Read
    wire                lsu_awready;
    wire                lsu_awvalid; 
    wire    [31:0]      lsu_awaddr;  
    wire    [3:0]       lsu_awid;    
    wire    [7:0]       lsu_awlen;   
    wire    [2:0]       lsu_awsize;  
    wire    [1:0]       lsu_awburst; 
    wire                lsu_wready;  
    wire                lsu_wvalid;  
    wire    [31:0]      lsu_wdata;   
    wire    [3:0]       lsu_wstrb;   
    wire                lsu_wlast;   
    wire                lsu_bready;  
    wire                lsu_bvalid;  
    wire    [1:0]       lsu_bresp;   
    wire    [3:0]       lsu_bid;     
    wire                lsu_arready; 
    wire                lsu_arvalid;
    wire    [31:0]      lsu_araddr;  
    wire    [3:0]       lsu_arid;    
    wire    [7:0]       lsu_arlen;   
    wire    [2:0]       lsu_arsize;  
    wire    [1:0]       lsu_arburst; 
    wire                lsu_rready;  
    wire                lsu_rvalid;  
    wire    [1:0]       lsu_rresp;   
    wire    [31:0]      lsu_rdata;   
    wire                lsu_rlast;   
    wire    [3:0]       lsu_rid;

    wire    [31:0]      Next_pc_ls_wb;
    wire    [4:0]       Rw_ls_wb;
    wire    [31:0]      result_ls_wb;
    wire                regwr_ls_wb;

    
    LSU_ysyx u_LSU_ysyx(
        .clk         	    (clock          ),
        .reset       	    (reset          ),
        // lsu ctrl
        .lsu_addr    	    (lsu_addr       ),
        .lsu_data    	    (lsu_data       ),
        .lsu_mode    	    (lsu_mode       ),
        .lsu_op      	    (lsu_op         ),
        // reg ctrl
        .Next_pc     	    (Next_pc_ex_ls  ),
        .Rw          	    (Rw_ex_ls       ),
        .result      	    (result_ex_ls   ),
        .regwr       	    (regwr_ex_ls    ),
        .Next_pc_out 	    (Next_pc_ls_wb  ),
        .Rw_out      	    (Rw_ls_wb       ),
        .result_out  	    (result_ls_wb   ),
        .regwr_out   	    (regwr_ls_wb    ),

        .lsu_valid   	    (lsu_valid      ),
        .lsu_ready   	    (lsu_ready      ),
        .wbu_ready   	    (wbu_ready      ),
        .wbu_valid   	    (wbu_valid      ),

        .master_awready     (lsu_awready    ),     
        .master_awvalid     (lsu_awvalid    ),     
        .master_awaddr      (lsu_awaddr     ),    
        .master_awid        (lsu_awid       ),  
        .master_awlen       (lsu_awlen      ),   
        .master_awsize      (lsu_awsize     ),    
        .master_awburst     (lsu_awburst    ),     
        .master_wready      (lsu_wready     ),    
        .master_wvalid      (lsu_wvalid     ),    
        .master_wdata       (lsu_wdata      ),   
        .master_wstrb       (lsu_wstrb      ),   
        .master_wlast       (lsu_wlast      ),   
        .master_bready      (lsu_bready     ),    
        .master_bvalid      (lsu_bvalid     ),    
        .master_bresp       (lsu_bresp      ),   
        .master_bid         (lsu_bid        ), 
        .master_arready     (lsu_arready    ),    
        .master_arvalid     (lsu_arvalid    ),    
        .master_araddr      (lsu_araddr     ),   
        .master_arid        (lsu_arid       ), 
        .master_arlen       (lsu_arlen      ),  
        .master_arsize      (lsu_arsize     ),   
        .master_arburst     (lsu_arburst    ),    
        .master_rready      (lsu_rready     ),   
        .master_rvalid      (lsu_rvalid     ),   
        .master_rresp       (lsu_rresp      ),  
        .master_rdata       (lsu_rdata      ),  
        .master_rlast       (lsu_rlast      ),  
        .master_rid         (lsu_rid        )
    );


    // output declaration of module WBU_ysyx

    wire            wbu_valid;
    wire            wbu_ready;

    WBU_ysyx u_WBU_ysyx(
        .clk         	    (clock          ),
        .reset       	    (reset          ),
        .lsu_valid   	    (wbu_valid      ),
        .lsu_ready   	    (wbu_ready      ),
        .ifu_ready   	    (ifu_ready      ),
        .ifu_valid   	    (ifu_valid      ),
        .Next_pc     	    (Next_pc_ls_wb  ),
        .Rw          	    (Rw_ls_wb       ),
        .result      	    (result_ls_wb   ),
        .regwr       	    (regwr_ls_wb    ),
        .Next_pc_out 	    (pc_wb_if       ),
        .Rw_out      	    (Rw_reg         ),
        .result_out  	    (result_reg     ),
        .regwr_out   	    (regwr_reg      )
    );

    wire    [4:0]       Rw_reg;
    wire    [31:0]      result_reg;
    wire                regwr_reg;

    // output declaration of module xBar

    xBar u_xBar(
        .clk               	(clock              ),
        .reset             	(reset              ),
        .ifu_valid         	(ifu_valid          ),
        .decode_valid      	(decode_valid       ),
        .ifu_awready       	(ifu_awready        ),
        .ifu_awvalid       	(ifu_awvalid        ),
        .ifu_awaddr        	(ifu_awaddr         ),
        .ifu_awid          	(ifu_awid           ),
        .ifu_awlen         	(ifu_awlen          ),
        .ifu_awsize        	(ifu_awsize         ),
        .ifu_awburst       	(ifu_awburst        ),
        .ifu_wready        	(ifu_wready         ),
        .ifu_wvalid        	(ifu_wvalid         ),
        .ifu_wdata         	(ifu_wdata          ),
        .ifu_wstrb         	(ifu_wstrb          ),
        .ifu_wlast         	(ifu_wlast          ),
        .ifu_bready        	(ifu_bready         ),
        .ifu_bvalid        	(ifu_bvalid         ),
        .ifu_bresp         	(ifu_bresp          ),
        .ifu_bid           	(ifu_bid            ),
        .ifu_arready       	(ifu_arready        ),
        .ifu_arvalid       	(ifu_arvalid        ),
        .ifu_araddr        	(ifu_araddr         ),
        .ifu_arid          	(ifu_arid           ),
        .ifu_arlen         	(ifu_arlen          ),
        .ifu_arsize        	(ifu_arsize         ),
        .ifu_arburst       	(ifu_arburst        ),
        .ifu_rready        	(ifu_rready         ),
        .ifu_rvalid        	(ifu_rvalid         ),
        .ifu_rresp         	(ifu_rresp          ),
        .ifu_rdata         	(ifu_rdata          ),
        .ifu_rlast         	(ifu_rlast          ),
        .ifu_rid           	(ifu_rid            ),
        .lsu_awready       	(lsu_awready        ),
        .lsu_awvalid       	(lsu_awvalid        ),
        .lsu_awaddr        	(lsu_awaddr         ),
        .lsu_awid          	(lsu_awid           ),
        .lsu_awlen         	(lsu_awlen          ),
        .lsu_awsize        	(lsu_awsize         ),
        .lsu_awburst       	(lsu_awburst        ),
        .lsu_wready        	(lsu_wready         ),
        .lsu_wvalid        	(lsu_wvalid         ),
        .lsu_wdata         	(lsu_wdata          ),
        .lsu_wstrb         	(lsu_wstrb          ),
        .lsu_wlast         	(lsu_wlast          ),
        .lsu_bready        	(lsu_bready         ),
        .lsu_bvalid        	(lsu_bvalid         ),
        .lsu_bresp         	(lsu_bresp          ),
        .lsu_bid           	(lsu_bid            ),
        .lsu_arready       	(lsu_arready        ),
        .lsu_arvalid       	(lsu_arvalid        ),
        .lsu_araddr        	(lsu_araddr         ),
        .lsu_arid          	(lsu_arid           ),
        .lsu_arlen         	(lsu_arlen          ),
        .lsu_arsize        	(lsu_arsize         ),
        .lsu_arburst       	(lsu_arburst        ),
        .lsu_rready        	(lsu_rready         ),
        .lsu_rvalid        	(lsu_rvalid         ),
        .lsu_rresp         	(lsu_rresp          ),
        .lsu_rdata         	(lsu_rdata          ),
        .lsu_rlast         	(lsu_rlast          ),
        .lsu_rid           	(lsu_rid            ),
        .io_master_awready 	(io_master_awready  ),
        .io_master_awvalid 	(io_master_awvalid  ),
        .io_master_awaddr  	(io_master_awaddr   ),
        .io_master_awid    	(io_master_awid     ),
        .io_master_awlen   	(io_master_awlen    ),
        .io_master_awsize  	(io_master_awsize   ),
        .io_master_awburst 	(io_master_awburst  ),
        .io_master_wready  	(io_master_wready   ),
        .io_master_wvalid  	(io_master_wvalid   ),
        .io_master_wdata   	(io_master_wdata    ),
        .io_master_wstrb   	(io_master_wstrb    ),
        .io_master_wlast   	(io_master_wlast    ),
        .io_master_bready  	(io_master_bready   ),
        .io_master_bvalid  	(io_master_bvalid   ),
        .io_master_bresp   	(io_master_bresp    ),
        .io_master_bid     	(io_master_bid      ),
        .io_master_arready 	(io_master_arready  ),
        .io_master_arvalid 	(io_master_arvalid  ),
        .io_master_araddr  	(io_master_araddr   ),
        .io_master_arid    	(io_master_arid     ),
        .io_master_arlen   	(io_master_arlen    ),
        .io_master_arsize  	(io_master_arsize   ),
        .io_master_arburst 	(io_master_arburst  ),
        .io_master_rready  	(io_master_rready   ),
        .io_master_rvalid  	(io_master_rvalid   ),
        .io_master_rresp   	(io_master_rresp    ),
        .io_master_rdata   	(io_master_rdata    ),
        .io_master_rlast   	(io_master_rlast    ),
        .io_master_rid     	(io_master_rid      )
    );
    
    
endmodule
