`timescale 1ns/1ps
`include "extend.sv"

module extend_tb;

    logic [31:0] ImmExt;
    logic [31:0] Instr;
    logic [2:0]  ImmSrc;

    extend uut (
        .ImmExt(ImmExt),
        .Instr(Instr),
        .ImmSrc(ImmSrc)
    );

    initial begin
        // I-type: Instr[31:20] = 0xFFC → sign-extended to 0xFFFFFFFC (-4)
        Instr  = {12'hFFC, 5'd1, 3'b010, 5'd2, 7'b0000011};
        ImmSrc = 3'b000;
        #10;

        // S-type: imm = {Instr[31:25], Instr[11:7]} = 0xFFC → 0xFFFFFFFC
        Instr  = {7'b1111111, 5'd2, 5'd1, 3'b010, 5'b11100, 7'b0100011};
        ImmSrc = 3'b001;
        #10;

        // B-type: sample branch offset
        Instr  = {7'b1010101, 5'd0, 5'd1, 3'b000, 5'b10101, 7'b1100011};
        ImmSrc = 3'b010;
        #10;

        // U-type: upper 20 bits → shifted to [31:12], lower 12 zeroed
        Instr  = {20'hABCDE, 5'd1, 7'b0110111};
        ImmSrc = 3'b011;
        #10;

        // J-type: sample jal offset
        Instr  = 32'hF1234567;
        ImmSrc = 3'b100;
        #10;

        $finish;
    end

    initial begin
        $monitor("Time=%0t | ImmSrc=%b | Instr=%h | ImmExt=%h",
                  $time, ImmSrc, Instr, ImmExt);
    end

    initial begin
        $dumpfile("extend_tb.vcd");
        $dumpvars(0, extend_tb);
    end

endmodule