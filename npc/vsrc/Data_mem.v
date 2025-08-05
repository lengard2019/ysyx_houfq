import "DPI-C" function int pmem_read_v(input int addr, input int len);
import "DPI-C" function void pmem_write_v(
  input int addr, input int len, input int data);

module Data_mem(
    input           clk,

    input   [31:0]  Addr,
    input   [2:0]   MemOp,
    input           MemtoReg,
    input   [31:0]  DataIn,
    input           Wren,
    output  [31:0]  busW
);

    reg [31:0]  rdata;
    reg [31:0]  DataOut;  

    always @(posedge clk) begin
        if(Wren == 1'b1)begin
            case (MemOp)
                3'b000: begin // sb
                    pmem_write_v(Addr, 1, DataIn);
                end
                3'b001: begin // sh
                    pmem_write_v(Addr, 2, DataIn);
                end
                3'b010: begin // sw
                    pmem_write_v(Addr, 4, DataIn);
                end
                default begin
                    
                end
            endcase
        end
    end

    always @(*) begin
        if(MemtoReg == 1'b1) begin
            case (MemOp)
                3'b000: begin // lb
                    rdata = pmem_read_v(Addr, 1);
                    DataOut = {{24{rdata[7]}}, rdata[7:0]};
                end
                3'b100: begin // lbu
                    rdata = pmem_read_v(Addr, 1);
                    DataOut = rdata;
                end
                3'b001: begin // lh
                    rdata = pmem_read_v(Addr, 2);
                    DataOut = {{16{rdata[15]}}, rdata[15:0]};
                end
                3'b101: begin // lhu
                    rdata = pmem_read_v(Addr, 2);
                    DataOut = rdata;
                end
                3'b010: begin // lw
                    rdata = pmem_read_v(Addr, 4);
                    DataOut = rdata;
                end
                default begin
                    rdata = 32'h00000000;
                    DataOut = 32'h00000000;
                end
            endcase
        end
        else begin
            rdata = 32'h00000000;
            DataOut = 32'h00000000;
        end
    end

    assign busW = (MemtoReg == 1'b1) ? DataOut : Addr;

endmodule
