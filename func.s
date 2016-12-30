.code32
.globl io_hlt, io_cli, io_sti, io_stihlt
.globl io_out8, io_in8
.globl io_store_eflags, io_load_eflags
.globl load_gdtr, load_idtr
.globl load_cr0, store_cr0
.globl load_tr
.globl asm_inthandler20, asm_inthandler21, asm_inthandler2c, asm_inthandler27
.globl asm_inthandler0c, asm_inthandler0d
.globl asm_end_app
.globl farjmp, farcall
.globl asm_hrb_api
.globl start_app
.extern inthandler20, inthandler21, inthandler2c, inthandler27
.extern inthandler0c, inthandler0d
.extern hrb_api
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

asm_inthandler0c:
    sti
    push %es
    push %ds
    pusha
    mov %esp, %eax
    push %eax
    mov %ss, %ax
    mov %ax, %ds
    mov %ax, %es
    call inthandler0c
    cmp $0, %eax
    jne asm_end_app
    pop %eax
    popa
    pop %ds
    pop %es
    add $4, %esp
    iret

asm_inthandler0d:
    sti
    push %es
    push %ds
    pusha
    mov %esp, %eax
    push %eax
    mov %ss, %ax
    mov %ax, %ds
    mov %ax, %es
    call inthandler0d
    cmp $0, %eax
    jne asm_end_app
    pop %eax
    popa
    pop %ds
    pop %es
    add $4, %esp
    iret


# void farjmp(int eip, int cs);
farjmp:
    ljmpl *4(%esp)
    ret

# void farcall(int eip, int cs);
farcall:
    lcall *4(%esp)
    ret

asm_hrb_api:
    sti
    push %ds
    push %es
    pusha
    pusha
    mov %ss, %ax
    mov %ax, %ds
    mov %ax, %es
    call hrb_api
    cmp $0, %eax
    jne asm_end_app
    add $32, %esp
    popa
    pop %es
    pop %ds
    iret

asm_end_app:
    mov (%eax), %esp
    movw $0, 4(%eax)
    popa
    ret # return to cmp_app

# void start_app(int eip, int cs, int esp, int ds, int *tss_esp0);
start_app:
    pusha # 32ビットレジスタを全部保存しておく
    mov 36(%esp), %eax # アプリ用のEIP
    mov 40(%esp), %ecx # アプリ用のCS
    mov 44(%esp), %edx # アプリ用のESP
    mov 48(%esp), %ebx # アプリ用のDS/SS
    mov 52(%esp), %ebp # tss.esp0の番地
    mov %esp, (%ebp) # OS用のESPを保存
    mov %ss, 4(%ebp) # OS用のSSを保存
    mov %bx, %es
    mov %bx, %ds
    mov %bx, %fs
    mov %bx, %gs
# 以下はlretでアプリに行かせるためのスタック調整
    or $3, %ecx # アプリ用のセグメント番号に3をorする
    or $3, %ebx # アプリ用のセグメント番号に3をorする
    push %ebx   # アプリのss
    push %edx   # アプリのesp
    push %ecx   # アプリのcs
    push %eax   # アプリのeip
    lret

