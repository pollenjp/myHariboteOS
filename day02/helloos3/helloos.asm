; hello-os
; TAB=4

        ORG     0x7c00          ; このプログラムがメモリ上のどこによみこまれるのか

; ディスクのための記述

        JMP     entry
        DB      0x90
        DB      "HELLOIPL"      ; ブートセレクタの名前を自由にかいていよい  (8Byte)
        DW      512             ; 1セクタの大きさ                           (512にしなければならない)
        DB      1               ; クラスタの大きさ                          (1セクタにしなければならない)
        DW      1               ; FATがどこから始まるか                     (普通は1セクタ目からにする)
        DB      2               ; FATの個数                                 (2にしなければならない)
        DW      224             ; ルートディレクトリ領域の大きさ            (普通は224エントリにする)
        DW      2880            ; このドライブの大きさ                      (2880セクタにしなければならない)
        DB      0xf0            ; メディアタイプ                            (0xf0にしなければならない)
        DW      9               ; FAT領域の長さ                             (9セクタにしなければならない)
        DW      18              ; 1トラックにいくつのセクタがあるか         (18にしなければならない)
        DW      2               ; ヘッドの数                                (2にしなければならない)
        DD      0               ; パーティションを使っていないのでここは必ず0
        DD      2880            ; このドライブの大きさをもう一度書く
        DB      0, 0, 0x29      ; よくわからないけどこの値にしておくといいらしい
        DD      0xffffffff      ; たぶんボリュームシリアル番号
        DB      "HELLO-OS   "   ; ディスクの名前                            (11Byte)
        DB      "FAT12   "      ; フォーマットの名前                        (8Byte)
        RESB    18              ; とりあえず18バイト開けておく

; Program Main Body
entry:
        MOV     AX, 0            ; レジスタの初期化
        MOV     SS, AX
        MOV     SP, 0x7c00
        MOV     DS, AX
        MOV     ES, AX

        MOV     SI, msg
putloop:
        MOV     AL, [SI]        ; BYTE (accumulator low)
        ADD     SI, 1           ; increment
        CMP     AL, 0           ; compare (<end msg>)
        JE      fin             ; jump to fin if equal to 0
        MOV     AH, 0x0e        ; AH = 0x0e
        MOV     BX, 15          ; BH = 0, BL = <color code>
        INT     0x10            ; interrupt BIOS
        JMP     putloop
fin:
        HLT
        JMP     fin

msg:
        DB      0x0a, 0x0a
        DB      "hello, world"
        DB      0x0a
        DB      0               ; end msg

        ;RESB    0x7dfe-($-$$)   ; これだとエラーが出た。。。
        RESB    0x7dfe-0x7c00-($-$$)    ; same "RESB    0x1fe-($-$$)"
                                        ; from 0x00 to 0x1ff : 512 Byte
                                        ; 2Byte分残す

        DB      0x55, 0xaa

; ブート以外の記述

        DB      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
        RESB    4600
        DB      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
        RESB    1469432

