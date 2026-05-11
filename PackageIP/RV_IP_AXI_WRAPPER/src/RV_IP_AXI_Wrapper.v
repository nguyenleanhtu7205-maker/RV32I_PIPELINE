`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 11:02:52 AM
// Design Name: 
// Module Name: RV_IP_AXI_Wrapper
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


module RV_IP_AXI_Wrapper #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 16
)(
    // AXI4-Lite Slave Interface
    input  wire        S_AXI_ACLK,
    input  wire        S_AXI_ARESETN,
    // Write address channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input  wire        S_AXI_AWVALID,
    output reg         S_AXI_AWREADY,
    // Write data channel
    input  wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input  wire [3:0]  S_AXI_WSTRB,
    input  wire        S_AXI_WVALID,
    output reg         S_AXI_WREADY,
    // Write response channel
    output reg  [1:0]  S_AXI_BRESP,
    output reg         S_AXI_BVALID,
    input  wire        S_AXI_BREADY,
    // Read address channel
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input  wire        S_AXI_ARVALID,
    output reg         S_AXI_ARREADY,
    // Read data channel
    output reg  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output reg  [1:0]  S_AXI_RRESP,
    output reg         S_AXI_RVALID,
    input  wire        S_AXI_RREADY
);

    // ============================================================
    // Register Map
    // 0x0000 ~ 0x3FFF : IMEM write (64KB)
    // 0x4000          : CTRL (bit0=reset, bit1=enable)
    // 0x4004          : STATUS (bit0=ip_done)
    // 0x4008          : IP_RESULT
    // ============================================================

    wire CLK   = S_AXI_ACLK;
    wire Resetn = S_AXI_ARESETN;

    // Control registers
    reg        rv_reset;
    reg        rv_enable;

    // BRAM write signals ??n RV_IP
    reg        bram_ena;
    reg [3:0]  bram_wea;
    reg [31:0] bram_addra;
    reg [31:0] bram_dina;
    wire[31:0] bram_douta;

    // L?y signals t? bên trong RV_IP
    wire [31:0] ip_result;
    wire        ip_done;

    // ============================================================
    // RV_IP Instance
    // ============================================================
    RV_IP rv_core(
        .CLK        (CLK),
        .Reset      (rv_reset),
        .EN         (rv_enable),
        .bram_clka  (CLK),
        .bram_ena   (bram_ena),
        .bram_wea   (bram_wea),
        .bram_addra (bram_addra),
        .bram_dina  (bram_dina),
        .bram_douta (bram_douta)
    );

    assign ip_result = rv_core.IP.result;
    assign ip_done   = rv_core.IP.done;

    // ============================================================
    // AXI Write Logic
    // ============================================================
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;
    reg aw_active, w_active;

    always @(posedge CLK) begin
        if (!Resetn) begin
            S_AXI_AWREADY <= 0;
            S_AXI_WREADY  <= 0;
            S_AXI_BVALID  <= 0;
            S_AXI_BRESP   <= 0;
            rv_reset       <= 1; // gi? reset khi ch?a có l?nh
            rv_enable      <= 0;
            bram_ena       <= 0;
            bram_wea       <= 0;
            aw_active      <= 0;
            w_active       <= 0;
        end
        else begin
            // Default
            bram_ena <= 0;
            bram_wea <= 0;

            // Latch write address
            if (S_AXI_AWVALID && !aw_active) begin
                axi_awaddr    <= S_AXI_AWADDR;
                S_AXI_AWREADY <= 1;
                aw_active     <= 1;
            end
            else
                S_AXI_AWREADY <= 0;

            // Latch write data
            if (S_AXI_WVALID && !w_active) begin
                S_AXI_WREADY <= 1;
                w_active     <= 1;
            end
            else
                S_AXI_WREADY <= 0;

            // Th?c hi?n ghi khi có c? address và data
            if (aw_active && w_active) begin
                aw_active <= 0;
                w_active  <= 0;

                if (axi_awaddr[15:14] == 2'b00) begin
                    // 0x0000 ~ 0x3FFF: Ghi vào IMEM
                    bram_ena   <= 1;
                    bram_wea   <= S_AXI_WSTRB;
                    bram_addra <= {16'b0, axi_awaddr};
                    bram_dina  <= S_AXI_WDATA;
                end
                else begin
                    case (axi_awaddr)
                        16'h4000: begin
                            rv_reset  <= S_AXI_WDATA[0];
                            rv_enable <= S_AXI_WDATA[1];
                        end
                        default: ;
                    endcase
                end

                // G?i response
                S_AXI_BVALID <= 1;
                S_AXI_BRESP  <= 2'b00; // OKAY
            end

            if (S_AXI_BVALID && S_AXI_BREADY)
                S_AXI_BVALID <= 0;
        end
    end

    // ============================================================
    // AXI Read Logic
    // ============================================================
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr;

    always @(posedge CLK) begin
        if (!Resetn) begin
            S_AXI_ARREADY <= 0;
            S_AXI_RVALID  <= 0;
            S_AXI_RDATA   <= 0;
            S_AXI_RRESP   <= 0;
        end
        else begin
            if (S_AXI_ARVALID && !S_AXI_ARREADY) begin
                S_AXI_ARREADY <= 1;
                axi_araddr    <= S_AXI_ARADDR;
            end
            else
                S_AXI_ARREADY <= 0;

            if (S_AXI_ARREADY && S_AXI_ARVALID && !S_AXI_RVALID) begin
                S_AXI_RVALID <= 1;
                S_AXI_RRESP  <= 2'b00;
                case (axi_araddr)
                    16'h4000: S_AXI_RDATA <= {30'b0, rv_enable, rv_reset};
                    16'h4004: S_AXI_RDATA <= {31'b0, ip_done};
                    16'h4008: S_AXI_RDATA <= ip_result;
                    default:  S_AXI_RDATA <= 32'hDEADBEEF;
                endcase
            end
            else if (S_AXI_RVALID && S_AXI_RREADY)
                S_AXI_RVALID <= 0;
        end
    end

endmodule

