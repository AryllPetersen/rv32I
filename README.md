# rv32I

![schematic](https://github.com/AryllPetersen/rv32I/blob/main/schematic.png?raw=true)

# Running Code Example

Enter /example and run `make`. It will run the simulation where it prints out each step the CPU is doing and will stop when it gets an ecall instruction. Afterwards, the DATA and BSS memory sections are printed.

## Example code
![code](https://github.com/AryllPetersen/rv32I/blob/main/code.jpg?raw=true)

## Example output
![output](https://github.com/AryllPetersen/rv32I/blob/main/output.jpg?raw=true)

## what does each file in /example do?

- example.c: Dummy code for the processor to run.
- example.txt: a text file containing the machine code in 1s and 0s to be loaded into Memory.sv
- example_raw.txt: unparsed example.txt, contains unnecessary info.
- objdump.txt: Information containing the address and size of each section, this information is put into command line arguments when running the simulation.
- asm.txt: The Dissassembled executable containing assembly instructions.


