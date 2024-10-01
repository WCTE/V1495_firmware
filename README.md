# V1495_firmware

This respository contains firmware for a CAEN V1495 FPGA module.
The V1495 has an Altera Cyclone (first generation) FPGA on it.

## External connectors

The V1495 has three built in connectors and three mezzanine card slots.
These will be used as:
 - Connector A: 32-channel Input
 - Connector B: 32-channel Input
 - Connector C: Unused
 - Mezzanine D: 32-channel Input via A395A mezzanine card
 - Mezzanine E: 8 LEMO outputs via A395D mezzanine card
 - Mezzanine F: 8 LEMO outputs via A395D mezzanine card

## Clocks

In addition to the data ports, there are also two LEMO ports labeled G on the front panel.
In this firmware, G0 shall receive a clock signal with a frequency of 62.5 MHz.
This 62.5 MHz clock is passes through a PLL which produces a 125 MHz clock.
All of the trigger logic is driven by this 125 MHz clock

The register communication is driven by an internal 40 MHz clock on the V1495.

## Latency

The data latency is discussed in detail in the [Latency document](./Latency.md).

## Data flow

### Raw data input

All data input into `A`, `B`, and `D` is counted by 24-bit counters.
Signals in A and B are first sent through a pre-logic treatment, where a delay and gate is applied.
Delays and gates are set via register.

Data input into `D` is only counted, it is not involved in any logic.

### Level 1 logic

The 64 channels after pre-logic treatment are passed to 10 logic units.
Each unit takes in all 64 channels, but only operates on channels which are enabled via register.
The Logic unit `and`s or `or`s the enabled channels together to produce a result.
This result has it's own delay and gate applied, and is then passed on to level 2.

The result of each logic unit is also counted by a 24-bit counter

### Level 2 logic 

There are four level 2 logic units.
Each level 2 logic unit takes in the 64 input channels (after pre-logic) and the delayed and gated level 1 results.
Channels and `L1` outputs can be enabled for `L2` via register..
As with `L1`, `L2` units `and` or `or` the enabled channels together to produce a result.
The result of `L2` has a gate width of one 8 ns clock tick applied

The result of each logic unit is counted by a 24-bit counter.

## LEMO output

The LEMO output can be configured using registers.
Any signal can be routed to the LEMO connectors:
 - `A`, `B`, or `D` raw input
 - `A` or `B` after pre-logic treatment
 - Any `L1` output before and after delay and gate applied
 - Any `L2` output before and after single tick gate applied

The output of LEMO 0 (the bottom-most LEMO connector on the mezzanine card) has a dead time applied.
This deadtime will suppress any signals coming some amount of clock ticks (set via register) coming after a trigger.


## Block diagram

Here is a simplified block diagram:
![Firmware Block Diagram](./fig/FirmwareBlockDiagram.svg "Firmware block diagram")

Note that this leaves out:
 - The register interface
 - Any input signal or logic signal can be routed to the LEMO connectors

## Register access

Register access is discussed in detail in the [registers](Registers.md) document

# Building the firmware

## Requirements

[Quartus 13.0.1](https://www.intel.com/content/www/us/en/software-kit/711919/intel-quartus-ii-subscription-edition-design-software-version-13-0sp1-for-linux.html) is required to build this firmware.
Newer versions of Quartus no longer support the first generation Cyclone devices.

A valid license is required to run Quartus.
Information on Quartus licenses at CERN can be found [here](https://engineering-software.docs.cern.ch/eda/sw/intel_quartus_ii/)

## Compiling the code

The firmware can be compiled in Quartus using the GUI, or by running the `compile.sh` script in the [scripts](./scripts) directory.

## Programming the FPGA

There are two ways to program the FPGA:
 - Via the CAEN upgrader tool
 - Via USB blaster dongle

### CAEN Upgrader tool

Programming via the CAEN upgrader loads the firmware into the flash memory.
The FPGA is then programmed from the flash memory when the V1495 boots up.

The benifit of this is method that is stable upon power cycling.
The drawback is that a power cycle is required to apply the firmware.

This is the recommended way of programming when not actively debugging the firmware

### USB blaster dongle

The other programming option is to use a [USB blaster dongle](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=46).
For this, the not-USB end if the dongle must be connected to the lower of the two matching ports on the V1495.

The benifit of this method is that the firmware is immediately available, no need to restart.
The drawback is that a power cycle will reset the firmware to the last version programmed via the CAEN upgrader.

This is recommended for firmware debugging and development.

**NOTE**: Having the USB Blaster dongle connected to the V1495 will block the CAEN Upgrader from working.
Remove the USB Blaster before programming via the CAEN Upgrader

## Programming script

A script is provided to ease programming of the V1495: `scripts/V1495-Program.sh`.

```
Usage: V1495-Program.sh [-m|--method] [-f|--file FILE]
                        [-v|--vme VME] [-a|--arg ARGS]
                        [-h|--help]

  This command programs a CAEN V1495 via the CAEN upgrader or
  a USB-Blaster dongle

  Options:
      -m, --method
            Method used to program the V1495. Options are CAEN
            or usb-blaster.
      -f, --file
            Name of the bit file to be programmed onto the V1495.
            CAEN programming requires an 'rbf' file, usb-blaster
            required an 'sof' file.
      -v, --vme
            16 most significant bits of the VME address (the value
            set by the rotary switches on the board).
            Not required for usb-blaster programming.
      -a, --arg
            Arguments for connection. For CAEN programming, use the
            USB device number. For usb-blaster, run 'jtagconfig' and
            use the text between '[' and ']' for the appropriate device
      -h, --help
            Print this help
```

# Simulation

A simulation of the firmware is provided in [the simulation directory](./simulation)
