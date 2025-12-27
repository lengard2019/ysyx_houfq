module LSU_ysyx( // ID = 1

    input               clk,
    input               reset,

    // lsu ctrl
    input   [31:0]      lsu_addr, // 内存操作地址
    input   [31:0]      lsu_data, // 写内存数据
    input   [1:0]       lsu_mode, // 00不访存，01 load，11 store，10 mdata
    input   [2:0]       lsu_op,   // memop,指示字节
    
    // pc_reg
    input   [31:0]      Next_pc,
    
    // reg ctrl
    input   [4:0]       Rw,
    input   [31:0]      result,
    input               regwr,
    
    // pc_reg
    output  [31:0]      Next_pc_out,
    
    // reg ctrl
    output  [4:0]       Rw_out,
    output  [31:0]      result_out,
    output              regwr_out,


    input               lsu_valid,
    output              lsu_ready,

    input               wbu_ready,
    output              wbu_valid, // 向wbu模块发

    // // interface to SRAM
    // // Address Read
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

    // 
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

    reg     [3:0]       current_state;
    reg     [3:0]       next_state;

    localparam IDLE             = 0;
    localparam WAIT_LSUVALID    = 1;
    localparam WAIT_ARREADY     = 2;
    localparam WAIT_RVALID      = 3;
    localparam WAIT_AWREADY     = 4;
    localparam WAIT_WREADY      = 5;
    localparam WAIT_BVALID      = 6;
    localparam WAIT_WBUREADY    = 7;
    localparam MEM_BRANCH       = 8;

    reg     [31:0]      rdata_r;
    reg     [1:0]       rresp_r;
    reg     [1:0]       bresp_r;

    // 
    always @(*) begin
        if(rresp_r != 2'b00) begin
            $display("LSU read error\n");
        end
        else begin

        end
    end

    always @(*) begin
        if(bresp_r != 2'b00) begin
            $display("LSU write error\n");
        end
        else begin
            
        end
    end


    reg     [1:0]       lsu_mode_r;
    reg     [2:0]       memop_r;
    reg     [31:0]      Addr_r;
    reg     [31:0]      DataIn_r;

    reg     [31:0]      Next_pc_r;
    
    // reg ctrl
    reg     [4:0]       Rw_r;
    reg     [31:0]      result_r; // alu result
    reg                 regwr_r; 
    reg     [31:0]      master_wdata_r;


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
                next_state = WAIT_LSUVALID;
            end

            WAIT_LSUVALID: begin
                if(lsu_valid == 1'b1) begin
                    next_state = MEM_BRANCH;
                end
                else begin
                    next_state = WAIT_LSUVALID;
                end
            end

            MEM_BRANCH: begin
                if(lsu_mode_r == 2'b11) begin // write
                    next_state = WAIT_AWREADY;
                end
                else if(lsu_mode_r == 2'b01) begin // read
                    next_state = WAIT_ARREADY;
                end
                else begin
                    next_state = WAIT_WBUREADY;
                end
            end

            WAIT_ARREADY: begin
                if(master_arready == 1'b1) begin
                    next_state = WAIT_RVALID;
                end
                else begin
                    next_state = WAIT_ARREADY;
                end
            end

            WAIT_RVALID: begin
                if(master_rvalid == 1'b1) begin
                    next_state = WAIT_WBUREADY;
                end
                else begin
                    next_state = WAIT_RVALID;
                end
            end

            WAIT_WBUREADY: begin // 向wbu传数据
                if(wbu_ready == 1'b1) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = WAIT_WBUREADY;
                end
            end

            WAIT_AWREADY: begin
                if(master_awready == 1'b1) begin
                    next_state = WAIT_WREADY;
                end
                else begin
                    next_state = WAIT_AWREADY;
                end
            end

            WAIT_WREADY: begin
                if(master_wready == 1'b1) begin
                    next_state = WAIT_BVALID;
                end
                else begin
                    next_state = WAIT_WREADY;
                end
            end

            WAIT_BVALID: begin
                if(master_bvalid == 1'b1) begin
                    next_state = WAIT_WBUREADY;               
                end
                else begin
                    next_state = WAIT_BVALID;
                end
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    reg     [3:0]               m_wstrb_r;
    assign  master_wstrb        = m_wstrb_r;
    assign  master_arburst      = 2'b10;

    reg     [31:0]              r_data;

    // read data
    always @(*) begin

        case(memop_r)
            3'b000: begin // lb
                case(Addr_r[1:0])
                    2'b00: r_data = {{24{rdata_r[7]}}, rdata_r[7:0]};
                    2'b01: r_data = {{24{rdata_r[15]}}, rdata_r[15:8]};
                    2'b10: r_data = {{24{rdata_r[23]}}, rdata_r[23:16]};
                    2'b11: r_data = {{24{rdata_r[31]}}, rdata_r[31:24]};
                endcase
            end
            
            3'b001: begin // lh
                case(Addr_r[1:0])
                    2'b00: r_data = {{16{rdata_r[15]}}, rdata_r[15:0]}; // 0
                    2'b10: r_data = {{16{rdata_r[31]}}, rdata_r[31:16]}; // 2
                    default: r_data = 32'h0; // 不会出现
                endcase
            end

            3'b010: begin // lw
                r_data = rdata_r;
            end

            3'b100: begin // lbu
                case(Addr_r[1:0])
                    2'b00: r_data = {{24'b0}, rdata_r[7:0]};
                    2'b01: r_data = {{24'b0}, rdata_r[15:8]};
                    2'b10: r_data = {{24'b0}, rdata_r[23:16]};
                    2'b11: r_data = {{24'b0}, rdata_r[31:24]};
                endcase
            end

            3'b101: begin // lhu
                case(Addr_r[1:0])
                    2'b00: r_data = {{16'b0}, rdata_r[15:0]};  // 0
                    2'b10: r_data = {{16'b0}, rdata_r[31:16]}; // 2
                    default: r_data = 32'h0; // 不会出现
                endcase
            end

            default: begin
                r_data = 32'h0000;
            end
        endcase
        
    end

    // read data
    // always @(*) begin

    //     case(memop_r)
    //         3'b000: begin // lb
    //             r_data = {{24{rdata_r[7]}}, rdata_r[7:0]};
    //         end
            
    //         3'b001: begin // lh
    //             r_data = {{16{rdata_r[15]}}, rdata_r[15:0]}; 
    //         end

    //         3'b010: begin // lw
    //             r_data = rdata_r;
    //         end

    //         3'b100: begin // lbu
    //             r_data = {{24'b0}, rdata_r[7:0]};
    //         end

    //         3'b101: begin // lhu
    //             r_data = {{16'b0}, rdata_r[15:0]};  // 0
    //         end

    //         default: begin
    //             r_data = 32'h0000;
    //         end
    //     endcase
        
    // end



    reg     [2:0]       master_arsize_r;
    assign  master_arsize       = master_arsize_r;

    // read arsize
    always @(*) begin

        case(memop_r)
            3'b000: begin // lb
                master_arsize_r = 3'b000; // 1byte
            end
            
            3'b001: begin // lh
                master_arsize_r = 3'b001; // 2bytes
            end

            3'b010: begin // lw
                master_arsize_r = 3'b010; // 4bytes
            end

            3'b100: begin // lbu
                master_arsize_r = 3'b000;
            end

            3'b101: begin // lhu
                master_arsize_r = 3'b001;
            end

            default: begin
                master_arsize_r = 3'b010;
            end
        endcase
    end

    // write
    always @(*) begin

        case(memop_r)
            3'b000: begin // sb
                // m_wstrb_r = 4'b0001;
                case(Addr_r[1:0])
                    2'b00: m_wstrb_r = 4'b0001;
                    2'b01: m_wstrb_r = 4'b0010;
                    2'b10: m_wstrb_r = 4'b0100;
                    2'b11: m_wstrb_r = 4'b1000;
                endcase
            end

            3'b001: begin // sh
                // m_wstrb_r = 4'b0011;
                case(Addr_r[1:0])
                    2'b00: m_wstrb_r = 4'b0011;
                    2'b10: m_wstrb_r = 4'b1100;
                    default: m_wstrb_r = 4'b0000;
                endcase
            end

            3'b010: begin // sw
                m_wstrb_r = 4'b1111;
            end

            default: begin
                m_wstrb_r = 4'b0000;
            end
        endcase
    end

    // assign  master_wdata_r = DataIn_r;

    always @(*) begin

        case(memop_r)
            3'b000: begin // sb
                case(Addr_r[1:0])
                    2'b00: master_wdata_r = DataIn_r;
                    2'b01: master_wdata_r = {DataIn_r[23:0], 8'h00};
                    2'b10: master_wdata_r = {DataIn_r[15:0], 16'h00};
                    2'b11: master_wdata_r = {DataIn_r[7:0], 24'h00};
                endcase
            end

            3'b001: begin // sh
                case(Addr_r[1:0])
                    2'b00: master_wdata_r = DataIn_r;
                    2'b10: master_wdata_r = {DataIn_r[15:0], 16'h00};
                    default: master_wdata_r = 32'h0000;
                endcase
            end

            3'b010: begin // sw
                master_wdata_r = DataIn_r;
            end

            default: begin
                master_wdata_r = 32'h0000;
            end
        endcase
    end



    // AXI_lite
    assign  lsu_ready           = (current_state == WAIT_LSUVALID) ? 1'b1 : 1'b0;
    // 传araddr  
    assign  master_arvalid      = (current_state == WAIT_ARREADY) ? 1'b1 : 1'b0;
    assign  master_araddr       = Addr_r;
    assign  master_arlen        = 8'h00;
    assign  master_arid         = 4'h1;
 
    assign  master_rready       = (current_state == WAIT_RVALID) ? 1'b1 : 1'b0;

    // 传awaddr 
    assign  master_awvalid      = (current_state == WAIT_AWREADY) ? 1'b1 : 1'b0;
    assign  master_awaddr       = {Addr_r[31:2], 2'b00};
    assign  master_awid         = 4'h1;
    assign  master_awburst      = 2'b01;

    // 传wdata
    assign  master_wvalid       = (current_state == WAIT_WREADY) ? 1'b1 : 1'b0;
    assign  master_wdata        = master_wdata_r;
    assign  master_wlast        = (current_state == WAIT_WREADY) ? 1'b1 : 1'b0;
    assign  master_awlen        = 8'h00;
    assign  master_awsize       = 3'b010;
    //
    assign  master_bready       = (current_state == WAIT_BVALID) ? 1'b1 : 1'b0;
    assign  wbu_valid           = (current_state == WAIT_WBUREADY) ? 1'b1 : 1'b0;

    assign  Next_pc_out         = Next_pc_r;

    assign  Rw_out              = Rw_r;
    assign  result_out          = (lsu_mode_r == 2'b01) ? r_data : result_r;    
    assign  regwr_out           = regwr_r;


    always @(posedge clk or posedge reset) begin // 从EXU接收mem操作数据
        if(reset == 1'b1) begin
            lsu_mode_r      <= 2'b00;
            memop_r         <= 3'b0000;
            Addr_r          <= 32'h00000000;
            DataIn_r        <= 32'h00000000;

            Next_pc_r       <= 0;       
            Rw_r            <= 0;   
            result_r        <= 0;       
            regwr_r         <= 0;   
        end
        else begin
            if(lsu_valid == 1'b1 && lsu_ready == 1'b1) begin
                lsu_mode_r      <= lsu_mode;
                memop_r         <= lsu_op;
                Addr_r          <= lsu_addr;
                DataIn_r        <= lsu_data;

                Next_pc_r       <= Next_pc;
                Rw_r            <= Rw;
                result_r        <= result;
                regwr_r         <= regwr;
            end
            else begin
            end
        end
    end

    always @(posedge clk or posedge reset) begin // 从SRAM收数据
        if(reset == 1'b1) begin
            rdata_r         <= 32'hffffffff;
            rresp_r         <= 2'b00;
        end
        else begin
            if(master_rready == 1'b1 && master_rvalid == 1'b1)begin
                rdata_r         <= master_rdata;
                rresp_r         <= master_rresp;
            end
            else begin
            end
        end
    end

    always @(posedge clk or posedge reset) begin // 从SRAM收写内存反馈
        if(reset == 1'b1) begin
            bresp_r          <= 2'b00;
        end
        else begin
            if(master_bvalid == 1'b1 && master_bready == 1'b1)begin
                bresp_r         <= master_bresp;
            end
            else begin
            end
        end
    end



endmodule
