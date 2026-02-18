module Co_detector (
    input wire [31:0] A_i, B_i, C_i, D_i,
    output wire [1:0] Co_o
);

    // Passo 1: Redução de 4 operandos para 3 (Full Adders em paralelo)
    // Isso transforma A, B, C em S1 e C1
    wire [31:0] s1 = A_i ^ B_i ^ C_i;
    wire [31:0] c1 = (A_i & B_i) | (A_i & C_i) | (B_i & C_i);
    
    // Passo 2: Redução de 3 operandos para 2
    // Agora somamos S1, D_i e o Carry C1 (deslocado)
    wire [31:0] c1_shift = {c1[30:0], 1'b0};
    
    wire [31:0] X = s1 ^ D_i ^ c1_shift;
    wire [31:0] Y = (s1 & D_i) | (s1 & c1_shift) | (D_i & c1_shift);
    
    // Agora temos apenas dois números: X e {Y, 0}
    // O carry final de A+B+C+D é o carry da soma de X + {Y[30:0], 0}
    // mais os bits de overflow que "sobraram" das reduções.

    wire [31:0] G = X & {Y[30:0], 1'b0};
    wire [31:0] P = X ^ {Y[30:0], 1'b0};

    // Carry Lookahead para os dois números finais
    wire [32:0] carry;
    assign carry[0] = 1'b0;
    
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : cla_logic
            assign carry[i+1] = G[i] | (P[i] & carry[i]);
        end
    endgenerate

    // O bit 33 (Co_o[0]) é o carry final da soma de 2 números (X + Y_shifted)
    // O bit 34 (Co_o[1]) vem do overflow direto dos compressores (c1[31] e Y[31])
    
    // A lógica de soma final para os dois carries:
    assign Co_o = carry[32] + c1[31] + Y[31];

endmodule