`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:43:48 AM
// Design Name: 
// Module Name: ProgramCounter
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


module ProgramCounter(
    input  wire        CLK, Reset, JumpReg, Jump, Branch, ONE, RetainPC,
    input  wire [31:0] ImmediateOutput, ReadData1, IF_ID_PC,
    input  wire [31:0] IF_ID_ReadData1,
    output reg  signed [31:0] PC
);

    always @(posedge CLK or posedge Reset) begin
        if (Reset) begin
            PC <= -4;
        end
        else begin
            PC <= ((JumpReg) ? IF_ID_ReadData1 : ((Jump || (Branch && ONE)) ? IF_ID_PC : PC))
                + ((RetainPC) ? 32'b0 : ((Jump || (Branch && ONE)) ? ImmediateOutput : 32'd4));
        end
    end

endmodule

