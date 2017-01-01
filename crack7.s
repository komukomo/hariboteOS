.global Main
.extern api_putchar

Main:
    mov  $1005*8, %ax
    mov  %ax, %ds
    mov  %ds:0x0000, %ecx  # このアプリのデータセグメントの大きさを読み取る
    mov  $2005*8, %ax
    mov  %ax, %ds

crackloop:       # 123で埋め尽くす
    sub  $1, %ecx
    movb $123, %ds:(%ecx)
    cmp  $0, %ecx
    push $40
    call api_putchar # ループが回っているかどうかの確認
    pop %eax
    jne  crackloop

fin:        # 終了
    mov  $4, %edx
    int  $0x40
