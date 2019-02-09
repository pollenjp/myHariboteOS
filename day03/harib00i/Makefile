OSNAME := haribote

.DEFAULT_GOAL : all
.PHONY : all
all : img

#===============================================================================
ipl10.bin : ipl10.asm
asmhead.bin : asmhead.asm
%.bin : %.asm
	nasm $^ -o $@ -l $*.lst

bootpack.hrb : bootpack.c os.lds
# Cファイルをリンカスクリプトを用いてコンパイル
# -march=i486
# -m32
# -nostdlib
# -T <linker-script>
#	.lds : Binutils LD Linker Script
	gcc -march=i486 -m32 -nostdlib \
		-T os.lds \
		-o $@ \
		bootpack.c

${OSNAME}.sys : asmhead.bin bootpack.hrb
# asmhead.bin => bootpack.hrb の順にバイナリを並べる
# 拡張子 .hrb はおそらくHaRiBoteの略
	cat $^ > $@

${OSNAME}.img : ipl10.bin ${OSNAME}.sys
# mtools
#  - [Mtools - Wikipedia](https://en.wikipedia.org/wiki/Mtools)
#  - [2.2 Drive letters - Mtools 4.0.23](https://www.gnu.org/software/mtools/manual/mtools.html#drive-letters)
#  - [mtoolsの使い方が知りたい - ITmedia エンタープライズ](http://www.itmedia.co.jp/help/tips/linux/l0317.html)
#
# 1440KBのフロッピーディスクに書き込む
	mformat -f 1440 -C -B ipl10.bin -i $@ ::
# OS本体をイメージに書き込む
	mcopy -i $@ ${OSNAME}.sys ::

#===============================================================================
.PHONY : asm
asm :
	make ipl10.bin

.PHONY : img
img :
	make ${OSNAME}.img 

.PHONY : run
run :
	make img
	qemu-system-i386 -fda ${OSNAME}.img

#===============================================================================
.PHONY : clean
clean :
# lstは残しておいてもいいと思うのでcleanに入れていない
	@rm *.img *.bin *.sys *.hrb

.PHONY : debug
debug:
	make img
	qemu-system-i386 -fda haribote.img -gdb tcp::10000 -S

