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
use work.components.all;
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
  
  signal REG_R : reg_data(7 downto 0);
  signal REG_RW : reg_data(53 downto 0);
    
	-- Data Producer signals
  signal wr_dly_cmd       : std_logic_vector( 1 downto 0) := (others => '0');
  signal wr_dly           : std_logic_vector( 1 downto 0) := (others => '0');
  signal input_A_mask     : std_logic_vector(31 downto 0) := (others => 'Z');
  signal input_B_mask			: std_logic_vector(31 downto 0) := (others => 'Z');
  signal ctrlreg     		  : std_logic_vector(31 downto 0) := (others => 'Z');  
  signal D_Expan     			: std_logic_vector(31 downto 0) := (others => 'Z');
  
  signal counter : unsigned(63 downto 0);
  
  signal allData : std_logic_vector(95 downto 0);
  signal mask : std_logic_vector(95 downto 0);
  
  signal hits : std_logic_vector(95 downto 0);
  
  signal otherClk : std_logic;
  
  signal prepared_signals : std_logic_vector(95 downto 0);
    
  
begin

  mask <= REG_RW(D_MASK) & REG_RW(B_MASK) & REG_RW(A_MASK);
  
  
  blk_pre_logic : block
    attribute preserve_for_debug : boolean;

  
  
    signal delay_regs : reg_data(23 downto 0);
    signal gate_regs : reg_data(23 downto 0);
	 
    signal delays : t_slv_v8(96 downto 0);
    signal gates : t_slv_v8(96 downto 0);
	 
	 attribute preserve_for_debug of delay_regs : signal is true;
    attribute preserve_for_debug of delays : signal is true;

	 
  begin
  
  delay_regs <= REG_RW(29 downto 6);
  gate_regs  <= REG_RW(53 downto 30);
  
    gen_level_1 : for i in 23 downto 0 generate  
      delays(4*i) <= delay_regs(i)(7 downto 0);
	   delays(4*i+1) <= delay_regs(i)(15 downto 8);
      delays(4*i+2) <= delay_regs(i)(23 downto 16);
      delays(4*i+3) <= delay_regs(i)(31 downto 24);
		
      gates(4*i) <= gate_regs(i)(7 downto 0);
	   gates(4*i+1) <= gate_regs(i)(15 downto 8);
      gates(4*i+2) <= gate_regs(i)(23 downto 16);
      gates(4*i+3) <= gate_regs(i)(31 downto 24);
    end generate; 
	 
	gen_pre_logic : for i in 95 downto 0 generate
	
	  inst_pre_logic : pre_logic 
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
  
      
  
  -- Port Output Enable (0=Output, 1=Input)
  nOED  <=  '1';    -- Output Enable Port D (only for A395D)
  nOEG  <=  '0';    -- Output Enable Port G
  D     <=  D_Expan	when IDD = "011"  else (others => 'Z');
  
  
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
  
  
  proc_data_pipeline : process(otherClk)
  begin
    if rising_edge(otherClk) then
	   allData <= D & B & A;
	 end if;
  end process proc_data_pipeline;
  
  
  
  
  inst_logic : logic_unit
 port map(
	clk => otherClk,
	reset => nLBRES,
	data_in => prepared_signals,
	mask => mask,
	type_i => '1',
	maskedData => open,
	result => open
 );
  
  
  
  
  
  
  
  
  
  	inst_regs :  V1495_regs_communication
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
  
  
  
--  blk_CDC : block
--    signal data_in : std_logic_vector(15 downto 0);
--    signal data_out : std_logic_vector(15 downto 0);
--	 signal wrreq_sig : std_logic;
--	 signal rdreq_sig : std_logic;
--	 signal wrfull_sig : std_logic;
--	 signal rdempty_sig : std_logic;
--  begin
--  
--  proc_pre_pipe : process(lclk)
--	  begin	  
--	    if rising_edge(lclk) then 
--		   data_in <=  & ;
--		 end if;
--	  end process proc_pre_pipe;
--  
--  CDC_fifo_inst : CDC_fifo PORT MAP (
--                data     => data_in,
--                rdclk    => otherClk,
--                rdreq    => rdreq_sig,
--					 
--                wrclk    => LCLK,
--                wrreq    => wrreq_sig,
--                q        => data_out,
--					 
--                rdempty  => rdempty_sig,
--                wrfull   => wrfull_sig
--        );
--		  
--	  wrreq_sig <= not wrfull_sig;
--	  rdreq_sig <= not rdempty_sig;
--		  
--	  proc_pipe : process(otherClk)
--	  begin	  
--	    if rising_edge(otherClk) then 
--		   gate <= data_out(7 downto 0);		  
--	      delay <= data_out(15 downto 8);		 
--		 end if;
--	  end process proc_pipe;
--  
--  end block blk_CDC;
  
  
  
  

  
  
  
--  inst_logic : logic_operator
--  port map(
--	clk => otherClk,
--	reset => not nLBRES,
--	a_gate_width => REG_RW(a_gate_width),
--	channel_mask => mask,
--	data_in => allData,
--	operation => '0',
--	result => hits
--  );
-- 
--	gen_many_logic : for i in 2500 downto 0 generate
--	  signal hit_s : std_logic_vector(95 downto 0);
--	begin
--	  inst_logic : logic_operator
--     port map(
--	    clk => otherClk,
--	    reset => not nLBRES,
--    	a_gate_width => REG_RW(a_gate_width),
--	    channel_mask => mask,
--	    data_in => allData,
--	    operation => '0',
--	    result => hit_s
--    );
--	
--	end generate gen_many_logic;


 
  --GOUT(1) <= A(0);  
  
--  
--    instance_gdgen: gdgen
--    port map(
--      lclk     			=> lclk,
--      GIN(0)           => not nLBRES,
--		GIN(1) => A(0),
--      ctrlreg       => ctrlreg,
--      pulse         => pulse,
--      wr_dly_cmd    => wr_dly_cmd,
--      wr_dly        => wr_dly,
--      ddly          => DDLY,
--      start	        => START,
--      nstart	      => nSTART,
--      out_pgdl	    => open,
--      out_fgdl	    => open,
--      delay_pdl     => x"10", --REG_RW(6)(7 downto 0),
--      gate_pdl      => x"ff", --REG_RW(7)(7 downto 0),
--      delay_fdl     => X"00000040",--REG_RW(4),
--      gate_fdl      =>  X"00000001"--REG_RW(5)
--    );
--    
	 
	inst_pll : ALTERA_CMN_PLL
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
  
  GOUT(0) <= lclk;
  GOUT(1) <= otherClk;
  
  
 
  -- REG_R6  -->  |    ------ 24 bit ------   --4bit--4bit-|       
  -- REG_R6  -->  | ... obligatory '0'  ...    |  0  |  0  |
  REG_R(VERSION)(3 downto 0)   <= conv_std_logic_vector(1, 4);  -- Firmware release
  REG_R(VERSION)(7 downto 4)   <= conv_std_logic_vector(7, 4);  -- Demo number
  REG_R(VERSION)(31 downto 8)  <= (others => '0');
  
  REG_R(5) <= x"DEADBEEF";
  
--  proc_reg_switch : process(LCLK)
--  begin
--    if rising_edge(LCLK) then
--      if REG_RW(6) = x"CAFECAFE" then
--        REG_R(1) <= x"DEADBEEF";
--      else
--        REG_R(1) <= x"BEEFBEEF";
--      end if;
--    end if;
--  end process proc_reg_switch;
   
  
  
--  proc_onof : process(LCLK)
--   variable onoff : std_logic := '0';
--  begin
--    if rising_edge(LCLK) then
--      if REG_RW(0)(0) = '0' then
--        onoff := '0';
--      else
--        onoff := not onoff;
--      end if;
--      GOUT(0) <= onoff;
--      GOUT(1) <= not onoff;  
--    end if;
--	 
--  end process proc_onof;
--  
  
--  proc_flipReg : process(LCLK)
--  begin
--    if rising_edge(LCLK) then
--      counter <= counter + 1;
--      REG_R(a_counter) <= std_logic_vector(counter(55 downto 24));
--		REG_R(4) <= std_logic_vector(counter(31 downto 0));    
--    end if;
--  end process proc_flipReg;
--
--  
  
  
  
 
end rtl;
   
