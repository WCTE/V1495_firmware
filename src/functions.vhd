-- Functions used

library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;

package functions IS

  -- check if one if the bits in a std_logic_vector is '1'
  function check_for_one( value: std_logic_vector ) return std_logic;
  -- Return how many bits in a std_logic_vector are '1'
  function bits_set(v : std_logic_vector) return natural;

end package functions;


package body functions is

  -- check if one if the bits in a std_logic_vector is '1'
  function    check_for_one( value: std_logic_vector ) return std_logic is
    variable compare: std_logic_vector( (value'length-1) downto 0) :=  (others => '0');
    variable holder: std_logic_vector( (value'length-1) downto 0);
    variable res: std_logic;
  begin
    
    holder := not( not(value) and not(compare));
    if(holder = compare) then
      res := '0';
    else
      res := '1';
    end if;
  return res; end function;
  
  -- Return how many bits in a std_logic_vector are '1'
  function bits_set(v : std_logic_vector) return natural is
    variable n : natural := 0;
  begin
  for i in v'range loop
    if v(i) = '1' then
      n := n + 1;
    end if;
  end loop;
  return n;
  end function bits_set;

end package body functions;