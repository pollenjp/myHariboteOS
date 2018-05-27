// harib03a/dsctbl.c

#include "bootpack.h"


void init_gdtidt(void)
  // global segmentation descriptor table
  // interupt descriptor table
{
  // GDT : 0x00270000-0x0027ffff (65535 byte)
  struct SegmentDescriptor * gdt = (struct SegmentDescriptor *) 0x00270000;   // 0x00270000-0x00270009 (8 byte)
  // GateDescriptor : 0x0026f800-0x0026ffff (28672 byte)
  struct GateDescriptor * idt = (struct GateDescriptor *) 0x0026f800;         // 0x0026f800-0x0026f807 (10 byte)
  int i;

  // initialize GDT
  for (i=0; i < 8192; i++){
    set_segmdesc(gdt + i, 0, 0, 0);
  }
  set_segmdesc(gdt + 1, 0xffffffff, 0x00000000, 0x4092);
  set_segmdesc(gdt + 2, 0x0007ffff, 0x00280000, 0x409a);
  load_gdtr(0xffff, 0x00270000);

  // initialize IDT
  for (i=0; i < 256; i++){
    set_gatedesc(idt + i, 0, 0, 0);
  }
  load_idtr(0x7ff, 0x0026f800);

  return;
}


void set_segmdesc(struct SegmentDescriptor * sd,  // 4 byte
                  unsigned int limit,             // 4 byte
                  int base,                       // 4 byte
                  int ar                          // 4 byte
    )
{
  if (limit > 0xffff){
    ar |= 0x8000;       // G_bit = 1
    limit /= 0x1000;
  }

  sd->limit_low = limit & 0xffff;
  sd->base_low = base & 0xffff;
  sd->base_mid = (base >> 16) & 0xff;
  sd->access_right = ar & 0xff;
  sd->limit_high = ((limit >> 16) & 0x0f) | ((ar >> 8) & 0xf0);
	sd->base_high = (base >> 24) & 0xff;
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


