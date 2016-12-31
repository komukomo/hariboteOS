OUTPUT_FORMAT("binary")

SECTIONS {
    . = 0x00;
    .text : { *(.text) }
    . = 0x800;
    .data : { *(.data) }
    .rodata : { *(.rodata) }
}
