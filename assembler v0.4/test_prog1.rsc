start:
          ld  x3, x2(0)            
          ld  x1, x2(4)            
          add x2, x3, x1           
          st  x2, x1(0)            
          sub x2, x3, x1           
          inv x2, x3               
          lsl x2, x3, x1           
          lsr x2, x3, x1           
          and x2, x3, x1           
          or  x2, x3, x1           
          slt x2, x3, x1           
          add x3, x3, x3           
          beq x3, x2, next         
          jmp next                 
          jmp -44                  // {jump 16}
next:
          bne x3, x2, -8           // {jump 56}
          jmp -12                  // {jump 56}
          lui x4, 124              
          ld  x3, x2(-10)          
          ld  x3, x2(-2048)        
          ld  x3, x2(2047)         // will not work!
          st  x2, x3(2047)         
