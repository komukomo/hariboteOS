.global api_putchar, api_putstr0, api_end, api_openwin
.global api_putstrwin, api_boxfilwin
.global api_initmalloc, api_malloc, api_free
.global api_point
.global api_getkey
.global api_alloctimer, api_inittimer, api_settimer, api_freetimer
.global api_refreshwin, api_linewin, api_openwin, api_closewin
.global api_beep
.global api_fopen, api_fseek, api_fclose, api_fsize, api_fread
.global api_cmdline
.global api_getlang

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

# void api_putstrwin(int win, int x, int y, int col, int len, char *str);
api_putstrwin:
    push %edi
    push %esi
    push %ebp
    push %ebx
    mov  $6, %edx
    mov  20(%esp), %ebx # win
    mov  24(%esp), %esi # x
    mov  28(%esp), %edi # y
    mov  32(%esp), %eax # col
    mov  36(%esp), %ecx # len
    mov  40(%esp), %ebp # str
    int  $0X40
    pop  %ebx
    pop  %ebp
    pop  %esi
    pop  %edi
    ret

# void api_boxfilwin(int win, int x0, int y0, int x1, int y1, int col);
api_boxfilwin:
    push %edi
    push %esi
    push %ebp
    push %ebx
    mov  $7, %edx
    mov  20(%esp), %ebx # win
    mov  24(%esp), %eax # x0
    mov  28(%esp), %ecx # y0
    mov  32(%esp), %esi # x1
    mov  36(%esp), %edi # y1
    mov  40(%esp), %ebp # col
    int  $0x40
    pop  %ebx
    pop  %ebp
    pop  %esi
    pop  %edi
    ret

# void api_initmalloc(void);
api_initmalloc:
    push %ebx
    mov  $8, %edx
    mov  %cs:0x0020, %ebx # malloc領域の番地
    mov  %ebx, %eax
    add  32*1024, %eax     # 32kbを足す
    mov  %cs:0x0000, %ecx  # データセグメントの大きさ
    sub  %eax, %ecx
    int  $0x40
    pop  %ebx
    ret

# char *api_malloc(int size);
api_malloc:
    push %ebx
    mov  $9, %edx
    mov  %cs:0x0020, %ebx
    mov  8(%esp), %ecx # size
    int  $0x40
    pop  %ebx
    ret

# void api_free(char *addr, int size);
api_free:
    push %ebx
    mov  $10, %edx
    mov  %cs:0x0020, %ebx
    mov  8(%esp), %eax # addr
    mov  12(%esp), %ecx # size
    int  $0x40
    pop  %ebx
    ret

# void api_point(int win, int x, int y, int col);
api_point:
    push %edi
    push %esi
    push %ebx
    mov  $11, %edx
    mov  16(%esp), %ebx # win
    mov  20(%esp), %esi # x
    mov  24(%esp), %edi # y
    mov  28(%esp), %eax # col
    int  $0x40
    pop  %ebx
    pop  %esi
    pop  %edi
    ret

# void api_refreshwin(int win, int x0, int y0, int x1, int y1);
api_refreshwin:
    push %edi
    push %esi
    push %ebx
    mov  $12, %edx
    mov  16(%esp), %ebx # win
    mov  20(%esp), %eax # x0
    mov  24(%esp), %ecx # y0
    mov  28(%esp), %esi # x1
    mov  32(%esp), %edi # y1
    int  $0x40
    pop  %ebx
    pop  %esi
    pop  %edi
    ret

# void api_linewin(int win, int x0, int y0, int x1, int y1, int col);
api_linewin:
    push %edi
    push %esi
    push %ebp
    push %ebx
    mov  $13, %edx
    mov  20(%esp), %ebx # win
    mov  24(%esp), %eax # x0
    mov  28(%esp), %ecx # y0
    mov  32(%esp), %esi # x1
    mov  36(%esp), %edi # y1
    mov  40(%esp), %ebp # col
    int  $0x40
    pop  %ebx
    pop  %ebp
    pop  %esi
    pop  %edi
    ret

# void api_closewin(int win);
api_closewin:
    push %ebx
    mov  $14, %edx
    mov  8(%esp), %ebx # win
    int  $0x40
    pop  %ebx
    ret

# int api_getkey(int mode);
api_getkey:
    mov  $15, %edx
    mov  4(%esp), %eax # mode
    int  $0x40
    ret

# int api_alloctimer(void);
api_alloctimer:
    mov  $16, %edx
    int  $0x40
    ret

# void api_inittimer(int timer, int data);
api_inittimer:
    push %ebx
    mov  $17, %edx
    mov  8(%esp), %ebx # timer
    mov  12(%esp), %eax # data
    int  $0x40
    pop  %ebx
    ret

# void api_settimer(int timer, int time);
api_settimer:
    push %ebx
    mov  $18, %edx
    mov  8(%esp), %ebx # timer
    mov  12(%esp), %eax # time
    int  $0x40
    pop  %ebx
    ret

# void api_freetimer(int timer);
api_freetimer:
    push %ebx
    mov  $19, %edx
    mov  8(%esp), %ebx # timer
    int  $0x40
    pop  %ebx
    ret

# void api_beep(int tone);
api_beep:
    mov  $20, %edx
    mov  4(%esp), %eax  # tone
    int  $0x40
    ret

# int api_fopen(char *fname);
api_fopen:
    push %ebx
    mov  $21, %edx
    mov  8(%esp), %ebx  # fname
    int  $0x40
    pop  %ebx
    ret

# void api_fclose(int fhandle);
api_fclose:
    mov  $22, %edx
    mov  4(%esp), %eax   # fhandle
    int  $0x40
    ret

# void api_fseek(int fhandle, int offset, int mode);
api_fseek:
    push %ebx
    mov  $23, %edx
    mov  8(%esp), %eax  # fhandle
    mov  16(%esp), %ecx  # mode
    mov  12(%esp), %ebx  # offset
    int  $0x40
    pop  %ebx
    ret

# int api_fsize(int fhandle, int mode);
api_fsize:
    mov  $24, %edx
    mov  4(%esp), %eax   # fhandle
    mov  4(%esp), %ecx   # mode
    int  $0x40
    ret

# int api_fread(char *buf, int maxsize, int fhandle);
api_fread:
    push %ebx
    mov  $25, %edx
    mov  16(%esp), %eax  # fhandle
    mov  12(%esp), %ecx  # maxsize
    mov  8(%esp), %ebx   # buf
    int  $0x40
    pop  %ebx
    ret

# int api_cmdline(char *buf, int maxsize);
api_cmdline:
    push %ebx
    mov  $26, %edx
    mov  12(%esp), %ecx  # maxsize
    mov  8(%esp), %ebx   # buf
    int  $0x40
    pop  %ebx
    ret

# int api_getlang(void);
api_getlang:
    mov $27, %edx
    int $0x40
    ret
