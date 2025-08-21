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


def int_to_twos_complement(val, bits):
    if val < 0:
        return val + (1 << bits)
    else:
        return val


def get_bits(value, start, end):
    mask = (1 << (end - start + 1)) -1
    return (value >> start) & mask

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

# ld     rd,  rs1(imm)
# st     rs2, rs1(imm)
# add    rd,  rs1, rs2
# inv    rd,  rs1	
# beq    rs1, rs2, imm
# bne    rs1, rs2, imm
# jmp    imm
# lui    rd,  imm

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
        
        # Replace a jump label with the value
        if jmp_label:
            value = label_to_line[jmp_label] - line_number
           
        if cmd:
            if   cmd == "ld":
                imm = int_to_twos_complement(value, 12)
                imm_11_0 = get_bits(imm, 0,  11)
                code = f"   {imm_11_0:012b}_{regB:05b}_000_{regA:05b}_0000000"
            elif cmd == "st":
                imm = int_to_twos_complement(value, 12)
                imm_11_5 = get_bits(imm, 5,  11)
                imm_4_0  = get_bits(imm, 0,  4)
                code = f"  {imm_11_5:07b}_{regA:05b}_{regB:05b}_000_{imm_4_0:05b}_0000100"
            elif cmd == "beq":
                #         imm[12]    imm[10:5]      imm[4:1]   imm[11]            per spec
                # get 13 bit twos complement as we drop the final bit
                imm = int_to_twos_complement(value, 13)
                imm_12   = get_bits(imm, 12, 12)
                imm_10_5 = get_bits(imm, 5,  10)
                imm_4_1  = get_bits(imm, 1,  4)
                imm_11   = get_bits(imm, 11, 11)
                code = f"{imm_12:01b}_{imm_10_5:06b}_{regB:05b}_{regA:05b}_000_{imm_4_1:04b}_{imm_11:01b}_0101100"
            elif cmd == "bne":
                #         imm[12]    imm[10:5]      imm[4:1]   imm[11]            per spec
                # get 13 bit twos complement as we drop the final bit
                imm = int_to_twos_complement(value, 13)
                imm_12   = get_bits(imm, 12, 12)
                imm_10_5 = get_bits(imm, 5,  10)
                imm_4_1  = get_bits(imm, 1,  4)
                imm_11   = get_bits(imm, 11, 11)
                code = f"{imm_12:01b}_{imm_10_5:06b}_{regB:05b}_{regA:05b}_000_{imm_4_1:04b}_{imm_11:01b}_0110000"
            elif cmd == "jmp":
                #         imm[20]    imm[10:1]      imm[11]    imm[19:12]         per spec
                # get 21 bit twos complement as we drop the final bit
                imm = int_to_twos_complement(value, 21)
                imm_20    = get_bits(imm, 20, 20)
                imm_10_1  = get_bits(imm, 1,  10)
                imm_11    = get_bits(imm, 11, 11)
                imm_19_12 = get_bits(imm, 12, 19)
                code = f"  {imm_20:01b}_{imm_10_1:010b}_{imm_11:01b}_{imm_19_12:08b}_00000_0110100"
            elif cmd == "inv":		
                code = f"  000000_000000_{regB:05b}_000_{regA:05b}_0010000"
            elif cmd == "lui":
                imm = int_to_twos_complement(value, 20)
                code = f"     {imm:020b}_{regA:05b}_0111000"
            elif cmd in arith_cmds:		
                code = f" 000000_0_{regC:05b}_{regB:05b}_000_{regA:05b}_0{arith_cmds[cmd]:04b}00"
            else:
                code = "ERROR"
                
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
    filename = "test_prog.rscin"
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
