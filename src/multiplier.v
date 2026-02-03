module multiplier ( 
    
    // Inputs
    input wire clk_i,
    input wire rst_i,
    input wire [31:0] op_A_i,
    input wire [31:0] op_B_i,
    input wire ext_A_i,
    input wire ext_B_i,
    input wire upper_i,

    // Outputs
    output wire [31:0] result_o,
    output done_o
);

    localparam INIT   = 3'b000;
    localparam MULT_1 = 3'b001;
    localparam MULT_2 = 3'b011;
    localparam MULT_3 = 3'b010;
    localparam MULT_4 = 3'b110;
    localparam DONE   = 3'b100;

    reg reg_A_en_s;
    reg reg_B_en_s;
    reg AC_en_s;
    reg mux_B_sel_s;
    reg [2:0] shift_0_s;
    reg [2:0] shift_1_s;
    reg [2:0] shift_2_s;
    reg [2:0] shift_3_s;
    reg [1:0] rol_amount_s;
    reg [2:0] current_state_s;
    reg [2:0] next_state_s;


    // CONTROL PATH
    always @(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            reg_A_en_s   <= 1'b0;
            reg_B_en_s   <= 1'b0;
            AC_en_s      <= 1'b0;
            mux_B_sel_s  <= 1'b0;
            shift_0_s    <= 3'b000;
            shift_1_s    <= 3'b000;
            shift_2_s    <= 3'b000;
            shift_3_s    <= 3'b000;
            rol_amount_s <= 2'b00;
            done_o       <= 1'b0;
        end
        else if (clk_i) begin

            case (current_state_s)
                INIT : begin
                    reg_A_en_s   <= 1'b1;
                    reg_B_en_s   <= 1'b1;
                    AC_en_s      <= 1'b0;
                    mux_B_sel_s  <= 1'b0;
                    shift_0_s    <= 3'bxxx;
                    shift_1_s    <= 3'bxxx;
                    shift_2_s    <= 3'bxxx;
                    shift_3_s    <= 3'bxxx;
                    rol_amount_s <= 2'b00;
                    done_o       <= 1'b0;
                end
                MULT_1 : begin
                    reg_A_en_s   <= 1'b0;
                    reg_B_en_s   <= 1'b1;
                    AC_en_s      <= 1'b1;
                    mux_B_sel_s  <= 1'b1;
                    shift_0_s    <= 3'b000;  // 0  = 0*8
                    shift_1_s    <= 3'b010;  // 16 = 2*8
                    shift_2_s    <= 3'b100;  // 32 = 4*8
                    shift_3_s    <= 3'b110;  // 48 = 6*8
                    rol_amount_s <= 2'b01;
                    done_o       <= 1'b0;
                end
                MULT_2 : begin
                    reg_A_en_s   <= 1'b0;
                    reg_B_en_s   <= 1'b1;
                    AC_en_s      <= 1'b1;
                    mux_B_sel_s  <= 1'b1;
                    shift_0_s    <= 3'b011;  // 24 = 3*8
                    shift_1_s    <= 3'b001;  // 8  = 1*8
                    shift_2_s    <= 3'b011;  // 24 = 3*8
                    shift_3_s    <= 3'b101;  // 40 = 5*8
                    rol_amount_s <= 2'b01;
                    done_o       <= 1'b0;
                end
                MULT_3 : begin
                    reg_A_en_s   <= 1'b0;
                    reg_B_en_s   <= 1'b1;
                    AC_en_s      <= 1'b1;
                    mux_B_sel_s  <= 1'b1;
                    shift_0_s    <= 3'b010;  // 16 = 2*8
                    shift_1_s    <= 3'b100;  // 32 = 4*8
                    shift_2_s    <= 3'b010;  // 16 = 2*8
                    shift_3_s    <= 3'b100;  // 32 = 4*8
                    rol_amount_s <= 2'b01;
                    done_o       <= 1'b0;
                end
                MULT_4 : begin
                    reg_A_en_s   <= 1'b0;
                    reg_B_en_s   <= 1'b1;
                    AC_en_s      <= 1'b1;
                    mux_B_sel_s  <= 1'b1;
                    shift_0_s    <= 3'b001;  // 8  = 1*8
                    shift_1_s    <= 3'b011;  // 24 = 3*8 
                    shift_2_s    <= 3'b101;  // 40 = 5*8
                    shift_3_s    <= 3'b011;  // 24 = 3*8
                    rol_amount_s <= 2'b01;
                    done_o       <= 1'b0;
                end
                DONE : begin
                    reg_A_en_s   <= 1'bx;
                    reg_B_en_s   <= 1'bx;
                    AC_en_s      <= 1'b0;
                    mux_B_sel_s  <= 1'bx;
                    shift_0_s    <= 3'bxxx;
                    shift_1_s    <= 3'bxxx;
                    shift_2_s    <= 3'bxxx;
                    shift_3_s    <= 3'bxxx;
                    rol_amount_s <= 2'bxx;
                    done_o       <= 1'b0;
                end
                default : begin
                    reg_A_en_s   <= 1'bx;
                    reg_B_en_s   <= 1'bx;
                    AC_en_s      <= 1'b0;
                    mux_B_sel_s  <= 1'bx;
                    shift_0_s    <= 3'bxxx;
                    shift_1_s    <= 3'bxxx;
                    shift_2_s    <= 3'bxxx;
                    shift_3_s    <= 3'bxxx;
                    rol_amount_s <= 2'bxx;
                    done_o       <= 1'b0;
                end
            endcase
        end
    end


// DATA PATH
    reg  [31:0] reg_A_s;
    reg  [31:0] reg_B_s;
    wire [31:0] mux_B_s;
    wire [31:0] rotated_mux_B_s;

    always @(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            reg_A_s <= 32'h00000000;
            reg_B_s <= 32'h00000000;
        end
        else if (clk_i) begin
            if (reg_A_en_s)
                reg_A_s <= op_A_i;
            
            if (reg_B_en_s)
                reg_B_s <= rotated_mux_B_s;
        end
    end

    assign mux_B_s = (mux_B_sel_s == 1'b0) ? op_B_i : reg_B_s;

    rotate_left Rotate_inst (
        .operand_i    ( mux_B_s         ),
        .rol_amount_i ( rol_amount_s    ),
        .result_o     ( rotated_mux_B_s )
    );



endmodule