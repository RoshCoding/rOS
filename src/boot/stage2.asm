; Our load location is 0x7E00, as it is free and we use it in stage 1, so we org there
org 0x7E00
; 16 bit
bits 16

%include "src/boot/constants.inc"


start:
    cld
    
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

    push eax
    mov si, E820_HEADER_ADDR
    mov cx, e820_header_size
    call dump_bytes
    pop eax
    jmp .halt

.error:
   pusha
   mov si, general_error_message
   call print_str
   popa

.halt:
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
    ; E820_HEADER_ADDR equ 0x1000 in constants.inc, as 0x1000 is open for our usage
    mov word [E820_HEADER_ADDR + e820_header.count], 0
    mov word [e820_fullcount], 0
    mov word [E820_HEADER_ADDR + e820_header.entry_size], E820_ENTRY_SIZE
    mov dword [E820_HEADER_ADDR + e820_header.entries_addr], E820_MAP_ADDR
    mov dword [E820_HEADER_ADDR + e820_header.magic], 0
    mov dword [E820_HEADER_ADDR + e820_header.flags], 0

    mov di, E820_MAP_ADDR
    mov ebx, 0
    
.E820_loop:
    mov eax, 0xE820
    mov ecx, 24
    mov edx, 0x534D4150

    mov dword [es:di + 20], 1
    int 0x15


    jc .E820_failed

    cmp eax, 0x534D4150
    jne .E820_failed
    
    ; Skipping tests
    jcxz .E820_next
    
    mov eax, [es:di + 8]
    or eax, [es:di + 12]
    jz .E820_next

    cmp cl, 20
    jbe .E820_accept
    
    test byte [es:di + 20], 1
    jz .E820_next

.E820_accept:
    ; mov si, new_line
    ; push ebx
    ; call print_str
    ; pop ebx

    ; Print routine for memory during reading
    ; mov si, di
    ; push ebx
    ; call dump_bytes
    ; pop ebx

    inc word [E820_HEADER_ADDR + e820_header.count]
    add di, E820_ENTRY_SIZE
    
    jmp .E820_next


.E820_failed:
    mov si, e820_fail
    call print_str
    stc
    ret

.E820_limit:
    mov si, new_line
    call print_str
    mov si, e820_limit_reached
    call print_str

    or dword [E820_HEADER_ADDR + e820_header.flags], 1

.E820_done:
    call E820_finish_header
    call E820_dump

    mov si, new_line
    call print_str
    mov si, e820_count_print
    call print_str
    
    push ax
    xor ax, ax
    mov ax, word [E820_HEADER_ADDR + e820_header.count]    
    call print_hex16
    pop ax

    mov si, new_line
    call print_str
    mov si, e820_success
    call print_str

    clc
    ret    

.E820_next:
    cmp ebx, 0
    je .E820_done
    
    inc word [e820_fullcount]
    cmp word [e820_fullcount], 256
    je .E820_limit

    cmp word [E820_HEADER_ADDR + e820_header.count], E820_MAX_ENTRIES		; Prevents the BIOS from going infinitely
    je .E820_limit

    jmp .E820_loop

E820_finish_header:
    mov dword [E820_HEADER_ADDR + e820_header.magic], E820_MAGIC
    ret

E820_dump:
    mov si, new_line
    call print_str

    mov bx, [E820_HEADER_ADDR + e820_header.count]
    mov di, [E820_HEADER_ADDR + e820_header.entries_addr]
   
    test bx, bx
    jz .done
    
    .loop:
	mov si, di
	mov cx, [E820_HEADER_ADDR + e820_header.entry_size]
	call dump_bytes

	mov si, new_line
	call print_str
    
	add di, [E820_HEADER_ADDR + e820_header.entry_size]

	dec bx
	jnz .loop

    .done:
	ret


%include "src/boot/prints/print.asm"
%include "src/boot/prints/print_hex16.asm"
%include "src/boot/prints/dump_bytes.asm"
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
e820_limit_reached:	db "E820 cap reached, truncating here", 0x0D, 0x0A, 0
e820_success:		db "E820 memory mapping successful", 0x0D, 0x0A, 0
e820_count_print:	db "Section Count: ", 0
e820_fullcount:		dw 0


; We change to 32 bit here
; bits 32

; We still want to end on a multiple of 512
times (512*STAGE2_SECTORS)-($-$$) db 0
