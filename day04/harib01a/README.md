# day04 C言語からメモリに書き込みたい - harib01a

imgファイル作成

```
$ make
```

実行...真っ白な画面に切り替わる

```
$ make run
```

`ref/`には実行に関係ないファイルをしまっておくことにした


## メモリに書き込む箇所の逆アセンブル

`bootpack.c`の`HariMain()`の中の以下の箇所の逆アセンブル

```
  for (i = 0xa0000; i <= 0xaffff; i++){
    // > VRAMは0xa0000～0xaffffの64KBです。厳密に言うと、320x200=64000なので、62.5KBですが.
    // > [INT(0x10); ビデオ関係](http://oswiki.osask.jp/?%28AT%29BIOS#n5884802)
    // 　なおこのグラフィックバッファの開始番地 0xaffff は `asmhead.asm` ないで メモリアドレスを指す変数 VRAM(=0x0ff8)
    // に保存されている. (`DWORD [VRAM]`)
    _write_mem8(/* int addr= */ i, /* int data = */ 15);  // 第2引数dataは 0-15 の値を期待するものである.
  }
```

逆アセンブル結果(`./debug/bootpack.hrb.dasm`)

```
  30:	55                   	push   ebp                                # 現在のベースポインタ(dbp)の中身をスタックに保存(同時にespもdecrement)
                                                                      #
                                                                      # > スタックポインタをデクリメントし、次にオペランドをスタックのトップに格納します
                                                                      # > スタックセグメントのアドレスサイズ属性によって、スタックポインタのサイズ（16ビットまたは32ビット）が決まり、
                                                                      # > 現在のコードセグメントのオペランドサイズ属性によって、スタックポインタをデクリメントする量
                                                                      # > （2バイトまたは4バイト）が決まります。例えば、アドレスサイズ属性とオペランドサイズ属性が32である場合
                                                                      # > 32ビットESP（スタックポインタ）が4バイトデクリメントされます。また、アドレスサイズ属性とオペランドサイズ属性が
                                                                      # > 16である場合、16ビットSPが2デクリメントされます
                                                                      # > [Tips　IA32（x86）命令一覧　Pから始まる命令　PUSH命令](http://softwaretechnique.jp/OS_Development/Tips/IA32_Instructions/PUSH.html)
                                                                      #
                                                                      # r16,r32で同じ命令になっている理由は「アドレスサイズ属性」に関係している.
                                                                      # > [アセンブリ言語 - オペランドサイズ、アドレスサイズとは？ 16bit演算を用意する意味は？ メモリサイズの制限とアドレスサイズの関係は？ - スタック・オーバーフロー](https://ja.stackoverflow.com/questions/39666/%E3%82%AA%E3%83%9A%E3%83%A9%E3%83%B3%E3%83%89%E3%82%B5%E3%82%A4%E3%82%BA-%E3%82%A2%E3%83%89%E3%83%AC%E3%82%B9%E3%82%B5%E3%82%A4%E3%82%BA%E3%81%A8%E3%81%AF-16bit%E6%BC%94%E7%AE%97%E3%82%92%E7%94%A8%E6%84%8F%E3%81%99%E3%82%8B%E6%84%8F%E5%91%B3%E3%81%AF-%E3%83%A1%E3%83%A2%E3%83%AA%E3%82%B5%E3%82%A4%E3%82%BA%E3%81%AE%E5%88%B6%E9%99%90%E3%81%A8%E3%82%A2%E3%83%89%E3%83%AC%E3%82%B9%E3%82%B5%E3%82%A4%E3%82%BA%E3%81%AE%E9%96%A2%E4%BF%82%E3%81%AF)
                                                                      #
  31:	89 e5                	mov    ebp,esp                            # 現在のespの値をebpに保存
  33:	83 ec 18             	sub    esp,0x18                           # espを0x18=16+8=24だけdecrement
  36:	c7 45 f4 00 00 0a 00 	mov    DWORD PTR [ebp-0xc],0xa0000        # 変数iに0xa0000を代入 (ebp-0xc=esp+0x8)
  3d:	eb 13                	jmp    0x52                               # 0x52番地にjump
  3f:	83 ec 08             	sub    esp,0x8                            ####################
                                                                      # <== 0x4c番地で0x10の倍数を足すことになっている(?)ためstackに無意味な枠を設けている?
                                                                      ####################
  42:	6a 0f                	push   0xf                                # _write_mem8(/* int addr= */ i, /* int data = */ 15);の第2引数をスタックに積み,espをdecrement
  44:	ff 75 f4             	push   DWORD PTR [ebp-0xc]                # _write_mem8(/* int addr= */ i, /* int data = */ 15);の第1引数をスタックに積み,espをdecrement
  47:	e8 26 00 00 00       	call   0x72                               # _write_mem8(/* int addr= */ i, /* int data = */ 15)の戻り先アドレス
                                                                      # (ここでは0x4c番地の4バイト)をスタックに積み,0x72(プロシージャ)にjump.
  4c:	83 c4 10             	add    esp,0x10                           #################### 
                                                                      # <== ここは 0x10, 0x20, ... 単位で足すことになっているみたい？ 0x3f番地ではそうなるように空白のstackを設けている. なぜなのか.
                                                                      # スタックポインタを0x10=16だけ戻す(足す)
                                                                      # (0x3fでの0x8) + 0x8(=byteof(int)+byteof(int))
                                                                      ####################
  4f:	ff 45 f4             	inc    DWORD PTR [ebp-0xc]                # i++
  52:	81 7d f4 ff ff 0a 00 	cmp    DWORD PTR [ebp-0xc],0xaffff        # forの条件判定部分
  59:	7e e4                	jle    0x3f                               # if (i <= 0xaffff) then jump to 0x3f
  5b:	e8 10 00 00 00       	call   0x70                               #

  72:	8b 4c 24 04          	mov    ecx,DWORD PTR [esp+0x4]
  76:	8a 44 24 08          	mov    al,BYTE PTR [esp+0x8]
  7a:	88 01                	mov    BYTE PTR [ecx],al
  7c:	c3                   	ret                                       # callの時にスタックに積んだであろう値の指す戻り先アドレスにjumpし,スタックをincrementすると思われる.
```

