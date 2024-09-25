

vcom -reportprogress 300 -work altera /home/sam/altera/13.0sp1/quartus/eda/sim_lib/altera_syn_attributes.vhd

vcom -reportprogress 300 -work work ../src/functions.vhd
vcom -reportprogress 300 -work work ../src/V1495_regs_pkg.vhd
vcom -reportprogress 300 -work work ../src/counter.vhd
vcom -reportprogress 300 -work work ../src/logic_unit.vhd
vcom -reportprogress 300 -work work ../src/prescale.vhd
vcom -reportprogress 300 -work work ../src/level1_logic.vhd
vcom -reportprogress 300 -work work ../src/level2_logic.vhd

vcom -reportprogress 300 -work work altera_cmn_pll_sim.vhd

vcom -reportprogress 300 -work work ../src/areset_sync.vhd
vcom -2008 -reportprogress 300 -work work ../src/delay_chain.vhd
vcom -reportprogress 300 -work work ../src/veto.vhd
vcom -reportprogress 300 -work work ../src/lemo_output.vhd
vcom -reportprogress 300 -work work ../src/pre_logic.vhd
vcom -reportprogress 300 -work work ../src/pre_logic_treatment.vhd
vcom -reportprogress 300 -work work ../src/trigger_deadtime.vhd
vcom -reportprogress 300 -work work ./V1495_regs_communication_sim.vhd

vcom -2008 -reportprogress 300 -work work ../src/HyperK-WCTE-V1495_top.vhd

vcom -reportprogress 300 -work work ./testbench.vhd

vsim -voptargs=+acc -i -l msim_transcript work.testbench

add wave -noupdate -divider -height 20 "Clocks"
add wave -label "onboard 40MHz" sim:/testbench/uut/LCLK
add wave -label "external 62.5MHz" sim:/testbench/uut/GIN(0)
add wave -label "PLL generated 125Mz" sim:/testbench/uut/clk_125

add wave -noupdate -divider -height 20 "Resets"
add wave sim:/testbench/uut/nLBRES
add wave sim:/testbench/uut/reset_reg
add wave sim:/testbench/uut/reset_startup
add wave sim:/testbench/uut/reset_125

add wave -noupdate -divider -height 20 "Raw data in"
add wave sim:/testbench/uut/A
add wave sim:/testbench/uut/B
add wave sim:/testbench/uut/D

add wave -noupdate -divider -height 20 "Raw data counters"
for {set i 0} {$i < 32} {incr i} {
    add wave -group "A counters" -label "A[$i]" sim:/testbench/uut/blk_raw_counters/gen_a_counters($i)/count
}
for {set i 0} {$i < 32} {incr i} {
    add wave -group "B counters" -label "D[$i]" sim:/testbench/uut/blk_raw_counters/gen_b_counters($i)/count
}
for {set i 0} {$i < 32} {incr i} {
    add wave -group "D counters" -label "D[$i]" sim:/testbench/uut/blk_raw_counters/gen_d_counters($i)/count
}

add wave -noupdate -divider -height 20 "pre-logic treatment"
add wave -label "A with pre-logic" sim:/testbench/uut/prepared_signals(31:0)
add wave -label "B with pre-logic" sim:/testbench/uut/prepared_signals(63:32)

for {set i 0} {$i < 32} {incr i} {
    add wave -group "A delay values" -label "$i" sim:/testbench/uut/blk_pre_logic/inst_pre_logic/gen_pre_logic($i)/inst_pre_logic/delay
}
for {set i 0} {$i < 32} {incr i} {
    add wave -group "B delay values" -label "$i" sim:/testbench/uut/blk_pre_logic/inst_pre_logic/gen_pre_logic([expr $i + 32])/inst_pre_logic/delay
}
for {set i 0} {$i < 32} {incr i} {
    add wave -group "A gate values" -label "$i" sim:/testbench/uut/blk_pre_logic/inst_pre_logic/gen_pre_logic($i)/inst_pre_logic/gate
}
for {set i 0} {$i < 32} {incr i} {
    add wave -group "B gate values" -label "$i" sim:/testbench/uut/blk_pre_logic/inst_pre_logic/gen_pre_logic([expr $i + 32])/inst_pre_logic/gate
}

add wave -noupdate -divider -height 20 "Level 1 logic"
for {set i 0} {$i < 10} {incr i} {
    add wave -group "L1[$i]" -label "Data mask" sim:/testbench/uut/gen_logic_level_1($i)/inst_l1_logic/mask
    add wave -group "L1[$i]" -label "Input data" sim:/testbench/uut/gen_logic_level_1($i)/inst_l1_logic/data_in
    add wave -group "L1[$i]" -label "logic type" sim:/testbench/uut/gen_logic_level_1($i)/inst_l1_logic/logic_type
    add wave -group "L1[$i]" -label "invert" sim:/testbench/uut/gen_logic_level_1($i)/inst_l1_logic/invert
    add wave -group "L1[$i]" -label "prescale" sim:/testbench/uut/gen_logic_level_1($i)/inst_l1_logic/prescale
}

for {set i 0} {$i < 10} {incr i} {
    add wave -group "L1 counters" -label "L1[$i]" sim:/testbench/uut/gen_logic_level_1(0)/inst_l1_logic/count
}
add wave -label "L1 results" sim:/testbench/uut/level1_result

add wave -noupdate -divider -height 20 "Level 1 pre-logic"
add wave -label "L1 with pre-logic" sim:/testbench/uut/prepared_signals_l1
for {set i 0} {$i < 10} {incr i} {
    add wave -group "L1 delay values" -label "$i" sim:/testbench/uut/blk_pre_logic_level1/inst_pre_logic/gen_pre_logic($i)/inst_pre_logic/delay
}
for {set i 0} {$i < 10} {incr i} {
    add wave -group "L1 gate values" -label "$i" sim:/testbench/uut/blk_pre_logic_level1/inst_pre_logic/gen_pre_logic($i)/inst_pre_logic/gate
}

add wave -noupdate -divider -height 20 "Level 2 logic"
add wave -label "L2 input (A)"  sim:/testbench/uut/level2_input(31:0)
add wave -label "L2 input (B)"  sim:/testbench/uut/level2_input(63:0)
add wave -label "L2 input (L1)"  sim:/testbench/uut/level2_input(73:64)
for {set i 0} {$i < 4} {incr i} {
    add wave -group "L2[$i]" -label "Data mask" sim:/testbench/uut/gen_logic_level_2($i)/inst_l2_logic/mask
    add wave -group "L2[$i]" -label "Input data" sim:/testbench/uut/gen_logic_level_2($i)/inst_l2_logic/data_in
    add wave -group "L2[$i]" -label "logic type" sim:/testbench/uut/gen_logic_level_2($i)/inst_l2_logic/logic_type
    add wave -group "L2[$i]" -label "invert" sim:/testbench/uut/gen_logic_level_2($i)/inst_l2_logic/invert
}
add wave -label "L2 result" sim:/testbench/uut/level2_result

add wave -noupdate -divider -height 20 "Spill veto"

set SPILLREG [exa -noshowbase -unsigned sim:/v1495_regs/ARW_SPILL]
add wave -label -unsigned "Pre spill channel"  sim:/testbench/uut/REG_RW($SPILLREG)(7:0)
add wave -label -unsigned "end of spill channel"  sim:/testbench/uut/REG_RW($SPILLREG)(15:8)
#add wave -label "Spill register"  sim:/testbench/uut/REG_RW($SPILLREG)(16)

#add wave -label "End of spill channel number"  sim:/testbench/uut/blk_spill_veto/end_of_spill
#add wave -label "Pre-spill channel number"  sim:/testbench/uut/blk_spill_veto/pre_spill

add wave -label "End of spill" sim:/testbench/uut/blk_spill_veto/inst_spill_veto/start_i
add wave -label "Pre-spill" sim:/testbench/uut/blk_spill_veto/inst_spill_veto/end_i
add wave -label "Spill veto enabled" sim:/testbench/uut/blk_spill_veto/inst_spill_veto/veto_en
add wave -label "Spill veto"  sim:/testbench/uut/blk_spill_veto/inst_spill_veto/veto_o

add wave -noupdate -divider -height 20 "LEMO outputs"

add wave -label "Raw A" sim:/testbench/uut/blk_lemo_output/inst_lemo/raw_in(31:0)
add wave -label "Raw B" sim:/testbench/uut/blk_lemo_output/inst_lemo/raw_in(63:32)
add wave -label "Raw D" sim:/testbench/uut/blk_lemo_output/inst_lemo/raw_in(95:64)
add wave -label "Raw L1" sim:/testbench/uut/blk_lemo_output/inst_lemo/raw_in(105:96)
add wave -label "Raw L2" sim:/testbench/uut/blk_lemo_output/inst_lemo/raw_in(109:106)

add wave -label "Pre-logic A" sim:/testbench/uut/blk_lemo_output/inst_lemo/prep_in(31:0)
add wave -label "Pre-logic B" sim:/testbench/uut/blk_lemo_output/inst_lemo/prep_in(63:32)
add wave -label "Pre-logic D" sim:/testbench/uut/blk_lemo_output/inst_lemo/prep_in(95:64)
add wave -label "Pre-logic L1" sim:/testbench/uut/blk_lemo_output/inst_lemo/prep_in(105:96)
add wave -label "Pre-logic L2" sim:/testbench/uut/blk_lemo_output/inst_lemo/prep_in(109:106)

add wave -label "Post trigger deadtime" sim:/testbench/uut/blk_lemo_output/inst_deadtime/data_out
add wave -label "LEMO output settings"  sim:/testbench/uut/blk_lemo_output/inst_lemo/regs_in

add wave -label "Signals at lemo connectors" {lemo_out {

    sim:/testbench/uut/E_Expan(0)
    sim:/testbench/uut/E_Expan(16)
    sim:/testbench/uut/E_Expan(1)
    sim:/testbench/uut/E_Expan(17)
    sim:/testbench/uut/E_Expan(12)
    sim:/testbench/uut/E_Expan(28)
    sim:/testbench/uut/E_Expan(13)
    sim:/testbench/uut/E_Expan(29)
    
    sim:/testbench/uut/F_Expan(0)
    sim:/testbench/uut/F_Expan(16)
    sim:/testbench/uut/F_Expan(1)
    sim:/testbench/uut/F_Expan(17)
    sim:/testbench/uut/F_Expan(12)
    sim:/testbench/uut/F_Expan(28)
    sim:/testbench/uut/F_Expan(13)
    sim:/testbench/uut/F_Expan(29)  

}}
