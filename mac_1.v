module mac_unit (
    input clk,
    input reset,
    input [31:0] img_patch_0,
    input [31:0] img_patch_1,
    input [31:0] img_patch_2,
    input [31:0] img_patch_3,
    input [31:0] img_patch_4,
    input [31:0] img_patch_5,
    input [31:0] img_patch_6,
    input [31:0] img_patch_7,
    input [31:0] img_patch_8,

    input [31:0] weights_0,
    input [31:0] weights_1,
    input [31:0] weights_2,
    input [31:0] weights_3,
    input [31:0] weights_4,
    input [31:0] weights_5,
    input [31:0] weights_6,
    input [31:0] weights_7,
    input [31:0] weights_8,

    input [31:0] bias,
    output [31:0] conv_result
);

    wire [31:0] products[0:8];
    wire [31:0] sum_stage1[0:4];
    wire [31:0] sum_stage2[0:1];
    wire [31:0] sum_stage3[0:1];

    // Multiply stage
    fp_multiply mul0 (.clk(clk), .reset(reset), .A(img_patch_0), .B(weights_0), .Result(products[0]));
    fp_multiply mul1 (.clk(clk), .reset(reset), .A(img_patch_1), .B(weights_1), .Result(products[1]));
    fp_multiply mul2 (.clk(clk), .reset(reset), .A(img_patch_2), .B(weights_2), .Result(products[2]));
    fp_multiply mul3 (.clk(clk), .reset(reset), .A(img_patch_3), .B(weights_3), .Result(products[3]));
    fp_multiply mul4 (.clk(clk), .reset(reset), .A(img_patch_4), .B(weights_4), .Result(products[4]));
    fp_multiply mul5 (.clk(clk), .reset(reset), .A(img_patch_5), .B(weights_5), .Result(products[5]));
    fp_multiply mul6 (.clk(clk), .reset(reset), .A(img_patch_6), .B(weights_6), .Result(products[6]));
    fp_multiply mul7 (.clk(clk), .reset(reset), .A(img_patch_7), .B(weights_7), .Result(products[7]));
    fp_multiply mul8 (.clk(clk), .reset(reset), .A(img_patch_8), .B(weights_8), .Result(products[8]));

    // Add tree
    fp_add add0 (.clk(clk), .reset(reset), .a(products[0]), .b(products[1]), .result(sum_stage1[0]));
    fp_add add1 (.clk(clk), .reset(reset), .a(products[2]), .b(products[3]), .result(sum_stage1[1]));
    fp_add add2 (.clk(clk), .reset(reset), .a(products[4]), .b(products[5]), .result(sum_stage1[2]));
    fp_add add3 (.clk(clk), .reset(reset), .a(products[6]), .b(products[7]), .result(sum_stage1[3]));
    assign sum_stage1[4] = products[8];

    fp_add add4 (.clk(clk), .reset(reset), .a(sum_stage1[0]), .b(sum_stage1[1]), .result(sum_stage2[0]));
    fp_add add5 (.clk(clk), .reset(reset), .a(sum_stage1[2]), .b(sum_stage1[3]), .result(sum_stage2[1]));
    fp_add add6 (.clk(clk), .reset(reset), .a(sum_stage2[0]), .b(sum_stage2[1]), .result(sum_stage3[0]));
    fp_add add7 (.clk(clk), .reset(reset), .a(sum_stage3[0]), .b(sum_stage1[4]), .result(sum_stage3[1]));

    // Add bias
    fp_add add_bias (.clk(clk), .reset(reset), .a(sum_stage3[1]), .b(bias), .result(conv_result));
endmodule
