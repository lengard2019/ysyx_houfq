#include "Vnpc_top.h"  // Verilator 生成的模型头文件
#include "verilated.h"
#include "Vnpc_top___024root.h"

#include "svdpi.h"
#include "Vnpc_top__Dpi.h"

#include <paddr.h>
// #include <mrom.h>
#include <npc_counter.h>
#include <common.h>
#include <locale.h>
#include <cpu/cpu.h>
#include <cpu/difftest.h>
#include <cpu/iringbuf.h>
#include "sdb/sdb.h"

#ifdef CONFIG_VCD_TRACE
// #include "verilated_vcd_c.h"  // 用于生成波形文件
#include "verilated_fst_c.h"
#endif



#define MAX_INST_TO_PRINT 10
// void init_monitor(int, char *[]);

NPC_state cpu = {};

static bool ebreak = false;
static uint32_t abort_count = 0;

uint64_t g_nr_guest_inst = 0;
uint64_t g_nr_cycle = 0;
static uint64_t g_timer = 0; // unit: us
static bool g_print_step = false;
// #ifdef CONFIG_DIFFTEST
static bool difftest_skip_first = false;
// #endif

VerilatedContext* contextp = NULL;
#ifdef CONFIG_VCD_TRACE
VerilatedFstC* tfp = NULL;
#endif

static Vnpc_top* top;

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
#ifdef CONFIG_VCD_TRACE
    tfp->dump(contextp->time()); // 记录波形
#endif
}

void init_npc(int argc, char *argv[]){
    contextp = new VerilatedContext;

    Verilated::commandArgs(argc, argv);

    top = new Vnpc_top;
    contextp->traceEverOn(true);
    
#ifdef CONFIG_VCD_TRACE
    tfp = new VerilatedFstC;
    top->trace(tfp, 20);
    tfp->open("soc_test.fst");
#endif

    // init
    top->clk = 1;
    top->reset = 1;

    cpu.pc = 0x80000000;
    cpu.reg[0] = 0;

    for (int i = 0; i < 20; i++){
        step_and_dump_wave();
    }

    top->reset = 0;
    step_and_dump_wave(); // 下降沿
    // top->eval();
}

void exit_npc(){
    step_and_dump_wave();
#ifdef CONFIG_VCD_TRACE
    tfp->close();
#endif
    printf("Simulation completed!\n");
}

/*reg function*/
static inline int check_reg_idx(int idx) {
  IFDEF(CONFIG_RT_CHECK, assert(idx >= 0 && idx < 32));
  return idx;
}

word_t get_reg(int idx){
  // return top->rootp->cpu_top__DOT__u_register__DOT__rf[check_reg_idx(idx)];
  return top->rootp->npc_top__DOT__u_cpu_top__DOT__u_register__DOT__rf[check_reg_idx(idx)];
}

void reg_display() {
  for(int i = 0; i < 16 ; i ++){
    printf("reg$%s ---> %08x\n",regs[i], top->rootp->npc_top__DOT__u_cpu_top__DOT__u_register__DOT__rf[i]);
  }
}
/*end*/


void call_ebreak() {
  ebreak = true;
}

// #ifdef CONFIG_DIFFTEST
static void trace_and_difftest(vaddr_t pc, vaddr_t dnpc) {
#ifdef CONFIG_ITRACE_COND
  // log_write("  log\n");
  if (ITRACE_COND) { log_write("    %08x %08x\n", pc, top->rootp->npc_top__DOT__u_cpu_top__DOT__u_IDU_ysyx__DOT__instr); }
  // if (ITRACE_COND) {
  //   char s[100];
  //   snprintf(s, sizeof(s), "    %08x    %08x", pc, top->rootp->ysyxSoCTop__DOT__dut__DOT__asic__DOT__cpu__DOT__cpu__DOT__u_IDU_ysyx__DOT__instr);
  //   ring_write(s); }
#endif
  if (g_print_step) { IFDEF(CONFIG_ITRACE, puts("abc\n")); }
  // printf("%08x, %08x\n", pc, dnpc);
  IFDEF(CONFIG_DIFFTEST, difftest_step(pc, dnpc));

#ifdef CONFIG_WATCHPOINT
  for(int i = 0; i < 32;i++){
    
    if(watchpoint_diff(i) == true)
    {
      npc_state.state = NPC_STOP;
      print_watchpoint(i);
    }
    wp_init(i);
  }
#endif
}
// #endif

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
  Log("cycles per instructions = " NUMBERIC_FMT " cycles/inst", g_nr_cycle/g_nr_guest_inst);
  if (g_timer > 0) Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  else Log("Finish running in less than 1 us and can not calculate the simulation frequency");
}

void assert_fail_msg() {
  reg_display();
  statistic();
}

vaddr_t cpu_state(){
  return top->rootp->npc_top__DOT__u_cpu_top__DOT__u_IFU_ysyx__DOT__pc_r;
}

static void npc_once(){
  
  // printf("81 addr = %08x\n", top->NextPc);
  // top->inst = pmem_read(top->NextPc, 4); // 取指令
  // printf("----> %08x\n", top->inst);

  uint32_t inst_pre = top->rootp->npc_top__DOT__u_cpu_top__DOT__u_IFU_ysyx__DOT__inst_r;
 
  step_and_dump_wave();  // 上升沿

  uint32_t inst_now = top->rootp->npc_top__DOT__u_cpu_top__DOT__u_IFU_ysyx__DOT__inst_r;

  // difftest
// #ifdef CONFIG_DIFFTEST
  IFDEF(CONFIG_DIFFTEST, state_copy());
  // state_copy();
  if(top->reset == 0 && top->rootp->npc_top__DOT__u_cpu_top__DOT__u_WBU_ysyx__DOT__current_state == 0){ // or EXU finish one inst
    if(difftest_skip_first == true){// 跳过第一次difftest
      // printf("pc = %08x, Next_pc = %08x\n", top->pc, top->Next_pc);
      trace_and_difftest(top->rootp->npc_top__DOT__u_cpu_top__DOT__u_WBU_ysyx__DOT__pc_r, top->rootp->npc_top__DOT__u_cpu_top__DOT__u_WBU_ysyx__DOT__pc_r);
    }
    else{
      difftest_skip_first = true;
    }
    g_nr_guest_inst ++;
  }
  
// #endif

  step_and_dump_wave();  // 下降沿

  g_nr_cycle ++ ;

  if(inst_pre == inst_now){
    abort_count ++;
  }
  else{
#ifdef CONFIG_COUNTER
    int type = type_of_inst();
    cycle_add(type, abort_count);
#endif
    abort_count = 0;
  }

  if(abort_count >= 20000){ // 保护
    npc_state.state = NPC_ABORT;
    npc_state.halt_pc = cpu_state();
    npc_state.halt_ret = get_reg(10);
  }

  if(ebreak == true){
#ifdef CONFIG_COUNTER
    display_counter();
#endif
    npc_state.state = NPC_END;
    npc_state.halt_pc = cpu_state();
    npc_state.halt_ret = get_reg(10);
  }
  
}

void npc_exec(uint64_t n){
  g_print_step = (n < MAX_INST_TO_PRINT); // MAX_INST_TO_PRINT = 10;
  switch (npc_state.state) {
    case NPC_END: case NPC_ABORT: case NPC_QUIT:
      printf("Program execution has ended. To restart the program, exit NEMU and run again.\n");
      return;
    default: npc_state.state = NPC_RUNNING;
  }

  uint64_t timer_start = get_time();

  // 仿真
  for(;n > 0; n --){
    npc_once();
    if (npc_state.state != NPC_RUNNING) break;
    IFDEF(CONFIG_DEVICE, device_update());
  }

  ring_print();

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
    case NPC_QUIT: statistic();
  }
}
