; While this function is really small, it's not worth taking up space in Stage 2 if unnecessary, so we can always comment the include and call lines, keeping this extra
disable_a20:
    in al, 0x92
    and al, 0xFD
    out 0x92, al
    ret
