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

void inthandler21(int *esp) {
  // PS/2 keyboard
  struct BOOTINFO *binfo = (struct BOOTINFO *)ADR_BOOTINFO;
  unsigned char data, s[16];
  io_out8(PIC0_OCW2, 0x61);
  data = io_in8(PORT_KEYDAT);

  mysprintf(s, "%d", data);
  boxfill8(binfo->vram, binfo->scrnx, COL8_008484, 0, 16, 24, 31);
  putfonts8_asc(binfo->vram, binfo->scrnx, 0, 16, COL8_FFFFFF, s);

  return;
}

void inthandler2c(int *esp) {
  // PS/2 mouse
  struct BOOTINFO *binfo = (struct BOOTINFO *)ADR_BOOTINFO;
  boxfill8(binfo->vram, binfo->scrnx, COL8_000000, 0, 0, 32 * 8 - 1, 15);
  putfonts8_asc(binfo->vram, binfo->scrnx, 0, 0, COL8_FFFFFF,
                "INT 2C (IRQ-12) : PS/2 mouse");
  for (;;) {
    io_hlt();
  }
}

void inthandler27(int *esp) {
  io_out8(PIC0_OCW2, 0x67);
  return;
}
