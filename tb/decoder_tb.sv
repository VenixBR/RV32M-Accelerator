module decoder_tb;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic mult_on;
    logic div_on;
    logic sigA;
    logic sigB;
    logic upper_rem;

    decoder DUT(
        .opcode_i   ( opcode    ),
        .funct3_i   ( funct3    ),
        .funct7_i   ( funct7    ),
        .mult_on_o  ( mult_on   ),
        .div_on_o   ( div_on    ),
        .signed_A_o ( sigA      ),
        .signed_B_o ( sigB      ),
        .upper_rem_o( upper_rem )
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);

        $display("\n+-----------------------------------------------------------------------------------+");
        $display(  "| CORRECT OPCODE : 0110011                                                          |");
        $display(  "| CORRECT FUNCT7 : 0000001                                                          |");
        $display(  "| CORRECT FUNCT3                                                                    |");
        $display(  "|     MUL    : 000        DIV  : 100                                                |");
        $display(  "|     MULH   : 001        DIVU : 101                                                |");
        $display(  "|     MULHSU : 010        REM  : 110                                                |");
        $display(  "|     MULHU  : 011        REMU : 111                                                |");
        $display(  "+---------+---------+--------+------------------------------------------------------+");
        $display(  "| OPCODE  | FUNCT7  | FUNCT3 |                      OUTPUTS                         |");
        $display(  "+---------+---------+--------+------------------------------------------------------+");

        opcode = 7'b0111011; // Invalid
        funct7 = 7'b0000001; // Valid
        funct3 = 3'b000;     // MUL
        #1
        $display(  "| %b | %b |   %b  | mult_on=%b div_on=%b signed_A=%b signed_B=%b upper_rem=%b |", 
                    opcode, funct7, funct3, mult_on, div_on, sigA, sigB, upper_rem);
        opcode = 7'b0110011; // Valid
        funct7 = 7'b0100001; // Invalid
        funct3 = 3'b000;     // MUL
        #1
        $display(  "| %b | %b |   %b  | mult_on=%b div_on=%b signed_A=%b signed_B=%b upper_rem=%b |", 
                    opcode, funct7, funct3, mult_on, div_on, sigA, sigB, upper_rem);

        opcode = 7'b0111011; // Invalid
        funct7 = 7'b0100001; // Invalid
        funct3 = 3'b000;     // MUL
        #1
        $display(  "| %b | %b |   %b  | mult_on=%b div_on=%b signed_A=%b signed_B=%b upper_rem=%b |", 
                    opcode, funct7, funct3, mult_on, div_on, sigA, sigB, upper_rem);

        $display(  "+---------+---------+--------+------------------------------------------------------+");


        opcode = 7'b0110011; // Valid
        funct7 = 7'b0000001; // Valid
        
        funct3 = 3'b000;     // MUL
        #1
        $display(  "| %b | %b |   %b  | mult_on=%b div_on=%b signed_A=%b signed_B=%b upper_rem=%b |", 
                    opcode, funct7, funct3, mult_on, div_on, sigA, sigB, upper_rem);


        funct3 = 3'b001;     // MULH
        #1
        $display(  "| %b | %b |   %b  | mult_on=%b div_on=%b signed_A=%b signed_B=%b upper_rem=%b |", 
                    opcode, funct7, funct3, mult_on, div_on, sigA, sigB, upper_rem);


        funct3 = 3'b010;     // MULSU
        #1
        $display(  "| %b | %b |   %b  | mult_on=%b div_on=%b signed_A=%b signed_B=%b upper_rem=%b |", 
                    opcode, funct7, funct3, mult_on, div_on, sigA, sigB, upper_rem);


        funct3 = 3'b011;     // MULHU
        #1
        $display(  "| %b | %b |   %b  | mult_on=%b div_on=%b signed_A=%b signed_B=%b upper_rem=%b |", 
                    opcode, funct7, funct3, mult_on, div_on, sigA, sigB, upper_rem);


        funct3 = 3'b100;     // DIV
        #1
        $display(  "| %b | %b |   %b  | mult_on=%b div_on=%b signed_A=%b signed_B=%b upper_rem=%b |", 
                    opcode, funct7, funct3, mult_on, div_on, sigA, sigB, upper_rem);

        funct3 = 3'b101;     // DIVU
        #1
        $display(  "| %b | %b |   %b  | mult_on=%b div_on=%b signed_A=%b signed_B=%b upper_rem=%b |", 
                    opcode, funct7, funct3, mult_on, div_on, sigA, sigB, upper_rem);

        funct3 = 3'b110;     // REM
        #1
        $display(  "| %b | %b |   %b  | mult_on=%b div_on=%b signed_A=%b signed_B=%b upper_rem=%b |", 
                    opcode, funct7, funct3, mult_on, div_on, sigA, sigB, upper_rem);

        funct3 = 3'b111;     // REMU
        #1
        $display(  "| %b | %b |   %b  | mult_on=%b div_on=%b signed_A=%b signed_B=%b upper_rem=%b |", 
                    opcode, funct7, funct3, mult_on, div_on, sigA, sigB, upper_rem);


        $display(  "+---------+---------+--------+------------------------------------------------------+\n");
        $finish;
    end

endmodule