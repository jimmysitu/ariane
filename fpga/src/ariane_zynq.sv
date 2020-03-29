// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Description: Xilinx ZYNQ top-level
// Author: Jimmy Situ <web@jimmystone.cn>

`ifndef ARIANE_ZYNQ
`define ARIANE_ZYNQ
module ariane_zynq (
   // Inouts
`ifndef VERILATOR
   PS_SRSTB, PS_PORB, PS_CLK, MIO, DDR_WEB, DDR_VRP, DDR_VRN,
   DDR_RAS_n, DDR_ODT, DDR_DRSTB, DDR_DQS_n, DDR_DQS, DDR_DQ, DDR_DM,
   DDR_Clk_n, DDR_Clk, DDR_CS_n, DDR_CKE, DDR_CAS_n, DDR_BankAddr,
   DDR_Addr,
   tck, tms, trst_n, tdi,tdo,
   dbg_o,
`else
   debug_req_ready, debug_req_valid, debug_req,
   debug_resp_ready, debug_resp_valid, debug_resp,
`endif
    /*AUTOARG*/
   // Outputs
   tx, led,
   // Inputs
   sys_clock, sys_resetn, rx, sw
   );


// SoC clock & reset
input logic sys_clock;
input logic sys_resetn;

// UART I/O
input logic rx;
output logic tx;

// GPIO I/O
input logic  [0:0] sw;
output logic [3:0] led;

`ifndef VERILATOR
// JTAG I/O
input  logic        tck;
input  logic        tms;
input  logic        trst_n;
input  logic        tdi;
output wire         tdo;
`endif

`ifndef VERILATOR
// Debug I/O
output logic [15:0] dbg_o;   // Debug IO to LA
assign dbg_o[0] = tck;
assign dbg_o[1] = tms;
assign dbg_o[2] = trst_n;
assign dbg_o[3] = tdi;
assign dbg_o[4] = tdo;
assign dbg_o[5] = tx;
assign dbg_o[6] = rx;
`endif

`ifndef VERILATOR
/*AUTOINOUT*/
// Beginning of automatic inouts (from unused autoinst inouts)
inout [14:0]            DDR_Addr;               // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout [2:0]             DDR_BankAddr;           // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   DDR_CAS_n;              // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   DDR_CKE;                // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   DDR_CS_n;               // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   DDR_Clk;                // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   DDR_Clk_n;              // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout [3:0]             DDR_DM;                 // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout [31:0]            DDR_DQ;                 // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout [3:0]             DDR_DQS;                // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout [3:0]             DDR_DQS_n;              // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   DDR_DRSTB;              // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   DDR_ODT;                // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   DDR_RAS_n;              // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   DDR_VRN;                // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   DDR_VRP;                // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   DDR_WEB;                // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout [53:0]            MIO;                    // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   PS_CLK;                 // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   PS_PORB;                // To/From i_xlnx_ps_7 of xlnx_ps_7.v
inout                   PS_SRSTB;               // To/From i_xlnx_ps_7 of xlnx_ps_7.v
// End of automatics
`endif
/*AUTOINPUT*/
/*AUTOOUTPUT*/

`ifndef VERILATOR
logic          debug_req_valid;
logic          debug_req_ready;
dm::dmi_req_t  debug_req;
logic          debug_resp_valid;
logic          debug_resp_ready;
dm::dmi_resp_t debug_resp;
`else
input  logic          debug_req_valid;
output logic          debug_req_ready;
input  dm::dmi_req_t  debug_req;
output logic          debug_resp_valid;
input  logic          debug_resp_ready;
output dm::dmi_resp_t debug_resp;
`endif

// 24 MByte in 8 byte words
localparam NumWords = (24 * 1024 * 1024) / 8;
localparam NBSlave = 2; // debug, ariane
localparam AxiAddrWidth = 32;
localparam AxiDataWidth = 64;
localparam AxiIdWidthMaster = 4;
localparam AxiIdWidthSlaves = AxiIdWidthMaster + $clog2(NBSlave); // 5
localparam AxiUserWidth = 1;

AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthMaster ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) slave[NBSlave-1:0]();

AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) master[ariane_soc::NB_PERIPHERALS-1:0]();

logic rst_n;        // reset from ps7, PoR
logic clk;          // clock from ps7, SoC clock
logic ndmreset;     // not debug module reset, from dm_top
logic ndmreset_n;   // not debug module reset, sync delay from ndmreset
logic debug_req_irq;
logic timer_irq;
logic ipi;

logic rtc;


// ROM
logic                    rom_req;
logic [AxiAddrWidth-1:0] rom_addr;
logic [AxiDataWidth-1:0] rom_rdata;

// Debug
logic          dmi_rst_n;

logic dmactive;

// IRQ
logic [1:0] irq;
logic [7:0] irq_p2f;

// disable test-enable
logic test_en;
assign test_en    = 1'b0;

logic [NBSlave-1:0] pc_asserted;

rstgen i_rstgen_dm (
    .clk_i        ( clk                     ),
    .rst_ni       ( rst_n & sys_resetn      ),
    .test_mode_i  ( test_en                 ),
    .rst_no       ( dmi_rst_n               ),
    .init_no      (                         ) // keep open
);

rstgen i_rstgen_main (
    .clk_i        ( clk                     ),
    .rst_ni       ( dmi_rst_n & (~ndmreset) ),
    .test_mode_i  ( test_en                 ),
    .rst_no       ( ndmreset_n              ),
    .init_no      (                         ) // keep open
);


// ---------------
// AXI Xbar
// ---------------
`ifndef VERILATOR
axi_node_wrap_with_slices #(
    // three ports from Ariane (instruction, data and bypass)
    .NB_SLAVE           ( NBSlave                    ),
    .NB_MASTER          ( ariane_soc::NB_PERIPHERALS ),
    .NB_REGION          ( ariane_soc::NrRegion       ),
    .AXI_ADDR_WIDTH     ( AxiAddrWidth               ),
    .AXI_DATA_WIDTH     ( AxiDataWidth               ),
    .AXI_USER_WIDTH     ( AxiUserWidth               ),
    .AXI_ID_WIDTH       ( AxiIdWidthMaster           ),
    .MASTER_SLICE_DEPTH ( 2                          ),
    .SLAVE_SLICE_DEPTH  ( 2                          )
`else
// For some unknown reason, verilator cannot compile with axi_multicut
axi_node_intf_wrap #(
    .NB_SLAVE       ( NBSlave                    ),
    .NB_MASTER      ( ariane_soc::NB_PERIPHERALS ),
    .NB_REGION      ( ariane_soc::NrRegion       ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth               ),
    .AXI_DATA_WIDTH ( AxiDataWidth               ),
    .AXI_USER_WIDTH ( AxiUserWidth               ),
    .AXI_ID_WIDTH   ( AxiIdWidthMaster           )
`endif
) i_axi_xbar (
    .clk          ( clk        ),
    .rst_n        ( ndmreset_n ),
    .test_en_i    ( test_en    ),
    .slave        ( slave      ),
    .master       ( master     ),
    .start_addr_i ({
        ariane_soc::DebugBase[AxiAddrWidth-1:0],
        ariane_soc::ROMBase  [AxiAddrWidth-1:0],
        ariane_soc::CLINTBase[AxiAddrWidth-1:0],
        ariane_soc::PLICBase [AxiAddrWidth-1:0],
        ariane_soc::DRAMBase [AxiAddrWidth-1:0],
        ariane_soc::UARTBase [AxiAddrWidth-1:0],
        ariane_soc::GPIOBase [AxiAddrWidth-1:0],
        ariane_soc::PS7Base  [AxiAddrWidth-1:0]
    }),
    .end_addr_i   ({
        ariane_soc::DebugBase[AxiAddrWidth-1:0]    + ariane_soc::DebugLength[AxiAddrWidth-1:0] - 1,
        ariane_soc::ROMBase  [AxiAddrWidth-1:0]    + ariane_soc::ROMLength  [AxiAddrWidth-1:0] - 1,
        ariane_soc::CLINTBase[AxiAddrWidth-1:0]    + ariane_soc::CLINTLength[AxiAddrWidth-1:0] - 1,
        ariane_soc::PLICBase [AxiAddrWidth-1:0]    + ariane_soc::PLICLength [AxiAddrWidth-1:0] - 1,
        ariane_soc::DRAMBase [AxiAddrWidth-1:0]    + ariane_soc::DRAMLength [AxiAddrWidth-1:0] - 1,
        ariane_soc::UARTBase [AxiAddrWidth-1:0]    + ariane_soc::UARTLength [AxiAddrWidth-1:0] - 1,
        ariane_soc::GPIOBase [AxiAddrWidth-1:0]    + ariane_soc::GPIOLength [AxiAddrWidth-1:0] - 1,
        ariane_soc::PS7Base  [AxiAddrWidth-1:0]    + ariane_soc::PS7Length  [AxiAddrWidth-1:0] - 1
    }),
    .valid_rule_i (ariane_soc::ValidRule)
);

// ---------------
// Debug Module
// ---------------
`ifndef VERILATOR
dmi_jtag #(
    .IdcodeValue ( 32'hbeefdeef  )
)i_dmi_jtag (
    .clk_i                ( clk                  ),
    .rst_ni               ( dmi_rst_n            ),
    .dmi_rst_no           (                      ), // keep open
    .testmode_i           ( test_en              ),
    .dmi_req_valid_o      ( debug_req_valid      ),
    .dmi_req_ready_i      ( debug_req_ready      ),
    .dmi_req_o            ( debug_req            ),
    .dmi_resp_valid_i     ( debug_resp_valid     ),
    .dmi_resp_ready_o     ( debug_resp_ready     ),
    .dmi_resp_i           ( debug_resp           ),
    .tck_i                ( tck    ),
    .tms_i                ( tms    ),
    .trst_ni              ( trst_n ),
    .td_i                 ( tdi    ),
    .td_o                 ( tdo    ),
    .tdo_oe_o             (        )
);
`endif

ariane_axi::req_t    dm_axi_m_req;
ariane_axi::resp_t   dm_axi_m_resp;

logic                dm_slave_req;
logic                dm_slave_we;
logic [64-1:0]       dm_slave_addr;
logic [64/8-1:0]     dm_slave_be;
logic [64-1:0]       dm_slave_wdata;
logic [64-1:0]       dm_slave_rdata;

logic                dm_master_req;
logic [64-1:0]       dm_master_add;
logic                dm_master_we;
logic [64-1:0]       dm_master_wdata;
logic [64/8-1:0]     dm_master_be;
logic                dm_master_gnt;
logic                dm_master_r_valid;
logic [64-1:0]       dm_master_r_rdata;

// debug module
dm_top #(
    .NrHarts          ( 1                 ),
    .BusWidth         ( AxiDataWidth      ),
    .SelectableHarts  ( 1'b1              )
) i_dm_top (
    .clk_i            ( clk               ),
    .rst_ni           ( dmi_rst_n         ), // PoR
    .testmode_i       ( test_en           ),
    .ndmreset_o       ( ndmreset          ),
    .dmactive_o       ( dmactive          ), // active debug session
    .debug_req_o      ( debug_req_irq     ),
    .unavailable_i    ( '0                ),
    .hartinfo_i       ( {ariane_pkg::DebugHartInfo} ),
    .slave_req_i      ( dm_slave_req      ),
    .slave_we_i       ( dm_slave_we       ),
    .slave_addr_i     ( dm_slave_addr     ),
    .slave_be_i       ( dm_slave_be       ),
    .slave_wdata_i    ( dm_slave_wdata    ),
    .slave_rdata_o    ( dm_slave_rdata    ),
    .master_req_o     ( dm_master_req     ),
    .master_add_o     ( dm_master_add     ),
    .master_we_o      ( dm_master_we      ),
    .master_wdata_o   ( dm_master_wdata   ),
    .master_be_o      ( dm_master_be      ),
    .master_gnt_i     ( dm_master_gnt     ),
    .master_r_valid_i ( dm_master_r_valid ),
    .master_r_rdata_i ( dm_master_r_rdata ),
    .dmi_rst_ni       ( dmi_rst_n         ),
    .dmi_req_valid_i  ( debug_req_valid   ),
    .dmi_req_ready_o  ( debug_req_ready   ),
    .dmi_req_i        ( debug_req         ),
    .dmi_resp_valid_o ( debug_resp_valid  ),
    .dmi_resp_ready_i ( debug_resp_ready  ),
    .dmi_resp_o       ( debug_resp        )
);

axi2mem #(
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves    ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth        ),
    .AXI_DATA_WIDTH ( AxiDataWidth        ),
    .AXI_USER_WIDTH ( AxiUserWidth        )
) i_dm_axi2mem (
    .clk_i      ( clk                       ),
    .rst_ni     ( dmi_rst_n                 ),
    .slave      ( master[ariane_soc::Debug] ),
    .req_o      ( dm_slave_req              ),
    .we_o       ( dm_slave_we               ),
    .addr_o     ( dm_slave_addr             ),
    .be_o       ( dm_slave_be               ),
    .data_o     ( dm_slave_wdata            ),
    .data_i     ( dm_slave_rdata            )
);

axi_master_connect i_dm_axi_master_connect (
    .axi_req_i(dm_axi_m_req),
    .axi_resp_o(dm_axi_m_resp),
    .master(slave[1])
);

axi_adapter #(
    .DATA_WIDTH            ( AxiDataWidth              )
) i_dm_axi_master (
    .clk_i                 ( clk                       ),
    .rst_ni                ( dmi_rst_n                 ),
    .req_i                 ( dm_master_req             ),
    .type_i                ( ariane_axi::SINGLE_REQ    ),
    .gnt_o                 ( dm_master_gnt             ),
    .gnt_id_o              (                           ),
    .addr_i                ( dm_master_add             ),
    .we_i                  ( dm_master_we              ),
    .wdata_i               ( dm_master_wdata           ),
    .be_i                  ( dm_master_be              ),
    .size_i                ( 2'b11                     ), // always do 64bit here and use byte enables to gate
    .id_i                  ( '0                        ),
    .valid_o               ( dm_master_r_valid         ),
    .rdata_o               ( dm_master_r_rdata         ),
    .id_o                  (                           ),
    .critical_word_o       (                           ),
    .critical_word_valid_o (                           ),
    .axi_req_o             ( dm_axi_m_req              ),
    .axi_resp_i            ( dm_axi_m_resp             )
);

// ---------------
// Core
// ---------------
ariane_axi::req_t    axi_ariane_req;
ariane_axi::resp_t   axi_ariane_resp;

ariane #(
    .ArianeCfg ( ariane_soc::ArianeSocCfg )
) i_ariane (
    .clk_i        ( clk                 ),
    .rst_ni       ( ndmreset_n          ),
    .boot_addr_i  ( ariane_soc::ROMBase ), // start fetching from ROM
    .hart_id_i    ( '0                  ),
    .irq_i        ( irq                 ),
    .ipi_i        ( ipi                 ),
    .time_irq_i   ( timer_irq           ),
    .debug_req_i  ( debug_req_irq       ),
    .axi_req_o    ( axi_ariane_req      ),
    .axi_resp_i   ( axi_ariane_resp     )
);

axi_master_connect i_axi_master_connect_ariane (
    .axi_req_i(axi_ariane_req),
    .axi_resp_o(axi_ariane_resp),
    .master(slave[0])
);

// ---------------
// CLINT
// ---------------
// divide clock by two
always_ff @(posedge clk or negedge ndmreset_n) begin
  if (~ndmreset_n) begin
    rtc <= 0;
  end else begin
    rtc <= rtc ^ 1'b1;
  end
end

ariane_axi::req_t    axi_clint_req;
ariane_axi::resp_t   axi_clint_resp;

clint #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .NR_CORES       ( 1                )
) i_clint (
    .clk_i       ( clk            ),
    .rst_ni      ( ndmreset_n     ),
    .testmode_i  ( test_en        ),
    .axi_req_i   ( axi_clint_req  ),
    .axi_resp_o  ( axi_clint_resp ),
    .rtc_i       ( rtc            ),
    .timer_irq_o ( timer_irq      ),
    .ipi_o       ( ipi            )
);

axi_slave_connect i_axi_slave_connect_clint (
    .axi_req_o(axi_clint_req), 
    .axi_resp_i(axi_clint_resp), 
    .slave(master[ariane_soc::CLINT])
);

// ---------------
// ROM
// ---------------
axi2mem #(
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) i_axi2rom (
    .clk_i  ( clk                     ),
    .rst_ni ( ndmreset_n              ),
    .slave  ( master[ariane_soc::ROM] ),
    .req_o  ( rom_req                 ),
    .we_o   (                         ),
    .addr_o ( rom_addr                ),
    .be_o   (                         ),
    .data_o (                         ),
    .data_i ( rom_rdata               )
);

bootrom i_bootrom (
    .clk_i   ( clk       ),
    .req_i   ( rom_req   ),
    .addr_i  ( rom_addr  ),
    .rdata_o ( rom_rdata )
);

// ---------------
// Peripherals
// ---------------
ariane_peripherals #(
    .AxiAddrWidth ( AxiAddrWidth     ),
    .AxiDataWidth ( AxiDataWidth     ),
    .AxiIdWidth   ( AxiIdWidthSlaves ),
    .AxiUserWidth ( AxiUserWidth     ),
`ifndef VERILATOR
    .InclUART     ( 1'b1             ),
    .InclGPIO     ( 1'b1             )
`else
    .InclUART     ( 1'b0             ),
    .InclGPIO     ( 1'b0             )
`endif
) i_ariane_peripherals (
    .clk_i        ( clk                          ),
    .rst_ni       ( ndmreset_n                   ),
    .plic         ( master[ariane_soc::PLIC]     ),
    .uart         ( master[ariane_soc::UART]     ),
    .gpio         ( master[ariane_soc::GPIO]     ),
    .irq_p2f_i    ( irq_p2f                      ),
    .irq_o        ( irq                          ),
    .rx_i         ( rx                           ),
    .tx_o         ( tx                           ),
    .leds_o       ( led                          ),
    .btns_i       ( sw                           )
);


// ---------------------
// SoC peripherals
// ---------------------
// ---------------
// DRAM <==> HP0
// ---------------
AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) dram();

axi_riscv_atomics_wrap #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_USER_WIDTH ( AxiUserWidth     ),
    .AXI_MAX_WRITE_TXNS ( 1  ),
    .RISCV_WORD_WIDTH   ( 64 )
) i_axi_riscv_atomics (
    .clk_i  ( clk                      ),
    .rst_ni ( ndmreset_n               ),
    .slv    ( master[ariane_soc::DRAM] ),
    .mst    ( dram                     )
);

`ifdef PROTOCOL_CHECKER
logic pc_status;

xlnx_protocol_checker i_xlnx_protocol_checker_dram (
  .pc_status(),
  .pc_asserted(pc_status),
  .aclk(clk),
  .aresetn(ndmreset_n),
  .pc_axi_awid     (dram.aw_id),
  .pc_axi_awaddr   (dram.aw_addr),
  .pc_axi_awlen    (dram.aw_len),
  .pc_axi_awsize   (dram.aw_size),
  .pc_axi_awburst  (dram.aw_burst),
  .pc_axi_awlock   (dram.aw_lock),
  .pc_axi_awcache  (dram.aw_cache),
  .pc_axi_awprot   (dram.aw_prot),
  .pc_axi_awqos    (dram.aw_qos),
  .pc_axi_awregion (dram.aw_region),
  .pc_axi_awuser   (dram.aw_user),
  .pc_axi_awvalid  (dram.aw_valid),
  .pc_axi_awready  (dram.aw_ready),
  .pc_axi_wlast    (dram.w_last),
  .pc_axi_wdata    (dram.w_data),
  .pc_axi_wstrb    (dram.w_strb),
  .pc_axi_wuser    (dram.w_user),
  .pc_axi_wvalid   (dram.w_valid),
  .pc_axi_wready   (dram.w_ready),
  .pc_axi_bid      (dram.b_id),
  .pc_axi_bresp    (dram.b_resp),
  .pc_axi_buser    (dram.b_user),
  .pc_axi_bvalid   (dram.b_valid),
  .pc_axi_bready   (dram.b_ready),
  .pc_axi_arid     (dram.ar_id),
  .pc_axi_araddr   (dram.ar_addr),
  .pc_axi_arlen    (dram.ar_len),
  .pc_axi_arsize   (dram.ar_size),
  .pc_axi_arburst  (dram.ar_burst),
  .pc_axi_arlock   (dram.ar_lock),
  .pc_axi_arcache  (dram.ar_cache),
  .pc_axi_arprot   (dram.ar_prot),
  .pc_axi_arqos    (dram.ar_qos),
  .pc_axi_arregion (dram.ar_region),
  .pc_axi_aruser   (dram.ar_user),
  .pc_axi_arvalid  (dram.ar_valid),
  .pc_axi_arready  (dram.ar_ready),
  .pc_axi_rid      (dram.r_id),
  .pc_axi_rlast    (dram.r_last),
  .pc_axi_rdata    (dram.r_data),
  .pc_axi_rresp    (dram.r_resp),
  .pc_axi_ruser    (dram.r_user),
  .pc_axi_rvalid   (dram.r_valid),
  .pc_axi_rready   (dram.r_ready)
);
`endif

assign dram.r_user = '0;
assign dram.b_user = '0;

// ---------------
// PS7 <==> GP0
// ---------------
`ifndef VERILATOR
logic [31:0] s_axi_gp0_awaddr;
logic [7:0]  s_axi_gp0_awlen;
logic [2:0]  s_axi_gp0_awsize;
logic [1:0]  s_axi_gp0_awburst;
logic [3:0]  s_axi_gp0_awcache;
logic [2:0]  s_axi_gp0_awprot;
logic [3:0]  s_axi_gp0_awqos;
logic        s_axi_gp0_awvalid;
logic        s_axi_gp0_awready;
logic [31:0] s_axi_gp0_wdata;
logic [3:0]  s_axi_gp0_wstrb;
logic        s_axi_gp0_wlast;
logic        s_axi_gp0_wvalid;
logic        s_axi_gp0_wready;
logic [1:0]  s_axi_gp0_bresp;
logic        s_axi_gp0_bvalid;
logic [5:0]  s_axi_gp0_bid;
logic        s_axi_gp0_bready;
logic [31:0] s_axi_gp0_araddr;
logic [7:0]  s_axi_gp0_arlen;
logic [2:0]  s_axi_gp0_arsize;
logic [1:0]  s_axi_gp0_arburst;
logic [3:0]  s_axi_gp0_arcache;
logic [2:0]  s_axi_gp0_arprot;
logic [3:0]  s_axi_gp0_arqos;
logic        s_axi_gp0_arvalid;
logic        s_axi_gp0_arready;
logic [31:0] s_axi_gp0_rdata;
logic [1:0]  s_axi_gp0_rresp;
logic        s_axi_gp0_rlast;
logic        s_axi_gp0_rvalid;
logic [5:0]  s_axi_gp0_rid;
logic        s_axi_gp0_rready;

// system-bus is 64-bit, convert down to 32 bit
xlnx_axi_dwidth_converter i_xlnx_axi_dwidth_converter_gp0(
    .s_axi_aclk     ( clk           ),
    .s_axi_aresetn  ( ndmreset_n    ),
    .s_axi_awid     ( master[ariane_soc::PS7].aw_id         ),
    .s_axi_awaddr   ( master[ariane_soc::PS7].aw_addr[31:0] ),
    .s_axi_awlen    ( master[ariane_soc::PS7].aw_len        ),
    .s_axi_awsize   ( master[ariane_soc::PS7].aw_size       ),
    .s_axi_awburst  ( master[ariane_soc::PS7].aw_burst      ),
    .s_axi_awlock   ( master[ariane_soc::PS7].aw_lock       ),
    .s_axi_awcache  ( master[ariane_soc::PS7].aw_cache      ),
    .s_axi_awprot   ( master[ariane_soc::PS7].aw_prot       ),
    .s_axi_awregion ( master[ariane_soc::PS7].aw_region     ),
    .s_axi_awqos    ( master[ariane_soc::PS7].aw_qos        ),
    .s_axi_awvalid  ( master[ariane_soc::PS7].aw_valid      ),
    .s_axi_awready  ( master[ariane_soc::PS7].aw_ready      ),
    .s_axi_wdata    ( master[ariane_soc::PS7].w_data        ),
    .s_axi_wstrb    ( master[ariane_soc::PS7].w_strb        ),
    .s_axi_wlast    ( master[ariane_soc::PS7].w_last        ),
    .s_axi_wvalid   ( master[ariane_soc::PS7].w_valid       ),
    .s_axi_wready   ( master[ariane_soc::PS7].w_ready       ),
    .s_axi_bid      ( master[ariane_soc::PS7].b_id          ),
    .s_axi_bresp    ( master[ariane_soc::PS7].b_resp        ),
    .s_axi_bvalid   ( master[ariane_soc::PS7].b_valid       ),
    .s_axi_bready   ( master[ariane_soc::PS7].b_ready       ),
    .s_axi_arid     ( master[ariane_soc::PS7].ar_id         ),
    .s_axi_araddr   ( master[ariane_soc::PS7].ar_addr[31:0] ),
    .s_axi_arlen    ( master[ariane_soc::PS7].ar_len        ),
    .s_axi_arsize   ( master[ariane_soc::PS7].ar_size       ),
    .s_axi_arburst  ( master[ariane_soc::PS7].ar_burst      ),
    .s_axi_arlock   ( master[ariane_soc::PS7].ar_lock       ),
    .s_axi_arcache  ( master[ariane_soc::PS7].ar_cache      ),
    .s_axi_arprot   ( master[ariane_soc::PS7].ar_prot       ),
    .s_axi_arregion ( master[ariane_soc::PS7].ar_region     ),
    .s_axi_arqos    ( master[ariane_soc::PS7].ar_qos        ),
    .s_axi_arvalid  ( master[ariane_soc::PS7].ar_valid      ),
    .s_axi_arready  ( master[ariane_soc::PS7].ar_ready      ),
    .s_axi_rid      ( master[ariane_soc::PS7].r_id          ),
    .s_axi_rdata    ( master[ariane_soc::PS7].r_data        ),
    .s_axi_rresp    ( master[ariane_soc::PS7].r_resp        ),
    .s_axi_rlast    ( master[ariane_soc::PS7].r_last        ),
    .s_axi_rvalid   ( master[ariane_soc::PS7].r_valid       ),
    .s_axi_rready   ( master[ariane_soc::PS7].r_ready       ),

    .m_axi_awaddr   ( s_axi_gp0_awaddr  ),
    .m_axi_awlen    ( s_axi_gp0_awlen   ),
    .m_axi_awsize   ( s_axi_gp0_awsize  ),
    .m_axi_awburst  ( s_axi_gp0_awburst ),
    .m_axi_awlock   ( s_axi_gp0_awlock  ),
    .m_axi_awcache  ( s_axi_gp0_awcache ),
    .m_axi_awprot   ( s_axi_gp0_awprot  ),
    .m_axi_awregion (                   ),
    .m_axi_awqos    ( s_axi_gp0_awqos   ),
    .m_axi_awvalid  ( s_axi_gp0_awvalid ),
    .m_axi_awready  ( s_axi_gp0_awready ),
    .m_axi_wdata    ( s_axi_gp0_wdata   ),
    .m_axi_wstrb    ( s_axi_gp0_wstrb   ),
    .m_axi_wlast    ( s_axi_gp0_wlast   ),
    .m_axi_wvalid   ( s_axi_gp0_wvalid  ),
    .m_axi_wready   ( s_axi_gp0_wready  ),
    .m_axi_bresp    ( s_axi_gp0_bresp   ),
    .m_axi_bvalid   ( s_axi_gp0_bvalid  ),
    .m_axi_bready   ( s_axi_gp0_bready  ),
    .m_axi_araddr   ( s_axi_gp0_araddr  ),
    .m_axi_arlen    ( s_axi_gp0_arlen   ),
    .m_axi_arsize   ( s_axi_gp0_arsize  ),
    .m_axi_arburst  ( s_axi_gp0_arburst ),
    .m_axi_arlock   ( s_axi_gp0_arlock  ),
    .m_axi_arcache  ( s_axi_gp0_arcache ),
    .m_axi_arprot   ( s_axi_gp0_arprot  ),
    .m_axi_arregion (                   ),
    .m_axi_arqos    ( s_axi_gp0_arqos   ),
    .m_axi_arvalid  ( s_axi_gp0_arvalid ),
    .m_axi_arready  ( s_axi_gp0_arready ),
    .m_axi_rdata    ( s_axi_gp0_rdata   ),
    .m_axi_rresp    ( s_axi_gp0_rresp   ),
    .m_axi_rlast    ( s_axi_gp0_rlast   ),
    .m_axi_rvalid   ( s_axi_gp0_rvalid  ),
    .m_axi_rready   ( s_axi_gp0_rready  )
);
`else
  logic                       gp0_req;
  logic                       gp0_we;
  logic [AxiAddrWidth-1:0]    gp0_addr;
  logic [AxiDataWidth/8-1:0]  gp0_be;
  logic [AxiDataWidth-1:0]    gp0_wdata;
  logic [AxiDataWidth-1:0]    gp0_rdata;
  
  axi2mem #(
    .AXI_ID_WIDTH   ( ariane_soc::IdWidthSlave ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth             ),
    .AXI_DATA_WIDTH ( AxiDataWidth             ),
    .AXI_USER_WIDTH ( AxiUserWidth             )
  ) i_axi2mem_gp0 (
    .clk_i  ( clk              ),
    .rst_ni ( ndmreset_n       ),
    .slave  ( master[ariane_soc::PS7] ),
    .req_o  ( gp0_req          ),
    .we_o   ( gp0_we           ),
    .addr_o ( gp0_addr         ),
    .be_o   ( gp0_be           ),
    .data_o ( gp0_wdata        ),
    .data_i ( gp0_rdata        )
  );

  sram #(
    .DATA_WIDTH ( AxiDataWidth ),
    .NUM_WORDS  ( (ariane_soc::PS7Length*8)/AxiDataWidth )
  ) i_sram_gp0 (
    .clk_i      ( clk                ),
    .rst_ni     ( ndmreset_n         ),
    .req_i      ( gp0_req            ),
    .we_i       ( gp0_we             ),
    .addr_i     ( gp0_addr[$clog2((ariane_soc::PS7Length*8)/AxiDataWidth)-1+$clog2(AxiDataWidth/8):$clog2(AxiDataWidth/8)] ),
    .wdata_i    ( gp0_wdata          ),
    .be_i       ( gp0_be             ),
    .rdata_o    ( gp0_rdata          )
  );
`endif

`ifndef VERILATOR
// ---------------
// Xilinx PS7
// ---------------
xlnx_ps_7 i_xlnx_ps_7 (
    .USB0_PORT_INDCTL    (      ),
    .USB0_VBUS_PWRSELECT (      ),
    .USB0_VBUS_PWRFAULT  (1'b0  ),
    // S_AXI_GP0
    .S_AXI_GP0_ARREADY  (s_axi_gp0_arready),
    .S_AXI_GP0_AWREADY  (s_axi_gp0_awready),
    .S_AXI_GP0_BVALID   (s_axi_gp0_bvalid),
    .S_AXI_GP0_RLAST    (s_axi_gp0_rlast),
    .S_AXI_GP0_RVALID   (s_axi_gp0_rvalid),
    .S_AXI_GP0_WREADY   (s_axi_gp0_wready),
    .S_AXI_GP0_BRESP    (s_axi_gp0_bresp),
    .S_AXI_GP0_RRESP    (s_axi_gp0_rresp),
    .S_AXI_GP0_RDATA    (s_axi_gp0_rdata),
    .S_AXI_GP0_BID      (s_axi_gp0_bid),
    .S_AXI_GP0_RID      (s_axi_gp0_rid),
    .S_AXI_GP0_ACLK     (clk          ),
    .S_AXI_GP0_ARVALID  (s_axi_gp0_arvalid),
    .S_AXI_GP0_AWVALID  (s_axi_gp0_awvalid),
    .S_AXI_GP0_BREADY   (s_axi_gp0_bready),
    .S_AXI_GP0_RREADY   (s_axi_gp0_rready),
    .S_AXI_GP0_WLAST    (s_axi_gp0_wlast),
    .S_AXI_GP0_WVALID   (s_axi_gp0_wvalid),
    .S_AXI_GP0_ARBURST  (s_axi_gp0_arburst),
    .S_AXI_GP0_ARLOCK   (s_axi_gp0_arlock),
    .S_AXI_GP0_ARSIZE   (s_axi_gp0_arsize),
    .S_AXI_GP0_AWBURST  (s_axi_gp0_awburst),
    .S_AXI_GP0_AWLOCK   (s_axi_gp0_awlock),
    .S_AXI_GP0_AWSIZE   (s_axi_gp0_awsize),
    .S_AXI_GP0_ARPROT   (s_axi_gp0_arprot),
    .S_AXI_GP0_AWPROT   (s_axi_gp0_awprot),
    .S_AXI_GP0_ARADDR   (s_axi_gp0_araddr),
    .S_AXI_GP0_AWADDR   (s_axi_gp0_awaddr),
    .S_AXI_GP0_WDATA    (s_axi_gp0_wdata),
    .S_AXI_GP0_ARCACHE  (s_axi_gp0_arcache),
    .S_AXI_GP0_ARLEN    (s_axi_gp0_arlen),
    .S_AXI_GP0_ARQOS    (s_axi_gp0_arqos),
    .S_AXI_GP0_AWCACHE  (s_axi_gp0_awcache),
    .S_AXI_GP0_AWLEN    (s_axi_gp0_awlen),
    .S_AXI_GP0_AWQOS    (s_axi_gp0_awqos),
    .S_AXI_GP0_WSTRB    (s_axi_gp0_wstrb),
    .S_AXI_GP0_ARID     ('b0            ), // reordering depth of 1 for downsizer
    .S_AXI_GP0_AWID     (s_axi_gp0_awid),
    .S_AXI_GP0_WID      (s_axi_gp0_awid), //  Any AXI3 component that requires a WID signal can generate this from the AWID value
    // S_AXI_HP0
    .S_AXI_HP0_ARREADY          (dram.ar_ready  ),
    .S_AXI_HP0_AWREADY          (dram.aw_ready  ),
    .S_AXI_HP0_BVALID           (dram.b_valid   ),
    .S_AXI_HP0_RLAST            (dram.r_last    ),
    .S_AXI_HP0_RVALID           (dram.r_valid   ),
    .S_AXI_HP0_WREADY           (dram.w_ready   ),
    .S_AXI_HP0_BRESP            (dram.b_resp    ),
    .S_AXI_HP0_RRESP            (dram.r_resp    ),
    .S_AXI_HP0_BID              (dram.b_id      ),
    .S_AXI_HP0_RID              (dram.r_id      ),
    .S_AXI_HP0_RDATA            (dram.r_data    ),
    .S_AXI_HP0_RCOUNT           (               ),
    .S_AXI_HP0_WCOUNT           (               ),
    .S_AXI_HP0_RACOUNT          (               ),
    .S_AXI_HP0_WACOUNT          (               ),
    .S_AXI_HP0_ACLK             (clk            ),
    .S_AXI_HP0_ARVALID          (dram.ar_valid  ),
    .S_AXI_HP0_AWVALID          (dram.aw_valid  ),
    .S_AXI_HP0_BREADY           (dram.b_ready   ),
    .S_AXI_HP0_RDISSUECAP1_EN   (1'b1           ),
    .S_AXI_HP0_RREADY           (dram.r_ready   ),
    .S_AXI_HP0_WLAST            (dram.w_last    ),
    .S_AXI_HP0_WRISSUECAP1_EN   (1'b1           ),
    .S_AXI_HP0_WVALID           (dram.w_valid   ),
    .S_AXI_HP0_ARBURST          (dram.ar_burst  ),
    .S_AXI_HP0_ARLOCK           (dram.ar_lock   ),
    .S_AXI_HP0_ARSIZE           (dram.ar_size   ),
    .S_AXI_HP0_AWBURST          (dram.aw_burst  ),
    .S_AXI_HP0_AWLOCK           (dram.aw_lock   ),
    .S_AXI_HP0_AWSIZE           (dram.aw_size   ),
    .S_AXI_HP0_ARPROT           (dram.ar_prot   ),
    .S_AXI_HP0_AWPROT           (dram.aw_prot   ),
    .S_AXI_HP0_ARADDR           (dram.ar_addr   ),
    .S_AXI_HP0_AWADDR           (dram.aw_addr   ),
    .S_AXI_HP0_ARCACHE          (dram.ar_cache  ),
    .S_AXI_HP0_ARLEN            (dram.ar_len    ),
    .S_AXI_HP0_ARQOS            (dram.ar_qos    ),
    .S_AXI_HP0_AWCACHE          (dram.aw_cache  ),
    .S_AXI_HP0_AWLEN            (dram.aw_len    ),
    .S_AXI_HP0_AWQOS            (dram.aw_qos    ),
    .S_AXI_HP0_ARID             (dram.ar_id     ),
    .S_AXI_HP0_AWID             (dram.aw_id     ),
    .S_AXI_HP0_WID              (dram.aw_id     ),  // Any AXI3 component that requires a WID signal can generate this from the AWID value
    .S_AXI_HP0_WDATA            (dram.w_data    ),
    .S_AXI_HP0_WSTRB            (dram.w_strb    ),
    // IRQ
    .IRQ_P2F_QSPI       (irq_p2f[0]  ),
    .IRQ_P2F_GPIO       (irq_p2f[1]  ),
    .IRQ_P2F_USB0       (irq_p2f[2]  ),
    .IRQ_P2F_ENET0      (irq_p2f[3]  ),
    .IRQ_P2F_ENET_WAKE0 (irq_p2f[4]  ),
    .IRQ_P2F_SDIO0      (irq_p2f[5]  ),
    .IRQ_P2F_SDIO1      (irq_p2f[6]  ),
    .IRQ_P2F_UART1      (irq_p2f[7]  ),
    // clock & reset output
    .FCLK_CLK0          (clk         ),
    .FCLK_RESET0_N      (rst_n       ),
    /*AUTOINST*/
                       // Inouts
                       .MIO             (MIO[53:0]),
                       .DDR_CAS_n       (DDR_CAS_n),
                       .DDR_CKE         (DDR_CKE),
                       .DDR_Clk_n       (DDR_Clk_n),
                       .DDR_Clk         (DDR_Clk),
                       .DDR_CS_n        (DDR_CS_n),
                       .DDR_DRSTB       (DDR_DRSTB),
                       .DDR_ODT         (DDR_ODT),
                       .DDR_RAS_n       (DDR_RAS_n),
                       .DDR_WEB         (DDR_WEB),
                       .DDR_BankAddr    (DDR_BankAddr[2:0]),
                       .DDR_Addr        (DDR_Addr[14:0]),
                       .DDR_VRN         (DDR_VRN),
                       .DDR_VRP         (DDR_VRP),
                       .DDR_DM          (DDR_DM[3:0]),
                       .DDR_DQ          (DDR_DQ[31:0]),
                       .DDR_DQS_n       (DDR_DQS_n[3:0]),
                       .DDR_DQS         (DDR_DQS[3:0]),
                       .PS_SRSTB        (PS_SRSTB),
                       .PS_CLK          (PS_CLK),
                       .PS_PORB         (PS_PORB));
`else
  logic                       hp0_req;
  logic                       hp0_we;
  logic [AxiAddrWidth-1:0]    hp0_addr;
  logic [AxiDataWidth/8-1:0]  hp0_be;
  logic [AxiDataWidth-1:0]    hp0_wdata;
  logic [AxiDataWidth-1:0]    hp0_rdata;

  axi2mem #(
    .AXI_ID_WIDTH   ( ariane_soc::IdWidthSlave ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth             ),
    .AXI_DATA_WIDTH ( AxiDataWidth             ),
    .AXI_USER_WIDTH ( AxiUserWidth             )
  ) i_axi2mem_hp0 (
    .clk_i  ( clk          ),
    .rst_ni ( ndmreset_n   ),
    .slave  ( dram         ),
    .req_o  ( hp0_req      ),
    .we_o   ( hp0_we       ),
    .addr_o ( hp0_addr     ),
    .be_o   ( hp0_be       ),
    .data_o ( hp0_wdata    ),
    .data_i ( hp0_rdata    )
  );

  sram #(
    .DATA_WIDTH ( AxiDataWidth ),
    .NUM_WORDS  ( (ariane_soc::DRAMLength*8)/AxiDataWidth )
  ) i_sram_hp0 (
    .clk_i      ( clk                ),
    .rst_ni     ( ndmreset_n         ),
    .req_i      ( hp0_req            ),
    .we_i       ( hp0_we             ),
    .addr_i     ( hp0_addr[$clog2((ariane_soc::DRAMLength*8)/AxiDataWidth)-1+$clog2(AxiDataWidth/8):$clog2(AxiDataWidth/8)] ),
    .wdata_i    ( hp0_wdata          ),
    .be_i       ( hp0_be             ),
    .rdata_o    ( hp0_rdata          )
  );

  assign irq_p2f = 'b0;
  assign clk = sys_clock;
  assign rst_n = sys_resetn;
`endif
endmodule
`endif

// Local Variables:
// verilog-library-directories:("." "../xilinx/xlnx_ps_7/ip/synth")
// End:
