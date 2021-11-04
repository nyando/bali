# Bali - Minimized Java Processor

Bali is a CPU implementation able to natively execute a subset of Java bytecode.
Written in the Verilog HDL, it supports the following:

- 32-bit integer arithmetic and logic operations
- static array handling
- static method handling

This allows a user to execute code in a single class with static methods.

## Development Environment

Bali is developed in Verilog in the Xilinx Vivado IDE.
Tests will be run on a Digilent Arty A7 development board with an Artix-7 35T FPGA.

## Testing

Tests will consist of a variety of Java programs with the above limitations.
Current tests include the following:

- `IntReverse` - Given an integer input, output the decimal base reverse integer.
- `PrimeSieve` - Simple Sieve of Eratosthenes implementation, outputting an array of booleans with `true` for prime numbers and `false` for non-primes.
- `QuickSort` - QuickSort implementation for 32-bit integer arrays.
- `RecursiveMath` - Implementation of 32-bit integer addition and multiplication using recursive definitions down to increment/decrement.
- `TowersOfHanoi` - Recursive solution for Towers of Hanoi.

## Simulation

To run a module simulation or testbench:

- open the `Makefile` in the project root
- change the `SIM_MODULE` variable to your desired top-level DUT module
- add the necessary design source files to `SV_SOURCES`
- add the necessary simulation source files to `SV_SIMS`
- run `make simulate` in the root project directory for CLI-only output, or `make simulate_gui` to view waveform results

## Programming the FPGA

To program the FPGA with a desired module, plug it into your PC, then:

- open the `Makefile` in the project root
- change the `MODULE_NAME` variable to your desired top-level module
- when using a different device from the one listed above, change `BOARD_NAME` and `DEVICE_NAME` accordingly
- run `make program` in the root project directory
