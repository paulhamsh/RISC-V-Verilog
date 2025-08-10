// size_inst is the number of bits in the address
// row_i is the number of rows that allows
// each row has a 32 bit value, so 4 bytes and therefore 4 address bytes
// but memory is word aligned in this version

// so size_data = 5, gives row_d of 32 addressable rows (each of 4 bytes, so 128 bytes of memory)

// to make address access word aligned, lose the last two bits
// to make it wrap at 128 bytes, only use the lower [`size_inst + 1 : 2] bits - so in this case, [33 : 2] 


`define size_inst 5
`define row_i (1 << `size_inst)

module InstructionMemory(
  input  [31:0] pc,
  output [31:0] instruction
  );

  // create the memory
  reg [31:0] memory [`row_i-1:0];
  
  // memory access will wrap at the limit of the number of words, and is word aligned so we ignore the lower two bits
  
  //wire [31:0] rom_addr = pc[`size_inst - 1 : 0];
  wire [`size_inst - 1 : 0] rom_addr = pc[`size_inst + 1 : 2];
  
  initial
    begin
      $readmemb("test_prog.mem", memory);
    end
  
  assign instruction = memory[rom_addr]; 

endmodule