#include <am.h>
#include <nemu.h>
#include <stdio.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {

  uint32_t kc = inl(KBD_ADDR);
  // if(kc != 0x00000000){
    // printf("13 %d\n", kc);
  // }
  kbd->keydown = kc & KEYDOWN_MASK ? true : false;
  kbd->keycode = kc & ~KEYDOWN_MASK;
}
