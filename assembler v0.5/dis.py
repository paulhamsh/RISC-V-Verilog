# My RISC simple assembler
# Creates assembler from My RISC machine code

# Disassemble a My RISC machine code file

# Writes output to the screen and two files
# Screen and .lmc file have line numbers
# The .mc file doesn't have line numbers

# Format is:

# {label_in_comment}
# {line_number} {binary} {comment}

# {comment} starts with // and run to the end of the line
# {label_in_comment} is formatted: // [label:line_number]
#                    - should be the only thing on that line
# {label} is any set of characters (except a :)
#                    - but A-Z a-z 0-9 and underscore are preferred
# {line_number} is a simple positive integer
# {binary} is a 16 bit binary number with underscores permitted

# Example:
 
# // comment
# // [start:0]
# // [start:0]
#
#           000000000000_00010_000_00011_0000000
#           000000000100_00010_000_00001_0000000  // with comment
# 12      000000_0_00001_00011_000_00010_0001000
# 12       0000000_00010_00001_000_00000_0000100  // with comment

# Instruction formats

# ld     rd,  rs1(imm)
# st     rs2, rs1(imm)
# add    rd,  rs1, rs2
# inv    rd,  rs1	
# beq    rs1, rs2, imm
# bne    rs1, rs2, imm
# jmp    imm
# lui    rd,  imm
#             note the imm for lui is the raw 20 bit value, not in its correct position at top 20 bits

# Machine code

# ld   -----imm----- --rs1 xxx --rd- 00000 00
# st   --imm-- --rs2 --rs1 xxx -imm- 00001 00 
# add  -func7- --rs2 --rs1 fu3 --rd- 00010 00 
# inv  -func7- --xxx --rs1 fu3 --rd- 00100 00
# beq  --imm-- --rs2 --rs1 fu3 -imm- 01011 00 
# bne  --imm-- --rs2 --rs1 fu3 -imm- 01100 00 
# jmp    ----------imm-------  --rd- 01101 00 
# lui    ----------imm-------  --rd- 01110 00 

# As written

# cmd regA, regB, regC, imm
# add r1,   r2,   r3
# ld  r1,   r2          (-12)

# ld   -----imm----- --rgB xxx --rgA 00000 00
# st   --imm-- --rgA --rgB xxx -imm- 00001 00 
# add  -func7- --rgC --rgB fu3 --rgA 00010 00 
# inv  -func7- --xxx --rgB fu3 --rgA 00100 00
# beq  --imm-- --rgB --rgA fu3 -imm- 01011 00 
# bne  --imm-- --rgB --rgA fu3 -imm- 01100 00 
# jmp    ----------imm-------  --rgA 01101 00 
# lui    ----------imm-------  --rgA 01110 00

def is_int(s):
    return s.isnumeric() or (s[0] == "-" and s[1:].isnumeric())

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
    
def disassemble(code):
    full_assembly = []
    opcodes_old = ["ld ", "st ", "add", "sub", "inv", "lsl", "lsr", "and", "or ", "slt", "", "beq", "bne", "jmp", "lui", "lli"]

    line_number = 0
    label_names = {}

    # Pass 1 - add all labels to the label table
    for line in code:
        find_label = line.find("// [")
        find_colon = line.find(":")
        find_end   = line.find("]")
        if find_label > -1 and find_colon > -1 and find_end > -1:    
            label = line[find_label + 4: find_colon]
            value = line[find_colon + 1: find_end]
            if is_int(value):
                label_names[int(value)] = label

   
    # Pass 2 - disassemble
    for line in code:
        comment = ""
        assembly = ""

        # remove anything between braces {}
        brace_start = line.find("{")
        brace_end  = line.find("}")
        if brace_start > -1 and brace_end > -1:
            line = line[:brace_start] + line[brace_end + 1:]

        # split on comment //
        line = line.strip()        
        comment_location = line.find("//")
        if comment_location > -1:
            comment = line[comment_location :]
            line = line[:comment_location]
            
        # check for a label in a comment (at start of comment) // [xxx:yy]
        if comment_location == 0:
            label_start = comment.find("[")
            label_end = comment.find(":")
            if label_start > -1 and label_end > -1:
                output = comment[label_start + 1 : label_end + 1]
            else:
                output = comment
            full_assembly.append((None, output))
            
        # otherwise process the line for disassembly    
        elif line != "":
            value = int(line, 2)

            opcode = get_bits(value, 0, 6)
            rs1    = get_bits(value, 15, 19)
            rs2    = get_bits(value, 20, 24)
            rd     = get_bits(value, 7, 11)
           
            #opcode = opcode >> 2 # drop bottom two bits as not needed
            
            sign      = get_bits(value, 31, 31)   # 1 bit
            val_30_20 = get_bits(value, 20, 30)   # 11 bits
            val_30_25 = get_bits(value, 25, 30)   # 6 bits
            val_24_21 = get_bits(value, 21, 24)   # 5 bits
            val_20    = get_bits(value, 20, 20)   # 1 bit                     
            val_19_12 = get_bits(value, 12, 19)   # 8 bits
            val_11_8  = get_bits(value, 8, 11)    # 4 bits
            val_7     = get_bits(value, 7, 7)     # 1 bit
                                
            imm_I = (sign_extend(sign, 21) << 11) + val_30_20
            imm_S = (sign_extend(sign, 21) << 11) + (val_30_25 << 5)  + (val_11_8 << 1)  + val_7
            imm_B = (sign_extend(sign, 20) << 12) + (val_7 << 11)     + (val_30_25 << 5) + (val_11_8 << 1)
            imm_U = (sign << 31)                  + (val_30_20 << 20) + (val_19_12 << 12)
            imm_J = (sign_extend(sign, 12) << 20) + (val_19_12 << 12) + (val_20 << 11)   + (val_30_25 << 5) + (val_24_21 << 1)
           
            signed_imm_I  = twos_complement_to_int(imm_I, 32)
            signed_imm_S  = twos_complement_to_int(imm_S, 32)
            signed_imm_B  = twos_complement_to_int(imm_B, 32)
            signed_imm_U  = twos_complement_to_int(imm_U, 32)
            signed_imm_J  = twos_complement_to_int(imm_J, 32)
            
            # base instruction
            assembly = f"{opcodes_old[opcode >> 2]:3s} "

            # and process all the optional registers and value
            # ld
            if   opcode == 0b0000_00:
                assembly += f"x{rd:d}, x{rs1:d}({signed_imm_I:d})"
            # st
            elif opcode == 0b0001_00:
                assembly += f"x{rs2:d}, x{rs1:d}({signed_imm_S:d})"
            # jmp, bne, beq
            elif opcode == 0b1101_00 or opcode == 0b1100_00 or opcode == 0b1011_00:
                if opcode == 0b1101_00:
                    imm = signed_imm_J  # jump
                else:
                    imm = signed_imm_B  # branch
                    assembly += f"x{rs1:d}, x{rs2:d}, "
                # this is the same logic for branch or jump - either use the label or calculated value
                jump_dest = line_number + imm
                if label_names.get(jump_dest):
                    assembly += label_names[jump_dest]
                else:
                    assembly += f"{imm:d}"
                    # check to see if we already have a comment or not
                    if comment == "":
                        comment = "//"
                    comment += f" {{jump {jump_dest:d}}}" 
            # inv
            elif opcode == 0b0100_00:
                assembly += f"x{rd:d}, x{rs1:d}"
            # lui
            elif opcode == 0b1110_00:
                # for LUI just show the base value, not in its real position
                shift_imm = signed_imm_U >> 12
                assembly += f"x{rd:d}, {shift_imm:d}"            
            # other arithmetic instructions
            else:
                assembly += f"x{rd:d}, x{rs1:d}, x{rs2:d}"

            # create the output with the assembly plus a comment
            # (which could be empty)
            output = f"{assembly:25s}" + comment
 
            full_assembly.append((line_number, output))
            line_number += 4
            
    return full_assembly

##############################################################

import sys, os

if len(sys.argv) > 1:
    filename = sys.argv[1]
    splitname = filename.split(".")
    outname1 = splitname[0] +".rsc"
    outname2 = splitname[0] +".lrs"
else:
    #filename = "test1.mc"
    filename = "test_prog1.mc"
    outname1 = None

f = open(filename, mode='r')
code = f.readlines()
f.close()
code_clean =[line.strip() for line in code]


ass = disassemble(code_clean)

# helper to reduce number of checks on files in the main loop
def printfile(txt, f):
    if f != None:
        print(txt, file = f)
        
# Print out the result

if outname1:
    f1 = open(outname1, mode='w')
    f2 = open(outname2, mode='w')
else:
    f1 = None
    f2 = None

for line_no, line in ass:
    if line_no != None:
        s1 = f"          {line:s}"
        s2 = f"{line_no:<4d}      {line:s}"
        print(s2)
        printfile(s1, f1)
        printfile(s2, f2)
    else:
        print(line)
        printfile(line, f1)
        printfile(line, f2)

if outname1:        
    f1.close()
    f2.close()

