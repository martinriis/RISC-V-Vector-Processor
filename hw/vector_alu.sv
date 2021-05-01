//////////////////////////////////
// Vector Arithmetic Logic Unit //
/////// Martin Riis, 2020 ////////
//////////////////////////////////

import vector_processor_pkg::*;
import riscv_pkg::*;

module vector_alu (
    input logic clk_i,
    input logic rst_i,
    
    input vector_t vs1_i,
    input vector_t vs2_i,
    input logic[XLEN-1:0] rs1_i,
    input vector_t v0_i, // Mask and carry in register
    output vector_t vd_o,
    input sew_t sew_i,
    
    input logic signed_i, // 0 = unsigned, 1 = signed
    input logic use_mask_i, // 0 = don't mask, 1 = use mask
    input logic use_carry_i, // 0 = don't use carry/borrow, 1 = use carry/borrow
    input logic produce_carry_i, // Produce carry/borrow out in mask register format
    input logic saturate_i, // 0 = overflow, 1 = saturate + set VXSAT bit
    
    input valu_opcodes valu_op_i
);

// Internal VS1 and VS2 signals
vector_t vs1;
vector_t vs2;

// VECTOR MASKING OPERATION //
/*
* If the mask input is '1', the input vectors are masked, else,
* no mask is applied. 
* The mask source is vector v0 (input v0_i) which is shared
* with the carry input. Therefore, a mask and carry cannot be
* used together.
*/
always_comb begin
    if (use_mask_i) begin
        case (sew_i)
            SEW8 : begin // 8-bit input
                for (int i = 0; i < 32; i++) begin
                    vs1.i8[i] <= vs1_i.i8[i] & ~{8{v0_i.i8[i]}};
                    vs2.i8[i] <= vs2_i.i8[i] & ~{8{v0_i.i8[i]}};
                end
            end
            SEW16 : begin // 16-bit input
                for (int i = 0; i < 16; i++) begin
                    vs1.i16[i] <= vs1_i.i16[i] & ~{16{v0_i.i16[i]}};
                    vs2.i16[i] <= vs2_i.i16[i] & ~{16{v0_i.i16[i]}};
                end
            end
            SEW32 : begin // 32-bit input
                for (int i = 0; i < 8; i++) begin
                    vs1.i32[i] <= vs1_i.i32[i] & ~{32{v0_i.i32[i]}};
                    vs2.i32[i] <= vs2_i.i32[i] & ~{32{v0_i.i32[i]}};
                end
            end
            SEW64 : begin // 64-bit input
                for (int i = 0; i < 4; i++) begin
                    vs1.i64[i] <= vs1_i.i64[i] & ~{64{v0_i.i64[i]}};
                    vs2.i64[i] <= vs2_i.i64[i] & ~{64{v0_i.i64[i]}};
                end
            end
        endcase
    end
    else begin
        vs1 <= vs1_i;
        vs2 <= vs1_i;
    end
end

// Internal carry signals
logic[31:0] carry_out;
logic[31:0] carry_in;
// Set external carry in
/*
External carry input uses the mask register (v0).
use_carry_i == 1 : carry input is used and sourced from mask register
use_carry_i == 0 : carry input is not used, carry_in = 0
*/
assign carry_in = use_carry_i ? v0_i.i32[0] : 32'b0;

addsub_256bit addsub_256bit_inst (
    .vaddsub_en_i (addsub_en_int),
    .a_i (vs1_int),
    .b_i (vs2_int),
    .sew_i (sew_i),
    .carry_ext_i (carry_ext_int),
    .op_i (addsub_op_i),
    .out_o (vd_o),
    .cout_o (carry_out_int)
);

logic_256bit logic_256bit_inst (
    .logic_en_i (logic_en_int),
    .a_i (vs1_int),
    .b_i (vs2_int),
    .sew_i (sew_i),
    .opcode_i (dc_alu_opcode_i),
    .out_o (vd_o)
);

endmodule
