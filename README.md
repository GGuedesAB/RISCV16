# RISCV16
This repository has a custom implementation of a 16 bit processor I called RISCV16. It has a very humble ISA with only 10 instructions. It is quite enough to have some fun writing complex algorithms to solve simple problems, like the modular division example, given in /Tests/.
## RISCV16 Schematic
This is a sketch of the organization in rv16r.v module.
![RISCV16 Schematic](/Doc/images/RISCV16_schematic.png)
## Instruction Table
Table of implemented instructions with control information (register addressing, ALU operation identifier).
![Instruction Table](/Doc/images/instruction_table.png)