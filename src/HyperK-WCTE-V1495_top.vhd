library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;


use work.V1495_regs.all;


entity HyperK_WCTE_V1495_top is
  port(
    -- Front Panel Ports
    A        : IN     std_logic_vector (31 DOWNTO 0);  -- In A (32 x LVDS/ECL)
    B        : IN     std_logic_vector (31 DOWNTO 0);  -- In B (32 x LVDS/ECL)
    C        : OUT    std_logic_vector (31 DOWNTO 0);  -- Out C (32 x LVDS)
    D        : INOUT  std_logic_vector (31 DOWNTO 0);  -- In/Out D (I/O Expansion)
    E        : INOUT  std_logic_vector (31 DOWNTO 0);  -- In/Out E (I/O Expansion)
    F        : INOUT  std_logic_vector (31 DOWNTO 0);  -- In/Out F (I/O Expansion)
    GIN      : IN     std_logic_vector ( 1 DOWNTO 0);   -- In G - LEMO (2 x NIM/TTL)
    GOUT     : OUT    std_logic_vector ( 1 DOWNTO 0);   -- Out G - LEMO (2 x NIM/TTL)
    -- Port Output Enable (0=Output, 1=Input)
    nOED     : OUT    std_logic;                       -- Output Enable Port D (only for A395D)
    nOEE     : OUT    std_logic;                       -- Output Enable Port E (only for A395D)
    nOEF     : OUT    std_logic;                       -- Output Enable Port F (only for A395D)
    nOEG     : OUT    std_logic;                       -- Output Enable Port G
    -- Port Level Select (0=NIM, 1=TTL)
    SELD     : OUT    std_logic;                       -- Output Level Select Port D (only for A395D)
    SELE     : OUT    std_logic;                       -- Output Level Select Port E (only for A395D)
    SELF     : OUT    std_logic;                       -- Output Level Select Port F (only for A395D)
    SELG     : OUT    std_logic;                       -- Output Level Select Port G

    -- Expansion Mezzanine Identifier:
    -- 000 : A395A (32 x IN LVDS/ECL)
    -- 001 : A395B (32 x OUT LVDS)
    -- 010 : A395C (32 x OUT ECL)
    -- 011 : A395D (8  x IN/OUT NIM/TTL)
    IDD      : IN     std_logic_vector (2 DOWNTO 0);   -- Slot D
    IDE      : IN     std_logic_vector (2 DOWNTO 0);   -- Slot E
    IDF      : IN     std_logic_vector (2 DOWNTO 0);   -- Slot F

    -- Delay Lines
    -- 0:1 => PDL (Programmable Delay Line): Step = 0.25ns / FSR = 64ns
    -- 2:3 => FDL (Free Running Delay Line with fixed delay)
    PULSE    : IN     std_logic_vector (3 DOWNTO 0);   -- Output of the delay line (0:1 => PDL; 2:3 => FDL)
    nSTART   : OUT    std_logic_vector (3 DOWNTO 2);   -- Start of FDL (active low)
    START    : OUT    std_logic_vector (1 DOWNTO 0);   -- Input of PDL (active high)
    DDLY     : INOUT  std_logic_vector (7 DOWNTO 0);   -- R/W Data for the PDL
    WR_DLY0  : OUT    std_logic;                       -- Write signal for the PDL0
    WR_DLY1  : OUT    std_logic;                       -- Write signal for the PDL1
    DIRDDLY  : OUT    std_logic;                       -- Direction of PDL data (0 => Read Dip Switches)
                                                       --                       (1 => Write from FPGA)
    nOEDDLY0 : OUT    std_logic;                       -- Output Enable for PDL0 (active low)
    nOEDDLY1 : OUT    std_logic;                       -- Output Enable for PDL1 (active low)

    -- LED drivers
    nLEDG    : OUT    std_logic;                       -- Green (active low)
    nLEDR    : OUT    std_logic;                       -- Red (active low)

    -- Spare
    SPARE    : INOUT  std_logic_vector (11 DOWNTO 0);

    -- Local Bus in/out signals
    nLBRES     : IN     std_logic;
    nBLAST     : IN     std_logic;
    WnR        : IN     std_logic;
    nADS       : IN     std_logic;
    LCLK       : IN     std_logic;
    nREADY     : OUT    std_logic;
    nINT       : OUT    std_logic;
    LAD        : INOUT  std_logic_vector (15 DOWNTO 0)
  );
  
end HyperK_WCTE_V1495_top;


architecture rtl of HyperK_WCTE_V1495_top is

  signal REG_R  : reg_data(17 downto 0) := (others => (others => 'Z'));
  signal REG_RW : reg_data(17 downto 0) := (others => (others => 'Z'));

  signal wr_dly_cmd       : std_logic_vector( 1 downto 0) := (others => '0');
	
  signal counter : unsigned(63 downto 0);

begin

  REG_R(6)(3 downto 0)   <= conv_std_logic_vector(1, 4);  -- Firmware release
  REG_R(6)(7 downto 4)   <= conv_std_logic_vector(6, 4);  -- Demo number
  REG_R(6)(31 downto 8)  <= (others => '1');
  REG_R(1) <= x"DEADBEEF" when REG_RW(6) = x"CAFECAFE" else
              x"BEEFBEED";
  
  REG_R(2) <= x"BEEFCAFE";
  
  REG_R(a_counter) <= std_logic_vector(counter(55 downto 24));
  REG_R(4) <= std_logic_vector(counter(31 downto 0));
  
  proc_flipReg : process(LCLK)
  begin
    if rising_edge(LCLK) then
	   counter <= counter + 1;	 
	 end if;
  end process proc_flipReg;
  
  proc_onof : process(LCLK)
   variable onoff : std_logic := '0';
  begin
    if rising_edge(LCLK) then
		 if REG_RW(0)(0) = '0' then
		   onoff := '0';
		 else
		   onoff := not onoff;
		 end if;
		 GOUT(0) <= onoff;
		 GOUT(1) <= not onoff;  
    end if;
  end process proc_onof;
  


    instance_V1495_com: entity work.V1495_regs_communication 
      port map (
        -- Local Bus in/out signals
        nLBRES      => nLBRES,
        nBLAST      => nBLAST,   
        WnR         => WnR,      
        nADS        => nADS,     
        LCLK        => LCLK,     
        nREADY      => nREADY,   
        nINT        => nINT,     
        LAD         => LAD,
        WR_DLY_CMD  => WR_DLY_CMD,
        -- Internal Registers
        REG_R     => REG_R,
        REG_RW    => REG_RW
      );


end architecture rtl;
