-- register package



library IEEE;
use IEEE.std_Logic_1164.all;
--use IEEE.std_Logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
--IEEE.std_Logic_unsigned.all;


package V1495_regs IS

-- Register addresses (generically named for now)
  type reg_addresses is array (natural range <>) of std_logic_vector(15 downto 0);

  -- Function to generate register address from a starting value
  function GenRegAddr(startReg : std_logic_vector(15 downto 0); numReg : integer) return reg_addresses;
							 
  type reg_data is array (natural range <>) of std_logic_vector(31 downto 0);
  
  type t_slv_v8 is array(natural range <>) of std_logic_vector(7 downto 0);
  
  type t_int_v is array(natural range <>) of integer;

  -- The number of read only registers
  constant numRregs :  integer := 8;
  -- The number or read/write registers
  constant numRWregs : integer := 23;
  
  -- Start address of read-only registers
  constant R_start_address : std_logic_vector(15 downto 0) := x"1000";
  -- addresses of read only registers
  constant a_reg_r : reg_addresses(0 to numRregs-1) := GenRegAddr(R_start_address, numRregs);
  
  -- Start address of read/write registers 
  constant RW_start_address : std_logic_vector(15 downto 0) := std_logic_vector(unsigned(a_reg_r(numRregs-1)) + 2);
  --addresses of read/write registers
  constant a_reg_rw : reg_addresses(0 to numRWregs-1) := GenRegAddr(RW_start_address, numRWregs);
       
  -- Address index of read only registers
  constant AR_VERSION : integer := 6; -- Firmware version
  
  constant AR_LVL1_COUNTERS : integer := 7; -- Counters for level 1 logic
  
  -- Address index of read/write registers
  constant ARW_RANGE_DELAY_PRE : t_int_v(0 to 7) := ( 6,  7,  8,  9, 10, 11, 12, 13); -- Delay registers for pre-logic treatment of input data. Each register covers four channels.
  constant ARW_RANGE_GATE_PRE  : t_int_v(0 to 7) := (14, 15, 16, 17, 18, 19, 20, 21); -- Gate width registers for pre-logic treatment of input data. Each register covers four channels.
 
  constant ARW_AMASK : integer := 22; -- Mask on 'A' channels for level 1 logic. Each bit of the register corresponds to a channel of the A input. '0' is disabled, '1' is enabled. Each register corresponds to a separate logic unit.
   
  constant ARW_LOGIC_TYPE : integer := 0; -- Logic type for each logic unit. Bits 0-9 correspond level 1 logic units 0-9. Bits 10-13 correspond to level 2 logic units 0-3. '0' sets logic to 'and', '1' sets to  'or'
  constant ARW_RESET : integer := 1; -- Reset

end package V1495_regs;

package body V1495_regs is

  -- Function to generate register address from a starting value
  function GenRegAddr(startReg : std_logic_vector(15 downto 0);
                      numReg : integer) return reg_addresses is
    variable curAddress : unsigned(15 downto 0) := unsigned(startReg);
    variable regList : reg_addresses(0 to numReg - 1);
  begin
    for i in 0 to numReg - 1 loop
      regList(i) := std_logic_vector(curAddress);
      curAddress := curAddress + 2;
    end loop;
      return regList;
  end function;

end package body V1495_regs;
