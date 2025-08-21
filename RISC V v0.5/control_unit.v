module ControlUnit(
  input      [6:0] opcode,
  input      [6:0] funct7,
  input      [2:0] funct3,
  output reg [3:0] alu_op,
  output reg [2:0] branch_cond,
  output reg       data_read_en, 
  output reg       data_write_en, 
  output reg [2:0] data_size,
  output reg [1:0] mem_to_reg, 
  output reg       reg_write_en,
  output reg       alu_b_src,
  output reg       alu_a_src
  );


  always @(*)
  begin
    case(opcode) 
    7'b001_0011:   // arithmetic with immediate
      begin
        alu_a_src      = 1'b0;    // rs1
        alu_b_src      = 1'b1;    // imm
        mem_to_reg     = 2'b00;   // data from alu
        reg_write_en   = 1'b1;    // write to rd
        data_read_en   = 1'b0;    // no read from memory 
        data_write_en  = 1'b0;    // no write to memory
        branch_cond    = 3'b010;  // no branch
        alu_op         = {funct7[5], funct3};   // alu_op has been encoded to match this
        data_size      = 3'b000;
      end
    7'b011_0011:   // arithmetic with registers
      begin
        alu_a_src      = 1'b0;    // rs1
        alu_b_src      = 1'b0;    // rs2
        mem_to_reg     = 2'b00;   // data from alu
        reg_write_en   = 1'b1;    // write to rd
        data_read_en   = 1'b0;    // no read from memory 
        data_write_en  = 1'b0;    // no write to memory
        branch_cond    = 3'b010;  // no branch
        alu_op         = {funct7[5], funct3};   // alu_op has been encoded to match this
        data_size      = 3'b000;      
      end   
    7'b110_0111:   // jalr          
      begin
        alu_a_src      = 1'b0;    // rs1  
        alu_b_src      = 1'b1;    // ext_imm
        mem_to_reg     = 2'b10;   // pc + 4
        reg_write_en   = 1'b1;    // write to rd
        data_read_en   = 1'b0;    // no read from memory 
        data_write_en  = 1'b0;    // no write to memory
        branch_cond    = 3'b011;  // branch always
        alu_op         = 4'b0000; // add
        data_size      = 3'b000;
      end    
    7'b110_1111:   // jal   
      begin
        alu_a_src      = 1'b1;    // pc_current  
        alu_b_src      = 1'b1;    // ext_imm
        mem_to_reg     = 2'b10;   // pc + 4
        reg_write_en   = 1'b1;    // write to rd
        data_read_en   = 1'b0;    // no read from memory   
        data_write_en  = 1'b0;    // no write to memory
        branch_cond    = 3'b011;  // branch always
        alu_op         = 4'b0000; // add
        data_size      = 3'b000;
      end       
    7'b010_0011:   // store
      begin
        alu_a_src     = 1'b0;     // rs1
        alu_b_src     = 1'b1;     // ext_imm
        mem_to_reg    = 2'b00;    // data from alu
        reg_write_en  = 1'b0;     // no write to rd
        data_read_en  = 1'b0;     // no read from memory   
        data_write_en = 1'b1;     // no write to memory
        branch_cond   = 3'b010;   // no branch
        alu_op        = 4'b0000;  // add
        data_size     = 3'b000;
      end  
    7'b000_0011:   // load
      begin
        alu_a_src     = 1'b0;     // rs1
        alu_b_src     = 1'b1;     // ext_imm
        mem_to_reg    = 2'b01;    // data from memory
        reg_write_en  = 1'b1;     // write to rd
        data_read_en  = 1'b1;     // read from memory
        data_write_en = 1'b0;     // no write to memory
        branch_cond   = 3'b010;   // no branch
        alu_op        = 4'b0000;  // add
        data_size     = 3'b000;      
      end          
    7'b011_0111:   // lui        
      begin        
        alu_a_src      = 1'b0;    // rs1
        alu_b_src      = 1'b1;    // imm
        mem_to_reg     = 2'b00;   // data from alu
        reg_write_en   = 1'b1;    // write to rd
        data_read_en   = 1'b0;    // no read from memory
        data_write_en  = 1'b0;    // no write to memory
        branch_cond    = 3'b010;  // no branch
        alu_op         = 4'b1001; // pass through alu_b
        data_size      = 3'b000;  
      end       
    7'b001_0111:   // auipc 
      begin
        alu_a_src      = 1'b1;    // pc
        alu_b_src      = 1'b1;    // imm
        mem_to_reg     = 2'b00;   // data from alu
        reg_write_en   = 1'b1;    // write to rd
        data_read_en   = 1'b0;    // no read from memory
        data_write_en  = 1'b0;    // no write to memory
        branch_cond    = 3'b010;  // no branch
        alu_op         = 4'b0000; // add
        data_size      = 3'b000;
      end 
    7'b110_0011:   // branch             
      begin
        alu_a_src      = 1'b1;    //  pc_current  
        alu_b_src      = 1'b1;    //  ext_imm
        mem_to_reg     = 2'b00;   // data from alu
        reg_write_en   = 1'b0;    // no write to rd
        data_read_en   = 1'b0;    // no read from memory
        data_write_en  = 1'b0;    // no write to memory
        branch_cond    = funct3;  // branch condition is encoded to match funct3
        alu_op         = 4'b0000; // add
        data_size      = 3'b000;
      end       
                 
                 
    // Old opcodes - remove eventually
    7'b0000000:  // LD
      begin
        alu_a_src     = 1'b0;     // rs1
        alu_b_src     = 1'b1;     // ext_imm
        mem_to_reg    = 2'b01;
        reg_write_en  = 1'b1;
        data_read_en  = 1'b1;
        data_write_en = 1'b0;
        branch_cond   = 3'b010;   // no branch
        alu_op        = 4'b0000;  // add
        data_size     = 3'b000;
      end
    7'b0000100:  // ST
      begin
        alu_a_src     = 1'b0;     // rs1
        alu_b_src     = 1'b1;     // ext_imm
        mem_to_reg    = 2'b00;
        reg_write_en  = 1'b0;
        data_read_en  = 1'b0;      
        data_write_en = 1'b1;
        branch_cond   = 3'b010;   // no branch
        alu_op        = 4'b0000;  // add
        data_size     = 3'b000;
      end
    7'b0001000:  // ADD
      begin
        alu_a_src      = 1'b0;    // rs1
        alu_b_src      = 1'b0;    // rs2
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b1;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b010;   // no branch
        alu_op         = 4'b0000;  // add
        data_size      = 3'b000;
      end
    7'b0001100:  // SUB
      begin
        alu_a_src      = 1'b0;
        alu_b_src      = 1'b0;
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b1;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b010;   // no branch
        alu_op         = 4'b1000;  // sub
        data_size      = 3'b000;
      end
    7'b0010000:  // INV
      begin
        alu_a_src      = 1'b0;
        alu_b_src      = 1'b0;
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b1;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b010;  // no branch
        alu_op         = 4'b1010; // inv
        data_size      = 3'b000;
      end
    7'b0010100:  // LSL
      begin
        alu_a_src      = 1'b0;
        alu_b_src      = 1'b0;
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b1;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b010;  // no branch
        alu_op         = 4'b0001; // lsl
        data_size      = 3'b000;
       end
    7'b0011000:  // LSR
      begin
        alu_a_src      = 1'b0;
        alu_b_src      = 1'b0;
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b1;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b010;  // no branch
        alu_op         = 4'b0101; // lsr
        data_size      = 3'b000;
      end
    7'b0011100:  // AND
      begin
        alu_a_src      = 1'b0;
        alu_b_src      = 1'b0;
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b1;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b010;  // no branch
        alu_op         = 4'b0111; // and
        data_size      = 3'b000;
      end
    7'b0100000:  // OR
      begin
        alu_a_src      = 1'b0;
        alu_b_src      = 1'b0;
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b1;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b010;  // no branch
        alu_op         = 4'b0110; // or
        data_size      = 3'b000;
      end
    7'b0100100:  // SLT
      begin
        alu_a_src      = 1'b0;
        alu_b_src      = 1'b0;
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b1;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b010;  // no branch
        alu_op         = 4'b0011; // slt
        data_size      = 3'b000;
      end
    7'b0101100:  // BEQ
      begin
        alu_a_src      = 1'b1;   //  pc_current
        alu_b_src      = 1'b1;   //  ext_imm
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b0;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b000;  // beq
        alu_op         = 4'b0000; // add
        data_size      = 3'b000;
      end
    7'b0110000:  // BNE
      begin
        alu_a_src      = 1'b1;   //  pc_current
        alu_b_src      = 1'b1;   //  ext_imm
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b0;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b001;  // bne
        alu_op         = 4'b0000; // add
        data_size      = 3'b000;
      end
    7'b0110100:  // JMP
      begin
        alu_a_src      = 1'b1;   //  pc_current  
        alu_b_src      = 1'b1;   //  ext_imm
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b0;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b011;  // branch always
        alu_op         = 4'b0000; // add
        data_size      = 3'b000;
      end   
    7'b0111000:  // LUI
      begin
        alu_a_src      = 1'b0;    // rs1
        alu_b_src      = 1'b1;    // ext_imm
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b1;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b010;  // no branch
        alu_op         = 4'b1001; // lui
        data_size      = 3'b000;
      end   
    default:    // ADD 
      begin 
        alu_a_src      = 1'b0;
        alu_b_src      = 1'b0;
        mem_to_reg     = 2'b00;
        reg_write_en   = 1'b1;
        data_read_en   = 1'b0;
        data_write_en  = 1'b0;
        branch_cond    = 3'b010;   // no branch
        alu_op         = 4'b0000;
        data_size      = 3'b000;
      end
    endcase
  end
endmodule
