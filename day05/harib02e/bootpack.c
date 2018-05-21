// bootpack.c

extern void io_hlt(void);
extern void io_cli(void);
extern void io_out8(int port, int data);
extern int io_load_eflags(void);
extern void io_store_eflags(int eflags);

void init_palette(void);
void set_palette(int start, int end, unsigned char *rgb);
void boxfill8(unsigned char *vram,
              int xsize,
              unsigned char c,
              int x0,
              int y0,
              int x1,
              int y1);
void init_screen(char *vram, int x, int y);
void putfont8(char *vram, int xsize, int x, int y, char c, char *font);


#define COL8_000000		0
#define COL8_FF0000		1
#define COL8_00FF00		2
#define COL8_FFFF00		3
#define COL8_0000FF		4
#define COL8_FF00FF		5
#define COL8_00FFFF		6
#define COL8_FFFFFF		7
#define COL8_C6C6C6		8
#define COL8_840000		9
#define COL8_008400		10
#define COL8_848400		11
#define COL8_000084		12
#define COL8_840084		13
#define COL8_008484		14
#define COL8_848484		15


struct BootInfo {
  char cyls, leds, vmode, reserve;    // 1 byte
  short scrnx, scrny;                 // 2 byte
  char *vram;                         // 4 byte
};


void HariMain(void)
{
  struct BootInfo *binfo = (struct BootInfo *) 0x0ff0;
  extern char hankaku[4096];
  int i;

  init_palette();
  init_screen(binfo->vram, binfo->scrnx, binfo->scrny);
  i = 8;
  putfont8(binfo->vram, binfo->scrnx,     i, 8, COL8_FFFFFF, hankaku + 'A' * 16);
  putfont8(binfo->vram, binfo->scrnx, 2 * i, 8, COL8_FFFFFF, hankaku + 'B' * 16);
  putfont8(binfo->vram, binfo->scrnx, 3 * i, 8, COL8_FFFFFF, hankaku + 'C' * 16);
  // putfont8(binfo->vram, binfo->scrnx, 4 * i, 8, COL8_FFFFFF, hankaku + '' * 16);
  putfont8(binfo->vram, binfo->scrnx, 5 * i, 8, COL8_FFFFFF, hankaku + '1' * 16);
  putfont8(binfo->vram, binfo->scrnx, 6 * i, 8, COL8_FFFFFF, hankaku + '2' * 16);
  putfont8(binfo->vram, binfo->scrnx, 7 * i, 8, COL8_FFFFFF, hankaku + '3' * 16);

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

void boxfill8(unsigned char *vram,
    int xsize,
    unsigned char c,
    int x0,
    int y0,
    int x1,
    int y1)
{
  for (int y = y0; y <= y1; y++){
    for (int x = x0; x <= x1; x++){
      vram[y * xsize + x] = c;
    }
  }
}


void init_screen(char *vram, int x, int y)
{
  boxfill8(vram, x, COL8_008484,  0,     0,      x -  1, y - 29);
  boxfill8(vram, x, COL8_C6C6C6,  0,     y - 28, x -  1, y - 28);
  boxfill8(vram, x, COL8_FFFFFF,  0,     y - 27, x -  1, y - 27);
  boxfill8(vram, x, COL8_C6C6C6,  0,     y - 26, x -  1, y -  1);

  boxfill8(vram, x, COL8_FFFFFF,  3,     y - 24, 59,     y - 24);
  boxfill8(vram, x, COL8_FFFFFF,  2,     y - 24,  2,     y -  4);
  boxfill8(vram, x, COL8_848484,  3,     y -  4, 59,     y -  4);
  boxfill8(vram, x, COL8_848484, 59,     y - 23, 59,     y -  5);
  boxfill8(vram, x, COL8_000000,  2,     y -  3, 59,     y -  3);
  boxfill8(vram, x, COL8_000000, 60,     y - 24, 60,     y -  3);

  boxfill8(vram, x, COL8_848484, x - 47, y - 24, x -  4, y - 24);
  boxfill8(vram, x, COL8_848484, x - 47, y - 23, x - 47, y -  4);
  boxfill8(vram, x, COL8_FFFFFF, x - 47, y -  3, x -  4, y -  3);
  boxfill8(vram, x, COL8_FFFFFF, x -  3, y - 24, x -  3, y -  3);
  return;
}


void putfont8(char *vram,   // 4 byte
              int xsize,    // 4 byte
              int x,        // 4 byte
              int y,        // 4 byte
              char c,       // 1 byte
              char *font)   // 4 byte
{
  int i;
  char d;     // 1 byte
  char *p;    // 4 byte
  for (i = 0; i < 16; i++){
    // 左上を(0, 0)として(x, y)の座標に描画
    p = vram + (y + i) * xsize + x;   // 1 byte
    d = font[i];
    if ((d & 0x80) != 0){p[0] = c;}
    if ((d & 0x40) != 0){p[1] = c;}
    if ((d & 0x20) != 0){p[2] = c;}
    if ((d & 0x10) != 0){p[3] = c;}
    if ((d & 0x08) != 0){p[4] = c;}
    if ((d & 0x04) != 0){p[5] = c;}
    if ((d & 0x02) != 0){p[6] = c;}
    if ((d & 0x01) != 0) p[7] = c;}
  return;
}

