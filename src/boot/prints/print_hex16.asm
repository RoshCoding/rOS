; Prints the two bytes in AX in hexadecimal for readability and testing
print_hex16:
    pusha			; Save all registers

    mov bh, 0x00

    call upper_four
    call lower_four
    
    popa
    ret

; Prints the upper byte in AX
upper_four:
    push ax
    shr ax, 12

    call print_nibble

    pop ax
    push ax
    shr ax, 8
    and al, 0x0F
    call print_nibble
    
    pop ax
    ret

; Prints the lower byte in AX
lower_four:
    push ax
    
    shr al, 4
    call print_nibble

    pop ax
    push ax
    and al, 0x0F
    call print_nibble

    pop ax
    ret

%include "src/boot/prints/print_nibble.asm"


