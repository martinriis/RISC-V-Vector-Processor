package vector_processor_pkg;

parameter XLEN = 32;
parameter VLEN = 256;

// Control and Status Registers
typedef enum logic [11:0] {
    CSR_VSTART      = 12'h008,
    CSR_VXSAT       = 12'h009,
    CSR_VXRM        = 12'h00A,
    CSR_VCSR        = 12'h00F,
    CSR_VL          = 12'hC20,
    CSR_VTYPE       = 12'hC21,
    CSR_VLENB       = 12'hC22
} csr_regs;

// OPCODEs
typedef enum logic [6:0] {
    OPCODE_LOAD_FP  = 7'h07, // Floating point load
    OPCODE_STORE_FP = 7'h27, // Floating point store
    OPCODE_AMO      = 7'h2F, // Atomic memory operation
    OPCODE_OP_V     = 7'h57  // Vector arithmatic
} opcodes;

// Memory Addressing Mode
typedef enum logic [2:0] {
    MOP_ZEU = 3'h0, // Zero extended unit stride
    MOP_ZES = 3'h2, // Zero extended strided
    MOP_ZEI = 3'h3, // Zero extended indexed
    MOP_SEU = 3'h4, // Sign extended unit stride
    MOP_SES = 3'h6, // Sign extended strided
    MOP_SEI = 3'h7  // Sign extended indexed          
} mops;

// LSU Widths
typedef enum logic [2:0] {
    S16     = 3'h1, // Scalar FP 16-bit
    S32     = 3'h2, // Scalar FP 32-bit
    S64     = 3'h3, // Scalar FP 64-bit
    S128    = 3'h4, // Scalar FP 128-bit
    VB      = 3'h0, // Vector byte
    VH      = 3'h5, // Vector halfword
    VW      = 3'h6, // Vector word
    VE      = 3'h7  // Vector element  
} lsu_widths;

// Vector ALU OPCODEs
typedef enum logic[5:0] {
    // LOGIC
    ALU_VAND,
    ALU_VNAND,
    ALU_VANDNOT,
    ALU_VOR,
    ALU_VNOR,
    ALU_VXOR,
    ALU_VXNOR,
    ALU_VNOT,
    // SHIFT
    ALU_VSLL,
    ALU_VSRL,
    ALU_VSRA,
    // ARITHMETIC
    ALU_VADD,
    ALU_VSUB,
    ALU_VMIN,
    ALU_VMAX,
    ALU_VADC,
    ALU_VSBC,
    // OTHER
    ALU_RGATHER
} alu_opcodes;

// Vector Compare OPCODEs
typedef enum logic[3:0] {
    COMP_EQ,
    COMP_NEQ,
    COMP_LT,
    COMP_LTU,
    COMP_LE,
    COMP_LEU,
    COMP_GT,
    COMP_GTU,
    COMP_MIN,
    COMP_MINU,
    COMP_MAX,
    COMP_MAXU
} comp_opcodes;

endpackage
