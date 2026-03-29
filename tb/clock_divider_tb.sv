module clock_divider_tb;

    logic clk, rst, clk_div2, clk_div3, clk_div5;

    clock_divider DUT (
        .clk_i ( clk ),
        .rst_i ( rst ),

        .clk_div2_o ( clk_div2 ),
        .clk_div3_o ( clk_div3 ),
        .clk_div5_o ( clk_div5 )
    );

    always #5 clk <= ~clk;

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);

        clk = 0;
        rst = 0; //0
        #1
        rst = 1; //1
        #1
        rst = 0; //2

        #1000 //1002
        $finish;



    end

endmodule