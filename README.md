# RISC-V-Vector-Processor
256-bit vector processor based on the RISC-V vector (V) extension
Currently, only the execution units are published, however, the registers, fetch and decode units are in development. 
**THIS PROJECT IS IN ACTIVE DEVELOPMENT AND SHOULD NOT BE CONSIDERED BUG FREE**

## 1. Background

## 2. RISC-V Vector Extension Terminology
### 2.1 Standard Element Width (SEW)
The SEW defines the width of each word in the vector. For example, a 256-bit vector could contain 8 32-bit words, in this case, the SEW would be 32 bits. SEW is encoded as a 3-bit value using the following method:
| `sew`/`vsew` | SEW |
|---|---|
| `000` | 8 |
| `001` | 16 |
| `010` | 32 |
| `011` | 64 |
| `100` | 128 |
| `101` | 256 |
| `110` | 512 |
| `111` | 1024 |

Although some execution units can operate on and value of SEW up to 256 (bits), most only support up to 64 (bits).

### 2.2 Vector Length (VLEN)
VLEN describes the total length (usually in bits) of the vectors operated upon by the processor. In this design, VLEN is fixed at 256 bits. In the future, some simple elements, such as the ALU may be extended to support arbitrary vector lengths. 

## 3. Features 
### 3.1 Integer Addition/Subtraction
Addition and subtraction are performed using the `addsub_256bit` module (`addsub.sv`). This can be used on its own or combined with the logic unit as the ALU module, `vector_alu` (`vector_alu.sv`).
| Port | Direction | Width | Description |
|---|---|---|---|
| `vaddsub_en_i` | in | 1 | Active high enable |
| `a_i` | in | 256 | Vector input A |
| `b_i` | in | 256 | Vector input B |
| `sew_i` | in | 3 | Standard element width (8, 16, 32, 64, 128, 256) |
| `carry_ext_i` | in | 32 | External carry/borrow in |
| `op_i` | in | 1 | Operation: 0 = subtract, 1 = add |
| `out_o` | out | 256 | Vector output |
| `cout_o` | out | 32 | Carry/borrow out |

### 3.2 Logic
Logic and shift operations are performed by the `logic_256bit` module (`vector_logic.sv`). This can be used on its own or combined with the addsub unit as the ALU module, `vector_alu` (`vector_alu.sv`).
| Port | Direction | Width | Description |
|---|---|---|---|
| `a_i` | in | 256 | Vector input A |
| `b_i` | in | 256 | Vector input B |
| `sew_i` | in | 3 | Standard element width (8, 16, 32, 64, 128, 256) |
| `opcode_i` | in | 6 | Logic/ALU opcodes |
| `carry_ext_i` | in | 32 | External carry/borrow in |

### 3.3 Integer Multiplication
Integer multiplication is performed by the `mult_256bit` module (`vector_mult.sv`). 
As the design targets Xilinx FPGAs, the `(* use_dsp48 =  "true"  *)` directive is added to force the tool to infer DSP48 blocks to perform the multiplication. This can be removed if targeting for simulation or if a non-Xilinx FPGA is used. 
| Port | Direction | Width | Description |
|---|---|---|---|
| `a_i` | in | 256 | Vector input A |
| `b_i` | in | 256 | Vector input B |
| `sew_i` | in | 3 | Standard element width (8, 16, 32, 64) |
| `out_o` | out | 256 | Vector output |

### 3.4 Shift

### 3.5 Integer Compare
Currently in development

### 3.6 Vector Masking
Vector masking allows certain elements of an input vector to be ignored by a execution unit. Vector register `v0` is used as the vector mask register, each element in a vector is allocated a single bit in the mask register. Element i is masked by bit i in the mask register.
Currently, only the ALU (module `vector_alu`) supports vector masking.

## 4. Processor Opcodes
Please note, these are the opcodes used for specifying the operation of each execution unit and are not identical to the opcodes used by the RISC-V vector extension standard. The decode module (not yet published) is responsible for this conversion. 
### 4.1 ALU
| Binary Code | Opcode | Operation|
|---|---|---|
| `000000` | `ALU_VAND` | `A & B` |
| `000001` | `ALU_VNAND`| `¬(A & B)`  |
| `000010` | `ALU_VANDNOT` | `A & ¬B` |
| `000011` | `ALU_VOR` | `A + B` |
| `000100` | `ALU_VNOR` | `¬(A + B)` |
| `000101` | `ALU_VXOR` | `A ⊕ B`|
| `000110` | `ALU_VXNOR` | `¬(A ⊕ B)` |
| `000111` | `ALU_VNOT` | `¬A` |
| `001000` | `ALU_VSLL` | `A << B` |
| `001001` | `ALU_VSRL`| `A >> B`  |
| `001010` | `ALU_VSRA` | `A >>> B` |
| `001011` | `ALU_VADD` | `A + B` |
| `001100` | `ALU_VSUB` | `A - B` |
| `001101` | `ALU_VMIN` | `min(A, B)`|
| `001110` | `ALU_VMAX` | `max(A, B)` |
| `001111` | `ALU_VADC` | `A + B + Cin` |
| `001110` | `ALU_VSBC` | `A - B - Cin` |
