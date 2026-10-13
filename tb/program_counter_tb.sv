`timescale 1ns/1ps
`include "program_counter.sv"

module program_counter_tb;

    logic [31:0] PC, PCPlus4;
    logic [31:0] PCTarget, ALUResult;
    logic [1:0]  PCSrc;
    logic        Reset, CLK;

    program_counter uut (
        .PC(PC),
        .PCPlus4(PCPlus4),
        .PCTarget(PCTarget),
        .ALUResult(ALUResult),
        .PCSrc(PCSrc),
        .Reset(Reset),
        .CLK(CLK)
    );

    // 10ns clock period
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end

    initial begin
        // Initialise inputs
        Reset     = 1;
        PCTarget  = 32'h00000010;
        ALUResult = 32'h00000020;
        PCSrc     = 2'b00;

        // Hold reset for one clock cycle
        #10;
        Reset = 0;

        // PCSrc=00: PC increments by 4 each cycle (PCPlus4)
        #20;

        // PCSrc=01: PC jumps to PCTarget (branch/jal)
        PCSrc = 2'b01;
        #10;

        // PCSrc=10: PC jumps to ALUResult (jalr)
        PCSrc = 2'b10;
        #10;

        // PCSrc=00: return to normal sequential execution
        PCSrc = 2'b00;
        #30;

        $finish;
    end

    initial begin
        $monitor("Time=%0t | Reset=%b | PCSrc=%b | PC=%h | PCPlus4=%h",
                  $time, Reset, PCSrc, PC, PCPlus4);
    end

    initial begin
        $dumpfile("program_counter_tb.vcd");
        $dumpvars(0, program_counter_tb);
    end

endmodule
