import vector_processor_pkg::*;

// *** 256-BIT LOGIC UNIT *** //
module logic_256bit (
    input wire [255:0] a_i, b_i,
    input wire [2:0] sew_i,
    input vector_processor_pkg::alu_opcodes opcode_i,
    output reg [255:0] out_o
);

reg [255:0] result_logic;

// LOGIC OPERATIONS //
always_comb begin
    result_logic = '0;
    case (opcode_i)
        ALU_VAND    : result_logic <= a_i & b_i;
        ALU_VNAND   : result_logic <= ~(a_i & b_i);
        ALU_VANDNOT : result_logic <= a_i & ~b_i;
        ALU_VOR     : result_logic <= a_i | b_i;
        ALU_VNOR    : result_logic <= ~(a_i | b_i);
        ALU_VXOR    : result_logic <= a_i ^ b_i;
        ALU_VXNOR   : result_logic <= ~(a_i ^ b_i);
        ALU_VNOT    : result_logic <= ~a_i;
    endcase
end

// SHIFT OPERATIONS //
// Can likely be optimised to use fewer resources
wire [255:0] result_shift_8bit, 
             result_shift_16bit,
             result_shift_32bit,
             result_shift_64bit,
             result_shift_128bit,
             result_shift_256bit;
reg [255:0]  result_shift;

// Instantiates 32 8-bit shiftere        
genvar i8;
for (i8 = 0; i8 < 255; i8 = i8 + 8) begin
    shifter # (.width (8)) shift_8bit (
        .a_i (a_i[i8+7:i8]),
        .b_i (b_i[i8+7:i8]),
        .opcode_i (opcode_i),
        .out_o (result_shift_8bit[i8+7:i8])
    );
end

// Instantiates 16 16-bit shiftere 
genvar i16;
for (i16 = 0; i16 < 255; i16 = i16 + 16) begin
    shifter # (.width (16)) shift_16bit (
        .a_i (a_i[i16+15:i16]),
        .b_i (b_i[i16+15:i16]),
        .opcode_i (opcode_i),
        .out_o (result_shift_16bit[i16+15:i16])
    );
end

// Instantiates 8 32-bit shiftere 
genvar i32;
for (i32 = 0; i32 < 255; i32 = i32 + 32) begin
    shifter # (.width (32)) shift_32bit (
        .a_i (a_i[i32+31:i32]),
        .b_i (b_i[i32+31:i32]),
        .opcode_i (opcode_i),
        .out_o (result_shift_32bit[i32+31:i32])
    );
end

// Instantiates 4 64-bit shiftere 
genvar i64;
for (i64 = 0; i64 < 255; i64 = i64 + 64) begin
    shifter # (.width (64)) shift_64bit (
        .a_i (a_i[i64+63:i64]),
        .b_i (b_i[i64+63:i64]),
        .opcode_i (opcode_i),
        .out_o (result_shift_64bit[i64+63:i64])
    );
end

// Instantiates 2 128-bit shiftere 
genvar i128;
for (i128 = 0; i128 < 255; i128 = i128 + 128) begin
    shifter # (.width (128)) shift_128bit (
        .a_i (a_i[i128+127:i128]),
        .b_i (b_i[i128+127:i128]),
        .opcode_i (opcode_i),
        .out_o (result_shift_128bit[i128+127:i128])
    );
end

// Instantiates 1 256-bit shifter 
genvar i256;
for (i256 = 0; i256 < 255; i256 = i256 + 256) begin
    shifter # (.width (256)) shift_256bit (
        .a_i (a_i[i256+255:i256]),
        .b_i (b_i[i256+255:i256]),
        .opcode_i (opcode_i),
        .out_o (result_shift_256bit[i256+255:i256])
    );
end

// SHIFTER OUTPUT CONTROL // 
// Selects shift output based on SEW
always_comb begin
    case (sew_i)
        3'b000  : result_shift <= result_shift_8bit;
        3'b001  : result_shift <= result_shift_16bit;
        3'b010  : result_shift <= result_shift_32bit;
        3'b011  : result_shift <= result_shift_64bit;
        3'b100  : result_shift <= result_shift_128bit;
        3'b101  : result_shift <= result_shift_256bit;
    endcase
end

// RESULT OUTPUT //
// Selects between logic block result and shifter result based on the opcode
always_comb begin
    out_o = '0;
    case (opcode_i)
        ALU_VAND, ALU_VNAND, ALU_VANDNOT, ALU_VOR,
        ALU_VNOR, ALU_VXOR, ALU_VXNOR, ALU_VNOT : out_o <= result_logic;
        ALU_VSLL, ALU_VSRL, ALU_VSRA : out_o <= result_shift;
    endcase
end
endmodule


// *** N-BIT SHIFTER *** //
// Shifts a_i by b_i bits
module shifter # (
    parameter width = 8
)
(
    input wire [width-1:0] a_i, b_i,
    input vector_processor_pkg::alu_opcodes opcode_i,
    output reg [width-1:0] out_o
);

always_comb begin
    case (opcode_i)
        ALU_VSLL : out_o <= a_i << b_i; // Left logical shift
        ALU_VSRL : out_o <= a_i >> b_i; // Right logical shift
        ALU_VSRA : out_o <= a_i >>> b_i; // Right arithmetic shift (preserves sign)
    endcase
end
endmodule