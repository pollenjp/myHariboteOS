; BOOT_INFO関係
; > メモしている場所は0x0ff0番地周辺ですが、メモリマップによるとこのへんも誰にも使われていないようでした
CYLS    EQU     0x0ff0      ; ブートセクタが設定する
LEDS    EQU     0x0ff1      ; LED State
VMODE   EQU     0x0ff2      ; Video MODE | 色数に関する情報（何ビットカラーか）
SCRNX   EQU     0x0ff4      ; SCReeN X   | 解像度X
SCRNY   EQU     0x0ff6      ; SCReeN Y   | 解像度Y
VRAM    EQU     0x0ff8      ; Video RAM  | グラフィックバッファの開始番地

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

fin:
        HLT
        JMP     fin

