.extern Main
.text
    .long 0xf0000 # segment size
    .ascii "Hari" # Hari-format
    .long 0
    .long 0x20000 # esp
    .long 0x20000 # data size
    .long 0x20000 # data address
    .word 0
    .byte 0
    jmp Main
    .long 0x40000 # malloc address
