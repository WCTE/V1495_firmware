library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;
use work.V1495_regs.all;


entity lemo_output is
  generic(
     n_channels : integer := 110
  );
  port(
    clk : in std_logic;
	 reset : in std_logic;
	 raw_in : std_logic_vector(n_channels-1 downto 0);
	 prep_in : std_logic_vector(n_channels-1 downto 0);
	 regs_in : in reg_data(0 to 7);
	 data_out : out std_logic_vector(7 downto 0)
  );
end entity lemo_output;

architecture behavioral of lemo_output is

	 signal channels : t_int_v(7 downto 0);
	 signal rawOrNot : std_logic_vector(7 downto 0);
	 
	 signal output : std_logic_vector(7 downto 0) := (others => '0');
    
  begin
  
    gen_integers : for i in 7 downto 0 generate
		rawOrNot(i) <= regs_in(i)(7);
		channels(i) <= to_integer(unsigned(regs_in(i)(6 downto 0)));
	 end generate;
  
    gen_output : for i in 7 downto 0 generate
	 
		proc_output : process(clk)
		
		begin
		  if rising_edge(clk) then
		      if rawOrNot(i) = '0' then
				  output(i) <= raw_in(channels(i));
			   else
			     output(i) <= prep_in(channels(i));
			   end if;
			 end if;
		end process proc_output;
	
	 
	 end generate; 
    data_out <= output;
  
  
end architecture behavioral;