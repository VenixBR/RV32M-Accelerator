module multiplier
(
    // Inputs
    input  [ 31:0]  A_i,
    input  [ 31:0]  B_i,
    // Outputs
    output [ 31:0]  writeback_value_o
);

    wire [7:0] A_8b_s [7:0];
    wire [7:0] B_8b_s [7:0];

    wire [7:0] AxB_8b_s [35:0];

    wire [31:0] sft_mult_s [35:0];
    wire [31:0] mult_result_s;


    /*===============================
             8(A_4b) x 8(B_4b)
    ===============================*/

    genvar k;
    generate
        for (k=0 ; k<8 ; k=k+1) begin
            assign A_8b_s[k] = {4'b0000, A_i[(k*4+3): k*4]};
            assign B_8b_s[k] = {4'b0000, B_i[(k*4+3): k*4]};
        end
    endgenerate

    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : loopA
            for (j=0; j < (8-i); j=j+1) begin : loopB

                 //localparam int idx = (i*8) - (i*(i-1))/2 + j;

                assign AxB_8b_s[(i*8) - (i*(i-1))/2 + j] = A_8b_s[i] * B_8b_s[j];

            end
        end
    endgenerate





    /*===============================
            SHIFT RESULTS
    ===============================*/

    genvar m, n;
    generate
        for (m = 0; m < 8; m = m + 1) begin : gen_row
            for (n = 0; n < (8 - m); n = n + 1) begin : gen_col
                assign sft_mult_s[(m*8) - (m*(m-1))/2 + n] = AxB_8b_s[(m*8) - (m*(m-1))/2 + n] << 4 * (m + n);

            end
        end
    endgenerate



    /*===============================
        EXTEND A AND B TO 33 BITS
    ===============================*/

    

    assign mult_result_s = {sft_mult_s[0], sft_mult_s[2]}  + sft_mult_s[1]  + sft_mult_s[3]  +
                           sft_mult_s[4]  + sft_mult_s[5]  + sft_mult_s[6]  + sft_mult_s[7]  + 
                           sft_mult_s[8]  + sft_mult_s[9]  + sft_mult_s[10] + sft_mult_s[11] +
                           sft_mult_s[12] + sft_mult_s[13] + sft_mult_s[14] + sft_mult_s[15] +
                           sft_mult_s[16] + sft_mult_s[17] + sft_mult_s[18] + sft_mult_s[19] +
                           sft_mult_s[20] + sft_mult_s[21] + sft_mult_s[22] + sft_mult_s[23] +
                           sft_mult_s[24] + sft_mult_s[25] + sft_mult_s[26] + sft_mult_s[27] +
                           sft_mult_s[28] + sft_mult_s[29] + sft_mult_s[30] + sft_mult_s[31] +
                           sft_mult_s[32] + sft_mult_s[33] + sft_mult_s[34] + sft_mult_s[35];



    assign mult_result_s = sft_mult_s[0]  + sft_mult_s[1]  + sft_mult_s[2]  + sft_mult_s[3]  +
                           sft_mult_s[4]  + sft_mult_s[5]  + sft_mult_s[6]  + sft_mult_s[7]  + 
                           sft_mult_s[8]  + sft_mult_s[9]  + sft_mult_s[10] + sft_mult_s[11] +
                           sft_mult_s[12] + sft_mult_s[13] + sft_mult_s[14] + sft_mult_s[15] +
                           sft_mult_s[16] + sft_mult_s[17] + sft_mult_s[18] + sft_mult_s[19] +
                           sft_mult_s[20] + sft_mult_s[21] + sft_mult_s[22] + sft_mult_s[23] +
                           sft_mult_s[24] + sft_mult_s[25] + sft_mult_s[26] + sft_mult_s[27] +
                           sft_mult_s[28] + sft_mult_s[29] + sft_mult_s[30] + sft_mult_s[31] +
                           sft_mult_s[32] + sft_mult_s[33] + sft_mult_s[34] + sft_mult_s[35];

    assign writeback_value_o = mult_result_s;
    

endmodule