ENTRY(_prog_start)

MEMORY
{
    ROM     (rx) : ORIGIN = 0x00010000, LENGTH = 0x10000
    CLINT   (rw) : ORIGIN = 0x02000000, LENGTH = 0xC0000
    UART    (rw) : ORIGIN = 0xC0000000, LENGTH = 0x1000
    /* DRAM 0x10000000 is reserved for FSBL loading */
    DRAM    (rwx): ORIGIN = 0x20000000, LENGTH = 0x20000000
}

SECTIONS
{
    _STACK_SIZE = DEFINED(_STACK_SIZE) ? _STACK_SIZE : 2K;

    .text.init : {
        *(.text.init)
    } > ROM

    .text : ALIGN(0x100) {
    _TEXT_START_ = .;
        *(.text)
    _TEXT_END_ = .;
    } > ROM

    .preinit_array : {
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP (*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);
    } > ROM

    .init_array : {
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
        KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
        PROVIDE_HIDDEN (__init_array_end = .);
    } > ROM

    .fini_array : {
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
        KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
        PROVIDE_HIDDEN (__fini_array_end = .);
    } > ROM

    .ctors : {
    /* gcc uses crtbegin.o to find the start of
       the constructors, so we make sure it is
       first.  Because this is a wildcard, it
       doesn't matter if the user does not
       actually link against crtbegin.o; the
       linker won't look for a file to match a
       wildcard.  The wildcard also means that it
       doesn't matter which directory crtbegin.o
       is in.  */
        KEEP (*crtbegin.o(.ctors))
        KEEP (*crtbegin?.o(.ctors))
    /* We don't want to include the .ctor section from
       the crtend.o file until after the sorted ctors.
       The .ctor section from the crtend file contains the
       end of ctors marker and it must be last */
        KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*(.ctors))
    } > ROM

    .dtors : {
        KEEP (*crtbegin.o(.dtors))
        KEEP (*crtbegin?.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*(.dtors))
    } > ROM

    .rodata : ALIGN(0x100) {
    _RODATA_START_ = .;
        *(.rodata)
        *(.dtb*)
        *(.rodata*)
    _RODATA_END_ = .;
    } > ROM

    .data : ALIGN(0x100) {
    _DATA_START_ = .;
        *(.data)
        PROVIDE( __global_pointer$ = . + 0x800 );
        *(.sdata .sdata.*)
    _DATA_END_ = .;
    } > DRAM AT > ROM

    PROVIDE(_data = ADDR(.data));
    PROVIDE(_data_lma = LOADADDR(.data));
    PROVIDE(_edata = .);

    PROVIDE( _bss_start = . );
    .bss : ALIGN(0x100) {
    _BSS_START_ = .;
        *(.bss)
    _BSS_END_ = .;
    } > DRAM
    PROVIDE( _bss_end = . );

    .heap : ALIGN(0x100) {
    _HEAP_START = .;
        *(.heap*)
     _HEAP_END = .;
    } > DRAM

    .stack ORIGIN(DRAM) + LENGTH(DRAM) - _STACK_SIZE : {
    _STACK_TOP = .;
        . += _STACK_SIZE;
        PROVIDE(_stack = .);
    _STACK_BOT = .;
    }

    . = ALIGN(8);
    PROVIDE( _end = . );
    PROVIDE( end = . );

}
