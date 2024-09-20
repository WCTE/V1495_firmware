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
  
  
    gen_dly_gate_1 : for i in div_ceil(n_channels,4)-1 downto 0 generate 	 
	   gen_dly_gate_2 : for j in 3 downto 0 generate
		  signal temp :std_logic_vector(15 downto 0);
		  begin
		  
   inst_dly: entity work.delay_chain
     generic map (
       W_WIDTH  => 16,
       D_DEPTH   => 2
     )
     port map (
       clk       => clk,
       en_i      => '1',
       sig_i     => delay_regs(i)(8*(j+1)-1 downto 8*j) & gate_regs(i)(8*(j+1)-1 downto 8*j),
       sig_o     => temp
     );
		
		   delays(4*i+j) <= temp(15 downto 8);
			gates(4*i+j) <= temp(7 downto 0);
		
		end generate gen_dly_gate_2;
    end generate gen_dly_gate_1; 

 
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
	end generate gen_pre_logic; 
  
end architecture behavioral;