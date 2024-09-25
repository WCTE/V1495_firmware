library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;
use ieee.math_real.all;

-----------------------------------------------
-- Data generator for simulation.
-- Generates 10ns pulses on randomly choosen
-- channels of A, B, and D with random time
-- intervals between pulses
-----------------------------------------------

entity dataGenerator is
  port(
    A : out std_logic_vector(31 downto 0) := (others => '0');
    B : out std_logic_vector(31 downto 0);
    D : out std_logic_vector(31 downto 0)
  );          
end entity dataGenerator;

architecture behavioral of dataGenerator is
begin

  process
    variable seed1, seed2: positive:=99; 
    variable rand: real;   
    variable rand_num :integer := 0;
    variable rand_interval :integer := 0;
  begin
    uniform(seed1, seed2, rand);
    rand_num := integer(rand*31.0); 
    A(rand_num) <= '1';
    wait for 10 ns;
    A <= (others => '0');
    uniform(seed1, seed2, rand);
    rand_interval := integer(rand*30.0);
    wait for rand_interval*1 ns;  
  end process;


  process
    variable seed1, seed2: positive:=60;  
    variable rand: real; 
    variable rand_num :integer := 0;
    variable rand_interval :integer := 0;
  begin
    uniform(seed1, seed2, rand);  
    rand_num := integer(rand*31.0);  
    B(rand_num) <= '1';
    wait for 10 ns;
    B <= (others => '0');
    uniform(seed1, seed2, rand);   
    rand_interval := integer(rand*30.0);
    wait for rand_interval*1 ns;  
  end process;

   process
    variable seed1, seed2: positive:=10;         
    variable rand: real;  
    variable rand_num :integer := 0;
    variable rand_interval :integer := 0;
  begin
    uniform(seed1, seed2, rand);   
    rand_num := integer(rand*31.0); 
    D(rand_num) <= '1';
    wait for 10 ns;
    D <= (others => '0');
    uniform(seed1, seed2, rand);  
    rand_interval := integer(rand*30.0);
    wait for rand_interval*1 ns;  
  end process; 


end architecture behavioral;


  
  
  
