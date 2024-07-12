
library IEEE;
use IEEE.std_Logic_1164.all;
--use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL; 
use work.components.all;
use work.V1495_regs.all;
use work.functions.all;

entity logic_operator is 
  port(
	 clk : in std_logic;
	 reset : in std_logic;
	 channel_mask : in std_logic_vector(95 downto 0);
	 data_in : in std_logic_vector(95 downto 0);
	 a_gate_width : in std_logic_vector(31 downto 0);
	 operation : in std_logic;
	 result : out std_logic_vector(95 downto 0);
	 new_result : out std_logic
  );
end entity logic_operator;



architecture behavioral of logic_operator is

  signal windowOpen : std_logic;
  signal maskedData : std_logic_vector(95 downto 0);  
  signal foundHits : std_logic_vector(95 downto 0);  
  
  type t_window_state is (IDLE, OPEN_WINDOW);
  signal window_state : t_window_state;
  
  signal setBits : natural;

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
		     new_result <= '0';	  
			else
			  case window_state is
			    
			
			    when IDLE =>
		         new_result <= '0';	  
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
					  if(bits_set(foundHits) > 1) then
					    result <= foundHits;
		             new_result <= '1';
					  else
					    new_result <= '0';	  
					  end if;
					else
		           new_result <= '0';	  
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
	  	 			
     setBits <= bits_set(foundHits);


end architecture behavioral;



  
  
  