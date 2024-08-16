library IEEE;
use IEEE.std_Logic_1164.all;
--use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL; 
use work.V1495_regs.all;
use work.functions.all;

entity counter is
  generic(
    count_width : integer := 32
  );
  port(
    clk : in std_logic;
	 reset : in std_logic;
	 count_en : in std_logic;
	 data_in : in std_logic;
	 count_out : out std_logic_vector(count_width - 1 downto 0) 
  
  );
end entity counter;


architecture behavioral of counter is

  signal counter_unsigned : unsigned(count_width - 1 downto 0);

begin

  proc_count : process(clk)
    variable prev : std_logic;
	 variable do_count : std_logic;
  begin
    if rising_edge(clk) then
	   if reset = '1' then
		  counter_unsigned <= (others => '0');
		  prev := '0';
		  do_count := '0';
		else
		  do_count := not prev and data_in;
		  if count_en = '1' and do_count = '1' then
		    counter_unsigned <= counter_unsigned + 1;
		  end if;		
		  prev := data_in;
		end if;
	 end if;
  end process proc_count;

  count_out <= std_logic_vector(counter_unsigned);


end architecture behavioral;