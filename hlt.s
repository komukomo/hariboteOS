.equ ASM_CONS_PUTCHAR, 0x0284153

    movl $'H', %eax
    lcall $2*8, $ASM_CONS_PUTCHAR
    movl $'E', %eax
    lcall $2*8, $ASM_CONS_PUTCHAR
    movl $'L', %eax
    lcall $2*8, $ASM_CONS_PUTCHAR
    movl $'L', %eax
    lcall $2*8, $ASM_CONS_PUTCHAR
    movl $'O', %eax
    lcall $2*8, $ASM_CONS_PUTCHAR
    lret
