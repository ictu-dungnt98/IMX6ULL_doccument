# Chapter 29: General Purpose Media Interface (GPMI)

> Nguồn: `IMX6ULLRM.pdf` — trang 1371–1420

<!-- page 1371 -->

Chapter 29
General Purpose Media Interface (GPMI)
29.1
Overview
The GPMI controller is a flexible interface to supporting up to four NAND flash chip
selects.
• ONFI3.2, DDR Mode, Samsung / Toshiba Toggle NAND protocol compatible.
• Fully configurable address and command behavior, providing support for future
devices not yet specified.
The GPMI resides on the APBH. The GPMI also provides an interface to the BCH
module to allow direct parity processing.
Registers are clocked on the HCLK domain. The I/O and pin timing are clocked on a
dedicated GPMICLK domain. GPMICLK can be set to maximize I/O performance.
The following figure shows a block diagram of the GPMI controller.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1371

<!-- page 1372 -->

GPMI DMA Interface State Machine
GPMI FIFO
GPMI Pin State Machine
div2
BCH
GPMI
GPMI / Memory /
GPIO Pin Mux
APBH
APBH MASTER
DMA Request 0
SHARED DMA
AHB MASTER
AHB SLAVE
AMBA
ARM Core
SRAM
APBHDMA
Pins
GPIO
Other Modules
HCLK
GPMICLK
System Clock
Generator
DMA Request 2
DMA Request 3
DMA Request 1
Figure 29-1. General-Purpose Media Interface Controller Block Diagram
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1372
NXP Semiconductors

<!-- page 1373 -->

29.2
External Signals
 The table found here describes the external signals of GPMI.  
Table 29-1. GPMI External Signals
Signal
Description
Pad
Mode
Direction
NAND_ALE
Address latch enable signal
NAND_ALE
ALT0
O
NAND_CE0_B
Chip enable signal
NAND_CE0_B
ALT0
O
NAND_CE1_B
Chip enable signal
NAND_CE1_B
ALT0
O
NAND_CE2_B
Chip enable signal
CSI_MCLK
ALT2
O
NAND_CE3_B
Chip enable signal
CSI_PIXCLK
ALT2
O
NAND_CLE
Command latch enable signal
NAND_CLE
ALT0
O
NAND_DATA00
Data signal
NAND_DATA00
ALT0
IO
NAND_DATA01
Data signal
NAND_DATA01
ALT0
IO
NAND_DATA02
Data signal
NAND_DATA02
ALT0
IO
NAND_DATA03
Data signal
NAND_DATA03
ALT0
IO
NAND_DATA04
Data signal
NAND_DATA04
ALT0
IO
NAND_DATA05
Data signal
NAND_DATA05
ALT0
IO
NAND_DATA06
Data signal
NAND_DATA06
ALT0
IO
NAND_DATA07
Data signal
NAND_DATA07
ALT0
IO
NAND_DQS
DQS signal
NAND_DQS
ALT0
IO
NAND_READY_B
Ready signal
NAND_READY_B
ALT0
IO
NAND_RE_B
Read enable signal
NAND_RE_B
ALT0
O
NAND_WE_B
Write enable signal
NAND_WE_B
ALT0
O
NAND_WP_B
Wait polarity signal
NAND_WP_B
ALT0
O
29.3
Clocks
The table found here describes the clock sources for GPMI.
Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 29-2. GPMI Clocks
Clock name
Clock Root
Description
bch_input_apb_clk
BCH to APBH input clock
gpmi_bch_input_bch_cl
k
BCH input clock
gpmi_bch_input_gpmi_i
o_clk
GPMI IO input clock
gpmi_input_apb_clk
GPMI to APBH clock
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1373

<!-- page 1374 -->

29.4
GPMI NAND Mode
The general-purpose media interface has several features to efficiently support NAND:
• Individual chip select pins and ganged ready/busy pin for up to four NANDs.
• Individual state machine and DMA channel for each chip select.
• Special command modes work with DMA controller to perform all normal NAND
functions without CPU intervention.
• Configurable timing based on a dedicated clock allows optimal balance of high
NAND performance and low system power.
GPMI and DMA have been designed to handle complex multi-page operations without
CPU intervention. The DMA uses a linked descriptor function with branching capability
to automatically handle all of the operations needed to read/write multiple pages:
• Data/Register Read/Write-The GPMI can be programmed to read or write multiple
cycles to the NAND address, command or data registers.
• Wait for NAND Ready-The GPMI's Wait-for-Ready mode can monitor the ready/
busy signal of a single NAND flash and signal the DMA when the device has
become ready. It also has a time-out counter and can indicate to the DMA that a
time-out error has occurred. The DMAs can conditionally branch to a different
descriptor in the case of an error.
• Check Status-The Read-and-Compare mode allows the GPMI to check NAND
status against a reference. If an error is found, the GPMI can instruct the DMA to
branch to an alternate descriptor, which attempts to fix the problem or asserts a CPU
IRQ.
29.4.1
Multiple NAND Support
The GPMI supports up to four NAND chip selects, with ganged ready/busy pins. Since
they share a data bus and control lines, the GPMI can only actively communicate with a
single NAND at a time. However, all NANDs can concurrently perform internal read,
write, or erase operations. With fast NAND flash and software support for concurrent
NAND operations, this architecture allows the total throughput to approach the data bus
speed, which can be as high as 50 MB/s (8-bit bus running at 50 MHz single clock edge)
in asynchronous mode and 200MB/s (8-bit bus running at 100MHz both clock edges) in
Source Synchronous mode.
GPMI NAND Mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1374
NXP Semiconductors

<!-- page 1375 -->

There are two options for controlling the four NAND chip selects via the DMA interface.
The first option is the one to one mapping, where the each DMA channel is tied to its
own NAND chip select. For example DMA channel 'n' accesses only NAND attached to
chip select 'n'. The second option is the decoupled mode where a DMA channel can
access any or all NAND chip selects connected to the GPMI. A DMA channel will
signify the NAND chip select it wants to access by writing its chip select value in the
GPMI_CTRL0[CS] field and setting the GPMI_CTRL1[DECOUPLE_CS] to 1. This
option is useful if software chooses to use only one DMA channel to access all the
attached NAND devices.
29.4.2
GPMI NAND Timing and Clocking
The dedicated clock, GPMICLK, is used as a timing reference for NAND flash I/O. Since
various NANDs have different timing requirements, GPMICLK may need to be adjusted
for each application.
While the actual pin timings are limited by the NAND chips used and the I/O pad
configuration, the GPMI can support data bus speeds of up to 200 MHz x 8 bits. The
actual read/write strobe timing parameters are adjusted as indicated in the register
descriptions in Memory Map.
29.4.3
Basic NAND Timing
29.4.3.1
NAND Asynchronous Timing
Figure 29-3 and illustrates the operation of the output (from host to device) timing
parameters in NAND ONFI asynchronous mode.
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1375

<!-- page 1376 -->

CLE = HW_GPMI_CTRL0.bit18 (ADDRESS[1])
ALE = HW_GPMI_CTRL0.bit17 (ADDRESS[0])
0
0
tAS
tDS
tDH
tDS
tDH
tDS
tDH
tDS
tDH
1 cycle
dev_clk
CE0_B
CLE/
ALE
WE_B
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
- tAS is configurable by programming HW_GPMI_TIMING0 Address_Setup: in this example, Address_Setup = 4, tAS is equal to 4 dev_clk cycles.
- tDS is configurable by programming HW_GPMI_TIMING0 Data_Setup; in this example, Data_Setup = 3, tDS is equal to 3 dev_clk cycles
- tDH is configuarble by programming HW_GPMI_TIMING0 Data_Hold: in this example, Data_Hold = 2, tDH is equal to 2 dev_clk cycles
- tAS/tDS/tDH will extend, if the output data is not ready in device fifo.
DATA[07:00]
as
Output
from
device
Host controller drives the DATA[07:00] bus
And also don't care if device will drive that or not and what will be drived
No.1
output[7:0]
No.2
output[7:0]
No.(n-1)
output[7:0]
No.n
output[7:0]
1 cycle
Figure 29-2. Asynchronous Mode Basic Write Timing Diagram (command write, address
write, or data write
GPMI NAND Mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1376
NXP Semiconductors

<!-- page 1377 -->

CLE = HW_GPMI_CTRL0.bit18 (ADDRESS[1])
ALE - HW_GPMI_CTRL0.bit17 (ADDRESS[0])
0
0
tAS
tDS
tDH
tDS
tDH
tDS
tDH
tDS
tDH
1 cycle
dev_clk
CE0_B
CLE/
ALE
RE_B
Host controller drives the DATA[07:00] bus
And also don't care if device will drive that or not and what will be drived
- tAS is configurable by programming HW_GPMI_TIMING0 Address_Setup: in this example, Address_Setup = 4, tAS is equal to 4 dev_clk cycles.
- tDS is configurable by programming HW_GPMI_TIMING0 Data_Setup; in this example, Data_Setup = 3, tDS is equal to 3 dev_clk cycles
- tDH is configuarble by programming HW_GPMI_TIMING0 Data_Hold: in this example, Data_Hold = 2, tDH is equal to 2 dev_clk cycles
- tRD is the delay from RE_B rising edge to the read datas ampling edge.  If SDR DLL is not enabled, tRD is 0.  If SDR DLL enabled, the delay depends on SDR DLL delay.
- tAS/tDS/tDH will extend, if the output data is not ready in device fifo.
ONFI asynchronous mode basic read timing diagram
(data read)
tRD
tRD
tRD
tRD
No. 1
input
No. 2
input
No. (n-1)
input
No. (n-1)
input
DATA[07:00]
as
input
from
device
tCK
1 cycle or more
read data
sampling edge
Figure 29-3. ONFI Asynchronous Mode Basic Read Timing Diagram (data read)
29.4.3.2
NAND Asynchronous EDO Mode Timing
In high-speed NANDS, the read data may not be valid until after the read strobe
(NAND_RE_B) deasserts. This is the case when the minimum tDS is programmed to
achieve higher bandwidth.
The GPMI implements a feedback read strobe to sample the read data. The feedback read
strobe can be delayed to support fast nand EDO (Extended Data Out) timing where the
read strobe may deassert before the read data is valid, and read data is valid for some time
after read strobe. Nand EDO timings is applied typically for read cycle frequency above
33 MHz. See Figure 29-4.
The GPMI provides control over the amount of delay applied to the feedback read strobe.
This delay depends on the maximum read access time (tREA) of the nand and the read
pulse width (tRP) used to access the nand. tRP is specified by
GPMI_TIMING0[DATA_SETUP] register. When (tREA + 4ns) is less than tRP, no
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1377

<!-- page 1378 -->

delay is required to sample to nand read data. (The 4ns provides adequate data setup time
for the GPMI.) In this case set GPMI_CTRL1[HALF_PERIOD] = 0;
GPMI_CTRL1[RDN_DELAY] = 0; GPMI_CTRL1[DLL_ENABLE] = 0.
When (tREA + 4ns) is greater than or equal to tRP, a delay of the feedback read strobe is
required to sample to nand read data. This delay is equal to the difference between these
two timings:
DELAY = tREA + 4ns - tRP.
Since the GPMI delay chain is limited to 6ns maximum, if DELAY > 6ns then increase
tRP by increasing the value of GPMI_TIMING0[DATA_SETUP] until DELAY is less
than or equal to 6ns.
The GPMI programming for this DELAY depends on the GPMICLK period. The GPMI
DLL will not function properly if the GPMICLK period is greater than 12ns: disable the
DLL if this is the case. If the GPMICLK period is greater than 6ns (and not greater than
12ns), set the GPMI_CTRL1[HALF_PERIOD]=1; This will cause the DLL reference
period (RP) to be one-half of the GPMICLK period. If the GPMICLK period is 6ns or
less then set the GPMI_CTRL1[HALF_PERIOD]=0; This will cause the DLL reference
period (RP) to be equal to the GPMICLK period. DELAY is a multiple (0 to 1.875) of
RP.
The GPMI_CTRL1[RDN_DELAY] is encoded as a 1-bit integer and 3-bit fraction delay
factor. DELAY is a multiple of the delay factor and the reference period. See table below
for details.
Table 29-3. RDN DELAY
HW_GPMI_CTRL1[RDN_DELAY]
Delay Factor
0
0.000
1
0.125
2
0.250
3
0.375
4
0.500
5
0.625
6
0.750
7
0.875
8
1.000
9
1.125
10
1.250
11
1.375
12
1.500
13
1.625
Table continues on the next page...
GPMI NAND Mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1378
NXP Semiconductors

<!-- page 1379 -->

Table 29-3. RDN DELAY (continued)
HW_GPMI_CTRL1[RDN_DELAY]
Delay Factor
14
1.750
15
1.875
DELAY = DelayFactor x RP or DELAY = GPMI_CTRL1[RDN_DELAY] x 0.125 x RP.
Use this equation to calculate the value for GPMI_CTRL1[RDN_DELAY]. Then set
GPMI_CTRL1[DLL_ENABLE]=1.
RE_B
ReadData
Feedback RE_B
RE_B
Read Data
Feedback RE_B
A
A
B
B
C
C
tRP
tREA
tREA
tRP
Delay
GPMI NAND Read Path Timing Diagram (Non-EDO)
(tREA + 4 ns) is less than tRP, no delay is required on rising edge of Feedback RDN to sample Read Data
GPMI NAND Read Path Timing Diagram (EDO mode)
Where (tREA + 4 ns) is greater than or equal to tRP, a delay of the Feedback RDN is required to sample to nand read data
Figure 29-4. NAND Read Path Timing
For example, a NAND with tREAmax = 20 ns, tRPmin = 12 ns, and tRCmin = 25 ns
(read cycle time) may be programmed as follows:
• GPMICLK clock frequency: Consider 480/6 = 80 MHz which is 12.5 ns clock
period. This is too close to the minimum NAND spec if we program the data setup
and hold to 1 GPMICLK cycle. Consider 480/7=68.57 MHz which is 14.58 ns clock
period. With data setup and hold set to 1, we have a tRP of 14.58ns and a tRC of
29.16 ns (good margins).
• Since (tREA +4ns) is greater than tRP, required DELAY = tREA + 4ns - tRP = 20 +
4 - 14.58ns = 9.42 ns.
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1379

<!-- page 1380 -->

• GPMI_CTRL1[HALF_PERIOD] =, since GPMICLK period is ns. So
RP=GPMICLK period = ns.
• DELAY = GPMI_CTRL1[RDN_DELAY] x 0.125 x RP. 9.42 ns =
GPMI_CTRL1[RDN_DELAY] x 0.125 x ns. GPMI_CTRL1[RDN_DELAY] =
NOTE
It is recommended that the drive strength of NAND_RE_B and
NAND_WE_B output pins be set to 8 mA. This will reduce the
transition time under heavy loads. Low transition times will be
important when NAND interface read and write cycle times are
below 30 ns. The other GPMI pins may remain at 4 mA, since
their frequency is only up to half that of NAND_RE_B and
NAND_WE_B.
29.4.3.3
NAND ONFI Source Synchronous Mode Timing
NOTE
In the following figures, CLK shares the same pin as WE_B in
Async Mode. And W/R# shares the same pin as RE_B in Async
Mode.
GPMI NAND Mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1380
NXP Semiconductors

<!-- page 1381 -->

CMD
tPRE
tPOST
tCAS
tCAH
tCK
CE_B
CLE
ALE
CLK
W/R#
DQS
DQS
output
enable
DATA[07:00]
DATA[07:00]
Output
Enable
Host controller does not drives the DATA[07:00] bus
And also don't care if device will drive that or not and what will be drived
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
tCK is equal to device clock period
tCAS       = 0.5 * tCK
tCAH       = 0.5 * tCK
tCE          = HW_GPMI_TIMING2.CE_DELAY * tCK
tCH          = 0.5 * tCK
tPRE        = HW_GPMI_TIMING2.PREAMBLE_DELAY * tCK
tPOST     = HW_GPMI_TIMING2.POST_DELAY * tCK         
tCH
tCE
Figure 29-5. ONFI Source Synchronous Mode Basic Command Write Timing Diagram
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1381

<!-- page 1382 -->

tPRE
tPOST
tCAS
tCAH
tCK
CE_B
CLE
ALE
CLK
W/R#
DQS
DQS
oen
DATA[07:00]
DATA[07:00]
oen
Host controller does not drives the DATA[07:00] bus
And also don't care if device will drive that or not and what will be drived.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
tCK is equal to device clock period
tCAS       = 0.5 * tCK
tCAH       = 0.5 * tCK
tCE          = HW_GPMI_TIMING2.CE_DELAY * tCK
tCH          = 0.5 * tCK
tPRE        = HW_GPMI_TIMING2.PREAMBLE_DELAY * tCK
tPOST     = HW_GPMI_TIMING2.POST_DELAY * tCK         
tCH
tCE
ADD
Figure 29-6. ONFI Source Synchronous Mode Basic Address Write Timing Diagram
GPMI NAND Mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1382
NXP Semiconductors

<!-- page 1383 -->

CMD
ADD
ADD
tCE
tCH
tCAS
tCAH
tCAS
tCAH
1CMDADDPAUSE
1CMDADDPAUSE
tCK
tPRE
tPOST
CE_B
CLE
ALE
CLK
W/R#
DQS
DQS
output
enable
DATA[07:00]
DATA[07:00]
Output
enable
Host controller does not drives the DATA[07:00] bus
And also do not care if device will drive that or not and what will be drived.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
tCK is equal to device clock period
tCAS      = 0.5 * tCK
tCAH      = 0.5 *tCK
tCE        = HW_GPMI_TIMING2.CE_DELAY * tCK
tCH        = 0.5 * tCK
tPRE      = HW_GPMI_TIMING2.PREAMBLE_DELAY * tCK
tPOST   = HW_GPMI_TIMING2.POST_DELAY * tCK
tCMDADDPAUSE = HW_GPMI_TIMING2.CMDADD_PAUSE * tCK
Figure 29-7. ONFI Source Synchronous Mode Command + Address Write Timing
Diagram
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1383

<!-- page 1384 -->

tCE
tCH
tDATAPAUSE
tCALS
tPOST
tCALH
tCK
tCALS
tPRE
tDQSS
tDQSS
tDQSS
CE_B
CLE
ALE
CLK
W/R#
DQS
DQS
output
enable
DATA[07:00]
Output
enable
Host controller does not drives the DATA[07:00] bus
And also do not care if device will drive that or not and what will be drived.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
tCK is equal to device clock period
tCE                      = HW_GPI_TIMING2.CE_DELAY * tCK
tCH                      = 0.5 * tCK
tCALS                  = 0.5 * tCK
tCALH                  = 0.5 * tCK
tPRE                    = HW_GPMI_TIMING2.PREAMBLE_DELAY *tCK
tPOST                  = HW_GPMI_TIMING2.POST_DELAY * tCK
tDATAPAUSE      = HW_GPMI_TIMING2.DATA_PAUSE * tCK
tDQSS                  = tCK       
DATA[07:00]
Figure 29-8. ONFI Source Synchronous Mode Data Write Timing Diagram
GPMI NAND Mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1384
NXP Semiconductors

<!-- page 1385 -->

tCH
tCALH
tCALS
tCE
tPRE
tCK
tCALS
tCALS
tPOST
4 tCK
tCKWR
tD QSCK
tD QSCK
tWRCK
tDQSD
tDQSHZ
tDATAPAUSE
CE_B
CLE
ALE
CLK
W/R#
Internal
DQS input
Valid
window
DQS
DQS
output
enable
DATA[07:00]
DATA[07:00]
Output
enable
Host controller does not drive the DATA[07:00] bus
And also do not care if device will drive that or not and what will be drived.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
tCK is equal to device clock period
tCE                      = HW_GPI_TIMING2.CE_DELAY * tCK
tCH                      = 0.5 * tCK
tCALS                  = 0.5 * tCK
tCALH                  = 0.5 * tCK
tPRE                    = HW_GPMI_TIMING2.PREAMBLE_DELAY *tCK
tPOST                  = HW_GPMI_TIMING2.POST_DELAY * tCK
tDATAPAUSE      = HW_GPMI_TIMING2.DATA_PAUSE * tCK
tWRCK/tCKWR/tDQSD/tDASCK/tDASHZ are device parameters      
Figure 29-9. ONFI Source Synchronous Mode Data Read Timing Diagram
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1385

<!-- page 1386 -->

29.4.3.4
NAND Toggle Mode Timing
1 cycle
1 cycle
tAS
tDH
tDS
0.51CK
0.51CK
command
dev_clk
CE_B
CLE
ALE
WE_B
RE_B
DQS
DATA[07:00] as
Output to
device
Host controller does not drive the DATA[07:00] bus
And also does not care if device will drive that or not and what will be drived.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
- tAS is configurable by programming HW_GPMI_TIMING0 Address_Setup;
- tDS is configurable by programming HW_GPMI_TIMING0 Data_Setup;
- tDH is configurable br programming HW_GPMI_TIMING Data_Hold;
- tAS/tDS/tDH will extend, if the output data is not ready in device fifo.
Figure 29-10. Samsung Toggle Mode Basic Command Write Timing Diagram
GPMI NAND Mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1386
NXP Semiconductors

<!-- page 1387 -->

1 cycle
1 cycle
tAS
tDH
tDS
0.5 tCK
0.5 tCK
address
dev_clk
CE_B
CLE
ALE
WE_B
RE_B
DQS
IDATA[07:00] as
Output to
device
Host controller does not drive the DATA[07:00] bus
And also does not care if device will drive that or not and what will be drived.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
- tAS is configurable by programming HW_GPMI_TIMING0 Address_Setup;
- tDS is configurable by programming HW_GPMI_TIMING0 Data_Setup;
- tDH is configurable br programming HW_GPMI_TIMING Data_Hold;
- tAS/tDS/tDH will extend, if the output data is not ready in device fifo.
Figure 29-11. Samsung Toggle Mode Basic Address Write Timing Diagram
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1387

<!-- page 1388 -->

tDS
tDS
tDS
tDS
tDS
tDS
tDH
tDH
tDH
tDH
tDH
tDH
tAS
1 cycle
1 cycle
1 cycle
address increment
Program command 0x80/81/85 sent,
host will drive DQS to 1
Program command not sent,
host will not drive DQS
command
address
address
address
address
address
Host controller does not drive the DATA[07:00] bus
And also do not care if device will drive that or not and what will be drived.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
- tAS is configurable by programming HW_GPMI_TIMING0 Address_Setup.
- tDS is configurable by programming HW_GPMI_TIMING0 Data_Setup
- tDH is configurable br programming HW_GPMI_TIMING Data_Hold
- tAS/tDS/tDH will extend, if the output data is not ready in device fifo.
Not lock cs
lock cs
CE_B
CLE
ALE
WE_B
RE_B
DQS
DATA[07:00] as
Output to
device
Figure 29-12. Samsung Toggle Mode Basic Command + Address Timing Diagram
GPMI NAND Mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1388
NXP Semiconductors

<!-- page 1389 -->

dev_clk
CE_B
0
0
0
1
CEL
ALE
WE_B
1
RE_B
DQS
DATA[07:00]
tPRE
1tCK
1tCK
tDATAPAUSE
tPOST
Idle cycles
0.5 tCK
0.5 tCK
Host controller does not drive the DATA[07:00] bus.
It also does not care if the device will drive or what will be driven.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by device.
tCK is equal to device clock period
= HW_GPMI_TIMIN G2.CE_DELAY* tCK
= HW_GPMI_TIMIN G2.PREAMBLE_DELAY* tCK
= HW_GPMI_TIMIN G2.POSTAMBLE_DELAY* tCK
= HW_GPMI_TIMIN G2.DATA_PAUSE* tCK
tCE
tPRE
tPOST
tDATAPAUSE
Figure 29-13. Toggle Mode Data Write Timing Diagram
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1389

<!-- page 1390 -->

dev_clk
CE_B
CEL
ALE
WE_B
RE_B
DQS
DATA[07:00]
tPRE
tCR
1tCK
tDATAPAUSE
tPOST
tRPSTH
Host controller does not drive the DATA[07:00] bus.
It also does not care if the device will drive or what will be driven.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by device.
tCE
1
tDQSRE
tDQSRE
tDQSRE
tCHZ
tCK is equal to device clock period
= HW_GPMI_TIMING2.CE_DELAY* tCK
= (HW_GPMI_TIMING2.PREAMBLE_DELAY -  HW_GPMI_TIMING2.TCR) *  tCK
= HW_GPMI_TIMING2.POSTAMBLE_DELAY* tCK
= HW_GPMI_TIMING2.DATA_PAUSE* tCK
tCE
tPRE
tPOST
tDATAPAUSE
tCR
= (HW_GPMI_TIMING2.TCR + 1) * tCK
tRPSTH
=   HW_GPMI_TIMING2.TRPSTH * tCK
Figure 29-14. Toggle Mode Data Read Timing Diagram
GPMI NAND Mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1390
NXP Semiconductors

<!-- page 1391 -->

dev_clk
CE_B
CLE
ALE
WE_B
RE_B
DQS
DATA[07:00]
1 tCK
A
tAS
tDS
tDH
tAS
tDS
tDH
tDS
tDH
tDS
tDH
tDS
tDH
tDS
tDH
0.5 tCK
1 tCK
1 tCK
address increment
Command
0x80/81/85
address
address
address
address
address
Host controller does not drive the DATA[07:00] bus
And also does not care if device will drive that or not and what will be drived.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
0.5 tCK
lock cs
Figure 29-15. Toggle Mode Program Timing Diagram (A)
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1391

<!-- page 1392 -->

dev_clk
CE_B
CLE
ALE
WE_B
RE_B
DQS
DATA[07:00]
address
A
B
1 tCK
Idle cycles
lock cs
tCE
tPRE
1 tCK
1 tCK
0.5 tCK
0.5 tCK
1 tCK
DATA PAUSE
tPOST
0.5 tCK
Idle cycles
Host controller does not drive the DATA[07:00] bus
And also does not care if device will drive that or not and what will be drived.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
Figure 29-16. Toggle Mode Program Timing Diagram (B)
GPMI NAND Mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1392
NXP Semiconductors

<!-- page 1393 -->

1 tCK
1 tCK
idle cycles
tAS
tDS
tDH
1 tCK
tPOST
0.5 tCK
Command
0x10/11
B
0.5 tCK
0.5 tCK
dev_clk
CE_B
CLE
ALE
WE_B
RE_B
DQS
DATA[07:00]
Host controller does not drive the DATA[07:00] bus
And also does not care if device will drive that or not and what will be drived.
Host controller drives the DATA[07:00] bus, but
the data in the DATA[07:00] should be ignored by the device
- tCK is equal to device clock period
- tAS is configurable by programming HW_GPMI_TIMING0 Address_Setup;
- tDS is configuraable by programming HW_GPMI_TIMING0 Data_Setup;
- tDH is configurable programming HW_GPMI_TIMING0 Data_Hold;
- tAS/tDS/tDH will extend, if the output data is not ready in device fifo.
- tPOST is configurable by programming HW_GPMI_TIMING2.POST_DELAY;
Figure 29-17. Toggle Mode Program Timing Diagram (C)
29.4.4
Hardware BCH Interface
The GPMI provides an interface to the BCH module. This reduces the SOC bus traffic
and the software involvement.
.
When BCH ECC is enable, parity information is inserted on-the-fly during writes to 8-bit
NAND devices. The BCH will supply payload and parity to the GPMI to write to the
NAND. During NAND reads, parity is checked and ECC processing is performed after
each read block. In this case the GPMI reads the NAND device and redirects the data and
parity to the BCH module for ECC processing.
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1393

<!-- page 1394 -->

To program the BCH for NAND writes, remove the soft reset and clock gates from
BCH_CTRL[SFTRST] and BCH_CTRL[CLKGATE]. The bulk of BCH programming is
actually applied to the GPMI via PIO operations embedded in its DMA command
structures. This has a subtle implication when writing to the GPMI ECC registers: access
to the these registers must be written in progressive register order. Thus, to write to the
GPMI_ECCCOUNT register, write first (in order) to registers GPMI_CTRL0,
GPMI_COMPARE, and GPMI_ECCCTRL before writing to GPMI_ECCCOUNT.
These additional register writes need to be accounted for in the CMDWORDS field of the
respective DMA channel command register.
NOTE
Note that the GPMI_PAYLOAD and GPMI_AUXILIARY
pointers need to be word-aligned for proper ECC operation. If
those pointers are non-word-aligned, then the BCH engine will
not operate properly and could possibly corrupt system memory
in the adjoining memory regions.
29.5
Behavior During Reset
A soft reset (SFTRST) can take multiple clock periods to complete, so do NOT set
CLKGATE when setting SFTRST. The reset process gates the clocks automatically.
29.6
GPMI Memory Map/Register Definition
The following registers provide control for programmable elements of the GPMI module.
NOTE
All ATA or UDMA features are not supported for the chip.
GPMI memory map
Absolute
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
180_6000
GPMI Control Register 0 Description (GPMI_CTRL0)
32
R/W
C000_0000h
29.6.1/1396
180_6004
GPMI Control Register 0 Description (GPMI_CTRL0_SET)
32
R/W
C000_0000h
29.6.1/1396
180_6008
GPMI Control Register 0 Description (GPMI_CTRL0_CLR)
32
R/W
C000_0000h
29.6.1/1396
180_600C
GPMI Control Register 0 Description (GPMI_CTRL0_TOG)
32
R/W
C000_0000h
29.6.1/1396
180_6010
GPMI Compare Register Description (GPMI_COMPARE)
32
R/W
0000_0000h
29.6.2/1398
Table continues on the next page...
Behavior During Reset
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1394
NXP Semiconductors

<!-- page 1395 -->

GPMI memory map (continued)
Absolute
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
180_6020
GPMI Integrated ECC Control Register Description
(GPMI_ECCCTRL)
32
R/W
0000_0000h
29.6.3/1399
180_6024
GPMI Integrated ECC Control Register Description
(GPMI_ECCCTRL_SET)
32
R/W
0000_0000h
29.6.3/1399
180_6028
GPMI Integrated ECC Control Register Description
(GPMI_ECCCTRL_CLR)
32
R/W
0000_0000h
29.6.3/1399
180_602C
GPMI Integrated ECC Control Register Description
(GPMI_ECCCTRL_TOG)
32
R/W
0000_0000h
29.6.3/1399
180_6030
GPMI Integrated ECC Transfer Count Register Description
(GPMI_ECCCOUNT)
32
R/W
0000_0000h
29.6.4/1400
180_6040
GPMI Payload Address Register Description
(GPMI_PAYLOAD)
32
R/W
0000_0000h
29.6.5/1400
180_6050
GPMI Auxiliary Address Register Description
(GPMI_AUXILIARY)
32
R/W
0000_0000h
29.6.6/1401
180_6060
GPMI Control Register 1 Description (GPMI_CTRL1)
32
R/W
0004_0004h
29.6.7/1402
180_6064
GPMI Control Register 1 Description (GPMI_CTRL1_SET)
32
R/W
0004_0004h
29.6.7/1402
180_6068
GPMI Control Register 1 Description (GPMI_CTRL1_CLR)
32
R/W
0004_0004h
29.6.7/1402
180_606C
GPMI Control Register 1 Description (GPMI_CTRL1_TOG)
32
R/W
0004_0004h
29.6.7/1402
180_6070
GPMI Timing Register 0 Description (GPMI_TIMING0)
32
R/W
0001_0203h
29.6.8/1404
180_6080
GPMI Timing Register 1 Description (GPMI_TIMING1)
32
R/W
0000_0000h
29.6.9/1405
180_6090
GPMI Timing Register 2 Description (GPMI_TIMING2)
32
R/W
0302_3336h
29.6.10/
1406
180_60A0
GPMI DMA Data Transfer Register Description
(GPMI_DATA)
32
R/W
0000_0000h
29.6.11/
1407
180_60B0
GPMI Status Register Description (GPMI_STAT)
32
R
0000_0005h
29.6.12/
1407
180_60C0
GPMI Debug Information Register Description
(GPMI_DEBUG)
32
R
0000_0000h
29.6.13/
1410
180_60D0
GPMI Version Register Description (GPMI_VERSION)
32
R
0502_0000h
29.6.14/
1410
180_60E0
GPMI Debug2 Information Register Description
(GPMI_DEBUG2)
32
R/W
0000_F100h
29.6.15/
1411
180_60F0
GPMI Debug3 Information Register Description
(GPMI_DEBUG3)
32
R
0000_0000h
29.6.16/
1414
180_6100
GPMI Double Rate Read DLL Control Register Description
(GPMI_READ_DDR_DLL_CTRL)
32
R/W
0000_0038h
29.6.17/
1414
180_6110
GPMI Double Rate Write DLL Control Register Description
(GPMI_WRITE_DDR_DLL_CTRL)
32
R/W
0000_0038h
29.6.18/
1416
180_6120
GPMI Double Rate Read DLL Status Register Description
(GPMI_READ_DDR_DLL_STS)
32
R
0000_0000h
29.6.19/
1418
180_6130
GPMI Double Rate Write DLL Status Register Description
(GPMI_WRITE_DDR_DLL_STS)
32
R
0000_0000h
29.6.20/
1419
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1395

<!-- page 1396 -->

29.6.1
GPMI Control Register 0 Description (GPMI_CTRL0n)
The GPMI control register 0 specifies the GPMI transaction to perform for the current
command chain item.
Address: 180_6000h base + 0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
SFTRST
CLKGATE
RUN
DEV_IRQ_EN
LOCK_CS
UDMA
COMMAND_MODE
WORD_LENGTH
CS
ADDRESS
ADDRESS_
INCREMENT
W
Reset
1
1
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
XFER_COUNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI_CTRL0n field descriptions
Field
Description
31
SFTRST
Set to zero for normal operation. When this bit is set to one (default),
then the entire block is held in its reset state. This will not work if the CLKGATE bit is already set to '1'.
CLKGATE must be cleared to '0' before issuing a soft reset. Also the GPMICLK must be running for this to
work properly.
RUN = 0x0 Allow GPMI to operate normally.
RESET = 0x1 Hold GPMI in reset.
30
CLKGATE
Set this bit zero for normal operation. Setting this bit to one (default),
gates all of the block level clocks off for miniminizing AC energy consumption.
RUN = 0x0 Allow GPMI to operate normally.
NO_CLKS = 0x1 Do not clock GPMI gates in order to minimize power consumption.
29
RUN
The GPMI is busy running a command whenever this bit is set to '1'. The GPMI is idle whenever this bit
set to zero. This can be set to one by a CPU write. In addition, the DMA sets this bit each time a DMA
command has finished its PIO transfer phase.
IDLE = 0x0 The GPMI is idle.
BUSY = 0x1 The GPMI is busy running a command.
Table continues on the next page...
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1396
NXP Semiconductors

<!-- page 1397 -->

GPMI_CTRL0n field descriptions (continued)
Field
Description
28
DEV_IRQ_EN
When set to '1' and ATA_IRQ pin is asserted, the GPMI_IRQ output will assert.
27
LOCK_CS
For ATA/NAND mode: 0= Deassert chip select (CS) after RUN is complete. 1= Continue to assert chip
select (CS) after RUN is complete.
For Camera Mode: 0= Dont wait for VSYNC rising edge before capturing data. 1= Wait for VSYNC rising
edge before capturing data (Camera mode only).
DISABLED = 0x0 Deassert chip select (CS) after RUN is complete.
ENABLED = 0x1 Continue to assert chip select (CS) after RUN is complete.
26
UDMA
DISABLED = 0x0 Use ATA-PIO mode on the external bus.
ENABLED = 0x1 Use ATA-Ultra DMA mode on the external bus.
0
Use ATA-PIO mode on the external bus.
1
Use ATA-Ultra DMA mode on the external bus.
25–24
COMMAND_
MODE
WRITE = 0x0 Write mode.
READ = 0x1 Read mode.
READ_AND_COMPARE = 0x2 Read and Compare mode (setting sense flop).
WAIT_FOR_READY = 0x3 Wait for Ready mode. For ATA WAIT_FOR_READY command set CS=01.
00
Write mode.
01
Read Mode.
10
Read and Compare Mode (setting sense flop).
11
Wait for Ready.
23
WORD_LENGTH
This bit should only be changed when RUN==0.
Reserve = 0x0 Reserved.
8_BIT = 0x1 8-bit Data Bus mode.
0
Reserved.
1
8-bit Data Bus mode.
22–20
CS
Selects which chip select is active for this command. For ATA WAIT_FOR_READY command, this must
be set to b01.
19–17
ADDRESS
Specifies the three address lines for ATA mode. In NAND mode, use A0 for CLE and A1 for ALE.
NAND_DATA = 0x0 In NAND mode, this address is used to read and write data bytes.
NAND_CLE = 0x1 In NAND mode, this address is used to write command bytes.
NAND_ALE = 0x2 In NAND mode, this address is used to write address bytes.
16
ADDRESS_
INCREMENT
In ATA mode, the address will increment with each cycle. In NAND mode, the address will increment
once, after the first cycle (going from CLE to ALE).
DISABLED = 0x0 Address does not increment.
ENABLED = 0x1 Increment address.
0
Address does not increment.
1
Increment address.
XFER_COUNT
Number of bytes to transfer for this command. A value of zero will transfer 64K bytes.
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1397

<!-- page 1398 -->

29.6.2
GPMI Compare Register Description (GPMI_COMPARE)
The GPMI compare register specifies the expect data and the xor mask for comparing to
the status values read from the device. This register is used by the Read and Compare
command.
GPMI_COMPARE 0x010
Address: 180_6000h base + 10h offset = 180_6010h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
MASK
REFERENCE
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI_COMPARE field descriptions
Field
Description
31–16
MASK
16-bit mask which is applied after the read data is XORed with the REFERENCE bit field.
REFERENCE
16-bit value which is XORed with data read from the NAND device.
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1398
NXP Semiconductors

<!-- page 1399 -->

29.6.3
GPMI Integrated ECC Control Register Description
(GPMI_ECCCTRLn)
The GPMI ECC control register handles configuration of the integrated ECC accelerator.
Address: 180_6000h base + 20h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
HANDLE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
RSVD2
ECC_CMD
ENABLE_ECC
RSVD1
BUFFER_MASK
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI_ECCCTRLn field descriptions
Field
Description
31–16
HANDLE
This is a register available to software to attach an identifier to a transaction in progress. This handle will
be available from the ECC register space when the completion interrupt occurs.
15
RSVD2
Always write zeroes to this bit field.
14–13
ECC_CMD
ECC Command information.
DECODE = 0x0 Decode.
ENCODE = 0x1 Encode.
RESERVE2 = 0x2 Reserved.
RESERVE3 = 0x3 Reserved.
Table continues on the next page...
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1399

<!-- page 1400 -->

GPMI_ECCCTRLn field descriptions (continued)
Field
Description
12
ENABLE_ECC
Enable ECC processing of GPMI transfers.
ENABLE = 0x1 Use integrated ECC for read and write transfers.
DISABLE = 0x0 Integrated ECC remains in idle.
11–9
RSVD1
Always write zeroes to this bit field.
BUFFER_MASK ECC buffer information. The BCH error correction only allows two configurations of the buffer mask -
software may either read just the first block on the flash page or the entire flash page. Write operations
must be for the entire flash page. Invalid buffer mask values will cause the DMA descriptor command to be
terminated.
BCH_AUXONLY = 0x100 Set to request transfer from only the auxiliary buffer (block 0 on flash).
BCH_PAGE = 0x1FF Set to request transfer to/from the entire page.
29.6.4
GPMI Integrated ECC Transfer Count Register Description
(GPMI_ECCCOUNT)
The GPMI ECC Transfer Count Register contains the count of bytes that flow through
the ECC subsystem.
GPMI_ECCCOUNT 0x030
Address: 180_6000h base + 30h offset = 180_6030h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
RSVD2
COUNT
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI_ECCCOUNT field descriptions
Field
Description
31–16
RSVD2
Always write zeroes to this bit field.
COUNT
Number of bytes to pass through ECC. This is the GPMI transfer count plus the syndrome count that will
be inserted into the stream by the ECC. In DMA2ECC_MODE this count must match the
GPMI_CTRL0_XFER_COUNT. A value of zero will transfer 64K words.
29.6.5
GPMI Payload Address Register Description
(GPMI_PAYLOAD)
The GPMI payload address register specifies the location of the data buffers in system
memory. This value must be word aligned.
GPMI_PAYLOAD 0x040
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1400
NXP Semiconductors

<!-- page 1401 -->

Address: 180_6000h base + 40h offset = 180_6040h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
ADDRESS
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
ADDRESS
RSVD0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI_PAYLOAD field descriptions
Field
Description
31–2
ADDRESS
Pointer to an array of one or more 512 byte payload buffers.
RSVD0
Always write zeroes to this bit field.
29.6.6
GPMI Auxiliary Address Register Description
(GPMI_AUXILIARY)
The GPMI auxiliary address register specifies the location of the auxiliary buffers in
system memory. This value must be word aligned.
GPMI_AUXILIARY 0x050
Address: 180_6000h base + 50h offset = 180_6050h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
ADDRESS
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
ADDRESS
RSVD0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI_AUXILIARY field descriptions
Field
Description
31–2
ADDRESS
Pointer to ECC control structure and meta-data storage.
RSVD0
Always write zeroes to this bit field.
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1401

<!-- page 1402 -->

29.6.7
GPMI Control Register 1 Description (GPMI_CTRL1n)
The GPMI control register 1 specifies additional control fields that are not used on a per-
transaction basis.
Address: 180_6000h base + 60h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
DEV_CLK_STOP
SSYNC_CLK_
STOP
WRITE_CLK_
STOP
TOGGLE_MODE
GPMI_CLK_DIV2_
EN
UPDATE_CS
SSYNCMODE
DECOUPLE_CS
WRN_DLY_
SEL
TEST_TRIGGER
TIMEOUT_IRQ_EN
GANGED_
RDYBUSY
BCH_MODE
DLL_ENABLE
HALF_PERIOD
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
1
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
RDN_DELAY
DMA2ECC_MODE
DEV_IRQ
TIMEOUT_IRQ
BURST_EN
ABORT_WAIT_
REQUEST
ABORT_WAIT_
FOR_READY_
CHANNEL
DEV_RESET
ATA_IRQRDY_
POLARITY
CAMERA_MODE
GPMI_MODE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
1
0
0
GPMI_CTRL1n field descriptions
Field
Description
31
DEV_CLK_STOP
set this bit to 1 will stop gpmi io working clk.
30
SSYNC_CLK_
STOP
set this bit to 1 will stop the source synchronous mode clk.
29
WRITE_CLK_
STOP
In onfi source synchronous mode, host may save power during the data write cycles by holding the CLK
signal high (i.e. stopping the CLK). The host may only stop the CLK during data write, by setting this bit to
1, if the device supports this feature as indicated in the parameter page.
28
TOGGLE_MODE
enable samsung toggle mode.
27
GPMI_CLK_
DIV2_EN
This bit should be reset to 0 in asynchronous mode. The frequence ratio of (device clock : ccm gpmi clock)
will be (1 : 1).
This bit should be set to 1, in source synchronous mode or toggle mode. The frequence raito of (device
clock : ccm gpmi clock) will be (1 : 2).
enable the gpmi clk divider.
0x0
internal factor-2 clock divider is disabled
0x1
internal factor-2 clock divider is enabled.
Table continues on the next page...
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1402
NXP Semiconductors

<!-- page 1403 -->

GPMI_CTRL1n field descriptions (continued)
Field
Description
26
UPDATE_CS
force the CS value is be updated to external chip select pin, even GPMI is idle.
25
SSYNCMODE
source synchronouse mode 1 or asynchrous mode 0.
ASYNC = 0x0 Asynchronous mode.
SSYNC = 0x1 Source Synchronous mode.
24
DECOUPLE_CS
Decouple Chip Select from DMA Channel. Setting this bit to 1 will allow a DMA channel to specify any
value in the CTRL0_CS register field. Software can use one DMA channel to access all 8 Nand devices.
23–22
WRN_DLY_SEL
Since the GPMI write strobe (WRN) is a fast clock pin, the delay on this signal can be programmed to
match the load on this pin.
0 = ~2ns; 1 = ~4ns; 2 = ~6ns; 3 = no delay.
21
TEST_TRIGGER
Test Trigger Enable
0
Disable
1
Enable
20
TIMEOUT_IRQ_
EN
Setting this bit to '1' will enable timeout IRQ for transfers in ATA mode only, and for WAIT_FOR_READY
commands in both ATA and Nand mode. The Device_Busy_Timeout value is used for this timeout.
19
GANGED_
RDYBUSY
Set this bit to 1 will force all Nand RDY_BUSY inputs to be sourced from (tied to) RDY_BUSY0. This will
free up all, except one, RDY_BUSY input pins.
18
BCH_MODE
This bit selects which error correction unit will access GPMI. This bit must always be set to '1', since only
the BCH unit is available in this design.
17
DLL_ENABLE
Set this bit to 1 to enable the GPMI DLL. This is required for fast NAND reads (above 30 MHz read
strobe).
After setting this bit, wait 64 GPMI clock cycles for the DLL to lock before performing a NAND read.
16
HALF_PERIOD
Set this bit to 1 if the GPMI clock period is greater than 16ns for proper DLL operation. DLL_ENABLE
must be zero while changing this field.
15–12
RDN_DELAY
This variable is a factor in the calculated delay to apply to the internal read strobe for correct read data
sampling.
The applied delay (AD) is between 0 and 1.875 times the reference period (RP). RP is one half of the
GPMI clock period if HALF_PERIOD=1
otherwise it is the full GPMI clock period. The equation is: AD = RDN_DELAY x 0.125 x RP. This value
must not exceed 16ns.
This variable is used to achieve faster NAND access. For example if the Read Strobe is asserted from
time 0 to 13ns but the read access time is 20ns,
then choose AD=12ns will cause the data to be sampled at time 25ns (13+12) giving a 5ns data setup
time. If RP=13ns then RDN_DELAY = 12/(0.125 x 13ns)
= 7.38 (0111b). DLL_ENABLE must be zero while changing this field.
11
DMA2ECC_
MODE
This is mainly for testing HWECC without involving the Nand device. Setting this bit will cause DMA write
data to redirected to HWECC module (instead of Nand Device) for encoding or decoding.
10
DEV_IRQ
This bit is set when an Interrupt is received from the ATA device. Write 0 to clear.
9
TIMEOUT_IRQ
This bit is set when a timeout occurs using the Device_Busy_Timeout value. Write 0 to clear.
Table continues on the next page...
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1403

<!-- page 1404 -->

GPMI_CTRL1n field descriptions (continued)
Field
Description
8
BURST_EN
When set to 1 each DMA request will generate a 4-transfer burst on the APB bus.
7
ABORT_WAIT_
REQUEST
Request to abort "wait for ready" command on channel indicated by
ABORT_WAIT_FOR_READY_CHANNEL. Hardware will clear this bit when abort is done.
6–4
ABORT_WAIT_
FOR_READY_
CHANNEL
Abort a wait for ready command on selected channel. Set the ABORT_WAIT_REQUEST to kick of
operation.
3
DEV_RESET
ENABLED = 0x0 NANDF_WP_B(WPN) pin is held low (asserted).
DISABLED = 0x1 NANDF_WP_B(WPN) pin is held high (de-asserted).
0
NANDF_WP_B pin is held low (asserted).
1
NANDF_WP_B pin is held high (de-asserted).
2
ATA_IRQRDY_
POLARITY
For ATA MODE:
Note NAND_RDY_BUSY[3:2] are not affected by this bit.
ACTIVELOW = 0x0 ATA IORDY and IRQ are active low, or NAND_RDY_BUSY[1:0] are active low ready.
ACTIVEHIGH = 0x1 ATA IORDY and IRQ are active high, or NAND_RDY_BUSY[1:0] are active high
ready.
0 External ATA IORDY and IRQ are active low.
1 External ATA IORDY and IRQ are active high.
For NAND MODE:
0
External RDY_BUSY[1] and RDY_BUSY[0] pins are ready when low and busy when high.
1
External RDY_BUSY[1] and RDY_BUSY[0] pins are ready when high and busy when low.
1
CAMERA_MODE
When set to 1 and ATA UDMA is enabled the UDMA interface becomes a camera interface.
0
GPMI_MODE
ATA mode is only supported on channel zero.
If ATA mode is selected, then only channel three is available for NAND use.
NAND = 0x0 NAND mode.
ATA = 0x1 ATA mode.
0
NAND mode.
1
ATA mode.
29.6.8
GPMI Timing Register 0 Description (GPMI_TIMING0)
The GPMI timing register 0 specifies the timing parameters that are used by the cycle
state machine to guarantee the various setup, hold and cycle times for the external media
type.
GPMI_TIMING0 0x070
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1404
NXP Semiconductors

<!-- page 1405 -->

Address: 180_6000h base + 70h offset = 180_6070h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
ADDRESS_SETUP
DATA_HOLD
DATA_SETUP
W
0
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
0
0
0
0
0
0
1
0
0
0
0
0
0
0
1
1
GPMI_TIMING0 field descriptions
Field
Description
31–24
RSVD1
Always write zeroes to this bit field.
23–16
ADDRESS_
SETUP
Number of GPMICLK cycles that the CE/ADDR signals are active before a strobe is asserted. A value of
zero is interpreted as 0. For ATA PIO modes this is known in the ATA7 specification as "Address valid to
DIOR-/DIOW- setup"
15–8
DATA_HOLD
Data bus hold time in GPMICLK cycles. Also the time that the data strobe is de-asserted in a cycle. A
value of zero is interpreted as 256. For ATA PIO modes this is known in the ATA7 specification as "DIOR-/
DIOW- recovery time"
DATA_SETUP
Data bus setup time in GPMICLK cycles. Also the time that the data strobe is asserted in a cycle. This
value must be greater than 2 for ATA devices that use IORDY to extend transfer cycles. A value of zero is
interpreted as 256. For ATA PIO modes this is known in the ATA7 specification as ""DIOR-/DIOW-"
29.6.9
GPMI Timing Register 1 Description (GPMI_TIMING1)
The GPMI timing register 1 specifies the timeouts used when monitoring the NAND
READY pin or the ATA IRQ and IOWAIT signals.
GPMI_TIMING1 0x080
Address: 180_6000h base + 80h offset = 180_6080h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
DEVICE_BUSY_TIMEOUT
RSVD1
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI_TIMING1 field descriptions
Field
Description
31–16
DEVICE_BUSY_
TIMEOUT
Timeout waiting for NAND Ready/Busy or ATA IRQ. Used in WAIT_FOR_READY mode. This value is the
number of GPMI_CLK cycles multiplied by 4096.
RSVD1
Always write zeroes to this bit field.
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1405

<!-- page 1406 -->

29.6.10
GPMI Timing Register 2 Description (GPMI_TIMING2)
The GPMI timing register 2 specifies the double data rate timing parameters that are used
by the cycle state machine to guarantee the various cs delay, pre-amble delay, post-amble
delay, command/address delay, data delay, TCR, TRPSTH, and read latency cycle times
for the external media type.
GPMI_TIMING2 0x090
Address: 180_6000h base + 90h offset = 180_6090h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
TRPSTH
TCR
READ_
LATENC
Y
RSVD0
CE_DELAY
PREAMBLE_
DELAY
POSTAMBLE
_DELAY
CMDADD_
PAUSE
DATA_
PAUSE
W
Reset 0
0
0
0
0
0
1
1
0
0
0
0
0
0
1
0
0
0
1
1
0
0
1
1
0
0
1
1
0
1
1
0
GPMI_TIMING2 field descriptions
Field
Description
31–29
TRPSTH
Only for Toggle NAND timing control delay TRPSTH GPMICLK cycles for CEn_B high to RE_B high, A
value of zero is interpreted as 8
28–27
TCR
Only for Toggle NAND timing control delay (TCR+1) GPMICLK cycles for CEn_B low to RE_B low, 0 is
less than or equal to TCR, which is less than the PREAMBLE_DELAY
26–24
READ_
LATENCY
This field is for double data rate read latency configuration.
others READ LATENCY is 3
000
READ LATENCY is 0
001
READ LATENCY is 1
010
READ LATENCY is 2
011
READ LATENCY is 3
100
READ LATENCY is 4
101
READ LATENCY is 5
23–21
RSVD0
Always write zeroes to this bit field.
20–16
CE_DELAY
GPMI dealy from CEn assert to W/Rn changing edge. value of zero is interpreted as 32.
15–12
PREAMBLE_
DELAY
GPMI pre-amble delay in GPMICLK cycles. A value of zero is interpreted as 16.
11–8
POSTAMBLE_
DELAY
GPMI post-amble delay in GPMICLK cycles. A value of zero is interpreted as 16.
7–4
CMDADD_
PAUSE
GPMI delay time from command or addres pause to command or address resume in GPMICLK cycles. A
value of zero is interpreted as 16.
DATA_PAUSE
GPMI delay time from data pause to data resume in GPMICLK cycles. A value of zero is interpreted as 16.
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1406
NXP Semiconductors

<!-- page 1407 -->

29.6.11
GPMI DMA Data Transfer Register Description
(GPMI_DATA)
The GPMI DMA data transfer register is used by the DMA to read or write data to or
from the ATA/NAND control state machine.
GPMI_DATA 0x0A0
Address: 180_6000h base + A0h offset = 180_60A0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
DATA
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI_DATA field descriptions
Field
Description
DATA
In 8-bit mode, one, two, three or four bytes can can be accessed to send the same number of bus cycles.
29.6.12
GPMI Status Register Description (GPMI_STAT)
The GPMI control and status register provides a read back path for various operational
states of the GPMI controller.
GPMI_STAT 0x0B0
Address: 180_6000h base + B0h offset = 180_60B0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
READY_BUSY
RDY_TIMEOUT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1407

<!-- page 1408 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
DEV7_ERROR
DEV6_ERROR
DEV5_ERROR
DEV4_ERROR
DEV3_ERROR
DEV2_ERROR
DEV1_ERROR
DEV0_ERROR
RSVD1
ATA_IRQ
INVALID_BUFFER_MASK
FIFO_EMPTY
FIFO_FULL
PRESENT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
1
0
1
GPMI_STAT field descriptions
Field
Description
31–24
READY_BUSY
Read-only view of NAND Ready_Busy Input pins.
23–16
RDY_TIMEOUT
State of the RDY/BUSY Timeout Flags. When any bit is set to '1' in this field, it indicates that a time out
has occurred while waiting for the ready state of the requested NAND device. Multiple bits may be set
simultaneously.
When GPMI_CTRL1_DECOUPLE_CS = 0, RDY_TIMEOUT[n] is associated with the NAND device on
chip_select[n].
When GPMI_CTRL1_DECOUPLE_CS = 1, these flags become associated to a DMA channel instead of a
NAND device.
For example if DMA channel 6 sends a WAIT_FOR_READY command for NAND Device 2, and a timeout
occured on READY_BUSY2,
then READY_TIMEOUT[6] will be set instead of READY_TIMEOUT[2].
15
DEV7_ERROR
DMA channel 7 (Timeout or compare failure, depending on COMMAND_MODE).
0
No error condition present on ATA/NAND Device accessed by DMA channel 7.
1
An Error has occurred on ATA/NAND Device accessed by
Table continues on the next page...
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1408
NXP Semiconductors

<!-- page 1409 -->

GPMI_STAT field descriptions (continued)
Field
Description
14
DEV6_ERROR
DMA channel 6 (Timeout or compare failure, depending on COMMAND_MODE).
0
No error condition present on ATA/NAND Device accessed by DMA channel 6.
1
An Error has occurred on ATA/NAND Device accessed by
13
DEV5_ERROR
DMA channel 5 (Timeout or compare failure, depending on COMMAND_MODE).
0
No error condition present on ATA/NAND Device accessed by DMA channel 5.
1
An Error has occurred on ATA/NAND Device accessed by
12
DEV4_ERROR
DMA channel 4 (Timeout or compare failure, depending on COMMAND_MODE).
0
No error condition present on ATA/NAND Device accessed by DMA channel 4.
1
An Error has occurred on ATA/NAND Device accessed by
11
DEV3_ERROR
DMA channel 3 (Timeout or compare failure, depending on COMMAND_MODE).
0
No error condition present on ATA/NAND Device accessed by DMA channel 3.
1
An Error has occurred on ATA/NAND Device accessed by
10
DEV2_ERROR
DMA channel 2 (Timeout or compare failure, depending on COMMAND_MODE).
0
No error condition present on ATA/NAND Device accessed by DMA channel 2.
1
An Error has occurred on ATA/NAND Device accessed by
9
DEV1_ERROR
DMA channel 1 (Timeout or compare failure, depending on COMMAND_MODE).
0
No error condition present on ATA/NAND Device accessed by DMA channel 1.
1
An Error has occurred on ATA/NAND Device accessed by
8
DEV0_ERROR
DMA channel 0 (Timeout or compare failure, depending on COMMAND_MODE).
0
No error condition present on ATA/NAND Device accessed by DMA channel 0.
1
An Error has occurred on ATA/NAND Device accessed by
7–5
RSVD1
Always write zeroes to this bit field.
4
ATA_IRQ
Status of the ATA_IRQ input pin.
3
INVALID_
BUFFER_MASK
Buffer Mask Validity bit.
0
ECC Buffer Mask is not invalid.
1
ECC Buffer Mask is invalid.
2
FIFO_EMPTY
NOT_EMPTY = 0x0 FIFO is not empty.
EMPTY = 0x1 FIFO is empty.
0
FIFO is not empty.
1
FIFO is empty.
1
FIFO_FULL
NOT_FULL = 0x0 FIFO is not full.
FULL = 0x1 FIFO is full.
0
FIFO is not full.
1
FIFO is full.
0
PRESENT
UNAVAILABLE = 0x0 GPMI is not present in this product.
AVAILABLE = 0x1 GPMI is present in this product.
Table continues on the next page...
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1409

<!-- page 1410 -->

GPMI_STAT field descriptions (continued)
Field
Description
0
GPMI is not present in this product.
1
GPMI is present is in this product.
29.6.13
GPMI Debug Information Register Description
(GPMI_DEBUG)
The GPMI debug information register provides a read back path for diagnostics to
determine the current operating state of the GPMI controller.
GPMI_DEBUG 0x0C0
Address: 180_6000h base + C0h offset = 180_60C0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
WAIT_FOR_READY_END
DMA_SENSE
DMAREQ
CMD_END
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI_DEBUG field descriptions
Field
Description
31–24
WAIT_FOR_
READY_END
Read Only view of the Wait_For_Ready End toggle signals to DMA. One per channel
23–16
DMA_SENSE
Read-only view of sense state of the 8 DMA channels. A value of "1" in any bit position indicates that a
read and compare command failed or a timeout occured for the corresponding channel.
15–8
DMAREQ
Read-only view of DMA request line for 8 DMA channels. A toggle on any bit position indicates a DMA
request for the corresponding channel.
CMD_END
Read Only view of the Command End toggle signals to DMA. One per channel
29.6.14
GPMI Version Register Description (GPMI_VERSION)
This register reflects the version number for the GPMI.
GPMI_VERSION 0x0D0
Address: 180_6000h base + D0h offset = 180_60D0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
MAJOR
MINOR
STEP
W
Reset 0
0
0
0
0
1
0
1
0
0
0
0
0
0
1
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1410
NXP Semiconductors

<!-- page 1411 -->

GPMI_VERSION field descriptions
Field
Description
31–24
MAJOR
Fixed read-only value reflecting the MAJOR field of the RTL version.
23–16
MINOR
Fixed read-only value reflecting the MINOR field of the RTL version.
STEP
Fixed read-only value reflecting the stepping of the RTL version.
29.6.15
GPMI Debug2 Information Register Description
(GPMI_DEBUG2)
The GPMI Debug2 information register provides a read back path for diagnostics to
determine the current operating state of the GPMI controller.
GPMI_DEBUG2 0x0E0
Address: 180_6000h base + E0h offset = 180_60E0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
RSVD1
UDMA_STATE
BUSY
PIN_STATE
MAIN_STATE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1411

<!-- page 1412 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
SYND2GPMI_BE
GPMI2SYND_VALID
GPMI2SYND_READY
SYND2GPMI_VALID
SYND2GPMI_READY
VIEW_DELAYED_RDN
UPDATE_WINDOW
RDN_TAP
W
Reset
1
1
1
1
0
0
0
1
0
0
0
0
0
0
0
0
GPMI_DEBUG2 field descriptions
Field
Description
31–28
RSVD1
Always write zeroes to this bit field.
27–24
UDMA_STATE
USM_IDLE = 4'h0, idle
USM_DMARQ = 4'h1, DMA req
USM_ACK = 4'h2, DMA ACK
USM_FIFO_E = 4'h3, Fifo empty
USM_WPAUSE = 4'h4, WR DMA Paused by device
USM_TSTRB = 4'h5, Toggle HSTROBE
USM_CAPTUR = 4'h6, Capture Stage, (data sampled with DSTROBE is valid)
USM_DATOUT = 4'h7, Change Burst DATAOUT
USM_CRC = 4'h8, Source CRC to Device
USM_WAIT_R = 4'h9, Waiting for DDMARDY-
USM_END = 4'ha; Negate DMAACK (end of DMA)
USM_WAIT_S = 4'hb, Waiting for DSTROBE
USM_RPAUSE = 4'hc, Rd DMA Paused by Host
USM_RSTOP = 4'hd, Rd DMA Stopped by Host
USM_WTERM = 4'he, Wr DMA Termination State
USM_RTERM = 4'hf, Rd DMA Termination state
Table continues on the next page...
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1412
NXP Semiconductors

<!-- page 1413 -->

GPMI_DEBUG2 field descriptions (continued)
Field
Description
23
BUSY
When asserted the GPMI is busy. Undefined results may occur if any registers are written when BUSY is
asserted.
DISABLED = 0x0 The GPMI is not busy.
ENABLED = 0x1 The GPMI is busy.
22–20
PIN_STATE
parameter PSM_IDLE = 3'h0, PSM_BYTCNT = 3'h1, PSM_ADDR = 3'h2, PSM_STALL = 3'h3,
PSM_STROBE = 3'h4, PSM_ATARDY = 3'h5, PSM_DHOLD = 3'h6, PSM_DONE = 3'h7.
PSM_IDLE = 0x0
PSM_BYTCNT = 0x1
PSM_ADDR = 0x2
PSM_STALL = 0x3
PSM_STROBE = 0x4
PSM_ATARDY = 0x5
PSM_DHOLD = 0x6
PSM_DONE = 0x7
19–16
MAIN_STATE
parameter MSM_IDLE = 4'h0, MSM_BYTCNT = 4'h1, MSM_WAITFE = 4'h2, MSM_WAITFR = 4'h3,
MSM_DMAREQ = 4'h4, MSM_DMAACK = 4'h5, MSM_WAITFF = 4'h6, MSM_LDFIFO = 4'h7,
MSM_LDDMAR = 4'h8, MSM_RDCMP = 4'h9, MSM_DONE = 4'hA.
MSM_IDLE = 0x0
MSM_BYTCNT = 0x1
MSM_WAITFE = 0x2
MSM_WAITFR = 0x3
MSM_DMAREQ = 0x4
MSM_DMAACK = 0x5
MSM_WAITFF = 0x6
MSM_LDFIFO = 0x7
MSM_LDDMAR = 0x8
MSM_RDCMP = 0x9
MSM_DONE = 0xA
15–12
SYND2GPMI_BE
Data byte enable Input from BCH.
11
GPMI2SYND_
VALID
Data handshake output to BCH.
10
GPMI2SYND_
READY
Data handshake output to BCH.
9
SYND2GPMI_
VALID
Data handshake Input from BCH.
8
SYND2GPMI_
READY
Data handshake Input from BCH.
Table continues on the next page...
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1413

<!-- page 1414 -->

GPMI_DEBUG2 field descriptions (continued)
Field
Description
7
VIEW_
DELAYED_RDN
Set to a 1 to select the delayed feedback RE_B to drive the GPMI_ADDR[0] (Nand CLE) pin. For debug
purposes, this will allow you see if DLL is functioning properly.
6
UPDATE_
WINDOW
A 1 indicates that the DLL is busy generating the required delay.
RDN_TAP
This is the DLL tap calculated by the DLL controller. The selects the amount of delay form the DLL chain.
29.6.16
GPMI Debug3 Information Register Description
(GPMI_DEBUG3)
The GPMI Debug3 information register provides a read back path for diagnostics to
determine the current operating state of the GPMI controller.
GPMI_DEBUG3 0x0F0
Address: 180_6000h base + F0h offset = 180_60F0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
APB_WORD_CNTR
DEV_WORD_CNTR
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI_DEBUG3 field descriptions
Field
Description
31–16
APB_WORD_
CNTR
Reflects the number of bytes remains to be transferred on the APB bus.
DEV_WORD_
CNTR
Reflects the number of bytes remains to be transferred on the ATA/Nand bus.
29.6.17
GPMI Double Rate Read DLL Control Register
Description (GPMI_READ_DDR_DLL_CTRL)
GPMI DDR Read Delay Loop Lock Control Register. This register provides
programmability in DDR mode for data input timing and data formats.
GPMI_READ_DDR_DLL_CTRL 0x100
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1414
NXP Semiconductors

<!-- page 1415 -->

Address: 180_6000h base + 100h offset = 180_6100h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
REF_UPDATE_INT
SLV_UPDATE_INT
RSVD1
SLV_
OVERRIDE_
VAL
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
SLV_OVERRIDE_VAL
SLV_OVERRIDE
REFCLK_ON
GATE_UPDATE
SLV_DLY_TARGET
SLV_FORCE_UPD
RESET
ENABLE
W
Reset
0
0
0
0
0
0
0
0
0
0
1
1
1
0
0
0
GPMI_READ_DDR_DLL_CTRL field descriptions
Field
Description
31–28
REF_UPDATE_
INT
This field allows the user to add additional delay cycles to the DLL control loop (reference delay line
control). By default, the DLL control loop shall update every two GPMICLK cycles. Programming this field
results in a DLL control loop update interval of (2 + REF_UPDATE_INT) * GPMICLK. It should be noted
that increasing the reference delay-line update interval reduces the ability of the DLL to adjust to fast
changes in conditions that may effect the delay (such as voltage and temperature)
27–20
SLV_UPDATE_
INT
Setting a value greater than 0 in this field, shall over-ride the default slave delay-line update interval of 256
GPMICLK cycles. A value of 0 results in an update interval of 256 GPMICLK cycles (default setting). A
value of 0x0f results in 15 cycles and so on. Note that software can always cause an update of the slave-
delay line using the SLV_FORCE_UPDATE register. Note that the slave delay line will also update
automatically when the reference DLL transitions to a locked state (from an un-locked state).
19–18
RSVD1
Reserved
17–10
SLV_
OVERRIDE_VAL
When SLV_OVERRIDE=1 This field is used to select 1 of 256 physical taps manually. A value of 0 selects
tap 1, and a value of 0x7f selects tap 256.
9
SLV_OVERRIDE
Set this bit to 1 to Enable manual override for slave delay chain using SLV_OVERRIDE_VAL; to set 0 to
disable manual override. This feature does not require the DLL to tbe enabled using the ENABLE bit. In
fact to reduce power, if SLV_OVERRIDE is used, it is recommended to disable the DLL with ENABLE=0
Table continues on the next page...
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1415

<!-- page 1416 -->

GPMI_READ_DDR_DLL_CTRL field descriptions (continued)
Field
Description
8
REFCLK_ON
set this bit to 1 will turn on the reference clock
7
GATE_UPDATE
Setting this bit to 1, forces the slave delay line not update
6–3
SLV_DLY_
TARGET
The delay target for the read clock is can be programmed in 1/16th increments of an GPMICLK half-
period. So the input read-clock can be delayed relative input data from (GPMICLK/2)/16 to GPMICLK/2.
2
SLV_FORCE_
UPD
Setting this bit to 1, forces the slave delay line to update to the DLL calibrated value immediately. The
slave delay line shall update automatically based on the SLV_UPDATE_INT interval or when a DLL lock
condition is sensed. Subsequent forcing of the slave-line update can only occur if SLV_FORCE_UP is set
back to 0 and then asserted again (edge triggered).
1
RESET
Setting this bit to 1 force a reset on DLL. This will cause the DLL to lose lock and re-calibrate to detect an
GPMICLK half period phase shift. This signal is used by the DLL as edge-sensitive, so in order to create a
subsequent reset, RESET must be taken low and then asserted again.
0
ENABLE
Set this bit to 1 to enable the DLL and delay chain; otherwise; set to 0 to bypasses DLL. Note that using
the slave delay line override feature with SLV_OVERRIDE and SLV_OVERRIDE VAL, the DLL does not
need to be enabled.
29.6.18
GPMI Double Rate Write DLL Control Register
Description (GPMI_WRITE_DDR_DLL_CTRL)
GPMI DDR Write Delay Loop Lock Control Register. This register provides
programmability in DDR mode for data output timing and data formats.
GPMI_WRITE_DDR_DLL_CTRL 0x110
Address: 180_6000h base + 110h offset = 180_6110h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
REF_UPDATE_INT
SLV_UPDATE_INT
RSVD1
SLV_
OVERRIDE_
VAL
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1416
NXP Semiconductors

<!-- page 1417 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
SLV_OVERRIDE_VAL
SLV_OVERRIDE
REFCLK_ON
GATE_UPDATE
SLV_DLY_TARGET
SLV_FORCE_UPD
RESET
ENABLE
W
Reset
0
0
0
0
0
0
0
0
0
0
1
1
1
0
0
0
GPMI_WRITE_DDR_DLL_CTRL field descriptions
Field
Description
31–28
REF_UPDATE_
INT
This field allows the user to add additional delay cycles to the DLL control loop (reference delay line
control). By default, the DLL control loop shall update every two GPMICLK cycles. Programming this field
results in a DLL control loop update interval of (2 + REF_UPDATE_INT) * GPMICLK. It should be noted
that increasing the reference delay-line update interval reduces the ability of the DLL to adjust to fast
changes in conditions that may effect the delay (such as voltage and temperature)
27–20
SLV_UPDATE_
INT
Setting a value greater than 0 in this field, shall over-ride the default slave delay-line update interval of 256
GPMICLK cycles. A value of 0 results in an update interval of 256 GPMICLK cycles (default setting). A
value of 0x0f results in 15 cycles and so on. Note that software can always cause an update of the slave-
delay line using the SLV_FORCE_UPDATE register. Note that the slave delay line will also update
automatically when the reference DLL transitions to a locked state (from an un-locked state).
19–18
RSVD1
Reserved
17–10
SLV_
OVERRIDE_VAL
When SLV_OVERRIDE=1 This field is used to select 1 of 256 physical taps manually. A value of 0 selects
tap 1, and a value of 0x7f selects tap 256.
9
SLV_OVERRIDE
Set this bit to 1 to Enable manual override for slave delay chain using SLV_OVERRIDE_VAL; to set 0 to
disable manual override. This feature does not require the DLL to tbe enabled using the ENABLE bit. In
fact to reduce power, if SLV_OVERRIDE is used, it is recommended to disable the DLL with ENABLE=0
8
REFCLK_ON
set this bit to 1 will turn on the reference clock
7
GATE_UPDATE
Setting this bit to 1, forces the slave delay line not update
6–3
SLV_DLY_
TARGET
The delay target for the read clock can be programmed in 1/16th increments of an GPMICLK half-period.
So the input read-clock can be delayed relative input data from (GPMICLK/2)/16 to GPMICLK/2.
2
SLV_FORCE_
UPD
Setting this bit to 1, forces the slave delay line to update to the DLL calibrated value immediately. The
slave delay line shall update automatically based on the SLV_UPDATE_INT interval or when a DLL lock
condition is sensed. Subsequent forcing of the slave-line update can only occur if SLV_FORCE_UP is set
back to 0 and then asserted again (edge triggered).
1
RESET
Setting this bit to 1 force a reset on DLL. This will cause the DLL to lose lock and re-calibrate to detect an
GPMICLK half period phase shift. This signal is used by the DLL as edge-sensitive, so in order to create a
subsequent reset, RESET must be taken low and then asserted again.
0
ENABLE
Set this bit to 1 to enable the DLL and delay chain; otherwise; set to 0 to bypasses DLL. Note that using
the slave delay line override feature with SLV_OVERRIDE and SLV_OVERRIDE VAL, the DLL does not
need to be enabled.
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1417

<!-- page 1418 -->

29.6.19
GPMI Double Rate Read DLL Status Register Description
(GPMI_READ_DDR_DLL_STS)
GPMI Double Rate Read DLL Status Register, Read Only. GPMI DLL status fields are
provided in this register.
GPMI_READ_DDR_DLL_STS 0x120
Address: 180_6000h base + 120h offset = 180_6120h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
RSVD1
REF_SEL
REF_LOCK
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
RSVD0
SLV_SEL
SLV_LOCK
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1418
NXP Semiconductors

<!-- page 1419 -->

GPMI_READ_DDR_DLL_STS field descriptions
Field
Description
31–25
RSVD1
Reserved
24–17
REF_SEL
Reference delay line select status.
16
REF_LOCK
Reference DLL lock status. This signifies that the DLL has detected and locked to a half-phase GPMICLK
shift, allowing the slave delay-line to perform programmed clock delays.
15–9
RSVD0
Reserved
8–1
SLV_SEL
Slave delay line select status
0
SLV_LOCK
Slave delay-line lock status. This signifies that a valid calibration has been set to the slave-delay line and
that the slave-delay line is implementing the programmed delay value.
29.6.20
GPMI Double Rate Write DLL Status Register Description
(GPMI_WRITE_DDR_DLL_STS)
GPMI Double Rate Write DLL Status Register, Read Only. GPMI DLL status fields are
provided in this register.
GPMI_WRITE_DDR_DLL_STS 0x130
Address: 180_6000h base + 130h offset = 180_6130h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
RSVD1
REF_SEL
REF_LOCK
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 29 General Purpose Media Interface (GPMI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1419

<!-- page 1420 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
RSVD0
SLV_SEL
SLV_LOCK
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
GPMI_WRITE_DDR_DLL_STS field descriptions
Field
Description
31–25
RSVD1
Reserved
24–17
REF_SEL
Reference delay line select status.
16
REF_LOCK
Reference DLL lock status. This signifies that the DLL has detected and locked to a half-phase GPMICLK
shift, allowing the slave delay-line to perform programmed clock delays.
15–9
RSVD0
Reserved
8–1
SLV_SEL
Slave delay line select status
0
SLV_LOCK
Slave delay-line lock status. This signifies that a valid calibration has been set to the slave-delay line and
that the slave-delay line is implementing the programmed delay value.
GPMI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1420
NXP Semiconductors

