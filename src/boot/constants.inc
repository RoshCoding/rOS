STAGE2_SECTORS			EQU 16
E820_MAP_ADDR			EQU 0x1000
E820_HEADER_ADDR		EQU 0x0FF0
E820_ENTRY_SIZE			EQU 24
E820_MAGIC			EQU 'E820'
E820_MAX_ENTRIES		EQU 128

struc e820_header
    .magic		resd 1		; Offset = +0
    .count		resw 1		; Offset = +4
    .entry_size		resw 1		; Offset = +6
    .entries_addr	resd 1		; Offset = +8
    .flags		resd 1		; Offset = +12
endstruc


