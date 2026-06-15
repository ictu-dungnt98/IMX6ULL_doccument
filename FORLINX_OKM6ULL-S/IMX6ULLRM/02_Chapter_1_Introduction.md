# Chapter 1: Introduction

> Nguồn: `IMX6ULLRM.pdf` — trang 159–174

<!-- page 159 -->

Chapter 1
Introduction
1.1
About This Document
The i.MX 6ULL application processors are NXP's latest additions to a growing family of
real-time processing products offering high-performance processing optimized for lowest
power consumption.
The i.MX 6ULL processors feature NXP's advanced implementation of the
ARM®Cortex®-A7 core.
The processors can be interfaced with DDR3, DDR3L LPDDR2 (single channel) DRAM
memory devices.
These products are suitable for applications such as:
• eReaders
• General embedded devices
• Industrial devices
1.1.1
Audience
This manual is intended for the board-level product designers and product software
developers. This manual assumes that the reader has a background in computer
engineering and/or software engineering and understands the concepts of the digital
system design, microprocessor architecture, Input/Output (I/O) devices, industry standard
communication, and device interface protocols.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
159

<!-- page 160 -->

1.1.2
Organization
This document covers the chip at a system level and provides an architectural overview.
It also covers the system memory map, system-level interrupt events, external pins and
pin multiplexing, external memory, system debug, system boot, multimedia subsystem,
power management, and system security.
1.1.3
Suggested Reading
This section lists the additional resources that provide background for the information in
this manual, as well as general information about the architecture.
1.1.3.1
General Information
The following documentation provides useful background information about the ARM
Cortex processor.
For information about the ARM Cortex processor see:
• http://infocenter.arm.com
1.1.3.2
Related Documentation
NXP documentation is available from the sources listed on the back cover of this manual;
the document order numbers are included in parentheses for ease in ordering.
For a current list of documentation, refer to http://www.nxp.com.
1.1.4
Conventions
This document uses the following notational conventions:
cleared / set
When a bit has a value of zero, it is said to be cleared; when it has a value of one, it is
said to be set.
mnemonics
Instruction mnemonics are shown in lowercase bold.
italics
Italics indicate variable command parameters, for example, bcctrx.
The book titles in the text are set in italics.
About This Document
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
160
NXP Semiconductors

<!-- page 161 -->

15
An integer in decimal.
0x
the prefix to denote a hexadecimal number.
0b
The prefix to denote a binary number. Binary values of 0 and 1 are written without a
prefix.
n'H4000CA00
The n-bit hexadecimal number.
BLK_REG_NAME
The register names are all uppercase. The block mnemonic is prepended with an
underscore delimiter (_).
BLK_REG[FIELD]
The fields within registers appear in brackets. For example, ESR[RLS] refers to the
Receive Last Slot field of the ESAI Status Register.
BLK_REG[ n]
The bit number n within the BLK.REG register.
BLK_REG[ l:r]
The register bit ranges. The ranges are indicated by the left-most bit number l and the
right-most bit number r, separated by a colon (:). For example, ESR[15:0] refers to the
lower half word in the ESAI Status Register.
x, U
In some contexts, such as signal encodings, an unitalicized x indicates a "don't care" or
"uninitialized". The binary value can be 1 or 0.
x
An italicized x indicates an alphanumeric variable.
n, m
Italicized n or m represent integer variables.
!
Binary logic operator NOT.
&&
Binary logic operator AND.
||
Binary logic operator OR.
^ or <O+>
Binary logic operator XOR. For example, A <O+> B.
|
Bit-wise OR. For example, 0b0001 | 0b1000 yields the value of 0b1001.
&
Bit-wise AND. For example, 0b0001 and 0b1000 yields the value of 0b0000.
{A,B}
Chapter 1 Introduction
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
161

<!-- page 162 -->

Concatenation, where the n-bit value A is prepended to the m-bit value B to form an (n
+m)-bit value. For example, {0, REGm [14:0]} yeilds a 16-bit value with 0 in the most
significant bit.
- or grey fill
Indicates a reserved bit field in a register. Although these bits can be written to with
ones or zeros, they always read zeros.
>>
Shift right logical one position.
<<
Shift left logical one position.
<=
Assignment.
==
Compare equal.
!=
Compare not equal.
>
Greater than.
<
Less than.
1.1.5
Register Access
1.1.5.1
Register Diagram Field Access Type Legend
This figure provides the interpretation of the notation used in the register diagrams for a
number of common field access types:
1
Reserved
returns 1
on read
0
Reserved
returns 0
on read
Fld
R/W
field
Read-only
field
Fld
Fld
Write-only
field
Fld
rtc
Fld
Fld
w1c
0
Write 1
to clear
Read
to clear
Self-
clear bit
Reserved
Figure 1-1. Register Field Conventions
NOTE
For reserved register fields, the software should mask off the
data in the field after a read (the software can't rely on the
contents of data read from a reserved field) and always write all
zeros.
About This Document
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
162
NXP Semiconductors

<!-- page 163 -->

1.1.5.2
Register Macro Usage
A common operation is to update one field without disturbing the contents of the
remaining fields in the register. Normally, this requires a read-modify-write (RMW)
operation, where the CPU reads the register, modifies the target field, then writes the
results back to the register. This is an expensive operation in terms of CPU cycles,
because of the initial register read.
To address this issue, some hardware registers are implemented as a group, including
registers that can be used to either set, clear, or toggle (SCT) individual bits of the
primary register. When writing to an SCT register, all the bits set to 1 perform the
associated operation on the primary register, while the bits set to 0 are not affected. The
SCT registers always read back 0, and should be considered write-only. The SCT
registers are not implemented if the primary register is read-only.
With this architecture, it is possible to update one or more fields using only register
writes. First, all bits of the target fields are cleared by a write to the associated clear
register, then the desired value of the target fields is written to the set register. This
sequence of two writes is referred to as a clear-set (CS) operation.
A CS operation does have one potential drawback. Whenever a field is modified, the
hardware sees a value of 0 before the final value is written. For most fields, passing
through the 0 state is not a problem. Nonetheless, this behavior is something to consider
when using a CS operation.
Also, a CS operation is not required for fields that are one-bit wide. While the CS
operation works in this case, it is more efficient to simply set or clear the target bit (that
is, one write instead of two). A simple set or clear operation is also atomic, while a CS
operation is not.
Note that not all macros for set, clear, or toggle (SCT) are atomic. For registers that do
not provide hardware support for this functionality, these macros are implemented as a
sequence of read-modify-write operations. When an atomic operation is required, the
developer should pay attention to this detail, because unexpected behavior might result if
an interrupt occurs in the middle of the critical section comprising the update sequence.
A set of SCT registers is offered for registers in many modules on this device, as
described in this manual. In a module memory map table, the suffix _SET, _CLR, or
_TOG is added to the base name of the register. For example, the
CCM_ANALOG_PLL_ARM register has three other registers called
CCM_ANALOG_PLL_ARM_SET, CCM_ANALOG_PLL_ARM_CLR, and
CCM_ANALOG_PLL_ARM_TOG.
Chapter 1 Introduction
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
163

<!-- page 164 -->

In the sub-section that describes one of these sets of registers, a short-hand convention is
used to denote that a register has the SCT register set. There is an italicized n appended to
the end of the short register name. Using the above example, the name used for this
register is CCM_ANALOG_PLL_ARMn. When you see this designation, there is a SCT
register set associated with the register, and you can verify this by checking it in the
memory map table. The address offset for each of these registers is given in the form of
the following example:
Address: 20C_8000h base + 0h offset + (4d × i), where i=0d to 3d
In this example, the address for each of the base registers and their three SCT registers
can be calculated as:
Register
Address
CCM_ANALOG_PLL_ARM
20C_8000h
CCM_ANALOG_PLL_ARM_SET
20C_8004h
CCM_ANALOG_PLL_ARM_CLR
20c_8008h
CCM_ANALOG_PLL_ARM_TOG
20C_800Ch
1.1.6
Signal Conventions
_b, _B
When appended to a signal name, this indicates that a signal is active-low.
NEG_ACTIVE
Overbar also denotes a negative active signal.
UPPERCASE
Package pin names, Block I/O signals.
lowercase
Lowercase is used to indicate internal signals.
1.1.7
Acronyms and Abbreviations
The table below contains acronyms and abbreviations used in this document.
Acronyms and Abbreviated Terms
Term
Meaning
ADC
Analog-to-Digital Converter
AHB
Advanced High-performance Bus
AIPS
Arm IP Bus
ALU
Arithmetic Logic Unit
Table continues on the next page...
About This Document
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
164
NXP Semiconductors

<!-- page 165 -->

Term
Meaning
AMBA
Advanced Microcontroller Bus Architecture
APB
Advanced Peripheral Bus
ASRC
Asynchronous Sample Rate Converter
AXI
Advanced eXtensible Interface
BEE
Bus Encrypt Engine
BIST
Built-In Self Test
CA/CM
Arm Cortex-A/Cortex-M
CAAM
Cryptographic Acceleration and Assurance Module
CAN
Controller Area Network
CCM
Clock Controller Module
CPU
Central Processing Unit
CSI
CMOS Sensor Interface
CSU
Central Security Unit
CTI
Cross Trigger Interface
DAP
Debug Access Port
DDR
Double data rate
DMA
Direct memory access
DPLL
Digital phase-locked loop
DRAM
Dynamic random access memory
ECC
Error correcting codes
ECSPI
Enhanced Configurable SPI
EIM
External Interface Module
ENET
Ethernet
EPIT
Enhanced Periodic Interrupt Timer
EPROM
Erasable Programmable Read-Only Memory
ETF
Embedded Trace FIFO
ETM
Embedded Trace Macrocell
FIFO
First-In-First-Out
GIC
General Interrupt Controller
GPC
General Power Controller
GPIO
General-Purpose I/O
GPR
General-Purpose Register
GPS
Global Positioning System
GPT
General-Purpose Timer
GPU
Graphics Processing Unit
GPV
Global Programmers View
HAB
High-Assurance Boot
I2C or I2C
Inter-Integrated Circuit
IC
Integrated Circuit
IEEE
Institute of Electrical and Electronics Engineers
IOMUX
Input-Output Multiplexer
Table continues on the next page...
Chapter 1 Introduction
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
165

<!-- page 166 -->

Term
Meaning
IP
Intellectual Property
IrDA
Infrared Data Association
JTAG
Joint Test Action Group (a serial bus protocol usually used for test purposes)
LCD
Liquid Crystal Display
LDO
Low-Dropout
LIFO
Last-In-First-Out
LRU
Least-Recently Used
LSB
Least-Significant Byte
LUT
Look-Up Table
LVDS
Low Voltage Differential Signaling
MAC
Medium Access Control
MMC
Multimedia Card
MMDC
Multi Mode DDR Controller
MSB
Most-Significant Byte
MT/s
Mega Transfers per second
OCRAM
On-Chip Random-Access Memory
OCOTP
On-Chip One-Time Programmable Controller
PCI
Peripheral Component Interconnect
PCMCIA
Personal Computer Memory Card International Association
PGC
Power Gating Controller
PIC
Programmable Interrupt Controller
PMU
Power Management Unit
POR
Power-On Reset
PSRAM
Pseudo-Static Random Access Memory
PWM
Pulse Width Modulation
PXP
Pixel Pipeline
QoS
Quality of Service
R2D
Radians to Degrees
RISC
Reduced Instruction Set Computing
ROM
Read-Only Memory
ROMCP
ROM Controller with Patch
RTOS
Real-Time Operating System
Rx
Receive
SAI
Synchronous Audio Interface
SCU
Snoop Control Unit
SD
Secure Digital
SDIO
Secure Digital Input/Output
SDLC
Synchronous Data Link Control
SDMA
Smart DMA
SIM
Subscriber Identification Module
SNVS
Secure Non-Volatile Storage
Table continues on the next page...
About This Document
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
166
NXP Semiconductors

<!-- page 167 -->

Term
Meaning
SoC
System-on-Chip
SPBA
Shared Peripheral Bus Arbiter
SPDIF
Sony Phillips Digital Interface
SPI
Serial Peripheral Interface
SRAM
Static Random-Access Memory
SRC
System Reset Controller
TFT
Thin-Film Transistor
TPIU
Trace Port Interface
TSGEN
Time Stamp Generator
Tx
Transmit
TZASC
TrustZone Address Space Controller
UART
Universal Asynchronous Receiver/Transmitter
USB
Universal Serial Bus
USDHC
Ultra Secured Digital Host Controller
WDOG
Watchdog
WLAN
Wireless Local Area Network
WXGA
Wide Extended Graphics Array
1.2
Introduction
This chapter introduces the architecture of the i.MX 6ULL Multimedia Applications
Processors. The i.MX 6ULL processors represent NXP's latest achievement in integrated
multimedia applications processors.
It is part of a growing i.MX family of multimedia-focused products, offering high-
performance processing optimized for the lowest power consumption.
1.3
Target Applications
The architecture's flexibility enables it to be used in a wide variety of general embedded
applications. The i.MX 6ULL processor provides all interfaces necessary to connect
peripherals such as WLAN, Bluetooth™, GPS, camera sensors, and multiple displays.
1.4
Features
The i.MX 6ULL processors are based on ARM®Cortex®-A7 MPCore™ Platform, which
has these features:
Chapter 1 Introduction
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
167

<!-- page 168 -->

• Single ARM Cortex-A7 MPCore (with TrustZone) with:
• 32 KB L1 instruction cache
• 32 KB L1 data cache
• Cortex-A7 NEON MPE (Media Processing Engine) co-processor
The ARM Cortex-A7 MPCore complex includes:
• General Interrupt Controller (GIC) with 128 interrupts support
• Global Timer
• Snoop Control Unit (SCU)
• 128 KB unified I/D L2 cache
• Single Master AXI (128-bit) bus interface output of L2 cache
• NEON MPE co-processor
• SIMD Media Processing Architecture
• NEON register file with 32x32-bit, 32x64-bit, and 16x128-bit general-purpose
registers
• NEON Integer execute pipeline (ALU, Shift, MAC)
• NEON dual, single-precision floating-point execute pipeline (FADD, FMUL)
• NEON load/store and permute pipeline
• Supports single- and double-precision add, subtract, multiply, divide, multiply
and accumulate, and square root operations, as described in the ARM VFPv4
architecture.
• Provides conversions between 16-bit, 32-bit, and 64-bit floating-point formats
and ARM integer word formats.
The target frequency of the core is 528 MHz non-overdrive and overdrive to 800 MHz
for industrial processor and 900 MHz for consumer processor over the specified
temperature range.
The i.MX 6ULL processors support high-volume, cost-effective handheld DRAM, NOR
flash, and SD memory card standards.
The memory system consists of these components:
• Level 1 cache—32 KB instruction, 32 KB data cache
• Level 2 cache—unified instruction and data (128 KB)
• On-Chip Memory:
• Boot ROM, including High-Assurance Boot (HAB, 96 KB)
• Internal fast access RAM (OCRAM, 128 KB)
• External memory interfaces:
• 16-bit LP-DDR2, 16-bit DDR3-400, and LV-DDR3-400
• 8-bit NAND-flash, including support for Raw MLC/TLC, 2 KB ,4 KB, and 8 KB
page size, BA-NAND, PBA-NAND, LBA-NAND, OneNAND™, and others
• BCH ECC up to 40 bits
• 16-bit NOR flash
Features
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
168
NXP Semiconductors

<!-- page 169 -->

• 16-bit PSRAM, Cellular RAM
• Dual-channel/single-channel QuadSPI flash
The i.MX 6ULL processor enables these interfaces to external devices (some of them are
muxed and not available simultaneously):
Displays:
• LCDIF—supports one parallel 24-bit LCD display with up to WXGA (1366 x 768)
resolution at 60 Hz
• EPDC—supports direct-driver for E-Ink EPD panels with resolution up to 2048 x
1536 at 106 Hz (or 4096 x 4096 at 20 Hz)
• Supports up to 64 LUT for concurrent updates
• Supports Auto-Waveform selection based on both the input image and current
panel content
• Supports collision detection
• Supports both the PVI panels and LGD GIP panels
Camera sensors:
• One parallel camera port (up to 24-bit and 66 MHz)
Expansion cards: four MMC/SD/SDIO card ports that support:
• 1-bit or 4-bit transfer mode specifications for the SD and SDIO cards up to UHS-I
SDR-104 mode (104 MB/s max)
• 1-bit, 4-bit, or 8-bit transfer mode specifications for the MMC cards up to 52 MHz in
both the SDR and DDR modes (104 MB/s max)
• Compatible with SD, miniSD, SDIO, miniSDIO, SD Combo, MMC and MMC RS,
embedded MMC, and embedded SD cards.
• Host-clock frequency variable from 32 kHz to 52 MHz
• Up to 200 Mbit/s data transfer for SD/SDIO cards using four parallel data lines
• Up to 416 Mbit/s data transfer for MMC cards using eight parallel data lines
• Up to 832 Mbit/s data transfer for MMC/SD cards using eight parallel data lines in
the DDR mode
USB:
• Two High-Speed (HS) USB 2.0 OTG (up to 480 Mbit/s), with integrated HS USB
PHY
Miscellaneous IPs and interfaces:
• Three I2S/SAI/AC97, each operating at up to 1.4 Mbit/s
• ESAI
• Eight UARTs (each operating at up to 5.0 Mbit/s) that provide the RS232 interface
and support 9-bit RS485 multidrop mode. Eight UARTs that support the 4-wire
mode.
Chapter 1 Introduction
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
169

<!-- page 170 -->

• Four eCSPI (enhanced CSPI), three of them support up to 52 M-bit/s, one can be of
low speed
• Four I2Cs supporting 400 kbit/s
• Dual-megabit Ethernet controller (IEEE1588-compliant), 10/100 Mbit/s
• Eight Pulse Width Modulators (PWM)
• System JTAG Controller (SJC)
• GPIO with interrupt capabilities
• 8x8 Key Pad Port (KPP)
• Sony Philips Digital Interface (SPDIF), Rx and Tx
• Two Controller Area Network (FlexCAN), 1 Mbit/s each
• Three Watchdog timers (WDOG)
• Asynchronous Sample Rate Converter (ASRC)
• Medium Quality Sound (MQS)
The i.MX 6ULL processors integrate the advanced Power Management Unit (PMU) and
these controllers:
• The PMU includes multiple LDO supplies for on-chip resources
• Temperature Sensor to monitor the die temperature
• DVFS to support low-power modes
• Software State Retention and Power Gating for ARM and MPE
• Multiple power modes
• Flexible clock-gating control scheme
The use of hardware accelerators is a key factor in obtaining high performance at low
power consumption levels, while keeping the CPU core relatively free for performing
other tasks.
The i.MX 6ULL processors incorporate this hardware accelerator:
• Pixel Processing Pipeline (PXP)
The security functions are enabled and accelerated by this hardware:
• ARM TrustZone including the TZ architecture (separation of interrupts, memory
mapping, and so on)
• SJC—System JTAG Controller—protects the JTAG from debug port attacks by
regulating or blocking the access to the system debug features.
• SNVS—Secure Non-Volatile Storage, including Secure Real-Time Clock.
• CSU—Central Security Unit—an enhancement for the IC Identification Module
(IIM). It is configured during boot and by the eFUSEs, and determines the security
level operation mode and the TZ policy.
• RNGB—True Random Number Generation
• A-HAB—Advanced High-Assurance Boot—HABv4 with these new embedded
enhancements: SHA-256, 2048-bit RSA key, version control mechanism, warm boot,
CSU, and TZ initialization.
Features
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
170
NXP Semiconductors

<!-- page 171 -->

NOTE
The actual feature set depends on the part number.
1.5
Architectural Overview
This section contains details about the chip architecture.
1.5.1
Simplified Block Diagram
A high-level block diagram is shown in the following figure. This diagram provides a
view of the chip's major sub-systems (processor domains, shared peripherals domain, and
memories) and logical connectivity.
Chapter 1 Introduction
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
171

<!-- page 172 -->

Debug
DAP
TPIU
CTIs
SJC
SPBA
Clock & Reset
PLL (6)
CCM
GPC
SRC
XTAL OSC
32K OSC
Timer/Control
WDOG (3)
(
GPT
EPIT (2)
Temp Monitor
Image Procssing
Pixel Processing Pipeline 
(PXP)
Security
CSU
Fuse Box
SNVS 
(SRTC)
Power Management
LDOs
WLAN
Modem IC
Digital Audio
CMOS Sensor
LCD Panel
Tamper 
Detection
NOR FLASH
(Quad SPI)
NOR FLASH
(Parallel )
USB OTG
(dev/host)
LP-DDR2 
/ DDR3
Keypad
10/100M 
Ethernet x2
Controller Area
Network
JTAG
(IEEE1149 .6)
eINK Panel 
Sensors
Battery Control 
Device
MMC/SD
SDXC
MMC/SD
eMMC/eSD
Crystal and
Clock Source
NAND FLASH
Display Interface
LCDIF
Smart DMA
SDMA
CAN x2
External Memory
MMDC
EIM
GPMI & BCH
QSPI
Internal Memory
OCRAM 128 KB
ROM 96 KB
ARM Cortex A7
MPCore Platform
Cortex-A7 Core
I-cahce
32 KB 
D-cache
32 KB 
NEON
ETM
SCU & Timer
L2 Cache 128 KB
Shared Peripherals
eCSPI (4)
SPDIF Tx/Rx
SAI (3)
UART (8)
AP Peripherals
uSDHC (2)
I2C (4)
PWM (8)
OCOTP
IOMUXC
KPP
GPIO
Ethernet (2)
USB OTG (2)
CAN (2)
Camera Interface
CSI
AXI and AHB Switch Fabric
2)
ASRC 
MQS 
ESAI 
Eletrophoretic Display (EPD)
HAB
Figure 1-2. Simplified block diagram
1.5.2
Architectural Partitioning
Architecture supports processing-intensive tasks in the following ways:
• ARM Cortex A7 MPCore™ Platform provides hardware features for:
• Operating System
• User applications (including control over hardware accelerators and non-
accelerated functions)
• TrustZone applications
Architectural Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
172
NXP Semiconductors

<!-- page 173 -->

• Smart DMA enables data transfer between non-mastering peripherals and external or
internal memories
• System Control is supported via:
• Clock Control Module (CCM)
• XTALOSC- 24 MHz Crystal oscillator source support
• OSC32KHz - 32.768 Hz Crystal oscillator source support
• System Reset Controller (SRC)
• General Power Controller (GPC)
• Temperature Sensor for monitoring and alarming on high temperature situations.
• Multimedia is supported with:
• Audio
• Audio codecs are provided by SW, which runs on ARM core, supporting
(but not limited to) MP3, WMA, AAC, HE-AAC and Pro10
• SPDIF Tx/Rx
• Audio sample rate conversion accelerator (ASRC)
• ESAI
• Video
• Display/graphics
• Pixel Pipeline (PXP)
• LCD interface (LCDIF)
• CMOS sensor interface
• EPDC
• Security is supported by:
• High Assurance Boot (HAB4) System
• ARM TrustZone (TZ) Trusted Execution environment
• Peripheral access policy control, using Central Security Unit (CSU)
• DCP and SNVS security architecture, providing:
• Security State Controller
• Encryption and Hashing functions, Random Number Generator (RNGB)
• Security Violation/Tamper Detection & Reporting
• System JTAG controller (SJC)
• Secure Real Time Clock (SRTC)
• TrustZone Watchdog (TZ WDOG)
• Connectivity peripherals, timers and External Memory Interfaces:
• Embedded DMAs
• 3.3V IO voltage for seamless integration
• Two USB 2.0 ports, including two PHYs: 2x HS-USB (OTG)
• Nand-Flash (MLC up to 40-bit ECC) and NOR Flash memory interface via
GPMI Nand-Flash controller
Chapter 1 Introduction
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
173

<!-- page 174 -->

• Timers: 2xEPIT, GPT and two Watch Dog timers (one of which is used for TZ),
in addition to the timers and watchdog timers integrated within the ARM Cortex
A7 MPCore™ platform.
• Miscellaneous connectivity support - FLEXCAN, MMC/SD, I2C, SPI, UART,
PWM and Keypad interface
1.5.3
Endianness Support
The chip supports only the Little Endian mode.
1.5.4
Memory Interfaces
The chip DDR controller supports these memory interfaces:
The EIM block provides an interface for SRAM and PSRAM, and a 16/8-bit NOR flash.
All EIM pins are muxed on other interfaces.
Architectural Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
174
NXP Semiconductors

