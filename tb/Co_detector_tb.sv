module Co_detector_tb;

    reg [31:0] A, B, C, D;
    wire [1:0] Co;

    Co_detector DUT (
        .A_i(A),
        .B_i(B),
        .C_i(C),
        .D_i(D),
        .Co_o(Co)
    );

    reg [33:0] A_ext, B_ext, C_ext, D_ext, result;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);

        A = 32'h00000001;
        B = 32'h00000002;
        C = 32'h00000003;
        D = 32'h00000004;
        A_ext = {2'b00, A};
        B_ext = {2'b00, B};
        C_ext = {2'b00, C};
        D_ext = {2'b00, D};
        result = A_ext + B_ext + C_ext + D_ext;

        #1

        $display("\n+-------------+--------+");
        $display(  "| Co Expected | Output |");
        $display(  "+-------------+--------+");
        $display(  "| %b          | %b     |", result[33:32], Co);

        #1
        A = 32'hFFFFFFFF;
        B = 32'h00000001;
        C = 32'h00000000;
        D = 32'h00000000;
        A_ext = {2'b00, A};
        B_ext = {2'b00, B};
        C_ext = {2'b00, C};
        D_ext = {2'b00, D};
        result = A_ext + B_ext + C_ext + D_ext;
        #1
        $display(  "| %b          | %b     |", result[33:32], Co);
        #1
        A = 32'hFFFFFFFF;
        B = 32'hFFFFFFFF;
        C = 32'h00000002;
        D = 32'h00000000;
        A_ext = {2'b00, A};
        B_ext = {2'b00, B};
        C_ext = {2'b00, C};
        D_ext = {2'b00, D};
        result = A_ext + B_ext + C_ext + D_ext;
        #1
        $display(  "| %b          | %b     |", result[33:32], Co);
        #1
        A = 32'hFFFFFFFF;
        B = 32'hFFFFFFFF;
        C = 32'hFFFFFFFF;
        D = 32'h00000003;
        A_ext = {2'b00, A};
        B_ext = {2'b00, B};
        C_ext = {2'b00, C};
        D_ext = {2'b00, D};
        result = A_ext + B_ext + C_ext + D_ext;
        #1
        $display(  "| %b          | %b     |", result[33:32], Co);
        #1
        A = 32'hFFFFFFFF;
        B = 32'h00000000;
        C = 32'hFFFFFFFF;
        D = 32'h00000000;
        A_ext = {2'b00, A}; B_ext = {2'b00, B}; C_ext = {2'b00, C}; D_ext = {2'b00, D};
        result = A_ext + B_ext + C_ext + D_ext;
        #1 $display(  "| %b          | %b     |", result[33:32], Co);
        A = 32'hFFFFFFFF;
        B = 32'hFFFFFFFF;
        C = 32'hFFFFFFFF;
        D = 32'hFFFFFFFF;
        A_ext = {2'b00, A}; B_ext = {2'b00, B}; C_ext = {2'b00, C}; D_ext = {2'b00, D};
        result = A_ext + B_ext + C_ext + D_ext;
        #1 $display(  "| %b          | %b     |", result[33:32], Co);
        A = 32'h80000000;
        B = 32'h80000000;
        C = 32'h80000000;
        D = 32'h00000000;
        A_ext = {2'b00, A}; B_ext = {2'b00, B}; C_ext = {2'b00, C}; D_ext = {2'b00, D};
        result = A_ext + B_ext + C_ext + D_ext;
        #1 $display(  "| %b          | %b     |", result[33:32], Co);
        A = 32'hF0000000;
        B = 32'hF0000000;
        C = 32'hF0000000;
        D = 32'hF0000000;
        A_ext = {2'b00, A}; B_ext = {2'b00, B}; C_ext = {2'b00, C}; D_ext = {2'b00, D};
        result = A_ext + B_ext + C_ext + D_ext;
        #1 $display(  "| %b          | %b     |", result[33:32], Co);
        
        $display(  "+-------------+--------+");

        $finish;


    end

endmodule