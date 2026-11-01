; Our load location is 0x7E00, as it is free and we use it in stage 1, so we org there
org 0x7E00
; 16 bit
bits 16

start:
    call main

main:
    push ax
    mov ax, 0
    mov es, ax
    mov ds, ax
    pop ax

    mov si, init_message
    call print_str		; Output to verify a successful load


    call A20_setup
    call E820_setup
    jc .error 
    jmp .halt

.error:
   pusha
   mov si, general_error_message
   call print_str
   popa

.halt
    jmp .halt

A20_setup:
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
    ret

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

E820_setup:
    mov byte [e820_count], 0

    mov di, 0x1000
    mov ebx, 0
    
.E820_loop:
    ; mov si, new_line
    ; call print_str

    mov eax, 0xE820
    mov ecx, 24
    mov edx, 0x534D4150

    mov dword [es:di + 20], 1
    int 0x15


    jc .E820_failed

    cmp eax, 0x534D4150
    jne .E820_failed

    ; push ax
    ; mov ax, [es:di]
    ; call print_hex16
    ; pop ax
    
    mov cx, 24
    mov si, di
    call dump_bytes

    inc byte [e820_count]
    add di, 24

    cmp ebx, 0
    je .E820_done

    
    cmp byte [e820_count], 32		; Prevents the BIOS from going infinitely
    je .E820_done

    mov si, new_line
    push ebx
    call print_str
    pop ebx

    jmp .E820_loop


.E820_failed:
    cmp byte [e820_count], 0
    jne .E820_done

    mov si, e820_fail
    call print_str
    stc
    ret

.E820_done:
   mov si, new_line
   call print_str
   mov si, e820_success
   call print_str

   clc
   ret 

%include "src/boot/print.asm"
%include "src/boot/print_hex16.asm"
%include "src/boot/dump_bytes.asm"
%include "src/boot/a20/check_a20.asm"
%include "src/boot/a20/disable_a20.asm"

init_message: 		db "Stage 2 loaded", 0x0D, 0x0A, 0
general_error_message:  db "Error has occured, halting", 0x0D, 0x0A, 0
new_line:		db "", 0x0D, 0x0A, 0

a20_fail_1:		db "A20 Disabled, Attempt 1", 0x0D, 0x0A, 0
a20_fail_2:		db "A20 Disabled, Attempt 2", 0x0D, 0x0A, 0
a20_fail_done:  	db "A20 enabling failed, unrecoverable problem", 0x0D, 0x0A, 0
a20_yes:		db "A20 Enabled", 0x0D, 0x0A, 0

e820_fail:		db "E820 Failed", 0x0D, 0x0A, 0 
e820_success:		db "E820 memory mapping successful", 0x0D, 0x0A, 0
e820_count:		db 0

SECTORS_STAGE2: 	db 8


; We change to 32 bit here
; bits 32

; We still want to end on a multiple of 512
times (512*8)-($-$$) db 0
