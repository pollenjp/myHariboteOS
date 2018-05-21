// bootpack.c

extern void io_hlt(void);
extern void write_mem8(int addr, int data);

void HariMain(void)
{
  for (int i = 0xa0000; i <= 0xaffff; i++){
    write_mem8(i, i & 0x0f);    // 16画素(下位4bit)ごとに色変更
  }

  for(;;){
    io_hlt();
  }
}
