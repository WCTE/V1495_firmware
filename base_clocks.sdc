

create_clock -name LCLK  -period 40MHz [get_ports {LCLK}]
create_clock -name GIN0  -period 62.5MHz [get_ports {GIN[0]}]
derive_pll_clocks

set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW_rtl_0_bypass*} -to {V1495_regs_communication:inst_regs|dcfifo:\blk_read_Fifo:dcfifo_component|dcfifo_gao1:auto_generated|altsyncram_0941:fifo_ram|ram_block15a0~porta_datain_reg*} -setup -end 2
set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW_rtl_0_bypass*} -to {V1495_regs_communication:inst_regs|dcfifo:\blk_read_Fifo:dcfifo_component|dcfifo_gao1:auto_generated|altsyncram_0941:fifo_ram|ram_block15a0~porta_datain_reg*} -hold -end 2
