          ld  r0, r2(0)            // 00 load R0 <- Mem(R2 + 0)                  ALU_op = 000  R0 = 1 Mem[0 + 0]
          ld  r1, r2(4)            // 01 load R1 <- Mem(R2 + 4)                  ALU_op = 000  R1 = 2 Mem[0 + 4]
          add r2, r0, r1           // 02 Add R2 <- R0 + R1                       ALU_op = 000  R2 = 3
          st  r2, r1(0)            // 03 Store Mem(R1 + 0) <- R2                 ALU_op = 000  Mem[4 + 0] = 3
          sub r2, r0, r1           // 04 sub R2 <- R0 - R1                       ALU_op = 001  R2 = 1111_1111_1111_1111__1111_1111_1111_1111 (-1)
          inv r2, r0               // 05 invert R2 <- !R0                        ALU_op = 100  R2 = 1111111111111110
          lsl r2, r0, r1           // 06 logical shift left R2 <- R0<<R1         ALU_op = 011  R2 = 0000000000000100
          lsr r2, r0, r1           // 07 logical shift right R2 <- R0>>R1        ALU_op = 100  R2 = 0000000000000000
          and r2, r0, r1           // 08 AND R2<- R0 AND R1                      ALU_op = 101  R2 = 0000000000000000
          or  r2, r0, r1           // 09 OR R2<- R0 OR R1                        ALU_op = 110  R2 = 0000000000000011
          slt r2, r0, r1           // 0a SLT R2 <- 1 if R0 < R1                  ALU_op = 111  R2 = 0000000000000001
          add r0, r0, r0           // 0b Add R0 <- R0 + R0                       ALU_op = 000  R0 = 0000000000000010
          beq r0, r2, 4            // 0c BEQ branch to jump if R0==R2, PCnew= PC+2+offset<<1 = 28 => offset = 1  will not branch {jump 56}
          bne r0, r2, 0            // 0d BNE branch to jump if R0!=R2, PCnew= PC+2+offset<<1 = 28 => offset = 0  will branch {jump 56}
          jmp 0                    // 0e J jump to the beginning address
