

create_clock -name LCLK  -period 40MHz [get_ports {LCLK}]
create_clock -name GIN0  -period 40MHz [get_ports {GIN[0]}]
derive_pll_clocks

set_multicycle_path -from [get_clocks {LCLK}] -to [get_clocks {inst_pll|\gen_pll:altpll_inst|pll|clk[0]}] -setup -start 2
set_multicycle_path -from [get_clocks {inst_pll|\gen_pll:altpll_inst|pll|clk[0]}] -to [get_clocks {LCLK}] -setup -end 2

set_multicycle_path -from [get_clocks {LCLK}] -to [get_clocks {inst_pll|\gen_pll:altpll_inst|pll|clk[0]}] -hold -start 2
set_multicycle_path -from [get_clocks {inst_pll|\gen_pll:altpll_inst|pll|clk[0]}] -to [get_clocks {LCLK}] -hold -end 2




#set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {\blk_pre_logic:delay_regs*} -hold -end 2
#set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {\blk_pre_logic:gate_regs*} -hold -end 2


#set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {\blk_pre_logic_level1:delay_regs*} -hold -end 2
#set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {\blk_pre_logic_level1:gate_regs*} -hold -end 2

#set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {*\gen_logic_level_*:*:mask*} -hold -end 2
#set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {*\gen_logic_level_*:*type*} -hold -end 2




#set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -setup -start 2
#set_multicycle_path -from {V1495_regs_communication:inst_regs|REG_RW*} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -hold -end 4

#set_multicycle_path -from {counter:\gen_logic_level_*:*:inst_counter|counter_unsigned*} -to {REG_R*} -setup -end 2
#set_multicycle_path -from {counter:\gen_logic_level_*:*:inst_counter|counter_unsigned*]} -to {REG_R*} -hold -end 2

#set_multicycle_path -from {counter:\blk_raw_counters*counter_unsigned*} -to {REG_R*} -setup -end 2
#set_multicycle_path -from {counter:\blk_raw_counters*counter_unsigned*} -to {REG_R*} -hold -end 2


set_false_path -from {counter:\gen_logic_level_*:*:inst_counter|\proc_count:prev} -to {lemo_output:\blk_lemo_output:inst_lemo|output*}

set_multicycle_path -from {\blk_pre_logic*} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -setup -end 2
set_multicycle_path -from {\blk_pre_logic*} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -hold -end 2


set_multicycle_path -from {counter:\blk_raw_counters:gen_*_counters*inst_counter|counter_unsigned*} -to  {V1495_regs_communication:inst_regs|LADout*}  -setup -start 2
set_multicycle_path -from {counter:\blk_raw_counters:gen_*_counters*inst_counter|counter_unsigned*} -to  {V1495_regs_communication:inst_regs|rreg*}  -setup -start 2

set_multicycle_path -from {counter:\blk_raw_counters:gen_*_counters*inst_counter|counter_unsigned*} -to  {V1495_regs_communication:inst_regs|LADout*}  -hold -end 2
set_multicycle_path -from {counter:\blk_raw_counters:gen_*_counters*inst_counter|counter_unsigned*} -to  {V1495_regs_communication:inst_regs|rreg*}  -hold -end 2

set_multicycle_path -from {allData*} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -setup -end 2
set_multicycle_path -from {allData*} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -hold -end 2


set_multicycle_path -from {logic_unit:\gen_logic_level_1*inst_logic|result} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -setup -end 2
set_multicycle_path -from {logic_unit:\gen_logic_level_1*inst_logic|result} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -hold -end 2