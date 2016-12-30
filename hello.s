    movl $msg, %ecx
    movl $1, %edx
putloop:
    movb %cs:(%ecx), %al
    cmp $0, %al
    je fin
    int $0x40
    add $1, %ecx
    jmp putloop
fin:
    mov $4, %edx
    int $0x40
msg:
    .ascii "hello\0"
