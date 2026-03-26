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
    input wire       done_i,

    // Outputs
    output wire        done_o,
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


    reg  [32:0] pipe_S2_A0xB0_s;     // PIPELINE REGISTERS
    reg  [32:0] pipe_S2_A1xB1_s;
    reg         pipe_S2_shift_amount_s;
    reg         pipe_S2_pipe_en_s;
    reg         pipe_S2_done_s;
    reg         pipe_S2_AC_en_s;
    

    wire [32:0] A0_x_B0_ext_s [31:0];        // Extends the signal of the A0 x B0 to 64 bits
    wire [32:0] A1_x_B1_ext_s [31:0];        // Extends the signal of the A1 x B1 to 64 bits

    wire [63:0] A0_x_B0_64_s;        // Extends the signal of the A0 x B0 to 64 bits
    wire [63:0] A1_x_B1_64_s;        // Extends the signal of the A1 x B1 to 64 bits


    reg  [63:0] A0_x_B0_sft_s;        // A0 x B0 shifted
    reg  [63:0] A1_x_B1_sft_s;        // A1 x B1 shifted


    reg  [63:0] pipe_S3_result_s;
    reg         reg_pipe_co_s;

    wire [47:0] partial_result_1_s;     // Partial result of multiplicatio to accumulator input
    wire [47:0] acumulated_result_s;


    reg  [47:0] pipe_S3_AC_s;                 // Accumulator value
    reg         pipe_S3_done_s;
    reg         pipe_S3_pipe_en_s;
    reg  [15:0] pipe_S3_answr_low_s;

wire [63:0] final_full_answer_s;
    

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
        else begin
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

    reg pipe_S1_AC_en_s;
    reg pipe_S1_shift_amount_s;
    reg pipe_S1_en_pipe_s;

    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i)begin
            pipe_S1_AC_en_s        <= 1'b0;
            pipe_S1_shift_amount_s <= 1'b0;
            pipe_S1_en_pipe_s      <= 1'b1;
        end
        else if (pipe_S3_pipe_en_s) begin
            pipe_S1_AC_en_s        <= AC_en_i;
            pipe_S1_shift_amount_s <= shift_amount_i;
            pipe_S1_en_pipe_s      <= en_pipe_i;
        end
    end
    
     wire [32:0] temp_mult1, temp_mult2;

    multiplier mult1 (
        .A_i(reg_A_s[15:0]),
        .B_i(reg_B_s[15:0]),
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_pipe_i(pipe_S3_pipe_en_s),
        .sigA_i(1'b0),
        .sigB_i(reg_sigB_s[0]),
    // Outputs
        .writeback_value_o(temp_mult1)
    );

    multiplier mult2 (
        .A_i(reg_A_s[31:16]),
        .B_i(reg_B_s[31:16]),
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_pipe_i(pipe_S3_pipe_en_s),
        .sigA_i(reg_sigA_s),
        .sigB_i(reg_sigB_s[1]),
    // Outputs
        .writeback_value_o(temp_mult2)
    );


    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            pipe_S2_A0xB0_s   <= 32'h0000;
            pipe_S2_A1xB1_s   <= 32'h0000;
            pipe_S2_AC_en_s   <= 1'b0;
            pipe_S2_shift_amount_s <= 1'b0;
            pipe_S2_pipe_en_s <= 1'b1;
            pipe_S2_done_s <= 1'b0;
        end
        else if ( pipe_S3_pipe_en_s ) begin
            pipe_S2_A0xB0_s   <= temp_mult1;
            pipe_S2_A1xB1_s   <= temp_mult2;
            pipe_S2_AC_en_s   <= pipe_S1_AC_en_s;
            pipe_S2_shift_amount_s <= pipe_S1_shift_amount_s;
            pipe_S2_done_s <= done_i;
            pipe_S2_pipe_en_s <= pipe_S1_en_pipe_s;
        end
    end


    // Signal extension of A x B to 64 bits
    assign A0_x_B0_64_s = {{31{pipe_S2_A0xB0_s[32]}}, pipe_S2_A0xB0_s};
    assign A1_x_B1_64_s = {{31{pipe_S2_A1xB1_s[32]}}, pipe_S2_A1xB1_s};

    // SHIFTERS
    always@* begin
        case (pipe_S2_shift_amount_s)
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

     
    assign partial_result_1_s = A0_x_B0_sft_s[63:16] + A1_x_B1_sft_s[63:16];

    assign acumulated_result_s = partial_result_1_s + pipe_S3_AC_s;

    reg [31:0] answer;

    // Accumulator
    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            pipe_S3_AC_s <= 48'h000000000000;
            answer <= 32'h00000000;
        end
        else if (pipe_S2_AC_en_s) begin
            pipe_S3_AC_s <= acumulated_result_s;
            answer <= (reg_upper_s) ? final_full_answer_s[63:32] : final_full_answer_s[31:0];  
        end
    end

    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            pipe_S3_done_s <= 1'b0;
            pipe_S3_pipe_en_s <= 1'b1;
        end
        else if (pipe_S3_pipe_en_s) begin
            pipe_S3_done_s <= pipe_S2_done_s;
            pipe_S3_pipe_en_s <= pipe_S2_pipe_en_s;
        end
    end

    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            pipe_S3_answr_low_s <= 16'h0000; 
        end
        else if (!pipe_S2_shift_amount_s && pipe_S3_pipe_en_s) begin
            pipe_S3_answr_low_s <= A0_x_B0_sft_s[15:0];
        end
    end

    
    //assign final_full_answer_s = {pipe_S3_AC_s, pipe_S3_answr_low_s};
    assign final_full_answer_s = {acumulated_result_s, pipe_S3_answr_low_s};
    

    //assign result_o = reg_upper_s ? final_full_answer_s[63:32] : final_full_answer_s[31:0];
    assign result_o = answer;
    assign done_o = pipe_S3_done_s;

endmodule