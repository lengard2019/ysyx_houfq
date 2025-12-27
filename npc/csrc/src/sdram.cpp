#include <sdram.h>
#include "svdpi.h"
#include "VysyxSoCTop__Dpi.h"
// #include <cpu/difftest.h>
#include <time.h>

// 内存数组
static uint16_t sdram[CONFIG_BANK][CONFIG_SDRAM_COL][CONFIG_SDRAM_ROW] PG_ALIGN_S = {};

// uint8_t* guest_to_host_sdram(paddr_t paddr) { return psram + paddr; }
// paddr_t host_to_guest_sdram(uint8_t *haddr) { return haddr - psram; }

// static inline word_t host_read(void *addr) { 
//     return *(uint32_t *)addr;
// }

// static inline void host_write(void *addr, uint8_t data) {

//     *(uint8_t *)addr = data; 
//     return;
  
// }
    
extern "C" void sdram_read(char bank, short row, short col, short *data){
  // paddr_t addr_r = (paddr_t)addr;
  uint8_t temp_bank = (uint8_t) bank;
  uint16_t temp_col = (uint16_t) col;
  uint16_t temp_row = (uint16_t) row;
  uint16_t temp;

    if(temp_bank < CONFIG_BANK && temp_col < CONFIG_SDRAM_COL && temp_row < CONFIG_SDRAM_ROW){
        // printf("read %08x, %08x\n", addr, temp);
        temp = sdram[temp_bank][temp_col][temp_row];
        *data = (short)temp;
        // printf("read %04x, %04x, %04x\n", temp_col, temp_row, temp);
    }
    else{
        printf("sdram out of bound\n");
        assert(0);
    }
    return;
}

extern "C" void sdram_write(char bank, short row, short col, char mask, short data) {
  
  uint8_t temp_bank = (uint8_t) bank;
  uint8_t temp_mask = (uint8_t) mask;
  uint16_t temp_col = (uint16_t) col;
  uint16_t temp_row = (uint16_t) row;
  uint16_t temp_data = (uint16_t) data;

  if(temp_bank < CONFIG_BANK && temp_col < CONFIG_SDRAM_COL && temp_row < CONFIG_SDRAM_ROW){
    if(mask == 0x00){
      sdram[temp_bank][temp_col][temp_row] = temp_data;
      // printf("write %08x, %08x\n", temp, (uint8_t)data);
    }
    else if(mask == 0x01){
      // printf("%04x\n", sdram[temp_bank][temp_col][temp_row]);
      sdram[temp_bank][temp_col][temp_row] = (sdram[temp_bank][temp_col][temp_row] & 0x00FF) | (temp_data & 0xFF00);
      // printf("%04x, %04x\n", sdram[temp_bank][temp_col][temp_row], temp_data);
    }
    else if(mask == 0x02){
      // printf("%04x\n", sdram[temp_bank][temp_col][temp_row]);
      sdram[temp_bank][temp_col][temp_row] = (sdram[temp_bank][temp_col][temp_row] & 0xFF00) | (temp_data & 0x00FF);
      // printf("%04x, %04x\n", sdram[temp_bank][temp_col][temp_row], temp_data);
    }
    else {
    }
    // printf("write %08x, %08x\n", temp, (uint8_t)data);
  }
  else{
    printf("sdram is out of bound\n");
    // assert(0);
  }
}