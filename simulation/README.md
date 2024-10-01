# Simulation of V1495 firmware

This directory contains a simulation of the V1495 using questasim.

## Running

Open questasim by running `vsim` at the bash command line.
Once questasim is open, run `source run.tcl` at the questasim command line.
This will compile all the VHDL source file for the project.
Once compilation is finished, type `run 100us` to run the simulation

## Description

The file `dataGenerator.vhd` provides a data source for the simulation.
It generates 10ns pulses with random time intevals between each pulse on all the channels of the A, B, and D inputs to the firmware.

The simulation doesn't cover the register iterface to the VME backplane.
Instead, registers are set using a python script.

## Setting registers

A script is provided to convert a register `.json` file created by the [Trigger config tool](https://github.com/WCTE/TriggerConfig) into a VHDL file.
To use it, run

```
python3 sim_reg_gen.py {registers.json}
```

This will generate a file, `V1495_regs_communication_sim.vhd` which sits in place of `V1495_regs_communication.vhd` in the simulation



