#include "platform.h"

#include "timer.h"
#include "uart.h"
#include "printf.h"
#include "gpt.h"


int main(){
    init_uart(PLATFORM_FREQ, 115200);
    printf("Ariane ZYNQ Zero Stage Bootloader\n");
    
    // Wait for a while for connection of OpenOCD
    for (int i =0; i < 5; i++){
        usleep(1000000);    // 1 second
        printf("...");
    }
    printf("\n");


    int res = gpt_find_boot_partition((uint8_t *)DRAM_BASE, 0x8000);  // 0x8000*0x200 = 16MB

    uint8_t* dram = DRAM_BASE;
    printf("DRAM_BASE@0x%llx\n", DRAM_BASE);

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
        echo();
    }
}

