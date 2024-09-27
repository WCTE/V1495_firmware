library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;
use work.V1495_regs.all;
use work.functions.all;

-- Sets the lemo outputs to the signals specified by registers
entity lemo_output is
  generic(
    -- Number of possible channels
    n_channels : integer := 110;
	 n_outputs : integer := 16
  );
  port(
    clk : in std_logic;
    reset : in std_logic;
    -- Un-prescaled data
    raw_in : std_logic_vector(n_channels-1 downto 0);
    -- Prescaled data
    prep_in : std_logic_vector(n_channels-1 downto 0);
    -- Relevant registers
    regs_in : in reg_data(0 to n_outputs-1);
    -- output signals to be routed to the lemo connectors
    data_out : out std_logic_vector(n_outputs-1 downto 0)
  );
end entity lemo_output;

architecture behavioral of lemo_output is
  
 
  signal dlyin : std_logic_vector(n_outputs-1 downto 0) := (others => '0');
  
    
begin

  
  gen_integers : for i in n_outputs-1 downto 0 generate
    signal rawOrNot : std_logic;
    signal channel : integer range 0 to n_channels;
	 
  begin
    -- Check if raw or prescaled channel is requested
    rawOrNot <= regs_in(i)(7);
    -- convert std_logic_vector signals into integers
    channel <= to_integer(unsigned(regs_in(i)(6 downto 0))); 
	 
    dlyin(i) <= raw_in(channel) when rawOrNot = '0' else
                prep_in(channel);
					 

  end generate;
  
  --data_out <= dlyin;
  
   inst_dly: entity work.delay_chain
     generic map (
       W_WIDTH  => 16,
       D_DEPTH   => 3
     )
     port map (
       clk       => clk,
       en_i      => '1',
       sig_i     => dlyin,
       sig_o     => data_out
     );
  
  
    
end architecture behavioral;
