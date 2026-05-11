`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:54:53 AM
// Design Name: 
// Module Name: Execute
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


module Execute(
    input  wire        CLK, EN, Reset, ID_EX_HazardDetected, HazardDetected,
    input  wire        imm, MEM_WB_MemToReg, MEM_WB_RegWrite, UpperImm, RetAddr,
    input  wire        RegSrc1, RegSrc2, prevMemToReg, prevRegWrite, prevMemWrite,
    input  wire [31:0] PC, ReadData1, previousReadData2, ImmediateOutput, WB_WriteData,
    input  wire [4:0]  ID_RS1, ID_RS2, prevWriteAddress, MEM_WB_WriteAddress, prevReadReg1, prevReadReg2,
    input  wire [2:0]  prevFunc3, ALUOp,
    input  wire [6:0]  Opcode,
    input  wire [6:0]  Func7,
    output reg  [2:0]  Func3,
    output reg  [31:0] ALUResult, ReadData2, exReadData1, exImmediateOutput,
    output wire [31:0] iALUResult,
    output reg  [4:0]  WriteAddress,
    output reg         MemToReg, RegWrite, MemWrite,
    output wire        ForwardMemToRegData_RS1, ForwardMemToRegData_RS2,
    output wire        Forward_ID_EX_ALU_To_ID_A, Forward_ID_EX_ALU_To_ID_B,
    output wire        Forward_EX_MEM_ALU_To_ID_A, Forward_EX_MEM_ALU_To_ID_B
);

    wire [3:0]  ALUOperation;
    reg  [31:0] DataA, DataB, FinalReadData2;
    wire        ForwardALU_A, ForwardALU_B;
    wire        ForwardMemToRegData_A, ForwardMemToRegData_B;

    // DataA
    always @(*) begin
        if (UpperImm)
            DataA = 32'b0;
        else if (RetAddr)
            DataA = PC;
        else if (ForwardALU_A)
            DataA = ALUResult;
        else if (ForwardMemToRegData_A && (Opcode != 7'b1100111))
            DataA = WB_WriteData;
        else if (RegSrc1)
            DataA = ReadData1;
        else
            DataA = PC;
    end

    // DataB + FinalReadData2
    always @(*) begin
        FinalReadData2 = previousReadData2;
        DataB = 32'b0;

        if (ForwardALU_B)
            FinalReadData2 = ALUResult;
        else if (ForwardMemToRegData_B)
            FinalReadData2 = WB_WriteData;

        if (imm)
            DataB = ImmediateOutput;
        else if (RetAddr)
            DataB = 32'd4;
        else if (RegSrc2)
            DataB = FinalReadData2;
    end

    ALUControl ALUCU(
        .ALUOp        (ALUOp),
        .func3        (prevFunc3),
        .func7        (Func7),
        .ALUOperation (ALUOperation)
    );

    ALU ALU(
        .dataA        (DataA),
        .dataB        (DataB),
        .ALUOperation (ALUOperation),
        .ALUOutput    (iALUResult)
    );

    ForwardingUnit FU(
        .EX_MEM_RD                 (WriteAddress),
        .MEM_WB_RD                 (MEM_WB_WriteAddress),
        .ID_EX_RS1                 (prevReadReg1),
        .ID_EX_RS2                 (prevReadReg2),
        .ID_RS1                    (ID_RS1),
        .ID_RS2                    (ID_RS2),
        .ID_EX_RD                  (prevWriteAddress),
        .ID_EX_RegWrite            (prevRegWrite),
        .EX_MEM_RegWrite           (RegWrite),
        .MEM_WB_RegWrite           (MEM_WB_RegWrite),
        .MemToReg                  (MEM_WB_MemToReg),
        .ForwardALU_A              (ForwardALU_A),
        .ForwardALU_B              (ForwardALU_B),
        .ForwardMemToRegData_A     (ForwardMemToRegData_A),
        .ForwardMemToRegData_B     (ForwardMemToRegData_B),
        .ForwardMemToRegData_RS1   (ForwardMemToRegData_RS1),
        .ForwardMemToRegData_RS2   (ForwardMemToRegData_RS2),
        .Forward_ID_EX_ALU_To_ID_A (Forward_ID_EX_ALU_To_ID_A),
        .Forward_ID_EX_ALU_To_ID_B (Forward_ID_EX_ALU_To_ID_B),
        .Forward_EX_MEM_ALU_To_ID_A(Forward_EX_MEM_ALU_To_ID_A),
        .Forward_EX_MEM_ALU_To_ID_B(Forward_EX_MEM_ALU_To_ID_B)
    );

    always @(posedge CLK) begin
        if (Reset || ID_EX_HazardDetected) begin
            MemWrite          <= 1'b0;
            RegWrite          <= 1'b0;
            MemToReg          <= 1'b0;
            ALUResult         <= 32'b0;
            ReadData2         <= 32'b0;
            Func3             <= 3'b0;
            exReadData1       <= 32'b0;
            exImmediateOutput <= 32'b0;
            WriteAddress      <= 5'b0;
        end
        else if (EN) begin
            MemWrite          <= prevMemWrite;
            RegWrite          <= prevRegWrite;
            MemToReg          <= prevMemToReg;
            ALUResult         <= iALUResult;
            ReadData2         <= FinalReadData2;
            Func3             <= prevFunc3;
            exReadData1       <= ReadData1;
            exImmediateOutput <= ImmediateOutput;
            WriteAddress      <= prevWriteAddress;
        end
    end

endmodule 

