MEMORY
{
    FLASH (rx)  : ORIGIN = 0x10000000, LENGTH = 64K
    RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 16K
}

ENTRY(_start)

SECTIONS
{
    .text : { *(.text*) *(.rodata*) } > FLASH
    .data : { *(.data*) } > RAM AT > FLASH
    .bss  : { *(.bss*) *(COMMON) } > RAM
}
