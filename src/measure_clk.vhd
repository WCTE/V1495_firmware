-- EMACS settings: -*- tab-width: 2; indent-tabs-mode: nil -*-
-- vim: tabstop=2:shiftwidth=2:expandtab
-- kate: tab-width 2; replace-tabs on; indent-width 2;
--------------------------------------------------------------------------------
--! @file
--! @brief Measure the number of clock cycles of a given clock via a reference clock.
--! @author Steffen Stärz <steffen.staerz@cern.ch>
--! @author Philipp Horn <philipp.horn@cern.ch>
--! @todo rename entity to measure_clock to disentangle ambiguity with port
--! @todo rename clk_in_time to clk_in_period
--------------------------------------------------------------------------------
--! @details Measure the number of clock cycles of a given clock via a reference clock.
--!
--! - Counts the #measure_clk clock cycles during a given period.
--! - The period is defined by the #clk_in_time generic and synchronized on the clock #clk.
--! - The number of clock cycles,#measure_value, counted during this period is indicated at #measure_valid = '1'.
--!
--! Examples of usage:
--! -# #clk with 100 MHz, measuring #measure_clk (expected to be 50 MHz) for 1.0 seconds:
--!    - #clk_in_time = 100.000.000, hence expect #measure_value = 50.000.000
--! -# #clk with 100 MHz, measuring #measure_clk (expected to be 124 MHz) for 0.5 milliseconds:
--!    - #clk_in_time = 50.000, hence expect #measure_value = 62.000
--------------------------------------------------------------------------------
--
-- Instantiation template:
--
--  [inst_name]: entity misc.measure_clk
--  generic map (
--    clk_in_time   => [integer := 125000000] --! number of clk cycles during which measure_clk is measured
--  )
--  port map (
--    clk           => [in  std_logic],     --! reference clock
--    rst           => [in  std_logic],     --! sync reset
--    measure_clk   => [in  std_logic],     --! clock being measured
--    measure_valid => [out std_logic],     --! valid signal, sync to clk
--    measure_value => [out std_logic_vector(31 downto 0)]  --! result of the measurement, sync to clk
--  );
--
-------------------------------------------------------------------------------

--! @cond
library IEEE;
use IEEE.std_logic_1164.all;
--! @endcond

entity measure_clk is
  generic(
    clk_in_time : integer := 125000000  --! number of #clk clock cycles during which measure_clk is measured (period of the measurement) (Ex : 125.000.000 for a 125 MHz clock and for a period of 1 second)
  );
  port(
    clk           : in  std_logic;  --! reference clock defining the period of the measurement
    reset         : in  std_logic;  --! synchronous reset, active high, synchronous to clock #clk
    measure_clk   : in  std_logic;  --! clock to be measured
    measure_valid : out std_logic;  --! valid signal when output #measure_value is available, synchronous to #clk
    measure_value : out std_logic_vector(31 downto 0) --! value of #measure_clk clock cycles counted during #clk_in_time clock cycles of #clk, synchronous to #clk
  );
end measure_clk;

library IEEE;
--! Using IEEE Standard Numeric
use IEEE.numeric_std.all;

--! Implementation of measure_clk
architecture behavioral of measure_clk is
  signal count_refclock : unsigned(31 downto 0);          --! counter to count cycles of #measure_clk during measurement period #clk_in_time (in #clk), sync on #measure_clk
  signal count_docu     : std_logic_vector(31 downto 0);  --! docu of counter #count_refclock at the end of measurement, sync on #measure_clk
  signal count_yoda     : std_logic_vector(31 downto 0);  --! latch on #count_docu at the end of measurement with handshake for clock domain crossing, sync on #clk

  signal gate         : std_logic;  --! signal to indicate measurement period, sync on #clk
  signal gate_ref     : std_logic;  --! signal to indicate measurement period, sync on #measure_clk
  signal latch        : std_logic;  --! one clock hot signal set every #clk_in_time cycles of #clk, sync on #clk
  signal stop         : std_logic;  --! one clock hot signal to show end of measurement, sync on #measure_clk
  signal handshake_clk  : std_logic;  --! handshake, generated in domain #clk
  signal handshake    : std_logic;  --! handshake to pass counter #count_docu in #measure_clk to #count_yoda in #clk clock domain, sync on #clk
  signal count_docu_v : std_logic;  --! valid signal for #count_docu to transfer into the #clk domain via #handshake, sync on #measure_clk
  signal count_docu_v_clk : std_logic;  --! count_docu_v in #clk domain

begin

  --! @details
  --! Use the #counting component to generate a one clock hot #latch signal every #clk_in_time cycles of #clk.
  --! - generate #latch signal every period (each #clk_in_time cycles of #clk)
  --! - #counting is always enabled an is reset upon #reset
  comp_every_period : entity work.counting
    generic map(
      counter_max_value => clk_in_time
    )
    port map(
      clk        => clk,
      rst        => reset,
      en         => '1',
      cycle_done => latch
    );

  --! @details
  --! Generate the #gate signal with a period of 2 times #clk_in_time cycles of #clk from #latch.
  --! - period divider on one clock hot #latch signal
  --! - generate measurement period (#gate = '1')
  proc_gen_gate : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        gate <= '0';
      elsif latch = '1' then
        gate <= not gate;
      end if;
    end if;
  end process;

  --! @details
  --! Use the #delay_chain component to synchronize #gate from the #clk into the #measure_clk clock domain as #gate_ref.
  comp_sync_gate : entity work.delay_chain
    port map (
      clk   => measure_clk,
      sig_i => gate,
      sig_o => gate_ref
    );

  --! @details
  --! Measure the #measure_clk via a simple counter #count_refclock in the #measure_clk clock domain.
  --! - counter #count_refclock is incremented when #gate_ref = 1 (half a period)
  --! - counter #count_refclock is cleared when #gate_ref = 0 (during the other half period)
  proc_count_refclock : process(measure_clk)
  begin
    if rising_edge(measure_clk) then
      if (gate_ref = '1') then
        count_refclock <= count_refclock + 1;
      else
        count_refclock <= (others => '0');
      end if;
    end if;
  end process;

  --! @details
  --! Use the #hilo_detect component to generate one clock hot #stop from #gate_ref in the #measure_clk domain to indicate end of measurement
  comp_gen_stop : entity work.hilo_detect
    port map (
      clk     => measure_clk,
      sig_in  => gate_ref,
      sig_out => stop
    );

  --! @details
  --! Store #count_refclock (counter for measurement), set #count_docu_v (valid) and wait for #handshake of the #proc_transfer_result process.
  --! - store #count_refclock as #count_docu and set #count_docu_v upon the #stop signal (end of measurement)
  --! - release #count_docu_v with #handshake (from #proc_transfer_result) between the #clk and #measure_clk clock domains
  proc_latch_count_refclock : process(measure_clk)
  begin
    if rising_edge(measure_clk) then
      if (stop = '1') then
        count_docu   <= std_logic_vector(count_refclock);
        count_docu_v <= '1';
      else
        count_docu <= count_docu;
        if handshake = '1' then
          count_docu_v <= '0';
        else
          count_docu_v <= count_docu_v;
        end if;
      end if;
    end if;
  end process;

  comp_transfer_count_docu_v : entity work.delay_chain
    port map (
      clk   => clk,
      sig_i => count_docu_v,
      sig_o => count_docu_v_clk
    );

  --! @details
  --! Transfer the result of the measurement from the #measure_clk to the #clk clock domain with handshake.
  --! - latch #count_docu (the stored result of the measurement in the #measure_clk domain) on #count_yoda with #clk clock
  --! - set and release #handshake between the #clk and #measure_clk clock domains via #count_docu_v.
  --! Note that this process triggers a warning in the Design Assistant "CE-Type CDC Transfer with Insufficient Constraints".
  --! This warning can safely be ignored as the signal will be stable when sampling due to external circuitry.
  proc_transfer_result : process(clk)
  begin
    if rising_edge(clk) then
      if count_docu_v_clk = '1' then
        count_yoda <= count_docu;
        handshake_clk  <= '1';
      else
        count_yoda <= count_yoda;
        handshake_clk  <= '0';
      end if;
    end if;
  end process;

  comp_transfer_handshake : entity work.delay_chain
    port map (
      clk   => measure_clk,
      sig_i => handshake_clk,
      sig_o => handshake
    );

  --! @details
  --! Use the #hilo_detect component to generate one clock hot #measure_valid from #handshake in the #clk domain to indicate the clock cycle (in the #clk domain) when #measure_value holds a valid measurement value.
  comp_gen_valid : entity work.hilo_detect
    port map (
      clk     => clk,
      sig_in  => handshake,
      sig_out => measure_valid
    );

  measure_value <= count_yoda;
end;
