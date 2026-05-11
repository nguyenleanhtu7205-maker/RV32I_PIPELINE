`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:49:12 AM
// Design Name: 
// Module Name: DataMemory
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


module DataMemory(
    input  wire        CLK, EN, MemWrite,
    input  wire [2:0]  Funct3,
    input  wire [31:0] DataAddress, WriteData,
    output reg  [31:0] ReadData,
    output reg  [3:0]  mask_bits
);

    reg [31:0] Memory [0:16383];

    // ---------- Write Logic ----------
    always @(posedge CLK) begin
        if (EN && MemWrite && (DataAddress >> 2) < 268435456) begin
            case (Funct3)
                3'b010: begin // sw
                    Memory[DataAddress >> 2] <= WriteData;
                    mask_bits <= 4'b1111;
                end
                3'b001: begin // sh
                    case (DataAddress[1])
                        1'b0: Memory[DataAddress >> 2][15:0]  <= WriteData[15:0];
                        1'b1: Memory[DataAddress >> 2][31:16] <= WriteData[15:0];
                    endcase
                    mask_bits <= 4'b0011;
                end
                3'b000: begin // sb
                    case (DataAddress[1:0])
                        2'b00: Memory[DataAddress >> 2][7:0]   <= WriteData[7:0];
                        2'b01: Memory[DataAddress >> 2][15:8]  <= WriteData[7:0];
                        2'b10: Memory[DataAddress >> 2][23:16] <= WriteData[7:0];
                        2'b11: Memory[DataAddress >> 2][31:24] <= WriteData[7:0];
                    endcase
                    mask_bits <= 4'b0001;
                end
                default: mask_bits <= 4'b0000;
            endcase
        end else begin
            mask_bits <= 4'b0000;
        end
    end

    // ---------- Read Logic ----------
    always @(*) begin
        if (EN && (DataAddress >> 2) < 268435456) begin
            case (Funct3)
                3'b010: begin // lw
                    ReadData = Memory[DataAddress >> 2];
                end
                3'b001: begin // lh
                    case (DataAddress[1])
                        1'b0: ReadData = {{16{Memory[DataAddress >> 2][15]}}, Memory[DataAddress >> 2][15:0]};
                        1'b1: ReadData = {{16{Memory[DataAddress >> 2][31]}}, Memory[DataAddress >> 2][31:16]};
                        default: ReadData = 32'b0;
                    endcase
                end
                3'b000: begin // lb
                    case (DataAddress[1:0])
                        2'b00: ReadData = {{24{Memory[DataAddress >> 2][7]}},  Memory[DataAddress >> 2][7:0]};
                        2'b01: ReadData = {{24{Memory[DataAddress >> 2][15]}}, Memory[DataAddress >> 2][15:8]};
                        2'b10: ReadData = {{24{Memory[DataAddress >> 2][23]}}, Memory[DataAddress >> 2][23:16]};
                        2'b11: ReadData = {{24{Memory[DataAddress >> 2][31]}}, Memory[DataAddress >> 2][31:24]};
                        default: ReadData = 32'b0;
                    endcase
                end
                3'b101: begin // lhu
                    case (DataAddress[1])
                        1'b0: ReadData = {16'b0, Memory[DataAddress >> 2][15:0]};
                        1'b1: ReadData = {16'b0, Memory[DataAddress >> 2][31:16]};
                        default: ReadData = 32'b0;
                    endcase
                end
                3'b100: begin // lbu
                    case (DataAddress[1:0])
                        2'b00: ReadData = {24'b0, Memory[DataAddress >> 2][7:0]};
                        2'b01: ReadData = {24'b0, Memory[DataAddress >> 2][15:8]};
                        2'b10: ReadData = {24'b0, Memory[DataAddress >> 2][23:16]};
                        2'b11: ReadData = {24'b0, Memory[DataAddress >> 2][31:24]};
                        default: ReadData = 32'b0;
                    endcase
                end
                default: ReadData = 32'b0;
            endcase
        end else begin
            ReadData = 32'b0;
        end
    end

endmodule