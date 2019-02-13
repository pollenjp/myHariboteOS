# day04 ポインタに挑戦 - harib01c

## imgファイル作成

```
$ make
```

## 実行

```
$ make run
```

`ref/`には実行に関係ないファイルをしまっておくことにした

## `(char *)`をつけなかった時のエラー

```
gcc -march=i486 -m32 -nostdlib \
        -T os.lds \
        -o bootpack.hrb \
        bootpack.c nasmfunc.o
bootpack.c: In function ‘HariMain’:
bootpack.c:16:7: warning: assignment makes pointer from integer without a cast [-Wint-conversion]
     p = i;          // 番地の代入
       ^
cat asmhead.bin bootpack.hrb > haribote.sys
```

## メモリに書き込む箇所の逆アセンブル

`bootpack.c`の`HariMain()`の中の以下の箇所の逆アセンブル

```
  int i;    // VRAM用番地指定変数, 32bit(4 Byte)番地
  char *p;  // *pは 1 Byte値, pは32bit(4 Byte)番地
  for (i = 0xa0000; i <= 0xaffff; i++){
    // > VRAMは0xa0000～0xaffffの64KBです。厳密に言うと、320x200=64000なので、62.5KBですが.
    // > [INT(0x10); ビデオ関係](http://oswiki.osask.jp/?%28AT%29BIOS#n5884802)
    // 　なおこのグラフィックバッファの開始番地 0xaffff は `asmhead.asm` ないで メモリアドレスを指す変数 VRAM(=0x0ff8)
    // に保存されている. (`DWORD [VRAM]`)
                     //                                   | 擬似アセンブリコード
    p = (char *) i;  // 番地の代入                        | MOV ECX,i
    *p = i & 0x0f;   // 0-15 の値を期待するものである.    | MOV BYTE [ECX],(i & 0x0f)
  }
```

逆アセンブル結果(`bootpack.hrb.dasm`)

```
  30:	55                   	push   ebp
  31:	89 e5                	mov    ebp,esp
  33:	83 ec 18             	sub    esp,0x18
  36:	c7 45 f4 00 00 0a 00 	mov    DWORD PTR [ebp-0xc],0xa0000    # initialize i = 0xa0000
                                                                  # ebp-0xc  : i
                                                                  # ebp-0x10 : p
  3d:	eb 16                	jmp    0x55
  3f:	8b 45 f4             	mov    eax,DWORD PTR [ebp-0xc]        # p = (char *) i; |
  42:	89 45 f0             	mov    DWORD PTR [ebp-0x10],eax       # ----------------|
  45:	8b 45 f4             	mov    eax,DWORD PTR [ebp-0xc]        # i & 0xf |
  48:	83 e0 0f             	and    eax,0xf                        # --------|
  4b:	88 c2                	mov    dl,al                          # *p = i & 0x0f |
  4d:	8b 45 f0             	mov    eax,DWORD PTR [ebp-0x10]       #               |
  50:	88 10                	mov    BYTE PTR [eax],dl              # --------------|
  52:	ff 45 f4             	inc    DWORD PTR [ebp-0xc]            # i++
  55:	81 7d f4 ff ff 0a 00 	cmp    DWORD PTR [ebp-0xc],0xaffff    # forの条件判定部分
  5c:	7e e1                	jle    0x3f
  5e:	e8 0d 00 00 00       	call   0x70
  63:	eb f9                	jmp    0x5e
  30:	55                   	push   ebp
  31:	89 e5                	mov    ebp,esp
  33:	83 ec 18             	sub    esp,0x18
```

