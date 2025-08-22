// size_data is the number of bits in the address
// row_d is the number of rows that allows
// so size_data = 7, gives row_d of 128 addressable rows (0..127) (each of 1 byte)

`define data_addr_bits      7                             
`define data_bytes       (1 << `data_addr_bits)              

module DataMemory(
  input         clk,
  input  [31:0] mem_access_addr,
  input  [31:0] mem_in,
  input         mem_write_en,
  input         mem_read_en,
  output [31:0] mem_out
  );

  reg  [7:0] memory[`data_bytes - 1 : 0];
  
  wire [`data_addr_bits - 1:0] ram_addr;
  // memory access will wrap at the limit of the number of bytes   
  assign ram_addr = mem_access_addr[`data_addr_bits - 1 : 0];
  
  initial
    begin
      $readmemb("test_data.mem", memory);
      
      //$monitor("Ram changed\n",
      //"\tmemory[0] = %b\n", memory[0],
      //"\tmemory[1] = %b\n", memory[1],
      //"\tmemory[2] = %b\n", memory[2]);    
    end
 
  always @(posedge clk) begin
    if (mem_write_en)
      begin  
        memory[ram_addr]     <= mem_in[7:0];
        memory[ram_addr + 1] <= mem_in[15:8];
        memory[ram_addr + 2] <= mem_in[23:16];
        memory[ram_addr + 3] <= mem_in[31:24];
      end
  end
  assign mem_out = (mem_read_en == 1'b1) ? { memory[ram_addr+3], memory[ram_addr+2], memory[ram_addr+1], memory[ram_addr] }: 32'd0; 

endmodule