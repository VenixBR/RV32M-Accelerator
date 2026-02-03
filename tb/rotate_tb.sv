module rotate_tb;

    logic [31:0] operand_s;
    logic [1:0]  rol_amount_s;
    logic [31:0] result_s;

    rotate_left DUT (
        .operand_i    ( operand_s    ),
        .rol_amount_i ( rol_amount_s ),
        .result_o     ( result_s     )
    );

    task test_result ( input logic [31:0] result_exp); begin

            if(result_s !== result_exp) begin
                $display ("ERROR");
                $finish;
            end
        end
    endtask



    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);

        operand_s = 32'b10101010_11001100_00000000_11111111;
        rol_amount_s = 2'b00;
        #1

        $display("\n+-------------------------------------+------------+--------------------------------------+");
        $display(  "|                OPERAND              | ROL AMOUNT |                RESULT                |");
        $display(  "+-------------------------------------+------------+--------------------------------------+");
        $display(  "| %b %b %b %b |     %b     |  %b %b %b %b |", 
                    operand_s[31:24], operand_s[23:16], operand_s[15:8], operand_s[7:0],
                    rol_amount_s, 
                    result_s[31:24], result_s[23:16], result_s[15:8], result_s[7:0]);
        #1 test_result(operand_s);

        #1 rol_amount_s = 2'b01; #1
        $display(  "| %b %b %b %b |     %b     |  %b %b %b %b |", 
                    operand_s[31:24], operand_s[23:16], operand_s[15:8], operand_s[7:0],
                    rol_amount_s, 
                    result_s[31:24], result_s[23:16], result_s[15:8], result_s[7:0]);
        #1 test_result({operand_s[23:16], operand_s[15:8], operand_s[7:0], operand_s[31:24]});

        #1 rol_amount_s = 2'b10; #1
        $display(  "| %b %b %b %b |     %b     |  %b %b %b %b |", 
                    operand_s[31:24], operand_s[23:16], operand_s[15:8], operand_s[7:0],
                    rol_amount_s, 
                    result_s[31:24], result_s[23:16], result_s[15:8], result_s[7:0]);
        #1 test_result({operand_s[15:8], operand_s[7:0], operand_s[31:24], operand_s[23:16]});

        #1 rol_amount_s = 2'b11; #1
        $display(  "| %b %b %b %b |     %b     |  %b %b %b %b |", 
                    operand_s[31:24], operand_s[23:16], operand_s[15:8], operand_s[7:0],
                    rol_amount_s, 
                    result_s[31:24], result_s[23:16], result_s[15:8], result_s[7:0]);
        #1 test_result({operand_s[7:0], operand_s[31:24], operand_s[23:16], operand_s[15:8]});

        $display(  "+-------------------------------------+------------+--------------------------------------+\n");

        $finish; 
    end


endmodule