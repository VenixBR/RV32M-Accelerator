module multiplier_DP ( 
    
    // Inputs
    input wire        clk_i,
    input wire        rst_i,
    input wire        upper_i,
    input wire        signed_A_i,     // signal extension of operand A
    input wire        signed_B_i,     // signal extension of operand B
    input wire [31:0] op_A_i,
    input wire [31:0] op_B_i,

    // Control Signals
    input wire       init_i,          // enable of register of operand A
    input wire       reg_B_en_i,      // enable of register of operand B
    input wire       AC_en_i,         // enable of result accumulator
    input wire       en_pipe_i,       // enable of pipeline registers
    input wire       rst_AC_i,        // reset to accumulator
    input wire       shift_amount_i,  // shift amount to multiplier results

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

    reg  [32:0] pipe_S2_A0xB0_s;     // PIPELINE REGISTERS
    reg  [32:0] pipe_S2_A1xB1_s;
    
    wire [63:0] A0_x_B0_64_s;        // Extends the signal of the A0 x B0 to 64 bits
    wire [63:0] A1_x_B1_64_s;        // Extends the signal of the A1 x B1 to 64 bits


    reg  [63:0] A0_x_B0_sft_s;        // A0 x B0 shifted
    reg  [63:0] A1_x_B1_sft_s;        // A1 x B1 shifted

    wire [47:0] partial_result_1_s;     // Partial result of multiplicatio to accumulator input
    wire [47:0] acumulated_result_s;


    wire rst_AC_s;
    reg  [47:0] pipe_S3_AC_s;                 // Accumulator value
    reg  [15:0] pipe_S3_answr_low_s;

    wire [63:0] final_full_answer_s;
    







    // Mux, sigB or rol(sigB, 1)
    assign mux_sigB_s = (init_i == 1'b1) ? {signed_B_i, 1'b0} : {reg_sigB_s[0], reg_sigB_s[1]};

    // Mux, opB or rol(opB, 16)
    assign mux_B_s = (init_i == 1'b1) ? op_B_i : {reg_B_s[15:0], reg_B_s[31:16]};

    // Input Registers
    always @(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            reg_A_s           <= 32'h00000000;
            reg_B_s           <= 32'h00000000;
            reg_upper_s       <= 1'b0;
            reg_sigA_s        <= 1'b0;
        end
        else begin
            if (init_i) begin
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
    
    wire [32:0] temp_mult1, temp_mult2;

    multiplier mult1 (
        // Inputs
        .clk_i     ( clk_i         ),
        .rst_i     ( rst_i         ),
        .A_i       ( reg_A_s[15:0] ),
        .B_i       ( reg_B_s[15:0] ),
        .en_pipe_i ( en_pipe_i     ),
        .sigA_i    ( 1'b0          ),
        .sigB_i    ( reg_sigB_s[0] ),
        // Outputs
        .result_o  ( temp_mult1    )
    );

    multiplier mult2 (
        // Inputs
        .clk_i     ( clk_i          ),
        .rst_i     ( rst_i          ),
        .A_i       ( reg_A_s[31:16] ),
        .B_i       ( reg_B_s[31:16] ),
        .en_pipe_i ( en_pipe_i      ),
        .sigA_i    ( reg_sigA_s     ),
        .sigB_i    ( reg_sigB_s[1]  ),
        // Outputs
        .result_o  ( temp_mult2     )
    );


    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            pipe_S2_A0xB0_s   <= 33'h00000;
            pipe_S2_A1xB1_s   <= 33'h00000;
        end
        else if ( en_pipe_i ) begin
            pipe_S2_A0xB0_s   <= temp_mult1;
            pipe_S2_A1xB1_s   <= temp_mult2;
        end
    end


    // Signal extension of A x B to 64 bits
    assign A0_x_B0_64_s = {{31{pipe_S2_A0xB0_s[32]}}, pipe_S2_A0xB0_s};
    assign A1_x_B1_64_s = {{31{pipe_S2_A1xB1_s[32]}}, pipe_S2_A1xB1_s};

    // SHIFTERS
    always@* begin
        case (shift_amount_i)
            1'b1 : begin
                A0_x_B0_sft_s = A0_x_B0_64_s;
                A1_x_B1_sft_s = A1_x_B1_64_s << 32;
            end
            1'b0 : begin
                A0_x_B0_sft_s = A0_x_B0_64_s << 16;
                A1_x_B1_sft_s = A1_x_B1_64_s << 16;
            end
        endcase
    end

     
    assign partial_result_1_s = A0_x_B0_sft_s[63:16] + A1_x_B1_sft_s[63:16];

    assign acumulated_result_s = partial_result_1_s + pipe_S3_AC_s;

    reg pipe_S3_upper_s;


    assign rst_AC_s = rst_i || rst_AC_i;

    // Accumulator [63:16], 48 bits
    always@(posedge clk_i, posedge rst_AC_s) begin
        if (rst_AC_s) begin
            pipe_S3_AC_s    <= 48'h000000000000;
            pipe_S3_upper_s <= 1'b0; 
        end
        else if (AC_en_i) begin
            pipe_S3_AC_s    <= acumulated_result_s;
            pipe_S3_upper_s <= reg_upper_s;
        end
    end

    // Accumulator [15:0], 16  bits
    always@(posedge clk_i, posedge rst_AC_s) begin
        if (rst_AC_s) begin
            pipe_S3_answr_low_s <= 16'h0000; 
        end
        else if (shift_amount_i) begin
            pipe_S3_answr_low_s <= A0_x_B0_sft_s[15:0];
        end
    end

    
    assign final_full_answer_s = {pipe_S3_AC_s, pipe_S3_answr_low_s};
    assign result_o = pipe_S3_upper_s ? final_full_answer_s[63:32] : final_full_answer_s[31:0];

endmodule