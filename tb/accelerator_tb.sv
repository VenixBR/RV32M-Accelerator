module accelerator_tb;

    localparam CLK_PERIOD = 10;
    localparam STAGES = 5;
    `ifdef TESTS_NUM
        localparam TESTS_NUM_h = `TESTS_NUM;
    `else
        localparam TESTS_NUM_h = 16;
    `endif

    logic clk, rst, done, stall, div_zero;
    logic [31:0] A_op;
    logic [31:0] B_op;
    logic [31:0] answer;
    logic [6:0] opcode;
    logic [6:0] funct7;
    logic [2:0] funct3;

    reg [63:0] A_ext, B_ext, AxB;
    int errors, tests;
    logic [7:0] Instructions;
    string errors_log;

    M_accelerator_wrapper DUT (
        .clk_i (clk),
        .rst_i (rst),

        .opcode_i (opcode),
        .funct3_i (funct3),
        .funct7_i (funct7),
        .op_A_i (A_op),
        .op_B_i(B_op),

        .result_o(answer),
        .done_o(done),
        .stall_o(stall),
        .division_by_zero_o(div_zero)
    );



    task TestResult ( input logic [31:0] A, input logic [31:0] B, input logic [7:0] Instrs);

        A_op = A;
        B_op = B;


        // MUL
        if (Instrs[0] == 1'b1) begin
            #(6*CLK_PERIOD)
            funct3 = 3'b000;    
            opcode = 7'b0110011; 
            A_ext = {{32{A_op[31]}}, A_op};
            B_ext = {{32{B_op[31]}}, B_op};
            AxB = A_ext * B_ext;
            #(CLK_PERIOD)
            opcode = 7'b0110010; 
            @(negedge done)
            #((9*CLK_PERIOD)/10)
            if (AxB[31:0]!=answer) begin
                errors_log = {errors_log, $sformatf("\n|    [%0d] Error in MUL at time %0d", errors+1, $time)};
                errors = errors+1;
            end
            tests = tests + 1;
            $display(  "| MUL         | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[31:0] ,answer, (AxB[31:0]==answer ? "     " : "ERROR"), $time );
        end

        // MULH
        if (Instrs[1] == 1'b1) begin
            #(10*CLK_PERIOD)
            funct3 = 3'b001;    
            opcode = 7'b0110011; 
            A_ext = {{32{A_op[31]}}, A_op};
            B_ext = {{32{B_op[31]}}, B_op};
            AxB = A_ext * B_ext;
            #(CLK_PERIOD)
            opcode = 7'b0110010; 
            @(negedge done)
            #((9*CLK_PERIOD)/10)
            if (AxB[63:32]!=answer) begin
                errors_log = {errors_log, $sformatf("\n|    [%0d] Error in MULH at time %0d", errors+1, $time)};
                errors = errors+1;
            end
            tests = tests + 1;
            $display(  "| MULH        | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[63:32] ,answer, (AxB[63:32]==answer ? "     " : "ERROR"), $time );
        end

        // MULHSU
        if (Instrs[2] == 1'b1) begin
            #(7*CLK_PERIOD)
            funct3 = 3'b010;
            opcode = 7'b0110011; 
            A_ext = {{32{A_op[31]}}, A_op};
            B_ext = {32'h00000000, B_op};
            AxB = A_ext * B_ext;
            #(CLK_PERIOD)
            opcode = 7'b0110010; 
            @(negedge done)
            #((9*CLK_PERIOD)/10)
            if (AxB[63:32]!=answer) begin
                errors_log = {errors_log, $sformatf("\n|    [%0d] Error in MULHSU at time %0d", errors+1, $time)};
                errors = errors+1;
            end
            tests = tests + 1;
            $display(  "| MULHSU      | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[63:32] ,answer, (AxB[63:32]==answer ? "     " : "ERROR"), $time );
        end

        // MULHU
        if (Instrs[3] == 1'b1) begin
            #(17*CLK_PERIOD)
            funct3 = 3'b011;
            opcode = 7'b0110011; 
            A_ext = {32'h00000000, A_op};
            B_ext = {32'h00000000, B_op};
            AxB = A_ext * B_ext;
            #(CLK_PERIOD)
            opcode = 7'b0110010; 
            @(negedge done)
            #((9*CLK_PERIOD)/10)
            if (AxB[63:32]!=answer) begin
                errors_log = {errors_log, $sformatf("\n|    [%0d] Error in MULHU at time %0d", errors+1, $time)};
                errors = errors+1;
            end
            tests = tests + 1;
            $display(  "| MULHS       | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[63:32] ,answer, (AxB[63:32]==answer ? "     " : "ERROR"), $time );  
        end

        // DIV
        if (Instrs[4] == 1'b1) begin
            #(3*CLK_PERIOD)
            funct3 = 3'b100;
            opcode = 7'b0110011; 
            A_ext = {32'h00000000, A_op};
            B_ext = {32'h00000000, B_op};
            AxB = $signed(A_op) / $signed(B_op);
            #(CLK_PERIOD)
            opcode = 7'b0110010; 
            @(negedge done)
            #((9*CLK_PERIOD)/10)
            if (AxB[31:0]!=answer) begin
                errors_log = {errors_log, $sformatf("\n|    [%0d] Error in DIV at time %0d", errors+1, $time)};
                errors = errors+1;
            end
            tests = tests + 1;
            $display(  "| DIV         | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[31:0] ,answer, (AxB[31:0]==answer ? "     " : "ERROR"), $time );  
        end

        // DIVU
        if (Instrs[5] == 1'b1) begin
            #(3*CLK_PERIOD)
            funct3 = 3'b100;
            opcode = 7'b0110011; 
            A_ext = {32'h00000000, A_op};
            B_ext = {32'h00000000, B_op};
            AxB = A_op / B_op;
            #(CLK_PERIOD)
            opcode = 7'b0110010; 
            @(negedge done)
            #((9*CLK_PERIOD)/10)
            if (AxB[31:0]!=answer) begin
                errors_log = {errors_log, $sformatf("\n|    [%0d] Error in DIVU at time %0d", errors+1, $time)};
                errors = errors+1;
            end
            tests = tests + 1;
            $display(  "| DIVU        | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A, B, AxB[31:0] ,answer, (AxB[31:0]==answer ? "     " : "ERROR"), $time );  
        end

        // REM
        if (Instrs[6] == 1'b1) begin
            #(3*CLK_PERIOD)
            funct3 = 3'b100;
            opcode = 7'b0110011; 
            A_ext = {32'h00000000, A_op};
            B_ext = {32'h00000000, B_op};
            AxB = $signed(A_op) % $signed(B_op);
            #(CLK_PERIOD)
            opcode = 7'b0110010; 
            @(negedge done)
            #((9*CLK_PERIOD)/10)
            if (AxB[31:0]!=answer) begin
                errors_log = {errors_log, $sformatf("\n|    [%0d] Error in REM at time %0d", errors+1, $time)};
                errors = errors+1;
            end
            tests = tests + 1;
            $display(  "| REM         | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A, B, AxB[31:0] ,answer, (AxB[31:0]==answer ? "     " : "ERROR"), $time );  
        end

        // REMU
        if (Instrs[7] == 1'b1) begin
            #(3*CLK_PERIOD)
            funct3 = 3'b100;
            opcode = 7'b0110011; 
            A_ext = {32'h00000000, A_op};
            B_ext = {32'h00000000, B_op};
            AxB = A_op % B_op;
            #(CLK_PERIOD)
            opcode = 7'b0110010; 
            @(negedge done)
            #((9*CLK_PERIOD)/10)
            if (AxB[31:0]!=answer) begin
                errors_log = {errors_log, $sformatf("\n|    [%0d] Error in REMU at time %0d", errors+1, $time)};
                errors = errors+1;
            end
            tests = tests + 1;
            $display(  "| REMU        | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[31:0] ,answer, (AxB[31:0]==answer ? "     " : "ERROR"), $time );  
        end

        $display(  "+-------------+------------+------------++------------+------------++-------+---------"); 
    endtask

    always #(CLK_PERIOD/2) clk <= ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);
        
        errors_log = "";
        clk = 0;
        rst = 0;
        errors = 0;
        Instructions = 8'b11111111;
        tests = 0;
        
        opcode = 7'b0110011; 
        funct7 = 7'b0000001;
        
        #(CLK_PERIOD/2) rst = 1; #(3*CLK_PERIOD/2) rst = 0;

        $display("\n+-------------+------------+------------++------------+------------++-------+---------");
        $display(  "| INSTRUCTION |  OPERAND A |  OPERAND B ||  EXPECTED  |   ANSWER   || INFO  | TIME");
        $display(  "+-------------+------------+------------++------------+------------++-------+---------");
        #1
            // TestResult(32'h80000001, 32'h80010002);
            // #1
            TestResult(32'h00000023, 32'h00000007, 8'b11111111);
            #1
        
        for (int i=0 ; i<TESTS_NUM_h ; i=i+1) begin
            #1
            TestResult($urandom, $urandom, Instructions);
            #1
            Instructions = Instructions + 8'b00011101; //29
        end


        $display(  "| INSTRUCTION |  OPERAND A |  OPERAND B ||  EXPECTED  |   ANSWER   || INFO  | TIME");
        $display(  "+-------------+------------+------------++------------+------------++-------+---------");
        $display(  "| Number of Tests  : %0d", tests);
        $display(  "| Number of Errors : %0d\n| %s", errors, errors_log);
        $display(  "+-------------------------------------------------------------------------------------");
        $finish;

        
    end

endmodule