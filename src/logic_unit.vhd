
library IEEE;
use IEEE.std_Logic_1164.all;
--use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL; 
use work.components.all;
use work.V1495_regs.all;
use work.functions.all;


entity logic_unit is
 port(
	clk: in std_logic;
	reset : in std_logic;
	data_in : in std_logic_vector(95 downto 0);
	mask : in std_logic_vector(95 downto 0);
	type_i : in std_logic;
	maskedData : out std_logic_vector(95 downto 0);
	result : out std_logic
 );
end entity logic_unit;


architecture behavioral of logic_unit is

  --signal maskedData : std_logic_vector(95 downto 0);

begin

 	maskedData <= data_in and mask;

--	result <= 
	
	




end architecture behavioral;