helloos.img: helloos.bin
	mformat -f 1440 -C -B helloos.bin -i helloos.img

helloos.bin: helloos.o link.ld
	ld -T link.ld -o helloos.bin helloos.o

helloos.o: helloos.s
	as -o helloos.o helloos.s

run: helloos.img
	qemu-system-i386 helloos.img

clean:
	rm *.o *.img *.bin
