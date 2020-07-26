#include "sd.h"
#include "printf.h"

#include "xparameters.h"
#include "xsdps.h"

static XSdPs Ps7_sd_0;

int init_sd()
{
    printf("Initializing SD...\n");

    XSdPs_Config * SdConfig_0;
    int32_t status;

    SdConfig_0 = XSdPs_LookupConfig(XPAR_PS7_SD_0_DEVICE_ID);
    if (NULL == SdConfig_0) {
        printf("SD lookup config failed!\n");
        return -1;
    }

    status = XSdPs_CfgInitialize(&Ps7_sd_0, SdConfig_0, SdConfig_0->BaseAddress);
    if (status != XST_SUCCESS) {
        printf("SD config initial failed, status: %d\n", status);
        return -2;
    }

    status = XSdPs_CardInitialize(&Ps7_sd_0);
    if (status != XST_SUCCESS) {
        printf("SD0 card initialization failed, status: %d\n", status);
        return -3;
    }
    else {
        printf("SD0 Initialization succeed!\n");
    }
    return 0;
}

// Max block count is between 0x3000-0x4000
#define MAX_BLKCNT (0x3000)
int sd_copy(void *dst, uint32_t src_lba, uint32_t blkcnt)
{
    uint8_t *buff = dst;
    // For unknown reason, XSdPs_ReadPolled fails when blkcnt is to large
    while(blkcnt > MAX_BLKCNT) {
        int status = XSdPs_ReadPolled(&Ps7_sd_0, src_lba, MAX_BLKCNT, buff);
        if(status != XST_SUCCESS){
            printf("SD0 Read failed, status: %d\n", status);
            return -1;
        }
        src_lba = src_lba + MAX_BLKCNT;
        buff = buff + MAX_BLKCNT * XSDPS_BLK_SIZE_512_MASK;
        blkcnt = blkcnt - MAX_BLKCNT;
    }

    int status = XSdPs_ReadPolled(&Ps7_sd_0, src_lba, blkcnt, buff);
    if(status != XST_SUCCESS){
            printf("SD0 Read failed, status: %d\n", status);
            return -1;
    }
    return 0;
}

