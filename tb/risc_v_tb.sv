`timescale 1ns/1ps
`include "risc_v.sv"

module risc_v_tb;

    // === Signal Declarations ===
    logic [31:0] CPUOut;
    logic [31:0] CPUIn;
    logic        Reset;
    logic        CLK;

    // === Instantiate the DUT ===
    risc_v dut (
        .CPUOut(CPUOut),
        .CPUIn(CPUIn),
        .Reset(Reset),
        .CLK(CLK)
    );

    // === Clock Generation: 10000ns period ===
    initial begin
        CLK = 0;
        forever #5000 CLK = ~CLK;  // 5000ns high + 5000ns low
    end

    // === Stimulus ===
    initial begin
        $dumpfile("risc_v_tb.vcd");
        $dumpvars(0, risc_v_tb);

        Reset = 1;
        CPUIn = 32'h00000000;

        #10000;  // wait 1 clock cycle

        CPUIn = 32'h00000000;  // Input value = 31
        Reset = 0;

        #1000000;  // allow multiple cycles to execute

        Reset = 1;
        #20000;

        $finish;
    end

    // === Monitor ===
    always @(negedge CLK) begin
        $display("t=%0d | CPUIn=%0d | CPUOut=%0d | Reset=%b | PCSrc=%b | PC=%0d | PCTarget=%h | ImmExt=%h | Instr=%h | ALUResult=%0d | RegWrite=%b | MemWrite=%b",
                  $time, CPUIn, CPUOut, Reset,
                  dut.PCSrc, dut.PC, dut.PCTarget,
                  dut.ImmExt, dut.Instr, dut.ALUResult,
                  dut.RegWrite, dut.MemWrite);
    end

endmodule