
library IEEE;
use IEEE.std_Logic_1164.all;
--use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL; 
use work.V1495_regs.all;
use work.functions.all;


entity pre_logic is
 port(
	clk: in std_logic;
	reset : in std_logic;
	data_in : in std_logic;
	delay : in std_logic_vector(7 downto 0);
	gate : in std_logic_vector(7 downto 0);
	delay_val : out integer;
   data_out: out std_logic
 );
end entity pre_logic;

architecture behavioral of pre_logic is

  signal delay_store : std_logic_vector(128 downto 0);
  signal dly : std_logic;
  signal delayed_signal : std_logic;
  signal gate_signal : std_logic;

  signal delay_integer : integer range 0 to 255;
  signal gate_integer : integer range 0 to 255;
  
  type t_gate_state is (IDLE, GATE_OPEN);
  signal gate_state : t_gate_state := IDLE;

  signal in_dly : std_logic;
  signal edge : std_logic;
  
  


begin

	 proc_edge_detect : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                in_dly <= '0';
            else
                in_dly <= data_in;
            end if;
        end if;

    end process;

    edge <= not in_dly and data_in;


  delay_integer <= to_integer(unsigned(delay));
  gate_integer <= to_integer(unsigned(gate));
 
  delay_val <= delay_integer;
 
  blk_delay : block
  
    type t_delay_state is (IDLE, WAITING);
    signal delay_state : t_delay_state;
  
  begin

  proc_delay : process(clk)
    variable counter : integer range 0 to 255;
  begin
    if rising_edge(clk) then
	   if reset = '1' then
		  counter := 0;
		  delay_state <= IDLE;
		  dly <= '0';
		else
	 
	     case delay_state is
	       
			 when IDLE =>
				dly <= '0';
			   if edge = '1' then
				  if delay_integer = 1 then
				    dly <= '1';
				  else				
				    delay_state <= WAITING;				 
				    counter := counter + 1;
				  end if;
				else
				  delay_state <= IDLE;
				  counter := 0;
				end if;
			 
			 when WAITING =>
			   if counter = delay_integer-1 then
				  counter := 0;
				  dly <= '1';
				  delay_state <= IDLE;
				else 
				  counter := counter + 1;
				  delay_state <= WAITING;
				  dly <= '0';
				end if;
				
		  end case;
	   end if;			
	 end if;
  end process proc_delay;
  
  delayed_signal <= edge when delay_integer = 0 else
                    dly;
						  
  end block blk_delay;					  
  
  
  proc_gate : process(clk)
    variable counter : integer range 0 to 255 := 0;
  begin
    if rising_edge(clk) then
	   if reset = '1' then
		  gate_state <= IDLE;
		  counter := 0;
		  gate_signal <= '0';
		else
      case gate_state is
		  
		  when IDLE =>
		    if delayed_signal = '1' then
			   gate_state <= GATE_OPEN;
				counter := 1;
				gate_signal <= '1';
			 else
			   gate_state <= IDLE;
			   counter := 0;
				gate_signal <= '0';
			 end if;
			 
		  when GATE_OPEN =>
		    if counter < gate_integer - 1 then
		      counter := counter + 1;
			   gate_signal <= '1';
				gate_state <= GATE_OPEN;
			 else
			   counter := 0;
				gate_state <= IDLE;
				gate_signal <= '0';
			 end if;
		  
		end case;
		end if;
	 end if;
  end process proc_gate;
  
  data_out <= '0'            when gate_integer = 0 else
              delayed_signal when gate_integer = 1 else  
	           gate_signal or delayed_signal;




end architecture behavioral;