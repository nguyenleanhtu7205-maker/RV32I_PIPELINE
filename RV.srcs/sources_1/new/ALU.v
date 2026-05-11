`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:40:45 AM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input  wire [31:0] dataA,
    input  wire [31:0] dataB,
    input  wire [3:0]  ALUOperation,
    output reg  [31:0] ALUOutput
);

    wire signed [31:0] dataA_s;
    wire signed [31:0] dataB_s;
    assign dataA_s = dataA;
    assign dataB_s = dataB;

    always @(*) begin
        case (ALUOperation)
            4'b0000: ALUOutput = dataA | dataB;
            4'b0001: ALUOutput = dataA & dataB;
            4'b0010: ALUOutput = dataA + dataB;
            4'b0011: ALUOutput = dataA - dataB;
            4'b0101: ALUOutput = {{31{1'b0}}, (dataA_s < dataB_s)};
            4'b1000: ALUOutput = dataA << dataB[4:0];
            4'b1001: ALUOutput = dataA ^ dataB;
            4'b1010: ALUOutput = dataA >> dataB[4:0];
            4'b1011: ALUOutput = dataA_s >>> dataB[4:0];
            4'b1101: ALUOutput = {{31{1'b0}}, (dataA < dataB)};
            default: ALUOutput = 32'b0;
        endcase
    end

endmodule 

