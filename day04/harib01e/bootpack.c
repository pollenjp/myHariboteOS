extern void _io_hlt(void);

void HariMain(void)
// > 「30日でできる!OS自作入門」 p66
// > おっと大事なことを忘れていました。関数名HariMainですが、これは非常に意味ある名前で、この名前の関数から
// > プログラムが始まるということになっています。だからこれを違う名前に変えることはできません。
{
  int i;                        // VRAM用番地指定変数, 32bit(4 Byte)番地
  char * p = (char *) 0xa0000;  // *pは 1 Byte値, pは32bit(4 Byte)番地
  for (i = 0; i <= 0xffff; i++){
    // > VRAMは0xa0000～0xaffffの64KBです。厳密に言うと、320x200=64000なので、62.5KBですが.
    // > [INT(0x10); ビデオ関係](http://oswiki.osask.jp/?%28AT%29BIOS#n5884802)
    // 　なおこのグラフィックバッファの開始番地 0xaffff は `asmhead.asm` ないで メモリアドレスを指す変数 VRAM(=0x0ff8)
    // に保存されている. (`DWORD [VRAM]`)
                      //                                  | 擬似アセンブリコード (特にx86命令等を調べた訳ではない)
    p[i] = i & 0x0f;  // 0-15 の値を期待するものである.   | MOV ECX,p
                      //                                  | ADD ECX,i
                      //                                  | MOV BYTE [ECX],(i & 0x0f)
  }

  for(;;){
    _io_hlt();
  }
}
