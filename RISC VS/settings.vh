`ifndef SETTINGS_H
`define SETTINGS_H

// PROGRAM CHOICE
// There are two base programs, risc_io_prog and test_risc_prog
// risc_io_prog reads the switches and buttons (on a Nexys 4 DDR) 
// and reflects that on the LEDS
// test_risc_prog runs a basic RISC V program to check the results
// IO_DEMO selects risc_io_prog else test_risc_prog is used

`define IO_DEMO

// MEMORY SETTINGS
// Memory can be either 4 banks each of width one byte, or one array of 32 bit words
// BANKED_MEM selects the 4 banks 

`define FULL_MEM
//`define ALIGNED_MEM
//`define BASIC_MEM


`define SYNCHRONOUS_MEM

// Select the size (in bytes) of data memory and instruction memory
`define data_bytes       128
`define instr_bytes      128

// TESTBENCH SETTINGS

// PROG_BASIC   will run the program in instruction memory for 200 steps - 
//              works for any program
// PROG_STEPPED will run each line and check the output 
//              (requires test_risc_prog so best to use with IO_DEMO undefined)
// PROG_INDIV   will run specific commands and is not dependent on 
//              data memory or instruction memory being initialised

`define PROG_BASIC 

//`define PROG_STEPPED
//`undef IO_DEMO

//`define PROG_INDIV

`endif