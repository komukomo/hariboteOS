OUTPUT_FORMAT("binary")

SECTIONS {
    . = 0x7c00;
    .text : { *(.text) }
    . = 0x7dfe;
    .sig : { SHORT(0xaa55); }
}
