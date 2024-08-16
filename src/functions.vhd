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
    -- Calculates: ceil(ld(arg))
  function log2ceil(arg : positive) return natural;
  
	function ite(cond : boolean; value1 : integer; value2 : integer) return integer;
	
	function and_reduct(slv : in std_logic_vector) return std_logic;
	function or_reduct(slv : in std_logic_vector) return std_logic;
	function div_ceil(a : natural; b : positive) return natural;
  

end package functions;


package body functions is
	function ite(cond : boolean; value1 : integer; value2 : integer) return integer is
	begin
		if cond then
			return value1;
		else
			return value2;
		end if;
	end function;


	function log2ceil(arg : positive) return natural is
		variable tmp : positive;
		variable log : natural;
	begin
		if arg = 1 then	return 0; end if;
		tmp := 1;
		log := 0;
		while arg > tmp loop
			tmp := tmp * 2;
			log := log + 1;
		end loop;
		return log;
	end function;



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
  
  function and_reduct(slv : in std_logic_vector) return std_logic is
  variable res_v : std_logic := '1';  -- Null slv vector will also return '1'
begin
  for i in slv'range loop
    res_v := res_v and slv(i);
  end loop;
  return res_v;
end function;

function or_reduct(slv : in std_logic_vector) return std_logic is
  variable res_v : std_logic := '0';  -- Null slv vector will also return '1'
begin
  for i in slv'range loop
    res_v := res_v or slv(i);
  end loop;
  return res_v;
end function;

	function div_ceil(a : natural; b : positive) return natural is	-- calculates: ceil(a / b)
	begin
		return (a + (b - 1)) / b;
	end function;



  
  

end package body functions;