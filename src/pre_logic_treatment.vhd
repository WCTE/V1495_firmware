library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;
use work.V1495_regs.all;
use work.functions.all;


entity pre_logic_treatment is
 generic(
   n_channels : integer := 64
 );
 port(
	clk: in std_logic;
	reset : in std_logic;
	delay_regs : in reg_data(div_ceil(n_channels,4)-1 downto 0);
	gate_regs : in reg_data(div_ceil(n_channels,4)-1 downto 0);
	data_in : in std_logic_vector(n_channels - 1 downto 0);
	prepared_signals : out std_logic_vector(n_channels - 1 downto 0)
 );
end entity pre_logic_treatment;

  -- Pre logic treatment  
 architecture behavioral of pre_logic_treatment is
  signal delays : t_slv_v8(delay_regs'length*4 -1 downto 0);
  signal gates : t_slv_v8(gate_regs'length*4 -1 downto 0);
 
begin
  
  
    gen_level_1 : for i in div_ceil(n_channels,4)-1 downto 0 generate 	 
      delays(4*i) <= delay_regs(i)(7 downto 0);
	   delays(4*i+1) <= delay_regs(i)(15 downto 8);
      delays(4*i+2) <= delay_regs(i)(23 downto 16);
      delays(4*i+3) <= delay_regs(i)(31 downto 24);
		
      gates(4*i) <= gate_regs(i)(7 downto 0);
	   gates(4*i+1) <= gate_regs(i)(15 downto 8);
      gates(4*i+2) <= gate_regs(i)(23 downto 16);
      gates(4*i+3) <= gate_regs(i)(31 downto 24);
    end generate; 

 
	gen_pre_logic : for i in n_channels-1 downto 0 generate
	
	
	  inst_pre_logic : entity work.pre_logic 
       port map(
	    clk => clk,
	    reset => reset,
	    data_in => data_in(i),
	    delay => delays(i),
	    gate  => gates(i),
       data_out => prepared_signals(i)
       );
	end generate; 
  
end architecture behavioral;