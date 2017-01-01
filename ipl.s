.equ CYLS, 20
.text
.code16
    jmp entry

    .byte 0x90
    .ascii "HELLOIPL"
    .word 512
    .byte 1
    .word 1
    .byte 2
    .word 224
    .word 2880
    .byte 0xf0
    .word 9
    .word 18
    .word 2
    .int 0
    .int 2880
    .byte 0, 0, 0x29
    .int 0xffffffff
    .ascii "HELLO-OS   "
    .ascii "FAT12   "
    .skip 18, 0x00

entry:
    movw $0, %ax
    movw %ax, %ss
    movw $0x7c00, %sp
    movw %ax, %ds
    movw %ax, %es

    movw $0x0820, %ax
    movw %ax, %es
    movb $0x00, %ch # cylinder:0
    movb $0x00, %dh # head:0
    movb $0x02, %cl # sector:2
readloop:
    movw $0x00, %si
retry:
    movb $0x02, %ah # 0x02:Read Sectors
    movb $0x01, %al # 1 sector
    movw $0, %bx
    movb $0x00, %dl # drive:0
    int $0x13 # 0x13:Disk Services
    jnc next
    addw $0x01, %si
    cmpw $0x05, %si
    jae error
    movb $0x00, %ah
    movb $0x00, %dl
    int $0x13 # reset
    jmp retry
next:
    movw %es, %ax
    addw $0x0020, %ax
    movw %ax, %es
    addb $0x01, %cl
    cmpb $18, %cl
    jbe readloop

    movb $0x01, %cl
    addb $0x01, %dh
    cmpb $0x02, %dh
    jb readloop
    movb $0x00, %dh
    addb $0x01, %ch
    cmpb $CYLS, %ch
    jb readloop

    movb $CYLS, (0x0ff0)
    jmp 0xc200

fin:
    hlt
    jmp fin

error:
    movw $msg, %si
putloop:
    movb (%si), %al
    addw $1, %si
    cmpb $0, %al
    je fin
    movb $0x0e, %ah
    movw $15, %bx
    int $0x10
    jmp putloop
msg:
    .byte 0x0a, 0x0a
    .string "load error"
