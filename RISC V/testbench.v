`timescale 1ns / 1ps

module test_RISC32;

  // Inputs
  reg clk;

  // Instantiate the Unit Under Test (UUT)
  Risc32 uut (
    .clk(clk)
  );

// PROG_BASIC will run the program in instruction memory for 200 steps
// PROG_STEPPED will run each line and check the output (assumes test program 1)
// PROG_INDIV will run specific commands and is not dependent on data memory or instruction memory being initialised

//`define PROG_BASIC 
//`define PROG_STEPPED
`define PROG_INDIV

`ifdef PROG_BASIC
  initial 
    begin
      clk <=0;
      #200;  // duration of the simulation
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
      $display("RISC-V 32 bit - instruction memory: %4d data memory: %4d", `instr_bytes, `data_bytes);
      #5;
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx3:   %8h", uut.datapath.reg_file.reg_array[3]);
      if (uut.datapath.reg_file.reg_array[3] != 32'h0001) $error("LD failure");
      
      clk = 0;
      #5;        
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx1:   %8h", uut.datapath.reg_file.reg_array[1]);
      if (uut.datapath.reg_file.reg_array[1] != 32'h0002) $error("LD failure");
 
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0003) $error("ADD failure");
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tmem[4]:   %2h", uut.datapath.dm.memory[4]);
      if (! (uut.datapath.dm.memory[4] == 8'h3 && uut.datapath.dm.memory[5] == 8'h0 && uut.datapath.dm.memory[6] == 8'h0 && uut.datapath.dm.memory[7] == 8'h0)) $error("ST failure");  
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'hffffffff) $error("SUB failure");     
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'hfffffffe) $error("INV failure");  
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0004) $error("LSL failure");        

      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0000) $error("LSR failure");   
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0000) $error("AND failure");   
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0003) $error("OR failure");  
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx2:   %8h", uut.datapath.reg_file.reg_array[2]);
      if (uut.datapath.reg_file.reg_array[2] != 32'h0001) $error("SLT failure");                     

      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx3:   %8h", uut.datapath.reg_file.reg_array[3]);
      if (uut.datapath.reg_file.reg_array[3] != 32'h0002) $error("ADD failure");  
 
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx3:   %8h", uut.datapath.reg_file.reg_array[3]);
      if (uut.datapath.reg_file.reg_array[3] != 32'h1000) $error("LUI failure");  
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      clk = 1;
      #5;
      $display("\tx3:   %8h", uut.datapath.reg_file.reg_array[3]);
      if (uut.datapath.reg_file.reg_array[3] != 32'h0000_1034) $error("AUIPC failure");  
      
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      $display("\tbranch_control: %1b", uut.datapath.branch_control);
      $display("\tpc_next: %8h", uut.datapath.pc_next);
      if (uut.datapath.pc_next != 32'h3c) $error("BEQ failure");  
      clk = 1;
      #5;
            
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      $display("\tbranch_control: %1b", uut.datapath.branch_control);
      $display("\tpc_next: %8h", uut.datapath.pc_next);
      if (uut.datapath.pc_next != 32'h44) $error("BNE failure");  
      clk = 1;
      #5;
            
      clk = 0;
      #5;   
      $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
      $display("\tbranch_control: %1b", uut.datapath.branch_control);
      $display("\tpc_next: %8h", uut.datapath.pc_next);
      if (uut.datapath.pc_next != 32'h10) $error("JMP failure - pc");    
      clk = 1;
      #5;
      $display("\tx1     : %8h", uut.datapath.reg_file.reg_array[1]);
      if (uut.datapath.reg_file.reg_array[1] != 32'h0048) $error("JMP failure - x1");   

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
       $display("RISC-V 32 bit - instruction memory: %4d data memory: %4d", `instr_bytes,  `data_bytes);
       $display("--------------------------------------------------");
       
       // Test 1 - lw x1, [0 + x2]       
       clk = 0;
       #5;     
       uut.datapath.pc_current = 0;
       //                               lw rd, rs1(ext_imm)
       //                               +++imm++++++_+rs1+_010_++rd+_++op+++ 
       uut.datapath.im.memory[0] <= 32'b000000000000_00010_010_00001_0000011; 
       uut.datapath.dm.memory[4] <= 8'h7f;               // Mem[4] = 0000_7f7f
       uut.datapath.dm.memory[5] <= 8'h7f;
       uut.datapath.dm.memory[6] <= 8'h00;
       uut.datapath.dm.memory[7] <= 8'h00;
       uut.datapath.reg_file.reg_array[2] <= 32'h0004;           // R2 = 4
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tx1:   %08h", uut.datapath.reg_file.reg_array[1]);
       if (uut.datapath.reg_file.reg_array[1] != 32'h0000_7f7f) $error("lw failure"); else $display("Success");
 

       // Test 2 - add x3, x1, x2
       clk = 0;
       #5;
       uut.datapath.pc_current = 0;
       //                               add rd, rs1, rs2
       //                               +func7+_+rs2+_+rs1+_fu3_++rd+_+++op++ 
       uut.datapath.im.memory[0] <= 32'b0000000_00010_00001_000_00011_0110011; 
       uut.datapath.reg_file.reg_array[1] <= 32'h0001;           // R1 = 0001
       uut.datapath.reg_file.reg_array[2] <= 32'h0fff;           // R2 = 0fff
       uut.datapath.reg_file.reg_array[3] <= 32'h2222;           // R3 = 2222
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tx3:   %08h", uut.datapath.reg_file.reg_array[3]);
       if (uut.datapath.reg_file.reg_array[3] != 32'h1000) $error("add failure"); else $display("Success");
 

       // Test 3 - lui x1, h55555
       clk = 0;
       #5;
       uut.datapath.pc_current = 0;
       //                               lui rd, imm
       //                               ++++++++++imm+++++++_++rd+_+++op++ 
       uut.datapath.im.memory[0] <= 32'b01010101010101010101_00001_0110111; 
       uut.datapath.reg_file.reg_array[1] <= 32'h0000_0000;           
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tx1:   %08h", uut.datapath.reg_file.reg_array[1]);
       if (uut.datapath.reg_file.reg_array[1] != 32'h5555_5000) $error("lui failure"); else $display("Success");


       // Test 5 - memory wrap - lw x1, x2(0)   (128) should wrap to 0
       clk = 0;
       #5;
       uut.datapath.pc_current = 0;
       //                                ld rd, rs1(ext_imm)
       //                                +++imm++++++_+rs1+_xxx_++rd+_++op+++  
       uut.datapath.im.memory[0]   <= 32'b000000000000_00010_010_00001_0000011; 
       uut.datapath.dm.memory[0]   <= 8'h7f;                        // Mem[0]   = f7f7_7f7f  - byte address 0
       uut.datapath.dm.memory[1]   <= 8'h7f;
       uut.datapath.dm.memory[2]   <= 8'hf7;
       uut.datapath.dm.memory[3]   <= 8'hf7;
       uut.datapath.dm.memory[124] <= 8'h88;                        // Mem[124] = 8888_8888  - byte address 124
       uut.datapath.dm.memory[125] <= 8'h88; 
       uut.datapath.dm.memory[126] <= 8'h88;
       uut.datapath.dm.memory[127] <= 8'h88;                
       uut.datapath.reg_file.reg_array[2] <= 32'd128;             // x2 = 128 (should wrap to 0)
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tx1:   %08h", uut.datapath.reg_file.reg_array[1]);
       if (uut.datapath.reg_file.reg_array[1] != 32'hf7f7_7f7f) $error("lw failure"); else $display("Success");

       // Test 6 - memory wrap - lw x1, x2(0)    (124)
       clk = 0;
       #5;
       uut.datapath.pc_current = 0;
       //                                ld rd, rs1(ext_imm)
       //                                +++imm++++++_+rs1+_010_++rd+_++op+++  
       uut.datapath.im.memory[0]  <= 32'b000000000000_00010_010_00001_0000011; 
       uut.datapath.dm.memory[0]   <= 8'h7f;                        // Mem[0]   = f7f7_7f7f  - byte address 0
       uut.datapath.dm.memory[1]   <= 8'h7f;
       uut.datapath.dm.memory[2]   <= 8'h7f;
       uut.datapath.dm.memory[3]   <= 8'h7f;
       uut.datapath.dm.memory[124] <= 8'h88;                        // Mem[124] = 8888_8888  - byte address 124
       uut.datapath.dm.memory[125] <= 8'h88; 
       uut.datapath.dm.memory[126] <= 8'h88;
       uut.datapath.dm.memory[127] <= 8'h88; 
       uut.datapath.reg_file.reg_array[2] <= 32'd124;             // x2 = 124 
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tx1:   %08h", uut.datapath.reg_file.reg_array[1]);
       if (uut.datapath.reg_file.reg_array[1] != 32'h8888_8888) $error("lw failure"); else $display("Success");

       // Test 7 - lh x1, [0 + x2]       
       clk = 0;
       #5;     
       uut.datapath.pc_current = 0;
       //                               lw rd, rs1(ext_imm)
       //                               +++imm++++++_+rs1+_001_++rd+_++op+++ 
       uut.datapath.im.memory[0] <= 32'b000000000000_00010_001_00001_0000011; 
       uut.datapath.dm.memory[4] <= 8'h7f;               // Mem[4] = 0000_7f7f
       uut.datapath.dm.memory[5] <= 8'h7f;
       uut.datapath.dm.memory[6] <= 8'h7f;
       uut.datapath.dm.memory[7] <= 8'h7f;
       uut.datapath.reg_file.reg_array[2] <= 32'h0004;           // R2 = 4
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tx1:   %08h", uut.datapath.reg_file.reg_array[1]);
       if (uut.datapath.reg_file.reg_array[1] != 32'h0000_7f7f) $error("lh failure"); else $display("Success");

       // Test 8 - lb x1, [0 + x2]       
       clk = 0;
       #5;     
       uut.datapath.pc_current = 0;
       //                               lw rd, rs1(ext_imm)
       //                               +++imm++++++_+rs1+_000_++rd+_++op+++ 
       uut.datapath.im.memory[0] <= 32'b000000000000_00010_000_00001_0000011; 
       uut.datapath.dm.memory[4] <= 8'h7f;               // Mem[4] = 0000_7f7f
       uut.datapath.dm.memory[5] <= 8'h7f;
       uut.datapath.dm.memory[6] <= 8'h7f;
       uut.datapath.dm.memory[7] <= 8'h7f;
       uut.datapath.reg_file.reg_array[2] <= 32'h0004;           // R2 = 4
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tx1:   %08h", uut.datapath.reg_file.reg_array[1]);
       if (uut.datapath.reg_file.reg_array[1] != 32'h0000_007f) $error("lbh failure"); else $display("Success");

       // Test 9 - lb x1, [0 + x2]       
       clk = 0;
       #5;     
       uut.datapath.pc_current = 0;
       //                               lw rd, rs1(ext_imm)
       //                               +++imm++++++_+rs1+_000_++rd+_++op+++ 
       uut.datapath.im.memory[0] <= 32'b000000000000_00010_000_00001_0000011; 
       uut.datapath.dm.memory[4] <= 8'h8f;               // Mem[4] = 0000_7f7f
       uut.datapath.dm.memory[5] <= 8'h77;
       uut.datapath.dm.memory[6] <= 8'h77;
       uut.datapath.dm.memory[7] <= 8'h77;
       uut.datapath.reg_file.reg_array[2] <= 32'h0004;           // R2 = 4
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tx1:   %08h", uut.datapath.reg_file.reg_array[1]);
       if (uut.datapath.reg_file.reg_array[1] != 32'hffff_ff8f) $error("lbh failure"); else $display("Success");

       // Test 10 - lhu x1, [0 + x2]       
       clk = 0;
       #5;     
       uut.datapath.pc_current = 0;
       //                               lw rd, rs1(ext_imm)
       //                               +++imm++++++_+rs1+_101_++rd+_++op+++ 
       uut.datapath.im.memory[0] <= 32'b000000000000_00010_101_00001_0000011; 
       uut.datapath.dm.memory[4] <= 8'h8f;               // Mem[4] = 0000_7f7f
       uut.datapath.dm.memory[5] <= 8'h8f;
       uut.datapath.dm.memory[6] <= 8'h77;
       uut.datapath.dm.memory[7] <= 8'h77;
       uut.datapath.reg_file.reg_array[2] <= 32'h0004;           // R2 = 4
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tx1:   %08h", uut.datapath.reg_file.reg_array[1]);
       if (uut.datapath.reg_file.reg_array[1] != 32'h0000_8f8f) $error("lbh failure"); else $display("Success");

       // Test sh - sh x1, [0 + x2]       
       clk = 0;
       #5;     
       uut.datapath.pc_current = 0;
       //                               sh rs2, rs1(ext_imm)
       //                               +++imm+_+rs2+_+rs1+_001_+imm+_++op+++ 
       uut.datapath.im.memory[0] <= 32'b0000000_00001_00010_001_00000_0100011; 
       uut.datapath.dm.memory[4] <= 8'h8f;               // Mem[4] = 0000_7f7f
       uut.datapath.dm.memory[5] <= 8'h8f;
       uut.datapath.dm.memory[6] <= 8'h77;
       uut.datapath.dm.memory[7] <= 8'h77;
       uut.datapath.reg_file.reg_array[2] <= 32'h0004;           // R2 = 4
       uut.datapath.reg_file.reg_array[1] <= 32'h9999_9999;
       #10;
       $display("PC:  %3d  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode );
       clk = 1;
       #5;
       $display("\tmem[4]:   %02h", uut.datapath.dm.memory[4]);
       $display("\tmem[5]:   %02h", uut.datapath.dm.memory[5]);       
       $display("\tmem[6]:   %02h", uut.datapath.dm.memory[6]);
       $display("\tmem[7]:   %02h", uut.datapath.dm.memory[7]);       
       if (uut.datapath.dm.memory[4] != 8'h99) $error("sh failure"); else $display("Success");
       if (uut.datapath.dm.memory[5] != 8'h99) $error("sh failure"); else $display("Success");
       if (uut.datapath.dm.memory[6] != 8'h77) $error("sh failure"); else $display("Success");
       if (uut.datapath.dm.memory[6] != 8'h77) $error("sh failure"); else $display("Success");

       #20;
       $finish;
     end
`endif

endmodule