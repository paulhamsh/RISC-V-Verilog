`include "settings.vh"

`define instr_addr_bits       $clog2(`instr_bytes)

module InstructionMemory(
  input  [31:0] pc,
  output [31:0] instruction
  );

  // create the memory
  reg [31:0] memory [`instr_addr_bits - 1:0];
  
  // memory access will wrap at the limit of the number of words, and is word aligned so we ignore the lower two bits
  wire [`instr_addr_bits - 1 : 0] rom_addr = pc[`instr_addr_bits + 1 : 2];
  
  initial
    begin
      `ifdef IO_DEMO
         $readmemb("risc_io_prog.mem", memory);
      `else
         $readmemb("risc_io_prog.mem", memory);
       `endif
    end
  
  assign instruction = memory[rom_addr]; 
endmodule