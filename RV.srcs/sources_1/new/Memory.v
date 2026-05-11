`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:44:34 AM
// Design Name: 
// Module Name: Memory
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


module Memory(
    input  wire        CLK, EN, Reset, MemWrite, prevRegWrite, prevMemToReg,
    input  wire [4:0]  prevWriteAddress,
    input  wire [2:0]  Funct3,
    input  wire [31:0] ReadData2, prevALUResult,
    output reg         RegWrite, MemToReg,
    output reg  [4:0]  WriteAddress,
    output reg  [31:0] ReadData, ALUResult,
    output wire [3:0]  mask_bits,
    output wire        mem_en,
    output wire        mem_we,
    output wire [31:0] mem_addr,
    output wire [31:0] mem_wdata,
    output wire [2:0]  mem_funct3,
    input  wire [31:0] mem_rdata
);

    assign mem_en     = EN;
    assign mem_we     = MemWrite;
    assign mem_addr   = prevALUResult;
    assign mem_wdata  = ReadData2;
    assign mem_funct3 = Funct3;

    assign mask_bits = (Funct3 == 3'b010) ? 4'b1111 :
                       (Funct3 == 3'b001) ? 4'b0011 :
                       (Funct3 == 3'b000) ? 4'b0001 : 4'b0000;

    always @(posedge CLK or posedge Reset) begin
        if (Reset) begin
            ReadData     <= 32'b0;
            ALUResult    <= 32'b0;
            RegWrite     <= 1'b0;
            MemToReg     <= 1'b0;
            WriteAddress <= 5'b0;
        end
        else if (EN) begin
            ReadData     <= mem_rdata;
            ALUResult    <= prevALUResult;
            RegWrite     <= prevRegWrite;
            MemToReg     <= prevMemToReg;
            WriteAddress <= prevWriteAddress;
        end
    end

endmodule

