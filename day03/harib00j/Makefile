OSNAME := haribote

.DEFAULT_GOAL : all
.PHONY : all
all : img
SAVE_DIR := ./ref

#===============================================================================
ipl10.bin    : ipl10.asm
asmhead.bin  : asmhead.asm
nasmfunc.o   : nasmfunc.asm

%.bin : %.asm
	@if [ ! -d ${SAVE_DIR} ]; then mkdir ${SAVE_DIR}; fi
	nasm $^ -o $@ -l ${SAVE_DIR}/$*.lst

%.o : %.asm
# https://nasm.us/doc/nasmdoc2.html
# -f <format> | 
#             | elf | Executable and Linkable Format Object Files
#             |     | > "elf" provides a default output file-name extension of `.o`. "elf" is a synonym for elf32.
#             |     | > [7.9 elf32, elf64, elfx32: Executable and Linkable Format Object Files](https://nasm.us/doc/nasmdoc7.html#section-7.9)
#             |     |
#             |     | > ELFはExecutable and Linking Formatの略であり、例えばC言語で書かれたソースコードを
#             |     | > コンパイルして出来た実行可能ファイルはELFファイルです
#             |     | > [ELF入門 - 情弱ログ](http://sugawarayusuke.hatenablog.com/entry/2017/04/09/213133)
# -o <output> |
# -g 		  | Causes nasm to generate debug information in selected format.
	nasm -g -f elf $^ -o $@

BOOTPACK_FILES := bootpack.c nasmfunc.o
bootpack.hrb : ${BOOTPACK_FILES} os.lds
# > 「30日でできる!OS自作入門」 p65
# > そんなわけで、実はbimファイルは「本来の状態ではない仮の形式」なので、完成品ではないのです。
# > これは全部くっつけて機械語としてまとめただけで、実際に使うためには、それぞれのOSが必要とする
# > 形式に合わせて加工しなければいけないのです。識別用のヘッダをつけるとか、圧縮するとか、そんな
# > ことです。今回は「はりぼてOS」の都合のよい形式にしたいので、そのためのプログラムを作りました。
# > bim2hrb.exeです。このプログラムもそのうち紹介しますが、今はまだダメです。
# 
# Cファイルをリンカスクリプトを用いてコンパイル
# -march=i486
# -m32
# -nostdlib
# -T <linker-script>
#	.lds : Binutils LD Linker Script
#   「はりぼてOS」の都合のよい形式に変換している
	gcc -march=i486 -m32 -nostdlib \
		-T os.lds \
		-o $@ \
		${BOOTPACK_FILES}

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
	@rm *.img *.bin *.sys *.hrb *.o

.PHONY : debug
debug:
	make img
	qemu-system-i386 -fda haribote.img -gdb tcp::10000 -S

