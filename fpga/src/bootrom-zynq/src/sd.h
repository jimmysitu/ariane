#pragma once

#include <stdint.h>

// SD driver wrapper for xsdps
int init_sd();
int sd_copy(volatile void *dst, uint32_t src_lba, uint32_t size);
