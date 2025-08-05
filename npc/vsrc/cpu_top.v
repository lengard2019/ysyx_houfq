module cpu_top(
    input           clk,
    input           rst,
    input   [31:0]  inst,

    output  [31:0]  NextPc,     // 读指令
    // output          MemtoReg,
    output  [2:0]   ExtOp
);

    wire    [4:0]   Ra;
    wire    [4:0]   Rb;
    wire    [4:0]   Rw;

    reg     [31:0]  instr;

    assign Ra = instr[19:15];
    assign Rb = instr[24:20];
    assign Rw = instr[11:7];


    // wire    [2:0]    ExtOp; 
    wire    [31:0]   imm;
    wire             RegWr;
    // wire    [2:0]    Branch;
    wire             MemtoReg;
    wire             MemWr;
    wire    [2:0]    MemOp;
    wire             ALUAsrc;
    wire    [1:0]    ALUBsrc;
    wire    [3:0]    ALUctr;          
    

    wire    [2:0]   branch;
    wire            less;
    wire            zero;
    wire            PCAsrc;
    wire            PCBsrc;

    wire [31:0] busW;
    
    Data_mem u_Data_mem(
        .clk      	(clk       ),
        .Addr     	(result    ),
        .MemOp    	(MemOp     ),
        .MemtoReg 	(MemtoReg  ),
        .DataIn   	(rs2       ),
        .Wren     	(MemWr     ),
        .busW     	(busW      )
    );
    
    RegisterFile #(5, 32) u_register
    (
        .clk            (clk),
        .busW           (busW),
        .Ra             (Ra),
        .Rb             (Rb),
        .Rw             (Rw),
        .Regwr          (RegWr),
        .busA           (rs1),
        .busB           (rs2)
    );

    IDU_ysyx u_idu
    (
        .instr          (instr),         
        .ExtOp          (ExtOp),              
        .imm            (imm),
        .RegWr          (RegWr),
        .Branch         (branch),
        .MemtoReg       (MemtoReg),
        .MemWr          (MemWr),
        .MemOp          (MemOp),
        .ALUAsrc        (ALUAsrc),
        .ALUBsrc        (ALUBsrc),
        .ALUctr         (ALUctr)
    );

    Branch_Cond u_branch
    (
        .branch         (branch ),
        .less           (less   ),
        .zero           (zero   ),
        .PCAsrc         (PCAsrc ),
        .PCBsrc         (PCBsrc )
    );

    // output declaration of module ALU_ysyx
    // wire less;
    // wire zero;
    wire [31:0] result;
    wire [31:0] rs1;
    wire [31:0] rs2;

    
    ALU_ysyx u_ALU_ysyx(
        .pc      	    (pc       ),
        .rs1     	    (rs1      ),
        .rs2     	    (rs2      ),
        .imm     	    (imm      ),
        .ALUctr  	    (ALUctr   ),
        .ALUAsrc 	    (ALUAsrc  ),
        .ALUBsrc 	    (ALUBsrc  ),
        .less    	    (less     ),
        .zero    	    (zero     ),
        .result  	    (result   )
    );

    // output declaration of module PC_ysyx
    wire [31:0] pc;
    
    PC_ysyx u_PC_ysyx(   //计算NextPc
        .imm    	    (imm     ),
        .pc     	    (pc      ),
        .rs1    	    (rs1     ),
        .PCAsrc 	    (PCAsrc  ),
        .PCBsrc 	    (PCBsrc  ),
        .result 	    (NextPc  )
    );

    // assign pc = NextPc;

    Reg #(32, 32'h80000000) u_nextpc // pc reg
    (
        .clk            (clk),
        .rst            (rst),
        .din            (NextPc),
        .dout           (pc),
        .wen            (1'b1)
    );

    // output declaration of module Reg
    // reg [WIDTH-1:0] dout;
    
    Reg #(32, 32'hffffffff) u_Reg(
        .clk  	        (clk    ),
        .rst  	        (rst    ),
        .din  	        (inst   ),
        .dout 	        (instr  ),
        .wen  	        (1'b1   )
    );


    
endmodule
