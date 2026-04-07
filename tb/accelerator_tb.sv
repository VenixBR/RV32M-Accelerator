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
    int errors, tests, log_file;
    int MUL_errors, MULH_errors, MULHU_errors, MULHSU_errors;
    int DIV_errors, DIVU_errors, REM_errors, REMU_errors;
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
                errors_log = {errors_log, $sformatf("\n|       [%0d] Error in MUL at time %0d", errors+1, $time)};
                errors = errors+1;
                MUL_errors = MUL_errors+1;
            end
            tests = tests + 1;
            $fdisplay(log_file,  "| MUL         | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[31:0] ,answer, (AxB[31:0]==answer ? "     " : "ERROR"), $time );

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
                errors_log = {errors_log, $sformatf("\n|       [%0d] Error in MULH at time %0d", errors+1, $time)};
                errors = errors+1;
                MULH_errors = MULH_errors+1;
            end
            tests = tests + 1;
            $fdisplay(log_file,  "| MULH        | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[63:32] ,answer, (AxB[63:32]==answer ? "     " : "ERROR"), $time );
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
                errors_log = {errors_log, $sformatf("\n|       [%0d] Error in MULHSU at time %0d", errors+1, $time)};
                errors = errors+1;
                MULHSU_errors = MULHSU_errors+1;
            end
            tests = tests + 1;
            $fdisplay(log_file,  "| MULHSU      | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[63:32] ,answer, (AxB[63:32]==answer ? "     " : "ERROR"), $time );
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
                errors_log = {errors_log, $sformatf("\n|       [%0d] Error in MULHU at time %0d", errors+1, $time)};
                errors = errors+1;
                MULHU_errors = MULHU_errors+1;
            end
            tests = tests + 1;
            $fdisplay(log_file,  "| MULHU       | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[63:32] ,answer, (AxB[63:32]==answer ? "     " : "ERROR"), $time );  
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
                errors_log = {errors_log, $sformatf("\n|       [%0d] Error in DIV at time %0d", errors+1, $time)};
                errors = errors+1;
                DIV_errors = DIV_errors+1;
            end
            tests = tests + 1;
            $fdisplay(log_file,  "| DIV         | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[31:0] ,answer, (AxB[31:0]==answer ? "     " : "ERROR"), $time );  
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
                errors_log = {errors_log, $sformatf("\n|       [%0d] Error in DIVU at time %0d", errors+1, $time)};
                errors = errors+1;
                DIVU_errors = DIVU_errors+1;
            end
            tests = tests + 1;
            $fdisplay(log_file,  "| DIVU        | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A, B, AxB[31:0] ,answer, (AxB[31:0]==answer ? "     " : "ERROR"), $time );  
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
                errors_log = {errors_log, $sformatf("\n|       [%0d] Error in REM at time %0d", errors+1, $time)};
                errors = errors+1;
                REM_errors = REM_errors+1;
            end
            tests = tests + 1;
            $fdisplay(log_file,  "| REM         | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A, B, AxB[31:0] ,answer, (AxB[31:0]==answer ? "     " : "ERROR"), $time );  
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
                errors_log = {errors_log, $sformatf("\n|       [%0d] Error in REMU at time %0d", errors+1, $time)};
                errors = errors+1;
                REMU_errors = REMU_errors+1;
            end
            tests = tests + 1;
            $fdisplay(log_file,  "| REMU        | 0x%h | 0x%h || 0x%h | 0x%h || %s | %0d", A,B,AxB[31:0] ,answer, (AxB[31:0]==answer ? "     " : "ERROR"), $time );  
        end

        $fdisplay(log_file,  "+-------------+------------+------------++------------+------------++-------+---------"); 
    endtask

    always #(CLK_PERIOD/2) clk <= ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);
        
        log_file = $fopen("Accelerator_tb.log", "w");
        errors_log = "";
        clk = 0;
        rst = 0;
        errors = 0;
        MUL_errors =0;
        MULH_errors=0;
        MULHU_errors=0;
        MULHSU_errors=0;
        DIV_errors=0;
        DIVU_errors=0;
        REM_errors =0;
        REMU_errors =0;
        Instructions = 8'b11111111;
        tests = 0;
        
        opcode = 7'b0110011; 
        funct7 = 7'b0000001;
        
        #(CLK_PERIOD/2) rst = 1; #(3*CLK_PERIOD/2) rst = 0;

        $fdisplay(log_file, "\n+-------------+------------+------------++------------+------------++-------+---------");
        $fdisplay(log_file,   "| INSTRUCTION |  OPERAND A |  OPERAND B ||  EXPECTED  |   ANSWER   || INFO  | TIME");
        $fdisplay(log_file,   "+-------------+------------+------------++------------+------------++-------+---------");
    
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


        $fdisplay(log_file, "");
        $display(  "+------------------------------------------------------------------------------------+"); 
        $display(  "|                                       REPORTS                                      |"); 
        $display(  "+------------------------------------------------------------------------------------+"); 
        $display(  "| Number of Tests        : %0d", tests);
        $display(  "| Total Number of Errors : %0d", errors);
        $display(  "|");
        $display(  "|       Errors on MUL    : %0d", MUL_errors);
        $display(  "|       Errors on MULH   : %0d", MULH_errors);
        $display(  "|       Errors on MULHSU : %0d", MULHSU_errors);
        $display(  "|       Errors on MULHU  : %0d", MULHU_errors);
        $display(  "|       Errors on DIV    : %0d", DIV_errors);
        $display(  "|       Errors on DIVU   : %0d", DIVU_errors);
        $display(  "|       Errors on REM    : %0d", REM_errors);
        $display(  "|       Errors on REMU   : %0d", REMU_errors);
        $display(  "|");
        $display(  "| The full report are in log archive.");
        $display(  "+-------------------------------------------------------------------------------------");

        $fdisplay(log_file,   "+------------------------------------------------------------------------------------+"); 
        $fdisplay(log_file,   "|                                       REPORTS                                      |"); 
        $fdisplay(log_file,   "+------------------------------------------------------------------------------------+"); 
        $fdisplay(log_file,   "| Number of Tests        : %0d", tests);
        $fdisplay(log_file,   "| Total Number of Errors : %0d", errors);
        $fdisplay(log_file,   "|");
        $fdisplay(log_file,   "|       Errors on MUL    : %0d", MUL_errors);
        $fdisplay(log_file,   "|       Errors on MULH   : %0d", MULH_errors);
        $fdisplay(log_file,   "|       Errors on MULHSU : %0d", MULHSU_errors);
        $fdisplay(log_file,   "|       Errors on MULHU  : %0d", MULHU_errors);
        $fdisplay(log_file,   "|       Errors on DIV    : %0d", DIV_errors);
        $fdisplay(log_file,   "|       Errors on DIVU   : %0d", DIVU_errors);
        $fdisplay(log_file,   "|       Errors on REM    : %0d", REM_errors);
        $fdisplay(log_file,   "|       Errors on REMU   : %0d\n| %s", REMU_errors, errors_log);
        $fdisplay(log_file,   "+-------------------------------------------------------------------------------------");
        $finish;

        
    end

endmodule