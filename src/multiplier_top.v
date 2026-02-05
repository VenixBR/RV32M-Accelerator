module multiplier_top (

    // Inputs
    input wire clk_i,
    input wire rst_i,
    input wire mult_en_i,
    input wire [31:0] op_A_i,
    input wire [31:0] op_B_i,
    input wire signed_A_i,
    input wire signed_B_i,
    input wire upper_i,

    // Outputs
    output wire [31:0] result_o,
    output done_o
);

    // Interconnect signals
    wire       reg_A_en_s;
    wire       reg_B_en_s;
    wire       AC_en_s;
    wire       mux_B_sel_s;
    wire [3:0] sig_ctrl_B_s,;
    wire [2:0] shift_0_s;
    wire [2:0] shift_1_s;
    wire [2:0] shift_2_s;
    wire [2:0] shift_3_s;
    wire       rol_en_s;

    // CONTROL PATH
    multiplier_CP MULT_CP_inst(
        // INPUTS
        .clk_i        ( clk_i        ),
        .rst_i        ( rst_i        ),
        .mult_en_i    ( mult_en_i    ), 
        .signed_B_i   ( signed_B_i   ),   

        // OUTPUTS
        .reg_A_en_o   ( reg_A_en_s   ),
        .reg_B_en_o   ( reg_B_en_s   ),
        .AC_en_o      ( AC_en_s      ),
        .mux_B_sel_o  ( mux_B_sel_s  ),
        .sig_ctrl_B_o ( sig_ctrl_B_s ),
        .shift_0_o    ( shift_0_s    ),
        .shift_1_o    ( shift_1_s    ),
        .shift_2_o    ( shift_2_s    ),
        .shift_3_o    ( shift_3_s    ),
        .rol_en_o     ( rol_en_s     ),
        .done_o       ( done_o       )
    );

    multiplier_DP MULT_DP_inst ( 
        // Inputs
        .clk_i        ( clk_i        ),
        .rst_i        ( rst_i        ),
        .upper_i      ( upper_i      ),
        .op_A_i       ( op_A_i       ),
        .op_B_i       ( op_B_i       ),
        .reg_A_en_i   ( reg_A_en_s   ),
        .reg_B_en_i   ( reg_B_en_s   ),
        .AC_en_i      ( AC_en_s      ),
        .mux_B_sel_i  ( mux_B_sel_s  ),
        .sig_ctrl_B_i ( sig_ctrl_B_s ),
        .shift_0_i    ( shift_0_s    ),
        .shift_1_i    ( shift_1_s    ),
        .shift_2_i    ( shift_2_s    ),
        .shift_3_i    ( shift_3_s    ),
        .rol_en_i     ( rol_en_s     ),

        // Outputs
        .result_o     ( result_o     )
    );


endmodule