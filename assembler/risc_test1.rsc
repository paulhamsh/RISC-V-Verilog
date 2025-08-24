// this can be single stepped in the testbench
start:
          lw	x3, 0(x0)             
          lw	x1, 4(x0)             
          add	x2, x3, x1           
          sw	x4, 4(x0)             
          sub	x2, x3, x1           
          xori	x2, x3, -1          
          sll	x2, x3, x1           
          srl	x2, x3, x1           
          and	x2, x3, x1           
          or	x2, x3, x1            
          slt	x2, x3, x1           
          add	x3, x3, x3           
          beq	x12, 12(x3)          
          bne	x8, 8(x3)            
          jalr	x1, 16(x0)          
          jalr	x1, 16(x0)          
//56	jal  x1, start
//60	jal  x1, -44
