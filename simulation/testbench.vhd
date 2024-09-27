library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;


entity testbench is
end entity testbench;

architecture tb of testbench is
  signal clk_int : std_logic := '0';
  signal clk_ext : std_logic := '0';
  signal nreset : std_logic := '1';

  signal A :std_logic_vector(31 downto 0);
  signal B :std_logic_vector(31 downto 0);
  signal D :std_logic_vector(31 downto 0);

  signal DDLY : std_logic_vector(7 downto 0);
  signal SPARE : std_logic_vector (11 DOWNTO 0);
  
begin

  clk_int <= not clk_int after 12.5ns;
  clk_ext <= not clk_ext after 8ns;
  nreset <= '0', '1' after 10 ns;
  
  

  uut : entity work.HyperK_WCTE_V1495_top
  port map(
    -- Front Panel Ports
    A => A,
    B => B,
    D => D,
    
    GIN(0)  => clk_ext,
    GIN(1) => '0',
    
    IDD   => "001",
    IDE  => "011",
    IDF  => "011",

    --PULSE  => "0000",
    --DDLY => DDLY,  
    --SPARE  => SPARE,

    -- Local Bus in/out signals
    nLBRES    => nreset,
    nBLAST   => '0',
    WnR     => '0',
    nADS     => '0',
    LCLK     => clk_int
  );

  data_source : entity work.dataGenerator
  port map(
    A => A,
    B => B,
    D =>D
  );

end architecture tb;
