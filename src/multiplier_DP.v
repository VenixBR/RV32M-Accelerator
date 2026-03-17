module multiplier_DP ( 
    
    // Inputs
    input wire        clk_i,
    input wire        rst_i,
    input wire        upper_i,
    input wire [31:0] op_A_i,
    input wire [31:0] op_B_i,

    // Control Signals
    input wire       reg_A_en_i,      // enable of register of operand A
    input wire       reg_B_en_i,      // enable of register of operand B
    input wire       AC_en_i,         // enable of result accumulator
    input wire       en_pipe_i,       // enable of pipeline registers
    input wire       mux_B_sel_i,     // mux selector of operand B
    input wire       signed_A_i,      // signal extension of operand A
    input wire       signed_B_i,      // signal extension of operand B
    input wire       shift_amount_i,  // shift amount to multiplier results
    input wire       rol_en_i,        // left rotate amount to operand B #UNECESSARY

    // Outputs
    output wire [31:0] result_o
);

    // SIGNALS
    reg  [31:0] reg_A_s;              // Input register to operand A
    reg  [31:0] reg_B_s;              // Input register to operand B
    reg         reg_upper_s;          // Input register to signal upper_i
    reg         reg_sigA_s;           // Input register to signal signed_A_i
    reg  [1:0]  reg_sigB_s;           // Input register to signal signed_B_i

    wire [31:0] mux_B_s;              // Output of mux to left rotate input
    wire [3:0]  mux_sigB_s;           // Output of mux to sigB reg
    
                                      // reg B value is divided in 2 parts: B1 B0
    wire [3:0] B0_s [3:0];           // B0 <- regB [7:0]
    wire [3:0] B1_s [3:0];           // B1 <- regB [15:8]

    wire [8:0] B0_ext_s [3:0];       // signal extension to 16 bits of B0 
    wire [8:0] B1_ext_s [3:0];       // signal extension to 16 bits of B1

                                      // reg A value is divided in 2 parts: A1 A0
    wire [3:0] A0_s [3:0];           // A0 <- regA [7:0]
    wire [3:0] A1_s [3:0];           // A1 <- regA [15:8]

    wire [8:0] A0_ext_s [3:0];        // signal extension to 16 bits of A0
    wire [8:0] A1_ext_s [3:0];       // signal extension to 16 bits of A1



    wire [8:0] A0_9b_s [3:0];
    wire [8:0] A1_9b_s [3:0];
    wire [8:0] B0_9b_s [3:0];
    wire [8:0] B1_9b_s [3:0];

    wire [9:0] A0xB0_9b_s [15:0];
    wire [9:0] A1xB1_9b_s [15:0];

    wire [31:0] sft_mult0_s [32:0];
    wire [31:0] sft_mult1_s [32:0];

    wire [31:0] mult_result0_s;
    wire [31:0] mult_result1_s;




    reg  [32:0] reg_pipe_A0xB0_s;     // PIPELINE REGISTERS
    reg  [32:0] reg_pipe_A1xB1_s;
    reg         reg_pipe_sft_amt_s;
    reg         reg_pipe_AC_en_s;
    

    wire [32:0] A0_x_B0_ext_s [31:0];        // Extends the signal of the A0 x B0 to 64 bits
    wire [32:0] A1_x_B1_ext_s [31:0];        // Extends the signal of the A1 x B1 to 64 bits

    wire [63:0] A0_x_B0_64_s;        // Extends the signal of the A0 x B0 to 64 bits
    wire [63:0] A1_x_B1_64_s;        // Extends the signal of the A1 x B1 to 64 bits


    reg  [63:0] A0_x_B0_sft_s;        // A0 x B0 shifted
    reg  [63:0] A1_x_B1_sft_s;        // A1 x B1 shifted

    wire [31:0] M0_mux_s;
    wire [31:0] M1_mux_s;

    wire        detect_co_s;
    wire        low_mul_co_s;

    reg  [63:0] reg_pipe_result_s;
    reg         reg_pipe_co_s;

    wire [63:0] partial_result_1_s;     // Partial result of multiplicatio to accumulator input
    wire [31:0] partial_result_2_s;     // Partial result of multiplicatio to accumulator input
    wire [31:0] partial_result_3_s;     // Partial result of multiplicatio to accumulator input

    wire [31:0] sum_s;
    wire [1:0] carries_s;
    reg  [63:0] AC_s;                 // Accumulator value

    

    // B Signed extension mux
    assign mux_sigB_s = (reg_A_en_i == 1'b1) ? {signed_B_i, 1'b0} : {reg_sigB_s[0], reg_sigB_s[1]};

    // Mux between B input and reg B value
    assign mux_B_s = (mux_B_sel_i == 1'b0) ? op_B_i : {reg_B_s[15:0], reg_B_s[31:16]};

    // Input Registers
    always @(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            reg_A_s           <= 32'h00000000;
            reg_B_s           <= 32'h00000000;
            reg_upper_s       <= 1'b0;
            reg_sigA_s        <= 1'b0;
        end
        else if (clk_i) begin
            if (reg_A_en_i) begin
                reg_A_s           <= op_A_i;
                reg_upper_s       <= upper_i;
                reg_sigA_s        <= signed_A_i;
            end
            
            if (reg_B_en_i) begin
                reg_B_s           <= mux_B_s;
                reg_sigB_s        <= mux_sigB_s; 
            end
        end
    end
    

    // // Divide reg A value in 2 parts
    // assign A0_s[0] = reg_A_s[3:0];
    // assign A0_s[1] = reg_A_s[7:4];
    // assign A0_s[2] = reg_A_s[11:8];
    // assign A0_s[3] = reg_A_s[15:12];

    // assign A1_s[0] = reg_A_s[19:16];
    // assign A1_s[1] = reg_A_s[23:20];
    // assign A1_s[2] = reg_A_s[27:24];
    // assign A1_s[3] = reg_A_s[31:28];

    // // Divide reg B value in 2 parts
    // assign B0_s[0] = reg_B_s[3:0];
    // assign B0_s[1] = reg_B_s[7:4];
    // assign B0_s[2] = reg_B_s[11:8];
    // assign B0_s[3] = reg_B_s[15:12];

    // assign B1_s[0] = reg_B_s[19:16];
    // assign B1_s[1] = reg_B_s[23:20];
    // assign B1_s[2] = reg_B_s[27:24];
    // assign B1_s[3] = reg_B_s[31:28];

    // // Signal extension to reg A value. The 4 parts are constant.
    // assign A0_ext_s[0] = {5'b00000, A0_s[0]};
    // assign A0_ext_s[1] = {5'b00000, A0_s[1]};
    // assign A0_ext_s[2] = {5'b00000, A0_s[2]};
    // assign A0_ext_s[3] = {5'b00000, A0_s[3]};

    // assign A1_ext_s[0] = {5'b00000, A1_s[0]};
    // assign A1_ext_s[1] = {5'b00000, A1_s[1]};
    // assign A1_ext_s[2] = {5'b00000, A1_s[2]};
    // assign A1_ext_s[3] = { (reg_sigA_s==1'b1) ? {5{A1_s[3][3]}} : 5'b00000 , A1_s[3]};


    // // Signal extension to reg B value. Are variable because B is rotated.
    // assign B0_ext_s[0] = {5'b00000, B0_s[0]};
    // assign B0_ext_s[1] = {5'b00000, B0_s[1]};
    // assign B0_ext_s[2] = {5'b00000, B0_s[2]};
    // assign B0_ext_s[3] = { (reg_sigB_s[0]==1'b1) ?  {5{B0_s[3][3]}} : 5'b00000 , B0_s[3]};

    // assign B1_ext_s[0] = {5'b00000, B1_s[0]};
    // assign B1_ext_s[1] = {5'b00000, B1_s[1]};
    // assign B1_ext_s[2] = {5'b00000, B1_s[2]};
    // assign B1_ext_s[3] = { (reg_sigB_s[1]==1'b1) ?  {5{B1_s[3][3]}} : 5'b00000 , B1_s[3]};


    // /*===============================
    //          8(A_4b) x 8(B_4b)
    // ===============================*/

    // assign A0xB0_9b_s[0]  = A0_ext_s[0] * B0_ext_s[0]; // A0    * B0      --> 0
    // assign A0xB0_9b_s[1]  = A0_ext_s[0] * B0_ext_s[1]; // A0    * B1<<4   --> 4 
    // assign A0xB0_9b_s[2]  = A0_ext_s[0] * B0_ext_s[2]; // A0    * B2<<8   --> 8
    // assign A0xB0_9b_s[3]  = A0_ext_s[0] * B0_ext_s[3]; // A0    * B3<<12  --> 12

    // assign A0xB0_9b_s[4]  = A0_ext_s[1] * B0_ext_s[0]; // A1<<4 * B0      --> 4
    // assign A0xB0_9b_s[5]  = A0_ext_s[1] * B0_ext_s[1]; // A1<<4 * B1<<4   --> 8
    // assign A0xB0_9b_s[6]  = A0_ext_s[1] * B0_ext_s[2]; // A1<<4 * B2<<8   --> 12
    // assign A0xB0_9b_s[7]  = A0_ext_s[1] * B0_ext_s[3]; // A1<<4 * B3<<12  --> 16

    // assign A0xB0_9b_s[8]  = A0_ext_s[2] * B0_ext_s[0]; // A2<<8 * B0      --> 8
    // assign A0xB0_9b_s[9] = A0_ext_s[2] * B0_ext_s[1]; // A2<<8 * B1<<4   --> 12
    // assign A0xB0_9b_s[10] = A0_ext_s[2] * B0_ext_s[2]; // A2<<8 * B2<<8   --> 16
    // assign A0xB0_9b_s[11] = A0_ext_s[2] * B0_ext_s[3]; // A2<<8 * B3<<12  --> 20

    // assign A0xB0_9b_s[12] = A0_ext_s[3] * B0_ext_s[0]; // A3<<12 * B0     --> 12
    // assign A0xB0_9b_s[13] = A0_ext_s[3] * B0_ext_s[1]; // A3<<12 * B1<<4  --> 16
    // assign A0xB0_9b_s[14] = A0_ext_s[3] * B0_ext_s[2]; // A3<<12 * B2<<8  --> 20
    // assign A0xB0_9b_s[15] = A0_ext_s[3] * B0_ext_s[3]; // A3<<12 * B3<<12 --> 24




    // assign A1xB1_9b_s[0]  = A1_ext_s[0] * B1_ext_s[0]; // A0 * B0
    // assign A1xB1_9b_s[1]  = A1_ext_s[0] * B1_ext_s[1]; // A0 * B1
    // assign A1xB1_9b_s[2]  = A1_ext_s[0] * B1_ext_s[2]; // A0 * B2
    // assign A1xB1_9b_s[3]  = A1_ext_s[0] * B1_ext_s[3]; // A0 * B3

    // assign A1xB1_9b_s[4]  = A1_ext_s[1] * B1_ext_s[0]; // A1 * B0
    // assign A1xB1_9b_s[5]  = A1_ext_s[1] * B1_ext_s[1]; // A1 * B1
    // assign A1xB1_9b_s[6]  = A1_ext_s[1] * B1_ext_s[2]; // A1 * B2
    // assign A1xB1_9b_s[7]  = A1_ext_s[1] * B1_ext_s[3]; // A1 * B3

    // assign A1xB1_9b_s[8]  = A1_ext_s[2] * B1_ext_s[0]; // A2 * B0
    // assign A1xB1_9b_s[9] = A1_ext_s[2] * B1_ext_s[1]; // A2 * B1
    // assign A1xB1_9b_s[10] = A1_ext_s[2] * B1_ext_s[2]; // A2 * B2
    // assign A1xB1_9b_s[11] = A1_ext_s[2] * B1_ext_s[3]; // A2 * B3

    // assign A1xB1_9b_s[12] = A1_ext_s[3] * B1_ext_s[0]; // A3 * B0
    // assign A1xB1_9b_s[13] = A1_ext_s[3] * B1_ext_s[1]; // A3 * B1
    // assign A1xB1_9b_s[14] = A1_ext_s[3] * B1_ext_s[2]; // A3 * B2
    // assign A1xB1_9b_s[15] = A1_ext_s[3] * B1_ext_s[3]; // A3 * B3

    // assign A0_x_B0_ext_s[0] = {23'h000000, A0xB0_9b_s[0]};
    // assign A0_x_B0_ext_s[1] = {23'h000000, A0xB0_9b_s[1]};
    // assign A0_x_B0_ext_s[2] = {23'h000000, A0xB0_9b_s[2]};
    // assign A0_x_B0_ext_s[3] = {23'h000000, A0xB0_9b_s[3]};
    // assign A0_x_B0_ext_s[4] = {23'h000000, A0xB0_9b_s[4]};
    // assign A0_x_B0_ext_s[5] = {23'h000000, A0xB0_9b_s[5]};
    // assign A0_x_B0_ext_s[6] = {23'h000000, A0xB0_9b_s[6]};
    // assign A0_x_B0_ext_s[7] = {23'h000000, A0xB0_9b_s[7]};
    // assign A0_x_B0_ext_s[8] = {23'h000000, A0xB0_9b_s[8]};
    // assign A0_x_B0_ext_s[9] = {23'h000000, A0xB0_9b_s[9]};
    // assign A0_x_B0_ext_s[10] = {23'h000000, A0xB0_9b_s[10]};
    // assign A0_x_B0_ext_s[11] = {23'h000000, A0xB0_9b_s[11]};
    // assign A0_x_B0_ext_s[12] = {23'h000000, A0xB0_9b_s[12]};
    // assign A0_x_B0_ext_s[13] = {23'h000000, A0xB0_9b_s[13]};
    // assign A0_x_B0_ext_s[14] = {23'h000000, A0xB0_9b_s[14]};
    // assign A0_x_B0_ext_s[15] = {23'h000000, A0xB0_9b_s[15]};

    // assign A1_x_B1_ext_s[0] = {23'h000000, A1xB1_9b_s[0]};
    // assign A1_x_B1_ext_s[1] = {23'h000000, A1xB1_9b_s[1]};
    // assign A1_x_B1_ext_s[2] = {23'h000000, A1xB1_9b_s[2]};
    // assign A1_x_B1_ext_s[3] = {23'h000000, A1xB1_9b_s[3]};
    // assign A1_x_B1_ext_s[4] = {23'h000000, A1xB1_9b_s[4]};
    // assign A1_x_B1_ext_s[5] = {23'h000000, A1xB1_9b_s[5]};
    // assign A1_x_B1_ext_s[6] = {23'h000000, A1xB1_9b_s[6]};
    // assign A1_x_B1_ext_s[7] = {23'h000000, A1xB1_9b_s[7]};
    // assign A1_x_B1_ext_s[8] = {23'h000000, A1xB1_9b_s[8]};
    // assign A1_x_B1_ext_s[9] = {23'h000000, A1xB1_9b_s[9]};
    // assign A1_x_B1_ext_s[10] = {23'h000000, A1xB1_9b_s[10]};
    // assign A1_x_B1_ext_s[11] = {23'h000000, A1xB1_9b_s[11]};
    // assign A1_x_B1_ext_s[12] = {23'h000000, A1xB1_9b_s[12]};
    // assign A1_x_B1_ext_s[13] = {23'h000000, A1xB1_9b_s[13]};
    // assign A1_x_B1_ext_s[14] = {23'h000000, A1xB1_9b_s[14]};
    // assign A1_x_B1_ext_s[15] = {23'h000000, A1xB1_9b_s[15]};


    // assign mult_result0_s = A0_x_B0_ext_s[0]      + A0_x_B0_ext_s[1]<<4   + A0_x_B0_ext_s[2]<<8   + A0_x_B0_ext_s[3]<<12  + 
    //                         A0_x_B0_ext_s[4]<<4   + A0_x_B0_ext_s[5]<<8   + A0_x_B0_ext_s[6]<<12  + A0_x_B0_ext_s[7]<<16  +
    //                         A0_x_B0_ext_s[8]<<8   + A0_x_B0_ext_s[9]<<12  + A0_x_B0_ext_s[10]<<16 + A0_x_B0_ext_s[11]<<20 + 
    //                         A0_x_B0_ext_s[12]<<12 + A0_x_B0_ext_s[13]<<16 + A0_x_B0_ext_s[14]<<20 + A0_x_B0_ext_s[15]<<24;

    // assign mult_result1_s = A1_x_B1_ext_s[0]      + A1_x_B1_ext_s[1]<<4   + A1_x_B1_ext_s[2]<<8   + A1_x_B1_ext_s[3]<<12  + 
    //                         A1_x_B1_ext_s[4]<<4   + A1_x_B1_ext_s[5]<<8   + A1_x_B1_ext_s[6]<<12  + A1_x_B1_ext_s[7]<<16  +
    //                         A1_x_B1_ext_s[8]<<8   + A1_x_B1_ext_s[9]<<12  + A1_x_B1_ext_s[10]<<16 + A1_x_B1_ext_s[11]<<20 + 
    //                         A1_x_B1_ext_s[12]<<12 + A1_x_B1_ext_s[13]<<16 + A1_x_B1_ext_s[14]<<20 + A1_x_B1_ext_s[15]<<24;


     wire [32:0] temp_mult1, temp_mult2;
//     wire [15:0] B0_st, B1_st;
//     wire [31:0] ext_a0, ext_a1, ext_b0, ext_b1;

// // Divide reg B value in 2 parts
//     assign B0_st = reg_B_s[15:0];
//     assign B1_st = reg_B_s[31:16];


//     // Signal extension to reg A value. The 4 parts are constant.
//     assign ext_a0 = {16'h0000 ,reg_A_s[15:0]};
//     //assign A0_ext_s = (reg_sigA_s==1'b1) ? {{{16{reg_A_s[16]}}}, reg_A_s[15:0]} : {16'h0000 ,reg_A_s[15:0]};
    
//     assign ext_a1 = (reg_sigA_s==1'b1) ? {{{16{reg_A_s[31]}}}, reg_A_s[31:16]} : {16'h0000 ,reg_A_s[31:16]};

//     // Signal extension to reg B value. Are variable because B is rotated.
//     assign ext_b0 = (reg_sigB_s[0]==1'b1) ? {{{16{B0_st[15]}}}, B0_st} : {16'h0000 ,B0_st};
//     assign ext_b1 = (reg_sigB_s[1]==1'b1) ? {{{16{B1_st[15]}}}, B1_st} : {16'h0000 ,B1_st};

    multiplier mult1 (
        .A_i(reg_A_s[15:0]),
        .B_i(reg_B_s[15:0]),
        .sigA_i(1'b0),
        .sigB_i(reg_sigB_s[0]),
    // Outputs
        .writeback_value_o(temp_mult1)
    );

    multiplier mult2 (
        .A_i(reg_A_s[31:16]),
        .B_i(reg_B_s[31:16]),
        .sigA_i(reg_sigA_s),
        .sigB_i(reg_sigB_s[1]),
    // Outputs
        .writeback_value_o(temp_mult2)
    );

    // assign temp_mult1 = {ext_b0[31], ext_b0} * {ext_a0[31], ext_a0};
    // assign temp_mult2 = {ext_b1[31], ext_b1} * {ext_a1[31], ext_a1};



    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            reg_pipe_A0xB0_s   <= 32'h0000;
            reg_pipe_A1xB1_s   <= 32'h0000;
            reg_pipe_AC_en_s   <= 1'b0;
            reg_pipe_sft_amt_s <= 1'b0;
        end
        else if ( en_pipe_i ) begin
            // reg_pipe_A0xB0_s   <= mult_result0_s;
            // reg_pipe_A1xB1_s   <= mult_result1_s;
            reg_pipe_A0xB0_s   <= temp_mult1;
            reg_pipe_A1xB1_s   <= temp_mult2;
            reg_pipe_AC_en_s   <= AC_en_i;
            reg_pipe_sft_amt_s <= shift_amount_i;
        end
    end


    // Signal extension of A x B to 64 bits
    assign A0_x_B0_64_s = {{31{reg_pipe_A0xB0_s[32]}}, reg_pipe_A0xB0_s};
    assign A1_x_B1_64_s = {{31{reg_pipe_A1xB1_s[32]}}, reg_pipe_A1xB1_s};

    // SHIFTERS
    always@* begin
        case (reg_pipe_sft_amt_s)
            1'b0 : begin
                A0_x_B0_sft_s = A0_x_B0_64_s;
                A1_x_B1_sft_s = A1_x_B1_64_s << 32;
            end
            1'b1 : begin
                A0_x_B0_sft_s = A0_x_B0_64_s << 16;
                A1_x_B1_sft_s = A1_x_B1_64_s << 16;
            end
        endcase
    end

    // assign M0_mux_s = (reg_upper_s) ? A0_x_B0_sft_s[63:32] : A0_x_B0_sft_s[31:0];
    // assign M1_mux_s = (reg_upper_s) ? A1_x_B1_sft_s[63:32] : A1_x_B1_sft_s[31:0];


    // Co_detector_V6 LOW_MULT_CO_inst (
    //     .A_i  ( A0_x_B0_sft_s[31:0] ),
    //     .B_i  ( A1_x_B1_sft_s[31:0] ),
    //     .Co_o ( detect_co_s ) 
    // );

    //assign low_mul_co_s = (reg_upper_s) ? detect_co_s : 1'b0;


    // Adders tree (2 layers + AC adder)
    
    //assign partial_result_1_s = M0_mux_s + M1_mux_s;
    assign partial_result_1_s = A0_x_B0_sft_s + A1_x_B1_sft_s;

    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            reg_pipe_result_s <= 64'h0000000000000000;
            //reg_pipe_co_s   <= 1'b0;
        end
        else if (en_pipe_i) begin
            reg_pipe_result_s <= partial_result_1_s;
            //reg_pipe_co_s   <= low_mul_co_s;
        end
    end

    // Accumulator
    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            AC_s <= 63'h0000000000000000;
        end
        else if (reg_pipe_AC_en_s) begin
            AC_s <= AC_s + reg_pipe_result_s;
        end
    end

    assign result_o = reg_upper_s ? AC_s[63:32] : AC_s[31:0];

endmodule