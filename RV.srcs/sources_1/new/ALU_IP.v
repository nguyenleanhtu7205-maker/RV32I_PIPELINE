`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 10:59:10 AM
// Design Name: 
// Module Name: ALU_IP
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


module ALU_IP(
    input  wire        CLK,
    input  wire        Reset,
    // Simple Bus slave interface
    input  wire        bus_en,      // transaction enable
    input  wire        bus_we,      // 1=write, 0=read
    input  wire [4:0]  bus_addr,    // offset ??a ch? n?i b?
    input  wire [31:0] bus_wdata,   // data ghi vào
    output reg  [31:0] bus_rdata,   // data ??c ra
    output wire        bus_ready    // IP s?n sàng tr? k?t qu?
);

    reg [31:0] operand_a;
    reg [31:0] operand_b;
    reg [31:0] opcode;
    reg [31:0] result;
    reg        done;

    assign bus_ready = done;

    // ---- Ghi vào IP ----
    always @(posedge CLK or posedge Reset) begin
        if (Reset) begin
            operand_a <= 32'b0;
            operand_b <= 32'b0;
            opcode    <= 32'b0;
            result    <= 32'b0;
            done      <= 1'b0;
        end
        else if (bus_en && bus_we) begin
            case (bus_addr)
                5'h00: begin
                    operand_a <= bus_wdata;
                    done      <= 1'b0;  // reset done khi ghi data m?i
                end
                5'h04: begin
                    operand_b <= bus_wdata;
                    done      <= 1'b0;
                end
                5'h08: begin
                    opcode <= bus_wdata;
                    // Tính toán ngay khi nh?n opcode
                    case (bus_wdata)
                        32'd0: result <= operand_a + operand_b;
                        32'd1: result <= operand_a - operand_b;
                        default: result <= 32'hDEADBEEF;
                    endcase
                    done <= 1'b1;
                end
                default: ;
            endcase
        end
    end

    // ---- ??c t? IP ----
    always @(*) begin
        bus_rdata = 32'b0;
        if (bus_en && !bus_we) begin
            case (bus_addr)
                5'h00: bus_rdata = operand_a;
                5'h04: bus_rdata = operand_b;
                5'h08: bus_rdata = opcode;
                5'h0C: bus_rdata = result;
                5'h10: bus_rdata = {31'b0, done};
                default: bus_rdata = 32'hDEADBEEF;
            endcase
        end
    end

endmodule
