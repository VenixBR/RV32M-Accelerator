module multiplier_tb;

    localparam CLK_PERIOD = 10;
    localparam STAGES = 7;

    logic clk, rst, sigA, sigB, upper, done, mult_on;
    logic [31:0] A_op, B_op, answer;
    logic [6:0] opcode, funct7;
    logic [2:0] funct3;

    multiplier_top_V6 DUT (
        .clk_i      ( clk     ),
        .rst_i      ( rst     ),
        .mult_en_i  ( mult_on ),
        .op_A_i     ( A_op    ),
        .op_B_i     ( B_op    ),
        .signed_A_i ( sigA    ),
        .signed_B_i ( sigB    ),
        .upper_i    ( upper   ),
        .result_o   ( answer  ),
        .done_o     ( done    )
    );

    decoder decoder (
        .opcode_i    ( opcode  ),
        .funct3_i    ( funct3  ),
        .funct7_i    ( funct7  ),

        .mult_on_o   ( mult_on ),
        //.div_on_o    (  ),
        .signed_A_o  ( sigA    ),
        .signed_B_o  ( sigB    ),
        .upper_rem_o ( upper   )
    );



    always #(CLK_PERIOD/2) clk <= ~clk;

    reg [63:0] A_ext, B_ext, AxB;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);
        clk = 0;
        rst = 0;

        opcode = 7'b0110011; 
        funct7 = 7'b0000001;

        A_op = 32'h80000001; // 2147483649 ou -2147483647
        B_op = 32'h80010002; // 65538 ou 65538
        // A_op = 32'h00000009; // 2147483649 ou -2147483647
        // B_op = 32'h00000007; // 65538 ou 65538
        
        funct3 = 3'b000;    // MUL
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {{32{B_op[31]}}, B_op};
        AxB = A_ext * B_ext;

        #(CLK_PERIOD/2)
        rst = 1;
        #(3*CLK_PERIOD/2)
        rst = 0;

        #(STAGES*CLK_PERIOD)

        $display("\n+-------------+------------+------------+");
        $display(  "| Instruction |  Expected  |   Answer   |");
        $display(  "+-------------+------------+------------+");
        $display(  "| MUL         | 0x%h | 0x%h |", AxB[31:0] ,answer); //0x00010002
        
        
        #(CLK_PERIOD/2)
        rst = 1;
        funct3 = 3'b001;    // MULH
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {{32{B_op[31]}}, B_op};
        AxB = A_ext * B_ext;
        #(3*CLK_PERIOD/2)
        rst = 0;

        # CLK_PERIOD
        
        #(STAGES*CLK_PERIOD)

         $display(  "| MULH        | 0x%h | 0x%h |", AxB[63:32] ,answer); //0x00010002


        #(CLK_PERIOD/2)
        funct3 = 3'b010;    // MULHSU
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {32'h00000000, B_op};
        AxB = A_ext * B_ext;
        rst = 1;
        #(3*CLK_PERIOD/2)
        rst = 0;
        
        
        #((STAGES)*CLK_PERIOD)

        $display(  "| MULHSU      | 0x%h | 0x%h |", AxB[63:32] ,answer); //0x00010002

        # CLK_PERIOD
        funct3 = 3'b011;    // MULHU
        A_ext = {32'h00000000, A_op};
        B_ext = {32'h00000000, B_op};
        AxB = A_ext * B_ext;
        rst = 1;
        #(3*CLK_PERIOD/2)
        rst = 0;
        #((STAGES)*CLK_PERIOD)
        
        $display(  "| MULHU       | 0x%h | 0x%h |", AxB[63:32] ,answer); //0x00010002
        $display(  "+-------------+------------+------------+\n");
        $finish;

        
    end



endmodule