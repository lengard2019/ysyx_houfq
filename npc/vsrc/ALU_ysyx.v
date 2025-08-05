module ALU_ysyx(
    input   [31:0]  pc,
    input   [31:0]  rs1,
    input   [31:0]  rs2,
    input   [31:0]  imm,
    input   [3:0]   ALUctr,
    input           ALUAsrc,
    input   [1:0]   ALUBsrc,

    output          less,
    output          zero,
    output  [31:0]  result

);

    // reg     [31:0]  rs2x; // -rs2
    // assign rs2x = (32'hffffffff ^ rs2 ) + {32'h00000001};

    reg     [31:0]  dataA;
    reg     [31:0]  dataB;

    reg             carry;
    // reg             of;

    reg     [31:0]  result_r;
    reg             overflow;
    reg             less_r;
    reg             zero_r;
    wire            is_compare;

    assign is_compare = (ALUctr == 4'b1010 || ALUctr == 4'b0010);

    assign result = ((is_compare == 1'b1) ? {31'b0, less_r} : result_r);
    assign less = less_r;
    assign zero = zero_r;


    MuxKey #(2, 1, 32) u_mux1(
        dataA,
        ALUAsrc,
        {
            1'b1, pc,
            1'b0, rs1
        }
    );

    MuxKeyWithDefault #(3, 2, 32) u_mux2(
        dataB,
        ALUBsrc,
        32'h00000000,
        {
            2'b00, rs2,
            2'b01, imm,
            2'b10, 32'h00000004
        }
    );

    reg     [32:0]  dataB_x;
    reg     [31:0]  dataB_shift;

    // assign dataB_x = (32'hffffffff ^ dataB ) + {32'h00000001}; // sub dataB
    // assign dataB_shift = {27'b0, dataB[4:0]};

    // always @(result_r) begin
    //     if(ALUctr == 4'b1010 || ALUctr == 4'b0010)begin
    //         result <= {31'b0, less_r};
    //     end
    //     else begin
    //         result <= result_r;
    //     end
    // end
    

    always @(dataA or dataB or ALUctr) begin
        case (ALUctr)
            4'b0000: begin //add.
                dataB_x = 33'b0;
                dataB_shift = 32'b0;
                {carry,result_r} = {1'b0, dataA} + {1'b0, dataB};
                overflow = 1'b0;
                less_r = 1'b0;
                zero_r = ~(| result_r);
            end
            4'b1000: begin // sub.
                dataB_x = (33'h1ffffffff ^ {1'b0, dataB}) + {33'h00000001};// 应该现扩展位数再加减
                dataB_shift = 32'b0;
                {carry,result_r} = {1'b0, dataA} + dataB_x;
                overflow = 1'b0;
                less_r = 1'b0;
                zero_r = ~(| result_r);
            end
            4'b0011: begin // lui
                dataB_x = 33'b0;
                dataB_shift = 32'b0;
                {carry,result_r} = {1'b0, dataB};
                overflow = 1'b0;
                less_r = 1'b0;
                zero_r = ~(| result_r);
            end
            4'b1010: begin // unsigned compare
                dataB_x = (33'h1ffffffff ^ {1'b0, dataB}) + {33'h00000001};// 应该现扩展位数再加减
                dataB_shift = 32'b0;
                {carry,result_r} = {1'b0, dataA} + dataB_x;
                overflow = (dataA[31] == dataB[31]) & (result_r[31] ^ dataA[31]);
                less_r = carry;
                zero_r = ~(| result_r);
            end
            4'b0010: begin // signed compare
                dataB_x = (33'h1ffffffff ^ {1'b0, dataB}) + {33'h00000001};
                dataB_shift = 32'b0;
                {carry,result_r} = {1'b0, dataA} + dataB_x;
                overflow = (dataA[31] ^ dataB[31]) & (result_r[31] ^ dataA[31]);
                less_r = overflow ? ~result_r[31] : result_r[31];
                // less_r = $signed(dataA) < $signed(dataB);
                zero_r = ~(| result_r);
            end
            4'b0100: begin // xor
                dataB_x = 33'b0;
                dataB_shift = 32'b0;
                {carry,result_r} = {1'b0, dataA ^ dataB};
                overflow = 1'b0;
                less_r = 1'b0;
                zero_r = ~(| result_r);
            end
            4'b0110: begin // or
                dataB_x = 33'b0;
                dataB_shift = 32'b0;
                {carry,result_r} = {1'b0, dataA | dataB};
                overflow = 1'b0;
                less_r = 1'b0;
                zero_r = ~(| result_r);
            end
            4'b0111: begin // and
                dataB_x = 33'b0;
                dataB_shift = 32'b0;
                {carry,result_r} = {1'b0, dataA & dataB};
                overflow = 1'b0;
                less_r = 1'b0;
                zero_r = ~(| result_r);
            end
            4'b0001: begin // left
                dataB_x = 33'b0;
                dataB_shift = {27'b0, dataB[4:0]};
                {carry,result_r} = {1'b0, dataA << dataB_shift};
                overflow = 1'b0;
                less_r = 1'b0;
                zero_r = ~(| result_r);
            end
            4'b0101: begin // right_logic
                dataB_x = 33'b0;
                dataB_shift = {27'b0, dataB[4:0]};
                {carry,result_r} = {1'b0, dataA >> dataB_shift};
                overflow = 1'b0;
                less_r = 1'b0;
                zero_r = ~(| result_r);
            end
            4'b1101: begin // right_a
                dataB_x = 33'b0;
                dataB_shift = {27'b0, dataB[4:0]};
                {carry,result_r} = {1'b0, $signed(dataA) >>> dataB_shift};
                overflow = 1'b0;
                less_r = 1'b0;
                zero_r = ~(| result_r);
            end
            default begin
                {carry,result_r} = 33'b0;
                less_r = 1'b0;
                zero_r = 1'b0;
                dataB_shift = 32'b0;
                overflow = 1'b0;
                dataB_x = 33'b0;
            end
        endcase
    end

endmodule
