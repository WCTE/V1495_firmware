library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;
use work.V1495_regs.all;

-- Entity contains level 1 logic unit and counter
entity level1_logic is
  generic(
    -- Number of input channels
    N_CHANNELS : integer := 64;
    -- Width of counters
    COUNTER_WIDTH : integer := 32
  );
  port(
    clk : in std_logic;
    reset : in std_logic;
    -- Mask to enable/disable channels in logic element
    mask : in std_logic_vector(N_CHANNELS-1 downto 0);
    -- Input data
    data_in : in std_logic_vector(N_CHANNELS-1 downto 0);
    -- Switch between and/or logic
    logic_type : in std_logic;
    -- Invert signals
    invert : in std_logic_vector(N_CHANNELS-1 downto 0);
    -- Prescale output by this factor
    prescale : in std_logic_vector(7 downto 0);
	 -- Counter enable
	 count_en_i : in std_logic;
    -- result of this logic unit
    result : out std_logic;
    -- counts number of times logic result is true
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

  mask_s <= mask;
  l_type_s <= logic_type;

  -- Invert data if requested
  gen_inv: for i in N_CHANNELS - 1 downto 0 generate
    data_s(i) <= not data_in(i) when invert(i) = '1' else
                 data_in(i);
  end generate gen_inv;
  prescale_s <= prescale;
	
  -- Instance of logic unit
  inst_logic : entity work.logic_unit
    generic map(
      bus_width => N_CHANNELS
    )
    port map(
      clk => clk,
      reset => reset,
      data_in => data_s(N_CHANNELS-1 downto 0),
      mask => mask_s(N_CHANNELS-1 downto 0),
      type_i => l_type_s,
      result => result_s
    );

  -- Instance of counter
  inst_counter : entity work.counter
   generic map(
     count_width => COUNTER_WIDTH
   )
   port map(
     clk => clk,
     reset => reset,
     count_en => count_en_i,
     data_in => result_s,
     count_out => count_s  --pipeline this
   );   

  -- Instance of prescale
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
	
end architecture behavioral;
