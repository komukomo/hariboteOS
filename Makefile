ipl.img: ipl.bin sys.bin
	mformat -f 1440 -C -B ipl.bin -i ipl.img
	mcopy sys.bin -i ipl.img ::

sys.bin: head.bin bootpack.bin
	cat head.bin bootpack.bin > sys.bin

bootpack.bin: bootpack.o func.o
	ld -o bootpack.bin -e Main --oformat=binary bootpack.o func.o

bootpack.o: bootpack.c
	gcc -nostdlib -Wl,--oformat=binary -c -o bootpack.o bootpack.c

head.bin: head.o
	ld -T head.ld -o head.bin head.o

head.o: head.s
	as -o head.o head.s

ipl.bin: ipl.o ipl.ld
	ld -T ipl.ld -o ipl.bin ipl.o

ipl.o: ipl.s
	as -o ipl.o ipl.s

func.o: func.s
	as -o func.o func.s

run: ipl.img
	qemu-system-i386 -fda ipl.img

clean:
	rm *.o *.img *.bin
