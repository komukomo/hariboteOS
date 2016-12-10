#include "bootpack.h"

struct BOOTINFO {
  char cyls;
  char leds;
  char vmode;
  char reserve;
  short scrnx;
  short scrny;
  char *vram;
};

void Main(void) {
  struct BOOTINFO *binfo = (struct BOOTINFO *)0x0ff0;
  char s[40], mcursor[256];
  int my = (binfo->scrny - 16) / 2;
  int mx = (binfo->scrnx - 28 - 16) / 2;

  init_gdtidt();
  init_pic();
  init_palette();
  init_screen(binfo->vram, binfo->scrnx, binfo->scrny);

  mysprintf(s, "(%d, %d) %d", binfo->scrnx, binfo->scrny, 4);
  putfonts8_asc(binfo->vram, binfo->scrnx, 8, 32, COL8_000000, s);
  putfonts8_asc(binfo->vram, binfo->scrnx, 8, 8, COL8_000000, "ABC 123.");
  init_mouse_cursor8(mcursor, COL8_008484);
  putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);

  for (;;) {
    io_hlt();
  }
}
