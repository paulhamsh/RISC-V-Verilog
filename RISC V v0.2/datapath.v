`timescale 1ns / 1ps
// fpga4student.com 

module DatapathUnit(
  input         clk,
  input         jump, beq, bne, 
  input         data_read_en, data_write_en, 
  input         reg_write_en, mem_to_reg, 
  input  [1:0]  alu_src,
  input  [3:0]  alu_op,
  output [6:0]  opcode,
 
  output [31:0] io_address,
  output [31:0] io_write_value,
  input  [31:0] io_read_value,
  output        io_write_en,
  output        io_read_en
  );
  
  reg  [31:0] pc_current;
  wire [31:0] pc_next;

  wire [31:0] pc_plus_4;

  wire        branch_control;
      
  wire [31:0] instr;
  
  wire [2:0]  rd;
  wire [31:0] rd_value;
  wire [2:0]  rs1;
  wire [31:0] rs1_value;
  wire [2:0]  rs2;
  wire [31:0] rs2_value;
  
  wire [31:0] ext_imm;
  wire [31:0] alu_in;
  wire [31:0] alu_out;
  wire        zero_flag;

  wire [31:0] data_read_value;

  wire        is_io;

  wire [31:0] mem_address;
  wire [31:0] mem_read_value;
  wire [31:0] mem_write_value;
  wire        mem_read_en;
  wire        mem_write_en;

  // Note that io_address is part of the interface
  // Note that io_read_value is part of the interface
  // Note that io_write_value is part of the interface
  // Note that io_read_en is part of the interface
  // Not that  io_write_en are part of the interface
  
  ////
  //// Program counter
  ////
  
  initial begin
    pc_current <= 32'd0;
  end
 
  // Update to next PC on rising clock
  always @(posedge clk)
  begin 
    pc_current <= pc_next;
  end

  // Output the opcode for control unit 
  assign opcode = instr[6:0];

  //// 
  //// Instruction memory
  //// 
    
  // Instruction memory
  InstructionMemory im
  (
    .pc(pc_current),
    .instruction(instr)
  );
   

  //// 
  //// Registers
  ////
    
 
  // Write back the destination register value - either ALU output
  // MEM_READ_MUX   

  Mux2_32 mem_read_mux(
    .sel(is_io), 
    .out(data_read_value), 
    .in0(mem_read_value), 
    .in1(io_read_value));
    
  // RD_VALUE_MUX   

  Mux2_32 read_value_mux(
    .sel(mem_to_reg),
    .out(rd_value), 
    .in0(alu_out), 
    .in1(data_read_value));

  // Register allocations
  assign rs1 = instr[17:15];
  assign rs2 = instr[22:20];
  assign rd  = instr[9:7];
  
  RegisterUnit reg_file
  (
    .clk(clk),
    .reg_write_en(reg_write_en),
    .rd(rd),
    .rd_value(rd_value),
    .rs1(rs1),
    .rs1_value(rs1_value),
    .rs2(rs2),
    .rs2_value(rs2_value)
   );
   
  ////
  //// ALU
  ////
 
  // extend the 6 bit immediate to 32 bits (copy bit 5 to all higher bits)
  assign ext_imm = {{26{instr[31]}}, instr[30:26]};  
 
  // ALU_IN_MUX
  // determine input for alu - either the rs2 value, the extended immediate value or 8 bit immediate
  
  Mux4_32 alu_mux (
    .sel(alu_src),
    .out(alu_in),
    .in0(rs2_value),
    .in1(ext_imm),
    .in2(instr[31:24]),
    .in3(ext_imm));
   
  // set up the ALU with rs1 and alu_in as inputs - exposes zero flag for branching
  ALU alu_unit
  (
    .a(rs1_value), 
    .b(alu_in), 
    .alu_control(alu_op), 
    .result(alu_out), 
    .zero(zero_flag)
  );

  ////
  //// Branch control
  ////
  
  // BRANCH_MUX
  // The PC increments by 1
  // If a branch is needed, branch_control is true, and the destination is set a PC+1 + ext_imm
  // If a jump is needed, the jump destination is calculated
  // Then pc_next set to the correct value - PC + 1, branch destination or jump destination
  
  assign branch_control = (beq && zero_flag) || (bne && ~zero_flag);
  assign pc_plus_4 = pc_current + 32'd4;  
  
  Mux4_32 branch(
    .sel({branch_control, jump}),              // select on branch , jump
    .out(pc_next),
    .in0(pc_plus_4),                           // no branch, no jump
    .in1({18'b0, instr[31:20], 2'b00}),        // jump location, limited to 12 bit address
    .in2(pc_plus_4 + {ext_imm[29:0], 2'b00}),  // branch
    .in3(pc_plus_4));                          // invalid - continue to next instruction
  
  ////
  //// Address decoder
  ////

  AddressDecoder ad
  (
    .data_address(alu_out),
    .data_read_en(data_read_en),
    .data_write_en(data_write_en),
    .data_write_value(rs2_value),
    .mem_address(mem_address),
    .mem_read_en(mem_read_en),
    .mem_write_en(mem_write_en),
    .mem_write_value(mem_write_value),
    .io_address(io_address),
    .io_read_en(io_read_en),
    .io_write_en(io_write_en),
    .io_write_value(io_write_value),
    .is_io(is_io)
  
  );
 

  // Data memory 
  DataMemory dm
  (
    .clk(clk),
    .mem_access_addr(mem_address),
    .mem_in(mem_write_value),
    .mem_write_en(mem_write_en),
    .mem_read_en(mem_read_en),
    .mem_out(mem_read_value)
  );
 
  // IO 
  // io_address, io_read_en and io_write_en set above
  // io_read_value is an input set in the other side of the IO interface
  // so only io_write_value to assign here
  ///assign io_write_value = rs2_value;
 
endmodule
