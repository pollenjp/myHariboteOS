
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

asmhead.bin : asmhead.asm Makefile
	nasm asmhead.asm -o asmhead.bin -l asmhead.lst
	#nasm -f elf asmhead.asm -o asmhead.bin

nasmfunc.o : nasmfunc.asm Makefile
	nasm -f elf nasmfunc.asm -o nasmfunc.o -l asmfunc.lst

bootpack.hrb : bootpack.c har.ld hankaku.c nasmfunc.o Makefile
	gcc -march=i486 -m32 -nostdlib -T har.ld bootpack.c hankaku.c nasmfunc.o -o bootpack.hrb

haribote.sys : asmhead.bin bootpack.hrb Makefile
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

