#include "Vcpu_top.h"  // Verilator 生成的模型头文件
#include "verilated.h"
#include "verilated_vcd_c.h"  // 用于生成波形文件
#include <iostream>
#include <paddr.h>
#include <common.h>

void init_monitor(int, char *[]);

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

// static vluint64_t time = 0;

static Vcpu_top* top;

void step_and_dump_wave(){
    top->clk = !top->clk; // 翻转时钟
    top->eval();
    contextp->timeInc(5);
    tfp->dump(contextp->time()); // 记录波形
}


void sim_init(){
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    top = new Vcpu_top;
    contextp->traceEverOn(true);
    top->trace(tfp, 20);
    tfp->open("cpu_top.vcd");
}

void sim_exit(){
    step_and_dump_wave();
    tfp->close();
}

static uint8_t MemLen(uint8_t memop){
    switch (memop)
    {
    case 0x00: return 1;
    case 0x01: return 2;
    case 0x02: return 4;
    case 0x04: return 1;
    case 0x05: return 2;
    default: assert(0);
    }
}



// void clock_driver(Vcpu_top* model, VerilatedVcdC* tfp, vluint64_t& time) {
//     model->clk = !model->clk;  // 翻转时钟
//     model->eval();
//     tfp->dump(time);  // 记录波形
//     time += 5;  // 增加仿真时间（假设时钟周期为 10 个单位，半周期为 5）
// };

int main(int argc, char** argv) {

    init_monitor(argc, argv);

    sim_init();

    // init
    top->clk = 1;
    top->rst = 1;
    top->NextPc = 0x80000000;
    top->busW = 0x00000000;

    for (int i = 0; i < 4; i++){
        step_and_dump_wave();
    }

    top->rst = 0;
    top->NextPc = 0x80000000;
    step_and_dump_wave();
    // top->eval();

    for(int i = 0; i < 100; i++){
      printf("81 addr = %08x\n", top->NextPc);
      top->inst = pmem_read(top->NextPc, 4); // 取指令
      printf("----> %08x\n", top->inst);
      
      step_and_dump_wave();  // 上升沿
      step_and_dump_wave();  // 下降沿


      if(top->MemtoReg == 0){
          top->busW = top->result;
      }
      else{
        if(top->MemOp < 4){
          top->busW = pmem_read(top->result, MemLen(top->MemOp));
        }
        else{
          if(MemLen(top->MemOp) == 1){
            SEXT(pmem_read(top->result, MemLen(top->MemOp)), 8);
          }
          else{
            SEXT(pmem_read(top->result, MemLen(top->MemOp)), 16);
          }
        }
      }

      if(top->MemWr == 1){
          pmem_write(top->result, MemLen(top->MemOp), top->Datawr);
      }
    }

    sim_exit();


    printf("Simulation completed!\n");
}