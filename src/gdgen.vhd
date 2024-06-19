-- ========================================================================
-- ****************************************************************************
-- Company:         CAEN SpA - Viareggio - Italy
-- Model:           V1495 -  Multipurpose Programmable Trigger Unit
-- Device:          ALTERA EP1C4F400C6
-- Author:          Eltion Begteshi
-- Date:            March 16th, 2010
-- ----------------------------------------------------------------------------
-- Module:          gdgen
-- Description:     Gate and Delay Generate
-- ****************************************************************************

-- NOTE: this is just an example to show how to use programable and free running
-- delay lines to generate a gate and delay signal. In this example, there are 4 
-- registers called delay_fdl(REG4), gate_fdl(REG5), delay_pdl(REG6) and gate_pdl(REG7)
-- that can be written and read from the VME (through the local bus) and where the user
-- can set the gate and delay for both of the proposed solution. The registers are 32 
-- bit wide and can be accessed in single mode.


library ieee;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_arith.all;
use IEEE.Std_Logic_unsigned.all;


ENTITY gdgen is
	port(
		lclk   				:	in	std_logic;
    GIN           : in  std_logic_vector( 1 downto 0);    -- In G - LEMO (2 x NIM/TTL)
    ctrlreg       : in std_logic_vector(31 downto 0);
    pulse         : in  std_logic_vector( 3 downto 0);    -- Output of the delay line (0:1 => PDL; 2:3 => FDL)
    wr_dly_cmd    : in  std_logic_vector( 1 downto 0);    -- Write request from local bus
    wr_dly        : buffer std_logic_vector( 1 downto 0); -- Write signal for the PDL0/PDL1
    ddly          : buffer std_logic_vector (7 downto 0); -- R/W Data for the PDL
    start         : buffer std_logic_vector (1 downto 0); -- Input of PDL (active high)
    nstart        : buffer std_logic_vector (3 downto 2); -- Start of FDL (active low)
		out_pgdl      : out std_logic;		                    -- programable gate delay output
    out_fgdl      : out std_logic;		                    -- Fixed gate delay output
    delay_pdl     : in  std_logic_vector( 7 downto 0);    -- Delay setting for PDL  
    gate_pdl      : in  std_logic_vector( 7 downto 0);    -- Gate setting for PDL  
    delay_fdl     : in  std_logic_vector(31 downto 0);    -- Delay setting for FDL  
    gate_fdl      : in  std_logic_vector(31 downto 0)     -- Delay setting for FDL  
 );
END gdgen ;


ARCHITECTURE RTL of gdgen is

  
  alias ext_areset_in   : std_logic is GIN(0);
  alias start_gdl_in    : std_logic is GIN(1);
  signal ext_areset     : std_logic;
  signal start_gdl      : std_logic;
  
  signal ares_fld_1     : std_logic;
  signal ares_fld_2     : std_logic;
  signal ares_pld_1     : std_logic;
  signal ares_pld_2     : std_logic;

  signal out2_fdl       : std_logic;
  signal out3_fdl       : std_logic;
  signal out1_pdl       : std_logic;
  signal out2_pdl       : std_logic;
  signal out3_pdl       : std_logic;
  
  signal delay_cycles_fdl   : std_logic_vector(32 downto 0);
  signal gate_cycles_fdl    : std_logic_vector(32 downto 0);
  signal cclcnt             : std_logic_vector(32 downto 0);
  signal sumccl_fdl         : std_logic_vector(32 downto 0);
  
  signal out_A_fdl      : std_logic;
  signal out_B_fdl      : std_logic;
  signal input_A_fdl    : std_logic;
  signal input_B_fdl    : std_logic;
  signal pulse_prog     : std_logic;
  signal pulse_prog_1   : std_logic;
  
  
  
begin
  ------------------------------------------------
  ----- Free Running Gate and Delay Generate -----
  ------------------------------------------------
  gate_cycles_fdl   <= '0' & gate_fdl;
  delay_cycles_fdl  <= '0' & delay_fdl;
  sumccl_fdl        <= gate_cycles_fdl + delay_cycles_fdl;
  
  
   --Updating input NIM/TTL
  ext_areset <=  ext_areset_in xnor ctrlreg(1);
  start_gdl  <=  start_gdl_in xnor ctrlreg(1);
  
  
  start_proc: process(start_gdl, ares_fld_2)
  begin
    if ares_fld_2 = '1' then
      nstart(2)   <= '1';
    elsif start_gdl'event and start_gdl = '1' then
      nstart(2)   <= '0';
    end if;
  end process start_proc;

  
  counter_proc: process(pulse(2), ares_fld_2)
  begin
    if ares_fld_2 = '1' then
      cclcnt  <= (others => '0');
      input_A_fdl <= '0';
      input_B_fdl <= '0';
    elsif pulse(2)'event and pulse(2) = '1' then
      cclcnt <= cclcnt + 1;
      if (cclcnt = delay_cycles_fdl - 1) then
        input_A_fdl <= '1';
      end if;
      if (cclcnt = sumccl_fdl - 1) then
        input_B_fdl <= '1';
      end if; 
    end if;
  end process counter_proc;
  
  
  fdl_delay_proc: process(input_A_fdl, ares_fld_1)
  begin
    if ares_fld_1 = '1' then
      out_A_fdl  <= '0';
    elsif input_A_fdl'event and input_A_fdl = '1' then
      out_A_fdl  <= '1';
    end if;
  end process fdl_delay_proc;
  
 
  fdl_gate_proc: process(input_B_fdl, ares_fld_2)
  begin
    if ares_fld_2 = '1' then
      out_B_fdl  <= '0';
    elsif input_B_fdl'event and input_B_fdl = '1' then
      out_B_fdl  <= '1';
    end if;
  end process fdl_gate_proc;
  
  out_fgdl <=  out_A_fdl;   -- the requested gate and delay signal using FDL
  
  --DFF 1 with asynchronous reset
  dff1_fdl_proc: process(lclk, ares_fld_2)
  begin
    if(ares_fld_2 = '1') then
      out2_fdl <= '0';
    elsif(lclk'event and lclk = '1') then
      out2_fdl <= out_B_fdl; 
    end if;  
  end process dff1_fdl_proc;
 

  --DFF 2 with asynchronous reset
  dff2_fdl_proc: process(lclk, ext_areset)
  begin
    if(ext_areset = '1') then
      out3_fdl <= '0';
    elsif(lclk'event and lclk = '0') then
      out3_fdl <= out2_fdl;  
    end if;
  end process dff2_fdl_proc;
  
  ares_fld_1  <=  out_B_fdl or ext_areset;
  ares_fld_2  <=  out3_fdl or ext_areset;
   
   
   
   
  ------------------------------------------------
  ----- Programmable Gate and Delay Generate -----
  ------------------------------------------------
  
  --generation of "writing" signals for programable delay lines 
  write_pdl_proc: process(LCLK, ext_areset)
  begin   
    if(ext_areset = '1') then
      DDLY      <= (others => '0');
    elsif(lclk'event and lclk = '1') then
      if(ctrlreg(4) = '0') then     -- Direction of PDL data (0 => Read Dip Switches)  
        wr_dly(0) <= '1';           --                       (1 => Write from FPGA)  
        wr_dly(1) <= '1';
      else                           
        if(wr_dly_cmd(0) = '1') then
          wr_dly(0) <= '1';
          DDLY  <=  delay_pdl;
        else
          wr_dly(0) <= '0';  
        end if;
        if(wr_dly_cmd(1) = '1') then
          wr_dly(1) <= '1';
          DDLY  <=  gate_pdl;
        else
          wr_dly(1) <= '0';
        end if;
      end if;
    end if;   
  end process write_pdl_proc;  
  
  
  pdl_0_proc: process(start_gdl, ares_pld_2)
  begin
    if ares_pld_2 = '1' then
      start(0)   <= '0';  -- input of the first PDL
    elsif start_gdl'event and start_gdl = '1' then
      start(0)   <= '1';
    end if;
  end process pdl_0_proc;
   
  
  pdl_1_proc: process(pulse(0), ares_pld_1)
  begin
    if ares_pld_1 = '1' then
      start(1)   <= '0';  -- input of the second PDL
    elsif pulse(0)'event and pulse(0) = '1' then
      start(1)   <= '1';
    end if;
  end process pdl_1_proc;
  
  
  adff_pdl_proc: process(pulse(1), ares_pld_2)
  begin
    if ares_pld_2 = '1' then
      out1_pdl     <= '0';
    elsif pulse(1)'event and pulse(1) = '1' then
      out1_pdl     <= '1';  
    end if;
  end process adff_pdl_proc;
  
  out_pgdl <=  start(1); -- the requested gate and delay signal using PDL
  
  
  --DFF 1 with asynchronous reset
  dff1_pdl_proc: process(lclk, ares_pld_2)
  begin
    if(ares_pld_2 = '1') then
      out2_pdl <= '0';
    elsif(lclk'event and lclk = '1') then
      out2_pdl <= out1_pdl; 
    end if;  
  end process dff1_pdl_proc;
 

  --DFF 2 with asynchronous reset
  dff2_pdl_proc: process(lclk, ext_areset)
  begin
    if(ext_areset = '1') then
      out3_pdl <= '0';
    elsif(lclk'event and lclk = '0') then
      out3_pdl <= out2_pdl;  
    end if;
  end process dff2_pdl_proc;
  
  
  ares_pld_1  <=  out1_pdl or ext_areset;
  ares_pld_2  <=  out3_pdl or ext_areset;
   
  
END RTL;






