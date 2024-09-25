import json
import re

def getValue(line):
    result = re.search(':=(.*);', line)
    value = result.group(1)
    if "GenIntegerList" in line:
        return GenIntegerList(line)
    elif "(" in value:
        newVal = value.replace('(',"").replace(')',"").replace(' ',"").split(',')
        return newVal
    else:
        return [value.strip()]     

filename="../src/V1495_regs_pkg.vhd"

with open(filename) as f:
    for line in f.readlines():
        if "constant numRWregs" in line:
            numRWregs = getValue(line)[0]            
        elif "constant RW_start_address" in line:
            RW_start_address = getValue(line)[0]


jfile="bug1_registers.json"
start = int("0"+RW_start_address.replace('"',""),16)

with open(jfile) as json_data:
    data = json.load(json_data)

regs = [""]*int(numRWregs)

a=0;
    
for key, value in data.items():
    index = int((int(key, 16) - start)/2)
    regs[index] = value


f = open("V1495_regs_communication_sim.vhd", "w")

f.write("library ieee;\n")
f.write("use IEEE.std_Logic_1164.all;\n")
f.write("use IEEE.NUMERIC_STD.ALL; \n")
f.write("use IEEE.std_Logic_unsigned.all;\n")

f.write("use work.V1495_regs.all;\n")
f.write("use work.functions.all;\n")

f.write("entity V1495_regs_communication is\n")
f.write("  generic(\n")
f.write("    N_R_REGS : integer := 18;\n")
f.write("    N_RW_REGS : integer := 84\n")
f.write("  );\n")
f.write("  port(\n")
f.write("    -- Data clock\n")
f.write("    clk_data   : in std_logic;\n")
f.write("    -- Local Bus in/out signals\n")
f.write("    nLBRES     : in     std_logic;\n")
f.write("    nBLAST     : in     std_logic;\n")
f.write("    WnR        : in     std_logic;\n")
f.write("    nADS       : in     std_logic;\n")
f.write("    LCLK       : in     std_logic;\n")
f.write("    nREADY     : out    std_logic;\n")
f.write("    nINT       : out    std_logic;\n")
f.write("    LAD        : inout  std_logic_vector(15 DOWNTO 0);\n")
         
f.write("    ADDR_W : out std_logic_vector(11 downto 0);\n")

f.write("    REG_R  : in reg_data(N_R_REGS - 1 downto 0);\n")
f.write("    REG_RW : out reg_data(N_RW_REGS - 1 downto 0)\n")
         
f.write("  );\n")
f.write("end V1495_regs_communication;\n")

f.write("architecture rtl of V1495_regs_communication is\n")

f.write("begin\n")

f.write("  ADDR_W <= x\"000\";\n")
    
for i in range(0, int(numRWregs)):
    if regs[i] == "":
        val="x\"00000000\""
    else:
        tmp = regs[i].split("0x")[1]
        val = "x\""+tmp.rjust(8,'0')+"\""
    f.write("  REG_RW("+str(i)+") <= "+val+";\n")

f.write("end architecture rtl;\n")
f.close();
