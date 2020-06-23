# start sequence of the bootloader
#
#
#include <smp.h>
#include "platform.h"

    .section .text.init
    .option norvc
    .globl _prog_start
_prog_start:
    smp_pause(s1, s2)

    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
	
    /* Load data section */
	la a0, _data_lma
	la a1, _data
	la a2, _edata
	bgeu a1, a2, 2f
1:
	lw t0, (a0)
	sw t0, (a1)
	addi a0, a0, 4
	addi a1, a1, 4
	bltu a1, a2, 1b
2:

	/* Clear bss section */
	la a0, _bss_start
	la a1, _bss_end
	bgeu a0, a1, 2f
1:
	sw zero, (a0)
	addi a0, a0, 4
	bltu a0, a1, 1b
2:
    
    call __libc_init_array

    la sp, _stack
    call main

    smp_resume(s1, s2)
    csrr a0, mhartid
    la a1, _dtb
    li s1, DRAM_BASE
    jr s1

    .section .dtb
    .globl _dtb
    .align 4, 0
_dtb:
    .incbin "ariane.dtb"

