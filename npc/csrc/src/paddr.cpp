#include <paddr.h>


// 内存数组
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {}; //0x8000000

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }//0x80000000
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }


static inline word_t host_read(void *addr, int len) {
    switch (len) {
      case 1: return *(uint8_t  *)addr;
      case 2: return *(uint16_t *)addr;
      case 4: return *(uint32_t *)addr;
      default: assert(0);
    }
}

static inline void host_write(void *addr, int len, word_t data) {
    switch (len) {
      case 1: *(uint8_t  *)addr = data; return;
      case 2: *(uint16_t *)addr = data; return;
      case 4: *(uint32_t *)addr = data; return;
      default: assert(0);
    }
}

void init_mem() {
  memset(pmem, 0, CONFIG_MSIZE);
  printf("physical memory area [ %08x ,  %08x ]", PMEM_LEFT, PMEM_RIGHT);
}
    
word_t pmem_read(paddr_t addr, int len) {
  if(addr <= 0x87FFFFFF && addr >= 0x80000000){
    word_t ret = host_read(guest_to_host(addr), len);
    return ret;
  }
  else{
    printf("addr = %08x  is out of bound\n", addr);
    // assert(0);
  }
  return 0;
}

void pmem_write(paddr_t addr, int len, word_t data) {
  if(addr <= 0x87FFFFFF && addr >= 0x80000000){
    host_write(guest_to_host(addr), len, data);
  }
  else{
    printf("addr = %08x  is out of bound\n", addr);
    // assert(0);
  }
}