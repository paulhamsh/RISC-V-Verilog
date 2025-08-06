`timescale 1ns / 1ps

module Risc32(
  input         clk,
  output [31:0] io_address,
  output [31:0] io_write_value,
  input  [31:0] io_read_value,
  output        io_write_en,
  output        io_read_en
  );
  
  // Control unit signals
  wire       cu_jump, cu_bne, cu_beq; 
  wire       cu_data_read_en, cu_data_write_en;
  wire       cu_mem_to_reg, cu_reg_write_en;
  wire [1:0] cu_alu_src; 
  wire [3:0] cu_alu_op;
  
  // Opcode from datapath to control unit
  wire [6:0] opcode;
  
  // Datapath
  DatapathUnit datapath
  (
    .clk(clk),
    .jump(cu_jump),
    .beq(cu_beq),
    .data_read_en(cu_data_read_en),
    .data_write_en(cu_data_write_en),
    .alu_src(cu_alu_src),
    .mem_to_reg(cu_mem_to_reg),
    .reg_write_en(cu_reg_write_en),
    .bne(cu_bne),
    .alu_op(cu_alu_op),
    .opcode(opcode),
    
    .io_address(io_address),
    .io_write_value(io_write_value),
    .io_read_value(io_read_value),
    .io_write_en(io_write_en),
    .io_read_en(io_read_en)
  );
 
  // control unit
  ControlUnit control
  (
    .opcode(opcode),
    .mem_to_reg(cu_mem_to_reg),
    .alu_op(cu_alu_op),
    .jump(cu_jump),
    .bne(cu_bne),
    .beq(cu_beq),
    .data_read_en(cu_data_read_en),
    .data_write_en(cu_data_write_en),
    .alu_src(cu_alu_src),
    .reg_write_en(cu_reg_write_en)
  );

endmodule

