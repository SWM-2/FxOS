all: unpaged run_u

unpaged:
	nasm -felf32 start.asm -o start.o
	ld -m elf_i386 -T linker.ld -o kernel_unpaged.elf start.o
	rm *.o

run_u:
	export GDK_BACKEND=wayland
	qemu-system-i386 -kernel kernel_unpaged.elf -monitor stdio