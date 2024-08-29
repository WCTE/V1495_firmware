library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity veto is
  port(
	 start_i : in std_logic;
	 end_i : in std_logic;
	 veto_o : out std_logic
  );
end entity veto;

architecture behavioral of veto is

begin

  proc_veto : procesS(start_i, end_i)
  begin
    if end_i = '1' then
	   veto_o <= '0';
	 elsif start_i = '1' then
	   veto_o <= '1';
	 end if;
  end process proc_veto;


end architecture behavioral;