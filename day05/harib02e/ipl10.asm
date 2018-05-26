; haribote-ipl
; TAB=4

CYLS    EQU     10              ; どこまで読み込むか (CYLinderS)

        ORG     0x7c00          ; このプログラムがメモリ上のどこに読み込まれるか

; discription for floppy disk
        JMP     entry           ; BS_JmpBoot
        DB      0x90            ; BS_JmpBoot
        DB      "HARIBOTE"      ; BS_OEMName    8B
        DW      512             ; BPB_BytsPerSec
        DB      1               ; BPB_SecPerClu
        DW      1               ; BPB_RevdSecCnt    : このBPBを含むブートセクタのみ
        DB      2               ; BPB_NumFATs       : FATの個数 (このフィールドの値は常に2に設定すべきである)
        DW      224             ; BPB_RootEntCnt
        DW      2880            ; BPB_TotSec16
        DB      0xf0            ; BPB_Media
        DW      9               ; BPB_FATSz16
        DW      18              ; BPB_SecPerTrk
        DW      2               ; BPB_NumHeads
        DD      0               ; BPB_HiddSec
        DD      2880            ; BPB_TotSec32

        ; FAT12/16におけるオフセット36以降のフィールド
        DB      0x00            ; BS_DrvNum
        DB      0x00            ; BS_Reserved1
        DB      0x29            ; BS_BootSig

        DD      0xffffffff      ; BS_VolID
        DB      "HARIBOTEOS "   ; BS_VolLab     11B
        DB      "FAT12   "      ; BS_FilSysType 8B
        RESB    18              ; とりあえず18バイト開けておく


; START BS_BootCode 64(0x14)   448(0x1C0)
entry:
        MOV     AX, 0           ; initialize Accumulator(resister)
        MOV     SS, AX          ; Stack Segment
        MOV     SP, 0x7c00      ; Stack Pointer
        MOV     DS, AX          ; Data Segment      : 番地指定のとき重要


; load disk
        MOV     AX, 0x0820
        MOV     ES, AX          ; buffer address       0x0820
        MOV     CH, 0           ; cylinder  0
        MOV     DH, 0           ; head      0
        MOV     CL, 2           ; sector    2

readloop:
        MOV     SI, 0           ; 失敗回数を数えるレジスタ

retry:
        MOV     AH, 0x02        ; acumulator high   : 0x02 - read disk
        MOV     AL, 1           ; acumulator low    : sector    1
        MOV     BX, 0           ; buffer address    0x0000
                                ; ES:BX, ESは代入済み
        MOV     DL, 0x00        ; data low          : drive number
        INT     0x13            ; BIOS call
        JNC     next            ; jump if not carry

        ADD     SI, 1           ; increment SI
        CMP     SI, 5
        JAE     error           ; SI >= 5 then jump to error

        MOV     AH, 0x00        ; 0x00 - reset
        MOV     DL, 0x00        ; A drive
        INT     0x13            ; reset drive
        JMP     retry

next:
        ; add 0x20 to ES
        ; 代わりにBXに512を足してもよい
        MOV     AX, ES          ; 0x20だけアドレスを進める
        ADD     AX, 0x0020      ; 512 / 16 = 0x20
        MOV     ES, AX

        ; increment CL (sector number)
        ADD     CL, 1
        CMP     CL, 18
        JBE     readloop

        ; ディスクのウラ面
        MOV     CL, 1           ; reset sector
        ADD     DH, 1           ; reverse HEAD
        CMP     DH, 2
        JB      readloop

        ; next Cylinder
        mov     DH, 0           ; reset HEAd
        ADD     CH, 1           ; cylinder += 1
        CMP     CH, CYLS
        JB      readloop

; ブートセクタの読み込みが終わったのでOS本体を実行
		MOV		[0x0ff0],CH		; IPLがどこまで読んだのかをメモ
        JMP     0xc200

error:
        MOV     SI, msg

putloop:
        MOV     AL, [SI]        ; BYTE (accumulator low)
        ADD     SI, 1           ; increment
        CMP     AL, 0           ; 終了条件
        JE      fin             ; jump to fin if equal to 0

        MOV     AH, 0x0e        ; 1 char-function
        MOV     BX, 15          ; color code
        INT     0x10            ; interrupt, call BIOS
        JMP     putloop

fin:
		HLT						; 何かあるまでCPUを停止させる
		JMP		fin				; 無限ループ

msg:
        DB      0x0a, 0x0a
        DB      "load error"
        DB      0x0a
        DB      0               ; end point

        RESB    0x7dfe - 0x7c00 - ($ - $$)  ; 現在の場所から0x1fdまで(残りの未使用領域)を0で埋める。
                                            ; 0x7c00スタートなのでその分を引いている
; END BS_BootCode
        DB      0x55, 0xaa      ; BS_BootSign, boot signature
