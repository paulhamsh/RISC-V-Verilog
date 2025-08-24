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
#           000000000000_00010_000_00011_00000_11
#           000000000100_00010_000_00001_00000_11  // with comment
# 12      000000_0_00001_00011_000_00010_00010_11
# 12       0000000_00010_00001_000_00000_00001_11  // with comment

# Instruction formats

# lw     rd,  imm(rs1)
# sw     rs2, imm(rs1)
# add    rd,  rs1, rs2
# beq    rs1, rs2, imm
# jal    rd,  imm
# jalr   rd,  imm(rs1)
# lui    rd,  imm
# auipc  rd,  imm


# Machine code

# add    -func7- --rs2 --rs1 fu3 --rd- 01100 11 
# addi   -func7- --rs2 --rs1 fu3 --rd- 00100 11 
# lw     -----imm----- --rs1 dw- --rd- 00000 11
# sw     --imm-- --rs2 --rs1 dw- -imm- 01000 11
# beq    --imm-- --rs2 --rs1 fu3 -imm- 11000 11
# jalr   -----imm----- --rs1 000 --rd- 11001 11
# jal      ----------imm-------  --rd- 11011 11
# lui      ----------imm-------  --rd- 01101 11
# auipc    ----------imm-------  --rd- 00101 11  

# As written

# cmd regA, regB, regC, imm
# add r1,   r2,   r3
# ld  r1,   r2          (-12)

# add    -func7- --rgC --rgB fu3 --rgA 01100 11  
# addi   -func7- --rgC --rgB fu3 --rgA 00100 11
# lw     -----imm----- --rgB dw- --rgA 00000 11
# sw     --imm-- --rgA --rgB dw- -imm- 01000 11
# beq    --imm-- --rgB --rgA fu3 -imm- 11000 11 
# jalr   -----imm----- --rgB 000 --rdA 11001 11
# jal      ----------imm-------  --rgA 11011 11
# lui      ----------imm-------  --rgA 01101 11
# auipc    ----------imm-------  --rgA 00101 11

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
            rd     = get_bits(value, 7, 11)
            func3  = get_bits(value, 12, 14)
            rs1    = get_bits(value, 15, 19)
            rs2    = get_bits(value, 20, 24)
            func7  = get_bits(value, 25, 31)
           
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
            
            # and process all the optional registers and value


            if   opcode == 0b01100_11:
                # arithmetic r type
                arith_r_cmds = ["add", "sll", "slt", "sltu", "xor",
                                "srl", "or",  "and", "sub",  "",
                                "",    "",    "",    "sra"]
                ind = (func7 >> 2) + func3
                assembly = arith_r_cmds[ind] + "\t"
                assembly += f"x{rd:d}, x{rs1:d}, x{rs2:d}"
            elif opcode == 0b00100_11:
                # arithmetic i type
                arith_i_cmds = ["addi", "slli", "slti", "sltiu", "xori",
                                "srli", "ori",  "andi", "",  "",
                                "",    "",    "",    "srai"]
                # check for the three shift instructions with 5 bit immediate
                if (func3 == 1 or func3 == 5):
                    ind = (func7 >> 2) + func3
                    assembly = arith_i_cmds[ind] + "\t"
                    assembly += f"x{rd:d}, x{rs1:d}, {imm_I & 31:d}"
                else:
                    assembly = arith_i_cmds[func3] + "\t"
                    assembly += f"x{rd:d}, x{rs1:d}, {signed_imm_I:d}"
            elif opcode == 0b00000_11:
                # load
                load_cmds = ["lb", "lh", "lw", "", "lbu", "lhu"]
                assembly = load_cmds[func3] + "\t"
                assembly += f"x{rd:d}, {signed_imm_I:d}(x{rs1:d})"                 
            elif opcode == 0b01000_11:
                # store
                store_cmds = ["sb", "sh", "sw"]
                assembly = store_cmds[func3] + "\t"
                assembly += f"x{rd:d}, {signed_imm_S:d}(x{rs1:d})" 
            elif opcode == 0b11000_11:
                # branch
                branch_cmds = ["beq", "bne", "", "", "blt", "bge", "bltu", "bgeu"]
                assembly = branch_cmds[func3] + "\t"
                assembly += f"x{rd:d}, {signed_imm_B:d}(x{rs1:d})" 
            elif opcode == 0b11001_11:
                # jalr
                assembly = "jalr" + "\t"
                assembly += f"x{rd:d}, {signed_imm_I:d}(x{rs1:d})"                
            elif opcode == 0b11011_11:
                # jal
                assembly = "jal" + "\t"
                shift_imm = signed_imm_J 
                assembly += f"x{rd:d}, {shift_imm:d}"
                
            elif opcode == 0b01101_11:
                # lui
                assembly = "lui" + "\t"
                shift_imm = signed_imm_U >> 12
                assembly += f"x{rd:d}, {shift_imm:d}"    
            elif opcode == 0b00101_11:
                # auipc
                assembly = "auipc" + "\t"
                shift_imm = signed_imm_U >> 12
                assembly += f"x{rd:d}, {shift_imm:d}" 


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
    filename = "risc_test.mc"
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

