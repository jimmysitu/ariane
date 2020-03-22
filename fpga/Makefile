VIVADO ?= vivado
VIVADOFLAGS ?= -nojournal -mode batch -source scripts/prologue.tcl

work-dir := work-fpga
ip-dir := xilinx
ifeq ($(BOARD), miz701n)
	bit := $(work-dir)/ariane_zynq.bit
	mcs := $(work-dir)/ariane_zynq.mcs
	ips := 	xlnx_ps_7.xci                 \
			xlnx_axi_dwidth_converter.xci \
			xlnx_axi_gpio.xci             \

else ifeq ($(BOARD), genesys2)
	bit := $(work-dir)/ariane_xilinx.bit
	mcs := $(work-dir)/ariane_xilinx.mcs
	ips := 	xlnx_axi_clock_converter.xci  \
			xlnx_axi_dwidth_converter.xci \
			xlnx_axi_quad_spi.xci         \
			xlnx_axi_gpio.xci             \
			xlnx_clk_gen.xci              \
			xlnx_mig_7_ddr3.xci
endif

ips := $(addprefix $(work-dir)/, $(ips))
ips-target := $(join $(addsuffix /ip/, $(addprefix $(ip-dir)/, $(basename $(ips)))), $(ips))

all: $(mcs)

# Generate mcs from bitstream
$(mcs): $(bit)
ifeq ($(BOARD), miz701n)
	$(VIVADO) -nojournal -mode batch -source scripts/dummy_system.tcl
	xsct scripts/create_fsbl.tcl
	bootgen -arch zynq -image scripts/zynq_qspi.bif \
		-w on -o dummy_system.bin
else ifeq ($(BOARD), genesys2)
	$(VIVADO) $(VIVADOFLAGS) -source scripts/write_cfgmem.tcl -tclargs $@ $^
endif

$(bit): $(ips)
	mkdir -p $(work-dir)
	$(VIVADO) $(VIVADOFLAGS) -source scripts/run.tcl
ifeq ($(BOARD), miz701n)
	cp ariane.runs/impl_1/ariane_zynq* ./$(work-dir)
else ifeq ($(BOARD), genesys2)
	cp ariane.runs/impl_1/ariane_xilinx* ./$(work-dir)
endif

$(ips): %.xci :
	mkdir -p $(work-dir)
	@echo Generating $(@F)
	@cd $(ip-dir)/$(basename $(@F)) && make clean && make
	@cp $(ip-dir)/$(basename $(@F))/ip/$(@F) $@

mcs: $(mcs)

program:
	$(VIVADO) $(VIVADOFLAGS) -source scripts/program.tcl
ifeq ($(BOARD), miz701n)
	xsct scripts/zynq_post.tcl
endif

flash:
ifeq ($(BOARD), miz701n)
	# AR# 70548
	# Zynq-7000 - QSPI programming in QSPI-boot mode
	cp -Trf dummy_system.fsbl dummy_system.flash
	sed -i '/BootModeRegister &= BOOT_MODES_MASK\;/a \\tBootModeRegister = JTAG_MODE\;' dummy_system.flash/main.c
	make -C dummy_system.flash all
	$(VIVADO) -nojournal -mode batch -source scripts/flash_zynq_qspi.tcl
endif

clean:
	rm -rf *.log *.jou *.str *.mif *.xpr *.runs *.sdk *.srcs *.sim \
		$(work-dir) *.cache *.hw *.ip_user_files

.PHONY:
	clean
