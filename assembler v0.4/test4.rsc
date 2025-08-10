// comment line
start:
another_label:
another:
// with comment
          ld  x3, x2(0)            
          ld  x1, x2(1)            
jump_point:
here:
          add x2, x3, x1           
          jmp here                 
          st  x2, x1(0)            
          sub x2, x3, x1           
          inv x2, x3               
          lsl x2, x3, x1           
          lsr x2, x3, x1           
          and x2, x3, x1           
          or  x2, x3, x1           
          slt x2, x3, x1           
          add x3, x3, x3           
          beq x3, x2, 4            // {jump 60}
          bne x3, x2, 0            // {jump 60}
          jmp another              
cont:
          ld  x1, x2(5)            // comment
          st  x3, x5(3)            // this is
          add x4, x2, x1           // a
interim:
          sub x7, x3, x3           // comment
          lsl x6, x4, x1           
          lsr x5, x5, x2           
          slt x4, x6, x3           
          and x3, x7, x4           
          or  x2, x5, x6           
          inv x1, x2               
          beq x1, x2, another      
          beq x1, x2, -8           // {jump 104}
          bne x1, x2, end          
          lui x5, 103              
          jmp interim              
end:
          jmp end                  
          jmp another              
