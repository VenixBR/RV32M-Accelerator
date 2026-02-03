module clock_divider (
    input  wire clk_i, //840MHz
    input  wire rst_i,

    output reg  clk_210MHz_o, // divided by 4
    output reg  clk_280MHz_o, // divided by 3
    output reg  clk_420MHz_o  // divided by 2
);

// Identificar as frequências necessárias e inserir pragmas constraint 
// de criação de clock gerado


endmodule