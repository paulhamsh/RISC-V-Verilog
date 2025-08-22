start:
          ld  x3, x2(0)            
          ld  x1, x2(4)            
          add	x2, x3, x1           
          st  x2, x1(0)            
          sub	x2, x3, x1           
          inv x2, x3               
          lsl x2, x3, x1           
          lsr x2, x3, x1           
          and	x2, x3, x1           
          or	x2, x3, x1            
          slt	x2, x3, x1           
          add	x3, x3, x3           
          beq	x8, x3(8)            
          jmp next                 
          jmp -44                  // {jump 12}
next:
          bne	x25, x3(-8)          
          jmp -12                  // {jump 52}
          lui	x4, 124              
          ld  x3, x2(-10)          
          ld  x3, x2(-2048)        
          ld  x3, x2(2047)         // will not work!
          st  x2, x3(2047)         
