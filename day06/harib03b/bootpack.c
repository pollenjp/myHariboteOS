// harib03a/bootpack.c

extern void io_hlt(void);
extern void io_cli(void);
extern void io_out8(int port, int data);
extern int io_load_eflags(void);
extern void io_store_eflags(int eflags);

extern void init_palette(void);
extern void set_palette(int start, int end, unsigned char *rgb);
extern void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1);
extern void init_screen8(char *vram, int x, int y);
extern void putfont8(char *vram, int xsize, int x, int y, char c, char *font);
extern void putfonts8_asc(char *vram, int xsize, int x, int y, char c, unsigned char *s);
extern void sprintf(char *str, char *fmt, ...);
extern void init_mouse_cursor8(char *mouse, char bc);
extern void putblock8_8(char *vram,int vxsize,int pxsize,int pysize,int px0,int py0,char *buf, int bxsize);

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

struct SegmentDescriptor {            // 8 byte
  short limit_low, base_low;          // 2 byte * 2
  char base_mid, access_right;        // 1 byte * 2
  char limit_high, base_high;         // 1 byte * 2
};

struct GateDescriptor {               // 10 byte   
  short offset_low, selector;         // 2 byte * 2
	char dw_count, access_right;        // 1 byte * 2
	short offset_high;                  // 2 byte * 2
};

extern void set_segmdesc(struct SegmentDescriptor * sd, unsigned int limit, int base, int ar);
extern void set_gatedesc(struct GateDescriptor * gd, int offset, int selector, int ar);
extern void init_gdtidt(void);
extern void load_gdtr(int limit, int addr);
extern void load_idtr(int limit, int addr);


//--------------------
//  HariMain
//--------------------
void HariMain(void)
{
  struct BootInfo *binfo = (struct BootInfo *) 0x0ff0;
  extern char hankaku[4096];
  char s[40], mcursor[256];
  int mx, my;   // mouse x, mouse y

  init_gdtidt();
  init_palette();
  init_screen8(binfo->vram, binfo->scrnx, binfo->scrny);

  putfonts8_asc(binfo->vram, binfo->scrnx,  8,  8, COL8_FFFFFF, "ABC 123");
  putfonts8_asc(binfo->vram, binfo->scrnx, 31, 31, COL8_000000, "Haribote OS");
  putfonts8_asc(binfo->vram, binfo->scrnx, 30, 30, COL8_FFFFFF, "Haribote OS");

  mx = (binfo->scrnx - 16) / 2;
  my = (binfo->scrny - 28 - 16) / 2;

  init_mouse_cursor8(mcursor, COL8_008484);
  putblock8_8(binfo->vram, binfo->scrnx, 16, 16, mx, my, mcursor, 16);

  sprintf(s, "scrnx = %d", binfo->scrnx);
  putfonts8_asc(binfo->vram, binfo->scrnx, 16, 64, COL8_FFFFFF, s);

  for(;;){
    io_hlt();
  }
}


