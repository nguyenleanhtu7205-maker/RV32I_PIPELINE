`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2026 11:01:15 AM
// Design Name: 
// Module Name: RV_IP_TB
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


module RV_IP_TB;

    // ============================================================
    // DUT signals
    // ============================================================
    reg        CLK;
    reg        Reset;
    reg        EN;

    // BRAM interface ?? n?p ch??ng trình
    reg        bram_clka;
    reg        bram_ena;
    reg [3:0]  bram_wea;
    reg [31:0] bram_addra;
    reg [31:0] bram_dina;
    wire[31:0] bram_douta;

    // ============================================================
    // DUT instantiation
    // ============================================================
    RV_IP uut(
        .CLK       (CLK),
        .Reset     (Reset),
        .EN        (EN),
        .bram_clka (bram_clka),
        .bram_ena  (bram_ena),
        .bram_wea  (bram_wea),
        .bram_addra(bram_addra),
        .bram_dina (bram_dina),
        .bram_douta(bram_douta)
    );

    // ============================================================
    // Clock: chu ky 2ns
    // ============================================================
    always #1 CLK      = ~CLK;
    always #1 bram_clka = ~bram_clka;

    // ============================================================
    // Chuong trinh RISC-V can nap vao IMEM
    // ============================================================
    reg [31:0] program [0:15];
    integer i;

    initial begin
        program[0]  = 32'h080000B7; // lui  x1,  0x8000
        program[1]  = 32'h01900113; // addi x2,  x0,  25
        program[2]  = 32'h0020A023; // sw   x2,  0(x1)
        program[3]  = 32'h00A00193; // addi x3,  x0,  10
        program[4]  = 32'h0030A223; // sw   x3,  4(x1)
        program[5]  = 32'h00000213; // addi x4,  x0,  0
        program[6]  = 32'h0040A423; // sw   x4,  8(x1)
        program[7]  = 32'h0100A283; // lw   x5,  16(x1) <- poll1
        program[8]  = 32'hFE028FE3; // beq  x5,  x0, poll1
        program[9]  = 32'h00C0A303; // lw   x6,  12(x1)
        program[10] = 32'h00100213; // addi x4,  x0,  1
        program[11] = 32'h0040A423; // sw   x4,  8(x1)
        program[12] = 32'h0100A283; // lw   x5,  16(x1) <- poll2
        program[13] = 32'hFE028FE3; // beq  x5,  x0, poll2
        program[14] = 32'h00C0A383; // lw   x7,  12(x1)
        program[15] = 32'h00000063; // beq  x0,  x0, done
    end

    // ============================================================
    // Task nap lenh vao IMEM qua BRAM port A
    // ============================================================
    task load_imem;
        integer idx;
        begin
            $display("[TB] Bat dau nap chuong trinh vao IMEM...");
            bram_ena  = 1;
            bram_wea  = 4'hF;
            for (idx = 0; idx < 16; idx = idx + 1) begin
                bram_addra = idx * 4; // byte address
                bram_dina  = program[idx];
                @(posedge bram_clka);
                #0.5;
                $display("[TB] IMEM[0x%04h] = 0x%08h", idx*4, program[idx]);
            end
            bram_ena  = 0;
            bram_wea  = 4'h0;
            bram_addra = 0;
            bram_dina  = 0;
            $display("[TB] Nap chuong trinh hoan tat!");
            $display("");
        end
    endtask

    // ============================================================
    // Theo doi ALU_IP
    // ============================================================
    wire [31:0] ip_operand_a = uut.IP.operand_a;
    wire [31:0] ip_operand_b = uut.IP.operand_b;
    wire [31:0] ip_opcode    = uut.IP.opcode;
    wire [31:0] ip_result    = uut.IP.result;
    wire        ip_done      = uut.IP.done;

    // Register file
    wire [31:0] rf_x1 = uut.PROCESSOR.ID_STAGE.RF.Registers[1];
    wire [31:0] rf_x2 = uut.PROCESSOR.ID_STAGE.RF.Registers[2];
    wire [31:0] rf_x3 = uut.PROCESSOR.ID_STAGE.RF.Registers[3];
    wire [31:0] rf_x6 = uut.PROCESSOR.ID_STAGE.RF.Registers[6];
    wire [31:0] rf_x7 = uut.PROCESSOR.ID_STAGE.RF.Registers[7];

    // ============================================================
    // Theo doi ip_done de in ket qua
    // ============================================================
    reg prev_done;
    reg result_printed;

    always @(posedge CLK) begin
        if (ip_done && !prev_done) begin
            $display("---------------------------------------");
            $display("[IP] ALU_IP tinh toan xong!");
            $display("[IP] operand_a = %0d", ip_operand_a);
            $display("[IP] operand_b = %0d", ip_operand_b);
            $display("[IP] opcode    = %0d (%s)",
                ip_opcode,
                (ip_opcode == 0) ? "ADD" : "SUB");
            $display("[IP] result    = %0d", ip_result);
            $display("---------------------------------------");
        end
        prev_done <= ip_done;
    end

    // ============================================================
    // Initial block chinh
    // ============================================================
    initial begin
        // Khoi tao
        CLK        = 0;
        bram_clka  = 0;
        Reset      = 1;
        EN         = 0;
        bram_ena   = 0;
        bram_wea   = 4'h0;
        bram_addra = 0;
        bram_dina  = 0;
        prev_done  = 0;
        result_printed = 0;

        $display("======================================================");
        $display("          RV_IP TESTBENCH");
        $display("======================================================");
        $display("Chuong trinh RISC-V:");
        $display("  ADD 25 + 10 -> ket qua luu vao x6");
        $display("  SUB 25 - 10 -> ket qua luu vao x7");
        $display("  Giao tiep voi ALU_IP qua MMIO 0x08000000");
        $display("======================================================");
        $display("");

        // Giu Reset trong 4 chu ky
        #4;

        // Nap chuong trinh vao IMEM khi dang reset
        // (processor chua chay, an toan de ghi IMEM)
        load_imem;

        // Release reset, bat dau chay
        $display("[TB] Release reset, processor bat dau chay...");
        Reset = 0;
        EN    = 1;
        $display("");

        // Cho du thoi gian de 2 phep tinh hoan thanh
        // ADD xong truoc, SUB xong sau
        #600;

        // In ket qua cuoi cung
        $display("");
        $display("======================================================");
        $display("          KET QUA CUOI CUNG");
        $display("======================================================");
        $display("Register File:");
        $display("  x1 = 0x%08h (base addr ALU_IP)", rf_x1);
        $display("  x2 = 0x%08h (operand_a = %0d)", rf_x2, rf_x2);
        $display("  x3 = 0x%08h (operand_b = %0d)", rf_x3, rf_x3);
        $display("  x6 = 0x%08h (ket qua ADD = %0d)", rf_x6, rf_x6);
        $display("  x7 = 0x%08h (ket qua SUB = %0d)", rf_x7, rf_x7);
        $display("");
        $display("ALU_IP state:");
        $display("  operand_a = %0d", ip_operand_a);
        $display("  operand_b = %0d", ip_operand_b);
        $display("  result    = %0d", ip_result);
        $display("  done      = %0d", ip_done);
        $display("======================================================");

        // Kiem tra ket qua
        $display("");
        $display("KIEM TRA:");
        if (rf_x6 === 32'd35)
            $display("  ADD 25 + 10 = %0d  --> PASS", rf_x6);
        else
            $display("  ADD 25 + 10 = %0d  --> FAIL (ky vong 35)", rf_x6);

        if (rf_x7 === 32'd15)
            $display("  SUB 25 - 10 = %0d  --> PASS", rf_x7);
        else
            $display("  SUB 25 - 10 = %0d  --> FAIL (ky vong 15)", rf_x7);

        $display("");
        if (rf_x6 === 32'd35 && rf_x7 === 32'd15)
            $display("  TONG HOP: PASS - Ca 2 phep tinh deu dung!");
        else
            $display("  TONG HOP: FAIL - Co phep tinh sai!");

        $display("======================================================");
        $finish;
    end

endmodule
