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

// *** 8-BIT FLIP-FLOP *** //
module flipflop_8bit (
    input wire clk_i,
    input wire [7:0] d_i,
    output reg [7:0] q_o 
);

always_ff @ (posedge clk_i) begin
    q_o <= d_i;
end
endmodule

// *** 8-BIT DELAY BLOCK *** //
// Allows for custom delay using flip-flops
module delay_8bit # (
    parameter delay = 8
)
(
    input wire clk_i,
    input wire [7:0] d_i,
    output wire [7:0] q_o
);

wire [7:0] sig_int[delay];

genvar d;
for (d = 0; d < delay; d++) begin
    // Single delay cycle - single flip-flop
    if (delay == 1) begin
        flipflop_8bit ff8_inst (
            .clk_i (clk_i),
            .d_i (d_i),
            .q_o (q_o)
        );
    end
    // Two cycle delay - two flip-flops
    else if (delay == 2) begin
        if (d == 0) begin
        flipflop_8bit ff8_inst (
            .clk_i (clk_i),
            .d_i (d_i),
            .q_o (sig_int[d])
        );
        end
        else begin
            flipflop_8bit ff8_inst (
                .clk_i (clk_i),
                .d_i (sig_int[d-1]),
                .q_o (q_o)
            );
        end
    end
    // Multi-cycle delay
    else begin
        if (d == 0) begin
            flipflop_8bit ff8_inst (
                .clk_i (clk_i),
                .d_i (d_i),
                .q_o (sig_int[d])
            );
        end
        else if (d == delay - 1) begin
            flipflop_8bit ff8_inst (
                .clk_i (clk_i),
                .d_i (sig_int[d-1]),
                .q_o (q_o)
            );
        end
        else begin
            flipflop_8bit ff8_inst (
                .clk_i (clk_i),
                .d_i (sig_int[d-1]),
                .q_o (sig_int[d])
            );
        end
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
    input wire clk_i,
    input wire vaddsub_en_i, // Active HIGH enable
    input wire [255:0] a_i, b_i,
    input wire [2:0] sew_i,
    input wire [31:0] carry_ext_i, // External carry in
    input wire op_i, // Operation, 0 = subtract, 1 = add
    output reg [255:0] out_o,
    output wire [32:0] cout_o // Carry out
);

reg [32:0] cin_int = 33'b0;
wire [32:0] cout_int;

// Mask internal carry values depending on the current SEW
always_comb begin
    case (sew_i)
        3'b000  : cin_int <= 32'h0 & cout_int; // 8-bit words
        3'b001  : cin_int <= 32'haaaaaaaa & cout_int; // 16-bit words
        3'b010  : cin_int <= 32'heeeeeeee & cout_int; // 32-bit words
        3'b011  : cin_int <= 32'hfefefefe & cout_int; // 64-bit words
        3'b100  : cin_int <= 32'hfffefffe & cout_int; // 128-bit words
        3'b101  : cin_int <= 32'hfffffffe & cout_int; // 256-bit words
    endcase
end

wire [255:0] a_int, b_int;

assign a_int[7:0] = a_i[7:0];
assign b_int[7:0] = b_i[7:0];

genvar p;
for (p = 1; p < 32; p++) begin
    delay_8bit # (
        .delay(p)
    )
    reg_pipeline_a (
        .clk_i (clk_i),
        .d_i (a_i[p*8+7:p*8]),
        .q_o (a_int[p*8+7:p*8])
    );
    
    delay_8bit # (
        .delay(p)
    )
    reg_pipeline_b (
        .clk_i (clk_i),
        .d_i (b_i[p*8+7:p*8]),
        .q_o (b_int[p*8+7:p*8])
    );
end

// Generate 32 8-bit addsubs (256-bits total)
genvar i;
for (i = 0; i < 32; i++) begin
    if (i == 0) begin
        addsub_8bit addsub_8bit_inst (
            .addsub8_en_i (vaddsub_en_i),
            .a_i (a_int[8*(i+1)-1:8*(i+1)-8]),
            .b_i (b_int[8*(i+1)-1:8*(i+1)-8]),
            .out_o (out_o[8*(i+1)-1:8*(i+1)-8]),
            .op_i (op_i),
            .cin_i (carry_ext_i[i]),
            .cout_o (cout_int[i+1])
        );
    end
    else begin
        addsub_8bit addsub_8bit_inst (
            .addsub8_en_i (vaddsub_en_i),
            .a_i (a_int[8*(i+1)-1:8*(i+1)-8]),
            .b_i (b_int[8*(i+1)-1:8*(i+1)-8]),
            .out_o (out_o[8*(i+1)-1:8*(i+1)-8]),
            .op_i (op_i),
            .cin_i (cin_int[i] | carry_ext_i[i]),
            .cout_o (cout_int[i+1])
        );
    end
end
endmodule
