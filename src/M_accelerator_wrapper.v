module M_accelerator_wrapper (
    input  wire clk_i,
    // input  wire clk_mult_i,
    // input  wire clk_div_i,
    // input  wire clk_core_i,
    input  wire rst_i,

    input  wire [6:0]  opcode_i,
    input  wire [2:0]  funct3_i,
    input  wire [6:0]  funct7_i,
    input  wire [31:0] op_A_i,
    input  wire [31:0] op_B_i,

    output wire  [31:0] result_o,
    output wire  stall_o,
    output wire  division_by_zero_o
);

    wire mult_on_s;
    wire div_on_s;
    wire signed_A_s;
    wire signed_B_s;
    wire upper_rem_s;

    wire [31:0] mult_result_s;
    wire        mult_stall_s;
    wire [31:0] div_result_s;
    wire        div_stall_s;
    wire        div_by_zero_s;

    wire rst_stall_s;

    wire mult_clk_s;
    wire div_clk_s;
    wire core_clk_s;

    reg mux_selector_s;


    // clock_divider CLOCK_DIVIDER_INST (
    //     .clk_i      ( clk_i      ),
    //     .rst_i      ( rst_i      ),
    //     .clk_div2_o ( div_clk_s  ),
    //     .clk_div3_o ( mult_clk_s ),
    //     .clk_div5_o ( core_clk_s )
    // );


    decoder DECODER_INST (
        // Inputs
        .opcode_i    ( opcode_i    ),
        .funct3_i    ( funct3_i    ),
        .funct7_i    ( funct7_i    ),

        // Outputs
        .mult_on_o   ( mult_on_s   ),
        .div_on_o    ( div_on_s    ),
        .signed_A_o  ( signed_A_s  ),
        .signed_B_o  ( signed_B_s  ),
        .upper_rem_o ( upper_rem_s )
    );

    assign rst_stall_s = rst_i || div_stall_s || mult_stall_s;



    multiplier_top MULTIPLIER_INST (
        // Inputs
        .clk_i      ( clk_i    ),
        .rst_i      ( rst_i         ),
        .mult_en_i  ( mult_on_s     ),
        .op_A_i     ( op_A_i        ),
        .op_B_i     ( op_B_i        ),
        .signed_A_i ( signed_A_s    ),
        .signed_B_i ( signed_B_s    ),
        .upper_i    ( upper_rem_s   ),

        // Outputs
        .result_o   ( mult_result_s ),
        .mul_stall_o ( mult_stall_s  )
    );

    divider DIVIDER_INST (
        // Inputs
        .clk_i       ( clk_i   ),
        .rst_i       ( rst_i       ),
        .div_on_i    ( div_on_s    ),
        .signed_A_i  ( signed_A_s  ),
        .signed_B_i  ( signed_B_s  ),
        .upper_rem_i ( upper_rem_s ),
        .operand_a_i ( op_A_i      ),
        .operand_b_i ( op_B_i      ),

        // Outputs
        .writeback_stall_o ( div_stall_s   ),
        .writeback_value_o ( div_result_s  ),
        .div_by_zero_o     ( div_by_zero_s )
    );

    always@(posedge clk_i, posedge rst_i) begin
        if (rst_i)
            mux_selector_s <= 1'b0;
        else if (mult_on_s || div_on_s)
            mux_selector_s <= div_on_s;
    end

    assign result_o = (mux_selector_s==1'b1) ? div_result_s : mult_result_s;
    //assign result_o = (mux_selector_s==1'b1) ? mult_result_s : div_result_s;
    assign stall_o = div_stall_s || mult_stall_s;


endmodule