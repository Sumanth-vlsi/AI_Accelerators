module relu_fp32 (
    input  wire [31:0] din,
    output wire [31:0] dout
);
    // IEEE-754: bit[31] is sign bit
    assign dout = din[31] ? 32'b0 : din;
endmodule
