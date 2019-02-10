; FAT12 format

; - [Tips　IA32（x86）命令一覧](http://softwaretechnique.jp/OS_Development/Tips/IA32_instructions.html)
;   - [Add命令](http://softwaretechnique.jp/OS_Development/Tips/IA32_Instructions/ADD.html)
;   - [MOV命令](http://softwaretechnique.jp/OS_Development/Tips/IA32_Instructions/MOV.html)

; リトルエンディアン
; フロッピーディスク | cylinder | 0,1,...,79 (外側から)
;                    | head     | 0,1 (両面記憶方式)
;                    | sector   | 1,2,...,18 (1 cylinderあたり)
;                    |          | 512 Byte per sector
;                    | 1440 [KB] = 80x2x18x512
;                    | C0-H0-S1 : cylinder 0 - head 0 - sector 0

;=======================================================================================================================
; ブートセクタ (512バイト)
; C0-H0-S1 : cylinder 0 - head 0 - sector 0
; > 0x00007c00 - 0x00007dff ： ブートセクタが読み込まれるアドレス
; > [ソフトウェア的用途区分 - (AT)memorymap - os-wiki](http://oswiki.osask.jp/?%28AT%29memorymap#qd4cd666)

CYLS    EQU     10              ; どこまで読み込むか (CYLinderS)
                                ; EQUal 定数宣言(nasm)
OS_BODY EQU      0xc200         ; OS本体が読み込まれている相対アドレス

        ;=======================================================================
        ; このプログラムがメモリ上のどこによみこまれるのか
        ; > [7.1.1 ORG: Binary File Program Origin - NASM - The Netwide Assembler](https://www.nasm.us/doc/nasmdoc7.html#section-7.1.1)
        ORG     0x7c00

        ;=======================================================================
        ; ディスクのための記述
        ; http://elm-chan.org/docs/fat.html#notes
        ; BPB(BIOS Parameter Block)
                                ; Name             | Offset              | Byte | Description
                                ;                                               | 
        ; FAT12/16/32共通フィールド(オフセット0～35)
        JMP     entry           ; BS_JmpBoot       | 0x0000-0x0002 0-2   |    3 | Jump to Bootstrap
        DB      0x90            ;                                               | ブートストラッププログラムへのジャンプ命令(x86命令)。
                                ;                                               | 0xEB, 0x??, 0x90 (ショート ジャンプ+NOP)
        DB      "HARIBOTE"      ; BS_OEMName       | 0x0003-0x000a 3-10  |    8 | これは単なる名前である
        DW      512             ; BPB_BytsPerSec   | 0x000b-0x000c 11-12 |    2 | セクタあたりのバイト数.
                                ;                                               | 512, 1024, 2048, 4096
                                ;                                               | Bytes Per Cluster
        DB      1               ; BPB_SecPerClus   | 0x000d           13 |    1 | アロケーションユニット(割り当て単位)当たりのセクタ数
                                ;                                               | アロケーションユニットはクラスタと呼ばれている
                                ;                                               | Secters Per Cluster
        DW      1               ; BPB_RsvdSecCnt   | 0x000e-0x000f 14-15 |    2 | 予約領域のセクタ数 (少なくとも
                                ;                                               | このBPB(BIOS Parameter Block)を含むブート
                                ;                                               | セクタそれ自身が存在するため0であってはならない)
        DB      2               ; BPB_NumFATs      | 0x0010           16 |    1 | FATの個数 
                                ;                                               | (このフィールドの値は常に2に設定すべきである)
        DW      224             ; BPB_RootEntCnt   | 0x0011-0x0012 17-18 |    2 | FAT12/16ボリュームではルートディレクトリに
                                ;                                               | 含まれるディレクトリエントリの数を示す.
                                ;                                               | このフィールドにはディレクトリテーブルのサイズが
                                ;                                               | 2セクタ境界にアライメントする値,つまり,
                                ;                                               | BPB_RootEntCnt*32がBPB_BytsPerSecの偶数倍になる値
                                ;                                               | を設定すべきである. (32というのはディレクトリエントリ1個のサイズ)
                                ;                                               | 最大の互換性のためにはFAT16では512に設定すべき.
                                ;                                               | FAT32ボリュームではこのフィールドは使われず,
                                ;                                               | 常に0でなければならない.
                                ;                                               | 224x32=4x16x32=4x512
                                ;                                               | 512=32x16
                                ;                  |                     |      | 
        DW      2880            ; BPB_TotSec16     | 0x0013-0x0014 19-20 |    2 | ボリュームの総セクタ数(古い16ビットフィールド).
                                ;                                               | ボリュームの4つの領域全てを含んだセクタ数.
                                ;                                               | FAT12/16でボリュームのセクタ数が0x10000以上になる
                                ;                                               | ときは,このフィールドには無効値(0)が設定され,真の
                                ;                                               | 値がBPB_TotSec32に設定される.
                                ;                                               | FAT32ボリュームでは,このフィールドは必ず無効値で
                                ;                                               | なければならない.
                                ;                                               | 0x10000=(2^4)^4=65536 > 2880
                                ;                  |                     |      | 
        DB      0xf0            ; BPB_Media        | 0x0015           21 |    1 | 区画分けされた固定ディスクドライブでは0xF8が標準
                                ;                                               | 値である. 区画分けされないリムーバブルメディアで
                                ;                                               | は0xF0がしばしば使われる. このフィールドに有効な
                                ;                                               | 値は,0xF0,0xF8,0xF9,0xFA,0xFB,0xFC,0xFD,0xFE,0xFF
                                ;                                               | で,ほかに重要な点はこれと同じ値をFAT[0]の下位8
                                ;                                               | ビットに置かなければならないということだけである.
                                ;                                               | これはMS-DOS 1.xでメディアタイプの設定に遡り,
                                ;                                               | 既に使われていない。
                                ;                  |                     |      | 
        DW      9               ; BPB_FATSz16      | 0x0016-0x0017 22-23 |    2 | 1個のFATが占めるセクタ数.
                                ;                                               | このフィールドはFAT12/FAT16ボリュームでのみ使われる.
                                ;                                               | FAT32ボリュームでは必ず無効値(0)でなければならず,
                                ;                                               | 代わりにBPB_FATSz32が使われる. FAT領域のサイズは,
                                ;                                               | この値 * BPB_NumFATsセクタとなる。
                                ;                  |                     |      | 
        DW      18              ; BPB_SecPerTrk    | 0x0018-0x0019 24-25 |    2 | トラック当たりのセクタ数
        DW      2               ; BPB_NumHeads     | 0x001a-0x001b 26-27 |    2 | ヘッドの数
        DD      0               ; BPB_HiddSec      | 0x001c-0x001f 28-31 |    4 | ストレージ上でこのボリュームの手前に存在する隠れ
                                ;                                               | た物理セクタの数. 一般的にIBM PCのディスクBIOSで
                                ;                                               | アクセスされるストレージに関するものであり,どの
                                ;                                               | ような値が入るかはシステム依存. ボリュームがスト
                                ;                                               | レージの先頭から始まる場合(つまりフロッピーディ
                                ;                                               | スクなど区画分けされていないもの)では常に0である
                                ;                                               | べきである.
                                ;                  |                     |      | 
        DD      0               ; BPB_TotSec32     | 0x0020-0x0023 32-35 |    4 | ボリュームの総セクタ数(新しい32ビットフィールド).
                                ;                                               | この値はボリュームの4つの領域全てを含んだセクタ数
                                ;                                               | である.
                                ;                                               | FAT12/16ボリュームで総セクタ数が0x10000未満のとき,
                                ;                                               | このフィールドは無効値(0)でなければならなず,真の
                                ;                                               | 値はBPB_TotSec16に設定される.
                                ;                                               | FAT32ボリュームでは常に有効値が入る.

        ;=======================================================================
        ; FAT12/16におけるオフセット36以降のフィールド
                                ; Name             | Offset              | Byte | Description
                                ;                  |                     |      | 
        DB      0x00            ; BS_DrvNum        | 0x0024           36 |    1 |
        DB      0x00            ; BS_Reserved1     | 0x0025           37 |    1 |
        DB      0x29            ; BS_BootSig       | 0x0026           38 |    1 |

        DD      0xffffffff      ; BS_VolID         | 0x0027-0x002a 39-42 |    4 | ボリュームシリアル番号
        DB      "HARIBOTEOS "   ; BS_VolLab        | 0x002a-0x0036 43-54 |   11 | ディスクの名前(ルートディレクトリに記録される11バイトのボリュームラベルに一致する)
        DB      "FAT12   "      ; BS_FilSysType    | 0x0036-0x003d 54-61 |    8 | フォーマットの名前
        RESB    18              ;                  | 0x003e-0x004f 62-79 |    8 | Reserve Bytes : [3.2.2 RESB and Friends: Declaring Uninitialized Data](https://www.nasm.us/doc/nasmdoc3.html#section-3.2.2)
                                ;                                               | 18バイト空けて 0x7c50 の直前まで埋める
                                ;                                               | naskでは0で初期化するみたいだがnasmだ
                                ;                                               | と初期化しない


        ;=======================================================================
        ; START BS_BootCode                                | 64      448
        ; (ブートストラッププログラム. システム依存フィールドで、未使用時はゼロで埋める。)
        ; 0x7c50
        ;
        ; rb (register byte),  rw (register word), rd (register double-word) 等の表記は
        ; https://www.intel.co.jp/content/dam/www/public/ijkk/jp/ja/documents/developer/IA32_Arh_Dev_Man_Vol2A_i.pdf
        ; によっている.
        ; >   | rb | rw | rd  |
        ; > 0 | AL | AX | EAX |
        ; > 1 | CL | CX | ECX |
        ; > 2 | DL | DX | EDX |
        ; > 3 | BL | BX | EBX |
        ; > 4 | AL | SP | ESP |
        ; > 5 | CL | BP | EBP |
        ; > 6 | DL | SI | ESI |
        ; > 7 | BL | DI | EDI |
        ; > imm8 － 即値バイト値。記号 imm8 は -128 から +127 までの符号付き数値である
        ; == 16 bit register ==
        ; AX : acumulator
        ; CX : Counter
        ; DX : Data
        ; BX : Base
        ; SP : Stack Pointer
        ; BP : Base  Pointer
        ; SI : Source      Index
        ; DI : Destination Index
        ; ES : Extra Segment
        ; CS : Code  Segment
        ; SS : Stack Segmengt
        ; DS : Data  Segmengt
        ; FS : no-name
        ; GS : no-name
entry:
                                ; [MOV命令 - Tips　IA32（x86）命令一覧　Mから始まる命令　MOV命令](http://softwaretechnique.jp/OS_Development/Tips/IA32_Instructions/MOV.html)
                                ; /r － 命令の ModR/M バイトに、レジスタ・オペランドと R/M オペランドの両方があることを示す.
                                ; Sreg － セグメントレジスタ. ビット割り当ては、ES=0,CS=1,SS=2,DS=3,FS=4,GS=5
                                ; |        | Byte | OpeCode | 命令,              | Description
        ; SSに0を代入
        ; DSに0を代入
        MOV     AX, 0           ; | B80000 |    3 | 0xB0+rb | MOV r8,   imm8     | imm8をr8に転送します
        MOV     SS, AX          ; | 8ED0   |    2 | 0x8E /r | MOV Sreg, r/m16※※  | r/m16をセグメントレジスタに転送します ※※　MOV命令のリンク先参照
                                ;                                                | MODR/M = mod + reg + r/m で構成されるのでそのうち
                                ;                                                | r/mが指定する数値が表すレジスタを使用
                                ;                                                | 例)
                                ;                                                | mod=11, reg=???, r/m=000(b)=0(decimal)=AX
                                ;                                                | reg には適当な値が入るのだろうか？
                                ;                                                | 今回)
                                ;                                                | D0= 11 010 000, r/m=000(b)=0(decimal)=AX
        MOV     SP, 0x7c00
        MOV     DS, AX          ; 番地指定のとき重要
                                ; どんなメモリの番地指定でもセグメントレジスタを一緒に指定しなくてはならない
                                ; default : DS (data segment)

        ;=====================
        ; LOAD DISK
        ; ディスクからの読み込み、ディスクへの書き込み、セクタのベリファイ、およびシーク
        ;   |       |読み込み時|書き込み時|ベリファイ時|シーク時|
        ;   | AH    | 0x02     | 0x03     | 0x04       | 0x0c   |
        ;   | AL    | 処理するセクタ数（連続したセクタを処理できる） | 0x01～0xff (1-255, 0)
        ;   | CH    | シリンダ番号 & 0xff | シリンダ番号は0x000～0x3ffの範囲で指定 （FDの場合は0x00～0x4f）
        ;   | CL    | セクタ番号(bit0-5)  | (シリンダ番号 & 0x300) >> 2 | 0x01～0xffの範囲で指定（FDの場合は0x01～0x12）
        ;   | DH    | ヘッド番号 | ヘッド番号は0x00～0xffの範囲で指定 （FDの場合は0x00～0x01）
        ;   | DL    | ドライブ番号
        ;   | ES:BX | バッファアドレス; （ベリファイ時、シーク時にはこれは参照しない）
        ;   | 戻り値：
        ;   |   FLAGS.CF | 0 | エラーなし, AH == 0
        ;   |            | 1 | エラーあり, AHにエラーコード（リセットファンクションと同じ）
        ;   > シークしてからアクセスしなければいけないというわけではない
        ;   > HDDへのアクセスの場合,BIOSはパーティションを理解せず,ハード的に1台のデバイスを1ドライブとして扱う事に注意すること.
        ;   > パーティション処理が必要なら自分でやるのだ.
        ;   > BIOSのせいだったかどうか忘れましたが,FDDのブートセクタをリードするとなぜか0x03～0x0aの8バイトの内容だけが正しく読み込まれません（変なごみが入っている）.
        ;   > I/Oを自分で制御してFDCをコントロールしたときはこんな変なことは起きません.
        MOV     AX, 0x0820
        MOV     ES, AX          ; Buffer Address | ES:BXのES
                                ; > 0x8000～0x81ffの512バイトにはあとでブートセクタの内容を入れようかなと思った
                                ; > なんで0x8000以降を使うことにしたのかというと、特に深い理由はないのですが、
                                ; > メモリマップを見たらこのへんは誰も使っていないようだったので、「はりぼてOS」
                                ; > が使わせてもらうことにしました

        ; C0-H0-S2
        MOV     CH, 0           ; シリンダ番号
        MOV     DH, 0           ; ヘッド番号
        MOV     CL, 2           ; セクタ番号

        MOV     SI, 0           ; 失敗回数を数える

readloop:
        MOV     SI, 0           ; 失敗回数を数える

retry:
        ; 失敗しても5回はドライブリセットを試す
        MOV     AH, 0x02        ; INT 0x13での読み込み指定
        MOV     AL, 1           ; 読み込む連続したセクタ数
        MOV     BX, 0           ; Buffer Address | ES:BXのBX
        MOV     DL, 0x00        ; ドライブ番号 Aドライブ
        INT     0x13            ; BIOS call -> エラーの時キャリーフラグが立つ
                                ; [INT(0x13); ディスク関係 - (AT)BIOS - os-wiki](http://oswiki.osask.jp/?%28AT%29BIOS#q5006ed6)
        JNC     next            ; Jump if Not CARRY FLAG == 1

        ADD     SI, 1
        CMP     SI, 5
        JAE     error           ; if SI >= 5 then jump to error

        MOV     AH, 0x00
        MOV     DL, 0x00        ; ドライブを指定
        INT     0x13            ; ドライブをリセット
        JMP     retry

next:
        ; 18セクタ(=18*512 Byte)を読み込む
        ; ディスクのうちの最初の10*2*18*512=184,320 Byte=180KB を読み込む
        ; C0-H0-S3 - C9-H1-S18
        ; メモリの 0x08200～0x34fff をディスクから読み込んだデータでびっしりと埋める
        ; メモリ番地0x8200～0xa3ffに読み込まれた
        ; > 　ループにする必要はなくて、ディスク読み込みのINT 0x13 のところで、ただALを17にしておけばすむのです
        ; > これをループにしたのは、ディスクBIOSの読み込みファンクション(*)の説明のところの「補足」のところを気にしたから
        ; > > 処理するセクタ数は0x01～0xffの範囲で指定（0x02以上を指定するときは、連続処理できる条
        ; > > 件があるかもしれないので注意-- FDの場合は、たぶん、複数のトラックにはまたがれないし、
        ; > > 64KB境界をこえてもいけない、だと思います）
        MOV     AX, ES          ; ADD ES,0x020 という命令がないのでこうしている
        ADD     AX, 0x0020      ; 512 / 16 = 0x20
        MOV     ES, AX          ; 0x20だけアドレスを進める
                                ; Buffer Register | ES:BX
                                ; ES:BX | ES*0x10 + BX
                                ; よって代わりにBXに512(=0x200)を足してもよい
        ; セクタ SECTOR
        ADD     CL, 1           ; セクタ番号を1増やす
        CMP     CL, 18
        JBE     readloop        ; 18セクタまで読み込んでいなければreadloopへ

        ; ヘッド HEAD
        MOV     CL, 1           ; reset SECTOR
        ADD     DH, 1           ; reverse HEAD
        CMP     DH, 2
        JB      readloop        ; if (DH < 2) つまり HEADが両面読み込み終えていなければreadloopへ

        ; シリンダ Cylinder
        MOV     DH, 0           ; reset HEAD
        ADD     CH, 1           ; CYLINDER += 1
        CMP     CH, CYLS        ; 定数CYLSと比較
        JB      readloop        ; CYLS分のCYLINDERを読み込み終えていないならばreadloopへ

        ;=======================================================================
        MOV     [0x0ff0], CH    ; IPLがどこまで読んだのかをメモ
                                ; CHがCYLINDERの番号を表す (最後にインクリメントされてから評価しているのでこの値は10)

        ; ブートセクタの読み込みが終わったのでOS本体を実行
        ;JMP     0xc200
        JMP     OS_BODY
        ;=======================================================================

fin:
        HLT
        JMP     fin             ; 無限ループ

error:
        MOV     SI, msg

putloop:
        MOV     AL, BYTE [DS:SI]; DS*0x10 + SI, DSを明示, ここではDS=0
        ADD     SI, 1           ; increment stack index
        CMP     AL, 0           ; compare (<end msg>)
        JE      fin             ; jump to fin if equal to 0

                                ; 一文字表示
        MOV     AH, 0x0e        ; AH = 0x0e
        MOV     BX, 15          ; BH = 0, BL = <color code>
        INT     0x10            ; interrupt BIOS
                                ; [INT(0x10); ビデオ関係 - (AT)BIOS - os-wiki](http://oswiki.osask.jp/?%28AT%29BIOS#n5884802)
        JMP     putloop

msg:
        DB      0x0a, 0x0a
        DB      "load error"
        DB      0x0a
        DB      0                   ; end msg

        ;RESB    0x7dfe-($-$$)      ; これだとエラーが出た。。。
                                    ; セクタサイズ 512 Byte なので 510 Byte目までを埋めたいときは
                                    ; 0x1fe - ($-$$) としてやればいい
                                    ; > you can tell how far into the section you are by using ($-$$)
                                    ; > [3.5 Expressions - NASM - The Netwide Assembler](https://www.nasm.us/doc/nasmdoc3.html#section-3.5)
        RESB    0x1fe-($-$$)        ; 現在の場所から 0x1fd (0x1fe の直前)
                                    ; まで(残りの未使用領域)を0で埋める
                                    ; (naskでは0で初期化するみたいだがnasm
                                    ; だと初期化しない) 
 
        ;=======================================================================
        ; END BS_BootCode       ; Name             | Offset              | Byte | Description
        DB      0x55, 0xaa      ; BS_BootSign      | 0x7dfe-0x7dff       | 510  |

