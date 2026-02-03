module new_multiplier_tb;

    localparam CLK_PERIOD = 10;
    localparam STAGES = 4;

    logic clk, rst, opcode_valid, hold;
    logic [31:0] opcode, A_op, B_op, answer;

    biriscv_multiplier DUV (
        .clk_i               ( clk          ),
        .rst_i               ( rst          ),
        .opcode_valid_i      ( opcode_valid ),
        .opcode_opcode_i     ( opcode       ),
        .opcode_ra_operand_i ( A_op         ),
        .opcode_rb_operand_i ( B_op         ),
        .hold_i              ( hold         ),
        .writeback_value_o   ( answer       )
    );

    always #CLK_PERIOD clk <= ~clk;

    reg [63:0] A_ext, B_ext, AxB;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUV);
        clk = 0;
        rst = 0;
        hold = 0;
        opcode_valid = 1;
        A_op = 32'h80000001; // 2147483649 ou -2147483647
        B_op = 32'h80010002; // 65538 ou 65538

        // A_op = 32'h00000009; // 2147483649 ou -2147483647
        // B_op = 32'h00000007; // 65538 ou 65538
        opcode = 32'b0000001_0101010101_000_01010_0110011; // MUL
        A_ext = {32'h00000000, A_op};
        B_ext = {32'h00000000, B_op};
        AxB = A_ext * B_ext;

        #(CLK_PERIOD/2)
        rst = 1;
        #(3*CLK_PERIOD/2)
        rst = 0;

        
        #((STAGES+1)*CLK_PERIOD)
        hold = 1;
        #((STAGES)*CLK_PERIOD)

        $display("\n+-------------+------------+------------+");
        $display(  "| Instruction |  Expected  |   Answer   |");
        $display(  "+-------------+------------+------------+");
        $display(  "| MUL         | 0x%h | 0x%h |", AxB[31:0] ,answer); //0x00010002
        

        # CLK_PERIOD
        opcode = 32'b0000001_0101010101_001_01010_0110011; // MULH
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {{32{B_op[31]}}, B_op};
        AxB = A_ext * B_ext;
        hold=0;
        #((STAGES+1)*CLK_PERIOD)
        hold = 1;
        #((STAGES)*CLK_PERIOD)

        $display(  "| MULH        | 0x%h | 0x%h |", AxB[63:32] ,answer); //0x00010002

        # CLK_PERIOD
        opcode = 32'b0000001_0101010101_010_01010_0110011; // MULHSU
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {32'h00000000, B_op};
        AxB = A_ext * B_ext;
        hold=0;
        #((STAGES+1)*CLK_PERIOD)
        hold = 1;
        #((STAGES)*CLK_PERIOD)

        $display(  "| MULHSU      | 0x%h | 0x%h |", AxB[63:32] ,answer); //0x00010002

        # CLK_PERIOD
        opcode = 32'b0000001_0101010101_011_01010_0110011; // MULHU
        A_ext = {32'h00000000, A_op};
        B_ext = {32'h00000000, B_op};
        AxB = A_ext * B_ext;
        hold=0;
        #((STAGES+1)*CLK_PERIOD)
        hold = 1;
        #((STAGES)*CLK_PERIOD)

        $display(  "| MULHU       | 0x%h | 0x%h |", AxB[63:32] ,answer); //0x00010002
        $display(  "+-------------+------------+------------+\n");
        $finish;

        
    end



endmodule