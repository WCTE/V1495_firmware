from genRegisterHeader import getRegisterList

REGISTERS = getRegisterList("../src/V1495_regs_pkg.vhd")
READONLY = REGISTERS["read-only"]
READWRITE = REGISTERS["read/write"]

f = open("../Registers.md", "w")

f.write("# Registers for V1495 firmware\n\n")

f.write("This document contains information on the register used by the V1495 firmware.\n\n")

f.write("- [Read only registers](#read-only-registers)\n")
f.write("   * [Counters for the raw inputs](#counters-for-the-raw-inputs)\n")
f.write("   * [Counters for the Logic units](#counters-for-the-logic-units)\n")
f.write("- [Read/Write registers](#readwrite-registers)\n")
f.write("   * [Reset](#reset)\n")
f.write("   * [Delay and Gate control](#delay-and-gate-control)\n")
f.write("      + [Raw inputs](#raw-inputs)\n")
f.write("      + [Level 1 output](#level-1-output)\n")
f.write("   * [Logic type](#logic-type)\n")
f.write("   * [Channel masks](#channel-masks)\n")
f.write("      + [Level 1 Input Masks](#level-1-input-masks)\n")
f.write("      + [Level 2 Input Masks](#level-2-input-masks)\n")
f.write("   * [Signal inversion](#signal-inversion)\n")
f.write("      + [Inverting inputs to Level 1 logic](#inverting-inputs-to-level-1-logic)\n")
f.write("      + [Inverting inputs to Level 2 logic](#inverting-inputs-to-level-2-logic)\n")
f.write("   * [Prescaling](#prescaling)\n")
f.write("   * [Output control](#output-control)\n")
f.write("      + [LEMO ports](#lemo-ports)\n")
f.write("      + [Post trigger veto](#post-trigger-veto)\n")
f.write("      + [Spill veto](#spill-veto)\n\n")


f.write("# Read only registers\n\n")
f.write("Read only registers are used for counters and fixed information about the firmware.\n\n");
f.write("Registers which provide information about the firmware are:\n")
 
for name in READONLY:
    if len(READONLY[name]['addresses']) == 1:
        f.write(" - "+name+": "+READONLY[name]['comment']+"\n")
        f.write("   - ")
        regList = ""
        for address in READONLY[name]['addresses']:
            regList += "`"+hex(address)+"`, "
            f.write(regList[:-2]+"\n")
            
          
f.write("\n\n")
f.write("## Counters for the raw inputs\n\n")

f.write("Each register in this table corresponds to a raw input channel counter:\n")


f.write("| Channel | Input A | Input B | Input D |\n")
f.write("| ------- | ------- | ------- | ------- |\n")

wanted_keys = ['AR_ACOUNTERS', 'AR_BCOUNTERS', 'AR_DCOUNTERS'] # The keys you want
raw_counters = dict((k, READONLY[k]) for k in wanted_keys if k in READONLY)

for i in range(len(raw_counters['AR_ACOUNTERS']['addresses'])):
    f.write("| "+str(i)+" | ")
    for name in raw_counters:
        f.write(hex(raw_counters[name]['addresses'][i])+" | ")
    f.write("\n");

f.write("\n\n")

f.write("## Counters for the Logic units\n\n")

f.write("Each register in this table corresponds to a logic unit channel counter:\n")

f.write("| Unit | Level 1 | Level 2 |\n")
f.write("| ---- | ------- | ------- |\n")

wanted_keys = ['AR_LVL1_COUNTERS', 'AR_LVL2_COUNTERS'] # The keys you want
logic_counters = dict((k, READONLY[k]) for k in wanted_keys if k in READONLY)

for i in range(len(logic_counters['AR_LVL1_COUNTERS']['addresses'])):
    f.write("| "+str(i)+" | ")
    for name in logic_counters:
        if i >= len(logic_counters[name]['addresses']):
            f.write("  |")
        else:
            f.write(hex(logic_counters[name]['addresses'][i])+" | ")
    f.write("\n")

f.write("\n\n")
f.write("# Read/Write registers\n\n")

f.write("## Reset\n\n")
f.write("Reading or writing to register `"+hex(READWRITE['ARW_RESET']['addresses'][0])+"` will reset the counters.\n")
f.write("The data written to this register doesn't matter, the act of reading/writing triggers the reset\n\n")
        
f.write("## Delay and Gate control\n\n")


f.write("Each delay and gate control register applies to four channels:\n")
f.write("Each register is 32-bits wide, thus 8-bits are used per channel\n\n")
n=3
f.write("For example, setting register `"+hex(READWRITE['ARW_DELAY_PRE']['addresses'][n])+"` to `0xAABBCCDD` will set:\n")
f.write(" - Delay on channel `A"+str(n*4)+"` to `DD`\n")
f.write(" - Delay on channel `A"+str(n*4+1)+"` to `CC`\n")
f.write(" - Delay on channel `A"+str(n*4+2)+"` to `BB`\n")
f.write(" - Delay on channel `A"+str(n*4+3)+"` to `AA`\n\n")

f.write("### Raw inputs\n\n")
f.write("The registers which control delay and gate for the `A` and `B` inputs are:\n")

f.write("| Channel | Delay Register | Gate Register |\n")
f.write("| ------- | ------- | ------- |\n")

wanted_keys = ['ARW_DELAY_PRE', 'ARW_GATE_PRE'] # The keys you want
prelogic = dict((k, READWRITE[k]) for k in wanted_keys if k in READWRITE)

for i in range(len(prelogic['ARW_DELAY_PRE']['addresses'])):
    if i<8:
        connector="A"
        j=i
    else:
        connector="B"
        j=i-8
    #if i==8:        
    #    f.write("|-------|-------|-------|\n")
    low = j*4
    high = (j+1)*4-1
    f.write("| "+connector+"["+str(high)+":"+str(low)+"]"+" | ")
    for name in prelogic:
        f.write(hex(prelogic[name]['addresses'][i])+" | ")
    f.write("\n");

f.write("\n\n")


f.write("### Level 1 output\n\n")

f.write("The registers which control delay and gate for the `L1` outputs are:\n")

f.write("| Unit | Delay Register | Gate Register |\n")
f.write("| ---- | ------- | ------- |\n")

wanted_keys = ['ARW_DELAY_LEVEL1', 'ARW_GATE_LEVEL1'] # The keys you want
prelogic = dict((k, READWRITE[k]) for k in wanted_keys if k in READWRITE)
for i in range(len(prelogic['ARW_DELAY_LEVEL1']['addresses'])):
    low = i*4
    high = (i+1)*4-1
    f.write("| L1["+str(high)+":"+str(low)+"]"+" | ")
    for name in prelogic:
        f.write(hex(prelogic[name]['addresses'][i])+" | ")
    f.write("\n");

f.write("\n\n")

f.write("## Logic type\n\n")

f.write("The register `"+hex(READWRITE['ARW_LOGIC_TYPE']['addresses'][0])+"` sets the logic type for level 1 and level 2 logic.\n")
f.write(" - Bits [9:0] set the logic type for `L1`\n")
f.write(" - Bits [13:10] set the logic type for `L2`\n\n")
f.write("If a bit is `0` the corresponding logic unit will be in `and` mode.\n")
f.write("If a bit is `1` the corresponding logic unit will be in `or` mode.\n\n")
f.write("For example, setting this register to `0x1B97` (`0b01-1011-1001-0111`) will set:\n")
f.write(" - L1 units 0, 1, 2, 4, 7, 8, and 9 to `or` mode\n")
f.write(" - L1 units 3, 5, and 6 to `and` mode\n")
f.write(" - L2 units 1 and 2 to `or` mode\n")
f.write(" - L1 units 0 and 3 to `and` mode\n\n")



f.write("## Channel masks\n\n")  

f.write("Channel masks are used to enable/disable channels going into a logic unit\n")
f.write("Each bit of a channel mask register corresponds to an input into a logic unit\n\n")

n=5
f.write("For example, setting register `"+hex(READWRITE['ARW_AMASK_L1']['addresses'][n])+"` to `0x000072C5` (`0b0000-0000-0000-0000-0111-0010-1100-0101`) will:\n")
f.write(" - enable channels A0, A2, A6, A7, A9, A12, A13, and A14\n")
f.write(" - disable all other channels\n")
f.write("For level 1 logic unit #"+str(n)+"\n")
f.write("Since register `"+hex(READWRITE['ARW_AMASK_L1']['addresses'][n])+" is a mask on `A` channels for `L1` #"+str(n)+"\n");

f.write("### Level 1 Input Masks\n\n")

f.write("The masks for input into `L1` are:\n")
f.write("| Unit | Mask on `A` | Mask on `B` |\n")
f.write("| ---- | ------- | ------- |\n")

wanted_keys = ['ARW_AMASK_L1', 'ARW_BMASK_L1'] # The keys you want
masks = dict((k, READWRITE[k]) for k in wanted_keys if k in READWRITE)
for i in range(len(masks['ARW_AMASK_L1']['addresses'])):
    f.write("| "+str(i)+" | ")
    for name in masks:
        if i >= len(masks[name]['addresses']):
            f.write("  |")
        else:
            f.write(hex(masks[name]['addresses'][i])+" | ")
    f.write("\n")

f.write("\n\n")

f.write("### Level 2 Input Masks\n\n")
f.write("Level 2 logic can have as inputs the result of level 1 logic as well as the `A` and `B` inputs\n\n")

f.write("The masks for input into `L2` are:\n")
f.write("| Unit | Mask on `A` | Mask on `B` | Mask on `L1` |\n")
f.write("| ---- | ------- | ------- | ------- |\n")

wanted_keys = ['ARW_AMASK_L2', 'ARW_BMASK_L2', 'ARW_L1MASK_L2'] # The keys you want
masks = dict((k, READWRITE[k]) for k in wanted_keys if k in READWRITE)
for i in range(len(masks['ARW_AMASK_L2']['addresses'])):
    f.write("| "+str(i)+" | ")
    for name in masks:
        if i >= len(masks[name]['addresses']):
            f.write("  |")
        else:
            f.write(hex(masks[name]['addresses'][i])+" | ")
    f.write("\n")

f.write("\n\n")

f.write("## Signal inversion\n\n")
f.write("Signals going into a logic can be inverted.\n")
n=2
f.write("For example, register `"+hex(READWRITE['ARW_BINV_L1']['addresses'][n])+"` inverts the signals going into logic level 1 from the B input port.\n")
f.write("Setting this to `0x8a210000` (`0b1000-1010-0010-0001-0000-0000-0000-0000`) will invert channels 16, 21, 25, 27, and 31, leaving the other channels un-inverted.\n")

f.write("### Inverting inputs to Level 1 logic\n\n")

f.write("The registers to invert input into `L1` are:\n")
f.write("| Unit | Invert `A` | Invert `B` |\n")
f.write("| ---- | ------- | ------- |\n")

wanted_keys = ['ARW_AINV_L1', 'ARW_BINV_L1'] # The keys you want
masks = dict((k, READWRITE[k]) for k in wanted_keys if k in READWRITE)
for i in range(len(masks['ARW_AINV_L1']['addresses'])):
    f.write("| "+str(i)+" | ")
    for name in masks:
        if i >= len(masks[name]['addresses']):
            f.write("  |")
        else:
            f.write(hex(masks[name]['addresses'][i])+" | ")
    f.write("\n")

f.write("\n\n")

f.write("### Inverting inputs to Level 2 logic\n\n")
f.write("Level 2 logic can have as inputs the result of level 1 logic as well as the `A` and `B` inputs\n\n")

f.write("The registers to invert input into `L2` are:\n")
f.write("| Unit | Invert `A` | Invert `B` | Invert `L1` |\n")
f.write("| ---- | ---------- | ---------- | ----------- |\n")
wanted_keys = ['ARW_AINV_L2', 'ARW_BINV_L2', 'ARW_L1INV_L2'] # The keys you want
masks = dict((k, READWRITE[k]) for k in wanted_keys if k in READWRITE)
for i in range(len(masks['ARW_AINV_L2']['addresses'])):
    f.write("| "+str(i)+" | ")
    for name in masks:
        if i >= len(masks[name]['addresses']):
            f.write("  |")
        else:
            f.write(hex(masks[name]['addresses'][i])+" | ")
    f.write("\n")

f.write("\n\n")

f.write("## Prescaling\n\n")
f.write("The results of level 1 logic can be prescaled by powers of 2.\n")
f.write("For a prescale value n, only 1/n positive results coming from the logic unit will be kept.\n")
f.write("The prescale factor is set by the most significant bit of the relevant register.\n\n")
n=7
f.write("For example, to prescale the output of `L1` #"+str(n)+" by 4, set register `"+hex(READWRITE['ARW_POST_L1_PRESCALE']['addresses'][n])+"` to `0x10` (`0b10000` or 2<sup>4</sup>).\n")
f.write("The prescale will ignore any bits lower than the MSB: 0x10 (0b10000) will produce the same prescaling as 0x1F (0b11111)\n\n")


f.write("The registers to prescale the output of `L1 are:\n")
f.write("| Unit | register |\n")
f.write("| ---- | ------- |\n")
wanted_keys = ['ARW_POST_L1_PRESCALE'] # The keys you want
masks = dict((k, READWRITE[k]) for k in wanted_keys if k in READWRITE)
for i in range(len(masks['ARW_POST_L1_PRESCALE']['addresses'])):
    f.write("| "+str(i)+" | ")
    for name in masks:
        if i >= len(masks[name]['addresses']):
            f.write("  |")
        else:
            f.write(hex(masks[name]['addresses'][i])+" | ")
    f.write("\n")

f.write("\n\n")

f.write("## Output control\n\n")

f.write("### LEMO ports\n\n")

f.write("The LEMO ports on the mezzanine cards can be set to output any of the signals or logic units before or after delay and gate are applied.")
f.write("The lowest 7 bits of the register correspond to the desired channel.")
f.write("These values are valid (Note, these are in decimal):\n")
f.write(" -    0-31: `A` inputs\n")
f.write(" -   32-63: `B` inputs\n")
f.write(" -   64-95: `D` inputs\n")
f.write(" -  96-106: `L1` outputs\n")
f.write(" - 107-110: `L2` outputs\n\n")
f.write("Bit 8 switches between raw and and delay/gate applied.\n")
f.write("If bit 8 is `1`, then the output will be the requested signal with delay and gate applied\n")
f.write("In the case of `L2` outputs, the output will have a gate width of 1 clock tick.\n\n")
n=6
f.write("For example, setting register `"+hex(READWRITE['ARW_F']['addresses'][n])+"` to `0x12` will output raw channel `A18` on LEMO port "+str(n)+" of the mezzanine card in port F.\n")
f.write("Setting this register to 0x32 instead will output the same channel, but with the delay and gate applied\n\n")

f.write("The registers to control the LEMO outputa are:\n")
f.write("| LEMO | Port E | Port F |\n")
f.write("| ---- | ------ | ------ |\n")
wanted_keys = ['ARW_E','ARW_F'] # The keys you want
lemo_out = dict((k, READWRITE[k]) for k in wanted_keys if k in READWRITE)
for i in range(len(lemo_out['ARW_E']['addresses'])):
    f.write("| "+str(i)+" | ")
    for name in lemo_out:
        f.write(hex(lemo_out[name]['addresses'][i])+" | ")
    f.write("\n")

f.write("\n\n")

f.write("### Post trigger veto\n\n")

f.write("A post trigger deadtime is applied to whatever signal is coming out of LEMO 0 of Ports E and F.\n")
f.write("The length of this deadtime is set by register `"+hex(READWRITE['ARW_DEADTIME']['addresses'][0])+"`.\n\n");

f.write("For example, setting this register to 0x271 (625 in decimal) will set the deadtime to 5us.\n")
f.write("In this case, after a trigger is sent out on LEMO 0, any other trigger on the same LEMO will be ignored for 625x8 ns = 5us\n")

f.write("### Spill veto\n\n")

f.write("During the spill veto, all the counters will be frozen and any triggers will be blocked.\n")
f.write("Two registers are used to setup the spill veto:\n")
f.write(" - Register `"+hex(READWRITE['ARW_ENDSPILL']['addresses'][0])+"` is set the signal connected to the end of spill signal\n")
f.write(" - Register `"+hex(READWRITE['ARW_PRESPILL']['addresses'][0])+"` is set the signal connected to the pre-spill signal\n\n")

f.write("Possible values for these are 0-63, or any of the signals coming into the A or B ports.\n")
f.write("0-31 corresponds to `A0`-`A31`, 32-63 corresponds to `B0`-`B31`\n\n")

f.write("The veto will start when the end of spill signal is asserted, and end when the pre-spill signal is asserted\n\n")
