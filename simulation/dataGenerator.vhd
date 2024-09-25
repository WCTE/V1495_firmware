library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;
use ieee.math_real.all;

entity dataGenerator is
  port(
    A : out std_logic_vector(31 downto 0) := (others => '0');
    B : out std_logic_vector(31 downto 0);
    D : out std_logic_vector(31 downto 0)
  );          
end entity dataGenerator;

architecture behavioral of dataGenerator is
  signal rand_numA : integer := 0;
  signal rand_numB : integer := 0;
  signal rand_numD : integer := 0;
begin

  process
    variable seed1, seed2: positive:=99;               -- seed values for random generator
    variable rand: real;   -- random real-number value in range 0 to 1.0  
    variable rand_num :integer := 0;
    variable rand_interval :integer := 0;
  begin
    uniform(seed1, seed2, rand);   -- generate random number
    rand_num := integer(rand*31.0);  -- rescale to 0..1000, convert integer part
    A(rand_num) <= '1';
    wait for 10 ns;
    A <= (others => '0');
    uniform(seed1, seed2, rand);   -- generate random number
    rand_interval := integer(rand*30.0);
    wait for rand_interval*1 ns;  
  end process;


  process
    variable seed1, seed2: positive:=60;               -- seed values for random generator
    variable rand: real;   -- random real-number value in range 0 to 1.0  
    variable rand_num :integer := 0;
    variable rand_interval :integer := 0;
  begin
    uniform(seed1, seed2, rand);   -- generate random number
    rand_num := integer(rand*31.0);  -- rescale to 0..1000, convert integer part
    B(rand_num) <= '1';
    wait for 10 ns;
    B <= (others => '0');
    uniform(seed1, seed2, rand);   -- generate random number
    rand_interval := integer(rand*30.0);
    wait for rand_interval*1 ns;  
  end process;

   process
    variable seed1, seed2: positive:=10;               -- seed values for random generator
    variable rand: real;   -- random real-number value in range 0 to 1.0  
    variable rand_num :integer := 0;
    variable rand_interval :integer := 0;
  begin
    uniform(seed1, seed2, rand);   -- generate random number
    rand_num := integer(rand*31.0);  -- rescale to 0..1000, convert integer part
    D(rand_num) <= '1';
    wait for 10 ns;
    D <= (others => '0');
    uniform(seed1, seed2, rand);   -- generate random number
    rand_interval := integer(rand*30.0);
    wait for rand_interval*1 ns;  
  end process; 


end architecture behavioral;


  
  
  
