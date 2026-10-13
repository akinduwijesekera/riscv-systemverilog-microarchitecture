// alu.sv
module alu (
    output logic signed [31:0] ALUResult,
    output logic               Zero, Negative,
    input  logic signed [31:0] SrcA, SrcB,
    input  logic [4:0]         ALUControl
);

wire [4:0] shift_amount = SrcB[4:0];   // moved outside always_comb

always_comb begin
    case (ALUControl)
        5'b00010: ALUResult = SrcA + SrcB;                     // add
        5'b01010: ALUResult = SrcA - SrcB;                     // sub
        5'b00111: ALUResult = SrcA | SrcB;                     // or
        5'b00110: ALUResult = SrcA & SrcB;                     // and
        5'b00000: ALUResult = SrcA << shift_amount;            // sll
        5'b10000: ALUResult = $unsigned(SrcA) >> shift_amount; // srl
        5'b01001: ALUResult = (SrcA < SrcB) ? 32'd1 : 32'd0;  // slt
        default:  ALUResult = 32'd0;
    endcase
end

assign Zero     = (ALUResult == 32'd0);
assign Negative = ALUResult[31];

endmodule