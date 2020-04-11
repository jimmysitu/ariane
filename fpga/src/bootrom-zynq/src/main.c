#include "platform.h"

#include "timer.h"
#include "uart.h"
#include "printf.h"
#include "gpt.h"

int main(){
    init_uart(PLATFORM_FREQ, 115200);
    printf("Ariane ZYNQ Zero Stage Bootloader\n");

    for (int i =0; i < 3; i++){
        usleep(1000000);    // 1 second
        printf("...");
    }
    printf("\n");

    // Disable & enable cache
    __asm__ volatile("csrwi 0x701, 0x00");
    __asm__ volatile("csrwi 0x701, 0x01");

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

