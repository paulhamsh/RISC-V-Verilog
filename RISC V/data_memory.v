`include "settings.vh"

`define data_addr_bits      $clog2(`data_bytes)            
`define bank_data_bits      (`data_addr_bits - 2)                
`define bank_data_bytes     (`data_bytes >> 2)

module DataMemory(
  input clk,
  // address input, shared by read and write port
  input [31:0]   mem_access_addr,
  input [31:0]   mem_in,
  input          mem_write_en,
  input          mem_read_en,
  input [2:0]    mem_data_size,  
  output reg [31:0]  mem_out
  );


`ifdef BANKED_MEM
  // ******************************************
  // ** MEMORY IS 4 BANKS EACH ONE BYTE WIDE **
  // ******************************************
     
  // four banks, A is msb and D is lsb

  reg [7:0] memA [`bank_data_bytes - 1:0];
  reg [7:0] memB [`bank_data_bytes - 1:0];
  reg [7:0] memC [`bank_data_bytes - 1:0];
  reg [7:0] memD [`bank_data_bytes - 1:0];
         
  // this needs to split the address range into highest `data_addr_bits-3 and bottom 2 bits    
  wire [`data_addr_bits - 3:0] word_addr;   // don't need the bottom two bits - that is the bank
  wire [1:0] bank_sel;
  
  // this needs to span the entire address range of [`data_addr_bits-1 : 0]
  // and will also wrap addresses outside of this range into the range
  assign word_addr = mem_access_addr[`data_addr_bits - 1 : 2];
  assign bank_sel  = mem_access_addr[1:0];

  initial
    begin
      `ifdef IO_DEMO
         $readmemb("risc_io_ramA.mem", memA);      
         $readmemb("risc_io_ramB.mem", memB);      
         $readmemb("risc_io_ramC.mem", memC);      
         $readmemb("risc_io_ramD.mem", memD);
      `else
         $readmemb("test_risc_ramA.mem", memA);      
         $readmemb("test_risc_ramB.mem", memB);      
         $readmemb("test_risc_ramC.mem", memC);      
         $readmemb("test_risc_ramD.mem", memD);
      `endif        
    end
  
  always @(posedge clk) begin
    if (mem_write_en)
      begin  
        case (mem_data_size)
          3'b000:
            case (bank_sel)
              2'b00:    memD[word_addr] <= mem_in[7:0];
              2'b01:    memC[word_addr] <= mem_in[7:0];
              2'b10:    memB[word_addr] <= mem_in[7:0];
              2'b11:    memA[word_addr] <= mem_in[7:0];              
             endcase
          3'b001:
            case (bank_sel)
            2'b00, 2'b01:   // only allow half-word aligned writes - ignore the lower bit
              begin
                memD[word_addr] <= mem_in[7:0];
                memC[word_addr] <= mem_in[15:8];
              end
            2'b10, 2'b11:
              begin
                memB[word_addr] <= mem_in[7:0];
                memA[word_addr] <= mem_in[15:8];
              end              
            endcase
          default: // really 3'b010
            begin
              memD[word_addr]   <= mem_in[7:0];
              memC[word_addr]   <= mem_in[15:8];
              memB[word_addr]   <= mem_in[23:16];
              memA[word_addr]   <= mem_in[31:24];
            end
        endcase
      end
  end

 
  always @(*) begin
    if (mem_read_en)
      case (mem_data_size)
        3'b000:          // lb
          case (bank_sel)
            2'b00:       mem_out = { {24{ memD[word_addr][7] }},                         memD[word_addr]};   
            2'b01:       mem_out = { {24{ memC[word_addr][7] }},                         memC[word_addr]};  
            2'b10:       mem_out = { {24{ memB[word_addr][7] }},                         memB[word_addr]};  
            2'b11:       mem_out = { {24{ memA[word_addr][7] }},                         memA[word_addr]}; 
          endcase
        3'b100:           // lbu 
          case (bank_sel)
            2'b00:        mem_out = { 24'b0,                                             memD[word_addr]};   
            2'b01:        mem_out = { 24'b0,                                             memC[word_addr]};   
            2'b10:        mem_out = { 24'b0,                                             memB[word_addr]};  
            2'b11:        mem_out = { 24'b0,                                             memA[word_addr]};   
          endcase
       3'b001:            // lh
          case (bank_sel) 
            2'b00, 2'b01: mem_out = { {16{ memC[word_addr][7]}},        memC[word_addr], memD[word_addr]}; 
            2'b10, 2'b11: mem_out = { {16{ memA[word_addr][7]}},        memA[word_addr], memB[word_addr]};   
          endcase
       3'b101: 
          case (bank_sel) // lhu
            2'b00, 2'b01: mem_out = { 16'b0,                            memC[word_addr], memD[word_addr]};   
            2'b10, 2'b11: mem_out = { 16'b0,                            memA[word_addr], memB[word_addr]};  
          endcase
        default:          // lw      really 3010
                          mem_out = { memA[word_addr], memB[word_addr], memC[word_addr], memD[word_addr]};  
      endcase
    else
      mem_out = 32'd0;
  end  

`else
  // *************************************
  // ** MEMORY IS ONE BANK 32 BITS WIDE **
  // *************************************
  
  reg [31:0] mem [`data_bytes - 1:0];
         
  // this needs to split the address range into highest `data_addr_bits-3 and bottom 2 bits    
  wire [`data_addr_bits - 3:0] word_addr;   // don't need the bottom two bits - that is the bank
  wire [1:0] byte_sel;
  
  // this needs to span the entire address range of [`data_addr_bits-1 : 0]
  // and will also wrap addresses outside of this range into the range
  assign word_addr = mem_access_addr[`data_addr_bits - 1 : 2];
  assign byte_sel  = mem_access_addr[1:0];
   
  initial
    begin
       `ifdef IO_DEMO
          $readmemb("risc_io_mem_word.mem", mem);  
       `else
          $readmemb("test_risc_mem_word.mem", mem);  
       `endif
    end
  
  always @(posedge clk) begin
    if (mem_write_en)
      begin  
        case (mem_data_size)
          3'b000:
            case (byte_sel)
              2'b00:    mem[word_addr][7:0]   <= mem_in[7:0];
              2'b01:    mem[word_addr][15:8]  <= mem_in[7:0];
              2'b10:    mem[word_addr][23:16] <= mem_in[7:0];
              2'b11:    mem[word_addr][31:24] <= mem_in[7:0];              
             endcase
          3'b001:
            case (byte_sel)
            2'b00, 2'b01:   // only allow half-word aligned writes - ignore the lower bit
              begin
                mem[word_addr][15:0] <= mem_in[15:0];
              end
            2'b10, 2'b11:
              begin
                mem[word_addr][15:0] <= mem_in[31:16];
              end              
            endcase
          default: // really 3'b010
            begin
              mem[word_addr] <= mem_in;
            end
        endcase
      end
  end

 
  always @(*) begin
    if (mem_read_en)
      case (mem_data_size)
        3'b000:          // lb
          case (byte_sel)
            2'b00:       mem_out = { {24{ mem[word_addr][7]  }},  mem[word_addr][7:0]};   
            2'b01:       mem_out = { {24{ mem[word_addr][15] }},  mem[word_addr][15:8]};  
            2'b10:       mem_out = { {24{ mem[word_addr][23] }},  mem[word_addr][23:16]};  
            2'b11:       mem_out = { {24{ mem[word_addr][31] }},  mem[word_addr][31:24]}; 
          endcase
        3'b100:           // lbu 
          case (byte_sel)
            2'b00:        mem_out = { 24'b0,                      mem[word_addr][7:0]};   
            2'b01:        mem_out = { 24'b0,                      mem[word_addr][15:8]};   
            2'b10:        mem_out = { 24'b0,                      mem[word_addr][23:16]};  
            2'b11:        mem_out = { 24'b0,                      mem[word_addr][31:24]};   
          endcase
       3'b001:            // lh
          case (byte_sel) 
            2'b00, 2'b01: mem_out = { {16{ mem[word_addr][15]}},  mem[word_addr][15:0]}; 
            2'b10, 2'b11: mem_out = { {16{ mem[word_addr][31]}},  mem[word_addr][31:16]};   
          endcase
       3'b101: 
          case (byte_sel) // lhu
            2'b00, 2'b01: mem_out = { 16'b0,                      mem[word_addr][15:0]};   
            2'b10, 2'b11: mem_out = { 16'b0,                      mem[word_addr][31:16]};  
          endcase
        default:          // lw      really 3010
                          mem_out = mem[word_addr];  
      endcase
    else
      mem_out = 32'd0;
  end  

`endif

endmodule
