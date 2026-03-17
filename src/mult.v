module multiplier
(
    // Inputs
    input  [ 15:0]  A_i,
    input  [ 15:0]  B_i,
    input sigA_i,
    input sigB_i,
    // Outputs
    output [ 32:0]  writeback_value_o
);

    wire [3:0] A3_s;
    wire [3:0] A2_s;
    wire [3:0] A1_s;
    wire [3:0] A0_s;

    wire [3:0] B3_s;
    wire [3:0] B2_s;
    wire [3:0] B1_s;
    wire [3:0] B0_s;

    wire [8:0] A3_ext_s;
    wire [8:0] A2_ext_s;
    wire [8:0] A1_ext_s;
    wire [8:0] A0_ext_s;

    wire [8:0] B3_ext_s;
    wire [8:0] B2_ext_s;
    wire [8:0] B1_ext_s;
    wire [8:0] B0_ext_s;

    wire [8:0] A0B0_s;
    wire [8:0] A0B1_s;
    wire [8:0] A0B2_s;
    wire [8:0] A0B3_s;
    wire [8:0] A1B0_s;
    wire [8:0] A1B1_s;
    wire [8:0] A1B2_s;
    wire [8:0] A1B3_s;
    wire [8:0] A2B0_s;
    wire [8:0] A2B1_s;
    wire [8:0] A2B2_s;
    wire [8:0] A2B3_s;
    wire [8:0] A3B0_s;
    wire [8:0] A3B1_s;
    wire [8:0] A3B2_s;
    wire [8:0] A3B3_s;

    wire [32:0] A0B0_ext_s;
    wire [32:0] A0B1_ext_s;
    wire [32:0] A0B2_ext_s;
    wire [32:0] A0B3_ext_s;
    wire [32:0] A1B0_ext_s;
    wire [32:0] A1B1_ext_s;
    wire [32:0] A1B2_ext_s;
    wire [32:0] A1B3_ext_s;
    wire [32:0] A2B0_ext_s;
    wire [32:0] A2B1_ext_s;
    wire [32:0] A2B2_ext_s;
    wire [32:0] A2B3_ext_s;
    wire [32:0] A3B0_ext_s;
    wire [32:0] A3B1_ext_s;
    wire [32:0] A3B2_ext_s;
    wire [32:0] A3B3_ext_s;

    wire [32:0] A0B0_sft_s;
    wire [32:0] A0B1_sft_s;
    wire [32:0] A0B2_sft_s;
    wire [32:0] A0B3_sft_s;
    wire [32:0] A1B0_sft_s;
    wire [32:0] A1B1_sft_s;
    wire [32:0] A1B2_sft_s;
    wire [32:0] A1B3_sft_s;
    wire [32:0] A2B0_sft_s;
    wire [32:0] A2B1_sft_s;
    wire [32:0] A2B2_sft_s;
    wire [32:0] A2B3_sft_s;
    wire [32:0] A3B0_sft_s;
    wire [32:0] A3B1_sft_s;
    wire [32:0] A3B2_sft_s;
    wire [32:0] A3B3_sft_s;




    assign A3_s = A_i[15:12];
    assign A2_s = A_i[11:8];
    assign A1_s = A_i[7:4];
    assign A0_s = A_i[3:0];

    assign B3_s = B_i[15:12];
    assign B2_s = B_i[11:8];
    assign B1_s = B_i[7:4];
    assign B0_s = B_i[3:0];

    assign A3_ext_s = (sigA_i) ? {{5{A3_s[3]}},A3_s} : {5'b00000, A3_s};
    assign A2_ext_s = {5'b00000, A2_s};
    assign A1_ext_s = {5'b00000, A1_s};
    assign A0_ext_s = {5'b00000, A0_s};

    assign B3_ext_s = (sigB_i) ? {{5{B3_s[3]}},B3_s} : {5'b00000, B3_s};
    assign B2_ext_s = {5'b00000, B2_s};
    assign B1_ext_s = {5'b00000, B1_s};
    assign B0_ext_s = {5'b00000, B0_s};

    assign A0B0_s = A0_ext_s*B0_ext_s;
    assign A0B1_s = A0_ext_s*B1_ext_s;
    assign A0B2_s = A0_ext_s*B2_ext_s;
    assign A0B3_s = A0_ext_s*B3_ext_s;
    assign A1B0_s = A1_ext_s*B0_ext_s;
    assign A1B1_s = A1_ext_s*B1_ext_s;
    assign A1B2_s = A1_ext_s*B2_ext_s;
    assign A1B3_s = A1_ext_s*B3_ext_s;
    assign A2B0_s = A2_ext_s*B0_ext_s;
    assign A2B1_s = A2_ext_s*B1_ext_s;
    assign A2B2_s = A2_ext_s*B2_ext_s;
    assign A2B3_s = A2_ext_s*B3_ext_s;
    assign A3B0_s = A3_ext_s*B0_ext_s;
    assign A3B1_s = A3_ext_s*B1_ext_s;
    assign A3B2_s = A3_ext_s*B2_ext_s;
    assign A3B3_s = A3_ext_s*B3_ext_s;

    assign A0B0_ext_s = {{24{A0B0_s[8]}}, A0B0_s};
    assign A0B1_ext_s = {{24{A0B1_s[8]}}, A0B1_s};
    assign A0B2_ext_s = {{24{A0B2_s[8]}}, A0B2_s};
    assign A0B3_ext_s = {{24{A0B3_s[8]}}, A0B3_s};
    assign A1B0_ext_s = {{24{A1B0_s[8]}}, A1B0_s};
    assign A1B1_ext_s = {{24{A1B1_s[8]}}, A1B1_s};
    assign A1B2_ext_s = {{24{A1B2_s[8]}}, A1B2_s};
    assign A1B3_ext_s = {{24{A1B3_s[8]}}, A1B3_s};
    assign A2B0_ext_s = {{24{A2B0_s[8]}}, A2B0_s};
    assign A2B1_ext_s = {{24{A2B1_s[8]}}, A2B1_s};
    assign A2B2_ext_s = {{24{A2B2_s[8]}}, A2B2_s};
    assign A2B3_ext_s = {{24{A2B3_s[8]}}, A2B3_s};
    assign A3B0_ext_s = {{24{A3B0_s[8]}}, A3B0_s};
    assign A3B1_ext_s = {{24{A3B1_s[8]}}, A3B1_s};
    assign A3B2_ext_s = {{24{A3B2_s[8]}}, A3B2_s};
    assign A3B3_ext_s = {{24{A3B3_s[8]}}, A3B3_s};

    assign A0B0_sft_s = A0B0_ext_s;
    assign A0B1_sft_s = A0B1_ext_s<<4;
    assign A0B2_sft_s = A0B2_ext_s<<8;
    assign A0B3_sft_s = A0B3_ext_s<<12;
    assign A1B0_sft_s = A1B0_ext_s<<4;
    assign A1B1_sft_s = A1B1_ext_s<<8;
    assign A1B2_sft_s = A1B2_ext_s<<12;
    assign A1B3_sft_s = A1B3_ext_s<<16;
    assign A2B0_sft_s = A2B0_ext_s<<8;
    assign A2B1_sft_s = A2B1_ext_s<<12;
    assign A2B2_sft_s = A2B2_ext_s<<16;
    assign A2B3_sft_s = A2B3_ext_s<<20;
    assign A3B0_sft_s = A3B0_ext_s<<12;
    assign A3B1_sft_s = A3B1_ext_s<<16;
    assign A3B2_sft_s = A3B2_ext_s<<20;
    assign A3B3_sft_s = A3B3_ext_s<<24;

    assign writeback_value_o = {A0B0_sft_s[32:4] + A0B1_sft_s[32:4] + A0B2_sft_s[32:4] + A0B3_sft_s[32:4] +
                               A1B0_sft_s[32:4] + A1B1_sft_s[32:4] + A1B2_sft_s[32:4] + A1B3_sft_s[32:4] +
                               A2B0_sft_s[32:4] + A2B1_sft_s[32:4] + A2B2_sft_s[32:4] + A2B3_sft_s[32:4] +
                               A3B0_sft_s[32:4] + A3B1_sft_s[32:4] + A3B2_sft_s[32:4] + A3B3_sft_s[32:4], A0B0_sft_s[3:0]};


endmodule