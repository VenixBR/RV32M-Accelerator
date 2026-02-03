module M_accelerator_wrapper (
    input  wire clk_mult_i,
    input  wire clk_div_i,
    input  wire clk_core_i,
    input  wire rst_i,

    input  wire [6:0]  opcode_i,
    input  wire [2:0]  funct3_i,
    input  wire [6:0]  funct7_i,
    input  wire [31:0] op_A_i,
    input  wire [31:0] op_b_i,

    output reg  [31:0] result_o,
    output reg  done_o
);



endmodule