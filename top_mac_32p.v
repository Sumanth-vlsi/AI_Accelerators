`timescale 1ns / 1ps



// --------------------- TOP ---------------------------
module top_conv_layer1 (
    input  wire         clk,
    input  wire         reset,

    input  wire [287:0]   img_patch_flat,       // 9 * 32 = 288 bits
    input  wire [9215:0]  conv1_weights_flat,   // 32 * 9 * 32 = 9216 bits
    input  wire [1023:0]  conv1_biases_flat,    // 32 * 32 = 1024 bits
    output wire [1023:0]  conv_outputs_flat     // 32 * 32 = 1024 bits (POST-ReLU)
);

    // Unpacked 3x3 image patch
    wire [31:0] img_patch [0:8];

    // Unpacked weights and biases
    wire [31:0] conv1_weights [0:31][0:8];
    wire [31:0] conv1_biases  [0:31];

    // MAC outputs and ReLU outputs per filter
    wire [31:0] conv_outputs    [0:31];
    wire [31:0] conv_outputs_relu [0:31];

    // Use distinct genvars for tool-friendliness
    genvar gi, gf, gj;

    // -------- Unpack img_patch_flat -> img_patch[0..8] --------
    generate
        for (gi = 0; gi < 9; gi = gi + 1) begin : G_UNPACK_IMG
            assign img_patch[gi] = img_patch_flat[gi*32 +: 32];
        end
    endgenerate

    // -------- Unpack conv1_weights_flat / conv1_biases_flat --------
    generate
        for (gf = 0; gf < 32; gf = gf + 1) begin : G_UNPACK_PARAMS
            assign conv1_biases[gf] = conv1_biases_flat[gf*32 +: 32];
            for (gj = 0; gj < 9; gj = gj + 1) begin : G_UNPACK_W
                assign conv1_weights[gf][gj] = conv1_weights_flat[32*(gf*9 + gj) +: 32];
            end
        end
    endgenerate

    // -------- Instantiate 32 MACs + ReLU and pack outputs --------
    generate
        for (gf = 0; gf < 32; gf = gf + 1) begin : G_PER_FILTER
            mac_unit mac_inst (
                .clk(clk),
                .reset(reset),

                .img_patch_0(img_patch[0]),
                .img_patch_1(img_patch[1]),
                .img_patch_2(img_patch[2]),
                .img_patch_3(img_patch[3]),
                .img_patch_4(img_patch[4]),
                .img_patch_5(img_patch[5]),
                .img_patch_6(img_patch[6]),
                .img_patch_7(img_patch[7]),
                .img_patch_8(img_patch[8]),

                .weights_0(conv1_weights[gf][0]),
                .weights_1(conv1_weights[gf][1]),
                .weights_2(conv1_weights[gf][2]),
                .weights_3(conv1_weights[gf][3]),
                .weights_4(conv1_weights[gf][4]),
                .weights_5(conv1_weights[gf][5]),
                .weights_6(conv1_weights[gf][6]),
                .weights_7(conv1_weights[gf][7]),
                .weights_8(conv1_weights[gf][8]),

                .bias(conv1_biases[gf]),
                .conv_result(conv_outputs[gf])
            );

            // ReLU stage (combinational)
            relu_fp32 relu_inst (
                .din (conv_outputs[gf]),
                .dout(conv_outputs_relu[gf])
            );

            // Pack POST-ReLU outputs
            assign conv_outputs_flat[gf*32 +: 32] = conv_outputs_relu[gf];
        end
    endgenerate

endmodule
