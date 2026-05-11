`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:50:52 AM
// Design Name: 
// Module Name: BranchDecisionUnit
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


module BranchDecisionUnit(
    input  wire [6:0]  Opcode,
    input  wire [31:0] dataA,
    input  wire [31:0] dataB,
    input  wire [2:0]  Func3,
    output reg         ONE
);

    wire signed [31:0] dataA_s;
    wire signed [31:0] dataB_s;
    assign dataA_s = dataA;
    assign dataB_s = dataB;

    always @(*) begin
        case ({Opcode, Func3})
            10'b1100011_000: ONE = (dataA_s == dataB_s);
            10'b1100011_001: ONE = (dataA_s != dataB_s);
            10'b1100011_100: ONE = (dataA_s <  dataB_s);
            10'b1100011_101: ONE = (dataA_s >= dataB_s);
            10'b1100011_110: ONE = (dataA   <  dataB);
            10'b1100011_111: ONE = (dataA   >= dataB);
            default:         ONE = 1'b0;
        endcase
    end

endmodule
