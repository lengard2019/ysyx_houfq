import "DPI-C" function int pmem_read_v(input int addr, input byte len);
import "DPI-C" function void pmem_write_v(input int addr, input byte wmask, input int data);
import "DPI-C" function int rand_v();

module SRAM(
    input               clk,
    input               reset,

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

    localparam IDLE             = 0;
    localparam WAIT_ARVALID     = 1;
    localparam DELAY            = 2;
    localparam WAIT_RLAST       = 3;

    localparam IDLE_W           = 4;
    localparam WAIT_AWVALID     = 5;
    localparam WAIT_WVALID      = 6;
    localparam WAIT_WDATA       = 7;
    localparam WAIT_BREADY      = 8;

    reg     [31:0]  data_r;


    reg     [3:0]   current_state;
    reg     [3:0]   next_state;

    reg     [31:0]  delay; 
    reg     [31:0]  delay_cnt;


    assign  io_slave_rlast  = 1'b0;
    assign  io_slave_rid    = 4'h0;
    assign  io_slave_bid    = 4'h0;

    // SRAM READ
    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end

    always @(*) begin

        case (current_state)
            IDLE: begin
                next_state = WAIT_ARVALID;
            end

            WAIT_ARVALID: begin
                if(io_slave_arvalid == 1'b1) begin
                    next_state = DELAY;
                end
                else begin
                    next_state = WAIT_ARVALID;
                end
            end

            DELAY: begin
                if(delay_cnt == delay) begin
                    next_state = WAIT_RLAST;
                end
                else begin
                    next_state = DELAY;
                end
            end

            WAIT_RLAST: begin
                if(io_slave_rready == 1'b1) begin // burst
                    next_state = IDLE;
                end
                else begin
                    next_state = WAIT_RLAST;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1)begin
            delay_cnt       <= 32'h00000000;
        end
        else begin
            case(next_state)

                IDLE: begin
                    delay_cnt       <= 32'h00000000;
                end

                DELAY: begin
                    delay_cnt       <= delay_cnt + 1'b1;
                end

                WAIT_RLAST: begin
                    delay_cnt       <= 32'h00000000;
                end

                default: begin
                    delay_cnt       <= 32'h00000000;
                end
            endcase
        end
    end


    // read r_addr
    always @ (posedge clk or posedge reset) begin 
        if(reset == 1'b1) begin
            data_r          <= 32'h00000000;
            delay           <= 32'h00000000;
        end
        else begin
            if(io_slave_arvalid == 1'b1 && io_slave_arready == 1'b1) begin // 握手，传输数据
                data_r          <= pmem_read_v({io_slave_araddr[31:2], 2'b00}, {5'b00000, io_slave_arsize});
                delay           <= rand_v();
            end
            else begin
            end
        end
    end

    assign io_slave_arready     = (current_state == WAIT_ARVALID) ? 1'b1 : 1'b0;
    assign io_slave_rvalid      = (current_state == WAIT_RLAST) ? 1'b1 : 1'b0;
    assign io_slave_rdata       = (current_state == WAIT_RLAST) ? data_r : 32'hffffffff;
    assign io_slave_rresp       = (current_state == WAIT_RLAST) ? 2'b00 : 2'b11;


    reg     [3:0]   current_state_w;
    reg     [3:0]   next_state_w;

    reg     [31:0]  waddr_r;
    reg     [31:0]  delay_w; // int rand()
    reg     [31:0]  delay_cnt_w;


    // SDRAM WRITE
    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1) begin
            current_state_w <= IDLE_W;
        end
        else begin
            current_state_w <= next_state_w;
        end
    end

    always @(*) begin

        case (current_state_w)
            IDLE_W: begin
                next_state_w = WAIT_AWVALID;
            end

            WAIT_AWVALID: begin // 握手时s_wready_r应该置高
                if(io_slave_awvalid == 1'b1) begin
                    next_state_w = WAIT_WVALID;
                end
                else begin
                    next_state_w = WAIT_AWVALID;
                end
            end

            WAIT_WVALID: begin
                if(io_slave_wvalid == 1'b1) begin
                    next_state_w = WAIT_WDATA;
                end
                else begin
                    next_state_w = WAIT_WVALID;
                end
            end

            WAIT_WDATA: begin
                if(delay_cnt_w == delay_w) begin
                    next_state_w = WAIT_BREADY;
                end
                else begin
                    next_state_w = WAIT_WDATA;
                end
            end

            WAIT_BREADY: begin
                if(io_slave_bready == 1'b1) begin
                    next_state_w = IDLE;
                end
                else begin
                    next_state_w = WAIT_BREADY;
                end
            end
            
            default: begin
                next_state_w = IDLE_W;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1)begin
            delay_cnt_w     <= 32'h00000000;
        end
        else begin
            case(next_state_w)

                IDLE_W: begin
                    delay_cnt_w     <= 32'h00000000;
                end

                WAIT_WDATA: begin
                    delay_cnt_w     <= delay_cnt_w + 1'b1;
                end

                default: begin
                    delay_cnt_w     <= 32'h00000000;
                end
            endcase
        end
    end

    assign  io_slave_awready       = (current_state_w == WAIT_AWVALID) ? 1'b1 : 1'b0;
    assign  io_slave_wready        = (current_state_w == WAIT_WVALID) ? 1'b1 : 1'b0;
    assign  io_slave_bvalid        = (current_state_w == WAIT_BREADY) ? 1'b1 : 1'b0;
    assign  io_slave_bresp         = 2'b00;    

    
    // read w_addr
    always @ (posedge clk or posedge reset) begin 
        if(reset == 1'b1) begin
            waddr_r         <= 32'h00000000;
        end
        else begin
            if(io_slave_awready == 1'b1 && io_slave_awvalid == 1'b1) begin
                waddr_r         <= io_slave_awaddr;
            end
            else begin

            end 
        end
    end

    // write data
    always @ (posedge clk or posedge reset) begin // 握手，赋值一次，s_arready_r随即置零
        if(reset == 1'b1) begin
            delay_w         <= 32'h00000000;
        end
        else begin
            if(io_slave_wvalid == 1'b1 && io_slave_wready == 1'b1) begin
                pmem_write_v(waddr_r, {4'b000, io_slave_wstrb}, io_slave_wdata);
                delay_w         <= rand_v();
            end
            else begin

            end
        end        
    end

endmodule
