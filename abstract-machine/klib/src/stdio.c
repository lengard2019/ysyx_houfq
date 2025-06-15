#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

static int int_to_str(int num, char *buffer) {
  char temp[20];
  int i = 0;
  int is_negative = 0;

  if (num < 0) {
      is_negative = 1;
      num = -num;
  }

  do {
      temp[i] = (num % 10) + '0';
      num /= 10;
      i++;
  } while (num > 0);

  if (is_negative) {
      temp[i++] = '-';
  }

  int len = i;
  for (int j = 0; j < len; j++) {
      buffer[j] = temp[len - 1 - j];
  }
  buffer[len] = '\0'; 
  return len;
}

int printf(const char *fmt, ...) {

  
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  

  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {

  va_list ap;

  int count = 0;

  char *p = out;

  va_start(ap, fmt);

  while(*fmt != '\0')
  {
    if(*fmt == '%'){
      fmt++;
      switch(*fmt){
        case 'd': {
          int num = va_arg(ap, int);
          int len = int_to_str(num, p);
          p += len;
          count += len;
          break;
        }
        case 's': {
          char *s = va_arg(ap, char *);
          int i = 0;
          while(*s != '\0')
          {
            *p = *s;
            i++;
            p++;
            s++;
          }
          count += i;
          break;
        }
        default :{
          *p++ = '%';
          *p++ = *fmt;
          count += 2;
          break;
        }
      }
    }
    else{
      *p++ = *fmt;
      count++;
    }
    fmt++;
  }
  *p = '\0';
  va_end(ap);
  return count;
  
  panic("Not implemented");
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
