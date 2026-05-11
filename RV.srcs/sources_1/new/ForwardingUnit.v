`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:47:51 AM
// Design Name: 
// Module Name: ForwardingUnit
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


module ForwardingUnit(
    input  wire [4:0] ID_EX_RD, EX_MEM_RD, MEM_WB_RD, ID_RS1, ID_RS2, ID_EX_RS1, ID_EX_RS2,
    input  wire       ID_EX_RegWrite, EX_MEM_RegWrite, MEM_WB_RegWrite, MemToReg,
    output reg        ForwardALU_A, ForwardALU_B,
    output reg        ForwardMemToRegData_A, ForwardMemToRegData_B,
    output reg        ForwardMemToRegData_RS1, ForwardMemToRegData_RS2,
    output reg        Forward_EX_MEM_ALU_To_ID_A, Forward_EX_MEM_ALU_To_ID_B,
    output reg        Forward_ID_EX_ALU_To_ID_A, Forward_ID_EX_ALU_To_ID_B
);

    always @(*) begin
        ForwardALU_A                = 1'b0;
        ForwardALU_B                = 1'b0;
        ForwardMemToRegData_A       = 1'b0;
        ForwardMemToRegData_B       = 1'b0;
        ForwardMemToRegData_RS1     = 1'b0;
        ForwardMemToRegData_RS2     = 1'b0;
        Forward_EX_MEM_ALU_To_ID_A = 1'b0;
        Forward_EX_MEM_ALU_To_ID_B = 1'b0;
        Forward_ID_EX_ALU_To_ID_A  = 1'b0;
        Forward_ID_EX_ALU_To_ID_B  = 1'b0;

        if (EX_MEM_RD == ID_EX_RS1 && EX_MEM_RegWrite && EX_MEM_RD != 0)
            ForwardALU_A = 1'b1;

        if (EX_MEM_RD == ID_EX_RS2 && EX_MEM_RegWrite && EX_MEM_RD != 0)
            ForwardALU_B = 1'b1;

        if (MEM_WB_RD == ID_EX_RS1 && MEM_WB_RegWrite && MEM_WB_RD != 0)
            ForwardMemToRegData_A = 1'b1;

        if (MEM_WB_RD == ID_EX_RS2 && MEM_WB_RegWrite && MEM_WB_RD != 0)
            ForwardMemToRegData_B = 1'b1;

        if (MEM_WB_RD == ID_RS1 && MEM_WB_RegWrite && MEM_WB_RD != 0)
            ForwardMemToRegData_RS1 = 1'b1;

        if (MEM_WB_RD == ID_RS2 && MEM_WB_RegWrite && MEM_WB_RD != 0)
            ForwardMemToRegData_RS2 = 1'b1;

        if (EX_MEM_RD == ID_RS1 && EX_MEM_RegWrite && EX_MEM_RD != 0)
            Forward_EX_MEM_ALU_To_ID_A = 1'b1;

        if (EX_MEM_RD == ID_RS2 && EX_MEM_RegWrite && EX_MEM_RD != 0)
            Forward_EX_MEM_ALU_To_ID_B = 1'b1;

        if (ID_EX_RD == ID_RS1 && ID_EX_RegWrite && ID_EX_RD != 0)
            Forward_ID_EX_ALU_To_ID_A = 1'b1;

        if (ID_EX_RD == ID_RS2 && ID_EX_RegWrite && ID_EX_RD != 0)
            Forward_ID_EX_ALU_To_ID_B = 1'b1;
    end

endmodule 
