.extern Main
.text
    .long 0x10000 # segment size
    .ascii "Hari" # Hari-format
    .long 0
    .long 0x900 # esp
    .long 0x900 # data size
    .long 0x900 # data address
    .word 0
    .byte 0
    jmp Main
    .long 0x01200 # malloc address
