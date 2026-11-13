print_str:
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
