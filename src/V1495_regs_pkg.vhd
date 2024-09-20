-- register package

library IEEE;
use IEEE.std_Logic_1164.all;
--use IEEE.std_Logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
--IEEE.std_Logic_unsigned.all;


package V1495_regs IS

  type t_int_v is array(natural range <>) of integer;

  function GenIntegerList(start : integer; num : integer) return t_int_v;
           
  type reg_data is array (natural range <>) of std_logic_vector(31 downto 0);
  
  type t_slv_v8 is array(natural range <>) of std_logic_vector(7 downto 0);
  
  -- The latest git SHA, updated at compile time
  constant GIT_SHA : std_logic_vector(31 downto 0) := x"0a3da351";

  -- The number of read only registers
  constant numRregs :  integer := 114;
  -- The number or read/write registers
  constant numRWregs : integer := 155;
  
  -- Start address of read-only registers
  constant R_start_address : std_logic_vector(15 downto 0) := x"1000";
  -- Start address of read/write registers 
  constant RW_start_address : std_logic_vector(15 downto 0) := x"3000"; 
      
  -- Address index of read only registers
  constant AR_VERSION : integer := 6; -- Firmware version
  
  constant AR_GIT : integer := 5; -- Most recent GIT commit SHA
  
  constant AR_ACOUNTERS : t_int_v(0 to 31) := GenIntegerList(17, 32); -- Counters for A input
  constant AR_BCOUNTERS : t_int_v(0 to 31) := GenIntegerList(49, 32); -- Counters for B input
  constant AR_DCOUNTERS : t_int_v(0 to 31) := GenIntegerList(81, 32); -- Counters for D input
  

  constant AR_LVL1_COUNTERS : t_int_v(0 to 9) := GenIntegerList(7, 10); -- Counters for level 1 logic
  constant AR_LVL2_COUNTERS : t_int_v(0 to 3) := GenIntegerList(0, 4);  -- Counters for level 2 logic
  
  -- Address index of read/write registers
  constant ARW_DELAY_PRE : t_int_v(0 to 15) := GenIntegerList(6, 16);  -- Delay registers for pre-logic treatment of input data. Each register covers four channels.
  constant ARW_GATE_PRE  : t_int_v(0 to 15) := GenIntegerList(22, 16); -- Gate width registers for pre-logic treatment of input data. Each register covers four channels.
    
  constant ARW_DELAY_LEVEL1 : t_int_v(0 to 2) := GenIntegerList(74, 3);-- Delay registers for pre-logic treatment of level 1 trigger. Each register covers four logic units.
  constant ARW_GATE_LEVEL1  : t_int_v(0 to 2) := GenIntegerList(77, 3); -- Gate width registers for pre-logic treatment of level 1 trigger. Each register covers four logic units.
 
  constant ARW_AMASK_L1 : t_int_v(0 to 9) := GenIntegerList(54, 10); -- Mask on 'A' channels for level 1 logic. Each bit of the register corresponds to a channel of the A input. '0' is disabled, '1' is enabled. Each register corresponds to a separate logic unit.
  constant ARW_BMASK_L1 : t_int_v(0 to 9) := GenIntegerList(64, 10); -- Mask on 'B' channels for level 1 logic. Each bit of the register corresponds to a channel of the B input. '0' is disabled, '1' is enabled. Each register corresponds to a separate logic unit.
  
  constant ARW_AINV_L1 : t_int_v(0 to 9) := GenIntegerList(113, 10); -- Invert 'A' channels for input into level 1 logic. Each bit of the register corresponds to a channel of the A input. '0' is disabled, '1' is enabled. Each register corresponds to a separate logic unit.
  constant ARW_BINV_L1 : t_int_v(0 to 9) := GenIntegerList(123, 10); -- Invert 'B' channels for input into level 1 logic. Each bit of the register corresponds to a channel of the B input. '0' is disabled, '1' is enabled. Each register corresponds to a separate logic unit.
  
  
  constant ARW_AMASK_L2 : t_int_v(0 to 3)  := GenIntegerList(80, 4); -- Mask on 'A' channels for level 2 logic. Each bit of the register corresponds to a channel of the A input. '0' is disabled, '1' is enabled. Each register corresponds to a separate level 2 logic unit.
  constant ARW_BMASK_L2 : t_int_v(0 to 3)  := GenIntegerList(84, 4); -- Mask on 'B' channels for level 2 logic. Each bit of the register corresponds to a channel of the B input. '0' is disabled, '1' is enabled. Each register corresponds to a separate level 2 logic unit.
  constant ARW_L1MASK_L2 : t_int_v(0 to 3) := GenIntegerList(88, 4); -- Mask on level 1 results for level 2 logic. Each bit of the register corresponds to a level 1 logic unit. '0' is disabled, '1' is enabled. Each register corresponds to a separate level 2 logic unit.

  constant ARW_AINV_L2 : t_int_v(0 to 3) := GenIntegerList(143, 4); -- Invert 'A' channels for input into level 2 logic. Each bit of the register corresponds to a channel of the A input. '0' is disabled, '1' is enabled. Each register corresponds to a separate logic unit.
  constant ARW_BINV_L2 : t_int_v(0 to 3) := GenIntegerList(147, 4); -- Invert 'B' channels for input into level 2 logic. Each bit of the register corresponds to a channel of the B input. '0' is disabled, '1' is enabled. Each register corresponds to a separate logic unit.
  constant ARW_L1INV_L2 : t_int_v(0 to 3) := GenIntegerList(151, 4); -- Invert 'L1' outputs for input into level 2 logic. Each bit of the register corresponds to a channel of the B input. '0' is disabled, '1' is enabled. Each register corresponds to a separate logic unit.
 
  
 
  constant ARW_LOGIC_TYPE : integer := 0; -- Logic type for each logic unit. Bits 0-9 correspond level 1 logic units 0-9. Bits 10-13 correspond to level 2 logic units 0-3. '0' sets logic to 'and', '1' sets to  'or'

  constant ARW_RESET : integer := 1; -- Register controlled reset. A read or write to this register will generate a reset
  
  constant ARW_F : t_int_v(0 to 7) := GenIntegerList(92, 8); -- Signals routed to the F NIM outputs
  constant ARW_E : t_int_v(0 to 7) := GenIntegerList(135, 8); -- Signals routed to the E NIM outputs
  
  constant ARW_POST_L1_PRESCALE : t_int_v(0 to 9) := GenIntegerList(100, 10); -- Prescale factor applied after Level 1 logic
  
  constant ARW_SPILL : integer := 111; -- Set to channel used for pre-spill, end-of-spill, and spill veto signal
  
  constant ARW_DEADTIME : integer := 134; -- Length of deadtime after trigger output on lemo(0)

end package V1495_regs;

package body V1495_regs is

  function GenIntegerList(start : integer; num : integer) return t_int_v is
    variable numList : t_int_v(0 to num-1);
    variable curVal : integer := start;
  begin
    for i in 0 to num - 1 loop
      numList(i) := curVal;
      curVal := curVal + 1;
    end loop;
    return numList;  
  end function;

end package body V1495_regs;
