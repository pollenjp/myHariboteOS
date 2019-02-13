section .text
        GLOBAL  _io_hlt
        GLOBAL  _write_mem8;

;=======================================================================================================================
_io_hlt:  ; void _io_hlt(void);
        HLT
        RET

;=======================================================================================================================
_write_mem8:  ; void _write_mem8(int addr, int data);
; int型 (4 Byte) の data を上位3Byteを切り落とし 1 Byte (8 bit) にして addr 番地に代入
; | Parameters
; | addr | int (4 Byte) | メモリアドレス
; | data | int (4 Byte) | 代入したい値, 下位1Byteのみ代入
; | Return
;===================
; > 「30日でできる!OS自作入門」 p69
; > C言語には直接メモリの番地を指定して書き込むための命令がありません(*).
; > * : うそだ、あるじゃないか! と思ったあなたは、この本の対象読者としては、かなり物知りである。
;===================
; > 「30日でできる!OS自作入門」 p70
; > 　すでにCPUは32ビットモードになっていますので、積極的に32ビットレジスタを使っています。ここで16ビットレジスタを
; > 使うこともできなくはないのですが、機械語のバイト数は増えるし、実行速度も遅くなるしで、いいことないです。
;===================
; 【関数呼び出し時のスタックの使い方】 @pollenjp
; 　C言語では関数呼び出しによって以下のような手順を踏む. 呼び出す関数の定義と呼び出し部分を以下とする.
; `int sample(int a, int b, char c){...}`
; `aaa = sample(111, 222, 'A'){...}`
; 1. まずスタックポインタ(SP,以下では32bitであることを考慮してESPと書く)
;    を「戻り先番地」と「仮引数」が必要な分のバイト分だけ増やす.
;    ESP <- ESP + byte(戻り先番地) + byte(int) + byte(int) + byte(char)
;    Note: - sizeof() は型のバイト数を表す.
;          - 以下では簡単のため byte(戻り先番地) = byte(ret_addr) と表記する.
; 2. [ESP]に byte(ret_addr) 分を消費して「戻り先番地」を保存.
;    [ESP + byte(ret_addr) ] に第1引数から順番に実引数値を格納していく. つまり,
;    [ESP + byte(ret_addr) ] 〜 [ESP + byte(ret_addr) + byte(int) - 1] の byte(ret_addr)分を使う.
;    そして,他の引数についても
;    [ESP + byte(ret_addr) + byte(int)]                          <- 111
;    [ESP + byte(ret_addr) + byte(int) + byte(int)]              <- 222
;    [ESP + byte(ret_addr) + byte(int) + byte(int) + byte(char)] <- 'A'
;    Note : - 仮引数と実引数の違いは定義の時に使うのが仮引数・関数呼び出しで使うのが実引数という程度でOK)
; 3. 関数内変数はESPを更新してスタックに積まれていく.
; 4. return が呼ばれたタイミングでESPを Step2 の段階に戻し,関数内変数が確保していたメモリは開放される.
; 5. return値については以下.
;    > C言語では関数の戻り値は1個以下に決められているので戻り値の記憶には 高速なレジスタを使うのが普通.
;    > [プログラミング序論　page10](http://www.ibe.kagoshima-u.ac.jp/edu/gengo0/p10.html)
; 参考: [プログラミング序論　page10](http://www.ibe.kagoshima-u.ac.jp/edu/gengo0/p10.html)
;===================
; > 「熱血アセンブラ入門」 p294
; > i386では引数もスタック経由で渡される
;===================
; > 「30日でできる!OS自作入門」 p70
; 自由に使っていいレジスタは EAX,ECX,EDX のみで他のレジスタは読み取り専用
; EAX,ECX,EDX 以外のレジスタは,
; > C言語部分の機械語が、C言語にとって大事な値を記憶させるために使っているからです.
																		; [ESP]  , ..., [ESP+3] に 関数の戻り先アドレス(32bit)が入っている.
        MOV     ECX, DWORD [ESP+4]  ; [ESP+4], ..., [ESP+7] に (int)addr が入っている. アドレッシングは32bit.
        MOV     AL,  BYTE  [ESP+8]  ; [ESP+8], ..., [ESP+11]に (int)data が入っている.
																		; int型(4Byte)のdataを上位3Byteを切り落とし1Byte(8bit)にしてALに代入
        MOV     BYTE [ECX], AL
        RET

