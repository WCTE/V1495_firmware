

create_clock -name LCLK  -period 40MHz [get_ports {LCLK}]
create_clock -name GIN0  -period 62.5MHz [get_ports {GIN[0]}]
derive_pll_clocks
