// bootpack.c

extern void io_hlt(void);
extern void io_cli(void);
extern void io_out8(int port, int data);
extern int io_load_eflags(void);
extern void io_store_eflags(int eflags);

void init_palette(void);
void set_palette(int start, int end, unsigned char *rgb);

void HariMain(void)
{
  char *p;  // BYTE [...]用番地
  p = (char *) 0xa0000;

  for (int i=0; i <= 0xffff; i++){
    p[i] = i & 0x0f;
  }

  for(;;){
    io_hlt();
  }
}

void init_palette(void)
{
  static unsigned char table_rgb[16 * 3] = {
    0x00, 0x00, 0x00,   // 000000 : 0 : 黒
    0xff, 0x00, 0x00,   // ff0000 : 1 : 明るい赤
    0x00, 0xff, 0x00,   // 00ff00 : 2 : 明るい緑
    0xff, 0xff, 0x00,   // ffff00 : 3 : 黄色
    0x00, 0x00, 0xff,   // 0000ff : 4 : 明るい青
    0xff, 0x00, 0xff,   // ff00ff : 5 : 明るい紫
    0x00, 0xff, 0xff,   // 00ffff : 6 : 明るい水色
    0xff, 0xff, 0xff,   // ffffff : 7 : 白
    0xc6, 0xc6, 0xc6,   // c6c6c6 : 8 : 明るい灰色
    0x84, 0x00, 0x00,   // 840000 : 9 : 暗い赤
    0x00, 0x84, 0x00,   // 008400 : 10: 暗い緑
    0x84, 0x84, 0x00,   // 848400 : 11: 暗い黄色
    0x00, 0x00, 0x84,   // 000084 : 12: 暗い青
    0x84, 0x00, 0x84,   // 840084 : 13: 暗い紫
    0x00, 0x84, 0x84,   // 008484 : 14: 暗い水色
    0x84, 0x84, 0x84,   // 848484 : 15: 暗い灰色
  };
  set_palette(0, 15, table_rgb);
  return;

    // static char 命令は、データにしか使えないけどDB命令担当
}

void set_palette(int start, int end, unsigned char *rgb)
{
  int i, eflags;
  eflags = io_load_eflags();    // 割り込み許可フラグの値を記録
  io_cli();                     // 許可フラグを0にして割り込みを禁止する
  io_out8(0x03c8, start);
  for (i = start; i <= end; i++){
    io_out8(0x03c9, rgb[0] / 4);
    io_out8(0x03c9, rgb[1] / 4);
    io_out8(0x03c9, rgb[2] / 4);
    rgb += 3;
  }
  io_store_eflags(eflags);    // 割り込み許可フラグを元にもどす
  return;
}

