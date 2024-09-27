-- ========================================================================
-- ****************************************************************************
-- Company:         CAEN SpA - Viareggio - Italy
-- Model:           V1495 -  Multipurpose Programmable Trigger Unit
-- FPGA Proj. Name: v1495scaler
-- Device:          ALTERA EP1C4F400C6
-- Author:          Carlo Tintori
-- Date:            May 26th, 20
-- ----------------------------------------------------------------------------
-- Module:          V1495_Demo4
-- Description:     Top design
-- ****************************************************************************

-- ############################################################################
-- Revision History:
-- ############################################################################


library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.std_Logic_unsigned.all;
use work.V1495_regs.all;
use work.functions.all;


entity HyperK_WCTE_V1495_top is
  port(
    -- Front Panel Ports
    A        : IN     std_logic_vector (31 DOWNTO 0);  -- In A (32 x LVDS/ECL)
    B        : IN     std_logic_vector (31 DOWNTO 0);  -- In B (32 x LVDS/ECL)
    D        : INOUT  std_logic_vector (31 DOWNTO 0);  -- In/Out D (I/O Expansion)
    E        : INOUT  std_logic_vector (31 DOWNTO 0);  -- In/Out E (I/O Expansion)
    F        : INOUT  std_logic_vector (31 DOWNTO 0);  -- In/Out F (I/O Expansion)
    GIN      : IN     std_logic_vector ( 1 DOWNTO 0);   -- In G - LEMO (2 x NIM/TTL)
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

    -- Local Bus in/out signals
    nLBRES     : IN     std_logic;
    nBLAST     : IN     std_logic;
    WnR        : IN     std_logic;
    nADS       : IN     std_logic;
    LCLK       : IN     std_logic;
    nREADY     : OUT    std_logic;
    --nINT       : OUT    std_logic;
    LAD        : INOUT  std_logic_vector (15 DOWNTO 0)
  );

END HyperK_WCTE_V1495_top ;


architecture rtl of HyperK_WCTE_V1495_top is

  --------------------------
  ------ CONSTANTS ---------
  --------------------------

  constant useExternalClk : boolean := true;
                                       
  -- Number of input channels used for logic
  constant N_LOGIC_CHANNELS : integer := A'length + B'length;
  -- Number of level 1 logic units
  constant N_LEVEL1 : integer := 10;
  -- Number of level 2 logic units
  constant N_LEVEL2 : integer := 4;
  
  -- Width of counters for A & B channels
  constant COUNT_WIDTH_INPUTS_AB : integer := 24;
  
  -- Width of counters for D channels
  constant COUNT_WIDTH_INPUTS_D : integer := 24;
  
  -- Width of channels for level 1 & 2 output
  constant COUNT_WIDTH_LOGIC : integer := 24;

  --------------------------
  ------- SIGNALS ----------
  --------------------------
  
  -- Registers
  signal REG_R : reg_data(numRregs-1 downto 0);
  signal REG_RW : reg_data(numRWregs-1 downto 0);
    
  -- Data Producer signals
  signal input_A_mask     : std_logic_vector(31 downto 0) := (others => 'Z');
  signal input_B_mask     : std_logic_vector(31 downto 0) := (others => 'Z');
  signal D_Expan          : std_logic_vector(31 downto 0) := (others => 'Z');
  signal F_Expan          : std_logic_vector(31 downto 0) := (others => 'Z');
  signal E_Expan          : std_logic_vector(31 downto 0) := (others => 'Z');

  -- Raw data for logic elements   
  signal allData : std_logic_vector(N_LOGIC_CHANNELS-1 downto 0);
  signal allData_dly1 : std_logic_vector(N_LOGIC_CHANNELS-1 downto 0);
  signal allData_dly2 : std_logic_vector(N_LOGIC_CHANNELS-1 downto 0);
    
  -- 125MHz clock derived from GIN(0)
  signal clk_125 : std_logic;
  
  -- Channel A & B data after pre-logic treatment
  signal prepared_signals : std_logic_vector(N_LOGIC_CHANNELS-1 downto 0);
  -- Channel A & B delayed by 1 clock tick to match timing of L1 output
  signal prepared_signals_dly_1 : std_logic_vector(N_LOGIC_CHANNELS-1 downto 0);
  -- Channel A & B delayed by 2 clock ticks to match timing of L1 output
  signal prepared_signals_dly_2 : std_logic_vector(N_LOGIC_CHANNELS-1 downto 0);
  -- Level 1 logic outputs after pre-logic treatment
  signal prepared_signals_l1 : std_logic_vector(N_LEVEL1-1 downto 0);
  -- Level 1 logic outputs delayed by 1 clock tick to match timing of L2 output
  signal prepared_signals_l1_dly1: std_logic_vector(N_LEVEL1-1 downto 0);
  
  -- Results of level 1 logic units
  signal level1_result : std_logic_vector(N_LEVEL1-1 downto 0);
  signal level1_result_dly : std_logic_vector(N_LEVEL1-1 downto 0);
  -- Input to level 2 logic
  signal level2_input  : std_logic_vector(N_LOGIC_CHANNELS+N_LEVEL1-1 downto 0);
  
  -- Level 2 logic results
  signal level2_result : std_logic_vector(N_LEVEL2-1 downto 0);
  -- Level 2 logic results, leading edge only
  signal level2_result_edge : std_logic_vector(N_LEVEL2-1 downto 0);
  
  -- Most recently requested address
  signal ADDR_W : std_logic_vector(11 downto 0);  
  
  -- Reset based on R/W of specific register
  signal reset_reg : std_logic;
  signal reset_reg_s : std_logic;
  -- Reset from nLBRES, moved to clk_125 domain
  signal reset_startup : std_logic;
  -- Reset in clk_125 domain
  signal reset_125 : std_logic;
  
  -- Between spills veto
  signal spill_veto : std_logic;  
  
  
begin

  -- generate a reset when a specific register is accessed
  proc_reset : process (clk_125)
  begin
    if rising_edge(clk_125) then
	   if ADDR_W(11) = '1' and to_integer(unsigned(ADDR_W(10 downto 0))) = ARW_RESET then
        reset_reg_s <= '1';
      else
        reset_reg_s <= '0';
      end if;
    end if;
  end process;
  
	   inst_dly_reg_rst: entity work.delay_chain
     generic map (
       W_WIDTH  => 1,
       D_DEPTH   => 2
     )
     port map (
       clk       => clk_125,
       en_i      => '1',
       sig_i(0)     => reset_reg_s,
       sig_o(0)     => reset_reg
     );
  
  	 inst_dly_LBRES_rst: entity work.delay_chain
     generic map (
       W_WIDTH  => 1,
       D_DEPTH   => 2
     )
     port map (
       clk       => clk_125,
       en_i      => '1',
       sig_i(0)     => not nLBRES,
       sig_o(0)     => reset_startup
     );
  
			 
  reset_125 <= reset_startup or reset_reg;  
      
  -- firmware version
  REG_R(AR_VERSION)(3 downto 0)   <= x"2";  -- Firmware release
  REG_R(AR_VERSION)(7 downto 4)   <= x"0";  -- Demo number

  REG_R(AR_GIT) <= GIT_SHA;
  
  -- Register interface
  inst_regs : entity work.V1495_regs_communication
  generic map(
    N_R_REGS => numRregs,
    N_RW_REGS => numRWregs      
  )
  port map(
    clk_data => clk_125,
    -- Local Bus in/out signals
    nLBRES     => nLBRES,
    nBLAST     => nBLAST,
    WnR        => WnR,
    nADS       => nADS,
    LCLK       => LCLK,
    nREADY     => nREADY,
    --nINT       => nINT,
    LAD        => LAD,
    
    ADDR_W => ADDR_W,      
    
    REG_R  => REG_R,
    REG_RW => REG_RW
  );

  --PRE-LOGIC-TREATMENT---------------------------------------------------
    
  blk_raw_counters : block
  begin
   		
    -- Generate counters for A channels		
    gen_a_counters : for i in A'range generate
      signal count : std_logic_vector(COUNT_WIDTH_INPUTS_AB-1 downto 0);
      --signal count_dly : std_logic_vector(COUNT_WIDTH_INPUTS_AB-1 downto 0);
    begin
      inst_counter : entity work.counter
      generic map(
        count_width => COUNT_WIDTH_INPUTS_AB
      )
      port map(
        reset => reset_125,
        count_en => not spill_veto,
        data_in => A(i),
        count_out => count  
      );
      -- Write count to a register      
		REG_R(AR_ACOUNTERS(i)) <= (31 downto COUNT_WIDTH_INPUTS_AB => '0') & count;
    end generate gen_a_counters;
	
    -- Generate counters for B channels	
    gen_b_counters : for i in B'range generate
      signal count : std_logic_vector(COUNT_WIDTH_INPUTS_AB-1 downto 0);
    begin
      inst_counter : entity work.counter
      generic map(
        count_width => COUNT_WIDTH_INPUTS_AB
      )
      port map(
        reset => reset_125,
        count_en => not spill_veto,
        data_in => B(i),
        count_out => count  
      );    
      -- Write count to a register  
      REG_R(AR_BCOUNTERS(i)) <= (31 downto COUNT_WIDTH_INPUTS_AB => '0') & count;
    end generate gen_b_counters;
	 
    -- Generate counters for D channels	
    gen_d_counters : for i in D'range generate
      signal count : std_logic_vector(COUNT_WIDTH_INPUTS_D-1 downto 0);
    begin
      inst_counter : entity work.counter
      generic map(
        count_width => COUNT_WIDTH_INPUTS_D
      )
      port map(
        reset => reset_125,
        count_en => not spill_veto,
        data_in => D(i),
        count_out => count  --pipeline this
      );   
      -- Write count to a register   
      REG_R(AR_DCOUNTERS(i)) <= (31 downto COUNT_WIDTH_INPUTS_D => '0') & count;
    end generate gen_d_counters;
	   
  end block blk_raw_counters;
   
  -- Move A & B data to clk_125 domain
  inst_dly_all: entity work.delay_chain
  generic map (
    W_WIDTH  => 64,
    D_DEPTH   => 1  
  )
  port map (
    clk       => clk_125,
    en_i      => '1',
    sig_i     => B & A,
    sig_o     => allData
  );
	  
 
  -- Pre logic treatment of raw inputs
  blk_pre_logic : block
    signal delay_regs : reg_data(15 downto 0);
    signal gate_regs : reg_data(15 downto 0); 
   
  begin
    
    -- convert 32-bit delay registers into 8-bit delay values
    gen_range : for i in ARW_DELAY_PRE'range generate
      delay_regs(i) <= REG_RW(ARW_DELAY_PRE(i));
    end generate gen_range;
  
    -- convert 32-bit gate registers into 8-bit gate values
    gen_gate : for i in ARW_GATE_PRE'range generate
      gate_regs(i)  <= REG_RW(ARW_GATE_PRE(i));
    end generate gen_gate;  
  
    inst_pre_logic: entity work.pre_logic_treatment
    generic map(
      n_channels => N_LOGIC_CHANNELS
    )
    port map (
      clk => clk_125,
      reset => reset_125,
      delay_regs => delay_regs,
      gate_regs => gate_regs,
      data_in => allData,
      prepared_signals => prepared_signals
    );
  
  end block blk_pre_logic; 
        
  
  --LEVEL-1-LOGIC---------------------------------------------------
  
  -- Level 1 logic
  gen_logic_level_1 : for i in N_LEVEL1-1 downto 0 generate
    signal count : std_logic_vector(COUNT_WIDTH_LOGIC-1 downto 0);
  begin
    -- Level 1 logic unit
    inst_l1_logic : entity work.level1_logic
    generic map (
      N_CHANNELS => N_LOGIC_CHANNELS,
      COUNTER_WIDTH => COUNT_WIDTH_LOGIC
    )
    port map(
      clk => clk_125,
      reset =>reset_125,
      mask => REG_RW(ARW_BMASK_L1(i)) & REG_RW(ARW_AMASK_L1(i)),
      data_in => prepared_signals,
      logic_type => REG_RW(ARW_LOGIC_TYPE)(i),
      prescale => REG_RW(ARW_POST_L1_PRESCALE(i))(7 downto 0),
      invert => REG_RW(ARW_BINV_L1(i)) & REG_RW(ARW_AINV_L1(i)),
      count_en_i => not spill_veto,    
		
      result => level1_result(i),
      count =>count     
    );
  
    -- Write the count to a register
    REG_R(AR_LVL1_COUNTERS(i)) <= (31 downto COUNT_WIDTH_LOGIC => '0')&count;
 
  end generate gen_logic_level_1;
    
  
  -- Pre logic treatment of level1 outputs
  blk_pre_logic_level1 : block
    signal delay_regs : reg_data(2 downto 0);
    signal gate_regs : reg_data(2 downto 0); 
   
  begin
    -- convert 32-bit delay registers into 8-bit delay values
    gen_range : for i in ARW_DELAY_LEVEL1'range generate
      delay_regs(i) <= REG_RW(ARW_DELAY_LEVEL1(i));
    end generate gen_range;

    -- convert 32-bit gate registers into 8-bit gate values
    gen_gate : for i in ARW_GATE_LEVEL1'range generate
      gate_regs(i)  <= REG_RW(ARW_GATE_LEVEL1(i));
    end generate gen_gate;  
	 
	  
    inst_pre_logic: entity work. pre_logic_treatment
    generic map(
      n_channels => N_LEVEL1
    )
    port map (
      clk => clk_125,
      reset => reset_125,
      delay_regs => delay_regs(div_ceil(N_LEVEL1,4)-1 downto 0),
      gate_regs => gate_regs(div_ceil(N_LEVEL1,4)-1 downto 0),
      data_in => level1_result,
      prepared_signals => prepared_signals_l1
    );
	 
  
  end block blk_pre_logic_level1;
  
  level2_input <= prepared_signals_l1 & prepared_signals_dly_1;

  gen_logic_level_2 : for i in N_LEVEL2-1 downto 0 generate
    signal result : std_logic;
    signal count : std_logic_vector(COUNT_WIDTH_LOGIC-1 downto 0);
    signal in_dly : std_logic;
    
  begin  
  
    -- level 2 logic unit
    inst_l2_logic : entity work.level2_logic
    generic map(
      N_CHANNELS => N_LEVEL1+N_LOGIC_CHANNELS,
      COUNTER_WIDTH => COUNT_WIDTH_LOGIC
    )
    port map(
      clk => clk_125,
      reset => reset_125,
      mask => REG_RW(ARW_L1MASK_L2(i))(N_LEVEL1-1 downto 0) & REG_RW(ARW_BMASK_L2(i)) & REG_RW(ARW_AMASK_L2(i)),
      data_in => level2_input,
      logic_type => REG_RW(ARW_LOGIC_TYPE)(i + N_LEVEL1),
      invert => REG_RW(ARW_L1INV_L2(i))(N_LEVEL1 -1  downto 0) & REG_RW(ARW_BINV_L2(i)) & REG_RW(ARW_AINV_L2(i)),
      count_en_i => not spill_veto,
      
      result => result,
      count => count
    ); 
 	 
    -- Write the count to a register
    REG_R(AR_LVL2_COUNTERS(i))   <= (31 downto COUNT_WIDTH_LOGIC => '0')&count;

    level2_result(i) <= result;
	 
    proc_edge_detect : process(clk_125)
    begin
      if rising_edge(clk_125) then
        if reset_125 = '1' then
          in_dly <= '0';
        else
          in_dly <= result;
        end if;
      end if;
    end process;

   level2_result_edge(i) <= not in_dly and result;
	   
  end generate gen_logic_level_2;

  
  -- 125 MHz clock generation
  gen_pll : if useExternalClk generate  
    ------------------------------------------------
    -- PLL to generate 125 MHz clock from 62.5 MHz input on GIN(0)
    inst_pll : entity work.ALTERA_CMN_PLL
    generic map(
      clk0_divide_by      => 1,
      clk0_duty_cycle     => 50,
      clk0_multiply_by    => 2,
      inclk0_input_frequency  => 16000  --actually period in us.
    )
    port map (
      areset     => not nLBRES,
      clk_in     => gin(0),
      clk_out_0  => clk_125,
      locked     => open
    );
  else generate
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
      clk_out_0  => clk_125,
      locked     => open
    );
  end generate;
  
  blk_dly : block
  begin
    inst_dly_all_out: entity work.delay_chain
    generic map (
      W_WIDTH  => 64,
      D_DEPTH   => 3  
    )
    port map (
      clk       => clk_125,
      en_i      => '1',
      sig_i     => allData,
      sig_o     => allData_dly1
    );
	      
    inst_dly_all_prep: entity work.delay_chain
    generic map (
      W_WIDTH  => 64,
      D_DEPTH   => 3  
    )
    port map (
      clk       => clk_125,
      en_i      => '1',
      sig_i     => prepared_signals,
      sig_o     => prepared_signals_dly_1
    ); 
	  
    inst_dly_all_out2: entity work.delay_chain
    generic map (
      W_WIDTH  => 64,
      D_DEPTH   => 2
    )
    port map (
      clk       => clk_125,
      en_i      => '1',
      sig_i     => allData_dly1,
      sig_o     => allData_dly2
    );
	      
    inst_dly_all_prep2: entity work.delay_chain
    generic map (
      W_WIDTH  => 64,
      D_DEPTH   => 2  
    )
    port map (
      clk       => clk_125,
      en_i      => '1',
      sig_i     => prepared_signals_dly_1,
      sig_o     => prepared_signals_dly_2
    ); 
  
    inst_dly_l1: entity work.delay_chain
    generic map (
      W_WIDTH  => 10,
      D_DEPTH   => 2  
    )
    port map (
      clk       => clk_125,
      en_i      => '1',
      sig_i     => prepared_signals_l1,
      sig_o     => prepared_signals_l1_dly1
    ); 
  
  
    inst_dly_l1_r: entity work.delay_chain
    generic map (
      W_WIDTH  => 10,
      D_DEPTH   => 2  
    )
    port map (
      clk       => clk_125,
      en_i      => '1',
      sig_i     => level1_result,
      sig_o     => level1_result_dly
    ); 
  end block blk_dly;	  

  
  -- Lemo output on ports E&F
  blk_lemo_output : block
    -- Mapping of A395D ports to lemo ports (from V1495 manual)
    constant A395D_Mapping : t_int_v(0 to 7) := (0, 16, 1, 17,  12, 28, 13, 29);
    signal lemo_out : std_logic_vector(15 downto 0);
    signal deadTime : std_logic;
  begin
   
    -- Set the output of the lemo connectors to signals based on register settings
    inst_lemo : entity work.lemo_output
      generic map(
        n_channels =>  N_LEVEL2+N_LEVEL1+32+N_LOGIC_CHANNELS,
        n_outputs => 16
      )
      port map (
        clk => clk_125,
        reset => reset_125,
        raw_in =>  level2_result &             level1_result_dly &           D & allData_dly2,       
        prep_in => level2_result_edge & prepared_signals_l1_dly1 & x"00000000" & prepared_signals_dly_2,  
        regs_in(0) => REG_RW(ARW_F(0)),
        regs_in(1) => REG_RW(ARW_F(1)),
        regs_in(2) => REG_RW(ARW_F(2)),
        regs_in(3) => REG_RW(ARW_F(3)),
        regs_in(4) => REG_RW(ARW_F(4)),
        regs_in(5) => REG_RW(ARW_F(5)),
        regs_in(6) => REG_RW(ARW_F(6)),
        regs_in(7) => REG_RW(ARW_F(7)),
		  
		  
        regs_in(8) => REG_RW(ARW_E(0)),
        regs_in(9) => REG_RW(ARW_E(1)),
        regs_in(10) => REG_RW(ARW_E(2)),
        regs_in(11) => REG_RW(ARW_E(3)),
        regs_in(12) => REG_RW(ARW_E(4)),
        regs_in(13) => REG_RW(ARW_E(5)),
        regs_in(14) => REG_RW(ARW_E(6)),
        regs_in(15) => REG_RW(ARW_E(7)),
        data_out => lemo_out
      );
 
    -- Map outputs of lemo_output to the actuall lemo connectors
--    gen_lemo_out : for i in 7 downto 1 generate
--      F_Expan(A395D_Mapping(i)) <= lemo_out(i); 
--      E_Expan(A395D_Mapping(i)) <= lemo_out(i+8); 	
--    end generate;
--    E_Expan(A395D_Mapping(0)) <= lemo_out(8);
	 
    -- Generate deadtime after trigger on lemo #0
    inst_deadtime : entity work.trigger_deadtime
    port map(
      clk => clk_125,
      reset => reset_125,
      data_in => lemo_out(0),
      data_out => deadTime,
      deadtime_width => REG_RW(ARW_DEADTIME)
    );


    --F_Expan(A395D_Mapping(0)) <= lemo_out(0) when deadtime='0' else
    --                             '0';
    
    proc_lemo0 : process(clk_125)
    begin
      if rising_edge(clk_125) then
        if deadtime = '0' and spill_veto = '0' then
          F_Expan(A395D_Mapping(0)) <= lemo_out(0);
        else 
          F_Expan(A395D_Mapping(0)) <= '0';
        end if;
		  F_Expan(A395D_Mapping(1)) <= lemo_out(1); 
		  F_Expan(A395D_Mapping(2)) <= lemo_out(2); 
		  F_Expan(A395D_Mapping(3)) <= lemo_out(3); 
		  F_Expan(A395D_Mapping(4)) <= lemo_out(4); 
		  F_Expan(A395D_Mapping(5)) <= lemo_out(5); 
		  F_Expan(A395D_Mapping(6)) <= lemo_out(6); 
		  F_Expan(A395D_Mapping(7)) <= lemo_out(7); 
		  
		  E_Expan(A395D_Mapping(0)) <= lemo_out(8); 
		  E_Expan(A395D_Mapping(1)) <= lemo_out(9); 
		  E_Expan(A395D_Mapping(2)) <= lemo_out(10); 
		  E_Expan(A395D_Mapping(3)) <= lemo_out(11); 
		  E_Expan(A395D_Mapping(4)) <= lemo_out(12); 
		  E_Expan(A395D_Mapping(5)) <= lemo_out(13); 
		  E_Expan(A395D_Mapping(6)) <= lemo_out(14); 
		  E_Expan(A395D_Mapping(7)) <= lemo_out(15); 
		  
      end if;
    end process proc_lemo0;
    
								
  end block blk_lemo_output;
  
  -- Generate veto based on a start signal and an end signal
  blk_spill_veto : block
    signal end_of_spill : std_logic;
    signal pre_spill : std_logic;	 
	 signal spill_veto_enable :std_logic;
	 
	 signal tmp_veto : std_logic;
  begin
    pre_spill <= allData(to_integer(unsigned(REG_RW(ARW_SPILL)(7 downto 0))));
    end_of_spill <= allData(to_integer(unsigned(REG_RW(ARW_SPILL)(15 downto 8))));
    spill_veto_enable <= REG_RW(ARW_SPILL)(16);
	 
	 spill_veto <= tmp_veto or REG_RW(ARW_SPILL)(31);
	 
    inst_spill_veto: entity work.veto
    port map(
      start_i => end_of_spill,
      end_i   => pre_spill,
      veto_en => spill_veto_enable,
      veto_o  => tmp_veto
    );  
  end block blk_spill_veto;
  
  
  
  -- Port Output Enable (0=Output, 1=Input)
  nOED  <=  '1';    -- Output Enable Port D (only for A395D)
  nOEG  <=  '1';    -- Output Enable Port G
  D     <=  D_Expan  when IDD = "011"  else (others => 'Z');
  
  
  nOEE <= '0';
  nOEF <= '0';
  F     <=  F_Expan    when IDF = "011"  else (others => 'Z');
  E     <=  E_Expan    when IDE = "011"  else (others => 'Z');

  
 
  --nOEDDLY0  <=  '0';  -- Output Enable for PDL0 (active low)
  --nOEDDLY1  <=  '0';  -- Output Enable for PDL1 (active low)
  
  -- Port Level Select (0=NIM, 1=TTL)
  SELD      <=  '1';    -- Output Level Select Port D (only for A395D)
  SELG      <=  '1';
  SELE      <=  '0';
  SELF      <=  '0';
  

  --DIRDDLY   <=  '1';  -- Direction of PDL data (0 => Read Dip Switches)
                              --                       (1 => Write from FPGA)                           
  --WR_DLY0   <=  '0';
  --WR_DLY1   <=  '0';
  

end rtl;
   
