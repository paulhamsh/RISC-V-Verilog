`define size_inst 5
`define row_i (1 << `size_inst)

module InstructionMemory(
  input  [31:0] pc,
  output [31:0] instruction
  );

  // create the memory
  reg [31:0] memory [`row_i-1:0];
  
  // memory access will wrap at the limit of the number of words
  wire [31:0] rom_addr = pc[`size_inst - 1 : 0];
  
  initial
    begin
      $readmemb("test_prog2.mem", memory);
    end
  
  assign instruction = memory[rom_addr]; 

endmodule