; Our load location is 0x7E00, as it is free and we use it in stage 1, so we org there
org 0x7E00
; 16 bit
bits 16

start:
    call main

main:
    mov si, message
    call print_str
    jmp .halt

.halt:
    jmp .halt


%include "src/boot/print.asm"

message: 	db 'Stage 2 loaded', 0

; We still want to end on a multiple of 512
times 512-($-$$) db 0
