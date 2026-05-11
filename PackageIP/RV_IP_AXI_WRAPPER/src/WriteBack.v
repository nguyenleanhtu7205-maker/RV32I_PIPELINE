`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:42:00 AM
// Design Name: 
// Module Name: WriteBack
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

module WriteBack(
    input  wire        CLK, MemToReg,
    input  wire [31:0] ReadData, ALUResult,
    output reg  [31:0] WriteData
);

    always @(*) begin
        WriteData = (MemToReg) ? ReadData : ALUResult;
    end

endmodule
