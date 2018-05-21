; nasmfunc.asm
; TAB=4

section .text
    GLOBAL  io_hlt

io_hlt:     ; void io_hlt(void);
    hlt
    ret
