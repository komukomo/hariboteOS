#include "bootpack.h"

void init_pic(void) {
  io_out8(PIC0_IMR, 0xff);
  io_out8(PIC1_IMR, 0xff);

  io_out8(PIC0_ICW1, 0x11);
  io_out8(PIC0_ICW2, 0x20);
  io_out8(PIC0_ICW3, 1 << 2);
  io_out8(PIC0_ICW4, 0x01);

  io_out8(PIC1_ICW1, 0x11);
  io_out8(PIC1_ICW2, 0x28);
  io_out8(PIC1_ICW3, 2);
  io_out8(PIC1_ICW4, 0x01);

  io_out8(PIC0_IMR, 0xfb);
  io_out8(PIC1_IMR, 0xff);

  return;
}

#define PORT_KEYDAT 0x0060

struct FIFO8 keyfifo;

void inthandler21(int *esp) {
  // PS/2 keyboard
  unsigned char data;
  io_out8(PIC0_OCW2, 0x61);
  data = io_in8(PORT_KEYDAT);
  fifo8_put(&keyfifo, data);
  return;
}

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

void inthandler27(int *esp) {
  io_out8(PIC0_OCW2, 0x67);
  return;
}
