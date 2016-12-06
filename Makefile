helloos.img: helloos.o
	ld --oformat binary -o helloos.img helloos.o

helloos.o: helloos.s
	as -o helloos.o helloos.s

run: helloos.img
	qemu-system-i386 helloos.img

clean:
	rm *.o *.img
