#include "bootpack.h"

struct FIFO8 mousefifo;

void inthandler2c(int *esp) {
  // PS/2 mouse
  unsigned char data;
  io_out8(PIC1_OCW2, 0x64);  // inform IRQ-12(slave)
  io_out8(PIC0_OCW2, 0x62);  // inform IRQ-02(master)
  data = io_in8(PORT_KEYDAT);
  fifo8_put(&mousefifo, data);
  return;
}

#define KEYCMD_SENDTO_MOUSE 0xd4
#define MOUSECMD_ENABLE 0xf4

void enable_mouse(struct MOUSE_DEC *mdec) {
  wait_KBC_sendready();
  io_out8(PORT_KEYCMD, KEYCMD_SENDTO_MOUSE);
  wait_KBC_sendready();
  io_out8(PORT_KEYDAT, MOUSECMD_ENABLE);
  mdec->phase = 0;
  return;
}

int mouse_decode(struct MOUSE_DEC *mdec, unsigned char dat) {
  if (mdec->phase == 0) {
    /* マウスの0xfaを待っている段階 */
    if (dat == 0xfa) {
      mdec->phase = 1;
    }
    return 0;
  }
  if (mdec->phase == 1) {
    /* マウスの1バイト目を待っている段階 */
    if ((dat & 0xc8) == 0x08) {
      /* 正しい1バイト目だった */
      mdec->buf[0] = dat;
      mdec->phase = 2;
    }
    return 0;
  }
  if (mdec->phase == 2) {
    /* マウスの2バイト目を待っている段階 */
    mdec->buf[1] = dat;
    mdec->phase = 3;
    return 0;
  }
  if (mdec->phase == 3) {
    /* マウスの3バイト目を待っている段階 */
    mdec->buf[2] = dat;
    mdec->phase = 1;
    mdec->btn = mdec->buf[0] & 0x07;
    mdec->x = mdec->buf[1];
    mdec->y = mdec->buf[2];
    if ((mdec->buf[0] & 0x10) != 0) {
      mdec->x |= 0xffffff00;
    }
    if ((mdec->buf[0] & 0x20) != 0) {
      mdec->y |= 0xffffff00;
    }
    mdec->y = -mdec->y; /* マウスではy方向の符号が画面と反対 */
    return 1;
  }
  return -1; /* ここに来ることはないはず */
}
