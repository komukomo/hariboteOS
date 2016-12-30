.global api_putchar, api_end
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

# void api_end(void);
api_end:
    mov $4, %edx
    int $0x40
