
library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;
use work.components.all;
use work.V1495_regs.all;


entity logic_operator is 
  port(
	 clk : in std_logic;
	 reset : in std_logic;
	 channel_mask : in std_logic_vector(95 downto 0);
	 data_in : in std_logic_vector(95 downto 0);
	 a_gate_width : in std_logic_vector(31 downto 0);
	 operation : in std_logic;
	 result : out std_logic_vector(95 downto 0)
  );
end entity logic_operator;



architecture behavioral of logic_operator is

  signal windowOpen : std_logic;
  signal maskedData : std_logic_vector(95 downto 0);  
  signal foundHits : std_logic_vector(95 downto 0);  
  
  type t_window_state is (IDLE, OPEN_WINDOW);
  signal window_state : t_window_state;
  
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
  

begin

	maskedData <= channel_mask and data_in;


	proc_window : process(clk)
	  variable window : unsigned(31 downto 0);
	begin
		if rising_edge(clk) then
			if reset = '1' then
			  foundHits <= (others => '0');
			  windowOpen <= '0';
			  window := (others => '0');
			  window_state <= IDLE;			  
			else
			  case window_state is
			    
			
			    when IDLE =>
				   if check_for_one(maskedData) = '1' then
					  foundHits <= maskedData;
					  window(0) := '1';
					  window_state <= OPEN_WINDOW;
					  windowOpen <= '1';
					else
					  window := (others => '0');
					  window_state <= IDLE;
					  windowOpen <= '0';
					end if; 
				 
				 
				 when OPEN_WINDOW =>
					if window >= unsigned(a_gate_width) then
					  window := (others => '0');
					  window_state <= IDLE;
					  windowOpen <= '0';
					  result <= foundHits;
					else
					  window := window + 1;
					  window_state <= OPEN_WINDOW;
					  windowOpen <= '1';
					  if check_for_one(maskedData) then
					    foundHits <= foundHits or maskedData;
					  end if;
					end if;
					  
				 
			  end case;
			end if;
		 end if;
	  end process proc_window;
	  	 			



end architecture behavioral;



  
  
  