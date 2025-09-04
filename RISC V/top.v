`timescale 1ns / 1ps

module top(
  input      CLK100MHZ,
  input      [15:0] SW,
  input      [4:0]  BTN,
  output reg [15:0] LED
  ); 
  
  wire [31:0] io_address;
  wire [31:0] io_write_value;
  reg  [31:0] io_read_value;
  wire        io_write_en;
  wire        io_read_en;   
  wire [2:0]  io_data_size;

  Risc32 risc(
    .clk(CLK100MHZ),
    .io_address(io_address),
    .io_write_value(io_write_value),
    .io_read_value(io_read_value),
    .io_write_en(io_write_en),
    .io_read_en(io_read_en),
    .io_data_size(io_data_size)
    );
 
   always @(posedge CLK100MHZ)
      begin
  
        if (io_read_en)
          case (io_address[1:0])
            2'b01:  io_read_value <= {16'b0, SW};
            2'b10:  io_read_value <= {27'b0, BTN};
            default: io_read_value <= 32'b0;
          endcase
        
        if (io_write_en && io_address[2])   // bit 2 is set in the write address
          LED <= io_write_value[15:0];
        //LED <= {io_write_value[7:0], pc[5:0], io_read_en, io_write_en};
          
     end
 endmodule