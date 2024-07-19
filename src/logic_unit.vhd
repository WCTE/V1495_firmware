
library IEEE;
use IEEE.std_Logic_1164.all;
--use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL; 
use work.V1495_regs.all;
use work.functions.all;


entity logic_unit is
 generic(
   bus_width : integer := 96
 );
 port(
	clk: in std_logic;
	reset : in std_logic;
	data_in : in std_logic_vector(bus_width-1 downto 0);
	mask : in std_logic_vector(bus_width-1 downto 0);
	type_i : in std_logic;
	result : out std_logic
 );
end entity logic_unit;


architecture behavioral of logic_unit is

  signal maskedData : std_logic_vector(bus_width-1 downto 0);

begin

	proc_logic : process(clk)
	begin
	  if rising_edge(clk) then
	    if reset = '1' then 
		   result <= '0';
		 else
		   if type_i = '0' then  -- AND
			  result <= and_reduct(maskedData);	
           maskedData <= data_in or not mask;  			
			elsif type_i = '1' then --OR
			  result <= or_reduct(maskedData);	
           maskedData <= data_in and mask;		
			end if;	 
		 
		 end if;	  
	  end if;
	end process proc_logic;

	


end architecture behavioral;