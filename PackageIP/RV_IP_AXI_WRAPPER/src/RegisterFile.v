`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:43:04 AM
// Design Name: 
// Module Name: RegisterFile
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


module RegisterFile(
    input  wire [4:0]  ReadReg1, ReadReg2, WriteAddress,
    input  wire        CLK, Reset, RegWrite,
    input  wire [31:0] WriteData,
    output reg  [31:0] ReadData1, ReadData2
);

    reg [31:0] Registers [0:31];

    integer i;

    always @(*) begin
        ReadData1 = Registers[ReadReg1];
        ReadData2 = Registers[ReadReg2];
    end

    always @(posedge CLK or posedge Reset) begin
        if (Reset) begin
            for (i = 0; i < 32; i = i + 1)
                Registers[i] <= 32'b0;
        end
        else begin
            if (RegWrite && (WriteAddress != 5'b0))
                Registers[WriteAddress] <= WriteData;
        end
    end

endmodule
