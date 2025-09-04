// size_data is the number of bits in the address
// row_d is the number of rows that allows
// so size_data = 7, gives row_d of 128 addressable rows (0..127) (each of 1 byte)

`define data_addr_bits      7                             
`define data_bytes       (1 << `data_addr_bits)              



`define size_data 5
`define row_d (1 << `size_data)

module DataMemory(
  input clk,
  // address input, shared by read and write port
  input [31:0]   mem_access_addr,
  input [31:0]   mem_in,
  input          mem_write_en,
  input          mem_read_en,
  input [2:0]    mem_data_size,  
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
      $readmemb("test_data4.mem", memory);
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




/*
module DataMemory(
  input             clk,
  input      [31:0] mem_access_addr,
  input      [31:0] mem_in,
  input             mem_write_en,
  input             mem_read_en,
  input       [2:0] mem_data_size, 
  output reg [31:0] mem_out
  );

  reg  [7:0] memory[`data_bytes - 1 : 0];
  
  wire [`data_addr_bits - 1:0] ram_addr;
  // memory access will wrap at the limit of the number of bytes   
  assign ram_addr = mem_access_addr[`data_addr_bits - 1 : 0];
  
  initial
    begin
      $readmemb("risc_io_data.mem", memory);
    end

  always @(posedge clk) begin
    if (mem_write_en)
      case (mem_data_size)
        3'b000:                      // sb
          begin
            memory[ram_addr]     <= mem_in[7:0];
          end     
         3'b001:                     // sh
          begin
            memory[ram_addr]     <= mem_in[7:0];
            memory[ram_addr + 1] <= mem_in[15:8];
          end      
        3'b010:                      // sw
          begin
            memory[ram_addr]     <= mem_in[7:0];
            memory[ram_addr + 1] <= mem_in[15:8];
            memory[ram_addr + 2] <= mem_in[23:16];
            memory[ram_addr + 3] <= mem_in[31:24];           
          end
        default:
          begin
            memory[ram_addr]     <= mem_in[7:0];
            memory[ram_addr + 1] <= mem_in[15:8];
            memory[ram_addr + 2] <= mem_in[23:16];
            memory[ram_addr + 3] <= mem_in[31:24];
          end
      endcase
  end
  
  //reg [31:0] data;  
   
  always @(*) begin
    if (mem_read_en)
      case (mem_data_size)
        3'b000:  mem_out = { {24{ memory[ram_addr][7] }}                                     , memory[ram_addr]};   // lb
        3'b001:  mem_out = { {16{ memory[ram_addr + 1][7]}} ,            memory[ram_addr + 1], memory[ram_addr]};   // lh
        3'b010:  mem_out = { memory[ram_addr + 3], memory[ram_addr + 2], memory[ram_addr + 1], memory[ram_addr]};   // lw
        3'b100:  mem_out = { 24'b0 ,                                                           memory[ram_addr]};   // lbu
        3'b101:  mem_out = { 16'b0 ,                                     memory[ram_addr + 1], memory[ram_addr]};   // lhu    
        default: mem_out = { memory[ram_addr + 3], memory[ram_addr + 2], memory[ram_addr + 1], memory[ram_addr]};   // default = lw
      endcase
    else
      mem_out = 32'd0;
  end  
endmodule
*/


