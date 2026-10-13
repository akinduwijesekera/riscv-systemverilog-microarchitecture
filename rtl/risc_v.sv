`include "instruction_memory.sv"
`include "reg_file.sv"
`include "extend.sv"
`include "alu.sv"
`include "data_memory_and_io.sv"
`include "program_counter.sv"
`include "control_unit.sv"

module risc_v(
    output logic [31:0] CPUOut,
    input  logic [31:0] CPUIn,
    input  logic Reset, CLK
);

    logic [31:0] Instr, WD3, RD1, RD2, SrcA, SrcB, ALUResult, RD, Result, 
                 ImmExt, PCTarget, PC, PCPlus4;
    logic [4:0]  A1, A2, A3;
    logic        MemWrite, ALUSrc, RegWrite;
    logic        Zero, Negative;
    logic [4:0]  ALUControl;
    logic [2:0]  ImmSrc;
    logic [1:0]  ResultSrc, PCSrc;

    // === Program Counter ===
    program_counter PCU(
        .PC(PC),
        .PCPlus4(PCPlus4),
        .PCTarget(PCTarget),
        .ALUResult(ALUResult),
        .PCSrc(PCSrc),
        .Reset(Reset),
        .CLK(CLK)
    );

    // === Instruction Memory ===
    instruction_memory IMEM(
        .Instr(Instr),
        .PC(PC)
    );

    // === Control Unit ===
    control_unit CU(
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

    // === Register File ===
    assign A1 = Instr[19:15];  // rs1
    assign A2 = Instr[24:20];  // rs2
    assign A3 = Instr[11:7];   // rd

    reg_file RF(
        .RD1(RD1),
        .RD2(RD2),
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .WD3(WD3),
        .WE3(RegWrite),
        .CLK(CLK)
    );

    // === Immediate Extension ===
    extend EXT(
        .ImmExt(ImmExt),
        .Instr(Instr),
        .ImmSrc(ImmSrc)
    );

    // === ALU Source Mux ===
    assign SrcA = RD1;
    assign SrcB = (ALUSrc) ? ImmExt : RD2;

    // === ALU ===
    alu ALU(
        .ALUResult(ALUResult),
        .Zero(Zero),
        .Negative(Negative),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUControl(ALUControl)
    );

    // === PC Target Adder ===
    assign PCTarget = PC + ImmExt;

    // === Data Memory and I/O ===
    data_memory_and_io DMEM(
        .RD(RD),
        .CPUOut(CPUOut),
        .A(ALUResult),
        .WD(RD2),
        .CPUIn(CPUIn),
        .WE(MemWrite),
        .CLK(CLK)
    );

    // === Result Mux ===
    always_comb begin
        case (ResultSrc)
            2'b00: Result = ImmExt;     // lui
            2'b01: Result = ALUResult;  // R-type / I-type arithmetic
            2'b10: Result = RD;         // lw
            2'b11: Result = PCPlus4;    // jal / jalr
            default: Result = 32'b0;
        endcase
    end

    assign WD3 = Result;

endmodule