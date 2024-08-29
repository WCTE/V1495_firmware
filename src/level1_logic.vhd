library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;
use work.V1495_regs.all;


entity level1_logic is
  generic(
    N_CHANNELS : integer := 64;
	 COUNTER_WIDTH : integer := 32
  );
  port(
    clk : in std_logic;
	 reset : in std_logic;
	 mask : in std_logic_vector(N_CHANNELS-1 downto 0);
	 data_in : in std_logic_vector(N_CHANNELS-1 downto 0);
	 logic_type : in std_logic;
	 prescale : in std_logic_vector(7 downto 0);
  
    result : out std_logic;
	 count : out std_logic_vector(COUNTER_WIDTH-1 downto 0)
     
  );
end entity level1_logic;


architecture behavioral of level1_logic is

    signal mask_s : std_logic_vector(N_CHANNELS-1 downto 0);
    signal result_s : std_logic;
    signal prescale_result : std_logic;
    signal l_type_s : std_logic;
    signal count_s : std_logic_vector(COUNTER_WIDTH-1 downto 0);
	 signal data_s: std_logic_vector(N_CHANNELS-1 downto 0);
	 
	 signal prescale_s : std_logic_vector(7 downto 0);
	 	 
begin
    
   proc_data_pipeline : process(clk)
     begin
       if rising_edge(clk) then
         mask_s <= mask;
         l_type_s <= logic_type;
			data_s <= data_in;
			prescale_s <= prescale;
     end if;
   end process proc_data_pipeline;

  
   inst_logic : entity work.logic_unit
   generic map(
     bus_width => N_CHANNELS
   )
   port map(
     clk => clk,
     reset => reset,
     data_in => data_s(N_CHANNELS-1 downto 0),
     mask => mask(N_CHANNELS-1 downto 0),
     type_i => l_type_s,
     result => result_s
   );
   
   inst_counter : entity work.counter
   generic map(
     count_width => COUNTER_WIDTH
   )
   port map(
     clk => clk,
     reset => reset,
     count_en => '1',
     data_in => result_s,
     count_out => count_s  --pipeline this
   );   
   
	inst_prescale : work.prescale
   port map(
     clk => clk,
     prescale_value => prescale_s,
     counter_value => count_s(7 downto 0),
     logic_result => result_s,
     prescaled_result => prescale_result
   );
	
	result <= prescale_result;
	count <= count_s;
	
	
--	
--   proc_counter_pipeline : process(lclk)
--   begin
--     if rising_edge(lclk) then
--       REG_R(AR_LVL1_COUNTERS(i)) <= (31 downto COUNTER_WIDTH => '0')&count;
--     end if;
--   end process proc_counter_pipeline;
    
   --level1_result(i) <= prescale_result;
	
end architecture behavioral;