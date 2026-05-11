`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:45:57 AM
// Design Name: 
// Module Name: InstructionMemory
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


module InstructionMemory(
    // Port B: RV32I ??c
    input  wire        EN,
    input  wire [31:0] InstructionAddress,
    output reg  [31:0] ReadInstruction,

    input  wire        clka,
    input  wire        ena,
    input  wire [3:0]  wea,        // write enable
    input  wire [31:0] addra,      // word address
    input  wire [31:0] dina,       // write data
    output reg  [31:0] douta       // read data (port A)
);

    (* ram_style = "block" *)
    reg [31:0] Memory [0:16383]; // 64KB IMEM

    // Khong dung $readmemh nua
    // ARM se nap chuong trinh qua Port A

   

    // Port A: AXI BRAM Controller ghi
    always @(posedge clka) begin
    if (ena && |wea)                    
        Memory[addra[15:2]] <= dina;    
    douta <= Memory[addra[15:2]];
end

    // Port B: RV32I ??c
    always @(*) begin
        if (EN)
            ReadInstruction = Memory[InstructionAddress >> 2];
        else
            ReadInstruction = 32'b0;
    end

endmodule 
