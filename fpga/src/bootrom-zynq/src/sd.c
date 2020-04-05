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
        return -1;
    }

    status = XSdPs_CfgInitialize(&Ps7_sd_0, SdConfig_0, SdConfig_0->BaseAddress);
    if (status != XST_SUCCESS) {
        printf("SD Config failed !\n");
        return -2;
    }
    
    status = XSdPs_SdCardInitialize(&Ps7_sd_0);
    if (status != XST_SUCCESS) {
        printf("SD0 Initialization failed !\n");
        return -3;
    }
    else {
        printf("SD0 Initialization succeed !\n");
    }
    return 0;
}

int sd_copy(void *dst, uint32_t src_lba, uint32_t size)
{
    int status = XSdPs_ReadPolled(&Ps7_sd_0, src_lba, 1, dst);
    if(status != 0){
        printf("SD0 Read failed!\n");
        return -1;
    }
    return 0;
}

