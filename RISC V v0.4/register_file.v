module RegisterUnit(
  input         clk,
  // write port
  input         reg_write_en,
  input  [2:0]  rd, 
  input  [31:0] rd_value,
  //read port 1
  input  [2:0]  rs1,
  output [31:0] rs1_value,
  //read port 2
  input  [2:0]  rs2,
  output [31:0] rs2_value
  );
  
  // the actual registers
  reg    [31:0] reg_array [31:0];

  integer i;
  initial begin
    reg_array[0] = 32'hffff;
    for(i = 1; i <= 31; i = i + 1)
      reg_array[i] <= 32'd0;
  end
    
  always @ (posedge clk ) begin
    if (reg_write_en && (rd != 0)) begin
      reg_array[rd] <= rd_value;
    end
  end
  
  assign rs1_value = (rs1 == 0) ? 0 : reg_array[rs1];
  assign rs2_value = (rs2 == 0) ? 0 : reg_array[rs2];

endmodule