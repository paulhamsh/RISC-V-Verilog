// data_addr_bits is the number of bits in the address
// so size_data = 7, gives row_d of 128 addressable rows (0..127) (each of 1 byte)
// and given we have 4 banks, this means each bank has 32 bytes 

`define data_addr_bits      7             
`define bank_data_bits      (`data_addr_bits - 2)                
`define total_data_bytes    (1 << `data_addr_bits)              
`define bank_data_bytes     (1 << `bank_data_bits)

//`define size_data 5
//`define row_d (1 << `size_data)


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
  // four banks, A is msb and D is lsb
  //reg [31:0] memory [`row_d-1:0];

  reg [7:0] memA [`bank_data_bytes - 1:0];
  reg [7:0] memB [`bank_data_bytes - 1:0];
  reg [7:0] memC [`bank_data_bytes - 1:0];
  reg [7:0] memD [`bank_data_bytes - 1:0];
         
  // this needs to split the address range into highest `data_addr_bits-3 and bottom 2 bits    
  wire [`data_addr_bits - 3:0] bank_addr;   // don't need the bottom two bits - that is the bank
  wire [1:0] bank_sel;
  
  // this needs to span the entire address range of [`data_addr_bits-1 : 0]
  // and will also wrap addresses outside of this range into the range
  assign bank_addr = mem_access_addr[`data_addr_bits - 1 : 2];
  assign bank_sel  = mem_access_addr[1:0];
  
  // wire [`data_addr_bits - 1:0] ram_addr;
  // memory access will wrap at the limit of the number of bytes   
  
  //wire [`size_data-1:0] ram_addr = mem_access_addr[`size_data + 1 : 2];
  
  //assign ram_addr = mem_access_addr[`data_addr_bits - 1 : 2];
  //assign ram_addr = mem_access_addr[`data_addr_bits - 1 : 0];
  //assign ram_offset = mem_access_addr[1:0];
      
  // memory access will wrap at the limit of the number of words, and is word aligned so we ignore the lower two bits
//  wire [`size_data - 1:0] ram_addr = mem_access_addr[`size_data + 1:2];
  //wire [`size_data-1:0] ram_addr = mem_access_addr[`size_data-1:0];
  
    
  initial
    begin
      //$readmemb("test_risc_data_b.mem", memory);
      //$readmemb("test_data4.mem", memory);
      //$readmemb("risc_io_data_b.mem", memory);
      
      // byte bank memory
      
      $readmemb("risc_io_ramA.mem", memA);      
      $readmemb("risc_io_ramB.mem", memB);      
      $readmemb("risc_io_ramC.mem", memC);      
      $readmemb("risc_io_ramD.mem", memD);
      
      /*
      $readmemb("test_risc_ramA.mem", memA);      
      $readmemb("test_risc_ramB.mem", memB);      
      $readmemb("test_risc_ramC.mem", memC);      
      $readmemb("test_risc_ramD.mem", memD);
      */         
    end
  
  always @(posedge clk) begin
    if (mem_write_en)
      begin  
        //memory[ram_addr] <= mem_in;
        
        /*
        memA[bank_addr] <= mem_in[31:24];
        memB[bank_addr] <= mem_in[23:16];
        memC[bank_addr] <= mem_in[15:8];
        memD[bank_addr] <= mem_in[7:0]; 
        */
        
        case (mem_data_size)
          3'b000:
            case (bank_sel)
              2'b00:    memD[bank_addr] <= mem_in[7:0];
              2'b01:    memC[bank_addr] <= mem_in[7:0];
              2'b10:    memB[bank_addr] <= mem_in[7:0];
              2'b11:    memA[bank_addr] <= mem_in[7:0];              
             endcase
          3'b001:
            case (bank_sel)
            2'b00, 2'b01:   // only allow half-word aligned writes - ignore the lower bit
              begin
                memD[bank_addr] <= mem_in[7:0];
                memC[bank_addr] <= mem_in[15:8];
              end
            2'b10, 2'b11:
              begin
                memB[bank_addr] <= mem_in[7:0];
                memA[bank_addr] <= mem_in[15:8];
              end              
            endcase
          default: // really 3'b010
            begin
              memD[bank_addr] <= mem_in[7:0];
              memC[bank_addr] <= mem_in[15:8];
              memB[bank_addr] <= mem_in[23:16];
              memA[bank_addr] <= mem_in[31:24];
            end
        endcase
      end
  end
  // assign mem_out = (mem_read_en == 1'b1) ? memory[ram_addr]: 32'd0; 
  // assign mem_out = (mem_read_en == 1'b1) ? {memA[bank_addr], memB[bank_addr], memC[bank_addr], memD[bank_addr]}: 32'd0;

  reg [31:0] mem_temp;
  
  always @(*) begin
    if (mem_read_en)
      case (mem_data_size)
        3'b000:          // lb
          case (bank_sel)
            2'b00:       mem_temp = { {24{ memD[bank_addr][7] }},                         memD[bank_addr]};   
            2'b01:       mem_temp = { {24{ memC[bank_addr][7] }},                         memC[bank_addr]};  
            2'b10:       mem_temp = { {24{ memB[bank_addr][7] }},                         memB[bank_addr]};  
            2'b11:       mem_temp = { {24{ memA[bank_addr][7] }},                         memA[bank_addr]}; 
          endcase
        3'b100:           // lbu 
          case (bank_sel)
            2'b00:        mem_temp = { 24'b0,                                             memD[bank_addr]};   
            2'b01:        mem_temp = { 24'b0,                                             memC[bank_addr]};   
            2'b10:        mem_temp = { 24'b0,                                             memB[bank_addr]};  
            2'b11:        mem_temp = { 24'b0,                                             memA[bank_addr]};   
          endcase
       3'b001:            // lh
          case (bank_sel) 
            2'b00, 2'b01: mem_temp = { {16{ memC[bank_addr][7]}},        memC[bank_addr], memD[bank_addr]}; 
            2'b10, 2'b11: mem_temp = { {16{ memA[bank_addr][7]}},        memA[bank_addr], memB[bank_addr]};   
          endcase
       3'b101: 
          case (bank_sel) // lhu
            2'b00, 2'b01: mem_temp = { 16'b0,                            memC[bank_addr], memD[bank_addr]};   
            2'b10, 2'b11: mem_temp = { 16'b0,                            memA[bank_addr], memB[bank_addr]};  
          endcase
        default:          // lw      really 3010
                          mem_temp = { memA[bank_addr], memB[bank_addr], memC[bank_addr], memD[bank_addr]};  
      endcase
    else
      mem_temp = 32'd0;
  end  
  
  assign mem_out = mem_temp;

endmodule


  /*
  
    // cannot use readmemb to load up 4 banks    
  
  integer fd;
  integer cnt;
  reg [31:0] value;
  integer loc;
  
  initial
    begin
      //fd = $fopen("test_risc_data_b.mem", "r");
      fd = $fopen("risc_io_data_b.mem", "r");
      if (fd == 0)
        begin
          $display("Could not open data file");
          $finish;
        end
      $display("Loading RAM....");
      loc = 0;
      while (!$feof(fd)) 
        begin
          cnt = $fscanf(fd, "%b\n", value);
          
          if (cnt > 0) 
            begin
              $display("%4d %8h", loc, value);
              memA[loc] = value[31:24];
              memB[loc] = value[23:16];
              memC[loc] = value[15:8];
              memD[loc] = value[7:0];             
              loc = loc + 1;
            end
        end
      $fclose(fd);
    end
  */

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