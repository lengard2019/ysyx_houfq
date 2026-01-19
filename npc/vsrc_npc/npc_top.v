module npc_top(
    input       clk,
    input       reset
);

    // output declaration of module cpu_top
    wire io_master_awvalid;
    wire [31:0] io_master_awaddr;
    wire [3:0] io_master_awid;
    wire [7:0] io_master_awlen;
    wire [2:0] io_master_awsize;
    wire [1:0] io_master_awburst;
    wire io_master_wvalid;
    wire [31:0] io_master_wdata;
    wire [3:0] io_master_wstrb;
    wire io_master_wlast;
    wire io_master_bready;
    wire io_master_arvalid;
    wire [31:0] io_master_araddr;
    wire [3:0] io_master_arid;
    wire [7:0] io_master_arlen;
    wire [2:0] io_master_arsize;
    wire [1:0] io_master_arburst;
    wire io_master_rready;
    wire io_slave_awready;
    wire io_slave_wready;
    wire io_slave_bvalid;
    wire [1:0] io_slave_bresp;
    wire [3:0] io_slave_bid;
    wire io_slave_arready;
    wire io_slave_rvalid;
    wire [1:0] io_slave_rresp;
    wire [31:0] io_slave_rdata;
    wire io_slave_rlast;
    wire [3:0] io_slave_rid;

    wire io_interrupt = 1'b0;
    
    cpu_top u_cpu_top(
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
        .io_master_rid     	(io_master_rid      ),
        .io_slave_awready  	(io_slave_awready   ),
        .io_slave_awvalid  	(0   ),
        .io_slave_awaddr   	(0    ),
        .io_slave_awid     	(0      ),
        .io_slave_awlen    	(0     ),
        .io_slave_awsize   	(0    ),
        .io_slave_awburst  	(0   ),
        .io_slave_wready   	(io_slave_wready    ),
        .io_slave_wvalid   	(0    ),
        .io_slave_wdata    	(0     ),
        .io_slave_wstrb    	(0     ),
        .io_slave_wlast    	(0     ),
        .io_slave_bready   	(0    ),
        .io_slave_bvalid   	(io_slave_bvalid    ),
        .io_slave_bresp    	(io_slave_bresp     ),
        .io_slave_bid      	(io_slave_bid       ),
        .io_slave_arready  	(io_slave_arready   ),
        .io_slave_arvalid  	(0   ),
        .io_slave_araddr   	(0    ),
        .io_slave_arid     	(0      ),
        .io_slave_arlen    	(0     ),
        .io_slave_arsize   	(0    ),
        .io_slave_arburst  	(0   ),
        .io_slave_rready   	(0    ),
        .io_slave_rvalid   	(io_slave_rvalid    ),
        .io_slave_rresp    	(io_slave_rresp     ),
        .io_slave_rdata    	(io_slave_rdata     ),
        .io_slave_rlast    	(io_slave_rlast     ),
        .io_slave_rid      	(io_slave_rid       ),
        .clock             	(clk                ),
        .reset             	(reset              ),
        .io_interrupt      	(io_interrupt       )
    );


    // output declaration of module SRAM
    wire            io_master_awready;
    wire            io_master_wready;
    wire            io_master_bvalid;
    wire [1:0]      io_master_bresp;
    wire [3:0]      io_master_bid;
    wire            io_master_arready;
    wire            io_master_rvalid;
    wire [1:0]      io_master_rresp;
    wire [31:0]     io_master_rdata;
    wire            io_master_rlast;
    wire [3:0]      io_master_rid;
    
    SRAM u_SRAM(
        .clk              	(clk                ),
        .reset            	(reset              ),
        .io_slave_awready 	(io_master_awready  ),
        .io_slave_awvalid 	(io_master_awvalid  ),
        .io_slave_awaddr  	(io_master_awaddr   ),
        .io_slave_awid    	(io_master_awid     ),
        .io_slave_awlen   	(io_master_awlen    ),
        .io_slave_awsize  	(io_master_awsize   ),
        .io_slave_awburst 	(io_master_awburst  ),
        .io_slave_wready  	(io_master_wready   ),
        .io_slave_wvalid  	(io_master_wvalid   ),
        .io_slave_wdata   	(io_master_wdata    ),
        .io_slave_wstrb   	(io_master_wstrb    ),
        .io_slave_wlast   	(io_master_wlast    ),
        .io_slave_bready  	(io_master_bready   ),
        .io_slave_bvalid  	(io_master_bvalid   ),
        .io_slave_bresp   	(io_master_bresp    ),
        .io_slave_bid     	(io_master_bid      ),
        .io_slave_arready 	(io_master_arready  ),
        .io_slave_arvalid 	(io_master_arvalid  ),
        .io_slave_araddr  	(io_master_araddr   ),
        .io_slave_arid    	(io_master_arid     ),
        .io_slave_arlen   	(io_master_arlen    ),
        .io_slave_arsize  	(io_master_arsize   ),
        .io_slave_arburst 	(io_master_arburst  ),
        .io_slave_rready  	(io_master_rready   ),
        .io_slave_rvalid  	(io_master_rvalid   ),
        .io_slave_rresp   	(io_master_rresp    ),
        .io_slave_rdata   	(io_master_rdata    ),
        .io_slave_rlast   	(io_master_rlast    ),
        .io_slave_rid     	(io_master_rid      )
    );
    
    


endmodule

