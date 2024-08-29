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

  constant N_LOGIC_CHANNELS : integer := A'length + B'length;
  constant N_LEVEL1 : integer := 10;
  constant N_LEVEL2 : integer := 4;
  
  constant COUNT_WIDTH_INPUTS_AB : integer := 20;
  constant COUNT_WIDTH_INPUTS_D : integer := 24;
  constant COUNT_WIDTH_LOGIC : integer := 16;

  --------------------------
  ------- SIGNALS ----------
  --------------------------
  
  signal REG_R : reg_data(numRregs-1 downto 0);
  signal REG_RW : reg_data(numRWregs-1 downto 0);
    
  -- Data Producer signals
  signal wr_dly_cmd       : std_logic_vector( 1 downto 0) := (others => '0');
  signal wr_dly           : std_logic_vector( 1 downto 0) := (others => '0');
  signal input_A_mask     : std_logic_vector(31 downto 0) := (others => 'Z');
  signal input_B_mask     : std_logic_vector(31 downto 0) := (others => 'Z');
  signal ctrlreg          : std_logic_vector(31 downto 0) := (others => 'Z');  
  signal D_Expan          : std_logic_vector(31 downto 0) := (others => 'Z');
  signal F_Expan          : std_logic_vector(31 downto 0) := (others => 'Z');

    
  signal allData : std_logic_vector(N_LOGIC_CHANNELS-1 downto 0);
  
  signal hits : std_logic_vector(N_LOGIC_CHANNELS-1 downto 0);
  
  signal otherClk : std_logic;
  
  signal prepared_signals : std_logic_vector(N_LOGIC_CHANNELS-1 downto 0);
  signal prepared_signals_l1 : std_logic_vector(N_LEVEL1-1 downto 0);
  
  signal level1_result : std_logic_vector(N_LEVEL1-1 downto 0);
  signal level2_input  : std_logic_vector(N_LOGIC_CHANNELS+N_LEVEL1-1 downto 0);
  
  signal level2_result : std_logic_vector(N_LEVEL2-1 downto 0);
  signal level2_result_edge : std_logic_vector(N_LEVEL2-1 downto 0);
  
  signal ADDR_W : std_logic_vector(15 downto 0);  
  signal localReset : std_logic;
  signal localResetLclk : std_logic;
  
  signal spill_veto : std_logic;  
  
  
begin

  proc_reset : process (lclk)
  begin
    if rising_edge(lclk) then
      if ADDR_W = a_reg_rw(ARW_RESET) then
        localResetLclk <= '1';
      else
        localResetLclk <= '0';
      end if;
    end if;
  end process;
  
  proc_reset_CDC : process(otherClk)
    variable temp : std_logic;
  begin
    if rising_edge(otherClk) then
      localReset <= temp;
		temp := localResetLclk;
		
   end if;
  end process proc_reset_CDC;
  

  -- firmware version
  REG_R(AR_VERSION)(3 downto 0)   <= x"1";  -- Firmware release
  REG_R(AR_VERSION)(7 downto 4)   <= x"0";  -- Demo number

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
    
    ADDR_W => ADDR_W,      
    
    REG_R  => REG_R,
    REG_RW => REG_RW
  );

  --PRE-LOGIC-TREATMENT---------------------------------------------------
    
  blk_raw_counters : block
  begin
   		
    gen_a_counters : for i in A'range generate
      signal count : std_logic_vector(COUNT_WIDTH_INPUTS_AB-1 downto 0);
    begin
      inst_counter : entity work.counter
      generic map(
        count_width => COUNT_WIDTH_INPUTS_AB
      )
      port map(
        clk => otherClk,
        reset => localReset,
        count_en => '1',
        data_in => A(i),
        count_out => count  --pipeline this
      );      
      REG_R(AR_ACOUNTERS(i)) <= (31 downto COUNT_WIDTH_INPUTS_AB => '0') & count;
    end generate gen_a_counters;
	
	
    gen_b_counters : for i in B'range generate
      signal count : std_logic_vector(COUNT_WIDTH_INPUTS_AB-1 downto 0);
    begin
      inst_counter : entity work.counter
      generic map(
        count_width => COUNT_WIDTH_INPUTS_AB
      )
      port map(
        clk => otherClk,
        reset => localReset,
        count_en => '1',
        data_in => B(i),
        count_out => count  --pipeline this
      );      
      REG_R(AR_BCOUNTERS(i)) <= (31 downto COUNT_WIDTH_INPUTS_AB => '0') & count;
    end generate gen_b_counters;
	 
	 	
    gen_d_counters : for i in B'range generate
      signal count : std_logic_vector(COUNT_WIDTH_INPUTS_D-1 downto 0);
    begin
      inst_counter : entity work.counter
      generic map(
        count_width => COUNT_WIDTH_INPUTS_D
      )
      port map(
        clk => otherClk,
        reset => localReset,
        count_en => '1',
        data_in => D(i),
        count_out => count  --pipeline this
      );      
      REG_R(AR_DCOUNTERS(i)) <= (31 downto COUNT_WIDTH_INPUTS_D => '0') & count;
    end generate gen_d_counters;
	   
  end block blk_raw_counters;
   
  
  -- Pre logic treatment  
  blk_pre_logic : block
    signal delay_regs : reg_data(15 downto 0);
    signal gate_regs : reg_data(15 downto 0); 
   
  begin
    
    gen_range : for i in ARW_DELAY_PRE'range generate
      proc_data_pipeline : process(otherClk)
      begin
        if rising_edge(otherClk) then  
          delay_regs(i) <= REG_RW(ARW_DELAY_PRE(i));
        end if;
      end process proc_data_pipeline;
    end generate gen_range;
  
    gen_gate : for i in ARW_GATE_PRE'range generate
      proc_data_pipeline : process(otherClk)
      begin
        if rising_edge(otherClk) then
        gate_regs(i)  <= REG_RW(ARW_GATE_PRE(i));
        end if;
      end process proc_data_pipeline;
    end generate gen_gate;  
  
    inst_pre_logic: work.pre_logic_treatment
    generic map(
      n_channels => N_LOGIC_CHANNELS
    )
    port map (
      clk => otherClk,
      reset => localReset,
      delay_regs => delay_regs,
      gate_regs => gate_regs,
      data_in => allData,
      prepared_signals => prepared_signals
    );
  
  end block blk_pre_logic;
  
        
  proc_data_pipeline : process(otherClk)
  begin
    if rising_edge(otherClk) then
      allData <= B & A;
    end if;
  end process proc_data_pipeline;
  
  --LEVEL-1-LOGIC---------------------------------------------------
  
  -- Level 1 logic
  gen_logic_level_1 : for i in N_LEVEL1-1 downto 0 generate
    signal count : std_logic_vector(COUNT_WIDTH_LOGIC-1 downto 0);
  begin
  
    inst_l1_logic : work.level1_logic
    generic map (
      N_CHANNELS => N_LOGIC_CHANNELS,
	   COUNTER_WIDTH => COUNT_WIDTH_LOGIC
    )
    port map(
      clk => otherClk,
	   reset =>localReset,
	   mask => REG_RW(ARW_BMASK_L1(i)) & REG_RW(ARW_AMASK_L1(i)),
	   data_in => prepared_signals,
	   logic_type => REG_RW(ARW_LOGIC_TYPE)(i),
	   prescale => REG_RW(ARW_POST_L1_PRESCALE(i))(7 downto 0),
  
      result => level1_result(i),
	   count =>count     
    );
  
  
    proc_counter_pipeline : process(lclk)
    begin
      if rising_edge(lclk) then
        REG_R(AR_LVL1_COUNTERS(i)) <= (31 downto COUNT_WIDTH_LOGIC => '0')&count;
      end if;
    end process proc_counter_pipeline;
  
  end generate gen_logic_level_1;
    
  
  -- Pre logic treatment of level1 outputs
  blk_pre_logic_level1 : block
    signal delay_regs : reg_data(2 downto 0);
    signal gate_regs : reg_data(2 downto 0); 
   
  begin
    
    gen_range : for i in ARW_DELAY_LEVEL1'range generate
      proc_data_pipeline : process(otherClk)
      begin
        if rising_edge(otherClk) then  
          delay_regs(i) <= REG_RW(ARW_DELAY_LEVEL1(i));
        end if;
      end process proc_data_pipeline;
    end generate gen_range;
  
    gen_gate : for i in ARW_GATE_LEVEL1'range generate
      proc_data_pipeline : process(otherClk)
      begin
        if rising_edge(otherClk) then
       gate_regs(i)  <= REG_RW(ARW_GATE_LEVEL1(i));
       end if;
      end process proc_data_pipeline;
    end generate gen_gate;  
	 
	  
    inst_pre_logic: work. pre_logic_treatment
    generic map(
      n_channels => N_LEVEL1
    )
    port map (
      clk => otherClk,
      reset => localReset,
      delay_regs => delay_regs,
      gate_regs => gate_regs,
      data_in => level1_result,
      prepared_signals => prepared_signals_l1
    );
	 
  
  end block blk_pre_logic_level1;
  

  
  --LEVEL-2-LOGIC---------------------------------------------------
    
  level2_input <= prepared_signals_l1 & prepared_signals;

  gen_logic_level_2 : for i in N_LEVEL2-1 downto 0 generate
    signal result : std_logic;
    signal count : std_logic_vector(COUNT_WIDTH_LOGIC-1 downto 0);
	 signal in_dly : std_logic;
    
  begin  
  
  
    inst_l2_logic : work.level2_logic
    generic map(
      N_CHANNELS => N_LEVEL1+N_LOGIC_CHANNELS,
	   COUNTER_WIDTH => COUNT_WIDTH_LOGIC
    )
    port map(
      clk => otherClk,
      reset => localReset,
	   mask => REG_RW(ARW_L1MASK_L2(i))(N_LEVEL1-1 downto 0) & REG_RW(ARW_BMASK_L2(i)) & REG_RW(ARW_AMASK_L2(i)),
	   data_in => level2_input,
	   logic_type => REG_RW(ARW_LOGIC_TYPE + N_LEVEL1)(i),
  
      result => result,
	   count => count
    ); 
 	 
    proc_counter_pipeline : process(lclk)
    begin
      if rising_edge(lclk) then
        REG_R(AR_LVL2_COUNTERS(i))   <= (31 downto COUNT_WIDTH_LOGIC => '0')&count;
      end if;
    end process proc_counter_pipeline;
  
    level2_result(i) <= result;
	 
	 proc_edge_detect : process(otherClk)
      begin
        if rising_edge(otherClk) then
          if localReset = '1' then
            in_dly <= '0';
          else
            in_dly <= result;
         end if;
       end if;
     end process;

   level2_result_edge(i) <= not in_dly and result;
	   
  end generate gen_logic_level_2;
  
  ------------------------------------------------
  
   inst_pll : entity work.ALTERA_CMN_PLL
   generic map(
     clk0_divide_by      => 8,
     clk0_duty_cycle     => 50,
     clk0_multiply_by    => 25,
     inclk0_input_frequency  => 25000  --actually period in us.
   )
   port map (
     areset     => not nLBRES,
     clk_in     => gin(0),
     clk_out_0  => otherClk,
     locked     => open
   );

  
  blk_lemo_output : block
    constant A395D_Mapping : t_int_v(0 to 7) := (0, 16, 1, 17,  12, 28, 13, 29);
    signal lemo_out : std_logic_vector(7 downto 0);
  begin
   
    inst_lemo : work.lemo_output
    port map (
      clk => otherClk,
      reset => localReset,
      raw_in =>  level2_result &            level1_result &           D & allData,
      prep_in => level2_result_edge & prepared_signals_l1 & x"00000000" & prepared_signals,
      regs_in(0) => REG_RW(ARW_F(0)),
      regs_in(1) => REG_RW(ARW_F(1)),
      regs_in(2) => REG_RW(ARW_F(2)),
      regs_in(3) => REG_RW(ARW_F(3)),
      regs_in(4) => REG_RW(ARW_F(4)),
      regs_in(5) => REG_RW(ARW_F(5)),
      regs_in(6) => REG_RW(ARW_F(6)),
      regs_in(7) => REG_RW(ARW_F(7)),
      data_out => lemo_out
    );
  
    gen_lemo_out : for i in 7 downto 0 generate
      F_Expan(A395D_Mapping(i)) <= lemo_out(i);  
    end generate;
      
  end block blk_lemo_output;
  
  blk_spill_veto : block
    signal spill_veto_start : std_logic;
    signal spill_veto_end : std_logic;	 
  begin
    spill_veto_start <= allData(to_integer(unsigned(REG_RW(ARW_PRESPILL)(6 downto 0))));
    spill_veto_end <= allData(to_integer(unsigned(REG_RW(ARW_ENDPSILL)(6 downto 0))));
	 
	 
    inst_spill_veto: work.veto
    port map(
	   start_i => spill_veto_end,
	   end_i   => spill_veto_start,
	   veto_o  => spill_veto
    );
  end block blk_spill_veto;
  
  
  
   -- Port Output Enable (0=Output, 1=Input)
  nOED  <=  '1';    -- Output Enable Port D (only for A395D)
  nOEG  <=  '1';    -- Output Enable Port G
  D     <=  D_Expan  when IDD = "011"  else (others => 'Z');
  F     <=  F_Expan    when IDF = "011"  else (others => 'Z');

  
  nOEDDLY0  <=  '0';  -- Output Enable for PDL0 (active low)
  nOEDDLY1  <=  '0';  -- Output Enable for PDL1 (active low)
  
  -- Port Level Select (0=NIM, 1=TTL)
  SELD      <=  ctrlreg(0);    -- Output Level Select Port D (only for A395D)
  --SELG      <=  ctrlreg(1);    -- Output Level Select Port G

  DIRDDLY   <=  ctrlreg(4);  -- Direction of PDL data (0 => Read Dip Switches)
                              --                       (1 => Write from FPGA)                           
  WR_DLY0   <=  wr_dly(0);
  WR_DLY1   <=  wr_dly(1);
  
  ctrlreg    <= X"00000013";--REG_RW(3);



  
  
  
 
end rtl;
   
