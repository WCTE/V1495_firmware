-- ========================================================================
-- ****************************************************************************
-- Company:         CAEN SpA - Viareggio - Italy
-- Model:           V1495 -  Multipurpose Programmable Trigger Unit
-- Device:          ALTERA EP1C4F400C6
-- Author:          Eltion Begteshi
-- Date:            March 16th, 2010
-- ----------------------------------------------------------------------------
-- Module:          components
-- Description:     This file contains declarations header of all components
-- ****************************************************************************

-- NOTE: 
-- ****************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use work.V1495_regs.all;
use work.functions.all;

PACKAGE components is

  component gdgen is
  port(
    lclk   				:	in	std_logic;
    GIN           : in  std_logic_vector( 1 downto 0);  -- In G - LEMO (2 x NIM/TTL)
    ctrlreg       : in std_logic_vector(31 downto 0);
    pulse         : in  std_logic_vector (3 downto 0);  -- Output of the delay line (0:1 => PDL; 2:3 => FDL)
    wr_dly_cmd    : in  std_logic_vector( 1 downto 0);
    wr_dly        : buffer std_logic_vector( 1 downto 0); -- Write signal for the PDL0/PDL1
    ddly          : buffer std_logic_vector (7 downto 0); -- R/W Data for the PDL
    start         : buffer std_logic_vector (1 downto 0); -- Input of PDL (active high)
    nstart        : buffer std_logic_vector (3 downto 2); -- Start of FDL (active low)
		out_pgdl      : out  std_logic;
    out_fgdl      : out  std_logic;
		delay_pdl     : in  std_logic_vector( 7 downto 0);
    gate_pdl      : in  std_logic_vector( 7 downto 0);
    delay_fdl     : in  std_logic_vector(31 downto 0);
    gate_fdl      : in  std_logic_vector(31 downto 0)
  );
  end component gdgen ;
  
  component CDC_fifo IS
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
END component CDC_fifo;
	
	
	component V1495_regs_communication is
		port(
			-- Local Bus in/out signals
			nLBRES     : in     std_logic;
			nBLAST     : in     std_logic;
			WnR        : in     std_logic;
			nADS       : in     std_logic;
			LCLK       : in     std_logic;
			nREADY     : out    std_logic;
			nINT       : out    std_logic;
			LAD        : inout  std_logic_vector(15 DOWNTO 0);
			wr_dly_cmd : out	  std_logic_vector( 1 DOWNTO 0);
		REG_R : in reg_data(7 downto 0);
		REG_RW : buffer reg_data(53 downto 0)
		
		);
	end component V1495_regs_communication ;

	component pre_logic is
 port(
	clk: in std_logic;
   reset : in std_logic;
	data_in : in std_logic;
	delay : in std_logic_vector(7 downto 0);
	gate : in std_logic_vector(7 downto 0);
   data_out: out std_logic
 );
end component pre_logic;
	
	
component logic_unit is
 port(
	clk: in std_logic;
	reset : in std_logic;
	data_in : in std_logic_vector(95 downto 0);
	mask : in std_logic_vector(95 downto 0);
	type_i : in std_logic;
	maskedData : out std_logic_vector(95 downto 0);
	result : out std_logic
 );
end component logic_unit;	

	component logic_operator is 
     port(
	    clk : in std_logic;
	    reset : in std_logic;
       channel_mask : in std_logic_vector(95 downto 0);
	    data_in : in std_logic_vector(95 downto 0);
	    a_gate_width : in std_logic_vector(31 downto 0);
	    operation : in std_logic;
	    result : out std_logic_vector(95 downto 0)
     );
   end component logic_operator;
	
	component ALTERA_CMN_PLL is
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
end component ALTERA_CMN_PLL;


component delay_fifo
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
end component;

	
	
	component V1495_Demo4 is
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
      --SPARE    : INOUT  std_logic_vector (11 DOWNTO 0);

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
	end component V1495_Demo4;
	
	component lbemulator is
  port(
      nLBRES     : out    std_logic;
      nBLAST     : out    std_logic;
      WnR        : out    std_logic;
      nADS       : out    std_logic;
      LCLK       : in			std_logic;
      nREADY     : in     std_logic;
      nINT       : in     std_logic;
      LAD        : inout  std_logic_vector (15 DOWNTO 0) 
	);
	end component lbemulator ;
	
	
	component fpemulator is
	port(
		-- Front Panel Ports
		LCLK			: in std_logic;
		A         : out		std_logic_vector (31 DOWNTO 0);  -- In A (32 x LVDS/ECL)
		B         : out 	std_logic_vector (31 DOWNTO 0);  -- In B (32 x LVDS/ECL)
		GIN       : out   std_logic_vector ( 1 DOWNTO 0)   -- In G - LEMO (2 x NIM/TTL)
	);
	end component fpemulator ;

END components;