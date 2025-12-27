import "DPI-C" function int pmem_read_v(input int addr, input int len);
import "DPI-C" function void pmem_write_v(input int addr, input int wmask, input int data);
import "DPI-C" function int rand_v();

module SRAM(
    input           clk,
    input           reset,

    // slave AXI4
    // Address Read
    input   [31:0]  s_araddr,
    input           s_arvalid,
    output          s_arready,

    // Data Read 
    output  [31:0]  s_rdata,
    output  [1:0]   s_rresp,
    output          s_rvalid,
    input           s_rready,

    // Address Write
    input   [31:0]  s_awaddr,
    input           s_awvalid,
    output          s_awready,

    // Data Write
    input   [31:0]  s_wdata,
    input   [3:0]   s_wstrb, // mask 
    input           s_wvalid,
    output          s_wready,

    // Write error
    output  [1:0]   s_bresp,
    output          s_bvalid,
    input           s_bready

);

    localparam IDLE             = 0;
    localparam WAIT_ARVALID     = 1;
    localparam WAIT_DATA        = 2;
    localparam WAIT_RREADY      = 3;

    localparam IDLE_W           = 4;
    localparam WAIT_AWVALID     = 5;
    localparam WAIT_WVALID      = 6;
    localparam WAIT_WDATA       = 7;
    localparam WAIT_BREADY      = 8;

    reg     [31:0]  data_r;


    reg     [3:0]   current_state;
    reg     [3:0]   next_state;

    reg     [31:0]  delay; // int rand()
    reg     [31:0]  delay_cnt;


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
                if(s_arvalid == 1'b1) begin
                    next_state = WAIT_DATA;
                end
                else begin
                    next_state = WAIT_ARVALID;
                end
            end

            WAIT_DATA: begin
                if(delay_cnt == delay) begin
                    next_state = WAIT_RREADY;
                end
                else begin
                    next_state = WAIT_DATA;
                end
            end

            WAIT_RREADY: begin
                if(s_rready == 1'b1) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = WAIT_RREADY;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1)begin
            // s_rdata_r       <= 32'hffffffff;
            // s_rresp_r       <= 2'b00;
            // s_rvalid_r      <= 1'b0;
            delay_cnt       <= 32'h00000000;
        end
        else begin
            case(next_state)

                IDLE: begin
                    delay_cnt       <= 32'h00000000;
                    // s_rdata_r       <= 32'hffffffff;
                    // s_rvalid_r      <= 1'b0;
                end

                WAIT_ARVALID: begin
                    // s_rvalid_r      <= 1'b0;
                end

                WAIT_DATA: begin
                    delay_cnt       <= delay_cnt + 1'b1;
                    // s_rvalid_r      <= 1'b0;
                end

                WAIT_RREADY: begin
                    delay_cnt       <= 32'h00000000;
                    // s_rdata_r       <= data_r;
                    // s_rresp_r       <= 2'b00;
                    // s_rvalid_r      <= 1'b1;
                end

                default: begin
                    // s_rdata_r       <= 32'hffffffff;
                    // s_rresp_r       <= 2'b00;
                    // s_rvalid_r      <= 1'b0;
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
            if(s_arvalid == 1'b1 && s_arready == 1'b1) begin // 握手，传输数据
                data_r          <= pmem_read_v(s_araddr, 4);
                delay           <= rand_v();
            end
            else begin
            end
        end
    end

    assign s_arready    = (current_state == WAIT_ARVALID) ? 1'b1 : 1'b0;
    assign s_rvalid     = (current_state == WAIT_RREADY) ? 1'b1 : 1'b0;
    assign s_rdata      = (current_state == WAIT_RREADY) ? data_r : 32'hffffffff;
    assign s_rresp      = (current_state == WAIT_RREADY) ? 2'b00 : 2'b11;


    reg     [3:0]   current_state_w;
    reg     [3:0]   next_state_w;

    // reg             s_awready_r;
    // reg             s_wready_r;
    // reg     [1:0]   s_bresp_r;
    // reg             s_bvalid_r;

    reg     [31:0]  waddr_r;
    reg     [31:0]  delay_w; // int rand()
    reg     [31:0]  delay_cnt_w;

    // assign  s_awready       = s_awready_r;
    // assign  s_wready        = s_wready_r;
    // assign  s_bresp         = s_bresp_r;
    // assign  s_bvalid        = s_bvalid_r;

    // SRAM WRITE
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
                if(s_awvalid == 1'b1) begin
                    next_state_w = WAIT_WVALID;
                end
                else begin
                    next_state_w = WAIT_AWVALID;
                end
            end

            WAIT_WVALID: begin
                if(s_wvalid == 1'b1) begin
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
                if(s_bready == 1'b1) begin
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
            // s_bresp_r       <= 2'b00;
            // s_bvalid_r      <= 1'b0;
            delay_cnt_w     <= 32'h00000000;
        end
        else begin
            case(next_state_w)

                IDLE_W: begin
                    // s_bresp_r       <= 2'b00;
                    // s_bvalid_r      <= 1'b0;
                    delay_cnt_w     <= 32'h00000000;
                end

                WAIT_AWVALID: begin

                end
                
                WAIT_WVALID: begin
                end

                WAIT_WDATA: begin
                    delay_cnt_w     <= delay_cnt_w + 1'b1;
                end

                WAIT_BREADY: begin                    
                    // s_bresp_r       <= 2'b00;
                    // s_bvalid_r      <= 1'b1;
                end


                default: begin
                    // s_bresp_r       <= 2'b00;
                    // s_bvalid_r      <= 1'b0;
                    delay_cnt_w     <= 32'h00000000;
                end
            endcase
        end
    end

    assign  s_awready       = (current_state_w == WAIT_AWVALID) ? 1'b1 : 1'b0;
    assign  s_wready        = (current_state_w == WAIT_WVALID) ? 1'b1 : 1'b0;
    assign  s_bvalid        = (current_state_w == WAIT_BREADY) ? 1'b1 : 1'b0;
    assign  s_bresp         = 2'b00;    

    
    // read w_addr
    always @ (posedge clk or posedge reset) begin 
        if(reset == 1'b1) begin
            waddr_r         <= 32'h00000000;
            // s_awready_r     <= 1'b0;
        end
        else begin
            if(s_awready == 1'b1 && s_awvalid == 1'b1) begin
                waddr_r         <= s_awaddr;
                // s_awready_r     <= 1'b0;
            end
            else begin
                // if(next_state_w == IDLE_W) begin
                //     s_awready_r     <= 1'b1;
                // end
            end 
        end
    end

    // write data
    always @ (posedge clk or posedge reset) begin // 握手，赋值一次，s_arready_r随即置零
        if(reset == 1'b1) begin
            delay_w         <= 32'h00000000;
            // s_wready_r      <= 1'b0;
        end
        else begin
            if(s_wvalid == 1'b1 && s_wready == 1'b1) begin
                pmem_write_v(waddr_r, s_wstrb, s_wdata);
                delay_w         <= rand_v();
                // s_wready_r      <= 1'b0;
            end
            else begin

            end
        end        
    end

endmodule
