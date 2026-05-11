`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:58:21 AM
// Design Name: 
// Module Name: BusInterconnect
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

module BusInterconnect(
    // Master
    input  wire        M_en,
    input  wire        M_we,
    input  wire [31:0] M_addr,
    input  wire [31:0] M_wdata,
    input  wire [2:0]  M_funct3,
    output reg  [31:0] M_rdata,
    // Slave 0: DataMemory
    output wire        S0_en,
    output wire        S0_we,
    output wire [31:0] S0_addr,
    output wire [31:0] S0_wdata,
    output wire [2:0]  S0_funct3,
    input  wire [31:0] S0_rdata,
    // Slave 1: ALU_IP
    output wire        S1_cs,
    output wire        S1_we,
    output wire [4:0]  S1_addr,
    output wire [31:0] S1_wdata,
    input  wire [31:0] S1_rdata,
    input  wire        S1_ready
);

    // Decode ??a ch?
    wire sel_dmem = (M_addr[31:27] == 5'b00000); // 0x0000_0000 ~ 0x07FF_FFFF
    wire sel_ip   = (M_addr[31:8]  == 24'h080000); // 0x0800_0000 ~ 0x0800_00FF

    // Slave 0: DataMemory
    assign S0_en     = M_en && sel_dmem;
    assign S0_we     = M_we;
    assign S0_addr   = M_addr;
    assign S0_wdata  = M_wdata;
    assign S0_funct3 = M_funct3;

    // Slave 1: ALU_IP
    assign S1_cs    = M_en && sel_ip;
    assign S1_we    = M_we;
    assign S1_addr  = M_addr[4:0];
    assign S1_wdata = M_wdata;

    // Mux rdata v? processor
    always @(*) begin
        if (sel_ip)
            M_rdata = S1_rdata;
        else if (sel_dmem)
            M_rdata = S0_rdata;
        else
            M_rdata = 32'hDEADBEEF;
    end

endmodule
