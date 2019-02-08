.DEFAULT_GOAL : all
.PHONY : all
all : img

ipl.bin : ipl.asm

%.bin : %.asm
	nasm $^ -o $@ -l $*.lst

helloos.img : ipl.bin
	cat $^ > $@


.PHONY : asm
asm :
	make ipl.bin

.PHONY : img
img :
	make helloos.img

.PHONY : run
run :
	make img
	qemu-system-i386 -fda helloos.img

.PHONY : clean
clean :
# lstは残しておいてもいいと思うのでcleanに入れていない
	@rm *.img *.bin

