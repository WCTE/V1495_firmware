--------------------------------------------------------------------------------
-- Simulation stand in for the altera PLL.
-- Does nothing but output a 125 MHz clock on 'clk_out_0', ignoring all inputs.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ALTERA_CMN_PLL is
generic (
  clk0_divide_by      : natural := 0;
  clk0_duty_cycle     : natural := 0;
  clk0_multiply_by    : natural := 0;
  inclk0_input_frequency  : natural := 0
);
port (
  areset          : in  std_logic := '0';
  clk_in          : in  std_logic := '0';
  clk_out_0       : out std_logic := '0';
  locked          : out std_logic := '0'
);
end ALTERA_CMN_PLL;


architecture SYN of ALTERA_CMN_PLL is
   signal tmp : std_logic := '0';
begin
  
  tmp <= not tmp after 4ns;
  clk_out_0 <= tmp;
  locked <= '1';
               
  
end SYN;
