module Data_mem(
    input           clk,

    // input   [31:0]  Addr,
    // input   [2:0]   MemOp,
    // input   [31:0]  result,
    // input           MemtoReg,
    input   [31:0]  DataIn,
    input           Wren,
    // input   [31:0]  Datard,

    // output  [31:0]  busW,
    output reg  [31:0]  Datawr
);

    // reg  [31:0]  DataOut;

    Reg #(32, 32'h0) u_memwr // write
    (
        clk,
        1'b0,
        DataIn,
        Datawr,
        Wren
    );

    // always @(negedge clk) begin // read
    //     DataOut <= Datard;
    // end

    // output declaration of module MuxKey
    // wire [DATA_LEN-1:0] out;
    
    // MuxKey #(2, 1, 32)u_MuxKey(
    //     busW,
    //     MemtoReg,
    //     {
    //         1'b0, result,
    //         1'b1, DataOut
    //     }
    // );
    
    


endmodule
