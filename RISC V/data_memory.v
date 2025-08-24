// size_data is the number of bits in the address
// row_d is the number of rows that allows
// so size_data = 7, gives row_d of 128 addressable rows (0..127) (each of 1 byte)

`define data_addr_bits      7                             
`define data_bytes       (1 << `data_addr_bits)              

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
      $readmemb("test_data.mem", memory);
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
        3'b001:  mem_out = { {16{ memory[ram_addr + 1][7 ]}} ,           memory[ram_addr + 1], memory[ram_addr]};   // lh
        3'b010:  mem_out = { memory[ram_addr + 3], memory[ram_addr + 2], memory[ram_addr + 1], memory[ram_addr]};   // lw
        3'b100:  mem_out = { 24'b0 ,                                                           memory[ram_addr]};   // lbu
        3'b101:  mem_out = { 16'b0 ,                                     memory[ram_addr + 1], memory[ram_addr]};   // lhu    
        default: mem_out = { memory[ram_addr + 3], memory[ram_addr + 2], memory[ram_addr + 1], memory[ram_addr]};   // default = lw
      endcase
    else
      mem_out = 32'd0;
  end  
endmodule