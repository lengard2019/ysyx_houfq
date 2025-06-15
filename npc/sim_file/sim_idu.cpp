#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../obj_dir/VIDU_ysyx.h"

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

static VIDU_ysyx* top;

void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}
void sim_init(){
  contextp = new VerilatedContext;
  tfp = new VerilatedVcdC;
  top = new VIDU_ysyx;
  contextp->traceEverOn(true);
  top->trace(tfp, 0);
  tfp->open("IDU_ysyx.vcd");
}

void sim_exit(){
  step_and_dump_wave();
  tfp->close();
}

int main() {
  sim_init();

  top->instr = 0x00000413; step_and_dump_wave();
  top->instr = 0x00009117; step_and_dump_wave();
  top->instr = 0xffc10113; step_and_dump_wave();
  top->instr = 0x1f8000ef; step_and_dump_wave();
  top->instr = 0x00008067; step_and_dump_wave();
  
                           
  
   sim_exit();
}