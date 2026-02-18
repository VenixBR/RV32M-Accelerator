module multiplier_DP_V6 ( 
    
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
    input wire       rol_en_i,        // left rotate amount to operand B

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
    wire [31:0] rotated_mux_B_s;      // Output of left rotate to register B input
    wire [3:0]  mux_sigB_s;           // Output of mux to sigB reg
    
                                      // reg B value is divided in 2 parts: B1 B0
    wire [15:0] B0_s;                  // B0 <- regB [7:0]
    wire [15:0] B1_s;                  // B1 <- regB [15:8]

    wire [31:0] B0_ext_s;             // signal extension to 16 bits of B0 
    wire [31:0] B1_ext_s;             // signal extension to 16 bits of B1

    wire [31:0] A0_ext_s;             // signal extension to 16 bits of A0
    wire [31:0] A1_ext_s;             // signal extension to 16 bits of A1



    wire [7:0] A0_8b_s [7:0];
    wire [7:0] A1_8b_s [7:0];
    wire [7:0] B0_8b_s [7:0];
    wire [7:0] B1_8b_s [7:0];

    wire [7:0] A0xB0_8b_s [35:0];
    wire [7:0] A1xB1_8b_s [35:0];

    wire [31:0] sft_mult0_s [35:0];
    wire [31:0] sft_mult1_s [35:0];

    wire [31:0] mult_result0_s;
    wire [31:0] mult_result1_s;




    reg  [31:0] reg_pipe_A0xB0_s;     // PIPELINE REGISTERS
    reg  [31:0] reg_pipe_A1xB1_s;
    reg         reg_pipe_sft_amt_s;
    reg         reg_pipe_AC_en_s;
    

    wire [63:0] A0_x_B0_ext_s;        // Extends the signal of the A0 x B0 to 64 bits
    wire [63:0] A1_x_B1_ext_s;        // Extends the signal of the A1 x B1 to 64 bits


    reg  [63:0] A0_x_B0_sft_s;        // A0 x B0 shifted
    reg  [63:0] A1_x_B1_sft_s;        // A1 x B1 shifted

    wire [31:0] M0_mux_s;
    wire [31:0] M1_mux_s;

    wire        detect_co_s;
    wire        low_mul_co_s;

    reg  [31:0] reg_pipe_result_s;
    reg         reg_pipe_co_s;

    wire [31:0] partial_result_1_s;     // Partial result of multiplicatio to accumulator input
    wire [31:0] partial_result_2_s;     // Partial result of multiplicatio to accumulator input
    wire [31:0] partial_result_3_s;     // Partial result of multiplicatio to accumulator input

    wire [31:0] sum_s;
    wire [1:0] carries_s;
    reg  [31:0] AC_s;                 // Accumulator value

    

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
                reg_B_s           <= rotated_mux_B_s;
                reg_sigB_s        <= mux_sigB_s; 
            end
        end
    end

    assign mux_sigB_s = (reg_A_en_i == 1'b1) ? {signed_B_i, 1'b0} : {reg_sigB_s[0], reg_sigB_s[1]};

    // Mux between B input and reg B value
    assign mux_B_s = (mux_B_sel_i == 1'b0) ? op_B_i : reg_B_s;

    // Left rotate to mux_B_s per multiples of 16
    assign rotated_mux_B_s = (rol_en_i == 1'b1) ? {mux_B_s[15:0], mux_B_s[31:16]} : mux_B_s;

    // Divide reg B value in 2 parts
    assign B0_s = reg_B_s[15:0];
    assign B1_s = reg_B_s[31:16];


    // Signal extension to reg A value. The 4 parts are constant.
    assign A0_ext_s = {8'b00000000 ,reg_A_s[15:0]};
    assign A1_ext_s = (reg_sigA_s==1'b1) ? {{{16{reg_A_s[31]}}}, reg_A_s[31:16]} : {16'h0000 ,reg_A_s[31:16]};

    // Signal extension to reg B value. Are variable because B is rotated.
    assign B0_ext_s = (reg_sigB_s[0]==1'b1) ? {{{16{B0_s[15]}}}, B0_s} : {16'h0000 ,B0_s};
    assign B1_ext_s = (reg_sigB_s[1]==1'b1) ? {{{16{B1_s[15]}}}, B1_s} : {16'b0000 ,B1_s};



    


    /*===============================
             8(A_4b) x 8(B_4b)
    ===============================*/

    genvar k;
    generate
        for (k=0 ; k<8 ; k=k+1) begin
            assign A0_8b_s[k] = {4'b0000, A0_ext_s[(k*4+3): k*4]};
            assign A1_8b_s[k] = {4'b0000, A1_ext_s[(k*4+3): k*4]};
            assign B0_8b_s[k] = {4'b0000, B0_ext_s[(k*4+3): k*4]};
            assign B1_8b_s[k] = {4'b0000, B1_ext_s[(k*4+3): k*4]};
        end
    endgenerate

    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : loopA
            for (j=0; j < (8-i); j=j+1) begin : loopB
                assign A0xB0_8b_s[(i*8) - (i*(i-1))/2 + j] = A0_8b_s[i] * B0_8b_s[j];
                assign A1xB1_8b_s[(i*8) - (i*(i-1))/2 + j] = A1_8b_s[i] * B1_8b_s[j];
            end
        end
    endgenerate





    assign mult_result0_s = {A0xB0_8b_s[6] , A0xB0_8b_s[4], A0xB0_8b_s[2], A0xB0_8b_s[0]}         +
                            {A0xB0_8b_s[7] , A0xB0_8b_s[5], A0xB0_8b_s[3], A0xB0_8b_s[1], 4'h0}   +
                            {A0xB0_8b_s[14], A0xB0_8b_s[12], A0xB0_8b_s[10], A0xB0_8b_s[8], 4'h0} + 
                            {A0xB0_8b_s[13], A0xB0_8b_s[11], A0xB0_8b_s[9] , 8'h00}               +
                            {A0xB0_8b_s[19], A0xB0_8b_s[17], A0xB0_8b_s[15], 8'h00}               +
                            {A0xB0_8b_s[20], A0xB0_8b_s[18], A0xB0_8b_s[16], 12'h000}             + 
                            {A0xB0_8b_s[25], A0xB0_8b_s[23], A0xB0_8b_s[21], 12'h000}             +
                            {A0xB0_8b_s[24], A0xB0_8b_s[22], 16'h0000}                            +
                            {A0xB0_8b_s[28], A0xB0_8b_s[26], 16'h0000}                            +
                            {A0xB0_8b_s[29], A0xB0_8b_s[27], 20'h00000}                           +
                            {A0xB0_8b_s[32], A0xB0_8b_s[30], 20'h00000}                           +
                            {A0xB0_8b_s[31], 24'h000000}                                          +
                            {A0xB0_8b_s[33], 24'h000000}                                          +
                            {A0xB0_8b_s[34][3:0], 28'h0000000}                                   +
                            {A0xB0_8b_s[35][3:0], 28'h0000000};

    assign mult_result1_s = {A1xB1_8b_s[6] , A1xB1_8b_s[4], A1xB1_8b_s[2], A1xB1_8b_s[0]}         +
                            {A1xB1_8b_s[7] , A1xB1_8b_s[5], A1xB1_8b_s[3], A1xB1_8b_s[1], 4'h0}   +
                            {A1xB1_8b_s[14], A1xB1_8b_s[12], A1xB1_8b_s[10], A1xB1_8b_s[8], 4'h0} + 
                            {A1xB1_8b_s[13], A1xB1_8b_s[11], A1xB1_8b_s[9] , 8'h00}               +
                            {A1xB1_8b_s[19], A1xB1_8b_s[17], A1xB1_8b_s[15], 8'h00}               +
                            {A1xB1_8b_s[20], A1xB1_8b_s[18], A1xB1_8b_s[16], 12'h000}             + 
                            {A1xB1_8b_s[25], A1xB1_8b_s[23], A1xB1_8b_s[21], 12'h000}             +
                            {A1xB1_8b_s[24], A1xB1_8b_s[22], 16'h0000}                            +
                            {A1xB1_8b_s[28], A1xB1_8b_s[26], 16'h0000}                            +
                            {A1xB1_8b_s[29], A1xB1_8b_s[27], 20'h00000}                           +
                            {A1xB1_8b_s[32], A1xB1_8b_s[30], 20'h00000}                           +
                            {A1xB1_8b_s[31], 24'h000000}                                          +
                            {A1xB1_8b_s[33], 24'h000000}                                          +
                            {A1xB1_8b_s[34][3:0], 28'h0000000}                                   +
                            {A1xB1_8b_s[35][3:0], 28'h0000000};




    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            reg_pipe_A0xB0_s   <= 32'h0000;
            reg_pipe_A1xB1_s   <= 32'h0000;
            reg_pipe_AC_en_s   <= 1'b0;
            reg_pipe_sft_amt_s <= 1'b0;
        end
        else if ( en_pipe_i ) begin
            reg_pipe_A0xB0_s   <= mult_result0_s;
            reg_pipe_A1xB1_s   <= mult_result1_s;
            reg_pipe_AC_en_s   <= AC_en_i;
            reg_pipe_sft_amt_s <= shift_amount_i;
        end
    end


    // Signal extension of A x B to 64 bits
    assign A0_x_B0_ext_s = {{32{reg_pipe_A0xB0_s[31]}}, reg_pipe_A0xB0_s};
    assign A1_x_B1_ext_s = {{32{reg_pipe_A1xB1_s[31]}}, reg_pipe_A1xB1_s};

    // SHIFTERS
    always@* begin
        case (reg_pipe_sft_amt_s)
            1'b0 : begin
                A0_x_B0_sft_s = A0_x_B0_ext_s;
                A1_x_B1_sft_s = A1_x_B1_ext_s << 32;
            end
            1'b1 : begin
                A0_x_B0_sft_s = A0_x_B0_ext_s << 16;
                A1_x_B1_sft_s = A1_x_B1_ext_s << 16;
            end
        endcase
    end

    assign M0_mux_s = (reg_upper_s) ? A0_x_B0_sft_s[63:32] : A0_x_B0_sft_s[31:0];
    assign M1_mux_s = (reg_upper_s) ? A1_x_B1_sft_s[63:32] : A1_x_B1_sft_s[31:0];


    Co_detector_V6 LOW_MULT_CO_inst (
        .A_i  ( A0_x_B0_sft_s[31:0] ),
        .B_i  ( A1_x_B1_sft_s[31:0] ),
        .Co_o ( detect_co_s ) 
    );

    assign low_mul_co_s = (reg_upper_s) ? detect_co_s : 1'b0;


    // Adders tree (2 layers + AC adder)
    assign partial_result_1_s = M0_mux_s + M1_mux_s;

    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            reg_pipe_result_s <= 32'h00000000;
            reg_pipe_co_s   <= 1'b0;
        end
        else if (en_pipe_i) begin
            reg_pipe_result_s <= partial_result_1_s;
            reg_pipe_co_s   <= low_mul_co_s;
        end
    end

    // Accumulator
    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            AC_s <= 32'h00000000;
        end
        else if (reg_pipe_AC_en_s) begin
            AC_s <= AC_s + reg_pipe_result_s + reg_pipe_co_s;
        end
    end

    assign result_o = AC_s;

endmodule