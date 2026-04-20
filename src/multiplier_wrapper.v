module multiplier_wrapper #(
    parameter N = 32
)(
    input  wire clk_i,
    input  wire rst_i,
    input  wire [N-1:0] opA_i,
    input  wire [N-1:0] opB_i,

    output wire [N*2-1:0] result_o
);
    
    // Sinais internos
    reg  [N-1:0] reg_opA_s;
    reg  [N-1:0] reg_opB_s;
    reg  [N*2-1:0] reg_result_s;
    wire [N*2-1:0] result_s;

    // Registra as entradas A e B
    always@(posedge clk_i, posedge rst_i) begin
        if(rst_i)begin
            reg_opA_s <= {N{1'b0}};
            reg_opB_s <= {N{1'b0}};
        end
        else begin
            reg_opA_s <= opA_i;
            reg_opB_s <= opB_i;
        end
    end

    // Instancia o Multiplicador
    multiplier #(
        .N(N)
    ) multiplier_inst (
        .A_i(reg_opA_s),
        .B_i(reg_opB_s),
        .result_o(result_s)
    );

    // Registra a saida S
    always@(posedge clk_i, posedge rst_i) begin
        if(rst_i)begin
            reg_result_s <= {N*2{1'b0}};
        end
        else begin
            reg_result_s <= result_s;
        end
    end

    // Atribui a saida do circuito a saida do registrador
    assign result_o = reg_result_s;

endmodule