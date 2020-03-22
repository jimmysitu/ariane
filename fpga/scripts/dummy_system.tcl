# 0. Source configure file
source scripts/dummy_system_init.tcl
source xilinx/xlnx_ps_7/tcl/config.tcl

create_project $designName . -force -part $partNumber
set_property board_part $boardName [current_project]

# 1. Create block design
create_bd_design $designName
current_bd_design $designName


set xlnx_ps_7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 $ipName ]
set_property -dict $ipParameter $xlnx_ps_7

connect_bd_net [get_bd_pins $ipName/FCLK_CLK0] [get_bd_pins $ipName/S_AXI_HP0_ACLK]
connect_bd_net [get_bd_pins $ipName/FCLK_CLK0] [get_bd_pins $ipName/S_AXI_GP0_ACLK]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
    -config {make_external "FIXED_IO, DDR" Master "Disable" Slave "Disable" } \
    [get_bd_cells $ipName]
save_bd_design
make_wrapper -files [get_files $designName.srcs/sources_1/bd/$designName/$designName.bd] -top
add_files -norecurse $designName.srcs/sources_1/bd/$designName/hdl/$designName\_wrapper.v

regexp -- {Vivado v([0-9]{4})\.[0-9]} [version] -> year
# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part $partNumber \
    -flow {Vivado Synthesis $year} \
    -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
    set_property flow "Vivado Synthesis $year" [get_runs synth_1]
    set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
}

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part $partNumber \
        -flow {Vivado Implementation $year} \
        -strategy "Vivado Implementation Defaults" \
        -parent_run synth_1
} else {
    set_property flow "Vivado Implementation $year" [get_runs impl_1]
    set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
}
# set the current impl run
current_run -implementation [get_runs impl_1]

# Synthesis
launch_runs synth_1
wait_on_run synth_1

# Generate hwdef
write_hwdef -force  -file $designName.sdk/$designName\_wrapper.hwdef

set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

# Generate hdf
write_sysdef -force -hwdef $designName.sdk/$designName\_wrapper.hwdef \
    -bitfile work-fpga/ariane_zynq.bit \
    -file $designName.sdk/$designName\_wrapper.hdf

