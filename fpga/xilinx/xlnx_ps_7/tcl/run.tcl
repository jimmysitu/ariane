set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set ipName xlnx_ps_7

create_project $ipName . -force -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name processing_system7 -vendor xilinx.com -library ip -module_name $ipName
set_property -dict [list  \
            CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {50}          \
            CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {40}            \
            CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125}  \
            CONFIG.PCW_USE_FABRIC_INTERRUPT {1}             \
            CONFIG.PCW_P2F_QSPI_INTR {1}                    \
            CONFIG.PCW_P2F_ENET0_INTR {1}                   \
            CONFIG.PCW_P2F_USB0_INTR {1}                    \
            CONFIG.PCW_P2F_SDIO0_INTR {1}                   \
            CONFIG.PCW_P2F_SDIO1_INTR {1}                   \
            CONFIG.PCW_P2F_UART1_INTR {1}                   \
            CONFIG.PCW_P2F_GPIO_INTR {1}                    \
            CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V}   \
            CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1}           \
            CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}        \
            CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1}            \
            CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V}   \
            CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1}          \
            CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27}        \
            CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1}            \
            CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53}     \
            CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1}           \
            CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39}          \
            CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1}            \
            CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45}            \
            CONFIG.PCW_SD0_GRP_CD_ENABLE {1}                \
            CONFIG.PCW_SD0_GRP_CD_IO {MIO 47}               \
            CONFIG.PCW_SD1_PERIPHERAL_ENABLE {1}            \
            CONFIG.PCW_SD1_SD1_IO {MIO 10 .. 15}            \
            CONFIG.PCW_SD1_GRP_CD_ENABLE {1}                \
            CONFIG.PCW_SD1_GRP_CD_IO {MIO 9}                \
            CONFIG.PCW_SD1_GRP_WP_ENABLE {1}                \
            CONFIG.PCW_SD1_GRP_WP_IO {MIO 0}                \
            CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1}          \
            CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49}        \
            CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1}             \
            CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO}               \
            CONFIG.PCW_USB_RESET_ENABLE {1}                 \
            CONFIG.PCW_USB0_RESET_IO {MIO 46}               \
            CONFIG.PCW_USE_S_AXI_HP0 {1}                    \
            CONFIG.PCW_USE_S_AXI_GP0 {1}                    \
            CONFIG.PCW_USE_M_AXI_GP0 {0}                    \
            CONFIG.PCW_USE_M_AXI_GP1 {0}
] [get_ips $ipName]


generate_target {instantiation_template} [get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1
