# Chapter 21: External Interface Module (EIM)

> Nguồn: `IMX6ULLRM.pdf` — trang 821–884

<!-- page 821 -->

Chapter 21
External Interface Module (EIM)
21.1
Overview
The EIM handles the interface to devices external to the chip, including generation of
chip selects, clock and control for external peripherals and memory. It provides
asynchronous access to devices with SRAM-like interface and synchronous access to
devices with NOR-Flash-like or PSRAM-like interface.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
821

<!-- page 822 -->

AXI 
controls
LPMD
LPACK
EIM_GRANT
EIM_BUSY
AXI
Interface
IPP_DO_STROBE
Output
Control
IPP_DO_CS_B[5:0]
IPP_DO_WE_B
IPP_DO_OE_B
IPP_DO_BE_B[3:0]
IPP_DO_ADV_B
IPP_OBE_DATA_DIR[3:0]
IPP_CBE_MADDR_DIR[1:0]
Synchronous
Core
Asynchronous
Core
Config.
Registers
IPS
Interface
Clock
Gating
Addr
Path
Data
Path
BCLK
Generation
CONFIGURATION
IPI_EIM_INT
EIM_BOOT[2:0]
IPG_CLK_S
IPS CONTROLS
IPP_IND_RDY_INT
IPP_DO_CRE_S
IPP_DO_CRE
ACLK
AXI_ADDR[31:0]
READ_BIGEND,WRITE_BIGEND
GATED CLOCKS
IPP_DO_BCLK
IPP_DO_ADDR_OUT[27:0]
IPP_DO_DATA_MADDR[31:0]
IPP_MUXED_DATA_IN[15:0]
IPP_IND_READ_DATA[31:0]
IPP_IND_WAIT_B
IPP_IND_FB_BCLK
IPP_IND_DTACK
WDATA[31:0]
RDATA[31:0]
Figure 21-1. EIM Diagram
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
822
NXP Semiconductors

<!-- page 823 -->

21.1.1
Features
• Six chip selects for external devices
• Flexible address decoding. Each chip select memory space determined
separately, according to VIA port configuration (see Chip Select Memory Map).
Configurable Chip Select 0 base address (by VIA)
• Individual select signal for each one of the memory space defined. Up to 6
memory spaces may be defined and programmed individually.
• 128 MByte maximum supported density by default (AUS bit is cleared). When
the AUS bit is set, maximum supported density is 32 MBytes.
• Selectable Write Protection for each Chip Select
• Support for multiplexed address / data bus operation x16 port size
• Programmable Data Port Size for each Chip Select (x8, x16)
• Programmable Wait-State generator for each Chip Select, for write and read accesses
separately
• Asynchronous accesses with programmable setup and hold times for control signals
• Support for Asynchronous page mode accesses (x16 port size)
• Independent synchronous Memory Burst Read Mode support for NOR-Flash and
PSRAM memories (x16 port size)
• Independent synchronous Memory Burst Write Mode support for PSRAM and NOR-
Flash like memories (CellularRAM™ from Micron, Infineon, and Cypress,
OneNAND™ and utRAM™ from Samsung, and COSMORAM™ from Toshiba)
• Support of NAND-Flash devices with NOR-Flash like interface - MDOC™ (M-
Systems), OneNAND™ (Samsung)
• Independent programmable variable/fix Latency support for read and write
synchronous (burst) mode
• Support for Big Endian and Little Endian operation modes per access
• Arm AXI slave interface. One ID at a time support.
21.1.2
Modes of Operation
The EIM has the following modes of operation:
• Asynchronous Mode
• Asynchronous Page Mode
• Multiplexed Address/Data mode
• Burst Clock Mode
• Low Power Modes
• Boot Mode
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
823

<!-- page 824 -->

See details in the EIM Operational Modes.
21.1.2.1
Asynchronous Mode
This is a non-burst mode that is used for SRAM access. In this mode, a single data is
read/written with each access (asserted address).
All controls' timings are controlled by preset values in Chip Select Configuration
Registers.
21.1.2.2
Asynchronous Page Read Mode
Setting the APR bit causes the EIM to perform memory burst accesses by emulating page
mode operation.
The external address asserts for each piece of data. The initial access timing is according
to RWSC field, and the next address assertions timing is according to PAT field. When
APR bit is set, RCSN OEN, RADVN and RBEN fields are ignored for burst access to the
external device.
The page size can be set via the BL field to 2, 4, 8, 16, or 32 words (the word size is
determined by the DSZ field).
21.1.2.3
Multiplexed Address/Data Mode
In this mode, multiplexing addresses and data bits on the same pins is supported for
synchronous/asynchronous accesses to x8/x16 data width memory devices.
For more information about the pins that drive data/address in 8/16 non-muxed mode and
16 muxed mode, see the following table.
Table 21-1. EIM Multiplexing
Setup
Non Multiplexed Addresss/Data Mode
Multiplexed
Address/
Data Mode
8-Bit
16-Bit
16 Bit
NUM = 0,
DSZ = 100
NUM = 0,
DSZ = 101
NUM = 0,
DSZ = 110
NUM = 0,
DSZ = 111
NUM = 0,
DSZ = 001
NUM = 0,
DSZ = 010
NUM = 1,
DSZ = 001
EIM_ADDR[1
5:00]
EIM_AD[15:0
0]
EIM_AD[15:0
0]
EIM_AD[15:0
0]
EIM_AD
[15:00]
EIM_AD[15:0
0]
EIM_AD[15:0
0]
EIM_AD[15:0
0]
EIM_ADDR[2
6:16]
EIM_ADDR[2
6:16]
EIM_ADDR[2
6:16]
EIM_ADDR[2
6:16]
EIM_ADDR[2
6:16]
EIM_ADDR[2
6:16]
EIM_ADDR[2
6:16]
EIM_ADDR[2
6:16]
Table continues on the next page...
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
824
NXP Semiconductors

<!-- page 825 -->

Table 21-1. EIM Multiplexing (continued)
Setup
Non Multiplexed Addresss/Data Mode
Multiplexed
Address/
Data Mode
8-Bit
16-Bit
16 Bit
NUM = 0,
DSZ = 100
NUM = 0,
DSZ = 101
NUM = 0,
DSZ = 110
NUM = 0,
DSZ = 111
NUM = 0,
DSZ = 001
NUM = 0,
DSZ = 010
NUM = 1,
DSZ = 001
EIM_DATA[07
:00],
EIM_EB0_B
EIM_DATA[07
:00]
-
Reserved
Reserved
EIM_DATA[07
:00]
Reserved
EIM_AD[07:0
0]
EIM_DATA[15
:8],
EIM_EB1_B
-
EIM_DATA[15
:08]
Reserved
Reserved
EIM_DATA[15
:08]
Reserved
EIM_A[15:08]
21.1.2.4
Burst Clock Mode
The controller has the ability to support burst synchronous operations in various
frequencies, depending on the frequency of the input clock supplied by the system (EIM
clock).
The EIM clock can be divided by one, two, three or four, and its frequency can be
changed according to the requirements. Variable and fix latency are supported for this
mode, according to the external device requirements.
• Synchronous read mode. This is a burst mode, which is used for reading from Flash/
PSRAM memory devices. In this mode, after address assertion a burst of sequential
data can be read. Data exchange is carried out according to BCLK being generated
by EIM. An access is delayed according to external WAIT_B signal assertion (signal
from the memory device).
• Synchronous write mode. A burst mode used for accessing external devices, which
support synchronous write type of access (PSRAM protocol). In this mode, after
address assertion a burst of sequential data can be written to the external device.
Access may be delayed according to WAIT_B signal assertion (signal from the
memory device) before first piece of data arrived to the external device.
NOTE
Maximum frequency of the EIM main clock is 133 MHz. It
may be reduced by the system for special cases of external
devices, which demand a different frequency then integer
division of the 133 MHz clock.
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
825

<!-- page 826 -->

21.1.2.5
Low Power Modes
The input clock is gated by ACT_CS bits. When all the ACT_CS are negated (all CS
disable) the internal clock is turned off; awready/wready & arready signal are de-asserted
and the master can't access the EIM.
21.1.2.6
Boot Mode
It is possible to perform a boot operation from external device located on CS0. The
configuration of the relevant bits are done with boot mode signals according to the
external device parameters (for example, port size and protocol assertion).
See for more details.
21.2
External Signals
The following table describes the external signals of EIM:
21.2.1
Other Important Block I/O Signals Internal to the SoC
The following table provides a description of other signals internal to the chip that are
important in understanding the function of EIM.
Table 21-2. EIM Important Internal Signals
Name
I/O
Description
EIM_FB_BCLK
Input
Burst Clock Feedback. This block input is used to sample read data during high transfer
speeds. The signal provides feedback from the I/O pad of the BCLK output pin and tends
to align more closely with data from the external memory device.
EIM_BOOT
Input
EIM Boot Configuration. These block inputs determine the reset state of DSZ[1:0] and
MUM.
ACLK
Input
AXI clock, maximum frequency 133 Mhz
IPG_CLK_S
Input
EIM module IPG clock
RST_B
Input
Active low HW reset
EIM_WARM_RESET
Input
Warm Reset. If this signal is asserted the rst_b will reset only the internal FF and state
machine while S/W registers will keep their current state. This signal is active high signal.
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
826
NXP Semiconductors

<!-- page 827 -->

21.3
Clocks
The following table describes the clock sources for EIM. Please see Clock Controller
Module (CCM) for clock setting, configuration and gating information.
Table 21-3. EIM Clocks
Clock name
Clock Root
Description
aclk
aclk_eim_slow_clk_root EIM clock (main)
aclk_slow
aclk_eim_slow_clk_root EIM clock (slow)
ipg_clk_s
ipg_clk_root
Peripheral access clock
aclk_exsc
aclk_eim_slow_clk_root EIM clock (external device)
• ACLK: EIM clock (main clock, AXI clock) with a Max frequency of 133 MHz. Can
be gated externally when there is no active AXI access.
• ACLK_SLOW: EIM all time running ACLK. Used for flip-flops that must be active
even when EIM is in low power down mode to provide clock for lpack/lpmd
registers, IP registers and IP to AXI sync registers.
• IPG_CLK_S: IPG clock for IP accesses. IP registers are activated by ACLK_SLOW
clock.
• ACLK_EXSC: Clock created from EIM clock for External device usage. Integer
division by 1, 2, 3 and 4 of the clock can be use with BCD bit field configuration,
according to external devices demands. EIM clock frequency may be reduced for
lower frequency support which cannot be achieved via BCD bit field.
21.4
Chip Select Memory Map
The EIM memory space is mapped into 128 MB total memory space in the processor
memory. For addresses, see the System memory map table and the CM4 memory map
table. The total 128 MB of memory can be divided among the EIM four chip selects. The
memory configuration across the chip selects is controlled by the IOMUXC_GPR1
register. The ADDRSn[10] fields control how much memory is allotted to each chip
select.
The following four configurations are supported:
• CS0 (128 MB), CS1 (0 MB), CS2 (0 MB), CS3 (0 MB) [default configuration]
• CS0 (64 MB), CS1 (64 MB), CS2 (0 MB), CS3 (0 MB)
• CS0 (64 MB), CS1 (32 MB), CS2 (32 MB), CS3 (0 MB)
• CS0 (32 MB), CS1 (32 MB), CS2 (32 MB), CS3 (32 MB)
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
827

<!-- page 828 -->

21.5
Functional Description
This section provides the functional description for the EIM.
21.5.1
Bus Sizing Configuration
The EIM supports byte, half word and word operands allowing access to x8, x16, x32
ports. It can be address/data multiplexed in x16, x32 ports. The port size is programmable
via the DSZ bit field in the corresponding Chip Select Configuration Register. An 8-bit
port can reside in each one of the bytes of the data bus. A 16-bit port can reside on the
lower 16 bits of the data bus, DATA_IN/OUT[15:0] or on the higher 16 bits of the data
bus, DATA_IN/OUT[31:16].
In the case of a multi-cycle transfer, the lower two address bits (ADDR[1:0]) are
incremented appropriately. The EIM address bus is configured according to DSZ bit field
and AUS bits. There is either one bit (for x16 port size) or two bits (for x32 port size)
right shift of the address bits (only when AUS=0) and no bit shift when AUS = 1 or
DSZ[2] = 1.
The EIM has a data multiplexer which takes the four bytes of the AXI data bus and routes
them to their required positions to properly interface to memory.
NOTE
A word access to or from a x16 port requires two external bus
cycles to complete the transfer.
A word access to or from a x8 port requires four external bus
cycles to complete the transfer.
21.5.1.1
8 BIT PORT SUPPORT
EIM has limited support for mot68000 & intel 386 protocols.
21.5.1.1.1
MOTOROLA 68000
EIM has limited support for mot68000 protocol. Only basic read or write asynchronous
operations are supported.
The following operations are not supported:
• Read modify write
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
828
NXP Semiconductors

<!-- page 829 -->

• Sync access
• All special accesses (Arm platform space, bus arbitration, bus control, bus error &
reset operations)
• FC outputs
21.5.1.1.2
INTEL 386
EIM has limited support for intel 386 protocol. Only basic read or write async non-
pipelined operations are supported.
The following operations are not supported:
• Other bus cycles (interrupt, halt & refresh)
• Bus lock
• M/IO, DC, LBA, NA, REFRESH & BS8 signals
21.5.2
EIM Operational Modes
Listed here are the main operational modes for EIM selected by control bit fields settings.
For details, see the bit field descriptions of SWR / SRD / MUM. All modes are supported
in with 8-, 16- or 32-bit port configuration, according to DSZ bit field.
Table 21-4. EIM Operation Modes Field Settings
Control bit fields
Brief mode description
MUM
SRD
SWR
0
0
0
Asynchronous write / Asynchronous read for APR=0 /
Asynchronous page read for APR=1, none multiplexed
1
Synchronous write/ Asynchronous read or APR=0 /
Asynchronous page read for APR=1,none multiplexed
1
0
Asynchronous write/Synchronous read none multiplexed
1
Synchronous write/read none multiplexed
1
0
0
Asynchronous write/read multiplexed
1
Synchronous write/ Asynchronous read multiplexed
1
0
Asynchronous write/Synchronous read multiplexed
1
Synchronous write/read multiplexed
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
829

<!-- page 830 -->

21.5.3
Burst Mode (Synchronous) Memory Operation
This mode is enabled for read or write access. Bit SWR sets the burst mode for write
operations at the corresponding chip select and bit SRD sets it for read operation.
When this mode is set, the controller attempts to translate the Master burst accesses to
memory burst accesses, being limited by the memory burst length, predefined by BL
value, or memory and Master WRAP/INCR boundary crossing non-matching. Only the
first address accessed is put by the controller on the external address bus in a memory
burst sequence.
EIM may translate from some Master sequential accesses to one or several memory
bursts, but not from two Master individual accesses to one memory burst.
For the first access in a memory burst sequence, the EIM asserts ADV, causing the
external burst device to latch the starting burst address; then toggle the burst clock
(BCLK) for a predefined number of cycles in order to latch the first unit of data.
Subsequent accessed data units can then be burst in fewer clock cycles, realizing an
overall increase in bus bandwidth.
NOTE
The BCLK signal toggles only when burst access is executed
toward the external device (BCM=1'b0 for normal mode use). It
runs with a 50% duty cycle until the end of access is reached.
When access is terminated, BCLK stops toggling.
Memory burst accesses are terminated by the EIM whenever it detects the following:
• The specific burst length has executed completely (end of access)
• Write access - missing data in write buffer (Master is delaying the data transfer
toward the EIM)
• Next sequential access crosses boundary with unequal condition (wrap/increment,
burst length) on the Master and memory
• Current memory burst length reached
21.5.4
Burst Clock Divisor (BCD)
In some cases, it may be necessary to slow the external bus in relation to the internal bus
to allow accesses to burst devices that have a maximum operating frequency less than the
operating frequency of the internal bus.
The internal bus frequency can be divided by one, two, three or four for presentation on
the external bus in burst mode operation.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
830
NXP Semiconductors

<!-- page 831 -->

BCLK can only be set to integer divisions of the incoming clock frequency. To get a
specific frequency on BCLK, configure the divider to change the incoming EIM clock
accordingly.
By programming the BCD bit field to various values, two signals on the external bus are
affected; ADV and BCLK. The ADV signal is asserted according to RADVA or
WADVA bit fields programming, and is negated according to the formula mentioned in
RADVN and WADVN bit fields description. The BCLK signal runs with a 50% duty
cycle until the end of access is reached.
If BCM = 1, the BCLK runs at frequency according to GBCD bit field settings on every
async memory access, regardless of the SWR and SRD bits configuration. Caution should
be exercised when using BCM bit; GBCD bit field should be updated once and should
not change when BCLK is toggling. The BCM bit is used mainly for system debug mode.
It has no functional use of the EIM in normal mode.
21.5.5
Burst Clock Start (BCS)
In an effort to allow greater flexibility in achieving the minimum number of wait states
on burst accesses, you can determine when you want the BCLK to start toggling after the
start of access. This allows the BCLK to be skewed from point of data capture on the
EIM clock by any number of EIM clock cycles.
Care must be exercised when setting BCS bit field in conjunction with the BCD and
RWSC/WWSC bit fields. See the external timing diagrams in Burst (Synchronous Mode)
Read Memory Accesses Timing Diagram - BCD=1 and Burst (Synchronous Mode) Read
Memory Accesses Timing Diagram - BCD=0 for examples of how to use the BCS, BCD
and RWSC/WWSC bit fields together.
21.5.6
Multiplexed Address/Data Mode Support
The control bit MUM allows support memory with multiplexed address/data bus both in
asynchronous and in synchronous modes.
Caution should be exercised for using OEA/WEA & ADH bit fields. They should be
configured according to the external device requirements, as it determines the time point
of end of address phase and start of data phase.
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
831

<!-- page 832 -->

21.5.7
Mixed Master/Memory Burst Modes Support
To provide mixed sequential/wrap accesses with different length, EIM interprets burst
signal and generate additional ADV signals whenever there appear unequal address or
burst boundary crossing condition.
BL bit field is used to notify EIM about current memory burst and wrap condition for
properly external address generation. In case of non-matching boundaries in both the
memory and Master access, EIM starts a new memory burst access by updating address
from Master on address bus and generating ADV signal.
21.5.8
AXI (Master) Bus Cycles Support
The EIM uses an Arm AXI slave interface. It has a 32-bit bus and supports one access
(one ID) at a time. No out of order or parallel accesses are supported.
The following AXI protocol signals are not supported:
• AWLOCK
• AWCACHE
• ARLOCK
• ARCACHE
ARID bus is sampled when:
• new read access is valid on the read address channel and is reflected on the RID bus
output toward the master.
AWID bus is sampled when:
• new write access is valid on the write address channel and is reflected on the
WID/BID bus output toward the master.
ARPROT and AWPROT signal are partially used. ARPROT[0] and AWPROT[0] bits are
used for normal/privileged access detection. ARPROT[2:1] and AWPROT[2:1] are not
used.
When sampling a valid access on both of the address channels, the read access will be
performed first while write access is pending. After last data transfer completed, the
pending write will be executed.
A new access may be executed one cycle after sampling a valid access on the read or
write address channels, assuming there is no current access (back to back) which can
cause a recovery or end of access penalty cycles, for write access, also assuming data is
in write buffer for fast execution.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
832
NXP Semiconductors

<!-- page 833 -->

NOTE
• Only 32-bit word size accesses are supported for burst
mode accesses.
• Only 8-bit (1 byte), 16-bit (2 byte) and 32-bit (4 byte) word
size supported for single access.
• Maximum number of burst length is 16.
• According to AXI protocol, burst access should not cross 4
KB blocks. In case EIM gets an access that crosses the 4
KB, memory address calculation is invalid.
AXI transfers shown in the table below are also supported. These AXI cycles will be
translated into the necessary cycles on the memory side. For example, for optimal
operation in case Arm cache is configured to 8 beat burst with wrap, a synchronous flash
and cellular RAM memory should be configured in 16 word wrap burst mode when using
a 16-bit data port, and in 8 word wrap burst mode when using a 32-bit data port. EIM
uses BL bit field to support different memory configurations. The controller splits the
transaction when needed in some cases. See Table 21-6.
Table 21-5. AXI Burst Cycles Supported
Burst Length -
Number of data
transfers
Burst size - Bytes
in transfer
Burst type
Description
1
1
INCR
Single transfer
1
2
INCR
Single transfer
1
4
INCR
Single transfer
2
4
WRAP
2-beat wrapping burst
4
4
WRAP
4-beat wrapping burst
8
4
WRAP
8-beat wrapping burst
16
4
WRAP
16-beat wrapping burst
2
4
INCR
2-beat incrementing burst
3
4
INCR
3-beat incrementing burst
4
4
INCR
4-beat incrementing burst
5
4
INCR
5-beat incrementing burst
6
4
INCR
6-beat incrementing burst
7
4
INCR
7-beat incrementing burst
8
4
INCR
8-beat incrementing burst
9
4
INCR
9-beat incrementing burst
10
4
INCR
10-beat incrementing burst
11
4
INCR
11-beat incrementing burst
12
4
INCR
12-beat incrementing burst
13
4
INCR
13-beat incrementing burst
14
4
INCR
14-beat incrementing burst
Table continues on the next page...
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
833

<!-- page 834 -->

Table 21-5. AXI Burst Cycles Supported (continued)
Burst Length -
Number of data
transfers
Burst size - Bytes
in transfer
Burst type
Description
15
4
INCR
15-beat incrementing burst
16
4
INCR
16-beat incrementing burst
Table 21-6. AXI to Memory Burst Splits Number
AXI Burst Type
Memory Burst
Type Config.
# of accesses to
X8
Memory Port size
# of accesses to
X16
Memory Port size
# of accesses to X32
Memory Port size
INC16
Aligned Addr.
WRAP4
16
8
4
Cont.
1
1
1
INC16
Unaligned Addr.
WRAP4
17
9
5
Cont.
1
1
1
WRAP16 Aligned Addr.
WRAP16
4
2
1
Cont.
1
1
1
WRAP16 Unaligned Addr.
WRAP16
5
3
1
Cont.
2
2
2
INC8
Aligned Addr.
WRAP8
4
2
1
WRAP16
2
1
1
INC8
Unaligned Addr.
WRAP8
4 or 5
2 or 3
2
WRAP16
2 or 3
2
1 or 2
WRAP8
Aligned Addr.
WRAP16
2
1
1
Cont.
1
1
1
WRAP8 Unaligned Addr.
WRAP16
2 or 3
1
2
Cont.
2
2
2
21.5.9
WAIT_B Signal, RWSC and WWSC bit fields Usage
Most of the external devices supporting burst mode for write or read accesses provide a
signal which indicates data is valid on the memory bus (a.k.a. handshake mode). For this
mode, RFL and WFL bits should be cleared and RWSC/ WWSC bit fields indicate when
the controller should start sampling this signal from the external device or, in other
words, how many BCLK cycles should be masked.
For devices which do not use this signal or have a fixed latency ability, the RFL and
WFL bits may be set for internal calculation regarding BCLK cycles penalty until data is
valid (memory initial access time). For this mode, RWSC/ WWSC indicates when the
data is ready for sampling by the controller (read access) or the external device (write
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
834
NXP Semiconductors

<!-- page 835 -->

access). There is separation between read and write accesses wait-state control. For read
access, RWSC bit field is valid and WWSC bit field is ignored; for write access, WWSC
is valid and RWSC is ignored.
21.5.10
IPS Register Interface
Access to the registers of the EIM, read or write, is made with IPS protocol signals. The
system should avoid changing the registers while master/memory transaction is valid, as
this can cause an unknown behavior of the controller.
Register access size is 32-bit as the register size definition, other size of access (byte or
half word) is not supported.
21.5.11
MRS Set for PSRAM
Memory registers of PSRAM devices can be configured according to external signal,
which indicates whether the access is to a memory array or memory register domain.
When the CRE bit is set, the following transactions to the external device will assert the
CRE signal. The polarity of this signal is determined by the CREP bit for active low or
active high assertion of the signal.
21.5.12
EIM Access Termination
EIM is monitoring the corresponding CSx control signal every time variable latency
access or dtack access is performed toward the external device.
In variable latency accesses, the Watchdog Timer (WDOG-1) counts BCLK cycles. If it
reaches the wdog_limit (according to the WDOG_LIMIT bit field in the WCR) before
the device signals can drive/sample new data, the controller will terminate the access and
generate an error response transfer toward the Master.
In dtack access, WDOG-1 counts ACLK cycles instead of BCLK and it reaches the
wdog_limit before the device asserts the dtack signal, the controller will terminate the
access and generate an error response transfer toward the Master.
WDOG-1 can by disabled by WDOG_EN bit in the WCR.
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
835

<!-- page 836 -->

21.5.13
Error Conditions
The following conditions cause an error (AXI error or IPS error) response signal:
• AXI errors
• Access to a disabled chip select - access to a mapped chip select address space
where the CSEN bit in the corresponding chip select Configuration Register is
clear
• Access to a non mapped address - access to an address that is not mapped to any
CS.
• User access to a supervisor-protected chip select address space (the SP bit in the
corresponding chip select Configuration Register is set)
• User access in fixed mode access
• User performs write access to write protected chip select
• First write data ID and write address ID do not match. (No data is written to the
memory.)
• First Write Data ID and write address ID match but one or more of the other
Write data IDs does not match the First Write data ID (data is written to memory
according)
• Access duration to external device from CSx signal assertion is
128/256/512/1024 cycles (access is terminated by the controller) - This error can
be disabled be software.
• IPS errors
• User read or write access to a reserved/non-valid address in the EIM
Configuration Register
21.5.14
DTACK Mode
In DTACK mode, the EIM uses DTACK signal as an indication of when to end the
access.
DTACK is an asynchronous edge/level sensitive signal. DTACK polarity is configurable
by the DAP bit in CsxGCR2 (default value is 0).
In this case, EIM begins the access and after a few cycles (according DAPS field) and
waits until DTACK (after synchronization) becomes asserted, then samples the data in
read access and completes the current data access (see Figure 21-15, Figure 21-16 &
Figure 21-17).
If more than one data is needed, CS will be negated between access (CSREC field is not
zero) and the AXI burst access will be split into single accesses (see Figure 21-19).
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
836
NXP Semiconductors

<!-- page 837 -->

21.5.15
EIM_GRANT / EIM_BUSY Handshake Description
Prior to executing command to one of the external device (chip select), EIM assert
EIM_BUSY signal (1'b1) and checks the EIM_GRANT signal status.
If EIM_GRANT signal is high, it indicates external data bus is not used by other slaves
(NAND Flash Controller) and EIM may start to execute the access. If EIM_GRANT is
low, EIM waits until it is set (1'b1) before executing the access.
EIM keeps EIM_BUSY signal set until it completes the access toward the external
device.
Once EIM_GRANT signal is set, it can not be reset until EIM_BUSY signal is cleared by
EIM.
NOTE
In 16-bit Muxed EIM doesn't use the data bus, therefore there is
no sharing of the data bus with NFC. EIM doesn't wait for
EIM_GRANT signal from NFC and doesn't assert the
EIM_BUSY signal.
21.5.16
LPMD / LPACK Handshake Description
These signals are used for frequency and/or voltage change, and for entering low power
mode during normal operation of the EIM. Before any change can take place, the
controller and all the relevant external devices should be in idle state, which means no
access or data transfer is in process.
LPMD input signal is asserted once EIM detects the assertion of LPMD, all ready signals
of the AXI channels are negated, and EIM is not sampling new accesses. It finishes all
the ongoing accesses and already pending ones. When EIM is in idle state, the LPACK
output signal is asserted. EIM will stay in idle state and the LPACK signal will stay
asserted until the LPMD signal is negated.
21.5.17
Endianness
Big and Little endianness are supported by the controller according to the following table.
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
837

<!-- page 838 -->

Table 21-7. EIM Out/in Data in Case AXI Out/in Data is 0xB3B2B1B0
Endian
mode
AXI
access
AXI
address
[1:0]
Port size and used bits
Word port
Half word port
Byte port
[31:24]
[23:16]
[15:8]
[7:0]
External
address
[0]
[31:24]
([15:8])
[23:16]
([7:0])
External
address
[1:0]
[31:24]
([23:16])
([15:8])
([7:0])
Big
Word
0
0xB3
0xB2
0xB1
0xB0
0
0xB3
0xB2
0
0xB3
1
0xB2
1
0xB1
0xB0
2
0xB1
3
0xB0
Half
Word
0
0xB1
0xB0
0
0xB3
0xB2
0
0xB3
1
0xB2
2
0xB3
0xB2
1
0xB1
0xB0
2
0xB1
3
0xB0
Byte
0
0xB0
0
0xB3
0
0xB3
1
0xB1
0xB2
1
0xB2
2
0xB2
1
0xB1
2
0xB1
3
0xB3
0xB0
3
0xB0
Little
Word
0
0xB3
0xB2
0xB1
0xB0
0
0xB1
0xB0
0
0xB0
1
0xB1
1
0xB3
0xB2
2
0xB2
3
0xB3
Half
Word
0
0xB1
0xB0
0
0xB1
0xB0
0
0xB0
1
0xB1
2
0xB3
0xB2
1
0xB3
0xB2
2
0xB2
3
0xB3
Byte
0
0xB0
0
0xB0
0
0xB0
1
0xB1
0xB1
1
0xB1
2
0xB2
1
0xB2
2
0xB2
3
0xB3
0xB3
3
0xB3
21.5.18
Strobe Signal Use
The strobe signal is toggling according to address/data valid condition on the external bus
for read and write accesses, and for both synchronous and asynchronous modes.
At any time point when address/data is valid on the external bus, the strobe signal will
generate a positive edge, which can be used to sample the external data and control
signal.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
838
NXP Semiconductors

<!-- page 839 -->

NOTE
Strobe signal for read data is active (RL + 1) cycles after data
on external bus is valid.
21.6
Initialization Information
21.6.1
Booting from EIM
EIM is ready to work with CS0 after the hardware reset, but it has been configured for
very slow access (for boot purposes), with additional setup and hold time.
Other CSs are disabled by hardware reset. Therefore, all CSs must be properly initialized
before use in writing values to the corresponding chip select configuration registers.
DSZ[1:0] and MUM fields are set according to EIM_BOOT [2:0] block inputs.
21.7
Typical Application
Application note uses following functions to illustrate EIM and memory accesses:
• WR16(address, data) is a 16 bit write access
• WR32(address, data) is a 32 bit write access
• RD16(address, data) is a 16 bit read access
• RD32(address, data) is a 32 bit read access
• WR_I(address, data, delta, counter) is a write data sequence, there data(i+1) = data(i)
+ delta
• COMMAND_SEQUENCE
• CHECK_STATUS
NOTE
COMMAND_SEQUENCE and CHECK_STATUS are
described in AMD Flash Utility, Intel Sibley Flash Utility,
MDOC Device Utility, Samsung OneNAND Utility, and
Spansion Flash Utility.
All addresses are byte addresses. "CS0" is a Chip Select 0 base address. "EIM_" is a
prefix of EIM's registers. 'h is a prefix of hexadecimal constant. "//" is a comment
beginning. csba[cs] is a dimension of CS base addresses. "addr" means an address offset
in current CS address space. Examples use CS0 address space, but it may apply to any CS
except for boot mode functionality.
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
839

<!-- page 840 -->

Configuration examples were verfied with the memory models listed below and may
require some adjustments for other family members.
21.7.1
Access to Intel Sibley Flash
The following configurations are intended to Sibley family muxed and non-muxed
devices.
21.7.1.1
Intel Sibley Flash Asynchronous Mode Configuration
• WR32('EIM_CS0GCR1,'h00210081);
• WR32('EIM_CS0RCR1,'h0e020000);
• WR32('EIM_CS0RCR2,'h00000000);
• WR32('EIM_CS0WCR1,'h0704a040);
21.7.1.2
Intel Sibley Flash Synchronous Mode Configuration
Configuration used for 133 MHz synchronous access to flash:
      // Set memory to synchronous read mode
           WR16('CS0+('h5903<<1),'h0060);
           WR16('CS0+('h5903<<1),'h0003);
           WR16('CS0+('h0000<<1),'h00ff);
      // Set EIM configuration to synchronous timing
           WR32('EIM_CS0GCR1,'h50214225);                       // 133 MHz
           WR32('EIM_CS0RCR1,'h0c000000);                       // 12 cycles on memory
Configuration used for 66 MHz synchronous access to muxed flash:
      // Set memory to synchronous read mode
           WR16('CS0+('h3103<<1),'h0060);
           WR16('CS0+('h3103<<1),'h0003);
           WR16('CS0+('h0000<<1),'h00ff);
      //--------------------------------------------------------------------------
      // Set EIM configuration to synchronous timing
           WR32('EIM_CS0GCR1,'h5021122d);                       // 66 MHz
           WR32('EIM_CS0RCR1,'h07000000);                       // 7cycles on memory
21.7.1.3
Intel Sibley Flash Utility
      // Single data word programming to addr
           WR16('CS0+addr,'h0060);                 // Unlock
           WR16('CS0+addr,'h00d0);
           WR16('CS0+addr, 'h0041);
           WR16('CS0+addr, data);
           WR16('CS0+caddr, 'h0070);                 // Read Status command
           while('CS0+data[7] == 0)                              // Wait / Polling
               RD16('CS0+addr, data);              // Read status
           RD16('CS0+addr, data);                  // Read status
Typical Application
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
840
NXP Semiconductors

<!-- page 841 -->

           WR16('CS0+'h0000,'h00ff);
      // Write buffer programming
           WR16('CS0+addr,'h0060);                 // Unlock
           WR16('CS0+addr,'h00d0);
           data    = 0;
           WR16('CS0+addr, 'h0070);                // Read Status command
           while(data[7] == 0)                            // Wait
               RD16('CS0+addr, data);              // Read status
           WR16('CS0+'h0000,'h00ff);
           WR16('CS0+addr,'h00e9);           // Write Buffer command
           WR16('CS0+addr,255);              // Word counter (<256)
           for(i=0; i<'h200; i = i + 'h40)
              WR_I('CS0+addr+i, data+((i>2)*'h0010_0001), 'h0010_0001, 16); // Data
           WR16('CS0+addr,'h00d0);           // Write Confirm command
           data  = 0;
           while(data[7] == 0)                      // Wait
              RD16('CS0+addr, data);         // Read status
           RD16('CS0+addr, data);            // Read status
           WR16('CS0+'h0000,'h00ff);
21.7.2
Access to MDOC Device
The following configurations are intended to MDOC H3 device.
21.7.2.1
MDOC Device Boot
To boot from the MDOC device the ERRST bit should be configured to 1, so that EIM
will hold the first read access to CS0 until the MDOC asserts the RDY signal.
21.7.2.2
MDOC Device Asynchronous Mode Configuration
       // Non-muxed mode
       WR32('EIM_CS0GCR1,'h00410081);
       WR32('EIM_CS0RCR1,'h0e121010);
       WR32('EIM_CS0RCR2,'h00000000);
       WR32('EIM_CS0WCR1,'h12092492);
       // Muxed mode
       WR32('EIM_CS0GCR1,'h00410081);
       WR32('EIM_CS0RCR1,'h0e121010);
       WR32('EIM_CS0RCR2,'h00000000);
       WR32('EIM_CS0WCR1,'h12092492);
21.7.2.3
MDOC Device Utility
       // Read Manufacturer ID and Device ID
           RE16('CS0+'h9400,'h4833);
           RE16('CS0+'h9422,'hb7cc);
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
841

<!-- page 842 -->

21.7.3
Access to Micron PSRAM
The following configurations are intended to mt45w4mw16bfb_706.
21.7.3.1
Micron PSRAM Asynchronous Mode Configuration
       // 16 bit memory
           WR32('EIM_CS0GCR1,'h403104b1);
           WR32('EIM_CS0RCR1,'h0b010000);
           WR32('EIM_CS0RCR2,'h00000008);
           WR32('EIM_CS0WCR1,'h0b040040);
       // 32 bit memory
           WR32('EIM_CS0GCR1,'h403304b1);
           WR32('EIM_CS0RCR1,'h0f010000);
           WR32('EIM_CS0RCR2,'h00000008);
           WR32('EIM_CS0WCR1,'h0f040040);
21.7.3.2
Micron PSRAM Synchronous Mode Configuration
       // 16 bit memory
           WR32('EIM_CS0GCR1,'h403104b1);
           WR32('EIM_CS0WCR1,'h0b040000);
           WR16('CS0+('h85947<<1),'h0040); // memory configuration
           WR32('EIM_CS0GCR1,'h4021_5487);// fixed latency memory wrap 4
           WR32('EIM_CS0RCR1,'h04000000);
           WR32('EIM_CS0RCR2,'h00000008);
           WR32('EIM_CS0WCR1,'h04000000);
       // 32 bit memory
           WR32('EIM_CS0GCR1,'h6003_04f1);
           WR32('EIM_CS0WCR1,'h0b04_0000);
           WR32('CS0+('h85947<<2),'h0040); // memory configuration
           WR32('EIM_CS0GCR1,'h4003_1487); // var latency memory inc. page size 128
           WR32('EIM_CS0RCR1,'h04000000);
           WR32('EIM_CS0RCR2,'h00000008);
           WR32('EIM_CS0WCR1,'h04000000);
21.7.4
Access to Samsung OneNAND
Mentioned below are the configurations intended for Samsung OneNAND muxed and
non-muxed devices.
21.7.4.1
Samsung OneNAND Boot
There are two ways to boot from Samsung OneNAND. In the first way, the ERRST bit is
set to 0 and the user has to poll the interrupt status in the OneNAND interrupt register (or
set interrupt handler there). In the second way, the ERRST bit is set to 1 and the user
should enable the device interrupt output before the first read from CS0 access is issued.
Load sectors 2,3 to DataRAM, page 0 done in the next example:
Typical Application
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
842
NXP Semiconductors

<!-- page 843 -->

• WR16('CS0+('hF241<<1),'h0); // Clear interrupt status
• WR16('CS0+('hF100<<1),'h0); // block[8:0] address
• WR16('CS0+('hF107<<1),'h2); // sector[1:0] and page[7:2] addresses
• WR16('CS0+('hF200<<1),'h802); // buffer[11:8] address and counter[1:0]
• WR16('CS0+('hF101<<1),'h0); // DDP choose
• WR16('CS0+('hF220<<1),'h0); // Set command
21.7.4.2
Samsung OneNAND Asynchronous Mode Configuration
       // Non-muxed memory
           WR32('EIM_CS0GCR1,'h00410081);
           WR32('EIM_CS0RCR1,'h0b010000);
           WR32('EIM_CS0RCR2,'h00000000);
           WR32('EIM_CS0WCR1,'h0c092480);
       // Muxed memory
           WR32('EIM_CS0GCR1,'h00410089);
           WR32('EIM_CS0RCR1,'h0b010000);
           WR32('EIM_CS0RCR2,'h00000000);
           WR32('EIM_CS0WCR1,'h0c092480);
21.7.4.3
Samsung OneNAND Synchronous Mode Configuration
Set memory and EIM to synchronous read mode is shown in the next example:
           WR16('CS0+('hF221<<1),'hc0e0); // Synchronous read, 4 clk latency
           WR32('EIM_CS0GCR1,'h50412405); // 44 MHz (non-muxed)
           WR32('EIM_CS0RCR1,'h05010000);
The muxed Samsung OneNAND supports synchronous write, too:
       // Set memory & EIM to synchronous read and write mode
           WR16('CS0+('hF221<<1),'hc0f2); // Sync. read and write, 4 clk latency
           WR32('EIM_CS0GCR1,'h5041240f); // 44 MHz
           WR32('EIM_CS0RCR1,'h05010000);
           WR32('EIM_CS0WCR1,'h05040000);
21.7.4.4
Samsung OneNAND Utility
The following utility algorithms are used on the Samsung OneNAND:
       // Unlock Block command
           WR16('CS0+('hF100<<1),'h0);        // DFS
           WR16('CS0+('hF100<<1),'h0);        // DBS
           WR16('CS0+('hF24c<<1),'h2);        // SBA - block number (2)
           WR16('CS0+('hF241<<1),'h0);        // Clear interrupt status
           WR16('CS0+('hF220<<1),'h23);       // Unlock command
           data ='h0;
           while(!(data &'h0004))             // Polling
              RD32('WIAR, data); // Read status
       // Erase block command
           WR16('CS0+('hF100<<1),'h2);        // DFS and block ([8:0]) address
           WR16('CS0+('hF101<<1),'h0);        // DBS
           WR16('CS0+('hF241<<1),'h0);        // Clear interrupt status
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
843

<!-- page 844 -->

                     WR16('CS0+('hF220<<1),'h94);            // Erase command
           data ='h0;
           while(!(data &'h0004))                  // Wait
               RD32('WIAR, data); // Read status
      // Program page command
           WR16('CS0+('hF100<<1),'h2);             // DFS and block[8:0] address
           WR16('CS0+('hF107<<1),'h0);             // sector[1:0] and page[7:2] addresses
           WR16('CS0+('hF200<<1),'h800);           // buffer[11:8] address and counter[1:0]
           WR16('CS0+('hF241<<1),'h0);             // Clear interrupt status
           WR16('CS0+('hF220<<1),'h80);            // Program command
           data ='h0;
           while(!(data &'h0004))                  // Wait
               RD32('WIAR, data); // Read status
21.7.5
Access to Samsung UtRAM
Below mentioned configurations are intended for Samsung UtRAM.
21.7.5.1
Samsung UtRAM Asynchronous Mode Configuration
           WR32('EIM_CS0GCR1,'h400104b1);
           WR32('EIM_CS0RCR1,'h0a010000);
           WR32('EIM_CS0RCR2,'h00000008);
           WR32('EIM_CS0WCR1,'h0b040040);
21.7.5.2
Samsung UtRAM Synchronous Mode Configuration
           RD16('CS0+('hff_ffff<<1),data);             // command sequence
           RD16('CS0+('hff_ffff<<1),data);
           RD16('CS0+('hff_ffff<<1),data);
           RD16('CS0+('hff_feff<<1),data);
           RD16('CS0+('h00_82a0<<1),data);             // memory sync. configuration
           WR32('EIM_CS0GCR1,'h4021_53b7);            // fixed latency memory wrap 32
           WR32('EIM_CS0RCR1,'h0500_0000);
           WR32('EIM_CS0WCR1,'h0300_0000);
21.7.6
Access to Spansion Flash
Below mentioned configurations are intended for Spansion Flash.
21.7.6.1
Spansion Flash Asynchronous Mode Configuration
           WR32('EIM_CS0GCR1,'h00410081);
           WR32('EIM_CS0RCR1,'h0a018000);
           WR32('EIM_CS0RCR2,'h00000000);
           WR32('EIM_CS0WCR1,'h0704a240);
WR16('CS0+('hF220<<1),'h94);            // Erase command
           data ='h0;
           while(!(data &'h0004))                  // Wait
               RD32('WIAR, data); // Read status
      // Program page command
Typical Application
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
844
NXP Semiconductors

<!-- page 845 -->

           WR16('CS0+('hF100<<1),'h2);             // DFS and block[8:0] address
           WR16('CS0+('hF107<<1),'h0);             // sector[1:0] and page[7:2] addresses
           WR16('CS0+('hF200<<1),'h800);           // buffer[11:8] address and counter[1:0]
           WR16('CS0+('hF241<<1),'h0);             // Clear interrupt status
           WR16('CS0+('hF220<<1),'h80);            // Program command
           data ='h0;
           while(!(data &'h0004))                  // Wait
               RD32('WIAR, data); // Read status
21.7.6.2
Spansion Flash Synchronous Mode Configuration
           WR16('CS0+('h0555<<1),'h00aa);   // command sequence
           WR16('CS0+('h02aa<<1),'h0055);
           WR16('CS0+('h0555<<1),'hd0);
           WR16('CS0+('h0000<<1),'h1ec4);   // memory sync. configuration
           WR32('EIM_CS0GCR1,'h50411325); // 66 MHz
           WR32('EIM_CS0RCR1,'h05000000); // 5 cycles on memory
21.7.6.3
Spansion Flash Utility
       // Single word programming
           COMMAND_SEQUENCE(cs,16,'ha0);           // single word programming
           WR16('CS0+addr, data);
           CHECK_STATUS('CS0+addr,data,16,1,errst);
       // Write buffer programming
           COMMAND_SEQUENCE(0,16,'h25);              // write buffer programming
           WR16('CS0+addr,'h001f);                     // counter-1
           WR_I('CS0+addr, data, 'h0010_0001, 16); // data
           WR16('CS0+addr,'h0029);                     // write buffer to flash
           CHECK_STATUS('CS0+addr+'h3e,data[31:16]+'h00f0,16,1,errst);
There COMMAND_SEQUENCE and CHECK_STATUS are next functions:
       task COMMAND_SEQUENCE;
           input[2:0]    cs;
           input[7:0]    port_size;
           input[31:0]   code;
       begin
           if(port_size == 16)
              begin
              WR16(csba[cs]+('h0555<<1),'h00aa);
              WR16(csba[cs]+('h02aa<<1),'h0055);
              WR16(csba[cs]+('h0555<<1),code);
              end
           else
              begin
              WR32(csba[cs]+('h0555<<2),'h00aa);
              WR32(csba[cs]+('h02aa<<2),'h0055);
              WR32(csba[cs]+('h0555<<2),code);
              end
       end
       endtask
       task     CHECK_STATUS;
           input[31:0] addr;
           input[31:0] edata;
           input[7:0]   port_size;
           input[7:0]   opcode;
           output[7:0] errst;
           reg[31:0]    data;
           reg[31:0]    data3;
       begin
           errst = 0;
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
845

<!-- page 846 -->

           data  = 0;
           data3 = 0;
while(!(data == edata) && !errst) // Wait operation
         begin: BR_EN
         RD16(addr, data);             // Read status
         if(data[7] !== edata[7])
             begin
             if(data[5] == 1)
                  begin
                  RD16(addr, data3);
                  RD16(addr, data);
                  if(data[6] !== data3[6])
                       begin
                       $display("CHECK_STATUS: Error timout on single data program");
                       errst = 1;
                       disable BR_EN;
                       end
                  end
             else
                  begin
                  if(opcode == 2)
                       if(data[1] == 1)
                           begin
                           RD16(addr, data3);
                           if(port_size == 32)
                              RD32(addr, data);
                           else
                              RD16(addr, data);
                           if(data[1] == 1 && data !== edata)
                              begin
                              $display("CHECK_STATUS: Error on write buffer");
                              errst =3;
                              disable BR_EN;
                              end
                           end
                  end
             end
         else
             begin
             RD16(addr, data3);
             if(port_size == 32)
                  RD32(addr, data);
             else
                  begin
                  RD16(addr, data);
                  edata[31:16] = 16'h0;
                  end
             if(data !== edata)
                  begin
                  $display("CHECK_STATUS: Error in data write on single data program");
                  errst =2;
                  disable BR_EN;
                  end
             end
         end
end
endtask
21.7.7
8 bit support
This section details the pin connections for Intel mode and Motorola mode.
Intel Mode - For intel mode use the following connection:
Typical Application
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
846
NXP Semiconductors

<!-- page 847 -->

Table 21-8. Intel Mode pin connections
Arm platform Pin
EIM Pin
Notes
ADS#
IPP_DO_ADV_B
WAL = 1,RAL = 1
W/R
IPP_DO_BE_B
WBED = 1
WR#
WE#
RD#
OE#
Mot. Mode - For intel mode use the following connection:
Table 21-9. Motorola Mode pin connections
Arm platform Pin
EIM Pin
Notes
AS#
IPP_DO_CS_B
R/W#
WE#
LDS#
BE#
21.8
External Bus Timing Diagrams
The following timing diagrams show the timing of accesses to memory or a peripheral
with different timing parameters. All examples done for CS0, but are valid for any others
chip select. BE means one from current used BE[3:0].
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
847

<!-- page 848 -->

21.8.1
Asynchronous Read Memory Accesses Timing Diagram
EIM clk
ARVALID
ARLEN
ARADDR
ARREADY
RDATA
RVALID
RLSAT
ADDR
CSo
ADV
OE
RW
DATA_IN
Last Valid Data
0
V1
V1
V1
Last Valid Address
RWSC
V1
Figure 21-2. Read Access, RWSC=2,RCSA=0,OEA=0,RCSN=0,OEN=0, RAL=1
External Bus Timing Diagrams
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
848
NXP Semiconductors

<!-- page 849 -->

21.8.2
Asynchronous Write Memory Accesses Timing Diagram
EIM clk
AWVALID
AWLEN
AWADDR
AWREADY
WDATA
WVALID
WLSAT
AWREADY
ADDR
CSo
WE
ADV
EB
DATA_OUT
0
V1
V1
Last Valid Address
Last Valid Data
Write Address 0
Write Data 0
WWSC
Figure 21-3. Write Access, WWSC=2,WCSA=0,WEA=0,WCSN=0,WEN=0,BEA=0, BEN=0,
WAL=1
21.8.3
Asynchronous Read/Write Memory Accesses Timing
Diagram
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
849

<!-- page 850 -->

EIM CLK
BCLK
ADDR
CSo
WE
ADV
OE
BE
DATA_IN
DATA_OUT
RWSC
WWSC
RD Address
WR Address
RCSA
RCSN
WCSA
WCSN
Read
WEA
WEN
Write
RADVA
RADVN+1
RADVN+RADVA+1
WADVA
WADVN+1
WADVN+WADVA+1
OEA
OEN
BEA
BEN
Read Data
Last Valid Data
Write Data
Figure 21-4.
RCSA=1,RADVA=2,OEA=1,RADVN=1,RCSN=1,OEN=1,WCSA=1,WEA=1,WADVA=1,BEA=
1,WADVN=1,WCSN=1,WEN=1,BEN=1
External Bus Timing Diagrams
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
850
NXP Semiconductors

<!-- page 851 -->

EIM CLK
BCLK
ADDR
CSo
WE
ADV
OE
BE
DATA_IN
DATA_OUT
RWSC
WWSC
RD Address
RCSA
RCSN
CSREC
WCSN
Read
WEN
Write
RADVA
RADVN+1
RADVN+RADVA+1
WADVN+1
WADVN+WADVA+1
OEA
OEN
BEN
Read Data
Last Valid Data
Write Data
WR Address
Figure 21-5.
RWSC=5,RCSA=1,RCSN=1,RADVA=1,RADVN=1,OEA=1,OEN=1,WWSC=4,WCSA=0,WCS
N=1,WEA=0,WEN=1,WADVA=1,WADVN=1,BEA=0,BEN=1,CSREC=1
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
851

<!-- page 852 -->

21.8.4
Asynchronous Read/Write Using RAL, WAL and CSREC
EIM CLK
BCLK
ADDR
CSo
WE
ADV
OE
BE
DATA_IN
DATA_OUT
RWSC
WWSC
RD Address
RCSA
RCSN
CSREC
WCSN
Read
WEN
Write
RADVA
RAL =1
WAL =1
OEA
BEN
Read Data
Last Valid Data
Write Data
WR Address
WCSA
CSREC
BEA
Figure 21-6.
RAL=1,RCSN=1,RADVA=2,OEA=1,RCSN=1,CSREC=1,WCSA=1,WEA=0,WADVA=0,BEA=
1,WAL=1,WCSN=1,WEN=1,BEN=1
21.8.5
Consecutive Asynchronous Write Memory Accesses
Timing Diagram
External Bus Timing Diagrams
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
852
NXP Semiconductors

<!-- page 853 -->

EIM CLK
ADDR
CSo
WE
ADV
BE
DATA_OUT
OE
BCLK
WWSC
Addr1
WWSC
Addr0
WDo
WD1
Figure 21-7.
WWSC=4,WCSA=0,WEA=0,WADVA=0,BEA=0,WCSN=0,WEN=0,WADVN=0,BEN=0,CSRE
C=0
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
853

<!-- page 854 -->

EIM CLK
ADDR
CSo
WE
ADV
BE
DATA_OUT
OE
BCLK
WWSC
CSREC
WWSC
Addr0
Addr1
Write
WDo
WD1
Figure 21-8.
WWSC=4,WCSA=0,WEA=0,WADVA=0,BEA=0,WCSN=0,WEN=0,WADVN=0,BEN=0,CSRE
C=2
External Bus Timing Diagrams
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
854
NXP Semiconductors

<!-- page 855 -->

EIM CLK
ADDR
CSo
WE
ADV
BE
DATA_OUT
OE
BCLK
WWSC
Addr0
WWSC
Addr1
WCSA
WEA
WADVA+WADVN+1
WCSN
WCSA
WEA
WEN
BEA
BEN
BEA
WD0
WD1
Write
Figure 21-9.
WWSC=7,WCSA=1,WCSN=1,WEA=1,WEN=2,WADVA=0,WADVN=2,BEA=1,BEN=2
21.8.6
Consecutive Asynchronous Read Memory Accesses
Timing Diagram
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
855

<!-- page 856 -->

EIM CLK
ADDR
CSo
OE
ADV
DATA_IN
BE
WE
BCLK
RWSC
RWSC
Addr0
Addr1
RData0
RData1
Read
Figure 21-10. RWSC=4,RCSA=0,OEA=0,RADVA=0,RCSN=0,OEN=0,RADVN=0,CSREC=0
EIM CLK
ADDR
CSo
OE
ADV
DATA_IN
WE
BE
BCLK
RWSC
CSREC
RWSC
RData0
RData1
Addr 0
Addr1
Figure 21-11. RWSC=4,RCSA=0,OEA=0,RADVA=0,RCSN=0,OEN=0,RADVN=0,CSREC=2
External Bus Timing Diagrams
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
856
NXP Semiconductors

<!-- page 857 -->

21.8.7
Burst (Synchronous Mode) Read Memory Accesses
Timing Diagram - BCD=0
Figure 21-12. SRD=1,BCD=0,BCS=0,RWSC=1,RADVA=0,RADVN=0,RFL=0,RL=0
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
857

<!-- page 858 -->

21.8.8
Burst (Synchronous Mode) Read Memory Accesses
Timing Diagram - BCD=1
Figure 21-13. BCD=1, RL = 3
External Bus Timing Diagrams
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
858
NXP Semiconductors

<!-- page 859 -->

Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
859

<!-- page 860 -->

21.8.9
Burst (Synchronous Mode) Write Memory Access Timing -
BCD=1
EIM clock
awvalid
awready
awaddr
awlen
V1
1
wvalid
wready
wdata
BCLK
CS
WR
ADV
ADDR
DATA_OUT
WAIT
D1
D2
ADDR
D1
D2
External Bus Timing Diagrams
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
860
NXP Semiconductors

<!-- page 861 -->

21.8.10
Asynchronous Page Mode Access
ACLK
ARVALID
ARLEN
ARADDR
ARREADY
RDATA
RVALID
RREADY
ADDR
DATA_IN
CSo
ADV
OE
4
V1
Last Valid Data
RD0
RD1
RD2
RD3
Last Valid Addr
A0
A1
A2
A3
RWSC
PAT
PAT
PAT
RDo
RD1
RD2
RD3
OEA
RLSAT
Figure 21-14. PAT = 2
21.8.11
DTACK Mode - AXI Single Access
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
861

<!-- page 862 -->

ACLK
ARVALID
ARLEN
ARADDR
ARREADY
RDATA
RVALID
ADDR
CSo
RW
ADV
OE
DTACK
DATA_IN
V1 Word
Last Valid Addr
Address V1
V1 Word
DAPS
Sync Time
0
V1
Figure 21-15. DAPS = 2
External Bus Timing Diagrams
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
862
NXP Semiconductors

<!-- page 863 -->

ACLK
ARVALID
ARLEN
ARADDR
ARREADY
RDATA
RVALID
ADDR
CSo
RW
ADV
OE
DTACK
DATA_IN
V1 Word
Last Valid Addr
Address V1
V1 Word
Sync Time
0
V1
Figure 21-16. DAPS = 0
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
863

<!-- page 864 -->

ACLK
ARVALID
ARLEN
ARADDR
ARREADY
RDATA
RVALID
ADDR
CSo
RW
ADV
OE
DTACK
DATA_IN
0
V1 Word
Last Valid Addr
V1 Word
Sync Time
Address V1
V1
Figure 21-17. DAPS = 0
External Bus Timing Diagrams
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
864
NXP Semiconductors

<!-- page 865 -->

21.8.12
DTACK Mode - AXI Single Write Access
ACLK
AWVALID
AWLEN
AWADDR
AWREADY
WDATA
WVALID
ADDR
CSo
OE
ADV
WE
DTACK
DATA_OUT
Last Valid Addr
Address V1
DAPS
Sync Time
V1 Word
0
V1
V1 word
Figure 21-18. DAPS = 2
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
865

<!-- page 866 -->

21.8.13
DTACK Mode - AXI Burst Access
ACLK
ARVALID
ARLEN
ARADDR
ARREADY
RDATA
RVALID
ADDR
CSo
RW
ADV
OE
DTACK
DATA_IN
V1 Word
Last Valid Addr
Address V1
DAPS
Sync Time
V1 Word
V2 Word
Address V2
DAPS
Sync Time
V2 Word
V1
1
Figure 21-19. DAPS = 2 CSREC = 2
21.9
EIM Memory Map/Register Definition
EIM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
866
NXP Semiconductors

<!-- page 867 -->

The EIM includes 33 user-accessible 32-bit registers. The the EIM Configuration
Register (EIM_WCR) contains control bits that configure the EIM for certain operation
modes.
The 160 bits used to control Individual Chip Select are divided into five registers:
• Chip Select n General Configuration Register 1 (EIM_CSnGCR1)
• Chip Select n General Configuration Register 2 (EIM_CSnGCR2)
• Chip Select n Read Configuration Register 1 (EIM_CSnRCR1)
• Chip Select n Read Configuration Register 2 (EIM_CSnRCR2)
• Chip Select n Write Configuration Register (EIM_CSnWCR)
In addition there are 3 general registers: EIM_WCR, EIM_WIAR, and EIM_EAR.
NOTE
• All EIM registers are sampled by IPG_CLK_S, therefore
IPG_CLK_S must be active when accessing through IP
bus.
• Read access from all registers (except EIM_WIAR and
EIM_EAR) will generate one IPG_XFR_WAIT cycle.
• Read access from EIM_WIAR and EIM_EAR will
generate six IPG_XFR_WAIT cycles.
• Write access to all registers (except EIM_EAR) will
generate three IPG_XFR_WAIT cycles.
• Write access to EIM_EAR will generate six
IPG_XFR_WAIT cycles.
EIM memory map
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
21B_8000
Chip Select n General Configuration Register 1
(EIM_CS0GCR1)
32
R/W
0001_0080h
21.9.1/869
21B_8004
Chip Select n General Configuration Register 2
(EIM_CS0GCR2)
32
R/W
0000_1000h
21.9.2/873
21B_8008
Chip Select n Read Configuration Register 1
(EIM_CS0RCR1)
32
R/W
0000_0000h
21.9.3/875
21B_800C
Chip Select n Read Configuration Register 2
(EIM_CS0RCR2)
32
R/W
0000_0000h
21.9.4/877
21B_8010
Chip Select n Write Configuration Register 1
(EIM_CS0WCR1)
32
R/W
0000_0000h
21.9.5/879
21B_8014
Chip Select n Write Configuration Register 2
(EIM_CS0WCR2)
32
R/W
0000_0000h
21.9.6/882
21B_8018
Chip Select n General Configuration Register 1
(EIM_CS1GCR1)
32
R/W
0001_0080h
21.9.1/869
Table continues on the next page...
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
867

<!-- page 868 -->

EIM memory map (continued)
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
21B_801C
Chip Select n General Configuration Register 2
(EIM_CS1GCR2)
32
R/W
0000_1000h
21.9.2/873
21B_8020
Chip Select n Read Configuration Register 1
(EIM_CS1RCR1)
32
R/W
0000_0000h
21.9.3/875
21B_8024
Chip Select n Read Configuration Register 2
(EIM_CS1RCR2)
32
R/W
0000_0000h
21.9.4/877
21B_8028
Chip Select n Write Configuration Register 1
(EIM_CS1WCR1)
32
R/W
0000_0000h
21.9.5/879
21B_802C
Chip Select n Write Configuration Register 2
(EIM_CS1WCR2)
32
R/W
0000_0000h
21.9.6/882
21B_8030
Chip Select n General Configuration Register 1
(EIM_CS2GCR1)
32
R/W
0001_0080h
21.9.1/869
21B_8034
Chip Select n General Configuration Register 2
(EIM_CS2GCR2)
32
R/W
0000_1000h
21.9.2/873
21B_8038
Chip Select n Read Configuration Register 1
(EIM_CS2RCR1)
32
R/W
0000_0000h
21.9.3/875
21B_803C
Chip Select n Read Configuration Register 2
(EIM_CS2RCR2)
32
R/W
0000_0000h
21.9.4/877
21B_8040
Chip Select n Write Configuration Register 1
(EIM_CS2WCR1)
32
R/W
0000_0000h
21.9.5/879
21B_8044
Chip Select n Write Configuration Register 2
(EIM_CS2WCR2)
32
R/W
0000_0000h
21.9.6/882
21B_8048
Chip Select n General Configuration Register 1
(EIM_CS3GCR1)
32
R/W
0001_0080h
21.9.1/869
21B_804C
Chip Select n General Configuration Register 2
(EIM_CS3GCR2)
32
R/W
0000_1000h
21.9.2/873
21B_8050
Chip Select n Read Configuration Register 1
(EIM_CS3RCR1)
32
R/W
0000_0000h
21.9.3/875
21B_8054
Chip Select n Read Configuration Register 2
(EIM_CS3RCR2)
32
R/W
0000_0000h
21.9.4/877
21B_8058
Chip Select n Write Configuration Register 1
(EIM_CS3WCR1)
32
R/W
0000_0000h
21.9.5/879
21B_805C
Chip Select n Write Configuration Register 2
(EIM_CS3WCR2)
32
R/W
0000_0000h
21.9.6/882
21B_8060
Chip Select n General Configuration Register 1
(EIM_CS4GCR1)
32
R/W
0001_0080h
21.9.1/869
21B_8064
Chip Select n General Configuration Register 2
(EIM_CS4GCR2)
32
R/W
0000_1000h
21.9.2/873
21B_8068
Chip Select n Read Configuration Register 1
(EIM_CS4RCR1)
32
R/W
0000_0000h
21.9.3/875
21B_806C
Chip Select n Read Configuration Register 2
(EIM_CS4RCR2)
32
R/W
0000_0000h
21.9.4/877
21B_8070
Chip Select n Write Configuration Register 1
(EIM_CS4WCR1)
32
R/W
0000_0000h
21.9.5/879
Table continues on the next page...
EIM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
868
NXP Semiconductors

<!-- page 869 -->

EIM memory map (continued)
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
21B_8074
Chip Select n Write Configuration Register 2
(EIM_CS4WCR2)
32
R/W
0000_0000h
21.9.6/882
21B_8078
Chip Select n General Configuration Register 1
(EIM_CS5GCR1)
32
R/W
0001_0080h
21.9.1/869
21B_807C
Chip Select n General Configuration Register 2
(EIM_CS5GCR2)
32
R/W
0000_1000h
21.9.2/873
21B_8080
Chip Select n Read Configuration Register 1
(EIM_CS5RCR1)
32
R/W
0000_0000h
21.9.3/875
21B_8084
Chip Select n Read Configuration Register 2
(EIM_CS5RCR2)
32
R/W
0000_0000h
21.9.4/877
21B_8088
Chip Select n Write Configuration Register 1
(EIM_CS5WCR1)
32
R/W
0000_0000h
21.9.5/879
21B_808C
Chip Select n Write Configuration Register 2
(EIM_CS5WCR2)
32
R/W
0000_0000h
21.9.6/882
21B_8090
EIM Configuration Register (EIM_WCR)
32
R/W
See section
21.9.7/883
21.9.1
Chip Select n General Configuration Register 1
(EIM_CSnGCR1)
Address: 21B_8000h base + 0h offset + (24d × i), where i=0d to 5d
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
PSZ
WP
GBC
AUS
CSREC
SP
DSZ
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
1
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
BCS
BCD
WC
BL
CREP
CRE
RFL
WFL
MUM
SRD
SWR
CSEN
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
1
0
0
0
0
0
0
0
EIM_CSnGCR1 field descriptions
Field
Description
31–28
PSZ
Page Size. This bit field indicates memory page size in words (word is defined by the DSZ field). PSZ is
used when fix latency mode is applied, WFL=1 for sync. write accesses, RFL=1 for sync. Read accesses.
When working in fix latency mode WAIT signal from the external device is not being monitored, PSZ is
used to determine if page boundary is reached and renewal of access is preformed. This bit field is
ignored when sync. Mode is disabled or fix latency mode is not being used for write or read access
separately.
Table continues on the next page...
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
869

<!-- page 870 -->

EIM_CSnGCR1 field descriptions (continued)
Field
Description
It can be valid for both access type, read or write, or only for one type, according to configuration. PSZ is
cleared by a hardware reset.
0000
8 words page size
0001
16 words page size
0010
32 words page size
0011
64 words page size
0100
128 words page size
0101
256 words page size
0110
512 words page size
0111
1024 (1k) words page size
1000
2048 (2k) words page size
1001
- 1111 Reserved
27
WP
Write Protect. This bit prevents writes to the address range defined by the corresponding chip select. WP
is cleared by a hardware reset.
0
Writes are allowed in the memory range defined by chip.
1
Writes are prohibited. All attempts to write to an address mapped by this chip select result in a error
response and no assertion of the chip select output.
26–24
GBC
Gap Between Chip Selects. This bit field, according to the settings shown below, determines the minimum
time between end of access to the current chip select and start of access to different chip select. GBC is
cleared by a hardware reset.
Example settings:
000
minimum of 0 EIM clock cycles before next access from different chip select (async. mode only)
001
minimum of 1 EIM clock cycles before next access from different chip select
010
minimum of 2 EIM clock cycles before next access from different chip select
111
minimum of 7 EIM clock cycles before next access from different chip select
23
AUS
Address UnShifted. This bit indicates an unshifted mode for address assertion for the relevant chip select
accesses. AUS bit is cleared by hardware reset.
0
Address shifted according to port size (DSZ config) (128 Mbyte maximum supported memory density).
1
Address unshifted (32 Mbyte maximum supported memory density).
22–20
CSREC
CS Recovery. This bit field, according to the settings shown below, determines the minimum pulse width
of CS, OE, and WE control signals before executing a new back to back access to the same chip select.
CSREC is cleared by a hardware reset.
NOTE: The reset value for EIM_CS0GCR1, CSREC[2:0] is 0b110. For EIM_CS1GCR1 - EIM_CS5GCR,
the reset value is 0b000.
Example settings:
000
0 EIM clock cycles minimum width of CS, OE and WE signals (read async. mode only)
001
1 EIM clock cycles minimum width of CS, OE and WE signals
010
2 EIM clock cycles minimum width of CS, OE and WE signals
111
7 EIM clock cycles minimum width of CS, OE and WE signals
19
SP
Supervisor Protect. This bit prevents accesses to the address range defined by the corresponding chip
select when the access is attempted in the User mode. SP is cleared by a hardware reset.
Table continues on the next page...
EIM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
870
NXP Semiconductors

<!-- page 871 -->

EIM_CSnGCR1 field descriptions (continued)
Field
Description
0
User mode accesses are allowed in the memory range defined by chip select.
1
User mode accesses are prohibited. All attempts to access an address mapped by this chip select in
User mode results in an error response and no assertion of the chip select output.
18–16
DSZ
Data Port Size. This bit field defines the width of an external device's data port as shown below.
NOTE: Only async. access supported for 8 bit port.
NOTE: The reset value for EIM_CS0GCR1, DSZ[2] = 0, DSZ[1:0] = EIM_BOOT[1:0]. For EIM_CS1GCR1
- EIM_CS5GCR1, the reset value is 0b001.
000
Reserved.
001
16 bit port resides on DATA[15:0]
010
16 bit port resides on DATA[31:16]
011
32 bit port resides on DATA[31:0]
100
8 bit port resides on DATA[7:0]
101
8 bit port resides on DATA[15:8]
110
8 bit port resides on DATA[23:16]
111
8 bit port resides on DATA[31:24]
15–14
BCS
Burst Clock Start. When SRD=1 or SWR=1,this bit field determines the number of EIM clock cycles delay
from start of access before the first rising edge of BCLK is generated.
When BCD=0 value of BCS=0 results in a half clock delay after the start of access. For other values of
BCD a one clock delay after the start of access is applied, not an immediate assertion. BCS is cleared by
a hardware reset.
00
0 EIM clock cycle additional delay
01
1 EIM clock cycle additional delay
10
2 EIM clock cycle additional delay
11
3 EIM clock cycle additional delay
13–12
BCD
Burst Clock Divisor. This bit field contains the value used to program the burst clock divisor for BCLK
generation. It is used to divide the internal EIMbus frequency. BCD is cleared by a hardware reset.
NOTE: For other then the mentioned below frequency such as 104 MHz, EIM clock (input clock) should
be adjust accordingly.
00
Divide EIM clock by 1
01
Divide EIM clock by 2
10
Divide EIM clock by 3
11
Divide EIM clock by 4
11
WC
Write Continuous. The WI bit indicates that write access to the memory are always continuous accesses
regardless of the BL field value. WI is cleared by hardware reset.
0
Write access burst length occurs according to BL value.
1
Write access burst length is continuous.
10–8
BL
Burst Length. The BL bit field indicates memory burst length in words (word is defined by the DSZ field)
and should be properly initialized for mixed wrap/increment accesses support. Continuous BL value
corresponds to continuous burst length setting of the external memory device. For fix memory burst size,
type is always wrap. In case not matching wrap boundaries in both the memory (BL field) and Master
access on the current address, EIM update address on the external device address bus and regenerates
the access.
BL is cleared by a hardware reset.
Table continues on the next page...
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
871

<!-- page 872 -->

EIM_CSnGCR1 field descriptions (continued)
Field
Description
When APR=1, Page Read Mode is applied, BL determine the number of words within the read page burst.
BL is cleared by a hardware reset for EIM_CS0GCR1 - EIM_CS5GCR1.
000
4 words Memory wrap burst length (read page burst size when APR = 1)
001
8 words Memory wrap burst length (read page burst size when APR = 1)
010
16 words Memory wrap burst length (read page burst size when APR = 1)
011
32 words Memory wrap burst length (read page burst size when APR = 1)
100
Continuous burst length (2 words read page burst size when APR = 1)
101
Reserved
110
Reserved
111
Reserved
7
CREP
Configuration Register Enable Polarity. This bit indicates CRE memory pin assertion state, active-low or
active-high, while executing a memory register set command to the external device (PSRAM memory
type). CREP is set by a hardware reset.
NOTE: Whenever PSRAM is connected the CREP value must be correct also for accesses where CRE
is disabled.
For Non-PSRAM memory CREP value should be 1.
0
CRE signal is active low
1
CRE signal is active high
6
CRE
Configuration Register Enable. This bit indicates CRE memory pin state while executing a memory
register set command to PSRAM external device. CRE is cleared by a hardware reset.
0
CRE signal use is disable
1
CRE signal use is enable
5
RFL
Read Fix Latency. This bit field determine if the controller is monitoring the WAIT signal from the External
device connected to the chip select (handshake mode - fix or variable data latency) or if it start sampling
data according to RWSC field, it only valid in synchronous mode. RFL is cleared by a hardware reset.
When RFL=1 Burst access is terminated on page boundary and resume on the following page according
to BL bit field configuration, because WAIT signal is not monitored from the external device.
0
the External device WAIT signal is being monitored, and it reflect the external data bus state
1
the state of the External devices is determined internally (Fix latency mode only)
4
WFL
Write Fix Latency. This bit field determine if the controller is monitoring the WAIT signal from the External
device connected to the chip select (handshake mode - fix or variable data latency) or if it start data
transfer according to WWSC field, it only valid in synchronous mode. WFL is cleared by a hardware reset.
When WFL=1 Burst access is terminated on page boundary and resume on the following page according
to BL bit field configuration, because WAIT signal is not monitored from the external device
0
the External device WAIT signal is being monitored, and it reflect the external data bus state
1
the state of the External devices is determined internally (Fix latency mode only)
3
MUM
Multiplexed Mode. This bit determines the address/data multiplexed mode for asynchronous and
synchronous accesses for 8 bit, 16 bit or 32 bit devices (DSZ config. dependent).
NOTE: The reset value for EIM_CS0GCR1[MUM] = EIM_BOOT[2]. For EIM_CS1GCR1 -
EIM_CS5GCR1 the reset value is 0.
0
Multiplexed Mode disable
1
Multiplexed Mode enable
Table continues on the next page...
EIM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
872
NXP Semiconductors

<!-- page 873 -->

EIM_CSnGCR1 field descriptions (continued)
Field
Description
2
SRD
Synchronous Read Data. This bit field determine the read accesses mode to the External device of the
chip select. The External device should be configured to the same mode as this bit implicates. SRD is
cleared by a hardware reset.
NOTE: Sync. accesses supported only for 16/32 bit port.
0
read accesses are in Asynchronous mode
1
read accesses are in Synchronous mode
1
SWR
Synchronous Write Data. This bit field determine the write accesses mode to the External device of the
chip select. The External device should be configured to the same mode as this bit implicates. SWR is
cleared by a hardware reset.
NOTE: Sync. accesses supported only for 16/32 bit port.
0
write accesses are in Asynchronous mode
1
write accesses are in Synchronous mode
0
CSEN
CS Enable. This bit controls the operation of the chip select pin. CSEN is set by a hardware reset for
CSGCR0 to allow external boot operation. CSEN is cleared by a hardware reset to CSGCR1-CSGCR5.
NOTE: Reset value for EIM_CS0GCR1 for CSEN is 1. For EIM_CS1GCR1-CS1GCR5 reset value is 0.
0
Chip select function is disabled; attempts to access an address mapped by this chip select results in
an error respond and no assertion of the chip select output
1
Chip select is enabled, and is asserted when presented with a valid access.
21.9.2
Chip Select n General Configuration Register 2
(EIM_CSnGCR2)
Address: 21B_8000h base + 4h offset + (24d × i), where i=0d to 5d
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
0
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
0
MUX16_BYP_
GRANT
0
DAP
DAE
DAPS
0
ADH
W
Reset
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
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
873

<!-- page 874 -->

EIM_CSnGCR2 field descriptions
Field
Description
31–13
Reserved
This read-only field is reserved and always has the value 0.
12
MUX16_BYP_
GRANT
Muxed 16 bypass grant. This bit when asserted causes EIM to bypass the grant/ack. arbitration with NFC
(only for 16 bit muxed mode accesses).
0
EIM waits for grant before driving a 16 bit muxed mode access to the memory.
1
EIM ignores the grant signal and immediately drives a 16 bit muxed mode access to the memory.
11–10
Reserved
This read-only field is reserved and always has the value 0.
9
DAP
Data Acknowledge Polarity. This bit indicates DTACK memory pin assertion state, active-low or active-
high, while executing an async access using DTACK signal from the external device. DAP is cleared by a
hardware reset.
0
DTACK signal is active high
1
DTACK signal is active low
8
DAE
Data Acknowledge Enable. This bit indicates external device is using DTACK pin as strobe/terminator of
an async. access. DTACK signal may be used only in asynchronous single read (APR=0) or write
accesses. DTACK poling start point is set by DAPS bit field. polarity of DTACK is set by DAP bit field. DAE
is cleared by a hardware reset.
0
DTACK signal use is disable
1
DTACK signal use is enable
7–4
DAPS
Data Acknowledge Poling Start. This bit field determine the starting point of DTACK input signal polling.
DAPS is used only in asynchronous single read or write accesses.
NOTE: Since DTACK is an async. signal the start point of DTACK signal polling is at least 3 cycles after
the start of access.
DAPS is cleared by a hardware reset.
Example settings:
0000
3 EIM clk cycle between start of access and first DTACK check
0001
4 EIM clk cycles between start of access and first DTACK check
0010
5 EIM clk cycles between start of access and first DTACK check
0111
10 EIM clk cycles between start of access and first DTACK check
1011
14 EIM clk cycles between start of access and first DTACK check
1111
18 EIM clk cycles between start of access and first DTACK check
3–2
Reserved
This read-only field is reserved and always has the value 0.
ADH
Address hold time - This bit field determine the address hold time after ADV negation when mum = 1
(muxed mode).
When mum = 0 this bit has no effect. For read accesses the field determines when the pads direction will
be switched.
NOTE: Reset value for EIM_CS0GCR2 for ADH is 10. For EIM_CS1GCR2-EIM_CS5GCR2 reset value
is 00.
00
0 cycle after ADV negation
01
1 cycle after ADV negation
10
2 cycle after ADV negation
11
Reserved
EIM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
874
NXP Semiconductors

<!-- page 875 -->

21.9.3
Chip Select n Read Configuration Register 1
(EIM_CSnRCR1)
Address: 21B_8000h base + 8h offset + (24d × i), where i=0d to 5d
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
0
RWSC
0
RADVA
RAL
RADVN
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
0
OEA
0
OEN
0
RCSA
0
RCSN
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
EIM_CSnRCR1 field descriptions
Field
Description
31–30
Reserved
This read-only field is reserved and always has the value 0.
29–24
RWSC
Read Wait State Control. This bit field programs the number of wait-states, according to the settings
shown below, for synchronous or asynchronous read access to the external device connected to the chip
select.
When SRD=1 and RFL=0, RWSC indicates the number of burst clock (BCLK) cycles from the start of an
access, before the controller can start sample data.Since WAIT signal can be asserted one cycle before
the first data can be sampled, the controller starts evaluating the WAIT signal state one cycle before, this
is referred as handshake mode or variable latency mode.
When SRD=1 and RFL=1, RWSC indicates the number of burst clock (BCLK) cycles from the start of an
access, until the external device is ready for data transfer, this is referred as fix latency mode.
When SRD=0, RFL bit is ignored, RWSC indicates the asynchronous access length and the number of
EIM clock cycles from the start of access until the external device is ready for data transfer.
RWSC is cleared by a hardware reset.
NOTE: The reset value for EIM_CS0RCR1, RWSC[5:0] = 0b011100. For CG1RCR1 - CS1RCR5 the
reset value is 0b000000.
Example settings:
000000
Reserved
000001
RWSC value is 1
000010
RWSC value is 2
111101
RWSC value is 61
111110
RWSC value is 62
111111
RWSC value is 63
23
Reserved
This read-only field is reserved and always has the value 0.
22–20
RADVA
ADV Assertion. This bit field determines when ADV signal is asserted for synchronous or asynchronous
read modes according to the settings shown below. RADVA is cleared by a hardware reset.
Example settings:
000
0 EIM clock cycles between beginning of access and ADV assertion
Table continues on the next page...
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
875

<!-- page 876 -->

EIM_CSnRCR1 field descriptions (continued)
Field
Description
001
1 EIM clock cycles between beginning of access and ADV assertion
010
2 EIM clock cycles between beginning of access and ADV assertion
111
7 EIM clock cycles between beginning of access and ADV assertion
19
RAL
Read ADV Low. This bit field determine ADV signal negation time. When RAL=1, RADVN bit field is
ignored and ADV signal will stay asserted until end of access. When RAL=0 negation of ADV signal is
according to RADVN bit field configuration.
18–16
RADVN
ADV Negation. This bit field determines when ADV signal to memory is negated during read accesses.
When SRD=1 (synchronous read mode), ADV negation occurs according to the following formula:
(RADVN + RADVA + BCD + BCS + 1) EIM clock cycles from start of access.
When asynchronous read mode is applied (SRD=0) and RAL=0 ADV negation occurs according to the
following formula: (RADVN + RADVA + 1) EIM clock cycles from start of access. RADVN is cleared by a
hardware reset.
NOTE: the reset value for EIM_CS0RCR1[RADVN] = 2. For EIM_CS1RCR1 - EIM_CS5RCR1, the reset
value is 0b000.
NOTE: This field should be configured so ADV negation will occur before the end of access. For ADV
negation at the same time with the end of access user should RAL bit.
15
Reserved
This read-only field is reserved and always has the value 0.
14–12
OEA
OE Assertion. This bit field determines when OE signal are asserted during read cycles (synchronous or
asynchronous mode), according to the settings shown below. OEA is cleared by a hardware reset.
In muxed mode OE assertion occurs (OEA + RADVN + RADVA + ADH +1) EIM clock cycles from start of
access.
NOTE: The reset value for EIM_CS0RCR1[OEA] is 0b000 if EIM_BOOT[2] = 0. If EIM_BOOT[2] is 1, the
reset value for EIM_CS0RCR1 is 0b010. The reset value of this field for EIM_CS1RCR1 -
EIM_CS5RCR1 is 0b000.
Example settings:
000
0 EIM clock cycles between beginning of access and OE assertion
001
1 EIM clock cycles between beginning of access and OE assertion
010
2 EIM clock cycles between beginning of access and OE assertion
111
7 EIM clock cycles between beginning of access and OE assertion
11
Reserved
This read-only field is reserved and always has the value 0.
10–8
OEN
OE Negation. This bit field determines when OE signal is negated during read cycles in asynchronous
single mode only (SRD=0 and APR = 0), according to the settings shown below. This bit field is ignored
when SRD=1. OEN is cleared by a hardware reset.
Example settings:
000
0 EIM clock cycles between end of access and OE negation
001
1 EIM clock cycles between end of access and OE negation
010
2 EIM clock cycles between end of access and OE negation
111
7 EIM clock cycles between end of access and OE negation
7
Reserved
This read-only field is reserved and always has the value 0.
6–4
RCSA
Read CS Assertion. This bit field determines when CS signal is asserted during read cycles (synchronous
or asynchronous mode), according to the settings shown below. RCSA is cleared by a hardware reset.
Table continues on the next page...
EIM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
876
NXP Semiconductors

<!-- page 877 -->

EIM_CSnRCR1 field descriptions (continued)
Field
Description
Example settings:
000
0 EIM clock cycles between beginning of read access and CS assertion
001
1 EIM clock cycles between beginning of read access and CS assertion
010
2 EIM clock cycles between beginning of read access and CS assertion
111
7 EIM clock cycles between beginning of read access and CS assertion
3
Reserved
This read-only field is reserved and always has the value 0.
RCSN
Read CS Negation. This bit field determines when CS signal is negated during read cycles in
asynchronous single mode only (SRD=0 and APR = 0), according to the settings shown below. This bit
field is ignored when SRD=1. RCSN is cleared by a hardware reset.
Example settings:
000
0 EIM clock cycles between end of read access and CS negation
001
1 EIM clock cycles between end of read access and CS negation
010
2 EIM clock cycles between end of read access and CS negation
111
7 EIM clock cycles between end of read access and CS negation
21.9.4
Chip Select n Read Configuration Register 2
(EIM_CSnRCR2)
Address: 21B_8000h base + Ch offset + (24d × i), where i=0d to 5d
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
0
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
APR
PAT
0
RL
0
RBEA
RBE
RBEN
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
EIM_CSnRCR2 field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15
APR
Asynchronous Page Read. This bit field determine the asynchronous read mode to the external device.
When APR=0, the async. read access is done as single word (where word is defined by the DSZ field).
when APR=1, the async. read access executed as page read. page size is according to BL field config.,
RCSN,RBEN,OEN and RADVN are being ignored.
APR is cleared by a hardware reset for EIM_CS1GCR1 - EIM_CS5GCR1.
NOTE: SRD=0 and MUM=0 must apply when APR=1
Table continues on the next page...
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
877

<!-- page 878 -->

EIM_CSnRCR2 field descriptions (continued)
Field
Description
14–12
PAT
Page Access Time. This bit field is used in Asynchronous Page Read mode only (APR=1). the initial
access is set by RWSC as in regular asynchronous mode. the consecutive address assertions width
determine by PAT field according to the settings shown below. when APR=0 this field is ignored.
PAT is cleared by a hardware reset for EIM_CS1GCR1 - EIM_CS5GCR1.
000
Address width is 2 EIM clock cycles
001
Address width is 3 EIM clock cycles
010
Address width is 4 EIM clock cycles
011
Address width is 5 EIM clock cycles
100
Address width is 6 EIM clock cycles
101
Address width is 7 EIM clock cycles
110
Address width is 8 EIM clock cycles
111
Address width is 9 EIM clock cycles
11–10
Reserved
This read-only field is reserved and always has the value 0.
9–8
RL
Read Latency. This bit field indicates cycle latency when executing a synchronous read operation.
The fields holds the feedback clock loop delay in aclk cycle units.
This field is cleared by a hardware reset.
00
Feedback clock loop delay is up to 1 cycle for BCD = 0 or 1.5 cycles for BCD != 0
01
Feedback clock loop delay is up to 2 cycles for BCD = 0 or 2.5 cycles for BCD != 0
10
Feedback clock loop delay is up to 3 cycles for BCD = 0 or 3.5 cycles for BCD != 0
11
Feedback clock loop delay is up to 4 cycles for BCD = 0 or 4.5 cycles for BCD != 0
7
Reserved
This read-only field is reserved and always has the value 0.
6–4
RBEA
Read BE Assertion. This bit field determines when BE signal is asserted during read cycles (synchronous
or asynchronous mode), according to the settings shown below. RBEA is cleared by a hardware reset.
Example settings:
000
0 EIM clock cycles between beginning of read access and BE assertion
001
1 EIM clock cycles between beginning of read access and BE assertion
010
2 EIM clock cycles between beginning of read access and BE assertion
111
7 EIM clock cycles between beginning of read access and BE assertion
3
RBE
Read BE enable. This bit field determines if BE will be asserted during read access.
0
- BE are disabled during read access.
1-
BE are enable during read access according to value of RBEA and RBEN bit fields.
RBEN
Read BE Negation. This bit field determines when BE signal is negated during read cycles in
asynchronous single mode only (SRD=0 and APR=0), according to the settings shown below. This bit field
is ignored when SRD=1. RBEN is cleared by a hardware reset.
Example settings:
000
0 EIM clock cycles between end of read access and BE negation
001
1 EIM clock cycles between end of read access and BE negation
010
2 EIM clock cycles between end of read access and BE negation
111
7 EIM clock cycles between end of read access and BE negation
EIM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
878
NXP Semiconductors

<!-- page 879 -->

21.9.5
Chip Select n Write Configuration Register 1
(EIM_CSnWCR1)
Address: 21B_8000h base + 10h offset + (24d × i), where i=0d to 5d
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
WAL
WBED
WWSC
WADVA
WADVN
WBEA
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
WBE
A
WBEN
WEA
WEN
WCSA
WCSN
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
EIM_CSnWCR1 field descriptions
Field
Description
31
WAL
Write ADV Low. This bit field determine ADV signal negation time in write accesses. When WAL=1,
WADVN bit field is ignored and ADV signal will stay asserted until end of access. When WAL=0 negation
of ADV signal is according to WADVN bit field configuration.
30
WBED
Write Byte Enable Disable. When asserted this bit prevent from IPP_DO_BE_B[x] to be asserted during
write accesses.This bit is cleared by hardware reset.
29–24
WWSC
Write Wait State Control. This bit field programs the number of wait-states, according to the settings
shown below, for synchronous or asynchronous write access to the external device connected to the chip
select.
When SWR=1 and WFL=0, WWSC indicates the number of burst clock (BCLK) cycles from the start of an
access, before the memory can sample the first data.Since WAIT signal can be asserted one cycle before
the first data can be sampled, the controller starts evaluating the WAIT signal state one cycle before, this
is referred as handshake mode or variable latency mode.
When SWR=1 and WFL=1, WWSC indicates the number of burst clock (BCLK) cycles from the start of an
access, until the external device is ready for data transfer, this is referred as fix latency mode.
When SWR=0, WFL bit is ignored, WWSC indicates the asynchronous access length and the number of
EIM clock cycles from the start of access until the external device is ready for data transfer.
WWSC is cleared by a hardware reset.
NOTE: The reset value for EIM_CS0WCR1, WWSC[5:0] = 0b011100. For EIM_CS1WCR1 -
EIM_CS5WCR1, the reset value of this field is 0b000000.
Example settings:
000000
Reserved
000001
WWSC value is 1
000010
WWSC value is 2
000011
WWSC value is 3
111111
WWSC value is 63
Table continues on the next page...
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
879

<!-- page 880 -->

EIM_CSnWCR1 field descriptions (continued)
Field
Description
23–21
WADVA
ADV Assertion. This bit field determines when ADV signal is asserted for synchronous or asynchronous
write modes according to the settings shown below. WADVA is cleared by a hardware reset.
Example settings:
000
0 EIM clock cycles between beginning of access and ADV assertion
001
1 EIM clock cycles between beginning of access and ADV assertion
010
2 EIM clock cycles between beginning of access and ADV assertion
111
7 EIM clock cycles between beginning of access and ADV assertion
20–18
WADVN
ADV Negation. This bit field determines when ADV signal to memory is negated during write accesses.
When SWR=1 (synchronous write mode), ADV negation occurs according to the following formula:
(WADVN + WADVA + BCD + BCS + 1) EIM clock cycles.
When asynchronous read mode is applied (SWR=0) ADV negation occurs according to the following
formula: (WADVN + WADVA + 1) EIM clock cycles.
NOTE: Reset value for EIM_CS0WCR for WADVN is 2. For EIM_CS1WCR - EIM_CS5WCR reset value
is 000.
NOTE: This field should be configured so ADV negation will occur before the end of access. For ADV
negation at the same time as the end of access, S/W should set the WAL bit.
17–15
WBEA
BE Assertion. This bit field determines when BE signal is asserted during write cycles in async. mode only
(SWR=0), according to the settings shown below. BEA is cleared by a hardware reset.
NOTE: Reset value for EIM_CS0WCR for WBEA is 2. For EIM_CS1WCR - EIM_CS5WCR reset value is
000.
Example settings:
000
0 EIM clock cycles between beginning of access and BE assertion
001
1 EIM clock cycles between beginning of access and BE assertion
010
2 EIM clock cycles between beginning of access and BE assertion
111
7 EIM clock cycles between beginning of access and BE assertion
14–12
WBEN
BE[3:0] Negation. This bit field determines when BE[3:0] bus signal is negated during write cycles in
async. mode only (SWR=0), according to the settings shown below. This bit field is ignored when SWR=1.
BEN is cleared by a hardware reset.
NOTE: Reset value for EIM_CS0WCR for WBEN is 2. For EIM_CS1WCR - EIM_CS5WCR reset value is
000.
Example settings:
000 0 EIM clock cycles between end of access and WE negation
001 1 EIM clock cycles between end of access and WE negation
010 2 EIM clock cycles between end of access and WE negation
111 7 EIM clock cycles between end of access and WE negation
11–9
WEA
WE Assertion. This bit field determines when WE signal is asserted during write cycles (synchronous or
asynchronous mode), according to the settings shown below. This bit field is ignored when executing a
read access to the external device. WEA is cleared by a hardware reset.
NOTE: Reset value for EIM_CS0WCR for WEA is 2. For EIM_CS1WCR - EIM_CS5WCR reset value is
000.
Example settings:
Table continues on the next page...
EIM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
880
NXP Semiconductors

<!-- page 881 -->

EIM_CSnWCR1 field descriptions (continued)
Field
Description
000
0 EIM clock cycles between beginning of access and WE assertion
001
1 EIM clock cycles between beginning of access and WE assertion
010
2 EIM clock cycles between beginning of access and WE assertion
111
7 EIMclock cycles between beginning of access and WE assertion
8–6
WEN
WE Negation. This bit field determines when WE signal is negated during write cycles in asynchronous
mode only (SWR=0), according to the settings shown below. This bit field is ignored when SWR=1. WEN
is cleared by a hardware reset.
NOTE: Reset value for EIM_CS0WCR for WEN is 2. For EIM_CS1WCR - EIM_CS5WCR reset value is
000.
Example settings:
000
0 EIM clock cycles between beginning of access and WE assertion
001
1 EIM clock cycles between beginning of access and WE assertion
010
2 EIM clock cycles between beginning of access and WE assertion
111
7 EIM clock cycles between beginning of access and WE assertion
5–3
WCSA
Write CS Assertion. This bit field determines when CS signal is asserted during write cycles (synchronous
or asynchronous mode), according to the settings shown below.this bit field is ignored when executing a
read access to the external device. WCSA is cleared by a hardware reset.
Example settings:
000
0 EIM clock cycles between beginning of write access and CS assertion
001
1 EIM clock cycles between beginning of write access and CS assertion
010
2 EIM clock cycles between beginning of write access and CS assertion
111
7 EIMclock cycles between beginning of write access and CS assertion
WCSN
Write CS Negation. This bit field determines when CS signal is negated during write cycles in
asynchronous mode only (SWR=0), according to the settings shown below. This bit field is ignored when
SWR=1. WCSN is cleared by a hardware reset.
Example settings:
000
0 EIM clock cycles between end of read access and CS negation
001
1 EIM clock cycles between end of read access and CS negation
010
2 EIM clock cycles between end of read access and CS negation
111
7 EIM clock cycles between end of read access and CS negation
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
881

<!-- page 882 -->

21.9.6
Chip Select n Write Configuration Register 2
(EIM_CSnWCR2)
Address: 21B_8000h base + 14h offset + (24d × i), where i=0d to 5d
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
0
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
0
WBCDD
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
EIM_CSnWCR2 field descriptions
Field
Description
31–1
Reserved
This read-only field is reserved and always has the value 0.
0
WBCDD
Write Burst Clock Divisor Decrement. If this bit is asserted and BCD value is 0 sync. write access will be
preformed as if BCD value is 1.When this bit is negated or BCD value is not 0 this bit has no affect.
This bit is cleared by hardware reset.
EIM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
882
NXP Semiconductors

<!-- page 883 -->

21.9.7
EIM Configuration Register (EIM_WCR)
Address: 21B_8000h base + 90h offset = 21B_8090h
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
0
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
Hard
ware
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
0
FRUN_ACLK_EN
WDOG_
LIMIT
WDOG_EN
0
INTPOL
INTEN
CONT_BCLK_
SEL
GBCD
BCM
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
0
0
0
0
0
Hard
ware
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
0
0
0
0
0
EIM_WCR field descriptions
Field
Description
31–12
Reserved
Reserved
This read-only field is reserved and always has the value 0.
11
FRUN_ACLK_EN
Free run ACLK enable
10–9
WDOG_LIMIT
Memory Watchdog (WDOG) cycle limit.
This bit field determines the number of BCLK cycles (ACLK cycles in dtack mode) before the WDOG
counter terminates the access and send an error response to the master.
00
128 BCLK cycles
01
256 BCLK cycles
10
512 BCLK cycles
11
1024 BCLK cycles
8
WDOG_EN
Memory WDOG enable.
This bit controls the operation of the wdog counter that terminates the EIM access.
0
Memory WDOG is Disabled
1
Memory WDOG is Enabled
Table continues on the next page...
Chapter 21 External Interface Module (EIM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
883

<!-- page 884 -->

EIM_WCR field descriptions (continued)
Field
Description
7–6
Reserved
This read-only field is reserved and always has the value 0.
5
INTPOL
Interrupt Polarity. This bit field determines the polarity of the external device interrupt.
0
External interrupt polarity is active low
1
External interrupt polarity is active high
4
INTEN
Interrupt Enable. When this bit is set the External signal RDY_INT as active interrupt. When interrupt
occurs, INT bit at the WCR will be set and t EIM_EXT_INT signal will be asserted correspondingly. This bit
is cleared by a hardware reset.
0
External interrupt Disable
1
External interrupt Enable
3
CONT_BCLK_
SEL
Continuous BCLK select
When this bit is set BCLK pin output continuous clock. Otherwize, BCLK will output clock only when
nesserary.
0
BCLK When nesserary
1
BCLK Continuous
2–1
GBCD
General Burst Clock Divisor. When BCM bit is set, this bit field contains the value used to program the
burst clock divisor for Continuous BCLK generation. The other BCD bit fields for each chip select are
ignored. It is used to divide the internal AXI bus frequency. When BCM=0 GBCD bit field has no influence.
GBCD is cleared by a hardware reset.
00
Divide EIM clock by 1
01
Divide EIM clock by 2
10
Divide EIM clock by 3
11
Divide EIM clock by 4
0
BCM
Burst Clock Mode. This bit selects the burst clock mode of operation. It is used for system debug mode.
BCM is cleared by a hardware reset.
NOTE: The BCLK frequency in this mode is according to GBCD bit field.
NOTE: The BCLK phase is opposite to the EIM clock in this mode if GBCD is 0.
NOTE: This bit should be used only in async. accesses. No sync access can be executed if this bit is set.
NOTE: When this bit is set bcd field shouldn't be configured to 0.
0
The burst clock runs only when accessing a chip select range with the SWR/SRD bits set. When the
burst clock is not running it remains in a logic 0 state. When the burst clock is running it is configured
by the BCD and BCS bit fields in the chip select Configuration Register.
1
The burst clock runs whenever ACLK is active (independent of chip select configuration)
EIM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
884
NXP Semiconductors

