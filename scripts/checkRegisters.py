from genRegisterHeader import getRegisterList

REGISTERS = getRegisterList("../src/V1495_regs_pkg.vhd")

addressList=[]
for rType in REGISTERS.keys():
    for name in REGISTERS[rType]:
        for address in REGISTERS[rType][name]['addresses']:
            addressList.append(address)

# create a list of duplicate elements
duplicates = list(set([num for num in addressList if addressList.count(num) > 1]))

if len(duplicates) == 0:
    print("No duplicates found")
else:
    for address in duplicates:
        print(hex(address)+" is found twice!")

        
