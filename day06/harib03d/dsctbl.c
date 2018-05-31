// dsctbl.c

#include "bootpack.h"


void init_gdtidt(void)
  // global segmentation descriptor table
  // interupt descriptor table
{
  // GDT : 0x00270000-0x0027ffff (65535 byte)
  struct SegmentDescriptor * gdt = (struct SegmentDescriptor *) ADR_GDT;   // 0x00270000-0x00270009 (8 byte)
  // GateDescriptor : 0x0026f800-0x0026ffff (28672 byte)
  struct GateDescriptor * idt = (struct GateDescriptor *) ADR_IDT;         // 0x0026f800-0x0026f807 (10 byte)
  int i;

  // initialize GDT
  for (i=0; i < 8192; i++){
    set_segmdesc(gdt + i, 0, 0, 0);
  }
  set_segmdesc(gdt + 1, 0xffffffff,   0x00000000, AR_DATA32_RW);
  set_segmdesc(gdt + 2, LIMIT_BOTPAK, ADR_BOTPAK, AR_CODE32_ER);
  load_gdtr(LIMIT_GDT, ADR_GDT);

  // initialize IDT
  for (i=0; i < 256; i++){
    set_gatedesc(idt + i, 0, 0, 0);
  }
  load_idtr(LIMIT_IDT, ADR_IDT);

  return;
}


/*------------------------------------------------------------
 *  set_segmdesc
 *  
 *  Parameters
 *  ----------
 *  access_right:
 *    xxxx0000xxxxxxxx
 *    ----
 *    GD00 <-- 拡張アクセエス権
 *    G: G bit
 *    D: segment mode (1:32bit, 0:16bit)
 *      - 00000000(0x00) :未使用の descriptor table 。
 *      - 10010010(0x92) :システム専用の読み書き可能なセグメント。実行はできない。
 *      - 10011010(0x9a) :システム専用の実行可能なセグメント。読み込みもOK。書き込みはできない。
 *      - 11110010(0xf2) :アプリケーション用の読み書き可能なセグメント。実行はできない。
 *      - 11111010(0xfa) :アプリケーション用の実行可能なセグメント。読み込みもOK。書き込みはできない。
 *------------------------------------------------------------*/
void set_segmdesc(struct SegmentDescriptor * sd,  // 4 byte
                  unsigned int limit,             // 4 byte --> 20 bit (Gbit=1 => ページ単位:4 kB x 1 MB = 1 GB)
                  int base,                       // 4 byte --> 32 bit (4 byte)
                  int ar                          // 4 byte : access_right --> 12 bit
    )
{
  if (limit > 0xffff){
    ar |= 0x8000;       // G_bit = 1
    limit /= 0x1000;
  }

  sd->limit_low    = limit & 0xffff;        // 2 byte : limitの下位1,2byte目を格納
  sd->base_low     = base & 0xffff;         // 2 byte : baseの下位から1,2byte目を格納
  sd->base_mid     = (base >> 16) & 0xff;   // 1 byte : baseの下位から3byte目を格納
  sd->access_right = ar & 0xff;             // 1 byte : arの下位から1byte目を格納
  sd->limit_high   = ((limit >> 16) & 0x0f) | ((ar >> 8) & 0xf0);
                                            // 4 bit : limitの下位から3byte目の下位の4bitを格納
                                            // 4 bit : arの下位から2byte目の下位4bitを格納
	sd->base_high    = (base >> 24) & 0xff;   // 1 byte : baseの下位から4byte目を格納
	return;
}


void set_gatedesc(struct GateDescriptor * gd,
                  int offset,
                  int selector,
                  int ar)
{
	gd->offset_low = offset & 0xffff;
	gd->selector = selector;
	gd->dw_count = (ar >> 8) & 0xff;
	gd->access_right = ar & 0xff;
	gd->offset_high = (offset >> 16) & 0xffff;
	return;
}


