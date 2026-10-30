; This file is to set up a program that can check the functionality of A20
; We return AX = 1 if enabled, and AX = 0 if disabled
check_a20:
    pushf
    push si
    push di
    push ds
    push es
    cli

    ; Set [ds:si] --> 0x0000:0x0500
    xor ax, ax
    mov ds, ax
    mov si, 0x0500

    ; Set [es:di] --> 0xFFFF:0x0510
    not ax
    mov es, ax
    mov di, 0x0510

    ; Let's save the old values before our test
    mov al, [ds:si]
    mov byte [.BufferBelowMB], al
    mov al, [es:di]
    mov byte [.BufferAboveMB], al

    ; Now it's time for our test
    mov ah, 1
    mov byte [ds:si], 1
    mov byte [es:di], 0
    mov al, [ds:si]
    cmp al, [es:di]
    jne .done
    dec ah

.done:
    ; Let's wrap this up and reset everything
    mov al, [.BufferBelowMB]
    mov [ds:si], al
    mov al, [.BufferAboveMB]
    mov [es:di], al
    mov al, ah			; Let's move the stuff in ah to al, clearing ah
    xor ah, ah
    pop es
    pop ds
    pop di
    pop si
    popf
    ret

    .BufferBelowMB:	db 0
    .BufferAboveMB:	db 0


