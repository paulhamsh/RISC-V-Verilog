`timescale 1ns / 1ps

module test_RISC32;

  // Inputs
  reg clk;

  // Instantiate the Unit Under Test (UUT)
  Risc32 uut (
    .clk(clk)
  );

// PROG_BASIC will run the program in instruction memory for 160 steps
// PROG_STEPPED will run each line and check the output (assumes test program 1)
// PROG_INDIV will run specific commands and is not dependent on data memory or instruction memory being initialised

//`define PROG_BASIC 
//`define PROG_STEPPED
`define PROG_INDIV

`ifdef PROG_BASIC
  initial 
    begin
      clk <=0;
      #160;  // duration of the simulation
      $finish;
    end

  always 
    begin
      #5 clk = ~clk;
    end

`elsif PROG_STEPPED

  initial 
    begin
      clk <=0;
    end

  always 
    begin
      $display("RISC-V 32 bit -  instruction memory: %4d data memory %4d", `row_i, `row_d);
      #10;
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tr0:   %8h", uut.datapath.reg_file.reg_array[0]);
      if (uut.datapath.reg_file.reg_array[0] != 32'h0001) $error("LD failure");
      
      clk = 0;
      #5;        
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tr1:   %8h", uut.datapath.reg_file.reg_array[1]);
      if (uut.datapath.reg_file.reg_array[1] != 32'h0002) $error("LD failure");
 
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tr2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0003) $error("ADD failure");
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tmem[2]:   %8h", uut.datapath.dm.memory[1]);
      if (uut.datapath.dm.memory[1] != 32'h0002) $error("ST failure");  
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tr2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'hffffffff) $error("SUB failure");     
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tr2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'hfffffffe) $error("INV failure");  
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tr2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0004) $error("LSL failure");        

      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tr2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0000) $error("LSR failure");   
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tr2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0000) $error("AND failure");   
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tr2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0003) $error("OR failure");  
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tr2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0001) $error("SLT failure");                     

      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tr0:   %8h", uut.datapath.reg_file.reg_array[0]);
      if (uut.datapath.reg_file.reg_array[0] != 32'h0002) $error("ADD failure");  
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      $display("\tbranch_control: %1b bne: %1b  beq: %1b  zero_flag: %1b", uut.datapath.branch_control, uut.datapath.bne, uut.datapath.beq, uut.datapath.zero_flag);
      $display("\tpc_next: %8h", uut.datapath.pc_next);
      if (uut.datapath.pc_next != 32'h34) $error("BEQ failure");  
      clk = 1;
      #5;
            
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      $display("\tbranch_control: %1b bne: %1b  beq: %1b  zero_flag: %1b", uut.datapath.branch_control, uut.datapath.bne, uut.datapath.beq, uut.datapath.zero_flag);
      $display("\tpc_next: %8h", uut.datapath.pc_next);
      if (uut.datapath.pc_next != 32'h3c) $error("BNE failure");  
      clk = 1;
      #5;
            
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      $display("\tjump: %1b", uut.datapath.jump);
      $display("\tpc_next: %8h", uut.datapath.pc_next);
      if (uut.datapath.pc_next != 32'h10) $error("JMP failure");        
      clk = 1;
      #5;

      #20;
      $finish;
    end
    
`elsif PROG_INDIV
   initial 
     begin
       clk <=0;
     end
    
   always 
     begin
       $display("RISC-V 32 bit - instruction memory: %4d data memory: %4d", `row_i, `row_d);
       $display("--------------------------------------------------");
       
       // Test 1 - LD R0, [0 + R2]       
       clk = 0;
       #5;     
       uut.datapath.pc_current = 0;
       //                               ld rd, rs1(off6)
       //                               +off6+_xx_rs2_xx_rs1_xxxxx_rd+_xxx_+op+ 
       uut.datapath.im.memory[0] <= 32'b000000_00_000_00_010_00000_000_000_0000; 
       uut.datapath.dm.memory[1] <= 32'h0000_7f7f;               // Mem[1] = 7f7f
       uut.datapath.reg_file.reg_array[2] <= 32'h0004;           // R2 = 4
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tr0:   %08h", uut.datapath.reg_file.reg_array[0]);
       if (uut.datapath.reg_file.reg_array[0] != 32'h0000_7f7f) $error("LD failure"); else $display("Success");
 

       // Test 2 - ADD R3, R1, R2          R3 = R1 + R2
       clk = 0;
       #5;
       uut.datapath.pc_current = 0;
       //                               add rd, rs1, rs2
       //                               +++++_xx_rs2_xx_rs1_xxxxx_rd+_xxx_+op+ 
       uut.datapath.im.memory[0] <= 32'b00000_00_010_00_001_00000_011_000_0010; 
       uut.datapath.reg_file.reg_array[1] <= 32'h0001;           // R1 = 0001
       uut.datapath.reg_file.reg_array[2] <= 32'h0fff;           // R2 = 0fff
       uut.datapath.reg_file.reg_array[3] <= 32'h2222;           // R3 = 2222
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tr3:   %08h", uut.datapath.reg_file.reg_array[3]);
       if (uut.datapath.reg_file.reg_array[3] != 32'h1000) $error("ADD failure"); else $display("Success");
 

       // Test 3 - LUI R1, 01010101
       clk = 0;
       #5;
       uut.datapath.pc_current = 0;
       //                               lui rs1, imm8
       //                               ++++++++_xxxxxx_rs1_xxxxx_rd+_xxx_+op+ 
       uut.datapath.im.memory[0] <= 32'b01010101_000000_001_00000_001_000_1110; 
       uut.datapath.reg_file.reg_array[1] <= 32'h0000_ffff;           // R1 = ffff
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tr1:   %08h", uut.datapath.reg_file.reg_array[1]);
       if (uut.datapath.reg_file.reg_array[1] != 32'h0000_55ff) $error("LUI failure"); else $display("Success");


       // Test 4 - LLI R1, 10101010
       clk = 0;
       #5;
       uut.datapath.pc_current = 0;
       //                               lui rs1, imm8
       //                               ++++++++_xxxxxx_rs1_xxxxx_rd+_xxx_+op+ 
       uut.datapath.im.memory[0] <= 32'b10101010_000000_001_00000_001_000_1111; 
       uut.datapath.reg_file.reg_array[1] <= 32'hffff;           // R1 = 0001
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tr1:   %08h", uut.datapath.reg_file.reg_array[1]);
       if (uut.datapath.reg_file.reg_array[1] != 32'hffaa) $error("LLI failure"); else $display("Success");


       // Test 5 - memory wrap - ld r0, r2(0)
       clk = 0;
       #5;
       uut.datapath.pc_current = 0;
       //                                ld rd, rs1(off6)
       //                                +off6+_xx_rs2_xx_rs1_xxxxx_rd+_xxx_+op+ 
       uut.datapath.im.memory[0]  <= 32'b000000_00_000_00_010_00000_000_000_0000; 
       uut.datapath.dm.memory[0]  <= 32'hf7f7_7f7f;               // Mem[0]   = f7f7_7f7f  - byte address 0
       uut.datapath.dm.memory[31] <= 32'h8888_8888;               // Mem[124] = 8888_8888  - byte address 124, even though index 31
       uut.datapath.reg_file.reg_array[2] <= 32'd128;             // R2 = 128 (should wrap to 0)
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tr0:   %08h", uut.datapath.reg_file.reg_array[0]);
       if (uut.datapath.reg_file.reg_array[0] != 32'hf7f7_7f7f) $error("LD failure"); else $display("Success");


       clk = 0;
       #5;
       uut.datapath.pc_current = 0;
       uut.datapath.im.memory[0]  <= 32'b000000_00_000_00_010_00000_000_000_0000; 
       uut.datapath.dm.memory[0]  <= 32'hf7f7_7f7f;               // Mem[4]   = f7f7_7f7f  - byte address 4, even though index 1
       uut.datapath.dm.memory[31] <= 32'h8888_8888;               // Mem[124] = 8888_8888  - byte address 124, even though index 31
       uut.datapath.reg_file.reg_array[2] <= 32'd124;             // R2 = 124 
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %4b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tr0:   %08h", uut.datapath.reg_file.reg_array[0]);
       if (uut.datapath.reg_file.reg_array[0] != 32'h8888_8888) $error("LD failure"); else $display("Success");


       #20;
       $finish;
     end
`endif

endmodule