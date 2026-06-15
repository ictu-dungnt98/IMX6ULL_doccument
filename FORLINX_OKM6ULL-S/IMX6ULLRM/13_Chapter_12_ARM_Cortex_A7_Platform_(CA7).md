# Chapter 12: ARM Cortex A7 Platform (CA7)

> Nguồn: `IMX6ULLRM.pdf` — trang 387–390

<!-- page 387 -->

Chapter 12
ARM Cortex A7 Platform (CA7)
12.1
Overview
The Cortex-A7 MPCore platform is a high-performance, low-power processor compliant
with the ARMv7-A architecture. The Cortex-A7 MPCore platform has a single
Arm®Cortex®-A7 core with a L1 cache subsystem and integrated Generic Interrupt
Controller (GIC).
Each Cortex-A7 MPCore includes the following:
• 32 KB L1 Instruction Cache
• 32 KB L1 Data Cache
• Media Processing Engine (MPE) with NEON technology supporting the Advanced
Single Instruction Multiple Data version 2 (SIMDv2) architecture
• Floating Point Unit (FPU) with support of the VFPv4-D32 architecture
NOTE
This is a superset of VFPv4-D16
• Support of ARMv7A architecture including:
• Security extensions for enhanced security
• Virtualization extensions
• Large Physical Address (LPA) extension (LPA only supported within Cortex-A7
MPCore platform)
The Cortex-A7 MPCore platform includes the following:
• Integrated Global Interrupt Controller (GIC) configured to support 128 shared
peripheral interrupts
• Generic timer
• Snoop control unit (SCU)
• 128 KB unified L2 cache
• Interconnect using a single 128-bit wide bus AMBA AXI bus
• ARMv7.1 Arm debug architecture that complies with the Coresight debug/trace
architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
387

<!-- page 388 -->

12.2
External Signals
The following table describes the external signals of Arm:
12.3
Clocks
This section will discuss the Cortex-A7 clocks. For the specification of the maximum
Cortex-A7 core frequency, please see the product datasheet. The following table
describes the clock sources for Arm. Please see Clock Controller Module (CCM) for
clock setting, configuration and gating information.
Table 12-1. Arm Clocks
Clock name
Clock Root
Description
clk_ahb
ahb_clk_root
AHB Clock
clk_apb_dbg
ahb_clk_root
APB Debug Clock
clk_atb
ahb_clk_root
ATB Clock
ipg_clk
ipg_clk_root
Peripheral Clock
trace_clk_in
ahb_clk_root
Trace Clock
Bus Clocks: The AXI master port of the Cortex-A7 MPCore platform is designed to run
at half the speed (1:2 ratio) of the Cortex-A7 core.
Debug Clocks: The APB debug interface is designed to run at half the speed (1:2 ratio)
of the Cortex-A7 core.
12.4
Platform Configuration
The revision and configuration of components the Cortex-A7 MPCore platform are
detailed below.
Table 12-2. Component Revision
Component
Revision
Cortex-A7 MPCore
MP020-BU-50000-r0p5-00rel0
MP020-BU-50000-r0p5-50rel0
ETM-A7
TM956-BU-50000-r0p0-00rel0
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
388
NXP Semiconductors

<!-- page 389 -->

Table 12-3. Cortex-A7 MPCore Global Configuration
Option
Selected Value
Comments
Instruction cache size
32 KB
L1 instruction cache size per core
Data cache size
32 KB
L1 data cache size per core
L2 cache controller
Present
Integrated L2 cache controller
L2 data RAM cycle latency
2 cycles
Shared Peripheral Interrupts
128
128 shared peripheral interrupts
Number of processors
1
Single Cortex-A7 MPCore
Integrated GIC
True
GIC included
Table 12-4. Cortex-A7 Core-Level Configuration
Option
Selected Value
Comments
NEON and/or FPU
FPU and NEON
FPU and NEON are both included in
each processor
12.5
Low-Power and Performance
This section will discuss the low-power and performance features of the Cortex-A7 Core
Platform.
The Cortex-A7 MPCore includes the following low-power features:
• Power-efficient processing provided by Cortex-A7 CPU
• 40nm LL process technology
• Flexible power domain partitioning with separate domains for the following blocks:
• CPU and respective L1 caches
• SCU and L2 cache controller
• L2 cache memory
• Debug including ETM
• Power-efficient timer events using combination of local generic timers and the global
system counter
• DVFS to support overdrive and non-overdrive modes of operation
Chapter 12 ARM Cortex A7 Platform (CA7)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
389

<!-- page 390 -->

Low-Power and Performance
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
390
NXP Semiconductors

