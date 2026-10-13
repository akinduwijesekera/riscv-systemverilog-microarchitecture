`timescale 1ns/1ps
`include "control_unit.sv"

module control_unit_tb;

    logic [1:0] PCSrc;
    logic [1:0] ResultSrc;
    logic       MemWrite, ALUSrc, RegWrite;
    logic [4:0] ALUControl;
    logic [2:0] ImmSrc;
    logic [31:0] Instr;
    logic        Zero, Negative;

    control_unit uut (
        .PCSrc(PCSrc),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .ImmSrc(ImmSrc),
        .Instr(Instr),
        .Zero(Zero),
        .Negative(Negative)
    );

    initial begin
        // R-type add (opcode=0110011, funct3=000, funct7=0000000)
        Instr = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
        Zero = 0; Negative = 0;
        #10;

        // R-type sub (opcode=0110011, funct3=000, funct7=0100000)
        Instr = {7'b0100000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011};
        #10;

        // I-type addi (opcode=0010011, funct3=000)
        Instr = {12'hABC, 5'd1, 3'b000, 5'd2, 7'b0010011};
        #10;

        // Load word lw (opcode=0000011, funct3=010)
        Instr = {12'h004, 5'd1, 3'b010, 5'd2, 7'b0000011};
        #10;

        // Store word sw (opcode=0100011, funct3=010)
        Instr = {7'b0000000, 5'd2, 5'd1, 3'b010, 5'b00100, 7'b0100011};
        #10;

        // beq taken (opcode=1100011, funct3=000, Zero=1)
        Instr = {7'b0000000, 5'd0, 5'd1, 3'b000, 5'd2, 7'b1100011};
        Zero = 1;
        #10;

        // beq not taken (Zero=0)
        Zero = 0;
        #10;

        // bne taken (funct3=001, Zero=0)
        Instr = {7'b0000000, 5'd0, 5'd1, 3'b001, 5'd2, 7'b1100011};
        Zero = 0;
        #10;

        // blt taken (funct3=100, Negative=1)
        Instr = {7'b0000000, 5'd0, 5'd1, 3'b100, 5'd2, 7'b1100011};
        Negative = 1;
        #10;

        // bge taken (funct3=101, Negative=0)
        Instr = {7'b0000000, 5'd0, 5'd1, 3'b101, 5'd2, 7'b1100011};
        Negative = 0;
        #10;

        // jal (opcode=1101111)
        Instr = {20'hABCDE, 5'd1, 7'b1101111};
        #10;

        // jalr (opcode=1100111, funct3=000)
        Instr = {12'h004, 5'd1, 3'b000, 5'd2, 7'b1100111};
        #10;

        // lui (opcode=0110111)
        Instr = {20'hABCDE, 5'd1, 7'b0110111};
        #10;

        $finish;
    end

    initial begin
        $monitor("Time=%0t | Instr=%h | PCSrc=%b | ResultSrc=%b | MemWrite=%b | ALUSrc=%b | RegWrite=%b | ALUControl=%b | ImmSrc=%b",
                  $time, Instr, PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite, ALUControl, ImmSrc);
    end

    initial begin
        $dumpfile("control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);
    end

endmodule