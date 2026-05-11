`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:46:57 AM
// Design Name: 
// Module Name: HazardDetectionUnit
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


module HazardDetectionUnit(
    input  wire       MemToReg,
    input  wire [4:0] ID_EX_RD, IF_ID_RS1, IF_ID_RS2,
    output reg        HazardDetected
);

    always @(*) begin
        if (MemToReg && (ID_EX_RD != 0) && (ID_EX_RD == IF_ID_RS1 || ID_EX_RD == IF_ID_RS2))
            HazardDetected = 1'b1;
        else
            HazardDetected = 1'b0;
    end

endmodule

