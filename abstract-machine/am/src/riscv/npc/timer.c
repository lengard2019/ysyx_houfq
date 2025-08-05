#include <am.h>
#include <npc.h>

void __am_timer_init() {
  outl(RTC_ADDR, 0);
  outl(RTC_ADDR + 4, 0);
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
  // uptime->us = 0;
  uptime->us = inl(RTC_ADDR + 4);
  uptime->us <<= 32;
  uptime->us += inl(RTC_ADDR);
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = inl(TIME_ADDR);
  rtc->minute = inl(TIME_ADDR + 4);
  rtc->hour   = inl(TIME_ADDR + 8);
  rtc->day    = inl(TIME_ADDR + 12);
  rtc->month  = inl(TIME_ADDR + 16);
  rtc->year   = inl(TIME_ADDR + 20) + 1900;
}
