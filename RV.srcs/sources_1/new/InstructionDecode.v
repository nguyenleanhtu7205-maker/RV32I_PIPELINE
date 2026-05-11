`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:54:09 AM
// Design Name: 
// Module Name: InstructionDecode
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


module InstructionDecode(
    input  wire        CLK, Reset, EN, MEM_WB_RegWrite,
    input  wire        ForwardMemToRegData_RS1, ForwardMemToRegData_RS2,
    input  wire        Forward_ID_EX_ALU_To_ID_A, Forward_ID_EX_ALU_To_ID_B,
    input  wire        Forward_EX_MEM_ALU_To_ID_A, Forward_EX_MEM_ALU_To_ID_B,
    input  wire [4:0]  prevReadReg1, prevReadReg2, MEM_WB_WriteAddress,
    input  wire [6:0]  prevOpcode,
    input  wire [31:0] previousPC, ReadInstruction, WriteData, EX_ALUResult, EX_MEM_ALUResult,
    output reg  [2:0]  ALUOp, Func3,
    output reg  [6:0]  Func7,
    output reg  [6:0]  Opcode,
    output reg  [4:0]  WriteAddress, ReadReg1, ReadReg2,
    output reg  [31:0] ReadData1, ReadData2, PC, ImmediateOutput,
    output wire [31:0] dataA,
    output wire [31:0] ImmediateOutputforPC,
    output reg         ID_EX_HazardDetected, imm, 
    output wire        JumpReg, Jump, Branch,
    output reg         RegSrc1, MemToReg, RegSrc2, RegWrite, UpperImm, MemWrite, RetAddr,
    output wire        ID_Flush, ONE, HazardDetected,
    output wire        rvfi_i_bool
);

    wire [2:0]  iALUOp;
    wire [31:0] iReadData1, iReadData2;
    reg  [31:0] dataB;
    wire        iRegSrc1, iRegSrc2, iMemToReg, iUpperImm, iRegWrite, iMemWrite, iRetAddr, iimm;

    ControlUnit CU(
        .Opcode     (prevOpcode),
        .ONE        (ONE),
        .ALUOp      (iALUOp),
        .JumpReg    (JumpReg),
        .Jump       (Jump),
        .Branch     (Branch),
        .RegSrc1    (iRegSrc1),
        .RegSrc2    (iRegSrc2),
        .UpperImm   (iUpperImm),
        .RegWrite   (iRegWrite),
        .MemWrite   (iMemWrite),
        .MemToReg   (iMemToReg),
        .RetAddr    (iRetAddr),
        .imm        (iimm),
        .ID_Flush   (ID_Flush),
        .rvfi_i_bool(rvfi_i_bool)
    );

    // dataA combinational
    reg [31:0] dataA_reg;
    assign dataA = dataA_reg;

    always @(*) begin
        if (HazardDetected)
            dataA_reg = WriteData;
        else if (Forward_ID_EX_ALU_To_ID_A)
            dataA_reg = EX_ALUResult;
        else if (Forward_EX_MEM_ALU_To_ID_A)
            dataA_reg = EX_MEM_ALUResult;
        else if (ForwardMemToRegData_RS1)
            dataA_reg = WriteData;
        else
            dataA_reg = iReadData1;

        if (HazardDetected)
            dataB = WriteData;
        else if (Forward_ID_EX_ALU_To_ID_B)
            dataB = EX_ALUResult;
        else if (Forward_EX_MEM_ALU_To_ID_B)
            dataB = EX_MEM_ALUResult;
        else if (ForwardMemToRegData_RS2)
            dataB = WriteData;
        else
            dataB = iReadData2;
    end

    BranchDecisionUnit BDU(
        .Opcode(prevOpcode),
        .Func3 (ReadInstruction[14:12]),
        .dataA (dataA_reg),
        .dataB (dataB),
        .ONE   (ONE)
    );

    RegisterFile RF(
        .CLK          (CLK),
        .Reset        (Reset),
        .RegWrite     (MEM_WB_RegWrite),
        .ReadReg1     (prevReadReg1),
        .ReadReg2     (prevReadReg2),
        .WriteAddress (MEM_WB_WriteAddress),
        .WriteData    (WriteData),
        .ReadData1    (iReadData1),
        .ReadData2    (iReadData2)
    );

    ImmediateGenerator IG(
        .Instruction    (ReadInstruction),
        .ImmediateOutput(ImmediateOutputforPC)
    );

    HazardDetectionUnit HDU(
        .MemToReg      (MemToReg),
        .ID_EX_RD      (WriteAddress),
        .IF_ID_RS1     (prevReadReg1),
        .IF_ID_RS2     (prevReadReg2),
        .HazardDetected(HazardDetected)
    );

    always @(posedge CLK) begin
        if (Reset || HazardDetected) begin
            ID_EX_HazardDetected <= (Branch) ? 1'b1 : 1'b0;
            RegSrc1          <= 1'b0;
            RegSrc2          <= 1'b0;
            UpperImm         <= 1'b0;
            MemWrite         <= 1'b0;
            RegWrite         <= 1'b0;
            MemToReg         <= 1'b0;
            RetAddr          <= 1'b0;
            ALUOp            <= 3'b000;
            ReadData1        <= 32'b0;
            ReadData2        <= 32'b0;
            PC               <= 32'b0;
            ImmediateOutput  <= 32'b0;
            Func3            <= 3'b0;
            Func7            <= 7'b0;
            WriteAddress     <= 5'b0;
            ReadReg1         <= 5'b0;
            ReadReg2         <= 5'b0;
            Opcode           <= 7'b0;
            imm              <= 1'b0;
        end
        else if (EN) begin
            ID_EX_HazardDetected <= 1'b0;
            RegSrc1          <= iRegSrc1;
            RegSrc2          <= iRegSrc2;
            UpperImm         <= iUpperImm;
            MemWrite         <= iMemWrite;
            RegWrite         <= iRegWrite;
            MemToReg         <= iMemToReg;
            RetAddr          <= iRetAddr;
            ALUOp            <= iALUOp;
            ReadData1        <= (ForwardMemToRegData_RS1) ? WriteData : iReadData1;
            ReadData2        <= (ForwardMemToRegData_RS2) ? WriteData : iReadData2;
            PC               <= previousPC;
            ImmediateOutput  <= ImmediateOutputforPC;
            Func3            <= ReadInstruction[14:12];
            Func7            <= ReadInstruction[31:25];
            WriteAddress     <= ReadInstruction[11:7];
            ReadReg1         <= prevReadReg1;
            ReadReg2         <= prevReadReg2;
            Opcode           <= prevOpcode;
            imm              <= iimm;
        end
    end

endmodule 

