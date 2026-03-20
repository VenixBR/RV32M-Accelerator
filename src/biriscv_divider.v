module biriscv_divider
(
    // Clocks e Resets
     input           clk_i
    ,input           rst_i
    
    // Controle vindo do Decoder
    ,input           opcode_valid_i // Sinal de trigger geral
    ,input           div_on_i       // Habilita o divisor
    ,input           signed_A_i     // Operando A é com sinal?
    ,input           signed_B_i     // Operando B é com sinal?
    ,input           upper_rem_i    // Queremos o resto (1) ou quociente (0)?

    // Dados
    ,input  [ 31:0]  operand_a_i
    ,input  [ 31:0]  operand_b_i  

    // Outputs
    ,output          writeback_valid_o
    ,output [ 31:0]  writeback_value_o
    ,output          div_by_zero_o
);

//-------------------------------------------------------------
// Registers / Wires
//-------------------------------------------------------------
reg          valid_q;
reg  [31:0]  wb_result_q;
reg          div_by_zero_q;

//-------------------------------------------------------------
// Core Registers
//-------------------------------------------------------------
reg [31:0] dividend_q;
reg [62:0] divisor_q;
reg [31:0] quotient_q;
reg [31:0] q_mask_q;

reg        is_quotient_q;
reg        div_busy_q;
reg        invert_res_q;

// ESTADOS DO PIPELINE
reg        div_calc_clz_q; 
reg        div_prepare_q;  

// Pipeline Registers
reg [5:0]  saved_shift_amt_q;
reg [31:0] saved_op_b_abs_q;

//-------------------------------------------------------------
// Lógica de Controle Inicial
//-------------------------------------------------------------
// O divisor só inicia se a instrução for válida E o decoder autorizar
wire div_start_w    = opcode_valid_i & div_on_i;

wire div_complete_w = (!(|q_mask_q) || !(|dividend_q))
                    & div_busy_q 
                    & !div_prepare_q 
                    & !div_calc_clz_q;

//-------------------------------------------------------------
// Pre-calculation (Absolutos baseados no Decoder)
//-------------------------------------------------------------
wire [31:0] op_a_abs_w;
wire [31:0] op_b_abs_w;

// Usa as flags signed_A_i e signed_B_i do seu decoder
assign op_a_abs_w = (signed_A_i && operand_a_i[31])
                  ? -operand_a_i
                  : operand_a_i;

assign op_b_abs_w = (signed_B_i && operand_b_i[31])
                  ? -operand_b_i
                  : operand_b_i;


// Função CLZ (Count Leading Zeros)
function [5:0] clz;
    input [31:0] data;
    integer i;
    begin
        clz = 32;
        for (i = 31; i >= 0; i = i - 1) begin
            if (data[i] && (clz == 32)) 
                clz = 31 - i;
        end
    end
endfunction

wire [5:0] lz_a_w;
wire [5:0] lz_b_w;
wire [5:0] diff_lz_w;

assign lz_a_w    = clz(dividend_q);       
assign lz_b_w    = clz(saved_op_b_abs_q); 
assign diff_lz_w = (lz_b_w > lz_a_w)
                 ? (lz_b_w - lz_a_w)
                 : 6'b0;

//-------------------------------------------------------------
// Speculative Subtraction
//-------------------------------------------------------------
wire [32:0] sub_res_w = {1'b0, dividend_q} - {1'b0, divisor_q[31:0]};
wire divisor_high_is_zero = (divisor_q[62:32] == 31'b0);
wire can_subtract_w = divisor_high_is_zero && !sub_res_w[32];

//-------------------------------------------------------------
// State Machine
//-------------------------------------------------------------
always @(posedge clk_i or posedge rst_i)
if (rst_i)
begin
    div_busy_q        <= 1'b0;
    div_calc_clz_q    <= 1'b0; 
    div_prepare_q     <= 1'b0;
    
    dividend_q        <= 32'b0;
    divisor_q         <= 63'b0;
    invert_res_q      <= 1'b0;
    quotient_q        <= 32'b0;
    q_mask_q          <= 32'b0;
    is_quotient_q     <= 1'b0;
    div_by_zero_q     <= 1'b0;
    
    saved_shift_amt_q <= 6'b0;
    saved_op_b_abs_q  <= 32'b0;
end
// CICLO 0: Entrada (START)
else if (div_start_w && !div_busy_q && !div_prepare_q && !div_calc_clz_q)
begin

    // Se upper_rem_i for 0, queremos o quociente (DIV). Se for 1, o resto (REM).
    is_quotient_q <= !upper_rem_i;

    // Lógica de inversão de sinal usando as flags do decoder
    // Inverte Quociente: Se for DIV, sinais diferentes, e divisor != 0
    // Inverte Resto: Se for REM e o dividendo for negativo
    invert_res_q <= (!upper_rem_i && signed_A_i && signed_B_i && (operand_a_i[31] != operand_b_i[31]) && |operand_b_i) || 
                    ( upper_rem_i && signed_A_i && operand_a_i[31]);

    // CHECK DE DIVISÃO POR ZERO
    if (op_b_abs_w == 32'b0)
    begin
        div_by_zero_q  <= 1'b1;
        dividend_q     <= operand_a_i; 
        quotient_q     <= 32'hFFFFFFFF;
        
        q_mask_q       <= 32'b0; 
        
        div_calc_clz_q <= 1'b0; 
        div_busy_q     <= 1'b1; 
    end
    else
    begin
        // Fluxo Normal
        div_by_zero_q    <= 1'b0;
        dividend_q       <= op_a_abs_w;
        saved_op_b_abs_q <= op_b_abs_w;
        quotient_q       <= 32'b0;

        div_calc_clz_q   <= 1'b1; 
        div_busy_q       <= 1'b1; 
    end
end

// CICLO 1: CLZ Calc (Pipeline Stage 1)
else if (div_calc_clz_q) 
begin
    saved_shift_amt_q <= diff_lz_w;
        
    // Early Termination Check
    if (saved_op_b_abs_q > dividend_q)
    begin
        q_mask_q <= 32'b0;
    end
            
    div_calc_clz_q <= 1'b0;
    div_prepare_q  <= 1'b1;
end

// CICLO 2: Barrel Shifter (Pipeline Stage 2)
else if (div_prepare_q)
begin
    if (q_mask_q != 32'b0 || (saved_op_b_abs_q <= dividend_q)) 
    begin
        q_mask_q      <= 32'h1 << saved_shift_amt_q;
        divisor_q     <= {31'b0, saved_op_b_abs_q} << saved_shift_amt_q;
        
        // Redundância de segurança
        if (saved_op_b_abs_q > dividend_q) 
             q_mask_q <= 32'b0;
    end
    else
    begin
        divisor_q     <= {31'b0, saved_op_b_abs_q};
    end

    div_prepare_q <= 1'b0;
end

// CICLO 3+: Execução
else if (div_complete_w)
begin
    div_busy_q <= 1'b0;
end
else if (div_busy_q)
begin
    if (can_subtract_w)
    begin
        dividend_q <= sub_res_w[31:0];
        quotient_q <= quotient_q | q_mask_q;
    end
    divisor_q <= {1'b0, divisor_q[62:1]};
    q_mask_q  <= {1'b0, q_mask_q[31:1]};
end

//-------------------------------------------------------------
// Output Generation
//-------------------------------------------------------------
reg [31:0] div_result_r;
always @ *
begin
    div_result_r = 32'b0;

    if (div_by_zero_q)
    begin
        if (is_quotient_q)
            div_result_r = 32'hFFFFFFFF; 
        else
            div_result_r = dividend_q;   
    end
    else
    begin
        if (is_quotient_q)
            div_result_r = invert_res_q ? -quotient_q : quotient_q;
        else
            div_result_r = invert_res_q ? -dividend_q : dividend_q;
    end
end

always @(posedge clk_i or posedge rst_i)
if (rst_i)
    valid_q <= 1'b0;
else
    valid_q <= div_complete_w;

always @(posedge clk_i or posedge rst_i)
if (rst_i)
    wb_result_q <= 32'b0;
else if (div_complete_w)
    wb_result_q <= div_result_r;

assign writeback_valid_o = valid_q;
assign writeback_value_o = wb_result_q;
assign div_by_zero_o     = valid_q & div_by_zero_q;

endmodule
