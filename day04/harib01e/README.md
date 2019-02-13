# day04 ポインタの応用(2) - harib01e

## imgファイル作成

```
$ make
```

## 実行

```
$ make run
```

`ref/`には実行に関係ないファイルをしまっておくことにした

## 逆アセンブル

`bootpack.c`の`HariMain()`の中の以下の箇所の逆アセンブル

```
  int i;                        // VRAM用番地指定変数, 32bit(4 Byte)番地
  char * p = (char *) 0xa0000;  // *pは 1 Byte値, pは32bit(4 Byte)番地
  for (i = 0; i <= 0xffff; i++){
    // > VRAMは0xa0000～0xaffffの64KBです。厳密に言うと、320x200=64000なので、62.5KBですが.
    // > [INT(0x10); ビデオ関係](http://oswiki.osask.jp/?%28AT%29BIOS#n5884802)
    // 　なおこのグラフィックバッファの開始番地 0xaffff は `asmhead.asm` ないで メモリアドレスを指す変数 VRAM(=0x0ff8)
    // に保存されている. (`DWORD [VRAM]`)
    p[i] = i & 0x0f;  // 0-15 の値を期待するものである.
  }
```

逆アセンブル結果(`bootpack.hrb.dasm`)

```
  30:	55                   	push   ebp
  31:	89 e5                	mov    ebp,esp
  33:	83 ec 18             	sub    esp,0x18
                                                                  # ebp-0xc  : i
                                                                  # ebp-0x10 : p
  36:	c7 45 f0 00 00 0a 00 	mov    DWORD PTR [ebp-0x10],0xa0000   # initialize p = 0xa
  3d:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [ebp-0xc],0x0        # initialize i = 0x0
  44:	eb 13                	jmp    0x59
                                                                  # *(p+i) = i & 0x0f  |
  46:	8b 55 f4             	mov    edx,DWORD PTR [ebp-0xc]        # p+i                |
  49:	8b 45 f0             	mov    eax,DWORD PTR [ebp-0x10]       #                    |
  4c:	01 d0                	add    eax,edx                        #                    |
  4e:	8b 55 f4             	mov    edx,DWORD PTR [ebp-0xc]        # i & 0x0f           |
  51:	83 e2 0f             	and    edx,0xf                        #                    |
  54:	88 10                	mov    BYTE PTR [eax],dl              # *(p+i) = i & 0x0f  |
  56:	ff 45 f4             	inc    DWORD PTR [ebp-0xc]            # i++
  59:	81 7d f4 ff ff 00 00 	cmp    DWORD PTR [ebp-0xc],0xffff     # forの条件判定部分
  60:	7e e4                	jle    0x46
  62:	e8 09 00 00 00       	call   0x70
  67:	eb f9                	jmp    0x62
```


