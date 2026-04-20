module multiplier_tb;

    `ifdef TESTS_NUM
        localparam TESTS_NUM_h = `TESTS_NUM;
    `else
        localparam TESTS_NUM_h = 100;
    `endif

    logic [31:0] A_op, B_op;
    logic [63:0] answer;
    int tests;
    int errors;


    multiplier DUT (
    .A_i (A_op),
    .B_i (B_op),
    .result_o (answer)
    );

    logic [63:0] expected;


    task TestResult (input logic [31:0]A, input logic [31:0]B);
        A_op=A;
        B_op=B;
        expected = A*B;
        #1
        errors = (answer==expected) ? errors : errors+1;
        $display("| %d | %d | %d | %s | %0d ", A, B, answer,  (answer==expected) ? "    ":"ERROR", $time);
    endtask









    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);
        tests = TESTS_NUM_h;
        errors = 0;

        $display("\n+------------+------------+----------------------+-------+-------+");
        $display(  "| INPUT A    | INPUT B    | ANSWER               | Erro  | time");
        $display(  "+------------+------------+----------------------+-------+-------+");

        for (int i=0 ; i<TESTS_NUM_h ; i=i+1) begin
            TestResult($urandom, $urandom);
        end
        $display("|Tests  : %d", tests);
        $display("|errors : %d", errors);

        
        $finish;

        
    end



endmodule