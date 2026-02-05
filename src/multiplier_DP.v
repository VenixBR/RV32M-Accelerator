module multiplier_DP ( 
    
    // Inputs
    input wire clk_i,
    input wire rst_i,
    input wire upper_i,
    input wire [31:0] op_A_i,
    input wire [31:0] op_B_i,

    // Control Signals
    input wire       reg_A_en_i,      // enable of register of operand A
    input wire       reg_B_en_i,      // enable of register of operand B
    input wire       AC_en_i,         // enable of result accumulator
    input wire       mux_B_sel_i,     // mux selector of operand B
    input wire       signed_A_i,      // signal extension of operand A
    input wire [3:0] sig_ctrl_B_i,    // signal extension of operand B
    input wire [2:0] shift_0_i,       // shift amount to multiplier 0
    input wire [2:0] shift_1_i,       // shift amount to multiplier 1
    input wire [2:0] shift_2_i,       // shift amount to multiplier 2
    input wire [2:0] shift_3_i,       // shift amount to multiplier 3
    input wire       rol_en_i,        // left rotate amount to operand B

    // Outputs
    output wire [31:0] result_o
);

    // SIGNALS
    reg  [31:0] reg_A_s;              // Input register to operand A
    reg  [31:0] reg_B_s;              // Input register to operand B
    wire [31:0] mux_B_s;              // Output of mux to left rotate input
    wire [31:0] rotated_mux_B_s;      // Output of left rotate to register B input
    
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

    wire [63:0] A0_x_B0_ext_s;        // Extends the signal of the A0 x B0 to 64 bits
    wire [63:0] A1_x_B1_ext_s;        // Extends the signal of the A1 x B1 to 64 bits
    wire [63:0] A2_x_B2_ext_s;        // Extends the signal of the A2 x B2 to 64 bits
    wire [63:0] A3_x_B3_ext_s;        // Extends the signal of the A3 x B3 to 64 bits

    reg  [63:0] A0_x_B0_sft_s;        // A0 x B0 shifted
    reg  [63:0] A1_x_B1_sft_s;        // A1 x B1 shifted
    reg  [63:0] A2_x_B2_sft_s;        // A2 x B2 shifted
    reg  [63:0] A3_x_B3_sft_s;        // A3 x B3 shifted

    wire [63:0] partial_result_s;     // Partial result of multiplicatio to accumulator input

    reg  [63:0] AC_s;                 // Accumulator value

    

    // Input Registers
    always @(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            reg_A_s <= 32'h00000000;
            reg_B_s <= 32'h00000000;
        end
        else if (clk_i) begin
            if (reg_A_en_i)
                reg_A_s <= op_A_i;
            
            if (reg_B_en_i)
                reg_B_s <= rotated_mux_B_s;
        end
    end

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
    assign A3_ext_s = (signed_A_i==1'b1) ? {{{8{reg_A_s[31]}}}, reg_A_s[31:24]} : {8'b00000000 ,reg_A_s[31:24]};

    // Signal extension to reg B value. Are variable because B is rotated.
    assign B0_ext_s = (sig_ctrl_B_i[0]==1'b1) ? {{{8{B0_s[7]}}}, B0_s} : {8'b00000000 ,B0_s};
    assign B1_ext_s = (sig_ctrl_B_i[1]==1'b1) ? {{{8{B1_s[7]}}}, B1_s} : {8'b00000000 ,B1_s};
    assign B2_ext_s = (sig_ctrl_B_i[2]==1'b1) ? {{{8{B2_s[7]}}}, B2_s} : {8'b00000000 ,B2_s};
    assign B3_ext_s = (sig_ctrl_B_i[3]==1'b1) ? {{{8{B3_s[7]}}}, B3_s} : {8'b00000000 ,B3_s};

    // Multiply the 4 tiny parts (16 bits) of original number.
    assign A0_x_B0_s = A0_ext_s * B0_ext_s;
    assign A1_x_B1_s = A1_ext_s * B1_ext_s;
    assign A2_x_B2_s = A2_ext_s * B2_ext_s;
    assign A3_x_B3_s = A3_ext_s * B3_ext_s;

    // PIPELINE STAGE HERE ( FOUR 16 BITS REGISTERS : 64 BITS )

    // Signal extension of A x B to 64 bits
    assign A0_x_B0_ext_s = {{48{A0_x_B0_s[15]}}, A0_x_B0_s};
    assign A1_x_B1_ext_s = {{48{A1_x_B1_s[15]}}, A1_x_B1_s};
    assign A2_x_B2_ext_s = {{48{A2_x_B2_s[15]}}, A2_x_B2_s};
    assign A3_x_B3_ext_s = {{48{A3_x_B3_s[15]}}, A3_x_B3_s};

    // SHIFTERS
    always@* begin
        // shifter to A0 x B0
        case (shift_0_i)
            3'b000  : begin A0_x_B0_sft_s = A0_x_B0_ext_s;       end       // 0*8
            3'b011  : begin A0_x_B0_sft_s = A0_x_B0_ext_s << 24; end // 3*8
            3'b010  : begin A0_x_B0_sft_s = A0_x_B0_ext_s << 16; end // 2*8
            3'b001  : begin A0_x_B0_sft_s = A0_x_B0_ext_s << 8;  end  // 1*8
            default : begin A0_x_B0_sft_s = A0_x_B0_ext_s;       end
        endcase

        // shifter to A1 x B1
        case (shift_1_i)
            3'b010  : begin A1_x_B1_sft_s = A1_x_B1_ext_s << 16; end // 2*8
            3'b001  : begin A1_x_B1_sft_s = A1_x_B1_ext_s << 8;  end // 1*8
            3'b100  : begin A1_x_B1_sft_s = A1_x_B1_ext_s << 32; end // 4*8
            3'b011  : begin A1_x_B1_sft_s = A1_x_B1_ext_s << 24; end // 3*8
            default : begin A1_x_B1_sft_s = A1_x_B1_ext_s << 16; end
        endcase

        // shifter to A2 x B2
        case (shift_2_i)
            3'b100  : begin A2_x_B2_sft_s = A2_x_B2_ext_s << 32; end // 4*8
            3'b011  : begin A2_x_B2_sft_s = A2_x_B2_ext_s << 24; end // 3*8
            3'b010  : begin A2_x_B2_sft_s = A2_x_B2_ext_s << 16; end // 2*8
            3'b101  : begin A2_x_B2_sft_s = A2_x_B2_ext_s << 40; end // 5*8
            default : begin A2_x_B2_sft_s = A2_x_B2_ext_s << 32; end
        endcase

        // shifter to A3 x B3
        case (shift_3_i)
            3'b110  : begin A3_x_B3_sft_s = A3_x_B3_ext_s << 48; end // 6*8
            3'b101  : begin A3_x_B3_sft_s = A3_x_B3_ext_s << 40; end // 5*8
            3'b100  : begin A3_x_B3_sft_s = A3_x_B3_ext_s << 32; end // 4*8
            3'b011  : begin A3_x_B3_sft_s = A3_x_B3_ext_s << 24; end // 3*8
            default : begin A3_x_B3_sft_s = A3_x_B3_ext_s << 48; end
        endcase
    end

    // Adders tree (2 layers + AC adder)
    assign partial_result_s = A0_x_B0_sft_s + A1_x_B1_sft_s + A2_x_B2_sft_s + A3_x_B3_sft_s;

    // Accumulator
    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            AC_s <= 64'h0000000000000000;
        end
        else if (AC_en_i) begin
            AC_s <= AC_s + partial_result_s;
        end
    end

    // Result MUX
    assign result_o = (upper_i==1'b1) ? AC_s[63:32] : AC_s[31:0];

endmodule