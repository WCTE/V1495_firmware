-- ========================================================================
-- ****************************************************************************
-- Company:         CAEN SpA - Viareggio - Italy
-- Model:           V1495 -  Multipurpose Programmable Trigger Unit
-- FPGA Proj. Name: v1495scaler
-- Device:          ALTERA EP1C4F400C6
-- Author:          Carlo Tintori
-- Date:            May 26th, 2010
-- ----------------------------------------------------------------------------
-- Module:          V1495_Demo4
-- Description:     Top design
-- ****************************************************************************

-- ############################################################################
-- Revision History:
-- ############################################################################


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
    C        : OUT     std_logic_vector (31 DOWNTO 0);  -- In C (32 x LVDS/ECL)
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

END HyperK_WCTE_V1495_top ;


architecture rtl of HyperK_WCTE_V1495_top is

  --------------------------
  ------- SIGNALS ----------
  --------------------------
  
  signal REG_R : reg_data(numRregs - 1 downto 0);
  signal REG_RW : reg_data(numRWregs - 1 downto 0);
    
	-- Data Producer signals
  signal wr_dly_cmd       : std_logic_vector( 1 downto 0) := (others => '0');
  signal wr_dly           : std_logic_vector( 1 downto 0) := (others => '0');
  signal input_A_mask     : std_logic_vector(31 downto 0) := (others => 'Z');
  signal input_B_mask			: std_logic_vector(31 downto 0) := (others => 'Z');
  signal ctrlreg     		  : std_logic_vector(31 downto 0) := (others => 'Z');  
  signal D_Expan     			: std_logic_vector(31 downto 0) := (others => 'Z');
  signal F_Expan     			: std_logic_vector(31 downto 0) := (others => 'Z');
  
  signal counter : unsigned(63 downto 0);
  
  signal allData : std_logic_vector(31 downto 0);
  
  signal otherClk : std_logic;
  
  signal prepared_signals : std_logic_vector(31 downto 0);
  
  signal level1_result : std_logic_vector(9 downto 0);
    
  
begin

  -- firmware version
  REG_R(AR_VERSION)(3 downto 0)   <= conv_std_logic_vector(1, 4);  -- Firmware release
  REG_R(AR_VERSION)(7 downto 4)   <= conv_std_logic_vector(0, 4);  -- Demo number
 
  
  -- Register interface
  inst_regs : entity work.V1495_regs_communication
      generic map(
		   N_R_REGS => numRregs,
		   N_RW_REGS => numRWregs			
		)
		port map(
		  -- Local Bus in/out signals
		  nLBRES     => nLBRES,
		  nBLAST     => nBLAST,
		  WnR        => WnR,
		  nADS       => nADS,
		  LCLK       => LCLK,
		  nREADY     => nREADY,
		  nINT       => nINT,
		  LAD        => LAD,
		  wr_dly_cmd => wr_dly_cmd,
		  
		  REG_R  => REG_R,
		  REG_RW => REG_RW
		);
  
  
  
  -- Pre logic treatment  
  blk_pre_logic : block
    signal delay_regs : reg_data(7 downto 0);
    signal gate_regs : reg_data(7 downto 0);
	 
    signal delays : t_slv_v8(31 downto 0);
    signal gates : t_slv_v8(31 downto 0);
	 
  begin
  
  
  gen_range : for i in ARW_RANGE_DELAY_PRE'range generate
    proc_data_pipeline : process(otherClk)
    begin
      if rising_edge(otherClk) then	
          delay_regs(i) <= REG_RW(ARW_RANGE_DELAY_PRE(i));
	   end if;
    end process proc_data_pipeline;
  
  end generate gen_range;
  
  
  gen_gate : for i in ARW_RANGE_GATE_PRE'range generate
  
    proc_data_pipeline : process(otherClk)
    begin
      if rising_edge(otherClk) then
			 gate_regs(i)  <= REG_RW(ARW_RANGE_GATE_PRE(i));
	   end if;
    end process proc_data_pipeline;
	 
  end generate gen_gate;
  

  
  
    gen_level_1 : for i in 7 downto 0 generate 	 
      delays(4*i) <= delay_regs(i)(7 downto 0);
	   delays(4*i+1) <= delay_regs(i)(15 downto 8);
      delays(4*i+2) <= delay_regs(i)(23 downto 16);
      delays(4*i+3) <= delay_regs(i)(31 downto 24);
		
      gates(4*i) <= gate_regs(i)(7 downto 0);
	   gates(4*i+1) <= gate_regs(i)(15 downto 8);
      gates(4*i+2) <= gate_regs(i)(23 downto 16);
      gates(4*i+3) <= gate_regs(i)(31 downto 24);
    end generate; 

   	
 
	gen_pre_logic : for i in 31 downto 0 generate
	
	
	  inst_pre_logic : entity work.pre_logic 
       port map(
	    clk => otherClk,
	    reset => not nLBRES,
	    data_in => allData(i),
	    delay => delays(i),
	    gate  => gates(i),
       data_out => prepared_signals(i)
       );
	end generate; 
	 
  
  end block blk_pre_logic;
  
  --Output prepared signals
  F_Expan(16) <= A(0);
  F_Expan(1) <= prepared_signals(0);
  
  F_Expan(17) <= A(1);
  F_Expan(12) <= prepared_signals(1);

  F_Expan(28) <= A(2);
  F_Expan(13) <= prepared_signals(2);
  
  proc_data_pipeline : process(otherClk)
  begin
    if rising_edge(otherClk) then
	   allData <= A;
	 end if;
  end process proc_data_pipeline;
  
  
  
  -- Level 1 logic
  gen_logic_level_1 : for i in 0 downto 0 generate
    signal mask : std_logic_vector(31 downto 0);
	 signal result : std_logic;
    signal l_type : std_logic;
  begin
    
	 proc_data_pipeline : process(otherClk)
    begin
      if rising_edge(otherClk) then
        mask <= REG_RW(ARW_AMASK);
		  l_type <= REG_RW(ARW_LOGIC_TYPE)(i);
	   end if;
	 end process proc_data_pipeline;
  
    inst_logic : entity work.logic_unit
	 generic map(
	   bus_width => 32
	 )
    port map(
	   clk => otherClk,
	   reset => not nLBRES,
	   data_in => prepared_signals,
	   mask => mask,
	   type_i => l_type,
	   result => result
    );
	 
	 inst_counter : entity work.counter
    port map(
      clk => otherClk,
	   reset => not nLBRES,
	   count_en => '1',
	   data_in => result,
	   count_out => REG_R(AR_LVL1_COUNTERS)  --pipeline this
    );	 
	 
	 level1_result(i) <= result;
	 
	 -- need three registers for each of the delay and gate.
	 
	 
--	 inst_level1_treatment : entity work.pre_logic 
--       port map(
--	    clk => otherClk,
--	    reset => not nLBRES,
--	    data_in => level1_result(i),
--	    delay => delays(i),
--	    gate  => gates(i),
--       data_out => level1_result(i)
--       );
	 
 
  end generate gen_logic_level_1;
  
  -- output coincidence result
  F_Expan(0) <= level1_result(0);
  
  SELF <= '0';
  nOEF <= '0';

  
   inst_pll : entity work.ALTERA_CMN_PLL
     generic map(
     clk0_divide_by      => 8,
     clk0_duty_cycle     => 50,
     clk0_multiply_by    => 25,
     inclk0_input_frequency  => 25000  --actually period in us.
   )
   port map (
     areset     => not nLBRES,
     clk_in     => lclk,
     clk_out_0  => otherClk,
     locked     => open
   );

  
  

   -- Port Output Enable (0=Output, 1=Input)
  nOED  <=  '1';    -- Output Enable Port D (only for A395D)
  nOEG  <=  '0';    -- Output Enable Port G
  D     <=  D_Expan	when IDD = "011"  else (others => 'Z');
  F     <=  F_Expan	when IDF = "011"  else (others => 'Z');
  
  
  nOEDDLY0  <=  '0';  -- Output Enable for PDL0 (active low)
  nOEDDLY1  <=  '0';  -- Output Enable for PDL1 (active low)
  
  -- Port Level Select (0=NIM, 1=TTL)
  SELD      <=  ctrlreg(0);    -- Output Level Select Port D (only for A395D)
  SELG      <=  ctrlreg(1);    -- Output Level Select Port G

  DIRDDLY   <=  ctrlreg(4);  -- Direction of PDL data (0 => Read Dip Switches)
                              --                       (1 => Write from FPGA)                           
  WR_DLY0   <=  wr_dly(0);
  WR_DLY1   <=  wr_dly(1);
  
  ctrlreg	  <= X"00000013";--REG_RW(3);

 

  
  
  
 
end rtl;
   
