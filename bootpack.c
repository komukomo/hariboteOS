#include "bootpack.h"

void Main(void) {
  struct BOOTINFO *binfo = (struct BOOTINFO *)ADR_BOOTINFO;
  char s[40], mcursor[256], keybuf[32], mousebuf[128];
  int my = (binfo->scrny - 16) / 2;
  int mx = (binfo->scrnx - 28 - 16) / 2;
  int i;
  struct MOUSE_DEC mdec;

  init_gdtidt();
  init_pic();
  io_sti();

  fifo8_init(&keyfifo, 32, keybuf);
  fifo8_init(&mousefifo, 128, mousebuf);
  io_out8(PIC0_IMR, 0xf9);  // PIC1/keyboard 11111001)
  io_out8(PIC1_IMR, 0xef);  // mouse 11101111

  init_keyboard();

  init_palette();
  init_screen(binfo->vram, binfo->scrnx, binfo->scrny);

  mysprintf(s, "(%d, %d) %d", binfo->scrnx, binfo->scrny, 4);
  putfonts8_asc(binfo->vram, binfo->scrnx, 8, 32, COL8_000000, s);

  init_mouse_cursor8(mcursor, COL8_008484);
  putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);

  enable_mouse(&mdec);

  while (1) {
    io_cli();
    if (fifo8_status(&keyfifo) + fifo8_status(&mousefifo) == 0) {
      io_stihlt();
    } else {
      if (fifo8_status(&keyfifo) != 0) {
        i = fifo8_get(&keyfifo);
        io_sti();
        mysprintf(s, "%X", i);
        boxfill8(binfo->vram, binfo->scrnx, COL8_008484, 0, 16, 15, 31);
        putfonts8_asc(binfo->vram, binfo->scrnx, 0, 16, COL8_FFFFFF, s);
      } else if (fifo8_status(&mousefifo) != 0) {
        i = fifo8_get(&mousefifo);
        io_sti();
        if (mouse_decode(&mdec, i) != 0) {
          /* データが3バイト揃ったので表示 */
          mysprintf(s, "[lcr %d %d]", mdec.x, mdec.y);
          if ((mdec.btn & 0x01) != 0) {
            s[1] = 'L';
          }
          if ((mdec.btn & 0x02) != 0) {
            s[3] = 'R';
          }
          if ((mdec.btn & 0x04) != 0) {
            s[2] = 'C';
          }
          boxfill8(binfo->vram, binfo->scrnx, COL8_008484, 32, 16,
                   32 + 15 * 8 - 1, 31);
          putfonts8_asc(binfo->vram, binfo->scrnx, 32, 16, COL8_FFFFFF, s);
          /* マウスカーソルの移動 */
          boxfill8(binfo->vram, binfo->scrnx, COL8_008484, mx, my, mx + 15,
                   my + 15); /* マウス消す */
          mx += mdec.x;
          my += mdec.y;
          if (mx < 0) {
            mx = 0;
          }
          if (my < 0) {
            my = 0;
          }
          if (mx > binfo->scrnx - 16) {
            mx = binfo->scrnx - 16;
          }
          if (my > binfo->scrny - 16) {
            my = binfo->scrny - 16;
          }
          mysprintf(s, "(%d, %d)", mx, my);
          boxfill8(binfo->vram, binfo->scrnx, COL8_008484, 0, 0, 79,
                   15); /* 座標消す */
          putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF,
                        s); /* 座標書く */
          putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor,
                      16); /* マウス描く */
        }
      }
    }
  }
}
