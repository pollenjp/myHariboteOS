// bootpack.c

extern void io_hlt(void);
extern void write_mem8(int addr, int data);

void HariMain(void)
{
  int i;
  for (i = 0xa0000; i <= 0xaffff; i++){
    write_mem8(i, 15);
  }

  for(;;){
    io_hlt();
  }
//fin:
//  goto fin;
}
