#include "platform.h"
#include "timer.h"
#include "printf.h"

uint64_t mtime_read(void)
{
  return *(volatile uint64_t *)(CLINT_BASE + MTIME_OFFSET);
}




void usleep(uint64_t us){

    uint64_t start_mtime, delta_mtime;

    // Don't start measuruing until we see an mtime tick
    uint64_t tmp = mtime_read();
    do{
        start_mtime = mtime_read();
    }while(start_mtime == tmp);

    do{
        delta_mtime = mtime_read() - start_mtime;
    }while(delta_mtime < (us*(PLATFORM_FREQ/1000000)));

}

