# Project Description

A RISCV 32 Base Integer CPU created in SystemVerilog. All user mode instructions have been implemented, ecall / ebreak is not implemented. The Design was verified by building an Alu testbench ([Alu_tb.sv](https://github.com/AryllPetersen/rv32I/blob/main/Alu_tb.sv)) and a Control Unit testbench ([ControlUnit_tb.sv](https://github.com/AryllPetersen/rv32I/blob/main/ControlUnit_tb.sv)). It was further verified by running machine code on it, the compiler used can be found [here](https://xpack-dev-tools.github.io/riscv-none-elf-gcc-xpack/docs/install/) and details of running the code yourself are in the [Running Code Example](#running-code-example) section.

## Schematic
![schematic](https://github.com/AryllPetersen/rv32I/blob/main/schematic.png?raw=true)

# Running Testbenches
### 1. Clone the repo
```
git clone https://github.com/AryllPetersen/rv32I.git
```
```
cd rv32I
```
ALU Testbench
```
vcs -sverilog rv32I.svh Alu.sv Alu_tb.sv 
```
Control Unit Testbench
```
vcs -sverilog rv32I.svh ControlUnit.sv ControlUnit_tb.sv
```

# Code Example

To help verify the design, a simple C program was compiled and loaded into the design's memory for the CPU to run. Since there is no printf, the program's output were assigned to global variables which can be viewed by printing the BSS and DATA sections after the program finished running. Here are screenshots of it working.

## Example code
The C code that was compiled for the CPU design to execute.

![code](https://github.com/AryllPetersen/rv32I/blob/main/code.jpg?raw=true)

## Example output
A screenshot of the terminal output after running the simulation. The results of the above example program can be seen in the SDATA memory section.

![output](https://github.com/AryllPetersen/rv32I/blob/main/output_v2.jpg?raw=true)

## Running the example yourself

### 1. Clone the repo
```
git clone https://github.com/AryllPetersen/rv32I.git
```
```
cd rv32I
```

### 2. (Optional) Compile the design with vcs
the simv file is already included so this step isn't necessary. There are two Makefiles make sure you are in the /rv32I directory.
```
make
```

### 3. Run the simv file. 
There are two Makefiles make sure you are in the /rv32I/example directory.
```
cd example
```
Do not run `make clean` unless you plan on compiling your own code. The make file will parse the already compiled code example's executable for the section sizes and addresses and places them in command line args and then runs the simulation. 
```
make
```
The simulation will print each step the CPU is doing such as loading instruction, loading value from memory, writting value to memory. There are three ways the simulation could end, the cpu reads an ecall instruction and will print "ecall instruction found. Program Finished". Or the cpu reads an instruction it can't decode and will print "CPU Halted. Program Finished". Or the simulation will timeout after 100,000 clock cycles(10 time units per cycle). 
Once the simulation is finished it should look like the [Example Output](#example-output) Screenshot above.

### 4. Running your own code on the design
You would need to install the compiler linked [here](https://xpack-dev-tools.github.io/riscv-none-elf-gcc-xpack/docs/install/). Once you do open the Makefile in /rv32I/example/Makefile and modify the variable `$LIBPATH` to be the location of the compiler. You will then run `make clean` before running `make`.


## what does each file in /example do?

- example.c: Dummy code for the processor to run.
- example.txt: a text file containing the machine code in 1s and 0s to be loaded into Memory.sv
- example_raw.txt: unparsed example.txt, contains unnecessary info.
- objdump.txt: Information containing the address and size of each section, this information is put into command line arguments when running the simulation.
- asm.txt: The Dissassembled executable containing assembly instructions.


