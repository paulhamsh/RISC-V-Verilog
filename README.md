My implementation of RISC V ISA in Verilog


<p align="center">
  <img src="https://github.com/paulhamsh/RISC-V-Verilog/blob/main/RISC-V.jpg" width="800">
</p>

**Control unit signals**  

| instruction    | opcode | alu_a_src | alu_b_src | alu_op | imm_type | rd_src | reg_write_en | data_read_en | data_write_en | data_size | branch cond |
|----------------|--------|-----------|-----------|--------|----------|--------|--------------|--------------|---------------|-----------|-------------|
| arithmetic reg | 011_0011 | 0 | 0 | see table | 0 | 00 | 1 | 0 | 0 | 000 | 010 |


