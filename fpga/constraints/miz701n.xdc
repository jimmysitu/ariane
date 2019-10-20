## Reset
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports sys_resetn]

# Clock
set_property -dict { PACKAGE_PIN {H16} IOSTANDARD {LVCMOS33}} [get_ports {sys_clock}]

## Use user IO as JTAG
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 PULLUP {TRUE}} [get_ports { trst_n }];
set_property -dict { PACKAGE_PIN L15 IOSTANDARD LVCMOS33 PULLUP {TRUE}} [get_ports { tck    }];
set_property -dict { PACKAGE_PIN B19 IOSTANDARD LVCMOS33 PULLUP {TRUE}} [get_ports { tdi    }];
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 PULLUP {TRUE}} [get_ports { tdo    }];
set_property -dict { PACKAGE_PIN A20 IOSTANDARD LVCMOS33 PULLUP {TRUE}} [get_ports { tms    }];
set_property CLOCK_DEDICATED_ROUTE {FALSE} [get_nets [get_ports {tck}]]
set_false_path -from [get_ports { trst_n } ]


# LEDs
set_property -dict { PACKAGE_PIN {N15} IOSTANDARD {LVCMOS33}} [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN {N16} IOSTANDARD {LVCMOS33}} [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN {M19} IOSTANDARD {LVCMOS33}} [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN {M20} IOSTANDARD {LVCMOS33}} [get_ports {led[3]}]

## Buttons
set_property -dict { PACKAGE_PIN {M15} IOSTANDARD {LVCMOS33}} [get_ports {sw[0]}]

## UART
set_property PACKAGE_PIN {E18} [get_ports {rx}]
set_property IOSTANDARD {LVCMOS33} [get_ports {rx}]
set_property IOB {TRUE} [ get_cells -of_objects [ all_fanout -flat -endpoints_only [get_ports {rx}]]]
set_property PACKAGE_PIN {G17} [get_ports {tx}]
set_property IOSTANDARD {LVCMOS33} [get_ports {tx}]
set_property IOB {TRUE} [ get_cells -of_objects [ all_fanin -flat -startpoints_only [get_ports {tx}]]]

