library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity trigger_deadtime is
port(
  clk : in std_logic;
  reset : in std_logic;
  data_in : in std_logic;
  data_out : out std_logic;
  deadtime_width : in std_logic_vector(31 downto 0)
);
end entity trigger_deadtime;

architecture behavioral of trigger_deadtime is

  type t_deadtime_state is (IDLE, COUNTING);
  signal deadtime_state : t_deadtime_state := IDLE;

  signal deadtime_l : std_logic;

begin

--   inst_dly: entity work.delay_chain
--     generic map (
--       W_WIDTH  => 32,
--       D_DEPTH   => 1
--     )
--     port map (
--       clk       => clk,
--       en_i      => '1',
--       sig_i     => deadtime_width,
--       sig_o     => deadtime_width_s
--	  );


  proc_deadtime : process(clk)
    variable counter : integer;
  begin
    if rising_edge(clk) then
      if reset = '1' then
        deadtime_l <= '0';
        counter := 0;
        deadtime_state <= IDLE;
      else
        case deadtime_state is

          when IDLE =>
            if data_in = '1' then
              counter := 1;
              deadtime_l <= '1';
              deadtime_state <= COUNTING;
            else
              counter := 0;
              deadtime_l <= '0';
              deadtime_state <= IDLE;
            end if;


          when COUNTING =>
            if counter >= to_integer(unsigned(deadtime_width)) then
              counter := 0;
              deadtime_l <= '0';
              deadtime_state <= IDLE;
            else
              deadtime_l <= '1';
              counter := counter +1;
              deadtime_state <= COUNTING;
            end if;

        end case;


      end if;
    end IF;
  end process proc_deadtime;

  data_out <= deadtime_l when unsigned(deadtime_width) > 0 else
              '0';

end architecture behavioral;
