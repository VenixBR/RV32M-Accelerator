module multiplier_DP_V3 ( 
    
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
    input wire [1:0] shift_amount_i,  // shift amount to multiplier results
    input wire       rol_en_i,        // left rotate amount to operand B

    // Outputs
    output wire [31:0] result_o
);

    // SIGNALS
    reg  [31:0] reg_A_s;              // Input register to operand A
    reg  [31:0] reg_B_s;              // Input register to operand B
    reg         reg_upper_s;          // Input register to signal upper_i
    reg         reg_sigA_s;           // Input register to signal signed_A_i
    reg  [3:0]  reg_sigB_s;           // Input register to signal signed_B_i

    wire [31:0] mux_B_s;              // Output of mux to left rotate input
    wire [31:0] rotated_mux_B_s;      // Output of left rotate to register B input
    wire [3:0]  mux_sigB_s;           // Output of mux to sigB reg
    
                                      // reg B value is divided in 4 parts: B3 B2 B1 B0
    wire [7:0] B0_s;                  // B0 <- regB [7:0]
    wire [7:0] B1_s;                  // B1 <- regB [15:8]
    wire [7:0] B2_s;                  // B2 <- regB [23:16]
    wire [7:0] B3_s;                  // B3 <- regB [31:24]

    wire [15:0] B0_ext_s;             // signal extension to 16 bits of B0 
    wire [15:0] B1_ext_s;             // signal extension to 16 bits of B1
    wire [15:0] B2_ext_s;             // signal extension to 16 bits of B2
    wire [15:0] B3_ext_s;             // signal extension to 16 bits of B3

    wire [15:0] A0_ext_s;             // signal extension to 16 bits of A0
    wire [15:0] A1_ext_s;             // signal extension to 16 bits of A1
    wire [15:0] A2_ext_s;             // signal extension to 16 bits of A2
    wire [15:0] A3_ext_s;             // signal extension to 16 bits of A3

    wire [15:0] A0_x_B0_s;            // Store A0 times current B0, after your left rotate
    wire [15:0] A1_x_B1_s;            // Store A1 times current B1, after your left rotate
    wire [15:0] A2_x_B2_s;            // Store A2 times current B2, after your left rotate
    wire [15:0] A3_x_B3_s;            // Store A3 times current B3, after your left rotate

    reg  [15:0] reg_pipe_A0xB0_s;     // PIPELINE REGISTERS
    reg  [15:0] reg_pipe_A1xB1_s;
    reg  [15:0] reg_pipe_A2xB2_s;
    reg  [15:0] reg_pipe_A3xB3_s;
    reg  [1:0]  reg_pipe_sft_amt_s;
    reg         reg_pipe_AC_en_s;
    


    wire [63:0] A0_x_B0_ext_s;        // Extends the signal of the A0 x B0 to 64 bits
    wire [63:0] A1_x_B1_ext_s;        // Extends the signal of the A1 x B1 to 64 bits
    wire [63:0] A2_x_B2_ext_s;        // Extends the signal of the A2 x B2 to 64 bits
    wire [63:0] A3_x_B3_ext_s;        // Extends the signal of the A3 x B3 to 64 bits

    reg  [63:0] A0_x_B0_sft_s;        // A0 x B0 shifted
    reg  [63:0] A1_x_B1_sft_s;        // A1 x B1 shifted
    reg  [63:0] A2_x_B2_sft_s;        // A2 x B2 shifted
    reg  [63:0] A3_x_B3_sft_s;        // A3 x B3 shifted

    wire [31:0] M0_mux_s;
    wire [31:0] M1_mux_s;
    wire [31:0] M2_mux_s;
    wire [31:0] M3_mux_s;

    wire [33:0] low_mul_res_1_s;  
    wire [33:0] low_mul_res_2_s;  
    wire [33:0] low_mul_res_3_s;  
    wire [1:0]  low_mul_co_s;


    wire [31:0] partial_result_1_s;     // Partial result of multiplicatio to accumulator input
    wire [31:0] partial_result_2_s;     // Partial result of multiplicatio to accumulator input
    wire [31:0] partial_result_3_s;     // Partial result of multiplicatio to accumulator input
    wire [31:0] partial_result_4_s;     // Partial result of multiplicatio to accumulator input

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

    assign mux_sigB_s = (reg_A_en_i == 1'b1) ? {signed_B_i, 3'b000} : {reg_sigB_s[2:0], reg_sigB_s[3]};

    // Mux between B input and reg B value
    assign mux_B_s = (mux_B_sel_i == 1'b0) ? op_B_i : reg_B_s;

    // Left rotate to mux_B_s per multiples of 8
    assign rotated_mux_B_s = (rol_en_i == 1'b1) ? {mux_B_s[23:0], mux_B_s[31:24]} : mux_B_s;

    // Divide reg B value in 4 parts
    assign B0_s = reg_B_s[7:0];
    assign B1_s = reg_B_s[15:8];
    assign B2_s = reg_B_s[23:16];
    assign B3_s = reg_B_s[31:24];

    // Signal extension to reg A value. The 4 parts are constant.
    assign A0_ext_s = {8'b00000000 ,reg_A_s[7:0]};
    assign A1_ext_s = {8'b00000000 ,reg_A_s[15:8]};
    assign A2_ext_s = {8'b00000000 ,reg_A_s[23:16]};
    assign A3_ext_s = (reg_sigA_s==1'b1) ? {{{8{reg_A_s[31]}}}, reg_A_s[31:24]} : {8'b00000000 ,reg_A_s[31:24]};

    // Signal extension to reg B value. Are variable because B is rotated.
    assign B0_ext_s = (reg_sigB_s[0]==1'b1) ? {{{8{B0_s[7]}}}, B0_s} : {8'b00000000 ,B0_s};
    assign B1_ext_s = (reg_sigB_s[1]==1'b1) ? {{{8{B1_s[7]}}}, B1_s} : {8'b00000000 ,B1_s};
    assign B2_ext_s = (reg_sigB_s[2]==1'b1) ? {{{8{B2_s[7]}}}, B2_s} : {8'b00000000 ,B2_s};
    assign B3_ext_s = (reg_sigB_s[3]==1'b1) ? {{{8{B3_s[7]}}}, B3_s} : {8'b00000000 ,B3_s};

    // Multiply the 4 tiny parts (16 bits) of original number.
    assign A0_x_B0_s = A0_ext_s * B0_ext_s;
    assign A1_x_B1_s = A1_ext_s * B1_ext_s;
    assign A2_x_B2_s = A2_ext_s * B2_ext_s;
    assign A3_x_B3_s = A3_ext_s * B3_ext_s;


    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            reg_pipe_A0xB0_s   <= 16'h0000;
            reg_pipe_A1xB1_s   <= 16'h0000;
            reg_pipe_A2xB2_s   <= 16'h0000;
            reg_pipe_A3xB3_s   <= 16'h0000;
            reg_pipe_AC_en_s   <= 1'b0;
            reg_pipe_sft_amt_s <= 2'b00;
        end
        else if ( en_pipe_i ) begin
            reg_pipe_A0xB0_s   <= A0_x_B0_s;
            reg_pipe_A1xB1_s   <= A1_x_B1_s;
            reg_pipe_A2xB2_s   <= A2_x_B2_s;
            reg_pipe_A3xB3_s   <= A3_x_B3_s;
            reg_pipe_AC_en_s   <= AC_en_i;
            reg_pipe_sft_amt_s <= shift_amount_i;
        end
    end


    // Signal extension of A x B to 64 bits
    assign A0_x_B0_ext_s = {{48{reg_pipe_A0xB0_s[15]}}, reg_pipe_A0xB0_s};
    assign A1_x_B1_ext_s = {{48{reg_pipe_A1xB1_s[15]}}, reg_pipe_A1xB1_s};
    assign A2_x_B2_ext_s = {{48{reg_pipe_A2xB2_s[15]}}, reg_pipe_A2xB2_s};
    assign A3_x_B3_ext_s = {{48{reg_pipe_A3xB3_s[15]}}, reg_pipe_A3xB3_s};

    // SHIFTERS
    always@* begin
        case (reg_pipe_sft_amt_s)
            2'b00 : begin
                A0_x_B0_sft_s = A0_x_B0_ext_s;
                A1_x_B1_sft_s = A1_x_B1_ext_s << 16;
                A2_x_B2_sft_s = A2_x_B2_ext_s << 32;
                A3_x_B3_sft_s = A3_x_B3_ext_s << 48;
            end
            2'b01 : begin
                A0_x_B0_sft_s = A0_x_B0_ext_s << 24;
                A1_x_B1_sft_s = A1_x_B1_ext_s << 8;
                A2_x_B2_sft_s = A2_x_B2_ext_s << 24;
                A3_x_B3_sft_s = A3_x_B3_ext_s << 40;
            end
            2'b11 : begin
                A0_x_B0_sft_s = A0_x_B0_ext_s << 16;
                A1_x_B1_sft_s = A1_x_B1_ext_s << 32;
                A2_x_B2_sft_s = A2_x_B2_ext_s << 16;
                A3_x_B3_sft_s = A3_x_B3_ext_s << 32;
            end
            2'b10 : begin
                A0_x_B0_sft_s = A0_x_B0_ext_s << 8;
                A1_x_B1_sft_s = A1_x_B1_ext_s << 24;
                A2_x_B2_sft_s = A2_x_B2_ext_s << 40;
                A3_x_B3_sft_s = A3_x_B3_ext_s << 24;
            end
        endcase
    end

    assign M0_mux_s = (reg_upper_s) ? A0_x_B0_sft_s[63:32] : A0_x_B0_sft_s[31:0];
    assign M1_mux_s = (reg_upper_s) ? A1_x_B1_sft_s[63:32] : A1_x_B1_sft_s[31:0];
    assign M2_mux_s = (reg_upper_s) ? A2_x_B2_sft_s[63:32] : A2_x_B2_sft_s[31:0];
    assign M3_mux_s = (reg_upper_s) ? A3_x_B3_sft_s[63:32] : A3_x_B3_sft_s[31:0];

    assign low_mul_res_1_s = {2'b00, A3_x_B3_sft_s[31:0]} + {2'b00, A2_x_B2_sft_s[31:0]} + {2'b00, A1_x_B1_sft_s[31:0]} + {2'b00, A0_x_B0_sft_s[31:0]};

    assign low_mul_co_s = (reg_upper_s) ? low_mul_res_1_s[33:32] : 2'b00;


    // Adders tree (2 layers + AC adder)
    assign partial_result_1_s = M0_mux_s + M1_mux_s + M2_mux_s + M3_mux_s + low_mul_co_s;



    // Accumulator
    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            AC_s <= 32'h00000000;
        end
        else if (reg_pipe_AC_en_s) begin
            AC_s <= AC_s + partial_result_1_s;
        end
    end

    assign result_o = AC_s;

endmodule