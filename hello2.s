    mov  $2, %edx
    mov $msg, %ebx
    int  $0x40
    lret

msg:
    .ascii "hello2"
