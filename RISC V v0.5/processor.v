module Risc32(
  input         clk,
  output [31:0] io_address,
  output [31:0] io_write_value,
  input  [31:0] io_read_value,
  output        io_write_en,
  output        io_read_en,
  output [2:0]  io_data_size
  );
  
  // Control unit signals
  wire [2:0] cu_branch_cond;
  wire       cu_data_read_en;
  wire       cu_data_write_en;
  wire [2:0] cu_data_size;
  wire [1:0] cu_mem_to_reg; 
  wire       cu_reg_write_en;
  wire       cu_alu_b_src; 
  wire       cu_alu_a_src;
  wire [3:0] cu_alu_op;

  
  // Opcode from datapath to control unit
  wire [6:0] dp_opcode;
  wire [6:0] dp_funct7;
  wire [2:0] dp_funct3;
  
  // Datapath
  DatapathUnit datapath
  (
    .clk(clk),
    .branch_cond(cu_branch_cond),
    .data_read_en(cu_data_read_en),
    .data_write_en(cu_data_write_en),
    .alu_b_src(cu_alu_b_src),
    .alu_a_src(cu_alu_a_src),
    .mem_to_reg(cu_mem_to_reg),
    .reg_write_en(cu_reg_write_en),
    .alu_op(cu_alu_op),
    .data_size(cu_data_size),
    .opcode(dp_opcode),
    .funct7(dp_funct7),
    .funct3(dp_funct3),
    .io_address(io_address),
    .io_write_value(io_write_value),
    .io_read_value(io_read_value),
    .io_write_en(io_write_en),
    .io_read_en(io_read_en),
    .io_data_size(io_data_size)
  );
 
  // control unit
  ControlUnit control
  (
    .opcode(dp_opcode),
    .funct7(dp_funct7),
    .funct3(dp_funct3),    
    .mem_to_reg(cu_mem_to_reg),
    .alu_op(cu_alu_op),
    .branch_cond(cu_branch_cond),
    .data_read_en(cu_data_read_en),
    .data_write_en(cu_data_write_en),
    .data_size(cu_data_size),
    .alu_b_src(cu_alu_b_src),
    .alu_a_src(cu_alu_a_src),
    .reg_write_en(cu_reg_write_en)
  );

endmodule

