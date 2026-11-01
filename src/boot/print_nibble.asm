print_nibble:
    cmp al, 10
    jb .digit
    add al, 'A' - 10		; Convert to letter
    jmp .write

.digit:
    add al, '0'			; Convert to a character

.write:
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10

    ret
