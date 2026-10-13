// program_counter.sv
module program_counter (
    output logic [31:0] PC, PCPlus4,
    input  logic [31:0] PCTarget, ALUResult,
    input  logic [1:0]  PCSrc,
    input  logic        Reset, CLK
);

assign PCPlus4 = PC + 4;

always_ff @(posedge CLK) begin
    if (Reset)
        PC <= 32'h00000000;
    else begin
        case (PCSrc)
            2'b00: PC <= PCPlus4;
            2'b01: PC <= PCTarget;
            2'b10: PC <= ALUResult;
            default: PC <= PCPlus4;
        endcase
    end
end

endmodule