#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"

#define RV32I_BASE    0xA0000000
#define IMEM_OFFSET   0x0000
#define CTRL_OFFSET   0x4000
#define STATUS_OFFSET 0x4004
#define RESULT_OFFSET 0x4008

#define AXI_WRITE(off, val) Xil_Out32(RV32I_BASE+(off), (val))
#define AXI_READ(off)       Xil_In32(RV32I_BASE+(off))

uint32_t rv_program[] = {
    0x080000B7,
    0x01900113,
    0x0020A023,
    0x00A00193,
    0x0030A223,
    0x00000213,
    0x0040A423,
    0x0100A283,
    0xFE028FE3,
    0x00C0A303,
    0x00100213,
    0x0040A423,
    0x0100A283,
    0xFE028FE3,
    0x00C0A383,
    0x00000063
};

int main() {
    xil_printf("\r\n=== RV32I + ALU_IP on KR260 ===\r\n");

    xil_printf("[1] Resetting...\r\n");
    AXI_WRITE(CTRL_OFFSET, 0x1);
    usleep(10000);

    xil_printf("[2] Loading program...\r\n");
    for (int i = 0; i < sizeof(rv_program)/4; i++)
        AXI_WRITE(IMEM_OFFSET + i*4, rv_program[i]);

    xil_printf("[3] Starting processor...\r\n");
    AXI_WRITE(CTRL_OFFSET, 0x2);

    xil_printf("[4] Waiting ADD 25+10...\r\n");
    int timeout = 1000000;
    while (!(AXI_READ(STATUS_OFFSET) & 0x1) && timeout--)
        usleep(1);
    uint32_t r1 = AXI_READ(RESULT_OFFSET);
    xil_printf("    ADD = %d %s\r\n", r1, r1==35?"[PASS]":"[FAIL]");

    usleep(100000);
    xil_printf("[5] Waiting SUB 25-10...\r\n");
    timeout = 1000000;
    while (!(AXI_READ(STATUS_OFFSET) & 0x1) && timeout--)
        usleep(1);
    uint32_t r2 = AXI_READ(RESULT_OFFSET);
    xil_printf("    SUB = %d %s\r\n", r2, r2==15?"[PASS]":"[FAIL]");

    xil_printf("=== Done ===\r\n");
    return 0;
}