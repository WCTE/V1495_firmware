

create_clock -name LCLK  -period 40MHz [get_ports {LCLK}]
create_clock -name GIN0  -period 62.5MHz [get_ports {GIN[0]}]
derive_pll_clocks

#set_multicycle_path -from [get_clocks {LCLK}] -to [get_clocks {inst_pll|\gen_pll:altpll_inst|pll|clk[0]}] -setup -start 2
#set_multicycle_path -from [get_clocks {inst_pll|\gen_pll:altpll_inst|pll|clk[0]}] -to [get_clocks {LCLK}] -setup -end 2

#set_multicycle_path -from [get_clocks {LCLK}] -to [get_clocks {inst_pll|\gen_pll:altpll_inst|pll|clk[0]}] -hold -start 2
#set_multicycle_path -from [get_clocks {inst_pll|\gen_pll:altpll_inst|pll|clk[0]}] -to [get_clocks {LCLK}] -hold -end 2


#set_multicycle_path -from {\blk_pre_logic*} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -setup -end 2
#set_multicycle_path -from {\blk_pre_logic*} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -hold -end 2

#set_multicycle_path -from {allData*} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -setup -end 2
#set_multicycle_path -from {allData*} -to {lemo_output:\blk_lemo_output:inst_lemo|output*} -hold -end 2


#set_false_path -from {*:inst_counter|\proc_count:prev} -to {lemo_output:\blk_lemo_output:inst_lemo|output*}
