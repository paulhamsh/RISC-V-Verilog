module ControlUnit(
      input [6:0] opcode,
      input [6:0] funct7,
      input [2:0] funct3,
      output reg [3:0] alu_op,
      output reg [2:0] branch_cond,
      output reg data_read_en, data_write_en, 
      output reg [1:0] mem_to_reg, 
      output reg reg_write_en,
      output reg alu_b_src,
      output reg alu_a_src
      );

  always @(*)
  begin
    case(opcode) 
      7'b0000011:  // LD
        begin
          alu_b_src     = 1'b1;
          alu_a_src     = 1'b0;
          mem_to_reg    = 2'b1;
          reg_write_en  = 1'b1;
          data_read_en  = 1'b1;
          data_write_en = 1'b0;
          branch_cond   = 3'b010;   // no branch
          alu_op        = 4'b0000;  // add
        end
      7'b0000111:  // ST
        begin
          alu_b_src     = 1'b1;
          alu_a_src     = 1'b0;          
          mem_to_reg    = 2'b0;
          reg_write_en  = 1'b0;
          data_read_en  = 1'b0;      
          data_write_en = 1'b1;
          branch_cond   = 3'b010;   // no branch
          alu_op        = 4'b0000;  // add
        end
      7'b0001011:  // ADD
        begin
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;          
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b010;   // no branch
          alu_op         = 4'b0000;  // add
        end
      7'b0001111:  // SUB
        begin
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;         
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b010;   // no branch
          alu_op         = 4'b0001;  // sub
        end
      7'b0010011:  // INV
        begin
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b010;  // no branch
          alu_op         = 4'b0010; // inv
        end
      7'b0010111:  // LSL
        begin
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b010;  // no branch
          alu_op         = 4'b0011; // lsl
         end
      7'b0011011:  // LSR
        begin
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b010;  // no branch
          alu_op         = 4'b0100; // lsr
        end
      7'b0011111:  // AND
        begin
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;         
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b010;  // no branch
          alu_op         = 4'b0101; // and
        end
      7'b0100011:  // OR
        begin
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b010;  // no branch
          alu_op         = 4'b0110; // or
        end
      7'b0100111:  // SLT
        begin
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b010;  // no branch
          alu_op         = 4'b0111; // slt
        end
      7'b0101111:  // BEQ
        begin
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b0;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b000;  // beq
          alu_op         = 4'b0000; // add
        end
      7'b0110011:  // BNE
        begin
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b0;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b001;  // bne
          alu_op         = 4'b0000; // add
        end
      7'b0110111:  // JMP
        begin
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;          
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b0;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b011;   // branch always
          alu_op         = 4'b0000; // add
        end   
      7'b0111011:  // LUI
        begin
          alu_b_src      = 1'b1;   // immediate
          alu_a_src      = 1'b0;          
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b010;  // no branch
          alu_op         = 4'b1000; // lui
        end   
      default:    // ADD 
        begin 
          alu_b_src      = 1'b0;
          alu_a_src      = 1'b0;
          mem_to_reg     = 2'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          branch_cond    = 3'b010;   // no branch
          alu_op         = 4'b0000;
        end
      endcase
  end

endmodule
