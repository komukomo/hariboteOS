ipl.img: ipl.bin sys.bin
	mformat -f 1440 -C -B ipl.bin -i ipl.img
	mcopy sys.bin -i ipl.img ::

sys.bin: head.bin bootpack.bin
	cat head.bin bootpack.bin > sys.bin

bootpack.bin: bootpack.o func.o
	ld -m elf_i386 -o bootpack.bin -e Main --oformat=binary bootpack.o func.o

bootpack.o: bootpack.c
	gcc -m32 -nostdlib -Wl,--oformat=binary -c -o bootpack.o bootpack.c

head.bin: head.o
	ld -m elf_i386 -T head.ld -o head.bin head.o

head.o: head.s
	as --32 -o head.o head.s

ipl.bin: ipl.o ipl.ld
	ld -m elf_i386 -T ipl.ld -o ipl.bin ipl.o

ipl.o: ipl.s
	as --32 -o ipl.o ipl.s

func.o: func.s
	as --32 -o func.o func.s

run: ipl.img
	qemu-system-i386 -fda ipl.img

clean:
	rm *.o *.img *.bin
