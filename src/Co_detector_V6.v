module Co_detector_V6 (
    input  wire [31:0] A_i,
    input  wire [31:0] B_i,
    output wire        Co_o
);

    // Generate e Propagate
    wire [31:0] G = A_i & B_i;
    wire [31:0] P = A_i ^ B_i;

    // Carry chain
    wire [32:0] carry;
    assign carry[0] = 1'b0;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : cla_logic
            assign carry[i+1] = G[i] | (P[i] & carry[i]);
        end
    endgenerate

    // Carry-out final
    assign Co_o = carry[32];

endmodule
