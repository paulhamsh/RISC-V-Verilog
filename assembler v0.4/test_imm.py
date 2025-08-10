def twos_complement_to_int(val, bits):
    limit = 1 << bits
    max_positive_int = (1 << (bits - 1)) - 1
 
    if val > max_positive_int:
        return val - limit
    else:
        return val
 
def get_bits(value, start, end):
    mask = (1 << (end - start + 1)) -1
    return (value >> start) & mask
 
def sign_extend(value, bits):
    if value == 1:
        return (1 << bits) - 1
    else:
        return 0
 
def get_imm(value):
    sign      = get_bits(value, 31, 31)   # 1 bit
    val_30_20 = get_bits(value, 20, 30)   # 11 bits
    val_30_25 = get_bits(value, 25, 30)   # 6 bits
    val_24_21 = get_bits(value, 21, 24)   # 5 bits
    val_20    = get_bits(value, 20, 20)   # 1 bit                     
    val_19_12 = get_bits(value, 12, 19)   # 8 bits
    val_11_8  = get_bits(value, 8, 11)    # 4 bits
    val_7     = get_bits(value, 7, 7)     # 1 bit
                                
    imm_I = (sign_extend(sign, 21) << 11) + val_30_20
    imm_S = (sign_extend(sign, 21) << 11) + (val_30_25 << 5) + (val_11_8 << 1) + val_7
    imm_B = (sign_extend(sign, 20) << 12) + (val_7 << 11) + (val_30_25 << 5) + (val_11_8 << 1)
    imm_U = (sign << 31) + (val_30_20 << 20) + (val_19_12 << 12)
    imm_J = (sign_extend(sign, 12) << 20) + (val_19_12 << 12) + (val_20 << 11) + (val_30_25 << 5) + (val_24_21 << 1)
    return (imm_I, imm_S, imm_B, imm_U, imm_J)
 
   
 
 
print("I type")
print("sssssssssssssssssssssxxxxxxxxxxx")
(i,s,b,u,j) = get_imm(0b0_00000000000_11111_111_11111_111_1111) 
print(f"{i:032b}")
(i,s,b,u,j) = get_imm(0b1_11111111111_00000_000_00000_0000000)
print(f"{i:032b}")
(i,s,b,u,j) = get_imm(0b1_00000000000_00000_000_00000_0000000)
print(f"{i:032b}")
(i,s,b,u,j) = get_imm(0b1_01010101010_00000_000_00000_0000000)
print(f"{i:032b}")
(i,s,b,u,j) = get_imm(0b0_10101010101_00000_000_00000_0000000)
print(f"{i:032b}")


print("S type")
print("sssssssssssssssssssssxxxxxxxxxxx")
(i,s,b,u,j) = get_imm(0b0_000000_11111_11111_111_00000_1111111) 
print(f"{s:032b}")
(i,s,b,u,j) = get_imm(0b1_111111_00000_00000_000_11111_0000000)
print(f"{s:032b}")
(i,s,b,u,j) = get_imm(0b1_000000_00000_00000_000_00000_0000000)
print(f"{s:032b}")
(i,s,b,u,j) = get_imm(0b1_010101_00000_00000_000_01010_0000000)
print(f"{s:032b}")
(i,s,b,u,j) = get_imm(0b0_101010_00000_00000_000_10101_0000000)
print(f"{s:032b}")


print("U type")
print("sxxxxxxxxxxxxxxxxxxx000000000000")
(i,s,b,u,j) = get_imm(0b0_0000000000000000000_11111_1111111) 
print(f"{u:032b}")
(i,s,b,u,j) = get_imm(0b1_1111111111111111111_00000_0000000)
print(f"{u:032b}")
(i,s,b,u,j) = get_imm(0b1_0000000000000000000_00000_0000000)
print(f"{u:032b}")
(i,s,b,u,j) = get_imm(0b1_0101010101010101010_00000_0000000)
print(f"{u:032b}")
(i,s,b,u,j) = get_imm(0b0_1010101010101010101_00000_0000000)
print(f"{u:032b}")


print("B type")
print("ssssssssssssssssssssxxxxxxxxxxx0")
(i,s,b,u,j) = get_imm(0b0_000000_11111_11111_111_00000_1111111) 
print(f"{b:032b}")
(i,s,b,u,j) = get_imm(0b1_111111_00000_00000_000_1111_1_0000000)
print(f"{b:032b}")
(i,s,b,u,j) = get_imm(0b1_000000_00000_00000_000_0000_0_0000000)
print(f"{b:032b}")
(i,s,b,u,j) = get_imm(0b1_101010_00000_00000_000_1010_0_0000000)
print(f"{b:032b}")
(i,s,b,u,j) = get_imm(0b0_010101_00000_00000_000_0101_1_0000000)
print(f"{b:032b}")

print("J type")
print("ssssssssssssxxxxxxxxxxxxxxxxxxx0")
(i,s,b,u,j) = get_imm(0b0_0000000000_0_00000000_11111_1111111) 
print(f"{j:032b}")
(i,s,b,u,j) = get_imm(0b1_1111111111_1_11111111_00000_0000000)
print(f"{j:032b}")
(i,s,b,u,j) = get_imm(0b1_0000000000_0_00000000_00000_0000000)
print(f"{j:032b}")
(i,s,b,u,j) = get_imm(0b1_1010101010_0_01010101_00000_0000000)
print(f"{j:032b}")
(i,s,b,u,j) = get_imm(0b0_0101010101_1_10101010_00000_0000000)
print(f"{j:032b}")

