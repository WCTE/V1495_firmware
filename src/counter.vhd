library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL; 
use work.V1495_regs.all;
use work.functions.all;


-- A simple counter module which counts when every clock rising edge of
-- `data_in`, as long as `count_en` is high.
entity counter is
  generic(
    count_width : integer := 32
  );
  port(
    reset : in std_logic;
    count_en : in std_logic;
    data_in : in std_logic;
    count_out : out std_logic_vector(count_width - 1 downto 0)     
  );
end entity counter;


architecture behavioral of counter is
  signal counter_unsigned : unsigned(count_width - 1 downto 0);
  signal do_count : std_logic;

begin

  do_count <= data_in and count_en;

  proc_count : process(do_count, reset)
  begin
    if reset = '1' then
	   counter_unsigned <= (others => '0');
	 elsif rising_edge(do_count) then	   
		counter_unsigned <= counter_unsigned+1;
	 end if;
  end process proc_count;

  count_out <= std_logic_vector(counter_unsigned);
  
end architecture behavioral;
