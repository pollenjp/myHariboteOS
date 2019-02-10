section .text
    GLOBAL  _io_hlt

_io_hlt:     ; void io_hlt(void);
    HLT
    RET
