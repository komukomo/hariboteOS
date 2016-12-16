#include "bootpack.h"

unsigned int memtest(unsigned int start, unsigned int end);
unsigned int memtest_sub(unsigned int start, unsigned int end);
int chk_486_or_newer(void);
void ctl_cache(char flg);

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

  i = memtest(0x00400000, 0xbfffffff) / (1024 * 1024);
  mysprintf(s, "memory %dMB", i);
  putfonts8_asc(binfo->vram, binfo->scrnx, 0, 32, COL8_FFFFFF, s);

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

#define DISABLE_CACHE 0
#define ENABLE_CACHE 1
unsigned int memtest(unsigned int start, unsigned int end) {
  unsigned int mem;
  int is486 = chk_486_or_newer();

  if (is486) {
    ctl_cache(DISABLE_CACHE);
  }
  mem = memtest_sub(start, end);
  if (is486) {
    ctl_cache(ENABLE_CACHE);
  }
  return mem;
}

#define CR0_CACHE_DISABLE 0x60000000
void ctl_cache(char flg) {
  int cr0 = load_cr0();
  switch (flg) {
    case DISABLE_CACHE:
      cr0 |= CR0_CACHE_DISABLE;
      break;
    case ENABLE_CACHE:
      cr0 &= ~CR0_CACHE_DISABLE;
      break;
  }
  store_cr0(cr0);
}

#define EFLAGS_AC_BIT 0x00040000
int chk_486_or_newer(void) {
  unsigned int eflg;
  int result = 0;

  eflg = io_load_eflags();
  eflg |= EFLAGS_AC_BIT;  // AC-bit = 1
  io_store_eflags(eflg);
  eflg = io_load_eflags();
  if ((eflg & EFLAGS_AC_BIT) != 0) {
    // 386ではAC=1にしても自動で0に戻ってしまう
    result = 1;
  }
  eflg &= ~EFLAGS_AC_BIT;  // AC-bit = 0
  io_store_eflags(eflg);
  return result;
}

unsigned int memtest_sub(unsigned int start, unsigned int end) {
  unsigned int i, *p, old, pat0 = 0xaa55aa55, pat1 = 0x55aa55aa;
  for (i = start; i <= end; i += 0x1000) {
    p = (unsigned int *)(i + 0xffc);
    old = *p;         /* いじる前の値を覚えておく */
    *p = pat0;        /* ためしに書いてみる */
    *p ^= 0xffffffff; /* そしてそれを反転してみる */
    if (*p != pat1) { /* 反転結果になったか？ */
    not_memory:
      *p = old;
      break;
    }
    *p ^= 0xffffffff; /* もう一度反転してみる */
    if (*p != pat0) { /* 元に戻ったか？ */
      goto not_memory;
    }
    *p = old; /* いじった値を元に戻す */
  }
  return i;
}
