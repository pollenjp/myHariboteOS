
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
# -r, --no-builtin-rules
#     Eliminate use of the built-in implicit rules.
#     Also clear out the default list of suffixes for suffix rules.
#	make --no-builtin-rules ipl.bin
	make ipl.bin

.PHONY : img
img :
	make helloos.img

.PHONY : run
run :
	make img
	qemu-system-i386 helloos.img

.PHONY : clean
clean :
# lstは残しておいてもいいと思うのでcleanに入れていない
	@rm *.img *.bin


