// bootpack.c

extern void io_hlt(void);
// extern void write_mem8(int addr, int data);

void HariMain(void)
{
  char *p;  // BYTE [...]用番地

  for (int i = 0xa0000; i <= 0xaffff; i++){
    p = (char *) i;
    *p = i & 0x0f;
    // write_mem8(i, i & 0x0f);
    // または
    // *((char *) i) = i & 0x0f;
    // と同じ処理
  }

  for(;;){
    io_hlt();
  }
}
