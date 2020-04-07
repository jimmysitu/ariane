ENTRY(main)

SECTIONS
{
    _STACK_SIZE = DEFINED(_STACK_SIZE) ? _STACK_SIZE : 2K;
    DRAM_BASE = 0x20000000; /* DRAM_BASE for debug */
    . = DRAM_BASE;

    .text.init : { *(.text.init) }

    .text : ALIGN(0x100) {
    _TEXT_START_ = .;
        *(.text)
    _TEXT_END_ = .;
    }

    .data : ALIGN(0x100) {
    _DATA_START_ = .;
        *(.data)
    _DATA_END_ = .;
    }

    PROVIDE(_data = ADDR(.data));
    PROVIDE(_data_lma = LOADADDR(.data));
    PROVIDE(_edata = .);

    .bss : ALIGN(0x100) {
    _BSS_START_ = .;
        *(.bss)
    _BSS_END_ = .;
    }

    .rodata : ALIGN(0x100) {
    _RODATA_START_ = .;
        *(.rodata)
        *(.dtb*)
        *(.rodata*)
    _RODATA_END_ = .;
    }

    .stack : ALIGN(0x100) {
    _STACK_END = .;
        PROVIDE( __stack = . );
        . += _STACK_SIZE;
    _STACK_START = .;
    }

}
