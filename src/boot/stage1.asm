; Sets the correct starting address
org 0x7C00
; We set bits to 16 because of the backwards compatability of x86, working from the 8086 CPU
; bits 16 tells NASM to emit 16 bit machine code, we'll be switching to 32 bit later
bits 16

start:
    jmp main

msg_success: 		db "Stage 1 complete", 0x0D, 0x0A, 0
msg_failure:		db "Load Failed", 0
boot_drive:		db 0
attempts:		db 3 			; We're making 3 attempts at this

main:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; Saving the boot drive, which BIOS only gives us once
    mov [boot_drive], dl
    ; We're loading Stage 2 from 0x7E00, so we plug that into ES:BX, but ES is already 00, so we just need to adjust BX
    mov bx, 0x7E00
    mov sp, 0x7C00 
    cld

    mov byte [attempts], 3
    call load_stage
    jc .failure

.success:
    mov si, msg_success
    call print_str

    mov dl, [boot_drive]
    jmp 0x7E00

.failure:
    mov si, msg_failure
    call print_str

.halt:
    jmp .halt

load_stage:
    mov ah, 0x02		; 0x02
    mov dl, [boot_drive]	; Drive number
    mov al, 1			; Number of sectors to read
    mov cl, 2			; Sector number, starting 1 (bits 0-5)
    mov ch, 0			; Cylinder
    mov dh, 0			; Head

    int 0x13

    jnc .done
    
    mov ah, 0x00
    mov dl, [boot_drive]
    
    int 0x13
    
    dec byte [attempts]
    jnz load_stage
    
.failed:
    stc
    ret

.done:
    ret

%include "src/boot/print.asm"

    

; File must be 512 bytes, with last two as 55 AA, so we fill whatever space is left with 0's
; $ = Current line, $$ = address of start, so $-$$ = total bytes so far
times 510-($-$$) db 0
; Little endian, so we flip 0xAA55 --> 55 AA
dw 0xAA55

