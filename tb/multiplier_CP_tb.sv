module multiplier_CP_tv;

    logic clk_i;
    logic rst_i;
    logic mult_en_i;             // Enable of the multiplier
    logic signed_B_i;            // indicates if it is necessary the signal extension from B

    logic       reg_A_en_o;      // enable of wireister of operand A
    logic       reg_B_en_o;      // enable of wireister of operand B
    logic       AC_en_o;         // enable of result accumulator
    logic       mux_B_sel_o;     // mux selector of operand B
    logic [3:0] sig_ctrl_B_o;    // signal extension of operand B
    logic [2:0] shift_0_o;       // shift amount to multiplier 0
    logic [2:0] shift_1_o;       // shift amount to multiplier 1
    logic [2:0] shift_2_o;       // shift amount to multiplier 2
    logic [2:0] shift_3_o;       // shift amount to multiplier 3
    logic       rol_en_o;        // left rotate amount to operand B
    logic       done_o;          // indicates when the operation ends


    multiplier_CP DUT (
        .clk_i        ( clk_i        ),
        .rst_i        ( rst_i        ),
        .mult_en_i    ( mult_en_i    ),
        .signed_B_i   ( signed_B_i   ),
        .reg_A_en_o   ( reg_A_en_o   ),
        .reg_B_en_o   ( reg_B_en_o   ),
        .AC_en_o      ( AC_en_o      ),
        .mux_B_sel_o  ( mux_B_sel_o  ),
        .sig_ctrl_B_o ( sig_ctrl_B_o ),
        .shift_0_o    ( shift_0_o    ),
        .shift_1_o    ( shift_1_o    ),
        .shift_2_o    ( shift_2_o    ),
        .shift_3_o    ( shift_3_o    ),
        .rol_en_o     ( rol_en_o     ),
        .done_o       ( done_o       )
    );

    task test_result(
        input string      state,
        input logic       reg_A_en_exp,
        input logic       reg_B_en_exp,
        input logic       AC_en_exp,
        input logic       mux_B_sel_exp,
        input logic [3:0] sig_ctrl_B_exp,
        input logic [2:0] shift_0_exp,
        input logic [2:0] shift_1_exp,
        input logic [2:0] shift_2_exp,
        input logic [2:0] shift_3_exp,
        input logic       rol_en_exp,
        input logic       done_exp  
    );

    $display("| %s  |    %b     |  A_en=%b B_en=%b AC_en=%b muxB=%b sig_B=%b sft0=%b sft1=%b sft2=%b sft3=%b rol_en=%b done=%b |",
                state, signed_B_i, reg_A_en_o, reg_B_en_o, AC_en_o, mux_B_sel_o ,sig_ctrl_B_o, shift_0_o, shift_1_o, shift_2_o, shift_3_o, rol_en_o, done_o);

    if      (reg_A_en_o !== reg_A_en_exp) print_error($sformatf("%s should be %b at time %0d", "reg_A_en_o", reg_A_en_exp, $time ));
    if (reg_B_en_o !== reg_B_en_exp) print_error($sformatf("%s should be %b at time %0d", "reg_B_en_o", reg_B_en_exp, $time ));
    if (AC_en_o !== AC_en_exp) print_error($sformatf("%s should be %b at time %0d", "AC_en_o", AC_en_exp, $time ));
    if (mux_B_sel_o !== mux_B_sel_exp) print_error($sformatf("%s should be %b at time %0d", "mux_B_sel_o", mux_B_sel_exp, $time ));
    if (sig_ctrl_B_o !== sig_ctrl_B_exp) print_error($sformatf("%s should be %b at time %0d", "sig_ctrl_B_o", sig_ctrl_B_exp, $time ));
    if (shift_0_o !== shift_0_exp) print_error($sformatf("%s should be %b at time %0d", "shift_0_o", shift_0_exp, $time ));
    if (shift_1_o !== shift_1_exp) print_error($sformatf("%s should be %b at time %0d", "shift_1_o", shift_1_exp, $time ));
    if (shift_2_o !== shift_2_exp) print_error($sformatf("%s should be %b at time %0d", "shift_2_o", shift_2_exp, $time ));
    if (shift_3_o !== shift_3_exp) print_error($sformatf("%s should be %b at time %0d", "shift_3_o", shift_3_exp, $time ));
    if (rol_en_o !== rol_en_exp) print_error($sformatf("%s should be %b at time %0d", "rol_en_o", rol_en_exp, $time ));
    if (done_o !== done_exp) print_error($sformatf("%s should be %b at time %0d", "done_o", done_exp, $time ));
        
    endtask

    task print_error (input string message); begin
            $display(  "# ERROR : %s\n", message);
        end
    endtask



    always #2 clk_i = ~clk_i;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);

        $display("\n+---------+----------+----------------------------------------------------------------------------------------------+");
        $display(  "|  STATE  | signed_B |                                             OUTPUTS                                          |");
        $display(  "+---------+----------+----------------------------------------------------------------------------------------------+");

        clk_i      = 1'b0;
        rst_i      = 1'b1;
        mult_en_i  = 1'b1;
        signed_B_i = 1'b0;

        #1
        rst_i = 1'b0;
        #1
        //                   regA,  regB,  AC,  muxB,   sigB,   sft0,   sft1,   sft2,   sft3,   rol,  done
        test_result("INIT  ", 1'b1, 1'b1, 1'b0, 1'b0, 4'b0000, 3'b000, 3'b000, 3'b000, 3'b000, 1'b0, 1'b0); //INIT
        #4
        test_result("MULT_1", 1'b0, 1'b1, 1'b1, 1'b1, 4'b0000, 3'b000, 3'b010, 3'b100, 3'b110, 1'b1, 1'b0); //MULT_1
        #4
        test_result("MULT_2", 1'b0, 1'b1, 1'b1, 1'b1, 4'b0000, 3'b011, 3'b001, 3'b011, 3'b101, 1'b1, 1'b0); //MULT_2
        #4
        test_result("MULT_3", 1'b0, 1'b1, 1'b1, 1'b1, 4'b0000, 3'b010, 3'b100, 3'b010, 3'b100, 1'b1, 1'b0); //MULT_3
        #4
        test_result("MULT_4", 1'b0, 1'b1, 1'b1, 1'b1, 4'b0000, 3'b001, 3'b011, 3'b101, 3'b011, 1'b1, 1'b0); //MULT_3
        #4
        test_result("DONE  ", 1'b0, 1'b0, 1'b0, 1'b0, 4'b0000, 3'b000, 3'b000, 3'b000, 3'b000, 1'b0, 1'b1); //DONE

        #1
        signed_B_i = 1'b1;
        rst_i      = 1'b1;
        #1
        rst_i      = 1'b0;
        #2

        $display(  "+---------+----------+----------------------------------------------------------------------------------------------+");

        //                   regA,  regB,  AC,  muxB,   sigB,   sft0,   sft1,   sft2,   sft3,   rol,  done
        test_result("INIT  ", 1'b1, 1'b1, 1'b0, 1'b0, 4'b0000, 3'b000, 3'b000, 3'b000, 3'b000, 1'b0, 1'b0); //INIT
        #4
        test_result("MULT_1", 1'b0, 1'b1, 1'b1, 1'b1, 4'b1000, 3'b000, 3'b010, 3'b100, 3'b110, 1'b1, 1'b0); //MULT_1
        #4
        test_result("MULT_2", 1'b0, 1'b1, 1'b1, 1'b1, 4'b0001, 3'b011, 3'b001, 3'b011, 3'b101, 1'b1, 1'b0); //MULT_2
        #4
        test_result("MULT_3", 1'b0, 1'b1, 1'b1, 1'b1, 4'b0010, 3'b010, 3'b100, 3'b010, 3'b100, 1'b1, 1'b0); //MULT_3
        #4
        test_result("MULT_4", 1'b0, 1'b1, 1'b1, 1'b1, 4'b0100, 3'b001, 3'b011, 3'b101, 3'b011, 1'b1, 1'b0); //MULT_3
        #4
        test_result("DONE  ", 1'b0, 1'b0, 1'b0, 1'b0, 4'b0000, 3'b000, 3'b000, 3'b000, 3'b000, 1'b0, 1'b1); //DONE
        $display(  "+---------+----------+----------------------------------------------------------------------------------------------+\n");

        $finish;
    end


endmodule