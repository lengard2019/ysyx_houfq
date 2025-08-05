module RegisterFile #(ADDR_WIDTH = 1, DATA_WIDTH = 1) (
  input clk,
  input [DATA_WIDTH-1:0] busW, //写寄存器数据
  input [ADDR_WIDTH-1:0] Ra, //地址，5位
  input [ADDR_WIDTH-1:0] Rb,
  input [ADDR_WIDTH-1:0] Rw, //rd
  input Regwr, // 写使能

  output [DATA_WIDTH-1:0] busA, //两个输出的寄存器数值
  output [DATA_WIDTH-1:0] busB

);
  reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:0]; // 2^ADDR_WIDTH
  
  always @(posedge clk) begin
    if (Regwr && Rw != 0) rf[Rw] <= busW;
  end

  reg [DATA_WIDTH-1:0] busA_r;
  reg [DATA_WIDTH-1:0] busB_r;

  assign busA = busA_r;
  assign busB = busB_r;

  always@(*) begin
    if(Ra == 0)begin
      busA_r = 0;
    end
    else begin
      busA_r = rf[Ra];
    end
  end

  always@(*) begin
    if(Rb == 0)begin
      busB_r = 0;
    end
    else begin
      busB_r = rf[Rb];
    end
  end



  
  
endmodule
