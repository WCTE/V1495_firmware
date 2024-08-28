library IEEE;
use IEEE.std_Logic_1164.all;
--use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity prescale is
  port(
    clk: in std_logic;
    prescale_value : in std_logic_vector(31 downto 0);
    counter_value : in std_logic_vector(31 downto 0);
    logic_result : in std_logic;
    prescaled_result : out std_logic
  );
end entity prescale;


architecture behavioral of prescale is
--  type Switches is range 0 to 32;

  signal MSB : integer range 0 to 31 := 0;

  signal prescaleCheck : std_logic_vector(31 downto 0):=(others => '0');

begin

  -- need to find MSB od prescale_value
  shifting : PROCESS(prescale_value)
    VARIABLE highest_switch : integer := 0;
  begin
    for i in 0 to 31 loop
      if prescale_value(i) = '1' then
        highest_switch := i;
      end if;
    end loop;
    MSB <= highest_switch;
  end process;


  prescaled_result <= logic_result when (counter_value(MSB-1 downto 0) = (MSB-1 downto 0 => '0')) or (prescale_value = x"00000000") else
                      '0';


end architecture behavioral;
