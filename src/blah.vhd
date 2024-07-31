
library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;
use work.V1495_regs.all;


entity blah is
port(
  addressesR : in reg_addresses(0 to numRregs-1);
  addressesRW : in reg_addresses(0 to numRWregs-1)
  );
end entity blah;

architecture behavioral of blah is

begin


end architecture behavioral;
  