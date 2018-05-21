; http://tsurugidake.hatenablog.jp/entry/2017/08/15/202414
; hello-os
; TAB=4

        ORG     0x7c00          ; このプログラムがメモリ上のどこによみこまれるのか

; ディスクのための記述
;                                                   offset  Byte
        JMP     entry           ; BS_JmpBoot        0         : jump to bootstrap program
        DB      0x90            ; BS_JmpBoot                1
        DB      "HELLOIPL"      ; BS_OEMName        3       8
        DW      512             ; BPB_BytsPerSec    11      2 : バイト単位のセクタ サイズ
        DB      1               ; BPB_SecPerClus    13      1 : アロケーション ユニット(<-クラスタ)(割り当て単位)当たりのセクタ数
        DW      1               ; BPB_RsvdSecCnt    14      2 : 予約領域のセクタ数 (少なくともこのBPBを含むブートセクタそれ自身が存在するため、0であってはならない)
        DB      2               ; BPB_NumFATs       16      1 : FATの個数 (このフィールドの値は常に2に設定すべきである)
        DW      224             ; BPB_RootEntCnt    17      2 : ルートディレクトリに含まれるディレクトリエントリの数を示す
        DW      2880            ; BPB_TotSec16      19      2 : ボリュームの総セクタ数(古い16ビット フィールド)
        DB      0xf0            ; BPB_Media         21      1 : メディアタイプ(区画分けされた固定ディスク ドライブでは0xF8が標準値である。区画分けされないリムーバブル メディアでは0xF0がしばしば使われる)
        DW      9               ; BPB_FATSz16       22      2 : 1個のFATが占めるセクタ数
        DW      18              ; BPB_SecPerTrk     24      2 : トラック当たりのセクタ数
        DW      2               ; BPB_NumHeads      26      2 : ヘッドの数
        DD      0               ; BPB_HiddSec       28      4 : ストレージ上でこのボリュームの手前に存在する隠れた物理セクタの数(ボリュームがストレージの先頭から始まる場合(つまりフロッピー ディスクなど区画分けされていないもの)では常に0であるべきである。)
        DD      2880            ; BPB_TotSec32      32      4 : ボリュームの総セクタ数(新しい32ビット フィールド)


; FAT12/16におけるオフセット36以降のフィールド
        ;DB      0, 0, 0x29      ; 以下の３行に分けて記述
        DB      0x00            ; BS_DrvNum         36      1
        DB      0x00            ; BS_Reserved1      37      1
        DB      0x29            ; BS_BootSig        38      1

        DD      0xffffffff      ; BS_VolID          39      4 : ボリュームシリアル番号
        DB      "HELLO-OS   "   ; BS_VolLab         43      11 : ディスクの名前(ルート ディレクトリに記録される11バイトのボリューム ラベルに一致する)
        DB      "FAT12   "      ; BS_FilSysType     54      8 : フォーマットの名前
        RESB    18              ; とりあえず18バイト開けておく

; START BS_BootCode                                 64      448
; (ブートストラップ プログラム。システム依存フィールドで、未使用時はゼロで埋める。)
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

        ;RESB    0x7dfe-($-$$)  ; これだとエラーが出た。。。
        RESB    0x7dfe-0x7c00-($-$$)    ; 現在の場所から0x1fdまで(残りの未使用領域)を0で埋める。
; END BS_BootCode

        DB      0x55, 0xaa      ; BS_BootSign       510     2 : 以下の記述と同様
        ;DW      0xAA55

