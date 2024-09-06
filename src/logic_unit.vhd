library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL; 
use work.V1495_regs.all;
use work.functions.all;

-- Entity which performs the logical and/or on the data
entity logic_unit is
  generic(
    -- Width of input data
    bus_width : integer := 96
  );
  port(
    clk: in std_logic;
    reset : in std_logic;
    -- Input data
    data_in : in std_logic_vector(bus_width-1 downto 0);
    -- Mask to enable/disable channel
    mask : in std_logic_vector(bus_width-1 downto 0);
    -- Switch between and/or logic
    type_i : in std_logic;
    -- result of logic
    result : out std_logic
  );
end entity logic_unit;


architecture behavioral of logic_unit is
  -- Data after mask is applied
  signal maskedData : std_logic_vector(bus_width-1 downto 0);

begin

  proc_logic : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then 
        result <= '0';
      else
        if type_i = '0' then  -- And logic is applied
          -- result is an and of all bits of masked data
          result <= and_reduct(maskedData);
          -- Sets all disabled channels to '1' so they don't affect the 'and'
          maskedData <= data_in or not mask;  			
        elsif type_i = '1' then -- Or logic is applied
          -- result is an or of all bits of masked data
          result <= or_reduct(maskedData);
          -- Sets all disabled channels to '0' so they don't affect the 'or'
          maskedData <= data_in and mask;		
        end if;	 
        
      end if;	  
    end if;
  end process proc_logic;

end architecture behavioral;
