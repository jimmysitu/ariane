#include "platform.h"

#include "uart.h"
#include "printf.h"
#include "gpt.h"

int main(){
    init_uart(PLATFORM_FREQ, 115200);
    printf("Ariane ZYNQ Zero Stage Bootloader\n");

    usleep(1000000);
    printf("...");
    usleep(1000000);
    printf("...");

    int res = gpt_find_boot_partition((uint8_t *)DRAM_BASE, 2 * 16384);

    if(res == 0){
        // jump to the address
        __asm__ volatile("li s0, %0"
                : //no output
                : "i" (DRAM_BASE));
        __asm__ volatile("la a1, _dtb");
        __asm__ volatile("jr s0" );
    }
    
    // Should never be here
    printf("Ariane ZYNQ zero stage boot fail\n");
    while(1){
    }
}

