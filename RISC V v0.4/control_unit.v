`timescale 1ns / 1ps

module ControlUnit(
      input [6:0] opcode,
      output reg [3:0] alu_op,
      output reg jump, beq, bne, 
      output reg data_read_en, data_write_en, mem_to_reg, reg_write_en,
      output reg alu_src
      );

  always @(*)
  begin
    case(opcode) 
      7'b0000011:  // LD
        begin
          alu_src       = 1'b1;
          mem_to_reg    = 1'b1;
          reg_write_en  = 1'b1;
          data_read_en  = 1'b1;
          data_write_en = 1'b0;
          beq           = 1'b0;
          bne           = 1'b0;
          alu_op        = 4'b0000;  // add
          jump          = 1'b0;   
        end
      7'b0000111:  // ST
        begin
          alu_src       = 1'b1;
          mem_to_reg    = 1'b0;
          reg_write_en  = 1'b0;
          data_read_en  = 1'b0;      
          data_write_en = 1'b1;
          beq           = 1'b0;
          bne           = 1'b0;
          alu_op        = 4'b0000;  // add
          jump          = 1'b0;   
        end
      7'b0001011:  // ADD
        begin
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b0;
          alu_op         = 4'b0000;  // add
          jump           = 1'b0;   
        end
      7'b0001111:  // SUB
        begin
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b0;
          alu_op         = 4'b0001;  // sub
          jump           = 1'b0;   
        end
      7'b0010011:  // INV
        begin
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b0;
          alu_op         = 4'b0010; // inv
          jump           = 1'b0;   
        end
      7'b0010111:  // LSL
        begin
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b0;
          alu_op         = 4'b0011; // lsl
          jump           = 1'b0;   
         end
      7'b0011011:  // LSR
        begin
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b0;
          alu_op         = 4'b0100; // lsr
          jump           = 1'b0;   
        end
      7'b0011111:  // AND
        begin
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b0;
          alu_op         = 4'b0101; // and
          jump           = 1'b0;   
        end
      7'b0100011:  // OR
        begin
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b0;
          alu_op         = 4'b0110; // or
          jump           = 1'b0;   
        end
      7'b0100111:  // SLT
        begin
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b0;
          alu_op         = 4'b0111; // slt
          jump           = 1'b0;   
        end
      7'b0101111:  // BEQ
        begin
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b0;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b1;
          bne            = 1'b0;
          alu_op         = 4'b0001; // sub
          jump           = 1'b0;   
        end
      7'b0110011:  // BNE
        begin
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b0;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b1;
          alu_op         = 4'b0001; // sub
          jump           = 1'b0;   
        end
      7'b0110111:  // JMP
        begin
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b0;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b0;
          alu_op         = 4'b0000; // add
          jump           = 1'b1;   
        end   
      7'b0111011:  // LUI
        begin
          alu_src        = 1'b1;   // immediate
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b0;
          alu_op         = 4'b1000; // lui
          jump           = 1'b0;   
        end   
       default: begin // ADD
          alu_src        = 1'b0;
          mem_to_reg     = 1'b0;
          reg_write_en   = 1'b1;
          data_read_en   = 1'b0;
          data_write_en  = 1'b0;
          beq            = 1'b0;
          bne            = 1'b0;
          alu_op         = 4'b0000;
          jump           = 1'b0; 
        end
      endcase
  end

endmodule
