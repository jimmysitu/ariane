#ifndef _PLATFORM_H
#define _PLATFORM_H

#define PLATFORM_FREQ 40000000

#define DRAM_BASE 0x10000000
#define DRAM_SIZE 0x30000000

#define CLINT_BASE 0x02000000
#define CLINT_SIZE 0xC0000

#define MTIME_OFFSET 0xBFF8

// CSRs
#define CSR_ICACHE 0x700
#define CSR_DCACHE 0x701

#endif

