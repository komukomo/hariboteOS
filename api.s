.global api_putchar, api_putstr0, api_end, api_openwin
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

# int api_openwin(char *buf, int xsiz, int ysiz, int col_inv, char *title);
api_openwin:
    push %edi
    push %esi
    push %ebx
    mov  $5, %edx
    mov  16(%esp), %ebx # BUF
    mov  20(%esp), %esi # XSIZ
    mov  24(%esp), %edi # YSIZ
    mov  28(%esp), %eax # COL_INV
    mov  32(%esp), %ecx # TITLE
    int  $0X40
    pop  %ebx
    pop  %esi
    pop  %edi
    ret
