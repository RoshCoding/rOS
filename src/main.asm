org 0x7C00
; We set bits to 16 because of the backwards compatability of x86, working from the original 8086 cpu
bits 16

main:
    hlt

.halt:
    jmp .halt

dw 0xAA55
