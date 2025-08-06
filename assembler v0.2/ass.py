# My RISC simple assembler
# Creates machine code from My RISC assembler

# Writes output to the screen and two files
# Screen and .lrs file have line numbers
# The .rsc file doesn't have line numbers

# Assemble a My RISC machine code file

# Format is:
# {line_number} {label} {code} {comment}
# Where any item may be present or missing
# Comments start //
# Anything after a left brace will be removed  - {

# Example:

# label_here:
#      ld rd, rs1(2)
#      jmp label       // comment at end of line
#      // standalone comment
# end: jmp end

# NOTE - any jump or banch offsets / immediate values are the actual number of bytes,
#        rather than the number of instructions


import re


# Check for leading negative sign - no need to check for plus sign as that is removed as whitespace

def is_uint(s):
    return s.isnumeric()

def is_int(s):
    return s.isnumeric() or (s[0] == "-" and s[1:].isnumeric())

        
def tokenise(txt) :
    # remove () and [] and + that might surround / precede an integer
    # make the left bracket and + into a space - for split()
    # and remove the right brackets
    # so:
    # ld x0, x2(0) => ld x0 x2 0
    # ld x0, x2+10 => ld x0 x2 10
    
    txt = txt.replace("[", " ")
    txt = txt.replace("]","")
    txt = txt.replace("(", " ")
    txt = txt.replace(")","")
    txt = txt.replace("+", " ")
    txt = txt.lower()

    # remove anything in braces {} - only allowed once in any line
    l_brace = txt.find("{")
    r_brace = txt.find("}")
    if r_brace > -1 and l_brace > -1:
        txt = txt[ : l_brace] + txt [r_brace + 1: ]

    # process comments - anything from // to end of the line
    comment = ""
    comment_location = txt.find("//")
    if comment_location != -1:
        comment = txt[comment_location : ]
        txt = txt[ : comment_location].strip()
    
    sp = re.split("[,\s]+", txt)

    label = None	
    cmd   = None	
    regA  = None	
    regB  = None	
    regC  = None	
    value = None
    jmp_label = None

    for ind, c in enumerate(sp):
        if len(c) > 0:             # don't process an empty cell
            if ind == 0 and is_int(c):
                # ignore line numbers
                pass
            elif c[-1] == ":":
                label = c[:-1]
            elif cmd == None:
                cmd = c
            elif regA == None and c[0] == "x" and is_uint(c[1:]):
                regA = int(c[1])
            elif regB == None and c[0] == "x" and is_uint(c[1:]):
                regB = int(c[1])
            elif regC == None and c[0] == "x" and is_uint(c[1:]):
                regC = int(c[1])
            elif value == None  and is_int(c):
                value = int(c)
            else:
                jmp_label = c
          
    return label, cmd, regA, regB, regC, value, jmp_label, comment

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

# ld   -off6- x --rs2 --rs1 xxx --rd- 0 0000 11
# st   -off6- x --rs2 --rs1 xxx xxxxx 0 0001 11 
# add  xxxxxx x --rs2 --rs1 xxx --rd- 0 0010 11 
# inv  xxxxxx x --xxx --rs1 xxx --rd- 0 0100 11
# beq  -off6- x --rs2 --rs1 xxx xxxxx 0 1011 11 
# bne  -off6- x --rs2 --rs1 xxx xxxxx 0 1100 11 
# jmp   ----off12---  xxxxx xxx xxxxx 0 1101 11 
# lui  --imm8-- x xxx --rs1 xxx --rd- 0 1110 11 
# lli  --imm8-- x xxx --rs1 xxx --rd- 0 1111 11

# As written

# cmd regA, regB, regC, value/offset12/imm8
# add r1,   r2,   r3
# ld  r1,   r2          (-12)

# ld   -off6- x xxxxx --rgB xxx --rgA 0 0000 11
# st   -off6- x --rgA --rgB xxxxx xxx 0 0001 11 
# add  xxxxxx x --rgC --rgB xxx --rgA 0 0010 11 
# inv  xxxxxx x xxxxx --rgB xxx --rgA 0 0100 11
# beq  -off6- x --rgB --rgA xxxxx xxx 0 1011 11 
# bne  -off6- x --rgB --rgA xxxxx xxx 0 1100 11 
# jmp   ----off12---  xxxxx xxxxx xxx 0 1101 11 
# lui  --imm8-- x xxx --rgB xxx --rgA 0 1110 11
# lli  --imm8-- x xxx --rgB xxx --rgA 0 1111 11

def assemble(code):
    result = []
    label_to_line = {}
    line_to_label = {}
    
    arith_cmds = {"add": 2, "sub": 3, "lsl": 5,
                  "lsr": 6, "and": 7, "or" : 8,
                  "slt": 9}
    
    # Pass 1 - for labels
    line_number = 0
    for line in code:
        (label, cmd, regA, regB, regC, value, jmp_label, comment) = tokenise(line)
        if label:
            label_to_line[label] = line_number
            line_to_label[line_number] = label
        if cmd:
            line_number += 4

    # Pass 2 - assembly
    line_number = 0
    for line in code:
        (label, cmd, regA, regB, regC, value, jmp_label, comment) = tokenise(line)
        code = ""
        
        # Calculate a jump offset
        if jmp_label:
            if cmd == "jmp":
                value = label_to_line[jmp_label]
            else:
                # only do this if we are bne or beq
                value = label_to_line[jmp_label] - (line_number + 4)

        # need to create values for: signed offsets, signed branch offset, jump offset, lli/lui immediate
        if value is not None:
            branch_value = value >> 2
            jump_value = value >> 2
            signed_value = value
            immediate = value
            
            if branch_value < 0:
                branch_value = 64 + branch_value


            if signed_value < 0:
                signed_value = 64 + signed_value
            
        if cmd:
            if   cmd == "ld":
                code = f"{signed_value:06b}_0_00000_{regB:05b}_000_{regA:05b}_0000011"
            elif cmd == "st":
                code = f"{signed_value:06b}_0_{regA:05b}_{regB:05b}_000_00000_0000111"
            elif cmd == "beq":
                code = f"{branch_value:06b}_0_{regB:05b}_{regA:05b}_000_00000_0101111"
            elif cmd == "bne":
                code = f"{branch_value:06b}_0_{regB:05b}_{regA:05b}_000_00000_0110011"
            elif cmd == "jmp":		
                code = f"  {jump_value:012b}_00000_000_00000_0110111"
            elif cmd == "inv":		
                code = f" 000000_000000_{regB:05b}_000_{regA:05b}_0010011"
            elif cmd == "lui":		
                code = f"{immediate:08b}_0_000_{regB:05b}_000_{regA:05b}_0111011"
            elif cmd == "lli":		
                code = f"{immediate:08b}_0_000_{regB:05b}_000_{regA:05b}_0111111"
            elif cmd in arith_cmds:		
                code = f"000000_0_{regC:05b}_{regB:05b}_000_{regA:05b}_0{arith_cmds[cmd]:04b}11" 
                
        result.append((line_number, label, code, comment))
        if code:
            line_number += 4
            
    return result

##############################################################


import sys, os
filename = ""

if len(sys.argv) == 2:
    filename = sys.argv[1]
    splitname = re.split("\.", filename)
    outname1 = splitname[0] + ".mc"
    outname2 = splitname[0] + ".lmc"
else:
    filename = "test4.rscin"
    outname1 = None
    outname2 = None

# read input file  into code_clean   
f = open(filename, mode='r')
code = f.readlines()
f.close()
code_clean =[line.strip() for line in code]

# assemble
fmc = assemble(code_clean)

# Print out the result
for l in code_clean:
    print(l)

print()

# helper to reduce number of checks on files in the main loop
def printfile(txt, f):
    if f != None:
        print(txt, file = f)
        
# Print machine code to two files, one with line numbers, one without
if outname1:
    f1 = open(outname1, mode='w')
    f2 = open(outname2, mode='w')
else:
    f1 = None
    f2 = None
    
for line_no, label, code, comment in fmc:
    if label:
        s = f"// [{label:s}:{line_no:d}]"
        print(s)
        printfile(s, f1)
        printfile(s, f2)

    if comment and not code:
        s = f"       {comment:s}"
        print(s)
        printfile(s, f1)
        printfile(s, f2)
        
    if code:
        s1 = f"        {code:22s} {comment:s}"
        s2 = f"{line_no:<4d}    {code:22s} {comment:s}"
        print(s2)
        printfile(s1, f1)
        printfile(s2, f2)

if outname1:
    f1.close()
    f2.close()
