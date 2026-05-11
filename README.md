# RV32I Pipeline Processor with Custom Bus & AXI Integration on KR260

## Overview

This project implements a custom **RV32I pipelined processor** in Verilog HDL and deploys it on the Xilinx KR260 platform.

Instead of using a standard interconnect such as AXI internally, the processor communicates with peripherals through a **custom lightweight bus protocol** designed specifically for this system.

The system contains:

- A custom 5-stage pipelined RV32I processor
- External Data Memory (DMEM)
- A custom Arithmetic IP core
- A custom Bus Interconnect
- An AXI4-Lite wrapper for SoC integration on KR260

The complete system is developed in **Vivado**, integrated into the KR260 SoC through AXI, and controlled using **Vitis** with bare-metal C software.

---

# System Architecture

```text
                  +----------------------+
                  |   ARM Processing     |
                  |      System (PS)     |
                  +----------+-----------+
                             |
                       AXI4-Lite
                             |
                             v
+--------------------------------------------------+
|                RV_IP_AXI_Wrapper                 |
|                                                  |
|  +--------------------------------------------+  |
|  |                  RV_IP                     |  |
|  |                                            |  |
|  |  +--------------+                          |  |
|  |  |  RV32I CPU   |                          |  |
|  |  |  Pipeline    |                          |  |
|  |  +------+-------+                          |  |
|  |         |                                  |  |
|  |         v                                  |  |
|  |  +--------------+                          |  |
|  |  | Custom Bus   |                          |  |
|  |  | Interconnect |                          |  |
|  |  +------+-------+                          |  |
|  |         |                                  |  |
|  |   +-----+------+                           |  |
|  |   |            |                           |  |
|  |   v            v                           |  |
|  | DMEM        ALU_IP                         |  |
|  |            (ADD/SUB)                       |  |
|  +--------------------------------------------+  |
+--------------------------------------------------+
