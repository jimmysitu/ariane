#include "gpt.h"
#include "printf.h"

#include "sd.h"
#include "uart.h"

int gpt_find_boot_partition(uint8_t* dest, uint32_t size)
{
    int ret = init_sd();
    if (ret != 0) {
        printf("Could not initialize SD... exiting\n");
        return -1;
    }

    printf("SD initialized!\n");

    size_t block_size = 512;

    int res;
    // load LBA1
    uint8_t lba1_buf[block_size];

    res = sd_copy(lba1_buf, 1, 1);
    if(res != 0){
        printf("SD card failed!\n");
        printf("sd_copy return value: %d\n", res);
        return -2;
    }
    gpt_pth_t *lba1 = (gpt_pth_t *)lba1_buf;

    printf("GPT partition table header:\n");

    printf("\tsignature:    ");
    uint8_t *sign = &(lba1->signature);
    for(int i=0; i<8; i++){
        printf("%c", sign[i]);
    }
    printf("\n");

    printf("\trevision:     %08X\n", lba1->revision);
    printf("\tsize:         %08X\n", lba1->header_size);
    printf("\tcrc_header:   %08X\n", lba1->crc_header);
    printf("\treserved:     %08X\n", lba1->reserved);
    printf("\tcurrent lba:  %llu\n", lba1->current_lba);
    printf("\tbackup lda:   %llu\n", lba1->backup_lba);
    printf("\tpartition entries lba:    %016llX\n", lba1->partition_entries_lba);
    printf("\tnumber partition entries: %8X\n", lba1->nr_partition_entries);
    printf("\tsize partition entries:   %8X\n", lba1->size_partition_entry);

    // load LBA2
    uint8_t lba2_buf[block_size];
    res = sd_copy(lba2_buf, lba1->partition_entries_lba, 1);

    if(res != 0){
        printf("SD card failed!\n");
        printf("sd_copy return value: %x\n", res);
        return -2;
    }

    for(int i = 0; i < 4; i++){
        partition_entries_t *part_entry = (partition_entries_t *)(lba2_buf + (i * 128));
        printf("GPT partition entry %d", i);
        printf("\n\tpartition type guid:    ");
        for (int j = 0; j < 16; j++)
            printf("%02X", part_entry->partition_type_guid[j]);

        printf("\n\tpartition guid:         ");
        for (int j = 0; j < 16; j++)
            printf("%02X", part_entry->partition_guid[j]);

        printf("\n\tfirst lba:    %u", part_entry->first_lba);
        printf("\n\tlast lba:     %u", part_entry->last_lba);
        printf("\n\tattributes:   %016llX", part_entry->attributes);
        printf("\n\tname:         ");
        for (int j = 0; j < 72; j++)
            printf("%02X", part_entry->name[j]);
        printf("\n");
    }

    partition_entries_t *boot = (partition_entries_t *)(lba2_buf);
    printf("Copying boot image...\n");
    res = sd_copy(dest, boot->first_lba, size);

    if (res != 0)
    {
        printf("SD card failed!\n");
        printf("sd_copy return value: %d\n", res);
        return -2;
    }

    printf("Done!\n");
    return 0;
}
