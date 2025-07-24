// size_data is the number of bits in the address
// row_d is the number of rows that allows
// each row has a 32 bit value, so 4 bytes and therefore 4 address bytes
// but memory is word aligned in this version

// so size_data = 5, gives row_d of 32 addressable rows (each of 4 bytes, so 128 bytes of memory)

// to make address access word aligned, lose the last two bits
// to make it wrap at 128 bytes, only use the lower [`size_data + 1 : 2] bits - so in this case, [33 : 2] 

`define size_data 5
`define row_d (1 << `size_data)

// This implementation will use byte address word-aligned memory - so 32 bits but addresses will be per byte
// At the moment all memory access will be 32 bits, so all requests will be word aligned

module DataMemory(
  input clk,
  // address input, shared by read and write port
  input [31:0]   mem_access_addr,
 
  // write port
  input [31:0]   mem_in,
  input          mem_write_en,
  input          mem_read_en,
  // read port
  output [31:0]  mem_out
  );

  // create the memory
  reg [31:0] memory [`row_d-1:0];
  
  // memory access will wrap at the limit of the number of words, and is word aligned so we ignore the lower two bits
  wire [`size_data-1:0] ram_addr = mem_access_addr[`size_data + 1:2];
  //wire [`size_data-1:0] ram_addr = mem_access_addr[`size_data-1:0];
  
  // check to see if memory access or io port access
  //assign is_mem_access = ~mem_access_addr[15];
    
  initial
    begin
      $readmemb("test_data2.mem", memory);
    end
 
  always @(posedge clk) begin
    if (mem_write_en)
      begin  
        memory[ram_addr] <= mem_in;
        
        $display("Writing to RAM: memory[%d] = %b", ram_addr, mem_in);
      end
  end
  assign mem_out = (mem_read_en == 1'b1) ? memory[ram_addr]: 32'd0; 

endmodule