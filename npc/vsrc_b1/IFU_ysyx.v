module IFU_ysyx( // ID = 0

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
    output  [31:0]      m_araddr,
    output              m_arvalid,
    input               m_arready,

    // Data Read 
    input   [31:0]      m_rdata,
    input   [1:0]       m_rresp,
    input               m_rvalid,
    output              m_rready,

    // Address Write
    output  [31:0]      m_awaddr,
    output              m_awvalid,
    input               m_awready,

    // Data Write
    output  [31:0]      m_wdata,
    output  [3:0]       m_wstrb,
    output              m_wvalid,
    input               m_wready,

    // B
    input   [1:0]       m_bresp,
    input               m_bvalid,
    output              m_bready

);

    localparam IDLE             = 0;
    localparam WAIT_PCVALID     = 1;
    localparam WAIT_ARREADY     = 2;
    localparam WAIT_RVAILD      = 3;
    localparam WAIT_INSTREADY   = 4;

    assign  m_bready            = 1'b0;
    assign  m_awaddr            = 32'hffffffff;
    assign  m_awvalid           = 1'b0;
    assign  m_wdata             = 32'hffffffff;
    assign  m_wstrb             = 4'b0000;
    assign  m_wvalid            = 1'b0;


    reg     [31:0]      inst_r;

    reg     [31:0]      pc_r;

    reg     [3:0]       current_state;
    reg     [3:0]       next_state;
    reg     [1:0]       m_rresp_r;


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
                if(m_arready == 1'b1)begin
                    next_state = WAIT_RVAILD;
                end
                else begin
                    next_state = WAIT_ARREADY;
                end
            end

            WAIT_RVAILD: begin // data
                if(m_rvalid == 1'b1)begin
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

    assign  pc_ready    = (current_state == WAIT_PCVALID) ? 1'b1 : 1'b0;
    assign  m_arvalid   = (current_state == WAIT_ARREADY) ? 1'b1 : 1'b0;
    assign  m_araddr    = pc_r;
    assign  m_rready    = (current_state == WAIT_RVAILD) ? 1'b1 : 1'b0;
    assign  inst_valid  = (current_state == WAIT_INSTREADY && m_rresp_r == 2'b00) ? 1'b1 : 1'b0;
    assign  inst        = inst_r;
    assign  pc_out      = pc_r;


    always @(posedge clk or posedge reset) begin // 收pc
        if(reset == 1'b1) begin
            pc_r            <= 32'h80000000;
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
            if(m_rready == 1'b1 && m_rvalid == 1'b1)begin
                inst_r          <= m_rdata;
                m_rresp_r       <= m_rresp;
            end
            else begin
            end
        end
    end


endmodule
