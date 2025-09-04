module BranchComp(
  input [31:0] a,
  input [31:0] b,
  input [2:0]  branch_cond,
  output reg   branch);
  
always @(*)
  case (branch_cond)
    
    3'b000:  branch = (a == b) ? 1 : 0;
    3'b001:  branch = (a != b) ? 1 : 0;
    
    3'b110:  branch = (a <  b) ? 1 : 0;
    3'b111:  branch = (a >= b) ? 1 : 0;
    3'b100:  branch = ($signed(a) <  $signed(b)) ? 1 : 0;
    3'b101:  branch = ($signed(a) >= $signed(b)) ? 1 : 0;
    
    3'b010:  branch = 0;    // no branch
    3'b011:  branch = 1;    // always branch 
    default: branch = 0;    // no branch
  endcase
endmodule
