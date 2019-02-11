extern void _io_hlt(void);
extern void _write_mem8(int addr, int data);

void HariMain(void)
// > 「30日でできる!OS自作入門」 p66
// > おっと大事なことを忘れていました。関数名HariMainですが、これは非常に意味ある名前で、この名前の関数から
// > プログラムが始まるということになっています。だからこれを違う名前に変えることはできません。
{
  int i;
  for (i = 0xa0000; i <= 0xaffff; i++){
    // > VRAMは0xa0000～0xaffffの64KBです。厳密に言うと、320x200=64000なので、62.5KBですが.
    // > [INT(0x10); ビデオ関係](http://oswiki.osask.jp/?%28AT%29BIOS#n5884802)
    // 　なおこのグラフィックバッファの開始番地 0xaffff は `asmhead.asm` ないで メモリアドレスを指す変数 VRAM(=0x0ff8)
    // に保存されている. (`DWORD [VRAM]`)
    _write_mem8(/* int addr= */ i, /* int data = */ 15);  // 第2引数dataは 0-15 の値を期待するものである.
  }

  for(;;){
    _io_hlt();
  }
}
