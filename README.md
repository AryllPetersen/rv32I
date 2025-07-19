# Project Description

A RISCV 32 Base Integer CPU created in SystemVerilog. All user mode instructions have been implemented, ecall / ebreak is not implemented. The Design was verified by building an Alu testbench ([Alu_tb.sv](https://github.com/AryllPetersen/rv32I/blob/main/Alu_tb.sv)) and a Control Unit testbench ([ControlUnit_tb.sv](https://github.com/AryllPetersen/rv32I/blob/main/ControlUnit_tb.sv)). It was further verified by running machine code on it, the compiler used can be found [here](https://xpack-dev-tools.github.io/riscv-none-elf-gcc-xpack/docs/install/) and details of running the code yourself are in the [Running Code Example](#running-code-example) section.

## Schematic
![schematic](https://github.com/AryllPetersen/rv32I/blob/main/schematic.png?raw=true)

# Running Code Example

Enter /example and run `make`. It will run the simulation where it prints out each step the CPU is doing and will stop when it gets an ecall instruction. Afterwards, the DATA and BSS memory sections are printed.

## Example code
![code](https://github.com/AryllPetersen/rv32I/blob/main/code.jpg?raw=true)

## Example output
![output](https://github.com/AryllPetersen/rv32I/blob/main/output_v2.jpg?raw=true)

## what does each file in /example do?

- example.c: Dummy code for the processor to run.
- example.txt: a text file containing the machine code in 1s and 0s to be loaded into Memory.sv
- example_raw.txt: unparsed example.txt, contains unnecessary info.
- objdump.txt: Information containing the address and size of each section, this information is put into command line arguments when running the simulation.
- asm.txt: The Dissassembled executable containing assembly instructions.


