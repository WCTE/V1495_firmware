

create_clock -name LCLK  -period 40MHz [get_ports {LCLK}]
derive_pll_clocks