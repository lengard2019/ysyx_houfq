module Nextpc_ysyx(

    input [31:0]    imm,
    input [31:0]    pc,
    input [31:0]    rs1,

    input [2:0]     branch,
    input           less,
    input           zero,
    input [31:0]    mretPc,
    input           mpcWr,

    output [31:0]   Next_pc
);

    wire            PCAsrc;
    wire            PCBsrc;

    Branch_Cond u_Branch_Cond(
        .branch 	(branch     ),
        .less   	(less       ),
        .zero   	(zero       ),
        .PCAsrc 	(PCAsrc     ),
        .PCBsrc 	(PCBsrc     )
    );

    PC_ysyx u_PC_ysyx(
        .imm    	(imm      ),
        .pc     	(pc       ),
        .mpcWr  	(mpcWr    ),
        .mretPc 	(mretPc   ),
        .rs1    	(rs1      ),
        .PCAsrc 	(PCAsrc   ),
        .PCBsrc 	(PCBsrc   ),
        .result 	(Next_pc  )
    );


endmodule
