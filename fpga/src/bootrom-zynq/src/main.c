#include "platform.h"
#include "uart.h"
#include "spi.h"
#include "sd.h"
#include "gpt.h"

int main()
{
    init_uart(PLATFORM_FREQ, 115200);
    print_uart("Hello World!\r\n");

    int res = gpt_find_boot_partition((uint8_t *)DRAM_BASE, 2 * 16384);

    if (res == 0)
    {
        // jump to the address
        __asm__ volatile("li s0, %0"
                : //no output
                : "i" (DRAM_BASE));
        __asm__ volatile("la a1, _dtb");
        __asm__ volatile("jr s0" );
    }

    while (1)
    {
        // do nothing
    }
}

void handle_trap(void)
{
    // print_uart("trap\r\n");
}
