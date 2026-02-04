module multiplier_DP ( 
    
    // Inputs
    input wire clk_i,
    input wire rst_i,
    input wire [31:0] op_A_i,
    input wire [31:0] op_B_i,

    // Control Signals
    input wire       reg_A_en_i,      // enable of register of operand A
    input wire       reg_B_en_i,      // enable of register of operand B
    input wire       AC_en_i,         // enable of result accumulator
    input wire       mux_B_sel_i,     // mux selector of operand B
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
    assign A3_ext_s = (signed_A_i==1'b1) ? {{{8{reg_A_s[7:0][31]}}}, reg_A_s[31:24]} : {8'b00000000 ,reg_A_s[31:24]};

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


endmodule