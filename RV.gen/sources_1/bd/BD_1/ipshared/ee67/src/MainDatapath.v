`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:57:08 AM
// Design Name: 
// Module Name: MainDatapath
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


module MainDatapath(
    input  wire        CLK, EN, Reset,
    // Bus interface ra ngoài RV_IP
    output wire        bus_en,
    output wire        bus_we,
    output wire [31:0] bus_addr,
    output wire [31:0] bus_wdata,
    output wire [2:0]  bus_funct3,
    output wire [3:0]  bus_mask,
    input  wire [31:0] bus_rdata,
    // ? Thêm AXI port cho IMEM
    input  wire        bram_clka,
    input  wire        bram_ena,
    input  wire [3:0]  bram_wea,
    input  wire [31:0] bram_addra,
    input  wire [31:0] bram_dina,
    output wire [31:0] bram_douta
);

    wire [31:0] IF_PC, IF_Instruction, prevPC;
    wire [31:0] ReadData1_TO_IF, ID_PC, ID_ImmediateOutput, ImmediateOutputforPC;
    wire [31:0] ID_ReadData1, ID_ReadData2;
    wire [31:0] iALUResult, EX_ALUResult, EX_ReadData2, EX_ReadData1, EX_ImmediateOutput;
    wire [31:0] MEM_ReadData, MEM_ALUResult;
    wire [31:0] WB_WriteData;

    wire        ID_EX_HazardDetected;
    wire        ID_ValidInstruction, ID_Flush, ID_imm;
    wire        ID_JumpReg, ID_Jump, ID_Branch;
    wire        ID_RegSrc1, ID_RegSrc2, ID_UpperImm;
    wire        ID_RegWrite, ID_MemWrite, ID_MemToReg, ID_RetAddr;
    wire        HazardDetected, ID_ONE;
    wire        EX_RegWrite, EX_MemWrite, EX_MemToReg;
    wire        MEM_RegWrite, MEM_MemToReg;
    wire        ForwardMemToRegData_RS1, ForwardMemToRegData_RS2;
    wire        Forward_ID_EX_ALU_To_ID_A, Forward_ID_EX_ALU_To_ID_B;
    wire        Forward_EX_MEM_ALU_To_ID_A, Forward_EX_MEM_ALU_To_ID_B;

    wire [2:0]  ID_Func3, EX_Func3, ID_ALUOp;
    wire [3:0]  mask_bits;
    wire [6:0]  ID_Func7;
    wire [6:0]  ID_Opcode;
    wire [4:0]  ID_WriteAddress, EX_WriteAddress, MEM_WriteAddress;
    wire [4:0]  ID_ReadReg1, ID_ReadReg2;

    // bus_mask l?y t? MEM_STAGE
    assign bus_mask = mask_bits;

    InstructionFetch IF_STAGE(
        .CLK                     (CLK),
        .EN                      (EN),
        .ONE                     (ID_ONE),
        .Reset                   (Reset),
        .Forward_ID_EX_ALU_To_ID_A  (Forward_ID_EX_ALU_To_ID_A),
        .Forward_EX_MEM_ALU_To_ID_A (Forward_EX_MEM_ALU_To_ID_A),
        .ForwardMemToRegData_RS1 (ForwardMemToRegData_RS1),
        .WriteData               (WB_WriteData),
        .EX_ALUResult            (iALUResult),
        .EX_MEM_ALUResult        (EX_ALUResult),
        .JumpReg                 (ID_JumpReg),
        .Jump                    (ID_Jump),
        .Branch                  (ID_Branch),
        .ImmediateOutput         (ImmediateOutputforPC),
        .IF_ID_ReadData1         (ReadData1_TO_IF),
        .ReadData1               (EX_ReadData1),
        .Instruction             (IF_Instruction),
        .PC                      (IF_PC),
        .PCcomputed              (prevPC),
        .RetainPC                (HazardDetected || ID_EX_HazardDetected),
        .RetainIF_ID             (HazardDetected || ID_EX_HazardDetected),
        .IF_Flush                (ID_Flush),
        // AXI port
        .bram_clka  (bram_clka),
        .bram_ena   (bram_ena),
        .bram_wea   (bram_wea),
        .bram_addra (bram_addra),
        .bram_dina  (bram_dina),
        .bram_douta (bram_douta)
    );

    InstructionDecode ID_STAGE(
        .CLK                        (CLK),
        .Reset                      (Reset),
        .EN                         (EN),
        .MEM_WB_RegWrite            (MEM_RegWrite),
        .ID_EX_HazardDetected       (ID_EX_HazardDetected),
        .prevReadReg1               (IF_Instruction[19:15]),
        .prevReadReg2               (IF_Instruction[24:20]),
        .MEM_WB_WriteAddress        (MEM_WriteAddress),
        .prevOpcode                 (IF_Instruction[6:0]),
        .ForwardMemToRegData_RS1    (ForwardMemToRegData_RS1),
        .ForwardMemToRegData_RS2    (ForwardMemToRegData_RS2),
        .Forward_ID_EX_ALU_To_ID_A  (Forward_ID_EX_ALU_To_ID_A),
        .Forward_ID_EX_ALU_To_ID_B  (Forward_ID_EX_ALU_To_ID_B),
        .Forward_EX_MEM_ALU_To_ID_A (Forward_EX_MEM_ALU_To_ID_A),
        .Forward_EX_MEM_ALU_To_ID_B (Forward_EX_MEM_ALU_To_ID_B),
        .Opcode                     (ID_Opcode),
        .previousPC                 (IF_PC),
        .ReadInstruction            (IF_Instruction),
        .WriteData                  (WB_WriteData),
        .EX_ALUResult               (iALUResult),
        .EX_MEM_ALUResult           (EX_ALUResult),
        .ALUOp                      (ID_ALUOp),
        .Func3                      (ID_Func3),
        .Func7                      (ID_Func7),
        .WriteAddress               (ID_WriteAddress),
        .ReadReg1                   (ID_ReadReg1),
        .ReadReg2                   (ID_ReadReg2),
        .ReadData1                  (ID_ReadData1),
        .ReadData2                  (ID_ReadData2),
        .dataA                      (ReadData1_TO_IF),
        .PC                         (ID_PC),
        .ImmediateOutput            (ID_ImmediateOutput),
        .ImmediateOutputforPC       (ImmediateOutputforPC),
        .JumpReg                    (ID_JumpReg),
        .Jump                       (ID_Jump),
        .Branch                     (ID_Branch),
        .RegSrc1                    (ID_RegSrc1),
        .MemToReg                   (ID_MemToReg),
        .RegSrc2                    (ID_RegSrc2),
        .RegWrite                   (ID_RegWrite),
        .UpperImm                   (ID_UpperImm),
        .MemWrite                   (ID_MemWrite),
        .RetAddr                    (ID_RetAddr),
        .ID_Flush                   (ID_Flush),
        .HazardDetected             (HazardDetected),
        .imm                        (ID_imm),
        .ONE                        (ID_ONE),
        .rvfi_i_bool                (ID_ValidInstruction)
    );

    Execute EX_STAGE(
        .CLK                        (CLK),
        .EN                         (EN),
        .Reset                      (Reset),
        .Opcode                     (ID_Opcode),
        .UpperImm                   (ID_UpperImm),
        .imm                        (ID_imm),
        .RetAddr                    (ID_RetAddr),
        .RegSrc1                    (ID_RegSrc1),
        .RegSrc2                    (ID_RegSrc2),
        .ID_EX_HazardDetected       (ID_EX_HazardDetected),
        .MEM_WB_WriteAddress        (MEM_WriteAddress),
        .MEM_WB_MemToReg            (MEM_MemToReg),
        .MEM_WB_RegWrite            (MEM_RegWrite),
        .ID_RS1                     (IF_Instruction[19:15]),
        .ID_RS2                     (IF_Instruction[24:20]),
        .prevMemToReg               (ID_MemToReg),
        .prevRegWrite               (ID_RegWrite),
        .prevMemWrite               (ID_MemWrite),
        .prevWriteAddress           (ID_WriteAddress),
        .prevReadReg1               (ID_ReadReg1),
        .prevReadReg2               (ID_ReadReg2),
        .PC                         (ID_PC),
        .ReadData1                  (ID_ReadData1),
        .previousReadData2          (ID_ReadData2),
        .ImmediateOutput            (ID_ImmediateOutput),
        .prevFunc3                  (ID_Func3),
        .WB_WriteData               (WB_WriteData),
        .ALUOp                      (ID_ALUOp),
        .Func7                      (ID_Func7),
        .Func3                      (EX_Func3),
        .ALUResult                  (EX_ALUResult),
        .iALUResult                 (iALUResult),
        .ReadData2                  (EX_ReadData2),
        .MemToReg                   (EX_MemToReg),
        .RegWrite                   (EX_RegWrite),
        .MemWrite                   (EX_MemWrite),
        .exReadData1                (EX_ReadData1),
        .exImmediateOutput          (EX_ImmediateOutput),
        .WriteAddress               (EX_WriteAddress),
        .ForwardMemToRegData_RS1    (ForwardMemToRegData_RS1),
        .ForwardMemToRegData_RS2    (ForwardMemToRegData_RS2),
        .Forward_ID_EX_ALU_To_ID_A  (Forward_ID_EX_ALU_To_ID_A),
        .Forward_ID_EX_ALU_To_ID_B  (Forward_ID_EX_ALU_To_ID_B),
        .Forward_EX_MEM_ALU_To_ID_A (Forward_EX_MEM_ALU_To_ID_A),
        .Forward_EX_MEM_ALU_To_ID_B (Forward_EX_MEM_ALU_To_ID_B),
        .HazardDetected             (HazardDetected)
    );

    Memory MEM_STAGE(
        .CLK              (CLK),
        .prevWriteAddress (EX_WriteAddress),
        .EN               (EN),
        .Reset            (Reset),
        .MemWrite         (EX_MemWrite),
        .prevRegWrite     (EX_RegWrite),
        .prevMemToReg     (EX_MemToReg),
        .Funct3           (EX_Func3),
        .ReadData2        (EX_ReadData2),
        .prevALUResult    (EX_ALUResult),
        .RegWrite         (MEM_RegWrite),
        .MemToReg         (MEM_MemToReg),
        .ReadData         (MEM_ReadData),
        .ALUResult        (MEM_ALUResult),
        .mask_bits        (mask_bits),
        .mem_en           (bus_en),
        .mem_we           (bus_we),
        .mem_addr         (bus_addr),
        .mem_wdata        (bus_wdata),
        .mem_funct3       (bus_funct3),
        .mem_rdata        (bus_rdata),
        .WriteAddress     (MEM_WriteAddress)
    );

    WriteBack WB_STAGE(
        .CLK      (CLK),
        .MemToReg (MEM_MemToReg),
        .ReadData (MEM_ReadData),
        .ALUResult(MEM_ALUResult),
        .WriteData(WB_WriteData)
    );

endmodule
