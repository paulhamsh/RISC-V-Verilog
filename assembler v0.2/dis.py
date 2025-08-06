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
#        000000_000_000_00_010_00000_000_000_0000 
#        000100_000_000_00_010_00000_001_000_0000 // with comment
# 12     000000_000_001_00_000_00000_010_000_0010
# 12     000000_000_001_00_000_00000_010_000_0010 // with comment

# Instruction formats

# ld     rd,  rs1(offset6)
# st     rs2, rs1(offset6)
# add    rd,  rs1, rs2
# inv    rd,  rs1	
# beq    rs1, rs2, offset6
# bne    rs1, rs2, offset6
# jmp    offset12
# lui    rd,  rs1, imm8
# lli    rd,  rs1, imm8

# Machine code

# ld   -off6- x --rs2 --rs1 xxx --rd- xxx 0000
# st   -off6- x --rs2 --rs1 xxx xxxxx xxx 0001  
# add  xxxxxx x --rs2 --rs1 xxx --rd- xxx 0010  
# inv  xxxxxx x --xxx --rs1 xxx --rd- xxx 0100
# beq  -off6- x --rs2 --rs1 xxx xxxxx xxx 1011  
# bne  -off6- x --rs2 --rs1 xxx xxxxx xxx 1100  
# jmp   ----off12---  xxxxx xxx xxxxx xxx 1101  
# lui  --imm8-- x xxx --rs1 xxx --rd- xxx 1110 
# lli  --imm8-- x xxx --rs1 xxx --rd- xxx 1111

# As written

# cmd regA, regB, regC, value/offset12/imm8
# add x1,   x2,   x3
# ld  x1,   x2          (-12)

# ld   -off6- x xxxxx --rgB xxx --rgA xxx 0000
# st   -off6- x --rgA --rgB xxxxx xxx xxx 0001  
# add  xxxxxx x --rgC --rgB xxx --rgA xxx 0010  
# inv  xxxxxx x xxxxx --rgB xxx --rgA xxx 0100
# beq  -off6- x --rgB --rgA xxxxx xxx xxx 1011  
# bne  -off6- x --rgB --rgA xxxxx xxx xxx 1100  
# jmp   ----off12---  xxxxx xxxxx xxx xxx 1101  
# lui  --imm8-- x xxx --rgB xxx --rgA xxx 1110 
# lli  --imm8-- x xxx --rgB xxx --rgA xxx 1111

def is_int(s):
    return s.isnumeric() or (s[0] == "-" and s[1:].isnumeric())

def disassemble(code):
    full_assembly = []
    opcodes = ["ld ", "st ", "add", "sub", "inv", "lsl", "lsr", "and", "or ", "slt", "", "beq", "bne", "jmp", "lui", "lli"]

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

            opcode = (value & 0b000000_0_00000_00000_000_00000_000_1111)
            rs1    = (value & 0b000000_0_00000_11111_000_00000_000_0000)  >> 15
            rs2    = (value & 0b000000_0_11111_00000_000_00000_000_0000)  >> 20
            rd     = (value & 0b000000_0_00000_00000_000_11111_000_0000)  >> 7
            off6   = (value & 0b111111_0_00000_00000_000_00000_000_0000)  >> 26
            off12  = (value & 0b111111_1_11111_00000_000_00000_000_0000)  >> 20
            imm8   = (value & 0b111111_11_0000_00000_000_00000_000_0000) >> 24
           
            # fix signed offset
            if off6 > 31:
                signed_offset = off6 - 64
            else:
                signed_offset = off6

            # base instruction
            assembly = f"{opcodes[opcode]:3s} "

            # and process all the optional registers and value
            # ld
            if   opcode == 0b0000:
                assembly += f"x{rd:d}, x{rs1:d}({signed_offset:d})"
            # st
            elif opcode == 0b0001:
                assembly += f"x{rs2:d}, x{rs1:d}({signed_offset:d})"
            # jmp
            elif opcode == 0b1101:
                jump_dest = off12 * 4
                if label_names.get(jump_dest):
                    assembly += label_names[jump_dest]
                else:
                    assembly += f"{jump_dest:d}"
            # beq and bne
            elif opcode == 0b1100 or opcode == 0b1011:
                assembly += f"x{rs1:d}, x{rs2:d}, "
                word_offset = signed_offset * 4
                jump_dest = line_number + 4 + word_offset
                if label_names.get(jump_dest):
                    assembly += label_names[jump_dest]
                else:
                    assembly += f"{word_offset:d}"
                    # check to see if we already have a comment or not
                    if comment == "":
                        comment = "//"
                    comment += f" {{jump {jump_dest:d}}}"
            # inv
            elif opcode == 0b0100:
                assembly += f"x{rd:d}, x{rs1:d}"
            # lli and lui
            elif opcode == 0b1110 or opcode == 0b1111:
                assembly += f"x{rd:d}, x{rs1:d}, {imm8:d}"
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
    filename = "test1.mc"
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

