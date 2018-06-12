# Makefile

CC = gcc
CFLAGS = -c -m32 -march=i486 -nostdlib


###########################

default:
	make run

#--------------------
#	hankaku char
#--------------------
convHankakuTxt : convHankakuTxt.c
	$(CC) $< -o $@

hankaku.c : hankaku.txt convHankakuTxt
	./convHankakuTxt


#--------------------
#	haribote
#--------------------
ipl10.bin : ipl10.asm Makefile
	nasm ipl10.asm -o ipl10.bin -l ipl10.lst

asmhead.bin : asmhead.asm
	nasm asmhead.asm -o asmhead.bin -l asmhead.lst

nasmfunc.o : nasmfunc.asm Makefile
	nasm -f elf nasmfunc.asm -o nasmfunc.o -l asmfunc.lst

hankaku.o : hankaku.c
	$(CC) $(CFLAGS) hankaku.c -o hankaku.o

mysprintf.o : mysprintf.c
	$(CC) $(CFLAGS) -nostdlib $^ -o $@

#bootpack.o : bootpack.c
#	$(CC) $(CFLAGS) bootpack.c -o bootpack.o

bootpack.hrb : bootpack.c hankaku.o nasmfunc.o mysprintf.o har.ld
	$(CC) -m32 -march=i486 -nostdlib -nostdinc -T har.ld bootpack.c hankaku.o nasmfunc.o mysprintf.o -o bootpack.hrb
#bootpack.hrb : bootpack.o hankaku.o nasmfunc.o mysprintf.o har.ld
#	ld -m elf_i386 -T har.ld bootpack.o hankaku.o nasmfunc.o mysprintf.o -o bootpack.hrb

haribote.sys : asmhead.bin bootpack.hrb Makefile
	#nasm haribote.asm -o haribote.sys -l haribote.lst
	cat asmhead.bin bootpack.hrb > haribote.sys

haribote.img : ipl10.bin haribote.sys Makefile
	mformat -f 1440 -C -B ipl10.bin -i haribote.img ::
	mcopy haribote.sys -i haribote.img ::

asm :
	make -r ipl10.bin

img :
	make -r haribote.img

run :
	make img
	qemu-system-i386 -fda haribote.img	# "-fda" for floppy disk

debug:
	make img
	qemu-system-i386 -fda haribote.img -gdb tcp::10000 -S

clean :
	rm *.lst
	rm *.o
	rm *.bin
	rm *.hrb
	rm *.sys
	rm hankaku.c
	rm convHankakuTxt

src_only :
	make clean
	rm haribote.img

