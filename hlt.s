
    movl $0x41, %eax # 'A'
    lcall $2*8, $0x028414e # asm_cons_putchar
fin:
    hlt
    jmp fin
