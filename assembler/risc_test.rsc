start:
          lb	x1, x2(0)             
          lh	x1, x2(0)             
          lw	x1, x2(0)             
          lbu	x1, x2(0)            
          lhu	x1, x2(0)            
          lhu	x1, x2(0)            
          sb	x0, x2(0)             
          sh	x0, x2(0)             
          sw	x0, x2(0)             
          sb	x31, x2(2047)         
          sb	x31, x2(2047)         
          sb	x31, x2(-1)           
          sb	x0, x2(-2048)         
          add	x1, x2, x3           
          sub	x1, x2, x3           
          sll	x1, x2, x3           
          slt	x1, x2, x3           
          sltu	x1, x2, x3          
          xor	x1, x2, x3           
          srl	x1, x2, x3           
          sra	x1, x2, x3           
          or	x1, x2, x3            
          and	x1, x2, x3           
          addi	x1, x2, 0           
          slti	x1, x2, 2047        
          sltiu	x1, x2, 2047       
          xori	x1, x2, 2047        
          ori	x1, x2, -1           
          andi	x1, x2, -1          
          slli	x1, x2, 1           
          srli	x1, x2, 1           
          srai	x1, x2, 1           
// branches must be even  and ought to be a multiple of 4 really
// so use even numbers in assembly
          beq	x2, x2(2)            
          bne	x31, x3(4094)        
          blt	x30, x3(2046)        
          bge	x30, x3(2046)        
          bltu	x31, x3(-2)         
          bgeu	x1, x1(-2048)       
// jal must be even  and ought to be a multiple of 4 really
// so use even numbers in assembly
          jal	x1, 2046             
          jal	x1, 524286           
          jal	x1, -524288          
          jal	x1, -2               
// jalr can be odd, but when placed into the pc will have the final bit dropped regardless
          jalr	x1, x2(-1)          
          jalr	x1, x2(1)           
          jalr	x1, x2(2047)        
          auipc	x1, 524287         
          auipc	x1, -1             
          lui	x1, 524287           
          lui	x1, -1               
