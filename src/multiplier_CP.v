module multiplier_CP (
    // INPUTS
    input wire clk_i,
    input wire rst_i,
    input wire mult_en_i,             // Enable of the multiplier

    // OUTPUTS
    output reg       init_o,      // enable of register of operand A
    output reg       reg_B_en_o,      // enable of register of operand B
    output reg       AC_en_o,         // enable of result accumulator
    output reg       en_pipe_o,       // enable of pipeline registers
    output reg       shift_amount_o,  // shift amount to multiplier results
    output reg       rst_AC_o,
    output reg       done_o           // indicates when the operation ends
);

    // Stages codification
    localparam INIT   = 3'b000;
    localparam MULT_1 = 3'b001;
    localparam MULT_2 = 3'b011;
    localparam WAIT   = 3'b010;
    localparam DONE   = 3'b110;

    // SIGNALS 
    reg [2:0] Current_State_s;
    reg [2:0] Next_State_s;


    // NEXT STAGE LOGIC
    always@* begin
        case(Current_State_s)
            INIT    : begin Next_State_s = (mult_en_i) ? MULT_1 : INIT; end
            MULT_1  : begin Next_State_s = MULT_2; end
            MULT_2  : begin Next_State_s = WAIT; end
            WAIT    : begin Next_State_s = DONE; end
            DONE    : begin Next_State_s = INIT; end
        endcase
    end

    // MEMORY LOGIC
    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            Current_State_s <= INIT;
        end
        else begin
            Current_State_s <= Next_State_s;
        end
    end


    // OUTPUTS LOGIC
    always@* begin
        case (Current_State_s)
            INIT : begin
                init_o         = 1'b1;
                reg_B_en_o     = 1'b1;
                en_pipe_o      = 1'b0;
                shift_amount_o = 1'b0;
                AC_en_o        = 1'b0;
                rst_AC_o       = 1'b0;
                done_o         = 1'b1;
            end
            MULT_1 : begin
                init_o         = 1'b0;
                reg_B_en_o     = 1'b1;
                en_pipe_o      = 1'b1;
                shift_amount_o = 1'b0;
                AC_en_o        = 1'b0;
                rst_AC_o       = 1'b1;
                done_o         = 1'b0;
            end
            MULT_2 : begin
                init_o         = 1'b0;
                reg_B_en_o     = 1'b1;
                en_pipe_o      = 1'b1;
                shift_amount_o = 1'b0;
                AC_en_o        = 1'b0;
                rst_AC_o       = 1'b0;
                done_o         = 1'b0;
            end
            WAIT : begin
                init_o         = 1'b0;
                reg_B_en_o     = 1'b0;
                en_pipe_o      = 1'b1;
                shift_amount_o = 1'b1;
                AC_en_o        = 1'b1;
                rst_AC_o       = 1'b0;
                done_o         = 1'b0;
            end
            DONE : begin
                init_o         = 1'b0;
                reg_B_en_o     = 1'b0;
                en_pipe_o      = 1'b1;
                shift_amount_o = 1'b0;
                AC_en_o        = 1'b1;
                rst_AC_o       = 1'b0;
                done_o         = 1'b0;
            end
            default : begin
                init_o         = 1'b0;
                reg_B_en_o     = 1'b0;
                en_pipe_o      = 1'b0;
                shift_amount_o = 1'b0;
                AC_en_o        = 1'b0;
                rst_AC_o       = 1'b0;
                done_o         = 1'b0;
            end
        endcase
    end

endmodule