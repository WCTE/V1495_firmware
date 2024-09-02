library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;
use work.V1495_regs.all;


entity level2_logic is
  generic(
    N_CHANNELS : integer := 74;
	 COUNTER_WIDTH : integer := 32
  );
  port(
    clk : in std_logic;
	 reset : in std_logic;
	 mask : in std_logic_vector(N_CHANNELS-1 downto 0);
	 data_in : in std_logic_vector(N_CHANNELS-1 downto 0);
	 logic_type : in std_logic;
  
    result : out std_logic;
	 count : out std_logic_vector(COUNTER_WIDTH-1 downto 0)
     
  );
end entity level2_logic;



architecture behavioral of level2_logic is

    signal result_s : std_logic;
    signal l_type_s : std_logic;
    signal mask_s : std_logic_vector(N_CHANNELS-1 downto 0);
    signal count_s : std_logic_vector(COUNTER_WIDTH-1 downto 0);
	 
  begin  
  
   --proc_data_pipeline : process(clk)
   -- begin
   --   if rising_edge(clk) then
        mask_s <= mask;
   --     l_type_s <= logic_type;
   --   end if;
   -- end process proc_data_pipeline;   
  
    inst_logic : entity work.logic_unit
    generic map(
      bus_width => N_CHANNELS
    )
    port map(
      clk => clk,
      reset => reset,
      data_in => data_in,
      mask => mask_s,
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
     data_in => l_type_s,
     count_out => count_s
    );   
	 
	 result <= result_s;
	 count <= count_s;
	 
	 
end architecture behavioral;