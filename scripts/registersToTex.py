from genRegisterHeader import getRegisterList

def table_preinfo(title, label, ncols):
    print("\\begin{table}[]")
    print("\caption{"+title+"}")
    print("\label{"+label+"}") 
    print("\\begin{tabular}{"+"l"*ncols+"}")

def table_end():
    print("\end{tabular}")
    print("\end{table}")
    print()

def makeArray(Names, REGs):
    array = []
    for name in Names:
        array.append(REGs[name]['addresses'])
    return array, Names
    



REGISTERS = getRegisterList("../src/V1495_regs_pkg.vhd")

array, names = makeArray(['AR_ACOUNTERS', 'AR_BCOUNTERS', 'AR_DCOUNTERS'], REGISTERS["read-only"])
handledRegisters = names

table_preinfo("Counters for raw input", "COUNTERS_RAW", 4)
print("        & Register address & & \\\\")
print("Channel & Input A & Input B & Input D \\\\")
for i in range(len(array[0])):
    print(str(i)+" & "+hex(array[0][i])+" & "+hex(array[1][i])+" & "+hex(array[2][i])+" \\\\")
table_end()
    
for l in range(1,3):
    L=str(l)
    array,names = makeArray(['ARW_AMASK_L'+L, 'ARW_BMASK_L'+L], REGISTERS["read/write"])
    handledRegisters+=names


    table_preinfo("Masks for Level "+L+" logic input", "L"+L+"+_MASK", 3)
    print("        & Register address & \\\\")
    print("Level "+L+" unit & Input A & Input B \\\\")
    for i in range(len(array[0])):
        print(str(i)+" & "+hex(array[0][i])+" & "+hex(array[1][i])+" \\\\")
    table_end()


for l in range(1,2):
    L=str(l)
    
    array,names = makeArray(['ARW_AINV_L'+L, 'ARW_BINV_L'+L], REGISTERS["read/write"])
    handledRegisters+=names

    table_preinfo("Invert for Level "+L+" logic input", "L"+L+"+_INV", 3)
    print("        & Register address & \\\\")
    print("Level "+L+" unit & Input A & Input B \\\\")
    for i in range(len(array[0])):
        print(str(i)+" & "+hex(array[0][i])+" & "+hex(array[1][i])+" \\\\")
    table_end()



    
     
array,names = makeArray(['ARW_DELAY_PRE', 'ARW_GATE_PRE'], REGISTERS["read/write"])
handledRegisters+=names

table_preinfo("Delay and gate for input data", "RW_DELAY_GATE", 3)
print("Channel range & Delay register & Gate register \\\\")
for i in range(len(array[0])):
    if i<8:
        connector="A"
        j=i
    else:
        connector="B"
        j=i-8
    low = j*4
    high = (j+1)*4-1
    if i==0 :
        print("Connector A & & \\\\")
    if i==8 :
        print("Connector B & & \\\\")
    print(str(high)+":"+str(low)+" & "+hex(array[0][i])+" & "+hex(array[1][i])+" \\\\")
table_end()

array,names = makeArray(['ARW_DELAY_LEVEL1', 'ARW_GATE_LEVEL1'], REGISTERS["read/write"])
handledRegisters+=names

table_preinfo("Delay and gate for level 1 logic output", "RW_DELAY_GATE_L1", 3)
print("Logic unit range & Delay register & Gate register \\\\")
for i in range(len(array[0])):
    low = i*4
    high = (i+1)*4-1
    print(str(high)+":"+str(low)+" & "+hex(array[0][i])+" & "+hex(array[1][i])+" \\\\")
table_end()

array,names = makeArray(['ARW_E', 'ARW_F'], REGISTERS["read/write"])
handledRegisters+=names

table_preinfo("Signals routed to Lemo outputs on connectors E and F", "LEMO_OUT", 3)
print("Lemo connector & Register for connector E &  Register for connector F \\\\")
for i in range(len(array[0])):
    print(str(i)+" & "+hex(array[0][i])+" & "+hex(array[1][i])+" \\\\")
table_end()

table_preinfo("Single registers", "OTHER_RW", 4)
print("name & address & type & description \\\\")
for rType in REGISTERS.keys():
    RWs = REGISTERS[rType]    
    for name in RWs:
        name_adj = name.replace("_", "\\_")
        if len(RWs[name]['addresses']) == 1:
            print(name_adj+" & "+hex(RWs[name]['addresses'][0])+" & "+rType+" & "+ RWs[name]['comment']+" \\\\")
            handledRegisters.append(name)
table_end()

# cover any registers that haven't been dealt with    
for rType in REGISTERS.keys():
    for name in REGISTERS[rType]:
        if name in handledRegisters:
            continue
        table_preinfo(REGISTERS[rType][name]['comment'], name, 2)
        i=0
        for address in REGISTERS[rType][name]['addresses']:
            print(hex(address)+" & "+str(i)+" \\\\")
            i=i+1
        table_end()
        
    print()
