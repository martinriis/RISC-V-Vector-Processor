import vector_processor_pkg::*;
`include "vector_addsub.sv"
`include "vector_logic.sv"

module vector_alu (
    input wire clk_i,
    input wire rst_i,
    
    input wire [255:0] vs1_i,
    input wire [255:0] vs2_i,
    input wire [XLEN-1:0] rs1_i,
    input wire [255:0] v0_i, // Mask and carry in register
    output reg [255:0] vd_o,
    input wire [2:0] sew_i,
    
    input wire dc_signed_i, // 0 = unsigned, 1 = signed
    input wire dc_use_mask_i, // 0 = use mask, 1 = don't mask
    input wire dc_use_carry_i, // 0 = don't use carry/borrow, 1 = use carry/borrow
    input wire dc_produce_carry_i, // Produce carry/borrow out in mask register format
    input wire dc_saturate_i, // 0 = overflow, 1 = saturate + set VXSAT bit
    
    input wire dc_en_addsub_i, // Active HIGH addsub enable
    
    input vector_processor_pkg::alu_opcodes dc_alu_opcode_i
);

// Internal VS1 and VS2 signals
reg [255:0] vs1_int;
reg [255:0] vs2_int;
// Mask if required
assign vs1_int = dc_use_mask_i ? vs1_i : vs1_i & v0_i[31:0];
assign vs2_int = dc_use_mask_i ? vs2_i : vs2_i & v0_i[31:0];

// Internal VD signals
reg [255:0] vd_int;

// Internal carry signals
reg [31:0] carry_out_int;
reg [31:0] carry_ext_int;
// Set external carry
assign carry_ext_int = dc_use_carry_i ? v0_i[31:0] : 32'b0;

addsub_256bit addsub_256bit_inst (
    .vaddsub_en_i (dc_en_addsub_i),
    .a_i (vs1_int),
    .b_i (vs2_int),
    .sew_i (sew_i),
    .carry_ext_i (carry_ext_int),
    .op_i (addsub_op_i),
    .out_o (vd_int),
    .cout_o (carry_out_int)
);

logic_256bit logic_256bit_inst (
    .a_i (vs1_int),
    .b_i (vs2_int),
    .sew_i (sew_i),
    .opcode_i (dc_alu_opcode_i),
    .out_o (vd_int)
);

endmodule