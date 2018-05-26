# Makefile

CC = gcc
CFLAGS = -c -m32 -march=i486 -nostdlib


###########################

ipl10.bin : ipl10.asm
	nasm $< -o $@ -l ipl10.lst

asmhead.bin : asmhead.asm
	nasm $< -o $@ -l asmhead.lst

bootpack.o : bootpack.c
	$(CC) $(CFLAGS) $< -o $@

nasmfunc.o : nasmfunc.asm
	nasm -f elf $< -o $@ -l asmfunc.lst

hankaku.o : hankaku.c
	$(CC) $(CFLAGS) $< -o $@

mysprintf.o : mysprintf.c
	$(CC) $(CFLAGS) -nostdlib $^ -o $@

graphic.o : graphic.c
	$(CC) $(CFLAGS) $< -o $@

dsctbl.o : dsctbl.c
	$(CC) $(CFLAGS) $< -o $@

bootpack.hrb : bootpack.c nasmfunc.o hankaku.o mysprintf.o graphic.o dsctbl.o har.ld
	$(CC) -m32 -march=i486 -nostdlib -nostdinc -T har.ld bootpack.c nasmfunc.o hankaku.o mysprintf.o graphic.o dsctbl.o -o $@

#bootpack.hrb : bootpack.o nasmfunc.o hankaku.o mysprintf.o graphic.o dsctbl.o har.ld
#	ld -m elf_i386 -T har.ld bootpack.o nasmfunc.o hankaku.o mysprintf.o graphic.o dsctbl.o -o $@

haribote.sys : asmhead.bin bootpack.hrb Makefile
	cat asmhead.bin bootpack.hrb > haribote.sys

haribote.img : ipl10.bin haribote.sys Makefile
	mformat -f 1440 -C -B ipl10.bin -i haribote.img ::
	mcopy haribote.sys -i haribote.img ::

img :
	make haribote.img

run :
	make img
	qemu-system-i386 -fda haribote.img	# "-fda" for floppy disk

debug:
	make img
	qemu-system-i386 -fda haribote.img -gdb tcp::10000 -S

clean :
	rm *.o
	rm *.lst
	rm *.bin
	rm *.hrb
	rm *.sys

src_only :
	make clean
	rm haribote.img


