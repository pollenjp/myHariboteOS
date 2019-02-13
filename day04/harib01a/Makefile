OSNAME := haribote

.DEFAULT_GOAL : all
.PHONY : all
all : img
DEBUG_DIR := ./debug
OBJDUMP_FLAGS := --full-contents --all-headers --target=binary --architecture=i386:intel --disassemble-all
# objdump
# -s, --full-contents        | Display the full contents of all sections requested
# -d, --disassemble          | Display assembler contents of executable sections
# -D, --disassemble-all      | Display assembler contents of all sections
# -b, --target=BFDNAME       | ターゲットのオブジェクト形式を BFDNAME と指定する
# -m, --architecture=MACHINE | ターゲットのアーキテクチャを MACHINE と指定する
#                            | x86-64 | Disassemble in 64bit mode
#                            | i386   | Disassemble in 32bit mode
#                            | i8086  | Disassemble in 16bit mode
# --endian=little            | リトルエンディアンと見なして逆アセンブルする
# [Linux徹底詳解再訪 続報・その１ - Wataru's memo(2004-04-29)](http://memo.wnishida.com/?date=20040429)


#===============================================================================
ipl10.bin    : ipl10.asm
asmhead.bin  : asmhead.asm
nasmfunc.o   : nasmfunc.asm

%.bin : %.asm 
	@make make-debug-dir
	nasm $^ -o $@ -l ${DEBUG_DIR}/$*.lst

%.o : %.asm
	@make make-debug-dir
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
	nasm -f elf $^ -o $@ -l ${DEBUG_DIR}/$*.lst

BOOTPACK_FILES := bootpack.c nasmfunc.o
bootpack.hrb : ${BOOTPACK_FILES} os.lds
	@make make-debug-dir
# > 「30日でできる!OS自作入門」 p65
# > そんなわけで、実はbimファイルは「本来の状態ではない仮の形式」なので、完成品ではないのです。
# > これは全部くっつけて機械語としてまとめただけで、実際に使うためには、それぞれのOSが必要とする
# > 形式に合わせて加工しなければいけないのです。識別用のヘッダをつけるとか、圧縮するとか、そんな
# > ことです。今回は「はりぼてOS」の都合のよい形式にしたいので、そのためのプログラムを作りました。
# > bim2hrb.exeです。このプログラムもそのうち紹介しますが、今はまだダメです。
#
# > 「30日でできる!OS自作入門」 p70-71
# > 　今回はその他にも1行追加しています。INSTRSET命令です。これは何かというと、このプログラムは486用のものですよ〜、
# > とnaskに教えているだけです。naskはこれを見ると、「ほほう、そうか。それならEAXという単語がきたら、これは
# > レジスタ名だと解釈しよう」と思ってくれます。何も指定しないと、8086という非常に古い、しかも16ビットレジスタしか
# > 持っていないCPU用に書かれたプログラムだと思い込んでしまい、EAXという単語に遭遇しても、「これはラベルか定数だな」
# > と誤解してしまうのです。
# > 　486用だと書いても、486でしか動かない機械語が出てくるというわけではなくて、単に単語の解釈の問題です。
# > だから486用モードでも16ビットレジスタだけを使っていれば、8086でも動く機械語になります。
# > CPUの家系図(インテルの場合)|8086->80186->286->386->486->Pentium->PentiumPro->PentiumII->PentiumIII->Pentium4->...
# >                            | 16 bit CPU     | 32 bit CPU
#
# Cファイルをリンカスクリプトを用いてコンパイル
# -march=i486        | Intel CPU 486用にコンパイルすることを指定. 「30日でできる!OS自作入門」 p70-71 に詳述.
# -m32               | > 32bit アプリケーションの作成は -m32 オプションをつけることで可能
#                    | > [「C」64bit のGCC で 32bit アプリケーションを作成する環境構築 ( CentOS 6.4 ) - プログラム日記](http://a4dosanddos.hatenablog.com/entry/2015/09/19/131052)
# -nostdlib          |
# -g                 | generates debug information to be used by GDB debugger
#                    | > | -g0 | no debug information
#                    | > | -g1 | minimal debug information
#                    | > | -g  | default debug information
#                    | > | -g3 | maximal debug information
#                    | > [gcc -g option flag (debug)](https://www.rapidtables.com/code/linux/gcc/gcc-g.html)
#                    |
# -O0                | > 最適化を無効にします。デバッグやコンパイルをすばやく行うには、このオプションを使用します。
#                    | > [最適化オプションのまとめ](http://wwweic.eri.u-tokyo.ac.jp/computer/manual/altix/compile/Fortran/Intel_Fdoc91/main_for/mergedProjects/optaps_for/common/optaps_lev_opts.htm)
#                    | -g0 | no debug information
#                    | -g1 | minimal debug information
#                    | -g  | default debug information
#                    | -g3 | maximal debug information
#                    |
# -T <linker-script> | file.lds | Binutils LD Linker Script, 「はりぼてOS」の形式を指定
	gcc -march=i486 -m32 -nostdlib -g -O0 \
		-T os.lds \
		-o $@ \
		${BOOTPACK_FILES}
# disassemble する
	objdump ${OBJDUMP_FLAGS} $@ > ${DEBUG_DIR}/$@.dasm

${OSNAME}.sys : asmhead.bin bootpack.hrb
%.sys :
	@make make-debug-dir
# asmhead.bin => bootpack.hrb の順にバイナリを並べる
# 拡張子 .hrb はおそらくHaRiBoteの略
	cat $^ > $@
	objdump ${OBJDUMP_FLAGS} $@ > ${DEBUG_DIR}/$@.dasm

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

.PHONY : make-debug-dir
make-debug-dir :
	@if [ ! -d ${DEBUG_DIR} ]; then mkdir ${DEBUG_DIR}; fi

#===============================================================================
.PHONY : clean
clean :
# lstは残しておいてもいいと思うのでcleanに入れていない
	@rm *.img *.bin *.sys *.hrb *.o

.PHONY : debug
debug:
	make img
	qemu-system-i386 -fda haribote.img -gdb tcp::10000 -S

