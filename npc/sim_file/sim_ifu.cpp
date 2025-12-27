#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../obj_dir/Vcpu_top.h"
#include "svdpi.h"
#include "Vcpu_top__Dpi.h"
#include <stdint.h>
#include <time.h>

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

static Vcpu_top* top;

// static uint32_t pmem[16] = {0x00000001, 0x00000002, 0x00000003, 0x00000004, 0x00000005, 0x00000006, 0x00000007, 0x00000008,
//                             0x00000009, 0x00000009, 0x00000009, 0x00000009, 0x00000009, 0x00000009, 0x00000009, 0x00000009 };


static uint32_t pmem [] = {
    0x00000297,  // auipc t0,0
    0x00028823,  // sb  zero,16(t0)
    0x0102c503,  // lbu a0,16(t0)
    0x00100073,  // ebreak (used as nemu_trap)
    0xdeadbeef,  // some data
    0x00000297,  // auipc t0,0
    0x00028823,  // sb  zero,16(t0)
    0x0102c503,  // lbu a0,16(t0)
    0x00100073,  // ebreak (used as nemu_trap)
    0xdeadbeef,  // some data
    0x00000297,  // auipc t0,0
    0x00028823,  // sb  zero,16(t0)
    0x0102c503,  // lbu a0,16(t0)
    0x00100073,  // ebreak (used as nemu_trap)
    0xdeadbeef,  // some data
    0x00000297,  // auipc t0,0
    0x00028823,  // sb  zero,16(t0)
    0x0102c503,  // lbu a0,16(t0)
    0x00100073,  // ebreak (used as nemu_trap)
    0xdeadbeef,  // some data
};


void step_and_dump_wave(){
    top->clk = !top->clk; // 翻转时钟
    top->eval();
    contextp->timeInc(5);
    tfp->dump(contextp->time());
}

void sim_init(){
    contextp = new VerilatedContext;

    top = new Vcpu_top;
    contextp->traceEverOn(true);
    
    tfp = new VerilatedVcdC;
    top->trace(tfp, 10);
    tfp->open("IFU_ysyx.vcd");

    // init
    top->clk = 1;
    top->reset = 1;

    for (int i = 0; i < 4; i++){
        step_and_dump_wave();
    }

    top->reset = 0;
    step_and_dump_wave(); // 下降沿

}

void sim_exit(){
    step_and_dump_wave();
    tfp->close();
    printf("Simulation completed!\n");
}

int pmem_read_v(int addr, int len){
    if(len == 4){
        return (int)pmem[addr - 0x80000000];
    }
    else{
        return -1;
    }
}

int rand_v(){
    return rand() % 8 + 1;
}

void pmem_write_v(int addr, int wmask, int data){
    uint32_t data_r = (uint32_t)data;
    if(wmask == 15){
        pmem[addr - 0x80000000] = data_r;
    }
}


int main() {

    sim_init();

    srand(time(0));

    top->pc = 0x80000000;
    top->pc_valid  = 1;
    top->decode_ready  = 1;
    for (int i = 0; i < 80; i ++) {

        // if(i == 10){
        //     top->s_rready  = 1;
        // }

        step_and_dump_wave(); // 上升沿

        
        // top->s_arvalid = 1;
        step_and_dump_wave(); // 下降沿

        if(top->decode_valid == 1){
            top->pc = top->pc + 1;
        }
    }

    sim_exit();
}