// Forces use of Xilinx DSP48 blocks for MAC operation
(* use_dsp48 = "true" *)

// 16-bit multiply-accumulate unit
module mult_16bit (
    input wire [15:0] a_i, b_i, c_i,
    output reg [31:0] fout_o, // Full 16-bit output
    output reg [15:0] out_o // Truncated 8-bit output
);

assign fout_o = a_i * b_i + c_i;
assign out_o = fout_o[15:0];

endmodule

// 256-BIT VECTOR MULTIPLIER
// Supports:
//  - 4x 64-bit words
//  - 8x 32-bit words
//  - 16x 16-bit words
//  - 32x 8-bit words

// Word length selected by sew_i input
module mult_256bit (
    input wire [255:0] a_i, b_i,
    input wire [2:0] sew_i,
    output reg [255:0] out_o
);

genvar i;
for (i = 0; i < 4; i++) begin
    mult_64bit mult_64bit_inst (
        .a_i (a_i[i*64+63:i*64]),
        .b_i (b_i[i*64+63:i*64]),
        .sew_i (sew_i),
        .out_o (out_o[i*64+63:i*64])
    );
end
endmodule


// 64-bit multiplier from 16-bit multipliers
module mult_64bit (
    input wire [63:0] a_i, b_i,
    input wire [7:0] sew_i,
    output reg [63:0] out_o
);

reg [15:0] a_int[10], b_int[10];
reg [15:0] out_int[10];
reg [31:0] fout_int [18];

always_comb begin
    case (sew_i)
        3'b000 : begin // 8-bit words
            a_int[0] <= {8'b0, a_i[7:0]};
            b_int[0] <= {8'b0, b_i[7:0]};
            
            a_int[1] <= {8'b0, a_i[15:8]};
            b_int[1] <= {8'b0, b_i[15:8]};
            
            a_int[2] <= {8'b0, a_i[23:16]};
            b_int[2] <= {8'b0, b_i[23:16]};
            
            a_int[3] <= {8'b0, a_i[31:24]};
            b_int[3] <= {8'b0, b_i[31:24]};
            
            a_int[4] <= {8'b0, a_i[39:32]};
            b_int[4] <= {8'b0, b_i[39:32]};
            
            a_int[5] <= {8'b0, a_i[47:40]};
            b_int[5] <= {8'b0, b_i[47:40]};
            
            a_int[6] <= {8'b0, a_i[55:48]};
            b_int[6] <= {8'b0, b_i[55:48]};
            
            a_int[7] <= {8'b0, a_i[63:56]};
            b_int[7] <= {8'b0, b_i[63:56]};
            
            a_int[8] <= 16'b0;
            b_int[8] <= 16'b0;
            a_int[9] <= 16'b0;
            b_int[9] <= 16'b0;
            
            // Outputs
            out_o[7:0] <= out_int[0];
            out_o[15:8] <= out_int[1];
            out_o[23:16] <= out_int[2];
            out_o[31:24] <= out_int[3];
            out_o[39:32] <= out_int[4];
            out_o[47:40] <= out_int[5];
            out_o[55:48] <= out_int[6];
            out_o[63:56] <= out_int[7];
            
            // Intermediate full output
            fout_int[1] <= 32'b0; // Stage 0-1
            fout_int[3] <= 32'b0; // Stage 1-2
            fout_int[5] <= 32'b0; // Stage 2-3
            fout_int[7] <= 32'b0; // Stage 3-4
            fout_int[9] <= 32'b0; // Stage 4-5
            fout_int[11] <= 32'b0; // Stage 5-6
            fout_int[13] <= 32'b0; // Stages 6-7
            fout_int[15] <= 32'b0; // Stage 7-8
            fout_int[17] <= 32'b0; // Stage 8-9
        end
        3'b001 : begin // 16-bit words
            a_int[0] <= a_i[15:0];
            b_int[0] <= b_i[15:0];
            
            a_int[1] <= a_i[31:16];
            b_int[1] <= b_i[31:16];
            
            a_int[2] <= a_i[47:32];
            b_int[2] <= b_i[47:32];
            
            a_int[3] <= a_i[63:48];
            b_int[3] <= b_i[63:48];
            
            a_int[4] <= 16'b0;
            b_int[4] <= 16'b0;
            a_int[5] <= 16'b0;
            b_int[5] <= 16'b0;
            a_int[6] <= 16'b0;
            b_int[6] <= 16'b0;
            a_int[7] <= 16'b0;
            b_int[7] <= 16'b0;
            a_int[8] <= 16'b0;
            b_int[8] <= 16'b0;
            a_int[9] <= 16'b0;
            b_int[9] <= 16'b0;
            
            // Outputs
            out_o[15:0] <= out_int[0];
            out_o[31:16] <= out_int[1];
            out_o[47:32] <= out_int[2];
            out_o[63:48] <= out_int[3];
            
            // Intermediate full output
            fout_int[1] <= 32'b0; // Stage 0-1
            fout_int[3] <= 32'b0; // Stage 1-2
            fout_int[5] <= 32'b0; // Stage 2-3
            fout_int[7] <= 32'b0; // Stage 3-4
            fout_int[9] <= 32'b0; // Stage 4-5
            fout_int[11] <= 32'b0; // Stage 5-6
            fout_int[13] <= 32'b0; // Stage 6-7
            fout_int[15] <= 32'b0; // Stage 7-8
            fout_int[17] <= 32'b0; // Stage 8-9
        end
        3'b010 : begin // 32-bit words
            a_int[0] <= a_i[15:0];
            b_int[0] <= b_i[15:0];
            
            a_int[1] <= a_i[15:0];
            b_int[1] <= b_i[31:16];
            a_int[2] <= a_i[31:16];
            b_int[2] <= b_i[15:0];
            
            a_int[3] <= a_i[47:32];
            b_int[3] <= b_i[47:32];
            
            a_int[4] <= a_i[47:32];
            b_int[4] <= b_i[63:48];
            a_int[5] <= a_i[63:48];
            b_int[5] <= b_i[47:32];
            
            a_int[6] <= 16'b0;
            b_int[6] <= 16'b0;
            a_int[7] <= 16'b0;
            b_int[7] <= 16'b0;
            a_int[8] <= 16'b0;
            b_int[8] <= 16'b0;
            a_int[9] <= 16'b0;
            b_int[9] <= 16'b0;
            
            // Outputs
            out_o[15:0] <= out_int[0];
            out_o[31:16] <= out_int[2];
            out_o[47:32] <= out_int[3];
            out_o[63:48] <= out_int[5];
            
            // Intermediate full output
            fout_int[1] <= fout_int[0] >> 16; // Stage 0-1
            fout_int[3] <= fout_int[2]; // Stage 1-2
            fout_int[5] <= 32'b0; // Stage 2-3
            fout_int[7] <= fout_int[6] >> 16; // Stage 3-4
            fout_int[9] <= fout_int[8]; // Stage 4-5
            fout_int[11] <= 32'b0; // Stage 5-6
            fout_int[13] <= 32'b0; // Stages 6-7
            fout_int[15] <= 32'b0; // Stage 7-8
            fout_int[17] <= 32'b0; // Stage 8-9
        end
        3'b011 : begin // 64-bit words
            a_int[0] <= a_i[15:0];
            b_int[0] <= b_i[15:0];
            
            a_int[1] <= a_i[15:0];
            b_int[1] <= b_i[31:16];
            a_int[2] <= a_i[31:16];
            b_int[2] <= b_i[15:0];
            
            a_int[3] <= a_i[15:0];
            b_int[3] <= b_i[47:32];
            a_int[4] <= a_i[31:16];
            b_int[4] <= b_i[31:16];
            a_int[5] <= a_i[47:32];
            b_int[5] <= b_i[15:0];
            
            a_int[6] <= a_i[15:0];
            b_int[6] <= b_i[63:48];
            a_int[7] <= a_i[31:16];
            b_int[7] <= b_i[47:32];
            a_int[8] <= a_i[47:32];
            b_int[8] <= b_i[31:16];
            a_int[9] <= a_i[63:48];
            b_int[9] <= b_i[15:0];
            
            // Outputs
            out_o[15:0] <= out_int[0];
            out_o[31:16] <= out_int[2];
            out_o[47:32] <= out_int[5];
            out_o[63:48] <= out_int[9];
            
            // Intermediate full output
            fout_int[1] <= fout_int[0] >> 16; // Stage 0-1
            fout_int[3] <= fout_int[2]; // Stage 1-2
            fout_int[5] <= fout_int[4] >> 16; // Stage 2-3
            fout_int[7] <= fout_int[6]; // Stage 3-4
            fout_int[9] <= fout_int[8]; // Stage 4-5
            fout_int[11] <= fout_int[10] >> 16; // Stage 5-6
            fout_int[13] <= fout_int[12]; // Stages 6-7
            fout_int[15] <= fout_int[14]; // Stage 7-8
            fout_int[17] <= fout_int[16]; // Stage 8-9
        end
    endcase
end

// INSTANTATES TEN 16-BIT MULTIPLIERS //
// 15:0
mult_16bit mult16_0 (
    .a_i (a_int[0]),
    .b_i (b_int[0]),
    .c_i (0),
    .fout_o (fout_int[0]),
    .out_o (out_int[0])
);

// 31:16
mult_16bit mult16_1 (
    .a_i (a_int[1]),
    .b_i (b_int[1]),
    .c_i (fout_int[1]),
    .fout_o (fout_int[2]),
    .out_o (out_int[1])
);

mult_16bit mult16_2 (
    .a_i (a_int[2]),
    .b_i (b_int[2]),
    .c_i (fout_int[3]),
    .fout_o (fout_int[4]),
    .out_o (out_int[2])
);

// 47:32
mult_16bit mult16_3 (
    .a_i (a_int[3]),
    .b_i (b_int[3]),
    .c_i (fout_int[5]),
    .fout_o (fout_int[6]),
    .out_o (out_int[3])
);

mult_16bit mult16_4 (
    .a_i (a_int[4]),
    .b_i (b_int[4]),
    .c_i (fout_int[7]),
    .fout_o (fout_int[8]),
    .out_o (out_int[4])
);

mult_16bit mult16_5 (
    .a_i (a_int[5]),
    .b_i (b_int[5]),
    .c_i (fout_int[9]),
    .fout_o (fout_int[10]),
    .out_o (out_int[5])
);

// 63:48
mult_16bit mult16_6 (
    .a_i (a_int[6]),
    .b_i (b_int[6]),
    .c_i (fout_int[11]),
    .fout_o (fout_int[12]),
    .out_o (out_int[6])
);

mult_16bit mult16_7 (
    .a_i (a_int[7]),
    .b_i (b_int[7]),
    .c_i (fout_int[13]),
    .fout_o (fout_int[14]),
    .out_o (out_int[7])
);

mult_16bit mult16_8 (
    .a_i (a_int[8]),
    .b_i (b_int[8]),
    .c_i (fout_int[15]),
    .fout_o (fout_int[16]),
    .out_o (out_int[8])
);

mult_16bit mult16_9 (
    .a_i (a_int[9]),
    .b_i (b_int[9]),
    .c_i (fout_int[17]),
    .fout_o (),
    .out_o (out_int[9])
);

endmodule