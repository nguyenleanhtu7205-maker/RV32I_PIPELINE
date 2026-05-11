`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:53:09 AM
// Design Name: 
// Module Name: InstructionFetch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module InstructionFetch(
    input  wire        IF_Flush, CLK, EN, ONE, Reset,
    input  wire        JumpReg, Jump, Branch, RetainPC, RetainIF_ID,
    input  wire        Forward_ID_EX_ALU_To_ID_A, Forward_EX_MEM_ALU_To_ID_A, ForwardMemToRegData_RS1,
    input  wire [31:0] ImmediateOutput, ReadData1, WriteData, EX_ALUResult, EX_MEM_ALUResult,
    input  wire [31:0] IF_ID_ReadData1,
    // ? Thêm AXI port cho IMEM
    input  wire        bram_clka,
    input  wire        bram_ena,
    input  wire [3:0]  bram_wea,       
    input  wire [31:0] bram_addra,     
    input  wire [31:0] bram_dina,
    output wire [31:0] bram_douta,
    output reg  [31:0] Instruction, PC,
    output wire [31:0] PCcomputed
);

    wire [31:0] InstructionFetched;
    reg  [31:0] ForwardedRS1;

    always @(*) begin
        if (Forward_ID_EX_ALU_To_ID_A)
            ForwardedRS1 = EX_ALUResult;
        else if (Forward_EX_MEM_ALU_To_ID_A)
            ForwardedRS1 = EX_MEM_ALUResult;
        else if (ForwardMemToRegData_RS1)
            ForwardedRS1 = WriteData;
        else
            ForwardedRS1 = IF_ID_ReadData1;
    end

    ProgramCounter ProgCount(
        .CLK             (CLK),
        .Reset           (Reset),
        .JumpReg         (JumpReg),
        .Jump            (Jump),
        .Branch          (Branch),
        .IF_ID_PC        (PC),
        .ONE             (ONE),
        .ImmediateOutput (ImmediateOutput),
        .IF_ID_ReadData1 (ForwardedRS1),
        .ReadData1       (ReadData1),
        .PC              (PCcomputed),
        .RetainPC        (RetainPC)
    );

    InstructionMemory IM(
        .EN                 (EN),
        .InstructionAddress (PCcomputed),
        .ReadInstruction    (InstructionFetched),
        .clka               (bram_clka),
        .ena                (bram_ena),
        .wea                (bram_wea),
        .addra              (bram_addra),
        .dina               (bram_dina),
        .douta              (bram_douta)
    );

    always @(posedge CLK or posedge Reset) begin
        if (Reset || IF_Flush) begin
            Instruction <= 32'b0;
            PC          <= 32'b0;
        end
        else if (EN && !RetainIF_ID) begin
            Instruction <= InstructionFetched;
            PC          <= PCcomputed;
        end
    end

endmodule 

