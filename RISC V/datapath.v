module DatapathUnit(
  input         clk,
  input  [2:0]  imm_type,
  input  [2:0]  branch_cond,
  input         data_read_en, 
  input         data_write_en, 
  input         reg_write_en, 
  input  [2:0]  data_size,
  input  [1:0]  rd_src, 
  input         alu_b_src,
  input         alu_a_src,
  input  [3:0]  alu_op,
  output [6:0]  opcode,
  output [6:0]  funct7,
  output [2:0]  funct3,
 
  output [31:0] io_address,
  output [31:0] io_write_value,
  input  [31:0] io_read_value,
  output        io_write_en,
  output        io_read_en,
  output [2:0]  io_data_size
  );
  
  reg  [31:0] pc_current;
  wire [31:0] pc_next;
  wire [31:0] pc_plus_4;

  wire        branch_control;
  
  wire [4:0]  rd;
  wire [31:0] rd_value;
  wire [4:0]  rs1;
  wire [31:0] rs1_value;
  wire [4:0]  rs2;
  wire [31:0] rs2_value;
  
  wire [31:0] instr;  
  reg  [31:0] ext_imm;
  wire [31:0] alu_b_in;
  wire [31:0] alu_a_in;
  wire [31:0] alu_out;

  wire [31:0] data_read_value;

  wire        is_io;
  wire [31:0] mem_address;
  wire [31:0] mem_read_value;
  wire [31:0] mem_write_value;
  wire        mem_read_en;
  wire        mem_write_en;
  wire [2:0]  mem_data_size;

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
 
  // Update to pc_next on rising clock
  // Note - the last bit it set to 0 just in case JALR had set it (the only case where it could be non-zero)
  always @(posedge clk)
  begin 
    pc_current <= {pc_next[31:1], 1'b0};     // last bit set to 0(for JALR)
  end

  assign pc_plus_4 = pc_current + 32'd4;  

  //// 
  //// Instruction memory
  //// 
    
  InstructionMemory im
  (
    .pc(pc_current),
    .instruction(instr)
  );

  assign opcode = instr[6:0];
  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];
  
  assign rs1    = instr[19:15];
  assign rs2    = instr[24:20];
  assign rd     = instr[11:7];

  //// 
  //// Registers
  ////
 
  // Write back the destination register value - either ALU output
  // MEM_READ_MUX   

  Mux2_32 mem_read_mux(
    .sel(is_io), 
    .out(data_read_value), 
    .in0(mem_read_value), 
    .in1(io_read_value)
    );
    
  // RD_VALUE_MUX   

  Mux4_32 read_value_mux(
    .sel(rd_src),
    .out(rd_value), 
    .in0(alu_out), 
    .in1(data_read_value),
    .in2(pc_plus_4),
    .in3(alu_out)           // should never be selected
    );

  // Register allocations

    RegisterUnit reg_file (
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
  //// ext_imm
  ////
  
  always @(*)
    case (imm_type)
       3'd1:    ext_imm = { {21{instr[31]}}, instr[30:25], instr[24:21], instr[20] };          // I type (load)
       3'd2:    ext_imm = { {21{instr[31]}}, instr[30:25], instr[11:8],  instr[7]  };          // S type (store)
       3'd3:    ext_imm = { {20{instr[31]}}, instr[7],     instr[30:25], instr[11:8],  1'b0};  // B type - effectively making ext_imm the full offset to branch
       3'd4:    ext_imm = { {12{instr[31]}}, instr[19:12], instr[20],    instr[30:21], 1'b0};  // J type - effectively making ext_imm the full offset to branch 
       3'd5:    ext_imm = {     instr[31],   instr[30:20], instr[19:12], 12'b0 };              // U type 
       default: ext_imm = { {21{instr[31]}}, instr[30:25], instr[24:21], instr[20] };          // includes R type, does not matter what it is 
    endcase
       

  // ALU_IN_MUX
  // determine input for alu - either the rs2 value or the extended immediate value
 
   Mux2_32 alu_a_mux (
    .sel(alu_a_src),
    .out(alu_a_in),
    .in0(rs1_value),
    .in1(pc_current)
    );
  
  Mux2_32 alu_b_mux (
    .sel(alu_b_src),
    .out(alu_b_in),
    .in0(rs2_value),
    .in1(ext_imm)
    );
   
  // set up the ALU with rs1 and alu_in as inputs - exposes zero flag for branching
  ALU alu_unit (
    .a(alu_a_in), 
    .b(alu_b_in), 
    .alu_control(alu_op), 
    .result(alu_out)
  );

  ////
  //// Branch control
  ////
  
  // BRANCH_MUX
  // The PC increments by 4
  // If a branch is needed, branch_control is true, and the destination is set a PC + ext_imm
  // If a jump is needed, the jump destination is calculated
  // Then pc_next set to the correct value - PC + 4, branch destination or jump destination
  
  // Branch comparator - do the comparsion based on branch_cond and set branch_control to 1 if a branch is needed
  BranchComp br_comp (
    .a(rs1_value),
    .b(rs2_value),
    .branch_cond(branch_cond),
    .branch(branch_control)
    );

  // Then select which is the new pc
  Mux2_32 branch_calc (
    .sel(branch_control),
    .out(pc_next),
    .in0(pc_plus_4),
    .in1(alu_out)
  );
   
  ////
  //// Address decoder
  ////

  AddressDecoder ad (
    .data_address(alu_out),
    .data_read_en(data_read_en),
    .data_write_en(data_write_en),
    .data_write_value(rs2_value),
    .data_size(data_size),
    .mem_address(mem_address),
    .mem_read_en(mem_read_en),
    .mem_write_en(mem_write_en),
    .mem_write_value(mem_write_value),
    .mem_data_size(mem_data_size),
    .io_address(io_address),
    .io_read_en(io_read_en),
    .io_write_en(io_write_en),
    .io_write_value(io_write_value),
    .io_data_size(io_data_size),
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
    .mem_out(mem_read_value),
    .mem_data_size(mem_data_size)
  );
  
 
  // IO 
  // io_address, io_read_en and io_write_en set above
  // io_read_value is an input set in the other side of the IO interface
  // so only io_write_value to assign here
  ///assign io_write_value = rs2_value;
 
endmodule
