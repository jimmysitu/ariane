ENTRY(_prog_start)

MEMORY
{
    ROM     (rx) : ORIGIN = 0x00010000, LENGTH = 0x1000
    CLINT   (rw) : ORIGIN = 0x02000000, LENGTH = 0xC0000
    UART    (rw) : ORIGIN = 0xC0000000, LENGTH = 0x1000
    /* Change DRAM base for debug */
    DRAM    (rwx): ORIGIN = 0x20000000, LENGTH = 0x20000000
}

SECTIONS
{
    _STACK_SIZE = DEFINED(_STACK_SIZE) ? _STACK_SIZE : 2K;

    .text.init : {
        *(.text.init)
    } > DRAM

    .text : ALIGN(0x100) {
    _TEXT_START_ = .;
        *(.text)
    _TEXT_END_ = .;
    } > DRAM

    .rodata : ALIGN(0x100) {
    _RODATA_START_ = .;
        *(.rodata)
        *(.dtb*)
        *(.rodata*)
    _RODATA_END_ = .;
    } > DRAM

    .data : ALIGN(0x100) {
    _DATA_START_ = .;
        *(.data)
    _DATA_END_ = .;
    } > DRAM

    PROVIDE(_data = ADDR(.data));
    PROVIDE(_data_lma = LOADADDR(.data));
    PROVIDE(_edata = .);

    .bss : ALIGN(0x100) {
    _BSS_START_ = .;
        *(.bss)
    _BSS_END_ = .;
    } > DRAM

    .heap : ALIGN(0x100) {
    _HEAP_START = .;
        *(.heap*)
     _HEAP_END = .;
    } > DRAM

    .stack ORIGIN(DRAM) + LENGTH(DRAM) - _STACK_SIZE : {
    _STACK_TOP = .;
        . += _STACK_SIZE;
        PROVIDE(__stack = .);
    _STACK_BOT = .;
    }

    . = ALIGN(8);
    PROVIDE( _end = . );
    PROVIDE( end = . );

}
