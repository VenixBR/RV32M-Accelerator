module multiplier
(
    // Inputs
    input  [31:0]  A_i,
    input  [31:0]  B_i,

    // Outputs
    output [63:0]  result_o
);

    
    wire [3:0] A0_s;
    wire [3:0] A1_s;
    wire [3:0] A2_s;
    wire [3:0] A3_s;
    wire [3:0] A4_s;
    wire [3:0] A5_s;
    wire [3:0] A6_s;
    wire [3:0] A7_s;
    
    wire [3:0] B0_s;
    wire [3:0] B1_s;
    wire [3:0] B2_s;
    wire [3:0] B3_s;
    wire [3:0] B4_s;
    wire [3:0] B5_s;
    wire [3:0] B6_s;
    wire [3:0] B7_s;

    wire [7:0] A0B0_s;
    wire [7:0] A0B1_s;
    wire [7:0] A0B2_s;
    wire [7:0] A0B3_s;
    wire [7:0] A0B4_s;
    wire [7:0] A0B5_s;
    wire [7:0] A0B6_s;
    wire [7:0] A0B7_s;

    wire [7:0] A1B0_s;
    wire [7:0] A1B1_s;
    wire [7:0] A1B2_s;
    wire [7:0] A1B3_s;
    wire [7:0] A1B4_s;
    wire [7:0] A1B5_s;
    wire [7:0] A1B6_s;
    wire [7:0] A1B7_s;

    wire [7:0] A2B0_s;
    wire [7:0] A2B1_s;
    wire [7:0] A2B2_s;
    wire [7:0] A2B3_s;
    wire [7:0] A2B4_s;
    wire [7:0] A2B5_s;
    wire [7:0] A2B6_s;
    wire [7:0] A2B7_s;

    wire [7:0] A3B0_s;
    wire [7:0] A3B1_s;
    wire [7:0] A3B2_s;
    wire [7:0] A3B3_s;
    wire [7:0] A3B4_s;
    wire [7:0] A3B5_s;
    wire [7:0] A3B6_s;
    wire [7:0] A3B7_s;

    wire [7:0] A4B0_s;
    wire [7:0] A4B1_s;
    wire [7:0] A4B2_s;
    wire [7:0] A4B3_s;
    wire [7:0] A4B4_s;
    wire [7:0] A4B5_s;
    wire [7:0] A4B6_s;
    wire [7:0] A4B7_s;

    wire [7:0] A5B0_s;
    wire [7:0] A5B1_s;
    wire [7:0] A5B2_s;
    wire [7:0] A5B3_s;
    wire [7:0] A5B4_s;
    wire [7:0] A5B5_s;
    wire [7:0] A5B6_s;
    wire [7:0] A5B7_s;

    wire [7:0] A6B0_s;
    wire [7:0] A6B1_s;
    wire [7:0] A6B2_s;
    wire [7:0] A6B3_s;
    wire [7:0] A6B4_s;
    wire [7:0] A6B5_s;
    wire [7:0] A6B6_s;
    wire [7:0] A6B7_s;
    
    wire [7:0] A7B0_s;
    wire [7:0] A7B1_s;
    wire [7:0] A7B2_s;
    wire [7:0] A7B3_s;
    wire [7:0] A7B4_s;
    wire [7:0] A7B5_s;
    wire [7:0] A7B6_s;
    wire [7:0] A7B7_s;

    wire [59:0] partial_1;
    wire [59:0] partial_2;
    wire [59:0] partial_3;
    wire [59:0] partial_4;
    wire [59:0] partial_5;
    wire [59:0] partial_6;
    wire [59:0] partial_7;
    wire [59:0] partial_8;
    wire [59:0] partial_9;
    wire [59:0] partial_10;
    wire [59:0] partial_11;
    wire [59:0] partial_12;
    wire [59:0] partial_13;
    wire [59:0] partial_14;
    wire [59:0] partial_15;
    wire [59:0] partial_16;

    wire [59:0] sum_s;




    assign A0_s = A_i[3:0];
    assign A1_s = A_i[7:4];
    assign A2_s = A_i[11:8];
    assign A3_s = A_i[15:12];
    assign A4_s = A_i[19:16];
    assign A5_s = A_i[23:20];
    assign A6_s = A_i[27:24];
    assign A7_s = A_i[31:28];

    assign B0_s = B_i[3:0];
    assign B1_s = B_i[7:4];
    assign B2_s = B_i[11:8];
    assign B3_s = B_i[15:12];
    assign B4_s = B_i[19:16];
    assign B5_s = B_i[23:20];
    assign B6_s = B_i[27:24];
    assign B7_s = B_i[31:28];

    assign A0B0_s = {4'h0, A0_s}*{4'h0, B0_s};
    assign A0B1_s = {4'h0, A0_s}*{4'h0, B1_s};
    assign A0B2_s = {4'h0, A0_s}*{4'h0, B2_s};
    assign A0B3_s = {4'h0, A0_s}*{4'h0, B3_s};
    assign A0B4_s = {4'h0, A0_s}*{4'h0, B4_s};
    assign A0B5_s = {4'h0, A0_s}*{4'h0, B5_s};
    assign A0B6_s = {4'h0, A0_s}*{4'h0, B6_s};
    assign A0B7_s = {4'h0, A0_s}*{4'h0, B7_s};

    assign A1B0_s = {4'h0, A1_s}*{4'h0, B0_s};
    assign A1B1_s = {4'h0, A1_s}*{4'h0, B1_s};
    assign A1B2_s = {4'h0, A1_s}*{4'h0, B2_s};
    assign A1B3_s = {4'h0, A1_s}*{4'h0, B3_s};
    assign A1B4_s = {4'h0, A1_s}*{4'h0, B4_s};
    assign A1B5_s = {4'h0, A1_s}*{4'h0, B5_s};
    assign A1B6_s = {4'h0, A1_s}*{4'h0, B6_s};
    assign A1B7_s = {4'h0, A1_s}*{4'h0, B7_s};

    assign A2B0_s = {4'h0, A2_s}*{4'h0, B0_s};
    assign A2B1_s = {4'h0, A2_s}*{4'h0, B1_s};
    assign A2B2_s = {4'h0, A2_s}*{4'h0, B2_s};
    assign A2B3_s = {4'h0, A2_s}*{4'h0, B3_s};
    assign A2B4_s = {4'h0, A2_s}*{4'h0, B4_s};
    assign A2B5_s = {4'h0, A2_s}*{4'h0, B5_s};
    assign A2B6_s = {4'h0, A2_s}*{4'h0, B6_s};
    assign A2B7_s = {4'h0, A2_s}*{4'h0, B7_s};

    assign A3B0_s = {4'h0, A3_s}*{4'h0, B0_s};
    assign A3B1_s = {4'h0, A3_s}*{4'h0, B1_s};
    assign A3B2_s = {4'h0, A3_s}*{4'h0, B2_s};
    assign A3B3_s = {4'h0, A3_s}*{4'h0, B3_s};
    assign A3B4_s = {4'h0, A3_s}*{4'h0, B4_s};
    assign A3B5_s = {4'h0, A3_s}*{4'h0, B5_s};
    assign A3B6_s = {4'h0, A3_s}*{4'h0, B6_s};
    assign A3B7_s = {4'h0, A3_s}*{4'h0, B7_s};

    assign A4B0_s = {4'h0, A4_s}*{4'h0, B0_s};
    assign A4B1_s = {4'h0, A4_s}*{4'h0, B1_s};
    assign A4B2_s = {4'h0, A4_s}*{4'h0, B2_s};
    assign A4B3_s = {4'h0, A4_s}*{4'h0, B3_s};
    assign A4B4_s = {4'h0, A4_s}*{4'h0, B4_s};
    assign A4B5_s = {4'h0, A4_s}*{4'h0, B5_s};
    assign A4B6_s = {4'h0, A4_s}*{4'h0, B6_s};
    assign A4B7_s = {4'h0, A4_s}*{4'h0, B7_s};

    assign A5B0_s = {4'h0, A5_s}*{4'h0, B0_s};
    assign A5B1_s = {4'h0, A5_s}*{4'h0, B1_s};
    assign A5B2_s = {4'h0, A5_s}*{4'h0, B2_s};
    assign A5B3_s = {4'h0, A5_s}*{4'h0, B3_s};
    assign A5B4_s = {4'h0, A5_s}*{4'h0, B4_s};
    assign A5B5_s = {4'h0, A5_s}*{4'h0, B5_s};
    assign A5B6_s = {4'h0, A5_s}*{4'h0, B6_s};
    assign A5B7_s = {4'h0, A5_s}*{4'h0, B7_s};

    assign A6B0_s = {4'h0, A6_s}*{4'h0, B0_s};
    assign A6B1_s = {4'h0, A6_s}*{4'h0, B1_s};
    assign A6B2_s = {4'h0, A6_s}*{4'h0, B2_s};
    assign A6B3_s = {4'h0, A6_s}*{4'h0, B3_s};
    assign A6B4_s = {4'h0, A6_s}*{4'h0, B4_s};
    assign A6B5_s = {4'h0, A6_s}*{4'h0, B5_s};
    assign A6B6_s = {4'h0, A6_s}*{4'h0, B6_s};
    assign A6B7_s = {4'h0, A6_s}*{4'h0, B7_s};

    assign A7B0_s = {4'h0, A7_s}*{4'h0, B0_s};
    assign A7B1_s = {4'h0, A7_s}*{4'h0, B1_s};
    assign A7B2_s = {4'h0, A7_s}*{4'h0, B2_s};
    assign A7B3_s = {4'h0, A7_s}*{4'h0, B3_s};
    assign A7B4_s = {4'h0, A7_s}*{4'h0, B4_s};
    assign A7B5_s = {4'h0, A7_s}*{4'h0, B5_s};
    assign A7B6_s = {4'h0, A7_s}*{4'h0, B6_s};
    assign A7B7_s = {4'h0, A7_s}*{4'h0, B7_s};



    assign partial_1 = {A7B7_s, A7B5_s, A7B3_s, A7B1_s, A0B6_s, A0B4_s, A0B2_s, A0B0_s[7:4]};
    assign partial_2 = {4'h0, A7B6_s, A7B4_s, A7B2_s, A0B7_s, A0B5_s, A0B3_s, A0B1_s};
    assign partial_3 = {4'h0, A6B7_s, A6B5_s, A6B3_s, A1B6_s, A1B4_s, A1B2_s, A1B0_s};
    assign partial_4 = {8'h00, A6B6_s, A6B4_s, A1B7_s, A1B5_s, A1B3_s, A1B1_s, 4'h0};
    assign partial_5 = {8'h00, A5B7_s, A5B5_s, A2B6_s, A2B4_s, A2B2_s, A2B0_s, 4'h0};
    assign partial_6 = {12'h000, A5B6_s, A2B7_s, A2B5_s, A2B3_s, A2B1_s, 8'h00};

    assign partial_7 = {12'h000, A4B7_s, A3B6_s, A3B4_s, A3B2_s, A3B0_s, 8'h00};
    assign partial_8 = {16'h0000, A3B7_s, A3B5_s, A3B3_s, A3B1_s, 12'h000};

    assign partial_9 = {16'h0000, A4B6_s, A4B4_s, A4B2_s, A4B0_s, 12'h000};

    assign partial_10 = {20'h00000, A4B5_s, A4B3_s, A4B1_s, 16'h0000};
    assign partial_11 = {20'h00000, A5B4_s, A5B2_s, A5B0_s, 16'h0000};

    assign partial_12 = {24'h000000, A5B3_s, A5B1_s, 20'h00000};
    assign partial_13 = {24'h000000, A6B2_s, A6B0_s, 20'h00000};
    assign partial_14 = {28'h0000000, A6B1_s, 24'h000000};
    assign partial_15 = {28'h0000000,A7B0_s, 24'h000000};

    assign sum_s = partial_1 + partial_2 + partial_3 + partial_4 +
                   partial_5 + partial_6 + partial_7 + partial_8 +
                   partial_9 + partial_10 + partial_11 + partial_12 +
                   partial_13 + partial_14 + partial_15;

    assign result_o = {sum_s, A0B0_s[3:0]};
endmodule