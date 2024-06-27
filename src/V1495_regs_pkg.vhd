-- register package



library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;


package V1495_regs IS

-- Register addresses (generically named for now)
  type reg_addresses is array (natural range <>) of std_logic_vector(15 downto 0);

  type reg_data is array (natural range <>) of std_logic_vector(31 downto 0);

  constant a_counter : integer := 3;
  constant a_gate_width : integer := 4;
  
  constant A_MASK : integer :=5;
  constant B_MASK : integer :=6;
  constant C_MASK : integer :=7;
  
  constant VERSION : integer := 6;

  constant a_reg_r : reg_addresses(0 to 17) := (x"1000",  
                                                x"1002",           
                                                x"1004",          
                                                x"1006",
                                                x"1008",
                                                x"100a",
                                                x"100c",
                                                x"100e",
                                                x"1010",
                                                x"1012",
                                                x"1014",
                                                x"1016",
                                                x"1018",
                                                x"101a",
                                                x"101c",
                                                x"101e",
                                                x"1020",
                                                x"1022");

  constant a_reg_rw : reg_addresses(0 to 17) := (x"1024",
                                                 x"1026",      
                                                 x"1028",
                                                 x"102a",
                                                 x"102c",
                                                 x"102e",
                                                 x"1030",
                                                 x"1032",
                                                 x"1034",
                                                 x"1036",
                                                 x"1038",
                                                 x"103a",
                                                 x"103c",
                                                 x"103e",
                                                 x"1040",
                                                 x"1042",
                                                 x"1044",
                                                 x"1046");
 
end package V1495_regs;

