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

# lw     rd,  rs1(imm)
# sw     rs2, rs1(imm)
# add    rd,  rs1, rs2
# beq    rs1, rs2, imm
# jal    rd,  imm
# jalr   rd,  rs1(imm)
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

def assemble(code):
    result = []
    label_to_line = {}
    line_to_label = {}
    
    old_arith_cmds = {"add": 2, "sub": 3, "lsl": 5,
                  "lsr": 6, "and": 7, "or" : 8,
                  "slt": 9}

    arith_r_cmds = {"add": 0, "sub": 8, "sll": 1,
                    "slt": 2, "sltu": 3, "xor" : 4,
                    "srl": 5, "sra": 13, "or": 6 , "and": 7}

    arith_i_cmds = {"addi": 0,  "slti": 2, "sltiu": 3, 
                    "xori": 4, "ori": 6 , "andi": 7}
                    
    arith_i_shift_cmds = {"slli": 1, "srli": 5, "srai": 13}
    
    load_cmds =    {"lb": 0, "lh": 1, "lw": 2, "lbu": 4, "lhu": 5}
    store_cmds =   {"sb": 0, "sh": 1, "sw": 2}
    branch_cmds =  {"beq": 0, "bne": 1, "blt": 4, "bge": 5, "bltu":6, "bgeu": 7}
        
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
            if   cmd in load_cmds:
                imm = int_to_twos_complement(value, 12)
                imm_11_0 = get_bits(imm, 0,  11)
                dw = load_cmds[cmd]
                code = f"   {imm_11_0:012b}_{regB:05b}_{dw:03b}_{regA:05b}_00000_11"
            elif cmd in store_cmds:
                imm = int_to_twos_complement(value, 12)
                imm_11_5 = get_bits(imm, 5,  11)
                imm_4_0  = get_bits(imm, 0,  4)
                dw = store_cmds[cmd]
                code = f"  {imm_11_5:07b}_{regA:05b}_{regB:05b}_{dw:03b}_{imm_4_0:05b}_01000_11"
            elif cmd in arith_r_cmds:
                val = arith_r_cmds[cmd]
                func7 = (val >> 3) & 1
                func3 = val & 7
                code = f"  0{func7:01b}00000_{regC:05b}_{regB:05b}_{func3:03b}_{regA:05b}_01100_11"
            elif cmd in arith_i_cmds:
                imm = int_to_twos_complement(value, 12)
                imm_11_0 = get_bits(imm, 0,  11) 
                val = arith_i_cmds[cmd]
                func7 = (val >> 3) & 1
                func3 = val & 7
                code = f"   {imm_11_0:012b}_{regB:05b}_{func3:03b}_{regA:05b}_00100_11"
            elif cmd in arith_i_shift_cmds:
                imm = int_to_twos_complement(value, 5)
                imm_0_4 = get_bits(imm, 0,  4) 
                val = arith_i_shift_cmds[cmd]
                func7 = (val >> 3) & 1
                func3 = val & 7
                code = f"  0{func7:01b}00000_{imm_0_4:05b}_{regB:05b}_{func3:03b}_{regA:05b}_00100_11"               
            elif cmd in branch_cmds:
                #         imm[12]    imm[10:5]      imm[4:1]   imm[11]            per spec
                # get 13 bit twos complement as we drop the final bit
                imm = int_to_twos_complement(value, 13)
                imm_12   = get_bits(imm, 12, 12)
                imm_10_5 = get_bits(imm, 5,  10)
                imm_4_1  = get_bits(imm, 1,  4)
                imm_11   = get_bits(imm, 11, 11)
                func3 = branch_cmds[cmd]
                code = f"{imm_12:01b}_{imm_10_5:06b}_{regB:05b}_{regA:05b}_{func3:03b}_{imm_4_1:04b}_{imm_11:01b}_11000_11"
            elif cmd == "jal":
                #         imm[20]    imm[10:1]      imm[11]    imm[19:12]         per spec
                # get 21 bit twos complement as we drop the final bit
                imm = int_to_twos_complement(value, 21)
                imm_20    = get_bits(imm, 20, 20)
                imm_10_1  = get_bits(imm, 1,  10)
                imm_11    = get_bits(imm, 11, 11)
                imm_19_12 = get_bits(imm, 12, 19)
                code = f"  {imm_20:01b}_{imm_10_1:010b}_{imm_11:01b}_{imm_19_12:08b}_{regA:05b}_11011_11"                
            elif cmd == "jalr":
                imm = int_to_twos_complement(value, 12)
                imm_11_0 = get_bits(imm, 0,  11)
                code = f"   {imm_11_0:012b}_{regB:05b}_000_{regA:05b}_11001_11"
            elif cmd == "auipc":
                imm = int_to_twos_complement(value, 20)
                imm_19_0 = get_bits(imm, 0,  19)
                code = f"     {imm_19_0:020b}_{regA:05b}_00101_11"
            elif cmd == "lui":
                imm = int_to_twos_complement(value, 20)
                imm_19_0 = get_bits(value, 0,  19)
                code = f"     {imm_19_0:020b}_{regA:05b}_01101_11"
                
            # OLD BITS START HERE 
            elif   cmd == "ld":
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
            elif cmd in old_arith_cmds:		
                code = f" 000000_0_{regC:05b}_{regB:05b}_000_{regA:05b}_0{old_arith_cmds[cmd]:04b}00"
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
    filename = "risc_test.rscin"
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
