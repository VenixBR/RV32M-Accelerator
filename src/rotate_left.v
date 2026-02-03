// This module can rotate a number per 8 mutipliples with 2 bits

module rotate_left (
    input wire [31:0] operand_i,
    input wire [1:0]  rol_amount_i,

    output reg  [31:0] result_o
);

    reg [7:0] po_1_s;
    reg [7:0] po_2_s;
    reg [7:0] po_3_s;
    reg [7:0] po_4_s;

    always@* begin
        po_1_s = operand_i[7:0];
        po_2_s = operand_i[15:8];
        po_3_s = operand_i[23:16];
        po_4_s = operand_i[31:24];

        case (rol_amount_i)
            2'b00 : begin result_o = operand_i; end                         // 0*8
            2'b01 : begin result_o = {po_3_s, po_2_s, po_1_s, po_4_s}; end  // 1*8
            2'b10 : begin result_o = {po_2_s, po_1_s, po_4_s, po_3_s}; end  // 2*8
            2'b11 : begin result_o = {po_1_s, po_4_s, po_3_s, po_2_s}; end  // 3*8
        endcase
    end

endmodule