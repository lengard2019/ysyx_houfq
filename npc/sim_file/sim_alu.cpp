#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../obj_dir/VALU_ysyx.h"

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

static VALU_ysyx* top;

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}
void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  top = new VALU_ysyx;
  contextp->traceEverOn(true);
  top->trace(tfp, 0);
  tfp->open("ALU_ysyx.vcd");
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
}

int main() {
  sim_init();

  top->pc = 0x80000000; top->rs1 = 0x00000001; top->rs2 = 0x00000001; top->imm = 0x00000001; top->ALUctr = 0x00000000; top->ALUAsrc = 0x00000000; top->ALUBsrc = 0x00000000;
  step_and_dump_wave(); // add
  top->pc = 0x80000000; top->rs1 = 0x00000001; top->rs2 = 0x00000001; top->imm = 0x00000001; top->ALUctr = 0x00000008; top->ALUAsrc = 0x00000000; top->ALUBsrc = 0x00000000;
  step_and_dump_wave(); // sub
  top->pc = 0x80000000; top->rs1 = 0xffffffff; top->rs2 = 0x00000001; top->imm = 0x00000001; top->ALUctr = 0x00000002; top->ALUAsrc = 0x00000000; top->ALUBsrc = 0x00000000;
  step_and_dump_wave(); // sltu
  top->pc = 0x80000000; top->rs1 = 0xffffffff; top->rs2 = 0x00000001; top->imm = 0x00000001; top->ALUctr = 0x0000000A; top->ALUAsrc = 0x00000000; top->ALUBsrc = 0x00000000;
  step_and_dump_wave(); // slt

   sim_exit();
}