module WBU_ysyx(

    input               clk,
    input               reset,

    input               lsu_valid,
    output              lsu_ready,

    input               ifu_ready,
    output              ifu_valid,
    
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
    output              regwr_out
);

    reg     [1:0]       current_state;
    reg     [1:0]       next_state;

    reg     [31:0]      pc_r;

    assign  Next_pc_out         = pc_r;

    assign  Rw_out              = Rw;
    assign  result_out          = result;
    assign  regwr_out           = (current_state == WAIT_IFUREADY) ? regwr : 1'b0;

    localparam  IDLE                = 0;
    localparam  WAIT_LSUVALID       = 1;
    localparam  WAIT_IFUREADY       = 2;

    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1) begin
            current_state       <= WAIT_IFUREADY;
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
                    next_state = WAIT_IFUREADY;
                end
                else begin
                    next_state = WAIT_LSUVALID;
                end
            end

            WAIT_IFUREADY: begin
                if(ifu_ready == 1'b1) begin
                    next_state = IDLE;
                end
                else begin
                    next_state = WAIT_IFUREADY;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    assign  lsu_ready       = (current_state == WAIT_LSUVALID) ? 1'b1 : 1'b0;

    assign  ifu_valid       = (current_state == WAIT_IFUREADY) ? 1'b1 : 1'b0;

    // read wbu
    always @(posedge clk or posedge reset) begin
        if(reset == 1'b1) begin
            pc_r        <= 32'h30000000;
        end
        else begin
            if(lsu_valid == 1'b1 && lsu_valid == 1'b1) begin
                pc_r        <= Next_pc;
            end          
        end
    end

endmodule
