////////////////////////////////////////
////////// RISC-V CPU Package //////////
////////// Martin Riis, 2020 ///////////
////////////////////////////////////////

package riscv_pkg;

typedef union packed {
    logic[255:0] i256;
    logic[1:0][127:0] i128;
    logic[3:0][63:0] i64;
    logic[7:0][31:0] i32;
    logic[15:0][15:0] i16;
    logic[31:0][7:0] i8;
    logic[63:0][3:0] i4;
} vector_t;

typedef enum logic[2:0] {
    SEW8    = 3'b000,
    SEW16   = 3'b001,
    SEW32   = 3'b010,
    SEW64   = 3'b011
    // SEW128 - SEW1024 are reserved as of v1.0
    //SEW128  = 3'b100,
    //SEW256  = 3'b101,
    //SEW512  = 3'b110,
    //SEW1024 = 3'b111
} sew_t;


///////////////////////////////
// Standard Instruction Formats
///////////////////////////////
typedef struct packed {
    logic[6:0] funct7;
    logic[4:0] rs2;
    logic[4:0] rs1;
    logic[2:0] funct3;
    logic[4:0] rd;
    logic[6:0] opcode;
} rtype_t;

typedef struct packed {
    logic[4:0] rs3;
    logic[1:0] fmt;
    logic[4:0] rs2;
    logic[4:0] rs1;
    logic[2:0] rm;
    logic[4:0] rd;
    logic[6:0] opcode;
} r4type_t;

typedef struct packed {
    logic[11:0] imm;
    logic[4:0] rs1;
    logic[2:0] funct3;
    logic[4:0] rd;
    logic[6:0] opcode;
} itype_t;

typedef struct packed {
    logic[6:0] imm1;
    logic[4:0] rs2;
    logic[4:0] rs1;
    logic[2:0] funct3;
    logic[4:0] imm0;
    logic[6:0] opcode;
} stype_t;

typedef struct packed {
    logic imm3;
    logic[5:0] imm1;
    logic[4:0] rs2;
    logic[4:0] rs1;
    logic[2:0] funct3;
    logic[3:0] imm0;
    logic imm2;
    logic[6:0] opcode;
} btype_t;

typedef struct packed {
    logic[19:0] imm;
    logic[4:0] rd;
    logic[6:0] opcode;
} utype_t;

typedef struct packed {
    logic imm3;
    logic[9:0] imm0;
    logic imm1;
    logic[7:0] imm2;
    logic[4:0] rd;
    logic[6:0] opcode;
} jtype_t;

typedef struct packed {
    logic[4:0] funct5;
    logic aq;
    logic rl;
    logic[4:0] rs2;
    logic[4:0] rs1;
    logic[2:0] funct3;
    logic[4:0] rd;
    logic[6:0] opcode;
} atype_t; // For AMO

typedef enum logic[6:0] {
    OPCODE_AMO        = 7'b0101111,
    OPCODE_C0         = 7'bXXXXX00,
    OPCODE_C1         = 7'bXXXXX01,
    OPCODE_C2         = 7'bXXXXX10,
    OPCODE_LD_FP      = 7'b0000111,
    OPCODE_ST_FP      = 7'b0100111,
    OPCODE_OP_FP      = 7'b0111011,
    OPCODE_FMADD      = 7'b1000011,
    OPCODE_FMSUB      = 7'b1000111,
    OPCODE_FNMSUB     = 7'b1001011,
    OPCODE_FNMADD     = 7'b1001111,
    OPCODE_OP_IMM     = 7'b0010011,
    OPCODE_LUI        = 7'b0110111,
    OPCODE_AUIPC      = 7'b0010111,
    OPCODE_OP         = 7'b0110011,
    OPCODE_JAL        = 7'b1101111,
    OPCODE_JALR       = 7'b1100111,
    OPCODE_BRANCH     = 7'b1100011,
    OPCODE_LOAD       = 7'b0000011,
    OPCODE_STORE      = 7'b0100011,
    OPCODE_MISC_MEM   = 7'b0001111,
    OPCODE_OPV        = 7'b1010111
} rv_opcodes;

typedef enum logic[2:0] {
    OPIVV   = 3'b000,
    OPFVV   = 3'b001,
    OPMVV   = 3'b010,
    OPIVI   = 3'b011,
    OPIVX   = 3'b100,
    OPFVF   = 3'b101,
    OPMVX   = 3'b110,
    OPCFG   = 3'b111
} vfunct3_t;

typedef enum logic[5:0] {
    VALU_NOP = 6'b000000,
    VALU_ADDU,
    VALU_ADDS,
    VALU_SUBU,
    VALU_SUBS,
    VALU_RSUB, // Should be more efficient than larger input muxes
    VALU_MINS,
    VALU_MINU,
    VALU_MAXS,
    VALU_MAXU,
    VALU_EQ,
    VALU_NE,
    VALU_LTU,
    VALU_LTS,
    VALU_LEU,
    VALU_LES,
    VALU_GTU,
    VALU_GTS,
    VALU_AND,
    VALU_OR,
    VALU_XOR,
    VALU_SLL,
    VALU_SRL,
    VALU_SRA,    
    VALU_ADC,
    VALU_SBC,
    VALU_AADDS,
    VALU_AADDU,
    VALU_ASUBS,
    VALU_ASUBU,
    VALU_ZEX2,
    VALU_ZEX4,
    VALU_ZEX8,
    VALU_SEX2,
    VALU_SEX4,
    VALU_SEX8
} valu_opcodes;

typedef enum logic[4:0] {
    VMD_NOP = 5'b00000,
    VMD_MULUU,
    VMD_MULUS,
    VMD_MULSS,
    VMD_DIVU,
    VMD_DIVS,
    VMD_REMU,
    VMD_REMS
} vmuldiv_opcodes;

typedef enum logic[5:0] {
    VFPU_NOP = 6'b000000,
    VFPU_ADD,
    VFPU_SUB,
    VFPU_MIN,
    VFPU_MAX,
    VFPU_SQRT,
    VFPU_SQRT_EST,
    VFPU_REC_EST,
    VFPU_EQ,
    VFPU_LE,
    VFPU_LT,
    VFPU_NE,
    VFPU_GT,
    VFPU_GE,
    VFPU_DIV,
    VFPU_RDIV,
    VFPU_MUL,
    VFPU_RSUB,
    VFPU_SGNJ,
    VFPU_SGNJN,
    VFPU_SGNJX,
    VFPU_F2U,
    VFPU_F2S,
    VFPU_U2F,
    VFPU_S2F,
    VFPU_F2D,
    VFPU_D2F,
    VFPU_CLASS
} vfpu_opcodes;

typedef enum logic[1:0] {
    CVT_NONE,
    CVT_WIDE,
    CVT_NARROW
} width_cvt_t;

typedef enum logic[2:0] {
    FPU_RNE  = 3'b000,
    FPU_RTZ  = 3'b001,
    FPU_RDN  = 3'b010,
    FPU_RUP  = 3'b011,
    FPU_RMM  = 3'b100,
    FPU_REV  = 3'b101, // Not part of standard F/D extensions, only used for vfpu
    FPU_ROD  = 3'b110, // Not part of standard F/D extensions, only used for vfpu
    FPU_INST = 3'b111
} fpu_round_t;

typedef struct packed {
    logic valid;
    logic[20:0] tag;
    logic [31:0] data;
} cache_struct;

typedef struct packed {
    logic[20:0] tag;
    logic[10:0] index;
} addr_struct;

endpackage
