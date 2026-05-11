`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:52:14 AM
// Design Name: 
// Module Name: ImmediateGenerator
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


module ImmediateGenerator(
    input  wire [31:0] Instruction,
    output reg  [31:0] ImmediateOutput
);

    reg [6:0] Opcode;

    always @(*) begin
        Opcode = Instruction[6:0];
        case (Opcode)
            7'b0010011,
            7'b0000011,
            7'b1100111: ImmediateOutput = {{20{Instruction[31]}}, Instruction[31:20]};
            7'b0010111,
            7'b0110111: ImmediateOutput = {Instruction[31:12], 12'b0};
            7'b0100011: ImmediateOutput = {{20{Instruction[31]}}, Instruction[31:25], Instruction[11:7]};
            7'b1100011: ImmediateOutput = {{19{Instruction[31]}}, Instruction[31], Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
            7'b1101111: ImmediateOutput = {{11{Instruction[31]}}, Instruction[31], Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
            default:    ImmediateOutput = 32'bx;
        endcase
    end

endmodule

