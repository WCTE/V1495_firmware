library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity prescale is
  port(
    clk: in std_logic;
    prescale_value : in std_logic_vector(7 downto 0);
    counter_value : in std_logic_vector(7 downto 0);
	 invert : in std_logic;
    logic_result : in std_logic;
    prescaled_result : out std_logic
  );
end entity prescale;


architecture behavioral of prescale is
  constant zeros : std_logic_vector(7 downto 0) := (others => '0');

   function not_swap(case1: boolean; inv: std_logic) return boolean is
	begin
	  if inv = '1' then
	    return not case1;
	  else
	    return case1;
	  end if;
	  
	end function;

	
begin

   

	proc_scale : process(clk)
	begin
	  if rising_edge(clk) then
 	    if prescale_value(7) = '1' then
		   if not(unsigned(counter_value(6 downto 0)) = 0) and invert = '0' then 
			  prescaled_result <= logic_result; 
		   elsif (unsigned(counter_value(6 downto 0)) = 0) and invert = '1' then 
			  prescaled_result <= logic_result; 
			else 
			  prescaled_result <= '0';  
			end if;
		 elsif prescale_value(6) = '1' then
		 	if not(unsigned(counter_value(5 downto 0)) = 0) and invert = '0' then
			  prescaled_result <= logic_result; 
		   elsif (unsigned(counter_value(5 downto 0)) = 0) and invert = '1' then 
			  prescaled_result <= logic_result; 
			else 
			  prescaled_result <= '0';  
			end if;	 
		 elsif prescale_value(5) = '1' then
		   if not(unsigned(counter_value(4 downto 0)) = 0) and invert = '0' then
			  prescaled_result <= logic_result; 
		   elsif (unsigned(counter_value(4 downto 0)) = 0) and invert = '1' then 
			  prescaled_result <= logic_result; 
			else 
			  prescaled_result <= '0';  
			end if;
		 elsif prescale_value(4) = '1' then
		   if not(unsigned(counter_value(3 downto 0)) = 0) and invert = '0' then
			  prescaled_result <= logic_result; 
		   elsif (unsigned(counter_value(3 downto 0)) = 0) and invert = '1' then 
			  prescaled_result <= logic_result; 
			else 
			  prescaled_result <= '0';  
			end if;
		 elsif prescale_value(3) = '1' then
		   if not(unsigned(counter_value(2 downto 0)) = 0) and invert = '0' then
			  prescaled_result <= logic_result; 
		   elsif (unsigned(counter_value(2 downto 0)) = 0) and invert = '1' then 
			  prescaled_result <= logic_result; 
			else 
			  prescaled_result <= '0';  
			end if;
		 elsif prescale_value(2) = '1' then
		   if not(unsigned(counter_value(1 downto 0)) = 0) and invert = '0' then
			  prescaled_result <= logic_result; 
			elsif (unsigned(counter_value(1 downto 0)) = 0) and invert = '1' then
			  prescaled_result <= logic_result; 
			else 
			  prescaled_result <= '0';  
			end if;
		 elsif prescale_value(1) = '1' then
		   if not(unsigned(counter_value(0 downto 0)) = 0) and invert = '0' then
			  prescaled_result <= logic_result; 
		   elsif (unsigned(counter_value(0 downto 0)) = 0) and invert = '1' then 
			  prescaled_result <= logic_result; 
			else
			  prescaled_result <= '0';  
			end if; 
		 else
		   prescaled_result <= logic_result;
		 end if;		 
	  end if;
	end process proc_scale;



end architecture behavioral;
