module multiplier_CP (
    // INPUTS
    input wire clk_i,
    input wire rst_i,
    input wire mult_en_i,             // Enable of the multiplier
    input wire signed_B_i,            // indicates if it is necessary the signal extension from B

    // OUTPUTS
    output reg       reg_A_en_o,      // enable of register of operand A
    output reg       reg_B_en_o,      // enable of register of operand B
    output reg       AC_en_o,         // enable of result accumulator
    output reg       mux_B_sel_o,     // mux selector of operand B
    output reg [3:0] sig_ctrl_B_o,    // signal extension of operand B
    output reg [2:0] shift_0_o,       // shift amount to multiplier 0
    output reg [2:0] shift_1_o,       // shift amount to multiplier 1
    output reg [2:0] shift_2_o,       // shift amount to multiplier 2
    output reg [2:0] shift_3_o,       // shift amount to multiplier 3
    output reg       rol_en_o,        // left rotate amount to operand B
    output reg       done_o           // indicates when the operation ends
);

    // Stages codification
    localparam INIT   = 3'b000;
    localparam MULT_1 = 3'b001;
    localparam MULT_2 = 3'b011;
    localparam MULT_3 = 3'b010;
    localparam MULT_4 = 3'b110;
    localparam DONE   = 3'b100;

    // SIGNALS 
    reg [2:0] Current_State_s;
    reg [2:0] Next_State_s;


    // NEXT STAGE LOGIC
    always@* begin
        case(Current_State_s)
            INIT    : begin Next_State_s = (mult_en_i) ? MULT_1 : INIT; end
            MULT_1  : begin Next_State_s = MULT_2; end
            MULT_2  : begin Next_State_s = MULT_3; end
            MULT_3  : begin Next_State_s = MULT_4; end
            MULT_4  : begin Next_State_s = DONE;   end
            DONE    : begin Next_State_s = DONE;   end
            default : begin Next_State_s = INIT;   end
        endcase
    end

    // MEMORY LOGIC
    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            Current_State_s <= INIT;
        end
        else if ( mult_en_i ) begin
            Current_State_s <= Next_State_s;
        end
    end


    // OUTPUTS LOGIC
    always@* begin
        case (Current_State_s)
            INIT : begin
                reg_A_en_o   = 1'b1;
                reg_B_en_o   = 1'b1;
                AC_en_o      = 1'b0;
                mux_B_sel_o  = 1'b0;
                sig_ctrl_B_o = 4'b0000;
                shift_0_o    = 3'b000;
                shift_1_o    = 3'b000;
                shift_2_o    = 3'b000;
                shift_3_o    = 3'b000;
                rol_en_o     = 1'b0;
                done_o       = 1'b0;
            end
            MULT_1 : begin
                reg_A_en_o   = 1'b0;
                reg_B_en_o   = 1'b1;
                AC_en_o      = 1'b1;
                sig_ctrl_B_o = {signed_B_i, 3'b000};
                mux_B_sel_o  = 1'b1;
                shift_0_o    = 3'b000;  // 0  = 0*8
                shift_1_o    = 3'b010;  // 16 = 2*8
                shift_2_o    = 3'b100;  // 32 = 4*8
                shift_3_o    = 3'b110;  // 48 = 6*8
                rol_en_o     = 1'b1;
                done_o       = 1'b0;
            end
            MULT_2 : begin
                reg_A_en_o   = 1'b0;
                reg_B_en_o   = 1'b1;
                AC_en_o      = 1'b1;
                sig_ctrl_B_o = {3'b000, signed_B_i};
                mux_B_sel_o  = 1'b1;
                shift_0_o    = 3'b011;  // 24 = 3*8
                shift_1_o    = 3'b001;  // 8  = 1*8
                shift_2_o    = 3'b011;  // 24 = 3*8
                shift_3_o    = 3'b101;  // 40 = 5*8
                rol_en_o     = 1'b1;
                done_o       = 1'b0;
            end
            MULT_3 : begin
                reg_A_en_o   = 1'b0;
                reg_B_en_o   = 1'b1;
                AC_en_o      = 1'b1;
                sig_ctrl_B_o = {2'b00, signed_B_i, 1'b0};
                mux_B_sel_o  = 1'b1;
                shift_0_o    = 3'b010;  // 16 = 2*8
                shift_1_o    = 3'b100;  // 32 = 4*8
                shift_2_o    = 3'b010;  // 16 = 2*8
                shift_3_o    = 3'b100;  // 32 = 4*8
                rol_en_o     = 1'b1;
                done_o       = 1'b0;
            end
            MULT_4 : begin
                reg_A_en_o   = 1'b0;
                reg_B_en_o   = 1'b1;
                AC_en_o      = 1'b1;
                sig_ctrl_B_o = {1'b0, signed_B_i, 2'b00};
                mux_B_sel_o  = 1'b1;
                shift_0_o    = 3'b001;  // 8  = 1*8
                shift_1_o    = 3'b011;  // 24 = 3*8 
                shift_2_o    = 3'b101;  // 40 = 5*8
                shift_3_o    = 3'b011;  // 24 = 3*8
                rol_en_o     = 1'b1;
                done_o       = 1'b0;
            end
            DONE : begin
                reg_A_en_o   = 1'b0;
                reg_B_en_o   = 1'b0;
                AC_en_o      = 1'b0;
                sig_ctrl_B_o = 4'b0000;
                mux_B_sel_o  = 1'b0;
                shift_0_o    = 3'b000;
                shift_1_o    = 3'b000;
                shift_2_o    = 3'b000;
                shift_3_o    = 3'b000;
                rol_en_o     = 1'b0;
                done_o       = 1'b1;
            end
            default : begin
                reg_A_en_o   = 1'b0;
                reg_B_en_o   = 1'b0;
                AC_en_o      = 1'b0;
                sig_ctrl_B_o = 4'b0000;
                mux_B_sel_o  = 1'b0;
                shift_0_o    = 3'b000;
                shift_1_o    = 3'b000;
                shift_2_o    = 3'b000;
                shift_3_o    = 3'b000;
                rol_en_o     = 1'b0;
                done_o       = 1'b0;
            end
        endcase
    end


endmodule