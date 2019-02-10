
BOTPAK  EQU    0x00280000    ; BOOTPACK     | bootpackのロード先
DSKCAC  EQU    0x00100000    ; DISK CACHE   | ディスクキャッシュの場所
DSKCAC0 EQU    0x00008000    ; DISK CACHE 0 | ディスクキャッシュの場所（リアルモード）

; BOOT_INFO関係
; > メモしている場所は0x0ff0番地周辺ですが、メモリマップによるとこのへんも誰にも使われていないようでした
CYLS    EQU     0x0ff0      ; ブートセクタが設定する
LEDS    EQU     0x0ff1      ; LED STATE
VMODE   EQU     0x0ff2      ; VIDEO MODE | 色数に関する情報（何ビットカラーか）
SCRNX   EQU     0x0ff4      ; SCREEN X   | 解像度X
SCRNY   EQU     0x0ff6      ; SCREEN Y   | 解像度Y
VRAM    EQU     0x0ff8      ; VIDEO RAM  | グラフィックバッファの開始番地

        ;=======================================================================
        ORG     0xc200      ; 0xc200 = 0x8000 + 0x4200
                            ; イメージファイルの 0x4200 アドレス番目に書き込まれている
                            ; また,先で 0x8000 以降を使うことに決めている

        ;=======================================================================
        ; [INT(0x10); ビデオ関係](http://oswiki.osask.jp/?%28AT%29BIOS#n5884802)
        ; ビデオモード設定
        ;   AH = 0x00;
        ;   AL = モード： (マイナーな画面モードは省略しています)
        ;     0x03：16色テキスト、80x25
        ;     0x12：VGAグラフィックス、640x480x4bitカラー、独自プレーンアクセス
        ;     0x13：VGAグラフィックス、320x200x8bitカラー、パックドピクセル
        ;     0x6a：拡張VGAグラフィックス、800x600x4bitカラー、独自プレーンアクセス（ビデオカードによってはサポートされない）
        ;   戻り値：なし
        MOV     AL, 0x13    ; VGA graphics, 320x200x(8 bit color)
        MOV     AH, 0x00
        INT     0x10

        ;=======================================================================
        ; 画面モードをメモする
        MOV     BYTE [VMODE], 8           ; Video MODE
        MOV     WORD [SCRNX], 320         ; SCReeN X
        MOV     WORD [SCRNY], 200         ; SCReeN Y
        MOV     DWORD [VRAM], 0x000a0000  ; Video RAM
                                          ; > VRAMは0xa0000～0xaffffの64KBです。厳密に言うと、320x200=64000なので、62.5KBですが.
                                          ;
                                          ; > [VRAM]に 0xa0000 を入れているのですが、PC の世界で VRAM というのはビデオラムのことで
                                          ; > 「video RAM」と書き、画面用のメモリのことです。このメモリは、もちろんデータを記憶することがい
                                          ; > つも通りできます。しかしVRAMは普通のメモリ以上の存在で、それぞれの番地が画面上の画素に対応
                                          ; > していて、これを利用することで画面に絵を出すことができるのです。

        ;=======================================================================
        ; [INT(0x16); キーボード関係 - (AT)BIOS - os-wiki](http://oswiki.osask.jp/?%28AT%29BIOS#lb9f3e72)
        ; キーロック＆シフト状態取得
        ;   AH = 0x02;
        ;   戻り値：
        ;   AL == 状態コード：
        ;     bit0：右シフト
        ;     bit1：左シフト
        ;     bit2：Ctrl
        ;     bit3：Alt
        ;     bit4：Scrollロック
        ;     bit5：Numロック
        ;     bit6：Capsロック
        ;     bit7：Insertモード
        ; BIOS (16 bit mode) から情報を取得
        MOV     AH, 0x02    ; キーロック＆シフト状態取得
        INT     0x16        ; Keyboard BIOS
        MOV     [LEDS], AL  ; LED State

        ; PICが一切の割り込みを受け付けないようにする
        ; AT互換機の仕様では、PICの初期化をするなら、
        ; こいつをCLI前にやっておかないと、たまにハングアップする
        ; PICの初期化はあとでやる

        MOV     AL, 0xff
        OUT     0x21, AL
        NOP                   ; OUT命令を連続させるとうまくいかない機種があるらしいので
        OUT     0xa1, AL

        CLI                   ; さらにCPUレベルでも割り込み禁止

        ; CPUから1MB以上のメモリにアクセスできるように、A20GATEを設定

        CALL waitkbdout
        MOV  AL,0xd1
        OUT  0x64,AL
        CALL waitkbdout
        MOV  AL,0xdf          ; enable A20
        OUT  0x60,AL
        CALL waitkbdout

        ; プロテクトモード移行
        
        ;[INSTRSET "i486p"]    ; i486の命令まで使いたいという記述
        ; ここで指定するのではなくgccでcompileする際にi486で指定

        LGDT [GDTR0]   ; 暫定GDTを設定
        MOV  EAX,CR0
        AND  EAX,0x7fffffff ; bit31を0にする（ページング禁止のため）
        OR  EAX,0x00000001 ; bit0を1にする（プロテクトモード移行のため）
        MOV  CR0,EAX
        JMP  pipelineflush
pipelineflush:
        MOV  AX,1*8   ;  読み書き可能セグメント32bit
        MOV  DS,AX
        MOV  ES,AX
        MOV  FS,AX
        MOV  GS,AX
        MOV  SS,AX

        ; bootpackの転送

        MOV  ESI,bootpack ; 転送元
        MOV  EDI,BOTPAK  ; 転送先
        MOV  ECX,512*1024/4
        ;MOV  ECX, 131072
        CALL memcpy

        ; ついでにディスクデータも本来の位置へ転送

        ; まずはブートセクタから

        MOV  ESI,0x7c00  ; 転送元
        MOV  EDI,DSKCAC  ; 転送先
        MOV  ECX,512/4
        ;MOV  ECX, 128
        CALL memcpy

        ; 残り全部

        MOV  ESI,DSKCAC0+512 ; 転送元
        MOV  EDI,DSKCAC+512 ; 転送先
        MOV  ECX,0
        MOV  CL,BYTE [CYLS]
        IMUL ECX,512*18*2/4 ; シリンダ数からバイト数/4に変換
        ;IMUL ECX, 4608
        SUB  ECX,512/4  ; IPLの分だけ差し引く
        ;SUB  ECX, 128  ; IPLの分だけ差し引く
        CALL memcpy

        ; asmheadでしなければいけないことは全部し終わったので、
        ; あとはbootpackに任せる
        
        ; bootpackの起動

        MOV  EBX,BOTPAK
        MOV  ECX,[EBX+16]
        ADD  ECX,3   ; ECX += 3;
        SHR  ECX,2   ; ECX /= 4;
        JZ  skip   ; 転送するべきものがない
        MOV  ESI,[EBX+20] ; 転送元
        ADD  ESI,EBX
        MOV  EDI,[EBX+12] ; 転送先
        CALL memcpy
skip:
        MOV  ESP,[EBX+12] ; スタック初期値
        JMP  DWORD 2*8:0x0000001b

waitkbdout:
        IN   AL,0x64
        AND   AL,0x02
        JNZ  waitkbdout  ; ANDの結果が0でなければwaitkbdoutへ
        RET

memcpy:
        MOV  EAX,[ESI]
        ADD  ESI,4
        MOV  [EDI],EAX
        ADD  EDI,4
        SUB  ECX,1
        JNZ  memcpy   ; 引き算した結果が0でなければmemcpyへ
        RET
        ; memcpyはアドレスサイズプリフィクスを入れ忘れなければ、ストリング命令でも書ける

        ALIGNB 16
GDT0:
        RESB 8    ; ヌルセレクタ
        DW  0xffff,0x0000,0x9200,0x00cf ; 読み書き可能セグメント32bit
        DW  0xffff,0x0000,0x9a28,0x0047 ; 実行可能セグメント32bit（bootpack用）

        DW  0
GDTR0:
        DW  8*3-1
        DD  GDT0

        ALIGNB 16
bootpack:

