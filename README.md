My implementation of RISC V ISA in Verilog


<p align="center">
  <img src="https://github.com/paulhamsh/RISC-V-Verilog/blob/main/RISC-V.jpg" width="800">
</p>

**Control unit signals**  

# 
| instruction    | opcode   | alu_a_src | alu_b_src | alu_op    | imm_type | rd_src | reg_write_en | data_read_en | data_write_en | data_size | branch cond |
|----------------|----------|-----------|-----------|-----------|----------|--------|--------------|--------------|---------------|-----------|-------------|
| arithmetic reg | 011_0011 | 0         | 0         | see table | 0        | 00     | 1            | 0            | 0             | 000       | 010         |
| arithmetic imm | 001_0011 | 0         | 1         | see table | 1        | 00     | 1            | 0            | 0             | 000       | 010         |
| load           | 000_0011 | 0         | 1         | 0000      | 1        | 01     | 1            | 1            | 0             | see table | 010         |
| store          | 010_0011 | 0         | 1         | 0000      | 2        | 00     | 0            | 0            | 1             | see table | 010         |
| branch         | 110_0011 | 1         | 1         | 0000      | 3        | 00     | 0            | 0            | 0             | 000       | see table   |
| jal            | 110_1111 | 1         | 1         | 0000      | 4        | 00     | 0            | 0            | 0             | 000       | 011         |
| jalr           | 110_0111 | 0         | 1         | 0000      | 1        | 10     | 1            | 0            | 0             | 000       | 011         |
| lui            | 011_0111 | 0         | 1         | 0000      | 5        | 00     | 1            | 0            | 0             | 000       | 010         |
| auipc          | 001_0111 | 1         | 1         | 0000      | 5        | 00     | 1            | 0            | 0             | 000       | 010         |



