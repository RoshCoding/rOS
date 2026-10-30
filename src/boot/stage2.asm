; Our load location is 0x7E00, as it is free and we use it in stage 1, so we org there
org 0x7E00
; 16 bit
bits 16

start:
    call main

main:
    mov si, init_message
    call print_str		; Output to verify a successful load
    
    ; call disable_a20		; We want to try disabling A20 to see if our enabling method works
    call check_a20

    ; We check if A20 is working, jumping to fix it if it's not, and jumping to continue the code if it is
    cmp ax, 1
    jne .a20_failure_1
    jmp .a20_success


.a20_failure_1:
    mov si, a20_fail_1
    call print_str

    ; Try method 1 to enable
    call enable_a20_1
    call check_a20
    cmp ax, 1
    jne .a20_failure_2
    jmp .a20_success

.a20_failure_2:
    mov si, a20_fail_2
    call print_str

    ; Try method 2 to enable
    call fast_a20
    call check_a20
    cmp ax, 1
    jne .a20_failure_done
    jmp .a20_success

.a20_failure_done:
    mov si, a20_fail_done
    call print_str
    jmp .halt

.a20_success:
    mov si, a20_yes
    call print_str

.halt:
    jmp .halt

; int 0x15
enable_a20_1:
    mov ax, 0x2401
    int 0x15
    ret

; Fast A20
fast_a20:
    in al, 0x92
    and al, 0xFE
    or al, 2
    out 0x92, al
    ret


%include "src/boot/print.asm"
%include "src/boot/a20/check_a20.asm"
%include "src/boot/a20/disable_a20.asm"

init_message: 	db "Stage 2 loaded", 0x0D, 0x0A, 0
a20_fail_1:	db "A20 Disabled, Attempt 1", 0x0D, 0x0A, 0
a20_fail_2:	db "A20 Disabled, Attempt 2", 0x0D, 0x0A, 0
a20_fail_done:  db "A20 enabling failed, unrecoverable problem", 0x0D, 0x0A, 0
a20_yes:	db "A20 Enabled", 0x0D, 0x0A, 0

; We still want to end on a multiple of 512
times 512-($-$$) db 0
