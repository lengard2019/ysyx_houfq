import "DPI-C" function int pmem_read_v(input int addr, input int len);
import "DPI-C" function void pmem_write_v(
  input int addr, input int len, input int data);

module Data_mem(
    input           clk,

    input   [31:0]  Addr,
    input   [2:0]   MemOp,
    input   [31:0]  mRegData,
    input   [1:0]   MemtoReg,
    input   [31:0]  DataIn,
    input           Wren,
    output  [31:0]  busW
);

    reg [31:0]  rdata;
    reg [31:0]  DataOut;  
    reg [31:0]  addr_r;

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

    always @(*) begin // load 需要延迟一个 difftest
        if(MemtoReg == 2'b01) begin
            case (MemOp)
                3'b000: begin // lb
                    addr_r = Addr;
                    rdata = pmem_read_v(addr_r, 1);
                    DataOut = {{24{rdata[7]}}, rdata[7:0]};
                end
                3'b100: begin // lbu
                    addr_r = Addr;
                    rdata = pmem_read_v(addr_r, 1);
                    DataOut = rdata;
                end
                3'b001: begin // lh
                    addr_r = Addr;
                    rdata = pmem_read_v(addr_r, 2);
                    DataOut = {{16{rdata[15]}}, rdata[15:0]};
                end
                3'b101: begin // lhu
                    addr_r = Addr;
                    rdata = pmem_read_v(addr_r, 2);
                    DataOut = rdata;
                end
                3'b010: begin // lw
                    addr_r = Addr;
                    rdata = pmem_read_v(addr_r, 4);
                    DataOut = rdata;
                end
                default begin
                    addr_r = 32'h00000000;
                    rdata = 32'h00000000;
                    DataOut = 32'h00000000;
                end
            endcase
        end
        else begin
            addr_r = 32'h00000000;
            rdata = 32'h00000000;
            DataOut = 32'h00000000;
        end
    end

    MuxKeyWithDefault #(3, 2, 32) u_busw(
        busW,
        MemtoReg,
        32'h00000000,
        {
            2'b00, Addr,
            2'b01, DataOut,
            2'b10, mRegData
        }
    );

endmodule
