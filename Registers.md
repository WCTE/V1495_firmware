# Registers for V1495 firmware

This document contains information on the register used by the V1495 firmware.

- [Read only registers](#read-only-registers)
   * [Counters for the raw inputs](#counters-for-the-raw-inputs)
   * [Counters for the Logic units](#counters-for-the-logic-units)
- [Read/Write registers](#readwrite-registers)
   * [Reset](#reset)
   * [Delay and Gate control](#delay-and-gate-control)
      + [Raw inputs](#raw-inputs)
      + [Level 1 output](#level-1-output)
   * [Logic type](#logic-type)
   * [Channel masks](#channel-masks)
      + [Level 1 Input Masks](#level-1-input-masks)
      + [Level 2 Input Masks](#level-2-input-masks)
   * [Signal inversion](#signal-inversion)
      + [Inverting inputs to Level 1 logic](#inverting-inputs-to-level-1-logic)
      + [Inverting inputs to Level 2 logic](#inverting-inputs-to-level-2-logic)
   * [Prescaling](#prescaling)
   * [Output control](#output-control)
      + [LEMO ports](#lemo-ports)
      + [Post trigger veto](#post-trigger-veto)
      + [Spill veto](#spill-veto)

# Read only registers

Read only registers are used for counters and fixed information about the firmware.

Registers which provide information about the firmware are:
 - AR_VERSION: Firmware version
   - `0x100c`
 - AR_GIT: Most recent GIT commit SHA
   - `0x100a`


## Counters for the raw inputs

Each register in this table corresponds to a raw input channel counter:
| Channel | Input A | Input B | Input D |
| ------- | ------- | ------- | ------- |
| 0 | 0x1022 | 0x1062 | 0x10a2 | 
| 1 | 0x1024 | 0x1064 | 0x10a4 | 
| 2 | 0x1026 | 0x1066 | 0x10a6 | 
| 3 | 0x1028 | 0x1068 | 0x10a8 | 
| 4 | 0x102a | 0x106a | 0x10aa | 
| 5 | 0x102c | 0x106c | 0x10ac | 
| 6 | 0x102e | 0x106e | 0x10ae | 
| 7 | 0x1030 | 0x1070 | 0x10b0 | 
| 8 | 0x1032 | 0x1072 | 0x10b2 | 
| 9 | 0x1034 | 0x1074 | 0x10b4 | 
| 10 | 0x1036 | 0x1076 | 0x10b6 | 
| 11 | 0x1038 | 0x1078 | 0x10b8 | 
| 12 | 0x103a | 0x107a | 0x10ba | 
| 13 | 0x103c | 0x107c | 0x10bc | 
| 14 | 0x103e | 0x107e | 0x10be | 
| 15 | 0x1040 | 0x1080 | 0x10c0 | 
| 16 | 0x1042 | 0x1082 | 0x10c2 | 
| 17 | 0x1044 | 0x1084 | 0x10c4 | 
| 18 | 0x1046 | 0x1086 | 0x10c6 | 
| 19 | 0x1048 | 0x1088 | 0x10c8 | 
| 20 | 0x104a | 0x108a | 0x10ca | 
| 21 | 0x104c | 0x108c | 0x10cc | 
| 22 | 0x104e | 0x108e | 0x10ce | 
| 23 | 0x1050 | 0x1090 | 0x10d0 | 
| 24 | 0x1052 | 0x1092 | 0x10d2 | 
| 25 | 0x1054 | 0x1094 | 0x10d4 | 
| 26 | 0x1056 | 0x1096 | 0x10d6 | 
| 27 | 0x1058 | 0x1098 | 0x10d8 | 
| 28 | 0x105a | 0x109a | 0x10da | 
| 29 | 0x105c | 0x109c | 0x10dc | 
| 30 | 0x105e | 0x109e | 0x10de | 
| 31 | 0x1060 | 0x10a0 | 0x10e0 | 


## Counters for the Logic units

Each register in this table corresponds to a logic unit channel counter:
| Unit | Level 1 | Level 2 |
| ---- | ------- | ------- |
| 0 | 0x100e | 0x1000 | 
| 1 | 0x1010 | 0x1002 | 
| 2 | 0x1012 | 0x1004 | 
| 3 | 0x1014 | 0x1006 | 
| 4 | 0x1016 |   |
| 5 | 0x1018 |   |
| 6 | 0x101a |   |
| 7 | 0x101c |   |
| 8 | 0x101e |   |
| 9 | 0x1020 |   |


# Read/Write registers

## Reset

Reading or writing to register `0x3002` will reset the counters.
The data written to this register doesn't matter, the act of reading/writing triggers the reset

## Delay and Gate control

Each delay and gate control register applies to four channels:
Each register is 32-bits wide, thus 8-bits are used per channel

For example, setting register `0x3012` to `0xAABBCCDD` will set:
 - Delay on channel `A12` to `DD`
 - Delay on channel `A13` to `CC`
 - Delay on channel `A14` to `BB`
 - Delay on channel `A15` to `AA`

### Raw inputs

The registers which control delay and gate for the `A` and `B` inputs are:
| Channel | Delay Register | Gate Register |
| ------- | ------- | ------- |
| A[3:0] | 0x300c | 0x302c | 
| A[7:4] | 0x300e | 0x302e | 
| A[11:8] | 0x3010 | 0x3030 | 
| A[15:12] | 0x3012 | 0x3032 | 
| A[19:16] | 0x3014 | 0x3034 | 
| A[23:20] | 0x3016 | 0x3036 | 
| A[27:24] | 0x3018 | 0x3038 | 
| A[31:28] | 0x301a | 0x303a | 
| B[3:0] | 0x301c | 0x303c | 
| B[7:4] | 0x301e | 0x303e | 
| B[11:8] | 0x3020 | 0x3040 | 
| B[15:12] | 0x3022 | 0x3042 | 
| B[19:16] | 0x3024 | 0x3044 | 
| B[23:20] | 0x3026 | 0x3046 | 
| B[27:24] | 0x3028 | 0x3048 | 
| B[31:28] | 0x302a | 0x304a | 


### Level 1 output

The registers which control delay and gate for the `L1` outputs are:
| Unit | Delay Register | Gate Register |
| ---- | ------- | ------- |
| L1[3:0] | 0x3094 | 0x309a | 
| L1[7:4] | 0x3096 | 0x309c | 
| L1[11:8] | 0x3098 | 0x309e | 


## Logic type

The register `0x3000` sets the logic type for level 1 and level 2 logic.
 - Bits [9:0] set the logic type for `L1`
 - Bits [13:10] set the logic type for `L2`

If a bit is `0` the corresponding logic unit will be in `and` mode.
If a bit is `1` the corresponding logic unit will be in `or` mode.

For example, setting this register to `0x1B97` (`0b01-1011-1001-0111`) will set:
 - L1 units 0, 1, 2, 4, 7, 8, and 9 to `or` mode
 - L1 units 3, 5, and 6 to `and` mode
 - L2 units 1 and 2 to `or` mode
 - L2 units 0 and 3 to `and` mode

## Channel masks

Channel masks are used to enable/disable channels going into a logic unit
Each bit of a channel mask register corresponds to an input into a logic unit

For example, setting register `0x3076` to `0x000072C5` (`0b0000-0000-0000-0000-0111-0010-1100-0101`) will:
 - enable channels A0, A2, A6, A7, A9, A12, A13, and A14
 - disable all other channels

For level 1 logic unit #5

### Level 1 Input Masks

The masks for input into `L1` are:
| Unit | Mask on `A` | Mask on `B` |
| ---- | ------- | ------- |
| 0 | 0x306c | 0x3080 | 
| 1 | 0x306e | 0x3082 | 
| 2 | 0x3070 | 0x3084 | 
| 3 | 0x3072 | 0x3086 | 
| 4 | 0x3074 | 0x3088 | 
| 5 | 0x3076 | 0x308a | 
| 6 | 0x3078 | 0x308c | 
| 7 | 0x307a | 0x308e | 
| 8 | 0x307c | 0x3090 | 
| 9 | 0x307e | 0x3092 | 


### Level 2 Input Masks

Level 2 logic can have as inputs the result of level 1 logic as well as the `A` and `B` inputs

The masks for input into `L2` are:
| Unit | Mask on `A` | Mask on `B` | Mask on `L1` |
| ---- | ------- | ------- | ------- |
| 0 | 0x30a0 | 0x30a8 | 0x30b0 | 
| 1 | 0x30a2 | 0x30aa | 0x30b2 | 
| 2 | 0x30a4 | 0x30ac | 0x30b4 | 
| 3 | 0x30a6 | 0x30ae | 0x30b6 | 


## Signal inversion

Signals going into a logic can be inverted.
For example, register `0x30fa` inverts the signals going into logic level 1 from the B input port.
Setting this to `0x8a210000` (`0b1000-1010-0010-0001-0000-0000-0000-0000`) will invert channels 16, 21, 25, 27, and 31 for L1[2], leaving the other channels un-inverted.

**NOTE**: Inversion is set for each logic unit seperately. Setting `0x30fa` to `0x8a210000` will **only** affect L1[2].
The same signals going into other logic units will not be inverted.
### Inverting inputs to Level 1 logic

The registers to invert input into `L1` are:
| Unit | Invert `A` | Invert `B` |
| ---- | ------- | ------- |
| 0 | 0x30e2 | 0x30f6 | 
| 1 | 0x30e4 | 0x30f8 | 
| 2 | 0x30e6 | 0x30fa | 
| 3 | 0x30e8 | 0x30fc | 
| 4 | 0x30ea | 0x30fe | 
| 5 | 0x30ec | 0x3100 | 
| 6 | 0x30ee | 0x3102 | 
| 7 | 0x30f0 | 0x3104 | 
| 8 | 0x30f2 | 0x3106 | 
| 9 | 0x30f4 | 0x3108 | 


### Inverting inputs to Level 2 logic

Level 2 logic can have as inputs the result of level 1 logic as well as the `A` and `B` inputs

The registers to invert input into `L2` are:
| Unit | Invert `A` | Invert `B` | Invert `L1` |
| ---- | ---------- | ---------- | ----------- |
| 0 | 0x311e | 0x3126 | 0x312e | 
| 1 | 0x3120 | 0x3128 | 0x3130 | 
| 2 | 0x3122 | 0x312a | 0x3132 | 
| 3 | 0x3124 | 0x312c | 0x3134 | 


## Prescaling

The results of level 1 logic can be prescaled by powers of 2.
For a prescale value n, only 1/n positive results coming from the logic unit will be kept.
The prescale factor is set by the most significant bit of the relevant register.

For example, to prescale the output of `L1` #7 by 4, set register `0x30d6` to `0x10` (`0b10000` or 2<sup>4</sup>).
The prescale will ignore any bits lower than the MSB: 0x10 (0b10000) will produce the same prescaling as 0x1F (0b11111)

The registers to prescale the output of `L1 are:
| Unit | register |
| ---- | ------- |
| 0 | 0x30c8 | 
| 1 | 0x30ca | 
| 2 | 0x30cc | 
| 3 | 0x30ce | 
| 4 | 0x30d0 | 
| 5 | 0x30d2 | 
| 6 | 0x30d4 | 
| 7 | 0x30d6 | 
| 8 | 0x30d8 | 
| 9 | 0x30da | 


## Output control

### LEMO ports

The LEMO ports on the mezzanine cards can be set to output any of the signals or logic units before or after delay and gate are applied.The lowest 7 bits of the register correspond to the desired channel.These values are valid (Note, these are in decimal):
 -    0-31: `A` inputs
 -   32-63: `B` inputs
 -   64-95: `D` inputs
 -  96-105: `L1` outputs
 - 106-109: `L2` outputs

Bit 8 switches between raw and and delay/gate applied.
If bit 8 is `1`, then the output will be the requested signal with delay and gate applied
In the case of `L2` outputs, the output will have a gate width of 1 clock tick.

For example, setting register `0x30c4` to `0x12` will output raw channel `A18` on LEMO port 6 of the mezzanine card in port F.
Setting this register to 0x32 instead will output the same channel, but with the delay and gate applied

The registers to control the LEMO outputa are:
| LEMO | Port E | Port F |
| ---- | ------ | ------ |
| 0 | 0x310e | 0x30b8 | 
| 1 | 0x3110 | 0x30ba | 
| 2 | 0x3112 | 0x30bc | 
| 3 | 0x3114 | 0x30be | 
| 4 | 0x3116 | 0x30c0 | 
| 5 | 0x3118 | 0x30c2 | 
| 6 | 0x311a | 0x30c4 | 
| 7 | 0x311c | 0x30c6 | 


### Post trigger veto

A post trigger deadtime is applied to whatever signal is coming out of LEMO 0 of Ports E and F.
The length of this deadtime is set by register `0x310c`.

For example, setting this register to 0x271 (625 in decimal) will set the deadtime to 5us.
In this case, after a trigger is sent out on LEMO 0, any other trigger on the same LEMO will be ignored for 625x8 ns = 5us
### Spill veto

During the spill veto, all the counters will be frozen and any triggers will be blocked.
The register at `0x30de` is used to setup the spill veto:
 - Bits [7:0] is the channel connected to the pre-spill signal
 - Bits [15:0] is the channel connected to the end-of-spill signal
 - Bit [16] is the veto enable

Possible values for these are 0-63, or any of the signals coming into the A or B ports.
0-31 corresponds to `A0`-`A31`, 32-63 corresponds to `B0`-`B31`

If the veto enable is set to `1`, the veto will start when the end of spill signal is asserted, and end when the pre-spill signal is asserted

If the veto enable is set to `0`, the veto will not be applied at any time.
