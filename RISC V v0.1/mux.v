module Mux2_32(
  input         sel,
  output [31:0] out,
  input  [31:0] in0,    // chosen when sel == 0
  input  [31:0] in1     // chosen when sel == 1
  );
  
  assign out = sel ? in1 : in0;
endmodule


module Mux4_32(
  input      [1:0]  sel,
  output reg [31:0] out,
  input      [31:0] in0,    // chosen when sel == 0
  input      [31:0] in1,    // chosen when sel == 1
  input      [31:0] in2,    // chosen when sel == 2
  input      [31:0] in3     // chosen when sel == 3
  );
     
  always @(*)
      begin 
        case(sel)
          2'b00:   out = in0;
          2'b01:   out = in1;
          2'b10:   out = in2;  
          2'b11:   out = in3;  
          default: out = in0;
        endcase
      end 
endmodule

module Mux4_3(
  input      [1:0]  sel,
  output reg [2:0] out,
  input      [2:0] in0,    // chosen when sel == 0
  input      [2:0] in1,    // chosen when sel == 1
  input      [2:0] in2,    // chosen when sel == 2
  input      [2:0] in3     // chosen when sel == 3
  );
     
  always @(*)
      begin 
        case(sel)
          2'b00:   out = in0;
          2'b01:   out = in1;
          2'b10:   out = in2;  
          2'b11:   out = in3;  
          default: out = in0;
        endcase
      end 
endmodule