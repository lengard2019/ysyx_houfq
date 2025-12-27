#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../obj_dir/VSRAM.h"
#include "svdpi.h"
#include "VSRAM__Dpi.h"
#include <stdint.h>
#include <time.h>

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

static VSRAM* top;

static uint32_t pmem[16] = {0x00000001, 0x00000002, 0x00000003, 0x00000004, 0x00000005, 0x00000006, 0x00000007, 0x00000008,
                            0x00000009, 0x00000009, 0x00000009, 0x00000009, 0x00000009, 0x00000009, 0x00000009, 0x00000009 };

void step_and_dump_wave(){
    top->clk = !top->clk; // 翻转时钟
    top->eval();
    contextp->timeInc(5);
    tfp->dump(contextp->time());
}

void sim_init(){
    contextp = new VerilatedContext;

    top = new VSRAM;
    contextp->traceEverOn(true);
    
    tfp = new VerilatedVcdC;
    top->trace(tfp, 5);
    tfp->open("SRAM.vcd");

    // init
    top->clk = 1;
    top->reset = 1;
    top->s_araddr = 0x00000000;
    top->s_arvalid = 0;
    top->s_rready = 0;

    top->s_awaddr = 0x00000000;
    top->s_awvalid = 0;
    top->s_wdata = 0x00000000;
    top->s_wstrb = 0;
    top->s_wvalid = 0;
    top->s_bready = 0;

    for (int i = 0; i < 4; i++){
        step_and_dump_wave();
    }

    top->reset = 0;
    top->s_awaddr = 0x00000000;
    step_and_dump_wave(); // 下降沿
    // top->eval();
}

void sim_exit(){
    step_and_dump_wave();
    tfp->close();
    printf("Simulation completed!\n");
}

int pmem_read_v(int addr, int len){
    if(len == 4){
        return (int)pmem[addr];
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
        pmem[addr] = data_r;
    }
}


// int main() {

//     sim_init();

//     srand(time(0));

//     top->s_arvalid = 1;
//     top->s_araddr  = 0x00000000;
//     top->s_rready  = 0;
//     for (int i = 0; i < 80; i ++){

//         // if(i == 30){
//         //     top->s_arvalid  = 1;
//         // }
//         // if(i == 40){
//         //     top->s_rready  = 1;
//         // }

//         if(i == 10){
//             top->s_rready  = 1;
//         }

//         step_and_dump_wave(); // 上升沿

        
//         // top->s_arvalid = 1;
//         step_and_dump_wave(); // 下降沿

//         if(top->s_rvalid == 1){
//             top->s_araddr = top->s_araddr + 1;
//         }
//     }

//     sim_exit();
// }


// top->s_awaddr = 0x00000000;
// top->s_awvalid = 0;
// top->s_wdata = 0x00000000;
// top->s_wstrb = 0;
// top->s_wvalid = 0;
// top->s_bready = 0;

int main() {

    sim_init();

    srand(time(0));

    top->s_awvalid  = 1;
    top->s_awaddr   = 2;
    top->s_wdata    = 10;
    top->s_wstrb    = 15;
    top->s_wvalid   = 1;
    top->s_bready   = 1;

    for (uint32_t i = 0; i < 20; i ++){
        
        // top->s_awvalid  = 1;
        // top->s_awaddr   = i;
        // top->s_wdata    = i + 10;
        // top->s_wstrb    = 15;
        // top->s_wvalid   = 1;
        // top->s_bready   = 1;

        step_and_dump_wave(); // 上升沿
        step_and_dump_wave(); // 下降沿
        
        
    }

    printf("%d\n", pmem[2]);

    sim_exit();
}
