module xBar(
    input               clk,
    input               reset,

    input               ifu_valid,
    input               decode_valid,

    output              ifu_awready,
    input               ifu_awvalid, 
    input   [31:0]      ifu_awaddr,  
    input   [3:0]       ifu_awid,    
    input   [7:0]       ifu_awlen,   
    input   [2:0]       ifu_awsize,  
    input   [1:0]       ifu_awburst, 
    output              ifu_wready,  
    input               ifu_wvalid,  
    input   [31:0]      ifu_wdata,   
    input   [3:0]       ifu_wstrb,   
    input               ifu_wlast,   
    input               ifu_bready,  
    output              ifu_bvalid,  
    output  [1:0]       ifu_bresp,   
    output  [3:0]       ifu_bid,     
    output              ifu_arready, 
    input               ifu_arvalid, 
    input   [31:0]      ifu_araddr,  
    input   [3:0]       ifu_arid,    
    input   [7:0]       ifu_arlen,   
    input   [2:0]       ifu_arsize,  
    input   [1:0]       ifu_arburst, 
    input               ifu_rready,  
    output              ifu_rvalid,  
    output  [1:0]       ifu_rresp,   
    output  [31:0]      ifu_rdata,   
    output              ifu_rlast,   
    output  [3:0]       ifu_rid,     

    output              lsu_awready,
    input               lsu_awvalid, 
    input   [31:0]      lsu_awaddr,  
    input   [3:0]       lsu_awid,    
    input   [7:0]       lsu_awlen,   
    input   [2:0]       lsu_awsize,  
    input   [1:0]       lsu_awburst, 
    output              lsu_wready,  
    input               lsu_wvalid,  
    input   [31:0]      lsu_wdata,   
    input   [3:0]       lsu_wstrb,   
    input               lsu_wlast,   
    input               lsu_bready,  
    output              lsu_bvalid,  
    output  [1:0]       lsu_bresp,   
    output  [3:0]       lsu_bid,     
    output              lsu_arready, 
    input               lsu_arvalid, 
    input   [31:0]      lsu_araddr,  
    input   [3:0]       lsu_arid,    
    input   [7:0]       lsu_arlen,   
    input   [2:0]       lsu_arsize,  
    input   [1:0]       lsu_arburst, 
    input               lsu_rready,  
    output              lsu_rvalid,  
    output  [1:0]       lsu_rresp,   
    output  [31:0]      lsu_rdata,   
    output              lsu_rlast,   
    output  [3:0]       lsu_rid,

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
    input   [3:0]       io_master_rid
);


    reg     current_state;
    reg     next_state;


    localparam  IFU_STATE   = 0;
    localparam  LSU_STATE   = 1;

    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1) begin
            current_state   <= IFU_STATE;
        end
        else begin
            current_state   <= next_state;
        end
    end

    always @(*) begin
        case(current_state)
            IFU_STATE: begin
                if(decode_valid == 1'b1) begin
                    next_state      = LSU_STATE;
                end
            end
            LSU_STATE: begin
                if(ifu_valid == 1'b1) begin
                    next_state      = IFU_STATE;
                end
            end
        endcase
    end

    assign  ifu_awready             = (current_state == IFU_STATE) ? io_master_awready : 1'b0;
    assign  lsu_awready             = (current_state == LSU_STATE) ? io_master_awready : 1'b0;

    assign  ifu_wready              = (current_state == IFU_STATE) ? io_master_wready : 1'b0;
    assign  lsu_wready              = (current_state == LSU_STATE) ? io_master_wready : 1'b0;

    assign  ifu_bvalid              = (current_state == IFU_STATE) ? io_master_bvalid : 1'b0;
    assign  lsu_bvalid              = (current_state == LSU_STATE) ? io_master_bvalid : 1'b0;

    assign  ifu_bresp               = (current_state == IFU_STATE) ? io_master_bresp : 2'b00;
    assign  lsu_bresp               = (current_state == LSU_STATE) ? io_master_bresp : 2'b00;

    assign  ifu_bid                 = (current_state == IFU_STATE) ? io_master_bid : 4'b0000;
    assign  lsu_bid                 = (current_state == LSU_STATE) ? io_master_bid : 4'b0000;

    assign  ifu_arready             = (current_state == IFU_STATE) ? io_master_arready : 1'b0;
    assign  lsu_arready             = (current_state == LSU_STATE) ? io_master_arready : 1'b0;
    
    assign  ifu_rvalid              = (current_state == IFU_STATE) ? io_master_rvalid : 1'b0;
    assign  lsu_rvalid              = (current_state == LSU_STATE) ? io_master_rvalid : 1'b0;

    assign  ifu_rresp               = (current_state == IFU_STATE) ? io_master_rresp : 2'b0;
    assign  lsu_rresp               = (current_state == LSU_STATE) ? io_master_rresp : 2'b0;

    assign  ifu_rdata               = (current_state == IFU_STATE) ? io_master_rdata : 32'b0;
    assign  lsu_rdata               = (current_state == LSU_STATE) ? io_master_rdata : 32'b0;

    assign  ifu_rlast               = (current_state == IFU_STATE) ? io_master_rlast : 1'b0;
    assign  lsu_rlast               = (current_state == LSU_STATE) ? io_master_rlast : 1'b0;

    assign  ifu_rid                 = (current_state == IFU_STATE) ? io_master_rid : 4'b0000;
    assign  lsu_rid                 = (current_state == LSU_STATE) ? io_master_rid : 4'b0000;


    // assign  io_master_awready       = (current_state == IFU_STATE) ? ifu_awready : lsu_awready;        
    assign  io_master_awvalid       = (current_state == IFU_STATE) ? ifu_awvalid : lsu_awvalid;        
    assign  io_master_awaddr        = (current_state == IFU_STATE) ? ifu_awaddr  : lsu_awaddr;      
    assign  io_master_awid          = (current_state == IFU_STATE) ? ifu_awid    : lsu_awid;  
    assign  io_master_awlen         = (current_state == IFU_STATE) ? ifu_awlen   : lsu_awlen;    
    assign  io_master_awsize        = (current_state == IFU_STATE) ? ifu_awsize  : lsu_awsize;      
    assign  io_master_awburst       = (current_state == IFU_STATE) ? ifu_awburst : lsu_awburst;        
    // assign  io_master_wready        = (current_state == IFU_STATE) ? ifu_wready  : lsu_wready;      
    assign  io_master_wvalid        = (current_state == IFU_STATE) ? ifu_wvalid  : lsu_wvalid;      
    assign  io_master_wdata         = (current_state == IFU_STATE) ? ifu_wdata   : lsu_wdata;    
    assign  io_master_wstrb         = (current_state == IFU_STATE) ? ifu_wstrb   : lsu_wstrb;    
    assign  io_master_wlast         = (current_state == IFU_STATE) ? ifu_wlast   : lsu_wlast;    
    assign  io_master_bready        = (current_state == IFU_STATE) ? ifu_bready  : lsu_bready;      
    // assign  io_master_bvalid        = (current_state == IFU_STATE) ? ifu_bvalid  : lsu_bvalid;      
    // assign  io_master_bresp         = (current_state == IFU_STATE) ? ifu_bresp   : lsu_bresp;    
    // assign  io_master_bid           = (current_state == IFU_STATE) ? ifu_bid     : lsu_bid;
    // assign  io_master_arready       = (current_state == IFU_STATE) ? ifu_arready : lsu_arready;        
    assign  io_master_arvalid       = (current_state == IFU_STATE) ? ifu_arvalid : lsu_arvalid;        
    assign  io_master_araddr        = (current_state == IFU_STATE) ? ifu_araddr  : lsu_araddr;      
    assign  io_master_arid          = (current_state == IFU_STATE) ? ifu_arid    : lsu_arid;  
    assign  io_master_arlen         = (current_state == IFU_STATE) ? ifu_arlen   : lsu_arlen;    
    assign  io_master_arsize        = (current_state == IFU_STATE) ? ifu_arsize  : lsu_arsize;      
    assign  io_master_arburst       = (current_state == IFU_STATE) ? ifu_arburst : lsu_arburst;        
    assign  io_master_rready        = (current_state == IFU_STATE) ? ifu_rready  : lsu_rready;      
    // assign  io_master_rvalid        = (current_state == IFU_STATE) ? ifu_rvalid  : lsu_rvalid;      
    // assign  io_master_rresp         = (current_state == IFU_STATE) ? ifu_rresp   : lsu_rresp;    
    // assign  io_master_rdata         = (current_state == IFU_STATE) ? ifu_rdata   : lsu_rdata;    
    // assign  io_master_rlast         = (current_state == IFU_STATE) ? ifu_rlast   : lsu_rlast;    
    // assign  io_master_rid           = (current_state == IFU_STATE) ? ifu_rid     : lsu_rid;



endmodule
