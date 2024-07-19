library IEEE;
use IEEE.std_Logic_1164.all;
--use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL; 
use work.V1495_regs.all;
use work.functions.all;

entity counter is
  port(
    clk : in std_logic;
	 reset : in std_logic;
	 count_en : in std_logic;
	 data_in : in std_logic;
	 count_out : out std_logic_vector(31 downto 0) 
  
  );
end entity counter;


architecture behavioral of counter is

  signal in_dly : std_logic;
  signal edge : std_logic;
  signal counter_unsigned : unsigned(31 downto 0);

begin

	 proc_edge_detect : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                in_dly <= '0';
            else
                in_dly <= data_in;
            end if;
        end if;

    end process;

    edge <= not in_dly and data_in;


  proc_count : process(clk)
  begin
    if rising_edge(clk) then
	   if reset = '1' then
		  counter_unsigned <= (others => '0');
		else
		  if count_en = '1' and edge = '1' then
		    counter_unsigned <= counter_unsigned + 1;
		  end if;		
		end if;
	 end if;
  end process proc_count;

  count_out <= std_logic_vector(counter_unsigned);


end architecture behavioral;