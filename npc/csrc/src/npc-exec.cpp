#include "Vcpu_top.h"  // Verilator 生成的模型头文件
#include "verilated.h"
#include "Vcpu_top___024root.h"
#include "verilated_vcd_c.h"  // 用于生成波形文件
#include <paddr.h>
// #include <reg.h>
#include <common.h>
#include <locale.h>
#include <cpu/cpu.h>
#include <cpu/difftest.h>


#define MAX_INST_TO_PRINT 10
// void init_monitor(int, char *[]);

NPC_state cpu = {};

uint64_t g_nr_guest_inst = 0;
static uint64_t g_timer = 0; // unit: us
static bool g_print_step = false;
#ifdef CONFIG_DIFFTEST
static bool difftest_skip_first = false;
#endif

VerilatedContext* contextp = NULL;
VerilatedVcdC* tfp = NULL;

// static vluint64_t time = 0;

static Vcpu_top* top;

const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};


void step_and_dump_wave(){
    top->clk = !top->clk; // 翻转时钟
    top->eval();
    contextp->timeInc(5);
    tfp->dump(contextp->time()); // 记录波形
}

void init_npc(){
    contextp = new VerilatedContext;
    tfp = new VerilatedVcdC;
    top = new Vcpu_top;
    contextp->traceEverOn(true);
    top->trace(tfp, 20);
    tfp->open("cpu_top.vcd");


    // init
    top->clk = 1;
    top->rst = 1;
    top->NextPc = 0x80000000;
    top->inst = 0xffffffff;
    top->rootp->cpu_top__DOT__instr = 0xffffffff;


    cpu.pc = RESET_VECTOR;
    cpu.reg[0] = 0;

    for (int i = 0; i < 4; i++){
        step_and_dump_wave();
    }

    top->rst = 0;
    top->NextPc = 0x80000000;
    step_and_dump_wave(); // 下降沿
    // top->eval();
}

void exit_npc(){
    step_and_dump_wave();
    tfp->close();
    printf("Simulation completed!\n");
}

/*reg function*/
static inline int check_reg_idx(int idx) {
  IFDEF(CONFIG_RT_CHECK, assert(idx >= 0 && idx < 32));
  return idx;
}

word_t get_reg(int idx){
  // return top->rootp->cpu_top__DOT__u_register__DOT__rf[check_reg_idx(idx)];
  return top->rootp->cpu_top__DOT__u_register__DOT__rf[check_reg_idx(idx)];
}

void reg_display() {
  for(int i = 0; i < 16 ; i ++){
    printf("reg$%s ---> %08x\n",regs[i], top->rootp->cpu_top__DOT__u_register__DOT__rf[i]);
  }
}
/*end*/

#ifdef CONFIG_DIFFTEST
static void trace_and_difftest(vaddr_t pc, vaddr_t dnpc) {
#ifdef CONFIG_ITRACE_COND
  if (ITRACE_COND) { log_write("    %08x %08x\n", pc, top->inst); }
#endif
  if (g_print_step) { IFDEF(CONFIG_ITRACE, puts("abc\n")); }
  IFDEF(CONFIG_DIFFTEST, difftest_step(pc, top->NextPc));

#ifdef CONFIG_WATCHPOINT
  for(int i = 0; i < 32;i++){
    
    if(watchpoint_diff(i) == true)
    {
      nemu_state.state = NEMU_STOP;
      print_watchpoint(i);
    }
    wp_init(i);
  }
#endif
}
#endif

static void state_copy(){
  for(int i = 0; i < 16; i++){
    cpu.reg[i] = get_reg(i);
  }
  cpu.pc = cpu_state();
}

static void statistic() {
  IFNDEF(CONFIG_TARGET_AM, setlocale(LC_NUMERIC, ""));
#define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("total guest instructions = " NUMBERIC_FMT, g_nr_guest_inst);
  if (g_timer > 0) Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  else Log("Finish running in less than 1 us and can not calculate the simulation frequency");
}

void assert_fail_msg() {
  reg_display();
  statistic();
}

vaddr_t cpu_state(){
  return top->rootp->cpu_top__DOT__pc;
}

static void npc_once(){
  
  // printf("81 addr = %08x\n", top->NextPc);
  top->inst = pmem_read(top->NextPc, 4); // 取指令
  // printf("----> %08x\n", top->inst);

 
  // log_write("    %08x  %08x\n", top->NextPc, top->inst);
  step_and_dump_wave();  // 上升沿

  // difftest
#ifdef CONFIG_DIFFTEST
  state_copy();
  if(difftest_skip_first == true){ // 跳过第一次difftest
    trace_and_difftest(top->rootp->cpu_top__DOT__pc, top->NextPc);
  }
  difftest_skip_first = true;
#endif
  

  step_and_dump_wave();  // 下降沿

  if(pmem_read(top->NextPc, 4) == 0x00100073){ // ebreak
    npc_state.state = NPC_END;
    npc_state.halt_pc = top->NextPc;
    npc_state.halt_ret = get_reg(10);
  }
}

void npc_exec(uint64_t n){
  g_print_step = (n < MAX_INST_TO_PRINT); // MAX_INST_TO_PRINT = 10;
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT: case NPC_QUIT:
      printf("Program execution has ended. To restart the program, exit NEMU and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING; // NEMU_RUNNING 或 NEMU_STOP
  }

  uint64_t timer_start = get_time();

  // 仿真
  for(;n > 0; n --){
    npc_once();
    g_nr_guest_inst ++;
    if (npc_state.state != NPC_RUNNING) break;
    IFDEF(CONFIG_DEVICE, device_update());
  }

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (npc_state.state) {
    case NPC_RUNNING: npc_state.state = NPC_STOP; break;

    case NPC_END: case NPC_ABORT:
      Log("npc: %s at pc = " FMT_WORD,
          (npc_state.state == NPC_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) :
           (npc_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) :
            ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
          npc_state.halt_pc); // NEMU_END, halt_ret != 0;
      // printf("148 %d\n", nemu_state.halt_ret);
      // fall through
    case NPC_QUIT: statistic();
  }
}
