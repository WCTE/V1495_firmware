--------------------------------------------------------------------------------
-- based on a WIZARD-GENERATED FILE
-- Set inclk0_input_frequency to 1000GHz/input frequency
-- Example:
--  input frequency = 100 MHz => inclk0_input_frequency = 10000
--  input frequency =  50 MHz => inclk0_input_frequency = 20000
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ALTERA_CMN_PLL is
generic (
  clk0_divide_by      : natural := 0;
  clk0_duty_cycle     : natural := 0;
  clk0_multiply_by    : natural := 0;
  inclk0_input_frequency  : natural := 0
);
port (
  areset          : in  std_logic := '0';
  clk_in          : in  std_logic := '0';
  clk_out_0       : out std_logic := '0';
  locked          : out std_logic := '0'
);
end ALTERA_CMN_PLL;

library altera_mf;


architecture SYN of ALTERA_CMN_PLL is


begin
  assert not (clk0_divide_by = 0 or clk0_duty_cycle = 0 or clk0_multiply_by = 0 or inclk0_input_frequency = 0)
    report "At least one missing generic: clk0_divide_by, clk0_duty_cycle,  clk0_multiply_by and inclk0_input_frequency must be given a value!"
    severity failure;


	 gen_pll: block
  --! wrong alignment to keep diff low
  signal clocks : STD_LOGIC_VECTOR (9 DOWNTO 0);

  COMPONENT altpll
  GENERIC (
    bandwidth_type    : STRING;
    clk0_divide_by    : NATURAL;
    clk0_duty_cycle   : NATURAL;
    clk0_multiply_by    : NATURAL;
    clk0_phase_shift    : STRING;
    -- compensate_clock   : STRING;
    inclk0_input_frequency    : NATURAL;
    intended_device_family    : STRING;
    lpm_hint    : STRING;
    lpm_type    : STRING;
    operation_mode    : STRING;
    pll_type    : STRING;
    port_activeclock    : STRING;
    port_areset   : STRING;
    port_clkbad0    : STRING;
    port_clkbad1    : STRING;
    port_clkloss    : STRING;
    port_clkswitch    : STRING;
    port_configupdate   : STRING;
    port_fbin   : STRING;
    port_fbout    : STRING;
    port_inclk0   : STRING;
    port_inclk1   : STRING;
    port_locked   : STRING;
    port_pfdena   : STRING;
    port_phasecounterselect   : STRING;
    port_phasedone    : STRING;
    port_phasestep    : STRING;
    port_phaseupdown    : STRING;
    port_pllena   : STRING;
    port_scanaclr   : STRING;
    port_scanclk    : STRING;
    port_scanclkena   : STRING;
    port_scandata   : STRING;
    port_scandataout    : STRING;
    port_scandone   : STRING;
    port_scanread   : STRING;
    port_scanwrite    : STRING;
    port_clk0   : STRING;
    port_clk1   : STRING;
    port_clk2   : STRING;
    port_clk3   : STRING;
    port_clk4   : STRING;
    port_clk5   : STRING;
    port_clk6   : STRING;
    port_clk7   : STRING;
    port_clk8   : STRING;
    port_clk9   : STRING;
    port_clkena0    : STRING;
    port_clkena1    : STRING;
    port_clkena2    : STRING;
    port_clkena3    : STRING;
    port_clkena4    : STRING;
    port_clkena5    : STRING;
    self_reset_on_loss_lock   : STRING;
    using_fbmimicbidir_port   : STRING;
    width_clock   : NATURAL
  );
  PORT (
      areset  : IN STD_LOGIC ;
      clk : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
      inclk : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
      locked  : OUT STD_LOGIC 
  );
  END COMPONENT;
  begin
    altpll_inst : altpll
    generic map (
    bandwidth_type => "AUTO",
    clk0_divide_by => clk0_divide_by,
    clk0_duty_cycle => clk0_duty_cycle,
    clk0_multiply_by => clk0_multiply_by,
    clk0_phase_shift => "0",
    -- compensate_clock => "CLK0",-- to avoid warning 15058
    inclk0_input_frequency => inclk0_input_frequency,
    intended_device_family => "Cyclone",
    lpm_hint => "CBX_MODULE_PREFIX=ALTERA_CMN_PLL",
    lpm_type => "altpll",
    -- operation_mode => "NORMAL",
    operation_mode => "NO_COMPENSATION",-- to avoid warning 15058
    pll_type => "AUTO",
    port_activeclock => "PORT_UNUSED",
    port_areset => "PORT_USED",
    port_clkbad0 => "PORT_UNUSED",
    port_clkbad1 => "PORT_UNUSED",
    port_clkloss => "PORT_UNUSED",
    port_clkswitch => "PORT_UNUSED",
    port_configupdate => "PORT_UNUSED",
    port_fbin => "PORT_UNUSED",
    port_fbout => "PORT_UNUSED",
    port_inclk0 => "PORT_USED",
    port_inclk1 => "PORT_UNUSED",
    port_locked => "PORT_USED",
    port_pfdena => "PORT_UNUSED",
    port_phasecounterselect => "PORT_UNUSED",
    port_phasedone => "PORT_UNUSED",
    port_phasestep => "PORT_UNUSED",
    port_phaseupdown => "PORT_UNUSED",
    port_pllena => "PORT_UNUSED",
    port_scanaclr => "PORT_UNUSED",
    port_scanclk => "PORT_UNUSED",
    port_scanclkena => "PORT_UNUSED",
    port_scandata => "PORT_UNUSED",
    port_scandataout => "PORT_UNUSED",
    port_scandone => "PORT_UNUSED",
    port_scanread => "PORT_UNUSED",
    port_scanwrite => "PORT_UNUSED",
    port_clk0 => "PORT_USED",
    port_clk1 => "PORT_UNUSED",
    port_clk2 => "PORT_UNUSED",
    port_clk3 => "PORT_UNUSED",
    port_clk4 => "PORT_UNUSED",
    port_clk5 => "PORT_UNUSED",
    port_clk6 => "PORT_UNUSED",
    port_clk7 => "PORT_UNUSED",
    port_clk8 => "PORT_UNUSED",
    port_clk9 => "PORT_UNUSED",
    port_clkena0 => "PORT_UNUSED",
    port_clkena1 => "PORT_UNUSED",
    port_clkena2 => "PORT_UNUSED",
    port_clkena3 => "PORT_UNUSED",
    port_clkena4 => "PORT_UNUSED",
    port_clkena5 => "PORT_UNUSED",
    self_reset_on_loss_lock => "OFF",
    using_fbmimicbidir_port => "OFF",
    width_clock => 10
    )
    port map (
    areset => areset,
    inclk(0) => clk_in,
    inclk(1) => '0',
    clk     => clocks,
    locked => locked
  );

  clk_out_0 <= clocks(0);
  end block;
--! else

end SYN;
