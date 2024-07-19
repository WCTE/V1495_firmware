import re

# Define the file's name.
filename = "../src/V1495_regs_pkg.vhd"

numRregs=0
numRWregs=0
R_start_address=""

RW_regnames=[]
R_regnames=[]

R_dict  = dict()
RW_dict  = dict()

def getValue(line):
    result = re.search(':=(.*);', line)
    value = result.group(1)
    if "(" in value:
        newVal = value.replace('(',"").replace(')',"").replace(' ',"").split(',')
        return newVal
    else:
        return value.strip()

def getComment(line):
    if "--" in line:
        return line.split("--",1)[-1].strip()
    else:
        return ""

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
            numRregs = getValue(line)
        elif "constant numRWregs" in line:
            numRWregs = getValue(line)            
        elif "constant R_start_address" in line:
            R_start_address = getValue(line)


start_address = int("0"+R_start_address.replace('"',""),16)

a_reg_r = []
a_reg_rw = []
for x in range(0, int(numRregs)*2, 2):
    address = start_address + x
    a_reg_r.append(address)

start_address = a_reg_r[-1]+2    
    
for x in range(0, int(numRWregs)*2, 2):
    address = start_address + x
    a_reg_rw.append(address)

with open(filename) as f:
    for line in f.readlines():
        for word in R_regnames:
            if "constant "+word in line:
                indexes = getValue(line)
                comment = getComment(line)
                ADDRS=[]
                for index in indexes:
                    ADDRS.append(a_reg_r[int(index)])            
                R_dict.update({word: {"addresses": ADDRS, "comment": comment}})  
        
        for word in RW_regnames:
            if "constant "+word in line:
                indexes = getValue(line)
                comment = getComment(line)
                ADDRS=[]
                for index in indexes:
                    ADDRS.append(a_reg_rw[int(index)])                 
                RW_dict.update({word: {"addresses": ADDRS, "comment": comment}})  




REGISTERS={'read-only': R_dict,
           'read/write': RW_dict}
print(REGISTERS['read-only']['AR_VERSION'])


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

