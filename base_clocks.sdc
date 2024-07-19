

create_clock -name LCLK  -period 40MHz [get_ports {LCLK}]
derive_pll_clocks

set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {\blk_pre_logic:delay_regs*} -hold -end 2
set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {\blk_pre_logic:gate_regs*} -hold -end 2
set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {\gen_logic_level_1:*:mask*} -hold -end 2
set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {\gen_logic_level_1:*type*} -hold -end 2
