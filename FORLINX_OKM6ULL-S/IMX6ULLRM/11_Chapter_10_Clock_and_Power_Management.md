# Chapter 10: Clock and Power Management

> Nguồn: `IMX6ULLRM.pdf` — trang 345–380

<!-- page 345 -->

Chapter 10
Clock and Power Management
10.1
Introduction
This chapter describes the Clock and Power Management architecture of the SoC.
The chip targets applications where low power consumption, long battery life, always-on
and instant-on capabilities are paramount, and where there is no need for active cooling.
To achieve these capabilities, the primary focus of the chip's design is reducing current
consumption as much as possible, while simultaneously enabling the maximum level of
peak performance and a balanced level of sustained performance for target applications.
To achieve this, the chip architecture uses a wide range of power-management techniques
and their combinations for maximum system design flexibility.
This chapter contains information about:
• Structural components of the power and clock management systems of the chip
• Power, clock and thermal management techniques supported by the chip
All given numerical values are typical or examples. For accurate values one should refer
to the datasheet.
10.2
Device Power Management Architecture Components
To provide a clean and versatile architecture supporting a wide range of power-
management techniques, clocks, and power rails are managed resources.
For each rail, two levels of management are defined: the first level is centralized or SoC-
level resource management, and the second is a local or "module level" resource
management.
The high level architectural view of the clock, power and thermal management system of
the chip is presented in the figure below.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
345

<!-- page 346 -->

Power/Clock/Voltage Domain
Power/Clock/Voltage Domain
Clock 
Generation
PMU
(Integrated Power Regulators and 
Switches)
Configuration 
and Status 
Registers
Control and 
Status Logic
Voltage 
Sensors
Temperature 
Sensors
OSC 
24MHz
OSC 
32.768KHz
SNVS
SRC
CCM
GPC
LPCG
Power/Clock/Voltage Domain
Configuration 
and Status 
Registers
Configuration 
and Status 
Registers
Handshake
Logic
Handshake
Logic
Clock Root 
Generation
Clock N
Control and 
Status Logic
Clock 2
Clock 1
Control and 
Status Logic
POR
SNVS
POR
Power
Good
ON/OFF
ON/OFF
Button
SJC
DEBUG RST
VDD_SOC_IN
VDD_ARM_IN
VDD_HIGH_IN
VDD_SNVS_IN
PMIC_ON_REQ
CLK1
PMIC_STBY_REQ
Color Coding
Digital logic
Clocks
Power
Clock Ready
PLL Enables
Power State
Power State ACK
Power State REQ
Power State REQ
Power State ACK
Clock State REQ
Clock State ACK
Clock Enable
from Module
Root 1
Root 2
Root M
Module clock
Figure 10-1. Power and clock management framework
10.2.1
Centralized components of clock generation and
management
Centralized components of the clock generation and management sub-system are
implemented in the following blocks:
• CCM (Clock Control Module): The CCM module provides control for primary
(source level) and secondary (root level) clock generation, division, distribution,
synchronization, and coarse-level gating. See Clock Controller Module (CCM)) for
Device Power Management Architecture Components
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
346
NXP Semiconductors

<!-- page 347 -->

information on the CCM architecture, functional description and programming
model.
• LPCG (Low Power Clock Gating): This module distributes the clocks to all blocks in
the SoC and handles block level software-controllable and automated clock gating.
See Clock Controller Module (CCM) for information on the LPCG architecture and
functional description.
10.2.2
Centralized components of power generation, distribution
and management
Centralized components of the power generation, distribution and management sub-
system are implemented in the following blocks:
• Power Management Unit (PMU). See Power Management Unit (PMU) for
information on the PMU architecture, functional description and programming
model.
• General Power Controller (GPC). See General Power Controller (GPC) for
information on the GPC architecture, functional description and programming model.
10.2.3
Reset generation and distribution system
Power and clock management are accompanied with an appropriate reset generation and
distribution system, centralized functions of which are implemented by the System Reset
Controller (SRC). See General Power Controller (GPC) for information on the GPC
architecture, functional description and programming model.
10.2.4
Power and clock management framework
Together, the modules listed above provide enhanced power-management features with
centralized control for the clock, reset, and power-management signals on the SoC.
The centralized management framework defines the managed components of the power-
management architecture. These components are called the clock, power, and voltage
domains.
NOTE
A domain is a group of modules or functional blocks that share
a common resource entity (for example, common clock root,
common power source, or a common power switch). The
software component managing shared resources should take
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
347

<!-- page 348 -->

into account the joint constraints of all the modules belonging
to that resource domain.
10.3
Clock Management
10.3.1
Centralized components of clock management system
The clock generation and management system is built around the CCM and LPCG
blocks.
A high level block diagram of the clock management system in the SoC environment is
shown in the following figure.
Clock Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
348
NXP Semiconductors

<!-- page 349 -->

Clock Generation
OSC 
24MHz
OSC 
32.768K
CLK1
Clock Generation
Control and Status logic
Configuration and 
Status Registers
CCM
Control and Status logic
Stop
global_pll_lrf
Enable_ARM_PLL
Enable_SYS_PLL
Enable_SYS_PLL_PFDs
Enable_USB1_PLL
Enable_USB1_PLL_PFDs
Enable_AUD_PLL
Enable_VID_PLL
Enable_ENET_PLL
XTAL_ENABLE
XTAL_POWER_DOWN
XTAL_BYPASS
Enable_MLB_PLL
Clock Selection and Root Generation
SYS_PLL
SYS_PLL_PFDs[3:0]
USB1_PLL
USB1_PLL_PFDs[3:0]
AUD_PLL
VID_PLL
32K_CLK
24M_CLK
Configuration and 
Status Registers
IOMUX
ENET
REF_CLK
LPCG
Clock Gating Logic
Root 1
Root_1_enable
SRC
Root 2
Root_2_enable
Root xxx
Root_xxx_enable
Module 1
Module K
Mod_1_CLK1
Mod_1_CLK1_enable
Mod_1_CLK2
Mod_1_CLK2_enable
Mod_1_CLKX
Mod_1_CLKX_enable
Mod_K_CLK1
Mod_K_CLK1_enable
Mod_K_CLK2
Mod_K_CLK2_enable
Mod_K_CLKY
Mod_K_CLKY_enable
ARM
ARM_CLK
WFI
Clock 
enable
At Reset  
Frequency change /Stop 
Request (Optional)
Frequency change /Stop 
Acknowledge  (Optional)
Frequency change /Stop 
Request (Optional)
Frequency change /Stop 
Acknowledge  (Optional)
Figure 10-2. Clock Management System
A high level block diagram of the clock generation is shown in the figure below.
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
349

<!-- page 350 -->

OSC24M
CLK1 (In)
CLK1 (Out)
CLK2 (In)
528 PLL
528PFD0
528PFD2
528PFD1
ARM PLL
ENET PLL
VIDEO PLL
AUDIO PLL
ref_armpll_clk
ref_528pfd3_clk
ref_528pfd1_clk
ref_528pfd2_clk
ref_528pfd0_clk
ref_528pll_clk
ref_enetpll_clk (500 MHz)
ref_vidpll_clk
ref_audpll_clk
armpll_bypass
armpll_enable
528pfd3_enable
528pfd3_bypass
528pfd2_bypass
528pfd1_bypass
528pfd0_bypass
528pll_bypass
enetpll_bypass
vidpll_bypass
audpll_bypass
ref_audpll_clk
ref_vidpll_clk
ref_enetpll_clk
ref_528pll_clk
ref_528pfd0_clk
ref_528pfd1_clk
ref_528pfd2_clk
ref_528pfd3_clk
ref_480pll_clk
ref_480pfd0_clk
ref_480pfd1_clk
ref_480pfd2_clk
ref_480pfd3_clk
ref_armpll_clk
osc_24M
528pfd3_enable
528pfd3_enable
528pfd0_enable
580pll_enable
enetpll_enable
vidpll_enable
audpll_enable
armpll_bypass_sel[1:0]
528pll_bypass_sel[1:0]
enetpll_bypass_sel[1:0]
vidpll_bypass_sel[1:0]
audpll_bypass_sel[1:0]
USB1_PLL
480PFD0
480PFD3
480PFD2
480PFD1
ref_480pfd3_clk
ref_480pfd1_clk
ref_480pfd2_clk
ref_480pfd0_clk
ref_480pll_clk
480pfd3_enable
480pfd2_enable
480pfd1_enable
480pfd0_enable
480pll_enable
480pfd3_bypass
480pfd2_bypass
480pfd1_bypass
480pfd0_bypass
480pll_bypass
480pll_bypass_sel[1:0]
USB2_PLL
Usb2pll_bypass usb2_enable
Div_enet
CLK2 (Out)
ref_audpll_clk
ref_vidpll_clk
ref_enetpll_clk
ref_528pll_clk
ref_528pfd0_clk
ref_528pfd1_clk
ref_528pfd2_clk
ref_528pfd3_clk
ref_480pll_clk
ref_480pfd0_clk
ref_480pfd1_clk
ref_480pfd2_clk
ref_armpll_clk
osc_24M
Div1/2/4/8/16
Div1/2/4
125 MHz
100 MHz
25/50/100/125 MHz
Figure 10-3. Primary Clock Generation
10.3.2
Clock generation
The clock generation section includes the components detailed in the following sections.
Clock Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
350
NXP Semiconductors

<!-- page 351 -->

10.3.2.1
Crystal Oscillator (XTALOSC)
The Crystal Oscillator block is comprised of both the high frequency oscillator (typical
frequency is 24 MHz) and the low frequency real time clock oscillator (typical frequency
of 32.768 KHz). Each of these oscillators is implemented as a biased amplifier that, when
combined with a suitable external quartz crystal and external load capacitors, implements
an oscillator. See Crystal Oscillator (XTALOSC) for details of the XTALOSC block.
10.3.2.2
Low Voltage Differential Signaling (LVDS) I/O ports
There is one LVDS I/O port used for clock generation. The low jitter differential I/O port
is provided to input and output clocks. It can take input clocks from outside of the SoC
and provide them to the PLLs or to the other modules, or it can take the outputs of the
PLLs and provide them outside of the SoC as a functional or reference clock.
10.3.2.3
PLLs
Seven PLLs are included in the clock generation section. Two of these PLLs are each
equipped with four Phase Fractional Dividers (PFDs) in order to generate additional
frequencies.
NOTE
Each PFD works independently by interpolating the VCO of the
PLL to which it is connected. It effectively takes the PLL VCO
frequency and produces 18/N x Fvco at its output where N
ranges from 12 to 35. PFD is a completely digital design with
no analog components or feedback loops. The frequency switch
time is much faster than a PLL because keeping the base PLL
locked and changing the integer N only changes the logical
combination of the interpolated outputs of the VCO. Note that
the PFD not only enables faster frequency changes than a PLL,
but also allows the configuration to be safely changed "on-the-
fly" without going through the output clock disabling/enabling
process.
The seven PLLs are listed below:
• PLL1 (also referred to as ARM_PLL) - This is the PLL clocking the ARM core
complex. It is a programmable integer frequency multiplier capable of output
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
351

<!-- page 352 -->

frequency of up to 1.3 GHz. Note that this frequency is higher than the maximum
chip supported frequency 1.0 GHz.
• PLL2 (also referred tp as System_PLL or 528_PLL) - PLL2 runs at a fixed multiplier
of 22, producing 528 MHz output frequency with 24 MHz reference from
XTALOSC. Besides the main output, this PLL drives four PFDs
(PLL2_PFD0...PLL2_PFD3). The main PLL output and its PFD outputs are used as
inputs for many clock roots. These do not require exact/constant frequency and can
be changed as a part of dynamic frequency scaling procedure. Typically, this PLL or
its PFDs are a clock source for internal system buses, internal processing logic, DDR
interface, NAND/NOR interface modules, etc.
• PLL3 (also referred to as USB1_PLL) - PLL3 is used in conjunction with the first
instance of USB PHY (USBPHY1, also known as OTG PHY). This PLL drives four
PFDs (PLL3_PFD0...PLL3_PFD3) and runs at a fixed multiplier of 20. This results
in a VCO frequency of 480 MHz with a 24 MHz oscillator. The main PLL output
and its PFD outputs are used as inputs for many clock roots that require constant
frequency, such as UART and other serial interfaces, audio interfaces, etc.
• PLL4 (also referred to as an Audio PLL) - This is a fractional multiplier PLL used
for generating a low jitter and high precision audio clock with standardized audio
frequencies. The PLLs oscillator frequency range is from 650 MHz to 1300 MHz,
and the frequency resolution is better than 1 Hz. This clock is mainly used as a clock
for serial audio interfaces and as a reference clock for external audio codecs. It is
equipped with a divider on its output and can generate divided by 1, 2 or 4 from the
PLL VCO frequency.
• PLL5 (also referred to as a Video PLL) - This is a fractional multiplier PLL used for
generating a low jitter and high precision video clock with standardized video
frequencies. The PLLs oscillator frequency range is from 650 MHz to 1300 MHz,
and the frequency resolution is better than 1 Hz. This clock is mainly used as a clock
for display and video interfaces. It is equipped with dividers on its output and can
generate clock divided by 1, 2, 4, 8 or16 from the PLL VCO frequency
• PLL6 (also referred to as ENET_PLL) - This PLL implements a fixed 20+(5/6)
multiplier. With a 24 MHz input, it has a VCO frequency of 500 MHz. This PLL is
used to generate:
• 50 or 25 MHz for the external ethernet interface.
• 125 MHz for reduced gigabit ethernet interface.
• 100 MHz for general purposes.
• PLL7 (also referred to as USB2_PLL) - This PLL provides clock exclusively to
USB2 PHY (USBPHY2, also known as OTG PHY). It runs at a fixed multiplier of
20, resulting in a VCO frequency of 480 MHz with a 24 MHz oscillator.
Clock Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
352
NXP Semiconductors

<!-- page 353 -->

10.3.2.3.1
General PLL Control and Status Functions
Each PLLs configuration and control functions are accessible individually through its
PFDs and global configuration and status registers.
Reference input clock for any of the PLLs could be selected individually by the
BYPASS_CLK_SRC field of the PLL control register. See CCM Analog Memory Map/
Register Definition for more information.
Each of the PLLs could be individually configured to "Bypass", "Output disabled" and
"Power Down" modes.
When configured in "Bypass" PLL pass directly its input reference clocks to the PLL
output. Bypassing the PLL is done by setting the BYPASS bit in the control register. For
the PLL equipped with PFDs the input reference clock is also bypassed to all PFDs
outputs.
When configured in output disabled mode (ENABLE=0), the PLL's output is completely
gated and there is neither a bypass clock nor PLL generated clock that propagates to PLL
output. Each PLL output has an individual "Output Enable" control bit. The PFDs are
gated by the ENABLE bit of their associated PLL. Each PFD does have an associated
clock gate bit that can be used to turn it off individually.
When configured in "Power Down mode" most of the PLL circuitry is switched off.
Neither main PLL output nor PFD outputs are available in this mode.
When the related PLL is powered up from the power down state or made to go through a
relock cycle due to PLL reprogramming, it is required that the related PFDx_CLKGATE
bit in CCM_ANALOG_PFD_480n or CCM_ANALOG_PFD_528n, be cycled on and off
(1 to 0) after PLL lock. The PFDs can be in the clock gated state during PLL relock but
must be un-clock gated only after lock is achieved. See the engineering bulletin,
Configuration of Phase Fractional Dividers (EB790) at www.nxp.com for procedure
details.
Individual PLL status is reflected in "PLL Lock" bits of the PLL control registers. PLL
enable logic which monitors the register value change is implemented to gate off the PLL
outputs during the "lock in" period.
Outputs are generated to be sent out by monitoring the individual PLL lock flags and
filtering out any random initial edges.
Individual PLL Lock ready flags are first "ORED" with "enables" and then "ANDED"
together to generate the global PLL lock ready flag that reflects status of all PLLs
enabled in certain moment.
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
353

<!-- page 354 -->

CCM Memory Map/Register Definition and CCM Analog Memory Map/Register
Definition contains detailed descriptions of the memory mapped registers and control
functions of the clock generation sub-module.
10.3.2.4
CCM
CCM includes:
• Clock root generation logic - This sub-block provides the registers that control most
of the secondary clock source programming, including both the primary clock source
selection and the clock dividers. The clock roots are each individual clocks to the
core, system buses (AXI, AHB, IPG) and all other SoC peripherals, among those are
serial clocks, baud clocks, and special functional clocks. Most of clock roots are
specific per module.
• CCM, in coordination with GPC, PMU and SRC, manages the Power modes, namely
RUN, WAIT and STOP modes. The gating of the peripheral clocks is programmable
in RUN and WAIT modes.
CCM manages the frequency scaling procedure for:
• ARM core clock - "on the fly" without clock interruption, by either shifting between
PLL sources PLL clock change or by changing the divider ratio.
• changing of the DDR memory controller clock. See MMDC handshake and Self
refresh and Frequency change entry/exit for more details.
• Peripheral root clock - by using programmable divider. The division factor can
change on the fly without loss of clocks.
NOTE
On-the-fly frequency changing for synchronous interfaces like
serial audio interfaces, video and display interfaces, or general
purpose serial interfaces (e.g. UART, CAN) may cause
synchronization loss and should not be done.
10.3.2.5
Low Power Clock Gating unit (LPCG)
The LPCG block receives the root clocks from CCM and splits them to clock branches
for each block. The clock branches are individually gated clocks.
The enables for those gates can come from three sources:
Clock Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
354
NXP Semiconductors

<!-- page 355 -->

• Clock enable signal from CCM - This signal is generated depending on the power
mode the system is in. For each power mode, it is defined in the software using the
configuration of the CGR bits in CCM.
• Clock enable signal from the block - This signal is generated by the block based on
its internal logic. Not every enable signal from the block is used. Each clock enable
signal from the block can be overridden based on the programmable bit in CCM.
• Clock enable signal from the reset controller (SRC) - This signal will enable the
clock during the reset procedure.
10.3.3
Peripheral components of clock management system
10.3.3.1
Interface and functional clock
Each block within the SoC has specific clock input characteristic requirements. Based on
the characteristics of the clocks delivered to modules, the clocks are divided into two
categories: bus interface clocks and functional clocks.
The bus interface clocks have the following characteristics:
• They ensure proper communication between any block/subsystem and the system
buses.
• In most cases, they supply the system interface and configuration registers of the
block.
• A typical block has one system bus clock, but blocks with multiple interface clocks
may also exist (that is, when a block is connected to multiple buses).
• The bus interface clocks are always fed by the outputs of the CCM/LPCG.
• Clock management for this type of clock is always implemented at the system level
because it requires coordinated clock management between the block and system
buses.
Functional clocks have the following characteristics:
• They supply the functional part of a block or a subsystem.
• Typically, these clocks are completely asynchronous and independent from the bus
interface clock of the same block.
• A block can have one or more functional clocks. Some functional clocks are
mandatory, while others are optional for its functioning. A block needs its mandatory
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
355

<!-- page 356 -->

clock(s) to be operational. The optional clocks are used for specific features and can
be shut down without stopping the block activity.
• The functional clocks are fed either by a CCM/LPCG block functional clock output,
or by some other clock source, such as a clock output of another block or an external
signal coming from IOMUX.
10.3.3.2
Block level clock management
Each block in the system may also have specific clock requirements. Certain module
clocks must be active when operating in some specific modes, or may be gated in some
others. Generally, the activation and gating of the module clocks are managed by LPCG.
Hence, the LPCG block must be programmed properly and, in case of hardware
controllable clock gating, peripheral module should provide signals indicating when to
activate and when to gate the module clocks.
The LPCG block differentiates the clock-management behavior for device modules based
on whether the block can initiate transactions on the device interconnect (called master
module), or if it cannot initiate transactions and only responds to the transactions initiated
by the master (called slave module). Thus, two hardware-based clock-management
protocols are used:
• Master protocol - Clock-management protocol between the CCM/LPCG and blocks
that can be bus master
• Slave protocol - Clock-management protocol between the CCM/LPCG and slave
modules
10.3.3.2.1
Master clock protocol
This protocol is used to indicate that a master module is ready to initiate a transaction on
the device interconnect and requests specific (both functional and interface) clocks. The
CCM/LPCG block ensures that the required clocks are active when the master module
requests that the CCM/LPCG enable them. The module is said to be functional after the
required clocks are activated.
Similarly, when the master module no longer requires the clocks, it informs the
LPCG/CCM block and the LPCG/CCM can then gate the clocks to the module and all the
clock precedents that are not used by other blocks. The master module is then said to be
in clock-gated or partially clock gated mode.
Examples of module supporting master clock protocol USDHC. Please see details in
chapters describing these modules and in the CCM enable override register
(CCM_CMEOR).
Clock Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
356
NXP Semiconductors

<!-- page 357 -->

10.3.3.2.2
Slave clock protocol
This hardware protocol allows CCM to control the state of a slave module. CCM informs
the slave module, through assertion of a stop/change request, when its clocks (both
interface and functional) can be changed or gated. The slave acknowledges the request
and CCM is then allowed to gate or change the clocks to the block.
Similarly, a clock-gated slave module may need to be woken up because of some event or
a service request from a master module. In this situation, CCM enables the clocks to the
module and then de-asserts the stop request to signal the module to wake up.
Examples of modules supporting slave clock protocol are CAN,EPIT and GPT. Please
see details in chapters describing these modules and in the CCM Module Enable Overide
Register (CCM_CMEOR). See CCM Memory Map/Register Definition for more details.
The protocol in both "master" and "slave" cases is completely hardware-controlled, but
software should configure the clock management behavior for the module in two places:
in the CCM registers associated with the block and in the block configuration registers.
10.3.3.3
Clock Domain(s)
A clock domain is a group of blocks fed by clock signals controlled by the same clock
controls in CCM. By gating the clocks in a clock domain, the clocks to all the blocks
belonging to that clock domain can be gated/activated, either by software control or by
hardware control associated with block activity. Thus, a clock domain allows efficient
control of the dynamic power consumption of the domain.
The device is partitioned into multiple clock domains and each clock domain is
controlled by an associated group of clock gating cells within the LPCG block. This
allows the CCM/LPCG to individually activate and gate each clock domain of the
system.
10.3.3.4
Domain level clock management
The domain clock manager can automatically (based on hardware conditions) and
manage the bus interface clocks within the clock domain. The functional clocks within
the clock domain are managed through software settings.
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
357

<!-- page 358 -->

10.3.3.5
Domain dependencies
A domain dependency is a hierarchical relationship between two clock domains. Clock
domain "X" is said to depend on a clock domain "Y" when a block in clock domain "Y"
provides services (or even just a clock) to a block in clock domain "X". As a result, clock
domain "Y" must be active whenever clock domain "X" is active.
The dependency between two clock domains may also exist if one clock domain serves to
ensure communication between two blocks (for example, the clock domain of the device
interconnect).
10.4
Power management
Power management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
358
NXP Semiconductors

<!-- page 359 -->

10.4.1
Centralized Components of Power Management System
The power generation and management system is built around the PMU and GPC blocks.
A high level block diagram of the power management system in the SoC environment is
shown in the figure below.
PMU ( Regulators and Switches )
PMU 
(Configuration 
and Status 
Registers )
PMU 
(Control and 
Status Logic )
Voltage 
Sensors
SNVS
SRC
CCM
GPC
ARM Logic power 
sub-domain
Configuration 
and Status 
Registers
Power
Gating
Logic
Control and 
Status Logic
Power State
POR
SNVS
POR
Power
Good
ON/OFF
ON / OFF
Button
VDD_SOC_IN
VDD_ARM_IN
VDD_HIGH_IN
VDD_SNVS_IN
PMIC_ON_REQ
PMIC_STBY_REQ
Control and 
Status Logic
SoC power domain
Memories
sub-domain
Configuration 
and Status 
Registers
Power Gate
Request/ACK
ARM Power Gating
ARM Isolation Control
GPC
Interrupt
Controller
Wake-up Interrupt
Interrupt Controller
ARM power domain
power gating
isolation control
power domains
SOC_PD
Figure 10-4. Power Management System
10.4.1.1
Integrated PMU
The first component of the power management system, referred to as the integrated PMU,
is designed to simplify the external power interface.
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
359

<!-- page 360 -->

It consists of a set of secondary power supplies that enable SoC operations from just two
or three primary supplies. The high level block diagram of the power tree, utilizing the
integrated PMU, is shown below.
VDD_ARM_IN
USB  VBUS 
Device 5V
USB VBUS 
Host 5V
VDD_SOC_IN
VDD_HIGH_IN
LDO_2P5
LDO_1P1
Bandgap
SOC
(VDD)
Internal 
Memory
ARM
Core
(VDDG)
LDO_SNVS
(RTC)
LDO_USB
USB PHY
ARM PLL
528 PLL
Video PLL
Audio PLL
ENET PLL
Efuse 
Switch
EFUSE
DDR IO
Pre Drivers
VDD_SNVS_IN
TSNS
Temperature
OSC24M
OSC32K
SVNS
POR, PFD, 
CLKMON
LDO_ARM
LDO_SOC
NVCC_DRAM
SoC voltage domain
ARM
Power
domain
ADC
SOC_PD
Figure 10-5. i.MX 6ULL Power Tree
The integrated PMU includes the following components:
• Two Digital LDO regulators
• Two Analog LDO regulators
• USB LDO
• SNVS regulator
See Power Management Unit (PMU) for further details on integrated PMU functional
description and programmability.
Power management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
360
NXP Semiconductors

<!-- page 361 -->

10.4.1.1.1
Digital LDO Regulators
The integrated PMU includes three digital LDO regulators: LDO_ARM(VDD_ARM_IN,
VDD_ARM_CAP), and LDO_SOC(VDD_SOC_IN, VDD_SOC_CAP). LDO_ARM and
LDO_SOC regulators provide power to the ARM core power domain. LDO_SOC
provides power to the SOC_PD and SOC power domains(except always-ON SNVS
domain).
NOTE
The name "digital" only refers to the type of load. It is not
related to the LDO design or feature set.
The digital LDO regulators can operate in the following modes:
• Internal Bypass - The regulation pass device (FET) is switched fully on, passing the
external input voltage to the load unaltered. The analog part of the regulator is
powered down in this state, removing any loss other than the IR drop through the
power grid and the FET. Be aware that a period of time (see datasheet) is required to
switch from the internal digital bypass mode to the analog regulation mode.
Typically it takes less than 100us. Please refer to PMU for further details on bypass
and power gate configuration.
• Power Gate - The regulation FET is switched fully off, limiting the current draw
from the supply. The analog part of the regulator is powered down, limiting the
power consumption. The output voltage will fall to a level where the residual leakage
of the power FET balances with the leakage of the load.
• Analog regulation mode - The regulation FET is controlled such that the output
voltage of the regulator equals the programmed target voltage. The target voltage is
fully programmable in 25mV steps.
These modes allow the regulators to implement voltage scaling and power gating, and
allow bypass when an external high power efficient regulator is used as a direct source
for some of the SoC loads.
These digital regulators also feature brownout detection, which is helpful to sense when
supplies are starting to collapse. Note that the core will be interrupted on a brownout.
Please see details in Miscellaneous Control Register (PMU_MISC2n).
For further details of LDO programming and configuration please refer to Digital
Regulator Core Register (PMU_REG_COREn).
The power management system is built under assumption that in typical applications the
single (and simple) shared power supply will be used for ARM core domain and SoC
domain. The combined load gains some efficiency, especially in low power modes and
saves BoM significantly.
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
361

<!-- page 362 -->

The DVFS in a typical cost/complexity optimized application is considered by mean of
internal LDO. In"full speed" modes LDO bypass is considered in both domains. The
dynamic voltage scaling to low load workpoints for ARM domain is implemented by
programming associated LDO.
10.4.1.1.2
Analog LDO regulators
There are two analog LDO regulators used for general system purposes:
• LDO_1P1 - The LDO_1P1 (VDD_HIGH_IN, NVCC_PLL) linearly regulates down
a higher supply voltage (2.8V-3.3V) to produce a nominal 1.1V output voltage. This
regulator supplies digital portions of USB PHYs, PLLs, and the internal 24 MHz
oscillator.
• LDO_2P5 - The LDO_2P5 (VDD_HIGH_IN, VDD_HIGH_CAP) linearly regulates
down a higher supply voltage (2.8V-3.3V) to produce a nominal 2.5V output voltage.
The regular 2.5V LDO is combined with an alternate self-biased low-precision weak
regulator which can be enabled for applications that need to keep the 2.5V output
voltage alive during low power modes, where the main regulator and its associated
global bandgap reference module are disabled to save power. The output of this
weak-regulator is not programmable and is a function of its input power supply as
well as its load current. Typically with a 3V input power supply, the weak-regulator
output is 2.525V and its output impedance is approximately 40Ohm. Special
procedure is recommended to move load back and forth between the main and low
power regulators. This regulator supplies most of the analog circuitry of the
integrated PHYs, special I/Os (DDR I/O), and other analog and mix signal
components integrated into the SoC.
10.4.1.1.3
USB LDO
The USB_LDO linearly regulates down the USB VBUS input voltages (typically 5V) to
produce a nominal 3.0V output voltage. This regulator has a built in power-mux that
allows the user to run the regulator from either one of the VBUS supplies when both are
present. If only one of the VBUS voltages is present, the regulator automatically selects
that supply. Current limit is also included to help the system keep the in-rush current
within limits as required in USB 2.0 specification. This regulator supplies only low speed
and full speed transceivers of USB PHYs.
Power management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
362
NXP Semiconductors

<!-- page 363 -->

10.4.1.1.4
SNVS regulator
The SNVS regulator takes the SNVS_IN supply and generates the SNVS_CAP supply,
which in turn powers the real time clock and low power section of the SNVS blocks. If
VDDHIGH_IN is present, then the SNVS_IN supply is internally shorted to the
VDDHIGH_IN supply to allow coin cell recharging if necessary.
10.4.1.2
GPC - General Power Controller
The GPC block includes the sub-blocks listed here.
• Power Gating Controller (PGC) - This sub-block of GPC has the following functions:
• Provides the user with the ability to switch off power to a target subsystem.
• Generates power-up and power-down control sequences. This includes
interaction with CCM/LPCG and SRC, and control for clock and reset
generation for power domains affected by power gating.
• Provides programmable registers that adjust the timing of the power control
signals.
• Controls the CPU power domain and SOC_PD power domain.
• Wake-up interrupt controller - This controller initiates the system wake-up from low
power modes when only low frequency real time clock remains active, and thus the
Generic Interrupt Controller (GIC) can not handle synchronous interrupt signals.
Additional features are as follows:
• Supports up to 128 interrupts
• Provides an option to mask/unmask each interrupt
• Detects interrupts and generates the wake up signal
See General Power Controller (GPC) for further details on GPC, its sub-blocks, and
information on its functional description and programmability.
10.4.1.3
SRC - System reset Controller
The reset controller is responsible for the generation of all reset signals and boot
configuration decoding.
It determines the source and the type of reset, such as POR, WARM, and COLD, and
performs the necessary reset signal qualifications. SRC is capable of generating reset
sequences in the following conditions:
• in interaction with external PMIC, based on external POR_B signal and "power
ready" signals generated by the integrated PMU
• or in interaction with the integrated PMU only, based on its "power ready" signal.
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
363

<!-- page 364 -->

Based on the type of reset, the reset logic generates the reset sequence for either the entire
SoC or for the blocks that are power-gated.
See System Reset Controller (SRC) for further details on SRC functional description and
programmability.
10.4.1.4
Power domain(s)
A power domain is a group of blocks or sub-blocks fed by power sources controlled by
the same power controls in GPC.
Some power domains can be split into a logic sub-domain and a memory sub-domain.
The memory sub-domain in such case may contain two entities:
• Memory array(s) - Powered by a dedicated voltage rail enabling memory retention
while core is OFF.
• Memory interface logic - Powered by the same voltage source as the logic sub-
domain of the power domain.
Signals crossing power domain boundaries or sub-domain boundaries are passed through
proper isolation and/or level-shifting cells to ensure robust operations of the SoC when
some of domains are power gated or working at a reduced voltage.
The following figure shows the power domain interface within the system.
Memory
Interface
Power Gating 
Control
GPC
Module X
PMU
Memory Array
Memory 
Interface Logic
Functional 
Logic and 
FlipFlops
CCM
Isolation 
And
Level 
Shifters  
Isolation 
And
Level 
Shifters  
Module 
Power Gating 
Control
Module 
Isolation
Control
Memory
Sub-domain
Isolation control
Memory
Sub-domain
Power Gating 
Control
To the rest 
of SoC
Figure 10-6. Power domain interface
Power management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
364
NXP Semiconductors

<!-- page 365 -->

10.4.1.4.1
Power distribution
The power distribution tree is comprised of multiple power domains. The main power
domains are:
• ARM - The ARM domain contains the ARM Core platform (except for memory
arrays and interface logic). This domain can be supplied either from an integrated
power supply or from an external controllable regulator, preferably high efficiency
DCDC converter.
• ARM Memory array - Memory arrays are connected to a separate and dedicated
power domain (separated from the Main logic and ARM domain). In normal
operation mode (functional mode), the memory arrays domain voltage level should
be kept equal to (same as) the rest of the core logic domains (Main, ARM). Please
refer to the Datasheet for further information about voltage level difference between
domains allowed in different power modes.
• SOC_PD domain -- The SOC_PD domain contains MMDC, APBHDMA, CSI,
ENET, LCDIF, PXP, RawNAND, SDMA, uSDHC and USB. It is supplied by
external regulator.
• SNVS/RTC low power domain - The SRTC domain contains only counter,
comparator and compared data of the on-chip RTC. This domain should be supplied
from an external single cell LiION battery and/or an external pre-regulated power
supply. SNVS also contains Low Power State Retention (LPSR) GPIO, IOMUX, and
LPSR general purpose register.
• Analog domain - The analog domain contains the PLLs, LDOs and USB PHY. The
domain supplies should be constant to allow continuous clock during any dynamic
voltage scaling techniques. The digital supply should be provided from an internal
regulator, and can be combined with the memory array supply. The analog supply
should be provided from internal low noise regulator.
• Main SoC logic - The main SoC logic domain contains the rest of the logic of the
SoC. It is supplied by an internal regulator.
From a DVFS and Power Gating standpoint, the following digital logic domains are
affected:
• Cortex-A7 Core Platform - DVFS and power gating.
• ARM Cortex-A7 memories - Power gating only.
• SOC_PD - Power gating only.
See table below for details of the system power domains layout and dependencies.
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
365

<!-- page 366 -->

10.4.1.4.2
Domain Memory and domain logic state retention in case of
Power Gating
The following is the list of relevant memories and logic domains with the description of
their state-retention support:
• Cortex-A7 Core Platform is sub-divided into three sub-domains listed below:
• Cortex-A7 Core Platform logic: The software state retention for all logic is
implemented in this domain. That means that the content of relevant registers should
be be stored in some memory retaining its state (L2 cache for example) while the
logic domain is power-gated. Details on how to implement the software retention can
be found in the Cortex-A7 Core Platform TRM.
• Cortex-A7 Core L1 memories - No retention. The L1 memories have a dedicated
supply on the package (VDD_CACHE_CAP) which should be connected to the
Cortex-A7 Core Platform supply. The L1 cache should be flushed prior to power
gating in order to allow powering up of the CPU at the same state as before power
gating.
• Cortex-A7 Core L2 memories - hardware state-retention since its supplies are driven
by the SoC supplies. When Cortex-A7 core is power gated, L2 Cache can be either
leaved on with its content retained or power gated together with the core.
• SOC_PD: This module can be powered gated (together) independently of Cortex-A7
power gating. SOC_PD is not allowed power down when Cortex-A7 is on. SOC_PD
will be powered on automatically together with Cortex-A7.
• SoC - hardware state-retention in Standby mode.
• SNVS_LP - hardware state-retention even when SoC supplies are removed.
10.4.1.4.3
Power Gating Domain Management
The following bullets provide the sequence required for power-gating the relevant power-
domains:
10.4.1.4.3.1
ARM Core Platform
1. Copy through software all the Core configuration registers to a powered-on memory
2. Configure the GPC/PGC CPU registers in PGC Memory Map/Register Definition as
follows to power-down the core on the next "WFI" instruction:
• Configure the GPC/PGC PGC_CPU_PDNSCR Register ISO and ISO2SW bits.
These bits determine the delay between the power-down request to enabling the
platform isolation and the platform isolation to the actual power-off switch to the
supplies accordingly.
• Configure the GPC/PGC PGC_CPU_PUPSCR Register SW and SW2ISO bits.
These bits determine the delay between the power-up request to the actual
power-up of the supplies and the last to the platform isolation disabling.
Power management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
366
NXP Semiconductors

<!-- page 367 -->

• Configure the GPC PGC PGC_CPU_CTRL PCR bit to allow the power down of
the platform
• ARM Core Platform should execute a "WFI" instruction.
ISO Count
ISO2SW Count
SW Count
SW2ISO Count
Power Down
Isolation enable
Power on
Power sequence phase
Figure 10-7. ARM Core Platform isolation and power on switch flow
10.4.1.4.3.2
SOC_PD
1. Configure the CCM CGR bits (CCM Memory Map/Register Definition) to disable
the SOC_PD clocks .
2. Configure the GPC/PGC Registers (GPC Memory Map/Register Definition) as
follows to power-down isolate the SOC_PD logic from the rest of the SoC logic:
Configure the GPC/PGC PDNSCR Register ISO bits. These bits determine the delay
between the power-down request to enabling the LDO domain isolation.
Configure the GPC/PGC PUPSCR Register SW2ISO bits. These bits determine the
power-up request to the LDO domain isolation disabling.
Configure the GPC/PGC CTRL[PCR] bit to allow the power down of the block.
Configure the GPC/PGC GPC_CNTR to power down SOC_PD
ISO Count
SW Gate Supply
SW Enable Supply
SW2ISO Count
Power Down
Isolation enable
Power on
Power sequence phase
Figure 10-8. SOC_PD isolation and power on switch flow
10.4.1.4.3.3
SoC
For additional power reduction it is possible to do the following:
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
367

<!-- page 368 -->

• Power-down the internal oscillator by configuring the following bits
CCM_CCR[COSC_EN] (CCM Memory Map/Register Definition). This can be done
only in case there is no dependency on 24 MHz XTAL for wake-up.
• It is possible to turn off and turn on the PMIC supplies to the SoC even when the
SoC supplies are off. Since SNVS_LP is powered through an "always on" supply,
configuring the SNVS_LP DP_EN to "1" allows changing the PMIC_ON_REQ pad
(SoC on/off supply indication to the PMIC) through the ONOFF pad.
10.4.1.4.4
Power Gating domain dependencies
There are 3 power domains that need to be isolated in different power-down cases:
• Cortex-A7 Core Platform and SOC_PD - Isolation needs to be enabled before power-
down. This is taken care of automatically once CCM and PGC are configured and the
Cortex-A7 Core Platform executes the "WFI" instruction.
• SNVS_LP - Different from the 2 cases above, the SNVS_LP isolation isolates the
signals coming from the SoC to the SNVS_LP. This is required for saving the
contents of the SNVS_LP (such as the real-time clock). The isolation is activated in 2
ways:
• Automatically through the power-fail detector in the PMU
• Through software configuration
Note: The arrows refer to the signal directions for the voltage level shifters and isolation cells
SoC Voltage
Domain
volt level
shifters
isolation
cells
ARM
volt level
shifters
isolation
cells
SNVS_LP
isolation
cells
SOC_PD
Figure 10-9. Isolation cells and Voltage level shifters placing
Power management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
368
NXP Semiconductors

<!-- page 369 -->

10.4.1.5
Voltage domains
The list found here states the different voltage domains and their scalability in regarding
to power-saving in dynamic and static scenarios.
• ARM - Cortex-A7 Core Platform including L1 and L2 cache - Scalable voltage in
both dynamic and static scenarios
• SoC Domains - Scalable voltage only in static scenarios
• ANALOG components including PLLs - Fixed voltage
• I/O - Fixed voltage
• SNVS_LP - Fixed voltage
10.4.1.6
Voltage domain management
10.4.1.6.1
Dynamic
10.4.1.6.1.1
Voltage Scaling
A simplistic way to reduce power consumption in dynamic scenarios is to scale down the
ARM, SoC and LDOs voltage according to the allowed voltage points and corresponding
frequencies specified in datasheet.
10.4.1.6.2
Static
10.4.1.6.2.1
Standby Leakage reduction (SLR)
Standby leakage reduction is a power-management technique utilizing:
• Reduced supply voltage for relevant domains
With SLR, the device switches into low-power active system modes automatically or in
response to user requests during system Stop, Wait, or DSM modes (that is, in situations
when no application is started and no system activity is presented).
When applying SLR, the system remains in the lowest static power mode while retaining
logic and memory states. This technique trades static power consumption for wake-up
latency while maintaining fast system response time suitable for most applications.
See CCM Control Register (CCM_CCR), CCM Low Power Control Register
(CCM_CLPCR) and PMU Miscellaneous Register 0 (PMU_MISC0) for further details
on SLR programmability options.
The following describes the flow for applying standby voltage:
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
369

<!-- page 370 -->

• Configure the external PMIC standby voltage, refer to chip datasheet.
• Configure CCM_CCR[RBC_EN] bits to bypass and disable PMU regulators in the
next ARM "WFI" execution.
• Configure CCM_CCR[REG_BYP_COUNT] bits to allow proper voltage restoration
by the external PMIC when exiting standby.
• ARM Core Platform executes the "WFI" instruction that completes the software
sequence putting the SoC into low power mode
10.4.1.6.2.2
ANALOG PHYs IPs
Details on how to put the IPs in low power mode can be found in each of the IP
documentation. Further reduction can be achieved by settings the
ENABLE_WEAK_LINREG in the PMU PMU_REG_2P5 register.
10.4.1.7
System domains layout
The following table describes the different power modes.
Table 10-1. Low Power Mode Definition (LDO Enabled Mode)
System IDLE
Low Power IDLE
SUSPEND
CCM LPM Mode
WAIT
WAIT
STOP
ARM Core
Low Voltage
Power Down
Power Down
L1 Cache
ON
Power Down
Power Down
L2 Cache
ON
ON
Power Down
SOC
Nominal Voltage
Nominal Voltage
Standby Voltage
SOC_PD
ON
ON
ON/Power Down
PLL
ON/Power Down
Power Down
Power Down
XTAL
ON
OFF
OFF
RC OSC
OFF
ON
OFF
DRAM
Self_Refresh1
Self-Refresh2
Self-Refresh2
DRAM IO Low Power
No
Yes
Yes
LDO ARM
ON
Power Gate
Power Gate
LDO SOC
ON
ON
Digital Bypass
LDO2P5
ON
OFF
OFF
LDO1P1
ON
OFF
OFF
WEAK2P5
OFF
ON
OFF
WEAK1P1
OFF
ON
OFF
Bandgap
ON
ON
OFF
Low Power Bandgap
OFF
OFF
OFF
MMDC Clock
24 MHz
OFF
OFF
Table continues on the next page...
Power management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
370
NXP Semiconductors

<!-- page 371 -->

Table 10-1. Low Power Mode Definition (LDO Enabled Mode) (continued)
System IDLE
Low Power IDLE
SUSPEND
AHB clock
24 MHz
3 MHz
OFF
IPG clock
12 MHz
1.5 MHz
OFF
PER clock
24 MHz
1 MHz
OFF
Module clocks
ON as needed
ON as needed
OFF
GPIO wakeup
yes
Yes
Yes
RTC wakeup
Yes
Yes
Yes
USB remote wakeup
Yes
Yes3
Yes3
Other wakeup source
Yes
Yes4
No
1.
Automatic enter self-refresh when there is no DRAM access;
2.
Put into self-refresh mode by SW before entering low power mode;
3.
Need SOC_PD power on to support USB remote wakeup;
4.
When a module is inside SOC_PD domain, need SOC_PD power on to support wakeup from it.
Table 10-2. Low Power Mode Definition (LDO Bypass Mode)
System IDLE
Low Power IDLE
SUSPEND
CCM LPM Mode
WAIT
WAIT
STOP
ARM Core
Low Voltage
Power Down
Power Down
L1 Cache
Low Voltage
Power Down
Power Down
L2 Cache
ON
ON
Power Down
SOC
Nominal Voltage
Nominal Voltage
Standby Voltage
SOC_PD
ON
ON
ON/Power Down
PLL
ON/Power Down
Power Down
Power Down
XTAL
ON
OFF
OFF
RC OSC
OFF
ON
OFF
DRAM
Self_Refresh1
Self-Refresh2
Self-Refresh2
DRAM IO Low Power
No
Yes
Yes
LDO ARM
Digital Bypass
Power Gate
Power Gate
LDO SOC
Digital Bypass
Digital Bypass
Digital Bypass
LDO2P5
ON
OFF
OFF
LDO1P1
ON
OFF
OFF
WEAK2P5
OFF
ON
OFF
WEAK1P1
OFF
ON
OFF
Bandgap
ON
OFF
OFF
Low Power Bandgap
OFF
ON
OFF
MMDC Clock
24 MHz
OFF
OFF
AHB clock
24 MHz
3 MHz
OFF
IPG clock
12 MHz
1.5 MHz
OFF
PER clock
24 MHz
1 MHz
OFF
Module clocks
ON as needed
ON as needed
OFF
GPIO wakeup
Yes
Yes
Yes
Table continues on the next page...
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
371

<!-- page 372 -->

Table 10-2. Low Power Mode Definition (LDO Bypass Mode) (continued)
System IDLE
Low Power IDLE
SUSPEND
RTC wakeup
Yes
Yes
Yes
USB remote wakeup
Yes
Yes3
Yes3
Other wakeup source
Yes
Yes4
No
1.
Automatic enter self-refresh when there is no DRAM access;
2.
Put into self-refresh mode by SW before entering low power mode;
3.
Need SOC_PD power on to support USB remote wakeup;
4.
When a module is inside SOC_PD domain, need SOC_PD power on to support wakeup from it.
There is a single hardware signal coming into PMU which sets the PMU in either of two
"STOP" states. The STOP state is implemented is controlled by the
PMU_MISC0[STOP_MODE_CONFIG] bit (See PMU Memory Map/Register
Definition). It is recommended that the blocks be configured for safe powerdown/up
through the registers before asserting the stop_mode signal. Blocks not described in the
section below are unaffected by stop_mode.
If the stop_mode_config is set to zero, thus in the STOP mode all blocks powered down
in minimum power configuration.
If the stop_mode_config is set to one, thus in the STOP mode some of the blocks remain
powered and in different states as defined in the table below.
Table 10-3. STOP mode configuration
Block
STOP_MODE_CONFIG=0
STOP_MODE_CONFIG=1
reg1p1
off
on
reg2p5
off
on
reg3p0
off/on depending on vbus. Uses crude
local reference if vbus is present
off/on depending on vbus . Uses analog
central bandgap if VBUS is present.
reg_core
bypassed if not power gated.
bypassed if not power gated
reg_soc
bypassed
bypassed
bandgap
off
functional
temp_sensor
off
off
well_bias
hardware controlled
hardware controlled
All PLLs
off
off
OSC24M
off
Controlled by CCM configuration
10.4.2
Power management techniques
The device supports the power-management techniques with the features found here.
• Partitioning of the device into voltage, power, clock, and reset domains
Power management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
372
NXP Semiconductors

<!-- page 373 -->

• Domain isolation that allows flexible configurations of domains on/off states to form
use cases targeting various applications
• Clock tree with selective clock-gating conditions and almost independent clock roots
• Power, reset, and clock control hardware mechanism to manage sleep and wake-up
dependencies of power domains
• Software-controllable and hardware-controllable clock gating for functional modules
and buses
• Memory retention and state retention capability (Software State Retention for ARM
core) for preserving memory contents and device state in low-power modes
• Support for low-power device modes input/output (I/O) pad configuration for
minimum power
• Variety of operating modes to optimize device performance and wake-up times
• Thermal monitoring and thermal aware performance management
Many of the low power features are fully or partially software controllable and can be
configured for the specific requirements of a target system.
Combining these techniques, the system designer may meet tight requirements of low-
power standby and operational modes while maintaining high performance for time-
critical tasks.
10.4.2.1
Power saving techniques
The table below lists power saving techniques supported by the SoC in their connection
to different components of power consumption.
Table 10-4. Power saving design/architecture and power saving techniques
Techniques
Active SoC
Power
Standby SoC
Power
System
Power
Temperature Monitoring, and active frequency throttling
√
ARM Core Platform SRPG (Software)
√
ARM Core Platform Power Gating
√
Clock gating (automatic dynamic and forced)
√
Integrated PMU (IR drop, efficiency, accuracy)
√
√
C4 package (IR drop, thermal)
√
Display Backlight optimization (SW)
√
Architecture: L2 cache
√
Architecture: USB integration
√
Low Power DDR: LPDDR2, LV-DDR3
√
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
373

<!-- page 374 -->

10.4.2.2
Thermal-aware power management
The temperature sensor block (TEMPMON) implements a temperature sensor/conversion
function. The block features an alarm function that can raise an interrupt signal if the
temperature is above a specified threshold.
Software may implement temperature aware DVFS for the ARM domain as well as
temperature aware frequency scaling for other system components to ensure that both the
frequency and voltage is lowered when the die temperature is above the specified limit.
Software may also implement temperature aware task scheduling to ensure that non-
critical tasks are suspended when the die temperature is above the specified limit.
See Temperature Monitor (TEMPMON) for further details on temperature monitor
functions and programmability options.
10.4.2.3
Peripheral Power management
10.4.2.3.1
Main memory power management
Main system memory, DDR3, and LPDDR2 are some of the most power-hungry system
components, but the SoC provides several options to manage DDR power.
Automated power saving modes are supported by the MMDC hardware. This feature
allows the DDR memory to automatically enter self-refresh mode when there are no
DDR accesses for a configurable time. The default setting is 1024 clock cycles which can
be optimized based on the customer use case and application.
See Power Saving and Clock Frequency Change modes for further details on MMDC
power saving features and programmability options.
Software may support DDR frequency scaling. Automated frequency changing procedure
is supported by MMDC and CCM modules.
NOTE
DDR frequency changes cost extra time and power. Slowing
requestors while keeping DDR at full speed may increase total
system power. Software may also implement Cooperative
Dynamic Frequency Scaling in order to keep the system
balanced, (that is, keep the system in balance when DDR
throughput is equal or slightly higher than total amount of
requests generated by all requestors).
Power management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
374
NXP Semiconductors

<!-- page 375 -->

Reducing the DDR frequency while in DLL-ON mode may be not efficient because:
• Reduction in DDR frequency will cause bus duty cycle to increase and thus reduces
chance of automatic MMDC power saving (place memory into SR).
• Total amount of read/write operation does not change (power is per-operation).
• The termination is active longer, though, lowering frequency below 396 MHz may
enable lowering drive strengths and termination.
When possible at lower performance use cases, software may switch DDR3 to DLL-off
mode. This allows it to greatly reduce DDR3 frequency and thus disable or reduce
termination and drive strength, which significantly reduces the power consumption of the
DDR3 interface.
A good strategy for many types of workloads is to combine most activity in bursts
(natively possible, for example, for typical multimedia applications, communication, etc.)
and run this segment at maximal speed, then switch to DLL-OFF mode to support
background activity (communication, display refresh, housekeeping).
The DRAM Interface power dissipation depends on many variables, however, proper
termination and drive strength is key for power and thermal performance. Memory and
controllers provide a host of programmable options for the drive strength of the output
buffers and for the on-die termination impedance.
The ideal settings for drive strength and ODT also depend on the clock frequency to
ensure that inter-symbol interference (ISI) effects are not introduced.
DDR PHY power is proportional to the amount and type of bus activity.
In cases where the DDR is placed into self-refresh, software can configure DDR I/O to be
floated or lowered to the minimum drive allowed by JEDEC.
Modifying the DDR drive strength must be done by code that is executing from a
memory region other than DDR (for example, IRAM). No access to DDR (including
page table walks, cache misses, alternate bus master accesses, etc.) is allowed while the
DDR I/O pads are being re-configured.
10.4.2.3.2
Video-Graphics system power management
10.4.2.3.3
IO power reduction
Software configures IO to low power modes:
• PHYs - make sure that all unused PHYs are placed to lowest power state. Please refer
relevant chapter for further information about different PHYs
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
375

<!-- page 376 -->

• Digital IOs - Make sure all unnecessary PU/PD are disabled and IO are switched to
either minimal drive strength or to input mode (when applicable)
• Set DDR type IO to CMOS mode if possible
10.4.3
Examples of External Power Supply Interface
This section presents the example of external power supply interfacing to the chip.
The scenario based on integrated PMU system is presented in the following figure. This
scenario minimizes BoM and board design complexity.
Power management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
376
NXP Semiconductors

<!-- page 377 -->

i.MX6 UltraLite
VDD_SNVS_CAP
VDD_SNVS_IN
SNVS_IO
NVCC_DRAM
DRAM_IO
NVCC_LVDS_2P5
LVDS_IO
VDD_ARM_IN
VDD_SOC_IN
VDD_HIGH_IN
LDO_ARM
LDO_SOC
ARM
CACHE Array
SNVS (LP)
LDO_SNVS
LDO_2P5
VDD_HIGH_CAP
VDD_ARM_CAP
LDO_1P1
OSC (24M)
NVCC_PLL_OUT
PMIC_ON_REQ
PMIC_STBY_REQ
POR
ON/OFF
Button
 DCDC 
DCDC High 
 
Could be connected to either coincell /
supercap in case of systems keeping real 
time clock in OFF mode. Otherwise could 
be combined with VDDHIGH_IN
Optional POR signal from DCDC converters
PWR_GOOD
PWR_GOOD
STBY
STBY
ON/OFF
ON/OFF
Optional Standby request  signal to DCDC converters
 
 
  
      
NVCC_LVDS_2P5 should 
be connected directly to
VDD_HIGH_CAP
SoC logic
DISPLAY
VDD_SoC_CAP
OSC (32K)
VADC
ADC
VDD_AFE_1P2
VDDA_AFE_3P3
VDDA_ADC_3P3
eFUSE
USB
PLLs
LDO_USB
VDD_USB_CAP
VDD_OTG2_VBUS
VDD_OTG1_VBUS
NVCC_xxx
GPIO Pads
NVCC_USB_H
USB 
PADs
Digital IO supplies should 
be provided per application 
requirements. All IO group 
supplies at the same
operating voltage, except 
NVCC_DRAM, can be combined.
Figure 10-10. Supplying i.MX 6ULL power using integrated PMU
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
377

<!-- page 378 -->

10.5
ONOFF (Button)
The chip supports the use of a button input signal to request main SoC power state
changes (i.e. On or Off) from the PMU.
The ONOFF logic inside of SNVS_LP allows for connecting directly to a PMIC or other
voltage regulator device. The logic takes a button input signal and then outputs a
pmic_en_b and set_pwr_off_irq signal. PMIC logic also supports the SNVS_LP tamper
logic which will allow waking the system up when a tamper event has happened while in
the OFF state. The logic has two different modes of operation (Dumb and Smart mode).
The Dumb PMIC Mode uses pmic_en_b to issue a level signal for on and off. Dumb
pmic mode has many different configuration options which include (debounce, off to on
time, and max time out).
• Debounce: The debounce configuration supports 0 msec, 50 msec, 100 msec and 500
msec. The debounce is used to generate the set_pwr_off_irq interrupt. While in the
ON state and the button is pressed longer than the debounce time the set_pwr_off_irq
is generated.
• Off to On Time: The Off to On configuration supports 0 msec, 50 msec, 100 msec,
and 500 msec. This configuration supports the time it takes to request power on after
the configured button press time has been reached. Once the button is pressed longer
than the configuration time, the state machine will transition from the OFF to the ON
state.
• Max Timeout: The max timeout configuration supports 5 secs, 10 secs, 15 secs and
disable. This configuration supports the time it takes to request power down after the
button has been pressed for the defined time.
The Dumb PMIC mode uses a 2 state state machine, as shown below. The output of the
pmic_en_b is generated by the state of the state machine.
ONOFF (Button)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
378
NXP Semiconductors

<!-- page 379 -->

ON
OFF
Reset
Button press longer
than the max timeout
or software enabled
shutdown
Wakeup or button 
press longer than 
Off to On configuration
Figure 10-11. Dumb PMIC Mode State Machine
The Smart PMIC mode is meant to connect to another PMIC. The pmic_en_b signal
issues a pulse instead of a level signal. The only configuration option available for this
mode is the Debounce configuration that is used for the set_pwr_off_irq.
Chapter 10 Clock and Power Management
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
379

<!-- page 380 -->

ONOFF (Button)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
380
NXP Semiconductors

