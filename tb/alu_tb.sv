`timescale 1ns/1ps
`include "alu.sv"

module alu_tb;

    logic signed [31:0] ALUResult;
    logic               Zero, Negative;
    logic signed [31:0] SrcA, SrcB;
    logic [4:0]         ALUControl;

    alu uut (
        .ALUResult(ALUResult),
        .Zero(Zero),
        .Negative(Negative),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUControl(ALUControl)
    );

    initial begin
        // ADD: 10 + 20 = 30
        SrcA = 32'd10; SrcB = 32'd20; ALUControl = 5'b00010;
        #10;

        // SUB: 30 - 10 = 20
        SrcA = 32'd30; SrcB = 32'd10; ALUControl = 5'b01010;
        #10;

        // SUB producing zero: 15 - 15 = 0 (Zero flag should set)
        SrcA = 32'd15; SrcB = 32'd15; ALUControl = 5'b01010;
        #10;

        // SUB producing negative: 5 - 10 = -5 (Negative flag should set)
        SrcA = 32'd5; SrcB = 32'd10; ALUControl = 5'b01010;
        #10;

        // OR: 0x0F0F0F0F | 0xF0F0F0F0 = 0xFFFFFFFF
        SrcA = 32'h0F0F0F0F; SrcB = 32'hF0F0F0F0; ALUControl = 5'b00111;
        #10;

        // AND: 0xFF00FF00 & 0x0F0F0F0F = 0x0F000F00
        SrcA = 32'hFF00FF00; SrcB = 32'h0F0F0F0F; ALUControl = 5'b00110;
        #10;

        // SLL: 1 << 4 = 16
        SrcA = 32'd1; SrcB = 32'd4; ALUControl = 5'b00000;
        #10;

        // SRL: 16 >> 4 = 1
        SrcA = 32'd16; SrcB = 32'd4; ALUControl = 5'b10000;
        #10;

        // SLT: 5 < 10 → result = 1
        SrcA = 32'd5; SrcB = 32'd10; ALUControl = 5'b01001;
        #10;

        // SLT: 10 < 5 → result = 0 (Zero flag should set)
        SrcA = 32'd10; SrcB = 32'd5; ALUControl = 5'b01001;
        #10;

        $finish;
    end

    initial begin
        $monitor("Time=%0t | ALUControl=%b | SrcA=%0d | SrcB=%0d | ALUResult=%0d | Zero=%b | Negative=%b",
                  $time, ALUControl, SrcA, SrcB, ALUResult, Zero, Negative);
    end

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
    end

endmodule