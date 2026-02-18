module multiplier_tb;

    localparam CLK_PERIOD = 10;
    localparam STAGES = 7;

    logic clk, rst, sigA, sigB, upper, done, mult_on;
    logic [31:0] A_op, B_op, answer;
    logic [6:0] opcode, funct7;
    logic [2:0] funct3;

    multiplier DUT (
    .A_i (A_op),
    .B_i (B_op),
    .writeback_value_o (answer)
    );


    reg [63:0] A_ext, B_ext, AxB;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);

        A_op = 32'h80000001; // 2147483649 ou -2147483647
        B_op = 32'h80010002; // 65538 ou 65538
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {{32{B_op[31]}}, B_op};
        AxB = A_ext * B_ext;
        #1
        $display("\n+-------------+------------+------------+");
        $display(  "| Instruction |  Expected  |   Answer   |");
        $display(  "+-------------+------------+------------+");
        $display(  "| MUL         | 0x%h | 0x%h |", AxB[31:0] ,answer); //0x00010002

        #1

        A_op = 32'h00000009; // 2147483649 ou -2147483647
        B_op = 32'h00000007; // 65538 ou 65538
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {{32{B_op[31]}}, B_op};
        AxB = A_ext * B_ext;
        #1
        $display(  "| MUL         | 0x%h | 0x%h |", AxB[31:0] ,answer); //0x00010002

        #1

        A_op = 32'h00a03009;
        B_op = 32'h00000107;
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {{32{B_op[31]}}, B_op};
        AxB = A_ext * B_ext;
        #1
        $display(  "| MUL         | 0x%h | 0x%h |", AxB[31:0] ,answer); //0x00010002

        #1

        A_op = 32'h0003209;
        B_op = 32'h0000001a;
        A_ext = {{32{A_op[31]}}, A_op};
        B_ext = {{32{B_op[31]}}, B_op};
        AxB = A_ext * B_ext;
        #1
        $display(  "| MUL         | 0x%h | 0x%h |", AxB[31:0] ,answer); //0x00010002
        
        #1
        
        $finish;

        
    end



endmodule