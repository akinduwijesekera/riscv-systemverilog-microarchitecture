// control_unit.sv
module control_unit (
    output logic [1:0] PCSrc,
    output logic [1:0] ResultSrc,
    output logic       MemWrite, ALUSrc, RegWrite,
    output logic [4:0] ALUControl,
    output logic [2:0] ImmSrc,
    input  logic [31:0] Instr,
    input  logic        Zero, Negative
);

logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;

assign opcode = Instr[6:0];
assign funct3 = Instr[14:12];
assign funct7 = Instr[31:25];

always_comb begin
    RegWrite   = 0;
    ALUSrc     = 0;
    MemWrite   = 0;
    PCSrc      = 2'b00;
    ResultSrc  = 2'b00;
    ALUControl = 5'b00000;
    ImmSrc     = 3'b000;

    case (opcode)

        // R-type: add, sub, or, and, sll, srl, slt
        7'b0110011: begin
            RegWrite  = 1;
            ALUSrc    = 0;
            MemWrite  = 0;
            PCSrc     = 2'b00;
            ResultSrc = 2'b01;
            ImmSrc    = 3'b000;
            case (funct3)
                3'b000: begin
                    if (funct7 == 7'b0100000)
                        ALUControl = 5'b01010; // sub
                    else
                        ALUControl = 5'b00010; // add
                end
                3'b111: ALUControl = 5'b00110; // and
                3'b110: ALUControl = 5'b00111; // or
                3'b001: ALUControl = 5'b00000; // sll
                3'b101: ALUControl = 5'b10000; // srl
                3'b010: ALUControl = 5'b01001; // slt
                default: ALUControl = 5'b00000;
            endcase
        end

        // I-type ALU: addi, ori, andi, slli, srli, slti
        7'b0010011: begin
            RegWrite  = 1;
            ALUSrc    = 1;
            MemWrite  = 0;
            PCSrc     = 2'b00;
            ResultSrc = 2'b01;
            ImmSrc    = 3'b000;
            case (funct3)
                3'b000: ALUControl = 5'b00010; // addi
                3'b111: ALUControl = 5'b00110; // andi
                3'b110: ALUControl = 5'b00111; // ori
                3'b001: ALUControl = 5'b00000; // slli
                3'b101: ALUControl = 5'b10000; // srli
                3'b010: ALUControl = 5'b01001; // slti
                default: ALUControl = 5'b00000;
            endcase
        end

        // Load word
        7'b0000011: begin
            RegWrite   = 1;
            ALUSrc     = 1;
            MemWrite   = 0;
            PCSrc      = 2'b00;
            ResultSrc  = 2'b10;
            ImmSrc     = 3'b000;
            ALUControl = 5'b00010;
        end

        // Store word
        7'b0100011: begin
            RegWrite   = 0;
            ALUSrc     = 1;
            MemWrite   = 1;
            PCSrc      = 2'b00;
            ImmSrc     = 3'b001;
            ALUControl = 5'b00010;
        end

        // B-type: beq, bne, blt, bge
        7'b1100011: begin
            RegWrite   = 0;
            ALUSrc     = 0;
            MemWrite   = 0;
            ImmSrc     = 3'b010;
            ALUControl = 5'b01010;
            case (funct3)
                3'b000: PCSrc = (Zero)      ? 2'b01 : 2'b00; // beq
                3'b001: PCSrc = (!Zero)     ? 2'b01 : 2'b00; // bne
                3'b100: PCSrc = (Negative)  ? 2'b01 : 2'b00; // blt
                3'b101: PCSrc = (!Negative) ? 2'b01 : 2'b00; // bge
                default: PCSrc = 2'b00;
            endcase
        end

        // JAL
        7'b1101111: begin
            RegWrite   = 1;
            ALUSrc     = 0;
            MemWrite   = 0;
            ImmSrc     = 3'b100;
            PCSrc      = 2'b01;
            ResultSrc  = 2'b11;
            ALUControl = 5'b00000;
        end

        // JALR
        7'b1100111: begin
            RegWrite   = 1;
            ALUSrc     = 1;
            MemWrite   = 0;
            ImmSrc     = 3'b000;
            PCSrc      = 2'b10;
            ResultSrc  = 2'b11;
            ALUControl = 5'b00010;
        end

        // LUI
        7'b0110111: begin
            RegWrite   = 1;
            ALUSrc     = 1;
            MemWrite   = 0;
            ImmSrc     = 3'b011;
            PCSrc      = 2'b00;
            ResultSrc  = 2'b00;
            ALUControl = 5'b00000;
        end

        default: begin
            RegWrite   = 0;
            ALUSrc     = 0;
            MemWrite   = 0;
            PCSrc      = 2'b00;
            ResultSrc  = 2'b00;
            ALUControl = 5'b00000;
            ImmSrc     = 3'b000;
        end

    endcase
end

endmodule