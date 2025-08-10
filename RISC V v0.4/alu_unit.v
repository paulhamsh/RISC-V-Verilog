

module ALU(
  input  [31:0]     a,  //src1
  input  [31:0]     b,  //src2
  input  [3:0]      alu_control, //function sel
 
  output reg [31:0] result,  //result 
  output            zero
  );

  always @(*)
    begin 
      case(alu_control)
        4'b0000:  result = a + b;   // add
        4'b0001:  result = a - b;   // sub
        4'b0010:  result = ~a;
        4'b0011:  result = a << b;
        4'b0100:  result = a >> b;
        4'b0101:  result = a & b;   // and
        4'b0110:  result = a | b;   // or
        4'b0111:  if (a < b) 
                    result = 32'd1;
                  else 
                    result = 32'd0;
        4'b1000:  result = b;       // lui
        default:  result = a + b;   // add
      endcase
    end 

  assign zero = (result == 32'd0) ? 1'b1: 1'b0;
endmodule