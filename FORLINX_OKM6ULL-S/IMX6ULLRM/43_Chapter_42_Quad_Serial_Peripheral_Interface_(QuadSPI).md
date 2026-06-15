# Chapter 42: Quad Serial Peripheral Interface (QuadSPI)

> Nguồn: `IMX6ULLRM.pdf` — trang 2965–3074

<!-- page 2965 -->

Chapter 42
Quad Serial Peripheral Interface (QuadSPI)
42.1
Overview
The Quad Serial Peripheral Interface (QuadSPI) block acts as an interface to one or two
external serial flash devices, each with up to four bidirectional data lines. The following
figure is a block diagram of the QuadSPI module.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2965

<!-- page 2966 -->

Peripheral Bus
LUT
AHB Bus
define
(Addr, Cmd)
wr_data
(Data)
(Data)
rd_data
(Data)
read_done
(Addr, Size)
read
IP_Control
DMA and Interrupt Control
Registers
TX 
Buffer
RX 
Buffer
command_build 
& buffer control
IP_Ctrl
AHB_Serve
AHB 
Buffer
AHB_Control
fetch
(Data)
(addr, size, type)
received
ipcommand 
(inst, addr, size)
ipacc
ready
wdata
rdata
ahbcommand 
(inst, addr, size)
rdata
ready
ahbacc
QSPI_IC_SFM
Clock Domain Crosser
rdata
wdata
start
QSPI_IF
Programmable sequence engine
SCLK clock domain
SCLK clock domain
Flexible I/O controller
QSPIn_A_DATA[3:0]
QSPIn_A_DQS
QSPIn_A_SCLK
QSPIn_A_SS1_B
QSPIn_A_SS0_B
QuadSPI Bus Flash A
QuadSPI Bus Flash B
QSPIn_B_DATA[3:0]
QSPIn_B_DQS
QSPIn_B_SCLK
QSPIn_B_SS1_B
QSPIn_B_SS0_B
Figure 42-1. QuadSPI Block Diagram
The following figure describes the serial flash clock diagram in QuadSPI:
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2966
NXP Semiconductors

<!-- page 2967 -->

Divider
by 4
ser_clk_4x
ser_clk_1x
Clock
Gate
Clock
Gate
SCLK_output
DQS_output
Figure 42-2. Flash Clock Diagram
ser_clk_4x is the serial clock root from CCM
ser_clk_1x’ is generated clock from ‘ser_clk_4x’ divided by 4
SCLK_output is serial output clock generated from ‘ser_clk_1x’ with inverter and clock
gate, it’s used as Clock by external serial flash device.
DQS_output is serial flash data strobe signal generated from ‘ser_clk_1x’ with inverter
and clock gate. This signal could be loopback from pad and used as sampling clock for
serial flash data.
42.1.1
Features
The QuadSPI supports the following features:
• Flexible sequence engine to support various flash vendor devices.
• Single, dual, quad mode of operation.
• DDR/DTR mode wherein the data is generated on every edge of the serial flash
clock.
• Support for flash data strobe signal for data sampling in DDR and SDR mode.
• Two identical serial flash devices can be connected and accessed in parallel for data
read operations, forming one (virtual) flash memory with doubled readout
bandwidth.
• DMA support to read RX Buffer data via AMBA AHB bus (64-bit width interface)
or IP registers space (32-bit access).
• Inner loop size of DMA access can be configured.
• Multi master accesses with priority
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2967

<!-- page 2968 -->

• Flexible and configurable buffer for each master
• Thirteen interrupt conditions (see Table 42-10)
• Memory mapped read access to connected flash devices.
• Programmable sequence engine to cater to future command/protocol changes and
able to support all existing vendor commands and operations.
• Supports 3-byte and 4-byte addressing.
• TXFIFO size is 512Byte
• RXFIFO size is 128Byte
• AHB BUF size is 1KByte
42.1.2
QuadSPI Modes of Operation
This section provides information about the modes in which the QuadSPI module can be
used.
42.1.2.1
Normal Mode
In this mode, one or two external serial flash memory devices can be accessed. Further
details about this mode of operation can be found in Modes of Operation (Normal Mode).
42.1.2.2
Module Disable Mode
This mode is used for power management of the device containing the QuadSPI module.
It is controlled by signals external to the QuadSPI. The clock to the non-memory mapped
logic in the QuadSPI can be stopped while in Module Disable Mode.
42.1.3
Acronyms and Abbreviations
The following table contains acronyms and abbreviations used in this document.
Table 42-1. Acronyms and Abbreviations
Terms
Description
AHB
Advanced High-performance Bus, version of AMBA
AMBA
Advanced Microcontroller Bus Architecture
Table continues on the next page...
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2968
NXP Semiconductors

<!-- page 2969 -->

Table 42-1. Acronyms and Abbreviations (continued)
Terms
Description
BE
Big Endian Byte Ordering
CS
Chip Select
DMA
Direct Memory Access
MB
Megabyte. Each MB is 1024 * 1024 bytes
IFM
Individual Flash Mode
PFM
Parallel Flash Mode
LSB
Least Significant Bit
MSB
Most Significant Bit
PCS
Peripheral Chip Select
QSPI, QuadSPI
Quad Serial Peripheral Interface
SCK
Serial Communications Clock
w1c
Write 1 to clear, writing a 1 to this field resets the flag
42.1.4
Glossary for QuadSPI module
Table 42-2. Glossary
Term
Definition
AHB Command
An AHB Command is a SFM Command triggered by a read access to the address range belonging
to the memory mapped access defined in Table 42-7. Refer to AHB Commands for details.
Asserted
A signal that is asserted is in its active state. An active low signal changes from logic level one to
logic level zero when asserted, and an active high signal changes from logic level zero to logic level
one.
Clear
To clear a bit or bits means to establish logic level zero on the bit or bits.
Clock Phase
Determines when the data should be sampled relative to the active edge of SCK
Clock Polarity
Determines the idle state of the SCK signal.
Drain
To remove entries from a FIFO by software or hardware.
Endianness
Byte Ordering scheme.
Field
Two or more register bits grouped together.
Fill
To add entries to a FIFO by software or hardware.
Host
Refers to another functional block in the device containing the QuadSPI module
Instruction Code
8 bits defining the type of command to be executed.
IP Command
An IP Command is a SFM Command triggered by writing into the QSPI_IPCR[SEQID] field.
Logic level one
The voltage that corresponds to Boolean true (1) state.
Logic level zero
The voltage that corresponds to Boolean false (0) state.
Negated
A signal that is negated is in its inactive state. An active low signal changes from logic level 0 to
logic level 1 when negated, and an active high signal changes from logic level 1 to logic level 0.
QSPI_AMBA_BASE
First address of QuadSPI address space on system memory map.
QSPI_ARDB_BASE
First address of QuadSPI Rx Buffer on system memory map.
Table continues on the next page...
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2969

<!-- page 2970 -->

Table 42-2. Glossary (continued)
Term
Definition
Set
To set a bit or bits means to establish logic level one on the bit or bits.
RX Buffer PUSH Event
Addition of valid entries into the RX Buffer. In the default case each Buffer PUSH Event adds 2
entries to the RX Buffer since the interface to the serial clock domain is 64 bits in width. Depending
on the number of bytes read from the serial flash device it is possible for the very last Buffer PUSH
Event that only one entry is added.
The QSPI_RBSR[RDBFL] field is incremented by the number of entries added to the RX Buffer.
RX Buffer POP Event
Removal of valid entries from the RX Buffer. Each Buffer POP Event removes
(QSPI_RBCT[WMRK] + 1) valid entries from the buffer. The QSPI_RBSR[RDBFL] field is
decremented by the same number and the QSPI_RBSR[RDCTR] field is incremented accordingly.
Individual Flash Mode
Access to a single, individual serial flash device. Refer to Serial Flash Access Schemes for details.
Parallel Flash Mode
Read access to two serial flash devices attached to the QuadSPI module in parallel. Refer to Serial
Flash Access Schemes for details.
SFM Command
Serial Flash Memory Command. A SFM command consists of an instruction code and all other
parameters (for example, size or mode bytes) needed for that specific instruction code. Triggering a
command either initiates a transaction on the external serial flash or results in an error. Refer to
Table 42-20 for details on errors.
Single/Dual/Quad
Instructions
Depending on the serial flash device connected to the QuadSPI module there will be instructions
using a different number of data lines.
• Single: Single line I/O with one data out and one data in line to/from the serial flash device.
• Dual: Dual line I/O with two bidirectional I/O lines, driven alternatively by the serial flash
device or the QuadSPI module
• Quad: Quad line I/O with 4 bidirectional I/O lines, driven alternatively by the serial flash device
or the QuadSPI
Transaction
A transaction consists of all flags, data and signals in either direction to execute a command for an
attached serial flash device. It is a combination of chip select, sclk, instruction code, address, mode-
and/or dummy bytes, transmit and/or receive data.
LUT
Look-up table.
42.2
External Signals
The following table describes the external signals of QSPI:
Table 42-3. QSPI External Signals
Signal
Description
Pad
Mode
Direction
QSPI_A_DATA0
I/O data signal 1 port 0 for serial
flash device A
NAND_READY_B
ALT0
I/O
QSPI_A_DATA1
I/O data signal 1 port 1 for serial
flash device A
NAND_CE0_B
ALT0
I/O
QSPI_A_DATA2
I/O data signal 1 port 2 for serial
flash device A
NAND_CE1_B
ALT0
I/O
QSPI_A_DATA3
I/O data signal 1 port 3 for serial
flash device A
NAND_CLE
ALT0
I/O
Table continues on the next page...
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2970
NXP Semiconductors

<!-- page 2971 -->

Table 42-3. QSPI External Signals
(continued)
Signal
Description
Pad
Mode
Direction
QSPI_A_SS0_B
Chip select 1 port 0 for serial flash
device A
NAND_DQS
ALT0
O
QSPI_A_SS1_B
Chip select 1 port 1 for serial flash
device A
NAND_DATA07
ALT0
O
QSPI_A_DQS
Data strobe signal 1 to serial flash
device A
NAND_ALE
ALT0
I
QSPI_A_SCLK
Serial clock output 1 to serial flash
device A
NAND_WP_B
ALT0
O
QSPI_B_DATA0
I/O data signal 1 port 0 for serial
flash device B
NAND_DATA02
ALT0
I/O
QSPI_B_DATA1
I/O data signal 1 port 1 for serial
flash device B
NAND_DATA03
ALT0
I/O
QSPI_B_DATA2
I/O data signal 1 port 2 for serial
flash device B
NAND_DATA04
ALT0
I/O
QSPI_B_DATA3
I/O data signal 1 port 3 for serial
flash device B
NAND_DATA05
ALT0
I/O
QSPI_B_SS0_B
Chip select 1 port 0 for serial flash
device B
NAND_WE_B
ALT0
O
QSPI_B_SS1_B
Chip select 1 port 1 for serial flash
device B
NAND_DATA00
ALT0
O
QSPI_B_DQS
Data strobe signal 1 to serial flash
device B
NAND_DATA01
ALT0
I
QSPI_B_SCLK
Serial clock output 1 to serial flash
device B
NAND_RE_B
ALT0
O
42.2.1
Driving External Signals
The different phases of serial flash access scheme are shown in the following figure.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2971

<!-- page 2972 -->

SS[1:0]
Single Pad Instructions
Not Driven
SCLK
DATA0
DATA1
DATA[3:2]
DATA[3:2]
DATA[1:0]
(pad
Driven all the time, values taken according to phase
Always Driven High
Always Driven High
Not Driven
DATA[3:0]
Not Driven
Driven for 
Tx Instr. only
Driven for 
Tx Instr. only
Dual Pad Instructions
Quad Pad Instructions
(pad
IDLE
INSTRUCTION
ADDRESS
IDLE
DATA
MODE
DUMMY
=
=
2'b0)
2'b01)
(pad = 2'b10)
Figure 42-3. Serial Flash Access Scheme
The different phases and the I/O driving characteristics of the QuadSPI module are
characterized in the following way:
• IDLE: Serial flash device not selected. No interaction with the serial flash device. All
DATA signals driven.
• INSTRUCTION: Serial flash device selected. The instruction is sent to the serial
flash device. All DATA signals are driven.
• ADDRESS: Serial Flash Address is sent to the device. All DATA signals are driven.
Note that this phase is not applicable for all SFM Commands.
• MODE: Mode bytes are sent to the serial flash device. All DATA signals are driven.
Note that this phase is not applicable for all SFM Commands.
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2972
NXP Semiconductors

<!-- page 2973 -->

• DUMMY: Dummy clocks are provided to the serial flash device. Refer to the Figure
42-3 for the DATA signals driven. The actual data lines required for the SFM
Command executed are not driven for data read commands. Note that this phase is
not applicable for all SFM Commands.
• DATA: Serial flash data are sent to or received from the serial flash device. Refer to
the preceding figure for the DATA signals driven. The actual data lines required for
the SFM Command executed are not driven for data read commands. Note that this
phase is not applicable for all SFM Commands.
The SS[1:0] and SCLK signals are driven permanently throughout all the phases.
In Individual Flash Mode this applies to the selected flash device. In Parallel Flash Mode
this applies to both serial flash devices simultaneously.
42.3
Memory Map and Register Definition
This section provides the memory map and register definitions of the QuadSPI module.
42.3.1
Register Write Access
This section describes the write access restriction terms that apply to all registers, which
can be one of the following:
• Register Write Access Restriction
For each register bit and register field, the write access conditions are specified in the
detailed register description. A description of the write access conditions is given in
the following table. If, for a specific register bit or field, none of the given write
access conditions is fulfilled, any write attempt to this register bit or field is ignored
without any notification. The values of the bits or fields are not changed.
The condition term [A or B] indicates that the register or field can be written to if at
least one of the conditions is fulfilled.
Table 42-4. Register Write Access
Restrictions
Condition
Description
Anytime
No write access restriction.
Disabled Mode
Write access only if QSPI_MCR[MDIS] = 1.
Table continues on the next page...
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2973

<!-- page 2974 -->

Table 42-4. Register Write Access Restrictions
(continued)
Condition
Description
Normal Mode
Write access only if the module is in Normal Mode.
• Register Write Access Requirements
All registers can be accessed with 8-bit, 16-bit, and 32-bit wide operations. For some
of the registers, at least a 16/32-bit wide write access is required to ensure correct
operation. This write access requirement is stated in the detailed register description
for each register affected.
42.3.2
Serial Flash Address Assignment
The serial flash address assignment may be modified by writing into Serial Flash A1 Top
Address (QuadSPI_SFA1AD) and Serial Flash A2 Top Address (QuadSPI_SFA2AD) for
device A and into Serial Flash B1Top Address (QuadSPI_SFB1AD) and Serial Flash
B2Top Address (QuadSPI_SFB2AD) for device B. The following table shows how
different access modes are related to the address specified for the next SFM Command.
Note that this address assignment is valid for both IP and AHB commands.
Table 42-5. Serial Flash Address Assignment
Parameter
Function
Access Mode
QSPI_AMBA_BASE
((31:10) - 22 bits)
QuadSPI AHB base address
TOP_ADDR_MEMA1(T
PADA1)
Top address for the external flash
A1 (first device of the dual die flash
A, or the first of the two independent
flashes sharing the IOFA)
Any access to the address space between
TOP_ADDR_MEMA1 and QSPI_AMBA_BASE will be routed
to Serial Flash A1
TOP_ADDR_MEMA2(T
PADA2)
Top address for the external flash
A2 (second device of the dual die
flash A, or the second of the two
independent flashes sharing the
IOFA).
Any access to the address space between
TOP_ADDR_MEMA2 and TOP_ADDR_MEMA1 will be
routed to Serial Flash A2
TOP_ADDR_MEMB1(T
PADB1)
Top address for the external flash
B1 (first device of the dual die flash
B, or the first of the two independent
flashes sharing the IOFB)
Any access to the address space between
TOP_ADDR_MEMB1 and TOP_ADDR_MEMA2 will be
routed to Serial Flash B1
TOP_ADDR_MEMB2(T
PADB2)
Top address for the external flash
B2 (second device of the dual die
flash B or the second of the two
independent flashes sharing the
IOFB)
Any access to the address space between
TOP_ADDR_MEMB2 and TOP_ADDR_MEMB1 will be
routed to Serial Flash A2
Memory Map and Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2974
NXP Semiconductors

<!-- page 2975 -->

42.3.3
AMBA Bus Register Memory Map
QSPI_AMBA_BASE defines the address to be used as start address of the serial flash
device as defined by the system memory map..
Table 42-6. QuadSPI AMBA Bus Memory Map
Address
Register Name
Memory Mapped Serial Flash Data - Individual Flash Mode on Flash A
QSPI_AMBA_BASE to (TOP_ADDR_MEMA2 -
0x01)
Memory Mapped Serial Flash Data - Individual Flash Mode on Flash A
Refer to Memory Mapped Serial Flash Data - Individual Flash Mode on
Flash A for details and to Table 42-14 and Table 42-18 for information
about the byte ordering.
Memory Mapped Serial Flash Data - Individual Flash Mode on Flash B
TOP_ADDR_MEMA2 to (TOP_ADDR_MEMB2 -
0x01)
Memory Mapped Serial Flash Data - Individual Flash Mode on Flash B
Refer to Memory Mapped Serial Flash Data - Individual Flash Mode on
Flash B for details and to Table 42-14 and Table 42-18 for information
about the byte ordering.
Parallel Flash Mode
QSPI_AMBA_BASE to (TOP_ADDR_MEMB2 -
0x01)
Parallel Flash Mode
Refer to Parallel Flash Mode for details and to Table 42-17 and Table
42-18 for information about the byte ordering.
AHB RX Data Buffer (QSPI_ARDB0 to QSPI_ARDB31)
QSPI_ARDB_BASE to… (32 * 4 Byte)
QSPI_ARDB_BASE + 0x0000_01FF
AHB RX Data Buffer (QSPI_ARDB0 to QSPI_ARDB31) Refer to Table
42-14 and Table 42-16 for information about the byte ordering.
Note
Any read access to non-implemented addresses will provide
undefined results.
In case single die flash devices, TOP_ADDR_MEMA2 and
TOP_ADDR_MEMB2 should be initialized/programmed to
TOP_ADDR_MEMA1 and TOP_ADDR_MEMB1
respectively- in effect, setting the size of these devices to 0.
This would ensure that the complete memory map is assigned
to only one flash device.
Parallel Flash Mode is valid only for commands related to data
read from the serial flash. The first device of flash A has to be
paired with the first device of flash B and the second device of
flash A has to be paired with the second device of flash B in
parallel mode. Parallel mode is selected via the
QSPI_BFGENCR[PAR_EN] bit for all masters in AHB driven
mode and via the QSPI_IPCR[PAR_EN] in IP driven mode. In
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2975

<!-- page 2976 -->

parallel mode, the incoming address (SFAR address in case of
IP initiated transactions and the incoming AHB address in case
of AHB initiated transactions) is divided by 2 and sent to the
two flashes connected in parallel.
Any IP Command other than data read in Parallel Flash Mode
will result in the assertion of the QSPI_FR[IUEF] flag and any
AHB Command other than data read in Parallel Flash Mode
will result in the assertion of the QSPI_FR[ABSEF] flag.
In the Individual Flash Modes, the 3/4 address bytes (as
programmed in the instruction/operand in the sequence)
available for the flash address is determined by SFADR [23:0]
or SFADR [31:0]as given in the table above.
In Parallel Flash Mode, both flashes are read with the same
starting address of 3/4 (as programmed in the instruction/
operand in the sequence) bytes in size. This address is derived
from SFADR [24:1] or SFADR [31:1] as given in the table
above. The LSB of the SFADR field is used to select the
appropriate bits of both flash devices to combine the byte
corresponding to the selected address.
42.3.4
AHB Bus Register Memory Map Descriptions
This chapter contains definitions of registers in the AMBA address space.
42.3.4.1
AHB Bus Access Considerations
It has to be noted that all logic in the QuadSPI module implementing the AHB Bus access
is designed to read the content of an external serial flash device. Therefore the following
restrictions apply to the QuadSPI module with respect to accesses to the AHB bus:
• Any write access is answered with the ERROR condition according to the AMBA
AHB Specification. No write occurs.
• Any AHB Command resulting in the assertion of the QSPI_FR[ABSEF] flag is
answered with the ERROR condition according to the AMBA_AHB specification.
The resulting AHB Command is ignored.
Memory Map and Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2976
NXP Semiconductors

<!-- page 2977 -->

• AHB Bus access types fully supported are NONSEQ and BUSY.
• AHB access type SEQ is treated in the same way like NONSEQ. Refer to the AMBA
AHB Specification for further details.
42.3.4.2
Memory Mapped Serial Flash Data - Individual Flash Mode
on Flash A
Starting with address QSPI_AMBA_BASE the content of the first external serial flash
devices is mapped into the address space of the device containing the QuadSPI module.
Serial flash address byte address 0x0 corresponds to bus address QSPI_AMBA_BASE
with increasing order. Assuming that a dual-die flash is connected on the first set of
external pads, the address space is divided into two parts, one for each device of the dual
die package. Refer to the following table for the address mapping. The byte ordering for
32 bit access is given in Table 42-14 and for 64 bit read access the byte ordering is given
in Table 42-18.
Table 42-7. Memory Mapped Individual Flash Mode - Flash A Address Scheme
Memory Mapped Address 32 Bit
Access
Memory Mapped Address 64 Bit
Access
Serial Flash Byte Address
Flash
Device
QSPI_AMBA_BASE + 0x00
QSPI_AMBA_BASE + 0x00
0x00_0000 to 0x00_0003
A1
QSPI_AMBA_BASE + 0x04
0x00_0004 to 0x00_0007
…
…
…
TOP_ADDR_MEMA1 - 0x08
TOP_ADDR_MEMA1 - 0x08
(TOP_ADDR_MEMA1- 0x08) to
(TOP_ADDR_MEMA1 - 0x04 -0x01)
TOP_ADDR_MEMA1 - 0x04
(TOP_ADDR_MEMA1 - 0x04) to
(TOP_ADDR_MEMA1 - 0x01)
TOP_ADDR_MEMA1 + 0x00
TOP_ADDR_MEMA1 + 0x00_0000
0x00_0000 to 0x00_0003
A2
TOP_ADDR_MEMA1 + 0x04
0x00_0004 to 0x00_0007
…..
…
…
TOP_ADDR_MEMA2 - 0x08
TOP_ADDR_MEMA2 - 0x08
(TOP_ADDR_MEMA2 - 0x08) to
(TOP_ADDR_MEMA2 - 0x04 -
0x01)
TOP_ADDR_MEMA2 - 0x04
(TOP_ADDR_MEMA2 - 0x04) to
(TOP_ADDR_MEMA2 - 0x01)
The available address range depends from the size of the external serial flash device. Any
access beyond the size of the external serial flash provides undefined results.
For details concerning the read process refer to Flash Read.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2977

<!-- page 2978 -->

42.3.4.3
Memory Mapped Serial Flash Data - Individual Flash Mode
on Flash B
Starting with address TOP_ADDR_MEMA2 the content of the first external serial flash
devices is mapped into the address space of the device containing the QuadSPI module.
Serial flash address byte address 0x0 corresponds to bus address TOP_ADDR_MEMA2
with increasing order. Assuming that a dual-die flash is connected on the first set of
external pads, the address space is divided into two parts, one for each device of the dual
die package. Refer the following table for the address mapping. The byte ordering for 32
bit access is given in Table 42-14 and for 64 bit read access the byte ordering is given in
Table 42-18.
Table 42-8. Memory Mapped Individual Flash Mode - Flash B Address Scheme
Memory Mapped Address 32 Bit
Access
Memory Mapped Address 64 Bit
Access
Serial Flash Byte Address
Flash
Device
TOP_ADDR_MEMA2 + 0x00
TOP_ADDR_MEMA2 + 0x00
0x00_0000 to 0x00_0003
B1
TOP_ADDR_MEMA2 + 0x04
0x00_0004 to 0x00_0007
…
…
…
TOP_ADDR_MEMB1 - 0x08
TOP_ADDR_MEMB1 - 0x08
(TOP_ADDR_MEMB1-
TOP_ADDR_MEMA2 - 0x08) to
(TOP_ADDR_MEMB1 -
TOP_ADDR_MEMA2 - 0x04 -0x01)
TOP_ADDR_MEMB1 - 0x04
(TOP_ADDR_MEMB1-
TOP_ADDR_MEMA2 - 0x04) to
(TOP_ADDR_MEMB1-
TOP_ADDR_MEMA2- 0x01)
TOP_ADDR_MEMB1 + 0x00
TOP_ADDR_MEMB1 + 0x00_0000
0x00_0000 to 0x00_0003
B2
TOP_ADDR_MEMB1 + 0x04
0x00_0004 to 0x00_0007
…..
…
…
TOP_ADDR_MEMB2 - 0x08
TOP_ADDR_MEMA2 - 0x08
(TOP_ADDR_MEMB2 -
TOP_ADDR_MEMB1- 0x08) to
(TOP_ADDR_MEMB2 -
TOP_ADDR_MEMB1 - 0x04 - 0x01)
TOP_ADDR_MEMB2 - 0x04
(TOP_ADDR_MEMB2-
TOP_ADDR_MEMB1 - 0x04) to
(TOP_ADDR_MEMB2 -
TOP_ADDR_MEMB1 - 0x01)
The available address range depends from the size of the external serial flash device. Any
access beyond the size of the external serial flash provides undefined results.
For details concerning the read process refer to Flash Read.
Memory Map and Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2978
NXP Semiconductors

<!-- page 2979 -->

42.3.4.4
Parallel Flash Mode
Any of the AHB flexible-buffers can be configured to work in parallel flash mode by
programming the QSPI_BFGENCR[PAR_EN] bit to '1'. When parallel mode is set, Flash
A1 is paired with Flash B1 and Flash A2 is paired with Flash B2. In parallel mode,
software should ensure that the size of Flash A1(A2) is equal to the size of Flash B1(B2).
Reads from any even AHB bus address provides bits [7:4] of both serial flash devices and
reads from any odd AHB bus address provides bits [3:0] of both flash devices. Refer to
the following table for the address mapping. The byte ordering for 32 bit access is given
in Table 42-16 and for 64 bit read access the byte ordering is given in Table 42-18.
Table 42-9. Memory Mapped Parallel Flash Mode Address Scheme
Memory Mapped Address 32 Bit
Access
Memory Mapped Address 64 Bit
Access
Serial Flash A Byte
Address
Serial Flash B Byte
Address
QSPI_AMBA_BASE + 0x0000_0000
QSPI_AMBA_BASE + 0x00
For details, please refer to Parallel
mode and Dual Die Flashes.
0x00_0000
-
0x00_0001
0x00_0000
-
0x00_0001
QSPI_AMBA_BASE + 0x0000_0004
0x00_002
-
0x00_0003
0x00_0002
-
0x00_0003
QSPI_AMBA_BASE + 0x0000_0008
QSPI_AMBA_BASE + 0x08
0x00_0004
-
0x00_0005
0x00_0004
-
0x00_0005
QSPI_AMBA_BASE +
0x0000_000C
0x00_0006
-
0x00_0007
0x00_0006
-
0x00_0007
…
…
…
…
TOP_ADDR_MEMB2 - 0x08
TOP_ADDR_MEMB2 - 0x08
(TOP_ADDR_MEMB2 -
QSPI_AMBA_BASE -
0x08)/2
(TOP_ADDR_MEMB2 -
QSPI_AMBA_BASE -
0x08)/2
TOP_ADDR_MEMB2 - 0x04
(TOP_ADDR_MEMB2 -
QSPI_AMBA_BASE -
0x04)/2 +0x01
(TOP_ADDR_MEMB2 -
QSPI_AMBA_BASE-
0x04)/2 + 0x01
The available address range covers 27 address bits, corresponding to 128 MB per flash
device. The usable space depends from the size of the external serial flash devices. Any
access beyond the size of the external serial flash provides undefined results.
For details concerning the read process refer to Flash Read.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2979

<!-- page 2980 -->

42.4
Interrupt Signals
The interrupt request lines of the QuadSPI module are mapped to the internal flags
according to the following table.
Table 42-10. Assignment of Interrupt Request Lines
IRQ/DMA line
QSPI_FR Flag
Interrupt Description
ipi_int_tfff
TBFF
TX Buffer Fill
ipi_int_tcf
TFF
Peripheral Command Transaction Finished
ipi_int_rfdf
RBDF
RX Buffer Drain
ipi_int_overrun
Buffer Overflow/Underrun Error
Logical OR from:
RBOF
RX Buffer Overrun
TBUF
TX Buffer Underrun
ABOF
AHB Buffer Overflow
ipi_int_cerr
Serial Flash Command Error
Logical OR from:
IPAEF
Peripheral access while AHB busy Error
IPIEF
Peripheral Command could not be triggered Error
IPGEF
Peripheral access while AHB Grant Error
IUEF
Peripheral Command Usage Error
ipi_int_ored
DLPFF, TBFF, TFF,
ILLINE, RBDF, RBOF,
TBUF, ABSEF, ABOF,
IPAEF, IPIEF, IPGEF,
IUEF
Logical OR from all the QSPI_FR flags mentioned
42.5
Functional Description
This section provides the functional information of the QuadSPI module.
42.5.1
Serial Flash Access Schemes
The Quad Serial Peripheral Interface (QuadSPI) block acts as an interface to one single or
two external serial flash devices, each with up to 4 bidirectional data lines. Depending
from the serial flash devices attached to the QuadSPI module the following access
schemes are possible:
Interrupt Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2980
NXP Semiconductors

<!-- page 2981 -->

Table 42-11. Access Schemes for Serial Flash Data Access
Access Scheme
One Flash Device on
Port A
One Flash Device on
Port B
Two identical Flash
Devices connected
on Port A and Port B
Individual Flash Mode: Access to Flash A
Yes
N/a
Yes
Individual Flash Mode: Access to Flash B
N/a
Yes
Yes
Parallel Flash Mode: Read from Flash A and
Flash B
N/a
N/a
Yes
Note
If two flash devices are accessed in Parallel Flash Mode, they
are accessed with identical control signals. Special alignment
on per-flash basis is not possible. It is within the responsibility
of the application to ensure that the identical signals are
applicable to both flash devices.
In Parallel Flash Mode, both external serial flash devices appear
logically as one single memory doubled in size with respect to
one individual flash device.
If two different flash devices are attached, they can be operated
only in Individual Flash Mode.
In the Parallel Flash Mode, only data read commands are
supported. Any other IP Command will result in an error
condition signaled by the assertion of the QSPI_FR[IUEF] flag
and any other AHB Command will result in the assertion of the
QSPI_FR[ABSEF] flag.
In the Individual Flash Mode, all supported commands are
available.
Unless explicitly noted, all the following descriptions relate to the Individual Flash Mode.
42.5.2
Modes of Operation
Refer to QuadSPI Modes of Operation for an overview over the possible operational
modes of the QuadSPI block.
• Normal Mode can be used for write or read accesses to an external serial flash
device.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2981

<!-- page 2982 -->

• Serial Flash Write: Data can be programmed into the flash via the IP interface
only. Refer to Flash Programming for further details.
• Serial Flash Read: Read the contents of the serial flash device. Two separate read
channels are available via RX Buffer and AHB Buffer, see Flash Read.
• Stop Mode: The mode is used for power management. When a request is made to
enter Stop Mode, the QuadSPI block acknowledges the request and completes the
SFM Command in progress, then the system clocks to the QuadSPI block may be
shut off
• Module Disable Mode: The mode is used for power management. The clock to the
non-memory mapped logic in the QuadSPI can be stopped while in Module Disable
Mode. The module enters the mode by setting QSPI_MCR[MDIS].
42.5.3
Normal Mode
This mode is used to allow communication with an external serial flash device.
Compared to the standard SPI protocol, this communication method uses up to 4
bidirectional data lines operating at high data rates. The communication to the external
serial flash device consists of an instruction code and optional address, mode, dummy
and data transfers. The flexible programmable core engine described below is immune to
a wide variety of command/protocol differences in the serial flash devices provided by
various flash vendors.
42.5.3.1
Programmable Sequence Engine
The core of the QuadSPI module is a programmable sequence engine that works on
"instruction-operand" pairs. The core controller executes each programmed instruction
sequentially. The complete list of instructions and the corresponding operands is given in
the following table.
Table 42-12. Instruction set
Instruction
Instruction
encoding
Pins
Operand
Action on Serial Flash(es)
CMD
6'd1
N=2'd{0,1,2}
2'd0 - One
pad
2'd1 - Two
pads
8 bit
command
value
Provide the serial flash with operand on the number of pads
specified
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2982
NXP Semiconductors

<!-- page 2983 -->

Table 42-12. Instruction set (continued)
Instruction
Instruction
encoding
Pins
Operand
Action on Serial Flash(es)
ADDR
6'd2
2'd2 - Four
pads
Number of
address bits
to be sent (for
example,
8'd24 => 24
address bits
required)
Provide the serial flash with address cycles according to the
operand on the number of pads specified. The actual address
to be provided will be derived from the incoming address in
case of AHB initiated transactions and the value of SFAR in
case of IPS initiated transactions .
DUMMY
6'd3
Number of
dummy clock
cycles (should
be <= 64
cycles)
Provide the serial flash with dummy cycles as per the
operand. The PAD information defines the number of pads in
input mode. (for example, one pad implies that pad 1 is not
driven, rest all are driven)
MODE
6'd4
8 bit mode
value
Provide the serial flash with 8 bit operand on the number of
pads specified
MODE2
6'd5
N=2'd{0,1}
2 bit mode
value
Provide the serial flash with 2 bit operand on the number of
pads1 specified
MODE4
6'd6
N=2'd{0,1,2}
4 bit mode
value
Provide the serial flash with 4 bit operand on the number of
pads2 specified
READ
6'd7
N=2'd{0,1,2}
2'd0 - One
pad
2'd1 - Two
pads
2'd2 - Four
pads
Read data
size in bytes
(for AHB
transactions,
the user's
application
should ensure
that data size
is a multiple of
8 bytes)
Read data from flash on the number of pads specified. The
data size may be overwritten by writing to the ADATSZ field of
the QSPI_BUFxCR registers for AHB initiated transactions
and IDATSZ field of IP Configuration Register
(QuadSPI_IPCR) for IP initiated transactions.
WRITE
6'd8
Write data
size in bytes
Write data on number of pads sepcified. The data size may
be overwritten by writing to the IDATSZ field of IP
Configuration Register (QuadSPI_IPCR) register
JMP_ON_CS
6'd9
NA
Instruction
number
Every time the CS is deasserted, jump to the instruction
pointed to by the operand. This instruction allows the
programmer to specify the behavior of the controller when a
new read transaction is initiated following a CS deassertion.
ADDR_DDR
6'd10
N=2'd{0,1,2}
2'd0 - One
pad
2'd1 - Two
pads
2'd2 - Four
pads
Number of
address bits
to be sent (for
example,
8'd24 => 24
address bits
required)
Provide the serial flash with address cycles according to the
operand on the number of pads specified at each clock edge
of serial flash clock. The actual address to be provided will be
derived from the incoming address in case of AHB initiated
transactions and the value of QSPI_SFAR in case of IPS
initiated transactions .
MODE_DDR
6'd11
8 bit mode
value
Provide the serial flash with 8 bit operand on the number of
pads specified at each clock edge of serial flash.
MODE2_DDR 6'd12
N=2'd{0}
2 bit mode
value
Provide the serial flash with 2 bit operand on the number of
pads specified at each clock edge of serial flash3
MODE4_DDR 6'd13
N=2'd{0,1}
4 bit mode
value
Provide the serial flash with 4 bit operand on the number of
pads specified at each clock edge of serial flash4.
Table continues on the next page...
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2983

<!-- page 2984 -->

Table 42-12. Instruction set (continued)
Instruction
Instruction
encoding
Pins
Operand
Action on Serial Flash(es)
READ_DDR
6'd14
N=2'd{0,1,2}
2'd0 - One
pad
2'd1 - Two
pads
2'd2 - Four
pads
Read data
size in bytes
(for AHB
transactions,
the user's
application
should ensure
that data size
is in multiple
of 8 bytes)
Read data from flash on the number of pads specified at each
clock edge of serial flash. The data size may be overwritten
by writing to the ADATSZ field of the QSPI_BUFxCR registers
for AHB initiated transactions and IDATSZ field of IP
Configuration Register (QuadSPI_IPCR) for IP initiated
transactions
WRITE_DDR
6'd15
Write data
size in bytes
Write data on the number of pads specified at each clock
edge of serial flash. The data size may be overwritten by
writing to the IDATSZ field of IP Configuration Register
(QuadSPI_IPCR) register
DATA_LEAR
N5
6'd16
8 bit Data
learning
pattern
Find the correct sampling point with the data learning pattern.
When this instruction is encountered, the
QSPI_SMPR[DDRSMP] values are ignored and the controller
finds the correct sampling point on its own by sampling the
data learning pattern.6
STOP
8'd0
NA
NA
Stop execution; deassert CS
1.
For a one pad instruction, MODE2 will take 2 serial flash clock cycles on the flash interface.
2.
For a one pad instruction, MODE4 will take 4 serial flash clock cycles on the flash interface. For a 4 pad instruction,
MODE4 will take 1 serial flash clock cycle on the flash interface.
3.
For a one pad instruction, MODE2_DDR will take 1 serial flash clock cycle on the flash interface.
4.
For a one pad instruction, MODE4_DDR will take 2 serial flash clock cycles on the flash interface. For a 4 pad instruction
MODE4_DDR will take half a cycle on the serial flash interface.
5.
Data learning is not implemented on this chip.
6.
t is not recommended to have 0x00 or 0xFF as the data learning pattern.
A sequence of such instruction-operand pairs may be pre-populated in the LUT according
to the device connected on board. Each instruction-operand pair is of 16 bits (2 bytes)
each. Every sequence pre-programmed in the LUT is referred to by its index.
The programmable sequence engine allows the user to configure the QuadSPI module
according to the serial flash connected on board. The flexible structure is easily adaptable
to new command/protocol changes from different vendors.
42.5.3.2
Flexible AHB buffers
In order to reduce the latency of the reads for AHB masters, the data read from the serial
flash is buffered in flexible AHB buffers. There are four such flexible buffers. The size of
each of these buffers is configurable with the minimum size being 0 Bytes and maximum
size being the size of the complete buffer instantiated.The size of buffer 0 is defined as
being from 0 to QSPI_BUF0IND. The Size of buffer 1 is from QSPI_BUF0IND to
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2984
NXP Semiconductors

<!-- page 2985 -->

QSPI_BUF1IND, buffer2 is from QSPI_BUF1IND to QSPI_BUF2IND and buffer 3 is
from QSPI_BUF2IND to the size of the complete buffer, which is given in the chip-
specific QuadSPI information.
Each flexible AHB buffer is associated with the following
1. An AHB master. Optionally, buffer3 may be configured as an "all master" buffer by
setting the QSPI_BUF3CR[ALLMST] bit. When buffer3 is configured in such a
way, any access from a master not associated with any other buffer is routed to
buffer3.
2. A datasize field representing the amount of data to be fetched from the flash on every
"missed" access.
The master port number of every incoming request is checked and the data is returned/
fetched into the corresponding associated buffer. Every "missed" access to the buffer
causes the controller to clear the buffer and fetch QSPI_BUFxCR[ADATSZ] amount of
data from the serial flash.As such, there is no benefit in configuring a buffer size of
greater than ADATSZ, as the locations greater than ADATSZ will never be used. For any
AHB access, the sequence pointed to by the QSPI_BFGENCR[SEQID] field is used for
the flash transaction initiated. The data is returned to the master as soon as the requested
amount is read from the serial flash. The controller however, continues to prefetch the
rest of the data in anticipation of a next consecutive request. Figure 42-4 shows the
flexible AHB buffers.
The QSPI_BFGENCR[SEQID] field points to an index of the LUT. Refer to Look-up
Table for details.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2985

<!-- page 2986 -->

Parametrizable max 
size
BUF2IND
BUF1IND
BUF0IND
buffer3
buffer2
buffer1
buffer0
QSPI_BFGENCR[SEQID]
LUT
Figure 42-4. Flexible AHB Buffers
Buffer0 may optionally be configured to be associated with a high priority master by
setting the QSPU_BUF0CR[HP_EN] bit. An access by a high priority master suspends
any ongoing prefetch to any of the other buffers. The ongoing prefetch is suspended and
the high priority master is serviced first. Once the high priority masters access completes,
the suspended transaction is resumed (before any other AHB access is entertained). The
status of the suspended buffer can be read from Sequence Suspend Status Register
(QuadSPI_SPNDST).
42.5.3.3
Suspend-Abort Mechanism
Any low priority AHB access can be suspended by a high priority AHB master request.
The ongoing transaction is suspended at 64 bit boundary. The suspended transaction is
restarted after the high priority master is served and the high priority transaction
including data prefetch is completed. While a transaction is in suspended state, it may be
aborted if a transaction by the same suspended master is made to a location which is
different from the location of the suspended transaction.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2986
NXP Semiconductors

<!-- page 2987 -->

Any ongoing transaction is aborted if a request from the same master arrives for a
location other than the location at which the transaction is going on. The abort can
happen at any point of time.
42.5.3.4
Look-up Table
The Look-up-table or LUT consists of a number of pre-programmed sequences. Each
sequence is basically a sequence of instruction-operand pairs which when executed
sequentially generates a valid serial flash transaction. Each sequence can have a
maximum of 8 instruction-operand pairs. The LUT can hold a maximum of 16 sequences.
The figure below shows the basic structure of the sequence in the LUT.
instr(6 bits)
LUT[4..7]
operand (8 bits)
pads (2 bits)
8 instruction-operand pairs 
in one sequence(LUT[0..3])
LUT[8..11]
LUT[60..63]
16 possible 
sequences 
can be 
programmed 
in the 
LUT
Look-up table
The instructions are executed sequentially until the last instruction or the 
STOP instruction is encountered.
Figure 42-5. LUT and sequence structure
At reset, the index 0 of the look-up-table (LUT[0..3]) is programmed with a basic read
sequence as given in Table 42-13. After reset the complete LUT may be reprogrammed
according to the device connected on board.In order to protect its contents during a code
runover the LUT may be locked, after which a write to the LUT will not be successful
until it has been unlocked again.The key for locking or unlocking the LUT is
0x5AF05AF0. The process for locking and un-locking the LUT is as follows:
Locking the LUT
1. Write the key (0x5AF05AF0) in to the LUT Key Register (QuadSPI_LUTKEY).
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2987

<!-- page 2988 -->

2. Write 0b01 to the LUT Lock Configuration Register (QuadSPI_LCKCR). Note that
this IPS transaction should immediately follow the above IPS transaction (no other
IPS transaction can be issued in between). A successful write into this register locks
the LUT.
Unlocking the LUT
1. Write the key (0x5AF05AF0) into the LUT Key Register (QuadSPI_LUTKEY)
2. Write 0b10 to the LUT Lock Configuration Register (QuadSPI_LCKCR). Note that
this IPS transaction should immediately follow the above IPS transaction (no other
IPS transaction can be issued in between). A successful write into this register
unlocks the LUT.
The lock status of the LUT can be read from QSPI_LCKCR[UNLOCK] and
QSPI_LCKCR[LOCK] bit.
Some example sequences are defined in Example Sequences. The reset sequence at LUT
index 0 is given in the following table.
Table 42-13. Reset sequence
Instruction
Pad
Operand
Comment
CMD
0x00
0x03
Read Data byte command on one pad
ADDR
0x00
0x18
24 Addr bits to be sent on one pad
READ
0x00
0x08
Read 64 bits
JMP_ON_CS
0x00
0x00
Jump to instruction 0 (CMD)
42.5.3.5
Issuing SFM Commands
Each access to the external device follows the same sequence:
1. The user must pre-populate the LUT with the serial flash command sequences that
are required for the flash device being used.
2. The QuadSPI module starts executing the instructions in the sequence one by one.
The transaction starts and the status bit QSPI_SR[BUSY] is set.
3. Communication with the external serial flash device is started and the transaction is
executed.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2988
NXP Semiconductors

<!-- page 2989 -->

4. When the transaction is finished (all transmit- and receive operations with the
external serial flash device are finished) the status bit QSPI_SR[BUSY] is reset. In
case of an IP Command the QSPI_FR[TFF] flag is asserted.
Further details are given in below in Flash Programming and Flash Read.
You can trigger the processing of SFM commands in the QuadSPI module in one of the
following ways:
• Using IP commands
For IP Commands the required components need to be written into the following
registers:
• Write the serial flash address to be used by the instruction into QSPI_SFAR,
refer to Serial Flash Address Register (QSPI_SFAR). For IP Commands not
related to specific addresses, the base address of the related flash need to be
programmed.For example, for an instruction which does not require an address
(i.e. write enable instruction) the SFAR should be programmed with the base
address of the memory the command is to be sent to.
• Write the sequence ID and data size details in the IP Configuration Register
(QSPI_IPCR).
• Note that the write into the QSPI_IPCR[SEQID] field must be the last step of the
sequence. It is possible to combine all fields of the QSPI_IPCR into one single
write. Refer to IP Configuration Register (QSPI_IPCR) for details.
Note that there are some conditions where no IP Command is executed after writing
the QSPI_IPCR[SEQID] field and the write operation itself is ignored. They are
described in Command Arbitration.
• Using AHB commands
Any AHB memory mapped access is routed to one of the buffers depending on the
master port number of the request. If the access is a "miss", a new serial flash
transaction is started. The transaction is based on the sequence pointed to by the
BFGENCR[SEQID] field as described in Flexible AHB buffers.
An AHB access is termed memory mapped when the access is to the memory
mapped serial flashes, as described in Memory Mapped Serial Flash Data -
Individual Flash Mode on Flash A and Memory Mapped Serial Flash Data -
Individual Flash Mode on Flash B.
Again the possible error conditions are described in Command Arbitration .
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2989

<!-- page 2990 -->

42.5.3.6
Flash Programming
In all cases the memory sector to be written needs to be erased first. The programming
sequence itself is then initiated in the following way:
1. Check that the TX Buffer is empty. If the QSPI_SR[TXEDA] bit is set then the TX
Buffer must be cleared by writing 1 into the QSPI_MCR[CLR_TXF] bit.
2. Program the address related to the command in the QSPI_SFAR register.
3. Provide initial data for the program command into the circular buffer via register TX
Buffer Data Register (QSPI_TBDR) . At least four word of data must be written into
the TX Buffer up to a maximum of 32.
4. Program the QSPI_IPCR register to trigger the command. The QSPI_IPCR[SEQID]
should point to an index of the LUT which has the flash program sequence pre-
programmed.The IDATSZ field should be set to denote the size of the write.
5. Depending on the amount of data required, step 3 must be repeated until all the
required data have been written into the QSPI_TBDR register.The
QSPI_SR[TXFULL] can be used to check if the buffer is ready to receive more data.
At any time, the QSPI_TBSR[TRCTR] field can be read to check how many words
have been written actually into the TX Buffer.
Upon writing the QSPI_IPCR[SEQID] field (refer to step 4) the QuadSPI module will
start to execute the programmed sequence. It is the responsibility of the software to
ensure that a correct sequence is programmed into the LUT in accordance with the flash
memory connected to the module. The data is fetched from the TX Buffer. It consists of
32 entries of 32-bits and is organized as a circular FIFO, whose read pointer is
incremented by four after each fetch. When all data are transmitted, the QuadSPI module
will return from 'busy' to 'idle'. However, this is not true for the external device since the
internal programming is still ongoing. It is up to the user to monitor the relevant status
information available from the serial flash device and to ensure that the programming is
finished properly.
42.5.3.7
Flash Read
Host access to the data stored in the external serial flash device is done in two steps. First,
the data must be read into the internal buffers and in the second step these internal buffers
can be read by the host.
1. Reading Serial Flash Data into the QuadSPI Module Internal Buffers
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2990
NXP Semiconductors

<!-- page 2991 -->

A read access to the external serial flash device can be triggered in two different
ways:
• IP Command Read: For reading flash data into the RX Buffer the user must
provide the correct sequence ID in the QuadSPI_IPCR[SEQID] register. The
sequence ID points to a sequence in the LUT. It is the responsibility of the
software to ensure that a correct read sequence is programmed in the LUT in
accordance with the serial flash device connected on board. The user should
program the Serial Flash Address Register (QSPI_SFAR) and the IP
Configuration Register (QSPI_IPCR) registers. All available read commands
supported by the external serial flash are possible.
Optionally it is possible to clear the RX Buffer pointer prior to triggering the IP
Command by writing a 1 into the QuadSPI_MCR[CLR_RXF] field.
From these inputs, the complete transaction is built when the
QSPI_IPCR[SEQID] field is written. The transaction related to the read access
starts and the requested number of bytes is fetched from the external serial flash
device into the RX Buffer. Since the read access is triggered by an IP command,
the IP_ACC status bit and the BUSY bit are both set (both are located in the
Status Register (QSPI_SR) ). A count of the number of entries currently in the
Rx Buffer can be obtained from QSPI_RBCT[RXBRD].
The communication with the external serial flash is stopped when the specified
number of bytes has been read (successful completion of the transaction).
• AHB Command Read: For reading flash data into the AHB Buffer the user
must set up a read access by a master to the address range in the system memory
map which the external serial flash devices are mapped to. The user should also
program the buffer registers corresponding to the AHB master initiating the
request, this is depends on the configuration of the QSPI_RBCT[RXBRD]. The
user should provide the correct sequence ID into the buffer generic configuration
register (QSPI_BFGENCR). It is the responsibility of the software to ensure that
a correct read sequence in programmed in the LUT in accordance with the serial
flash device connected on board. Flash device selection and access mode are
determined by the address accessed in the AHB address space associated to the
QuadSPI module (refer to Memory Mapped Serial Flash Data - Individual Flash
Mode on Flash A, Memory Mapped Serial Flash Data - Individual Flash Mode
on Flash B and Parallel Flash Mode.)
On each AHB read access to the memory mapped area the valid data in the AHB
Buffer is checked against the address requested in the actual read. When the
AHB read request can't be served from the content of the AHB Buffer, the buffer
is flushed and the sequence pointed to by the sequence ID is executed by the
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2991

<!-- page 2992 -->

controller. The requested number of buffer entries defined in the
QSPI_BUFxCR[ADATSZ] field is then fetched from the external serial flash
device into the internal AHB Buffer. Since the read access is triggered via the
AHB bus, the QSPI_SR[AHB_ACC] status bit is set driving in turn the
QSPI_SR[BUSY] bit until the transaction is finished. The communication with
the external serial flash is stopped when the specified number of entries has been
filled.
2. Data Transfer from the QuadSPI Module Internal Buffers
The data read out from the external serial flash device by the QuadSPI module is
stored in the internal buffers.The means of accessing the data from the buffer differs
depending on which buffer the data has been loaded to. Refer to Block Diagram for
details about the two available buffers, the RX Buffer and the AHB Buffer, in the
QuadSPI module:
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2992
NXP Semiconductors

<!-- page 2993 -->

Memory mapped access
Register access (RBDR)
RX 
Buffer
TX 
Buffer
Memory mapped access
ARDB access
This Buffer is transparent to the user and is non-memory mapped
AHB 
Buffer
Byte Swapper for endianness
Note:
READ ACCESS
READ ACCESS
WRITE ACCESS 
Figure 42-6. QuadSPI memory map
• The RX Buffer is implemented as FIFO of depth 32 entries of 4 bytes. Its content
is accessible in two different address areas both referring to the identical data
and the same physical memory.
In the IPS address space in the area associated to QSPI_RBDR0 to QSPI_RBDR31
In the AHB address space in the area associated to QSPI_ARDB0 to QSPI_ARDB31. Two
successive entries are accessed with one single 64 bit AHB read operation.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2993

<!-- page 2994 -->

RX Buffer operation can be summarized as follows: The QSPI_RBCT[WMRK]
field determines at which fill level the RXWE bit is asserted and how many
entries are removed from the RX Buffer on each Buffer POP operation. So the
QSPI_SR[RXWE] bit indicates that the configured number of data entries is
available in the RX Buffer and the QSPI_RBSR[RDBFL] field indicates how
many valid entries are available in total. Note that the first entry (QSPI_RBDR0
or QSPI_ARDB0) always corresponds to the first valid entry in the RX Buffer.
The software needs to manage the number of valid data bytes itself.
Further details can be found in RX Buffer Data Register (QuadSPI_RBDRn) and
in AHB RX Data Buffer (QSPI_ARDB0 to QSPI_ARDB31).
• Flag-based Data Read of the RX Buffer is done by polling the
QSPI_SR[RXWE] bit. When it is asserted the valid entries can be read either via
the IPS address space (QSPI_RBDRn) or the AHB address space
(QSPI_ARDBn). A Buffer POP operation must be triggered by the application
by writing a 1 into the QSPI_FR[RBDF] bit - this automatically updates the
FIFO to point to the next entry as defined by RBCT[WMRK]. For example, if
WMRK is set to 3, then the buffer will discard 16 bytes of data.
• DMA controlled Data Read of the RX Buffer is done by using the DMA
module.The application must ensure that the DMA controller of the related
device is programmed appropriately like it is described in DMA Usage.
DMA controlled read out is triggered fully automatically by the assertion of the
QSPI_SR[RXWE] bit. The related Buffer POP operation is also handled
completely inside the QuadSPI module. Like in the case above, accessing the RX
Buffer content either on QSPI_RBDRn or QSPI_ARDBn related addresses is
equivalent.
• AHB Buffer data read via memory mapped access: This kind of access is
done by reading one of the addresses assigned to the external serial flash
device(s) within the range given in Table 42-6 table under the condition that the
data requested are already present in the AHB Buffer or it is currently being
read from the serial flash device by the instruction in progress. If this is not the
case a memory mapped AHB command read is triggered as described above. If
the requested data is already available in the AHB Buffer they are provided
directly to the host.
When AHB access are made to the flash memory mapped address, the data will
be fetched and returned to the AHB interface. Till the data is being fetched the
AHB interface would be stalled. As soon as the data from the requested address
has been read by the QuadSPI module the AHB read access is served. So it is
possible to run sequential reads from the AHB buffer at arbitrary speed without
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2994
NXP Semiconductors

<!-- page 2995 -->

the need to monitor any information about the availability of the data.
Nevertheless this access scheme stalls the AHB bus for the time required to read
the data from the serial flash device. A better way is (when it is known the
access is sequential) to have a prefetch enabled (by programming the ADATSZ
field) such that before the next sequential AHB access come, the data is already
fetched into the buffer.
As long as the host restricts its accesses to the data already in the buffer and the
data currently fetched from the serial flash, it is possible to run the host read
from the AHB Buffer in parallel to the serial flash read into the AHB Buffer.
42.5.3.8
Byte Ordering of Serial Flash Read Data
In this paragraph the byte ordering of the serial flash data is given. The basic scheme is
that the first byte read out of the serial flash device - which is addressed by the
QSPI_SFAR[SFADR] field - corresponds to bit position QSPI_RBDR0[ 31:24] register
for IP Command read. In contrast to that for AHB Command read the bytes are always
positioned according to the byte ordering of the AHB bus.
• Byte Ordering in Individual Flash Mode
The following table gives the byte ordering scheme of how the byte oriented data
space of the serial flash device is mapped into one single 32 bit entry of the RX
Buffer or the AHB Buffer. The table is valid within the following context:
• Flash A or Flash B in Individual Flash Mode
• All AHB data read commands with access size of 32 bit
Table 42-14. Byte Ordering in Individual Flash
Mode
Serial Flash Byte Numbering
3
2
1
0
Buffer Entry Bit Position [31:0]
(32 Bit data width)
[31:24]
[23:16]
[15:8]
[7:0]
Note
For IP Commands the read size can be given in number of
bytes. If this number is not a multiple of 4, then the last
buffer entry is not completely filled with the missing higher
numbered bytes at undefined values.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2995

<!-- page 2996 -->

For AHB Commands, reads, starting from an address not aligned to 32 bit
boundaries, the requested bytes are given at the appropriate positions according to
the AMBA AHB specification.
• Byte Ordering in Parallel Flash Mode
In Parallel Flash Mode each byte is combined out of 2 half bytes which are read in
parallel from the two serial flash devices. The following tables shows how the flash
content is separated into the half bytes and how the half bytes are assembled to the
content of the QSPI_RBDR0 register.
Table 42-15. Serial Flash Device Half Byte
Ordering
Serial Flash
Device Byte #
Flash A
Bit Position
Flash B
Bit Position
[7:4]
[3:0]
[7:4]
[3:0]
0
fah0
fal0
fbh0
fbl0
1
fah1
fal1
fbh1
fbl1
2
fah2
fal2
fbh2
fbl2
3
fah3
fal3
fbh3
fbl3
4
fah4
fal4
fbh4
fbl4
5
fah5
fal5
fbh5
fbl5
6
fah6
fal6
fbh6
fbl6
7
fah7
fal7
fbh7
fbl7
8
fah8
fal8
fbh8
fbl8
The table entry naming reflects the half byte positioning in the serial flash devices:
• <fa>h0 means Flash A, <fb>h0 means Flash B.
• fa<h>0 means half byte in high position, fa<l>o means half byte in low
position.
• fah<0> means physical byte address 0 in the serial flash device, fal<1> means
physical byte address 1 in the serial flash device.
Table 42-16. Byte Ordering in Parallel Flash Mode - RX
Buffer
QSPI_SFAR[SFADR] set to 0x000_0000
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2996
NXP Semiconductors

<!-- page 2997 -->

Table 42-16. Byte Ordering in Parallel Flash Mode - RX Buffer
(continued)
QSPI_RBDR0
QSPI_ARDB0
fal1
fbl1
fah1
fbh1
fal0
fbl0
fah0
fbh0
QSPI_RBDR1
QSPI_ARDB1
fal3
fbl3
fah3
fbh3
fal2
fbl2
fah2
fbh2
QSPI_SFAR[SFADR] set to 0x000_0001
QSPI_RBDR0
QSPI_ARDB0
fal2
fbl2
fah2
fbh2
fal1
fbl1
fah1
fbh1
QSPI_RBDR1
QSPI_ARDB1
fal4
fbl4
fah4
fbh4
fal3
fbl3
fah3
fbh3
Note
For IP Commands the read size can be given in number of
bytes. If this number is not a multiple of 4 the last buffer
entry is not completely filled with the missing higher
numbered bytes at undefined values.
* Appicable only for single io mode.
Table 42-17. Byte Ordering in Parallel Flash Mode - AHB
Buffer
AHB Address
(32 Bit Access)
fal1
fbl1
fah1
fbh1
fal0
fbl0
fah0
fbh0
AHB Address
0x800_0004
(32 Bit Access)
fal3
fbl3
fah3
fbh3
fal2
fbl2
fah2
fbh2
Note
For AHB Command read starting from an address not
aligned to 32 bit boundaries or AHB access size smaller
than 32 bit the requested bytes are given at the appropriate
positions according to the AMBA AHB specification.
• Buffer Entry Ordering for 64 Bit Read Access
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2997

<!-- page 2998 -->

For read access via the AHB interface 64 bit access is possible. Each 64 bit access
reads 2 32 bit entries simultaneously. The ordering of these 32 bit entries within the
64 bit word is given in the following table.
Table 42-18. 64 Bit Read Access Buffer Entry
Ordering
AHB Read Data Bit Position [63:0]
[63:32]
[31:0]
Buffer Entry #
Odd (1, 3, 5, …)
Even (0, 2, 4, …)
42.5.3.9
Normal Mode Interrupt and DMA Requests
The QuadSPI module has different flags that can only generate interrupt requests and one
flag that can generate interrupt as well as DMA requests. The following table lists the
eight conditions. Note that the flags mentioned in the table are related to the Flag Register
(QSPI_FR).
Table 42-19. Interrupt and DMA Request Conditions
Condition
Flag(QSPI_FR)
DMA
Data Learn patttern Failure
DLPFF
-
TX Buffer Fill
TBFF
-
TX Buffer Underrun
TBUF
-
Illegal Instruction Error
ILLINE
-
RX Buffer Drain
RBDF
X
RX Buffer Overflow
RBOF
-
AHB Buffer Overflow
ABOF
-
AHB Sequence Error
ABSEF
-
IP Command Usage Error
IUEF
-
IP Command Trigger during AHB
Access Error
IPAEF
-
IP Command Trigger could not be
executed Error
IPIEF
-
IP Access during AHB Grant Error
IPGEF
-
IP Command related Transaction
Finished
TFF
-
Each condition has a flag bit in the Flag Register (QSPI_FR) and a Request Enable bit in
the DMA Request Select and Enable Register (QSPI_RSER) . The RX Buffer Drain Flag
(RBDF) has separate enable bits for generating IRQ and DMA requests. Note that not all
flags have an individual IRQ line. Check the devices Interrupt Vector Table for more
details.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2998
NXP Semiconductors

<!-- page 2999 -->

• Transmit Buffer Fill Interrupt Request:
The Transmit Buffer Fill IRQ indicates that the TX Buffer can accept new data. It is
asserted if the QSPI_FR[TBFF] flag is asserted and if the corresponding enable bit
(QSIP_RSER[TBFIE]) is set. Refer to TX Buffer Operation, for details about the
assertion of the QSPI_FR[TBFF] flag.
• Receive Buffer Drain Interrupt or DMA Request:
The Receive Buffer Drain IRQ derived from the QSPI_FR[RBDF] flag indicates that
the RX Buffer of the QuadSPI module has data available from the serial flash device
to be read by the host. It remains set as long as the QSPI_RBSR[RXWE] bit is set.
The QSPI_RSER[RBDIE] bit enables the related IRQ.
Aside from the IRQ it is possible to handle RX Buffer drain by DMA. If the
QSPI_RSER[RBDDE] bit is set, a DMA request will be triggered when the RX
Buffer contains more than QSPI_RBCT[WMRK] valid entries.The application must
set the environment appropriately (for example, the DMA controller) for the DMA
transfers.
• Buffer Overflow/Underrun Interrupt Request:
The Buffer Overflow/Underrun IRQ is a combination of the following flags (all
located in the QSPI_FR register with the related enable bits in the QSPI_RSER
register):
• TBUF - TX Buffer Underrun, enabled by TBUIE
• RBOF - RX Buffer Overflow, enabled by RBOIE
• ABOF - AHB Buffer Overflow, enabled by ABOIE
The Transmit Buffer Underrun indicates that an underrun condition in the TX
Buffer has occurred. It is generated when a write instruction is triggered whilst
the Tx Buffer is empty and the QSPI_RSER[TFUFIE] bit is set.
The Receive Buffer Overflow indicates that an overflow condition in the RX
Buffer has occurred. It is generated when the RX Buffer is full, an additional
read transfer attempts to write into the RX Buffer and the QSPI_RSER[RBOIE]
bit is set.
The AHB Buffer Overflow indicates that an overflow condition in the AHB
Buffer has occurred. It is generated when the AHB Buffer is full, an additional
read transfer attempts to write into the AHB Buffer and the
QSPI_RSER[ABOIE] bit is set.
The data from the transfers that generated the individual overflow conditions is
ignored.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2999

<!-- page 3000 -->

• Serial Flash Command Error Interrupt Request
If the IPAEF, IPIEF, IPGEF or IUEF flags in the QSPI_FR are set, and the related
interrupt enable bits in the QSPI_RSER are also set, then an interrupt is requested.
• Transaction Finished Interrupt Request
The IP Command Transaction Finished IRQ indicates the completion of the current
IP Command.It is triggered by the QSPI_FR[TFF] flag and is masked by the
QSPI_RSER[TFIE] bit.
42.5.3.10
TX Buffer Operation
The TX Buffer provides the data used for page programming. For proper operation it is
required to provide at least four entry in the TX Buffer prior to starting the execution of
the page programming command. The application must ensure that the required number
of data bytes is written into the TX Buffer fast enough as long as the command is
executed without a TX Buffer overflow or underrun.
The QuadSPI module sets the QSPI_FR[TBFF] flag so long as the TX Buffer is not full
and can accept more data.
When the QuadSPI module tries to pull data out of an empty TX Buffer the TX Buffer
underrun is signaled by the QSPI_FR[TBUF] flag.The TX buffer underrun flag is also
asserted when TX buffer contains less than 128 bits of data and QuadSPI module tries to
pull out data from it. The current IP Command leading to the underrun condition is
continued until the specified number of bytes has been sent to the serial flash device, in
the underrun condition when QuadSPI module tries to pull out data of empty TX buffer,
the data transferred is all F's i.e. once the underrun flag is set under this condition, it will
return F's until the required number of bytes are not sent. This has been done to ensure
that the software need not to erase whole sector after underrun, just reprogramming from
failure point will serve the purpose. When this Sequence Command is finished, the
QSPI_FR[TBFF] flag is asserted indicating that the Tx Buffer is ready to be written
again.
The TX Buffer overflow isn't signaled explicitly, but the TX Buffer fill level can be
monitored by the QSPI_TBSR[TRBFL] field.
Refer to TX Buffer Status Register (QuadSPI_TBSR) and Flag Register (QuadSPI_FR)
for details about the TX Buffer related registers.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3000
NXP Semiconductors

<!-- page 3001 -->

42.5.3.11
Address scheme
Earlier serial flash memories supported only 24-bit address space hence restricting the
maximum memory size of the serial flash as 16 MB. The new memory specification
supports two types of 32-bit addressing mode in addition to legacy 24-bit address mode.
• Extended Address Mode
In this mode, the legacy 24-bit commands are converted to accept 32-bit address
commands. The flash memory needs to be configured for 32-bit address mode. Also,
while programming the LUT sequence in QuadSPI for 32-bit mode, the ADDR and
ADDR_DDR command should be programmed with 8’d32 as the operand value. By
default, the QuadSPI is in 24-bit legacy address mode. Each of the memory vendors
have a different way of enabling this mode (Refer to the memory specification from
memory vendors). For example, the command B7h sent to Macronix flash will
enable it for 32-bit address mode.
• Extended Address register
In this mode, the upper 8-bit of the 32-bit address is provided by the Extended
address register in the memory itself. The memory provides a specific register which
is updated according to the address to be accessed. This effectively converts the
legacy 24-bit address command into 32-bit address commands. The memories greater
in size than 16 MB, consists of banks of 16 MB. The 8-bit written in the extended
address register effectively enables a bank. For example in Spansion memory, when
the extended address register is updated with a value of 0x01 with the help of the
command 17h, it will open Bank1 of the memory. The consequent 24-bit address
commands will lead to Bank1. The extended address register needs to be update with
the respective value for access to other banks. This effectively converts the legacy
24-bit address command into 32-bit address commands.
42.6
Initialization/Application Information
This section provides the initialization and application information of the QuadSPI
module.
42.6.1
Power Up and Reset
Note that the serial flash devices connected to the QuadSPI module may require special
voltage characteristics of their inputs during power up or reset. It is the responsibility of
the application to ensure this.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3001

<!-- page 3002 -->

42.6.2
Available Status/Flag Information
This paragraph gives an overview of the different status and flag information available
and their interdependencies for different use cases. Related registers are QSPI_SR and
QSPI_FR. Refer to the related descriptions how to set up the QuadSPI module
appropriately.
42.6.2.1
IP Commands
Refer to IP Configuration Register (QuadSPI_IPCR) for additional details not explicitly
covered in this paragraph.
• IP Commands - Normal Operation
Writing the QSPI_IPCR[SEQID] field triggers the execution of a new IP Command.
Given that this is a legal command the QSPI_SR[IPACC] and the QSPI_SR[BUSY]
bits are asserted simultaneously, immediately after the execution is started.
When the instruction on the serial flash device has been finished these bits are de-
asserted and the QSPI_FR[TFF] flag is set.
• IP Commands - Error Situations
Refer to Table 42-20 below.
42.6.2.2
AHB Commands
Refer to Section 1, Reading Serial Flash Data into the QuadSPI Module, in Flash Read
for additional details not explicitly covered in this paragraph.
• AHB Commands - Normal Operation
Memory mapped read access to a serial flash address not contained in the AHB
Buffer, triggers the execution of an AHB Command. Given that this is a legal
command the QSPI_SR[AHBACC] and the QSPI_SR[BUSY] bits are asserted
simultaneously immediately after the execution is started. When the instruction on
the serial flash device has been finished these bits are de-asserted.
• IP Commands - Error Situations
Refer to Table 42-20 below.
Initialization/Application Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3002
NXP Semiconductors

<!-- page 3003 -->

42.6.2.3
Overview of Error Flags
The following table gives an overview of the different error flags in the QSPI_FR register
and additional error-related details.
Table 42-20. Overview of QSPI_FR Error Flags
Error Category
Error Flag in
QSPI_FR
Command Execution on Serial Flash
Device
TFF Behavior (in case of IP commands
only)
Description
AHB Error Flag
ABSEF
Flash transaction is aborted
AHB sequence contains
• WRITE instruction
• WRITE_DDR instruction
AHB Error Flag
ABOF
Flash transaction continues until it finishes
Set when the module tried to push
data into the AHB buffer that
exceeded the size of the AHB buffer.
Only occurs due to wrong
programming of the
QSPI_BUFxCR[ADATSZ].
Miscellaneous Error
Flag
DLPFF1
Flash transaction continues until it finishes
Set when DATA_LEARN instruction
was encountered in a sequence but
no sampling point was found for the
data learning pattern.
Miscellaneous Error
Flag
ILLINE
Flash transaction aborted
Illegal instruction Error Flag – Set
when an illegal instruction is
encountered by the controller in any
of the sequences.
Command Arbitration
Error
IPIEF
TFF not asserted in conjunction with that
command
IP Command Error - caused when
IP access is currently in progress
(IP_ACC set) and
• write attempt to QSPI_IPCR
register.
• write attempt to QSPI_SFAR
register.
• write attempt to QSPI_RBCT
register.
Command Arbitration
Error
IPAEF
• AHB Command already
running, another IP Command
could not be executed.
• AHB Command already
running, write attempt to
QSPI_IPCR[SEQID] field.
Command Arbitration
Error
IPGEF
• Exclusive access to the serial
flash granted for AHB
Commands, write attempt to
QSPI_IPCR[SEQID] field.
IP Command Error
IUEF
—
• IP Command Usage Error
Table continues on the next page...
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3003

<!-- page 3004 -->

Table 42-20. Overview of QSPI_FR Error Flags
(continued)
Error Category
Error Flag in
QSPI_FR
Command Execution on Serial Flash
Device
TFF Behavior (in case of IP commands
only)
Description
Buffer Related Error
RBOF
TFF is asserted on completion
• RX Buffer Overrun
Buffer Related Error
TBUF
• TX Buffer Underrun
1.
Data learning is not implemented on this chip.
Note that only the buffer related errors are related to a transaction on the external serial
flash. All the other errors do not trigger an actual transaction.
42.6.2.4
IP Bus and AHB Access Command Collisions
There are two flags related to this topic, the QSPI_FR[IPAEF] and QSPI_FR[IPIEF].
Refer to sub-section "Reading Serial Flash Data into the QuadSPI Module" of Flash
Read section, for a description of the flags and Command Arbitration , for details about
possible command collisions.
42.6.3
Exclusive Access to Serial Flash for AHB Commands
It is possible that several masters need to access the serial flash device connected to the
QuadSPI module separately, one master by triggering IP Commands and reading the RX
Buffer (via RBDRn register) and the other masters by triggering AHB Commands (via
ARDBn Registers). These two set of buffer (RBDR and ARDB Buffer) points to the
same physical buffer.Refer to Figure 42-6 To avoid command collisions resulting in
excessive latencies the QuadSPI module implements a request-handshake mechanism
between the master triggering AHB Commands and the QuadSPI module allowing this
specific master to request exclusive access to the serial flash device for AHB Commands.
If this exclusive access is granted the execution of IP Commands is blocked. This
resolves command collisions and excessive times where the AHB interface may be
blocked.
If this capability is used in the device there is additional status and flag information
available related to this mechanism. The QSPI_SR[AHBGNT] bit reflects the module-
internal state that the exclusive access mentioned above is granted, any attempt to trigger
an IP Command is rejected and results in the assertion of the QSPI_FR[IPGEF] flag.
Refer to the descriptions of the related bit and flag for details.
Initialization/Application Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3004
NXP Semiconductors

<!-- page 3005 -->

It is within the responsibility of the application to set up the master using this mechanism
appropriately, if used incorrectly no IP Commands at all can be triggered.
Two different cases can be distinguished:
42.6.3.1
RX Buffer Read via QSPI_ARDB Registers
In this case all masters share the AHB bus for RX Buffer as well as for AHB Buffer read.
In this case the access to the AHB interface by the master triggering AHB Commands
must be deferred until any pending IP Command has been finished and the RX Buffer
readout has been finished as well. The QSPI ARDB Buffers access the Rx buffer i.e the
data from the Rx Buffer is returned and no data from AHB Buffer is touched. This is the
conservative use case, corresponding to the reset value 0 of the QSPI_RBCT[RXBRD]
bit.
In this case the QSPI_SR[AHBGNT] bit is asserted not earlier than any running IP
Command has been finished (QSPI_SR[IP_ACC] is 0), the RX Buffer has been read out
completely (QSPI_RBSR[RDBFL] equal to 0) or no DMA read is pending
(QSPI_SR[RXDMA] equal to 0 and Rx Buffer readout is via
AHB(QSPI_RBCT[RXBRD]) equal to 1.
42.6.3.2
RX Buffer Read via QSPI_RBDR Registers
This is the preferred use case as an access to the AHB buffer (memory mapped flash)
does not interfere with any IPS access to read the RBDR buffer. It is not possible that a
pending AHB bus access triggered by an AHB Command stalls the AHB bus and blocks
the RX Buffer readout since the RX Buffer is read via the IP bus based registers
QSPI_RBDR0 to QSPI_RBDR31.
For this case it is recommended to program the QSPI_RBCT[RXBRD] bit to 1. The
QSPI_SR[AHBGNT] bit is asserted immediately after any running IP Command has
been finished (QSPI_SR[IP_ACC] is 0), the RX Buffer has been read out completely
(QSPI_RBSR[RDBFL] equal to 0) or no DMA read is pending (QSPI_SR[RXDMA]
equal to 0, allowing the master triggering AHB Commands to trigger AHB Commands as
soon as possible without the need to wait for the RX Buffer readout to be finished.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3005

<!-- page 3006 -->

42.6.4
Command Arbitration
In case of overlapping commands, the arbitration scheme is described in the following
paragraphs under the assumption that the priority mechanism described in Exclusive
Access to Serial Flash for AHB Commands is not used:
• During the execution of an IP Command, the running IP Command can't be
terminated by issuing another IP Command or AHB Command. The
QSPI_FR[IPIEF] flag is asserted when the host tries to write into the QSPI_IPCR
register. When the host triggers an AHB Command (refer to sub-section "Reading
Serial Flash Data into the QuadSPI Module" of Flash Read section, for details), this
command is stalled until the currently running IP Command is finished.
• During the execution of an AHB Command, the running AHB Command can't be
terminated by issuing an IP Command. The command is ignored and the
QSPI_FR[IPAEF] flag is asserted. Refer to Flag Register (QuadSPI_FR) for the
description of these flags.
When another AHB Command is triggered the address of the memory mapped access
is considered. If the requested address is currently read from the serial flash device,
the running command is continued. If this is not the case the currently running
command is terminated and another AHB Command related to the requested address
is executed. Refer to sub-section "Reading Serial Flash Data into the QuadSPI
Module" of Flash Read section, for further details.
In case of coinciding commands the IP Command is triggered and the AHB Command is
stalled until the IP Command has been finished (QSPI_SR[IP_ACC] has been
deasserted).
The IP Commands ignored in case of command collision will not result in the assertion of
the QSPI_FR[TFF] flag.
42.6.5
Flash Device Selection
Regardless of the SFM Command (IP or AHB) the access mode is selected by specifying
the 32 bit address value for the following SFM Command.
For IP Commands the access mode is selected with the address programmed into the
QSPI_SFAR register. Refer to Serial Flash Address Register (QuadSPI_SFAR) for
details.
For AHB Commands the access mode is determined by the memory mapped address
which is accessed Refer to AMBA Bus Register Memory Map for details.
Initialization/Application Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3006
NXP Semiconductors

<!-- page 3007 -->

42.6.6
DMA Usage
For the complete description of the DMA module refer to the related DMA Controller
chapter. In this paragraph only the details specific to the DMA usage related to the
QuadSPI module are given.
42.6.6.1
DMA Usage in Normal Mode
42.6.6.1.1
Bandwidth considerations
Careful consideration of the throughput rate of the entire chain (serial flash -> AHB bus /
IP Bus -> DMA controller) involved in the read data process is essential for proper
operation. Such analysis must take into account not only the data rate provided by the
serial flash but also the data rate of the AHB bus and the performance of the DMA
controller in reading data from the RX buffer.
Two figures must match for proper operation, that means that the data rate provided by
the serial flash device must not exceed the average RX Buffer readout data rate.
Otherwise, the longer this state persists, a RX Buffer overflow will result.
AHB Bus Side (data read):
The total number of bus cycles for each DMA Minor Loop completion is added from the
following components:
• Overhead for each minor loop, given by DMA controller: Assume 10 cycles
• Overhead due to clock domain crossing: Assume 2 cycles
• Number of bus clock cycles required for 8 bytes (64 bit read size): Assume 2 cycles
(read/write sequence of DMA controller)
Note that the size of the minor loop is determined by the size of the
QSPI_RBCT[WMRK] field, therefore the overhead given above distributes among
(QSPI_RBCT[WMRK]+1)/2 read accesses of 64 bit each.
The following table gives some examples for typical use cases:
Table 42-21. Access Duration Examples - Bus Clock Side
QSPI_RBCT[WMRK]
Number of Bytes per DMA
Loop 1
Number of Bus Clock
cycles for DMA Minor Loop
Time Duration of DMA
Minor Loop for 120Mhz Bus
clock Frequency
0
4
12+2 = 14
~117ns
Table continues on the next page...
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3007

<!-- page 3008 -->

Table 42-21. Access Duration Examples - Bus Clock Side (continued)
QSPI_RBCT[WMRK]
Number of Bytes per DMA
Loop 1
Number of Bus Clock
cycles for DMA Minor Loop
Time Duration of DMA
Minor Loop for 120Mhz Bus
clock Frequency
1
8
12+2 = 14
~117ns
3
16
12+4 = 16
~133ns
7
32
12+8 = 20
~167ns
11
48
12+12 = 24
~200ns
1.
DMA Loop means one Minor Loop Completion which is equivalent to one.
NOTE
The table figure represents ideal scenario, actual performance
will depend on how the system is integrated.
Serial Flash Device Side (data read):
The number of serial flash cycles can be determined in the following way:
• Number of serial flash clock cycles required to read 4 bytes, corresponding to one
RX Buffer entry (setup of command and address not considered): 2 cycles for Quad
DDR mode instructions in Parallel Flash Mode, 4 cycles for Quad (SDR) mode
instruction in parallel flash mode or Dual IO DDR mode instruction in parallel flash
mode, 8 cycles for Quad Mode (SDR) instructions in Individual Flash Mode etc.
• Overhead due to clock domain crossing : 1 cycle.
The following table lists the number of clock cycles required to read the data from the
serial flash corresponding to the different settings of the QSPI_RBCT[WMRK] field:
Table 42-22. Access Duration Examples - Serial Flash side
QSPI_RBCT[
WMRK]
setting
Num Bytes
per DMA
Loop 1
Num SCKFx for 60MHz SCKFx
Time duration of Flash data readout for
60MHz SCKFx (~16.6ns period)
IFM 2 Quad
IFM Quad
DDR
PFM 3 Quad
DDR
IFM Quad
IFM Quad
DDR
PFM Quad
DDR
0
4
9
5
3
~150ns
~83ns
~50ns
1
8
17
9
5
~282ns
~150ns
~83ns
3
16
33
17
9
~548ns
~282ns
~150ns
7
32
65
33
17
~1079ns
~548ns
~282ns
11
48
97
49
25
~1610ns
~813ns
~415ns
1.
DMA Loop means one Minor loop completion which is equivalent to one Major Loop iteration.
2.
Individual flash mode.
3.
Parallel flash mode.
Initialization/Application Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3008
NXP Semiconductors

<!-- page 3009 -->

From the examples given in the two tables above, it can be seen that depending on the
relationship between the Bus clock and Serial flash clock frequencies, there are settings
possible where the serial flash provides the read data faster than the AHB bus can read
out the RX buffer. In the above tables, it is the case of PFM Quad DDR mode with
Watermark up to 3 and other cases. In these cases, the RX buffer data keeps
accumulating over time and will eventually overflow. To avoid RX Buffer overflow, the
data transaction size should be small enough.
A complementary example would be when the watermark is set to be too high. In such a
case, the time taken by the DMA to read out the RX buffer entries should be smaller than
the time taken by the controller to push in the remaining entries in the buffer.
NOTE
The tables mentioned above are only examples which must be
correlated with the DMA in the system.
42.6.7
Parallel mode
QuadSPI can access two flashes in parallel. This increases the throughput of the QuadSPI
by two times. Only read operations are allowed in parallel mode. In case a write
transaction is initiated in parallel mode, QSPI_FR[IUEF] is set. When dual die flashes are
accessed in parallel mode, it is mandatory for flash A1 to be of the same size as B1 and
A2 to be of the same size as B2. The following figure shows how QuadSPI maps the
incoming addresses to the different flashes connected on board.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3009

<!-- page 3010 -->

Figure 42-7. Flash addressing
An example programming for parallel mode access is given below (flash sizes are
assumed to be 256MB):
• QSPI_AMBA_BASE - 0x10000000
• QSPI_SFA1AD[TPADA1] - 0x20000000
• QSPI_SFA2AD[TPADA2] - 0x30000000
• QSPI_SFB1AD[TPADB1] - 0x40000000
• QSPI_SFB2AD[TPADB2] - 0x50000000
In order to access the first location of A1/B1 pair, the incoming address should be
0x10000000. QSPI_AMBA_BASE is subtracted from this address and the result is
divided by two. Therefore, address provided to flash A1 and B1
Flash Address = (Memory mapped address - QSPI_AMBA_BASE)/2
For Memory Mapped address:
• 0x10000000, flash address: 0x0 (Or, the first address of flash A1 and B1)
• 0x10000004, flash address: 0x2
• 0x10000008, flash address: 0x4 etc.
Similarly, in order to access the first location of A2/B2 pair, the incoming address should
be 0x30000000.
Flash Address = (Memory mapped address - SFA2AD)/2
Initialization/Application Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3010
NXP Semiconductors

<!-- page 3011 -->

For Memory Mapped address:
• 0x30000000, flash address: 0x0 (Or, the first address of flash A2 and B2)
• 0x30000004, flash address: 0x2
• 0x30000008, flash address: 0x4 etc.
Figure 42-8. Memory map - Serial and Parallel
42.7
Byte Ordering - Endianness
QuadSPI provides support for swapping the flash read/write data based on the
configuration of the QSPI_MCR[END_CFG]. By default the data is always returned in
64 bit LE format on the AHB bus and 32 bit LE format on the IPS interface when read
via the RX buffer and written in 32 bit LE format when written via the TX buffer.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3011

<!-- page 3012 -->

The table(QSPI_MCR[END_CFG]) below shows the complete bit ordering. BE signifies
Big Endian which means the high order bits of the associated data vectors are associated
with low order address positions. LE signifies Little Endian which means the lower order
bits of the associated data vectors are associated with low order address positions.Refer to
figure Figure 42-6
Table 42-23. QSPI_MCR[END_CFG]
00
64 bit BE
01
32 bit LE
10
32 bit BE
11
64 bit LE
The tables below (Byte ordering configuration in AHB) and (Byte ordering configuration
in IPS) show how this configuration is implemented in QSPI AHB and IPS interfaces
respectively. B in the table signifies Byte and the index 1-8 refers to the byte position i.e.
1 refer to bits[7:0], 8 refer to bits[63:56] and so on.
Table 42-24. Byte ordering configuration in AHB
64 bit BE
B1
B2
B3
B4
B5
B6
B7
B8
64 bit LE
B8
B7
B6
B5
B4
B3
B2
B1
32 bit BE
B5
B6
B7
B8
B1
B2
B3
B4
32 bit LE
B4
B3
B2
B1
B8
B7
B6
B5
Table 42-25. Byte ordering configuration in IPS
32BE
B1
B2
B3
B4
32LE
B4
B3
B2
B1
The examples below show the byte ordering in 64 bit BE configuration for AHB Buffer
and 32 bit BE for TX/RX Buffer:
42.7.1
Programming Flash Data
CPU write instructions to the QSPI_TBDR register like
• Write QSPI_TBDR -> 0x01_02_03_04
• Write QSPI_TBDR -> 0x05_06_07_08
result in the following content of the TX Buffer:
Byte Ordering - Endianness
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3012
NXP Semiconductors

<!-- page 3013 -->

Table 42-26. Example of QuadSPI TX Buffer
TX Buffer Entry
Content
0
32'h01_02_03_04
1
32'h05_06_07_08
Programming the TX Buffer into the external serial flash device results in the following
byte order to be sent to the serial flash:
• 01…02…03…04…05…06…07…08
42.7.2
Reading Flash Data into the RX Buffer
Reading the content from the same address provides the following sequence of bytes,
identical to the write case:
• 01…02…03…04…05…06…07…08
This results in the RX Buffer filled with:
Table 42-27. Resulting RX Buffer Content
RX Buffer Entry
Content
0
32'h01_02_03_04
1
32'h05_06_07_08
42.7.2.1
Readout of the RX Buffer via QSPI_RBDRn
The RX Buffer content appears at CPU read access via the Peripheral bus interface in the
following order:
• Read QSPI_RBDR0 <- 0x01_02_03_04
• Read QSPI_RBDR1 <- 0x05_06_07_08
42.7.2.2
Readout of the RX Buffer via ARDBn
The RX Buffer content appears at read access on the AMBA AHB interface at the
QuadSPI module boundary:
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3013

<!-- page 3014 -->

• (1a): 32 Bit Access: Read QSPI_ARDB0 <- 0x01_02_03_04
• (2a): 32 Bit Access: Read QSPI_ARDB1 <- 0x05_06_07_08
• (1b/2b): 64 Bit Access: Read QSPI_ARDB0 <- 0x01_02_03_04_05_06_07_08
42.7.3
Reading Flash Data into the AHB Buffer
Reading the content from the same address as it was written to provides the following
sequence of bytes, identical to the write case:
• 01…02…03…04…05…06…07…08
This results in the AHB Buffer filled with:
Table 42-28. Resulting AHB Buffer Content
AHB Buffer Entry
Content
0
64'h01_02_03_04_05_06_07_08
42.7.3.1
Readout of the AHB Buffer via Memory Mapped Read
The AHB Buffer content appears at read access on the AMBA AHB interface at the
QuadSPI module boundary:
• (1a): 32 Bit Read Access: <- 0x01_02_03_04
• (2a): 32 Bit Read Access: <- 0x05_06_07_08
• (1/2): 64 Bit Read Access: <- 0x01_02_03_04_05_06_07_08
42.8
Serial Flash Devices
Several different vendors make flash devices with a QuadSPI interface. At present there
is no set standard for the QuadSPI instruction set. Most common commands currently
have the same instruction code for all vendors, however some commands are unique to
specific vendors. Some example sequences are provided below.
Serial Flash Devices
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3014
NXP Semiconductors

<!-- page 3015 -->

42.8.1
Example Sequences
This section provides the example sequences of the QuadSPI module.
Table 42-29. Exit 4 x I/O Read Enhance Performance Mode (XIP) (Macronix) and Read
Status
INSTR
PAD
OPERAND
COMMENT
CMD
0x0
0xEB
4xIO Read Command
ADDR
0x2
0x18
24 Bit address to be send on
4 pads
MODE
0x2
0x00
2 mode cycles (exit XIP)
DUMMY
0x0
0x04
4 dummy cycles
READ
0x2
0x08
Read 64 bits
CMD
0x0
0x05
Read Status register
READ
0x0
0x01
Status register data
STOP
0x0
0x00
STOP, Instruction over
42.8.1.1
Fast Read Sequence (Macronix/Numonyx/Spansion/
Winbond)
The following table shows the fast read sequence for Macronix/Numonyx/Spansion/
Winbond flashes.
Table 42-30. Fast Read sequence
Instruction
Pad
Operand
Comment
CMD
0x0
0x0B
Fast Read command = 0x0B
ADDR
0x0
0x18
24 Addr bits to be sent on one pad
DUMMY
0x0
0x08
8 Dummy cycles
READ
0x0
0x04
Read 32 Bits on one pad
JMP_ON_CS
0x0
0x00
Jump to instruction 0 (CMD)
42.8.1.2
Fast Dual I/O DT Read Sequence (Macronix)
The following table shows the Fast Dual I/O DT read sequence for Macronix flashes.
Table 42-31. Fast Dual I/O DT Read sequence
Instruction
Pad
Operand
Comment
CMD
0x0
0xBD
Fast Dual I/O DT read command = 0xBD
Table continues on the next page...
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3015

<!-- page 3016 -->

Table 42-31. Fast Dual I/O DT Read sequence (continued)
Instruction
Pad
Operand
Comment
ADDR_DDR
0x1
0x18
24 Addr bits to be sent on 2 pads in DDR mode
MODE4_DDR
0x1
0x00
P2=P0 or P3=P1 is necessary. Refer to Macronix
datasheet for details. One clock cycle for mode.
DUMMY
0x0
0x06
6 Dummy cycles
READ_DDR
0x1
0x04
Read 32 Bits on 2 pads in DDR mode
JMP_ON_CS
0x0
0x00
Jump to instruction 0 (CMD)
42.8.1.3
Fast Read Quad Output (Winbond)
The following table shows the Fast read quad output sequence for Winbond memories
Table 42-32. Fast Read Quad output sequence
Instruction
Pad
Operand
Comment
CMD
0x0
0x6B
Fast read quad output command = 0x6B
ADDR
0x0
0x18
24 Addr bits to be sent on 1 pad
DUMMY
0x0
0x08
8 Dummy cycles
READ
0x2
0x04
Read 32 Bits on 4 pads
JMP_ON_CS
0x0
0x00
Jump to instruction 0 (CMD)
42.8.1.4
4 x I/O Read Enhance Performance Mode (XIP) (Macronix)
The following table shows the 4 x I/O Read Enhance Performance Mode for Macronix
flashes. The enhanced performance mode is also known as XIP mode.
Table 42-33. Fast Read Quad output sequence
Instruction
Pad
Operand
Comment
CMD
0x0
0xEB
4xI/O Read command = 0xEB
ADDR
0x2
0x18
24 Addr bits to be sent on 4 pads
MODE
0x2
0xA5
2 mode cycles
DUMMY
0x0
0x04
4 Dummy cycles
READ
0x2
0x04
Read 32 Bits on 4 pads
JMP_ON_CS
0x0
0x01
Jump to instruction 1 (ADDR)
When in XIP mode the software should ensure that all the flashes connected to the
controller are in XIP mode. As a part of initializing the controller, all the flashes may be
enabled with XIP by carrying out dummy reads.
Serial Flash Devices
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3016
NXP Semiconductors

<!-- page 3017 -->

42.8.1.5
Dual Command Page Program (Numonyx)
The following table shows the Dual command page program sequence for Numonyx
flashes.
Table 42-34. Dual Command Page Program sequence
Instruction
Pad
Operand
Comment
CMD
0x1
0x02
Dual command page program = 0x02 on 2 pads
ADDR
0x1
0x18
24 Addr bits to be sent on 2 pads
WRITE
0x1
0x20
Write 32 Bytes on 2 pads
STOP
0x0
0x00
STOP, Instruction over
42.8.1.6
Sector Erase (Macronix/Spansion/Numonyx)
The following table shows the Sector erase sequence for Macronix/Spansion/Numonyx
flashes
Table 42-35. Sector Erase sequence
Instruction
Pad
Operand
Comment
CMD
0x0
0xD8
Sector erase command = 0xD8
ADDR
0x0
0x18
24 Addr bits to be sent on 1 pad
STOP
0x0
0x00
STOP, Instruction over
42.8.1.7
Read Status Register (Macronix/Spansion/Numonyx/
Winbond)
The following table shows the Read status register sequence for Macronix/Spansion/
Numonyx/Winbond flashes.
Table 42-36. Read Status Register Sequence
Instruction
Pad
Operand
Comment
CMD
0x0
0x05
Read status register command = 0x05
READ
0x0
0x01
Read status register data
STOP
0x0
0x00
STOP, Instruction over
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3017

<!-- page 3018 -->

42.8.2
Dual Die Flashes
Certain serial flash vendors provide dual-die packages which are essentially two devices
(dies) stacked within the same package to increase the memory capacity of a single
package. These two devices within a package share the same data and clock pins, but
have individual Chip Selects. QuadSPI controller provides support for two dual-die
packages to be connected simultaneously. The figure below shows the two dual-die
packages and the naming conventions used in this document. For simplicity, the data pins
are shown to be unidirectional.
QuadSPI
QSPI_A_SS0_B
QSPI_A_SCLK
QSPI_A_DATA[3:0]
QSPI_A_SS1_B
Dual-die package1
Flash A1
Flash A2
Flash B1
Flash B2
Dual-die package2
QSPI_B_SS0_B
QSPI_B_SCLK
QSPI_B_DATA[3:0]
QSPI_B_SS1_B
Figure 42-9. Dual-die support
Since the two devices within one package share the same i/o pads, they cannot function in
parallel mode. Software should ensure that when QuadSPI is configured in parallel mode
the two selected flash devices are from different dual-die packages.
42.8.3
Boot initialization sequence
The following are the recommended sequence of steps for booting from QuadSPI:
• System out of reset and flash available (300us)
Serial Flash Devices
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3018
NXP Semiconductors

<!-- page 3019 -->

• Clocks still at very low frequency. Clock tree configured, I/O pins configured. First
request sent to QuadSPI for address 0x0 of flash.
• The reset command sequence in QuadSPI has 0x03 (basic read command) which is
applicable to all flashes at < 50MHz serial flash clock
• The first few bytes of data is read from the flash which contains the following
information:
• The total sizes of all the flashes connected on board
• Whether DDR mode supported
• Frequency of DDR operation
• Continuous mode entry sequence
• 24bit or 32bit addressing (assuming 24bit for first accesses)
• All the serial flashes are configured
• Quad Mode enabled
• Dummy reads to enter into XIP
• QuadSPI is configured
• Parallel enable set
• LUT configured for highest performance reads
• DDR mode enabled (if applicable)
• Buffers configured
• Serial flash clock frequency increased.
• Boot reads happen in parallel, DDR enabled, quad output mode @66MHz.
42.9
Sampling of Serial Flash Input Data
42.9.1
Internal Sampling of Serial Flash Input Data
Depending from the actual implementation there is a delay between the internal clocking
in the QuadSPI module and the external serial flash device.Refer to the following figure
for an overview of this scheme.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3019

<!-- page 3020 -->

QUADSPI
Clock Gen
Sampling
Serial Flash
Clock
Data 
Out
SCK - Serial Flash Clock
SI_IO[0:3] - Serial Flash Data
1
5
2
4
3
Figure 42-10. Serial Flash Sampling Clock Overview
Note
The arrival of the serial flash data in the sampling stage of the
QuadSPI module are given in the following figure. Note that
the amount of the total delay tDel,total is very specific to the
characteristics of the actual implementation.
Note also that the serial flash device clock SCK is inverted with
respect to the QuadSPI internal reference clock.
internal reference for serial flash data sampling
internal ref clock
SCK - serial flash clock
serial flash data
tDel,total 
Possible Sampling Points
N/1
N/2
I/2
I/1
Figure 42-11. Serial Flash Sampling Clock Timing
The rising edge of the internal reference clock is taken as timing reference for the data
output of the serial flash. After a time of tDel,total the data arrive at the internal sampling
stage of the QuadSPI module.
According to the Serial Flash Sampling Clock Overview figure, the following parts of the
delay chain contribute to tDel,total:
Sampling of Serial Flash Input Data
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3020
NXP Semiconductors

<!-- page 3021 -->

1. Output delay of the serial flash clock output of the device containing the QuadSPI
module
2. Wire delay of application/PCB from the device containing the QuadSPI module to
the external serial flash device
3. Clock to data out delay of the external serial flash device, including input and output
delays
4. Wire delay of application/PCB from the external serial flash device to the device
containing the QuadSPI module
5. Input delay belonging to the data in input
The possible points in time for the sampling of the incoming data are denoted as N/1, I/1,
N/2 and I/2 above. The sampling point relevant for the internal sampling is configured in
the QSPI_SMPR register, refer to Sampling Register (QuadSPI_SMPR) for details. Note
that the falling edges of the reference clock are not actually used, instead the inverted
clock is used for sampling at these positions. The following table gives an overview of
the available configurations for the commands running at regular (full) speed:
Table 42-37. Sampling Configuration
Sampling Point
Description
Delay
[FSDLY]
[HSDLY]
Phase
[FSPHS]
[HSPHS]
QSPI_SMPR for
Full Speed
Setting1
N/1
sampling with non-inverted clock, 1 sample delay 0
0
0x0000000x
I/1
sampling with inverted clock, 1 sample delay
0
1
0x0000002x
N/2
sampling with non-inverted clock, 2 samples
delay
1
0
0x0000004x
I/2
sampling with inverted clock, 2 samples delay
1
1
0x0000006x
1.
'x' is not considered here
Depending from the actual delay and the serial flash clock frequency the appropriate
sampling point can be chosen. The following remarks should be considered when
selecting the appropriate setting:
• Theoretically there should be 2 settings possible to capture the correct data since the
serial flash output is valid for 1 clock cycle, disregarding rise and fall times and
timing uncertainties.
• Depending from the timing uncertainties it may turn out in actual applications that
only one possible sample positions remains. This is subject to careful consideration
depending from the actual implementation.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3021

<!-- page 3022 -->

• The delay tDel,total is an absolute size to shift the point in time when the serial flash
date get valid at the QuadSPI input.
• For decreasing frequency of the serial flash clock the distance between the edges
increases. So for large differences in the frequency the required setting may change.
• For commands running at half of the regular serial flash clock
(QSPI_SMPR[HSENA] bit set) the sampling point must be figured separately to
allow for the compensation of the absolute shift in time with respect to the sample-
relative setting in the QSPI_SPMPR register.
42.9.2
DDR Mode
The increasing requirement of improved throughput has introduced the double data rate
(DDR) mode. In DDR mode, the data is transferred on both the rising and falling edges of
the serial flash clock. The DDR serial flashes sample as well as drive the data on both
rising and falling edges of serial flash clock.
42.10
Serial Flash Data Input Timing
There are sampling modes for input flash data:
• Internal sampling - Input serial flash data is captured by internal serial clock. In SDR
mode, serial data is sampled by serial clock 1x (ser_clk_1x) rise edge. In DDR mode,
serial data is sampled by serial clock 4x (ser_clk_4x) rise edge.
• Loopback DQS sampling - Soc will output serial data strobe with internal serial
clock. This serial data strobe would be loopback from pad and used to sample input
serial data. In SDR mode, serial data is sampled by loopback DQS rise edge. In DDR
mode, serial data is sampled by loopback DQS both edge
NOTE
DQS pad need to be set to force input for loopback.
• Flash DQS sampling - Some serial Flash device provide the data strobe output
together with serial data. This strobe signal is used to sample input serial data
directly. In SDR mode, serial data is sampled by Flash DQS rise edge. In DDR
mode, serial data is sampled by Flash DQS both edge
Following table shows selection for sampling mode:
Sampling mode
DQS_EN
DQS_LOOPBACK_EN
Internal sampling
0
doesn't matter
Table continues on the next page...
Serial Flash Data Input Timing
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3022
NXP Semiconductors

<!-- page 3023 -->

Sampling mode
DQS_EN
DQS_LOOPBACK_EN
Loopback DQS sampling
1
1
Flash DQS sampling
1
0
Serial flash data and clock path for input timing is shown in the following figure.
quadspi
ser_clk_4x
SCLK - Serial Flash Clock
Clock
Serial Flash
Data 
Output
SIO[3:0] - Serial Flash Data
Sampling
DQS
sampling
 clock
 selection
Clock 
generation
ser_clk_1x
Data
Strobe
Output
ser_clk_4x
ser_clk_1x
dqs_clk
dqs_output
sclk_output
Figure 42-12. Serial flash data and clock path
NOTE
The red line is for data input path, the blue line is for DQS
loopback path, and the purple line is for DQS input path from
Serial Flash.
Total delay (Ttotal_delay_data) for serial flash data input is the sum of following delay:
1. Output delay of serial flash clock from internal serial clock to SCLK pad inside SOC
2. Wire delay of serial flash clock (SCLK) from SOC to external Serial Flash Device
3. Clock to Output Valid time of external Serial Flash Device
4. Wire delay of serial flash data (SIO) from external serial Flash Device to SOC
5. Input delay of serial flash data from SIO pad to internal sample register
Total delay (Ttotal_delay_loopback_dqs) for loopback DQS clock is the sum of
following delay:
1. Output delay of DQS clock from internal serial clock to DQS pad inside SOC
2. Input delay of DQS clock from DQS pad to internal sample register
Total delay (Ttotal_delay_flash_dqs) for Flash DQS clock is the sum of following delay:
1. Output delay of serial flash clock from internal serial clock to SCLK pad inside SOC
2. Wire delay of serial flash clock (SCLK) from SOC to external Serial Flash Device
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3023

<!-- page 3024 -->

3. Clock to DQS Output time of external Serial Flash Device
4. Wire delay of serial flash data strobe (DQS) from external serial Flash Device to
SOC
5. Input delay of DQS clock from DQS pad to internal sample register
42.10.1
Input timing in SDR mode with internal sampling
Input Timing diagram in SDR mode with internal sampling is show in the figure below.
ser_clk_1x
SCK - serial flash clock
serial flash data
Ttotal_delay_data
QSPI_SMPR[SDRSMP]
2
1
0
3
Figure 42-13. Internal sample SDR
There are four sample points for this sampling mode, which is determined by register
field QSPI_SMPR.SDRSMP.
Sampling point need to be select correctly to meet both Setup and Hold timing for
internal sample registers:
• For sample point N, Setup requirement is: Tcycle*(N+2)/2>Ttotal_delay_data,max
• For sample point N, Hold requirement is: Ttotal_delay_data,min>Tcycle*N/2
NOTE
Tcycle is the cycle of ser_clk_1x. Ttotal_delay_data,max is
maximum delay of serial data input path. Ttotal_delay_data,min
is the minimum delay of serial data input path. N=0,1,2,3
42.10.2
Input timing in DDR mode with internal sampling
Input Timing diagram in SDR mode with internal sampling is show in the following
figure.
Serial Flash Data Input Timing
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3024
NXP Semiconductors

<!-- page 3025 -->

QSPI_SMPR[DDRSMP]
2
1
0
3 4 5 6 7
ser_clkk_1x
SCK - serial flash clock
serial flash data
ser_clk_4x
Ttotal_delay_data
There are 8 sample points for this sampling mode, which is determined by register field
DDRSMP.
Sampling point need to be select correctly to meet both Setup and Hold timing for
internal sample registers:
• For sample point N, Setup requirement is: Tcycle * (N+2)/8 >Ttotal_delay_data,max
• For sample point N, Hold requirement is: Ttotal_delay_data,min> Tcycle * N/8
42.10.3
Input timing in SDR mode with loopback DQS sampling
Input Timing diagram in SDR mode with internal sampling is show in the following
figure.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3025

<!-- page 3026 -->

ser_clk_1x
SCK - serial flash clock
serial flash data
Ttotal_delay_data
sample point
DQS- serial flash data strobe
launch clock
Figure 42-14. Input timing in SDR mode with loopback DQS sampling
In SDR mode and loopback sampling mode, DQS_PHASE_EN should be set 1.
For this sample point, the Setup requirement is: Tcycle >max(Ttotal_delay_data-
Ttotal_delay_loopback_dqs). The Hold requirement is: min(Ttotal_delay_data-
Ttotal_delay_loopback_dqs)> 0.
42.10.4
Input timing in DDR mode with loopback DQS sampling
Input Timing diagram in DDR mode with internal sampling is show in the following
figure.
Serial Flash Data Input Timing
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3026
NXP Semiconductors

<!-- page 3027 -->

ser_clk_1x
SCK - serial flash clock
serial flash data
Ttotal_delay_data
sample point
DQS- serial flash data strobe
launch clock
Figure 42-15. Input timing in DDR mode with loopback DQS sampling
In DDR mode and loopback sampling mode, DQS_PHASE_EN should be set 0.
For this sample point, the Setup requirement is: Tcycle >max(Ttotal_delay_data-
Ttotal_delay_loopback_dqs). The Hold requirement is: min(Ttotal_delay_data-
Ttotal_delay_loopback_dqs)> 0.
42.10.5
Input timing in SDR mode with flash DQS sampling
Input Timing diagram in SDR mode with internal sampling is show in the following
figure.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3027

<!-- page 3028 -->

ser_clk_1x
SCK - serial flash clock
serial flash data
Ttotal_delay_data
sample point
DQS- serial flash data strobe
launch clock
Figure 42-16. Input timing in SDR mode with flash DQS sampling
In this sampling mode, there will be a setup/hold requirement on Flash serial Data and
Flash serial Data Strobe. This value will be specified in the data sheet.
42.10.6
Input timing in DDR mode with flash DQS sampling
Input Timing diagram in DDR mode with internal sampling is show in the following
figure.
ser_clk_1x
SCK - serial flash clock
serial flash data
Ttotal_delay_data
sample point
DQS- serial flash data strobe
launch clock
Figure 42-17. Input timing in DDR mode with flash DQS sampling
Serial Flash Data Input Timing
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3028
NXP Semiconductors

<!-- page 3029 -->

In this sampling mode, there will be a setup/hold requirement on Flash serial Data and
Flash serial Data Strobe. This value will be specified in the data sheet.
42.10.7
Data Strobe Signal functionality
Some external serial flashes provide the data strobe (DQS/RDS) output which is fed
directly to the QuadSPI module. The strobe (DQS/RDS) signal needs to be delayed to
have the edges aligned to the data valid period. QuadSPI internally samples the incoming
data at posedge of the strobe signal for SDR and on both the edges of the strobe signal for
DDR. Refer to the figure for more detail.
Internal Ref 
clock
SCK
Data Strobe Signal*
* DQS for Macronix and RDS for Spansion
Data
internal reference for serial flash data sampling
Data sampled on both the edges of Data Strobe Signal
Figure 42-18. Data strobe signal functionality
42.11
Output timing in SDR mode
Output timing diagram in SDR mode is show in the following figure.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3029

<!-- page 3030 -->

ser_clk_1x
SCK - serial flash clock
serial flash data
Tdata_out_setup
Tdata_out_hold
Figure 42-19. Output timing in SDR mode
In SDR mode, quadspi output serial data with internal serial clock rise edge 1x
(ser_clk_1x). Flash Device has requirement on Data and Clock setup and hold timing.
42.12
Output timing in DDR mode
Output Timing diagram in DDR mode is show in the following figure.
ser_clk_4x
SCK - serial flash clock
serial flash data
Tdata_out_setup
Tdata_out_hold
ser_clk_1x
Figure 42-20. Output timing in DDR mode
In DDR mode, quadspi output serial data with internal serial clock both edge 1x
(ser_clk_1x) and then delay one ser_clk_4x cycle for hold timing.
Output timing in DDR mode
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3030
NXP Semiconductors

<!-- page 3031 -->

NOTE
TX_DDR_DELAY_EN should be set to 1 for DDR mode.
AHB RX Data Buffer (QSPI_ARDB0 to QSPI_ARDB31)
AHB RX Data Buffer (QSPI_ARDB0 to QSPI_ARDB31)
NOTE
See the System Memory map in this document for the base
address of the QSPI AHB RX Data Buffer.
memory map
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
0
AHB RX Data Buffer register (ARDB0)
32
R/W
0000_0000h
42.13.1.1/
3031
4
AHB RX Data Buffer register (ARDB1)
32
R/W
0000_0000h
42.13.1.1/
3031
8
AHB RX Data Buffer register (ARDB2)
32
R/W
0000_0000h
42.13.1.1/
3031
C
AHB RX Data Buffer register (ARDB3)
32
R/W
0000_0000h
42.13.1.1/
3031
10
AHB RX Data Buffer register (ARDB4)
32
R/W
0000_0000h
42.13.1.1/
3031
14
AHB RX Data Buffer register (ARDB5)
32
R/W
0000_0000h
42.13.1.1/
3031
18
AHB RX Data Buffer register (ARDB6)
32
R/W
0000_0000h
42.13.1.1/
3031
1C
AHB RX Data Buffer register (ARDB7)
32
R/W
0000_0000h
42.13.1.1/
3031
20
AHB RX Data Buffer register (ARDB8)
32
R/W
0000_0000h
42.13.1.1/
3031
24
AHB RX Data Buffer register (ARDB9)
32
R/W
0000_0000h
42.13.1.1/
3031
28
AHB RX Data Buffer register (ARDB10)
32
R/W
0000_0000h
42.13.1.1/
3031
2C
AHB RX Data Buffer register (ARDB11)
32
R/W
0000_0000h
42.13.1.1/
3031
30
AHB RX Data Buffer register (ARDB12)
32
R/W
0000_0000h
42.13.1.1/
3031
Table continues on the next page...
42.13
42.13.1
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3031

<!-- page 3032 -->

memory map (continued)
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
34
AHB RX Data Buffer register (ARDB13)
32
R/W
0000_0000h
42.13.1.1/
3031
38
AHB RX Data Buffer register (ARDB14)
32
R/W
0000_0000h
42.13.1.1/
3031
3C
AHB RX Data Buffer register (ARDB15)
32
R/W
0000_0000h
42.13.1.1/
3031
40
AHB RX Data Buffer register (ARDB16)
32
R/W
0000_0000h
42.13.1.1/
3031
44
AHB RX Data Buffer register (ARDB17)
32
R/W
0000_0000h
42.13.1.1/
3031
48
AHB RX Data Buffer register (ARDB18)
32
R/W
0000_0000h
42.13.1.1/
3031
4C
AHB RX Data Buffer register (ARDB19)
32
R/W
0000_0000h
42.13.1.1/
3031
50
AHB RX Data Buffer register (ARDB20)
32
R/W
0000_0000h
42.13.1.1/
3031
54
AHB RX Data Buffer register (ARDB21)
32
R/W
0000_0000h
42.13.1.1/
3031
58
AHB RX Data Buffer register (ARDB22)
32
R/W
0000_0000h
42.13.1.1/
3031
5C
AHB RX Data Buffer register (ARDB23)
32
R/W
0000_0000h
42.13.1.1/
3031
60
AHB RX Data Buffer register (ARDB24)
32
R/W
0000_0000h
42.13.1.1/
3031
64
AHB RX Data Buffer register (ARDB25)
32
R/W
0000_0000h
42.13.1.1/
3031
68
AHB RX Data Buffer register (ARDB26)
32
R/W
0000_0000h
42.13.1.1/
3031
6C
AHB RX Data Buffer register (ARDB27)
32
R/W
0000_0000h
42.13.1.1/
3031
70
AHB RX Data Buffer register (ARDB28)
32
R/W
0000_0000h
42.13.1.1/
3031
74
AHB RX Data Buffer register (ARDB29)
32
R/W
0000_0000h
42.13.1.1/
3031
78
AHB RX Data Buffer register (ARDB30)
32
R/W
0000_0000h
42.13.1.1/
3031
7C
AHB RX Data Buffer register (ARDB31)
32
R/W
0000_0000h
42.13.1.1/
3031
AHB RX Data Buffer (QSPI_ARDB0 to QSPI_ARDB31)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3032
NXP Semiconductors

<!-- page 3033 -->

42.13.1.1
AHB RX Data Buffer register (ARDBn)
The AHB RX Data Buffer register 0 to 31 can be used to read the buffer content of the
RX Buffer from successive addresses. QSPI_ARDB0 corresponds to the RX Buffer
register entry corresponding to the current value of the read pointer with increasing order.
The increment of the read pointer depends from the access scheme (DMA or flag-driven).
Refer to "Data Transfer from the QuadSPI Module Internal Buffers" section in Flash
Read section, RX Buffer, data read via register interface and AHB read, for the
description of successive accesses to the RX Buffer content. Refer also to Byte Ordering
of Serial Flash Read Data for the byte ordering scheme.
Valid address range accessible in the QSPI_ARDBn range depends from the number of
RX Buffer entries implemented and from the number of valid buffer entries available in
the RX Buffer.
• Example 1, RX Buffer filled completely with 32 words: In this case the address
range for valid read access extends from QSPI_ARDB0 to QSPI_ARDB31.
• Example 2, RX Buffer filled with 5 valid words, RX Buffer fill level
QSPI_RBSR[RDBFL] is 5. In this case an access to QSPI_ARDB4 provides the last
valid entry.
Address: 0h base + 0h offset + (4d × i), where i=0d to 31d
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
ARXD
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
ARDBn field descriptions
Field
Description
ARXD
ARDB provided RX Buffer Data.
Byte order (endianness) is identical to the RX Buffer Data Registers.
42.14
Peripheral Bus Register Descriptions
This section provides the peripheral bus register information of the QuadSPI module.
This section provides the memory map and register definitions of the QuadSPI module.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3033

<!-- page 3034 -->

QuadSPI memory map
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
21E_0000
Module Configuration Register (QuadSPI_MCR)
32
R/W
000F_4000h
42.14.1/
3039
21E_0008
IP Configuration Register (QuadSPI_IPCR)
32
R/W
0000_0000h
42.14.2/
3042
21E_000C
Flash Configuration Register (QuadSPI_FLSHCR)
32
R/W
0000_0303h
42.14.3/
3043
21E_0010
Buffer0 Configuration Register (QuadSPI_BUF0CR)
32
R/W
0000_0000h
42.14.4/
3043
21E_0014
Buffer1 Configuration Register (QuadSPI_BUF1CR)
32
R/W
0000_0000h
42.14.5/
3044
21E_0018
Buffer2 Configuration Register (QuadSPI_BUF2CR)
32
R/W
0000_0000h
42.14.6/
3045
21E_001C
Buffer3 Configuration Register (QuadSPI_BUF3CR)
32
R/W
See section
42.14.7/
3046
21E_0020
Buffer Generic Configuration Register
(QuadSPI_BFGENCR)
32
R/W
0000_0000h
42.14.8/
3047
21E_0030
Buffer0 Top Index Register (QuadSPI_BUF0IND)
32
R/W
0000_0000h
42.14.9/
3047
21E_0034
Buffer1 Top Index Register (QuadSPI_BUF1IND)
32
R/W
0000_0000h
42.14.10/
3048
21E_0038
Buffer2 Top Index Register (QuadSPI_BUF2IND)
32
R/W
0000_0000h
42.14.11/
3049
21E_0100
Serial Flash Address Register (QuadSPI_SFAR)
32
R/W
0000_0000h
42.14.12/
3050
21E_0108
Sampling Register (QuadSPI_SMPR)
32
R/W
0000_0000h
42.14.13/
3050
21E_010C
RX Buffer Status Register (QuadSPI_RBSR)
32
R
0000_0000h
42.14.14/
3051
21E_0110
RX Buffer Control Register (QuadSPI_RBCT)
32
R/W
0000_0000h
42.14.15/
3052
21E_0150
TX Buffer Status Register (QuadSPI_TBSR)
32
R
0000_0000h
42.14.16/
3053
21E_0154
TX Buffer Data Register (QuadSPI_TBDR)
32
R/W
0000_0000h
42.14.17/
3053
21E_015C
Status Register (QuadSPI_SR)
32
R
0000_3800h
42.14.18/
3055
21E_0160
Flag Register (QuadSPI_FR)
32
w1c
0800_0000h
42.14.19/
3058
21E_0164
Interrupt and DMA Request Select and Enable Register
(QuadSPI_RSER)
32
R/W
0000_0000h
42.14.20/
3061
21E_0168
Sequence Suspend Status Register (QuadSPI_SPNDST)
32
R
0000_0000h
42.14.21/
3064
21E_016C
Sequence Pointer Clear Register (QuadSPI_SPTRCLR)
32
R/W
0000_0000h
42.14.22/
3066
Table continues on the next page...
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3034
NXP Semiconductors

<!-- page 3035 -->

QuadSPI memory map (continued)
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
21E_0180
Serial Flash A1 Top Address (QuadSPI_SFA1AD)
32
R/W
0000_0000h
42.14.23/
3066
21E_0184
Serial Flash A2 Top Address (QuadSPI_SFA2AD)
32
R/W
0000_0000h
42.14.24/
3067
21E_0188
Serial Flash B1Top Address (QuadSPI_SFB1AD)
32
R/W
0000_0000h
42.14.25/
3067
21E_018C
Serial Flash B2Top Address (QuadSPI_SFB2AD)
32
R/W
0000_0000h
42.14.26/
3068
21E_0200
RX Buffer Data Register (QuadSPI_RBDR0)
32
R/W
0000_0000h
42.14.27/
3068
21E_0204
RX Buffer Data Register (QuadSPI_RBDR1)
32
R/W
0000_0000h
42.14.27/
3068
21E_0208
RX Buffer Data Register (QuadSPI_RBDR2)
32
R/W
0000_0000h
42.14.27/
3068
21E_020C
RX Buffer Data Register (QuadSPI_RBDR3)
32
R/W
0000_0000h
42.14.27/
3068
21E_0210
RX Buffer Data Register (QuadSPI_RBDR4)
32
R/W
0000_0000h
42.14.27/
3068
21E_0214
RX Buffer Data Register (QuadSPI_RBDR5)
32
R/W
0000_0000h
42.14.27/
3068
21E_0218
RX Buffer Data Register (QuadSPI_RBDR6)
32
R/W
0000_0000h
42.14.27/
3068
21E_021C
RX Buffer Data Register (QuadSPI_RBDR7)
32
R/W
0000_0000h
42.14.27/
3068
21E_0220
RX Buffer Data Register (QuadSPI_RBDR8)
32
R/W
0000_0000h
42.14.27/
3068
21E_0224
RX Buffer Data Register (QuadSPI_RBDR9)
32
R/W
0000_0000h
42.14.27/
3068
21E_0228
RX Buffer Data Register (QuadSPI_RBDR10)
32
R/W
0000_0000h
42.14.27/
3068
21E_022C
RX Buffer Data Register (QuadSPI_RBDR11)
32
R/W
0000_0000h
42.14.27/
3068
21E_0230
RX Buffer Data Register (QuadSPI_RBDR12)
32
R/W
0000_0000h
42.14.27/
3068
21E_0234
RX Buffer Data Register (QuadSPI_RBDR13)
32
R/W
0000_0000h
42.14.27/
3068
21E_0238
RX Buffer Data Register (QuadSPI_RBDR14)
32
R/W
0000_0000h
42.14.27/
3068
21E_023C
RX Buffer Data Register (QuadSPI_RBDR15)
32
R/W
0000_0000h
42.14.27/
3068
21E_0240
RX Buffer Data Register (QuadSPI_RBDR16)
32
R/W
0000_0000h
42.14.27/
3068
21E_0244
RX Buffer Data Register (QuadSPI_RBDR17)
32
R/W
0000_0000h
42.14.27/
3068
Table continues on the next page...
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3035

<!-- page 3036 -->

QuadSPI memory map (continued)
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
21E_0248
RX Buffer Data Register (QuadSPI_RBDR18)
32
R/W
0000_0000h
42.14.27/
3068
21E_024C
RX Buffer Data Register (QuadSPI_RBDR19)
32
R/W
0000_0000h
42.14.27/
3068
21E_0250
RX Buffer Data Register (QuadSPI_RBDR20)
32
R/W
0000_0000h
42.14.27/
3068
21E_0254
RX Buffer Data Register (QuadSPI_RBDR21)
32
R/W
0000_0000h
42.14.27/
3068
21E_0258
RX Buffer Data Register (QuadSPI_RBDR22)
32
R/W
0000_0000h
42.14.27/
3068
21E_025C
RX Buffer Data Register (QuadSPI_RBDR23)
32
R/W
0000_0000h
42.14.27/
3068
21E_0260
RX Buffer Data Register (QuadSPI_RBDR24)
32
R/W
0000_0000h
42.14.27/
3068
21E_0264
RX Buffer Data Register (QuadSPI_RBDR25)
32
R/W
0000_0000h
42.14.27/
3068
21E_0268
RX Buffer Data Register (QuadSPI_RBDR26)
32
R/W
0000_0000h
42.14.27/
3068
21E_026C
RX Buffer Data Register (QuadSPI_RBDR27)
32
R/W
0000_0000h
42.14.27/
3068
21E_0270
RX Buffer Data Register (QuadSPI_RBDR28)
32
R/W
0000_0000h
42.14.27/
3068
21E_0274
RX Buffer Data Register (QuadSPI_RBDR29)
32
R/W
0000_0000h
42.14.27/
3068
21E_0278
RX Buffer Data Register (QuadSPI_RBDR30)
32
R/W
0000_0000h
42.14.27/
3068
21E_027C
RX Buffer Data Register (QuadSPI_RBDR31)
32
R/W
0000_0000h
42.14.27/
3068
21E_0300
LUT Key Register (QuadSPI_LUTKEY)
32
R/W
5AF0_5AF0h
42.14.28/
3069
21E_0304
LUT Lock Configuration Register (QuadSPI_LCKCR)
32
R/W
0000_0002h
42.14.29/
3070
21E_0310
Look-up Table register (QuadSPI_LUT0)
32
R/W
0818_0403h
42.14.30/
3071
21E_0314
Look-up Table register (QuadSPI_LUT1)
32
R/W
2400_1C08h
42.14.31/
3072
21E_0318
Look-up Table register (QuadSPI_LUT2)
32
R/W
0000_0000h
42.14.32/
3073
21E_031C
Look-up Table register (QuadSPI_LUT3)
32
R/W
0000_0000h
42.14.32/
3073
21E_0320
Look-up Table register (QuadSPI_LUT4)
32
R/W
0000_0000h
42.14.32/
3073
21E_0324
Look-up Table register (QuadSPI_LUT5)
32
R/W
0000_0000h
42.14.32/
3073
Table continues on the next page...
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3036
NXP Semiconductors

<!-- page 3037 -->

QuadSPI memory map (continued)
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
21E_0328
Look-up Table register (QuadSPI_LUT6)
32
R/W
0000_0000h
42.14.32/
3073
21E_032C
Look-up Table register (QuadSPI_LUT7)
32
R/W
0000_0000h
42.14.32/
3073
21E_0330
Look-up Table register (QuadSPI_LUT8)
32
R/W
0000_0000h
42.14.32/
3073
21E_0334
Look-up Table register (QuadSPI_LUT9)
32
R/W
0000_0000h
42.14.32/
3073
21E_0338
Look-up Table register (QuadSPI_LUT10)
32
R/W
0000_0000h
42.14.32/
3073
21E_033C
Look-up Table register (QuadSPI_LUT11)
32
R/W
0000_0000h
42.14.32/
3073
21E_0340
Look-up Table register (QuadSPI_LUT12)
32
R/W
0000_0000h
42.14.32/
3073
21E_0344
Look-up Table register (QuadSPI_LUT13)
32
R/W
0000_0000h
42.14.32/
3073
21E_0348
Look-up Table register (QuadSPI_LUT14)
32
R/W
0000_0000h
42.14.32/
3073
21E_034C
Look-up Table register (QuadSPI_LUT15)
32
R/W
0000_0000h
42.14.32/
3073
21E_0350
Look-up Table register (QuadSPI_LUT16)
32
R/W
0000_0000h
42.14.32/
3073
21E_0354
Look-up Table register (QuadSPI_LUT17)
32
R/W
0000_0000h
42.14.32/
3073
21E_0358
Look-up Table register (QuadSPI_LUT18)
32
R/W
0000_0000h
42.14.32/
3073
21E_035C
Look-up Table register (QuadSPI_LUT19)
32
R/W
0000_0000h
42.14.32/
3073
21E_0360
Look-up Table register (QuadSPI_LUT20)
32
R/W
0000_0000h
42.14.32/
3073
21E_0364
Look-up Table register (QuadSPI_LUT21)
32
R/W
0000_0000h
42.14.32/
3073
21E_0368
Look-up Table register (QuadSPI_LUT22)
32
R/W
0000_0000h
42.14.32/
3073
21E_036C
Look-up Table register (QuadSPI_LUT23)
32
R/W
0000_0000h
42.14.32/
3073
21E_0370
Look-up Table register (QuadSPI_LUT24)
32
R/W
0000_0000h
42.14.32/
3073
21E_0374
Look-up Table register (QuadSPI_LUT25)
32
R/W
0000_0000h
42.14.32/
3073
21E_0378
Look-up Table register (QuadSPI_LUT26)
32
R/W
0000_0000h
42.14.32/
3073
21E_037C
Look-up Table register (QuadSPI_LUT27)
32
R/W
0000_0000h
42.14.32/
3073
Table continues on the next page...
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3037

<!-- page 3038 -->

QuadSPI memory map (continued)
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
21E_0380
Look-up Table register (QuadSPI_LUT28)
32
R/W
0000_0000h
42.14.32/
3073
21E_0384
Look-up Table register (QuadSPI_LUT29)
32
R/W
0000_0000h
42.14.32/
3073
21E_0388
Look-up Table register (QuadSPI_LUT30)
32
R/W
0000_0000h
42.14.32/
3073
21E_038C
Look-up Table register (QuadSPI_LUT31)
32
R/W
0000_0000h
42.14.32/
3073
21E_0390
Look-up Table register (QuadSPI_LUT32)
32
R/W
0000_0000h
42.14.32/
3073
21E_0394
Look-up Table register (QuadSPI_LUT33)
32
R/W
0000_0000h
42.14.32/
3073
21E_0398
Look-up Table register (QuadSPI_LUT34)
32
R/W
0000_0000h
42.14.32/
3073
21E_039C
Look-up Table register (QuadSPI_LUT35)
32
R/W
0000_0000h
42.14.32/
3073
21E_03A0
Look-up Table register (QuadSPI_LUT36)
32
R/W
0000_0000h
42.14.32/
3073
21E_03A4
Look-up Table register (QuadSPI_LUT37)
32
R/W
0000_0000h
42.14.32/
3073
21E_03A8
Look-up Table register (QuadSPI_LUT38)
32
R/W
0000_0000h
42.14.32/
3073
21E_03AC
Look-up Table register (QuadSPI_LUT39)
32
R/W
0000_0000h
42.14.32/
3073
21E_03B0
Look-up Table register (QuadSPI_LUT40)
32
R/W
0000_0000h
42.14.32/
3073
21E_03B4
Look-up Table register (QuadSPI_LUT41)
32
R/W
0000_0000h
42.14.32/
3073
21E_03B8
Look-up Table register (QuadSPI_LUT42)
32
R/W
0000_0000h
42.14.32/
3073
21E_03BC
Look-up Table register (QuadSPI_LUT43)
32
R/W
0000_0000h
42.14.32/
3073
21E_03C0
Look-up Table register (QuadSPI_LUT44)
32
R/W
0000_0000h
42.14.32/
3073
21E_03C4
Look-up Table register (QuadSPI_LUT45)
32
R/W
0000_0000h
42.14.32/
3073
21E_03C8
Look-up Table register (QuadSPI_LUT46)
32
R/W
0000_0000h
42.14.32/
3073
21E_03CC
Look-up Table register (QuadSPI_LUT47)
32
R/W
0000_0000h
42.14.32/
3073
21E_03D0
Look-up Table register (QuadSPI_LUT48)
32
R/W
0000_0000h
42.14.32/
3073
21E_03D4
Look-up Table register (QuadSPI_LUT49)
32
R/W
0000_0000h
42.14.32/
3073
Table continues on the next page...
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3038
NXP Semiconductors

<!-- page 3039 -->

QuadSPI memory map (continued)
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
21E_03D8
Look-up Table register (QuadSPI_LUT50)
32
R/W
0000_0000h
42.14.32/
3073
21E_03DC
Look-up Table register (QuadSPI_LUT51)
32
R/W
0000_0000h
42.14.32/
3073
21E_03E0
Look-up Table register (QuadSPI_LUT52)
32
R/W
0000_0000h
42.14.32/
3073
21E_03E4
Look-up Table register (QuadSPI_LUT53)
32
R/W
0000_0000h
42.14.32/
3073
21E_03E8
Look-up Table register (QuadSPI_LUT54)
32
R/W
0000_0000h
42.14.32/
3073
21E_03EC
Look-up Table register (QuadSPI_LUT55)
32
R/W
0000_0000h
42.14.32/
3073
21E_03F0
Look-up Table register (QuadSPI_LUT56)
32
R/W
0000_0000h
42.14.32/
3073
21E_03F4
Look-up Table register (QuadSPI_LUT57)
32
R/W
0000_0000h
42.14.32/
3073
21E_03F8
Look-up Table register (QuadSPI_LUT58)
32
R/W
0000_0000h
42.14.32/
3073
21E_03FC
Look-up Table register (QuadSPI_LUT59)
32
R/W
0000_0000h
42.14.32/
3073
21E_0400
Look-up Table register (QuadSPI_LUT60)
32
R/W
0000_0000h
42.14.32/
3073
21E_0404
Look-up Table register (QuadSPI_LUT61)
32
R/W
0000_0000h
42.14.32/
3073
21E_0408
Look-up Table register (QuadSPI_LUT62)
32
R/W
0000_0000h
42.14.32/
3073
21E_040C
Look-up Table register (QuadSPI_LUT63)
32
R/W
0000_0000h
42.14.32/
3073
42.14.1
Module Configuration Register (QuadSPI_MCR)
The QuadSPI_MCR holds configuration data associated with QuadSPI operation.
Write:
• All other fields: Anytime
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3039

<!-- page 3040 -->

Address: 21E_0000h base + 0h offset = 21E_0000h
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
Reserved
DQS_PHASE_
EN
Reserved
Reserved
DQS_
LOOPBACK_EN
Reserved
Reserved
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
1
1
1
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
Reserved
MDIS
Reserved
CLR_
TXF
CLR_
RXF
Reserved
DDR_EN
DQS_EN
Reserved
END_CFG
SWRSTHD
SWRSTSD
W
Reset
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
QuadSPI_MCR field descriptions
Field
Description
31
Reserved
This field is reserved.
This field should always be set to 0.
30
DQS_PHASE_
EN
This bit controls internal DQS output phase.
If DQS_EN and DQS_LOOPBACK_EN are both set to 1, this bit should be set in SDR mode, and cleared
in DDR mode.
If either DQS_EN or DQS_LOOPBACK_EN is set to 0, this bit is ignored.
29
Reserved
This field is reserved.
This field should always be set to 0.
28–25
Reserved
This field is reserved.
This field should always be set to 0.
24
DQS_
LOOPBACK_EN
Quadspi will output serial data strobe signal which will be loopback from pad to sample input flash serial
data. Please note pad should be force input for loopback.Quadspi will output serial data strobe signal
which will be loopback from pad to sample input flash serial data. Please note pad should be force input
for loopback.
This bit is a don't care when DQS_EN is set to 0.
1'b1
DQS loopback sampling enabled
1'b0
DQS loopback sampling disabled
23–20
Reserved
This field is reserved.
19–16
Reserved
This field is reserved.
This field is reserved and should always be set to 0xF.
15
Reserved
This field is reserved.
This field is reserved.
14
MDIS
Module Disable. The MDIS bit allows the clock to the non-memory mapped logic in the QuadSPI to be
stopped, putting the QuadSPI in a software controlled power-saving state. Please refer to , for more
information.
Table continues on the next page...
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3040
NXP Semiconductors

<!-- page 3041 -->

QuadSPI_MCR field descriptions (continued)
Field
Description
0
Enable QuadSPI clocks.
1
Allow external logic to disable QuadSPI clocks.
13–12
Reserved
This field is reserved.
11
CLR_TXF
Clear TX FIFO/Buffer. Invalidate the TX Buffer content.
0
No action.
1
Read and write pointers of the TX Buffer are reset to 0. QSPI_TBSR[TRCTR] is reset to 0.
10
CLR_RXF
Clear RX FIFO. Invalidate the RX Buffer.
0
No action.
1
Read and write pointers of the RX Buffer are reset to 0. QSPI_RBSR[RDBFL] is reset to 0.
9–8
Reserved
This field is reserved.
7
DDR_EN
DDR mode enable:
0
2x and 4x clocks are disabled for SDR instructions only
1
2x and 4x clocks are enabled supports both SDR and DDR instruction.
6
DQS_EN
DQS enable: This field is valid for both SDR and DDR mode.For more details Refer Data Strobe Signal
Functionality
0
DQS disabled.
1
DQS enabled- When enabled, the incoming data is sampled on both the edges of DQS input when
QSPI_MCR[DDR_EN] is set, else, on only one edge when QSPI_MCR[DDR_EN] is 0. The
QSPI_SMPR[DDR_SMP] values are ignored.
5–4
Reserved
This field is reserved.
3–2
END_CFG
Defines the endianness of the QSPI module.For more details refer to Byte Ordering Endianess
1
SWRSTHD
Software reset for AHB domain
NOTE: Please keep other fields value when write to SWRSTHD and SWRSTSD
NOTE: These software reset don’t reset register setting but only reset internal flip‐flops in quadspi
controller
NOTE: To remove the reset, need to write 0 to SWRSTHD and SWRSTSD
0
No action
1
AHB domain flops are reset. Does not reset configuration registers.
It is advisable to reset both the serial flash domain and AHB domain at the same time. Resetting only
one domain might lead to side effects.
0
SWRSTSD
Software reset for Serial Flash domain
NOTE: Please keep other fields value when write to SWRSTHD and SWRSTSD
NOTE: These software reset don’t reset register setting but only reset internal flip‐flops in quadspi
controller
NOTE: To remove the reset, need to write 0 to SWRSTHD and SWRSTSD
Table continues on the next page...
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3041

<!-- page 3042 -->

QuadSPI_MCR field descriptions (continued)
Field
Description
0
No action
1
Serial Flash domain flops are reset. Does not reset configuration registers.
It is advisable to reset both the serial flash domain and AHB domain at the same time. Resetting only
one domain might lead to side effects.
42.14.2
IP Configuration Register (QuadSPI_IPCR)
The IP configuration register provides all the configuration required for an IP initiated
command. An IP command can be triggered by writing in the SEQID field of this
register. If the SEQID field is written successfully, a new command to the external serial
flash is started as per the sequence pointed to by the SEQID field. Refer to Normal
Mode , for details about the command triggering and command execution.
Write:
• QSPI_SR[IP_ACC]=0
Address: 21E_0000h base + 8h offset = 21E_0008h
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
Reserved
SEQID
Reserved
PAR_EN
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
IDATSZ
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
QuadSPI_IPCR field descriptions
Field
Description
31–28
Reserved
This field is reserved.
27–24
SEQID
Points to a sequence in the Look-up-table. The SEQID defines the bits [6:2] of the LUT index. The bits
[1:0] are always assumed to be 0. Refer to Look-up Table for more details. A write to this bit -field triggers
a transaction on the serial flash interface.
23–17
Reserved
This field is reserved.
16
PAR_EN
When set, a transaction to two serial flash devices is triggered in parallel mode. Refer to Parallel Flash
Mode for more details.
IDATSZ
IP data transfer size: Defines the data transfer size in bytes of the IP command.
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3042
NXP Semiconductors

<!-- page 3043 -->

42.14.3
Flash Configuration Register (QuadSPI_FLSHCR)
The Flash configuration register contains the flash device specific timings that must be
met by the QuadSPI controller for the device to function correctly.
Write:
• QSPI_SR[AHB_ACC] = 0
• QSPI_SR[IP_ACC] = 0
Address: 21E_0000h base + Ch offset = 21E_000Ch
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
Reserved
TCSH
Reserved
TCSS
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
1
1
0
0
0
0
0
0
1
1
QuadSPI_FLSHCR field descriptions
Field
Description
31–12
Reserved
This field is reserved.
Reserved.
11–8
TCSH
Serial flash CS hold time in terms of serial flash clock cycles.
NOTE: The actual delay between chip select assertion and clock fall edge is defined as:
• 1 SCK cycle if TCSH is set 0 or 1
• N SCK cycle if TCSH is set N (N>1)
7–4
Reserved
This field is reserved.
Reserved.
TCSS
Serial flash CS setup time in terms of serial flash clock cycles.
NOTE:
1. The actual delay between chip select assertion and clock fall edge is defined as:
• 0.5 SCK cycle if TCSS is set 0 or 1
• N+0.5 SCK cycle if TCSS is set N (N>1)
2. Any update to TCSS register bits is visible on the flash interface only from the second
transaction following the update.
42.14.4
Buffer0 Configuration Register (QuadSPI_BUF0CR)
This register provides the configuration for any access to buffer0. An access is routed to
buffer0 when the master port number of the incoming AHB request matches the
MSTRID field of the BUF0CR. Any buffer "miss" leads to a serial flash transaction
being triggered as per the sequence pointed to the SEQID field. Buffer0 may also be
configured as a high priority buffer by setting the HP_EN field of this register.
Write:
• QSPI_SR[AHB_ACC] = 0
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3043

<!-- page 3044 -->

Address: 21E_0000h base + 10h offset = 21E_0010h
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
HP_
EN
Reserved
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
ADATSZ
Reserved
MSTRID
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
QuadSPI_BUF0CR field descriptions
Field
Description
31
HP_EN
High Priority Enable: When set, the master associated with this buffer is assigned a priority higher than the
rest of the masters. An access by a high priority master will suspend any ongoing prefetch by another AHB
master and will be serviced on high priority. Refer to Flexible AHB Buffers for details.
30–16
Reserved
This field is reserved.
15–8
ADATSZ
AHB data transfer size: Defines the data transfer size in 8 bytes of an AHB triggered access to serial flash.
For example,a value of 0x2 will set transfer size to 16bytes.When ADATSZ = 0, the data size mentioned
the sequence pointed to by the SEQID field overrides this value. SW should ensure that this transfer size
is not greater than the size of this buffer.
7–4
Reserved
This field is reserved.
Reserved.
MSTRID
Master ID: The ID of the AHB master associated with BUFFER0. Any AHB access with this master port
number is routed to this buffer.
42.14.5
Buffer1 Configuration Register (QuadSPI_BUF1CR)
This register provides the configuration for any access to buffer1. An access is routed to
buffer1 when the master port number of the incoming AHB request matches the
MSTRID field of the BUF1CR. Any buffer "miss" leads to the buffer being flushed and a
serial flash transaction being triggered as per the sequence pointed to by the SEQID field.
Write:
• QSPI_SR[AHB_ACC] = 0
Address: 21E_0000h base + 14h offset = 21E_0014h
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
Reserved
ADATSZ
Reserved
MSTRID
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
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3044
NXP Semiconductors

<!-- page 3045 -->

QuadSPI_BUF1CR field descriptions
Field
Description
31–16
Reserved
This field is reserved.
15–8
ADATSZ
AHB data transfer size: Defines the data transfer size in 8 bytes of an AHB triggered access to serial
flash.For example, a value of 0x2 will set transfer size to 16bytes. When ADATSZ = 0, the data size
mentioned the sequence pointed to by the SEQID field overrides this value. SW should ensure that this
transfer size is not greater than the size of this buffer.
7–4
Reserved
This field is reserved.
MSTRID
Master ID: The ID of the AHB master associated with BUFFER1. Any AHB access with this master port
number is routed to this buffer.
42.14.6
Buffer2 Configuration Register (QuadSPI_BUF2CR)
This register provides the configuration for any access to buffer2. An access is routed to
buffer2 when the master port number of the incoming AHB request matches the
MSTRID field of the BUF2CR. Any buffer "miss" leads to the buffer being flushed and a
serial flash transaction being triggered as per the sequence pointed to by the SEQID field.
Write:
• QSPI_SR[AHB_ACC] = 0
Address: 21E_0000h base + 18h offset = 21E_0018h
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
Reserved
ADATSZ
Reserved
MSTRID
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
QuadSPI_BUF2CR field descriptions
Field
Description
31–16
Reserved
This field is reserved.
Reserved.
15–8
ADATSZ
AHB data transfer size: Defines the data transfer size in 8 Bytes of an AHB triggered access to serial
flash. For example, a value of 0x2 will set transfer size to 16bytes.When ADATSZ = 0, the data size
mentioned the sequence pointed to by the SEQID field overrides this value. SW should ensure that this
transfer size is not greater than the size of this buffer.
7–4
Reserved
This field is reserved.
Reserved.
MSTRID
Master ID: The ID of the AHB master associated with BUFFER2. Any AHB access with this master port
number is routed to this buffer.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3045

<!-- page 3046 -->

42.14.7
Buffer3 Configuration Register (QuadSPI_BUF3CR)
This register provides the configuration for any access to buffer3. An access is routed to
buffer3 when the master port number of the incoming AHB request matches the
MSTRID field of the BUF3CR. Any buffer "miss" leads to the buffer being flushed a
serial flash transaction being triggered as per the sequence pointed to by the SEQID field.
If the ALLMST field is set, any transaction where the master port number does not match
any of the buffer MSTRID fields will be routed to this buffer. In the case that the
ALLMST field is not set, any such transaction (where master port number does not match
any of the MSTRID fields) will be returned an ERROR response.
Write:
• QSPI_SR[AHB_ACC] = 0
.
Address: 21E_0000h base + 1Ch offset = 21E_001Ch
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
ALLMST
Reserved
W
Reset
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
ADATSZ
Reserved
MSTRID
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
QuadSPI_BUF3CR field descriptions
Field
Description
31
ALLMST
All master enable: When set, buffer3 acts as an all-master buffer. Any AHB access with a master port
number not matching with the master ID of buffer0 or buffer1 or buffer2 is routed to buffer3. When set, the
MSTRID field of this register is ignored.
30–16
Reserved
This field is reserved.
Reserved.
15–8
ADATSZ
AHB data transfer size: Defines the data transfer size in 8 Bytes of an AHB triggered access to serial
flash. When ADATSZ = 0, the data size mentioned the sequence pointed to by the SEQID field overrides
this value. SW should ensure that this transfer size is not greater than the size of this buffer.
7–4
Reserved
This field is reserved.
MSTRID
Master ID: The ID of the AHB master associated with BUFFER3. Any AHB access with this master port
number is routed to this buffer.
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3046
NXP Semiconductors

<!-- page 3047 -->

42.14.8
Buffer Generic Configuration Register (QuadSPI_BFGENCR)
This register provides the generic configuration to any of the buffer accesses. Any buffer
"miss" leads to the buffer being flushed and a serial flash transaction being triggered as
per the sequence pointed to by the SEQID field. If the PAR_EN field is set, all the buffer
accesses result in parallel accesses to the flashes.
Write:
• QSPI_SR[AHB_ACC] = 0
Address: 21E_0000h base + 20h offset = 21E_0020h
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
Reserved
PAR_EN
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
SEQID
Reserved
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
QuadSPI_BFGENCR field descriptions
Field
Description
31–17
Reserved
This field is reserved.
16
PAR_EN
When set, a transaction to two serial flash devices is triggered in parallel mode. Refer to Parallel Flash
Mode for more details.
15–12
SEQID
Points to a sequence in the Look-up-table. The SEQID defines the bits [6:2] of the LUT index. The bits
[1:0] are always assumed to be 0. Refer to Look-up Table.
NOTE: If the sequence pointer differs between the new and previous sequence then the user should
reset this. See QSPI_SPTRCLR for more information.
Reserved
This field is reserved.
42.14.9
Buffer0 Top Index Register (QuadSPI_BUF0IND)
This register specifies the top index of buffer0, which defines its size. Note that that the 3
LSBs of this register are set to zero - this ensures that the buffer is 64bit aligned, as each
buffer entry is 64bits long.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3047

<!-- page 3048 -->

The register value should be set to the desired number of bytes less 8. For example,
setting BUF0IND to 0 gives 8 bytes, 1 give 16bytes etc.
The size of buffer0 is the difference between the BUF0IND+8 and 0.
It is the responsibility of the software to ensure that BUF0IND value is not greater than
the overall size of the buffer. The hardware does not provide any protection against
illegal programming.
Write:
• QSPI_SR[AHB_ACC] = 0
Address: 21E_0000h base + 30h offset = 21E_0030h
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
TPINDX0
Reserved
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
QuadSPI_BUF0IND field descriptions
Field
Description
31–3
TPINDX0
Top index of buffer 0.
Reserved
This field is reserved.
Reserved.
42.14.10
Buffer1 Top Index Register (QuadSPI_BUF1IND)
This register specifies the top index of buffer1, which defines its size. Note that the 3
LSBs of this register are set to zero - this ensures that the buffer is 64bit aligned as each
buffer entry is 64bits long.
The register value should be set to the desired number of bytes less. The size of buffer1 is
the difference between the BUF1IND and BUF0IND.
It is the responsibility of the software to ensure that BUF1IND value is not greater than
the overall size of the buffer. The hardware does not provide any protection against
illegal programming.
Write:
• QSPI_SR[AHB_ACC] = 0
Address: 21E_0000h base + 34h offset = 21E_0034h
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
TPINDX1
Reserved
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
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3048
NXP Semiconductors

<!-- page 3049 -->

QuadSPI_BUF1IND field descriptions
Field
Description
31–3
TPINDX1
Top index of buffer 1.
Reserved
This field is reserved.
42.14.11
Buffer2 Top Index Register (QuadSPI_BUF2IND)
This register specifies the top index of buffer2, which defines its size. Note that that the 3
LSBs of this register are set to zero - this ensures that the buffer is 64bit aligned as each
buffer entry is 64bits long.
The register value should be set to the desired number of bytes less 8. The size of buffer2
is the difference between the BUF2IND and BUF1IND.
It is the responsibility of the software to ensure that BUF2IND value is not greater than
the overall size of the buffer. The hardware does not provide any protection against
illegal programming.
Write:
• QSPI_SR[AHB_ACC] = 0
Address: 21E_0000h base + 38h offset = 21E_0038h
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
TPINDX2
Reserved
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
QuadSPI_BUF2IND field descriptions
Field
Description
31–3
TPINDX2
Top index of buffer 2.
Reserved
This field is reserved.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3049

<!-- page 3050 -->

42.14.12
Serial Flash Address Register (QuadSPI_SFAR)
The module automatically translates this address on the memory map to the address on
the flash itself. When operating in 24bit mode, only bits 23-0 are sent to the flash, in
32bit mode, bits 27-0 are used with bits 31-28 driven to 0 Refer to Table 42-5 for the
mapping between the access mode and the QSPI_SFAR content and to Normal Mode for
details about the command triggering and command execution. The software should
ensure that the serial flash address provided in the QSPI_SFAR register lies in the valid
flash address range as defined in Table 42-5.
Write:
• QSPI_SR[IP_ACC] = 0
Address: 21E_0000h base + 100h offset = 21E_0100h
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
SFADR
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
QuadSPI_SFAR field descriptions
Field
Description
SFADR
Serial Flash Address. The register content is used as byte address for all following IP Commands.
42.14.13
Sampling Register (QuadSPI_SMPR)
The Sampling Register allows configuration of how the incoming data from the external
serial flash devices are sampled in the QuadSPI module.
Write:Disabled Mode
Address: 21E_0000h base + 108h offset = 21E_0108h
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
DDRSMP
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
SDRSMP
0
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
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3050
NXP Semiconductors

<!-- page 3051 -->

QuadSPI_SMPR field descriptions
Field
Description
31–19
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
18–16
DDRSMP
DDR Sampling point. Select the sampling point for incoming data when serial flash is executing a DDR
instruction. Refer to Input timing in DDR mode with internal sampling , for details on the sampling points.
15–7
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
6–5
SDRSMP
SDR sampling point.
4–3
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
42.14.14
RX Buffer Status Register (QuadSPI_RBSR)
This register contains information related to the receive data buffer.
Address: 21E_0000h base + 10Ch offset = 21E_010Ch
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
RDCTR
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
Reserved
RDBFL
Reserved
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
QuadSPI_RBSR field descriptions
Field
Description
31–16
RDCTR
Read Counter, indicates how many entries of 4 bytes have been removed from the RX Buffer.For example
a value of 0x2 would indicate 8bytes have been removed
It is incremented by the number (QSPI_RBCT[WMRK] + 1) on RX Buffer POP event. The RX Buffer can
be popped using DMA or pop flag QSPI_FR[RBDF]. The QSPI_RSER[RBDDE] defines which pop has to
be done. For further details please refer to AHB RX Data Buffer (QSPI_ARDB0 to QSPI_ARDB31) and
"Data Transfer from the QuadSPI Module Internal Buffers section in Flash Read section.
15–14
Reserved
This field is reserved.
13–8
RDBFL
RX Buffer Fill Level, indicates how many entries of 4 bytes are still available in the RX Buffer.For example
a value of 0x2 would indicate 8bytes are available.
Reserved
This field is reserved.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3051

<!-- page 3052 -->

42.14.15
RX Buffer Control Register (QuadSPI_RBCT)
This register contains control data related to the receive data buffer.
Write:
• QSPI_SR[IP_ACC] = 0
Address: 21E_0000h base + 110h offset = 21E_0110h
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
Reserved
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
Reserved
RXBRD
Reserved
WMRK
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
QuadSPI_RBCT field descriptions
Field
Description
31–9
Reserved
This field is reserved.
8
RXBRD
RX Buffer Readout: This bit specifies the access scheme for the RX Buffer readout.
0
RX Buffer content is read using the AHB Bus registers QSPI_ARDB0 to QSPI_ARDB31.
For details, refer to Exclusive Access to Serial Flash for AHB Commands.
1
RX Buffer content is read using the IP Bus registers QSPI_RBDR0 to QSPI_RBDR31.
7–5
Reserved
This field is reserved.
WMRK
RX Buffer Watermark: This field determines when the readout action of the RX Buffer is triggered. When
the number of valid entries in the RX Buffer is equal to or greater than the number given by (WMRK+1) the
QSPI_SR[RXWE] flag is asserted.The value should be entered as the number of 4byte entries minus 1.
For example a value of 0x0 would set the watermark to 4bytes, 1 to 8bytes, 2 to 12bytes etc.
For details, refer to DMA Usage.
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3052
NXP Semiconductors

<!-- page 3053 -->

42.14.16
TX Buffer Status Register (QuadSPI_TBSR)
This register contains information related to the transmit data buffer.
Address: 21E_0000h base + 150h offset = 21E_0150h
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
TRCTR
Reserved
TRBFL
Reserved
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
QuadSPI_TBSR field descriptions
Field
Description
31–16
TRCTR
Transmit Counter. This field indicates how many entries of 4 bytes have been written into the TX Buffer by
host accesses. It is reset to 0 when a 1 is written into the QSPI_MCR[CLR_TXF] bit. It is incremented on
each write access to the QSPI_TBDR register when another word has been pushed onto the TX Buffer.
When it is not cleared the TRCTR field wraps around to 0. Refer to TX Buffer Data Register
(QuadSPI_TBDR) for details.
15–13
Reserved
This field is reserved.
12–8
TRBFL
TX Buffer Fill Level. The TRBFL field contains the number of entries of 4 bytes each available in the TX
Buffer for the QuadSPI module to transmit to the serial flash device.
Reserved
This field is reserved.
42.14.17
TX Buffer Data Register (QuadSPI_TBDR)
The QSPI_TBDR register provides access to the circular TX Buffer of depth 128 bytes.
This buffer provides the data written into it as write data for the page programming
commands to the serial flash device. Refer to Table 42-14 for the byte ordering scheme.
A write transaction on the flash with data size of less than 32 bits will lead to the removal
of four data entry from the TX buffer. The valid bits will be used and the rest of the bits
will be discarded.
Write:
• QSPI_SR[TXFULL] = 0
32-bit write access required
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3053

<!-- page 3054 -->

NOTE
There is no limitation on Flash programming size. But the data
size written to TX Buffer should be 64 Byte aligned. If flash
programming size is not 64 bytes aligned, please write
redundant data to TX Buffers. The redundant data will be
ignored by QuadSPI controller.
Address: 21E_0000h base + 154h offset = 21E_0154h
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
TXDATA
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
QuadSPI_TBDR field descriptions
Field
Description
TXDATA
TX Data
On write access the data is written into the next available entry of the TX Buffer and the
QPSI_TBSR[TRBFL] field is updated accordingly.
On a read access, the last data written to the register is returned.
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3054
NXP Semiconductors

<!-- page 3055 -->

42.14.18
Status Register (QuadSPI_SR)
The QSPI_SR register provides all available status information about SFM command
execution and arbitration, the RX Buffer and TX Buffer and the AHB Buffer.
Address: 21E_0000h base + 15Ch offset = 21E_015Ch
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
DLPSMP
Reserved
TXFULL
Reserved
Reserved
TXEDA
RXDMA
Reserved
RXFULL
Reserved
RXWE
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
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3055

<!-- page 3056 -->

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
Reserved
AHB3FUL
AHB2FUL
AHB1FUL
AHB0FUL
AHB3NE
AHB2NE
AHB1NE
AHB0NE
AHBTRN
AHBGNT
Reserved
Reserved
AHB_ACC
IP_ACC
BUSY
W
Reset
0
0
1
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
QuadSPI_SR field descriptions
Field
Description
31–29
DLPSMP
NOTE: Data learning is not implemented on this chip.
Data learning pattern sampling point: The sampling point found by the controller with the data learning
pattern.
• This is used for DDR only.
• If the learning fails, this field will return garbage and DLPFF bit will be set.
28
Reserved
This field is reserved.
27
TXFULL
TX Buffer Full: Asserted when no more data can be stored.
26
Reserved
This field is reserved.
25
Reserved
This field is reserved.
24
TXEDA
Tx Buffer Enough Data Available
Asserted when TX Buffer contains enough data for any pop operation to take place. There must be atleast
128bit data available in TX FIFO for any pop operation otherwise QSPI_FR[TBUF] will be set.
Table continues on the next page...
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3056
NXP Semiconductors

<!-- page 3057 -->

QuadSPI_SR field descriptions (continued)
Field
Description
23
RXDMA
RX Buffer DMA: Asserted when RX Buffer read out via DMA is active i.e DMA is requested or running.
22–20
Reserved
This field is reserved.
19
RXFULL
RX Buffer Full: Asserted when the RX Buffer is full, i.e. that QSPI_RBSR[RDBFL] field is equal to 32.
18–17
Reserved
This field is reserved.
16
RXWE
RX Buffer Watermark Exceeded: Asserted when the number of valid entries in the RX Buffer exceeds the
number given in the QSPI_RBCT[WMRK] field.
15
Reserved
This field is reserved.
14
AHB3FUL
AHB 3 Buffer Full: Asserted when AHB 3 buffer is full.
13
AHB2FUL
AHB 2 Buffer Full: Asserted when AHB 2 buffer is full.
12
AHB1FUL
AHB 1 Buffer Full: Asserted when AHB 1 buffer is full.
11
AHB0FUL
AHB 0 Buffer Full: Asserted when AHB 0 buffer is full.
10
AHB3NE
AHB 3 Buffer Not Empty: Asserted when AHB 3 buffer contains data.
9
AHB2NE
AHB 2 Buffer Not Empty: Asserted when AHB 2 buffer contains data.
8
AHB1NE
AHB 1 Buffer Not Empty: Asserted when AHB 1 buffer contains data.
7
AHB0NE
AHB 0 Buffer Not Empty: Asserted when AHB 0 buffer contains data.
6
AHBTRN
AHB Access Transaction pending: Asserted when there is a pending request on the AHB interface. Refer
to the AMBA specification for details.
5
AHBGNT
AHB Command priority Granted: Asserted when another module has been granted priority of AHB
Commands against IP Commands. For details refer to Command Arbitration.
4
Reserved
This field is reserved.
3
RESERVED
This field is reserved.
2
AHB_ACC
AHB Access: Asserted when the transaction currently executed was initiated by AHB bus.
1
IP_ACC
IP Access: Asserted when transaction currently executed was initiated by IP bus.
0
BUSY
Module Busy: Asserted when module is currently busy handling a transaction to an external flash device.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3057

<!-- page 3058 -->

42.14.19
Flag Register (QuadSPI_FR)
The QSPI_FR register provides all available flags about SFM command execution and
arbitration which may serve as source for the generation of interrupt service requests.
Note that the error flags in this register do not relate directly to the execution of the
transaction in the serial flash device itself but only to the behavior and conditions visible
in the QuadSPI module.
Write:Enabled Mode
Address: 21E_0000h base + 160h offset = 21E_0160h
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
DLPFF
Reserved
Reserved
TBFF
TBUF
Reserved
ILLINE
Reserved
RBOF
RBDF
W
w1c
w1c
w1c
w1c
w1c
w1c
Reset
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
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3058
NXP Semiconductors

<!-- page 3059 -->

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
ABSEF
Reserved
Reserved
ABOF
IUEF
Reserved
IPAEF
IPIEF
Reserved
IPGEF
Reserved
TFF
W
w1c
w1c
w1c
w1c
w1c
w1c
w1c
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
QuadSPI_FR field descriptions
Field
Description
31
DLPFF
NOTE: Data learning is not implemented on this chip.
Data Learning Pattern Failure Flag: Set when DATA_LEARN instruction was encountered in a sequence
but no sampling point was found for the data learning pattern The controller automatically starts sampling
using the value in QSPI_SMPR[DDRSMP].
30
Reserved
This field is reserved.
29–28
Reserved
This field is reserved.
27
TBFF
TX Buffer Fill Flag: Before writing to the TX buffer, this bit should be cleared. Then this bit has to be read
back. If the bit is set, the TX Buffer can take more data. If the bit remains cleared, the TX buffer is full.
Refer to Tx Buffer Operation for details.
26
TBUF
TX Buffer Underrun Flag: Set when the module tried to pull data although TX Buffer was emptyor the
buffer contains less than 128bits of data. The application must ensure that the buffer never goes empty
during a transaction expect for the last data fetch. The IP Command leading to the TX Buffer underrun is
continued (data sent to the serial flash device is all F in case of valid tx underrun. The application must
clear the TX Buffer in response to this event by writing a 1 into the QSPI_MCR[CLR_TXF] bit.
25–24
Reserved
This field is reserved.
23
ILLINE
Illegal Instruction Error Flag: Set when an illegal instruction is encountered by the controller in any of the
sequences. Refer to Table 42-12 for a list of legal instructions.
22–18
Reserved
This field is reserved.
17
RBOF
RX Buffer Overflow Flag: Set when not all the data read from the serial flash device could be pushed into
the RX Buffer.
The IP Command leading to this condition is continued until the number of bytes according to the
QSPI_IPCR[IDATSZ] field has been read from the serial flash device.
Table continues on the next page...
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3059

<!-- page 3060 -->

QuadSPI_FR field descriptions (continued)
Field
Description
The content of the RX Buffer is not changed.
16
RBDF
RX Buffer Drain Flag: Will be set if the QuadSPI_SR[RXWE] status bit is asserted.
Writing 1 into this bit triggers one of the following actions:
• If the RX Buffer has up to QuadSPI_RBCT[WMRK] valid entries then the flag is cleared.
• If the RX Buffer has more than QuadSPI_RBCT[WMRK] valid entries and the
QuadSPI_RSER[RBDDE] bit is not set (flag driven mode) a RX Buffer POP event is triggered.
The flag remains set if the RX Buffer contains more than QuadSPI_RBCT[WMRK] valid entries after the
RX Buffer POP event is finished.
The flag is cleared if the RX Buffer contains less than or equal to QuadSPI_RBCT[WMRK] valid entries
after the RX Buffer POP event is finished.
Refer to "Receive Buffer Drain Interrupt or DMA Request" section in Normal Mode Interrupt and DMA
Requests, for details.
15
ABSEF
AHB Sequence Error Flag: Set when the execution of an AHB Command is started with an WRITE or
WRITE_DDR Command in the sequence pointed to by the QSPI_BUFxCR register
Communication with the serial flash device is terminated before the execution of WRITE/WRITE_DDR
command by the QuadSPI module.
The AHB bus request which triggered this command is answered with an ERROR response.
14
Reserved
Reserved
This field is reserved.
13
Reserved
Reserved
This field is reserved.
12
ABOF
AHB Buffer Overflow Flag: Set when the size of the AHB access exceeds the size of the AHB buffer. This
condition can occur only if the QSPI_BUFxCR[ADATSZ] field is programmed incorrectly.
The AHB Command leading to this condition is continued until the number of entries according to the
QSPI_BUFxCR[ADATSZ] field has been read from the serial flash device.
The content of the AHB Buffer is not changed.
11
IUEF
IP Command Usage Error Flag: Set when in parallel flash mode the execution of an IP Command is
started and the sequence pointed to by the sequence ID contains a WRITE or a WRITE_DDR command.
Refer to Table 42-12 table for the related commands.
Communication with the serial flash device is terminated before the execution of WRITE/WRITE_DDR
command by the QuadSPI module.
10–8
Reserved
This field is reserved.
7
IPAEF
IP Command Trigger during AHB Access Error Flag. Set when the following condition occurs:
• A write access occurs to the QSPI_IPCR[SEQID] field and the QSPI_SR[AHB_ACC] bit is set. Any
command leading to the assertion of the IPAEF flag is ignored.
6
IPIEF
IP Command Trigger could not be executed Error Flag. Set when the QSPI_SR[IP_ACC] bit is set (i.e. an
IP triggered command is currently executing) and any of the following conditions occurs:
• Write access to the QSPI_IPCR register. Any command leading to the assertion of the IPIEF flag is
ignored
• Write access to the QSPI_SFAR register.
• Write access to the QSPI_RBCT register.
5
Reserved
This field is reserved.
Table continues on the next page...
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3060
NXP Semiconductors

<!-- page 3061 -->

QuadSPI_FR field descriptions (continued)
Field
Description
4
IPGEF
IP Command Trigger during AHB Grant Error Flag: Set when the following condition occurs:
• A write access occurs to the QSPI_IPCR[SEQID] field and the QSPI_SR[AHBGNT] bit is set. Any
command leading to the assertion of the IPGEF flag is ignored.
3–1
Reserved
This field is reserved.
0
TFF
IP Command Transaction Finished Flag: Set when the QuadSPI module has finished a running IP
Command. If an error occurred the related error flags are valid, at the latest, in the same clock cycle when
the TFF flag is asserted.
1. QSPI_BUFxCR implies anyone of QSPI_BUF0CR/QSPI_BUF1CR/QSPI_BUF2CR/QSPI_BUF3CR
42.14.20
Interrupt and DMA Request Select and Enable Register
(QuadSPI_RSER)
The QuadSPI_RSER register provides enables and selectors for the interrupts in the
QuadSPI module.
NOTE
Each flag of the QuadSPI_FR register enabled as source for an
interrupt prevents the QuadSPI module from entering Stop
Mode or Module Disable Mode when this flag is set.
Write:Anytime
Address: 21E_0000h base + 164h offset = 21E_0164h
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
DLPFIE
Reserved
Reserved
TBFIE
TBUIE
Reserved
Reserved
ILLINIE
Reserved
RBDDE
Reserved
RBOIE
RBDIE
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
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3061

<!-- page 3062 -->

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
ABSEIE
Reserved
Reserved
ABOIE
IUEIE
Reserved
IPAEIE
IPIEIE
Reserved
IPGEIE
Reserved
TFIE
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
QuadSPI_RSER field descriptions
Field
Description
31
DLPFIE
NOTE: Data learning is not implemented on this chip.
Data Learning Pattern Failure Interrupt enable. Triggered by DLPFF flag in QSPI_FR register
0
No DLPFF interrupt will be generated
1
DLPFF interrupt will be generated
30
Reserved
This field is reserved.
29–28
RESERVED
This field is reserved.
27
TBFIE
TX Buffer Fill Interrupt Enable
0
No TBFF interrupt will be generated
1
TBFF interrupt will be generated
26
TBUIE
TX Buffer Underrun Interrupt Enable
0
No TBUF interrupt will be generated
1
TBUF interrupt will be generated
25
Reserved
This field is reserved.
24
Reserved
This field is reserved.
23
ILLINIE
Illegal Instruction Error Interrupt Enable. Triggered by ILLINE flag in QSPI_FR
0
No ILLINE interrupt will be generated
1
ILLINE interrupt will be generated
22
Reserved
This field is reserved.
21
RBDDE
RX Buffer Drain DMA Enable: Enables generation of DMA requests for RX Buffer Drain. When this bit is
set DMA requests are generated as long as the QSPI_SR[RXWE] status bit is set.
0
No DMA request will be generated
1
DMA request will be generated
20–18
Reserved
This field is reserved.
Table continues on the next page...
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3062
NXP Semiconductors

<!-- page 3063 -->

QuadSPI_RSER field descriptions (continued)
Field
Description
17
RBOIE
RX Buffer Overflow Interrupt Enable
0
No RBOF interrupt will be generated
1
RBOF interrupt will be generated
16
RBDIE
RX Buffer Drain Interrupt Enable: Enables generation of IRQ requests for RX Buffer Drain. When this bit is
set the interrupt is asserted as long as the QuadSPI_SR[RBDF] flag is set.
0
No RBDF interrupt will be generated
1
RBDF Interrupt will be generated
15
ABSEIE
AHB Sequence Error Interrupt Enable: Triggered by ABSEF flags of QSPI_FR
0
No ABSEF interrupt will be generated
1
ABSEF interrupt will be generated
14
Reserved
Reserved
This field is reserved.
13
Reserved
Reserved
This field is reserved.
12
ABOIE
AHB Buffer Overflow Interrupt Enable
0
No ABOF interrupt will be generated
1
ABOF interrupt will be generated
11
IUEIE
IP Command Usage Error Interrupt Enable
0
No IUEF interrupt will be generated
1
IUEF interrupt will be generated
10–8
Reserved
This field is reserved.
7
IPAEIE
IP Command Trigger during AHB Access Error Interrupt Enable
0
No IPAEF interrupt will be generated
1
IPAEF interrupt will be generated
6
IPIEIE
IP Command Trigger during IP Access Error Interrupt Enable
0
No IPIEF interrupt will be generated
0
IPIEF interrupt will be generated
5
Reserved
This field is reserved.
4
IPGEIE
IP Command Trigger during AHB Grant Error Interrupt Enable
0
No IPGEF interrupt will be generated
1
IPGEF interrupt will be generated
3–1
Reserved
This field is reserved.
Reserved.
0
TFIE
Transaction Finished Interrupt Enable
0
No TFF interrupt will be generated
1
TFF interrupt will be generated
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3063

<!-- page 3064 -->

42.14.21
Sequence Suspend Status Register (QuadSPI_SPNDST)
The sequence suspend status register provides information specific to any suspended
sequence. An AHB sequence may be suspended when a high priority AHB master makes
an access before the AHB sequence completes the data transfer requested.
Address: 21E_0000h base + 168h offset = 21E_0168h
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
Reserved
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
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3064
NXP Semiconductors

<!-- page 3065 -->

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
DATLFT
Reserved
SPDBUF
Reserved
SUSPND
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
QuadSPI_SPNDST field descriptions
Field
Description
31–16
Reserved
This field is reserved.
15–9
DATLFT
Data left: Provides information about the amount of data left to be read in the suspended sequence. Valid
only when SUSPND is set to 1'b1. Value in terms of 64 bits or 8 bytes
8
Reserved
This field is reserved.
7–6
SPDBUF
Suspended Buffer: Provides the suspended buffer number. Valid only when SUSPND is set to 1'b1
5–1
Reserved
This field is reserved.
0
SUSPND
When set, it signifies that a sequence is in suspended state
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3065

<!-- page 3066 -->

42.14.22
Sequence Pointer Clear Register (QuadSPI_SPTRCLR)
The sequence pointer clear register provides bits to reset the IP and Buffer sequence
pointers. The sequence pointer contains the index of which instruction within the LUT
entry is to be executed next. For example, if the LUT entry ends on a JMP_ON_CS value
of 2, the index will be stored as 2.
The software should reset the sequence pointers whenever the sequence ID is changed by
updating the SEQID field in QSPI_IPCR or QSPI_BFGENCR.
Address: 21E_0000h base + 16Ch offset = 21E_016Ch
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
Reserved
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
Reserved
IPPTRC
Reserved
BFPTRC
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
QuadSPI_SPTRCLR field descriptions
Field
Description
31–9
Reserved
This field is reserved.
8
IPPTRC
IP Pointer Clear:
1: Clears the sequence pointer for IP accesses as defined in QuadSPI_IPCR
7–1
Reserved
This field is reserved.
Reserved.
0
BFPTRC
Buffer Pointer Clear:
1: Clears the sequence pointer for AHB accesses as defined in QuadSPI_BFGENCR.
42.14.23
Serial Flash A1 Top Address (QuadSPI_SFA1AD)
The QSPI_SFA1AD register provides the address mapping for the serial flash A1.The
difference between QSPI_SFA1AD[TPADA1] and QSPI_AMBA_BASE defines the size
of the memory map for serial flash A1.
Write:
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3066
NXP Semiconductors

<!-- page 3067 -->

• QSPI_SR[IP_ACC] = 0
• QSPI_SR[AHB_ACC] = 0
Address: 21E_0000h base + 180h offset = 21E_0180h
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
TPADA1
Reserved
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
QuadSPI_SFA1AD field descriptions
Field
Description
31–10
TPADA1
Top address for Serial Flash A1. In effect, TPADxx is the first location of the next memory.
Reserved
This field is reserved.
42.14.24
Serial Flash A2 Top Address (QuadSPI_SFA2AD)
The QSPI_SFA2AD register provides the address mapping for the serial flash A2.The
difference between QSPI_SFA2AD[TPADA2] and QSPI_SFA1AD[TPADA1] defines
the size of the memory map for serial flash A2.
Write:
• QSPI_SR[IP_ACC] = 0
• QSPI_SR[AHB_ACC] = 0
Address: 21E_0000h base + 184h offset = 21E_0184h
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
TPADA2
Reserved
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
QuadSPI_SFA2AD field descriptions
Field
Description
31–10
TPADA2
Top address for Serial Flash A2. In effect, TPxxAD is the first location of the next memory.
Reserved
This field is reserved.
42.14.25
Serial Flash B1Top Address (QuadSPI_SFB1AD)
The QSPI_SFB1AD register provides the address mapping for the serial flash B1.The
difference between QSPI_SFB1AD[TPADB1] and QSPI_SFA2AD[TPADA2] defines
the size of the memory map for serial flash B1.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3067

<!-- page 3068 -->

Write:
• QSPI_SR[IP_ACC] = 0
• QSPI_SR[AHB_ACC] = 0
Address: 21E_0000h base + 188h offset = 21E_0188h
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
TPADB1
Reserved
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
QuadSPI_SFB1AD field descriptions
Field
Description
31–10
TPADB1
Top address for Serial Flash B1.In effect, TPxxAD is the first location of the next memory.
Reserved
This field is reserved.
42.14.26
Serial Flash B2Top Address (QuadSPI_SFB2AD)
The QSPI_SFB2AD register provides the address mapping for the serial flash B2.The
difference between QSPI_SFB2AD[TPADB2] and QSPI_SFB1AD[TPADB1] defines
the size of the memory map for serial flash B2.
Write:
• QSPI_SR[IP_ACC] = 0
• QSPI_SR[AHB_ACC] = 0
Address: 21E_0000h base + 18Ch offset = 21E_018Ch
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
TPADB2
Reserved
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
QuadSPI_SFB2AD field descriptions
Field
Description
31–10
TPADB2
Top address for Serial Flash B2. In effect, TPxxAD is the first location of the next memory.
Reserved
This field is reserved.
42.14.27
RX Buffer Data Register (QuadSPI_RBDRn)
The QuadSPI_RBDR registers provide access to the individual entries in the RX Buffer.
Refer to Table 42-14 for the byte ordering scheme.
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3068
NXP Semiconductors

<!-- page 3069 -->

QuadSPI_RBDR0 corresponds to the actual position of the read pointer within the RX
Buffer. The number of valid entries available depends from the number of RX Buffer
entries implemented and from the number of valid buffer entries available in the RX
Buffer.
Example 1, RX Buffer filled completely with 32 words: In this case the address range for
valid read access extends from QuadSPI_RBDR0 to QuadSPI_RBDR31.
Example 2, RX Buffer filled with 5 valid words: RX Buffer fill level
QuadSPI_RBSR[RDBFL] is 5. In this case an access to QuadSPI_RBDR4 provides the
last valid entry.
Any access beyond the range of valid RX Buffer entries provides undefined results.
Address: 21E_0000h base + 200h offset + (4d × i), where i=0d to 31d
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
RXDATA
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
QuadSPI_RBDRn field descriptions
Field
Description
RXDATA
RX Data. The RXDATA field contains the data associated with the related RX Buffer entry. Data format
and byte ordering is given in Byte Ordering of Serial Flash Read Data .
42.14.28
LUT Key Register (QuadSPI_LUTKEY)
The LUT Key register contains the key to lock and unlock the Look-up-table. Refer to
Look-up Table for details.
Write:Anytime
Address: 21E_0000h base + 300h offset = 21E_0300h
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
KEY
W
Reset 0
1
0
1
1
0
1
0
1
1
1
1
0
0
0
0
0
1
0
1
1
0
1
0
1
1
1
1
0
0
0
0
QuadSPI_LUTKEY field descriptions
Field
Description
KEY
The key to lock or unlock the LUT. The KEY is 0x5AF05AF0. The read value is always 0x5AF05AF0
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3069

<!-- page 3070 -->

42.14.29
LUT Lock Configuration Register (QuadSPI_LCKCR)
The LUT lock configuration register is used along with QSPI_LUTKEY register to lock
or unlock the LUT. This register has to be written immediately after QSPI_LUTKEY
register for the lock or unlock operation to be successful. Refer to Look-up Table for
details. Setting both the LOCK and UNLOCK bits as "00" or "11" is not allowed.
Write:Just after writing the LUT Key Register
(QSPI_LUTKEY)
Address: 21E_0000h base + 304h offset = 21E_0304h
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
Reserved
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
Reserved
UNLOCK
LOCK
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
1
0
QuadSPI_LCKCR field descriptions
Field
Description
31–2
Reserved
This field is reserved.
1
UNLOCK
Unlocks the LUT when the following two conditions are met:
1. This register is written just after the LUT Key Register (QuadSPI_LUTKEY)
2. The LUT key register was written with 0x5AF05AF0 key
0
LOCK
Locks the LUT when the following condition is met:
1. This register is written just after the LUT Key Register (QuadSPI_LUTKEY)
2. The LUT key register was written with 0x5AF05AF0 key
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3070
NXP Semiconductors

<!-- page 3071 -->

42.14.30
Look-up Table register (QuadSPI_LUT0)
The LUT registers are a look-up-table for sequences of instructions. The programmable
sequence engine executes the instructions in these sequences to generate a valid serial
flash transaction. There are a total of 64 LUT registers. These 64 registers are divided
into groups of 4 registers that make a valid sequence. Therefore, QSPI_LUT[0],
QSPI_LUT[4], QSPI_LUT[8] ..... QSPI_LUT[60] are the starting registers of a valid
sequence. Each of these sets of 4 registers can have a maximum of 8 instructions. A
maximum of 16 sequences can be defined at one time. Look-up Table describes the LUT
registers in detail.
Write:Once the LUT is unlocked
Address: 21E_0000h base + 310h offset = 21E_0310h
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
INSTR1
PAD1
OPRND1
W
Reset
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
1
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
INSTR0
PAD0
OPRND0
W
Reset
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
1
1
QuadSPI_LUT0 field descriptions
Field
Description
31–26
INSTR1
Instruction 1
25–24
PAD1
Pad information for INSTR1.
00
1 Pad
01
2 Pads
10
4 Pads
11
NA
23–16
OPRND1
Operand for INSTR1.
15–10
INSTR0
Instruction 0
9–8
PAD0
Pad information for INSTR0.
00
1 Pad
01
2 Pads
10
4 Pads
11
NA
OPRND0
Operand for INSTR0.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3071

<!-- page 3072 -->

42.14.31
Look-up Table register (QuadSPI_LUT1)
The LUT registers are a look-up-table for sequences of instructions. The programmable
sequence engine executes the instructions in these sequences to generate a valid serial
flash transaction. There are a total of 64 LUT registers. These 64 registers are divided
into groups of 4 registers that make a valid sequence. Therefore, QSPI_LUT[0],
QSPI_LUT[4], QSPI_LUT[8] ..... QSPI_LUT[60] are the starting registers of a valid
sequence. Each of these sets of 4 registers can have a maximum of 8 instructions. A
maximum of 16 sequences can be defined at one time. Look-up Table describes the LUT
registers in detail.
Write:Once the LUT is unlocked
Address: 21E_0000h base + 314h offset = 21E_0314h
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
INSTR1
PAD1
OPRND1
W
Reset
0
0
1
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
INSTR0
PAD0
OPRND0
W
Reset
0
0
0
1
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
QuadSPI_LUT1 field descriptions
Field
Description
31–26
INSTR1
Instruction 1
25–24
PAD1
Pad information for INSTR1.
00
1 Pad
01
2 Pads
10
4 Pads
11
NA
23–16
OPRND1
Operand for INSTR1.
15–10
INSTR0
Instruction 0
9–8
PAD0
Pad information for INSTR0.
00
1 Pad
01
2 Pads
10
4 Pads
11
NA
OPRND0
Operand for INSTR0.
Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3072
NXP Semiconductors

<!-- page 3073 -->

42.14.32
Look-up Table register (QuadSPI_LUTn)
The LUT registers are a look-up-table for sequences of instructions. The programmable
sequence engine executes the instructions in these sequences to generate a valid serial
flash transaction. There are a total of 64 LUT registers. These 64 registers are divided
into groups of 4 registers that make a valid sequence. Therefore, QSPI_LUT[0],
QSPI_LUT[4], QSPI_LUT[8] ..... QSPI_LUT[60] are the starting registers of a valid
sequence. Each of these sets of 4 registers can have a maximum of 8 instructions. A
maximum of 16 sequences can be defined at one time. Look-up Table describes the LUT
registers in detail.
Write:Once the LUT is unlocked
Address: 21E_0000h base + 318h offset + (4d × i), where i=0d to 61d
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
INSTR1
PAD1
OPRND1
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
INSTR0
PAD0
OPRND0
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
QuadSPI_LUTn field descriptions
Field
Description
31–26
INSTR1
Instruction 1
25–24
PAD1
Pad information for INSTR1.
00
1 Pad
01
2 Pads
10
4 Pads
11
NA
23–16
OPRND1
Operand for INSTR1.
15–10
INSTR0
Instruction 0
9–8
PAD0
Pad information for INSTR0.
00
1 Pad
01
2 Pads
10
4 Pads
11
NA
OPRND0
Operand for INSTR0.
Chapter 42 Quad Serial Peripheral Interface (QuadSPI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3073

<!-- page 3074 -->

Peripheral Bus Register Descriptions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3074
NXP Semiconductors

