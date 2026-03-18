module multiplier_tb;

    localparam CLK_PERIOD = 10;
    localparam STAGES = 5;
    localparam TESTS_NUM = 5000;

    logic clk, rst, sigA, sigB, upper, done, mult_on;
    logic [31:0] A_op, B_op, answer;
    logic [6:0] opcode, funct7;
    logic [2:0] funct3;

    reg [63:0] A_ext, B_ext, AxB;
    int errors, tests;

    multiplier_top DUT (
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


    task TestResult ( input logic [31:0] A, input logic [31:0] B);

        A_op = A;
        B_op = B;

        funct3 = 3'b000;    // MUL
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {{32{B_op[31]}}, B_op};
        AxB = A_ext * B_ext;
        #(CLK_PERIOD/2) rst = 1; #(3*CLK_PERIOD/2) rst = 0; #(STAGES*CLK_PERIOD)
        errors = (AxB[31:0]==answer) ? errors : errors+1;
        $display(  "| MUL         | 0x%h | 0x%h | %s | %0d", AxB[31:0] ,answer, (AxB[31:0]==answer ? "     " : "ERROR"), $time );


        #(2*CLK_PERIOD)
        rst = 1;
        funct3 = 3'b001;    // MULH
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {{32{B_op[31]}}, B_op};
        AxB = A_ext * B_ext;
        #(3*CLK_PERIOD/2)
        rst = 0;  
        #(STAGES*CLK_PERIOD)
        errors = (AxB[63:32]==answer) ? errors : errors+1;
        $display(  "| MULH        | 0x%h | 0x%h | %s | %0d", AxB[63:32] ,answer, (AxB[63:32]==answer ? "     " : "ERROR"), $time );

        #(2*CLK_PERIOD)
        funct3 = 3'b010;    // MULHSU
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {32'h00000000, B_op};
        AxB = A_ext * B_ext;
        rst = 1;
        #(3*CLK_PERIOD)
        rst = 0;
        #((STAGES)*CLK_PERIOD)
        errors = (AxB[63:32]==answer) ? errors : errors+1;
        $display(  "| MULHSU      | 0x%h | 0x%h | %s | %0d", AxB[63:32] ,answer, (AxB[63:32]==answer ? "     " : "ERROR"), $time );

        #(2*CLK_PERIOD)
        funct3 = 3'b011;    // MULHU
        A_ext = {32'h00000000, A_op};
        B_ext = {32'h00000000, B_op};
        AxB = A_ext * B_ext;
        rst = 1;
        #(3*CLK_PERIOD/2)
        rst = 0;
        #((STAGES)*CLK_PERIOD)
        errors = (AxB[63:32]==answer) ? errors : errors+1;
        $display(  "| MULHS       | 0x%h | 0x%h | %s | %0d", AxB[63:32] ,answer, (AxB[63:32]==answer ? "     " : "ERROR"), $time );  
        $display(  "+-------------+------------+------------+-------+---------"); 
    endtask

    always #(CLK_PERIOD/2) clk <= ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);
        
        clk = 0;
        rst = 0;
        errors = 0;
        tests = TESTS_NUM;

        opcode = 7'b0110011; 
        funct7 = 7'b0000001;

        $display("\n+-------------+------------+------------+-------+---------");
        $display(  "| Instruction |  Expected  |   Answer   | Error | Time");
        $display(  "+-------------+------------+------------+-------+---------");
        #1
            TestResult(32'h80000001, 32'h80010002);
            #1
        
        for (int i=0 ; i<TESTS_NUM ; i=i+1) begin
            #1
            TestResult($urandom, $urandom);
        end


        
        $display(  "+-------------+------------+------------+-------+---------");
        $display(  "| Number of Tests  : %0d", tests*4);
        $display(  "| Number of Errors : %0d", errors);
        $display(  "+---------------------------------------------------------");
        $finish;

        
    end



endmodule