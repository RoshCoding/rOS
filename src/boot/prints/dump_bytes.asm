dump_bytes:
    pusha			; Save all registers

    mov bh, 0x00

.print:
    jcxz .done

    lodsb

    push ax

    
    shr al, 4
    call print_nibble

    pop ax
    and al, 0x0F
    call print_nibble

    mov ah, 0x0E
    mov al, ' '
    int 0x10

    dec cx
    cmp cx, 0x0
    jne .print

.done:
    popa
    ret
