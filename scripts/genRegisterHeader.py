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
            
def GenIntegerList(line):
    split = line.split("GenIntegerList")[1].split(";")[0]
    split = re.sub('[(),]', '',split)
    start,num = split.split()
    end = int(start)+int(num)
    return list(range(int(start), end))

def parseLine(line, a_reg):
    indexes = getValue(line)
    if "--" in line:
        comment = line.split("--",1)[-1].strip()
    else:
        comment = ""        
    ADDRS=[]
    for index in indexes:
        ADDRS.append(a_reg[int(index)])
    return ADDRS, comment
        
def genRegAddr(startReg, numReg):
    regList = []
    for x in range(0, int(numReg)*2, 2):
        address = startReg + x
        regList.append(address)
    return regList
           

def getRegisterList(filename):

    RW_regnames=[]
    R_regnames=[]

    R_dict  = dict()
    RW_dict  = dict()

    # Get the register names
    with open(filename) as f:
        for line in f.readlines():
            if "constant AR" in line:
                tokens = line.split()
                for word in tokens:
                    if "ARW" in word:
                        RW_regnames.append(word)
                    elif "AR" in word:
                        R_regnames.append(word)
            elif "constant numRregs" in line:
                numRregs = getValue(line)[0]
            elif "constant numRWregs" in line:
                numRWregs = getValue(line)[0]            
            elif "constant R_start_address" in line:
                R_start_address = getValue(line)[0]


    start_address = int("0"+R_start_address.replace('"',""),16)
    a_reg_r = genRegAddr(start_address, numRregs)

    start_address = a_reg_r[-1]+2   
    a_reg_rw = genRegAddr(start_address, numRWregs)

    with open(filename) as f:
        for line in f.readlines():
            for word in R_regnames:
                if "constant "+word in line:
                    ADDRS, comment = parseLine(line, a_reg_r)
                    R_dict.update({word: {"addresses": ADDRS, "comment": comment}})  

            for word in RW_regnames:
                if "constant "+word in line:
                    ADDRS, comment = parseLine(line, a_reg_rw)
                    RW_dict.update({word: {"addresses": ADDRS, "comment": comment}})

    REGISTERS={'read-only': R_dict,
               'read/write': RW_dict}

    return REGISTERS



REGISTERS = getRegisterList("../src/V1495_regs_pkg.vhd")

for rType in REGISTERS.keys():
    print(rType)
    for name in REGISTERS[rType]:
    
        print(name+":")
        print("\t"+REGISTERS[rType][name]['comment'])
        print("\t", end="")
        for address in REGISTERS[rType][name]['addresses']:
            print(hex(address)+", ", end="")
        print()
    print()



