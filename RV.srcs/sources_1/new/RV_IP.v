`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 11:00:06 AM
// Design Name: 
// Module Name: RV_IP
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


module RV_IP(
    input  wire        CLK,
    input  wire        Reset,
    input  wire        EN,
    // BRAM interface chu?n Xilinx cho IMEM
    input  wire        bram_clka,
    input  wire        bram_ena,
    input  wire [3:0]  bram_wea,       
    input  wire [31:0] bram_addra,     
    input  wire [31:0] bram_dina,
    output wire [31:0] bram_douta
);

    // Bus signals
    wire        bus_en_w, bus_we_w;
    wire [31:0] bus_addr_w, bus_wdata_w;
    wire [2:0]  bus_funct3_w;
    wire [3:0]  bus_mask_w;
    wire [31:0] bus_rdata_w;

    // DMEM signals
    wire        dmem_en, dmem_we;
    wire [31:0] dmem_addr, dmem_wdata, dmem_rdata;
    wire [2:0]  dmem_funct3;
    wire [3:0]  dmem_mask;

    // IP signals
    wire        ip_cs, ip_we;
    wire [4:0]  ip_addr;
    wire [31:0] ip_wdata, ip_rdata;
    wire        ip_ready;

    // Chuy?n ??i BRAM interface
    // 4-bit wea ? 1-bit we
    wire        bram_we_internal  = |bram_wea;
    // byte address ? word address
    wire [13:0] bram_addr_internal = bram_addra[15:2];

    
    MainDatapath PROCESSOR(
        .CLK        (CLK),
        .EN         (EN),
        .Reset      (Reset),
        .bus_en     (bus_en_w),
        .bus_we     (bus_we_w),
        .bus_addr   (bus_addr_w),
        .bus_wdata  (bus_wdata_w),
        .bus_funct3 (bus_funct3_w),
        .bus_mask   (bus_mask_w),
        .bus_rdata  (bus_rdata_w),
        // BRAM cho IMEM
        .bram_clka  (bram_clka),   // bram_clk  ? bram_clka
        .bram_ena   (bram_ena),    // bram_en   ? bram_ena
        .bram_wea   (bram_wea),    // bram_we   ? bram_wea
        .bram_addra (bram_addra),  // bram_addr ? bram_addra
        .bram_dina  (bram_dina),   // bram_wdata? bram_dina
        .bram_douta (bram_douta)   
    );

   
    BusInterconnect BUS(
        .M_en      (bus_en_w),
        .M_we      (bus_we_w),
        .M_addr    (bus_addr_w),
        .M_wdata   (bus_wdata_w),
        .M_funct3  (bus_funct3_w),
        .M_rdata   (bus_rdata_w),
        .S0_en     (dmem_en),
        .S0_we     (dmem_we),
        .S0_addr   (dmem_addr),
        .S0_wdata  (dmem_wdata),
        .S0_funct3 (dmem_funct3),
        .S0_rdata  (dmem_rdata),
        .S1_cs     (ip_cs),
        .S1_we     (ip_we),
        .S1_addr   (ip_addr),
        .S1_wdata  (ip_wdata),
        .S1_rdata  (ip_rdata),
        .S1_ready  (ip_ready)
    );

   
    DataMemory DMEM(
        .CLK         (CLK),
        .EN          (dmem_en),
        .MemWrite    (dmem_we),
        .Funct3      (dmem_funct3),
        .DataAddress (dmem_addr),
        .WriteData   (dmem_wdata),
        .ReadData    (dmem_rdata),
        .mask_bits   (dmem_mask)
    );

    
    ALU_IP IP(
        .CLK      (CLK),
        .Reset    (Reset),
        .bus_en   (ip_cs),
        .bus_we   (ip_we),
        .bus_addr (ip_addr),
        .bus_wdata(ip_wdata),
        .bus_rdata(ip_rdata),
        .bus_ready(ip_ready)
    );

endmodule
