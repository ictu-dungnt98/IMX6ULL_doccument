# Chapter 54: TrustZone Address Space Controller (TZASC)

> Nguồn: `IMX6ULLRM.pdf` — trang 3559–3560

<!-- page 3559 -->

Chapter 54
TrustZone Address Space Controller (TZASC)
54.1
Overview
The TrustZone Address Space Controller (TZASC) protects security-sensitive SW and
data in a trusted execution environment against potentially compromised SW running on
the platform.
The TZASC block diagram is shown in figure below.
TZASC
 Clock and reset 
 
 AXI bus 
 Security lock signal 
 APB 
 Interrupt signal 
Slave
Interface
Slave
Interface
Master
Interface
Address
Region Control
AXI Bus
(to DDR Controller)
Figure 54-1. TZASC Block Diagram
The TZASC is an IP by Arm ("CoreLink™ TrustZone Address Space Controller
TZC-380"), designed to provide configurable protection over program (SW) memory
space.
The main features of TZASC are:
• Supports 16 independent address regions
• Access controls are independently programmable for each address region
• Sensitive registers may be locked
• Host interrupt may be programmed to signal attempted access control violations
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3559

<!-- page 3560 -->

• AXI master/slave interfaces for transactions
• APB slave interface for configuration and status reporting
54.2
Clocks
The table found here describes the clock sources for TZASC.
Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 54-1. TZASC Clocks
Clock name
Clock Root
Description
aclk
mmdc_axi_clk_root
Module clock
54.3
Address Mapping in various memory mapping modes
The address configured to the TZASC controller(s) must match the "local addresses" as
being passed on to the DDR controller(s).
Memory "aliasing" implications on TZASC settings - in systems which does not utilize
the maximal supported DDR space the controller is designed for, the whole DDR
memory map becomes "aliased" (replicated) by the size of the physical memory used. In
such cases, the TZASC must be configured to protect all aliased regions as well (i.e.
effectively reducing the number of available TZASC regions, since all aliased regions
must be handled, for each "real" space needing protection).
For complete details on TZASC functionality and the programming model, see the Arm
document, “CoreLink™ TrustZone Address Space Controller TZC-380 Technical
Reference Manual, (Rev r0p1 or newer)”, available at http://infocenter.arm.com.
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3560
NXP Semiconductors

