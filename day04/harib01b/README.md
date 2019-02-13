# day04 しましま模様 - harib01b

imgファイル作成

```
$ make
```

実行...しましまになる

```
$ make run
```

`ref/`には実行に関係ないファイルをしまっておくことにした

## メモリに書き込む箇所の逆アセンブル

`bootpack.c`の`HariMain()`の中の以下の箇所の逆アセンブル

```
  int i;
  for (i = 0xa0000; i <= 0xaffff; i++){
    // > VRAMは0xa0000～0xaffffの64KBです。厳密に言うと、320x200=64000なので、62.5KBですが.
    // > [INT(0x10); ビデオ関係](http://oswiki.osask.jp/?%28AT%29BIOS#n5884802)
    // 　なおこのグラフィックバッファの開始番地 0xaffff は `asmhead.asm` ないで メモリアドレスを指す変数 VRAM(=0x0ff8)
    // に保存されている. (`DWORD [VRAM]`)
    _write_mem8(/* int addr= */ i, /* int data = */ i & 0x0f);  // 第2引数dataは 0-15 の値を期待するものである.
  }
```

逆アセンブル結果(`bootpack.hrb.dasm`)

```
  30:	55                   	push   ebp
  31:	89 e5                	mov    ebp,esp
  33:	83 ec 18             	sub    esp,0x18
  36:	c7 45 f4 00 00 0a 00 	mov    DWORD PTR [ebp-0xc],0xa0000  # initialize i = 0xa0000
  3d:	eb 18                	jmp    0x57
  3f:	8b 45 f4             	mov    eax,DWORD PTR [ebp-0xc]
  42:	83 e0 0f             	and    eax,0xf                      # i & 0xf
  45:	83 ec 08             	sub    esp,0x8                      # esp調整
  48:	50                   	push   eax                          # argument
  49:	ff 75 f4             	push   DWORD PTR [ebp-0xc]          # argument
  4c:	e8 21 00 00 00       	call   0x72                         # call procedure
  51:	83 c4 10             	add    esp,0x10                     # esp調整
  54:	ff 45 f4             	inc    DWORD PTR [ebp-0xc]          # i++
  57:	81 7d f4 ff ff 0a 00 	cmp    DWORD PTR [ebp-0xc],0xaffff  # forの条件判定部分
  5e:	7e df                	jle    0x3f
  60:	e8 0b 00 00 00       	call   0x70
  65:	eb f9                	jmp    0x60
```

