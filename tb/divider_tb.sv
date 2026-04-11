module divider_tb;

    localparam CLK_PERIOD = 10;

    `ifdef TESTS_NUM
        localparam TESTS_NUM_h = `TESTS_NUM;
    `else
        localparam TESTS_NUM_h = 16;
    `endif

    logic clk, rst, sigA, sigB, upper, done, div_on, div_by_zero;
    logic [31:0] A_op, B_op, answer;
    logic [6:0] opcode, funct7;
    logic [2:0] funct3;

    reg [63:0] A_ext, B_ext, AxB;
    int errors, tests;
    int temp_cycles, total_cycles;
    logic [3:0] Instructions;

    divider DUT (
        .clk_i       ( clk     ),
        .rst_i       ( rst     ),
        .div_on_i    ( div_on  ),
        .signed_A_i  ( sigA    ),
        .signed_B_i  ( sigB    ),
        .upper_rem_i ( upper   ),
        .operand_a_i ( A_op    ),
        .operand_b_i ( B_op    ),
        .writeback_stall_o ( done ),
        .writeback_value_o ( answer ),
        .div_by_zero_o     ( div_by_zero)
    );

    decoder decoder (
        .opcode_i    ( opcode  ),
        .funct3_i    ( funct3  ),
        .funct7_i    ( funct7  ),

        //.mult_on_o   ( mult_on ),
        .div_on_o    ( div_on  ),
        .signed_A_o  ( sigA    ),
        .signed_B_o  ( sigB    ),
        .upper_rem_o ( upper   )
    );


    task TestResult ( input logic [31:0] A, input logic [31:0] B, input logic [3:0] Instrs);

        A_op = A;
        B_op = B;

        // DIV
        if (Instrs[0] == 1'b1) begin
            #(3*CLK_PERIOD)
            funct3 = 3'b100;
            temp_cycles =0;
            opcode = 7'b0110011; 
            A_ext = {32'h00000000, A_op};
            B_ext = {32'h00000000, B_op};
            AxB = $signed(A_op) / $signed(B_op);
            @(posedge clk)
            temp_cycles =0;
            funct3 = {$urandom};
            opcode = {6'b011001, $urandom};
            @(negedge done)
            opcode = 7'b0110010;
            #((9*CLK_PERIOD)/10)
            errors = (AxB[31:0]==answer) ? errors : errors+1;
            tests = tests + 1;
            $display(  "| DIV         | 0x%h | 0x%h | %6d | %s | %0d", AxB[31:0] ,answer, temp_cycles, (AxB[31:0]==answer ? "     " : "ERROR"), $time );
            total_cycles = total_cycles + temp_cycles;
        end

        // DIVU
        if (Instrs[1] == 1'b1) begin
            #(3*CLK_PERIOD)
            funct3 = 3'b101;
            opcode = 7'b0110011; 
            A_ext = {32'h00000000, A_op};
            B_ext = {32'h00000000, B_op};
            AxB = A_op / B_op;
            @(posedge clk)
            temp_cycles =0;
            funct3 = {$urandom};
            opcode = {6'b011001, $urandom};
            @(negedge done)
            opcode = 7'b0110010;
            #((9*CLK_PERIOD)/10)
            errors = (AxB[31:0]==answer) ? errors : errors+1;
            tests = tests + 1;
            $display(  "| DIVU        | 0x%h | 0x%h | %6d | %s | %0d", AxB[31:0] ,answer, temp_cycles, (AxB[31:0]==answer ? "     " : "ERROR"), $time );
            total_cycles = total_cycles + temp_cycles;
        end

        // REM
        if (Instrs[2] == 1'b1) begin
             #(3*CLK_PERIOD)
            funct3 = 3'b110;
            opcode = 7'b0110011; 
            A_ext = {32'h00000000, A_op};
            B_ext = {32'h00000000, B_op};
            AxB = $signed(A_op) % $signed(B_op);
            @(posedge clk)
            temp_cycles =0;
            funct3 = {$urandom};
            opcode = {6'b011001, $urandom};
            @(negedge done)
            opcode = 7'b0110010; 
            #((9*CLK_PERIOD)/10)
            errors = (AxB[31:0]==answer) ? errors : errors+1;
            tests = tests + 1;
            $display(  "| REM         | 0x%h | 0x%h | %6d | %s | %0d", AxB[31:0] ,answer, temp_cycles, (AxB[31:0]==answer ? "     " : "ERROR"), $time );
            total_cycles = total_cycles + temp_cycles;
        end

        // REMU
        if (Instrs[3] == 1'b1) begin
            #(3*CLK_PERIOD)
            funct3 = 3'b111;
            opcode = 7'b0110011; 
            A_ext = {32'h00000000, A_op};
            B_ext = {32'h00000000, B_op};
            AxB = A_op % B_op;
            @(posedge clk)
            temp_cycles =0;
            funct3 = {$urandom};
            opcode = {6'b011001, $urandom};
            @(negedge done)
            opcode = 7'b0110010;
            #((9*CLK_PERIOD)/10)
            errors = (AxB[31:0]==answer) ? errors : errors+1; 
            tests = tests + 1;
            $display(  "| REMU        | 0x%h | 0x%h | %6d | %s | %0d", AxB[31:0] ,answer, temp_cycles, (AxB[31:0]==answer ? "     " : "ERROR"), $time );  
            total_cycles = total_cycles + temp_cycles;
        end
        $display(  "+-------------+------------+------------+-------+--------+--------");
    endtask


    always #(CLK_PERIOD/2) clk <= ~clk;
    always@(posedge clk) temp_cycles = temp_cycles +1;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT, decoder);
        
        clk = 0;
        rst = 0;
        errors = 0;
        tests = 0;
        Instructions = 4'b0000;
        
        opcode = 7'b0110011; 
        funct7 = 7'b0000001;
        
        #(CLK_PERIOD/2) rst = 1; #(3*CLK_PERIOD/2) rst = 0;

        $display("\n+-------------+------------+------------+--------+-------+--------");
        $display(  "| Instruction |  Expected  |   Answer   | Cycles | Error | Time");
        $display(  "+-------------+------------+------------+--------+-------+--------");
            #1
             TestResult(32'h00000000, 32'h00000000, 4'b1111);
             #1
             TestResult(32'hffffffff, 32'h00000001, 4'b1111);
             #1
        
        for (int i=0 ; tests<TESTS_NUM_h ; i=i+1) begin
            #1
            TestResult($urandom, $urandom, Instructions);
            #1
            Instructions = Instructions + 4'b0111;
        end


        
        $display(  "| Number of Tests  : %0d", tests);
        $display(  "| Number of Errors : %0d", errors);
        $display(  "| Cycles Average   : %0.2f", real'(total_cycles)/tests);
        $display(  "+-----------------------------------------------------------------");
        $finish;

        
    end



endmodule