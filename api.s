.global api_putchar
.extern Main
.text
call Main
lret

# void api_putchar(int c);
api_putchar:
    movl $1, %edx
    mov 4(%esp), %al
    int $0x40
    ret
