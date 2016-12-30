    mov  $2, %edx
    mov $msg, %ebx
    int  $0x40
    mov $4, %edx
    int $0x40

msg:
    .ascii "hello2\0"
