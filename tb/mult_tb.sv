module multiplier_tb;

    localparam TESTS_NUM = 3000;

    logic sigA;
    logic [1:0] sigB;
    logic [31:0] A_op, B_op;
    logic [32:0] answer1, answer2;
    logic [6:0] opcode, funct7;
    logic [2:0] funct3;

    multiplier DUT1 (
    .A_i (A_op[15:0]),
    .B_i (B_op[15:0]),
    .sigA_i(1'b0),
    .sigB_i(sigB[0]),
    .writeback_value_o (answer1)
    );

    multiplier DUT2 (
    .A_i (A_op[31:16]),
    .B_i (B_op[31:16]),
    .sigA_i(sigA),
    .sigB_i(sigB[1]),
    .writeback_value_o (answer2)
    );



    wire [32:0] temp_mult1, temp_mult2;
    wire [15:0] B0_st, B1_st;
    wire [31:0] ext_a0, ext_a1, ext_b0, ext_b1;

// Divide reg B value in 2 parts
    assign B0_st = B_op[15:0];
    assign B1_st = B_op[31:16];


    // Signal extension to reg A value. The 4 parts are constant.
    assign ext_a0 = {16'h0000 ,A_op[15:0]};
    //assign A0_ext_s = (reg_sigA_s==1'b1) ? {{{16{reg_A_s[16]}}}, reg_A_s[15:0]} : {16'h0000 ,reg_A_s[15:0]};
    
    assign ext_a1 = (sigA==1'b1) ? {{{16{A_op[31]}}}, A_op[31:16]} : {16'h0000 ,A_op[31:16]};

    // Signal extension to reg B value. Are variable because B is rotated.
    assign ext_b0 = (sigB[0]==1'b1) ? {{{16{B0_st[15]}}}, B0_st} : {16'h0000 ,B0_st};
    assign ext_b1 = (sigB[1]==1'b1) ? {{{16{B1_st[15]}}}, B1_st} : {16'h0000 ,B1_st};

    assign temp_mult1 = {ext_b0[31], ext_b0} * {ext_a0[31], ext_a0};
    assign temp_mult2 = {ext_b1[31], ext_b1} * {ext_a1[31], ext_a1};

    

    task TestResult (input logic [31:0]A, input logic [31:0] B, input logic sA, input logic [1:0] sB);
        A_op=A;
        B_op=B;
        sigA = sA;
        sigB = sB;
        #1
        $display("| %d | %d | %d | %d | %s | %s |", A, B, answer1, answer2, (answer1==temp_mult1) ? "    ":"ERROR", (answer2==temp_mult2) ? "    ":"ERROR");
    endtask









    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT1, DUT2, temp_mult2,temp_mult1);

        $display("\n+------------+------------+------------+------------+-------+-------+");
        $display(  "| INPUT A    | INPUT B    | ANSWER 1   | ANSWER 2   | Err A | Err B |");
        $display(  "+------------+------------+------------+------------+-------+-------+");

        for (int i=0 ; i<TESTS_NUM ; i=i+1) begin
            TestResult($urandom, $urandom, $urandom, $urandom);
        end

        
        $finish;

        
    end



endmodule