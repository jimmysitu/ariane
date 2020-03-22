source scripts/dummy_system_init.tcl

# Create FSBL
set hwdsgn [hsi::open_hw_design $designName.sdk/$designName\_wrapper.hdf]
hsi::generate_app -hw $hwdsgn -os standalone -proc ps7_cortexa9_0 \
    -app zynq_fsbl -sw fsbl -compile \
    -dir $designName.fsbl

