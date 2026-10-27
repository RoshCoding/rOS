; Sets the correct starting address
org 0x7C00
; We set bits to 16 because of the backwards compatability of x86, working from the original 8086 cpu
; bits 16 tells NASM to emit 16 bit machine code, we'll be switching to 32 bit later
bits 16



start:
    jmp main

main:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    

    mov sp, 0x7C00
    
    cld
    call print_str

    jmp .halt

.halt:
    jmp .halt

print_str:
    mov si, message
    mov bh, 0x00
    mov ah, 0x0e

.print:
    lodsb
    cmp al, 0x00
    je .done
    int 0x10
    jmp .print

.done:
    ret


message: 		db 'Hello World', 0x00
    

; File must be 512 bytes, with last two as 55 AA, so we fill whatever space is left with 0's
; $ = Current line, $$ = address of start, so $-$$ = total bytes so far
times 510-($-$$) db 0
; Little endian, so we flip 0xAA55 --> 55 AA
dw 0xAA55

