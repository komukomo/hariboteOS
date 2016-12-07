helloos.img: helloos.bin kos.bin
	mformat -f 1440 -C -B helloos.bin -i helloos.img
	mcopy kos.bin -i helloos.img ::

kos.bin: kos.s
	as -o kos.o kos.s
	ld --oformat binary -o kos.bin kos.o

helloos.bin: helloos.o link.ld
	ld -T link.ld -o helloos.bin helloos.o

helloos.o: helloos.s
	as -o helloos.o helloos.s

run: helloos.img
	qemu-system-i386 -fda helloos.img

clean:
	rm *.o *.img *.bin
