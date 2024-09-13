from genRegisterHeader import getRegisterList

REGISTERS = getRegisterList("../src/V1495_regs_pkg.vhd")

f = open("README.md", "w")

for rType in REGISTERS.keys():
    f.write("# "+rType+" Registers\n")
    for name in REGISTERS[rType]:
        f.write(" - "+name+": "+REGISTERS[rType][name]['comment']+"\n")
        f.write("   - ")
        regList = ""
        for address in REGISTERS[rType][name]['addresses']:
            regList += "`"+hex(address)+"`, "
        f.write(regList[:-2]+"\n")
    f.write("\n")
