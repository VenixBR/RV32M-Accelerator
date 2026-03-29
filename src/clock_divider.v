module clock_divider (
    input  wire clk_i, //960MHz
    input  wire rst_i,

    output reg  clk_div5_o, // divided by 5
    output reg  clk_div3_o, // divided by 3
    output reg  clk_div2_o  // divided by 2
);

// Identificar as frequências necessárias e inserir pragmas constraint 
// de criação de clock gerado

    reg  [1:0]count3_s;
    reg [2:0] count5_s;

    reg clk_div_2_s;
    reg clk_div_3_s;
    reg clk_div_5_s;


    // Clock div 2
    always@(posedge clk_i, posedge rst_i) begin
        if(rst_i)
            clk_div_2_s <= 1'b0;
        else    
            clk_div_2_s <= ~clk_div_2_s;
    end
    assign clk_div2_o = clk_div_2_s;


    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            count3_s <= 2'b00;
            clk_div_3_s <= 1'b0;
        end else begin
            if (count3_s == 2'b10)
                count3_s <= 2'b00;
            else
                count3_s <= count3_s + 2'b01;

            if (count3_s == 2'b00)
                clk_div_3_s <= 1'b1;
            else
                clk_div_3_s <= 1'b0;
        end
    end


    assign clk_div3_o = clk_div_3_s;



    // Clock div 5
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            count5_s <= 3'b000;
            clk_div_5_s <= 1'b0;
        end else begin
            if (count5_s == 3'b100)
                count5_s <= 3'b000;
            else
                count5_s <= count5_s + 3'b001;

            if (count5_s == 3'b000 || count5_s == 3'b001)
                clk_div_5_s <= 1'b1;
            else
                clk_div_5_s <= 1'b0;
        end
    end
    assign clk_div5_o = clk_div_5_s;



endmodule