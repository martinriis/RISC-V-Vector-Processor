import vector_processor_pkg::*;

// *** 8-BIT ADDER/SUBTRACTOR WITH CARRY IN AND OUT *** //
module addsub_8bit (
    input wire addsub8_en_i, // Active HIGH enable
    input wire [7:0] a_i, b_i,
    input wire cin_i, // Carry in
    input wire op_i, // Operation, 0 = subtract, 1 = add
    output reg [7:0] out_o,
    output reg cout_o // Carry out
);

reg [8:0] full_out; // 9-bit output

assign out_o = addsub8_en_i ? full_out[7:0] : 8'b0;
assign cout_o = addsub8_en_i ? full_out[8] : 1'b0;

always_comb begin
    if (addsub8_en_i) begin
        if (op_i) // Add
            full_out <= a_i + b_i + cin_i;
        else // Subtract
            full_out <= a_i - b_i - cin_i;
    end
end
endmodule


// *** 256-BIT VECTOR ADDER WITH VECTOR CARRY IN AND OUT *** //
// Supports:
//  - 1x 256-bit word
//  - 2x 128-bit words
//  - 4x 64-bit words
//  - 8x 32-bit words
//  - 16x 16-bit words
//  - 32x 8-bit words

// Word length selected by sew_i input
module addsub_256bit (
    input wire vaddsub_en_i, // Active HIGH enable
    input wire [255:0] a_i, b_i,
    input wire [2:0] sew_i,
    input wire [31:0] carry_ext_i, // External carry in
    input wire op_i, // Operation, 0 = subtract, 1 = add
    output reg [255:0] out_o,
    output reg [31:0] cout_o // Carry out
);

reg [32:0] carry_int; // Internal carry 

// Mask internal carry values depending on the current SEW
always_comb begin
    case (sew_i)
        3'b000  : carry_int <= 32'h0 & cout_o; // 8-bit words
        3'b001  : carry_int <= 32'h55555555 & cout_o; // 16-bit words
        3'b010  : carry_int <= 32'h77777777 & cout_o; // 32-bit words
        3'b011  : carry_int <= 32'h7f7f7f7f & cout_o; // 64-bit words
        3'b100  : carry_int <= 32'h7fff7fff & cout_o; // 128-bit words
        3'b101  : carry_int <= 32'h7fffffff & cout_o; // 256-bit words
    endcase
end

// Generate 32 8-bit addsubs (256-bits total)
genvar i;
for (i = 0; i < 32; i = i + 1) begin
    addsub_8bit addsub_8bit_inst (
        .addsub8_en_i (vaddsub_en_i),
        .a_i (a_i[8*(i+1)-1:8*(i+1)-8]),
        .b_i (b_i[8*(i+1)-1:8*(i+1)-8]),
        .out_o (out_o[8*(i+1)-1:8*(i+1)-8]),
        .op_i (op_i),
        .cin_i (carry_int[i] | carry_ext_i[i]),
        .cout_o (cout_o[i+1])
    );
end
endmodule
