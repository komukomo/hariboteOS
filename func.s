.code32
.globl io_hlt, io_cli
.globl io_out8
.globl io_store_eflags, io_load_eflags
.text

io_hlt:
    hlt
    ret

io_cli:
    cli
    ret

# void io_out8(int port, int data)
io_out8:
    movl 4(%esp), %edx
    movb 8(%esp), %al
    outb %al, %dx
    ret

# void io_store_eflags(int eflags)
io_store_eflags:
    movl 4(%esp), %eax
    pushl %eax
    popf
    ret

# int io_load_eflags(void)
io_load_eflags:
    pushf
    popl %eax
    ret
