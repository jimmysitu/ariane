CROSSCOMPILE ?= riscv64-unknown-elf-
CC = ${CROSSCOMPILE}gcc
PYTHON=python

CFLAGS = -O0 -ggdb -march=rv64imac -mabi=lp64 -mcmodel=medany -mexplicit-relocs \
		 -Wstack-usage=0x800 -Wall

CFLAGS_DBG = \
		 -fstack-usage \
		 -Wstack-usage=0x800 -Wall \

CCASFLAGS = -mcmodel=medany -mexplicit-relocs
LDFLAGS = -nostdlib -nodefaultlibs -nostartfiles

INCLUDES = -I./ -I./src -I./zynq_bsp/ariane_zynq/include
DEFINES = -DPRINTF_DISABLE_SUPPORT_EXPONENTIAL \
		  -DPRINTF_DISABLE_SUPPORT_FLOAT \

SRCS_C = src/main.c src/uart.c src/sd.c src/gpt.c src/printf.c src/timer.c
SRCS_ASM = startup.S
OBJS_C = $(SRCS_C:.c=.o)
OBJS_S = $(SRCS_ASM:.S=.o)
LIBS = zynq_bsp/ariane_zynq/lib/libxil.a

MAIN = bootrom.elf
MAIN_DBG = bootrom_dbg.elf
MAIN_BIN = $(MAIN:.elf=.bin)
MAIN_IMG = $(MAIN:.elf=.img)
MAIN_SV = $(MAIN:.elf=.sv)

#.PHONY: clean

default: all

$(MAIN_DBG): ariane.dtb $(OBJS_C) $(OBJS_S) linker_dbg.lds
	$(CC) $(CFLAGS) $(CFLAGS_DBG) $(LDFLAGS) $(INCLUDES) $(DEFINES) \
		-Tlinker_dbg.lds $(OBJS_S) $(OBJS_C) $(LIBS) -o $@
	@echo "LD    >= $@"

$(MAIN): ariane.dtb $(OBJS_C) $(OBJS_S) linker.lds $(LIBS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDES) $(DEFINES) \
		-Tlinker.lds $(OBJS_S) $(OBJS_C) $(LIBS) -o $@
	@echo "LD    >= $@"

%.img: %.bin
	dd if=$< of=$@ bs=128

%.bin: %.elf
	$(CROSSCOMPILE)objcopy -O binary $< $@

%.o: %.c
	@$(CC) $(CFLAGS) $(INCLUDES) $(DEFINES) -c $<  -o $@
	@echo "CC    <= $<"

%.o: %.S
	@$(CC) $(CFLAGS) $(CCASFLAGS) $(INCLUDES) -c $<  -o $@
	@echo "CC    <= $<"

%.dtb: %.dts
	dtc -I dts $< -O dtb -o $@

%.sv: %.img
	$(PYTHON) ./gen_rom.py $<
	@echo "PYTHON >= $(MAIN_SV)"

clean:
	make -C zynq_bsp clean
	$(RM) $(OBJS_C) $(OBJS_S) $(MAIN) $(MAIN_BIN) $(MAIN_IMG) *.dtb

lib:
	make -C zynq_bsp

all: lib $(MAIN) $(MAIN_BIN) $(MAIN_IMG) $(MAIN_SV)
	@echo "Zero stage bootloader has been compiled!"

debug: lib $(MAIN_DBG)

# DO NOT DELETE THIS LINE -- make depend needs it
