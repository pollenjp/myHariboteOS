extern void _io_hlt(void);
extern void _write_mem8(int addr, int data);

void HariMain(void)
// > 「30日でできる!OS自作入門」 p66
// > おっと大事なことを忘れていました。関数名HariMainですが、これは非常に意味ある名前で、この名前の関数から
// > プログラムが始まるということになっています。だからこれを違う名前に変えることはできません。
{
  int i;
  for (i = 0xa0000; i <= 0xaffff; i++){
    _write_mem8(i, 15);
  }

  for(;;){
    _io_hlt();
  }
}
