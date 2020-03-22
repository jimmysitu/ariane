source scripts/dummy_system_init.tcl

open_hw
connect_hw_server -url localhost:3121

# Program flash
set stdout [exec program_flash -f $designName.bin -fsbl $designName.flash/executable.elf \
	-flash_type qspi_single -blank_check -verify \
	-cable type xilinx_tcf url tcp:localhost:3121]

puts $stdout

