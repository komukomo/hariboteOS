.code32
.globl io_hlt, io_cli, io_sti, io_stihlt
.globl io_out8, io_in8
.globl io_store_eflags, io_load_eflags
.globl load_gdtr, load_idtr
.globl load_cr0, store_cr0
.globl load_tr
.globl asm_inthandler20, asm_inthandler21, asm_inthandler2c, asm_inthandler27
.globl farjmp, farcall
.globl asm_cons_putchar
.extern inthandler20, inthandler21, inthandler2c, inthandler27
.extern cons_putchar
.text

io_hlt:
    hlt
    ret

io_cli:
    cli
    ret

io_sti:
    sti
    ret 

io_stihlt:
    sti
    hlt
    ret

# void io_out8(int port, int data)
io_out8:
    movl 4(%esp), %edx
    movb 8(%esp), %al
    outb %al, %dx
    ret

# int io_in8(int port)
io_in8:
    movl 4(%esp), %edx
    movl $0, %eax
    inb %dx, %al
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

# void load_gdtr(int limit, int addr)
load_gdtr:
    movw 4(%esp), %ax
    movw %ax, 6(%esp)
    lgdt 6(%esp)
    ret

# void load_idtr(int limit, int addr)
load_idtr:
    movw 4(%esp), %ax
    movw %ax, 6(%esp)
    lidt 6(%esp)
    ret

# int load_cr0(void)
load_cr0:
    movl %cr0, %eax
    ret

# void store_cr0(int cr0);
store_cr0:
    movl 4(%esp), %eax
    movl %eax, %cr0
    ret

# void load_tr(int tr);
load_tr:
    ltr 4(%esp)
    ret

asm_inthandler20:
    push %es
    push %ds
    pusha
    mov %esp, %eax
    push %eax
    mov %ss, %ax
    mov %ax, %ds
    mov %ax, %es
    call inthandler20
    pop %eax
    popa
    pop %ds
    pop %es
    iret

asm_inthandler21:
    push %es
    push %ds
    pusha
    mov %esp, %eax
    push %eax
    mov %ss, %ax
    mov %ax, %ds
    mov %ax, %es
    call inthandler21
    pop %eax
    popa
    pop %ds
    pop %es
    iret

asm_inthandler27:
    push %es
    push %ds
    pusha
    mov %esp, %eax
    push %eax
    mov %ss, %ax
    mov %ax, %ds
    mov %ax, %es
    call inthandler27
    pop %eax
    popa
    pop %dx
    pop %es
    iret

asm_inthandler2c:
    push %es
    push %ds
    pusha
    mov %esp, %eax
    push %eax
    mov %ss, %ax
    mov %ax, %ds
    mov %ax, %es
    call inthandler2c
    pop %eax
    popa
    pop %ds
    pop %es
    iret


# void farjmp(int eip, int cs);
farjmp:
    ljmpl *4(%esp)
    ret

# void farcall(int eip, int cs);
farcall:
    lcall *4(%esp)
    ret

asm_cons_putchar:
    sti
    push $1
    #andl 0xff, %eax
    push %eax
    push (0x0fec)
    call cons_putchar
    add $12, %esp
    iret

