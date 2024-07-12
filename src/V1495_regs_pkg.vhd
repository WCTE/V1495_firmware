-- register package



library IEEE;
use IEEE.std_Logic_1164.all;
use IEEE.std_Logic_arith.all;
use IEEE.std_Logic_unsigned.all;


package V1495_regs IS

-- Register addresses (generically named for now)
  type reg_addresses is array (natural range <>) of std_logic_vector(15 downto 0);

  type reg_data is array (natural range <>) of std_logic_vector(31 downto 0);
  
  type t_slv_v8 is array(natural range <>) of std_logic_vector(7 downto 0);

  constant a_counter : integer := 3;
  constant a_gate_width : integer := 4;
  
  constant A_MASK : integer :=3;
  constant B_MASK : integer :=4;
  constant D_MASK : integer :=5;
  
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

  constant a_reg_rw : reg_addresses(0 to 53) := (x"1024", --0
                                                 x"1026",      
                                                 x"1028", --2
                                                 x"102a",
                                                 x"102c", --4
                                                 x"102e",  
                                                 x"1030", --6 (start of delay registers) (A connector)
	                                              x"1032", 
                                                 x"1034", --8
                                                 x"1036",
                                                 x"1038", --10
                                                 x"103a",
                                                 x"103c", --12
                                                 x"103e",  --end of A
                                                 x"1040", --14 --B
                                                 x"1042",
                                                 x"1044", --16
                                                 x"1046",
                                                 x"1048", --18
                                                 x"104a",
                                                 x"104c", --20
                                                 x"104e", --end of B
                                                 x"1050", --22 --C
                                                 x"1052",
                                                 x"1054", --24
                                                 x"1056",
                                                 x"1058", --26
                                                 x"105a",
                                                 x"105c", --28
                                                 x"105e", --29 (end of delay registers) end of C
                                                 x"1060", --30 (start of gate registers) A
                                                 x"1062",
                                                 x"1064", --32
                                                 x"1066",
                                                 x"1068", --34 
                                                 x"106a",
                                                 x"106c", --36
                                                 x"106e",  --end A
                                                 x"1070", --38 B
                                                 x"1072",
                                                 x"1074", --40
                                                 x"1076",
                                                 x"1078", --42
                                                 x"107a",
                                                 x"107c", --44
                                                 x"107e", --end B
                                                 x"1080", --46 C
                                                 x"1082",
                                                 x"1084", --48
                                                 x"1086",
                                                 x"1088", --50
                                                 x"108a",
                                                 x"108c", --52
                                                 x"108e");--53 (end of gate registers) end C
															 
																 
																 
																 															 
 
end package V1495_regs;

