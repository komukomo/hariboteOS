objs = bootpack.o window.o console.o file.o int.o mtask.o timer.o sheet.o memory.o lib.o fifo.o mouse.o keyboard.o func.o font.o graphic.o dsctbl.o
img = sys.img

CC = gcc
CFLAGS = -m32 -nostdlib
LD = ld
LDFLAGS = -m elf_i386
AS = as
ASFLAGS = --32

$(img): ipl.bin head.bin bootpack.bin hello.bin hello2.bin a.hrb hello4.hrb winhelo.hrb winhelo2.hrb winhelo3.hrb star1.hrb lines.hrb walk.hrb noodle.hrb beepdown.hrb crack1.hrb
	cat head.bin bootpack.bin > sys.bin
	mformat -f 1440 -C -B ipl.bin -i $@
	mcopy sys.bin -i $@ ::
	mcopy int.c -i $@ ::
	mcopy hello.bin -i $@ ::
	mcopy hello2.bin -i $@ ::
	mcopy a.hrb -i $@ ::
	mcopy hello4.hrb -i $@ ::
	mcopy winhelo.hrb -i $@ ::
	mcopy winhelo2.hrb -i $@ ::
	mcopy winhelo3.hrb -i $@ ::
	mcopy star1.hrb -i $@ ::
	mcopy lines.hrb -i $@ ::
	mcopy walk.hrb -i $@ ::
	mcopy noodle.hrb -i $@ ::
	mcopy beepdown.hrb -i $@ ::
	mcopy crack1.hrb -i $@ ::

bootpack.bin: $(objs) bootpack.ld
	$(LD) -v $(LDFLAGS) -Map bootpack.map -T bootpack.ld -o $@ $(objs)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $*.c

%.bin: %.s %.ld
	$(AS) $(ASFLAGS) -o $*.o $*.s
	$(LD) $(LDFLAGS) -T $*.ld -o $@ $*.o

func.o: func.s
	$(AS) $(ASFLAGS) --32 -o $@ $*.s

font.c: hankaku.txt
	./make_font.py hankaku.txt > $@

run: $(img)
	qemu-system-i386 -fda $(img) -monitor stdio

%.hrb: api.s api.ld %.c lib.o
	$(AS) $(ASFLAGS) -o api.o api.s
	$(CC) $(CFLAGS) -T api.ld -o $@ api.o $*.c lib.c


.PHONY: clean
clean:
	rm *.o *.img *.bin font.c *.map *.hrb

lib_test: lib.o test/lib_test.c
	$(CC) -m32 -o test/lib_test test/lib_test.c lib.o
	./test/lib_test && echo 'Success, lib_test passed'
