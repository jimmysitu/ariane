#include "platform.h"
#include "timer.h"
#include "printf.h"

uint64_t mtime_read(void)
{
  return *(volatile uint64_t *)(CLINT_BASE + MTIME_OFFSET);
}




void usleep(uint64_t us){

    uint64_t cur_mtime, end_mtime;

    cur_mtime = mtime_read();
    end_mtime = cur_mtime + us * (PLATFORM_FREQ/(2U*1000000U));
    do{
        cur_mtime = mtime_read();
    }while(cur_mtime < end_mtime);

    return;
}

