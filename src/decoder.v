module decoder (

    // INPUTS
    input wire [6:0] opcode_i,
    input wire [2:0] funct3_i,
    input wire [6:0] funct7_i,

    // OUTPUTS
    output reg mult_on_o,
    output reg div_on_o,
    output reg signed_A_o,
    output reg signed_B_o,
    output reg upper_rem_o
);

    localparam opcode_M      = 7'b0110011;
    localparam funct7_M      = 7'b0000001;
    localparam funct3_MUL    = 3'b000;
    localparam funct3_MULH   = 3'b001;
    localparam funct3_MULHSU = 3'b010;
    localparam funct3_MULHU  = 3'b011;
    localparam funct3_DIV    = 3'b100;
    localparam funct3_DIVU   = 3'b101;
    localparam funct3_REM    = 3'b110;
    localparam funct3_REMU   = 3'b111;


    reg active_accelerator_s;

    
    always@* begin

        // Activate the accelerator if it is an M instruction
        if (opcode_i == opcode_M && funct7_i == funct7_M) begin
            active_accelerator_s = 1'b1;
        end
        else begin
            active_accelerator_s = 1'b0;
        end


        // Activate the multiplier or divider
        if (active_accelerator_s == 1'b1 && funct3_i[2] == 1'b0) begin
            mult_on_o = 1'b1;
            div_on_o  = 1'b0;
        end
        else if (active_accelerator_s == 1'b1 && funct3_i[2] == 1'b1) begin
            mult_on_o = 1'b0;
            div_on_o  = 1'b1;
        end
        else begin
            mult_on_o = 1'b0;
            div_on_o  = 1'b0;
        end


        // Set the signals to control the operations
        case (funct3_i)
            funct3_MUL : begin
                signed_A_o  = 1'b0;
                signed_B_o  = 1'b0;
                upper_rem_o = 1'b0;
            end
            funct3_MULH : begin
                signed_A_o  = 1'b1;
                signed_B_o  = 1'b1;
                upper_rem_o = 1'b1;
            end
            funct3_MULHU : begin
                signed_A_o  = 1'b0;
                signed_B_o  = 1'b0;
                upper_rem_o = 1'b1;
            end
            funct3_MULHSU : begin
                signed_A_o  = 1'b1;
                signed_B_o  = 1'b0;
                upper_rem_o = 1'b1;
            end
            funct3_DIV : begin
                signed_A_o  = 1'b1;
                signed_B_o  = 1'b1;
                upper_rem_o = 1'b0;
            end
            funct3_DIVU : begin
                signed_A_o  = 1'b0;
                signed_B_o  = 1'b0;
                upper_rem_o = 1'b0;
            end
            funct3_REM : begin
                signed_A_o  = 1'b1;
                signed_B_o  = 1'b1;
                upper_rem_o = 1'b1;
            end
            funct3_REMU : begin
                signed_A_o  = 1'b0;
                signed_B_o  = 1'b0;
                upper_rem_o = 1'b1;
            end
        endcase
    end

endmodule