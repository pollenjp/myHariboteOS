; hello-os
; TAB=4

    DB      0xeb, 0x4e, 0x90
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

    DB  0xb8, 0x00, 0x00, 0x8e, 0xd0, 0xbc, 0x00, 0x7c
    DB  0x8e, 0xd8, 0x8e, 0xc0, 0xbe, 0x74, 0x7c, 0x8a
    DB  0x04, 0x83, 0xc6, 0x01, 0x3c, 0x00, 0x74, 0x09
    db  0xb4, 0x0e, 0xbb, 0x0f, 0x00, 0xcd, 0x10, 0xeb
    db  0xee, 0xf4, 0xeb, 0xfd

; Message

    db      0x0a, 0x0a
    db      "hello, world"
    db      0x0a
    db      0

    resb    0x1fe-($-$$)

    db      0x55, 0xaa

; ブート以外の記述

    db      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    resb    4600
    db      0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    resb    1469432
