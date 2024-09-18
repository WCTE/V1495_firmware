library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;
use work.V1495_regs.all;

-- Entity contains level 2 logic unit and counter
entity level2_logic is
  generic(
    -- Number of input channels
    N_CHANNELS : integer := 74;
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
    -- result of this logic unit
    result : out std_logic;
    -- counts number of times logic result is true
    count : out std_logic_vector(COUNTER_WIDTH-1 downto 0)     
  );
end entity level2_logic;



architecture behavioral of level2_logic is

    signal result_s : std_logic;
    signal mask_s : std_logic_vector(N_CHANNELS-1 downto 0);
    signal count_s : std_logic_vector(COUNTER_WIDTH-1 downto 0);
    signal data_s: std_logic_vector(N_CHANNELS-1 downto 0);
	 
  begin  
  
    mask_s <= mask;
	 
	 -- Invert data if requested
    gen_inv: for i in N_CHANNELS - 1 downto 0 generate
      data_s(i) <= not data_in(i) when invert(i) = '1' else
                   data_in(i);
    end generate gen_inv;

    -- Instance of logic unit
    inst_logic : entity work.logic_unit
    generic map(
      bus_width => N_CHANNELS
    )
    port map(
      clk => clk,
      reset => reset,
      data_in => data_s,
      mask => mask_s,
      type_i => logic_type,
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
        count_en => '1',
        data_in => logic_type,
        count_out => count_s
      );   
	 
    result <= result_s;
    count <= count_s;
	 
end architecture behavioral;
