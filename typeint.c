#include <api.h>

void Main(void) {
  int fh;
  char c;
  fh = api_fopen("int.c");
  if (fh != 0) {
    for (;;) {
      if (api_fread(&c, 1, fh) == 0) {
        break;
      }
      api_putchar(c);
    }
  }
  api_end();
}
