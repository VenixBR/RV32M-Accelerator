/*
1 pipeline stage
CRITICAL PATH : 16 bits multiplier

PDK      : Cadence 45nm
MAX FREQ : 335 MHz
CYCLES   : 8
TIME     : 23,92 ns
POWER    : 2625,03 uW
ENERGY   : 62,79 pJ 
AREA     : 14700,074 um2
*/

module multiplier_top_V2 (

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
    output wire done_o
);

    // Interconnect signals
    wire       reg_A_en_s;
    wire       reg_B_en_s;
    wire       AC_en_s;
    wire       en_pipe_s;
    wire       mux_B_sel_s;
    wire [1:0] shift_amount_s;
    wire       rol_en_s;

    // CONTROL PATH
    multiplier_CP_V2 MULT_CP_inst(
        // INPUTS
        .clk_i          ( clk_i          ),
        .rst_i          ( rst_i          ),
        .mult_en_i      ( mult_en_i      ),

        // OUTPUTS
        .reg_A_en_o     ( reg_A_en_s     ),
        .reg_B_en_o     ( reg_B_en_s     ),
        .AC_en_o        ( AC_en_s        ),
        .en_pipe_o      ( en_pipe_s      ),
        .mux_B_sel_o    ( mux_B_sel_s    ),
        .shift_amount_o ( shift_amount_s ),
        .rol_en_o       ( rol_en_s       ),
        .done_o         ( done_o         )
    );

    multiplier_DP_V2 MULT_DP_inst ( 
        // Inputs
        .clk_i          ( clk_i          ),
        .rst_i          ( rst_i          ),
        .signed_A_i     ( signed_A_i     ),
        .signed_B_i     ( signed_B_i     ),
        .upper_i        ( upper_i        ),
        .op_A_i         ( op_A_i         ),
        .op_B_i         ( op_B_i         ),
        .reg_A_en_i     ( reg_A_en_s     ),
        .reg_B_en_i     ( reg_B_en_s     ),
        .AC_en_i        ( AC_en_s        ),
        .en_pipe_i      ( en_pipe_s      ),
        .mux_B_sel_i    ( mux_B_sel_s    ),
        .shift_amount_i ( shift_amount_s ),
        .rol_en_i       ( rol_en_s       ),

        // Outputs
        .result_o       ( result_o       )
    );


endmodule