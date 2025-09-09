`timescale 1ns / 1ps

`include "settings.vh"

`define get_31_24(v)         ((v & 32'hff00_0000) >> 24)
`define get_23_16(v)         ((v & 32'h00ff_0000) >> 16)
`define get_15_8(v)          ((v & 32'h0000_ff00) >> 8)
`define get_7_0(v)            (v & 32'h0000_00ff)

`define make_word(v1, v2, v3,v4)    {v1, v2, v3, v4}
`define make_half(v1, v2)           {v1, v2}

`ifdef BANKED_MEM

`define memA(a)             uut.datapath.dm.memA[a>>2]
`define memB(a)             uut.datapath.dm.memB[a>>2]
`define memC(a)             uut.datapath.dm.memC[a>>2]
`define memD(a)             uut.datapath.dm.memD[a>>2]
`define set_memw(a, v)      `memD(a) <= `get_7_0(v); `memC(a) <= `get_15_8(v); `memB(a) <= `get_23_16(v); `memA(a) <= `get_31_24(v)
`define show_memw(a)        $display("\tmemw{%1d]:   %8h", a, `make_word(`memA(a), `memB(a), `memC(a), `memD(a)) ) 
`define check_memw(a, v, em, sm) if (`make_word(`memA(a), `memB(a), `memC(a), `memD(a)) != v) $display(em); else $display(sm)

`else

`define memW(a)             uut.datapath.dm.mem[a>>2]
`define set_memw(a, v)     `memW(a) <= v
`define show_memw(a)       $display("\tmemw{%1d]:   %8h", a, `memW(a)) 
`define check_memw(a, v, em, sm) if (`memW(a) != v) begin $display(em); fails = fails + 1; end else $display(sm)

`endif


`define register(r)         uut.datapath.reg_file.reg_array[r]
`define set_reg(r, v)       uut.datapath.reg_file.reg_array[r] <= v
`define set_pc(a)           uut.datapath.pc_current <= a
`define set_instr(a, v)     uut.datapath.im.memory[a] <= v

`define show_state          $display("PC:  %8h  Instruction: %32b   Opcode: %7b", uut.datapath.pc_current, uut.datapath.instr, uut.datapath.opcode )

`define tick                clk = ~clk; #5
`define clock_up            clk = 1; #5
`define clock_down          clk = 0; #5
`define run_step            `clock_down; `show_state; `clock_up

`define show_reg(r)         $display("\tx%1d:   %8h", r, uut.datapath.reg_file.reg_array[r])
`define show_pcnext         $display("\tpc_next: %8h", uut.datapath.pc_next)
`define show_pc             $display("\tpc: %8h", uut.datapath.pc_current)

`define check_pcnext(v, em, sm)  if (uut.datapath.pc_next != v) begin $display(em); fails = fails + 1; end else $display(sm)
`define check_pc(v, em, sm)      if (uut.datapath.pc_current != v) begin $display(em); fails = fails + 1; end else $display(sm)
`define check_reg(r, v, em, sm)  if (uut.datapath.reg_file.reg_array[r] != v) begin $display(em); fails = fails + 1; end else $display(sm)

`define check_arith_reg(x1, x2, res, cmd, txt)  `set_pc(0); \
                                                `set_instr(0, 32'b0000000_00010_00001_000_00011_0110011 | (cmd << 12)); \
                                                `set_reg(1, x1);    \
                                                `set_reg(2, x2);    \
                                                `run_step;  \
                                                `show_reg(3);   \
                                                if (`register(3) != res) begin $display("%s %s", txt, "failed"); fails = fails + 1; end else $display("%s %s", txt, "success")

module test_RISC32;

  // Inputs
  reg clk;

  // Instantiate the Unit Under Test (UUT)
  Risc32 uut (
    .clk(clk)
  );

integer fails = 0;

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
      #10;
      fails = 0;
      $display("RISC-V 32 bit - instruction memory: %4d data memory: %4d", `instr_bytes, `data_bytes);
      
      `run_step;
      `show_reg(3);
      `check_reg(3, 32'h0001, "ldw fail", "ldw success");
     
      `run_step;
      `show_reg(1);
      `check_reg(1, 32'h0002, "ldw fail", "ldw success");
      
      `run_step;
      `show_reg(2);
      `check_reg(2, 32'h0003, "add fail", "add success");

      `run_step;    
      `show_memw(4);
      `check_memw(4, 32'h0000_0003, "stw fail", "stw success");

      `run_step;
      `show_reg(2);
      `check_reg(2, 32'hffff_ffff, "sub fail", "sub success");
                  
      `run_step;
      `show_reg(2);
      `check_reg(2, 32'hffff_fffe, "xori fail", "xori success");

      `run_step;
      `show_reg(2);
      `check_reg(2, 32'h0000_0004, "sll fail", "sll success");
      
      `run_step;
      `show_reg(2);
      `check_reg(2, 32'h0000_0000, "srl fail", "srl success");
      
      `run_step; 
      `show_reg(2);
      `check_reg(2, 32'h0000_0000, "and fail", "and success");
  
      `run_step; 
      `show_reg(2);
      `check_reg(2, 32'h0000_0003, "or fail", "or success");    

      `run_step;
      `show_reg(2);
      `check_reg(2, 32'h0000_0001, "slt fail", "slt success");  

      `run_step;
      `show_reg(3);
      `check_reg(3, 32'h0000_0002, "add fail", "add success");  

      `run_step; 
      `show_reg(3);
      `check_reg(3, 32'h0000_1000, "lui fail", "lui success");  

      `run_step; 
      `show_reg(3);
      `check_reg(3, 32'h0000_1034, "auipc fail", "auipc success"); 

      `run_step;
      `show_pc;
      `check_pc(32'h0000_003c, "beq fail", "beq success");
       
      `run_step;
      `show_pc;
      `check_pc(32'h0000_0044, "bne fail", "bne success"); 

      `run_step;
      `show_pc;  
      `check_pc(32'h0000_0010, "jalr fail - jump", "jalr success - jump"); 
      `show_reg(1);
      `check_reg(1, 32'h0000_0048, "jalr fail - store return address", "jalr success - store return address");   

      // can check it like this
      //`clock_down;
      //`show_state;
      //`show_pcnext;
      //`check_pcnext(32'h0000_0010, "jalr fail - jump"); 
      //`clock_up;    
      //`show_reg(1);
      //`check_reg(1, 32'h0000_0048, "jalr fail - store return address");       

      $display("Testbench complete: %d fails", fails);
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
       #10;
       fails = 0;
       $display("RISC-V 32 bit - instruction memory: %4d data memory: %4d", `instr_bytes,  `data_bytes);
       
       `check_arith_reg(1, 5, 6, 3'b000, "add");   
       `check_arith_reg(32'hffff_ffff, 5, 4, 3'b000, "add"); 
       `check_arith_reg(3, 4, 7, 3'b110, "or");  
       `check_arith_reg(32'h55, 32'h50, 32'h5, 3'b100, "xor");  
       `check_arith_reg(32'h55, 32'h55, 32'h0, 3'b100, "xor");  
       `check_arith_reg(32'h55, 32'h50, 32'h50, 3'b111, "and");  
                     
       // Test lw x1, [0 + x2]       
       // Objective - show that a memory word load works
       //                lw rd, rs1(ext_imm)
       //                +++imm++++++_+rs1+_010_++rd+_++op+++ 
       `set_pc(0);
       `set_instr(0, 32'b000000000000_00010_010_00001_0000011);
       `set_memw(4, 32'h0000_7f7f);
       `set_reg(2, 32'h0004);                            // x2 = 4
       `run_step;
       `show_reg(1);
       `check_reg(1, 32'h0000_7f7f, "lw failure", "lw succcess");

       // Test add x3, x1, x2
       // Objective - show that add of hfff and 1 is h1000
       //                add rd, rs1, rs2
       //                +func7+_+rs2+_+rs1+_fu3_++rd+_+++op++ 
       `set_pc(0);
       `set_instr(0, 32'b0000000_00010_00001_000_00011_0110011); 
       `set_reg(1, 32'h0001);    
       `set_reg(2, 32'h0fff);    
       `set_reg(3, 32'h2222);    
       `run_step;
       `show_reg(3);
       `check_reg(3, 32'h0000_1000, "add failure", "add succcess");

       // Test lui x1, h55555
       // Objective - show that lui loads the upper 20 bits
       //                lui rd, imm
       //                ++++++++++imm+++++++_++rd+_+++op++ 
       `set_pc(0);
       `set_instr(0, 32'b01010101010101010101_00001_0110111); 
       `set_reg(1, 32'h0000_0000);    
       `run_step;
       `show_reg(1);
       `check_reg(1, 32'h5555_5000, "lui failure", "lui succcess");

       // Test memory wrap - lw x1, x2(0)   (128) should wrap to 0
       // Objective - show that accessing the word *above* the last word in memory wraps to 0
       //                lw rd, rs1(ext_imm)
       //                +++imm++++++_+rs1+_xxx_++rd+_++op+++  
       `set_pc(0);                                            
       `set_instr(0, 32'b000000000000_00010_010_00001_0000011); 
       `set_memw(0, 32'h7f7f_f7f7);
       `set_memw(124, 32'h8888_8888);     
       `set_reg(2, 32'd128);  
       `run_step;
       `show_reg(1);
       `check_reg(1, 32'h7f7f_f7f7, "lw memory wrap failure", "lw memory wrap succcess");
       
       // Test memory top - lw x1, x2(0)    (124)
       // Objective - show that a read from last word in memory works
       //                lw rd, rs1(ext_imm)
       //                +++imm++++++_+rs1+_010_++rd+_++op+++  
       `set_pc(0);                                            
       `set_instr(0, 32'b000000000000_00010_010_00001_0000011);
       `set_memw(0, 32'h7f7f_f7f7);
       `set_memw(124, 32'h8888_8888);     
       `set_reg(2, 32'd124);  
       `run_step;
       `show_reg(1);
       `check_reg(1, 32'h8888_8888, "lw memory top failure", "lw memory top succcess");
 
       // Test lh x1, [0 + x2]       
       // Objective - show lh does not retrieve the higher two bytes but sets to zeo
       //                lh rd, rs1(ext_imm)
       //                +++imm++++++_+rs1+_001_++rd+_++op+++ 
       `set_pc(0);                                            
       `set_instr(0, 32'b000000000000_00010_001_00001_0000011);
       `set_memw(0, 32'h7f7f_7f7f); 
       `set_reg(2, 32'h0004);  
       `run_step;
       `show_reg(1);
       `check_reg(1, 32'h0000_7f7f, "lh failure", "lh succcess");

       // Test lb x1, [0 + x2]   
       // Objective - show lb does not sign extend when top bit is 0 (ok, it does - but sign extends 0)
       //                lb rd, rs1(ext_imm)
       //                +++imm++++++_+rs1+_000_++rd+_++op+++ 
       `set_pc(0);                                            
       `set_instr(0, 32'b000000000000_00010_000_00001_0000011);
       `set_memw(0, 32'h7f7f_7f7f); 
       `set_reg(2, 32'h0004);  
       `run_step;
       `show_reg(1);
       `check_reg(1, 32'h0000_007f, "lb (7f) failure", "lb (7f) succcess");
 
       // Test lb x1, [0 + x2]       
       // Objective - show lb does sign extend when top bit is 1
       //                lb rd, rs1(ext_imm)
       //                +++imm++++++_+rs1+_000_++rd+_++op+++ 
       `set_pc(0);                                            
       `set_instr(0, 32'b000000000000_00010_000_00001_0000011);
       `set_memw(4, 32'h7777_778f); 
       `set_reg(2, 32'h0004);  
       `run_step;
       `show_reg(1);
       `check_reg(1, 32'hffff_ff8f, "lb (8f) failure", "lb (8f) succcess");       
       
       // Test lhu x1, [0 + x2]         
       // Objective - show lhu does not sign extend the half-word on load
       //                lhu rd, rs1(ext_imm)
       //                +++imm++++++_+rs1+_101_++rd+_++op+++
       `set_pc(0);                                            
       `set_instr(0, 32'b000000000000_00010_101_00001_0000011);
       `set_memw(4, 32'h7777_8f8f); 
       `set_reg(2, 32'h0004);  
       `run_step;
       `show_reg(1);
       `check_reg(1, 32'h0000_8f8f, "lhu failure", "lhu succcess");       
 
       // Test sh x1, [0 + x2]       
       // Objective - show sh only updates lower two bytes in memory
       //                sh rs2, rs1(ext_imm)
       //                +++imm+_+rs2+_+rs1+_001_+imm+_++op+++ 
       `set_pc(0);                                            
       `set_instr(0, 32'b0000000_00001_00010_001_00000_0100011);
       `set_memw(4, 32'h7777_8f8f); 
       `set_reg(2, 32'h0004);  
       `set_reg(1, 32'h9999_9999);  
       `run_step;
       `show_memw(4);
       `check_memw(4, 32'h7777_9999, "sh failure", "sh succcess");   
       
       $display("Testbench complete: %d fails", fails);
       #20;
       $finish;
     end
`endif

endmodule