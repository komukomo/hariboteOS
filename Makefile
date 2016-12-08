helloos.img: helloos.bin sys.bin
	mformat -f 1440 -C -B helloos.bin -i helloos.img
	mcopy sys.bin -i helloos.img ::

sys.bin: kos.bin bootpack.bin
	cat kos.bin bootpack.bin > sys.bin

bootpack.bin: bootpack.o func.o
	ld -o bootpack.bin -e Main --oformat=binary bootpack.o func.o

bootpack.o: bootpack.c
	gcc -nostdlib -Wl,--oformat=binary -c -o bootpack.o bootpack.c

kos.bin: kos.o
	ld -T kos.ld -o kos.bin kos.o

kos.o: kos.s
	as -o kos.o kos.s

helloos.bin: helloos.o link.ld
	ld -T link.ld -o helloos.bin helloos.o

helloos.o: helloos.s
	as -o helloos.o helloos.s

func.o: func.s
	as -o func.o func.s

run: helloos.img
	qemu-system-i386 -fda helloos.img

clean:
	rm *.o *.img *.bin
