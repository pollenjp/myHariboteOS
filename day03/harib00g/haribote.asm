; haribote-os
; TAB=4
        ORG     0xc200      ; 0xc200 <- 0x8000 + 0x4200
                            ; Where on memory this program will be loaded

        MOV     AL, 0x13    ; VGA graphics, 320x200x8bit
        MOV     AH, 0x00
        INT     0x10

fin:
        HLT
        JMP     fin
