module IFU_ysyx( // ID = 0 原子访问，对齐，无窄传输

    input               clk,
    input               reset,

    output  [31:0]      inst,
    output  [31:0]      pc_out,

    input   [31:0]      pc,
    input               pc_valid,
    output              pc_ready,

    // interface to IDU
    input               inst_ready,
    output              inst_valid,

    // interface to SRAM  AXI
    // Address Read
    // output  [31:0]      m_araddr,
    // output              m_arvalid,
    // input               m_arready,

    // // Data Read 
    // input   [31:0]      m_rdata,
    // input   [1:0]       m_rresp,
    // input               m_rvalid,
    // output              m_rready,

    // // Address Write
    // output  [31:0]      m_awaddr,
    // output              m_awvalid,
    // input               m_awready,

    // // Data Write
    // output  [31:0]      m_wdata,
    // output  [3:0]       m_wstrb,
    // output              m_wvalid,
    // input               m_wready,

    // // B
    // input   [1:0]       m_bresp,
    // input               m_bvalid,
    // output              m_bready

    input               master_awready,
    output              master_awvalid, 
    output  [31:0]      master_awaddr,  
    output  [3:0]       master_awid,    
    output  [7:0]       master_awlen,   
    output  [2:0]       master_awsize,  
    output  [1:0]       master_awburst, 
    input               master_wready,  
    output              master_wvalid,  
    output  [31:0]      master_wdata,   
    output  [3:0]       master_wstrb,   
    output              master_wlast,   
    output              master_bready,  
    input               master_bvalid,  
    input   [1:0]       master_bresp,   
    input   [3:0]       master_bid,     

    input               master_arready, 
    output              master_arvalid, 
    output  [31:0]      master_araddr,  
    output  [3:0]       master_arid,    
    output  [7:0]       master_arlen,   
    output  [2:0]       master_arsize,  
    output  [1:0]       master_arburst, 
    output              master_rready,  
    input               master_rvalid,  
    input   [1:0]       master_rresp,   
    input   [31:0]      master_rdata,   
    input               master_rlast,   
    input   [3:0]       master_rid     

);

    localparam IDLE             = 0;
    localparam WAIT_PCVALID     = 1;
    localparam WAIT_ARREADY     = 2;
    localparam WAIT_RVAILD      = 3;
    localparam WAIT_INSTREADY   = 4;

    // unused
    assign  master_bready           = 1'b0;
    assign  master_awaddr           = 32'h0;
    assign  master_awvalid          = 1'b0;
    assign  master_wdata            = 32'h0;
    assign  master_wstrb            = 4'b0000;
    assign  master_wvalid           = 1'b0;
    assign  master_wlast            = 1'b0;
    assign  master_awid             = 0;    
    assign  master_awlen            = 0;     
    assign  master_awsize           = 0;      
    assign  master_awburst          = 0;       


    reg     [31:0]      inst_r;

    reg     [31:0]      pc_r;

    reg     [3:0]       current_state;
    reg     [3:0]       next_state;
    reg     [1:0]       m_rresp_r;

    always @(*) begin
        if(m_rresp_r != 2'b00) begin
            $display("IFU read error\n");
        end
        else begin

        end
    end



    always @(posedge clk or posedge reset) begin
        if (reset == 1'b1) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    always @(*) begin

        next_state = current_state;

        case (current_state)
            IDLE: begin
                next_state = WAIT_PCVALID;
            end

            WAIT_PCVALID: begin // pc握手后把arvalid置高
                if(pc_valid == 1'b1) begin
                    next_state = WAIT_ARREADY;
                end
                else begin
                    next_state = WAIT_PCVALID;
                end
            end

            WAIT_ARREADY: begin // addr
                if(master_arready == 1'b1)begin
                    next_state = WAIT_RVAILD;
                end
                else begin
                    next_state = WAIT_ARREADY;
                end
            end

            WAIT_RVAILD: begin // data
                if(master_rvalid == 1'b1)begin
                    next_state = WAIT_INSTREADY;
                end
                else begin
                    next_state = WAIT_RVAILD;
                end
            end

            WAIT_INSTREADY: begin
                if(inst_ready == 1'b1) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = WAIT_INSTREADY;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    assign  pc_ready            = (current_state == WAIT_PCVALID) ? 1'b1 : 1'b0;
    assign  master_arvalid      = (current_state == WAIT_ARREADY) ? 1'b1 : 1'b0;
    assign  master_araddr       = pc_r;
    assign  master_arburst      = 2'b10;
    assign  master_arid         = 4'b0000;
    assign  master_arlen        = 8'h00;
    assign  master_arsize       = 3'b010; // 4字节
    assign  master_rready       = (current_state == WAIT_RVAILD) ? 1'b1 : 1'b0;
    assign  inst_valid          = (current_state == WAIT_INSTREADY && m_rresp_r == 2'b00) ? 1'b1 : 1'b0;
    assign  inst                = inst_r;
    assign  pc_out              = pc_r;


    always @(posedge clk or posedge reset) begin // 收pc
        if(reset == 1'b1) begin
            pc_r            <= 32'h30000000;
        end
        else begin
            if(pc_ready == 1'b1 && pc_valid == 1'b1)begin
                pc_r            <= pc;
            end
            else begin
            end
        end
    end

    always @(posedge clk or posedge reset) begin // 从SRAM收指令
        if(reset == 1'b1) begin
            inst_r          <= 32'hffffffff;
        end
        else begin
            if(master_rready == 1'b1 && master_rvalid == 1'b1)begin
                inst_r          <= master_rdata;
                m_rresp_r       <= master_rresp;
            end
            else begin
            end
        end
    end


endmodule
