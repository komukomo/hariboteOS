.global api_putchar, api_putstr0, api_end
.extern Main
.text
    .long 0x10000 # segment size
    .ascii "Hari" # Hari-format
    .long 0
    .long 0
    .long 0x10000 # data size
    .long 0 # data address
    .word 0
    .byte 0
    call Main
    lret

# void api_putchar(int c);
api_putchar:
    movl $1, %edx
    mov 4(%esp), %al
    int $0x40
    ret

# void api_putstr0(char *s);
api_putstr0:
    push %ebx
    mov  $2, %edx
    mov  8(%esp), %ebx
    int  $0X40
    pop  %ebx
    ret

# void api_end(void);
api_end:
    mov $4, %edx
    int $0x40
