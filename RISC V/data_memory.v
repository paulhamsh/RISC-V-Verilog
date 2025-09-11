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
         
  // this needs to split the address range into highest `data_addr_bits-3 
  // and bottom 2 bits    
  
  wire [`data_addr_bits - 3:0] word_addr, next_addr;  
  wire [1:0] bank_sel;
  
  // this needs to span the entire address range of [`data_addr_bits-1 : 0]
  // and will also wrap addresses outside of this range into the range
  
  assign word_addr = mem_access_addr[`data_addr_bits - 1 : 2];
  assign next_addr = word_addr + 1;
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
    if (mem_write_en) begin  
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
            2'b00: begin
              memD[word_addr] <= mem_in[7:0];
              memC[word_addr] <= mem_in[15:8];
            end
            2'b01: begin
              memC[word_addr] <= mem_in[7:0];
              memB[word_addr] <= mem_in[15:8];
            end
            2'b10: begin
              memB[word_addr] <= mem_in[7:0];
              memA[word_addr] <= mem_in[15:8];
            end
            2'b11: begin
              memA[word_addr] <= mem_in[7:0];
              memD[next_addr] <= mem_in[15:8];   // next row of memory
            end
          endcase
        default: // really 3'b010
          case (bank_sel)
            2'b00: begin
              memD[word_addr] <= mem_in[7:0];
              memC[word_addr] <= mem_in[15:8];
              memB[word_addr] <= mem_in[23:16];
              memA[word_addr] <= mem_in[31:24];
            end
            2'b01: begin
              memC[word_addr] <= mem_in[7:0];
              memB[word_addr] <= mem_in[15:8];
              memA[word_addr] <= mem_in[23:16];
              memD[next_addr] <= mem_in[31:24];
            end
            2'b10: begin
              memB[word_addr] <= mem_in[7:0];
              memA[word_addr] <= mem_in[15:8];
              memD[next_addr] <= mem_in[23:16];
              memC[next_addr] <= mem_in[31:24];
            end
            2'b11: begin
              memA[word_addr] <= mem_in[7:0];
              memD[next_addr] <= mem_in[15:8];
              memC[next_addr] <= mem_in[23:16];
              memB[next_addr] <= mem_in[31:24];
            end
          endcase
      endcase
    end
  end

  reg [31:0] mem_uns;
  
  always @(*) begin
    //if (mem_read_en)
      case (mem_data_size)
        3'b000, 3'b100:   // lb?
          case (bank_sel)
            2'b00: mem_uns = { 24'b0, memD[word_addr] };   
            2'b01: mem_uns = { 24'b0, memC[word_addr] };   
            2'b10: mem_uns = { 24'b0, memB[word_addr] };  
            2'b11: mem_uns = { 24'b0, memA[word_addr] };   
          endcase
        3'b001, 3'b101:   // lh?
          case (bank_sel) 
            2'b00: mem_uns = { 16'b0, memC[word_addr], memD[word_addr] };
            2'b01: mem_uns = { 16'b0, memB[word_addr], memC[word_addr] };   
            2'b10: mem_uns = { 16'b0, memA[word_addr], memB[word_addr] };
            2'b11: mem_uns = { 16'b0, memD[next_addr], memA[word_addr] };  
          endcase
        default:  
          case (bank_sel) 
            2'b00: mem_uns = { memA[word_addr], memB[word_addr], memC[word_addr], memD[word_addr] }; 
            2'b01: mem_uns = { memD[next_addr], memA[word_addr], memB[word_addr], memC[word_addr] }; 
            2'b10: mem_uns = { memC[next_addr], memD[next_addr], memA[word_addr], memB[word_addr] }; 
            2'b11: mem_uns = { memB[next_addr], memC[next_addr], memD[next_addr], memA[word_addr] };
          endcase
      endcase
      
    //else
    //  mem_uns = 32'd0;
  end  

  // make the number sign extended if required
  always @(*) begin
    case (mem_data_size)
      3'b000:  mem_out = { {24{ mem_uns[7]  }},  mem_uns[7:0]  };   
      3'b001:  mem_out = { {16{ mem_uns[15] }},  mem_uns[15:0] };  
      default: mem_out = mem_uns; 
    endcase
  end

/*
  // ******************************************
  // ** MEMORY IS 4 BANKS EACH ONE BYTE WIDE **
  // ******************************************
     
  // four banks, A is msb and D is lsb

  reg [7:0] memA [`bank_data_bytes - 1:0];
  reg [7:0] memB [`bank_data_bytes - 1:0];
  reg [7:0] memC [`bank_data_bytes - 1:0];
  reg [7:0] memD [`bank_data_bytes - 1:0];
         
  // this needs to split the address range into highest `data_addr_bits-3 
  // and bottom 2 bits    
  
  wire [`data_addr_bits - 3:0] word_addr;  
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
            2'b00, 2'b01:   // only allow half-word aligned writes 
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
*/
`else
  // *************************************
  // ** MEMORY IS ONE BANK 32 BITS WIDE **
  // *************************************
  
  reg [31:0] mem [`data_bytes - 1:0];
         
  // this needs to split the address range into highest `data_addr_bits-3 
  // and bottom 2 bits    
  
  wire [`data_addr_bits - 3:0] word_addr;   
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
              2'b00:      mem[word_addr][7:0]   <= mem_in[7:0];
              2'b01:      mem[word_addr][15:8]  <= mem_in[7:0];
              2'b10:      mem[word_addr][23:16] <= mem_in[7:0];
              2'b11:      mem[word_addr][31:24] <= mem_in[7:0];              
             endcase
          3'b001:
            case (byte_sel)
            2'b00, 2'b01: mem[word_addr][15:0]  <= mem_in[15:0];
            2'b10, 2'b11: mem[word_addr][31:16] <= mem_in[15:0];
             endcase
          default:        mem[word_addr] <= mem_in;
        endcase
      end
  end

 
  always @(*) begin
    if (mem_read_en)
      case (mem_data_size)
        3'b000:          // lb
          case (byte_sel)
            2'b00:        mem_out = { {24{ mem[word_addr][7]  }}, mem[word_addr][7:0]};   
            2'b01:        mem_out = { {24{ mem[word_addr][15] }}, mem[word_addr][15:8]};  
            2'b10:        mem_out = { {24{ mem[word_addr][23] }}, mem[word_addr][23:16]};  
            2'b11:        mem_out = { {24{ mem[word_addr][31] }}, mem[word_addr][31:24]}; 
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
        default:          mem_out = mem[word_addr];  
      endcase
    else
      mem_out = 32'd0;
  end  

`endif

endmodule
