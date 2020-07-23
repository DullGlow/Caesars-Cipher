caesar: main.o functions.o
	ld -m elf_i386 -o caesar main.o functions.o
main.o: main.asm
	nasm -f elf -g -F dwarf main.asm
functions.o: functions.asm
	nasm -f elf -g -F dwarf functions.asm
