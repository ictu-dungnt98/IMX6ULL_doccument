# Chapter 56: Universal Serial Bus Controller (USB)

> Nguồn: `IMX6ULLRM.pdf` — trang 3641–3900

<!-- page 3641 -->

Chapter 56
Universal Serial Bus Controller (USB)
56.1
Overview
The USB controller block provides high performance USB functionality that conforms to
the Universal Serial Bus Specification, Rev. 2.0 (Compaq, Hewlett-Packard, Intel,
Lucent, Microsoft, NEC, Philips; 2000), and the On-The-Go and Embedded Host
Supplement to the USB Revision 2.0 Specification (Hewlett-Packard Company, Intel
Corporation, LSI Corporation, Microsoft Corporation, Renesas Electronics Corporation,
ST-Ericsson; 2012).
The USB controller consists of independent USB controller cores: two On-The-Go
(OTG) controller cores. Each controller core supports UTMI interface. See Features for
more details. controller cores are single-port cores. For the OTG cores, there is only one
port. The port can be used as either a downstream or an upstream port.
The following figure is a block diagram of USB.
56.1.1
Features
There are USB 2.0 controller cores in this chip:
• Controller Core 0 is also named 'OTG1 Core'; its connected port is named 'OTG1
port'.
• Controller Core 1 is also named 'OTG2 Core'; its connected port is named 'OTG2
port'.
The following list provides features of each of the controller cores.
• USB 2.0 Controller Core 0
• High-Speed/Full-Speed/Low-Speed OTG core
• HS/FS/LS UTMI compliant interface
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3641

<!-- page 3642 -->

• High Speed, Full Speed and Low Speed operation in Host mode (with UTMI
transceiver)
• High Speed, and Full Speed operation in Peripheral mode (with UTMI
transceiver)
• Hardware support for OTG signaling, session request protocol, and host
negotiation protocol
• Up to 8 bidirectional endpoints
• Support charger detection
• USB 2.0 Controller Core 1
• High-Speed/Full-Speed/Low-Speed OTG core
• HS/FS/LS UTMI compliant interface
• High Speed, Full Speed and Low Speed operation in Host mode (with UTMI
transceiver)
• High Speed, and Full Speed operation in Peripheral mode (with UTMI
transceiver)
• Hardware support for OTG signaling, session request protocol, and host
negotiation protocol
• Up to 8 bidirectional endpoints
• Low-power mode with local and remote wake-up capability
• Serial PHY interfaces configurable for bidirectional/unidirectional and differential/
single ended
• Embedded DMA controller in each core
56.1.2
Modes of Operation
The USB has two main modes of operation: normal mode and low power mode.
Each USB OTG controller core can operate in High Speed operation (480 Mbps), Full
Speed operation (12 Mbps) and Low Speed operation (1.5 Mbps).
This chapter explains the operation modes.
56.1.2.1
Normal Mode
The OTG controller core can operate in Host mode and Device (Peripheral) mode. The
Host-only controller core can operate in Host mode only.
Each USB controller core has its corresponding port, which can work in one or more
interface modes.
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3642
NXP Semiconductors

<!-- page 3643 -->

NOTE
Each controller supports only the interface type listed below.
Selecting a different interface type in the PORTSC.PTS field
results in unpredictable behavior and may cause the system to
hang.
• OTG1 port
• This port supports on-chip UTMI transceiver only.
• OTG2 port
• This port supports on-chip UTMI transceiver only.
NOTE
HSIC is an inter-chip interface that is optimized for circuit
board layouts.
56.1.2.2
Low-Power Mode
Each USB controller core has a low-power mode (Suspend mode) to save power
consumption.
As described in the USB 2.0 specification, the device can go into the Suspend state after
it sees a constant Idle state on the upstream facing port. The OTG controller core enters
Suspend mode after 3 ms of inactivity on the port when it is in Device Operation mode.
Host controllers, including the OTG controller in Host mode, do not suspend
automatically but can be placed in Suspend mode by software.
Either the local ARM platform or the remote USB Host/Peripheral can initiate a wake-up
sequence to resume USB communication. For details about Suspend/Resume, see USB
Power Control.
56.2
External Signals
The table found here describes the external signals of USB.
Table 56-1. USB External Signals
Signal
Description
Pad
Mode
Direction
USB_OTG1_ID
ID signal
GPIO1_IO00
ALT2
I
SD1_DATA0
ALT8
UART3_TX_DATA
ALT8
USB_OTG1_OC
OTG External input for VBUS
overcurrent detection
ENET2_RX_DATA1
ALT8
I
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3643

<!-- page 3644 -->

Table 56-1. USB External Signals
(continued)
Signal
Description
Pad
Mode
Direction
GPIO1_IO01
ALT2
SD1_CLK
ALT8
USB_OTG1_PWR
To control PMIC to supply VBUS
voltage
ENET2_RX_DATA0
ALT8
O
GPIO1_IO04
ALT2
SD1_CMD
ALT8
USB_OTG2_ID
ID signal
ENET2_TX_CLK
ALT8
I
GPIO1_IO05
ALT2
SD1_DATA3
ALT8
USB_OTG2_OC
OTG External input for VBUS
overcurrent detection
ENET2_TX_EN
ALT8
I
GPIO1_IO03
ALT2
SD1_DATA2
ALT8
USB_OTG2_PWR
To control PMIC to supply VBUS
voltage
ENET2_TX_DATA1
ALT8
O
GPIO1_IO02
ALT2
SD1_DATA1
ALT8
56.3
Functional Description
These sections describe the functionality of the various building blocks of the USB.
56.3.1
USB 2.0 Controller Core 0
The USB 2.0 Controller 0 is an instantiation of an EHCI-compatible core which supports
high-, full-, and low-speed operation.
In Host mode, this controller core supports high-, full-, and low-speed operation. In
Device mode, it supports high- and full-speed operation.
56.3.1.1
Host Mode
The controller supports direct connection of .
Although there is no separate Transaction Translator block in the system, the transaction
translator function normally associated with a USB 2.0 high speed hub has been
implemented within the DMA and protocol engine blocks to support connection to full
and low speed devices.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3644
NXP Semiconductors

<!-- page 3645 -->

56.3.1.2
Peripheral (Device) Mode
• Up to eight bidirectional endpoints
• High/full-speed operation
• Support of HNP and SRP
• Remote wake-up capability
56.3.2
USB 2.0 Controller Core 1
USB 2.0 Controller Core 1 is an instantiation of EHCI-compatible core which supports
High Speed / Full Speed / Low Speed operation with ULPI interface. It also supports
High Speed operation with HSIC interface.
This USB core's signals connect directly to I/O pins (HSIC interface).
56.3.3
USB Power Control
The USB controller supports suspend and wake-up functionality.
The power control block allows for placing the transceiver in USB low power mode
when USB bus is IDLE, and supports local and remote wake-up to bring the transceiver
out of USB low power mode when needed. Additionally, the power control block can
wake-up the Arm platform from core sleep mode by generating an interrupt.
56.3.3.1
Entering Low Power Suspend Mode
In Host operation mode, low power suspend mode is entered as follows:
1. Clear the ASE and PSE bits in USB_USBCMD, and wait until the AS and PS bits in
USB_USBSTS become "0".
2. Set the "SUSPEND" bit in USB_PORTSC1
3. Set the "PHCD" bit in USB_PORTSC1
4. Set all PWD bits in USBPHYx_PWD
5. Set CLKGATE in USBPHYx_CTRL
NOTE
Step 3,4,5 shall be done in atomic operation. That is, interrupt
should be disabled during these three steps.
For device operation mode, low power suspend mode is entered as follows:
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3645

<!-- page 3646 -->

1. After Host drive is IDLE for 3ms, an SLI interrupt is issued (the "DCSUSPEND" or
"SLI" bit in USB_USBSTS)
2. Set the "PHCD" bit on USB_PORTSC1
3. Set all PWD bits in USBPHYx_PWD
4. Set CLKGATE in USBPHYx_CTRL
NOTE
Step 2,3,4 shall be done in atomic operation. That is, interrupt
should be disabled during these three steps.
56.3.3.2
Wake-Up Events
The power control block monitors the USB bus when the USB core is in the USB
suspend state.
Depending on whether the core is on Host or Device mode, a number of wake-up
conditions are monitored. Upon detection of a wake-up condition, an interrupt
(asynchronous) will be generated to Arm platform if the related wake-up interrupt enable
bit is set.
USB wake-up interrupt also re-activates the Arm platform clocks if they were stopped
during the suspend.
56.3.3.2.1
Host Mode Events
The host controller wakes up on the following events:
• Remote Wake-up Request
A peripheral can request the host to reactivate the bus by driving wake-up signaling on
the DM/DP lines. The power control block sends a wake-up request to the USB core
when a J-K transition on DM/DP line is detected.
• Wake-Up On Overcurrent
If Wake-Up On Overcurrent is enabled (WKOC bit in the USB core register PORTSC1 is
set '1'), the power control block sends a wake-up request to the USB core when an
overcurrent event is detected.
• Wake-Up On Disconnect
If Wake-Up On Disconnect is enabled (WKDC bit in the USB core register PORTSC1 is
set '1'), the power control block sends a wake-up request to the USB core when a
disconnection event is detected (J-SE0/K-SE0 transition on DM/DP line).
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3646
NXP Semiconductors

<!-- page 3647 -->

• Wake-Up On Connect
If a Wake-Up On Connect is enabled (WKCN bit in the USB core register PORTSC1 is
set '1'), the power control sub-block sends a wake-up request to the USB core when the
connection event is detected (SE0-J/SE0-K transition on DM/DP line).
For a detailed description of register bits WKOC, WKDC, WKCN, please see Port Status
& Control (USB_nPORTSC1).
56.3.4
Interrupts
56.3.4.1
USB Core Interrupts
Each USB core uses one dedicated vector in the Interrupt Table. The vector numbers
associated with each of the cores can be found in the Interrupt section.
With the exception of the wake-up interrupts, all of the interrupt sources are controlled in
the USB Cores. Refer to the Interrupt Enable Register (USB_nUSBINTR) for details.
56.3.4.2
USB Wake-Up Interrupts
Each USB Core has an associated wake-up interrupt. The wake-up interrupts are
generated outside of the USB controller cores, but using the same vector as the
corresponding USB controller cores interrupt.
These interrupts are generated by the Power Control blocks which run on the 32 KHz
standby clock. The wake-up interrupt is designed to work even when the USB and Arm
platform clocks are disabled, such that a wake-up condition on the USB bus can re-
activate the Arm platform clocks.
Because the wake-up interrupt is generated and cleared on a 32 KHz clock, this interrupt
request responds very slowly to clear actions. For this reason, the software must disable
the wake-up interrupt to clear the request flag. Disabling the interrupt masks the request
instantaneously as this is clocked by the Arm platform clock. The software should wait
for at least three 32 KHz clock cycles before re-enabling this interrupt to allow sufficient
time for the request flag to clear. Because this interrupt is only used during low power
modes of the USB, it is sufficient to enable the wake-up interrupt just prior to entering
the USB suspend mode.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3647

<!-- page 3648 -->

56.4
USB Operation Model
This section describes the detailed application knowledge for OTG1 and OTG2 ports.
56.4.1
Register Interface
Configuration, control and status registers are divided into three categories, identification,
capability and operational registers.
NOTE
USB controller registers support only DWORD (32-bit) access.
• Identification registers are used to declare the slave interface presence along with the
complete set of the hardware configuration parameters.
• Static, read only capability registers define the software limits, restrictions, and
capabilities of the host/device controller.
• Operational registers are dynamic control or status registers that may be read only,
read/write, or read/write-to-clear. The following sections define the use of these
registers.
EHCI registers are listed alongside device registers to show the complementary nature of
host and device control.
The following table describes the Interface register sets.
Table 56-2. Interface Register Sets
Offset
Register Set
Explanation
000h-07Ch
Identification Registers
Identification registers are used to declare the slave interface presence and
include a table of the hardware configuration parameters.
100h-124h
Capability Registers
Capability registers specify the limits, restrictions, and capabilities of a host/
device controller implementation.
These values are used as parameters to the host/device controller driver.
080h-0FCh
140h-1FCh
Operational Registers
Operational registers are used by the system software to control and monitor
the operational state of the host/device controller.
56.4.1.1
Configuration, Control and Status Register Set
The following table describes the Device/Host capability registers.
NOTE
Depending on implementation, "x" can have the following
values: UOG1, UOG2.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3648
NXP Semiconductors

<!-- page 3649 -->

.
Table 56-3. Device/Host Capability Registers
Offset
Size
(Bytes)
Mnemonic
Register Name
Device
Mode
Host
Mode
000h
4
USB_x_ID
Identification Register
O
O
004h
4
USB_x_HWGENERAL
General Hardware Parameters
O
O
008h
4
USB_x_HWHOST
Host Hardware Parameters
X
O
00Ch
4
USB_x_HWDEVICE
Device Hardware Parameters
O
X
010h
4
USB_x_HWTXBUF
TX Buffer Hardware Parameters
O
O
014h
4
USB_x_HWRXBUF
RX Buffer Hardware Parameters
O
O
018-07Fh
-
Reserved
080h
4
USB_x_GPTIMER0LD
General Purpose Timer #0 Load Register
O
O
084h
4
USB_x_GPTIMER0CTR
L
General Purpose Timer #0 Control Register
O
O
088h
4
USB_x_GPTIMER1LD
General Purpose Timer #1 Load Register
O
O
08Ch
4
USB_x_GPTIMER1CTR
L
General Purpose Timer #1 Control Register
O
O
090h
4
USB_x_SBUSCFG
System Bus Interface Configuration Register
O
O
094-09Fh
-
Reserved
100h
1
USB_x_CAPLENGTH
Capability Register Length
O
O
101h
-
Reserved
102h
2
USB_x_HCIVERSION
Host Controller Interface Version Number
X
O
104h
4
USB_x_HCSPARAMS
Host Controller Structural Parameters
X
O
108h
4
USB_x_HCCPARAMS
Host Controller Capability Parameters
X
O
10C-11Fh
-
Reserved
120h
2
USB_x_DCIVERSION
Device Controller Interface Version Number
O
X
122h
2
-
Reserved
124h
4
USB_x_DCCPARAMS
Device Controller Capability Parameters
O
X
128-13Fh
-
Reserved
140h
4
USB_x_USBCMD
USB Command Register
O
O
144h
4
USB_x_USBSTS
USB Status Register
O
O
148h
4
USB_x_USBINTR
USB Interrupt Enable Register
O
O
14Ch
4
USB_x_FRINDEX
USB Frame Index
O
O
150h
4
-
Reserved
154h
4
USB_x_PERIODICLISTB
ASE
Frame List Base Address
X
O
USB_x_DEVICEADDR
USB Device Address
O
X
158h
4
USB_x_ASYNCLISTADD
R
Next Asynchronous List Address
X
O
4
USB_x_ENDPOINTLIST
ADDR
Address at Endpoint list in memory
O
X
15Ch
4
-
Reserved
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3649

<!-- page 3650 -->

Table 56-3. Device/Host Capability Registers (continued)
Offset
Size
(Bytes)
Mnemonic
Register Name
Device
Mode
Host
Mode
160h
4
USB_x_BURSTSIZE
Programmable Burst Size
O
O
164h
4
USB_x_TXFILLTUNING
Host Transmit Pre-Buffer Packet Tuning
X
O
168h
4
-
Reserved
170h
4
-
Reserved
178h
4
USB_x_ENDPTNAK
Endpoint NAK register
O
X
17Ch
4
USB_x_ENDPTNAKEN
Endpoint NAK Enable register
O
X
180h
4
USB_x_CONFIGFLAG
Configured Flag Register
X
O
184h
4
USB_x_PORTSC1
Port Status/Control Register 1
O
O
188-1A3h
-
Reserved
1A4h
4
USB_x_OTGSC
On-The-Go Status/Control Register (OTG only)
O
O
1A8h
4
USB_x_USBMODE
USB Controller Operating Mode
O
O
1ACh
4
USB_x_ENDPTSETUPS
TAT
Endpoint Setup Status
O
X
1B0h
4
USB_x_ENDPTPRIME
Endpoint Initialization
O
X
1B4h
4
USB_x_ENDPTFLUSH
Endpoint De-Initialization
O
X
1B8h
4
USB_x_ENDPTSTATUS
Endpoint Status
O
X
1BCh
4
USB_x_ENDPTCOMPLE
TE
Endpoint Complete
O
X
1C0
1C4
...
1DCh
64
USB_x_ENDPTCTRL0
USB_x_ENDPTCTRL1
....
USB_x_ENDPTCTRL7
Endpoint Control Register 0-7
O
X
NOTE
"O" means the register is available in host/device operation
mode;
"X" means the register is reserved in host/device operation
mode
56.4.1.2
Identification Registers
Identification registers are used to declare the slave interface presence and include a table
of the hardware configuration parameters.
56.4.1.3
OTG Operations
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3650
NXP Semiconductors

<!-- page 3651 -->

56.4.1.3.1
Register Bits
In the previous section, the Register interface has behaviors described for device mode
and behaviors described for host mode. However, for OTG operations it is necessary to
perform tasks independent of the controller mode.
NOTE
The only way to transit the controller mode out of host or
device mode is with the controller reset bit. Therefore, it is also
necessary for the OTG tasks to be performed independent of a
controller reset as well as independent of the controller mode.
The following figure shows the controller mode.
Idle (00)
Device (10)
Host (11)
Write "10" to
USBMODE
Write "11" to
USBMODE
Hardware Reset or
USBCMD.Reset = 1
Figure 56-1. Controller Mode
To this end, listed below are the register bits that are used for OTG operations, which are
independent of the controller mode and are also not affected by a write to the reset bit in
the USBCMD register:
All Identification Registers
All Device/Host Capability Registers
OTGSC: All bits
PORTSC1:
Physical Interface Select
Physical Interface Serial Select
Physical Interface Data Width
Physical Interface Low Power
Physical Interface Wake Signals
Port Indicators
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3651

<!-- page 3652 -->

Port Power
56.4.2
Host Data Structures
This section defines the interface data structures used to communicate control, status, and
data between HCD (software) and the Enhanced Host Controller (hardware).
The data structure definitions in this chapter support a 32-bit memory buffer address
space. The interface consists of a Periodic Schedule, Periodic Frame List, Asynchronous
Schedule, Isochronous Transaction Descriptors, Split-transaction Isochronous Transfer
Descriptors, Queue Heads, and Queue Element Transfer Descriptors.
The periodic frame list is the root of all periodic (isochronous and interrupt transfer type)
transfers for the host controller. The asynchronous list is the root for all the bulk and
control transfers. Isochronous data streams are managed using Isochronous Transaction
Descriptors. Isochronous split-transaction data streams are managed with Split-
transaction Isochronous Transfer Descriptors. All Interrupt, Control, and Bulk data
streams are managed via queue heads and Queue Element Transfer Descriptors. These
data structures are optimized to reduce the total memory footprint of the schedule and to
reduce (on average) the number of memory accesses needed to execute a USB
transaction.
Note that software must ensure that no interface data structure reachable by the EHCI
host controller spans a 4 K-page boundary.
The data structures defined in this section are (from the host controller's perspective) a
mix of read-only and read/writeable fields. The host controller must preserve the read-
only fields on all data structure writes.
56.4.2.1
Periodic Frame List
This schedule is for all periodic transfers (isochronous and interrupt). The periodic
schedule is referenced from the operational registers space using the
USB_PERIODICLISTBASE address register and the USB_FRINDEX register.
The periodic schedule is based on an array of pointers called the Periodic Frame List.
The USB_PERIODICLISTBASE address register is combined with the USB_FRINDEX
register to produce a memory pointer into the frame list. The Periodic Frame List
implements a sliding window of work over time.
The following figure shows the organization of periodic schedule.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3652
NXP Semiconductors

<!-- page 3653 -->

A
A
A
A
A
A
A
.
.
.
Periodic Frame
List
1024, 512, or 256
elements
Periodic Frame
List Element
Address
FRINDEX
PeriodicList Base
Operational
Registers
8
4
1
.
.
.
A
Isochronous Transfer
Descriptor(s)
.
.
.
Interrupt Queue]
Heads
Poll Rate: N ---> 1
Last Periodic
has end of
List Mark
Figure 56-2. Periodic Schedule Organization
Split transaction Interrupt, Bulk and Control are also managed using queue heads and
queue element transfer descriptors.
The periodic frame list is a 4 K-page aligned array of Frame List Link pointers. The
length of the frame list may be programmable. The programmability of the periodic
frame list is exported to system software via the USB_HCCPARAMS register. If non-
programmable, the length is 1024 elements. If programmable, the length can be selected
by system software as one of 256, 512, or 1024 elements. An implementation must
support all three sizes. Programming the size (that is, the number of elements) is
accomplished by system software writing the appropriate value into Frame List Size field
in the USB_USBCMD register.
Frame List Link pointers direct the host controller to the first work item in the frame's
periodic schedule for the current micro-frame. The link pointers are aligned on DWord
boundaries within the Frame List.
The table below illustrates the format of the Frame list element pointer.
Table 56-4. Format of Frame List Element Pointer
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9
8
7
6
5
4
3
2
1
0
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3653

<!-- page 3654 -->

Table 56-4. Format of Frame List Element Pointer (continued)
Frame List Link Pointer
0
Typ
03-00H
Frame List Link pointers always reference memory objects that are 32-byte aligned. The
referenced object may be an isochronous transfer descriptor for high-speed devices, a
split-transaction isochronous transfer descriptor (for full-speed isochronous endpoints), or
a queue head (used to support high-, full- and low-speed interrupt). System software
should not place non-periodic schedule items into the periodic schedule. The least
significant bits in a frame list pointer are used to key the host controller as to the type of
object the pointer is referencing.
The least significant bit is the T-Bit (bit 0). When this bit is set to a one, the host
controller never uses the value of the frame list pointer as a physical memory pointer. The
Typ field is used to indicate the exact type of data structure being referenced by this
pointer. The value encodings are.
Table 56-5. Typ Field Value Definitions
Value
Meaning
00b
Isochronous Transfer Descriptor
01b
Queue Head
10b
Split Transaction Isochronous Transfer Descriptor.
11b
Frame Span Traversal Node.
56.4.2.2
Asynchronous List Queue Head Pointer
The Asynchronous Transfer List (based at the USB_ASYNCLISTADDR register) is
where all of the control and bulk transfers are managed.
Host controllers use this list only when it reaches the end of the periodic list, the periodic
list is disabled, or the periodic list is empty.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3654
NXP Semiconductors

<!-- page 3655 -->

AsynListAddr
Operational
Registers
H
Bulk/Control Queue Heads
Figure 56-3. Asynchronous Schedule Organization
The Asynchronous list is a simple circular list of queue heads. The
USB_ASYNCLISTADDR register is simply a pointer to the next queue head. This
implements a pure round-robin service for all queue heads linked into the asynchronous
list.
56.4.2.3
Isochronous (High-Speed) Transfer Descriptor (iTD)
The format of an isochronous transfer descriptor is shown in the table below.
This structure is used only for high-speed isochronous endpoints. All other transfer types
should use queue structures. Isochronous TDs must be aligned on a 32-byte boundary.
Table 56-6. Isochronous Transaction Descriptor (iTD)
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9
8
7
6
5
4
3
2
1
0
Next Link Pointer
0
Typ
T
03-00
H
Status
Transaction 0 Length
IO
C
PG*
Transaction 0 Offset*
07-04
H
Status
Transaction 1 Length
IO
C
PG*
Transaction 1 Offset*
0B-0
8H
Status
Transaction 2 Length
IO
C
PG*
Transaction 2 Offset*
0F-0
CH
Status
Transaction 3 Length
IO
C
PG*
Transaction 3 Offset*
13-10
H
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3655

<!-- page 3656 -->

Table 56-6. Isochronous Transaction Descriptor (iTD) (continued)
Status
Transaction 4 Length
IO
C
PG*
Transaction 4 Offset*
17-14
H
Status
Transaction 5 Length
IO
C
PG*
Transaction 5 Offset*
1B-1
8H
Status
Transaction 6 Length
IO
C
PG*
Transaction 6 Offset*
1F-1
CH
Status
Transaction 7 Length
IO
C
PG*
Transaction 7 Offset*
23-20
H
Buffer Pointer (Page 0)
EndPt
R
Device Address
27-24
H
Buffer Pointer (Page 1)
I/
O
Maximum Packet Size
2B-2
8H
Buffer Pointer (Page 2)
-
Mult
2F-2
CH
Buffer Pointer (Page 3)
-
33-30
H
Buffer Pointer (Page 4)
-
37-34
H
Buffer Pointer (Page 5)
-
3B-3
8H
Buffer Pointer (Page 6)
-
3F-3
CH
Host Controller Read/Write
Host Controller Read Only
These fields may be modified by the host controller if the I/O field indicates an OUT.
56.4.2.3.1
Next Link Pointer
The first DWord of an iTD is a pointer to the next schedule data structure.
The following table describes the Next Schedule Element pointer field.
Table 56-7. Next Schedule Element Pointer
Bit
Description
31-5
Link Pointer (LP)
These bits correspond to memory address signals [31:5], respectively. This field points to another
Isochronous Transaction Descriptor (iTD/siTD) or Queue Head (QH).
4-3
These bits are reserved and their value has no effect on operation. Software should initialize this field to
zero.
Table continues on the next page...
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3656
NXP Semiconductors

<!-- page 3657 -->

Table 56-7. Next Schedule Element Pointer (continued)
Reserved
2-1
QH/(s)iTD Select
(Typ)
This field indicates to the Host Controller whether the item referenced is an iTD, siTD or a QH. This allows
the Host Controller to perform the proper type of processing on the item after it is fetched. Value
encodings are:
Value Meaning 00b iTD (isochronous transfer descriptor) 01b QH (queue head) 10b siTD (split transaction
isochronous transfer descriptor 11b FSTN (frame span traversal node)
0
Terminate (T)
1= Link Pointer field is not valid. 0= Link Pointer field is valid.
56.4.2.3.2
iTD Transaction Status and Control List
DWords 1 through 8 are eight slots of transaction control and status.
Each transaction description includes:
• Status results field
• Transaction length (bytes to send for OUT transactions and bytes received for IN
transactions).
• Buffer offset. The PG and Transaction X Offset fields are used with the buffer
pointer list to construct the starting buffer address for the transaction.
The host controller uses the information in each transaction description plus the endpoint
information contained in the first three DWords of the Buffer Page Pointer list, to execute
a transaction on the USB.
The following table describes iTD Transaction Status and Control fields.
Table 56-8. iTD Transaction Status and Control
Bit
Description
31-28
Status
This field records the status of the transaction executed by the host controller for this slot. This field is a bit
vector with the following encoding:
Bit
Definition
31
Active. Set to one by software to enable the execution of an isochronous transaction by the Host
Controller. When the transaction associated with this descriptor is completed, the Host Controller
sets this bit to zero indicating that a transaction for this element should not be executed when it is
next encountered in the schedule.
30
Data Buffer Error. Set to a one by the Host Controller during status update to indicate that the Host
Controller is unable to keep up with the reception of incoming data (overrun) or is unable to supply
data fast enough during transmission (under run). If an overrun condition occurs, no action is
necessary.
29
Babble Detected. Set to one by the Host Controller during status update when" babble" is detected
during the transaction generated by this descriptor.
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3657

<!-- page 3658 -->

Table 56-8. iTD Transaction Status and Control (continued)
Bit
Description
28
Transaction Error (XactErr). Set to one by the Host Controller during status update in the case
where the host did not receive a valid response from the device (Timeout, CRC, Bad PID, etc.).
This bit may only be set for isochronous IN transactions.
27-16
Transaction X
Length
For an OUT, this field is the number of data bytes the host controller sends during the transaction. The
host controller is not required to update this field to reflect the actual number of bytes transferred during the
transfer. For an IN, the initial value of the endpoint to deliver. During the status update, the host controller
writes back the field is the number of bytes the host expects the number of bytes successfully received.
The value in this register is the actual byte count (0‡zero length data, 1‡one byte, 2‡two bytes, etc.). The
maximum value this field may contain is 0xC00 (3072).
15
Interrupt On
Complete (IOC)
If this bit is set to one, it specifies that when this transaction completes, the Host Controller should issue an
interrupt at the next interrupt threshold.
14-12
Page Select
(PG)
These bits are set by software to indicate which of the buffer page pointers the offset field in this slot
should be concatenated to produce the starting memory address for this transaction. The valid range of
values for this field is 0 to 6.
11-0
Transaction X
Offset
This field is a value that is an offset, expressed in bytes, from the beginning of a buffer. This field is
concatenated onto the buffer page pointer indicated in the adjacent PG field to produce the starting buffer
address for this transaction.
56.4.2.3.3
iTD Buffer Page Pointer List (Plus)
DWords 9-15 of an isochronous transaction descriptor are nominally page pointers (4 K
aligned) to the data buffer for this transfer descriptor. This data structure requires the
associated data buffer to be contiguous (relative to virtual memory), but allows the
physical memory pages to be non-contiguous.
Seven page pointers are provided to support the expression of eight isochronous transfers.
The seven pointers allow for 3 (transactions) * 1024 (maximum packet size) * 8
(transaction records) (24576 bytes) to be moved with this data structure, regardless of the
alignment offset of the first page.
Because each pointer is a 4 K aligned page pointer, the least significant 12 bits in several
of the page pointers are used for other purposes.
The tables below illustrate the field descriptions.
Table 56-9. iTD Buffer Pointer Page 0 (Plus)
Bit
Description
31-12
Buffer Pointer (Page 0)
This is a 4 K aligned pointer to physical memory. Corresponds to memory address bits
[31:12].
11-8
Endpoint Number (Endpt)
This 4-bit field selects the particular endpoint number on the device serving as the data
source or sink.
Table continues on the next page...
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3658
NXP Semiconductors

<!-- page 3659 -->

Table 56-9. iTD Buffer Pointer Page 0 (Plus) (continued)
Bit
Description
7
Reserved
Bit reserved for future use and should be initialized by software to zero.
6-0
Device Address
This field selects the specific device serving as the data source or sink.
Table 56-10. iTD Buffer Pointer Page 1 (Plus)
Bit
Description
31-12
Buffer Pointer (Page 1)
This is a 4K aligned pointer to physical memory. Corresponds to memory address bits
[31:12].
11
Direction (I/O)
0 = OUT; 1 = IN. This field encodes whether the high-speed transaction should use an IN or
OUT PID.
10-0
Maximum Packet Size
This directly corresponds to the maximum packet size of the associated endpoint
(wMaxPacketSize). This field is used for high-bandwidth endpoints where more than one
transaction is issued per transaction description (per micro-frame). This field is used with the
Multi field to support high-bandwidth pipes. This field is also used for all IN transfers to detect
packet babble. Software should not set a value larger than 1024 (400h). Any value larger
yields undefined results.
Table 56-11. iTD Buffer Pointer Page 2 (Plus)
Bit
Description
31-12
Buffer Pointer
This is a 4K aligned pointer to physical memory. Corresponds to memory address bits
[31:12].
11-2
Reserved
This bit reserved for future use and should be set to zero.
1-0
Multi
This field is used to indicate to the host controller the number of transactions that should be
executed per transaction description (per micro-frame). The valid values are:
Value Meaning
00b Reserved. A zero in this field yields undefined results.
01b One transaction to be issued for this endpoint per micro- frame.
10b Two transactions to be issued for this endpoint per micro- frame.
11b Three transactions to be issued for this endpoint per micro- frame.
Table 56-12. iTD Buffer Pointer Page 3-6
Bit
Description
31-12
Buffer Pointer
This is a 4 K aligned pointer to physical memory. Corresponds to memory address bits
[31:12].
11-0
Reserved
These bits reserved for future use and should be set to zero.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3659

<!-- page 3660 -->

56.4.2.4
Split Transaction Isochronous Transfer Descriptor (siTD)
All Full-speed isochronous transfers through the internal transaction translator are
managed using the siTD data structure. This data structure satisfies the operational
requirements for managing the split transaction protocol.
The following table shows the Split Transaction Isochronous Transfer Descriptor (siTD).
Table 56-13. Split Transaction Isochronous Transfer Descriptor
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9
8
7
6
5
4
3
2
1
0
Addr
Next Link Pointer
0
Typ
T
03-
00
I/
O
Port Number
-
Hub Addr
Reserved
EndPt
-
Device Address
07-
041
Reserved
μFrame C-mask
μFrame S-mask
0B-
081
io
c
P
Reserved
Total Bytes to Transfer
μFrame C-prog-mask
Status
0F-
0C2
Buffer Pointer (Page 0)
Current Offset
13-
102
Buffer Pointer (Page 1)
Reserved
TP
T-count
17-
142
Back Pointer
0
T
1B-
18
1.
04-0B: Static Endpoint State
2.
0C-13: Transfer results
Host Controller Read/Write
Host Controller Read Only
56.4.2.4.1
Next Link Pointer
DWord0 of a siTD is a pointer to the next schedule data structure.
The following table describes the Next Link Pointer fields.
Table 56-14. Next Link Pointer
Bit
Description
31-5
Next Link Pointer (LP). This field contains the address of the next data object to be processed in the periodic
list and corresponds to memory address signals [31:5], respectively.
Table continues on the next page...
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3660
NXP Semiconductors

<!-- page 3661 -->

Table 56-14. Next Link Pointer (continued)
Bit
Description
4-3
Reserved. These bits must be written as zeros.
2-1
QH/(s)iTD Select (Typ). This field indicates to the Host Controller whether the item referenced is an iTD/siTD or
a QH. This allows the Host Controller to perform the proper type of processing on the item after it is fetched.
Value encodings are:
Value Meaning
00b iTD (isochronous transfer descriptor)
01b QH (queue head)
10b siTD (split transaction isochronous transfer descriptor
11b FSTN (frame span traversal node)
0
Terminate (T).
1 = Link Pointer field is not valid. 0 = Link Pointer is valid.
56.4.2.4.2
siTD Endpoint Capabilities/Characteristics
DWords 1 and 2 specify static information about the full-speed endpoint, the addressing
of the parent Companion Controller, and micro-frame scheduling control.
The tables below describe the Endpoint and transaction translator characteristics and
micro-frame schedule control fields.
Table 56-15. Endpoint and Transaction Translator Characteristics
Bit
Description
31
Direction (I/O).0 = OUT; 1 = IN. This field encodes whether the full-speed transaction should be an IN or
OUT.
30-24
Port Number. This field is the port number of the recipient Transaction Translator.
23
Reserved. Bit reserved and should be set to zero.
22-16
Hub Address. This field holds the device address of the Companion Controllers' hub.
15-12
Reserved. Field reserved and should be set to zero.
11-8
Endpoint Number (Endpt). This 4-bit field selects the particular endpoint number on the device serving as the
data source or sink.
7
Reserved. Bit is reserved for future use. It should be set to zero.
6-0
Device Address. This field selects the specific device serving as the data source or sink.
Table 56-16. Micro-frame Schedule Control
Bit
Description
31-16
Reserved. This field reserved for future use. It should be set to zero.
15-8
Split Completion Mask (mFrame C-Mask). This field (along with the Active and SplitX- state fields in the
Status byte) is used to determine during which micro-frames the host controller should execute complete-split
transactions. When the criteria for using this field is met, an all zeros value has undefined behavior. The host
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3661

<!-- page 3662 -->

Table 56-16. Micro-frame Schedule Control (continued)
Bit
Description
controller uses the value of the three low-order bits of the FRINDEX register to index into this bit field. If the
FRINDEX register value indexes to a position where the mFrame C-Mask field is a one, then this siTD is a
candidate for transaction execution. There may be more than one bit in this mask set.
7-0
Split Start Mask (mFrame S-mask). This field (along with the Active and SplitX-state fields in the Status byte)
is used to determine during which micro-frames the host controller should execute start-split transactions. The
host controller uses the value of the three low-order bits of the FRINDEX register to index into this bit field. If
the FRINDEX register value indexes to a position where the mFrame S-mask field is a one, then this siTD is a
candidate for transaction execution. An all zeros value in this field, in combination with existing periodic frame
list has undefined results.
56.4.2.4.3
siTD Transfer State
DWords 3-6 are used to manage the state of the transfer.
The following table describes siTD transfer state fields.
Table 56-17. siTD Transfer Status and Control
Bit
Description
31
Interrupt On Complete (ioc). 0 = Do not interrupt when transaction is complete. 1 = Do interrupt when
transaction is complete. When the host controller determines that the split transaction has completed it asserts
a hardware interrupt at the next interrupt threshold.
30
Page Select (P). Used to indicate which data page pointer should be concatenated with the CurrentOffset field
to construct a data buffer pointer (0 selects Page 0 pointer and 1 selects Page 1). The host controller is not
required to write this field back when the siTD is retired (Active bit transitioned from a one to a zero).
29-26
Reserved. This field reserved for future use and should be set to zero.
25-16
Total Bytes To Transfer. This field is initialized by software to the total number of bytes expected in this transfer.
Maximum value is 1023 (3FFh)
15-8
μFrame Complete-split Progress Mask (C-prog-Mask). This field is used by the host controller to record which
split-completes has been executed.
7-0: Status—This field records the status of the transaction executed by the host controller for this slot. It is a bit
vector with the encoding shown in the following rows.
7
Active. Set to one by software to enable the execution of an isochronous split transaction by the Host
Controller.
6
ERR. Set to a one by the Host Controller when an ERR response is received from the Companion Controller.
5
Data Buffer Error. Set to a one by the Host Controller during status update to indicate that the Host Controller is
unable to keep up with the reception of incoming data (overrun) or is unable to supply data fast enough during
transmission (under run). In the case of an under run, the Host Controller transmits an incorrect CRC (thus
invalidating the data at the endpoint). If an overrun condition occurs, no action is necessary.
4
Babble Detected. Set to a one by the Host Controller during status update when" babble" is detected during the
transaction generated by this descriptor.
3
Transaction Error (XactErr). Set to a one by the Host Controller during status update in the case where the host
did not receive a valid response from the device (Timeout, CRC, Bad PID, etc.). This bit is set only for IN
transactions.
2
Missed Micro-Frame. The host controller detected that a host-induced hold- off caused the host controller to
miss a required complete-split transaction.
Table continues on the next page...
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3662
NXP Semiconductors

<!-- page 3663 -->

Table 56-17. siTD Transfer Status and Control (continued)
Bit
Description
1
Split Transaction State (SplitXstate). The bit encodings are:
Value Meaning
00b Do Start Split.
This value directs the host controller to issue a Start split transaction to the endpoint when a match is
encountered in the S-mask.
01b Do Complete Split.
This value directs the host controller to issue a Complete split transaction to the endpoint when a match is
encountered in the C-mask.
0
Reserved. Bit reserved for future use and should be set to zero.
56.4.2.4.4
siTD Buffer Pointer List (plus)
DWords 4 and 5 are the data buffer page pointers for the transfer. This structure supports
one physical page cross. The most significant 20 bits of each DWord in this section are
the 4 K (page) aligned buffer pointers.
The least significant 12 bits of each DWord are used as additional transfer state. The
following table describes the siTD buffer pointer fields.
Table 56-18. Buffer Page Pointer List (plus)
Bit
Description
31-12
Buffer Pointer List. Bits [31:12] of DWords 4 and 5 are 4 K page aligned physical memory addresses.
These bits correspond to physical address bits [31:12] respectively. The lower 12 bits in each pointer are
defined and used as specified below. The field P (see siTD Transfer State) specifies the current active
pointer.
Bits 11-0
(Page 0)
Current Offset—The 12 least significant bits of the Page 0 pointer are the current byte offset for the current
page pointer (as selected with the page indicator bit (P field). The host controller is not required to write this
field back when the siTD is retired (Active bit transitioned from a one to a zero).
Bits 11-0 (Page 1)—The least significant bits of the Page 1 pointer are split into three subfields as shown in the
following rows.
11-5
(Page 1)
Reserved
4-3
(Page 1)
Transaction position (TP). This field is used with T-count to determine whether to send all, first, middle, or
last with each outbound transaction payload. System software must initialize this field with the appropriate
starting value. The host controller must correctly manage this state during the lifetime of the transfer. The
bit encodings are:
Value Meaning
00b All. The entire full-speed transaction data payload is in this transaction (that is, less than or equal to
188 bytes).
01b Begin. This is the first data payload for a full- speed that is greater than 188 bytes.
10B Mid. This is the middle payload for a full-speed OUT transaction that is larger than 188 bytes.
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3663

<!-- page 3664 -->

Table 56-18. Buffer Page Pointer List (plus) (continued)
Bit
Description
11b End. This is the last payload for a full-speed OUT transaction that was larger than 188 bytes.
2-0
(Page 1)
Transaction count (T-Count). Software initializes this field with the number of OUT start-splits this transfer
requires. Any value larger than 6 is undefined.
56.4.2.4.5
siTD Back Link Pointer
DWord 6 of a siTD is simply another schedule link pointer. This pointer is always zero,
or references a siTD, and it cannot reference any other schedule data structure.
The following table describes the siTD back link pointer fields.
Table 56-19. siTD Back Link Pointer
Bit
Description
31-5
siTD Back Pointer. This field is a physical memory pointer to a siTD.
4-1
Reserved. This field is reserved for future use. It should be set to zero.
0
Terminate (T).
1 = siTD Back Pointer field is not valid.
0 = siTD Back Pointer field is valid.
56.4.2.5
Queue element transfer descriptor (qTD)
This data structure is only used with a queue head. It describes one or more USB
transactions to transfer up to 20480 (5*4096) bytes.
The structure contains two structure pointers used for queue advancement, a DWord of
transfer state, and a five-element array of data buffer pointers.
It is 32 bytes and must be physically contiguous.
The buffer associated with this transfer must be virtually contiguous. The buffer may start
on any byte boundary; however, for optimal utilization of on-chip busses it is
recommended to align the buffers on a 32-byte boundary. A separate buffer pointer list
element must be used for each physical page in the buffer, regardless of whether the
buffer is physically contiguous.
Host controller updates (host controller writes) to stand-alone qTDs only occur during
transfer retirement. References in the following bit field definitions of updates to the qTD
are to the qTD portion of a queue head.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3664
NXP Semiconductors

<!-- page 3665 -->

The following table shows the queue element transfer descriptor data structure.
Table 56-20. Queue element transfer descriptor data structure
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9
8
7
6
5
4
3
2
1
0
Addr
Next qTD Pointer
0
T
03-
00
Alternate Next qTD Pointer
0
T
07-
04
dt
Total Bytes to Transfer
io
c
C_Page
Cerr
PID
Code
Status
0B-
081
Buffer Pointer (page 0)
Current Offset
0F-
0C1
Buffer Pointer (page 1)
Reserved
13-
10
Buffer Pointer (page 2)
Reserved
17-
14
Buffer Pointer (page 3)
Reserved
1B-
18
Buffer Pointer (page 4)
Reserved
1F-
1C
1.
08-0F: Transfer Results
Host Controller Read/Write
Host Controller Read Only
Queue Element Transfer Descriptors must be aligned on 32-byte boundaries.
56.4.2.5.1
Next qTD Pointer
The first DWord of an element transfer descriptor is a pointer to another transfer element
descriptor.
The following table describes Next qTD pointer fields.
Table 56-21. qTD Next Element Transfer Pointer (DWord 0)
Bit
Description
31-5
Next Transfer Element Pointer. This field contains the physical memory address of the next qTD to be
processed. The field corresponds to memory address signals[31:5], respectively.
4-1
Reserved
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3665

<!-- page 3666 -->

Table 56-21. qTD Next Element Transfer Pointer (DWord 0) (continued)
0
Terminate (T). 1= pointer is invalid. 0=Pointer is valid (points to a valid Transfer Element Descriptor). This
bit indicates to the Host Controller that there are no more valid entries in the queue.
56.4.2.5.2
Alternate Next qTD Pointer
The second DWord of a queue element transfer descriptor is used to support hardware-
only advance of the data stream to the next transfer descriptor on short packet. To be
more explicit the host controller always uses this pointer when the current qTD is retired
due to short packet.
The following table describes the TD Alternate Next Element Transfer Pointer field
descriptions.
Table 56-22. TD Alternate Next Element Transfer Pointer (DWord 1)
Bit
Description
31-5
Alternate Next Transfer Element Pointer. This field contains the physical memory address of the next qTD
to be processed in the event that the current qTD execution encounters a short packet (for an IN
transaction). The field corresponds to memory address signals [31:5], respectively.
4-1
Reserved
0
Terminate (T). 1= pointer is invalid. 0=Pointer is valid (points to a valid Transfer Element Descriptor). This
bit indicates to the Host Controller that there are no more valid entries in the queue.
56.4.2.5.3
qTD Token
The third DWord of a queue element transfer descriptor contains most of the information
the host controller requires to execute a USB transaction (the remaining endpoint-
addressing information is specified in the queue head).
NOTE
The field descriptions forward reference fields defined in the
queue head. Where necessary, these forward references are
preceded with a QH notation.
The following table describes the TD Token fields.
Table 56-23. TD Token (DWord 2)
Bit
Description
31
Data Toggle
This is the data toggle sequence bit. The use of this bit depends on the setting of the Data
Toggle Control bit in the queue head.
Table continues on the next page...
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3666
NXP Semiconductors

<!-- page 3667 -->

Table 56-23. TD Token (DWord 2) (continued)
Bit
Description
30-16
Total Bytes to Transfer
This field specifies the total number of bytes to be moved with this transfer descriptor. This
field is decremented by the number of bytes actually moved during the transaction, only on
the successful completion of the transaction. The maximum value software may store in this
field is 5 * 4K (5000H). This is the maximum number of bytes 5 page pointers can access. If
the value of this field is zero when the host controller fetches this transfer descriptor (and the
active bit is set), the host controller executes a zero-length transaction and retires the transfer
descriptor. It is not a requirement for OUT transfers that Total Bytes To Transfer be an even
multiple of QHD.Maximum Packet Length. If software builds such a transfer descriptor for an
OUT transfer, the last transaction is always less than QHD.Maximum Packet Length.
Although it is possible to create a transfer up to 20K this assumes the 1st offset into the first
page is 0. When the offset cannot be predetermined, crossing past the 5th page can be
guaranteed by limiting the total bytes to 16K**. Therefore, the maximum recommended
transfer is 16 K(4000H).
15
Interrupt On Complete (IOC)
If this bit is set to a one, it specifies that when this qTD is completed, the Host Controller
should issue an interrupt at the next interrupt threshold.
14-12
Current Page (C_Page)
This field is used as an index into the qTD buffer pointer list. Valid values are in the range 0H
to 4H. The host controller is not required to write this field back when the qTD is retired.
11-10
Error Counter (CERR)
This field is a 2-bit down counter that keeps track of the number of consecutive Errors
detected while executing this qTD. If this field is programmed with a non-zero value during
set-up, the Host Controller decrements the count and writes it back to the qTD if the
transaction fails. If the counter counts from one to zero, the Host Controller marks the qTD
inactive, sets the Halted bit to a one, and error status bit for the error that caused CERR to
decrement to zero. An interrupt is generated if the USB Error Interrupt Enable bit in the
USBINTR register is set to a one. If HCD programs this field to zero during set-up, the Host
Controller does not count errors for this qTD and there is no limit on the retries of this qTD.
Note that write-backs of intermediate execution state are to the queue head overlay area, not
the qTD.
Transaction Error - Decrement
Data Buffer Error - No Decrement3
Stalled - No Decrement1
Babble Detected - No Decrement1
No Error - No Decrement2
Error
Decrement Counter
1
Detection of Babble or Stall automatically halts the queue head. Thus, count is
not decremented
2
If the EPS field indicates a HS device or the queue head is in the Asynchronous
Schedule (and PIDCode indicates an IN or OUT) and a bus transaction
completes and the host controller does not detect a transaction error, then the
host controller should reset CERR to extend the total number of errors for this
transaction. For example, CERR should be reset with maximum value (3) on
each successful completion of a transaction. The host controller must never
reset this field if the value at the start of the transaction is 00b.
See Split Transaction Interrupt for CERR adjustment rules when the EPS field
indicates a FS or LS device and the queue head is in the Periodic Schedule. See
Asynchronous - Do Complete Split for CERR adjustment rules when the EPS
field indicates a FS or LS device, the queue head is in the Asynchronous
schedule and the PIDCode indicates a SETUP.
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3667

<!-- page 3668 -->

Table 56-23. TD Token (DWord 2) (continued)
Bit
Description
3
Data buffer errors are host problems. They don't count against the device's
retries.
NOTE: Software must not program CERR to a value of zero when the EPS field is
programmed with a value indicating a Full- or Low-speed device. This combination
could result in undefined behavior.
9-8
PID Code
This field is an encoding of the token, which should be used for transactions associated with
this transfer descriptor. Encodings are:
00b
OUT Token generates token (E1H)
01b
IN Token generates token (69H)
10b
SETUP Token generates token (2DH) (undefined if endpoint is an interrupt, the
queue head is non-zero) transfer type, for example, μFrame S-mask field in.
11b
Reserved
7-0
Status
This field is used by the Host Controller to communicate individual command execution states
back to HCD. This field contains the status of the last transaction performed on this qTD. The
bit encodings are:
Bit
Status Field Description
7
Active. Set to one by software to enable the execution of transactions by the
Host Controller.
6
Halted. Set to one by the Host Controller during status updates to indicate that a
serious error has occurred at the device/endpoint addressed by this qTD. This
can be caused by babble, the error counter counting down to zero, or reception
of the STALL handshake from the device during a transaction. Any time that a
transaction results in the Halted bit being set to a one, the Active bit is also set to
zero.
5
Data Buffer Error. Set to a one by the Host Controller during status update to
indicate that the Host Controller is unable to keep up with the reception of
incoming data (overrun) or is unable to supply data fast enough during
transmission (under run). If an overrun condition occurs, the Host Controller
forces a timeout condition on the USB, invalidating the transaction at the source.
If the host controller sets this bit to a one, then it remains a one for the duration
of the transfer.
4
Babble Detected. Set to a one by the Host Controller during status update when"
babble" is detected during the transaction. In addition to setting this bit, the Host
Controller also sets the Halted bit to a one. Because "babble" is considered a
fatal error for the transfer, setting the Halted bit to a one insures that no more
transactions occur because of this descriptor.
3
Transaction Error (XactErr). Set to a one by the Host Controller during status
update in the case where the host did not receive a valid response from the
device (Timeout, CRC, Bad PID, etc.). If the host controller sets this bit to a one,
then it remains a one for the duration of the transfer.
2
Missed Micro-Frame. This bit is ignored unless the QH.EPS field indicates a full-
or low-speed endpoint and the queue head is in the periodic list. This bit is set
when the host controller detected that a host-induced hold-off caused the host
controller to miss a required complete-split transaction. If the host controller sets
this bit to a one, then it remains a one for the duration of the transfer.
1
Split Transaction State (SplitXstate). This bit is ignored by the host controller
unless the QH.EPS field indicates a full- or low-speed endpoint. When a Full- or
Low-speed device, the host controller uses this bit to track the state of the split-
Table continues on the next page...
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3668
NXP Semiconductors

<!-- page 3669 -->

Table 56-23. TD Token (DWord 2) (continued)
Bit
Description
transaction. The functional requirements of the host controller for managing this
state bit and the split transaction protocol depends on whether the endpoint is in
the periodic or asynchronous schedule. The bit encodings are:
Value Meaning
0b Do Start Split. This value directs the host controller to issue a Start split
transaction to the endpoint.
1b Do Complete Split. This value directs the host controller to issue a Complete
split transaction to the endpoint.
0
Ping State (P)/ERR. If the QH.EPS field indicates a High-speed device and the
PID_Code indicates an OUT endpoint, then this is the state bit for the Ping
protocol. The bit encodings are:
Value Meaning
0b Do OUT. This value directs the host controller to issue an OUT PID to the
endpoint.
1b Do Ping. This value directs the host controller to issue a PING PID to the
endpoint.
If the QH.EPS field does not indicate a High-speed device, then this field is used
as an error indicator bit. It is set to a one by the host controller whenever a
periodic split-transaction receives an ERR handshake.
56.4.2.5.4
qTD Buffer Page Pointer List
The last five DWords of a queue element transfer descriptor is an array of physical
memory address pointers. These pointers reference the individual pages of a data buffer.
System software initializes Current Offset field to the starting offset into the current page,
where current page is selected through the value in the C_Page field.
The following table describes the qTD Buffer Pointer(s) (DWords 3-7) fields.
Table 56-24. qTD Buffer Pointer(s) (DWords 3-7)
Bit
Description
31-12
Buffer Pointer List. Each element in the list is a 4 K page aligned physical memory address. The lower 12
bits in each pointer are reserved (except for the first one), as each memory pointer must reference the
start of a 4 K page. The field C_Page specifies the current active pointer. When the transfer element
descriptor is fetched, the starting buffer address is selected using C_Page (similar to an array index to
select an array element). If a transaction spans a 4K buffer boundary, the host controller must detect the
page-span boundary in the data stream, increment C_Page and advance to the next buffer pointer in the
list, and conclude the transaction through the new buffer pointer.
11-0
Current Offset (Reserved). This field is reserved in all pointers except the first one (for example Page 0).
The host controller should ignore all reserved bits. For the page 0 current offset interpretation, this field is
the byte offset into the current page (as selected by C_Page). The host controller is not required to write
this field back when the qTD is retired. Software should ensure the Reserved fields are initialized to zero.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3669

<!-- page 3670 -->

56.4.2.6
Queue Head
The table located in this section shows the Queue Head structure layout.
The following table shows the queue head structure layout.
Table 56-25. Queue Head Structure Layout
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9
8
7
6
5
4
3
2
1
0
Addr
Queue Head Horizontal Link Pointer
0
Typ
T
03-
00
RL
C
Maximum Packet Length
H
dt
c
EP
EndPt
I
Device Address
07-
041
Mult
Port Number2
Hub Addr2
μFrame C-mask2
μFrame S-mask
0B-
081
Current qTD Pointer
0
0F-
0C
Next qTD Pointer
0
T
13-
103
Alternate Next qTD pointer
NakCnt
T
17-
144
dt
Total Bytes to Transfer
io
c
C_Page
Cerr
PID
Code
Status
1B-
18
Buffer Pointer (Page 0)
Current Offset
1F-
1C
Buffer Pointer (Page 1)
Reserved
C-prog-mask2
23-
20
Buffer Pointer (Page 2)
S-bytes2
FrameTa
g2
27-
244
Buffer Pointer (Page 3)
Reserved
2B-
28
Buffer Pointer (Page 4)
Reserved
2F-
2C3
1.
04-0B: Static endpoint state.
2.
These fields are used exclusively to support split transactions to USB 2.0 hubs
3.
10-2F: Transfer overlay.
4.
14-27: Transfer results.
Host Controller Read/Write
Host Controller Read Only
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3670
NXP Semiconductors

<!-- page 3671 -->

56.4.2.6.1
Queue Head Horizontal Link Pointer
The first DWord of a Queue Head contains a link pointer to the next data object to be
processed after any required processing in this queue has been completed, as well as the
control bits defined below.
This pointer may reference a queue head or one of the isochronous transfer descriptors. It
must not reference a queue element transfer descriptor.
The following table describes the Queue head DWord 0 fields.
Table 56-26. Queue Head DWord 0
Bit
Description
31-5
Queue Head Horizontal Link Pointer (QHLP). This field contains the address of the next data object to be
processed in the horizontal list and corresponds to memory address signals [31:5], respectively.
4-3
Reserved
2-1
QH/(s)iTD Select (Typ). This field indicates to the hardware whether the item referenced by the link pointer is
an iTD, siTD or a QH. This allows the Host Controller to perform the proper type of processing on the item after
it is fetched. Value encodings are:
Value Meaning
00b iTD (isochronous transfer descriptor)
01b QH (queue head)
10b siTD (split transaction isochronous transfer descriptor)
11b FSTN (frame span traversal node)
0
Terminate (T). 1=Last QH (pointer is invalid). 0=Pointer is valid. If the queue head is in the context of the
periodic list, a one bit in this field indicates to the host controller that this is the end of the periodic list. This bit
is ignored by the host controller when the queue head is in the Asynchronous schedule. Software must ensure
that queue heads reachable by the host controller always have valid horizontal link pointers.
56.4.2.6.2
Queue Head Endpoint Capabilities/Characteristics
The second and third DWords of a Queue Head specifies static information about the
endpoint. This information does not change over the lifetime of the endpoint.
There are three types of information in this region:
• Endpoint Characteristics. These are the USB endpoint characteristics including
addressing, maximum packet size, and endpoint speed.
• Endpoint Capabilities. These are adjustable parameters of the endpoint. They effect
how the endpoint data stream is managed by the host controller.
• Split Transaction Characteristics. This data structure is used to manage full- and low-
speed data streams for bulk, control, and interrupt via split transactions to USB2.0
Hub Transaction Translator. There are additional fields used for addressing the hub
and scheduling the protocol transactions (for periodic).
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3671

<!-- page 3672 -->

The host controller must not modify the bits in this region.
The following table describes the Endpoint characteristics: Queue head DWord 1 fields.
Table 56-27. Endpoint Characteristics: Queue Head DWord 1
Bit
Description
31-28
Nak Count Reload (RL). This field contains a value, which is used by the host controller to reload the Nak
Counter field.
27
Control Endpoint Flag (C). If the QH.EPS field indicates the endpoint is not a high-speed device, and the
endpoint is a control endpoint, then software must set this bit to a one. Otherwise, it should always set this bit
to zero.
26-16
Maximum Packet Length. This directly corresponds to the maximum packet size of the associated endpoint
(wMaxPacketSize). The maximum value this field may contain is 0x400 (1024).
15
Head of Reclamation List Flag (H). This bit is set by System Software to mark a queue head as being the
head of the reclamation list.
14
Data Toggle Control (DTC). This bit specifies where the host controller should get the initial data toggle on an
overlay transition.
0b Ignore DT bit from incoming qTD. Host controller preserves DT bit in the queue head.
1b Initial data toggle comes from incoming qTD DT bit. Host controller replaces DT bit in the queue head from
the DT bit in the qTD.
13-12
Endpoint Speed (EPS). This is the speed of the associated endpoint. Bit combinations are:
Value
Meaning
00b
Full-Speed (12 Mbits/sec)
01b
Low-Speed (1.5 Mbits/sec)
10b
High-Speed (480 Mbits/sec)
11b
Reserved
This field must not be modified by the host controller.
11-8
Endpoint Number (Endpt). This 4-bit field selects the particular endpoint number on the device serving as the
data source or sink.
7
Inactivate on Next Transaction (I). This bit is used by system software to request that the host controller set
the Active bit to zero. See Rebalancing the periodic schedule , for full operational details. This field is only
valid when the queue head is in the Periodic Schedule and the EPS field indicates a Full or Low-speed
endpoint. Setting this bit to one when the queue head is in the Asynchronous Schedule or the EPS field
indicates a high-speed device yields undefined results.
6-0
Device Address. This field selects the specific device serving as the data source or sink.
The table below describes the Endpoint capabilities: Queue head DWord 2 field
descriptions.
Table 56-28. Endpoint Capabilities: Queue Head DWord 2
Bit
Description
31-30
High-Bandwidth Pipe Multiplier (Mult). This field is a multiplier used to key the host controller as the number of
successive packets the host controller may submit to the endpoint in the current execution. The host
controller makes the simplifying assumption that software properly initializes this field (regardless of location
of queue head in the schedules or other run time parameters). The valid values are:
Value Meaning
Table continues on the next page...
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3672
NXP Semiconductors

<!-- page 3673 -->

Table 56-28. Endpoint Capabilities: Queue Head DWord 2 (continued)
00b Reserved. A zero in this field yields undefined results.
01b One transaction to be issued for this endpoint per micro-frame.
10b Two transactions to be issued for this endpoint per micro-frame.
11b Three transactions to be issued for this endpoint per micro-frame.
29-23
Port Number. This field is ignored by the host controller unless the EPS field indicates a full- or low-speed
device. The value is the port number identifier on the USB 2.0 Hub (for hub at device address Hub Addr
below), below which the full- or low-speed device associated with this endpoint is attached. This information is
used in the split-transaction protocol.
22-16
Hub Addr. This field is ignored by the host controller unless the EPS field indicates a full-or low-speed device.
The value is the USB device address of the USB 2.0 Hub below which the full- or low-speed device
associated with this endpoint is attached. This field is used in the split-transaction protocol.
15-8
Split Completion Mask (μFrame C-Mask). This field is ignored by the host controller unless the EPS field
indicates this device is a low- or full-speed device and this queue head is in the periodic list. This field (along
with the Active and SplitX-state fields) is used to determine during which micro-frames the host controller
should execute a complete-split transaction. When the criteria for using this field are met, a zero value in this
field has undefined behavior. This field is used by the host controller to match against the three low-order bits
of the FRINDEX register. If the FRINDEX register bits decode to a position where the μFrame C- Mask field is
a one, then this queue head is a candidate for transaction execution. There may be more than one bit in this
mask set.
7-0
Interrupt Schedule Mask (μFrame S-mask). This field is used for all endpoint speeds. Software should set this
field to a zero when the queue head is on the asynchronous schedule. A non-zero value in this field indicates
an interrupt endpoint. The host controller uses the value of the three low-order bits of the FRINDEX register
as an index into a bit position in this bit vector. If the μFrame S-mask field has a one at the indexed bit
position then this queue head is a candidate for transaction execution. If the EPS field indicates the endpoint
is a high-speed endpoint, then the transaction executed is determined by the PID_Code field contained in the
execution area. This field is also used to support split transaction types: Interrupt (IN/OUT). This condition is
true when this field is non-zero and the EPS field indicates this is either a full- or low-speed device. A zero
value in this field, in combination with existing in the periodic frame list has undefined results.
56.4.2.6.3
Transfer Overlay-Queue Head
The nine DWords in this area represent a transaction working space for the host
controller. The general operational model is that the host controller can detect whether
the overlay area contains a description of an active transfer. If it does not contain an
active transfer, then it follows the Queue Head Horizontal Link Pointer to the next queue
head. The host controller will never follow the Next Transfer Queue Element or Alternate
Queue Element pointers unless it is actively attempting to advance the queue. For the
duration of the transfer, the host controller keeps the incremental status of the transfer in
the overlay area. When the transfer is complete, the results are written back to the
original queue element.
The DWord3 of a Queue Head contains a pointer to the source qTD currently associated
with the overlay. The host controller uses this pointer to write back the overlay area into
the source qTD after the transfer is complete.
The following table describes the current qTD link pointer field descriptions.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3673

<!-- page 3674 -->

Table 56-29. Current qTD Link Pointer
Bit
Description
31-5
Current Element Transaction Descriptor Link Pointer. This field contains the address Of the current transaction
being processed in this queue and corresponds to memory address signals [31:5], respectively.
4-0
Reserved (R). These bits are ignored by the host controller when using the value as an address to write data.
The actual value may vary depending on the usage.
The DWords 4-11 of a queue head are the transaction overlay area. This area has the
same base structure as a Queue Element Transfer Descriptor. The queue head utilizes the
reserved fields of the page pointers to implement tracking the state of split transactions.
This area is characterized as an overlay because when the queue is advanced to the next
queue element, the source queue element is merged onto this area. This area serves as
execution cache for the transfer.
The table below describes the Host-controller rules for bits in overlay.
Table 56-30. Host-Controller Rules for Bits in Overlay (DWords 5, 6, 8 and 9)
DWord
Bit
Description
5
4-1
Nak Counter (NakCnt)μRW. This field is a counter the host controller decrements whenever a
transaction for the endpoint associated with this queue head results in a Nak or Nyet response.
This counter is reloaded from RL before a transaction is executed during the first pass of the
reclamation list (relative to an Asynchronous List Restart condition). It is also loaded from RL
during an overlay.
6
31
Data Toggle. The Data Toggle Control controls whether the host controller preserves this bit
when an overlay operation is performed.
6
15
Interrupt On Complete (IOC). The IOC control bit is always inherited from the source qTD when
the overlay operation is performed.
6
11-10
Error Counter (C_ERR). This two-bit field is copied from the qTD during the overlay and written
back during queue advancement.
6
0
Ping State (P)/ERR. If the EPS field indicates a high-speed endpoint, then this field should be
preserved during the overlay operation.
8
7-0
Split-transaction Complete-split Progress (C-prog-mask). This field is initialized to zero during
any overlay. This field is used to track the progress of an interrupt split-transaction.
9
4-0
Split-transaction Frame Tag (Frame Tag). This field is initialized to zero during any overlay. This
field is used to track the progress of an interrupt split-transaction.
9
11-5
S-bytes. Software must ensure that the S-bytes field in a qTD is zero before activating the qTD.
This field is used to keep track of the number of bytes sent or received during an IN or OUT split
transaction.
56.4.2.7
Periodic Frame Span Traversal Node (FSTN)
This data structure is to be used only for managing Full- and Low-speed transactions that
span a Host-frame boundary.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3674
NXP Semiconductors

<!-- page 3675 -->

See Host Controller Operational Model for FSTNs for full operational details. Software
must not use an FSTN in the Asynchronous Schedule. An FSTN in the Asynchronous
schedule results in undefined behavior. Software must not use the FSTN feature with a
host controller whose USB_HCIVERSION register indicates a revision implementation
below 0096h. FSTNs are not defined for implementations before 0.96 and their use yields
undefined results.
Table 56-31. Frame Span Traversal Node Structure Layout
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9
8
7
6
5
4
3
2
1
0
Addr
Normal Path Link Pointer
0
Typ
T
03-
00
Back Path Link Pointer
0
Typ1
T
07-
04
1.
Must be set to indicate a queue head
Host Controller Read/Write
Host Controller Read Only
56.4.2.7.1
FSTN Normal Path Pointer
The first DWord of an FSTN contains a link pointer to the next schedule object. This
object can be of any valid periodic schedule data type.
The following table describes the FSTN normal path pointer fields.
Table 56-32. FSTN Normal Path Pointer Field Descriptions
Bit
Description
31-5
Normal Path Link Pointer (NPLP). This field contains the address of the next data object to be processed in
the periodic list and corresponds to memory address signals [31:5], respectively.
4-3
Reserved
2-1
QH/(s)iTD/FSTN Select (Typ). This field indicates to the Host Controller whether the item referenced is a iTD/
siTD, a QH or an FSTN. This allows the Host Controller to perform the proper type of processing on the item
after it is fetched. Value encodings are:
Value Meaning
00b iTD (isochronous transfer descriptor)
01b QH (queue head)
10b siTD (split transaction isochronous transfer descriptor)
11b FSTN (Frame Span Traversal Node)
0
Terminate (T).
1 = Link Pointer field is not valid. 0 = Link Pointer is valid.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3675

<!-- page 3676 -->

56.4.2.7.2
FSTN Back Path Link Pointer
The second DWord of an FTSN node contains a link pointer to a queue head.
If the T-bit in this pointer is zero, then this FSTN is a Save-Place indicator. Its Typ field
must be set by software to indicate the target data structure is a queue head. If the T-bit in
this pointer is set to one, then this FSTN is the Restore indicator. When the T-bit is one,
the host controller ignores the Typ field.
The following table describes the FSTN back path link pointer fields.
Table 56-33. FSTN Back Path Link Pointer Field Descriptions
Bit
Description
31-5
Back Path Link Pointer (BPLP). This field contains the address of a Queue Head. This field corresponds to
memory address signals [31:5], respectively.
4-3
Reserved
2-1
Typ. Software must ensure this field is set to indicate the target data structure is a Queue Head. Any other
value in this field yields undefined results.
0
Terminate (T). 1=Link Pointer field is not valid (that is the host controller must not use bits [31:5] as a valid
memory address). This value also indicates that this FSTN is a Restore indicator.
0=Link Pointer is valid (that is the host controller may use bits [31:5] (in combination with the
CTRLDSSEGMENT register if applicable) as a valid memory address). This value also indicates that this
FSTN is a Save-Place indicator.
56.4.3
Host Operational Model
The general operational model is for the enhanced interface host controller hardware and
enhanced interface host controller driver (generally referred to as system software).
Each significant operational feature of the EHCI host controller is discussed in a separate
section. Each section presents the operational model requirements for the host controller
hardware. Where appropriate, recommended system software operational models for
features are also presented.
56.4.3.1
Host Controller Initialization
After initial power-on or HCReset (hardware or through HCReset bit in the
USB_USBCMD register), all of the operational registers are at their default values. After
a hardware reset, only the operational registers not contained in the Auxiliary power well
are at their default values.
The following table describes the default values of operational registers.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3676
NXP Semiconductors

<!-- page 3677 -->

.
Table 56-34. Default Values of Operational Register Space
Operational Register
Default Value (after Reset)
USB_USBCMD
00080000h (00080B00h, if Asynchronous Schedule Park
Capability is one)
USB_USBSTS
00001000h
USB_USBINTR
00000000h
USB_FRINDEX
00000000h
USB_CTRLDSSEGMENT
00000000h
USB_PERIODICLISTBASE
Undefined
USB_ASYNCLISTADDR
Undefined
USB_CONFIGFLAG
00000000h
USB_PORTSC1
00002000h (w/PPC set to one); 00003000h (w/PPC set to zero)
To initialize the host controller, software should perform the following steps:
• Write the appropriate value to the USB_USBINTR register to enable the appropriate
interrupts.
• Write the base address of the Periodic Frame List to the USB_PERIODICLIST
BASE register. If no work items are in the periodic schedule, all elements of the
Periodic Frame List should have their T-Bits set to one.
• Write the USB_USBCMD register to set the desired interrupt threshold, frame list
size (if applicable) and turn the host controller ON through setting the Run/Stop bit.
At this point, the host controller is up and running and the port registers begin reporting
device connects, and so on. System software can enumerate a port through the reset
process (where the port is in the enabled state). At this point, the port is active with SOFs
occurring down the enabled ports, but the schedules have not enabled. To communicate
with devices through the asynchronous schedule, system software must write the
USB_ASYNCLISTADDR register with the address of a control or bulk queue head.
Software must then enable the asynchronous schedule by writing one to the
Asynchronous Schedule Enable bit in the USB_USBCMD register. To communicate with
devices through the periodic schedule, system software must enable the periodic schedule
by writing one to the Periodic Schedule Enable bit in the USB_USBCMD register.
NOTE
The schedules can be turned on before the first port is reset (and
enabled).
When the USB_USBCMD register is written, system software must ensure the
appropriate bits are preserved, depending on the intended operation.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3677

<!-- page 3678 -->

56.4.3.2
Port Routing and Control
The EHCI specification defines that a USB 2.0 Host controller is comprised of one high-
speed host controller, which implements the EHCI programming interface and 0 to N
USB 1.1 companion host controllers.
Companion host controllers (cHCs) may be implementations of either Universal or Open
host controller specifications. This configuration is used to deliver the required full USB
2.0-defined port capability; for example, Low-, Full-, and High-speed capability for every
port.
NOTE
The USB controllers on do not require nor support companion
controllers to support Full and Low Speed device. Full and Low
Speed devices are supported within the USB controller by
emulating the functionality of a high-speed HUB. Therefore, no
port routing is present in the controller. Please refer to
Embedded Transaction Translator Function for details.
The following figure illustrates a simple block diagram of the port routing logic and its
relationship to the high-speed and companion host controllers within a USB 2.0 host
controller.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3678
NXP Semiconductors

<!-- page 3679 -->

Companion
USB1.1 HC
High-Speed
(ehci) HC
Data
Port Reg.
Data
Port Reg.
Port Routing
Logic
Transceiver
Port 1
Port
Owner
USB 2.0 Host Controller
Figure 56-4. Example USB 2.0 Host Controller Port Routing Block Diagram
There exists one transceiver per physical port and each host controller block has its own
port status and control registers. The EHCI controller has port status and control registers
for every port. Each companion host controller has only the port control and status
registers it is required to operate. Either the EHCI host controller or one companion host
controller controls each transceiver. Routing logic lies between the transceiver, the port
status and control registers.1
The port routing logic is controlled from signals originating in the EHCI host controller.
The EHCI host controller has a global routing policy control field and per-port ownership
control fields. The Configured Flag (CF) bit is the global routing policy control. At
power-on or reset, the default routing policy is to the companion controllers (if they
exist). If the system does not include a driver for the EHCI host controller and the host
controller includes Companion Controllers, then the ports still work in Full- and Low-
speed mode (assuming the system includes a driver for the companion controllers). In
general, when the EHCI owns the ports, the companion host controllers' port registers do
not see a connect indication from the transceiver. Similarly, when a companion host
controller owns a port, the EHCI controller's port registers do not see a connect indication
1.
The routing logic should not be implemented in the 480 MHz clock domain of the transceiver.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3679

<!-- page 3680 -->

from the transceiver. The details on the rules for the port routing logic are described in
the following sections. The USB 2.0 host controller must be implemented as a multi-
function PCI device if the implementation includes companion controllers. The
companion host controllers' function numbers must be less than the EHCI host controller
function number. The EHCI host controller must be a larger function number with respect
to the companion host controllers associated with this EHCI host controller. If a PCI
device implementation contains only an EHCI controller (that is no companion
controllers or other PCI functions), then the EHCI host controller must be function zero,
in accordance with the PCI Specification. The N_CC field in the Structural Parameter
register (HCSPARAMS) indicates whether the controller implementation includes
companion host controllers. When N_CC has a non-zero value there exists companion
host controllers. If N_CC has a value of zero, then the host controller implementation
does not include companion host controllers. If the host controller root ports are exposed
to attachment of full- or low-speed devices, the ports always fails the high-speed chirp
during reset and the ports are not enabled. System software can notify the user of the
illegal condition. This type of implementation requires a USB 2.0 hub be connected to a
root port to provide full and low-speed device connectivity.
System software uses information in the host controller capability registers to determine
how the ports are routed to the companion host controllers. See Host Controller Structural
Parameters (USB_nHCSPARAMS)
56.4.3.2.1
Port Routing Control through EHCI Configured (CF) Bit
Each port in the USB 2.0 host controller are routed either to a single companion host
controller or to the EHCI host controller.
The port routing logic is controlled by two mechanisms in the EHCI HC: a host controller
global flag and per-port control. The Configured Flag (CF) bit, is used to globally set the
policy of the routing logic. Each port register has a Port Owner control bit which allows
the EHCI Driver to explicitly control the routing of individual ports. Whenever the CF bit
transitions from zero to one (this transition is only available under program control) the
port routing unconditionally routes all of the port registers to the EHCI HC (all Port
Owner bits go to zero). While the CF-bit is one, the EHCI Driver controls individual
ports' routing through the Port Owner control bit. Likewise, whenever the CF bit
transitions from one to zero (as a result of Aux power application, HCRESET, or
software writing zero to CF-bit), the port routing unconditionally routes all of the port
registers to the appropriate companion HC. The default value for the EHCI HC's CF bit
(after Aux power application or HCRESET) is zero.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3680
NXP Semiconductors

<!-- page 3681 -->

The view of the port depends on the current owner. A Universal or Open companion host
controller will see port register bits consistent with the appropriate specification. Port bit
definitions that are required for EHCI host controllers are not visible to companion host
controllers.
The following table summarizes the default routing for all the ports, based on the value of
the EHCI HC's CF bit.
Table 56-35. Default Port Routing Depending on EHCI HC CF Bit
HS CF Bit
Default Port
Ownership
Explanation
0B
Companion HCs
The companion host controllers own the ports and only Full- and Low-speed
devices are supported in the system. The exact port assignments are
implementation dependent. The ports behave only as Full- and Low-speed ports in
this configuration
1B
EHCI HC
The EHCI host controller has default ownership over all of the ports. The routing
logic inhibits device connect events from reaching the companion HCs' port status
and control registers when the port owner is the EHCI HC.The EHCI HC has
access to the additional port status and control bits defined in this specification
(see Port Status & Control (USB_nPORTSC1)). The EHCI HC can temporarily
release control of the port to a companion HC by setting the PortOwner bit in the
PORTSC1 register to one.
56.4.3.2.2
Port Routing Control through PortOwner and Disconnect Event
Manipulating the port routing through the CF-bit is an extreme process and not intended
to be used during normal operation.
The normal mode of port ownership transferal is on the granularity of individual ports
using the Port Owner bit in the EHCI HC's USB_PORTSC1 register (for hand-offs from
EHCI to companion host controllers). Individual port ownership is returned to the EHCI
controller when the port registers a device disconnect. When the disconnect is detected,
the port routing logic immediately returns the port ownership to the EHCI controller. The
companion host controller port register detects the device disconnect and operates
normally.
Under normal operating conditions (assuming all HC drivers loaded and operational and
the EHCI CF-bit is set to one), the typical port enumeration sequence proceeds as
illustrated below:
• Initial condition is that EHCI is port owner. A device is connected causing the port to
detect a connect, set the port connect change bit and issue a port-change interrupt (if
enabled).
• EHCI Driver identifies the port with the new connect change bit asserted and sends a
change report to the hub driver. Hub driver issues a GetPortStatus() request and
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3681

<!-- page 3682 -->

identifies the connect change. It then issues a request to clear the connect change,
followed by a request to reset and enable the port.
• When the EHCI Driver receives the request to reset and enable the port, it first
checks the value reported by the LineStatus bits in the USB_PORTSC1 register. If
they indicate the attached device is a full-speed device (for example, D+ is asserted),
then the EHCI Driver sets the PortReset control bit to one (and sets the PortEnable
bit to zero) which begins the reset-process. Software times the duration of the reset,
then terminates reset signaling by writing zero to the port reset bit. The reset process
is actually complete when software reads zero in the PortReset bit. The EHCI Driver
checks the PortOwner bit in the USB_PORTSC1 register. If set to one, the connected
device is a high-speed device and EHCI Driver (root hub emulator) issues a change
report to the hub driver and the hub driver continues to enumerate the attached
device.
• At the time the EHCI Driver receives the port reset and enable request the LineStatus
bits might indicate a low-speed device. Additionally, when the port reset process is
complete, the PortEnable field may indicate that a full-speed device is attached. In
either case the EHCI driver sets the PortOwner bit in the USB_PORTSC1 register to
one to release port ownership to a companion host controller.
• When the EHCI Driver sets PortOwner bit to one, the port routing logic makes the
connection state of the transceiver available to the companion host controller port
register and removes the connection state from the EHCI HC port. The EHCI
USB_PORTSC1 register observes and reports a disconnect event through the
disconnect change bit. The EHCI Driver detects the connection status change (either
by polling or by port change interrupt) and then sends a change report to the hub
driver. When the hub driver requests that port-state, the EHCI Driver responds with a
reset complete change set to one, a connect change set to one and a connect status set
to zero. This information is derived directly from the EHCI port register. This allows
the hub driver to assume the device was disconnected during reset. It acknowledges
the change bits and wait for the next change event. While the EHCI controller does
not own the port, it simply remains in a state where the port reports no device
connected. The device-connect evaluation circuitry of the companion HC activates
and detects the device, the companion Driver detects the connection and enumerates
the port.
When a port is routed to a companion HC, it remains under the control of the companion
HC until the device is disconnected from the root port (ignoring for now the scenario
where EHCI's CF-bit transitions from1b to 0b). When a disconnect occurs, the disconnect
event is detected by both the companion HC port control and the EHCI port ownership
control. On the event, the port ownership is returned immediately to the EHCI controller.
The companion HC stack detects the disconnect and acknowledges as it would in an
ordinary standalone implementation. Subsequent connects is detected by the EHCI port
register and the process repeats.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3682
NXP Semiconductors

<!-- page 3683 -->

56.4.3.2.3
Example Port Routing State Machine
The following figure illustrates an example of how the port ownership should be
managed. The following sections describe the entry conditions to each state.
EHCI
Owner
Companion
Owner
PortOwner neq 0
AND
EHCI CF EQ 1
PortOwner .eq. 0
OR
Disconnect
AND
EHCI CF .eq. 1
EHCI CF = 0
EHCI CF --->1
Figure 56-5. Port Owner Handoff State Machine
56.4.3.2.3.1
EHCI HC Owner
Entry to this state occurs when one of the following events occur:
• When the EHCI HC's Configure Flag (CF) bit in the USB_CONFIGFLAG register
transitions from zero to one. This signals the fact that the system has a host controller
driver for the EHCI HC and that all ports in the USB 2.0 host controller must default
route to the EHCI controller.
• When the port is owned by a companion HC and the device is disconnected from the
port. The EHCI port routing control logic is notified of the disconnect, and returns
port routing to the EHCI controller. The connection state of the companion HC goes
immediately to the disconnected state (with appropriate side effect to connect
change, enable and enable change). The companion HC driver acknowledges the
disconnect by setting the connect status change bit to zero. This allows the
companion HC's driver to interact with the port completely through the disconnect
process.
• When system software writes zero to the PortOwner bit in the USB_PORTSC1
register. This allows software to take ownership of a port from a companion host
controller. When this occurs, the routing logic to the companion HC effectively
signals a disconnect to the companion HC's port status and control register.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3683

<!-- page 3684 -->

56.4.3.2.3.2
Companion HC Owner
Entry to this state occurs whenever one of the following events occur:
• When the PortOwner field transitions from zero to one.
• When the HS-mode HC's Configure Flag (CF) is equal to zero.
On entry to this state, the routing logic allows the companion HC port register to detect a
device connect. Normal port enumeration proceeds.
56.4.3.2.4
Port Power
The Port Power Control (PPC) bit in the USB_HCSPARAMS register indicates whether
the USB 2.0 host controller has port power control (see Host Controller Structural
Parameters (USB_nHCSPARAMS)).
When this bit is zero, then the host controller does not support software control of port
power switches. When in this configuration, the port power is always available and the
companion host controllers must implement functionality consistent with port power
always on. When the PPC bit is one, then the host controller implementation includes
port power switches. Each available switch has an output enable, which is referred to in
this discussion as PortPowerOutputEnable (PPE). PPE is controlled based on the state of
the combination bits PPC bit, EHCI Configured (CF)-bit and individual Port Power (PP)
bits.
The following table describes the summary behavioral model.
Table 56-36. Port Power Enable Control Rules
CF
CHC1 (PP)
EHC2 (PP)
Owner
PPE3
Description
0
0
X
CHC
0
When the EHCI controller is not
configured, the port is owned by the
companion host controller. When the
companion HC's port power select is off,
then the port power is off.
0
1
X
CHC
1
Similar to previous entry. When the
companion HC's port power select is on,
then the port power is on.
1
0
0
CHC
0
Port owner has port power turned off, the
power to port is off.
1
0
0
EHC
0
Port owner has port power turned off, the
power to port is off.
1
0
1
EHC
1
Port owner has port power on, so power
to port is on.
1
0
1
CHC
1
If either HC has port power turned on, the
power to the port is on.
Table continues on the next page...
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3684
NXP Semiconductors

<!-- page 3685 -->

Table 56-36. Port Power Enable Control Rules (continued)
1
1
0
EHC
1
If either HC has port power turned on, the
power to the port is on.
1
1
0
CHC
1
Port owner has port power on, so power
to port is on.
1
1
1
CHC
1
Port owner has port power on, so power
to port is on.
1
1
1
EHC
1
Port owner has port power on, so power
to port is on.
1.
CHC (Companion Host Controller).
2.
EHC (EHCI Host Controller).
3.
PPE (Port Power Enable). This bit actually turns on the port power switch (if one exists).
56.4.3.2.5
Port Reporting Over-Current
Host controllers are by definition power providers on USB. Whether the ports are
considered high- or low-powered is a platform implementation issue. Each EHCI
USB_PORTSC1 register has an over-current status and over-current change bit.
The functionality of these bits are specified in the USB Specification Revision 2.0.
The over current detection and limiting logic usually resides outside the host controller
logic. This logic may be associated with one or more ports. When this logic detects an
over-current condition it is made available to both the companion and EHCI ports. The
effect of an over-current status on a companion host controller port is beyond the scope
of this document.
The over-current condition effects the following bits in the USB_PORTSC1 register on
the EHCI port:
• Over-current Active bits are set to one. When the over-current condition goes away,
the Over-current Active bit transitions from one to zero.
• Over-current Change bits are set to one. On every transition of the Over-current
Active bit the host controller sets the Over-current Change bit to one. Software sets
the Over-current Change bit to zero by writing one to this bit.
• Port Enabled/Disabled bit is set to zero. When this change bit gets set to one, then the
Port Change Detect bit in the USB_USBSTS register is set to one.
• Port Power (PP) bits may optionally be set to zero. There is no requirement in USB
that a power provider shut off power in an over current condition. It is sufficient to
limit the current and leave power applied. When the Over-current Change bit
transitions from zero to one, the host controller also sets the Port Change Detect bit
in the USB_USBSTS register to one. In addition, if the Port Change Interrupt Enable
bit in the USB_USBINTR register is one, then the host controller issues an interrupt
to the system. Refer to Table 56-37 for summary behavior for over-current detection
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3685

<!-- page 3686 -->

when the host controller is halted (suspended from a device component point of
view).
56.4.3.3
Suspend/Resume-Host Operational Model
The EHCI host controller provides an equivalent suspend and resume model as that
defined for individual ports in a USB 2.0 Hub.
Control mechanisms are provided to allow system software to suspend and resume
individual ports. The mechanisms allow the individual ports to be resumed completely
through software initiation. Other control mechanisms are provided to parameterize the
host controller's response (or sensitivity) to external resume events. In this discussion,
host-initiated, or software initiated resumes are called Resume Events/Actions. Bus-
initiated resume events are called wake-up events. The classes of wake-up events are:
• Remote-wake-up enabled device asserts resume signaling. In similar kind to USB 2.0
Hubs, EHCI controllers must always respond to explicit device resume signaling and
wake-up the system (if necessary).
• Port connect and disconnect and over-current events. Sensitivity to these events can
be turned on or off by using the per-port control bits in the USB_PORTSC1 registers.
Selective suspend is a feature supported by every USB_PORTSC1 register. It is used to
place specific ports into a suspend mode. This feature is used as a functional component
for implementing the appropriate power management policy implemented in a particular
operating system. When system software intends to suspend the entire bus, it should
selectively suspend all enabled ports, then shut off the host controller by setting the Run/
Stop bit in the USB_USBCMD register to zero. The EHCI sub-block can then be placed
into a lower device state through the PCI power management interface (see Appendix A,
Enhanced Host Controller Interface Specification for Universal Serial Bus, Revision
0.95, November 2000, Intel Corporation. http://www.intel.com).
When a wake event occurs, the system resumes operation and system software eventually
set the Run/Stop bit to one and resume the suspended ports. Software must not set the
Run/Stop bit to one until it is confirmed that the clock to the host controller is stable. This
is usually confirmed in a system implementation in that all of the clocks in the system are
stable before the Arm platform is restarted. So, by definition, if software is running,
clocks in the system are stable and the Run/Stop bit in the USB_USBCMD register can
be set to one. Minimum system software delays are also defined in the PCI Power
Management Specification. Refer to PCI Power Management Specification for more
information.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3686
NXP Semiconductors

<!-- page 3687 -->

56.4.3.3.1
Port Suspend/Resume
System software places individual ports into suspend mode by writing one into the
appropriate USB_PORTSC1 Suspend bit. Software must only set the Suspend bit when
the port is in the enabled state (Port Enabled bit is one) and the EHCI is the port owner
(PortOwner bit is zero).
The host controller may evaluate the Suspend bit immediately or wait until a micro-frame
or frame boundary occurs. If evaluated immediately, the port is not suspended until the
current transaction (if one is executing) completes. Therefore, there may be several
micro-frames of activity on the port until the host controller evaluates the Suspend bit.
The host controller must evaluate the Suspend bit at least every frame boundary.
System software can initiate a resume on a selectively suspended port by writing one to
the Force Port Resume bit. Software should not attempt to resume a port unless the port
reports that it is in the suspended state (see Port Status & Control (USB_nPORTSC1)). If
system software sets Force Port Resume bit to one when the port is not in the suspended
state, the resulting behavior is undefined. In order to assure proper USB device operation,
software must wait for at least 10 ms after a port indicates that it is suspended (Suspend
bit is one) before initiating a port resume through the Force Port Resume bit. When Force
Port Resume bit is one, the host controller sends resume signaling down the port. System
software times the duration of the resume (nominally 20 ms) then sets the Force Port
Resume bit to zero. When the host controller receives the write to transition Force Port
Resume to zero, it completes the resume sequence as defined in the USB specification,
and sets both the Force Port Resume and Suspend bits to zero. Software-initiated port
resumes do not affect the Port Change Detect bit in the USB_USBSTS register nor do
they cause an interrupt if the Port Change Interrupt Enable bit in the USB_USBINTR
register is one. An external USB event may also initiate a resume. The wake events are
defined above. When a wake event occurs on a suspended port, the resume signaling is
detected by the port and the resume is reflected downstream within 100 μsec. The port's
Force Port Resume bit is set to one and the Port Change Detect bit in the USB_USBSTS
register is set to one. If the Port Change Interrupt Enable bit in the USB_USBINTR
register is one the host controller issues a hardware interrupt.
System software observes the resume event on the port, delays a port resume time
(nominally 20 ms), then terminates the resume sequence by writing zero to the Force Port
Resume bit in the port. The host controller receives the write of zero to Force Port
Resume, terminates the resume sequence and sets Force Port Resume and Suspend port
bits to zero. Software can determine that the port is enabled (not suspended) by sampling
the USB_PORTSC1 register and observing that the Suspend and Force Port Resume bits
are zero. Software must ensure that the host controller is running (that is HCHalted bit in
the USB_USBSTS register is zero), before terminating a resume by writing zero to a
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3687

<!-- page 3688 -->

port's Force Port Resume bit. If HCHalted is one when Force Port Resume is set to zero,
then SOFs do not occur down the enabled port and the device returns to suspend mode in
a maximum of 10 msec.
The table below summarizes the wake-up events. Whenever a resume event is detected,
the Port Change Detect bit in the USB_USBSTS register is set to one. If the Port Change
Interrupt Enable bit is one in the USB_USBINTR register, the host controller generates
an interrupt on the resume event. Software acknowledges the resume event interrupt by
clearing the Port Change Detect status bit in the USB_USBSTS register.
Table 56-37. Behavior During Wake-up Events
Port Status and Signaling Type
Signaled Port Response
Device State
D0
Not D0
Port disabled, resume K-State received
No Effect
N/A
N/A
Port suspended, resume K-State
received
Resume reflected downstream on signaled port. Force
Port Resume status bit in USB_PORTSC1 register is set
to one. Port Change Detect bit in USB_USBSTS register
set to one.
[1], [2]
[2]
Port is enabled, disabled or suspended,
and the port's WKDSCNNT_E bit is one.
A disconnect is detected.
Depending in the initial port state, theUSB_ PORTSC1
Connected Enable status bits are set to zero, and the
Connect Change status bit is set to one. Port Change
Detect bit in the USB_USBSTS register is set to one.
[1], [2]
[2]
Port is enabled, disabled or suspended,
and the port's WKDSCNNT_E bit is zero.
A disconnect is detected.
Depending on the initial port state, the USB_PORTSC1
Connect and Enable status bits are set to zero, and the
Connect Change status bit is set to one. Port Change
Detect bit in the USB_USBSTS register is set to one.
[1], [3]
[3]
Port is not connected and the port's
WKCNNT_E bit is one. A connect is
detected.
USB_PORTSC1 Connect Status and Connect Status
Change bits are set to one. Port Change Detect bit in
the USB_USBSTS register is set to one.
[1], [2]
[2]
Port is not connected and the port's
WKCNNT_E bit is zero. A connect is
detected.
USB_PORTSC1 Connect Status and Connect Status
Change bits are set to one. Port Change Detect bit in
the USB_USBSTS register is set to one.
[1], [3]
[3]
Port is connected and the port's
WKOC_E bit is one. An over-current
condition occurs.
USB_PORTSC1 Over-current Active, Over-current
Change bits are set to one. If Port Enable/Disable bit is
one, it is set to zero. Port Change Detect bit in the
USB_USBSTS register is set to one
[1], [2]
[2]
Port is connected and the port's
WKOC_E bit is zero. An over-current
condition occurs.
USB_PORTSC1 Over-current Active, Over-current
Change bits are set to one. If Port Enable/Disable bit is
one, it is set to zero. Port Change Detect bit in the
USB_USBSTS register is set to one.
[1], [3]
[3]
[1] Hardware interrupt issued if Port Change Interrupt Enable bit in the USB_USBINTR
register is one.
[2] PME# asserted if enabled (Note: PME Status must always be set to one).
[3] PME# not asserted.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3688
NXP Semiconductors

<!-- page 3689 -->

56.4.3.4
Schedule Traversal Rules
The host controller executes transactions for devices using a simple, shared-memory
schedule.
The schedule is comprised of a few data structures, organized into two distinct lists. The
data structures are designed to provide the maximum flexibility required by USB,
minimize memory traffic and hardware / software complexity.
System software maintains two schedules for the host controller: a periodic schedule and
an asynchronous schedule. The root of the periodic schedule is the
USB_PERIODICLISTBASE register (see Frame List Base Address
(USB_nPERIODICLISTBASE))/ Device Address (USB_nDEVICEADDR). The
USB_PERIODICLISTBASE register is the physical memory base address of the periodic
frame list. The periodic frame list is an array of physical memory pointers. The objects
referenced from the frame list must be valid schedule data structures as defined in Host
Data Structures. In each micro-frame, if the periodic schedule is enabled (see Periodic
scheduling threshold) then the host controller must execute from the periodic schedule
before executing from the asynchronous schedule. It only executes from the
asynchronous schedule after it encounters the end of the periodic schedule. The host
controller traverses the periodic schedule by constructing an array offset reference from
the USB_PERIODICLISTBASE and the USB_FRINDEX registers (see the following
figure). It fetches the element and begins traversing the graph of linked schedule data
structures.
The end of the periodic schedule is identified by a next link pointer of a schedule data
structure having its T-bit set to one. When the host controller encounters a T-Bit set to
one during a horizontal traversal of the periodic list, it interprets this as an End-Of-
Periodic-List mark. This causes the host controller to cease working on the periodic
schedule and transitions immediately to traversing the asynchronous schedule. After the
transition, the host controller executes from the asynchronous schedule until the end of
the micro-frame.
The following figure illustrates the derivation of pointer into frame list array.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3689

<!-- page 3690 -->

0
1
2
11
12
31
12
31
0
1
2
12
13
3
DWord-aligned
Periodic Frame List Element
Address
Periodic Frame
List
Frame Index Register
Periodic Frame List Base
Address
Figure 56-6. Derivation of Pointer into Frame List Array
When the host controller determines that it is the time to execute from the asynchronous
list, it uses the operational register USB_ASYNCLISTADDR to access the asynchronous
schedule, see the figure below.
H
USBCMD
USBSTS
ASYNCLISTADDR
Operational
Registers
. . .
. . .
Figure 56-7. General Format of Asynchronous Schedule List
The USB_ASYNCLISTADDR register contains a physical memory pointer to the next
queue head. When the host controller makes a transition to executing the asynchronous
schedule, it begins by reading the queue head referenced by the
USB_ASYNCLISTADDR register. Software must set queue head horizontal pointer T-
bits to zero for queue heads in the asynchronous schedule. See Asynchronous Schedule
for complete operational details.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3690
NXP Semiconductors

<!-- page 3691 -->

56.4.3.4.1
Example - Preserving Micro-Frame Integrity
One of the requirements of a USB host controller is to maintain Frame Integrity. This
means that the HC must preserve the micro-frame boundaries.
For example, SOF packets must be generated on time (within the specified allowable
jitter), and High-speed EOF1,2 thresholds must be enforced. The end of micro-frame
timing points EOF1 and EOF2 are clearly defined in the USB Specification Revision 2.0.
One implication of this responsibility is that the HC must ensure that it does not start
transactions that do not complete before the end of the micro-frame. More precisely, no
transactions should be started by the host controller, which do not complete in their
entirety before the EOF1 point. In order to enforce this rule, the host controller must
check each transaction before it starts to ensure that it completes before the end of the
micro-frame.
So, what exactly needs to be involved in this check? Fundamentally, the transaction data
payload, plus bit stuffing, plus transaction overhead must be taken into consideration. It is
possible to be extremely accurate on how much time the next transaction takes. Take
OUTs for an example. The host controller must fetch all of the OUT data from memory
in order to send it onto the USB bus. A host controller implementation could pre-fetch all
of the OUT data, and pre-compute the actual number of bits in the token and data
packets. In addition, the system knows the depth of the target endpoint, so it could closely
estimate turnaround time for handshake. In addition, the host controller knows the size of
a handshake packet. Pre-computing effects of bit stuffing and summing up the other
overhead numbers can allow the host controller to know exactly whether there is enough
bus time, before EOF1 to complete the OUT transaction. To accomplish this particular
approach takes an inordinate amount of time and hardware complexity.
The alternative is to make a reasonable guess whether the next transaction can be started.
An example approximation algorithm is described below. This example algorithm relies
on the EHCI policy that periodic transactions are scheduled first in the micro-frame. It is
a reasonable assumption that software never over-commits the micro-frame to periodic
transactions greater than the specification allowable 80%. In the available remaining 20%
bandwidth, the host controller has some ability (in this example) to decide whether or not
to execute a transaction. The result of this algorithm is that sometimes, under some
circumstances a transaction is not executed that could have been executed. However,
under all circumstances, a transaction is never started unless there is enough time in the
frame to complete the transaction.
56.4.3.4.1.1
Transaction Fit - A Best-Fit Approximation Algorithm
A curve is calculated which represents the latest start time for every packet size, at which
software schedules the start of a periodic transaction.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3691

<!-- page 3692 -->

This curve is the 80% bandwidth curve. Another curve is calculated which is the
absolute, latest permitted start time for every packet size. This curve represents the
absolute latest time, that a transaction of each packet size can be started and completed,
in the micro-frame. A plot of these two curves are illustrated in Figure 56-8. The plot Y-
axis represents the number of byte-times left in a frame.
The space between the 80% and the Last Start plots is bandwidth reclamation area. In this
algorithm the host controller may skip transactions during this time if it is prudent.
The Best-Fit Approximation method plots a function (f(x)) between the 80% and Last
Start curves. The function f(x) adds a constant to every transaction's maximum packet
size and the result compared with the number of bytes left in the frame. The constant
represents an approximation of the effects of bit stuffing and protocol overhead. The host
controller starts transactions whose results land above the function curve. The host
controller will not start transactions whose results land below the function curve.
The following figure illustrates the Best-Fit Approximation.
0
1000
2000
3000
4000
5000
6000
7000
1
64
127
190
253
316
379
442
505
588
631
694
757
820
883
946 1009
Packet Size in Bytes
Byte
Times 
to EOF
Transactions that will
be started
Transactions that will be skipped
Goal is to minimize area under this curve
80% Threshold
Last Start
f(x)
Figure 56-8. Best Fit Approximation
The LastStart line was calculated in this example to assume the absolute worst-case bus
overhead per transaction. The particular transaction used is a start-split, zero-length OUT
transaction with a handshake. Summaries of the component parts are listed in the table
below. The component times were derived from the protocol timings defined in the USB
Specification Revision 2.0.
Table 56-38. Example Worse-case Transaction Timing Components
Component
Bit time
Byte Time
Explanation
Table continues on the next page...
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3692
NXP Semiconductors

<!-- page 3693 -->

Table 56-38. Example Worse-case Transaction Timing Components (continued)
Split Token
76
9.5
Split token as defined in USB core specification. Includes sync,
token, eop, and so on.
Host 2 Host IPG
88
11
Number of bit times required between consecutive host packets.
Token
67
8.375
Token as defined in USB core specification. Includes sync,
token, eop, and so on.
Host 2 Host IPG
88
11
Token as defined in USB core specification. Includessync, token,
eop, and so on.
Data Packet (0 data
bytes)
66.7
8.34
Zero-length data packet. Includes sync, PID, crc16, eop, and so
on.
Turnaround time
721
90.125
Time for packet initiator (Host) to see the beginning of a
response to a transmitted packet.
Handshake packet
48
6
Handshake packet as defined in USB core specification.
Includes sync, PID, eop, and so on.
144
Total
The exact details of the function (f(x)) are up to the particular implementation. However,
it should be obvious that the goal is to minimize the area under the curve between the
approximation function and the Last Start curve, without dipping below the LastStart
line, while at the same time keeping the check as simple as possible for hardware
implementation. The f(x) in Figure 56-8 was constructed using the following pseudo-
code test on each transaction size data point. This algorithm assumes that the host
controller keeps track of the remaining bits in the frame.
Alorithm CheckTransactionWillFit (MaximumPacketSize, HC_BytesLeftInFrame) 
Begin
Local Temp = MaximumPacketSize + 192 
Local rvalue = TRUE
If MaximumPacketSize >= 128 then 
     Temp += 128 
End If
If Temp > HC_BytesLeftInFrame then 
     Rvalue = FALSE
End If 
Return rvalue
End
This algorithm takes two inputs, the current maximum packet size of the transaction and
the hardware counter of the number of bytes left in the current micro-frame. It
unconditionally adds a simple constant of 192 to the maximum packet size to account for
a first-order effect of transaction overhead and bit stuffing. If the transaction size is
greater than or equal to 128 bytes, then an additional constant of 128 is added to the
running sum to account for the additional worst-case bit stuffing of payloads larger than
128. An inflection point was inserted at 128 because the f(x) plot was getting close to the
LastStart line.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3693

<!-- page 3694 -->

56.4.3.5
Periodic Schedule Frame Boundaries vs Bus Frame
Boundaries
The USB Specification Revision 2.0 requires that the frame boundaries (SOF frame
number changes) of the high-speed bus and the full- and low-speed bus(s) below USB 2.0
Hubs be strictly aligned.
Super-imposed on this requirement is that USB 2.0 Hubs manage full- and low-speed
transactions through a micro-frame pipeline (see start- (SS) and complete- (CS) splits
illustrated in the following figure). A simple, direct projection of the frame boundary
model into the host controller interface schedule architecture creates tension (complexity
for both hardware and software) between the frame boundaries and the scheduling
mechanisms required to service the full- and low-speed transaction translator periodic
pipelines.
7
0
1
2
3
4
5
6
7
0
SS
CS
CS
CS SS
CS
CS
CS
CS
CS
HS Bus
FS/LS Bus
Frame Boundary
Micro-frame number(s)
Figure 56-9. Frame Boundary Relationship between HS bus and FS/LS Bus
The simple projection, as the above figure illustrates, introduces frame-boundary wrap
conditions for scheduling on both the beginning and end of a frame. In order to reduce
the complexity for hardware and software, the host controller is required to implement
one micro-frame phase shift for its view of frame boundaries. The phase shift eliminates
the beginning of frame and frame-wrap scheduling boundary conditions.
The implementation of this phase shift requires that the host controller use one register
value for accessing the periodic frame list and another value for the frame number value
included in the SOF token. These two values are separate, but tightly coupled. The
periodic frame list is accessed through the Frame List Index Register (USB_FRINDEX)
documented in USB Frame Index (USB_nFRINDEX) and initially illustrated in Schedule
Traversal Rules. Bits FRINDEX[2:0], represent the micro-frame number. The SOF value
is coupled to the value of FRINDEX[13:3]. Both FRINDEX[13:3] and the SOF value are
increment based on FRINDEX[2:0]. It is required that the SOF value be delayed from the
FRINDEX value by one micro-frame. The one micro-frame delay yields host controller
periodic schedule and bus frame boundary relationship as illustrated in the following
figure. This adjustment allows software to trivially schedule the periodic start and
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3694
NXP Semiconductors

<!-- page 3695 -->

complete-split transactions for full-and low-speed periodic endpoints, using the natural
alignment of the periodic schedule interface. The reasons for selecting this phase-shift are
beyond the scope of this specification.
The following figure illustrates how periodic schedule data structures relate to schedule
frame boundaries and bus frame boundaries. To aid the presentation, two terms are
defined: The host controller's view of the 1 msec boundaries is called H-Frames. The
high-speed bus's view of the 1 msec boundaries is called B-Frames.
0
1
2
3
4
5
6
7
0
1
2
3
4
5
6
7
0
1
2
SS
CS
CS
CS
CS
SS
CS
CS
CS
CS
HC Periodic
Schedule
Micro-frames
HS Bus
Frames
full/low-speed
transaction
full/low-speed
transaction
B-Frame N
B-Frame N+1
H-Frame N+1
H-Frame N
Interface Data
Structure
Interface Data
Structure
HC Periodic Schedule
Frame Boundaries
HS/FS/LS Bus
Frame Boundaries
7
Figure 56-10. Relationship of Periodic Schedule Frame Boundaries to Bus Frame
Boundaries
H-Frame boundaries for the host controller correspond to increments of FRINDEX[13:3].
Micro-frame numbers for the H-Frame are tracked by FRINDEX[2:0]. B-Frame
boundaries are visible on the high-speed bus through changes in the SOF token's frame
number. Micro-frame numbers on the high-speed bus are only derived from the SOF
token's frame number (that is the high-speed bus sees eight SOFs with the same frame
number value). H-Frames and B-Frames have the fixed relationship (that is B-Frames lag
H-Frames by one micro-frame time) illustrated in the figure above. The host controller's
periodic schedule is naturally aligned to H-Frames. Software schedules transactions for
full- and low-speed periodic endpoints relative the H-Frames. The result is these
transactions execute on the high-speed bus at exactly the right time for the USB 2.0 Hub
periodic pipeline. As described in USB Frame Index (USB_nFRINDEX), the SOF Value
can be implemented as a shadow register (in this example, called SOFV), which lags the
FRINDEX register bits [13:3] by one micro-frame count. This lag behavior can be
accomplished by incrementing FRINDEX[13:3] based on carry-out on the 7 to 0
increment of FRINDEX[2:0] and incrementing SOFV based on the transition of 0 to 1 of
FRINDEX[2:0].
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3695

<!-- page 3696 -->

Software is allowed to write to FRINDEX. USB Frame Index (USB_nFRINDEX)
provides the requirements that software should adhere when writing a new value in
FRINDEX.
The table below illustrates the required relationship between the value of FRINDEX and
the value of SOFV.
Table 56-39. Operation of FRINDEX and SOFV (SOF Value Register)
Current
Next
FRINDEX[F]
SOFV
FRINDEX[mF]
FRINDEX[F]
SOFV
FRINDEX[mF]
N
N
111b
N+1
N
000b
N+1
N
000b
N+1
N+1
001b
N+1
N+1
001b
N+1
N+1
010b
N+1
N+1
010b
N+1
N+1
011b
N+1
N+1
011b
N+1
N+1
100b
N+1
N+1
100b
N+1
N+1
101b
N+1
N+1
101b
N+1
N+1
110b
N+1
N+1
110b
N+1
N+1
111b
NOTE
Where [F] = [13:3]; [μF] = [2:0]
56.4.3.6
Periodic Schedule
The periodic schedule traversal is enabled or disabled through the Periodic Schedule
Enable bit in the USB_USBCMD register. If the Periodic Schedule Enable bit is set to
zero, then the host controller simply does not try to access the periodic frame list through
the USB_PERIODICLISTBASE register. Likewise, when the Periodic Schedule Enable
bit is one, then the host controller does use the USB_PERIODICLISTBASE register to
traverse the periodic schedule.
The host controller will not react to modifications to the Periodic Schedule Enable
immediately. In order to eliminate conflicts with split transactions, the host controller
evaluates the Periodic Schedule Enable bit only when FRINDEX[2:0] is zero. System
software must not disable the periodic schedule if the schedule contains an active split
transaction work item that spans the 000b micro-frame. These work items must be
removed from the schedule before the Periodic Schedule Enable bit is written to zero.
The Periodic Schedule Status bit in the USB_USBSTS register indicates status of the
periodic schedule. System software enables (or disables) the periodic schedule by writing
one (or zero) to the Periodic Schedule Enable bit in the USB_USBCMD register.
Software then can poll the Periodic Schedule Status bit to determine when the periodic
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3696
NXP Semiconductors

<!-- page 3697 -->

schedule has made the desired transition. Software must not modify the Periodic
Schedule Enable bit unless the value of the Periodic Schedule Enable bit equals that of
the Periodic Schedule Status bit.
The periodic schedule is used to manage all isochronous and interrupt transfer streams.
The base of the periodic schedule is the periodic frame list. Software links schedule data
structures to the periodic frame list to produce a graph of scheduled data structures. The
graph represents an appropriate sequence of transactions.
The following figure illustrates isochronous transfers (using iTDs and siTDs) with a
period of one are linked directly to the periodic frame list. Interrupt transfers (are
managed with queue heads) and isochronous streams with periods other than one are
linked following the period-one iTD/siTDs. Interrupt queue heads are linked into the
frame list ordered by poll rate. Longer poll rates are linked first (for example, closest to
the periodic frame list), followed by shorter poll rates, with queue heads with a poll rate
of one, on the very end.
A
A
A
A
A
A
8
4
1
Last
Periodic
has End of
List Mark
A
Isochronous Transfer
Descriptor(s)
1024, 512, or 256
elements
Periodic Frame List
Interrupt Queue
Heads
Poll Rate: 1
Poll Rate: N → 1
Figure 56-11. Example Periodic Schedule
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3697

<!-- page 3698 -->

56.4.3.7
Managing Isochronous Transfers Using iTDs
The structure of an iTD is presented in Isochronous (High-Speed) Transfer Descriptor
(iTD). The four distinct sections to an iTD:
• The first field is the Next Link Pointer. This field is for schedule linkage purposes
only.
• Transaction description array. This area is an eight-element array. Each element
represents control and status information for one micro-frame's worth of transactions
for a single high-speed isochronous endpoint.
• The buffer page pointer array is a 7-element array of physical memory pointers to
data buffers. These are 4 K aligned pointers to physical memory.
• Endpoint capabilities. This area utilizes the unused low-order 12 bits of the buffer
page pointer array. The fields in this area are used across all transactions executed for
this iTD, including endpoint addressing, transfer direction, maximum packet size and
high-bandwidth multiplier.
56.4.3.7.1
Host Controller Operational Model for iTDs
The host controller uses FRINDEX register bits [12:3] to index into the periodic frame
list. This means that the host controller visits each frame list element eight consecutive
times before incrementing to the next periodic frame list element. Each iTD contains
eight transaction descriptions, which map directly to FRINDEX register bits [2:0].
Therefore, each transaction descriptor corresponds to one micro-frame. Each iTD can
span 8 micro-frames worth of transactions.
When the host controller fetches an iTD, it uses FRINDEX register bits [2:0] to index
into the transaction description array.
If the active bit in the Status field of the indexed transaction description is set to zero, the
host controller ignores the iTD and follows the Next pointer to the next schedule data
structure.
When the indexed active bit is one, the host controller continues to parse the iTD. It
stores the indexed transaction description and the general endpoint information (device
address, endpoint number, maximum packet size, and so on.). It also uses the Page Select
(PG) field to index the buffer pointer array, storing the selected buffer pointer and the
next sequential buffer pointer. For example, if PG field is 0, then the host controller
stores Page 0 and Page 1.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3698
NXP Semiconductors

<!-- page 3699 -->

The host controller constructs a physical data buffer address by concatenating the current
buffer pointer (as selected using the current transaction description's PG field) and the
transaction description's Transaction Offset field. The host controller uses the endpoint
addressing information and I/O-bit to execute a transaction to the appropriate endpoint.
When the transaction is complete, the host controller clears the active bit and writes back
any additional status information to the Status field in the currently selected transaction
description.
The data buffer associated with the iTD must be virtually contiguous memory. Seven
page pointers are provided to support eight high-bandwidth transactions regardless of the
starting packet's offset alignment into the first page. A starting buffer pointer (physical
memory address) is constructed by concatenating the page pointer (for example, page 0
pointer) selected by the active transaction descriptions' PG (for example, value: 00B)
field with the transaction offset field. As the transaction moves data, the host controller
must detect when an increment of the current buffer pointer crosses a page boundary.
When this occurs the host controller simply replaces the current buffer pointer's page
portion with the next page pointer (for example, page 1 pointer) and continues to move
data. The size of each bus transaction is determined by the value in the Maximum Packet
Size field. An iTD supports high-bandwidth pipes through the Mult (multiplier) field.
When the Mult field is 1, 2, or 3, the host controller executes the specified number of
Maximum Packet sized bus transactions for the endpoint in the current micro-frame. In
other words, the Mult field represents a transaction count for the endpoint in the current
micro-frame. If the Mult field is zero, the operation of the host controller is undefined.
The transfer description is used to service all transactions indicated by the Mult field.
For OUT transfers, the value of the Transaction X Length field represents the total bytes
to be sent during the micro-frame. The Mult field must be set by software to be consistent
with Transaction X Length and Maximum Packet Sixe. The host controller sends the
bytes in Maximum Packet Size'd portions. After each transaction, the host controller
decrements its local copy of Transaction X Length by Maximum Packet Size. The
number of bytes the host controller sends is always Maximum Packet Size or Transaction
X Length, whichever is less. The host controller advances the transfer state in the transfer
description, updates the appropriate record in the iTD and moves to the next schedule
data structure. The maximum sized transaction supported is 3 x 1024 bytes.
For IN transfers, the host controller issues Mult transactions. It is assumed that software
has properly initialized the iTD to accommodate all of the possible data. During each IN
transaction, the host controller must use Maximum Packet Size to detect packet babble
errors. The host controller keeps the sum of bytes received in the Transaction X Length
field. After all transactions for the endpoint have completed for the micro-frame,
Transaction X Length contains the total bytes received. If the final value of Transaction
X Length is less than the value of Maximum Packet Size, then less data than was allowed
for was received from the associated endpoint. This short packet condition does not set
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3699

<!-- page 3700 -->

the USBINT bit in the USB_USBSTS register to one. The host controller will not detect
this condition. If the device sends more than Transaction X Length or Maximum Packet
Size bytes (whichever is less), then the host controller sets the Babble Detected bit to one
and set the Active bit to zero. Note, that the host controller is not required to update the
iTD field Transaction X Length in this error scenario. If the Mult field is greater than one,
then the host controller automatically executes the value of Mult transactions. The host
controller will not execute all Mult transactions if:
• The endpoint is an OUT and Transaction X Length goes to zero before all the Mult
transactions have executed (ran out of data), or
• The endpoint is an IN and the endpoint delivers a short packet, or an error occurs on
a transaction before Mult transactions have been executed. The end of micro-frame
may occur before all of the transaction opportunities have been executed. When this
happens, the transfer state of the transfer description is advanced to reflect the
progress that was made, the result written back to the iTD and the host controller
proceeds to processing the next micro-frame. Refer to Appendix D for a table
summary of the host controller required behavior for all the high-bandwidth
transaction cases.
56.4.3.7.2
Software Operational Model for iTDs
A client buffer request to an isochronous endpoint may span 1 to N micro-frames. When
N is larger than one, system software may have to use multiple iTDs to read or write data
with the buffer (if N is larger than eight, it must use more than one iTD).
The following figure illustrates the simple model of how a client buffer is mapped by
system software to the periodic schedule (that is the periodic frame list and a set of iTDs).
On the right is the client description of its request. The description includes a buffer base
address plus additional annotations to identify which portions of the buffer should be
used with each bus transaction. In the middle is the iTD data structures used by the
system software to service the client request. Each iTD can be initialized to service up to
24 transactions, organized into eight groups of up to three transactions each. Each group
maps to one micro-frame's worth of transactions. The EHCI controller does not provide
per-transaction results within a micro-frame. It treats the per-micro-frame transactions as
a single logical transfer. On the left is the host controller's frame list. System software
establishes references from the appropriate locations in the frame list to each of the
appropriate iTDs. If the buffer is large, then system software can use a small set of iTDs
to service the entire buffer. System software can activate the transaction description
records (contained in each iTD) in any pattern required for the particular data stream.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3700
NXP Semiconductors

<!-- page 3701 -->

Frame i
Frame i+1
Frame i+2
Frame i+n
iTD0
iTD1
iTDn
. . .
. . .
. . .
. . .
Client
Request
USB Xact
Information
Figure 56-12. Example Association of iTDs to Client Request Buffer
As noted above, the client request includes a pointer to the base of the buffer and offsets
into the buffer to annotate which buffer sections are to be used on each bus transaction
that occurs on this endpoint. System software must initialize each transaction description
in an iTD to ensure it uses the correct portion of the client buffer. For example, for each
transaction description, the PG field is set to index the correct physical buffer page
pointer and the Transaction Offset field is set relative to the correct buffer pointer page
(for example, the same one referenced by the PG field). When the host controller
executes a transaction it selects a transaction description record based on FRINDEX[2:0].
It then uses the current Page Buffer Pointer (as selected by the PG field) and concatenates
to the transaction offset field. The result is a starting buffer address for the transaction. As
the host controller moves data for the transaction, it must watch for a page wrap condition
and properly advance to the next available Page Buffer Pointer. System software must not
use the Page 6 buffer pointer in a transaction description where the length of the transfer
wraps a page boundary. Doing so yields undefined behavior. The host controller
hardware is not required to 'alias' the page selector to Page zero. USB 2.0 isochronous
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3701

<!-- page 3702 -->

endpoints can specify a period greater than one. Software can achieve the appropriate
scheduling by linking iTDs into the appropriate frames (relative to the frame list) and by
setting appropriate transaction description elements active bits to one.
56.4.3.7.2.1
Periodic scheduling threshold
The Isochronous Scheduling Threshold field in the USB_HCCPARAMS capability
register is an indicator to system software as to how the host controller pre-fetches and
effectively caches schedule data structures.
It is used by system software when adding isochronous work items to the periodic
schedule. The value of this field indicates to system software the minimum distance it can
update isochronous data (relative to the current location of the host controller execution
in the periodic list) and still have the host controller process them.
The iTD and siTD data structures each describe 8 micro-frames worth of transactions.
The host controller is allowed to cache one (or more) of these data structures in order to
reduce memory traffic. Three basic caching models that account for the fact the
isochronous data structures span 8 micro-frames. The three caching models are: no
caching, micro-frame caching and frame caching.
When software is adding new isochronous transactions to the schedule, it always
performs a read of the USB_FRINDEX register to determine the current frame and
micro-frame the host controller is currently executing. Of course, there is no information
about where in the micro-frame the host controller is, so a constant uncertainty-factor of
one micro-frame has to be assumed. Combining the knowledge of where the host
controller is executing with the knowledge of the caching model allows the definition of
simple algorithms for how closely software can reliably work to the executing host
controller.
No caching is indicated with a value of zero in the Isochronous Scheduling Threshold
field. The host controller may pre-fetch data structures during a periodic schedule
traversal (per micro-frame) but always dumps any accumulated schedule state at the end
of the micro-frame. At the appropriate time relative to the beginning of every micro-
frame, the host controller always begins schedule traversal from the frame list. Software
can use the value of the USB_FRINDEX register (plus the constant 1 uncertainty-factor)
to determine the approximate position of the executing host controller. When no caching
is selected, software can add an isochronous transaction as near as 2 micro-frames in
front of the current executing position of the host controller.
Frame caching is indicated with a non-zero value in bit [7] of the Isochronous Scheduling
Threshold field. In the frame-caching model, system software assumes that the host
controller caches one (or more) isochronous data structures for an entire frame (8 micro-
frames). Software uses the value of the USB_FRINDEX register (plus the constant 1
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3702
NXP Semiconductors

<!-- page 3703 -->

uncertainty) to determine the current micro-frame/frame (assume modulo 8 arithmetic in
adding the constant 1 to the micro-frame number). For any current frame N, if the current
micro-frame is 0 to 6, then software can safely add isochronous transactions to Frame N
+ 1. If the current micro-frame is 7, then software can add isochronous transactions to
Frame N + 2.
Micro-frame caching is indicated with a non-zero value in the least-significant 3 bits of
the Isochronous Scheduling Threshold field. System software assumes the host controller
caches one or more periodic data structures for the number of micro-frames indicated in
the Isochronous Scheduling Threshold field. For example, if the count value were 2, then
the host controller keeps a window of 2 micro-frames worth of state (current micro-
frame, plus the next) on-chip. On each micro-frame boundary, the host controller releases
the current micro-frame state and begins accumulating the next micro-frame state.
56.4.3.8
Asynchronous Schedule
The Asynchronous schedule traversal is enabled or disabled through the Asynchronous
Schedule Enable bit in the USB_USBCMD register.
If the Asynchronous Schedule Enable bit is set to zero, then the host controller simply
does not try to access the asynchronous schedule through the USB_ASYNCLISTADDR
register. Likewise, when the Asynchronous Schedule Enable bit is one, then the host
controller does use the USB_ASYNCLISTADDR register to traverse the asynchronous
schedule. Modifications to the Asynchronous Schedule Enable bit are not necessarily
immediate. Rather the new value of the bit is taken into consideration the next time the
host controller needs to use the value of the USB_ASYNCLISTADDR register to get the
next queue head.
The Asynchronous Schedule Status bit in the USB_USBSTS register indicates status of
the asynchronous schedule. System software enables (or disables) the asynchronous
schedule by writing one (or zero) to the Asynchronous Schedule Enable bit in the
USB_USBCMD register. Software then can poll the Asynchronous Schedule Status bit to
determine when the asynchronous schedule has made the desired transition. Software
must not modify the Asynchronous Schedule Enable bit unless the value of the
Asynchronous Schedule Enable bit equals that of the Asynchronous Schedule Status bit.
The asynchronous schedule is used to manage all Control and Bulk transfers. Control and
Bulk transfers are managed using queue head data structures. The asynchronous schedule
is based at the USB_ASYNCLISTADDR register. The default value of the
USB_ASYNCLISTADDR register after reset is undefined and the schedule is disabled
when the Asynchronous Schedule Enable bit is zero.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3703

<!-- page 3704 -->

Software may only write this register with defined results when the schedule is disabled.
For example, Asynchronous Schedule Enable bit in the USB_USBCMD and the
Asynchronous Schedule Status bit in the USB_USBSTS register are zero. System
software enables execution from the asynchronous schedule by writing a valid memory
address (of a queue head) into this register. Then software enables the asynchronous
schedule by setting the Asynchronous Schedule Enable bit to one. The asynchronous
schedule is actually enabled when the Asynchronous Schedule Status bit is one.
When the host controller begins servicing the asynchronous schedule, it begins by using
the value of the USB_ASYNCLISTADDR register. It reads the first referenced data
structure and begins executing transactions and traversing the linked list as appropriate.
When the host controller completes processing the asynchronous schedule, it retains the
value of the last accessed queue head's horizontal pointer in the
USB_ASYNCLISTADDR register. Next time the asynchronous schedule is accessed,
this is the first data structure that is serviced. This provides round-robin fairness for
processing the asynchronous schedule.
A host controller completes processing the asynchronous schedule when one of the
following events occur:
• The end of a micro-frame occurs.
• The host controller detects an empty list condition (see Empty Asynchronous
Schedule Detection )
• The schedule has been disabled through the Asynchronous Schedule Enable bit in the
USB_USBCMD register.
The queue heads in the asynchronous list are linked into a simple circular list as shown in
Figure 56-7. Queue head data structures are the only valid data structures that may be
linked into the asynchronous schedule. An isochronous transfer descriptor (iTD or siTD)
in the asynchronous schedule yields undefined results.
The maximum packet size field in a queue head is sized to accommodate the use of this
data structure for all non-isochronous transfer types. The USB Specification, Revision 2.0
specifies the maximum packet sizes for all transfer types and transfer speeds. System
software should always parameterize the queue head data structures according to the core
specification requirements.
56.4.3.8.1
Adding Queue Heads to Asynchronous Schedule
This is a software requirement section.
There are two independent events for adding queue heads to the asynchronous schedule.
The first is the initial activation of the asynchronous list. The second is inserting a new
queue head into an activated asynchronous list.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3704
NXP Semiconductors

<!-- page 3705 -->

Activation of the list is simple. System software writes the physical memory address of a
queue head into the USB_ASYNCLISTADDR register, then enables the list by setting
the Asynchronous Schedule Enable bit in the USB_USBCMD register to one.
When inserting a queue head into an active list, software must ensure that the schedule is
always coherent from the host controllers' point of view. This means that the system
software must ensure that all queue head pointer fields are valid. For example, qTD
pointers have T-Bits set to one or reference valid qTDs and the Horizontal Pointer
references a valid queue head data structure. The following algorithm represents the
functional requirements:
InsertQueueHead (pQHeadCurrent, pQueueHeadNew) 
          --
          -- Requirement: all inputs must be properly initialized.
          --
          -- pQHeadCurrent is a pointer to a queue head that is
          -- already in the active list 
          -- pQHeadNew is a pointer to the queue head to be added 
          --
          -- This algorithm links a new queue head into a existing
          -- list 
          --
          pQueueHeadNew.HorizontalPointer  =  pQueueHeadCurrent.HorizontalPointer
          pQueueHeadCurrent.HorizontalPointer =  physicalAddressOf(pQueueHeadNew)
End InsertQueueHead
56.4.3.8.2
Removing Queue Heads from Asynchronous Schedule
This is a software requirement section.
There are two independent events for removing queue heads from the asynchronous
schedule. The first is shutting down (deactivating) the asynchronous list. The second is
extracting a single queue head from an activated list.
Software deactivates the asynchronous schedule by setting the Asynchronous Schedule
Enable bit in the USB_USBCMD register to zero. Software can determine when the list
is idle when the Asynchronous Schedule Status bit in the USB_USBSTS register is zero.
The normal mode of operation is that software removes queue heads from the
asynchronous schedule without shutting it down. Software must not remove an active
queue head from the schedule. Software should first deactivate all active qTDs, wait for
the queue head to go inactive, then remove the queue head from the asynchronous list.
Software removes a queue head from the asynchronous list through the following
algorithm. As illustrated, the unlinking is quite easy. Software merely must ensure all of
the link pointers reachable by the host controller are kept consistent.
UnlinkQueueHead (pQHeadPrevious, pQueueHeadToUnlink, pQHeadNext) 
          --
          -- Requirement: all inputs must be properly initialized.
          --
          -- pQHeadPrevious is a pointer to a queue head that
          -- references the queue head to remove 
          -- pQHeadToUnlink is a pointer to the queue head to be
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3705

<!-- page 3706 -->

          -- removed
          -- pQheadNext is a pointer to a queue head still in the 
          -- schedule. Software provides this pointer with the 
          -- following strict rules: 
          --          if the host software is one queue head, then 
          --          pQHeadNext must be the same as 
          --          QueueheadToUnlink.HorizontalPointer. If the host 
          --          software is unlinking a consecutive series of 
          --          queue heads, QHeadNext must be set by software to 
          --          the  queue head remaining in the schedule.
          --
          -- This algorithm unlinks a queue head from a circular list 
          --
          pQueueHeadPrevious.HorizontalPointer =  pQueueHeadToUnlink.HorizontalPointer 
                               pQueueHeadToUnlink.HorizontalPointer = pQHeadNext
End UnlinkQueueHead
If software removes the queue head with the H-bit set to one, it must select another queue
head still linked into the schedule and set its H-bit to one. This should be completed
before removing the queue head. The requirement is that software keep one queue head
in the asynchronous schedule, with its H-bit set to one. At the point software has removed
one or more queue heads from the asynchronous schedule, it is unknown whether the host
controller has a cached pointer to them. Similarly, it is unknown how long the host
controller might retain the cached information, as it is implementation dependent and
may be affected by the actual dynamics of the schedule load. Therefore, once software
has removed a queue head from the asynchronous list, it must retain the coherency of the
queue head (link pointers, and so on). It cannot disturb the removed queue heads until it
knows that the host controller does not have a local copy of a pointer to any of the
removed data structures.
The method software uses to determine when it is safe to modify a removed queue head
is to handshake with the host controller. The handshake mechanism allows software to
remove items from the asynchronous schedule, then execute a simple, lightweight
handshake that is used by software as a key that it can free (or reuse) the memory
associated the data structures it has removed from the asynchronous schedule.
The handshake is implemented with three bits in the host controller. The first bit is a
command bit (Interrupt on Async Advance Doorbell bit in the USB_USBCMD register)
that allows software to inform the host controller that something has been removed from
its asynchronous schedule. The second bit is a status bit (Interrupt on Async Advance bit
in the USB_USBSTS register) that the host controller sets after it has released all on-chip
state that may potentially reference one of the data structures just removed. When the
host controller sets this status bit to one, it also sets the command bit to zero. The third bit
is an interrupt enable (Interrupt on Async Advance bit in the USB_USBINTR register)
that is matched with the status bit. If the status bit is one and the interrupt enable bit is
one, then the host controller asserts a hardware interrupt.
The figure below illustrates a general example. In this example, consecutive queue heads
(B and C) are unlinked from the schedule using the algorithm above. Before the unlink
operation, the host controller has a copy of queue head A.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3706
NXP Semiconductors

<!-- page 3707 -->

The unlink algorithm requires that as software unlinks each queue head, the unlinked
queue head is loaded with the address of a queue head that remains in the asynchronous
schedule.
When the host controller observes that doorbell bit being set to one, it makes a note of the
local reachable schedule information. In this example, the local reachable schedule
information includes both queue heads (A and B). It is sufficient that the host controller
can set the status bit (and clear the doorbell bit) as soon as it has traversed beyond current
reachable schedule information (that is traversed beyond queue head (B) in this example).
The following figure illustrates the generic queue head unlink scenario.
A
B
C
D
Memory State
A
USBCMD.Interrupt on Async Advance Doorbell = 0
HC State
Before Unlink
A
B
C
D
Memory State
A
USBCMD.Interrupt on Async Advance Doorbell = 1
USBSTS.Interrupt on Async Advance = 0
HC State
After Unlink (B,C) & @ Doorbell
A
B
C
D
Memory State
D
USBCMD.Interrupt on Async Advance Doorbell = 0
USBSTS.Interrupt on Async Advance = 1
HC State
After Doorbell
Figure 56-13. Generic Queue Head Unlink Scenario
Alternatively, a host controller implementation is allowed to traverse the entire
asynchronous schedule list (for example, observed the head of the queue (twice)) before
setting the Advance on Async status bit to one.
Software may re-use the memory associated with the removed queue heads after it
observes the Interrupt on Async Advance status bit is set to one, following assertion of
the doorbell. Software should acknowledge the Interrupt on Async Advance status as
indicated in the USB_USBSTS register, before using the doorbell handshake again.
56.4.3.8.3
Empty Asynchronous Schedule Detection
The Enhanced Host Controller Interface uses two bits to detect when the asynchronous
schedule is empty.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3707

<!-- page 3708 -->

The queue head data structure (see Table 56-25) defines an H-bit in the queue head,
which allows software to mark a queue head as being the head of the reclaim list. The
Enhanced Host Controller Interface also keeps a 1-bit flag in the USB_USBSTS register
(Reclamation) that is set to zero when the Enhanced Interface Host Controller observes a
queue head with the H-bit set to one. The reclamation flag in the status register is set to
one when any USB transaction from the asynchronous schedule is executed (or whenever
the asynchronous schedule starts, see Asynchronous schedule traversal: Start Event).
If the Enhanced Host Controller Interface ever encounters an H-bit of one and a
Reclamation bit of zero, the EHCI controller simply stops traversal of the asynchronous
schedule.
An example illustrating the H-bit in a schedule is shown in the following figure.
Horizontal Ptr
0
01
1
H
Operational Area
Typ T
Horizontal Ptr
0
01
0
H
Operational Area
Typ T
Horizontal Ptr
0
01
0
H
Operational Area
Typ T
List Head
Asynchronous Schedule
USBCMD
USBSTS
ASYNCLISTADDR
. . .
. . .
Operational
Registers
Reclamation Flag
1: Transaction Executed
0: Head of List Seen
Figure 56-14. Asynchronous Schedule List w/Annotation to Mark Head of List
Software must ensure there is at most one queue head with the H-bit set to one, and that it
is always coherent with respect to the schedule.
56.4.3.8.4
Restarting Asynchronous Schedule Before EOF
There are many situations where the host controller will detect an empty list long before
the end of the micro-frame.
It is important to remember that under many circumstances the schedule traversal has
stopped due to Nak/Nyet responses from all endpoints.
An example of particular interest is when a start-split for a bulk endpoint occurs early in
the micro-frame. Given the EHCI simple traversal rules, the complete-split for that
transaction may Nak/Nyet out very quickly. If it is the only item in the schedule, then the
host controller ceases traversal of the Asynchronous schedule very early in the micro-
frame. In order to provide reasonable service to this endpoint, the host controller should
issue the complete-split before the end of the current micro-frame, instead of waiting
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3708
NXP Semiconductors

<!-- page 3709 -->

until the next micro-frame. When the reason for host controller idling asynchronous
schedule traversal is because of empty list detection, it is mandatory the host controller
implement a 'waking' method to resume traversal of the asynchronous schedule. An
example method is described below.
56.4.3.8.4.1
Example Method for Restarting Asynchronous Schedule Traversal
The reason for idling the host controller when the list is empty is to keep the host
controller from unnecessarily occupying too much memory bandwidth. The question is:
how long should the host controller stay idle before restarting?
The answer in this example is based on deriving a manifest constant, which is the amount
of time the host controller will stay idle before restarting traversal. In this example, the
manifest constant is called AsyncSchedSleepTime, and has a value of 10 μsec. The value
is derived based on the analysis in Example Derivation for AsyncSchedSleepTime, The
traversal algorithm is simple:
• Traverse the Asynchronous schedule until the either an End-Of-micro-Frame event
occurs, or an empty list is detected. If the event is an End-of-micro-Frame, go
attempt to traverse the Periodic schedule. If the event is an empty list, then set a sleep
timer and go to a schedule sleep state.
• When the sleep timer expires, set working context to the Asynchronous Schedule
start condition and go to schedule active state. The start context allows the HC to
reload Nakcnt fields, and so on. So the HC has a chance to run for more than one
iteration through the schedule.
This process simply repeats itself each micro-frame. The figure below illustrates a sample
state machine to manage the active and sleep states of the Asynchronous Schedule
traversal policy. There are three states: Actively traversing the Asynchronous schedule,
Sleeping, and Not Active. The last two are similar in terms of interaction with the
Asynchronous schedule, but the Not Active state means that the host controller is busy
with the Periodic schedule or the Asynchronous schedule is not enabled. The Sleeping
state is specifically a special state where the host controller is just waiting for a period of
time before resuming execution of the Asynchronous schedule.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3709

<!-- page 3710 -->

Periodic Schedule Complete
And Async Schedule
Enabled
Denotes an action is
triggered by this event.
Action is described where is
defined
End of micro-Frame
End of micro-Frame => C
Sleep Timer Expires => B
Empty List => A
Asyn Sched
Active
Asyn Sched
Sleeping
Asyn Sched
Not Active
End of micro-Frame
Figure 56-15. Example State Machine for Managing Asynchronous Schedule Traversal
The actions referred to in the figure above are defined in the following table.
Table 56-40. Asynchronous Schedule SM Transition Actions
Action
Action Description Label
A
On detection of the empty list, the host controller sets the AsynchronousTraversalSleepTimer to
AsyncSchedSleepTime.
B
When the AsynchronousTraversalSleepTimer expires, the host controller sets the Reclamation bit in the
USBSTS register to one and moves the Nak Counter reload state machine to WaitForListHead (see Nak Count
Reload Control ).
C
The host controller cancels the sleep timer (AsynchronousTraversalSleepTimer).
56.4.3.8.4.2
Async Sched Not Active
This is the initial state of the traversal state machine after a host controller reset. The
traversal state machine does not leave this state when the Asynchronous Schedule Enable
bit in the USB_USBCMD register is zero.
This state is entered from Async Sched Active or Async Sched Sleeping states when the
end-of-micro-frame event is detected.
56.4.3.8.4.3
Async Sched Active
This state is entered from the Async Sched Not Active state when the periodic schedule is
not active. It is also entered from the Async Sched Sleeping states when the
AsyncrhonousTraversalSleepTimer expires. On every transition into this state, the host
controller sets the Reclamation bit in the USB_USBSTS register to one.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3710
NXP Semiconductors

<!-- page 3711 -->

While in this state, the host controller continually traverses the asynchronous schedule
until either the end of micro-frame or an empty list condition is detected.
56.4.3.8.4.4
Async Sched Sleeping
The state is entered from the Async Sched Active state when a schedule empty condition
is detected. On entry to this state, the host controller sets the
AsynchronousTraversalSleepTimer to AsyncSchedSleepTime.
56.4.3.8.4.5
Example Derivation for AsyncSchedSleepTime
The derivation is based on analysis of what work the host controller could be doing next.
It assumes the host controller does not keep any state about what work is possibly
pending in the asynchronous schedule. The schedule could contain any mix of the
possible combinations of high- full- or low-speed control and bulk requests.
The table below summarizes some of the typical 'next transactions' that could be in the
schedule, and the amount of time (for example footprint, or wall clock) the transaction
takes to complete.
Table 56-41. Typical Low-/Full-speed Transaction Times
Transaction Attributes
Footprint (time)
Description
Speed
HS
11.9 ms
Maximum foot print for a worst-case, full-sized bulk data transaction.
Size
512
9.45 ms
Maximum footprint for an approximate best-case, full-sized bulk data
transaction.
Type
Bulk
Speed
FS
~50 ms
Approximate typical for full-sized bulk data. An 8-byte low-speed is about
2x, or between 90 and 100 ms.
Size
64
Type
Bulk
Speed
FS
~12 ms
Approximate typical for 8-byte bulk/control (that is setup)
Size
8
Type
Cntrl
A AsyncSchedSleepTime value of 10 μs provides a reasonable relaxation of the system
memory load and still provides a good level of service for the various transfer types and
payload sizes. For example, say we detect an empty list after issuing a start-split for a 64-
byte full-speed bulk request. Assuming this is the only thing in the list, the host controller
gets the results of the full-speed transaction from the hub during the fifth complete-split
request. If the full-speed transaction was an IN and it nak'd, the 10 μs sleep period would
allow the host controller to get the NAK results on the first complete-split.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3711

<!-- page 3712 -->

56.4.3.8.5
Asynchronous schedule traversal: Start Event
Once the HC has idled itself through the empty schedule detection (Section 0), it will
naturally activate and begin processing from the Periodic Schedule at the beginning of
each micro-frame.
In addition, it may have idled itself early in a micro-frame. When this occurs (idles early
in the micro-frame) the HC must occasionally re-activate during the micro-frame and
traverse the asynchronous schedule to determine whether any progress can be made. The
requirements and method for this restart are described in Restarting Asynchronous
Schedule Before EOF . Asynchronous schedule Start Events are defined to be:
• Whenever the host controller transitions from the periodic schedule to the
asynchronous schedule. If the periodic schedule is disabled and the asynchronous
schedule is enabled, then the beginning of the micro-frame is equivalent to the
transition from the periodic schedule, or
• The asynchronous schedule traversal restarts from a sleeping state (see Restarting
Asynchronous Schedule Before EOF ).
56.4.3.8.6
Reclamation Status Bit (USBSTS Register)
The operation of the empty asynchronous schedule detection feature (see Empty
Asynchronous Schedule Detection ) depends on the proper management of the
Reclamation bit in the USB_USBSTS register. The host controller tests for an empty
schedule just after it fetches a new queue head while traversing the asynchronous
schedule (see Fetch Queue Head ).
The host controller is required to set the Reclamation bit to one whenever an
asynchronous schedule traversal Start Event, as documented in Asynchronous schedule
traversal: Start Event, occurs. The Reclamation bit is also set to one whenever the host
controller executes a transaction while traversing the asynchronous schedule (see Execute
Transaction ). The host controller sets the Reclamation bit to zero whenever it finds a
queue head with its H-bit set to one. Software should only set a queue head's H-bit if the
queue head is in the asynchronous schedule. If software sets the H-bit in an interrupt
queue head to one, the resulting behavior is undefined. The host controller may set the
Reclamation bit to zero when executing from the periodic schedule.
56.4.3.9
Operational Model for Nak Counter
This section describes the operational model for the NakCnt field defined in a queue
head.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3712
NXP Semiconductors

<!-- page 3713 -->

See Queue Head Initialization for more information. Software should not use this feature
for interrupt queue heads. This rule is not required to be enforced by the host controller.
USB protocol has built-in flow control through the Nak response by a device. There are
several scenarios, beyond the Ping feature, where an endpoint may naturally Nak or Nyet
the majority of the time. An example is the host controller management of the split
transaction protocol for control and bulk endpoints. All bulk endpoints (High- or Full-
speed) are serviced through the same asynchronous schedule. The time between the Start-
split transaction and the first Complete-split transaction could be very short (that is like
when the endpoint is the only one in the asynchronous schedule). The hub NYETs
(effectively Naks) the Complete-split transaction until the classic transaction is complete.
This could result in the host controller thrashing memory, repeatedly fetching the queue
head and executing the transaction to the Hub, which does not complete until after the
transaction on the classic bus completes.
The two component fields in a queue head to support the throttling feature: a counter
field (NakCnt), and a counter reload field (RL). NakCnt is used by the host controller as
one of the criteria to determine whether or not to execute a transaction to the endpoint.
The two operational modes associated with this counter:
• Not Used- This mode is set when the RL field is zero. The host controller ignores the
NakCnt field for any execution of transactions through a queue head with an RL field
of zero. Software must use this selection for interrupt endpoints.
• Nak Throttle Mode- This mode is selected when the RL field is non-zero. In this
mode, the value in the NakCnt field represents the maximum number of Nak or Nyet
responses the host controller tolerates on each endpoint. In this mode, the HC
decrements the NakCnt field based on the token/handshake criteria listed in the table
below. The host controller must reload NakCnt when the endpoint successfully
moves data (for example, policy to reward device for moving data).
The following table describes the NakCnt field adjustment rules.
Table 56-42. NakCnt Field Adjustment Rules
Token
Handshake
Handshake NAK
NYET
IN/PING
decrement NakCnt
N/A (protocol error)
OUT
decrement NakCnt
No Action1 Start
Split
decrement NakCnt
N/A (protocol error)
Complete Split
No Action
Decrement NakCnt
1.
Recommended behavior on this response is to reload NakCnt
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3713

<!-- page 3714 -->

In summary, system software enables the counter by setting the reload field (RL) to a
non-zero value. The host controller may execute a transaction if NakCnt is non-zero. The
host controller does not execute a transaction if NakCnt is zero. The reload mechanism is
described in detail in Nak Count Reload Control .
NOTE
When all queue heads in the Asynchronous Schedule either
exhausts all transfers or all NakCnt's go to zero, then the host
controller detects an empty Asynchronous Schedule and idle
schedule traversal (see Empty Asynchronous Schedule
Detection ).
Any time the host controller begins a new traversal of the Asynchronous Schedule, a
Start Event is assumed, see Asynchronous schedule traversal: Start Event. Every time a
Start-Event occurs, the Nak Count reload procedure is enabled.
56.4.3.9.1
Nak Count Reload Control
When the host controller reaches the Execute Transaction state for a queue head
(meaning that it has an active operational state), it checks to determine whether the
NakCnt field should be reloaded from RL (see Execute Transaction ). If the answer is yes,
then RL is copied into NakCnt. After the reload or if the reload is not active, the host
controller evaluates whether to execute the transaction.
The host controller must reload nak counters (NakCnt see Table 56-25) in queue heads
during the first pass through the reclamation list after an asynchronous schedule Start
Event (see Asynchronous schedule traversal: Start Event for the definition of the Start
Event). The Asynchronous Schedule should have at most one queue head marked as the
head (see Figure 56-14).
The following figure illustrates an example state machine that satisfies the operational
requirements of the host controller detecting the first pass through the Asynchronous
Schedule. This state machine is maintained internal to the host controller and is only used
to gate reloading of the nak counter during the queue head traversal state: Execute
Transaction (see the figure below). The host controller does not perform the nak counter
reload operation if the RL field (see Table 56-25) is set to zero.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3714
NXP Semiconductors

<!-- page 3715 -->

Do Reload
Wait for List
Head
Wait for
Start Event
QH.H == 1
Start
Event
QH.H == 1
Figure 56-16. Example HC State Machine for Controlling Nak Counter Reloads
56.4.3.9.1.1
Wait for List Head
This is the initial state.
The state machine enters this state from Wait for Start Event when a start event as
defined in Asynchronous schedule traversal: Start Event occurs.
The purpose of this state is to wait for the first observation of the head of the
Asynchronous Schedule.
This occurs when the host controller fetches a queue head whose H-bit is set to one.
56.4.3.9.1.2
Do Reload
This state is entered from the Wait for List Head state when the host controller fetches a
queue head with the H-bit set to one. While in this state, the host controller performs nak
counter reloads for every queue head visited that has a non-zero nak reload value (RL)
field.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3715

<!-- page 3716 -->

56.4.3.9.1.3
Wait for Start Event
This state is entered from the Do Reload state when a queue head with the H-bit set to
one is fetched. While in this state, the host controller does not perform nak counter
reloads.
56.4.3.10
Managing Control/Bulk/Interrupt Transfers through Queue
Heads
This section presents an overview of how the host controller interacts with queuing data
structures.
Queue heads use the Queue Element Transfer Descriptor (qTD) structure. One queue
head is used to manage the data stream for one endpoint. The queue head structure
contains static endpoint characteristics and capabilities. It also contains a working area
from where individual bus transactions for an endpoint are executed (see Overlay area
defined in Table 56-25). Each qTD represents one or more bus transactions, which is
defined in the context of this specification as a transfer.
The general processing model for the host controller's use of a queue head is simple:
• read a queue head,
• execute a transaction from the overlay area,
• write back the results of the transaction to the overlay area,
• move to the next queue head.
If the host controller encounters errors during a transaction, the host controller sets one
(or more) of the error reporting bits in the queue head's Status field. The Status field
accumulates all errors encountered during the execution of a qTD (for example, the error
bits in the queue head Status field are 'sticky' until the transfer (qTD) has completed).
This state is always written back to the source qTD when the transfer is complete. On
transfer (for example, buffer or halt conditions) boundaries, the host controller must auto-
advance (without software intervention) to the next qTD. Additionally, the hardware
must be able to halt the queue so no additional bus transactions occurs for the endpoint
and the host controller does not advance the queue.
An example host controller operational state machine of a queue head traversal is
illustrated in the following figure. This state machine is a model for how a host controller
should traverse a queue head. The host controller must be able to advance the queue from
the Fetch QH state in order to avoid all hardware/software race conditions. This simple
mechanism allows software to simply link qTDs to the queue head and activate them,
then the host controller always find them if/when they are reachable. The figure below
illustrates the Host Controller Queue Head Traversal State Machine.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3716
NXP Semiconductors

<!-- page 3717 -->

Execute
Transaction
Fetch QH
Write Back
qTD
Advance
Queue
Active
And !Halted
!Active
Active
Halted or
!Active and 1 bit
Start
Active
!Active
And !Halted
Follow Qh
Horizontal
Pointer
!Active
Figure 56-17. Host Controller Queue Head Traversal State Machine
This traversal state machine applies to all queue heads, regardless of transfer type or
whether split transactions are required. The following sections describe each state. Each
state description describes the entry criteria. The Execute Transaction state (see Execute
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3717

<!-- page 3718 -->

Transaction ) describes the basic requirements for all endpoints. Split Transactions for
Asynchronous Transfers and Split Transaction Interrupt describe details of the required
extensions to the Execute Transaction state for endpoints requiring split transactions.
NOTE
Prior to software placing a queue head into either the periodic
or asynchronous list, software must ensure the queue head is
properly initialized. Minimally, the queue head should be
initialized to the following (see Section Queue Head for layout
of a queue head):
Valid static endpoint state.
• For the very first use of a queue head, software may zero-out the queue head transfer
overlay, then set the Next qTD Pointer field value to reference a valid qTD.
56.4.3.10.1
Fetch Queue Head
A queue head can be referenced from the physical address stored in the
ASYNCLISTADDR Register (see Next Asynch. Address (USB_nASYNCLISTADDR))/
Endpoint List Address (USB_nENDPTLISTADDR) Additionally, it may be referenced
from the Next LinkPointer field of an iTD, siTD, FSTN or another Queue Head. If the
referencing link pointer has the Typ field set to indicate a queue head, it is assumed to
reference a queue head structure as defined in Table 56-25.
While in this state, the host controller performs operations to implement empty schedule
detection (see Empty Asynchronous Schedule Detection ) and Nak Counter reloads (see
Operational Model for Nak Counter). After the queue head has been fetched, the host
controller conducts the following queries for empty schedule detection:
• If queue head is not an interrupt queue head (that is S-mask is zero), and
• The H-bit is one, and
• The Reclamation bit in the USBSTS register is zero.
When these criteria are met, the host controller stops traversing the asynchronous list (as
described in Empty Asynchronous Schedule Detection ). When the criteria are not met,
the host controller continues schedule traversal. If the queue head is not an interrupt and
the H-bit is one and the Reclamation bit is one, then the host controller sets the
Reclamation bit in the USBSTS register to zero before completing this state. The
operations for reloading of the Nak Counter are described in detail in Operational Model
for Nak Counter.
This state is complete when the queue head has been read on-chip.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3718
NXP Semiconductors

<!-- page 3719 -->

56.4.3.10.2
Advance Queue
To advance the queue, the host controller must find the next qTD, adjust pointers,
perform the overlay and write back the results to the queue head.
This state is entered from the FetchQHD state if the overlay Active and Halt bits are set to
zero. On entry to this state, the host controller determines which next pointer to use to
fetch a qTD, fetches a qTD and determines whether or not to perform an overlay.
NOTE
If the I-bit is one and the Active bit is zero, the host controller
immediately skips processing of this queue head, exits this state
and uses the horizontal pointer to the next schedule data
structure. If the field Bytes to Transfer is not zero and the T-bit
in the Alternate Next qTD Pointer is set to zero, then the host
controller uses the Alternate Next qTD Pointer. Otherwise, the
host controller uses the NextqTD Pointer. If NextqTD Pointer's
T-bit is set to one, then the host controller exits this state and
uses the horizontal pointer to the next schedule data structure.
Using the selected pointer the host controller fetches the referenced qTD. If the fetched
qTD has its Active bit set to one, the host controller moves the pointer value used to reach
the qTD (Next or Alternate Next) to the Current qTD Pointer field, then performs the
overlay. If the fetched qTD has its Active bit set to zero, the host controller aborts the
queue advance and follows the queue head's horizontal pointer to the next schedule data
structure.
The host controller performs the overlay based on the following rules:
• The value of the data toggle (dt) field in the overlay area depends on the value of the
data toggle control (dtc) bit (see Table 56-27).
• If the EPS field indicates the endpoint is a high-speed endpoint, the Ping state field is
preserved by the host controller. The value of this field is not changed as a result of
the overlay.
• C-prog-mask field is set to zero (field from incoming qTD is ignored, as is the
current contents of the overlay area).
• Frame Tag field is set to zero (field from incoming qTD is ignored, as is the current
contents of the overlay area).
• NakCnt field in the overlay area is loaded from the RL field in the queue head's Static
Endpoint State.
• All other areas of the overlay are set by the incoming qTD.
The host controller exits this state when it has committed the write to the queue head.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3719

<!-- page 3720 -->

56.4.3.10.3
Execute Transaction
The host controller enters this state from the Fetch Queue Head state only if the Active bit
in Status field of the queue head is set to one.
On entry to this state, the host controller executes a few pre-operations, then checks some
pre-condition criteria before committing to executing a transaction for the queue head.
The pre-operations performed and the pre-condition criteria depend on whether the queue
head is an interrupt endpoint. The host controller can determine that a queue head is an
interrupt queue head when the queue head's S-mask field contains a non-zero value. It is
the responsibility of software to ensure the S-mask field is appropriately initialized based
on the transfer type. There are other criteria that must be met if the EPS field indicates
that the endpoint is a low- or full-speed endpoint, see Split Transactions for
Asynchronous Transfers and Split Transaction Interrupt .
56.4.3.10.3.1
Interrupt Transfer Pre-condition Criteria
If the queue head is for an interrupt endpoint (for example, non-zero S-mask field), then
the FRINDEX[2:0] field must identify a bit in the S-mask field that has one in it.
For example, an S-mask value of 00100000b would evaluate to true only when
FRINDEX[2:0] is equal to 101b. If this condition is met then the host controller considers
this queue head for a transaction.
56.4.3.10.3.2
Asynchronous Transfer Pre-operations and Pre-condition Criteria
If the queue head is not for an interrupt endpoint (for example, zero S-mask field), then
the host controller performs one pre-operation and then evaluates one pre-condition
criteria.
The pre-operation is:
Checks the Nak counter reload state (Operational Model for Nak Counter). It may be
necessary for the host controller to reload the Nak Counter field. The reload is performed
at this time.
The pre-condition evaluated is:
• Whether or not the NakCnt field has been reloaded, the host controller checks the
value of the NakCnt field in the queue head. If NakCnt is non-zero, or if the Reload
Nak Counter field is zero, then the host controller considers this queue head for a
transaction.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3720
NXP Semiconductors

<!-- page 3721 -->

56.4.3.10.3.3
Transfer Type Independent Pre-operations
Regardless of the transfer type, the host controller always performs at least one pre-
operation and evaluates one pre-condition. The pre-operation is:
• A host controller internal transaction (down) counter qHTransactionCounter is
loaded from the queue head's Mult field. A host controller implementation is allowed
to ignore this for queue heads on the asynchronous list. It is mandatory for interrupt
queue heads. Software should ensure that the Mult field is set appropriately for the
transfer type.
The pre-conditions evaluated are:
• The host controller determines whether there is enough time in the micro-frame to
complete this transaction (see Transaction Fit - A Best-Fit Approximation Algorithm
for an example evaluation method). If there is not enough time to complete the
transaction, the host controller exits this state.
• If the value of qHTransactionCounter for an interrupt endpoint is zero, then the host
controller exits this state.
When the pre-operations are complete and pre-conditions are met, the host controller sets
the Reclamation bit in the USBSTS register to one and then begins executing one or more
transactions using the endpoint information in the queue head. The host controller iterates
qHTransactionCounter times in this state executing transactions. After each transaction is
executed, qHTransactionCounter is decremented by one. The host controller exits this
state when one of the following events occurs:
• The qHTransactionCounter decrements to zero, or
• The endpoint responds to the transaction with any handshake other than an ACK,4 or
• The transaction experiences a transaction error, or
• The Active bit in the queue head goes to zero, or
• There is not enough time in the micro-frame left to execute the next transaction(see
Transaction Fit - A Best-Fit Approximation Algorithm ) for example method for
implementing the frame boundary test).
NOTE
For a high-bandwidth interrupt OUT endpoint, the host
controller may optionally immediately retry the transaction if it
fails.
The results of each transaction is recorded in the on-chip overlay area. If data was
successfully moved during the transaction, the transfer state in the overlay area is
advanced. To advance queue head's transfer state, the Total Bytes to Transfer field is
decremented by the number of bytes moved in the transaction, the data toggle bit (dt) is
toggled, the current page offset is advanced to the next appropriate value (for example,
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3721

<!-- page 3722 -->

advanced by the number of bytes successfully moved), and the C_Page field is updated
to the appropriate value (if necessary). See Buffer Pointer List Use for Data Streaming
with qTDs .
NOTE
The Total Bytes To Transfer field may be zero when all the
other criteria for executing a transaction are met. When this
occurs, the host controller executes zero-length transaction to
the endpoint. If the PID_Code field indicates an IN transaction
and the device delivers data, the host controller detects a packet
babble condition, set the babble and halted bits in the Status
field, set the Active bit to zero, write back the results to the
source qTD, then exit this state.
In the event an IN token receives a data PID mismatch response, the host controller must
ignore the received data (for example not advance the transfer state for the bytes
received). Additionally, if the endpoint is an interrupt IN, then the host controller must
record that the transaction occurred (for example, decrement qHTransactionCounter). It
is recommended (but not required) the host controller continue executing transactions for
this endpoint if the resultant value of qHTransactionCounter is greater than one.
If the response to the IN bus transaction is a Nak (or Nyet) and RL is non-zero, NakCnt is
decremented by one. If RL is zero, then no write-back by the host controller is required
(for a transaction receiving a Nak or Nyet response and the value of CErr did not
change). Software should set the RL field to zero if the queue head is an interrupt
endpoint. Host controller hardware is not required to enforce this rule or operation.
After the transaction has finished and the host controller has completed the post
processing of the results (advancing the transfer state and possibly NakCnt, the host
controller writes back the results of the transaction to the queue head's overlay area in
main memory).
The number of bytes moved during an IN transaction depends on how much data the
device endpoint delivers. The maximum number of bytes a device can send is
MaximumPacket Size. The number of bytes moved during an OUT transaction is either
Maximum Packet Length bytes or Total Bytes to Transfer, whichever is less.
If there was a transaction error during the transaction, the transfer state (as defined above)
is not advanced by the host controller. The CErr field is decremented by one and the
status field is updated to reflect the type of error observed. Transaction errors are
summarized in Transaction Error .
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3722
NXP Semiconductors

<!-- page 3723 -->

The following events causes the host controller to clear the Active bit in the queue head's
overlay status field. When the Active bit transitions from one to zero, the transfer in the
overlay is considered complete. The reason for the transfer completion (clearing the
Active bit) determines the next state.
• CErr field decrements to zero. When this occurs the Halted bit is set to one and
Active is set to zero. This results in the hardware not advancing the queue and the
pipe halts. Software must intercede to recover.
• The device responds to the transaction with a STALL PID. When this occurs, the
Halted bit is set to one and the Active bit is set to zero. This results in the hardware
not advancing the queue and the pipe halts. Software must intercede to recover.
• The Total Bytes to Transfer field is zero after the transaction completes.
• For a zero length transaction, it was zero before the transaction was started.
When this condition occurs, the Active bit is set to zero.
• The PID code is an IN, and the number of bytes moved during the transaction is less
than the Maximum Packet Length. When this occurs, the Active bit is set to zero and
a short packet condition exists. The short-packet condition is detected during the
Advance Queue state. Refer to Split Transactions for additional rules for managing
low- and full-speed transactions.
With the exception of a NAK response (when RL field is zero), the host controller always
writes the results of the transaction back to the overlay area in main memory. This
includes when the transfer completes. For a high-speed endpoint, the queue head
information written back includes minimally the following fields: The PID Code field
indicates an IN and the device sends more than the expected number of bytes (for
example Maximum Packet Length or Total Bytes to Transfer bytes, whichever is less) (for
example a packet babble). This results in the host controller setting the Halted bit to one.
• NakCnt, dt, Total Bytes to Transfer, C_Page, Status, CERR, and Current Offset
For a low- or full-speed device the queue head information written back also includes the
fields:
• C-prog-mask, FrameTag and S-bytes.
The duration of this state depends on the time it takes to complete the transaction(s) and
the status write to the overlay is committed.
56.4.3.10.3.4
Halting a Queue Head
A halted endpoint is defined only for the transfer types that are managed through queue
heads (control, bulk and interrupt).
The following events indicate that the endpoint has reached a condition where no more
activity can occur without intervention from the driver:
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3723

<!-- page 3724 -->

• An endpoint may return a STALL handshake during a transaction,
• A transaction had three consecutive error conditions, or
• A Packet Babble error occurs on the endpoint.
When any of these events occur (for a queue head) the Host Controller halts the queue
head and set the USBERRINT status bit in the USB_n_USBSTS register to one. To halt
the queue head, the Active bit is set to zero and the Halted bit is set to one. There may be
other error status bits that are set when a queue is halted. The host controller always
writes back the overlay area to the source qTD when the transfer is complete, regardless
of the reason (normal completion, short packet or halt). The host controller does not
advance the transfer state on a transaction that results in a Halt condition (for example no
updates necessary for Total Bytes to Transfer, C_Page, Current Offset, and dt). The host
controller must update CErr as appropriate. When a queue head is halted, the USB Error
Interrupt bit in the USB_n_USBSTS register is set to one. If the USB Error Interrupt
Enable bit in the USB_n_USBINTR register is set to one, a hardware interrupt is
generated at the next interrupt threshold.
56.4.3.10.3.5
Asynchronous Schedule Park Mode
Asynchronous Schedule Park mode is a special execution mode that can be enabled by
system software, where the host controller is permitted to execute more than one bus
transaction from a high-speed queue head in the Asynchronous schedule before
continuing horizontal traversal of the Asynchronous schedule.
This feature has no effect on queue heads or other data structures in the Periodic
schedule. This feature is similar in intent as the Mult feature that is used in the Periodic
schedule. Where-as the Mult feature is a characteristic that is tunable for each endpoint;
park-mode is a policy that is applied to all high-speed queue heads in the asynchronous
schedule. It is essentially the specification of an iterator for consecutive bus transactions
to the same endpoint. All of the rules for managing bus transactions and the results of
those as defined in Execute Transaction apply. This feature merely specifies how many
consecutive times the host controller is permitted to execute from the same queue head
before moving to the next queue head in the Asynchronous List. This feature should
allow the host controller to attain better bus utilization for those devices that are capable
of moving data at maximum rate, while at the same time providing a fair service to all
endpoints.
A host controller exports its capability to support this feature to system software by
setting the Asynchronous Schedule Park Capability bit in the USB_n_HCCPARAMs
register to one. This information keys system software that the Asynchronous Schedule
Park Mode Enable and Asynchronous Schedule Park Mode Count fields in the
USB_n_USBCMD register are modifiable. System software enables the feature by
writing a one to the Asynchronous Schedule Park Mode Enable bit.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3724
NXP Semiconductors

<!-- page 3725 -->

When park-mode is not enabled (for example Asynchronous Schedule Park Mode Enable
bit in the USB_n_USBCMD register is zero), the host controller must not execute more
than one bus transaction per high-speed queue head, per traversal of the asynchronous
schedule. When park-mode is enabled, the host controller must not apply the feature to a
queue head whose EPS field indicates a Low/Full-speed device (for example only one
bus transaction is allowed from each Low/Full-speed queue head per traversal of the
asynchronous schedule). Park-mode may only be applied to queue heads in the
Asynchronous schedule whose EPS field indicates that it is a high-speed device.
The host controller must apply park mode to queue heads whose EPS field indicates a
high-speed endpoint. The maximum number of consecutive bus transactions a host
controller may execute on a high-speed queue head is determined by the value in the
Asynchronous Schedule Park Mode Count field in the USB_n_USBCMD register.
Software must not set Asynchronous Schedule Park Mode Enable bit to one and also set
Asynchronous Schedule Park Mode Count field to zero. The resulting behavior is not
defined. An example behavioral example describes the operational requirements for the
host controller implementing park-mode. This feature does not affect how the host
controller handles the bus transaction as defined in Execute Transaction . It only effects
how many consecutive bus transactions for the current queue head can be executed. All
boundary conditions, error detection and reporting applies as usual. This feature is similar
in concept to the use of the Mult field for high-bandwidth Interrupt for queue heads in the
Periodic Schedule.
The host controller effectively loads an internal down-counter PM-Count from
Asynchronous Schedule Park Mode Count when Asyncrhonous Schedule Park Mode
Enable bit is one, and a high-speed queue head is first fetched and meets all the criteria
for executing a bus transaction. After the bus transaction, PM-Count is decremented. The
host controller may continue to execute bus transactions from the current queue head
until PM-Count goes to zero, an error is detected, the buffer for the current transfer is
exhausted or the endpoint responds with a flow-control or STALL handshake.
The following table summarizes the responses that effect whether the host controller
continues with another bus transaction for the current queue head.
Table 56-43. Actions for Park Mode, based on Endpoint Response and Residual Transfer
State
PID
Endpoint Response
Transfer State after Transaction
Action
PM-Count
Bytes to Transfer
IN
DATA[0,1] w/Maximum
Packet sized data
Not zero
Not Zero
Allowed to perform another bus transaction.1, 
2
Not zero
Zero
Retire qTD and move to next QH
Zero
Don't care
Move to next QH.
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3725

<!-- page 3726 -->

Table 56-43. Actions for Park Mode, based on Endpoint Response and Residual Transfer
State (continued)
DATA[0,1] w/short
packet
Don't care
Don't care
Retire qTD and move to next QH.
NAK
Don't care
Don't care
Move to next QH.
STALL, XactErr
Don't care
Don't care
Move to next QH.
OUT
ACK
Not zero
Not Zero
Allowed to perform another bus transaction.2
Not zero
Zero
Retire qTD and move to next QH
Zero
Don't' care
Move to next QH.
NYET, NAK
Don't care
Don't care
Move to next QH.
STALL, XactErr
Don't care
Don't care
Move to next QH
PING
ACK
Not Zero
Not Zero
Allowed to perform another bus transaction. 2
NAK
Don't care
Don't care
Move to next QH
STALL, XactErr
Don't care
Don't care
Move to next QH
1.
The host controller may continue to execute bus transactions from the current high-speed queue head (if PM-Count is not
equal to zero), if a PID mismatch is detected (for example expected DATA1 and received DATA0, or visa-versa).
2.
This specification does not require that the host controller execute another bus transaction when PM-Count is non-zero.
Implementations are encouraged to make appropriate complexity and performance trade-offs.
56.4.3.10.4
Write Back qTD
This state is entered from the Execute Transaction state when the Active bit is set to zero.
The source data for the write-back is the transfer results area of the queue head overlay
area (see Table 56-43).
The host controller uses the Current qTD Pointer field as the target address for the qTD.
The queue head transfer result area is written back to the transfer result area of the target
qTD. This state is also referred to as: qTD retirement. The fields that must be written
back to the source qTD include Total Bytes to Transfer, Cerr, and Status.
The duration of this state depends on when the qTD write-back is committed.
56.4.3.10.5
Follow Queue Head Horizontal Pointer
The host controller must use the horizontal pointer in the queue head to the next schedule
data structure when any of the following conditions exist:
• If the Active bit is one on exit from the Execute Transaction state, or
• When the host controller exits the Write Back qTD state, or
• If the Advance Queue state fails to advance the queue because the target qTD is not
active, or
• If the Halted bit is one on exit from the Fetch QH state.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3726
NXP Semiconductors

<!-- page 3727 -->

There is no functional requirement that the host controller wait until the current
transaction is complete before using the horizontal pointer to read the next linked data
structure. However, it must wait until the current transaction is complete before executing
the next data structure.
56.4.3.10.6
Buffer Pointer List Use for Data Streaming with qTDs
A qTD has an array of buffer pointers, which is used to reference the data buffer for a
transfer. This specification requires that the buffer associated with the transfer be
virtually contiguous.
This means: if the buffer spans more than one physical page, it must obey the following
rules (the figure below illustrates an example):
• The first portion of the buffer must begin at some offset in a page and extend through
the end of the page.
• The remaining buffer cannot be allocated in small chunks scattered around memory.
For each 4 K chunk beyond the first page, each buffer portion matches to a full 4 K
page. The final portion, which may only be large enough to occupy a portion of a
page, must start at the top of the page and be contiguous within that page.
The buffer pointer list in the qTD is long enough to support a maximum transfer size of
20 K bytes. This case occurs when all five buffer pointers are used and the first offset is
zero. A qTD handles a 16 Kbyte buffer with any starting buffer alignment.
The host controller uses the field C_Page field as an index value to determine which
buffer pointer in the list should be used to start the current transaction. The host controller
uses a different buffer pointer for each physical page of the buffer. This is always true,
even if the buffer is physically contiguous.
The host controller must detect when the current transaction spans a page boundary and
automatically move to the next available buffer pointer in the page pointer list. The next
available pointer is reached by incrementing C_Page and pulling the next page pointer
from the list. Software must ensure there are sufficient buffer pointers to move the
amount of data specified in the Bytes to Transfer field.
The following figure illustrates a nominal example of how System software would
initialize the buffer pointers list and the C_Page field for a transfer size of 16383 bytes.
C_Page is set to zero. The upper 20-bits of Page 0 references the start of the physical
page. Current Offset (the lower 12-bits of queue head Dword 7) holds the offset in the
page for example 2049 (for example 4096-2047). The remaining page pointers are set to
reference the beginning of each subsequent 4 K page.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3727

<!-- page 3728 -->

Pointer (page 0)
Pointer (page 1)
Pointer (page 2)
Pointer (page 3)
Pointer (page 4)
C_Page = 0
2047
4K
2048
4K
4K
The physical pages in memory
may or may not be physically
contiguous.
Bytes to Transfer = 16383 bytes
Page 0 = 2047
Page 1 = 4096
Page 2 = 4096
Page 3 = 4096
Page 4 = 2048
Total: 16383
Figure 56-18. Example Mapping of qTD Buffer Pointers to Buffer Pages
For the first transaction on the qTD (assuming a 512-byte transaction), the host controller
uses the first buffer pointer (page 0 because C_Page is set to zero) and concatenates the
Current Offset field. The 512 bytes are moved during the transaction, the Current Offset
and Total Bytes to Transfer are adjusted by 512 and written back to the queue head
working area.
During the 4th transaction, the host controller needs 511 bytes in page 0 and one byte in
page 1. The host controller increments C_Page (to 1) and use the page 1 pointer to move
the final byte of the transaction. After the 4th transaction, the active page pointer is the
page 1 pointer and Current Offset has rolled to one, and both are written back to the
overlay area. The transactions continue for the rest of the buffer, with the host controller
automatically moving to the next page pointer (that is C_Page) when necessary. The
three conditions for how the host controller handles C_Page:
• The current transaction does not span a page boundary. The value of C_Page is not
adjusted by the host controller.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3728
NXP Semiconductors

<!-- page 3729 -->

• The current transaction does span a page boundary. The host controller must detect
the page cross condition and advance to the next buffer while streaming data to/from
the USB.
• The current transaction completes on a page boundary (that is the last byte moved for
the current transaction is the last byte in the page for the current page pointer). The
host controller must increment C_Page before writing back status for the transaction.
NOTE
The only valid adjustment the host controller may make to
C_Page is to increment by one.
56.4.3.10.7
Adding Interrupt Queue Heads to the Periodic Schedule
The link path(s) from the periodic frame list to a queue head establishes in which frames
a transaction can be executed for the queue head. Queue heads are linked into the
periodic schedule so they are polled at the appropriate rate.
System software sets a bit in a queue head's S-Mask to indicate which micro-frame with-
in 1 msec period a transaction should be executed for the queue head. Software must
ensure that all queue heads in the periodic schedule have S-Mask set to a non-zero value.
An S-mask with zero value in the context of the periodic schedule yields undefined
results.
If the desired poll rate is greater than one frame, system software can use a combination
of queue head linking and S-Mask values to spread interrupts of equal poll rates through
the schedule so that the periodic bandwidth is allocated and managed in the most efficient
manner possible. Some examples are illustrated in the following table.
Table 56-44. Example Periodic Reference Patterns for Interrupt Transfers with 2ms Poll
Rate
Frame # Reference
Sequence
Description
0, 2, 4, 6, 8, and so on
S-Mask = 01h
A queue head for the bInterval of 2 msec (16 micro-frames) is linked into the periodic schedule so
that it is reachable from the periodic frame list locations indicated in the previous column. In
addition, the S-Mask field in the queue head is set to 01h, indicating that the transaction for the
endpoint should be executed on the bus during micro-frame 0 of the frame.
0, 2, 4, 6, 8, and so on
S-Mask = 02h
Another example of a queue head with a bInterval of 2 msec is linked into the periodic frame list at
exactly the same interval as the previous example. However, the S-Mask is set to 02h indicating
that the transaction for the endpoint should be executed on the bus during micro-frame 1 of the
frame.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3729

<!-- page 3730 -->

56.4.3.10.8
Managing Transfer Complete Interrupts from Queue Heads
The host controller sets an interrupt to be signaled at the next interrupt threshold when
the completed transfer (qTD) has an Interrupt on Complete (IOC) bit set to one, or
whenever a transfer (qTD) completes with a short packet.
If system software needs multiple qTDs to complete a client request (that is like a control
transfer) the intermediate qTDs do not require interrupts. System software may only need
a single interrupt to notify it that the complete buffer has been transferred. System
software may set IOC's to occur more frequently. A motivation for this may be that it
wants early notification so that interface data structures can be re-used in a timely
manner.
56.4.3.11
Ping Control
USB 2.0 defines an addition to the protocol for high-speed devices called Ping. Ping is
required for all USB 2.0 High-speed bulk and control endpoints.
Ping is not allowed for a split-transaction stream. This extension to the protocol
eliminates the bad side-effects of Naking OUT endpoints. The Status field has a Ping
State bit, which the host controller uses to determine the next actual PID it uses in the
next transaction to the endpoint (see the table below).
The Ping State bit is only managed by the host controller for queue heads that meet the
following criteria:
• Queue head is not an interrupt and
• EPS field equals High-Speed and
• PIDCode field equals OUT
The following table illustrates the state transition table for the host controller's
responsibility for maintaining the PING protocol. Refer to Chapter 8 in the USB
Specification Revision 2.0 for detailed description on the Ping protocol.
Table 56-45. Ping Control State Transition Table
Event
Current
Host
Device
Next
Do Ping
PING
Nak
Do Ping
Do Ping
PING
Ack
Do OUT
Do Ping
PING
XactErr 1
Do Ping
Do Ping
PING
Stall
N/C 2 Do
OUT
OUT
Nak
Do Ping
Do OUT
OUT
Nyet
Do Ping
Table continues on the next page...
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3730
NXP Semiconductors

<!-- page 3731 -->

Table 56-45. Ping Control State Transition Table (continued)
Do OUT
OUT
Ack
Do OUT
Do OUT
OUT
XactErr1
Do Ping
Do OUT
OUT
Stall
N/C 2
1.
Transaction Error (XactErr) is any time the host misses the handshake.
2.
No transition change required for the Ping State bit. The Stall handshake results in the endpoint being halted (for example
Active set to zero and Halt set to one). Software intervention is required to restart queue. 3 A Nyet response to an OUT
means that the device has accepted the data, but cannot receive any more at this time. Host must advance the transfer
state and additionally, transition the Ping State bit to Do Ping. The Ping State bit has the following encoding:
Table 56-46. Ping State bit Encoding
Value
Meaning
0B
Do OUT The host controller uses an OUT PID during the next bus transaction to this endpoint.
1B
Do Ping The host controller uses a PING PID during the next bus transaction to this endpoint.
The defined ping protocol (see USB 2.0 Specification, Chapter 8) allows the host to be
imprecise on the initialization of the ping protocol (that is start in Do OUT when we don't
know whether there is space on the device or not). The host controller manages the Ping
State bit. System software sets the initial value in the queue head when it initializes a
queue head. The host controller preserves the Ping State bit across all queue
advancements. This means that when a new qTD is written into the queue head overlay
area, the previous value of the Ping State bit is preserved.
56.4.3.12
Split Transactions
USB 2.0 defines extensions to the bus protocol for managing USB 1.x data streams
through USB 2.0 Hubs.
This section describes how the host controller uses the interface data structures to manage
data streams with full- and low-speed devices, connected below USB 2.0 hub, utilizing
the split transaction protocol.
Refer to USB 2.0 Specification for the complete definition of the split transaction
protocol. Full- and Low-speed devices are enumerated identically as high-speed devices,
but the transactions to the Full- and Low-speed endpoints use the split-transaction
protocol on the high-speed bus. The split transaction protocol is an encapsulation of (or
wrapper around) the Full- or Low-speed transaction. The high-speed wrapper portion of
the protocol is addressed to the USB 2.0 Hub and Transaction Translator below which the
Full- or Low-speed device is attached.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3731

<!-- page 3732 -->

The EHCI interface uses dedicated data structures for managing full-speed isochronous
data streams (see Split Transaction Isochronous Transfer Descriptor (siTD)). Control,
Bulk and Interrupt are managed using the queuing data structures (see Queue Head). The
interface data structures need to be programmed with the device address and the
Transaction Translator number of the USB 2.0 Hub operating as the Low-/Full-speed
host controller for this link. The following sections describe the details of how the host
controller must process and manage the split transaction protocol.
56.4.3.12.1
Split Transactions for Asynchronous Transfers
A queue head in the asynchronous schedule with an EPS field indicating a full-or low-
speed device indicates to the host controller that it must use split transactions to stream
data for this queue head.
All full-speed bulk and full-, low-speed control are managed through queue heads in the
asynchronous schedule.
Software must initialize the queue head with the appropriate device address and port
number for the transaction translator that is serving as the full/low-speed host controller
for the links connecting the endpoint. Software must also initialize the split transaction
state bit (SplitXState) to Do-Start-Split. Finally, if the endpoint is a control endpoint, then
system software must set the Control Transfer Type (C) bit in the queue head to one. If
this is not a control transfer type endpoint, the C bit must be initialized by software to be
zero. This information is used by the host controller to properly set the Endpoint Type
(ET) field in the split transaction bus token. When the C bit is zero, the split transaction
token's ET field is set to indicate a bulk endpoint. When the C bit is one, the split
transaction token's ET field is set to indicate a control endpoint. Refer to Chapter 8 of
USB Specification Revision 2.0 for details.
Do Start
Split
Do
Complete
Split
AcK
!XzctErr
.and.
!NYET
.and.
!Stall
Nyet
XactErr
XactErr
NaK
Decrement Error
Count (CERR)
and
Do immediate retry
of complete-split
Stall
Endpoint Halt
Nak
.and.
PidCode .eq. SETUP
Endpoint Active
Endpoint Halt
Decrement Error
Count (CERR)
CERR goes to zero
CERR goes to zero
Set XactErr bit and
Decrement Error
Count (CERR)
Figure 56-19. Host Controller Asynchronous Schedule Split-Transaction State Machine
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3732
NXP Semiconductors

<!-- page 3733 -->

56.4.3.12.1.1
Asynchronous - Do Start Split
This is the state which software must initialize a full- or low-speed asynchronous queue
head. This state is entered from the Do Complete Split state only after a complete-split
transaction receives a valid response from the transaction translator that is not a Nyet
handshake.
For queue heads in this state, the host controller executes a start-split transaction to the
appropriate transaction translator. If the bus transaction completes without an error and
PidCode indicates an IN or OUT transaction, then the host controller reloads the error
counter (CErr). If it is a successful bus transaction and the PidCode indicates a SETUP,
the host controller does not reload the error counter. If the transaction translator responds
with a Nak, the queue head is left in this state, and the host controller proceeds to the next
queue head in the asynchronous schedule.
If the host controller times out the transaction (no response, or bad response) the host
controller decrements Cerr and proceeds to the next queue head in the asynchronous
schedule.
56.4.3.12.1.2
Asynchronous - Do Complete Split
This state is entered from the Do Start Split state only after a start-split transaction
receives an Ack handshake from the transaction translator.
For queue heads in this state, the host controller executes a complete-split transaction to
the appropriate transaction translator. If the transaction translator responds with a Nyet
handshake, the queue head is left in this state, the error counter is reset and the host
controller proceeds to the next queue head in the asynchronous schedule. When a Nyet
handshake is received for a bus transaction where the queue head's PidCode indicates an
IN or OUT, the host controller reloads the error counter (CErr). When a Nyet handshake
is received for a complete-split bus transaction where the queue head's PidCode indicates
a SETUP, the host controller must not adjust the value of CErr.
Independent of PIDCode, the following responses have the effects:
• Transaction Error (XactErr). Timeout or data CRC failure, and so on. The error
counter (Cerr) is decremented by one and the complete split transaction is
immediately retried (if possible). If there is not enough time in the micro-frame to
execute the retry, the host controller MUST ensure that the next time the host
controller begins executing from the Asynchronous schedule, it must begin executing
from this queue head. If another start-split (for some other endpoint) is sent to the
transaction translator before the complete-split is really completed, the transaction
translator could dump the results (which were never delivered to the host). This is
why the core specification states the retries must be immediate. A method to
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3733

<!-- page 3734 -->

accomplish this behavior is to not advance the asynchronous schedule. When the host
controller returns to the asynchronous schedule in the next micro-frame, the first
transaction from the schedule is the retry for this endpoint.
If Cerr went to zero, the host controller must halt the queue.
• NAK. The target endpoint Nak'd the full- or low-speed transaction. The state of the
transfer is not advanced and the state is exited. If the PidCode is a SETUP, then the
Nak response is a protocol error. The XactErr status bit is set to one and the CErr
field is decremented.
• STALL. The target endpoint responded with a STALL handshake. The host
controller sets the halt bit in the status byte, retires the qTD but does not attempt to
advance the queue.
If the PidCode indicates an IN, then any of following responses are expected:
• DATA0/1. On reception of data, the host controller ensures the PID matches the
expected data toggle and checks CRC. If the packet is good, the host controller
advances the state of the transfer, for example move the data pointer by the number
of bytes received, decrement BytesToTransfer field by the number of bytes received,
and toggle the dt bit. The host controller then exit this state. The response and
advancement of transfer may trigger other processing events, such as retirement of
the qTD and advancement of the queue.
If the data sequence PID does not match the expected, the data is ignored, the transfer
state is not advanced and this state is exited. If the PidCode indicates an OUT/SETUP,
then any of following responses are expected:
• ACK. The target endpoint accepted the data, so the host controller must advance the
state of the transfer. The Current Offset field is incremented by Maximum Packet
Length or Bytes to Transfer, whichever is less. The field Bytes To Transfer is
decremented by the same amount and the data toggle bit (dt) is toggled. The host
controller then exit this state.
• Advancing the transfer state may cause other processing events such as retirement of
the qTD and advancement of the queue (see Managing Control/Bulk/Interrupt
Transfers through Queue Heads).
56.4.3.12.2
Split Transaction Interrupt
Split-transaction Interrupt-IN/OUT endpoints are managed through the same data
structures used for high-speed interrupt endpoints. They both co-exist in the periodic
schedule.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3734
NXP Semiconductors

<!-- page 3735 -->

Queue heads/qTDs offer the set of features required for reliable data delivery, which is
characteristic to interrupt transfer types. The split-transaction protocol is managed
completely within this defined functional transfer framework. For example, for a high-
speed endpoint, the host controller visits a queue head, execute a high-speed transaction
(if criteria are met) and advance the transfer state (or not) depending on the results of the
entire transaction. For low- and full-speed endpoints, the details of the execution phase
are different (that is takes more than one bus transaction to complete), but the remainder
of the operational framework is intact. This means that the transfer advancement, and so
on, occurs as defined in Managing Control/Bulk/Interrupt Transfers through Queue
Heads, but only occurs on the completion of a split transaction.
56.4.3.12.2.1
Split Transaction Scheduling Mechanisms for Interrupt
Full- and low-speed Interrupt queue heads have an EPS field indicating full- or low-speed
and have a non-zero S-mask field.
The host controller can detect this combination of parameters and assume the endpoint is
a periodic endpoint. Low- and full-speed interrupt queue heads require the use of the split
transaction protocol. The host controller sets the Endpoint Type (ET) field in the split
token to indicate the transaction is an interrupt. These transactions are managed through a
transaction translator's periodic pipeline. Software should not set these fields to indicate
the queue head is an interrupt unless the queue head is used in the periodic schedule.
System software manages the per/transaction translator periodic pipeline by budgeting
and scheduling exactly during which micro-frames the start-splits and complete-splits for
each endpoint occurs. The characteristics of the transaction translator are such that the
high-speed transaction protocol must execute during explicit micro-frames, or the data or
response information in the pipeline is lost.
The following figure illustrates the general scheduling boundary conditions that are
supported by the EHCI periodic schedule and queue head data structure. The S and CX
labels indicate micro-frames where software can schedule start-splits and complete splits
(respectively).
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3735

<!-- page 3736 -->

7
0
1
2
3
4
5
6
7
0
1
S
C0
C1
C2
S
C0
C1
C2
S
C0
C1
C2
S
C0
C1
C2
7
0
1
2
3
4
5
6
7
0
6
Periodic Schedule
Micro-frame
Case 1:
Normal Case
Case 2a:
End of Frame
Case 2b:
End of Frame
Case 2c:
End of Frame
HS/FS/LS
Bus Micro-frame
B-Frame N-1
B-Frame N
B-Frame N+1
H-Frame N
Figure 56-20. Split Transaction, Interrupt Scheduling Boundary Conditions
The scheduling cases are:
• Case 1: The normal scheduling case is where the entire split transaction is completely
bounded by a frame (H-Frame in this case).
• Case 2a through Case 2c: The USB 2.0 Hub pipeline rules states clearly, when and
how many complete-splits must be scheduled to account for earliest to latest
execution on the full/low-speed link. The complete-splits may span the H-Frame
boundary when the start-split is in micro-frame 4 or later. When this occurs, the H-
Frame to B-Frame alignment requires that the queue head be reachable from
consecutive periodic frame list locations. System software cannot build an efficient
schedule that satisfies this requirement unless it uses FSTNs.
The figure below illustrates the general layout of the periodic schedule.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3736
NXP Semiconductors

<!-- page 3737 -->

Level 8
Level 4
Level 2
Level 1
(root)
Periodic
Frame List
Linkage repeats every 8 for
remainder of frame list
87
80
81
82
83
84
85
86
80b
40
41
42
43
20
21
10
Figure 56-21. General Structure of EHCI Periodic Schedule Utilizing Interrupt Spreading
The periodic frame list is effectively the leaf level a binary tree, which is always
traversed leaf to root. Each level in the tree corresponds to a 2N poll rate. Software can
efficiently manage periodic bandwidth on the USB by spreading interrupt queue heads
that have the same poll rate requirement across all the available paths from the frame list.
For example, system software can schedule eight poll rate 8 queue heads and account for
them once in the high-speed bus bandwidth allocation.
When an endpoint is allocated an execution footprint that spans a frame boundary, the
queue head for the endpoint must be reachable from consecutive locations in the frame
list. An example would be if 80b where such an endpoint. Without additional support on
the interface, to get 80b reachable at the correct time, software would have to link 81 to
80b. It would then have to move 41 and everything linked after into the same path as 40.
This upsets the integrity of the binary tree and disallows the use of the spreading
technique.
FSTN data structures are used to preserve the integrity of the binary-tree structure and
enable the use of the spreading technique. Host Controller Operational Model for FSTNs
defines the hardware and software operational model requirements for using FSTNs.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3737

<!-- page 3738 -->

The following queue head fields are initialized by system software to instruct the host
controller when to execute portions of the split-transaction protocol:
• SplitXState. This is single bit residing in the Status field of a queue head (see Table
56-23). This bit is used to track the current state of the split transaction.
• Frame S-mask. This is a bit-field where-in system software sets a bit corresponding
to the micro-frame (within an H-Frame) that the host controller should execute a
start-split transaction. This is always qualified by the value of the SplitXState bit in
the Status field of the queue head. For example, referring to Figure 56-20, case one,
the S-mask would have a value of 00000001b indicating that if the queue head is
traversed by the host controller, and the SplitXState indicates Do_Start, and the
current micro-frame as indicated by FRINDEX[2:0] is 0, then execute a start-split
transaction.
• Frame C-mask. This is a bit-field where system software sets one or more bits
corresponding to the micro-frames (within an H-Frame) that the host controller
should execute complete-split transactions. The interpretation of this field is always
qualified by the value of the SplitXState bit in the Status field of the queue head. For
example, referring to Figure 56-20, case one, the C-mask would have a value of
00011100b indicating that if the queue head is traversed by the host controller, and
the SplitXState indicates Do_Complete, and the current micro-frame as indicated by
FRINDEX[2:0] is 2, 3, or 4, then execute a complete-split transaction. It is software's
responsibility to ensure that the translation between H-Frames and B-Frames is
correctly performed when setting bits in S-mask and C-mask
56.4.3.12.2.2
Host Controller Operational Model for FSTNs
The FSTN data structure is used to manage Low/Full-speed interrupt queue heads that
need to be reached from consecutive frame list locations (that is boundary cases 2a
through 2c).
An FSTN is essentially a back pointer, similar in intent to the back pointer field in the
siTD data structure (see siTD Back Link Pointer).
This feature provides software a simple primitive to save a schedule position, redirect the
host controller to traverse the necessary queue heads in the previous frame, then restore
the original schedule position and complete normal traversal.
The four components to the use of FSTNs:
• FSTN data structure.
• A Save Place indicator. This is always an FSTN with its Back Path Link Pointer.T-
bit set to zero.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3738
NXP Semiconductors

<!-- page 3739 -->

• A Restore indicator. This is always an FSTN with its Back Path Link Pointer.T-bit
set to one.
• Host controller FSTN traversal rules.
When the host controller encounters an FSTN during micro-frames 2 through 7 it simply
follows the node's Normal Path Link Pointer to access the next schedule data structure.
NOTE
The FSTN's Normal Path Link Pointer.T-bit may set to one,
which the host controller must interpret as the end of periodic
list mark.
When the host controller encounters a Save-Place FSTN in micro-frames 0 or 1, it saves
the value of the Normal Path Link Pointer and set an internal flag indicating that it is
executing in Recovery Path mode. Recovery Path mode modifies the host controller's
rules for how it traverses the schedule and limits which data structures is considered for
execution of bus transactions. The host controller continues executing in Recovery Path
mode until it encounters a Restore FSTN or it determines that it has reached the end of
the micro-frame (see details in the list below).
The rules for schedule traversal and limited execution while in Recovery Path mode are:
• Always follow the Normal Path Link Pointer when it encounters an FSTN that is a
Save-Place indicator. The host controller must not recursively follow Save-Place
FSTNs. Therefore, while executing in Recovery Path mode, it must never follow an
FSTN's Back Path Link Pointer.
• Do not process an siTD or, iTD data structure. Simply follow its Next Link Pointer.
• Do not process a QH (Queue Head) whose EPS field indicates a high-speed device.
Simply follow its Horizontal Link Pointer.
• When a QH's EPS field indicates a Full/Low-speed device, the host controller
considers only it for execution if its SplitXState is DoComplete (note: this applies
whether the PID Code indicates an IN or an OUT). See Execute Transaction and
Tracking Split Transaction Progress for Interrupt Transfers for a complete list of
additional conditions that must be met in general for the host controller to issue a bus
transaction.
• The host controller must not execute a Start-split transaction while executing in
Recovery Path mode. See Periodic Isochronous - Do Complete Split for special
handling when in Recovery Path mode.
• Stop traversing the recovery path when it encounters an FSTN that is a Restore
indicator. The host controller unconditionally uses the saved value of the Save-Place
FSTN's Normal Path Link Pointer when returning to the normal path traversal. The
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3739

<!-- page 3740 -->

host controller must clear the context of executing a Recovery Path when it restores
schedule traversal to the Save-Place FSTN's Normal Path Link Pointer.
• If the host controller determines that there is not enough time left in the micro-frame
to complete processing of the periodic schedule, it abandons traversal of the recovery
path, and clears the context of executing a recovery path. The result is that at the start
of the next consecutive micro-frame, the host controller starts traversal at the frame
list.
An example traversal of a periodic schedule that includes FSTNs is illustrated in the
following figure.
Frame Numbers
N + 5
N+ 4
N + 3
Normal Traversal
for Frame N + 1, 
micro-frames 0,1
N + 1
87
86
85
84
83,0
82,0
81
80
82,1
82,2
82,3
83,1
83,2
N-ptr
B-ptr
T-bit=0
Save-N
43
42
41
40
21
20
N-ptr
B-ptrE
10
T-bit=1
Restore-N
Causes 'Restore' to
Normal path
traversal 
Recovery Path Traversal
N - 2
N - 1
N
Normal Travesal
for Frame N
Figure 56-22. Example Host Controller Traversal of Recovery Path via FSTNs
In frame N+1 (micro-frames 0 and 1), when the host controller encounters Save-Path
FSTN (Save-N), it observes that Save-N.Back Path Link Pointer.T-bit is zero (definition
of a Save-Path indicator). The host controller saves the value of Save-N.Normal Path
Link Pointer and follows Save-N.Back Path Link Pointer. At the same time, it sets an
internal flag indicating that it is now in Recovery Path mode (the recovery path is
annotated in the figure above with a large dashed line). The host controller continues
traversing data structures on the recovery path and executing only those bus transactions
as noted above, on the recovery path until it reaches Restore FSTN (Restore-N). Restore-
N.Back Path Link Pointer.T-bit is set to one (definition of a Restore indicator), so the
host controller exits Recovery Path mode by clearing the internal Recovery Path mode
flag and commences (restores) schedule traversal using the saved value of the Save-Place
FSTN's Normal Path Link Pointer (for example Save-N.Normal Path Link Pointer). The
nodes traversed during these micro-frames include: {83.0, 83.1, 83.2, Save-A, 82.2, 82.3, 42,
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3740
NXP Semiconductors

<!-- page 3741 -->

20, Restore-N, 43, 21, Restore-N, 10 …}. The nodes on the recovery-path are in bold. In
frame N (micro-frames 0-7), for this example, the host controller traverses all of the
schedule data structures utilizing the Normal Path Link Pointers in any FSTNs it
encounters. This is because the host controller has not yet encountered a Save-Place
FSTN so it not executing in Recovery Path mode. When it encounters the Restore FSTN,
(Restore-N), during micro-frames 0 and 1, it uses Restore-N.Normal Path Link Pointer to
traverse to the next data structure (that is normal schedule traversal). This is because the
host controller must use a Restore FSTN's Normal Path Link Pointer when not executing
in a Recovery-Path mode. The nodes traversed during frame N include: {82.0, 82.1, 82.2,
82.3, 42, 20, Restore-N, 10 …}.
In frame N+1 (micro-frames 2-7), when the host controller encounters Save-Path FSTN
Save-N, it unconditionally follows Save-N.Normal Path Link Pointer. The nodes
traversed during these micro-frames include: {83.0, 83.1, 83.2, Save-A, 43, 21, Restore-N,
10 …}.
56.4.3.12.2.3
Software Operational Model for FSTNs
Software must create a consistent, coherent schedule for the host controller to traverse.
When using FSTNs, system software must adhere to the following rules:
• Each Save-Place indicator requires a matching Restore indicator.
• The Save-Place indicator is an FSTN with a valid Back Path Link Pointer and T-
bit equal to zero.
• Back Path Link Pointer.Typ field must be set to indicate the referenced data
structure is a queue head. The Restore indicator is an FSTN with its Back
Path Link Pointer.T-bit set to one.
• A Restore FSTN may be matched to one or more Save-Place FSTNs. For
example, if the schedule includes a poll-rate 1 level, then system software only
needs to place a Restore FSTN at the beginning of this list in order to match all
possible Save-Place FSTNs.
• If the schedule does not have elements linked at a poll-rate level of one, and one or
more Save-Place FSTNs are used, then System Software must ensure the Restore
FSTN's Normal Path Link Pointer's T-bit is set to one, as this is used to mark the end
of the periodic list.
• When the schedule does have elements linked at a poll rate level of one, a Restore
FSTN must be the first data structure on the poll rate one list. All traversal paths
from the frame list converge on the poll-rate one list. System software must ensure
that Recovery Path mode is exited before the host controller is allowed to traverse the
poll rate level one list.
• A Save-Place FSTN's Back Path Link Pointer must reference a queue head data
structure. The referenced queue head must be reachable from the previous frame list
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3741

<!-- page 3742 -->

location. In other words, if the Save-Place FSTN is reachable from frame list offset
N, then the FSTN's Back Path Link Pointer must reference a queue head that is
reachable from frame list offset N-1.
Software should make the schedule as efficient as possible. What this means in this
context is that software should have no more than one Save-Place FSTN reachable in any
single frame. Note there is times when two (or more, depending on the implementation)
could exist as full/low-speed footprints change with bandwidth adjustments. This could
occur, for example when a bandwidth re-balance causes system software to move the
Save-Place FSTN from one poll rate level to another. During the transition, software
must preserve the integrity of the previous schedule until the new schedule is in place.
56.4.3.12.2.4
Tracking Split Transaction Progress for Interrupt Transfers
To correctly maintain the data stream, the host controller must be able to detect and
report errors where data is lost.
For interrupt-IN transfers, data is lost when it makes it into the USB 2.0 hub, but the USB
2.0 host system is unable to get it from the USB 2.0 Hub and into the system before it
expires from the transaction translator pipeline.
When a lost data condition is detected, the queue must be halted, thus signaling system
software to recover from the error. A data-loss condition exists whenever a start-split is
issued, accepted and successfully executed by the USB 2.0 Hub, but the complete-splits
get unrecoverable errors on the high-speed link, or the complete-splits do not occur at the
correct times. One reason complete-splits might not occur at the right time would be due
to host-induced system hold-offs that cause the host controller to miss bus transactions
because it cannot get timely access to the schedule in system memory.
The same condition can occur for an interrupt-OUT, but the result is not an endpoint halt
condition, but rather effects only the progress of the transfer. The queue head has the
following fields to track the progress of each split transaction. These fields are used to
keep incremental state about which (and when) portions have been executed.
• C-prog-mask. This is an eight-bit bit-vector where the host controller keeps track of
which complete-splits have been executed. Due to the nature of the Transaction
Translator periodic pipeline, the complete-splits need to be executed in-order. The
host controller needs to detect when the complete-splits have not been executed in
order. This can only occur due to system hold-offs where the host controller cannot
get to the memory-based schedule. C-prog-mask is a simple bit-vector that the host
controller sets one of the C-prog-mask bits for each complete-split executed. The bit
position is determined by the micro-frame number in which the complete-split was
executed. The host controller always checks C-prog-mask before executing a
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3742
NXP Semiconductors

<!-- page 3743 -->

complete-split transaction. If the previous complete-splits have not been executed
then it means one (or more) have been skipped and data has potentially been lost.
• FrameTag. This field is used by the host controller during the complete-split portion
of the split transaction to tag the queue head with the frame number (H-Frame
number) when the next complete split must be executed.
• S-bytes. This field can be used to store the number of data payload bytes sent during
the start-split (if the transaction was an OUT). The S-bytes field must be used to
accumulate the data payload bytes received during the complete-splits (for an IN).
56.4.3.12.2.5
Split Transaction Execution State Machine for Interrupt
In the following presentation, all references to micro-frame are in the context of a micro-
frame within an H-Frame.
As with asynchronous Full- and Low-speed endpoints, a split-transaction state machine is
used to manage the split transaction sequence.
Aside from the fields defined in the queue head for scheduling and tracking the split
transaction, the host controller calculates one internal mechanism that is also used to
manage the split transaction. The internal calculated mechanism is:
• cMicroFrameBit is a single-bit encoding of the current micro-frame number. It is an
eight-bit value calculated by the host controller at the beginning of every micro-
frame. It is calculated from the three least significant bits of the FRINDEX register
(that is, cMicroFrameBit = (1 shifted-left(FRINDEX[2:0])). The cMicroFrameBit has
at most one bit asserted, which always corresponds to the current micro-frame
number. For example, if the current micro-frame is 0, then cMicroFrameBit will
equal 00000001b. The variable cMicroFrameBit is used to compare against the S-
mask and C-mask fields to determine whether the queue head is marked for a start- or
complete-splt transaction for the current micro-frame.
The following figure illustrates the state machine for managing a complete interrupt split
transaction. There are two phases to each split transaction. The first is a single start-split
transaction, which occurs when the SplitXState is at Do_Start and the single bit in
cMicroFrameBit has a corresponding bit active in QH.S-mask. The transaction translator
does not acknowledge the receipt of the periodic start-split, so the host controller
unconditionally transitions the state to Do_Complete. Due to the available jitter in the
transaction translator pipeline, there will be more than one complete-split transaction
scheduled by software for the Do_Complete state. This translates simply to the fact that
there are multiple bits set to a one in the QH.C-mask field.
The host controller keeps the queue head in the Do_Complete state until the split
transaction is complete (see definition below), or an error condition triggers the three-
strikes-rule (for example, after the host tries the same transaction three times, and each
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3743

<!-- page 3744 -->

encounters an error, the host controller will stop retrying the bus transaction and halt the
endpoint, thus requiring system software to detect the condition and perform system-
dependent recovery).
Do Start
Split
Do
Complete
Split
Halt Queue
State
Active
Queue
State
Split Transaction
Complete
MDATA
or NYET
Data Loss
.or.
STALL
.or.
Dabble
.or.
CERR ->
(QH.S-Mask & cMicroFrameBit)
. issue start-split transaction
. tag QH w/frame number according to frame tag rules
. QH.c-prog-mask = zero (00b)
QH.C-Mask & cMicroFrameBit
.and.
(FRINDEX[7:3] .eq. QH.FrameTag)
.and.
CheckPreviousBit(QH.C-prog-mask, QH.C-mask, cMicroFrameBit
. issue complete-split transaction
. tag QH w/frame number according to the
** Sframe tag rules
. QH.c.prog-mask != cMicroFrameBit
XactErr
Decrement Error Counter
(CERR) and Do immediate retry
of complete-split
!(QH.S-Mask & MicroFrameBit)
Figure 56-23. Split Transaction State Machine for Interrupt
See Previous Section for the frame tag management rules.
Periodic Interrupt - Do Start Split
This is the state software must initialize a full- or low-speed interrupt queue head
StartXState bit. This state is entered from the Do_Complete Split state only after the split
transaction is complete. This occurs when one of the following events occur: The
transaction translator responds to a complete-split transaction with one of the following:
• NAK. A NAK response is a propagation of the full- or low-speed endpoint's NAK
response.
• ACK. An ACK response is a propagation of the full- or low-speed endpoint's ACK
response. Only occurs on an OUT endpoint.
• DATA 0/1. Only occurs for INs. Indicates that this is the last of the data from the
endpoint for this split transaction.
• ERR. The transaction on the low-/full-speed link below the transaction translator had
a failure (for example, timeout, bad CRC, etc.).
• NYET (and Last). The host controller issued the last complete-split and the
transaction translator responded with a NYET handshake. This means that the start-
split was not correctly received by the transaction translator, so it never executed a
transaction to the full- or low-speed endpoint, see Section Periodic Isochronous - Do
Complete Split for the definition of 'Last'.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3744
NXP Semiconductors

<!-- page 3745 -->

Each time the host controller visits a queue head in this state (once within the Execute
Transaction state), it performs the following test to determine whether to execute a start-
split.
• QH.S-mask is bit-wise anded with cMicroFrameBit.
If the result is non-zero, then the host controller will issue a start-split transaction. If the
PIDCode field indicates an IN transaction, the host controller must zero-out the QH.S-
bytes field. After the split-transaction has been executed, the host controller sets up state
in the queue head to track the progress of the complete-split phase of the split transaction.
Specifically, it records the expected frame number into QH.FrameTag field (see
Section ), set C-prog-mask to zero (00h), and exits this state. Note that the host controller
must not adjust the value of CErr as a result of completion of a start-split transaction.
Periodic Interrupt - Do Complete Split
This state is entered unconditionally from the Do Start Split state after a start-split
transaction is executed on the bus. Each time the host controller visits a queue head in
this state (once within the Execute Transaction state), it checks to determine whether a
complete-split transaction should be executed now.
There are four tests to determine whether a complete-split transaction should be executed.
• Test A. cMicroFrameBit is bit-wise anded with QH.C-mask field. A non-zero result
indicates that software scheduled a complete-split for this endpoint, during this
micro-frame.
• Test B. QH.FrameTag is compared with the current contents of FRINDEX[7:3]. An
equal indicates a match.
• Test C. The complete-split progress bit vector is checked to determine whether the
previous bit is set, indicating that the previous complete-split was appropriately
executed. An example algorithm for this test is provided below:
Algorithm Boolean CheckPreviousBit(QH.C-prog-mask, QH.C-mask, cMicroFrameBit)
Begin
-- Return values:
-- TRUE - no error
-- FALSE - error
--
Boolean rvalue = TRUE;
previousBit = cMicroframeBit logical-rotate-right(1)
-- Bit-wise anding previousBit with C-mask indicates 
-- whether there was an intent
-- to send a complete split in the previous micro-frame. So, 
-- if the
-- 'previous bit' is set in C-mask, check C-prog-mask to 
-- make sure it
-- happened.
If (previousBit bitAND QH.C-mask)then
                               If not(previousBit bitAND QH.C-prog-mask) then
                    rvalue = FALSE;
          End if
End If
-- If the C-prog-mask already has a one in this bit position, 
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3745

<!-- page 3746 -->

-- then an aliasing
-- error has occurred. It will probably get caught by the 
-- FrameTag Test, but
-- at any rate it is an error condition that as detectable here
-- should not allow
-- a transaction to be executed.
If (cMicroFrameBit bitAND QH.C-prog-mask) then
 rvalue = FALSE;
End if
return (rvalue)
End Algorithm
• Test D. Check to see if a start-split should be executed in this micro-frame. Note this
is the same test performed in the Do Start Split state (see Section Periodic
Isochronous - Do Start Split ). Whenever it evaluates to TRUE and the controller is
NOT processing in the context of a Recovery Path mode, it means a start-split should
occur in this micro-frame. Test D and Test A evaluating to TRUE at the same time is
a system software error. Behavior is undefined.
If (A .and. B .and. C .and. not(D)) then the host controller will execute a complete-split
transaction. When the host controller commits to executing the complete-split transaction,
it updates QH.C-prog-mask by bit-ORing with cMicroFrameBit. On completion of the
complete-split transaction, the host controller records the result of the transaction in the
queue head and sets QH.FrameTag to the expected H-Frame number (see Section ). The
effect to the state of the queue head and thus the state of the transfer depends on the
response by the transaction translator to the complete-split transaction. The following
responses have the effects (note that any responses that result in decrementing of the
CErr will result in the queue head being halted by the host controller if the result of the
decrement is zero):
• NYET (and Last). On each NYET response, the host controller checks to determine
whether this is the last complete-split for this split transaction. Last is defined in this
context as the condition where all of the scheduled complete-splits have been
executed. If it is the last complete-split (with a NYET response), then the transfer
state of the queue head is not advanced (never received any data) and this state
exited. The transaction translator must have responded to all the clompete-splits with
NYETs, meaning that the start-split issued by the host controller was not received.
The start-split should be retried at the next poll period.
• The test for whether this is the Last complete split can be performed by XOR QH.C-
mask with QH.C-prog-mask. If the result is all zeros then all complete-splits have
been executed. When this condition occurs, the XactErr status bit is set to a one and
the CErr field is decremented.
• NYET (and not Last). See above description for testing for Last. The complete-split
transaction received a NYET response from the transaction translator. Do not update
any transfer state (except for C-prog-mask and FrameTag) and stay in this state. The
host controller must not adjust CErr on this response.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3746
NXP Semiconductors

<!-- page 3747 -->

• Transaction Error (XactErr). Timeout, data CRC failure, etc. The CErr field is
decremented and the XactErr bit in the Status field is set to a one. The complete split
transaction is immediately retried (if Cerr is non-zero).If there is not enough time in
the micro-frame to complete the retry and the endpoint is an IN, or CErr is
decremented to a zero from a one, the queue is halted. If there is not enough time in
the micro-frame to complete the retry and the endpoint is an OUT and CErr is not
zero, then this state is exited (that is, return to Do Start Split). This results in a retry
of the entire OUT split transaction, at the next poll period. Refer to Chapter 11 Hubs
(specifically the section full- and low-speed Interrupts) in the USB Specification
Revision 2.0 for detailed requirements on why these errors must be immediately
retried.
• ACK. This can only occur if the target endpoint is an OUT. The target endpoint
ACK'd the data and this response is a propagation of the endpoint ACK up to the
host controller. The host controller must advance the state of the transfer. The
Current Offset field is incremented by Maximum Packet Length or Bytes to Transfer,
whichever is less. The field Bytes To Transfer is decremented by the same amount.
And the data toggle bit (dt) is toggled. The host controller will then exit this state for
this queue head. The host controller must reload CErr with maximum value on this
response. Advancing the transfer state may cause other process events such as
retirement of the qTD and advancement of the queue (see Section Managing Control/
Bulk/Interrupt Transfers through Queue Heads).
• MDATA. This response will only occur for an IN endpoint. The transaction
translator responded with zero or more bytes of data and an MDATA PID. The
incremental number of bytes received is accumulated in QH.S-bytes. The host
controller must not adjust CErr on this response.
• DATA0/1. This response may only occur for an IN endpoint. The number of bytes
received is added to the accumulated byte count in QH.S-bytes. The state of the
transfer is advanced by the result and the host controller will exit this state for this
queue head.
• Advancing the transfer state may cause other processing events such as retirement of
the qTD and advancement of the queue (see Section Managing Control/Bulk/
Interrupt Transfers through Queue Heads).
• If the data sequence PID does not match the expected, the entirety of the data
received in this split transaction is ignored, the transfer state is not advanced and this
state is exited.
• NAK. The target endpoint Nak'd the full- or low-speed transaction. The state of the
transfer is not advanced, and this state is exited. The host controller must reload CErr
with maximum value on this response.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3747

<!-- page 3748 -->

• ERR. There was an error during the full- or low-speed transaction. The ERR status
bit is set to a one, Cerr is decremented, the state of the transfer is not advanced, and
this state is exited.
• STALL. The queue is halted (an exit condition of the Execute Transaction state). The
status field bits: Active bit is set to zero and the Halted bit is set to a one and the qTD
is retired. Responses which are not enumerated in the list or which are received out
of sequence are illegal and may result in undefined host controller behavior. The
other possible combinations of tests A, B, C, and D may indicate that data or
response was lost. The table below lists the possible combinations and the
appropriate action.
Table 56-47. Interrupt IN/OUT Do Complete Split State Execution Criteria
Condition
Action
Description
not(A)
not(D)
Ignore QHD
Neither a start nor complete-split is scheduled for the current micro-
frame.Host controller should continue walking the schedule.
A
not(C)
If PIDCode = IN
Halt QHD
If PIDCode = OUT
Retry start-split
Progress bit check failed. These means a complete-split has been
missed. There is the possibility of lost data. If PIDCode is an IN, then the
Queue head must be halted.
If PIDCode is an OUT, then the transfer state is not advanced and the
state exited (for example, start-split is retried). This is a host-induced
error and does not effect CERR.
In either case, set the Missed Micro-frame bit in the status field to a one.
A
not(B)
C
If PIDCode = IN
Halt QHD
If PIDCode = OUT
Retry start-split
QH.FrameTag test failed. This means that exactly one or more H-Frames
have been skipped. This means complete-splits and have missed. There
is the possibility of lost data. If PIDCode is an IN, then the Queue head
must be halted.
If PIDCode is an OUT, then the transfer state is not advanced and the
state exited (for example, start-split is retried). This is a host-induced
error and does not effect CERR.
In either case, set the Missed Micro-frame bit in the status field to a one.
A
B
C
not(D)
Execute
complete-split
This is the non-error case where the host controller executes a complete-
split transaction.
D
If PIDCode = IN
Halt QHD
If PIDCode = OUT
Retry start-split
This is a degenerate case where the start-split was issued, but all of the
complete-splits were skipped and all possible intervening
opportunities to detect the missed data failed to fire. If PIDCode is an IN,
then the Queue head must be halted.
If PIDCode is an OUT, then the transfer state is not advanced and the
state exited (for example, start-split is retried). This is a host-induced
error and does not effect CERR.
In either case, set the Missed Micro-frame bit in the status field to a one.
Note: When executing in the context of a Recovery Path mode, the host
controller is allowed to process the queue head and take the actions
indicated above, or it may wait until the queue head is visited in the
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3748
NXP Semiconductors

<!-- page 3749 -->

Table 56-47. Interrupt IN/OUT Do Complete Split State Execution Criteria
normal processing mode. Regardless, the host controller must not
execute a start-split in the context of a executing in a Recovery Path
mode.
Managing QH.FrameTag Field
The QH.FrameTag field in a queue head is completely managed by the host controller.
The rules for setting QH.FrameTag are simple:
• Rule 1: If transitioning from Do Start Split to Do Complete Split and the current
value of FRINDEX[2:0] is 6 QH.FrameTag is set to FRINDEX[7:3] + 1. This
accommodates split transactions whose start-split and complete-splits are in different
H-Frames (case 2a, see Figure 56-20).
• Rule 2: If the current value of FRINDEX[2:0] is 7, QH.FrameTag is set to
FRINDEX[7:3] + 1. This accommodates staying in Do Complete Split for cases 2a,
2b, and 2c (Figure 56-20).
• Rule 3: If transitioning from Do_Start Split to Do Complete Split and the current
value of FRINDEX[2:0] is not 6, or currently in Do Complete Split and the current
value of (FRINDEX[2:0]) is not 7, FrameTag is set to FRINDEX[7:3]. This
accommodates all other cases (Figure 56-20).
56.4.3.12.2.6
Rebalancing the periodic schedule
System software must occasionally adjust a periodic queue head's S-mask and C-mask
fields during operation.
This need occurs when adjustments to the periodic schedule create a new bandwidth
budget and one or more queue head's are assigned new execution footprints (that is, new
S-mask and C-mask values).
It is imperative that System software must not update these masks to new values in the
midst of a split transaction. In order to avoid any race conditions with the update, the
EHCI host controller provides a simple assist to system software. System software sets
the Inactivate-on-next-Transaction (I) bit to a one to signal the host controller that it
intends to update the S-mask and C-mask on this queue head. System software will then
wait for the host controller to observe the I-bit is a one and transition the Active bit to a
zero. The rules for how and when the host controller sets the Active bit to zero are
enumerated below:
• If the Active bit is a zero, no action is taken. The host controller does not attempt to
advance the queue when the I-bit is a one.
• If the Active bit is a one and the SplitXState is DoStart (regardless of the value of S-
mask), the host controller will simply set Active bit to a zero. The host controller is
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3749

<!-- page 3750 -->

not required to write the transfer state back to the current qTD. Note that if the S-
mask indicates that a start-split is scheduled for the current micro-frame, the host
controller must not issue the start-split bus transaction. It must set the Active bit to
zero.
System software must save transfer state before setting the I-bit to a one. This is required
so that it can correctly determine what transfer progress (if any) occurred after the I-bit
was set to a one and the host controller executed its final bus-transaction and set Active to
a zero.
After system software has updated the S-mask and C-mask, it must then reactivate the
queue head. Because the Active bit and the I-bit cannot be updated with the same write,
system software needs to use the following algorithm to coherently re-activate a queue
head that has been stopped via the I-bit.
1. Set the Halted bit to a one, then
2. Set the I-bit to a zero, then
3. Set the Active bit to a one and the Halted bit to a zero in the same write.
Setting the Halted bit to a one inhibits the host controller from attempting to advance the
queue between the time the I-bit goes to a zero and the Active bit goes to a one.
56.4.3.12.3
Split Transaction Isochronous
Full-speed isochronous transfers are managed using the split-transaction protocol through
a USB 2.0 transaction translator in a USB2.0 Hub. The EHCI controller utilizes siTD
data structure to support the special requirements of isochronous split-transactions.
This data structure uses the scheduling model of isochronous TDs (iTD, Section
Isochronous (High-Speed) Transfer Descriptor (iTD)) (see Section Managing
Isochronous Transfers Using iTDs for the operational model of iTDs) with the contiguous
data feature provided by queue heads. This simple arrangement allows a single
isochronous scheduling model and adds the additional feature that all data received from
the endpoint (per split transaction) must land into a contiguous buffer.
56.4.3.12.3.1
Split Transaction Scheduling Mechanisms for Isochronous
Full-speed isochronous transactions are managed through a transaction translator's
periodic pipeline. As with full- and low-speed interrupt, system software manages each
transaction translator's periodic pipeline by budgeting and scheduling exactly during
which micro-frames the start-splits and complete-splits for each full-speed isochronous
endpoint occur.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3750
NXP Semiconductors

<!-- page 3751 -->

The requirements described in Section Split Transaction Scheduling Mechanisms for
Interrupt apply. The following figure illustrates the general scheduling boundary
conditions that are supported by the EHCI periodic schedule. The SX and CX labels
indicate micro-frames where software can schedule start- and complete-splits
(respectively). The H-Frame boundaries are marked with a large, solid bold vertical line.
The B-Frame boundaries are marked with a large, bold, dashed line. The bottom of the
figure illustrates the relationship of an siTD to the H-Frame.
7
0
1
2
3
4
5
6
7
0
1
S
C0
C1
C2
C3
S0
S1
S2
S3
S
C0
C1
C2
C3
S0
S1
S2
S3
C0
C1
C2
C3
C4
C5
C6
S
7
0
1
2
3
4
5
6
7
0
C6
S
B-Frame N
B-Frame N-1
B-Frame N+1
H-Frame N
H-Frame N+1
siTDx
siTDx + 1
6
Periodic Schedule
Micro-frame
Case 1:
Normal Case
Case 2b:
Start and Complete
in H-Frame,
micro-frame  0
 
HS/FS/LS Bus
Micro-frame
B-Frame
Case 2a:
Frame Wrap @
End of H-Frame
IN
OUT
Figure 56-24. Split Transaction, Isochronous Scheduling Boundary Conditions
When the endpoint is an isochronous OUT, there are only start-splits, and no complete-
splits. When the endpoint is an isochronous IN, there is at most one start-split and one to
N complete-splits. The scheduling boundary cases are:
• Case 1: The entire split transaction is completely bounded by an H-Frame. For
example: the start-splits and complete-splits are all scheduled to occur in the same H-
Frame.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3751

<!-- page 3752 -->

• Case 2a: This boundary case is where one or more (at most two) complete-splits of a
split transaction IN are scheduled across an H-Frame boundary. This can only occur
when the split transaction has the possibility of moving data in B-Frame, micro-
frames 6 or 7 (H-Frame micro-frame 7 or 0). When an H-Frame boundary wrap
condition occurs, the scheduling of the split transaction spans more than one location
in the periodic list.(For example, it takes two siTDs in adjacent periodic frame list
locations to fully describe the scheduling for the split transaction.)
• Although the scheduling of the split transaction may take two data structures, all of
the complete-splits for each full-speed IN isochronous transaction must use only one
data pointer. For this reason, siTDs contain a back pointer, the use of which is
described below.
• Software must never schedule full-speed isochronous OUTs across an H-Frame
boundary.
• Case 2b: This case can only occur for a very large isochronous IN. It is the only
allowed scenario where a start-split and complete-split for the same endpoint can
occur in the same micro-frame. Software must enforce this rule by scheduling the
large transaction first. Large is defined to be anything larger than 579 byte maximum
packet size.
A subset of the same mechanisms employed by full- and low-speed interrupt queue heads
are employed in siTDs to schedule and track the portions of isochronous split
transactions. The following fields are initialized by system software to instruct the host
controller when to execute portions of the split transaction protocol.
• SplitXState. This is a single bit residing in the Status field of an siTD (see Figure
56-25). This bit is used to track the current state of the split transaction. The rules for
managing this bit are described in Section Split Transaction Execution State Machine
for Interrupt.
• Frame S-mask. This is a bit-field where-in system software sets a bit corresponding
to the micro-frame (within an H-Frame) that the host controller should execute a
start-split transaction. This is always qualified by the value of the SplitXState bit. For
example, referring to the IN example in Figure 56-24, case one, the S-mask would
have a value of 00000001b indicating that if the siTD is traversed by the host
controller, and the SplitXState indicates Do Start Split, and the current micro-frame
as indicated by USB_n_FRINDEX[2:0] is 0, then execute a start-split transaction.
• Frame C-mask. This is a bit-field where system software sets one or more bits
corresponding to the micro-frames (within an H-Frame) that the host controller
should execute complete-split transactions. The interpretation of this field is always
qualified by the value of the SplitXState bit. For example, referring to the IN example
in Figure 56-24, case one, the C-mask would have a value of 00111100b indicating
that if the siTD is traversed by the host controller, and the SplitXState indicates Do
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3752
NXP Semiconductors

<!-- page 3753 -->

Complete Split, and the current micro-frame as indicated by USB_n_FRINDEX[2:0]
is 2, 3, 4, or 5, then execute a complete-split transaction.
• Back Pointer. This field in a siTD is used to complete an IN split-transaction using
the previous H-Frame's siTD. This is only used when the scheduling of the
complete-splits span an H-Frame boundary.
There exists a one-to-one relationship between a high-speed isochronous split transaction
(including all start- and complete-splits) and one full-speed isochronous transaction. An
siTD contains (amongst other things) buffer state and split transaction scheduling
information. An siTD's buffer state always maps to one full-speed isochronous data
payload. This means that for any full-speed transaction payload, a single siTD's data
buffer must be used. This rule applies to both IN an OUTs. An siTD's scheduling
information usually also maps to one high-speed isochronous split transaction. The
exception to this rule is the H-Frame boundary wrap cases mentioned above.
The siTD data structure describes at most, one frame's worth of high-speed transactions
and that description is strictly bounded within a frame boundary. The figure below
illustrates some examples. On the top are examples of the full-speed transaction
footprints for the boundary scheduling cases described above. In the middle are time-
frame references for both the B-Frames (HS/FS/LS Bus) and the H-Frames. On the
bottom is illustrated the relationship between the scope of an siTD description and the
time references. Each H-Frame corresponds to a single location in the periodic frame list.
The implication is that each siTD is reachable from a single periodic frame list location at
a time.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3753

<!-- page 3754 -->

0
1
2
3
4
5
6
7
0
1
2
3
4
5
6
7
0
1
2
3
4
5
6
7
0
1
2
3
4
5
6
7
0
1
2
3
0
1
2
3
4
5
6
7
4
5
6
7
B-Frame r
B-Frame r+1
B-Frame r+2
B-Frame r-1
H-Frame r
H-Frame r+1
H-Frame r+2
H-Frame r-1
Case 1
Case 2a
Case 2b
Full-Speed
Transaction
siTDx+1
siTDx
Back Pointer
Figure 56-25. siTD Scheduling Boundary Examples
Each case is described below:
• Case 1: One siTD is sufficient to describe and complete the isochronous split
transaction because the whole isochronous split transaction is tightly contained
within a single H-Frame.
• Case 2a, 2b: Although both INs and OUTs can have these footprints, OUTs always
take only one siTD to schedule. However, INs (for these boundary cases) require two
siTDs to complete the scheduling of the isochronous split transaction siTDX is used
to always issue the start-split and the first N complete-splits. The full-speed
transaction (for these cases) can deliver data on the full-speed bus segment during
micro-frame 7 of H-FrameY+1, or micro-frame 0 of H-FrameY+2. The complete splits
are scheduled using siTDX+2 (not shown). The complete-splits to extract this data
must use the buffer pointer from siTDX+1. The only way for the host controller to
reach siTDX+1 from H-FrameY+2is to use siTDX+2's back pointer. The host controller
rules for when to use the back pointer are described is Section Periodic Isochronous -
Do Complete Split .
Software must apply the following rules when calculating the schedule and linking the
schedule data structures into the periodic schedule:
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3754
NXP Semiconductors

<!-- page 3755 -->

• Software must ensure that an isochronous split-transaction is started so that it will
complete before the end of the B-Frame.
• Software must ensure that for a single full-speed isochronous endpoint, there is never
a start-split and complete-split in H-Frame, micro-frame 1. This is mandated as a
rule so that case 2a and case 2b can be discriminated. According to the core USB
specification, the long isochronous transaction illustrated in Case 2b, could be
scheduled so that the start-split was in micro-frame 1 of H-Frame N and the last
complete-split would need to occur in micro-frame 1 of H-Frame N+1. However, it is
impossible to discriminate between cases 2a and case 2b, which has significant
impact on the complexity of the host controller.
56.4.3.12.3.2
Tracking Split Transaction Progress for Isochronous Transfers
To correctly maintain the data stream, the host controller must be able to detect and
report errors where device to host data is lost. Isochronous endpoints do not employ the
concept of a halt on error, however the host is required to identify and report per-packet
errors observed in the data stream. This includes schedule traversal problems (skipped
micro-frames), timeouts and corrupted data received.
In similar kind to interrupt split-transactions, the portions of the split transaction protocol
must execute in the micro-frames they are scheduled. The queue head data structure used
to manage full- and low-speed interrupt has several mechanisms for tracking when
portions of a transaction have occurred. Isochronous transfers use siTDs, for their
transfers, and the data structures are only reachable via the schedule in the exact micro-
frame in which they are required (so all the mechanism employed for tracking in queue
heads is not required for siTDs). Software has the option of reusing siTD several times in
the complete periodic schedule. However, it must ensure that the results of split
transaction N are consumed and the siTD reinitialized (activated) before the host
controller gets back to the siTD (in a future micro-frame).
Split-transaction isochronous OUTs utilize a low-level protocol to indicate which
portions of the split transaction data have arrived. Control over the low-level protocol is
exposed in an siTD via the fields Transaction Position (TP) and Transaction Count (T-
count). If the entire data payload for the OUT split transaction is larger than 188 bytes,
there will be more than one start-split transaction, each of which require proper
annotation. If host hold-offs occur, then the sequence of annotations received from the
host will not be complete, which is detected and handled by the transaction translator. See
Section Periodic Isochronous - Do Start Split for a description on how these fields are
used during a sequence of start-split transactions.
The fields siTD.T-Count and siTD.TP are used by the host controller to drive and
sequence the transaction position annotations. It is the responsibility of system software
to properly initialize these fields in each siTD. Once the budget for a split-transaction
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3755

<!-- page 3756 -->

isochronous endpoint is established, S-mask, T-Count, and TP initialization values for all
the siTD associated with the endpoint are constant. They remain constant until the budget
for the endpoint is recalculated by software and the periodic schedule adjusted.
For IN-endpoints, the transaction translator simply annotates the response data packets
with enough information to allow the host controller to identify the last data. As with split
transaction Interrupt, it is the host controller's responsibility to detect when it has missed
an opportunity to execute a complete-split. The following field in the siTD is used to
track and detect errors in the execution of a split transaction for an IN isochronous
endpoint.
• C-prog-mask. This is an eight-bit bit-vector where the host controller keeps track of
which complete-splits have been executed. Due to the nature of the Transaction
Translator periodic pipeline, the complete-splits need to be executed in-order. The
host controller needs to detect when the complete-splits have not been executed in
order. This can only occur due to system hold-offs where the host controller cannot
get to the memory-based schedule. C-prog-mask is a simple bit-vector that the host
controller sets a bit for each complete-split executed. The bit position is determined
by the micro-frame (USB_n_FRINDEX[2:0]) number in which the complete-split
was executed. The host controller always checks C-prog-mask before executing a
complete-split transaction. If the previous complete-splits have not been executed,
then it means one (or more) have been skipped and data has potentially been lost.
System software is required to initialize this field to zero before setting an siTD's
Active bit to a one.
If a transaction translator returns with the final data before all of the complete-splits have
been executed, the state of the transfer is advanced so that the remaining complete-splits
are not executed. Refer to Section Asynchronous - Do Complete Split for a description on
how the state of the transfer is advanced. It is important to note that an IN siTD is retired
based solely on the responses from the Transaction Translator to the complete-split
transactions. This means, for example, that it is possible for a transaction translator to
respond to a complete-split with an MDATA PID. The number of bytes in the MDATA's
data payload could cause the siTD field Total Bytes to Transfer to decrement to zero.
This response can occur, before all of the scheduled complete-splits have been executed.
In other interface, data structures (for example, high-speed data streams through queue
heads), the transition of Total Bytes to Transfer to zero signals the end of the transfer and
results in setting of the Active bit to zero. However, in this case, the result has not been
delivered by the Transaction Translator and the host must continue with the next
complete-split transaction to extract the residual transaction state. This scenario occurs
because of the pipeline rules for a Transaction Translator (see Chapter 11 of the
Universal Serial Bus Revision 2.0). In summary the periodic pipeline rules require that on
a micro-frame boundary, the Transaction Translator will hold the final two bytes received
(if it has not seen an End Of Packet (EOP)) in the full-speed bus pipe stage and give the
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3756
NXP Semiconductors

<!-- page 3757 -->

remaining bytes to the high-speed pipeline stage. At the micro-frame boundary, the
Transaction Translator could have received the entire packet (including both CRC bytes)
but not received the packet EOP. In the next micro-frame, the Transaction Translator will
respond with an MDATA and send all of the data bytes (with the two CRC bytes being
held in the full-speed pipeline stage). This could cause the siTD to decrement its Total
Bytes to Transfer field to zero, indicating it has received all expected data. The host must
still execute one more (scheduled) complete-split transaction in order to extract the
results of the full-speed transaction from the Transaction Translator (for example, the
Transaction Translator may have detected a CRC failure, and this result must be
forwarded to the host).
If the host experiences hold-offs that cause the host controller to skip one or more (but
not all) scheduled split transactions for an isochronous OUT, then the protocol to the
transaction translator will not be consistent and the transaction translator will detect and
react to the problem. Likewise, for host hold-offs that cause the host controller to skip
one or more (but not all) scheduled split transactions for an isochronous IN, the C-prog-
mask is used by the host controller to detect errors. However, if the host experiences a
hold-off that causes it to skip all of an siTD, or an siTD expires during a host hold off (for
example, a hold-off occurs and the siTD is no longer reachable by the host controller in
order for it to report the hold-off event), then system software must detect that the siTDs
have not been processed by the host controller (that is, state not advanced) and report the
appropriate error to the client driver.
56.4.3.12.3.3
Split Transaction Execution State Machine for Isochronous
In the following presentation, all references to micro-frame are in the context of a micro-
frame within an H-Frame.
If the Active bit in the Status byte is a zero, the host controller will ignore the siTD and
continue traversing the periodic schedule. Otherwise the host controller will process the
siTD as specified below. A split transaction state machine is used to manage the split-
transaction protocol sequence. The host controller uses the fields defined in Section
Tracking Split Transaction Progress for Interrupt Transfers , plus the variable
cMicroFrameBit defined in Section Split Transaction Execution State Machine for
Interrupt to track the progress of an isochronous split transaction. The figure below
illustrates the state machine for managing an siTD through an isochronous split
transaction. Bold, dotted circles denote the state of the Active bit in the Status field of a
siTD. The Bold, dotted arcs denote the transitions between these states. Solid circles
denote the states of the split transaction state machine and the solid arcs denote the
transitions between these states. Dotted arcs and boxes reference actions that take place
either as a result of a transition or from being in a state.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3757

<!-- page 3758 -->

Do Start
Split
Do
Complete
Split
Active
case 2(a,b)
siTD x-1 complete
issue complete-split
transaction
issue start-split transaction
siTD.S-mask & cMicroFrameBit
.and. direction .eq. IN
siTD.C-mask & cMicroFrameBit
.and. checkpreviousBit(C-prog-mask, C-mask, cMicroFrameBit)
NYET
.and.
Not Last
Advance data
buffer state
MDATA
IN Split
Transaction
Complete
Not Active
Active = 0b
Active = 1b
siTD.S-mask & cMicroFrameBit
.and. direction .eq. OUT
Active = 0b
Figure 56-26. Split Transaction State Machine for Isochronous
56.4.3.12.3.4
Periodic Isochronous - Do Start Split
Isochronous split transaction OUTs use only this state.
An siTD for a split-transaction isochronous IN is either initialized to this state, or the
siTD transitions to this state from Do Complete Split when a case 2a (IN) or 2b
scheduling boundary isochronous split-transaction completes.
Each time the host controller reaches an active siTD in this state, it checks the siTD.S-
mask against cMicroFrameBit. If there is a one in the appropriate position, the siTD will
execute a start-split transaction. By definition, the host controller cannot reach an siTD at
the wrong time. If the I/O field indicates an IN, then the start-split transaction includes
only the extended token plus the full-speed token. Software must initialize the siTD.Total
Bytes To Transfer field to the number of bytes expected. This is usually the maximum
packet size for the full-speed endpoint. The host controller exits this state when the start-
split transaction is complete.
The remainder of this section is specific to an isochronous OUT endpoint (that is, the I/O
field indicates an OUT). When the host controller executes a start-split transaction for an
isochronous OUT it includes a data payload in the start-split transaction. The memory
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3758
NXP Semiconductors

<!-- page 3759 -->

buffer address for the data payload is constructed by concatenating siTD.Current Offset
with the page pointer indicated by the page selector field (siTD.P). A zero in this field
selects Page 0 and a 1 selects Page 1. During the start-split for an OUT, if the data
transfer crosses a page boundary during the transaction, the host controller must detect
the page cross, update the siTD.P-bit from a zero to a one, and begin using the siTD.Page
1 with siTD.Current Offset as the memory address pointer. The field siTD.TP is used to
annotate each start-split transaction with the indication of which part of the split-
transaction data the current payload represents (ALL, BEGIN, MID, END). In all cases
the host controller simply uses the value in siTD.TP to mark the start-split with the
correct transaction position code.
T-Count is always initialized to the number of start-splits for the current frame. TP is
always initialized to the first required transaction position identifier. The scheduling
boundary case (see Figure 56-25) is used to determine the initial value of TP. The initial
cases are summarized in the following table.
Table 56-48. Initial Conditions for OUT siTD's TP and T-count Fields
Case
T-count
TP
Description
1, 2a
=1
ALL
When the OUT data payload is less than (or equal to) 188 bytes, only one start-
split is required to move the data. The one start-split must be marked with an
ALL.
1, 2a
!=1
BEGIN
When the OUT data payload is greater than 188 bytes more than one start-split
must be used to move the data. The initial start-split must be marked with a
BEGIN.
After each start-split transaction is complete, the host controller updates T-Count and TP
appropriately so that the next start-split is correctly annotated.
The table below illustrates all of the TP and T-count transitions, which must be
accomplished by the host controller.
.
Table 56-49. Transaction Position (TP)/Transaction Count (T-Count) Transition Table
TP
T-count next
TP next
Description
ALL
0
N/A
Transition from ALL, to done.
BEGIN
1
END
Transition from BEGIN to END. Occurs when T-count starts at 2.
BEGIN
!=1
MID
Transition from BEGIN to MID. Occurs when T-count starts at greater than 2.
MID
!=1
MID
TP stays at MID while T-count is not equal to 1 (that is, greater than 1). This case
can occur for any of the scheduling boundary cases where the T-count starts
greater than 3.
MID
1
END
Transition from MID to END. This case can occur for any of the scheduling
boundary cases where the T-count starts greater than 2.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3759

<!-- page 3760 -->

The start-split transactions do not receive a handshake from the transaction translator, so
the host controller always advances the transfer state in the siTD after the bus transaction
is complete. To advance the transfer state the following operations take place:
• The siTD.Total Bytes To Transfer and the siTD.Current Offset fields are adjusted to
reflect the number of bytes transferred.
• The siTD.P (page selector) bit is updated appropriately.
• The siTD.TP and siTD.T-count fields are updated appropriately as defined in Table
56-49.
These fields are then written back to the memory based siTD. The S-mask is fixed for the
life of the current budget. As mentioned above, TP and T-count are set specifically in
each siTD to reflect the data to be sent from this siTD. Therefore, regardless of the value
of S-mask, the actual number of start-split transactions depends on T-count (or
equivalently, Total Bytes to Transfer). The host controller must set the Active bit to a zero
when it detects that all of the schedule data has been sent to the bus. The preferred
method is to detect when T-Count decrements to zero as a result of a start-split bus
transaction. Equivalently, the host controller can detect when Total Bytes to Transfer
decrements to zero. Either implementation must ensure that if the initial condition is
Total Bytes to Transfer equal to zero and T-count is equal to a one, then the host
controller will issue a single start-split, with a zero-length data payload. Software must
ensure that TP, T-count and Total Bytes to Transfer are set to deliver the appropriate
number of bus transactions from each siTD. An inconsistent combination will yield
undefined behavior.
If the host experiences hold-offs that cause the host controller to skip start-split
transactions for an OUT transfer, the state of the transfer will not progress appropriately.
The transaction translator will observe protocol violations in the arrival of the start-splits
for the OUT endpoint (that is, the transaction position annotation will be incorrect as
received by the transaction translator).
Example scenarios are described in Section Split Transaction for Isochronous -
Processing Examples.
A host controller implementation can optionally track the progress of an OUT split
transaction by setting appropriate bits in the siTD.C-prog-mask as it executes each
scheduled start-split. The checkPreviousBit() algorithm defined in Periodic Isochronous -
Do Complete Split can be used prior to executing each start-split to determine whether
start-splits were skipped. The host controller can use this mechanism to detect missed
micro-frames. It can then set the siTD's Active bit to zero and stop execution of this siTD.
This saves on both memory and high-speed bus bandwidth.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3760
NXP Semiconductors

<!-- page 3761 -->

56.4.3.12.3.5
Periodic Isochronous - Do Complete Split
This state is only used by a split-transaction isochronous IN endpoint.
This state is entered unconditionally from the Do Start State after a start-split transaction
is executed for an IN endpoint. Each time the host controller visits an siTD in this state, it
conducts a number of tests to determine whether it should execute a complete-split
transaction. The individual tests are listed below. The sequence they are applied depends
on which micro-frame the host controller is currently executing which means that the
tests might not be applied until after the siTD referenced from the back pointer has been
fetched.
• Test A. cMicroFrameBit is bit-wise anded with siTD.C-mask field. A non-zero result
indicates that software scheduled a complete-split for this endpoint, during this
micro-frame. This test is always applied to a newly fetched siTD that is in this state.
• Test B. The siTD.C-prog-mask bit vector is checked to determine whether the
previous complete splits have been executed. An example algorithm is below (this is
slightly different than the algorithm used in Section Periodic Isochronous - Do
Complete Split ). The sequence in which this test is applied depends on the current
value of USB_n_FRINDEX[2:0]. If USB_n_FRINDEX[2:0] is 0 or 1, it is not
applied until the back pointer has been used. Otherwise it is applied immediately.
Algorithm Boolean CheckPreviousBit(siTD.C-prog-mask, siTD.C-mask, cMicroFrameBit)
Begin
          Boolean rvalue = TRUE;
          previousBit = cMicroFrameBit rotate-right(1)
          -- Bit-wise anding previousBit with C-mask indicates whether there was an intent
          -- to send a complete split in the previous micro-frame. So, if the
          -- 'previous bit' is set in C-mask, check C-prog-mask to make sure it
          -- happened.
          if previousBit bitAND siTD.C-mask then
                    if not (previousBit bitAND siTD.C-prog-mask) then
                               rvalue = FALSE
                    End if
          End if
          Return rvalue
End Algorithm
If Test A is true and USB_n_FRINDEX[2:0] is zero or one, then this is a case 2a or 2b
scheduling boundary (see Figure 56-24). See Section Periodic Isochronous - Do
Complete Split for details in handling this condition.
If Test A and Test B evaluate to true, then the host controller will execute a complete-
split transaction using the transfer state of the current siTD. When the host controller
commits to executing the complete-split transaction, it updates QH.C-prog-mask by bit-
ORing with cMicroFrameBit. The transfer state is advanced based on the completion
status of the complete-split transaction. To advance the transfer state of an IN siTD, the
host controller must:
• Decrement the number of bytes received from siTD.Total Bytes To Transfer,
• Adjust siTD.Current Offset by the number of bytes received,
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3761

<!-- page 3762 -->

• Adjust siTD.P (page selector) field if the transfer caused the host controller to use the
next page pointer, and
• Set any appropriate bits in the siTD.Status field, depending on the results of the
transaction.
Note that if the host controller encounters a condition where siTD.Total Bytes To
Transfer is zero, and it receives more data, the host controller must not write the
additional data to memory. The siTD.Status.Active bit must be set to zero and the
siTD.Status.Babble Detected bit must be set to a one. The fields siTD.Total Bytes To
Transfer, siTD.Current Offset, and siTD.P (page selector) are not required to be updated
as a result of this transaction attempt.
The host controller must accept (assuming good data packet CRC and sufficient room in
the buffer as indicated by the value of siTD.Total Bytes To Transfer) MDATA and
DATA0/1 data payloads up to and including 192 bytes. A host controller implementation
may optionally set siTD.Status Active to a zero and siTD.Status.Babble Detected to a one
when it receives and MDATA or DATA0/1 with a data payload of more than 192 bytes.
The following responses have the noted effects:
• ERR. The full-speed transaction completed with a time-out or bad CRC and this is a
reflection of that error to the host. The host controller sets the ERR bit in the
siTD.Status field and sets the Active bit to a zero.
• Transaction Error (XactErr). The complete-split transaction encounters a Timeout,
CRC16 failure, etc. The siTD.Status field XactErr field is set to a one and the
complete-split transaction must be retried immediately. The host controller must use
an internal error counter to count the number of retries as a counter field is not
provided in the siTD data structure. The host controller will not retry more than two
times. If the host controller exhausts the retries or the end of the micro-frame occurs,
the Active bit is set to zero.
• DATAx (0 or 1). This response signals that the final data for the split transaction has
arrived. The transfer state of the siTD is advanced and the Active bit is set to a zero.
If the Bytes To Transfer field has not decremented to zero (including the reception of
the data payload in the DATAx response), then less data than was expected, or
allowed for was actually received. This short packet event does not set the USBINT
status bit in the USBSTS register to a one. The host controller will not detect this
condition.
• NYET (and Last). On each NYET response, the host controller also checks to
determine whether this is the last complete-split for this split transaction. Last was
defined in Section Periodic Isochronous - Do Complete Split . If it is the last
complete-split (with a NYET response), then the transfer state of the siTD is not
advanced (never received any data) and the Active bit is set to a zero. No bits are set
in the Status field because this is essentially a skipped transaction. The transaction
translator must have responded to all the scheduled clompete-splits with NYETs,
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3762
NXP Semiconductors

<!-- page 3763 -->

meaning that the start-split issued by the host controller was not received. This result
should be interpreted by system software as if the transaction was completely
skipped. The test for whether this is the last complete split can be performed by
XORing C-mask with C-prog-mask. A zero result indicates that all complete-splits
have been executed.
• MDATA (and Last). See above description for testing for Last. This can only occur
when there is an error condition. Either there has been a babble condition on the full-
speed link, which delayed the completion of the full-speed transaction, or software
set up the S-mask and/or C-masks incorrectly. The host controller must set XactErr
bit to a one and the Active bit is set to a zero.
• NYET (and not Last). See above description for testing for Last. The complete-split
transaction received a NYET response from the transaction translator. Do not update
any transfer state (except for C-prog-mask) and stay in this state.
• MDATA (and not Last). The transaction translator responds with an MDATA when
it has partial data for the split transaction. For example, the full-speed transaction
data payload spans from micro-frame X to X+1 and during micro-frame X, the
transaction translator will respond with an MDATA and the data accumulated up to
the end of micro-frame X. The host controller advances the transfer state to reflect
the number of bytes received.
If Test A succeeds, but Test B fails, it means that one or more of the complete-splits have
been skipped. The host controller sets the Missed Micro-Frame status bit and sets the
Active bit to a zero.
56.4.3.12.3.6
Complete-Split for Scheduling Boundary Cases 2a, 2b
Boundary cases 2a and 2b (INs only) (see Figure 56-24) require that the host controller
use the transaction state context of the previous siTD to finish the split transaction. The
table below enumerates the transaction state fields.
Table 56-50. Summary siTD Split Transaction State
Buffer State
Status
Execution Progress
Total Bytes To Transfer
P (page select)
Current Offset
TP (transaction position)
T-count (transaction count)
All bits in the status field
C-prog-mask
NOTE
TP and T-count are used only for Host to Device (OUT)
endpoints.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3763

<!-- page 3764 -->

If software has budgeted the schedule of this data stream with a frame wrap case, then it
must initialize the siTD.Back Pointer field to reference a valid siTD and will have the
siTD.Back Pointer.T-bit in the siTD.Back Pointer
field set to a zero. Otherwise, software must set the siTD.Back Pointer.T-bit in the
siTD.Back Pointer field to a one. The host controller's rules for interpreting when to use
the siTD.Back Pointer field are listed below. These rules apply only when the siTD's
Active bit is a one and the SplitXState is Do Complete Split.
• When cMicroFrameBit is a 1h and the siTDX.Back Pointer.T-bit is a zero, or
• If cMicroFrameBit is a 2h and siTDX.S-mask[0] is a zero
When either of these conditions apply, then the host controller must use the transaction
state from siTDX-1.
In order to access siTDX-1, the host controller reads on-chip the siTD referenced from
siTDX.Back Pointer.
The host controller must save the entire state from siTDX while processing siTDX-1. This
is to accommodate for case 2b processing. The host controller must not recursively walk
the list of siTD.Back Pointers.
If siTDX-1 is active (Active bit is a one and SplitXStat is Do Complete Split), then both
Test A and Test B are applied as described above. If these criteria to execute a complete-
split are met, the host controller executes the complete split and evaluates the results as
described above. The transaction state (see Table 56-50) of siTDX-1 is appropriately
advanced based on the results and written back to memory. If the resultant state of
siTDX-1's Active bit is a one, then the host controller returns to the context of siTDX, and
follows its next pointer to the next schedule item. No updates to siTDX are necessary.
If siTDX-1 is active (Active bit is a one and SplitXStat is Do Start Split), then the host
controller must set Active bit to a zero and Missed Micro-Frame status bit to a one and
the resultant status written back to memory.
If siTDX-1'sActive bit is a zero, (because it was zero when the host controller first visited
siTDX-1 via siTDX's back pointer, it transitioned to zero as a result of a detected error, or
the results of siTDX-1's complete-split transaction transitioned it to zero), then the host
controller returns to the context of siTDX and transitions its SplitXState to Do Start Split.
The host controller then determines whether the case 2b start split boundary condition
exists (that is, if cMicroframeBit is a 1b and siTDX.S-mask[0] is a 1b). If this criterion is
met the host controller immediately executes a start-split transaction and appropriately
advances the transaction state of siTDX, then follows siTDX.Next Pointer to the next
schedule item. If the criterion is not met, the host controller simply follows siTDX.Next
Pointer to the next schedule item. Note that in the case of a 2b boundary case, the split-
transaction of siTDX-1 will have its Active bit set to zero when the host controller returns
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3764
NXP Semiconductors

<!-- page 3765 -->

to the context of siTDX. Also, note that software should not initialize an siTD with C-
mask bits 0 and 1 set to a one and an S-mask with bit zero set to a one. This scheduling
combination is not supported and the behavior of the host controller is undefined.
56.4.3.12.3.7
Split Transaction for Isochronous - Processing Examples
There is an important difference between how the hardware/software manages the
isochronous split transaction state machine and how it manages the asynchronous and
interrupt split transaction state machines.
The asynchronous and interrupt split transaction state machines are encapsulated within a
single queue head. The progress of the data stream depends on the progress of each split
transaction. In some respects, the split-transaction state machine is sequenced via the
Execute Transaction queue head traversal state machine (see Figure 56-17).
Isochronous is a pure time-oriented transaction/data stream. The interface data structures
are optimized to efficiently describe transactions that need to occur at specific times. The
isochronous split-transaction state machine must be managed across these time-oriented
data structures. This means that system software must correctly describe the scheduling
of split-transactions across more than one data structure.
Then the host controller must make the appropriate state transitions at the appropriate
times, in the correct data structures.
For example, the table below illustrates a couple of frames worth of scheduling required
to schedule a case 2a full-speed isochronous data stream.
Table 56-51. Example Case 2a - Software Scheduling siTDs for an IN Endpoint
siTDX
Micro-Frames
Initial
SplitXState
#
Masks
0
1
2
3
4
5
6
7
X
S-Mask
-
-
-
-
1
-
-
-
Do Start Split
C-Mask
1
1
-
-
-
-
1
1
X+1
S-Mask
-
-
-
-
1
-
-
-
Do Complete Split
C-Mask
1
1
1
1
X+2
S-Mask
-
-
-
-
1
-
-
-
Do Complete Split
C-Mask
1
1
1
1
X+3
S-Mask
Repeats previous pattern
Do Complete Split
C-Mask
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3765

<!-- page 3766 -->

This example shows the first three siTDs for the transaction stream. Because this is the
case-2a frame-wrap case, S-masks of all siTDs for this endpoint have a value of 10h (a
one bit in micro-frame 4) and C-mask value of C3h (one-bits in micro-frames 0,1, 6 and
7). Additionally, sofware ensures that the Back Pointer field of each siTD references the
appropriate siTD data structure (and the Back PointerT-bits are set to zero).
The initial SplitXState of the first siTD is Do Start Split. The host controller will visit the
first siTD eight times during frame X. The C-mask bits in micro-frames 0 and 1 are
ignored because the state is Do Start Split. During micro-frame 4, the host controller
determines that it can run a start-split (and does) and changes SplitXState to Do Complete
Split. During micro-frames 6 and 7, the host controller executes complete-splits. Notice
the siTD for frame X+1 has its SplitXState initialized to Do Complete Split. As the host
controller continues to traverse the schedule during H-Frame X+1, it will visit the second
siTD eight times. During micro-frames 0 and 1 it will detect that it must execute
complete-splits.
During H-Frame X+1, micro-frame 0, the host controller detects that siTDX+1's Back
Pointer.T-bit is a zero, saves the state of siTDX+1 and fetches siTDX. It executes the
complete split transaction using the transaction state of siTDX. If the siTDX split
transaction is complete, siTD's Active bit is set to zero and results written back to siTDX.
The host controller retains the fact that siTDX is retired and transitions the SplitXState in
the siTDX+1 to Do Start Split. At this point, the host controller is prepared to execute the
start-split for siTDX+1 when it reaches micro-frame 4. If the split-transaction completes
early (transaction-complete is defined in Section Periodic Isochronous - Do Complete
Split ), that is, before all the scheduled complete-splits have been executed, the host
controller will transition siTDX.SplitXState to Do Start Split early and naturally skip the
remaining scheduled complete-split transactions. For this example, siTDX+1 does not
receive a DATA0 response until H-Frame X+2, micro-frame 1.
During H-Frame X+2, micro-frame 0, the host controller detects that siTDX+2's Back
Pointer.T-bit is a zero, saves the state of siTDX+2 and fetches siTDX+1. As described
above, it executes another split transaction, receives an MDATA response, updates the
transfer state, but does not modify the Active bit. The host controller returns to the
context of siTDX+2, and traverses its next pointer without any state change updates to
siTDX+2. S
During H-Frame X+2, micro-frame 1, the host controller detects siTDX+2's S-mask[0] is
a zero, saves the state of siTDX+2 and fetches siTDX+1. It executes another complete-split
transaction, receives a DATA0 response, updates the transfer state and sets the Active bit
to a zero. It returns to the state of siTDX+2 and changes its SplitXState to Do Start Split.
At this point, the host controller is prepared to execute start-splits for siTDX+2 when it
reaches micro-frame 4.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3766
NXP Semiconductors

<!-- page 3767 -->

56.4.3.13
Host Controller Pause
When the host controller's HCHalted bit in the USBSTS register is a zero, the host
controller is sending SOF (Start OF Frame) packets down all enabled ports.
When the schedules are enabled, the EHCI host controller will access the schedules in
main memory each micro-frame. This constant pinging of main memory is known to
create Arm platform power management problems for mobile systems. Specifically,
mobile systems aggressively manage the state of the Arm platform, based on recent
history usage. In the more aggressive power saving modes, the Arm platform can disable
its caches. Current PC architectures assume that bus-master accesses to main memory
must be cache-coherent. So, when bus masters are busy touching memory, the Arm
platform power management software can detect this activity over time and inhibit the
transition of the Arm platform into its lowest power savings mode. USB controllers are
bus-masters and the frequency at which they access their memory-based schedules keeps
the Arm platform power management software from placing the Arm platform into its
lowest power savings state.
USB Host controllers don't access main memory when they are suspended. However,
there are a variety of reasons why placing the USB controllers into suspend won't work,
but they are beyond the scope of this document. The base requirement is that the USB
controller needs to be kept out of main memory, while at the same time, the USB bus is
kept from going into suspend.
EHCI controllers provide a large-grained mechanism that can be manipulated by system
software to change the memory access pattern of the host controller. System software can
manipulate the schedule enable bits in the USBCMD register to turn on/off the
scheduling traversal. A software heuristic can be applied to implement an on/off duty
cycle that allows the USB to make reasonable progress and allow the Arm platform
power management to get the Arm platform into its lowest power state. This method is
not intended to be applied at all times to throttle USB, but should only be applied in very
specific configurations and usage loads. For example, when only a keyboard or mouse is
attached to the USB, the heuristic could detect times when the USB is attempting to move
data only very infrequently and can adjust the duty cycle to allow the Arm platform to
reach its low power state for longer periods of time. Similarly, it could detect increases in
the USB load and adjust the duty cycle appropriately, even to the point where the
schedules are never disabled. The assumption here is that the USB is moving data and the
Arm platform will be required to process the data streams.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3767

<!-- page 3768 -->

It is suggested that in order to provide a complete solution for the system, the companion
host controllers should also provide a similar method to allow system software to inhibit
the companion host controller from accessing its shared memory based data structures
(schedule lists or otherwise).
56.4.3.14
Port Test Modes -Host Operational Model
EHCI host controllers must implement the port test modes Test J_State, Test K_State,
Test_Packet, Test Force_Enable, and Test SE0_NAK as described in the USB
Specification Revision 2.0.
The system is only allowed to test ports that are owned by the EHCI controller (for
example, CF-bit is a one and PortOwner bit is a zero). System software is allowed to
have at most one port in test mode at a time. Placing more than one port in test mode will
yield undefined results. The required, per port test sequence is (assuming the CF-bit in
the USB_n_CONFIGFLAG register is a one):
• Disable the periodic and asynchronous schedules by setting the Asynchronous
Schedule Enable and Periodic Schedule Enable bits in the USBCMD register to a
zero.
• Place all enabled root ports into the suspended state by setting the Suspend bit in
each appropriate USB_n_PORTSC register to a one.
• Set the Run/Stop bit in the USBCMD register to a zero and wait for the HCHalted bit
in the USBSTS register, to transition to a one. Note that an EHCI host controller
implementation may optionally allow port testing with the Run/Stop bit set to a one.
However, all host controllers must support port testing with Run/Stop set to a zero
and HCHalted set to a one.
• Set the Port Test Control field in the port under test PORTSC register to the value
corresponding to the desired test mode. If the selected test is Test_Force_Enable,
then the Run/Stop bit in the USBCMD register must then be transitioned back to one,
in order to enable transmission of SOFs out of the port under test.
• When the test is complete, system software must ensure the host controller is halted
(HCHalted bit is a one) then it terminates and exits test mode by setting HCReset to a
one.
56.4.3.15
Interrupts-Host Operational Model
The EHCI Host Controller hardware provides interrupt capability based on a number of
sources.
There are several general groups of interrupt sources:
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3768
NXP Semiconductors

<!-- page 3769 -->

• Interrupts as a result of executing transactions from the schedule (success and error
conditions),
• Host controller events (Port change events, etc.), and
• Host Controller error events
All transaction-based sources are maskable through the Host Controller's Interrupt Enable
register (USBINTR, see Section Interrupt Enable Register (USB_nUSBINTR)).
Additionally, individual transfer descriptors can be marked to generate an interrupt on
completion. This section describes each interrupt source and the processing that occurs in
response to the interrupt.
During normal operation, interrupts may be immediate or deferred until the next interrupt
threshold occurs. The interrupt threshold is a tunable parameter via the Interrupt
Threshold Control field in the USBCMD register. The value of this register controls
when the host controller will generate an interrupt on behalf of normal transaction
execution. When a transaction completes during an interrupt interval period, the interrupt
signaling the completion of the transfer will not occur until the interrupt threshold occurs.
For example, the default value is eight micro-frames. This means that the host controller
will not generate interrupts any more frequently than once every eight micro-frames.
Section Host System Error details effects of a host system error.
If an interrupt has been scheduled to be generated for the current interrupt threshold
interval, the interrupt is not signaled until after the status for the last complete transaction
in the interval has been written back to host memory. This may sometimes result in the
interrupt not being signaled until the next interrupt threshold.
Initial interrupt processing is the same, regardless of the reason for the interrupt. When an
interrupt is signaled by the hardware, Arm platform control is transferred to host
controller's USB interrupt handler. The precise mechanism to accomplish the transfer is
OS specific. For this discussion it is just assumed that control is received. When the
interrupt handler receives control, its first action is to reads the USBSTS (USB Status
Register). It then acknowledges the interrupt by clearing all of the interrupt status bits by
writing ones to these bit positions. The handler then determines whether the interrupt is
due to schedule processing or some other event. After acknowledging the interrupt, the
handler (via an OS-specific mechanism), schedules a deferred procedure call (DPC)
which will execute later. The DPC routine processes the results of the schedule
execution. The precise mechanisms used are beyond the scope of this document.
Note: the host controller is not required to de-assert a currently active interrupt condition
when software sets the interrupt enables (in the USBINR register, see Section Interrupt
Enable Register (USB_nUSBINTR)) to a zero. The only reliable method software should
use for acknowledging an interrupt is by transitioning the appropriate status bits in the
USBSTS register (Section USB Status Register (USB_nUSBSTS)) from a one to a zero.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3769

<!-- page 3770 -->

56.4.3.15.1
Transfer/Transaction Based Interrupts
These interrupt sources are associated with transfer and transaction progress. They are all
dependent on the next interrupt threshold.
56.4.3.15.1.1
Transaction Error
A transaction error is any error that caused the host controller to think that the transfer did
not complete successfully.
The table below lists the events/responses that the host can observe as a result of a
transaction. The effects of the error counter and interrupt status are summarized in the
following paragraphs. Most of these errors set the XactErr status bit in the appropriate
interface data structure.
There is a small set of protocol errors that relate only when executing a queue head and
fit under the umbrella of a WRONG PID error that are significant to explicitly identify.
When these errors occur, the XactErr status bit in the queue head is set and the CErr field
is decremented. When the PIDCode indicates a SETUP, the following responses are
protocol errors and result in XactErr bit being set to a one and the CErr field being
decremented.
• EPS field indicates a high-speed device and it returns a Nak handshake to a SETUP.
• EPS field indicates a high-speed device and it returns a Nyet handshake to a SETUP.
• EPS field indicates a low- or full-speed device and the complete-split receives a Nak
handshake.
Table 56-52. Summary of Transaction Errors
Event /
Result
Queue Head/qTD/iTD/siTD Side-effects
USB Status Register
(USBSTS)
Cerr
Status Field
USBERRINT
CRC
-1
XactErr set to a one.
1, 1
Timeout
-1
XactErr set to a one.
11
Bad PID2
-1
XactErr set to a one.
11
Babble
N/A
Section Serial Bus Babble
1
Buffer Error
N/A
Section Data Buffer Error
1.
If occurs in a queue head, then USBERRINT is asserted only when CErr counts down from a one to a zero. In addition the
queue is halted, see Halting a Queue Head.
2.
The host controller received a response from the device, but it could not recognize the PID as a valid PID.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3770
NXP Semiconductors

<!-- page 3771 -->

56.4.3.15.1.2
Serial Bus Babble
When a device transmits more data on the USB than the host controller is expecting for
this transaction, it is defined to be babbling. In general, this is called a Packet Babble.
When a device sends more data than the Maximum Length number of bytes, the host
controller sets the Babble Detected bit to a one and halts the endpoint if it is using a
queue head (see Halting a Queue Head ). Maximum Length is defined as the minimum of
Total Bytes to Transfer and Maximum Packet Size. The CErr field is not decremented for
a packet babble condition (only applies to queue heads). A babble condition also exists if
IN transaction is in progress at High-speed EOF2 point. This is called a frame babble. A
frame babble condition is recorded into the appropriate schedule data structure. In
addition, the host controller must disable the port to which the frame babble is detected.
The USBERRINT bit in the USB_n_USBSTS register is set to a one and if the USB Error
Interrupt Enable bit in the USB_n_USBINTR register is a one, then a hardware interrupt
is signaled to the system at the next interrupt threshold. The host controller must never
start an OUT transaction that will babble across a micro-frame EOF.
NOTE
When a host controller detects a data PID mismatch, it must
either: disable the packet babble checking for the duration of
the bus transaction or do packet babble checking based solely
on Maximum Packet Size. The USB core specification defines
the requirements on a data receiver when it receives a data PID
mismatch (for example, expects a DATA0 and gets a DATA1
or visa-versa). In summary, it must ignore the received data and
respond with an ACK handshake, in order to advance the
transmitter's data sequence.
The EHCI interface allows System software to provide buffers
for a Control, Bulk or Interrupt IN endpoint that are not an even
multiple of the maximum packet size specified by the device.
Whenever a device misses an ACK for an IN endpoint, the host
and device are out of synchronization with respect to the
progress of the data transfer. The host controller may have
advanced the transfer to a buffer that is less than maximum
packet size. The device will re-send its maximum packet size
data packet, with the original data PID, in response to the next
IN token. In order to properly manage the bus protocol, the host
controller must disable the packet babble check when it
observes the data PID mismatch.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3771

<!-- page 3772 -->

56.4.3.15.1.3
Data Buffer Error
This event indicates that an overrun of incoming data or a underrun of outgoing data has
occurred for this transaction.
This would generally be caused by the host controller not being able to access required
data buffers in memory within necessary latency requirements. These conditions are not
considered transaction errors, and do not effect the error count in the queue head. When
these errors do occur, the host controller records the fact the error occurred by setting the
Data Buffer Error bit in the queue head, iTD or siTD.
If the data buffer error occurs on a non-isochronous IN, the host controller will not issue
a handshake to the endpoint. This will force the endpoint to resend the same data (and
data toggle) in response to the next IN to the endpoint.
If the data buffer error occurs on an OUT, the host controller must corrupt the end of the
packet so that it cannot be interpreted by the device as a good data packet. Simply
truncating the packet is not considered acceptable. An acceptable implementation option
is to 1's complement the CRC bytes and send them. There are other options suggested in
the Transaction Translator section of the USB Specification Revision 2.0.
56.4.3.15.1.4
USB Interrupt (Interrupt on Completion (IOC))
Transfer Descriptors (iTDs, siTDs, and queue heads (qTDs)) contain a bit that can be set
to cause an interrupt on their completion. The completion of the transfer associated with
that schedule item causes the USB Interrupt (USBINT) bit in the USB_n_USBSTS
register to be set to a one.
In addition, if a short packet is encountered on an IN transaction associated with a queue
head, then this event also causes USBINT to be set to a one. If the USB Interrupt Enable
bit in the USB_n_USBINTR register is set to a one, a hardware interrupt is signaled to
the system at the next interrupt threshold. If the completion is because of errors, the
USBERRINT bit in the USB_n_USBSTS register is also set to a one.
56.4.3.15.1.5
Short Packet
Reception of a data packet that is less than the endpoint's Max Packet size during
Control, Bulk or Interrupt transfers signals the completion of the transfer. Whenever a
short packet completion occurs during a queue head execution, the USBINT bit in the
USB_n_USBSTS register is set to a one.
If the USB Interrupt Enable bit is set in the USB_n_USBINTR register, a hardware
interrupt is signaled to the system at the next interrupt threshold.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3772
NXP Semiconductors

<!-- page 3773 -->

56.4.3.15.2
Host Controller Event Interrupts
These interrupt sources are independent of the interrupt threshold (with the one exception
being the Interrupt on Async Advance, see Section Interrupt on Async Advance ).
56.4.3.15.2.1
Port Change Events
Port registers contain status and status change bits. When the status change bits are set to
a one, the host controller sets the Port Change Detect bit in the USBSTS register to a
one.
If the Port Change Interrupt Enable bit in the USB_n_USBINTR register is a one, then
the host controller will issue a hardware interrupt. The port status change bits include:
• Connect Status Change
• Port Enable/Disable Change
• Over-current Change
• Force Port Resume
56.4.3.15.2.2
Frame List Rollover
This event indicates that the host controller has wrapped the frame list. The current
programmed size of the frame list effects how often this interrupt occurs.
If the frame list size is 1024, then the interrupt will occur every 1024 milliseconds, if it is
512, then it will occur every 512 milliseconds, etc. When a frame list rollover is detected,
the host controller sets the Frame List Rollover bit in the USB.USBSTS register to a one.
If the Frame List Rollover Enable bit in the USB.USBINTR register is set to a one, the
host controller issues a hardware interrupt. This interrupt is not delayed to the next
interrupt threshold.
56.4.3.15.2.3
Interrupt on Async Advance
This event is used for deterministic removal of queue heads from the asynchronous
schedule. Whenever the host controller advances the on-chip context of the asynchronous
schedule, it evaluates the value of the Interrupt on Async Advance Doorbell bit in the
USB.USBCMD register.
If it is a one, it sets the Interrupt on Async Advance bit in the USB.USBSTS register to a
one. If the Interrupton Async Advance Enable bit in the USB.USBINTR register is a one,
the host controller issues a hardware interrupt at the next interrupt threshold. A detailed
explanation of this feature is described in Section Removing Queue Heads from
Asynchronous Schedule .
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3773

<!-- page 3774 -->

56.4.3.15.2.4
Host System Error
The host controller is a bus master and any interaction between the host controller and the
system may experience errors.
The type of host error may be catastrophic to the host controller (such as a Master Abort)
making it impossible for the host controller to continue in a coherent fashion.In the
presence of non-catastrophic host errors, such as parity errors, the host controller could
potentially continue operation. The recommended behavior for these types of errors is to
escalate it to a catastrophic error and halt the host controller. Host-based error must result
in the following actions:
• The Run/Stop bit in the USB.USBCMD register is set to a zero.
• The following bits in the USB.USBSTS register are set:
• Host System Error bit is to a one.
• HCHalted bit is set to a one.
• If the Host System Error Enable bit in the USB.USBINTR register is a one, then the
host controller will issue a hardware interrupt. This interrupt is not delayed to the
next interrupt threshold. The following table summarizes the required actions taken
on the various host errors.
Table 56-53. Summary Behavior of EHCI Host Controller on Host System Errors
Cycle Type
Master Abort
Target Abort
Data Phase Parity
Frame list pointer fetch (read)
Fatal
Fatal
Fatal [o]
siTD fetch (read)
Fatal
Fatal
Fatal [o]
siTD status write-back (write)
Fatal [o]
Fatal [o]
Fatal [o]
iTD fetch (read)
Fatal
Fatal
Fatal [o]
iTD status write-back (write)
Fatal [o]
Fatal [o]
Fatal [o]
qTD fetch (read)
Fatal
Fatal
Fatal [o]
qHD status write-back (write)
Fatal [o]
Fatal [o]
Fatal [o]
Data write
Fatal [o]
Fatal [o]
Fatal [o]
Data read
Fatal
Fatal
Fatal [o]
Potentially, a host controller implementation could continue operation without a halt.
However, the recommended behavior is to halt the host controller.
NOTE
After a Host System Error, Software must reset the host
controller through HCReset in the USB.USBCMD register
before re-initializing and restarting the host controller.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3774
NXP Semiconductors

<!-- page 3775 -->

56.4.4
EHCI Deviation
For the purposes a dual-role Host/Device controller with support for On-The-Go
applications, it is necessary to deviate from the EHCI specification. Enhanced Host
Controller Interface Specification for Universal Serial Bus, Revision 0.95, November
2000, Intel Corporation. http://www.intel.com. Device operation & On-The-Go operation
is not specified in the EHCI and thus the implementation supported in this core is
proprietary.
The host mode operation of the core is near EHCI compatible with few minor differences
documented in this section.
The particulars of the deviations occur in the areas summarized here:
• Embedded Transaction Translator - Allows direct attachment of FS and LS devices
in host mode without the need for a companion controller.
• Device operation - In host mode the device operational registers are generally
disabled and thus device mode is mostly transparent when in host mode. However,
there are a couple exceptions documented in the following sections.
• Embedded design interface - This core does not have a PCI Interface and therefore
the PCI configuration registers described in the EHCI specification are not
applicable.
• On-The-Go Operation - This design includes an On-The-Go controller for Port #1.
56.4.4.1
Embedded Transaction Translator Function
The OTG controller supports directly connected full and low speed devices without
requiring a companion controller by including the capabilities of a USB 2.0 high speed
hub transaction translator.
Although there is no separate Transaction Translator block in the system, the transaction
translator function normally associated with a high speed hub has been implemented
within the DMA and Protocol engine blocks. The embedded transaction translator
function is an extension to EHCI interface, but makes use of the standard data structures
and operational models that exist in the EHCI specification to support full and low speed
devices.
56.4.4.1.1
Capability Registers
The following additions have been added to the capability registers to support the
embedded Transaction Translator Function:
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3775

<!-- page 3776 -->

• N_TT added to USB.HCSPARAMS - Host Control Structural Parameters
• N_PTT added to USB.HCSPARAMS - Host Control Structural Parameters
56.4.4.1.2
Operational Registers
The following additions have been added to the operational registers to support the
embedded TT:
• Addition of two-bit Port Speed (PSPD) to the Port Status & Control
(USB_nPORTSC1) register.
56.4.4.1.3
Discovery-EHCI Deviation
In a standard EHCI controller design, the EHCI host controller driver detects a Full speed
(FS) or Low speed (LS) device by noting if the port enable bit is set after the port reset
operation.
The port enable will only be set in a standard EHCI controller implementation after the
port reset operation and when the host and device negotiate a High-Speed connection
(that is, Chirp completes successfully).
Because this controller has an embedded Transaction Translator, the port enable will
always be set after the port reset operation regardless of the result of the host device chirp
result and the resulting port speed will be indicated by the PSPD field in USB.PORTSCx.
Therefore, the standard EHCI host controller driver requires an alteration to handle
directly connected Full and Low speed devices or hubs.
The change is a fundamental one in that is summarized in the following table.
Table 56-54. Summary of EHCI
Standard EHCI
EHCI with embedded Transaction Translator
After port enable bit is set following a connection and
reset sequence, the device/hub is assumed to be HS.
After port enable bit is set following a connection and reset
sequence, the device/hub speed is noted from USB.PORTSCx.
FS and LS devices are assumed to be downstream
from a HS hub thus, all port-level control is performed
through the Hub Class to the nearest Hub.
FS and LS device can be either downstream from a HS hub or
directly attached. When the FS/LS device is downstream from a HS
hub, then port-level control is done using the Hub Class through the
nearest Hub. When a FS/LS device is directly attached, then port-
level control is accomplished using USB.PORTSCx.
FS and LS devices are assumed to be downstream
from a HS hub with HubAddr=X. [where HubAddr > 0
and HubAddr is the address of the Hub where the bus
transitions from HS to FS/LS (ie. Split target hub)]
FS and LS device can be either downstream from a HS hub with
HubAddr = X [HubAddr > 0] or directly attached [where HubAddr = 0
and HubAddr is the address of the Root Hub where the bus
transitions from HS to FS/LS (ie. Split target hub is the root hub) ]
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3776
NXP Semiconductors

<!-- page 3777 -->

56.4.4.1.4
Data Structures
The same data structures used for FS/LS transactions though a HS hub are also used for
transactions through the Root Hub with sm embedded Transaction Translator.
Here it is demonstrated how the Hub Address and Endpoint Speed fields should be set for
directly attached FS/LS devices and hubs:
1. QH (for direct attach FS/LS) - Async. (Bulk/Control Endpoints) Periodic (Interrupt)
• Hub Address = 0
• Transactions to direct attached device/hub.
• QH.EPS = Port Speed
• Transactions to a device downstream from direct attached FS hub.
• QH.EPS = Downstream Device Speed
NOTE
When QH.EPS = 01 (LS) and PORTSCx.PSPD =
00 (FS), a LS-pre-pid will be sent before the
transmitting LS traffic.
Maximum Packet Size must be less than or equal
64 or undefined behaviour may result.
2. siTD (for direct attach FS) - Periodic (ISO Endpoint)
• All FS ISO transactions:
• Hub Address = 0
• siTD.EPS = 00 (full speed)
• Maximum Packet Size must less than or equal to 1023 or undefined
behaviour may result.
56.4.4.1.5
Operational Model
The operational models are well defined for the behavior of the Transaction Translator
(see USB 2.0 specification. Universal Serial Bus Specification, Revision 2.0, April 2000,
Compaq, Hewlett-Packard, Intel, Lucent, Microsoft, NEC, Philips. http://www.usb.org)
and for the EHCI controller moving packets between system memory and a USB-HS hub.
Because the embedded Transaction Translator exists within the host controller there is no
physical bus between EHCI host controller driver and the USB FS/LS bus. These sections
will briefly discuss the operational model for how the EHCI and Transaction Translator
operational models are combined without the physical bus between. The following
sections assume the reader is familiar with both the EHCI and USB 2.0 Transaction
Translator operational models.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3777

<!-- page 3778 -->

56.4.4.1.5.1
Micro- frame Pipeline
The EHCI operational model uses the concept of H-frames and B-frames to describe the
pipeline between the Host (H) and the Bus (B). The embedded Transaction Translator
shall use the same pipeline algorithms specified in the USB 2.0 specification for a Hub-
based Transaction Translator.
All periodic transfers always begin at B-frame 0 (after SOF) and continue until the stored
periodic transfers are complete. As an example of the micro-frame pipeline implemented
in the embedded Transaction Translator, all periodic transfers that are tagged in EHCI to
execute in H-frame 0 will be ready to execute on the bus in B-frame 0.
It is important to note that when programming the S-mask and C-masks in the EHCI data
structures to schedule periodic transfers for the embedded Transaction Translator, the
EHCI host controller driver must follow the same rules specified in EHCI for
programming the S-mask and C-mask for downstream Hub-based Transaction
Translators.
Once periodic transfers are exhausted, any stored asynchronous transfer will be moved.
Asynchronous transfers are opportunistic in that they shall execute whenever possible
and their operation is not tied to H-frame and B-frame boundaries with the exception that
an asynchronous transfer can not babble through the SOF (start of B-frame 0.)
56.4.4.1.5.2
Split State Machines
The start and complete split operational model differs from EHCI slightly because there
is no bus medium between the EHCI controller and the embedded Transaction Translator.
Where a start or complete-split operation would occur by requesting the split to the HS
hub, the start/complete split operation is simple an internal operation to the embedded
Transaction Translator. The following table summarizes the conditions where handshakes
are emulated from internal state instead of actual handshakes to HS split bus traffic.
Table 56-55. Summary of the Conditons of Handshakes1
Condition
Emulate TT Response
Start-Split: All asynchronous buffers full.
NAK
Start-Split: All periodic buffers full.
ERR
Start-Split: Success for start of Async.
Transaction.
ACK
Start-Split: Start Periodic Transaction.
No Handshake (Ok)
Complete-Split: Failed to find transaction in
queue.
Bus Time Out
Complete-Split: Transaction in Queue is Busy. NYET
Complete-Split: Transaction in Queue is
Complete.
[Actual Handshake from LS/FS device]
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3778
NXP Semiconductors

<!-- page 3779 -->

1.
The un-shaded cells represent Start-Splits and the shaded cells represent Complete-Splits
56.4.4.1.5.3
Asynchronous Transaction Scheduling and Buffer Management
The following USB 2.0 specification items are implemented in the embedded Transaction
Translator:
• Sequencing is provided & a packet length estimator ensures no full-speed/low-speed
packet babbles into SOF time.
• Transaction tracking for 2 data pipes.
56.4.4.1.5.3.1
USB 2.0 - 11.17.3
• Sequencing is provided & a packet length estimator ensures no full-speed/low-speed
packet babbles into SOF time.
56.4.4.1.5.3.2
USB 2.0 - 11.17.4
• Transaction tracking for 2 data pipes.
56.4.4.1.5.4
Periodic Transaction Scheduling and Buffer Management
The following USB 2.0 specification items are implemented in the embedded Transaction
Translator:
• Abort of pending start-splits
• EOF (and not started in micro-frames 6)
• Idle for more than 4 micro-frames
• Abort of pending complete-splits
• EOF
• Idle for more than 4 micro-frames
• Transaction tracking for up to 16 data pipes.
• Complete-split transaction searching.
NOTE
There is no data schedule mechanism for these transactions
other than the micro-frame pipeline. The embedded TT assumes
the number of packets scheduled in a frame does not exceed the
frame duration (1 ms) or else undefined behavior may result.
56.4.4.1.5.4.1
USB 2.0 - 11.18.6.[1-2]
• Abort of pending start-splits
• EOF (and not started in micro-frames 6)
• Idle for more than 4 micro-frames
• Abort of pending complete-splits
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3779

<!-- page 3780 -->

• EOF
• Idle for more than 4 micro-frames
56.4.4.1.5.4.2
USB 2.0 - 11.18.[7-8]
• Transaction tracking for up to 16 data pipes.
• Complete-split transaction searching.
NOTE
There is no data schedule mechanism for these transactions
other than the micro-frame pipeline. The embedded TT assumes
the number of packets scheduled in a frame does not exceed the
frame duration (1 ms) or else undefined behavior may result.
56.4.4.1.5.5
Multiple Transaction Translators
The maximum number of embedded Transaction Translators that is currently supported is
one as indicated by the N_TT field in the Host Controller Structural Parameters
(USB_nHCSPARAMS) register.
56.4.4.2
Device Operation
The co-existence of a device operational controller within the host controller has little
effect on EHCI compatibility for host operation except as noted in this section.
56.4.4.2.1
USB_USBMODE Register
Given that the dual-role controller is initialized in neither host nor device mode, the USB
Device Mode (USB_nUSBMODE) register must be programmed for host operation
before the EHCI host controller driver can begin EHCI host operations.
56.4.4.2.2
Non-Zero Fields the Register File
Some of the reserved fields and reserved addresses in the capability registers and
operational register have use in device mode, the following must be adhered to:
• Write operations to all EHCI reserved fields (some of which are device fields) with
the operation registers should always be written to zero. This is an EHCI requirement
of the device controller driver that must be adhered to.
• Read operations by the host controller must properly mask EHCI reserved fields
(some of which are device fields) because fields that are used exclusive for device
are undefined in host mode .
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3780
NXP Semiconductors

<!-- page 3781 -->

56.4.4.2.3
SOF Interrupt
This SOF Interrupt used for device mode is shared as a free running 125us interrupt for
host mode.
EHCI does not specify this interrupt but it has been added for convenience and as a
potential software time base. See USB Status Register (USB_nUSBSTS) and Interrupt
Enable Register (USB_nUSBINTR) registers.
56.4.4.3
Embedded Design Interface
This is an Embedded USB Host Controller as defined by the EHCI specification and thus
does not implement the PCI configuration registers.
56.4.4.3.1
Frame Adjust Register
Given that the optional PCI configuration registers are not included in this
implementation, there is no corresponding bit level timing adjustments like is provided
by the Frame Adjust register in the PCI configuration registers. Starts of micro-frames are
timed precisely to 125 us using the transceiver clock as a reference clock. That is, a 60
Mhz transceiver clock for 8-bit physical interfaces & full-speed serial interfaces or 30
Mhz transceiver clock for 16-bit physical interfaces.
56.4.4.4
Miscellaneous variations from EHCI
56.4.4.4.1
Programmable Physical Interface Behaviour
This design supports multiple Physical interfaces which can operate in differing modes
when the core is configured with software programmable Physical Interface Modes.
Software programmability allows the selection of the Physical interface part during the
board design phase instead of during the chip design phase. The control bits for selecting
the Physical Interface operating mode have been added to the Port Status & Control
(USB_nPORTSC1) register providing a capability that is not defined by EHCI.
56.4.4.4.2
Discovery
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3781

<!-- page 3782 -->

56.4.4.4.2.1
Port Reset
The port connect methods specified by EHCI require setting the port reset bit in the Port
Status & Control (USB_nPORTSC1) register for a duration of 10ms. Due to the
complexity required to support the attachment of devices that are not high speed there are
counter already present in the design that can count the 10ms reset pulse to alleviate the
requirement of the software to measure this duration. Therefore, the basic connection is
then summarized as the following:
• [Port Change Interrupt] Port connect change occurs to notify the host controller
driver that a device has attached.
• Software shall write a '1' to reset the device.
• Software shall write a '0' to reset the device after 10 ms.
• This step, which is necessary in a standard EHCI design, may be omitted with
this implementation. Should the EHCI host controller driver attempt to write a '0'
to the reset bit while a reset is in progress, the write will simple be ignored and
the reset will continue until completion.
• [Port Change Interrupt] Port enable change occurs to notify the host controller that
the device in now operational and at this point the port speed has been determined.
56.4.4.4.2.2
Port Speed Detection
After the port change interrupt indicates that a port is enabled, the EHCI stack should
determine the port speed. Unlike the EHCI implementation, which will re-assign the port
owner for any device that does not connect at High-Speed, this host controller supports
direct attach of non High-Speed devices.
Therefore, the following differences are important regarding port speed detection:
• Port Owner is read-only and always reads 0.
• A 2-bit Port Speed indicator has been added to PORTSC to provide the current
operating speed of the port to the host controller driver.
• A 1-bit High Speed indicator has been added to PORTSC to signify that the port is in
High-Speed vs. Full/Low Speed - This information is redundant with the 2-bit Port
Speed indicator above.
56.4.4.4.3
Port Test Mode
Port Test Control mode behaves fully as described in EHCI. An alternate host controller
driver procedure is not necessary or supported.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3782
NXP Semiconductors

<!-- page 3783 -->

56.4.5
Device Data Structures
This section defines the interface data structures used to communicate control, status, and
data between Device Controller Driver (DCD) Software and the Device Controller.
The data structure definitions in this chapter support a 32-bit memory buffer address
space. The interface consists of device Queue Heads and Transfer Descriptors.
NOTE
Software must ensure that no interface data structure reachable
by the Device Controller spans a 4K-page boundary.
The data structures defined in the chapter are (from the device controller's perspective) a
mix of read-only and read/ writable fields. The device controller must preserve the read-
only fields on all data structure writes.
The figure below shows the organization of the EndPoint Queue Head.
Endpoint QH 1 - Out
Endpoint QH 0 - In
Endpoint QH 0 - Out
Endpoint
Transfer
Descriptor
Up to
32 elements
ENDPOINTLISTADDR
Transfer
Buffer
Transfer
Buffer
Transfer
Buffer
Transfer
Buffer
Transfer Buffer Pointer
Transfer
Buffer
Pointer
Transfer
Buffer
Pointer
Transfer Buffer
Pointer
Endpoint Queue Heads
Figure 56-27. EndPoint Queue Head Organization
Endpoint queue heads are arranged in an array in a continuous area of memory pointed to
by the USB.ENDPOINTLISTADDR pointer. The even -numbered device queue heads in
the list support receive endpoints (OUT/SETUP) and the odd-numbered queue heads in
the list are used for transmit endpoints (IN/INTERRUPT). The device controller will
index into this array based upon the endpoint number received from the USB bus. All
information necessary to respond to transactions for all primed transfers is contained in
this list so the Device Controller can readily respond to incoming requests without having
to traverse a linked list.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3783

<!-- page 3784 -->

NOTE
The Endpoint Queue Head List must be aligned to a 2k
boundary.
56.4.5.1
Endpoint Queue Head (dQH)
The device Endpoint Queue Head (dQH) is where all transfers for a given endpoint are
managed. The dQH is a 48-byte data structure, but must be aligned on 64-byte
boundaries.
During priming of an endpoint, the dTD (device transfer descriptor) is copied into the
overlay area of the dQH, which starts at the nextTD pointer DWord and continues
through the end of the buffer pointers DWords. After a transfer is complete, the dTD
status DWord is updated in the dTD pointed to by the currentTD pointer. While a packet
is in progress, the overlay area of the dQH is used as a staging area for the dTD so that
the Device Controller can access needed information with little minimal latency.
Table 56-56. Endpoint Queue Head (dQH)
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9
8
7
6
5
4
3
2
1
0
Mult
zlt 0
Maximum Packet Length
io
s
0
Current dTD Pointer
0
Next dTD Pointer
0
T1
0
Total Bytes
io
c
0
MultO
0
Status
Buffer Pointer (Page 0)
Current Offset
Buffer Pointer (Page 1)
Reserved
Buffer Pointer (Page 2)
Reserved
Buffer Pointer (Page 3)
Reserved
Buffer Pointer (Page 4)1
Reserved
Reserved
Set-up Buffer Bytes 3…0
Set-up Buffer Bytes 7…4
1.
Transfer overlay starts at T and continues through Buffer Pointer (Page 4).
Host Controller Read/Write
Host Controller Read Only
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3784
NXP Semiconductors

<!-- page 3785 -->

56.4.5.1.1
Endpoint Capabilities/Characteristics
This DWord specifies static information about the endpoint, in other words, this
information does not change over the lifetime of the endpoint. Device Controller software
should not attempt to modify this information while the corresponding endpoint is
enabled.
Table 56-57 describes the endpoint capabilities.
Table 56-57. Endpoint Capabilities/Characteristics
Bit
Description
31-30
Mult. This field is used to indicate the number of packets executed per transaction description as given by the
following:
00 - Execute N Transactions as demonstrated by the USB variable length packet protocol where N is
computed using the Maximum Packet Length (dQH) and the Total Bytes field (dTD)
01 Execute 1 Transaction. 10 Execute 2 Transactions. 11 Execute 3 Transactions.
NOTE: Non-ISO endpoints must set Mult="00". ISO endpoints must set Mult="01", "10", or "11" as needed.
29
Zero Length Termination Select. This bit is used to indicate when a zero length packet is used to terminate
transfers where to total transfer length is a multiple . This bit is not relevant for Isochronous
0 - Enable zero length packet to terminate transfers equal to a multiple of the Maximum Packet Length.
(default).
1 - Disable the zero length packet on transfers that are equal in length to a multiple Maximum Packet Length.
28-27
Reserved. These bit reserved for future use and should be set to zero.
26-16
Maximum Packet Length. This directly corresponds to the maximum packet size of the associated endpoint
(wMaxPacketSize). The maximum value this field may contain is 0x400 (1024).
15
Interrupt On Setup (IOS). This bit is used on control type endpoints to indicate if USBINT is set in response to
a setup being received.
14-0
Reserved. Bits reserved for future use and should be set to zero.
56.4.5.1.2
Transfer Overlay-Endpoint Queue Head
The seven DWords in the overlay area represent a transaction working space for the
device controller.
The general operational model is that the device controller can detect whether the overlay
area contains a description of an active transfer. If it does not contain an active transfer,
then it will not read the associated endpoint.
After an endpoint is readied, the dTD will be copied into this queue head overlay area by
the device controller. Until a transfer is expired, software must not write the queue head
overlay area or the associated transfer descriptor. When the transfer is complete, the
device controller will write the results back to the original transfer descriptor and advance
the queue.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3785

<!-- page 3786 -->

See dTD for a description of the overlay fields.
56.4.5.1.3
Current dTD Pointer
The current dTD pointer is used by the device controller to locate the transfer in progress.
This word is for Device Controller (hardware) use only and should not be modified by
DCD software.
The following table describes the dTD Pointer.
Table 56-58. Next dTD Pointer
Bit
Description
31-5
Current dTD. This field is a pointer to the dTD that is represented in the transfer overlay area. This field will be
modified by the Device Controller to next dTD pointer during endpoint priming or queue advance.
4-0
Reserved. Bit reserved for future use and should be set to zero.
56.4.5.1.4
Set-up Buffer
The set-up buffer is dedicated storage for the 8-byte data that follows a set-up PID.
NOTE
Each endpoint has a TX and an RX dQH associated with it, and
only the RX queue head is used for receiving setup data
packets.
The following table describes the Multiple Mode Control.
Table 56-59. Multiple Mode Control (HCCPARAMS)
DWord
Bits
Description
1
31-0
Setup Buffer 0. This buffer contains bytes 3 to 0 of an incoming setup buffer packet and is written
by the device controller to be read by software.
2
31-0
Setup Buffer 1. This buffer contains bytes 7 to 4 of an incoming setup buffer packet and is written
by the device controller to be read by software.
56.4.5.2
Endpoint Transfer Descriptor (dTD)
The dTD describes to the device controller the location and quantity of data to be sent/
received for a given transfer.
The DCD should not attempt to modify any field in an active dTD except the Next Like
Pointer, which should only be modified as described in section Managing Transfers with
Transfer Descriptors.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3786
NXP Semiconductors

<!-- page 3787 -->

Table below shows the Endpoint Transfer Descriptor (dTD).
Table 56-60. Endpoint Transfer Descriptor (dTD)
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9
8
7
6
5
4
3
2
1
0
Next Link Pointer
0
T
0
Total Bytes
ioc 0
MultO
0
Status
Buffer Pointer (Page 0)
Current Offset
Buffer Pointer (Page 1)
0
Frame Number
Buffer Pointer (Page 2)
Reserved
Buffer Pointer (Page 3)
Reserved
Buffer Pointer (Page 4)
Reserved
Host Controller Read/Write
Host Controller Read Only
The following table describes the dTD Pointer.
Table 56-61. Next dTD Pointer
Bit
Description
31-5
Next Transfer Element Pointer. This field contains the physical memory address of the next dTD to be
processed. The field corresponds to memory address signals [31:5], respectively.
4-1
Reserved. Bits reserved for future use and should be set to zero.
0
Terminate (T). 1=pointer is invalid. 0=Pointer is valid (points to a valid Transfer Element Descriptor). This bit
indicates to the Device Controller that there are no more valid entries in the queue.
The following table describes the dTD Token.
Table 56-62. dTD Token
Bit
Description
31
Reserved. Bit reserved for future use and should be set to zero.
30-16
Total Bytes. This field specifies the total number of bytes to be moved with this transfer descriptor. This field is
decremented by the number of bytes actually moved during the transaction and only on the successful
completion of the transaction.
The maximum value software may store in the field is 5*4K (5000H). This is the maximum number of bytes 5
page pointers can access. Although it is possible to create a transfer up to 20K this assumes the 1st offset into
the first page is 0. When the offset cannot be predetermined, crossing past the 5th page can be guaranteed by
limiting the total bytes to 16K**. Therefore, the maximum recommended transfer is 16K (4000H).
If the value of the field is zero when the host controller fetches this transfer descriptor (and the active bit is set),
the device controller executes a zero-length transaction and retires the transfer descriptor.
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3787

<!-- page 3788 -->

Table 56-62. dTD Token (continued)
It is not a requirement for IN transfers that Total Bytes To Transfer be an even multiple of Maximum Packet
Length. If software builds such a transfer descriptor for an IN transfer, the last transaction will always be less
that Maximum Packet Length.
15
Interrupt On Complete (IOC). This bit is used to indicate if USBINT is to be set in response to device controller
being finished with this dTD.
14-12
Reserved. Bits reserved for future use and should be set to zero.
11-10
Multiplier Override (MultO). This field can be used for transmit ISO's (ie. ISO-IN) to override the multiplier in the
QH. This field must be zero for all packet types that are not transmit-ISO.
Example:
if QH.multiplier = 3; Maximum packet size = 8; Total Bytes = 15; MultiO = 0 [default]
Three packets are sent: {Data2(8); Data1(7); Data0(0)}
if QH.multiplier = 3; Maximum packet size = 8; Total Bytes = 15; MultiO = 2
Two packets are sent: {Data1(8); Data0(7)}
For maximal efficiency, software should compute MultO = greatest integer of (Total Bytes / Max. Packet Size)
except for the case when Total Bytes = 0; then MultO should be 1.
Note: Non-ISO and Non-TX endpoints must set MultO = "00".
9-8
Reserved. Bits reserved for future use and should be set to zero.
7-0
Status. This field is used by the Device Controller to communicate individual command execution states back
to the Device Controller software. This field contains the status of the last transaction performed on this qTD.
The bit encodings are:
Bit Status Field Description
7 Active.
6 Halted.
5 Data Buffer Error.
3 Transaction Error.
4, 2, 0 Reserved.
The table below describes the dTD Buffer Page Pointer List.
Table 56-63. dTD Buffer Page Pointer List
Bit
Description
31-12
Buffer Pointer. Selects the page offset in memory for the packet buffer. Non virtual memory systems will
typically set the buffer pointers to a series of incrementing integers.
0,11-0
Current Offset. Offset into the 4kb buffer where the packet is to begin.
1,10-0
Frame Number. Written by the device controller to indicate the frame number in which a packet finishes. This is
typically be used to correlate relative completion times of packets on an ISO endpoint.
56.4.6
Device Operational Model
The function of the device operation is to transfer a request in the memory image to and
from the Universal Serial Bus.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3788
NXP Semiconductors

<!-- page 3789 -->

Using a set of linked list transfer descriptors, pointed to by a queue head, the device
controller will perform the data transfers. The following sections explain the use of the
device controller from the device controller driver (DCD) point-of-view and further
describe how specific USB bus events relate to status changes in the device controller
programmer's interface.
56.4.6.1
Device Controller Initialization
After hardware reset, the device is disabled until the Run/Stop bit is set to a '1'. In the
disabled state, the pull-up on the USB D+ is not active which prevents an attach event
from occurring. At a minimum, it is necessary to have the queue heads setup for endpoint
zero before the device attach occurs.
Shortly after the device is enabled, a USB reset will occur followed by setup packet
arriving at endpoint 0. A Queue head must be prepared so that the device controller can
store the incoming setup packet.
In order to initialize a device, the software should perform the following steps:
• Set Controller Mode in the USB.USBMODE register to device mode.
NOTE
Transitioning from host mode to device mode requires a
device controller reset before modifying USB.USBMODE.
• Allocate and Initialize device queue heads in system memory.
• Minimum: Initialize device queue heads 0 Tx & 0 Rx.
NOTE
All device queue heads for control endpoints must be
initialized before the endpoint is enabled. Non-Control
device queue heads before the endpoint can be used.
• For information on device queue heads, refer to section Device Data Structures.
• Configure USB.ENDPOINTLISTADDR Pointer.
• For additional information on USB.ENDPOINTLISTADDR, refer to the register
table.
• Enable the microprocessor interrupt associated with the USB core.
• Recommended: enable all device interrupts including: USBINT, USBERRINT,
Port Change Detect, USB Reset Received, DCSuspend.
• For a list of available interrupts refer to the Interrupt Enable Register
(USB_nUSBINTR) and the USB Status Register (USB_nUSBSTS) register
tables.
• Set Run/Stop bit to Run Mode.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3789

<!-- page 3790 -->

• After the Run bit is set and the device is connected to a host, a Bus Reset will be
issued by host downstream port. The DCD must monitor the reset event and
adjust the software state as described in the Bus Reset section of the Port State
and Control section below.
NOTE
Endpoint 0 is designed as a control endpoint only and does
not need to be configured using ENDPTCTRL0 register.
It is also not necessary to prime Endpoint 0 initially because the first packet received will
always be a setup packet. The contents of the first setup packet will require a response in
accordance with USB device framework (Chapter 9) command set.
56.4.6.2
Port State and Control
From a chip or system reset, the device controller enters the powered state. A transition
from the powered state to the attach state occurs when the Run/Stop bit is set to a '1'.
After receiving a reset on the bus, the port will enter the defaultFS or defaultHS state in
accordance with the reset protocol described in Appendix C.2 of the USB Specification
Rev. 2.0.
The following state diagram depicts the state of a USB 2.0 device.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3790
NXP Semiconductors

<!-- page 3791 -->

Configured
FS/HS
Suspend
FS/HS
Bus Inactive
Bus Activity
Suspend
FS/HS
Bus Inactive
Bus Activity
Suspend
FS/HS
Bus Inactive
Bus Activity
Default
FS/HS
Address
FS/HS
Attach
Reset
Powered
Set Run/Stop
bit to Run
Mode
Power
Interruption
When the host resets
the device returns to
the default state
Software Only State
Active State
Inactive State
Device
Deconfigured
Device
Configured
Address
Assigned
Figure 56-28. Device State Diagram
States powered, attach, defaultFS/HS, suspendFS/HS are implemented in the device
controller and are communicated to the DCD using the following status bits:
The following table describes the Device Controller State Information Bits.
Table 56-64. Device Controller State Information Bits
Bit
Register
DCSuspend
USB Status Register (USB_nUSBSTS)
USB Reset Received
USB Status Register (USB_nUSBSTS)
Port Change Detect
USB Status Register (USB_nUSBSTS)
High-Speed Port
Port Status & Control (USB_nPORTSC1)
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3791

<!-- page 3792 -->

It is the responsibility of the DCD to maintain a state variable to differentiate between the
DefaultFS/HS state and the Address/Configured states. Change of state from Default to
Address and the Configured states is part of the enumeration process described in the
device framework section of the USB 2.0 Specification.
As a result of entering the Address state, the device address register (DEVICEADDR)
must be programmed by the DCD.
Entry into the Configured indicates that all endpoints to be used in the operation of the
device have been properly initialized by programming the USB_UOG_ENDPTCTRLx
registers and initializing the associated queue heads.
56.4.6.2.1
Bus Reset
A bus reset is used by the host to initialize downstream devices.
When a bus reset is detected, the device controller will renegotiate its attachment speed,
reset the device address to 0, and notify the DCD by interrupt (assuming the USB Reset
Interrupt Enable is set). After a reset is received, all endpoints (except endpoint 0) are
disabled and any primed transactions will be cancelled by the device controller. The
concept of priming will be clarified below, but the DCD must perform the following
tasks when a reset is received:
Clear all setup token semaphores by reading the Endpoint Status (USB_nENDPTSTAT)
register and writing the same value back to the Endpoint Status (USB_nENDPTSTAT)
register.
Clear all the endpoint complete status bits by reading the Endpoint Complete
(USB_nENDPTCOMPLETE) register and writing the same value back to the Endpoint
Complete (USB_nENDPTCOMPLETE) register.
Cancel all primed status by waiting until all bits in the Endpoint Prime
(USB_nENDPTPRIME) are 0 and then writing 0xFFFFFFFF to Endpoint Flush
(USB_nENDPTFLUSH).
Read the reset bit in the Port Status & Control (USB_nPORTSC1) register and make sure
that it is still active. A USB reset will occur for a minimum of 3 ms and the DCD must
reach this point in the reset cleanup before end of the reset occurs, otherwise a hardware
reset of the device controller is recommended (rare.)
• A hardware reset can be performed by writing a one to the device controller reset bit
in the USBCMD reset. Note: a hardware reset will cause the device to detach from
the bus by clearing the Run/Stop bit. Thus, the DCD must completely re-initialize the
device controller after a hardware reset.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3792
NXP Semiconductors

<!-- page 3793 -->

Free all allocated dTDs because they will no longer be executed by the device controller.
If this is the first time the DCD is processing a USB reset event, then it is likely that no
dTDs have been allocated.
At this time, the DCD may release control back to the OS because no further changes to
the device controller are permitted until a Port Change Detect is indicated.
After a Port Change Detect, the device has reached the default state and the DCD can
read the Port Status & Control (USB_nPORTSC1) to determine if the device is operating
in FS or HS mode. At this time, the device controller has reached normal operating mode
and DCD can begin enumeration according to the USB Chapter 9 - Device Framework.
NOTE
The device DCD may use the FS/HS mode information to
determine the bandwidth mode of the device
In some applications, it may not be possible to enable one or more pipes while in FS
mode. Beyond the data rate issue, there is no difference in DCD operation between FS
and HS modes.
56.4.6.2.2
Suspend/Resume
The detials of suspend and resume are explained in these sections.
56.4.6.2.2.1
Suspend
Suspend Description
In order to conserve power, USB devices automatically enter the suspended state when
the device has observed no bus traffic for a specified period. When suspended, the USB
device maintains any internal status, including its address and configuration. Attached
devices must be prepared to suspend at any time they are powered, regardless of if they
have been assigned a non-default address, are configured, or neither. Bus activity may
cease due to the host entering a suspend mode of its own. In addition, a USB device shall
also enter the suspended state when the hub port it is attached to is disabled.
A USB device exits suspend mode when there is bus activity. A USB device may also
request the host to exit suspend mode or selective suspend by using electrical signaling to
indicate remote wakeup. The ability of a device to signal remote wakeup is optional. If
the USB device is capable of remote wakeup signaling, the device must support the
ability of the host to enable and disable this capability. When the device is reset, remote
wakeup signaling must be disabled.
Suspend Operational Model
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3793

<!-- page 3794 -->

The device controller moves into the suspend state when suspend signaling is detected or
activity is missing on the upstream port for more than a specific period. After the device
controller enters the suspend state, the DCD is notified by an interrupt (assuming DC
Suspend Interrupt is enabled). When the DCSuspend bit in the Port Status & Control
(USB_nPORTSC1) is set to a '1', the device controller is suspended.
DCD response when the device controller is suspended is application specific and may
involve switching to low power operation.
Information on the bus power limits in suspend state can be found in USB 2.0
specification.
NOTE
Review system level clocking issues defined in section (Ref:
Signals-Clocking) for the clocking requirements of a suspended
device controller.
56.4.6.2.2.2
Resume
If the device controller is suspended, its operation is resumed when any non-idle
signaling is received on its upstream facing port. In addition, the device can signal the
system to resume operation by forcing resume signaling to the upstream port.
Resume signaling is sent upstream by writing a '1' to the Resume bit in the in the Port
Status & Control (USB_nPORTSC1) while the device is in suspend state. Sending
resume signal to an upstream port should cause the host to issue resume signaling and
bring the suspended bus segment (one more devices) back to the active condition.
NOTE
Before resume signaling can be used, the host must enable it by
using the Set Feature command defined in device framework
(chapter 9) of the USB 2.0 Specification.
56.4.6.3
Managing Endpoints
The USB 2.0 specification defines an endpoint, also called a device endpoint or an
address endpoint as a uniquely addressable portion of a USB device that can source or
sink data in a communications channel between the host and the device.
The endpoint address is specified by the combination of the endpoint number and the
endpoint direction.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3794
NXP Semiconductors

<!-- page 3795 -->

The channel between the host and an endpoint at a specific device represents a data pipe.
Endpoint 0 for a device is always a control type data channel used for device discovery
and enumeration. Other types of endpoints support by USB include bulk, interrupt, and
isochronous. Each endpoint type has specific behavior related to packet response and
error handling. More detail on endpoint operation can be found in the USB 2.0
specification.
The USB OTG device controller hardware supports up to 8 endpoint numbers.
Each endpoint direction is essentially independent and can be configured with differing
behavior in each direction. For example, the DCD can configure endpoint 1-IN to be a
bulk endpoint and endpoint 1-OUT to be an isochronous endpoint. This helps to conserve
the total number of endpoints required for device operation. The only exception is that
control endpoints must use both directions on a single endpoint number to function as a
control endpoint. Endpoint 0 is, for example, is always a control endpoint and uses the
pair of directions.
Each endpoint direction requires a queue head allocated in memory. To support the 8
endpoint numbers, 16 queue heads are required. The operation of an endpoint and use of
queue heads are described later in this document.
56.4.6.3.1
Endpoint Initialization
After hardware reset, all endpoints except endpoint zero are uninitialized and disabled.
The DCD must configure and enable each endpoint by writing to configuration bit in the
USB_UOG_ENDPTCTRLx register.
Each 32-bit USB_UOG_ENDPTCTRLx is split into an upper and lower half. The lower
half of USB_UOG_ENDPTCTRLx is used to configure the receive or OUT endpoint and
the upper half is likewise used to configure the corresponding transmit or IN endpoint.
Control endpoints must be configured the same in both the upper and lower half of the
USB_UOG_ENDPTCTRLx register otherwise the behavior is undefined. The following
table shows how to construct a configuration word for endpoint initialization. The
following table shows the fields and values for the Device Controller Endpoint
initialization.
Table 56-65. Device Controller Endpoint Initialization
Field
Value
Data Toggle Reset
1
Data Toggle Inhibit
0
Endpoint Type
00 Control
01 Isochronous
10 Bulk
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3795

<!-- page 3796 -->

Table 56-65. Device Controller Endpoint Initialization (continued)
11 Interrupt
Endpoint Stall
0
56.4.6.3.2
Stalling
There are two occasions where the device controller may need to return to the host a
STALL.
The first occasion is the functional stall, which is a condition set by the DCD as described
in the USB 2.0 device framework. A functional stall is only used on non-control
endpoints and can be enabled in the device controller by setting the endpoint stall bit in
the USB_UOG_ENDPTCTRLx register associated with the given endpoint and the given
direction. In a functional stall condition, the device controller will continue to return
STALL responses to all transactions occurring on the respective endpoint and direction
until the endpoint stall bit is cleared by the DCD.
A protocol stall, unlike a function stall, is used on control endpoints is automatically
cleared by the device controller at the start of a new control transaction (setup phase).
When enabling a protocol stall, the DCD should enable the stall bits (both directions) as a
pair. A single write to the USB_UOG_ENDPTCTRLx register can ensure that both stall
bits are set at the same instant.
NOTE
Any write to the USB_UOG_ENDPTCTRLx register during
operational mode must preserve the endpoint type field (that is,
perform a read-modify-write).
The following table shows the response matrix for the Device Controller Stall.
Table 56-66. Device Controller Stall Response Matrix
USB Packet
Endpoint Stall Bit.
Effect on STALL bit.
USB Response
SETUP packet received by a non-
control endpoint.
N/A
None.
STALL
IN/OUT/PING packet received by
a non-control endpoint.
'1'
None.
STALL
IN/OUT/PING packet received by
a non-control endpoint.
'0'
None.
ACK/
NAK/
NYET
SETUP packet received by a
control endpoint.
N/A
Cleared
ACK
IN/OUT/PING packet received by
a control endpoint
'1'
None
STALL
Table continues on the next page...
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3796
NXP Semiconductors

<!-- page 3797 -->

Table 56-66. Device Controller Stall Response Matrix (continued)
IN/OUT/PING packet received by
a control endpoint.
'0'
None.
ACK/
NAK/
NYET
56.4.6.3.3
Data Toggle
Data toggle is a mechanism to maintain data coherency between host and device for any
given data pipe.
For more information on data toggle, refer to the USB 2.0 specification.
56.4.6.3.3.1
Data Toggle Reset
The DCD may reset the data toggle state bit and cause the data toggle sequence to reset in
the device controller by writing a '1' to the data toggle reset bit in the
USB_UOG_ENDPTCTRLx register.
This should only be necessary when configuring/initializing an endpoint or returning
from a STALL condition.
56.4.6.3.3.2
Data Toggle Inhibit
NOTE
This feature is for test purposes only and should never be used
during normal device controller operation.
Setting the data toggle Inhibit bit active ('1') causes the device controller to ignore the
data toggle pattern that is normally sent and accept all incoming data packets regardless
of the data toggle state.
In normal operation, the device controller checks the DATA0/DATA1 bit against the data
toggle to determine if the packet is valid. If Data PID does not match the data toggle state
bit maintained by the device controller for that endpoint, the Data toggle is considered
not valid. If the data toggle is not valid, the device controller assumes the packet was
already received and discards the packet (not reporting it to the DCD). To prevent the
host controller from re-sending the same packet, the device controller will respond to the
error packet by acknowledging it with either an ACK or NYET response.
56.4.6.3.3.3
Priming Transmit Endpoints
Priming a transmit endpoint will cause the device controller to fetch the device transfer
descriptor (dTD) for the transaction pointed to by the device queue head (dQH).
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3797

<!-- page 3798 -->

After the dTD is fetched, it will be stored in the dQH until the device controller
completes the transfer described by the dTD. Storing the dTD in the dQH allows the
device controller to fetch the operating context needed to handle a request from the host
without the need to follow the linked list, starting at the dQH when the host request is
received.
After the device has loaded the dTD, the leading data in the packet is stored in a FIFO in
the device controller. This FIFO is split into virtual channels so that the leading data can
be stored for any endpoint up to the maximum number of endpoints configured at device
synthesis time.
After a priming request is complete, an endpoint state of primed is indicated in the
USB_UOG_ENDPTSTATUS register. For a primed transmit endpoint, the device
controller can respond to an IN request from the host and meet the stringent bus
turnaround time of High Speed USB.
Because only the leading data is stored in the device controller FIFO, it is necessary for
the device controller to begin filling in behind leading data after the transaction starts.
The FIFO must be sized to account for the maximum latency that can be incurred by the
system memory bus. More information about FIFO sizing is presented in section .
56.4.6.3.3.4
Priming Receive Endpoints
Priming receive endpoints is identical to priming of transmit endpoints from the point of
view of the DCD. At the device controller the major difference in the operational model
is that there is no data movement of the leading packet data simply because the data is to
be received from the host.
Note as part of the architecture, the FIFO for the receive endpoints is not partitioned into
multiple channels like the transmit FIFO. Thus, the size of the RX FIFO does not scale
with the number of endpoints.
56.4.6.4
Operational Model For Packet Transfers
All transactions on the USB bus are initiated by the host and in turn, the device must
respond to any request from the host within the turnaround time stated in the USB 2.0
Specification.
At USB 1.1 Full or Low Speed rates, this turnaround time was significant and the USB
1.1 device controllers were architected so that the device controller could access main
memory or interrupt a host protocol processor in order to respond to the USB 1.1
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3798
NXP Semiconductors

<!-- page 3799 -->

transaction. The architecture of the USB 2.0 device controller must be different because
same methods will not meet USB 2.0 High-speed turnaround time requirements by
simply increasing clock rate.
A USB host will send requests to the device controller in an order that can not be
precisely predicted as a single pipeline, so it is not possible to prepare a single packet for
the device controller to execute. However, the order of packet requests is predictable
when the endpoint number and direction is considered. For example, if endpoint 3
(transmit direction) is configured as a bulk pipe, then we can expect the host will send IN
requests to that endpoint. This device controller is architected in such a way that it can
prepare packets for each endpoint/direction in anticipation of the host request. The
process of preparing the device controller to send or receive data in response to host
initiated transaction on the bus is referred to as "priming" the endpoint. This term will be
used throughout the following documentation to describe the device controller operation
so the DCD can be architected properly use priming. Further, note that the term
"flushing" is used to describe the action of clearing a packet that was queued for
execution.
56.4.6.4.1
Interrupt/Bulk Endpoint Operational Model
The behaviors of the device controller for interrupt and bulk endpoints are identical.
All valid IN and OUT transactions to bulk pipes will handshake with a NAK unless the
endpoint had been primed. Once the endpoint has been primed, data delivery will
commence.
A dTD will be retired by the device controller when the packets described in the transfer
descriptor have been completed. Each dTD describes N packets to be transferred
according to the USB Variable Length transfer protocol. The formula and table on the
following page describe how the device controller computes the number and length of the
packets to be sent/received by the USB vary according to the total number of bytes and
maximum packet length.
With Zero Length Termination (ZLT) = 0
N = INT(Number Of Bytes/Max. Packet Length) + 1
With Zero Length Termination (ZLT) = 1
N = MAXINT(Number Of Bytes/Max. Packet Length)
Table 56-67. Variable Length Transfer Protocol Example (ZLT = 0)
Bytes (dTD)
Max. Packet Length (dQH)
N
P1
P2
P3
511
256
2
256
255
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3799

<!-- page 3800 -->

Table 56-67. Variable Length Transfer Protocol Example (ZLT = 0) (continued)
512
256
3
256
256
0
512
512
2
512
0
Table 56-68. Variable Length Transfer Protocol Example (ZLT = 1)
Bytes (dTD)
Max. Packet Length (dQH)
N
P1
P2
P3
511
256
2
256
255
512
256
2
256
256
512
512
1
512
NOTE
The MULT field in the dQH must be set to "00" for bulk,
interrupt, and control endpoints.
TX-dTD is complete when:
• All packets described dTD were successfully transmitted. *** Total bytes in dTD
will equal zero when this occurs.
RX-dTD is complete when:
• All packets described in dTD were successfully received. *** Total bytes in dTD
will equal zero when this occurs.
• A short packet (number of bytes < maximum packet length) was received. *** This
is a successful transfer completion; DCD must check Total Bytes in dTD to
determine the number of bytes that are remaining. From the total bytes remaining in
the dTD, the DCD can compute the actual bytes received.
• A long packet was received (number of bytes > maximum packet size) OR (total
bytes received > total bytes specified). *** This is an error condition. The device
controller will discard the remaining packet, and set the Buffer Error bit in the dTD.
In addition, the endpoint will be flushed and the USBERR interrupt will become
active.
On the successful completion of the packet(s) described by the dTD, the active bit in the
dTD will be cleared and the next pointer will be followed when the Terminate bit is clear.
When the Terminate bit is set, the device controller will flush the endpoint/direction and
cease operations for that endpoint/direction.
On the unsuccessful completion of a packet (see long packet above), the dQH will be left
pointing to the dTD that was in error. In order to recover from this error condition, the
DCD must properly reinitialize the dQH by clearing the active bit and update the nextTD
pointer before attempting to re-prime the endpoint.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3800
NXP Semiconductors

<!-- page 3801 -->

NOTE
All packet level errors such as a missing handshake or CRC
error will be retried automatically by the device controller.
There is no required interaction with the DCD for handling such errors.
56.4.6.4.1.1
Interrupt/Bulk Endpoint Bus Response Matrix
The table below shows the response matrix for Interrput/Bulk Endpoint Bus.
Table 56-69. Interrupt/Bulk Endpoint Bus Response Matrix
Stall
Not Primed
Primed
Underflow
Overflow
Setup
Ignore
Ignore
Ignore
N/A
N/A
In
STALL
NAK
Transmit
BS Error
N/A
Out
STALL
NAK
Receive + NYET/ACK N/A
NAK
Ping
STALL
NAK
ACK
N/A
N/A
Invalid
Ignore
Ignore
Ignore
Ignore
Ignore
NOTE
BS Error = Force Bit Stuff Error
NYET/ACK - NYET unless the Transfer Descriptor has
packets remaining according to the USB variable length
protocol then ACK.
SYSERR - System error should never occur when the latency
FIFOs are correctly sized and the DCD is responsive.
56.4.6.4.2
Control Endpoint Operation Model
This section details the setup phase, data phase, status phase, and the control endpoint bus
response matrix.
56.4.6.4.2.1
Setup Phase
All requests to a control endpoint begin with a setup phase followed by an optional data
phase and a required status phase. The device controller will always accept the setup
phase unless the setup lockout is engaged.
The setup lockout will engage so that future setup packets are ignored. Lockout of setup
packets ensures that while software is reading the setup packet stored in the queue head,
that data is not written as it is being read potentially causing an invalid setup packet.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3801

<!-- page 3802 -->

The setup lockout mechanism can be disabled and a new tripwire type semaphore will
ensure that the setup packet payload is extracted from the queue head without being
corrupted be an incoming setup packet. This is the preferred behavior because ignoring
repeated setup packets due to long software interrupt latency would be a compliance
issue.
• Disable Setup Lockout by writing 1 to Setup Lockout Mode (SLOM) in USB Device
Mode (USB_nUSBMODE). (once at initialization). Setup lockout is not necessary
when using the tripwire as described below.
NOTE
Leaving the Setup Lockout Mode As 0 will result in pre-2.3
hardware behavior.
• After receiving an interrupt and inspecting Endpoint Setup Status
(USB_nENDPTSETUPSTAT) to determine that a setup packet was received on a
particular pipe:
a. Write 1 to clear corresponding bit Endpoint Setup Status
(USB_nENDPTSETUPSTAT).
b. Write 1 to Setup Tripwire (SUTW) in USB Command Register
(USB_nUSBCMD) register.
c. Duplicate contents of dQH.SetupBuffer into local software byte array.
d. Read Setup TripWire (SUTW) in USB Command Register (USB_nUSBCMD)
register. (if set - continue; if cleared - goto 2)
e. Write 0 to clear Setup Tripwire (SUTW) in USB Command Register
(USB_nUSBCMD) register.
f. Process setup packet using local software byte array copy and execute status/
handshake phases.
NOTE
After receiving a new setup packet the status and/or handshake
phases may still be pending from a previous control sequence.
These should be flushed & deallocated before linking a new
status and/or handshake dTD for the most recent setup packet.
56.4.6.4.2.2
Data Phase
Following the setup phase, the DCD must create a device transfer descriptor for the data
phase and prime the transfer.
After priming the packet, the DCD must verify a new setup packet has not been received
by reading the USB.ENDPTSETUPSTAT register immediately verifying that the prime
had completed. A prime will complete when the associated bit in the Endpoint Prime
(USB_nENDPTPRIME) register is zero and the associated bit in the Endpoint Status
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3802
NXP Semiconductors

<!-- page 3803 -->

(USB_nENDPTSTAT) register is a one. If a prime fails, ie. The Endpoint Prime
(USB_nENDPTPRIME) bit goes to zero and the Endpoint Status (USB_nENDPTSTAT)
bit is not set, then the prime has failed. This can only be due to improper setup of the
dQH, dTD or a setup arriving during the prime operation. If a new setup packet is
indicated after the ENDPTPRIME bit is cleared, then the transfer descriptor can be freed
and the DCD must reinterpret the setup packet.
Should a setup arrive after the data stage is primed, the device controller will
automatically clear the prime status (Endpoint Status (USB_nENDPTSTAT)) to enforce
data coherency with the setup packet.
NOTE
• The MULT field in the dQH must be set to "00" for bulk,
interrupt, and control endpoints.
• Error handling of data phase packets is the same as bulk
packets described previously.
56.4.6.4.2.3
Status Phase
Similar to the data phase, the DCD must create a transfer descriptor (with byte length
equal zero) and prime the endpoint for the status phase.
The DCD must also perform the same checks of the USB.ENDPTSETUPSTAT as
described above in the data phase.
NOTE
• The MULT field in the dQH must be set to 00 for bulk,
interrupt, and control endpoints.
• Error handling of data phase packets is the same as bulk
packets described previously.
56.4.6.4.2.4
Control Endpoint Bus Response Matrix
Shown in the following table is the device controller response to packets on a control
endpoint according to the device controller state.
The table below shows the response matrix for the Control Endpoint Bus.
Table 56-70. Control Endpoint Bus Response Matrix
Token Type
Endpoint State
Setup Lockout
Stall
Not Primed
Primed
Underflow
Overflow
Setup
ACK
ACK
ACK
N/A
SYSERR
In
STALL
NAK
Transmit
BS Error
N/A
N/A
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3803

<!-- page 3804 -->

Table 56-70. Control Endpoint Bus Response Matrix (continued)
Out
STALL
NAK
Receive +
NYET/ACK
N/A
NAK
N/A
Ping
STALL
NAK
ACK
N/A
N/A
N/A
Invalid
Ignore
Ignore
Ignore
Ignore
Ignore
Ignore
BS Error = Force Bit Stuff Error
NYET/ACK - NYET unless the Transfer Descriptor has packets remaining according to
the USB variable length protocol then ACK.
SYSERR - System error should never occur when the latency FIFOs are correctly sized
and the DCD is responsive.
56.4.6.4.3
Isochronous Endpoint Operational Model
Isochronous endpoints are used for real-time scheduled delivery of data and their
operational model is significantly different than the host throttled Bulk, Interrupt, and
Control data pipes.
Real time delivery by the device controller will be accomplished by the following:
• Exactly MULT Packets per (micro) Frame are transmitted/received. Note: MULT is
a two-bit field in the device Queue Head. The variable length packet protocol is not
used on isochronous endpoints.
• NAK responses are not used. Instead, zero length packets are sent in response to an
IN request to an unprimed endpoints. For unprimed RX endpoints, the response to an
OUT transaction is to ignore the packet within the device controller.
• Prime requests always schedule the transfer described in the dTD for the next (micro)
frame. If the ISO-dTD is still active after that frame, then the ISO-dTD will be held
ready until executed or canceled by the DCD.
An EHCI compatible host controller uses the periodic frame list to schedule data
exchanges to Isochronous endpoints. The operational model for device mode does not use
such a data structure. Instead, the same dTD used for Control/Bulk/Interrupt endpoints is
also used for isochronous endpoints. The difference is in the handling of the dTD.
The first difference between bulk and ISO-endpoints is that priming an ISO-endpoint is a
delayed operation such that an endpoint will become primed only after a SOF is received.
After the DCD writes the prime bit, the prime bit will be cleared as usual to indicate to
software that the device controller completed a priming the dTD for transfer. Internal to
the design, the device controller hardware masks that prime start until the next frame
boundary. This behavior is hidden from the DCD but occurs so that the device controller
can match the dTD to a specific (micro)frame.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3804
NXP Semiconductors

<!-- page 3805 -->

Another difference with isochronous endpoints is that the transaction must wholly
complete in a (micro)frame. Once an ISO transaction is started in a (micro)frame it will
retire the corresponding dTD when MULT transactions occur or the device controller
finds a fulfillment condition.
The transaction error bit set in the status field indicates a fulfillment error condition.
When a fulfillment error occurs, the frame after the transfer failed to complete wholly,
the device controller will force retire the ISO-dTD and move to the next ISO-dTD.
It is important to note that fulfillment errors are only caused due to partially completed
packets. If no activity occurs to a primed ISO-dTD, the transaction will stay primed
indefinitely. This means it is up to software discard transmit ISO-dTDs that pile up from
a failure of the host to move the data.
Finally, the last difference with ISO packets is in the data level error handling. When a
CRC error occurs on a received packet, the packet is not retried similar to bulk and
control endpoints. Instead, the CRC is noted by setting the Transaction Error bit and the
data is stored as usual for the application software to sort out.
• TX Packet Retired
• MULT counter reaches zero.
• Fulfillment Error [Transaction Error bit is set]
• # Packets Occurred > 0 AND # Packets Occurred < MULT
NOTE
For TX-ISO, MULT Counter can be loaded with a
lesser value in the dTD Multiplier Override field in
hardware versions 2.3 and later. If the Multiplier
Override is zero, the MULT Counter is initialized
to the Multiplier in the QH.
• RX Packet Retired:
• MULT counter reaches zero.
• Non-MDATA Data PID is received**
• ** Exit criteria only valid in hardware version 2.3 or later. Previous to
hardware version 2.3, any PID sequence that did not match the MULT field
exactly would be flagged as a transaction error due to PID mismatch or
fulfillment error.
• Overflow Error:
• Packet received is > maximum packet length. [Buffer Error bit is set]
• Packet received exceeds total bytes allocated in dTD. [Buffer Error bit is set]
• Fulfillment Error [Transaction Error bit is set]
• # Packets Occurred > 0 AND # Packets Occurred < MULT
• CRC Error [Transaction Error bit is set]
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3805

<!-- page 3806 -->

NOTE
For ISO, when a dTD is retired, the next dTD is primed for the
next frame. For continuous (micro)frame to (micro)frame
operation the DCD should ensure that the dTD linked-list is out
ahead of the device controller by at least two (micro)frames.
56.4.6.4.3.1
Isochronous Pipe Synchronization
When it is necessary to synchronize an isochronous data pipe to the host, the (micro)
frame number (USB_UOG_FRINDEX register) can be used as a marker.
To cause a packet transfer to occur at a specific (micro) frame number [N], the DCD
should interrupt on SOF during frame N-1. When the USB_UOG_FRINDEX=N-1, the
DCD must write the prime bit. The device controller will prime the isochronous endpoint
in (micro) frame N-1 so that the device controller will execute delivery during (micro)
frame N.
NOTE
Priming an endpoint towards the end of (micro) frame N-1 will
not guarantee delivery in (micro) frame N. The delivery may
actually occur in (micro) frame N+1 if device controller does
not have enough time to complete the prime before the SOF for
packet N is received.
56.4.6.4.3.2
Isochronous Endpoint Bus Response Matrix
The following table shows the response matrix for the Isochronous Endpoint Bus.
Table 56-71. Isochronous Endpoint Bus Response Matrix
Stall
Not Primed
Primed
Underflow
Overflow
Setup
STALL
STALL
STALL
N/A
N/A
In
NULL Packet
NULL Packet
Transmit
BS Error
N/A
Out
Ignore
Ignore
Receive
N/A
Drop Packet
Ping
Ignore
Ignore
Ignore
Ignore
Ignore
Invalid
Ignore
Ignore
Ignore
Ignore
Ignore
1. BS Error = Force Bit Stuff Error
NULL Packet = Zero Length Packet
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3806
NXP Semiconductors

<!-- page 3807 -->

56.4.6.5
Managing Queue Heads
The following figure shows the End Point Queue Head.
Endpoint QH 1 - Out
Endpoint QH 0 - In
Endpoint QH 0 - Out
Endpoint
Transfer
Descriptor
Up to
32 elements
ENDPOINTLISTADDR
Transfer
Buffer
Transfer
Buffer
Transfer
Buffer
Transfer
Buffer
Transfer Buffer Pointer
Transfer Buffer
Pointer
Transfer Buffer 
Pointer
Transfer Buffer 
Pointer
Figure 56-29. End Point Queue Head Diagram
The device queue head (dQH) points to the linked list of transfer tasks, each depicted by
the device Transfer Descriptor (dTD). An area of memory pointed to by
USB.ENDPOINTLISTADDR contains a group of all dQH's in a sequential list as shown
in Figure 56-29. The even elements in the list of dQH's are used for receive endpoints
(OUT/SETUP) and the odd elements are used for transmit endpoints (IN/INTERRUPT).
Device transfer descriptors are linked head to tail starting at the queue head and ending at
a terminate bit. Once the dTD has been retired, it will no longer be part of the linked list
from the queue head. Therefore, software is required to track all transfer descriptors
because pointers will no longer exist within the queue head once the dTD is retired (see
section Software Link Pointers).
In addition to the current and next pointers and the dTD overlay examined in section
Operational Model For Packet Transfers, the dQH also contains the following parameters
for the associated endpoint: Multipler, Maximum Packet Length, Interrupt On Setup. The
complete initialization of the dQH including these fields is demonstrated in the next
section.
56.4.6.5.1
Queue Head Initialization
One device queue head must be initialized for each active endpoint.
To initialize a device queue head:
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3807

<!-- page 3808 -->

• Write the wMaxPacketSize field as required by the USB Chapter 9 or application
specific protocol.
• Write the multiplier field to 0 for control, bulk, and interrupt endpoints. For ISO
endpoints, set the multiplier to 1,2, or 3 as required bandwidth and in conjunction
with the USB Chapter 9 protocol.
NOTE
In FS mode, the multiplier field can only be 1 for ISO
endpoints.
• Write the next dTD Terminate bit field to 1.
• Write the Active bit in the status field to 0.
• Write the Halt bit in the status field to 0.
NOTE
The DCD must only modify dQH if the associated endpoint is
not primed and there are no outstanding dTD's.
56.4.6.5.2
Operational Model For Setup Transfers
As discussed in section Control Endpoint Operation Model, setup transfer requires
special treatment by the DCD. A setup transfer does not use a dTD but instead stores the
incoming data from a setup packet in an 8-byte buffer within the dQH.
Upon receiving notification of the setup packet, the DCD should handle the setup transfer
as demonstrated here:
1. Copy setup buffer contents from dQH - RX to software buffer.
2. Acknowledge setup backup by writing a "1" to the corresponding bit in
ENDPTSETUPSTAT.
NOTE
• The acknowledge must occur before continuing to
process the setup packet.
• After the acknowledge has occurred, the DCD must not
attempt to access the setup buffer in the dQH - RX.
Only the local software copy should be examined.
3. Check for pending data or status dTD's from previous control transfers and flush if
any exist as discussed in section Flushing/De-priming an Endpoint.
4. Decode setup packet and prepare data phase [optional] and status phase transfer as
required by the USB Chapter 9 or application specific protocol.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3808
NXP Semiconductors

<!-- page 3809 -->

NOTE
It is possible for the device controller to receive setup packets
before previous control transfers complete. Existing control
packets in progress must be flushed and the new control packet
completed.
56.4.6.6
Managing Transfers with Transfer Descriptors
56.4.6.6.1
Software Link Pointers
It is necessary for the DCD software to maintain head and tail pointers to the for the
linked list of dTDs for each respective queue head.
This is necessary because the dQH only maintains pointers to the current working dTD
and the next dTD to be executed. The operations described in next section for managing
dTD will assume the DCD can use reference the head and tail of the dTD linked list. The
following figure shows the Software Link Pointers.
Completed dTDs
Queued dTDs
Endpoint
QH
current
next
Tail Pointer
Head Pointer
Figure 56-30. Software Link Pointers
NOTE
To conserve memory, the reserved fields at the end of the dQH
can be used to store the Head & Tail pointers, but it still
remains the responsibility of the DCD to maintain the pointers.
56.4.6.6.2
Building a Transfer Descriptor
Before a transfer can be executed from the linked list, a dTD must be built to describe the
transfer.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3809

<!-- page 3810 -->

Use the following procedure for building dTDs.
Allocate 8-DWord dTD block of memory aligned to 8-DWord boundaries. Example: bit
address 4:0 would be equal to "00000"
Write the following fields:
1. Initialize first 7 DWords to 0.
2. Set the terminate bit to 1.
3. Fill in total bytes with transfer size.
4. Set the interrupt on complete if desired.
5. Initialize the status field with the active bit set to 1 and all remaining status bits set to
0.
6. Fill in buffer pointer page 0 and the current offset to point to the start of the data
buffer.
7. Initialize buffer pointer page 1 through page 4 to be one greater than each of the
previous buffer pointer.
56.4.6.6.3
Executing A Transfer Descriptor
To safely add a dTD, the DCD must be follow this procedure which will handle the event
where the device controller reaches the end of the dTD list at the same time a new dTD is
being added to the end of the list.
Determine whether the link list is empty: Check DCD driver to see if pipe is empty
(internal representation of linked-list should indicate if any packets are outstanding).
• Case 1: Link list is empty
a. Write dQH next pointer AND dQH terminate bit to 0 as a single DWord
operation.
b. Clear active & halt bit in dQH (in case set from a previous error).
c. Prime endpoint by writing 1 to correct bit position in Endpoint Prime
(USB_nENDPTPRIME).
• Case 2: Link list is not empty
a. Add dTD to end of linked list.
b. Read correct prime bit in Endpoint Prime (USB_nENDPTPRIME)- if 1 DONE.
c. Set ATDTW bit in USBCMD register to 1.
d. Read correct status bit in Endpoint Status (USB_nENDPTSTAT). (store in tmp.
variable for later)
e. Read ATDTW bit in USBCMD register.
• If 0 goto 3.
• If 1 continue to 6.
f. Write ATDTW bit in USBCMD register to 0.
g. If status bit read in (3) is 1 DONE.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3810
NXP Semiconductors

<!-- page 3811 -->

h. If status bit read in (3) is 0 then Goto Case 1: Step 1.
56.4.6.6.4
Transfer Completion
After a dTD has been initialized and the associated endpoint primed the device controller
will execute the transfer upon the host-initiated request. The DCD will be notified with a
USB interrupt if the Interrupt On Complete bit was set or alternately, the DCD can poll
the endpoint complete register to find when the dTD had been executed. After a dTD has
been executed, DCD can check the status bits to determine success or failure.
NOTE
Multiple dTD can be completed in a single endpoint complete
notification. After clearing the notification, DCD must search
the dTD linked list and retire all dTDs that have finished
(Active bit cleared).
By reading the status fields of the completed dTDs, the DCD can determine if the
transfers completed successfully. Success is determined with the following combination
of status bits:
• Active = 0
• Halted = 0
• Transaction Error = 0
• Data Buffer Error = 0
Should any combination other than the one shown above exist, the DCD must take proper
action. Transfer failure mechanisms are indicated in the Device Error Matrix.
In addition to checking the status bit the DCD must read the Transfer Bytes field to
determine the actual bytes transferred. When a transfer is complete, the Total Bytes
transferred is by decremented by the actual bytes transferred. For Transmit packets, a
packet is only complete after the actual bytes reaches zero, but for receive packets, the
host may send fewer bytes in the transfer according the USB variable length packet
protocol.
56.4.6.6.5
Flushing/De-priming an Endpoint
It is necessary for the DCD to flush to de-prime one more endpoints on a USB device
reset or during a broken control transfer.
There may also be application specific requirements to stop transfers in progress. The
following procedure can be used by the DCD to stop a transfer in progress:
1. Write a '1' to the corresponding bit(s) in Endpoint Flush (USB_nENDPTFLUSH).
2. Wait until all bits in Endpoint Flush (USB_nENDPTFLUSH) are '0'.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3811

<!-- page 3812 -->

• Software note: this operation may take a large amount of time depending on the
USB bus activity. It is not desirable to have this wait loop within an interrupt
service routine.
3. Read Endpoint Status (USB_nENDPTSTAT) to ensure that for all endpoints
commanded to be flushed, that the corresponding bits are now '0'. If the
corresponding bits are '1' after step #2 has finished, then the flush failed as described
in the following:
• Explanation: In very rare cases, a packet is in progress to the particular endpoint
when commanded flush using Endpoint Flush (USB_nENDPTFLUSH). A
safeguard is in place to refuse the flush to ensure that the packet in progress
completes successfully. The DCD may need to repeatedly flush any endpoints
that fail to flush be repeating steps 1-3 until each endpoint is successfully
flushed.
56.4.6.6.6
Device Error Matrix
The following table summarizes packet errors that are not automatically handled by the
Device Controller.
Table 56-72. Device Error Matrix
Error
Direction
Packet Type Data Buffer Error Bit
Transaction Error Bit
Overflow **
RX
Any
1
0
ISO Packet Error
RX
ISO
0
1
ISO Fulfillment Error
Both
ISO
0
1
Notice that the device controller handles all errors on Bulk/Control/Interrupt Endpoints
except for a data buffer overflow. However, for ISO endpoints, errors packets are not
retried and errors are tagged as indicated. The table below describes the errors.
Table 56-73. Error Descriptions
Error
Description
Overflow
Number of bytes received exceeded max. packet size or total buffer length.
** This error will also set the Halt bit in the dQH and if there are dTDs remaining in the linked
list for the endpoint, then those will not be executed.
ISO Packet Error
CRC Error on received ISO packet. Contents not guaranteed to be correct.
ISO Fulfillment Error
Host failed to complete the number of packets defined in the dQH mult field within the given
(micro)frame. For scheduled data delivery the DCD may need to readjust the data queue
because a fulfillment error will cause Device Controller to cease data transfers on the pipe for
one (micro)frame. During the "dead" (micro)frame, the Device Controller reports error on the
pipe and primes for the following frame.
USB Operation Model
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3812
NXP Semiconductors

<!-- page 3813 -->

56.4.6.7
Servicing Interrupts
The interrupt service routine must consider that there are high-frequency, low-frequency
operations, and error operations and order accordingly.
56.4.6.7.1
High-Frequency Interrupts
High frequency interrupts in particular should be handled in the order below. The most
important of these is listed first because the DCD must acknowledge a setup buffer in the
timeliest manner possible.
The table below describes the High frequency interrupt events.
Table 56-74. High Frequency Interrupt Events
Execution Order
Interrupt
Action
1a
USB Interrupt -
USB.ENDPTSETUPSTATUS
Copy contents of setup buffer and acknowledge setup packet
(as indicated in Figure 56-29 shows the End Point Queue
Head). Process setup packet according to USB 2.0 Chapter 9
or application specific protocol.
1b
USB Interrupt1 - USB.ENDPTCOMPLETE
Handle completion of dTD as indicated in Figure 56-29 shows
the End Point Queue Head.
2
SOF Interrupt
Action as deemed necessary by application. This interrupt may
not have a use in all applications.
1.
It is likely that multiple interrupts to stack up on any call to the Interrupt Service Routine AND during the Interrupt Service
Routine.
56.4.6.7.2
Low-Frequency Interrupts
The low frequency interrupts can be handled in any order because they do not occur often
in comparison to the high-frequency interrupts.
The table below shows the Low frequency interrupt events.
Table 56-75. Low Frequency Interrupt Events
Interrupt
Action
Port Change
Change software state information.
Sleep Enable (Suspend)
Change software state information. Low power handling as necessary.
Reset Received
Change software state information. Abort pending transfers.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3813

<!-- page 3814 -->

56.4.6.7.3
Error Interrupts
Error interrupts will be least frequent and should be placed last in the interrupt service
routine.
The following table shows the error interrput events.
Table 56-76. Error Interrupt Events
Interrupt
Action
USB Error Interrupt
This error is redundant because it combines USB Interrupt and an error status in the
dTD. The DCD will more aptly handle packet-level errors by checking dTD status field
upon receipt of USB Interrupt (w/ USB.ENDPTCOMPLETE).
System Error
Unrecoverable error. Immediate Reset of core; free transfers buffers in progress and
restart the DCD.
56.5
USB Non-Core Memory Map/Register Definition
There are two kinds of registers in the USB module: USB core registers and USB non-
core registers.
USB core registers are used to control USB core functions, and more independent of
USB features. Each USB controller core has its own core registers.
USB non-core registera are additional to USB core registers, and more dependent on
USB features. i.MX series products vary in non-core registers.
This section describes only the USB non-core registers. For detailed descriptions of USB
core registers, please refer to Register Interface .
NOTE
• For reserved bits, please preserve the value when writing
(read its reset value, then write this value back)
• "USB_UOG1_", "USB_UOG2_" prefix in register name
indicates it is a core register for OTG1/OTG2 controller
core respectively.
• USBNC_USB_" prefix in register name indicates it is a
USB non-core register.
USB Non-Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3814
NXP Semiconductors

<!-- page 3815 -->

USBNC memory map
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
218_4800
USB OTG1 Control Register (USBNC_USB_OTG1_CTRL)
32
R/W
3000_1000h
56.5.1/3816
218_4804
USB OTG2 Control Register (USBNC_USB_OTG2_CTRL)
32
R/W
3000_1000h
56.5.2/3819
218_4818
OTG1 UTMI PHY Control 0 Register
(USBNC_USB_OTG1_PHY_CTRL_0)
32
R/W
8000_0000h
56.5.3/3822
218_481C
OTG2 UTMI PHY Control 0 Register
(USBNC_USB_OTG2_PHY_CTRL_0)
32
R/W
8000_0098h
56.5.4/3823
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3815

<!-- page 3816 -->

56.5.1
USB OTG1 Control Register (USBNC_USB_OTG1_CTRL)
The USB OTG1 control register controls the integration specific features of the USB
OTG1 module. These features are not directly related to the USB functionality, but
control special features, interfacing on the USB ports, as well as power control and wake-
up functionality.
Address: 218_4000h base + 800h offset = 218_4800h
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
WIR
Reserved
WKUP_DPDM_EN
Reserved
WKUP_VBUS_EN
WKUP_ID_EN
W
Reset
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
0
0
0
0
0
0
USB Non-Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3816
NXP Semiconductors

<!-- page 3817 -->

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
WKUP_SW
WKUP_SW_EN
Reserved
WIE
PWR_POL
OVER_CUR_POL
OVER_CUR_DIS
Reserved
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
USBNC_USB_OTG1_CTRL field descriptions
Field
Description
31
WIR
OTG1 Wake-up Interrupt Request
This bit indicates that a wake-up interrupt request is received on the OTG1 port. This bit is cleared by
disabling the wake-up interrupt (clearing bit "OWIE").
1
Wake-up Interrupt Request received
0
No wake-up interrupt request received
30
-
This field is reserved.
Reserved
29
WKUP_DPDM_
EN
Wake-up on DPDM change enable
1
(Default) DPDM changes wake-up to be enabled, it is for device only.
0
DPDM changes wake-up to be disabled only when VBUS is 0.
28–18
-
This field is reserved.
Reserved
17
WKUP_VBUS_
EN
OTG1 wake-up on VBUS change enable
1
Enable
0
Disable
16
WKUP_ID_EN
OTG1 Wake-up on ID change enable
1
Enable
0
Disable
15
WKUP_SW
OTG1 Software Wake-up
1
Force wake-up
0
Inactive
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3817

<!-- page 3818 -->

USBNC_USB_OTG1_CTRL field descriptions (continued)
Field
Description
14
WKUP_SW_EN
OTG1 Software Wake-up Enable
1
Enable
0
Disable
13–11
-
This field is reserved.
Reserved
10
WIE
OTG1 Wake-up Interrupt Enable
This bit enables or disables the OTG1 wake-up interrupt. Disabling the interrupt also clears the Interrupt
request bit. Wake-up interrupt enable should be turned off after receiving a wake-up interrupt and turned
on again prior to going in suspend mode
1
Interrupt Enabled
0
Interrupt Disabled
9
PWR_POL
OTG1 Power Polarity
This bit should be set according to PMIC Power Pin polarity.
1
PMIC Power Pin is High active.
0
PMIC Power Pin is Low active.
8
OVER_CUR_
POL
OTG1 Polarity of Overcurrent
The polarity of OTG1 port overcurrent event
1
Low active (low on this signal represents an overcurrent condition)
0
High active (high on this signal represents an overcurrent condition)
7
OVER_CUR_DIS
Disable OTG1 Overcurrent Detection
1
Disables overcurrent detection
0
Enables overcurrent detection
-
This field is reserved.
Reserved
USB Non-Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3818
NXP Semiconductors

<!-- page 3819 -->

56.5.2
USB OTG2 Control Register (USBNC_USB_OTG2_CTRL)
The USB OTG2 control register controls the integration specific features of the USB
OTG2 module. These features are not directly related to the USB functionality, but
control special features, interfacing on the USB ports, as well as power control and wake-
up functionality.
Address: 218_4000h base + 804h offset = 218_4804h
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
WIR
Reserved
WKUP_DPDM_EN
Reserved
WKUP_VBUS_EN
WKUP_ID_EN
W
Reset
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
0
0
0
0
0
0
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3819

<!-- page 3820 -->

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
WKUP_SW
WKUP_SW_EN
Reserved
WIE
PWR_POL
OVER_CUR_POL
OVER_CUR_DIS
Reserved
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
USBNC_USB_OTG2_CTRL field descriptions
Field
Description
31
WIR
OTG2 Wake-up Interrupt Request
This bit indicates that a wake-up interrupt request is received on the OTG port. This bit is cleared by
disabling the wake-up interrupt (clearing bit "OWIE").
1
Wake-up Interrupt Request received
0
No wake-up interrupt request received
30
-
This field is reserved.
Reserved
29
WKUP_DPDM_
EN
Wake-up on DPDM change enable
1
(Default) DPDM changes wake-up to be enabled, it is for device only.
0
DPDM changes wake-up to be disabled only when VBUS is 0.
28–18
-
This field is reserved.
Reserved
17
WKUP_VBUS_
EN
OTG2 wake-up on VBUS change enable
1
Enable
0
Disable
16
WKUP_ID_EN
OTG2 Wake-up on ID change enable
1
Enable
0
Disable
15
WKUP_SW
OTG2 Software Wake-up
1
Force wake-up
0
Inactive
Table continues on the next page...
USB Non-Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3820
NXP Semiconductors

<!-- page 3821 -->

USBNC_USB_OTG2_CTRL field descriptions (continued)
Field
Description
14
WKUP_SW_EN
OTG2 Software Wake-up Enable
1
Enable
0
Disable
13–11
-
This field is reserved.
Reserved
10
WIE
OTG2 Wake-up Interrupt Enable
This bit enables or disables the OTG2 wake-up interrupt. Disabling the interrupt also clears the Interrupt
request bit. Wake-up interrupt enable should be turned off after receiving a wake-up interrupt and turned
on again prior to going in suspend mode
1
Interrupt Enabled
0
Interrupt Disabled
9
PWR_POL
OTG2 Power Polarity
This bit should be set according to PMIC Power Pin polarity.
1
PMIC Power Pin is High active.
0
PMIC Power Pin is Low active.
8
OVER_CUR_
POL
OTG2 Polarity of Overcurrent
The polarity of OTG2 port overcurrent event
1
Low active (low on this signal represents an overcurrent condition)
0
High active (high on this signal represents an overcurrent condition)
7
OVER_CUR_DIS
Disable OTG2 Overcurrent Detection
1
Disables overcurrent detection
0
Enables overcurrent detection
-
This field is reserved.
Reserved
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3821

<!-- page 3822 -->

56.5.3
OTG1 UTMI PHY Control 0 Register
(USBNC_USB_OTG1_PHY_CTRL_0)
USB OTG1 UTMI PHY control register 0 is used to control the on-chip OTG1 UTMI
PHY.
Address: 218_4000h base + 818h offset = 218_4818h
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
UTMI_CLK_
VLD
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
0
0
0
0
USBNC_USB_OTG1_PHY_CTRL_0 field descriptions
Field
Description
31
UTMI_CLK_VLD
Indicating whether OTG1 UTMI PHY clock is valid
1
Valid
0
Invalid
30–3
-
This field is reserved.
Reserved
-
This field is reserved.
Reserved
USB Non-Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3822
NXP Semiconductors

<!-- page 3823 -->

56.5.4
OTG2 UTMI PHY Control 0 Register
(USBNC_USB_OTG2_PHY_CTRL_0)
USB OTG2 UTMI PHY Control Register 0 are used to control the on-chip OTG2 UTMI
PHY.
Address: 218_4000h base + 81Ch offset = 218_481Ch
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
UTMI_CLK_
VLD
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
1
0
0
1
1
0
0
0
USBNC_USB_OTG2_PHY_CTRL_0 field descriptions
Field
Description
31
UTMI_CLK_VLD
Indicating whether OTG2 UTMI PHY clock is valid
1
Valid
0
Invalid
30–3
-
This field is reserved.
Reserved
-
This field is reserved.
Reserved
56.6
USB Core Memory Map/Register Definition
USB memory map
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
218_4000
Identification register (USB_UOG1_ID)
32
R
E4A1_FA05h
56.6.1/3828
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3823

<!-- page 3824 -->

USB memory map (continued)
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
218_4004
Hardware General (USB_UOG1_HWGENERAL)
32
R
0000_0035h
56.6.2/3828
218_4008
Host Hardware Parameters (USB_UOG1_HWHOST)
32
R
1002_0001h
56.6.3/3830
218_400C
Device Hardware Parameters (USB_UOG1_HWDEVICE)
32
R
0000_0011h
56.6.4/3831
218_4010
TX Buffer Hardware Parameters (USB_UOG1_HWTXBUF)
32
R
8008_0B08h
56.6.5/3831
218_4014
RX Buffer Hardware Parameters (USB_UOG1_HWRXBUF)
32
R
0000_0808h
56.6.6/3832
218_4080
General Purpose Timer #0 Load
(USB_UOG1_GPTIMER0LD)
32
R/W
0000_0000h
56.6.7/3833
218_4084
General Purpose Timer #0 Controller
(USB_UOG1_GPTIMER0CTRL)
32
R/W
0000_0000h
56.6.8/3833
218_4088
General Purpose Timer #1 Load
(USB_UOG1_GPTIMER1LD)
32
R/W
0000_0000h
56.6.9/3835
218_408C
General Purpose Timer #1 Controller
(USB_UOG1_GPTIMER1CTRL)
32
R/W
0000_0000h
56.6.10/
3835
218_4090
System Bus Config (USB_UOG1_SBUSCFG)
32
R/W
0000_0002h
56.6.11/
3836
218_4100
Capability Registers Length (USB_UOG1_CAPLENGTH)
8
R
40h
56.6.12/
3837
218_4102
Host Controller Interface Version
(USB_UOG1_HCIVERSION)
16
R
0100h
56.6.13/
3838
218_4104
Host Controller Structural Parameters
(USB_UOG1_HCSPARAMS)
32
R
0001_0011h
56.6.14/
3838
218_4108
Host Controller Capability Parameters
(USB_UOG1_HCCPARAMS)
32
R
0000_0006h
56.6.15/
3840
218_4120
Device Controller Interface Version
(USB_UOG1_DCIVERSION)
16
R
0001h
56.6.16/
3842
218_4124
Device Controller Capability Parameters
(USB_UOG1_DCCPARAMS)
32
R
0000_0188h
56.6.17/
3843
218_4140
USB Command Register (USB_UOG1_USBCMD)
32
R/W
0008_0000h
56.6.18/
3844
218_4144
USB Status Register (USB_UOG1_USBSTS)
32
R/W
0000_0000h
56.6.19/
3848
218_4148
Interrupt Enable Register (USB_UOG1_USBINTR)
32
R/W
0000_0000h
56.6.20/
3852
218_414C
USB Frame Index (USB_UOG1_FRINDEX)
32
R/W
0000_0000h
56.6.21/
3854
218_4154
Frame List Base Address
(USB_UOG1_PERIODICLISTBASE)
32
R/W
0000_0000h
56.6.22/
3855
218_4154
Device Address (USB_UOG1_DEVICEADDR)
32
R/W
0000_0000h
56.6.23/
3855
218_4158
Next Asynch. Address (USB_UOG1_ASYNCLISTADDR)
32
R/W
0000_0000h
56.6.24/
3856
218_4158
Endpoint List Address (USB_UOG1_ENDPTLISTADDR)
32
R/W
0000_0000h
56.6.25/
3857
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3824
NXP Semiconductors

<!-- page 3825 -->

USB memory map (continued)
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
218_4160
Programmable Burst Size (USB_UOG1_BURSTSIZE)
32
R/W
0000_0808h
56.6.26/
3857
218_4164
TX FIFO Fill Tuning (USB_UOG1_TXFILLTUNING)
32
R/W
000A_0000h
56.6.27/
3858
218_4178
Endpoint NAK (USB_UOG1_ENDPTNAK)
32
R/W
0000_0000h
56.6.28/
3860
218_417C
Endpoint NAK Enable (USB_UOG1_ENDPTNAKEN)
32
R/W
0000_0000h
56.6.29/
3860
218_4180
Configure Flag Register (USB_UOG1_CONFIGFLAG)
32
R/W
0000_0001h
56.6.30/
3861
218_4184
Port Status & Control (USB_UOG1_PORTSC1)
32
R/W
1000_0000h
56.6.31/
3861
218_41A4
On-The-Go Status & control (USB_UOG1_OTGSC)
32
R/W
0000_1120h
56.6.32/
3868
218_41A8
USB Device Mode (USB_UOG1_USBMODE)
32
R/W
0000_5000h
56.6.33/
3872
218_41AC
Endpoint Setup Status (USB_UOG1_ENDPTSETUPSTAT)
32
R/W
0000_0000h
56.6.34/
3873
218_41B0
Endpoint Prime (USB_UOG1_ENDPTPRIME)
32
R/W
0000_0000h
56.6.35/
3874
218_41B4
Endpoint Flush (USB_UOG1_ENDPTFLUSH)
32
R/W
0000_0000h
56.6.36/
3875
218_41B8
Endpoint Status (USB_UOG1_ENDPTSTAT)
32
R
0000_0000h
56.6.37/
3875
218_41BC
Endpoint Complete (USB_UOG1_ENDPTCOMPLETE)
32
R/W
0000_0000h
56.6.38/
3876
218_41C0
Endpoint Control0 (USB_UOG1_ENDPTCTRL0)
32
R/W
0080_0080h
56.6.39/
3877
218_41C4
Endpoint Control 1 (USB_UOG1_ENDPTCTRL1)
32
R/W
0000_0000h
56.6.40/
3879
218_41C8
Endpoint Control 2 (USB_UOG1_ENDPTCTRL2)
32
R/W
0000_0000h
56.6.41/
3882
218_41CC
Endpoint Control 3 (USB_UOG1_ENDPTCTRL3)
32
R/W
0000_0000h
56.6.42/
3884
218_41D0
Endpoint Control 4 (USB_UOG1_ENDPTCTRL4)
32
R/W
0000_0000h
56.6.43/
3887
218_41D4
Endpoint Control 5 (USB_UOG1_ENDPTCTRL5)
32
R/W
0000_0000h
56.6.44/
3890
218_41D8
Endpoint Control 6 (USB_UOG1_ENDPTCTRL6)
32
R/W
0000_0000h
56.6.45/
3893
218_41DC
Endpoint Control 7 (USB_UOG1_ENDPTCTRL7)
32
R/W
0000_0000h
56.6.46/
3896
218_4200
Identification register (USB_UOG2_ID)
32
R
E4A1_FA05h
56.6.1/3828
218_4204
Hardware General (USB_UOG2_HWGENERAL)
32
R
0000_0035h
56.6.2/3828
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3825

<!-- page 3826 -->

USB memory map (continued)
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
218_4208
Host Hardware Parameters (USB_UOG2_HWHOST)
32
R
1002_0001h
56.6.3/3830
218_420C
Device Hardware Parameters (USB_UOG2_HWDEVICE)
32
R
0000_0011h
56.6.4/3831
218_4210
TX Buffer Hardware Parameters (USB_UOG2_HWTXBUF)
32
R
8008_0B08h
56.6.5/3831
218_4214
RX Buffer Hardware Parameters (USB_UOG2_HWRXBUF)
32
R
0000_0808h
56.6.6/3832
218_4280
General Purpose Timer #0 Load
(USB_UOG2_GPTIMER0LD)
32
R/W
0000_0000h
56.6.7/3833
218_4284
General Purpose Timer #0 Controller
(USB_UOG2_GPTIMER0CTRL)
32
R/W
0000_0000h
56.6.8/3833
218_4288
General Purpose Timer #1 Load
(USB_UOG2_GPTIMER1LD)
32
R/W
0000_0000h
56.6.9/3835
218_428C
General Purpose Timer #1 Controller
(USB_UOG2_GPTIMER1CTRL)
32
R/W
0000_0000h
56.6.10/
3835
218_4290
System Bus Config (USB_UOG2_SBUSCFG)
32
R/W
0000_0002h
56.6.11/
3836
218_4300
Capability Registers Length (USB_UOG2_CAPLENGTH)
8
R
40h
56.6.12/
3837
218_4302
Host Controller Interface Version
(USB_UOG2_HCIVERSION)
16
R
0100h
56.6.13/
3838
218_4304
Host Controller Structural Parameters
(USB_UOG2_HCSPARAMS)
32
R
0001_0011h
56.6.14/
3838
218_4308
Host Controller Capability Parameters
(USB_UOG2_HCCPARAMS)
32
R
0000_0006h
56.6.15/
3840
218_4320
Device Controller Interface Version
(USB_UOG2_DCIVERSION)
16
R
0001h
56.6.16/
3842
218_4324
Device Controller Capability Parameters
(USB_UOG2_DCCPARAMS)
32
R
0000_0188h
56.6.17/
3843
218_4340
USB Command Register (USB_UOG2_USBCMD)
32
R/W
0008_0000h
56.6.18/
3844
218_4344
USB Status Register (USB_UOG2_USBSTS)
32
R/W
0000_0000h
56.6.19/
3848
218_4348
Interrupt Enable Register (USB_UOG2_USBINTR)
32
R/W
0000_0000h
56.6.20/
3852
218_434C
USB Frame Index (USB_UOG2_FRINDEX)
32
R/W
0000_0000h
56.6.21/
3854
218_4354
Frame List Base Address
(USB_UOG2_PERIODICLISTBASE)
32
R/W
0000_0000h
56.6.22/
3855
218_4354
Device Address (USB_UOG2_DEVICEADDR)
32
R/W
0000_0000h
56.6.23/
3855
218_4358
Next Asynch. Address (USB_UOG2_ASYNCLISTADDR)
32
R/W
0000_0000h
56.6.24/
3856
218_4358
Endpoint List Address (USB_UOG2_ENDPTLISTADDR)
32
R/W
0000_0000h
56.6.25/
3857
218_4360
Programmable Burst Size (USB_UOG2_BURSTSIZE)
32
R/W
0000_0808h
56.6.26/
3857
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3826
NXP Semiconductors

<!-- page 3827 -->

USB memory map (continued)
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
218_4364
TX FIFO Fill Tuning (USB_UOG2_TXFILLTUNING)
32
R/W
000A_0000h
56.6.27/
3858
218_4378
Endpoint NAK (USB_UOG2_ENDPTNAK)
32
R/W
0000_0000h
56.6.28/
3860
218_437C
Endpoint NAK Enable (USB_UOG2_ENDPTNAKEN)
32
R/W
0000_0000h
56.6.29/
3860
218_4380
Configure Flag Register (USB_UOG2_CONFIGFLAG)
32
R/W
0000_0001h
56.6.30/
3861
218_4384
Port Status & Control (USB_UOG2_PORTSC1)
32
R/W
1000_0000h
56.6.31/
3861
218_43A4
On-The-Go Status & control (USB_UOG2_OTGSC)
32
R/W
0000_1120h
56.6.32/
3868
218_43A8
USB Device Mode (USB_UOG2_USBMODE)
32
R/W
0000_5000h
56.6.33/
3872
218_43AC
Endpoint Setup Status (USB_UOG2_ENDPTSETUPSTAT)
32
R/W
0000_0000h
56.6.34/
3873
218_43B0
Endpoint Prime (USB_UOG2_ENDPTPRIME)
32
R/W
0000_0000h
56.6.35/
3874
218_43B4
Endpoint Flush (USB_UOG2_ENDPTFLUSH)
32
R/W
0000_0000h
56.6.36/
3875
218_43B8
Endpoint Status (USB_UOG2_ENDPTSTAT)
32
R
0000_0000h
56.6.37/
3875
218_43BC
Endpoint Complete (USB_UOG2_ENDPTCOMPLETE)
32
R/W
0000_0000h
56.6.38/
3876
218_43C0
Endpoint Control0 (USB_UOG2_ENDPTCTRL0)
32
R/W
0080_0080h
56.6.39/
3877
218_43C4
Endpoint Control 1 (USB_UOG2_ENDPTCTRL1)
32
R/W
0000_0000h
56.6.40/
3879
218_43C8
Endpoint Control 2 (USB_UOG2_ENDPTCTRL2)
32
R/W
0000_0000h
56.6.41/
3882
218_43CC
Endpoint Control 3 (USB_UOG2_ENDPTCTRL3)
32
R/W
0000_0000h
56.6.42/
3884
218_43D0
Endpoint Control 4 (USB_UOG2_ENDPTCTRL4)
32
R/W
0000_0000h
56.6.43/
3887
218_43D4
Endpoint Control 5 (USB_UOG2_ENDPTCTRL5)
32
R/W
0000_0000h
56.6.44/
3890
218_43D8
Endpoint Control 6 (USB_UOG2_ENDPTCTRL6)
32
R/W
0000_0000h
56.6.45/
3893
218_43DC
Endpoint Control 7 (USB_UOG2_ENDPTCTRL7)
32
R/W
0000_0000h
56.6.46/
3896
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3827

<!-- page 3828 -->

56.6.1
Identification register (USB_nID)
The ID register identifies the USB 2.0 High-Speed core and its revision.
Address: 218_4000h base + 0h offset + (512d × i), where i=0d to 1d
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
REVISION
W
Reset
1
1
1
0
0
1
0
0
1
0
1
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
Reserved
NID
Reserved
ID
W
Reset
1
1
1
1
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
1
USB_nID field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–16
REVISION
Revision number of the controller core.
15–14
-
This field is reserved.
Reserved
13–8
NID
Complement version of ID
7–6
-
This field is reserved.
Reserved
ID
Configuration number.
This number is set to 0x05 and indicates that the peripheral is USB 2.0 High-Speed core.
56.6.2
Hardware General (USB_nHWGENERAL)
General hardware parameters as defined in System Level Issues and Core Configuration.
NOTE
The reset value could vary from instance to instance. Please see
the detail in bit field description and ignore reset value in
summary table in this case!
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3828
NXP Semiconductors

<!-- page 3829 -->

Address: 218_4000h base + 4h offset + (512d × i), where i=0d to 1d
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
SM
PHYM
PHYW
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
1
1
0
1
0
1
USB_nHWGENERAL field descriptions
Field
Description
31–11
-
This field is reserved.
Reserved
10–9
SM
Serial interface mode capability
00
No Serial Engine, always use parallel signalling.
01
Serial Engine present, always use serial signalling for FS/LS.
10
Software programmable - Reset to use parallel signalling for FS/LS
11
Software programmable - Reset to use serial signalling for FS/LS
8–6
PHYM
Transciever type
000
UTMI/UMTI+
001
ULPI DDR
010
ULPI
011
Serial Only
100
Software programmable - reset to UTMI/UTMI+
101
Software programmable - reset to ULPI DDR
110
Software programmable - reset to ULPI
111
Software programmable - reset to Serial
1000
IC-USB
1001
Software programmable - reset to IC-USB
1010
HSIC
1011
Software programmable - reset to HSIC
5–4
PHYW
Data width of the transciever connected to the controller core.
PHYW bit reset value is
00
8 bit wide data bus
Software non-programmable
01
16 bit wide data bus
Software non-programmable
10
Reset to 8 bit wide data bus
Software programmable
11
Reset to 16 bit wide data bus
Software programmable
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3829

<!-- page 3830 -->

USB_nHWGENERAL field descriptions (continued)
Field
Description
-
This field is reserved.
Reserved
56.6.3
Host Hardware Parameters (USB_nHWHOST)
Address: 218_4000h base + 8h offset + (512d × i), where i=0d to 1d
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
1
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
NPORT
HC
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
USB_nHWHOST field descriptions
Field
Description
31–4
-
This field is reserved.
Reserved
3–1
NPORT
The Nmber of downstream ports supported by the host controller is (NPORT+1).
NOTE: When these bits value is '000', it indicates a single-port host controller.
0
HC
Host Capable.
Indicating whether host operation mode is supported or not.
1
Supported
0
Not supported
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3830
NXP Semiconductors

<!-- page 3831 -->

56.6.4
Device Hardware Parameters (USB_nHWDEVICE)
Address: 218_4000h base + Ch offset + (512d × i), where i=0d to 1d
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
DEVEP
DC
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
1
0
0
0
1
USB_nHWDEVICE field descriptions
Field
Description
31–6
-
This field is reserved.
Reserved
5–1
DEVEP
Device Endpoint Number
0
DC
Device Capable.
Indicating whether device operation mode is supported or not.
1
Supported
0
Not supported
56.6.5
TX Buffer Hardware Parameters (USB_nHWTXBUF)
Address: 218_4000h base + 10h offset + (512d × i), where i=0d to 1d
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
TXCHANADD
Reserved
TXBURST
W
Reset 1
0
0
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
0
1
0
1
1
0
0
0
0
1
0
0
0
USB_nHWTXBUF field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–16
TXCHANADD
TX FIFO Buffer size is: (2^TXCHANADD) * 4 Bytes.
These bits are set to '08h', so buffer size is 256*4 Bytes.
For the OTG controller operating in device mode, this is the FIFO buffer size per endpoint. As the OTG
controller has 8 TX endpoint, there are 8 of these buffers.
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3831

<!-- page 3832 -->

USB_nHWTXBUF field descriptions (continued)
Field
Description
For the OTG controller operating in host mode, or for Host-only controller, the entire buffer memory is
used as a single TX buffer. Therefore, there is only 1 of this buffer
15–8
-
This field is reserved.
Reserved
TXBURST
Default burst size for memory to TX buffer transfer.
This is reset value of TXPBURST bits in USB core regsiter USB_n_BURSTSIZE.
Please see Programmable Burst Size (USB_nBURSTSIZE) .
56.6.6
RX Buffer Hardware Parameters (USB_nHWRXBUF)
Address: 218_4000h base + 14h offset + (512d × i), where i=0d to 1d
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
RXADD
RXBURST
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
1
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
USB_nHWRXBUF field descriptions
Field
Description
31–16
-
This field is reserved.
Reserved
15–8
RXADD
Buffer total size for all receive endpoints is (2^RXADD).
RX Buffer size is: (2^RXADD) * 4 Bytes.
These bits are set to '08h', so buffer size is 256*4 Bytes.
There is a single Receive FIFO buffer in the USB controller. The buffer is shared for all endpoints for the
OTG controller in device mode.
RXBURST
Default burst size for memory to RX buffer transfer.
This is reset value of RXPBURST bits in USB core regsiter USB_n_BURSTSIZE.
Please see Programmable Burst Size (USB_nBURSTSIZE) .
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3832
NXP Semiconductors

<!-- page 3833 -->

56.6.7
General Purpose Timer #0 Load (USB_nGPTIMER0LD)
This register controls load value of the count timer in register n_GPTIMER0CTRL.
Please see General Purpose Timer #0 Controller (USB_nGPTIMER0CTRL) .
Address: 218_4000h base + 80h offset + (512d × i), where i=0d to 1d
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
GPTLD
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
USB_nGPTIMER0LD field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
GPTLD
General Purpose Timer Load Value
These bit fields are loaded to GPTCNT bits when GPTRST bit is set '1b'.
This value represents the time in microseconds minus 1 for the timer duration.
Example: for a one millisecond timer, load 1000-1=999 or 0x0003E7.
NOTE: Max value is 0xFFFFFF or 16.777215 seconds.
56.6.8
General Purpose Timer #0 Controller
(USB_nGPTIMER0CTRL)
This register contains the control for this countdown timer and a data field can be queried
to determine the running count value. This timer has granularity on 1 us and can be
programmed to a little over 16 seconds. There are two counter modes which are
described in the register table below. When the timer counter value transitions to zero, an
interrupt could be generated if enable.
Interrupt status bit is TI0 bit in n_USBSTS register (See USB Status Register
(USB_nUSBSTS) ), interrupt enable bit is TIE0 bit in n_USBINTR register. (See
Interrupt Enable Register (USB_nUSBINTR) .)
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3833

<!-- page 3834 -->

Address: 218_4000h base + 84h offset + (512d × i), where i=0d to 1d
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
GPTRUN
GPTRST
Reserved
GPTMODE
GPTCNT
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
GPTCNT
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
USB_nGPTIMER0CTRL field descriptions
Field
Description
31
GPTRUN
General Purpose Timer Run
GPTCNT bits are not effected when setting or clearing this bit.
0
Stop counting
1
Run
30
GPTRST
General Purpose Timer Reset
0
No action
1
Load counter value from GPTLD bits in n_GPTIMER0LD
29–25
-
This field is reserved.
Reserved
24
GPTMODE
General Purpose Timer Mode
In one shot mode, the timer will count down to zero, generate an interrupt, and stop until the counter is
reset by software;
In repeat mode, the timer will count down to zero, generate an interrupt and automatically reload the
counter value from GPTLD bits to start again.
0
One Shot Mode
1
Repeat Mode
GPTCNT
General Purpose Timer Counter.
This field is the count value of the countdown timer.
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3834
NXP Semiconductors

<!-- page 3835 -->

56.6.9
General Purpose Timer #1 Load (USB_nGPTIMER1LD)
This register controls load value of the count timer in register n_GPTIMER1CTRL.
Please see General Purpose Timer #1 Controller (USB_nGPTIMER1CTRL) .
Address: 218_4000h base + 88h offset + (512d × i), where i=0d to 1d
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
GPTLD
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
USB_nGPTIMER1LD field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
GPTLD
General Purpose Timer Load Value
These bit fields are loaded to GPTCNT bits when GPTRST bit is set '1b'.
This value represents the time in microseconds minus 1 for the timer duration.
Example: for a one millisecond timer, load 1000-1=999 or 0x0003E7.
NOTE: Max value is 0xFFFFFF or 16.777215 seconds.
56.6.10
General Purpose Timer #1 Controller
(USB_nGPTIMER1CTRL)
This register contains the control for this countdown timer and a data field can be queried
to determine the running count value. This timer has granularity on 1 us and can be
programmed to a little over 16 seconds. There are two counter modes which are
described in the register table below. When the timer counter value transitions to zero, an
interrupt could be generated if enable.
Interrupt status bit is TI1 bit in USB_n_USBSTS register (See USB Status Register
(USB_nUSBSTS) ), interrupt enable bit is TIE1 bit in n_USBINTR register (See
Interrupt Enable Register (USB_nUSBINTR) ).
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3835

<!-- page 3836 -->

Address: 218_4000h base + 8Ch offset + (512d × i), where i=0d to 1d
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
GPTRUN
GPTRST
Reserved
GPTMODE
GPTCNT
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
GPTCNT
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
USB_nGPTIMER1CTRL field descriptions
Field
Description
31
GPTRUN
General Purpose Timer Run
GPTCNT bits are not effected when setting or clearing this bit.
0
Stop counting
1
Run
30
GPTRST
General Purpose Timer Reset
0
No action
1
Load counter value from GPTLD bits in USB_n_GPTIMER0LD
29–25
-
This field is reserved.
Reserved
24
GPTMODE
General Purpose Timer Mode
In one shot mode, the timer will count down to zero, generate an interrupt, and stop until the counter is
reset by software. In repeat mode, the timer will count down to zero, generate an interrupt and
automatically reload the counter value from GPTLD bits to start again.
0
One Shot Mode
1
Repeat Mode
GPTCNT
General Purpose Timer Counter.
This field is the count value of the countdown timer.
56.6.11
System Bus Config (USB_nSBUSCFG)
Address: 218_4000h base + 90h offset + (512d × i), where i=0d to 1d
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
AHBBRS
T
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
1
0
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3836
NXP Semiconductors

<!-- page 3837 -->

USB_nSBUSCFG field descriptions
Field
Description
31–3
-
This field is reserved.
Reserved
AHBBRST
AHB master interface Burst configuration
These bits control AHB master transfer type sequence (or priority).
NOTE: This register overrides n_BURSTSIZE register when its value is not zero.
000
Incremental burst of unspecified length only
001
INCR4 burst, then single transfer
010
INCR8 burst, INCR4 burst, then single transfer
011
INCR16 burst, INCR8 burst, INCR4 burst, then single transfer
100
Reserved, don't use
101
INCR4 burst, then incremental burst of unspecified length
110
INCR8 burst, INCR4 burst, then incremental burst of unspecified length
111
INCR16 burst, INCR8 burst, INCR4 burst, then incremental burst of unspecified length
56.6.12
Capability Registers Length (USB_nCAPLENGTH)
The Capability Registers Length register contains the address offset to the Operational
registers relative to the CAPLENGTH register.
Address: 218_4000h base + 100h offset + (512d × i), where i=0d to 1d
Bit
7
6
5
4
3
2
1
0
Read
CAPLENGTH
Write
Reset
0
1
0
0
0
0
0
0
USB_nCAPLENGTH field descriptions
Field
Description
CAPLENGTH
These bits are used as an offset to add to register base to find the beginning of the Operational Register.
Default value is '40h'.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3837

<!-- page 3838 -->

56.6.13
Host Controller Interface Version (USB_nHCIVERSION)
This is a 2-byte register containing a BCD encoding of the EHCI revision number
supported by this host controller. The most significant byte of this register represents a
major revision and the least significant byte is the minor revision.
Address: 218_4000h base + 102h offset + (512d × i), where i=0d to 1d
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
Read
HCIVERSION
Write
Reset
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
0
USB_nHCIVERSION field descriptions
Field
Description
HCIVERSION
Host Controller Interface Version Number
Default value is '10h', which means EHCI rev1.0.
56.6.14
Host Controller Structural Parameters
(USB_nHCSPARAMS)
The following figure shows the port steering logic capabilities of Host Control Structural
Parameters (n_HCSPARAMS).
Address: 218_4000h base + 104h offset + (512d × i), where i=0d to 1d
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
N_TT
N_PTT
Reserved
PI
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
N_CC
N_PCC
Reserved
PPC
N_PORTS
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
1
0
0
0
1
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3838
NXP Semiconductors

<!-- page 3839 -->

USB_nHCSPARAMS field descriptions
Field
Description
31–28
-
This field is reserved.
Reserved
27–24
N_TT
Number of Transaction Translators (N_TT). Default value '0000b'
This field indicates the number of embedded transaction translators associated with the USB2.0 host
controller.
These bits would be set to '0001b' for Multi-Port Host, and '0000b' for Single-Port Host.
23–20
N_PTT
Number of Ports per Transaction Translator (N_PTT). Default value '0000b'
This field indicates the number of ports assigned to each transaction translator within the USB2.0 host
controller.
These bits would be set to equal N_PORTS for Multi-Port Host, and '0000b' for Single-Port Host.
19–17
-
This field is reserved.
Reserved
16
PI
Port Indicators (P INDICATOR)
This bit indicates whether the ports support port indicator control. When set to one, the port status and
control registers include a read/writeable field for controlling the state of the port indicator
This bit is "1b" in all controller core.
15–12
N_CC
Number of Companion Controller (N_CC).
This field indicates the number of companion controllers associated with this USB2.0 host controller.
These bits are '0000b' in all controller core.
0
There is no internal Companion Controller and port-ownership hand-off is not supported.
1
There are internal companion controller(s) and port-ownership hand-offs is supported.
11–8
N_PCC
Number of Ports per Companion Controller
This field indicates the number of ports supported per internal Companion Controller. It is used to indicate
the port routing configuration to the system software.
For example, if N_PORTS has a value of 6 and N_CC has a value of 2 then N_PCC could have a value of
3. The convention is that the first N_PCC ports are assumed to be routed to companion controller 1, the
next N_PCC ports to companion controller 2, etc. In the previous example, the N_PCC could have been 4,
where the first 4 are routed to companion controller 1 and the last two are routed to companion controller
2. The number in this field must be consistent with N_PORTS and N_CC.
These bits are '0000b' in all controller core.
7–5
-
This field is reserved.
Reserved
4
PPC
Port Power Control
This field indicates whether the host controller implementation includes port power control. A one indicates
the ports have port power switches. A zero indicates the ports do not have port power switches. The value
of this field affects the functionality of the Port Power field in each port status and control register
N_PORTS
Number of downstream ports. This field specifies the number of physical downstream ports implemented
on this host controller. The value of this field determines how many port registers are addressable in the
Operational Register.
Valid values are in the range of 1h to Fh. A zero in this field is undefined.
These bits are always set to '0001b' because all controller cores are Single-Port Host.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3839

<!-- page 3840 -->

56.6.15
Host Controller Capability Parameters
(USB_nHCCPARAMS)
This register identifies multiple mode control (time-base bit functionality), addressing
capability.
Address: 218_4000h base + 108h offset + (512d × i), where i=0d to 1d
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
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3840
NXP Semiconductors

<!-- page 3841 -->

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
EECP
IST
Reserved
ASP
PFL
ADC
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
1
0
USB_nHCCPARAMS field descriptions
Field
Description
31–16
-
This field is reserved.
Reserved
15–8
EECP
EHCI Extended Capabilities Pointer.
This field indicates the existence of a capabilities list. A value of 00h indicates no extended capabilities are
implemented. A non-zero value in this register indicates the offset in PCI configuration space of the first
EHCI extended capability. The pointer value must be 40h or greater if implemented to maintain the
consistency of the PCI header defined for this class of device.
NOTE: These bits are set '00h' in all controller core.
7–4
IST
Isochronous Scheduling Threshold.
This field indicates, relative to the current position of the executing host controller, where software can
reliably update the isochronous schedule. When bit [7] is zero, the value of the least significant 3 bits
indicates the number of micro-frames a host controller can hold a set of isochronous data structures (one
or more) before flushing the state. When bit [7] is a one, then host software assumes the host controller
may cache an isochronous data structure for an entire frame.
These bits are set '00h' in all controller core.
3
-
This field is reserved.
Reserved
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3841

<!-- page 3842 -->

USB_nHCCPARAMS field descriptions (continued)
Field
Description
2
ASP
Asynchronous Schedule Park Capability
If this bit is set to a one, then the host controller supports the park feature for high-speed queue heads in
the Asynchronous Schedule. The feature can be disabled or enabled and set to a specific level by using
the Asynchronous Schedule Park Mode Enable and Asynchronous Schedule Park Mode Count fields in
the USBCMD register.
NOTE: ASP bit reset value: '00b' for OTG controller core, '11b' for Host-only controller core.
1
PFL
Programmable Frame List Flag
If this bit is set to zero, then the system software must use a frame list length of 1024 elements with this
host controller. The USBCMD register Frame List Size field is a read-only register and must be set to zero.
If set to a one, then the system software can specify and use a smaller frame list and configure the host
controller via the USBCMD register Frame List Size field. The frame list must always be aligned on a 4K-
page boundary. This requirement ensures that the frame list is always physically contiguous.
This bit is set '1b' in all controller core.
0
ADC
64-bit Addressing Capability
This bit is set '0b' in all controller core, no 64-bit addressing capability is supported.
56.6.16
Device Controller Interface Version (USB_nDCIVERSION)
This register indicates the two-byte BCD encoding of the device controller interface
version number.
Address: 218_4000h base + 120h offset + (512d × i), where i=0d to 1d
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
Read
DCIVERSION
Write
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
USB_nDCIVERSION field descriptions
Field
Description
DCIVERSION
Device Controller Interface Version Number
Default value is '01h', which means rev0.1.
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3842
NXP Semiconductors

<!-- page 3843 -->

56.6.17
Device Controller Capability Parameters
(USB_nDCCPARAMS)
These fields describe the overall device capability of the controller.
Address: 218_4000h base + 124h offset + (512d × i), where i=0d to 1d
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
HC
DC
Reserved
DEN
W
Reset
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
1
0
0
0
USB_nDCCPARAMS field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved
8
HC
Host Capable
When this bit is 1, this controller is capable of operating as an EHCI compatible USB 2.0 host controller.
7
DC
Device Capable
When this bit is 1, this controller is capable of operating as a USB 2.0 device.
6–5
-
This field is reserved.
Reserved
DEN
Device Endpoint Number
This field indicates the number of endpoints built into the device controller. If this controller is not device
capable, then this field will be zero. Valid values are 0 - 15.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3843

<!-- page 3844 -->

56.6.18
USB Command Register (USB_nUSBCMD)
The Command Register indicates the command to be executed by the serial bus host/
device controller. Writing to the register causes a command to be executed.
Address: 218_4000h base + 140h offset + (512d × i), where i=0d to 1d
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
ITC
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
FS_2
Reserved
SUTW
ATDTW
ASPE
Reserved
ASP
Reserved
IAA
ASE
PSE
FS_1
RST
RS
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
USB_nUSBCMD field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–16
ITC
Interrupt Threshold Control -Read/Write.
The system software uses this field to set the maximum rate at which the host/device controller will issue
interrupts. ITC contains the maximum interrupt interval measured in micro-frames. Valid values are shown
below.
Value Maximum Interrupt Interval
0x00
Immediate (no threshold)
0x01
1 micro-frame
0x02
2 micro-frames
0x04
4 micro-frames
0x08
8 micro-frames
0x10
16 micro-frames
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3844
NXP Semiconductors

<!-- page 3845 -->

USB_nUSBCMD field descriptions (continued)
Field
Description
0x20
32 micro-frames
0x40
64 micro-frames
15
FS_2
See also bits 3-2
Frame List Size - (Read/Write or Read Only). [host mode only]
This field is Read/Write only if Programmable Frame List Flag in the HCCPARAMS registers is set to one.
This field specifies the size of the frame list that controls which bits in the Frame Index Register should be
used for the Frame List Current index.
NOTE: This field is made up from USBCMD bits 15, 3 and 2.
Value Meaning
000
1024 elements (4096 bytes) Default value
001
512 elements (2048 bytes)
010
256 elements (1024 bytes)
011
128 elements (512 bytes)
100
64 elements (256 bytes)
101
32 elements (128 bytes)
110
16 elements (64 bytes)
111
8 elements (32 bytes)
14
-
This field is reserved.
Reserved
13
SUTW
Setup TripWire - Read/Write. [device mode only]
This bit is used as a semaphore to ensure that the setup data payload of 8 bytes is extracted from a QH
by the DCD without being corrupted. If the setup lockout mode is off (SLOM bit in USB core register
n_USBMODE, see USB Device Mode (USB_nUSBMODE) ) then there is a hazard when new setup data
arrives while the DCD is copying the setup data payload from the QH for a previous setup packet. This bit
is set and cleared by software.
This bit would also be cleared by hardware when a hazard detected.
12
ATDTW
Add dTD TripWire - Read/Write. [device mode only]
This bit is used as a semaphore to ensure proper addition of a new dTD to an active (primed) endpoint's
linked list. This bit is set and cleared by software.
This bit would also be cleared by hardware when state machine is hazard region for which adding a dTD
to a primed endpoint may go unrecognized.
11
ASPE
Asynchronous Schedule Park Mode Enable - Read/Write.
If the Asynchronous Park Capability bit in the HCCPARAMS register is a one, then this bit defaults to a 1h
and is R/W. Otherwise the bit must be a zero and is RO. Software uses this bit to enable or disable Park
mode. When this bit is one, Park mode is enabled. When this bit is a zero, Park mode is disabled.
NOTE: ASPE bit reset value: '0b' for OTG controller .
10
-
This field is reserved.
Reserved
9–8
ASP
Asynchronous Schedule Park Mode Count - Read/Write.
If the Asynchronous Park Capability bit in the HCCPARAMS register is a one, then this field defaults to 3h
and is R/W. Otherwise it defaults to zero and is Read-Only. It contains a count of the number of
successive transactions the host controller is allowed to execute from a high-speed queue head on the
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3845

<!-- page 3846 -->

USB_nUSBCMD field descriptions (continued)
Field
Description
Asynchronous schedule before continuing traversal of the Asynchronous schedule. Valid values are 1h to
3h. Software must not write a zero to this bit when Park Mode Enable is a one as this will result in
undefined behavior.
This field is set to 3h in all controller core.
7
-
This field is reserved.
Reserved
6
IAA
Interrupt on Async Advance Doorbell - Read/Write.
This bit is used as a doorbell by software to tell the host controller to issue an interrupt the next time it
advances asynchronous schedule. Software must write a 1 to this bit to ring the doorbell.
When the host controller has evicted all appropriate cached schedule states, it sets the Interrupt on Async
Advance status bit in the USBSTS register. If the Interrupt on Sync Advance Enable bit in the USBINTR
register is one, then the host controller will assert an interrupt at the next interrupt threshold.
The host controller sets this bit to zero after it has set the Interrupt on Sync Advance status bit in the
USBSTS register to one. Software should not write a one to this bit when the asynchronous schedule is
inactive. Doing so will yield undefined results.
This bit is only used in host mode. Writing a one to this bit when device mode is selected will have
undefined results.
5
ASE
Asynchronous Schedule Enable - Read/Write. Default 0b.
This bit controls whether the host controller skips processing the Asynchronous Schedule.
Only the host controller uses this bit.
Values Meaning
0
Do not process the Asynchronous Schedule.
1
Use the ASYNCLISTADDR register to access the Asynchronous Schedule.
4
PSE
Periodic Schedule Enable- Read/Write. Default 0b.
This bit controls whether the host controller skips processing the Periodic Schedule.
Only the host controller uses this bit.
Values Meaning
0
Do not process the Periodic Schedule
1
Use the PERIODICLISTBASE register to access the Periodic Schedule.
3–2
FS_1
See description at bit 15
1
RST
Controller Reset (RESET) - Read/Write. Software uses this bit to reset the controller. This bit is set to zero
by the Host/Device Controller when the reset process is complete. Software cannot terminate the reset
process early by writing a zero to this register.
Host operation mode:
When software writes a one to this bit, the Controller resets its internal pipelines, timers, counters, state
machines etc. to their initial value. Any transaction currently in progress on USB is immediately
terminated. A USB reset is not driven on downstream ports. Software should not set this bit to a one when
the HCHalted bit in the USBSTS register is a zero. Attempting to reset an actively running host controller
will result in undefined behavior.
Device operation mode:
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3846
NXP Semiconductors

<!-- page 3847 -->

USB_nUSBCMD field descriptions (continued)
Field
Description
When software writes a one to this bit, the Controller resets its internal pipelines, timers, counters, state
machines etc. to their initial value. Writing a one to this bit when the device is in the attached state is not
recommended, because the effect on an attached host is undefined. In order to ensure that the device is
not in an attached state before initiating a device controller reset, all primed endpoints should be flushed
and the USBCMD Run/Stop bit should be set to 0.
0
RS
Run/Stop (RS) - Read/Write. Default 0b. 1=Run. 0=Stop.
Host operation mode:
When set to '1b', the Controller proceeds with the execution of the schedule. The Controller continues
execution as long as this bit is set to a one. When this bit is set to 0, the Host Controller completes the
current transaction on the USB and then halts. The HC Halted bit in the status register indicates when the
Controller has finished the transaction and has entered the stopped state. Software should not write a one
to this field unless the controller is in the Halted state (that is, HCHalted in the USBSTS register is a one).
Device operation mode:
Writing a one to this bit will cause the controller to enable a pull-up on D+ and initiate an attach event. This
control bit is not directly connected to the pull-up enable, as the pull-up will become disabled upon
transitioning into high-speed mode. Software should use this bit to prevent an attach event before the
controller has been properly initialized. Writing a 0 to this will cause a detach event.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3847

<!-- page 3848 -->

56.6.19
USB Status Register (USB_nUSBSTS)
This register indicates various states of the Host/Device Controller and any pending
interrupts. This register does not indicate status resulting from a transaction on the serial
bus.
Address: 218_4000h base + 144h offset + (512d × i), where i=0d to 1d
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
TI1
TI0
Reserved
NAKI
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
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3848
NXP Semiconductors

<!-- page 3849 -->

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
AS
PS
RCL
HCH
Reserved
ULPII
Reserved
SLI
SRI
URI
AAI
SEI
FRI
PCI
UEI
UI
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
USB_nUSBSTS field descriptions
Field
Description
31–26
-
This field is reserved.
Reserved
25
TI1
General Purpose Timer Interrupt 1(GPTINT1)--R/WC.
This bit is set when the counter in the GPTIMER1CTRL register transitions to zero, writing a one to this bit
will clear it.
24
TI0
General Purpose Timer Interrupt 0(GPTINT0)--R/WC.
This bit is set when the counter in the GPTIMER0CTRL register transitions to zero, writing a one to this bit
clears it.
23–17
-
This field is reserved.
Reserved
16
NAKI
NAK Interrupt Bit--RO.
This bit is set by hardware when for a particular endpoint both the TX/RX Endpoint NAK bit and
corresponding TX/RX Endpoint NAK Enable bit are set. This bit is automatically cleared by hardware when
all Enabled TX/RX Endpoint NAK bits are cleared.
15
AS
Asynchronous Schedule Status - Read Only.
This bit reports the current real status of the Asynchronous Schedule. When set to zero the asynchronous
schedule status is disabled and if set to one the status is enabled. The Host Controller is not required to
immediately disable or enable the Asynchronous Schedule when software transitions the Asynchronous
Schedule Enable bit in the USBCMD register. When this bit and the Asynchronous Schedule Enable bit
are the same value, the Asynchronous Schedule is either enabled (1) or disabled (0).
Only used in the host operation mode.
14
PS
Periodic Schedule Status - Read Only.
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3849

<!-- page 3850 -->

USB_nUSBSTS field descriptions (continued)
Field
Description
This bit reports the current real status of the Periodic Schedule. When set to zero the periodic schedule is
disabled, and if set to one the status is enabled. The Host Controller is not required to immediately disable
or enable the Periodic Schedule when software transitions the Periodic Schedule Enable bit in the
USBCMD register. When this bit and the Periodic Schedule Enable bit are the same value, the Periodic
Schedule is either enabled (1) or disabled (0).
Only used in the host operation mode.
13
RCL
Reclamation - Read Only.
This is a read-only status bit used to detect an empty asynchronous schedule.
Only used in the host operation mode.
12
HCH
HCHaIted - Read Only.
This bit is a zero whenever the Run/Stop bit is a one. The Controller sets this bit to one after it has
stopped executing because of the Run/Stop bit being set to 0, either by software or by the Controller
hardware (for example, an internal error).
Only used in the host operation mode.
Default value is '0b' for OTG core.
This is because OTG core is not operating as host in default. Please see CM bit in USB_n_USBMODE
register.
NOTE: HCH bit reset value: '0b' for OTG controller core.
11
-
This field is reserved.
Reserved
10
ULPII
ULPI Interrupt - R/WC.
This bit will be set '1b' by hardware when there is an event completion in ULPI viewport.
This bit is usable only if the controller support UPLI interface mode.
9
-
This field is reserved.
Reserved
8
SLI
DCSuspend - R/WC.
When a controller enters a suspend state from an active state, this bit will be set to a one. The device
controller clears the bit upon exiting from a suspend state.
Only used in device operation mode.
7
SRI
SOF Received - R/WC.
When the device controller detects a Start Of (micro) Frame, this bit will be set to a one. When a SOF is
extremely late, the device controller will automatically set this bit to indicate that an SOF was expected.
Therefore, this bit will be set roughly every 1ms in device FS mode and every 125ms in HS mode and will
be synchronized to the actual SOF that is received.
Because the device controller is initialized to FS before connect, this bit will be set at an interval of 1ms
during the prelude to connect and chirp.
In host mode, this bit will be set every 125us and can be used by host controller driver as a time base.
Software writes a 1 to this bit to clear it.
6
URI
USB Reset Received - R/WC.
When the device controller detects a USB Reset and enters the default state, this bit will be set to a one.
Software can write a 1 to this bit to clear the USB Reset Received status bit.
Only used in device operation mode.
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3850
NXP Semiconductors

<!-- page 3851 -->

USB_nUSBSTS field descriptions (continued)
Field
Description
5
AAI
Interrupt on Async Advance - R/WC.
System software can force the host controller to issue an interrupt the next time the host controller
advances the asynchronous schedule by writing a one to the Interrupt on Async Advance Doorbell bit in
the n_USBCMD register. This status bit indicates the assertion of that interrupt source.
Only used in host operation mode.
4
SEI
System Error- R/WC.
This bit is will be set to '1b' when an Error response is seen to a read on the system interface.
3
FRI
Frame List Rollover - R/WC.
The Host Controller sets this bit to a one when the Frame List Index rolls over from its maximum value to
zero. The exact value at which the rollover occurs depends on the frame list size. For example. If the
frame list size (as programmed in the Frame List Size field of the USB_n_USBCMD register) is 1024, the
Frame Index Register rolls over every time FRINDEX [13] toggles. Similarly, if the size is 512, the Host
Controller sets this bit to a one every time FHINDEX [12] toggles.
Only used in host operation mode.
2
PCI
Port Change Detect - R/WC.
The Host Controller sets this bit to a one when on any port a Connect Status occurs, a Port Enable/
Disable Change occurs, or the Force Port Resume bit is set as the result of a J-K transition on the
suspended port.
The Device Controller sets this bit to a one when the port controller enters the full or high-speed
operational state. When the port controller exits the full or high-speed operation states due to Reset or
Suspend events, the notification mechanisms are the USB Reset Received bit and the DCSuspend bits
respectively.
1
UEI
USB Error Interrupt (USBERRINT) - R/WC.
When completion of a USB transaction results in an error condition, this bit is set by the Host/Device
Controller. This bit is set along with the USBINT bit, if the TD on which the error interrupt occurred also
had its interrupt on complete (IOC) bit set.
The device controller detects resume signaling only.
0
UI
USB Interrupt (USBINT) - R/WC.
This bit is set by the Host/Device Controller when the cause of an interrupt is a completion of a USB
transaction where the Transfer Descriptor (TD) has an interrupt on complete (IOC) bit set.
This bit is also set by the Host/Device Controller when a short packet is detected. A short packet is when
the actual number of bytes received was less than the expected number of bytes.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3851

<!-- page 3852 -->

56.6.20
Interrupt Enable Register (USB_nUSBINTR)
The interrupts to software are enabled with this register. An interrupt is generated when a
bit is set and the corresponding interrupt source is active. The USB Status register
(n_USBSTS) still shows interrupt sources even if they are disabled by the n_USBINTR
register, allowing polling of interrupt events by the software.
Address: 218_4000h base + 148h offset + (512d × i), where i=0d to 1d
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
TIE1
TIE0
Reserved
UPIE
UAIE
Reserved
NAKE
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
-
ULPIE
Reserved
SLE
SRE
URE
AAE
SEE
FRE
PCE
UEE
UE
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
USB_nUSBINTR field descriptions
Field
Description
31–26
-
This field is reserved.
Reserved
25
TIE1
General Purpose Timer #1 Interrupt Enable
When this bit is one and the TI1 bit in n_USBSTS register is a one the controller will issue an interrupt.
24
TIE0
General Purpose Timer #0 Interrupt Enable
When this bit is one and the TI0 bit in n_USBSTS register is a one the controller will issue an interrupt.
23–20
-
This field is reserved.
Reserved
19
UPIE
USB Host Periodic Interrupt Enable
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3852
NXP Semiconductors

<!-- page 3853 -->

USB_nUSBINTR field descriptions (continued)
Field
Description
When this bit is one, and the UPI bit in the n_USBSTS register is one, host controller will issue an interrupt
at the next interrupt threshold.
18
UAIE
USB Host Asynchronous Interrupt Enable
When this bit is one, and the UAI bit in the n_USBSTS register is one, host controller will issue an interrupt
at the next interrupt threshold.
17
-
This field is reserved.
Reserved
16
NAKE
NAK Interrupt Enable
When this bit is one and the NAKI bit in n_USBSTS register is a one the controller will issue an interrupt.
15–11
-
These bits are reserved and should be set to zero.
10
ULPIE
ULPI Interrupt Enable
When this bit is one and the UPLII bit in n_USBSTS register is a one the controller will issue an interrupt.
This bit is usable only if the controller support UPLI interface mode.
9
-
This field is reserved.
Reserved
8
SLE
Sleep Interrupt Enable
When this bit is one and the SLI bit in n_n_USBSTS register is a one the controller will issue an interrupt.
Only used in device operation mode.
7
SRE
SOF Received Interrupt Enable
When this bit is one and the SRI bit in n_USBSTS register is a one the controller will issue an interrupt.
6
URE
USB Reset Interrupt Enable
When this bit is one and the URI bit in n_USBSTS register is a one the controller will issue an interrupt.
Only used in device operation mode.
5
AAE
Async Advance Interrupt Enable
When this bit is one and the AAI bit in n_USBSTS register is a one the controller will issue an interrupt.
Only used in host operation mode.
4
SEE
System Error Interrupt Enable
When this bit is one and the SEI bit in n_USBSTS register is a one the controller will issue an interrupt.
Only used in host operation mode.
3
FRE
Frame List Rollover Interrupt Enable
When this bit is one and the FRI bit in n_USBSTS register is a one the controller will issue an interrupt.
Only used in host operation mode.
2
PCE
Port Change Detect Interrupt Enable
When this bit is one and the PCI bit in n_USBSTS register is a one the controller will issue an interrupt.
1
UEE
USB Error Interrupt Enable
When this bit is one and the UEI bit in n_USBSTS register is a one the controller will issue an interrupt.
0
UE
USB Interrupt Enable
When this bit is one and the UI bit in n_USBSTS register is a one the controller will issue an interrupt.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3853

<!-- page 3854 -->

56.6.21
USB Frame Index (USB_nFRINDEX)
This register is used by the host controller to index the periodic frame list. The register
updates every 125 microseconds (once each micro-frame). Bits [N: 3] are used to select a
particular entry in the Periodic Frame List during periodic schedule execution. The
number of bits used for the index depends on the size of the frame list as set by system
software in the Frame List Size field in the n_USBCMD register.
This register must be written as a DWord. Byte writes produce undefined results. This
register cannot be written unless the Host Controller is in the 'Halted' state as indicated by
the HCHalted bit. A write to this register while the Run/Stop hit is set to a one produces
undefined results. Writes to this register also affect the SOF value.
In device mode this register is read only and, the device controller updates the FRINDEX
[13:3] register from the frame number indicated by the SOF marker. Whenever a SOF is
received by the USB bus, FRINDEX [13:3] will be checked against the SOF marker. If
FRINDEX [13:3] is different from the SOF marker, FRINDEX [13:3] will be set to the
SOF value and FRINDEX [2:0] will be set to zero (that is, SOF for 1 ms frame). If
FRINDEX [13:3] is equal to the SOF value, FRINDEX [2:0] will be increment (that is,
SOF for 125 us micro-frame.).
Address: 218_4000h base + 14Ch offset + (512d × i), where i=0d to 1d
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
FRINDEX
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
USB_nFRINDEX field descriptions
Field
Description
31–14
-
This field is reserved.
Reserved
FRINDEX
Frame Index.
The value, in this register, increments at the end of each time frame (micro-frame). Bits [N: 3] are used for
the Frame List current index. This means that each location of the frame list is accessed 8 times (frames
or micro-frames) before moving to the next index.
The following illustrates values of N based on the value of the Frame List Size field in the USBCMD
register, when used in host mode.
USBCMD [Frame List Size] Number Elements N
In device mode the value is the current frame number of the last frame transmitted. It is not used as an
index.
In either mode bits 2:0 indicate the current microframe.
000
(1024) 12
001
(512) 11
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3854
NXP Semiconductors

<!-- page 3855 -->

USB_nFRINDEX field descriptions (continued)
Field
Description
010
(256) 10
011
(128) 9
100
(64) 8
101
(32) 7
110
(16) 6
111
(8) 5
56.6.22
Frame List Base Address (USB_nPERIODICLISTBASE)
Host Controller only
This 32-bit register contains the beginning address of the Periodic Frame List in the
system memory. HCD loads this register prior to starting the schedule execution by the
Host Controller. The memory structure referenced by this physical memory pointer is
assumed to be 4-Kbyte aligned. The contents of this register are combined with the
Frame Index Register (USB_n_FRINDEX) to enable the Host Controller to step through
the Periodic Frame List in sequence.
Address: 218_4000h base + 154h offset + (512d × i), where i=0d to 1d
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
BASEADR
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
USB_nPERIODICLISTBASE field descriptions
Field
Description
31–12
BASEADR
Base Address (Low).
These bits correspond to memory address signals [31:12], respectively.
Only used by the host controller.
-
This field is reserved.
Reserved
56.6.23
Device Address (USB_nDEVICEADDR)
Device Controller only
The upper seven bits of this register represent the device address. After any controller
reset or a USB reset, the device address is set to the default address (0). The default
address will match all incoming addresses. Software shall reprogram the address after
receiving a SET_ADDRESS descriptor.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3855

<!-- page 3856 -->

Address: 218_4000h base + 154h offset + (512d × i), where i=0d to 1d
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
USBADR
USBADRA
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
USB_nDEVICEADDR field descriptions
Field
Description
31–25
USBADR
Device Address.
These bits correspond to the USB device address
24
USBADRA
Device Address Advance. Default=0.
When this bit is '0', any writes to USBADR are instantaneous. When this bit is written to a '1' at the same
time or before USBADR is written, the write to the USBADR field is staged and held in a hidden register.
After an IN occurs on endpoint 0 and is ACKed, USBADR will be loaded from the holding register.
Hardware will automatically clear this bit on the following conditions:
1) IN is ACKed to endpoint 0. (USBADR is updated from staging register).
2) OUT/SETUP occur to endpoint 0. (USBADR is not updated).
3) Device Reset occurs (USBADR is reset to 0).
NOTE: After the status phase of the SET_ADDRESS descriptor, the DCD has 2 ms to program the
USBADR field. This mechanism will ensure this specification is met when the DCD can not write
of the device address within 2ms from the SET_ADDRESS status phase. If the DCD writes the
USBADR with USBADRA=1 after the SET_ADDRESS data phase (before the prime of the status
phase), the USBADR will be programmed instantly at the correct time and meet the 2ms USB
requirement.
-
This field is reserved.
Reserved
56.6.24
Next Asynch. Address (USB_nASYNCLISTADDR)
Host Controller only
This 32-bit register contains the address of the next asynchronous queue head to be
executed by the host. Bits [4:0] of this register cannot be modified by the system software
and will always return a zero when read.
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3856
NXP Semiconductors

<!-- page 3857 -->

Address: 218_4000h base + 158h offset + (512d × i), where i=0d to 1d
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
ASYBASE
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
USB_nASYNCLISTADDR field descriptions
Field
Description
31–5
ASYBASE
Link Pointer Low (LPL).
These bits correspond to memory address signals [31:5], respectively. This field may only reference a
Queue Head (QH).
Only used by the host controller.
-
This field is reserved.
Reserved
56.6.25
Endpoint List Address (USB_nENDPTLISTADDR)
Device Controller only
In device mode, this register contains the address of the top of the endpoint list in system
memory. Bits [10:0] of this register cannot be modified by the system software and will
always return a zero when read.
The memory structure referenced by this physical memory pointer is assumed 64-byte.
Address: 218_4000h base + 158h offset + (512d × i), where i=0d to 1d
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
EPBASE
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
USB_nENDPTLISTADDR field descriptions
Field
Description
31–11
EPBASE
Endpoint List Pointer(Low). These bits correspond to memory address signals [31:11], respectively. This
field will reference a list of up to 32 Queue Head (QH) (that is, one queue head per endpoint & direction).
-
This field is reserved.
Reserved
56.6.26
Programmable Burst Size (USB_nBURSTSIZE)
This register is used to control the burst size used during data movement on the AHB
master interface. This register is ignored if AHBBRST bits in SBUSCFG register is non-
zero value.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3857

<!-- page 3858 -->

Address: 218_4000h base + 160h offset + (512d × i), where i=0d to 1d
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
TXPBURST
RXPBURST
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
1
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
USB_nBURSTSIZE field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16–8
TXPBURST
Programmable TX Burst Size.
Default value is determined by TXBURST bits in n_HWTXBUF.
This register represents the maximum length of a the burst in 32-bit words while moving data from system
memory to the USB bus.
RXPBURST
Programmable RX Burst Size.
Default value is determined by TXBURST bits in n_HWRXBUF.
This register represents the maximum length of a the burst in 32-bit words while moving data from the
USB bus to system memory.
56.6.27
TX FIFO Fill Tuning (USB_nTXFILLTUNING)
The fields in this register control performance tuning associated with how the host
controller posts data to the TX latency FIFO before moving the data onto the USB bus.
The specific areas of performance include the how much data to post into the FIFO and
an estimate for how long that operation should take in the target system.
Definitions:
T 0 = Standard packet overhead
T 1 = Time to send data payload
T ff = Time to fetch packet into TX FIFO up to specified level.
T s = Total Packet Flight Time (send-only) packet
T s = T 0 + T 1
T p = Total Packet Time (fetch and send) packet
T p = T ff + T 0 + T 1
Upon discovery of a transmit (OUT/SETUP) packet in the data structures, host controller
checks to ensure Tp remains before the end of the [micro]frame. If so it proceeds to pre-
fill the TX FIFO. If at anytime during the pre-fill operation the time remaining the
[micro]frame is < Ts then the packet attempt ceases and the packet is tried at a later time.
Although this is not an error condition and the host controller will eventually recover, a
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3858
NXP Semiconductors

<!-- page 3859 -->

mark will be made the scheduler health counter to note the occurrence of a "back-off"
event. When a back-off event is detected, the partial packet fetched may need to be
discarded from the latency buffer to make room for periodic traffic that will begin after
the next SOF. Too many back-off events can waste bandwidth and power on the system
bus and thus should be minimized (not necessarily eliminated). Back-offs can be
minimized with use of the n_TSCHHEALTH ( Tff ) described below.
NOTE
The reset value could vary from instance to instance. Please see
the detail in bit field description and ignore reset value in
summary table in this case!
Address: 218_4000h base + 164h offset + (512d × i), where i=0d to 1d
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
TXFIFOTHRES
Reserved
TXSCHHEALTH
TXSCHOH
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
1
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
USB_nTXFILLTUNING field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–16
TXFIFOTHRES
FIFO Burst Threshold. (Read/Write)
This register controls the number of data bursts that are posted to the TX latency FIFO in host mode
before the packet begins on to the bus. The minimum value is 2 and this value should be a low as possible
to maximize USB performance. A higher value can be used in systems with unpredictable latency and/or
insufficient bandwidth where the FIFO may underrun because the data transferred from the latency FIFO
to USB occurs before it can be replenished from system memory. This value is ignored if the Stream
Disable bit in USB_n_USBMODE register is set.
Default value is '0Ah for OTG controller core.
15–13
-
This field is reserved.
Reserved
12–8
TXSCHHEALTH
Scheduler Health Counter. (Read/Write To Clear)
This register increments when the host controller fails to fill the TX latency FIFO to the level programmed
by TXFIFOTHRES before running out of time to send the packet before the next Start-Of-Frame. This
health counter measures the number of times this occurs to provide feedback to selecting a proper
TXSCHOH. Writing to this register will clear the counter and this counter will max. at 31.
Default value is '00h' for OTG controller core.
TXSCHOH
Scheduler Overhead. (Read/Write) [Default = 0]
This register adds an additional fixed offset to the schedule time estimator described above as Tff. As an
approximation, the value chosen for this register should limit the number of back-off events captured in the
TXSCHHEALTH to less than 10 per second in a highly utilized bus. Choosing a value that is too high for
this register is not desired as it can needlessly reduce USB utilization. The time unit represented in this
register is 1.267us when a device is connected in High-Speed Mode. The time unit represented in this
register is 6.333us when a device is connected in Low/Full Speed Mode.
Default value is '08h' for OTG controller core.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3859

<!-- page 3860 -->

56.6.28
Endpoint NAK (USB_nENDPTNAK)
Address: 218_4000h base + 178h offset + (512d × i), where i=0d to 1d
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
EPTN
Reserved
EPRN
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
USB_nENDPTNAK field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–16
EPTN
TX Endpoint NAK - R/WC.
Each TX endpoint has 1 bit in this field. The bit is set when the
device sends a NAK handshake on a received IN token for the corresponding endpoint.
Bit [N] - Endpoint #[N], N is 0-7
15–8
-
This field is reserved.
Reserved
EPRN
RX Endpoint NAK - R/WC.
Each RX endpoint has 1 bit in this field. The bit is set when the
device sends a NAK handshake on a received OUT or PING token for the corresponding endpoint.
Bit [N] - Endpoint #[N], N is 0-7
56.6.29
Endpoint NAK Enable (USB_nENDPTNAKEN)
Address: 218_4000h base + 17Ch offset + (512d × i), where i=0d to 1d
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
EPTNE
Reserved
EPRNE
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
USB_nENDPTNAKEN field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–16
EPTNE
TX Endpoint NAK Enable - R/W.
Each bit is an enable bit for the corresponding TX Endpoint NAK bit. If this bit is set and the corresponding
TX Endpoint NAK bit is set, the NAK Interrupt bit is set.
Bit [N] - Endpoint #[N], N is 0-7
15–8
-
This field is reserved.
Reserved
EPRNE
RX Endpoint NAK Enable - R/W.
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3860
NXP Semiconductors

<!-- page 3861 -->

USB_nENDPTNAKEN field descriptions (continued)
Field
Description
Each bit is an enable bit for the corresponding RX Endpoint NAK bit. If this bit is set and the corresponding
RX Endpoint NAK bit is set, the NAK Interrupt bit is set.
Bit [N] - Endpoint #[N], N is 0-7
56.6.30
Configure Flag Register (USB_nCONFIGFLAG)
Address: 218_4000h base + 180h offset + (512d × i), where i=0d to 1d
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
CF
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
USB_nCONFIGFLAG field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
CF
Configure Flag
Host software sets this bit as the last action in its process of configuring the Host Controller. This bit
controls the default port-routing control logic.
0
Port routing control logic default-routes each port to an implementation dependent classic host
controller.
1
Port routing control logic default-routes all ports to this host controller.
56.6.31
Port Status & Control (USB_nPORTSC1)
Host Controller
A host controller could implement one to eight port status and control registers. The
number is determined by N_PORTs bits in HWSPARAMs register (please see Host
Controller Structural Parameters (USB_nHCSPARAMS) ). Software could read this
parameter register to determine how many ports need service.
All controller cores on this product are Single-Port, so there is only one port status and
control register for each controller core.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3861

<!-- page 3862 -->

This register is only reset by power on reset or controller core reset. The initial conditions
of a port are:
• No device connected
• Port disabled
If the port supports power control, this state remains until port power is supplied (by
software).
Device Controller
A controller operating in device mode has only port register one (PORTSC1) and it does
not support power control in that mode. Port control in device mode is only used for
status port reset, suspend, and current connect status. It is also used to initiate test mode
or force signaling and allows software to put the PHY into low power suspend mode and
disable the PHY clock.
Address: 218_4000h base + 184h offset + (512d × i), where i=0d to 1d
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
PTS_1
STS
PTW
PSPD
PTS_2
PFSC
PHCD
WKOC
WKDC
WKCN
PTC
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
PIC
PO
PP
LS
HSP
PR
SUSP
FPR
OCC
OCA
PEC
PE
CSC
CCS
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
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3862
NXP Semiconductors

<!-- page 3863 -->

USB_nPORTSC1 field descriptions
Field
Description
31–30
PTS_1
NOTE: All USB port interface modes are listed in this field description, but not all are supported. For
detail feature of each controller core, please see Features . The behaviour is unknown when
unsupported interface mode is selected.
29
STS
Serial Transceiver Select
1 Serial Interface Engine is selected
0 Parallel Interface signals is selected
Serial Interface Engine can be used in combination with UTMI+/ULPI physical interface to provide FS/LS
signaling instead of the parallel interface signals.
When this bit is set '1b', serial interface engine will be used instead of parallel interface signals.
This bit has no effect unless PTS bits is set to select UTMI+/ULPI interface.
The Serial/USB1.1 PHY/IC-USB will use the serial interface engine for FS/LS signaling regardless of this
bit value.
28
PTW
Parallel Transceiver Width
This bit has no effect if serial interface engine is used.
For OTG1/OTG2 core, it is Read-Only. Reset value is '1b'.
0
Select the 8-bit UTMI interface [60MHz]
1
Select the 16-bit UTMI interface [30MHz]
27–26
PSPD
Port Speed - Read Only.
This register field indicates the speed at which the port is operating.
00
Full Speed
01
Low Speed
10
High Speed
11
Undefined
25
PTS_2
See description at bits 31-30
24
PFSC
Port Force Full Speed Connect - Read/Write. Default = 0b.
When this bit is set to '1b', the port will be forced to only connect at Full Speed, It disables the chirp
sequence that allows the port to identify itself as High Speed.
1
Forced to full speed
0
Normal operation
23
PHCD
PHY Low Power Suspend - Clock Disable (PLPSCD) - Read/Write. Default = 0b.
When this bit is set to '1b', the PHY clock is disabled. Reading this bit will indicate the status of the PHY
clock.
NOTE: The PHY clock cannot be disabled if it is being used as the system clock.
In device mode, The PHY can be put into Low Power Suspend when the device is not running (USBCMD
Run/Stop=0b) or the host has signalled suspend (PORTSC1 SUSPEND=1b). PHY Low power suspend
will be cleared automatically when the host initials resume. Before forcing a resume from the device, the
device controller driver must clear this bit.
In host mode, the PHY can be put into Low Power Suspend when the downstream device has been put
into suspend mode or when no downstream device is connected. Low power suspend is completely under
the control of software.
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3863

<!-- page 3864 -->

USB_nPORTSC1 field descriptions (continued)
Field
Description
1
Disable PHY clock
0
Enable PHY clock
22
WKOC
Wake on Over-current Enable (WKOC_E) - Read/Write. Default = 0b.
Writing this bit to a one enables the port to be sensitive to over-current conditions as wake-up events.
This field is zero if Port Power(Port Status & Control (USB_nPORTSC1)) is zero.
21
WKDC
Wake on Disconnect Enable (WKDSCNNT_E) - Read/Write. Default=0b. Writing this bit to a one enables
the port to be sensitive to device disconnects as wake-up events.
This field is zero if Port Power(Port Status & Control (USB_nPORTSC1)) is zero or in device mode.
20
WKCN
Wake on Connect Enable (WKCNNT_E) - Read/Write. Default=0b.
Writing this bit to a one enables the port to be sensitive to device connects as wake-up events.
This field is zero if Port Power(Port Status & Control (USB_nPORTSC1)) is zero or in device mode.
19–16
PTC
Port Test Control - Read/Write. Default = 0000b.
Refer to Port Test Mode for the operational model for using these test modes and the USB Specification
Revision 2.0, Chapter 7 for details on each test mode.
The FORCE_ENABLE_FS and FORCE ENABLE_LS are extensions to the test mode support specified in
the EHCI specification. Writing the PTC field to any of the FORCE_ENABLE_{HS/FS/LS} values will force
the port into the connected and enabled state at the selected speed. Writing the PTC field back to
TEST_MODE_DISABLE will allow the port state machines to progress normally from that point.
NOTE: Low speed operations are not supported as a peripheral device.
Any other value than zero indicates that the port is operating in test mode.
Value Specific Test
0000
TEST_MODE_DISABLE
0001
J_STATE
0010
K_STATE
0011
SE0 (host) / NAK (device)
0100
Packet
0101
FORCE_ENABLE_HS
0110
FORCE_ENABLE_FS
0111
FORCE_ENABLE_LS
1000-1111
Reserved
15–14
PIC
Port Indicator Control - Read/Write. Default = Ob.
Writing to this field has no effect if the P_INDICATOR bit in the HCSPARAMS register is a zero.
Refer to the USB Specification Revision 2.0 for a description on how these bits are to be used.
This field is zero if Port Power is zero.
Bit Value Meaning
00
Port indicators are off
01
Amber
10
Green
11
Undefined
13
PO
Port Owner-Read/Write. Default = 0.
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3864
NXP Semiconductors

<!-- page 3865 -->

USB_nPORTSC1 field descriptions (continued)
Field
Description
This bit unconditionally goes to a 0 when the configured bit in the CONFIGFLAG register makes a 0 to 1
transition. This bit unconditionally goes to 1 whenever the Configured bit is zero System software uses this
field to release ownership of the port to a selected host controller (in the event that the attached device is
not a high-speed device). Software writes a one to this bit when the attached device is not a high-speed
device. A one in this bit means that an internal companion controller owns and controls the port.
Port owner handoff is not supported in all controller cores, therefore this bit will always be 0.
12
PP
Port Power (PP)-Read/Write or Read Only.
The function of this bit depends on the value of the Port Power Switching (PPC) field in the HCSPARAMS
register. The behavior is as follows:
PPC
PP Operation
0
1b Read Only - Host controller does not have port power control switches. Each port is hard-wired to
power.
1
1b/0b - Read/Write. OTG controller requires port power control switches. This bit represents the current
setting of the switch (0=off, 1=on). When power is not available on a port (that is, PP equals a 0), the port
is non-functional and will not report attaches, detaches, etc.
When an over-current condition is detected on a powered port and PPC is a one, the PP bit in each
affected port may be transitional by the host controller driver from a one to a zero (removing power from
the port).
This feature is implemented in all controller cores (PPC = 1).
11–10
LS
Line Status-Read Only. These bits reflect the current logical levels of the D+ (bit 11) and D- (bit 10) signal
lines.
In host mode, the use of linestate by the host controller driver is not necessary (unlike EHCI), because the
port controller state machine and the port routing manage the connection of LS and FS.
In device mode, the use of linestate by the device controller driver is not necessary.
The encoding of the bits are:
Bits [11:10] Meaning
00
SE0
10
J-state
01
K-state
11
Undefined
9
HSP
High-Speed Port - Read Only. Default = 0b.
When the bit is one, the host/device connected to the port is in high-speed mode and if set to zero, the
host/device connected to the port is not in a high-speed mode.
NOTE: HSP is redundant with PSPD(bit 27, 26) but remained for compatibility.
8
PR
Port Reset - Read/Write or Read Only. Default = 0b.
In Host Mode: Read/Write. 1=Port is in Reset. 0=Port is not in Reset. Default 0.
When software writes a one to this bit the bus-reset sequence as defined in the USB Specification
Revision 2.0 is started. This bit will automatically change to zero after the reset sequence is complete.
This behavior is different from EHCI where the host controller driver is required to set this bit to a zero
after the reset duration is timed in the driver.
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3865

<!-- page 3866 -->

USB_nPORTSC1 field descriptions (continued)
Field
Description
In Device Mode: This bit is a read only status bit. Device reset from the USB bus is also indicated in the
USBSTS register.
This field is zero if Port Power(Port Status & Control (USB_nPORTSC1)) is zero.
7
SUSP
Suspend - Read/Write or Read Only. Default = 0b.
1=Port in suspend state. 0=Port not in suspend state.
In Host Mode: Read/Write.
Port Enabled Bit and Suspend bit of this register define the port states as follows:
Bits [Port Enabled, Suspend] Port State
0x Disable
10 Enable
11 Suspend
When in suspend state, downstream propagation of data is blocked on this port, except for port reset. The
blocking occurs at the end of the current transaction if a transaction was in progress when this bit was
written to 1. In the suspend state, the port is sensitive to resume detection. Note that the bit status does
not change until the port is suspended and that there may be a delay in suspending a port if there is a
transaction currently in progress on the USB.
The host controller will unconditionally set this bit to zero when software sets the Force Port Resume bit to
zero. The host controller ignores a write of zero to this bit.
If host software sets this bit to a one when the port is not enabled (that is, Port enabled bit is a zero) the
results are undefined.
This field is zero if Port Power(Port Status & Control (USB_nPORTSC1)) is zero in host mode.
In Device Mode: Read Only.
In device mode this bit is a read only status bit.
6
FPR
Force Port Resume -Read/Write. 1= Resume detected/driven on port. 0=No resume (K-state) detected/
driven on port. Default = 0.
In Host Mode:
Software sets this bit to one to drive resume signaling. The Host Controller sets this bit to one if a J-to-K
transition is detected while the port is in the Suspend state. When this bit transitions to a one because a J-
to-K transition is detected, the Port Change Detect bit in the USBSTS register is also set to one. This bit
will automatically change to zero after the resume sequence is complete. This behavior is different from
EHCI where the host controller driver is required to set this bit to a zero after the resume duration is timed
in the driver.
Note that when the Host controller owns the port, the resume sequence follows the defined sequence
documented in the USB Specification Revision 2.0. The resume signaling (Full-speed 'K') is driven on the
port as long as this bit remains a one. This bit will remain a one until the port has switched to the high-
speed idle. Writing a zero has no effect because the port controller will time the resume operation, clear
the bit the port control state switches to HS or FS idle.
This field is zero if Port Power(Port Status & Control (USB_nPORTSC1)) is zero in host mode.
This bit is not-EHCI compatible.
In Device mode:
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3866
NXP Semiconductors

<!-- page 3867 -->

USB_nPORTSC1 field descriptions (continued)
Field
Description
After the device has been in Suspend State for 5ms or more, software must set this bit to one to drive
resume signaling before clearing. The Device Controller will set this bit to one if a J-to-K transition is
detected while the port is in the Suspend state. The bit will be cleared when the device returns to normal
operation. Also, when this bit wil be cleared because a K-to-J transition detected, the Port Change Detect
bit in the USBSTS register is also set to one.
5
OCC
Over-current Change-R/WC. Default=0.
This bit is set '1b' by hardware when there is a change to Over-current Active. Software can clear this bit
by writing a one to this bit position.
4
OCA
Over-current Active-Read Only. Default 0.
This bit will automatically transition from one to zero when the over current condition is removed.
1
This port currently has an over-current condition
0
This port does not have an over-current condition.
3
PEC
Port Enable/Disable Change-R/WC. 1=Port enabled/disabled status has changed. 0=No change. Default =
0.
In Host Mode:
For the root hub, this bit is set to a one only when a port is disabled due to disconnect on the port or due to
the appropriate conditions existing at the EOF2 point (See Chapter 11 of the USB Specification). Software
clears this by writing a one to it.
This field is zero if Port Power(Port Status & Control (USB_nPORTSC1)) is zero.
In Device mode:
The device port is always enabled, so this bit is always '0b'.
2
PE
Port Enabled/Disabled-Read/Write. 1=Enable. 0=Disable. Default 0.
In Host Mode:
Ports can only be enabled by the host controller as a part of the reset and enable. Software cannot enable
a port by writing a one to this field. Ports can be disabled by either a fault condition (disconnect event or
other fault condition) or by the host software. Note that the bit status does not change until the port state
actually changes. There may be a delay in disabling or enabling a port due to other host controller and bus
events.
When the port is disabled, (0b) downstream propagation of data is blocked except for reset.
This field is zero if Port Power(Port Status & Control (USB_nPORTSC1)) is zero in host mode.
In Device Mode:
The device port is always enabled, so this bit is always '1b'.
1
CSC
Connect Status Change-R/WC. 1 =Change in Current Connect Status. 0=No change. Default 0.
In Host Mode:
Indicates a change has occurred in the port's Current Connect Status. The host/device controller sets this
bit for all changes to the port device connect status, even if system software has not cleared an existing
connect status change. For example, the insertion status changes twice before system software has
cleared the changed condition, hub hardware will be 'setting' an already-set bit (that is, the bit will remain
set). Software clears this bit by writing a one to it.
This field is zero if Port Power(Port Status & Control (USB_nPORTSC1)) is zero in host mode.
In Device Mode:
This bit is undefined in device controller mode.
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3867

<!-- page 3868 -->

USB_nPORTSC1 field descriptions (continued)
Field
Description
0
CCS
Current Connect Status-Read Only.
In Host Mode:
1=Device is present on port. 0=No device is present. Default = 0. This value reflects the current state of
the port, and may not correspond directly to the event that caused the Connect Status Change bit (Bit 1)
to be set.
This field is zero if Port Power(Port Status & Control (USB_nPORTSC1)) is zero in host mode.
In Device Mode:
1=Attached. 0=Not Attached. Default=0. A one indicates that the device successfully attached and is
operating in either high speed or full speed as indicated by the High Speed Port bit in this register. A zero
indicates that the device did not attach successfully or was forcibly disconnected by the software writing a
zero to the Run bit in the USBCMD register. It does not state the device being disconnected or
suspended.
56.6.32
On-The-Go Status & control (USB_nOTGSC)
This register is availabe only in OTG controller core. It has four sections:
• OTG Interrupt enables (Read/Write)
• OTG Interrupt status (Read/Write to Clear)
• OTG Status inputs (Read Only)
• OTG Controls (Read/Write)
The status inputs are debounced using a 1 ms time constant. Values on the status inputs
that do not persist for more than 1 ms does not cause an update of the status input
register, or cause an OTG interrupt.
See also USB Device Mode (USB_nUSBMODE) register.
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3868
NXP Semiconductors

<!-- page 3869 -->

Address: 218_4000h base + 1A4h offset + (512d × i), where i=0d to 1d
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
DPIE
EN_
1MS
BSEIE
BSVIE
ASVIE
AVVIE
IDIE
Reserved
DPIS
STATUS_1MS
BSEIS
BSVIS
ASVIS
AVVIS
IDIS
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
DPS
TOG_1MS
BSE
BSV
ASV
AVV
ID
Reserved
IDPU
DP
OT
Reserved
VC
VD
W
Reset
0
0
0
1
0
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
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3869

<!-- page 3870 -->

USB_nOTGSC field descriptions
Field
Description
31
-
This field is reserved.
Reserved
30
DPIE
Data Pulse Interrupt Enable
29
EN_1MS
1 millisecond timer Interrupt Enable - Read/Write
28
BSEIE
B Session End Interrupt Enable - Read/Write.
Setting this bit enables the B session end interrupt.
27
BSVIE
B Session Valid Interrupt Enable - Read/Write.
Setting this bit enables the B session valid interrupt.
26
ASVIE
A Session Valid Interrupt Enable - Read/Write.
Setting this bit enables the A session valid interrupt.
25
AVVIE
A VBus Valid Interrupt Enable - Read/Write.
Setting this bit enables the A VBus valid interrupt.
24
IDIE
USB ID Interrupt Enable - Read/Write.
Setting this bit enables the USB ID interrupt.
23
-
This field is reserved.
Reserved
22
DPIS
Data Pulse Interrupt Status - Read/Write to Clear.
This bit is set when data bus pulsing occurs on DP or DM. Data bus pulsing is only detected when
USBMODE.CM = Host (11) and PORTSC1(0)[PP] = 0.
Software must write a one to clear this bit.
21
STATUS_1MS
1 millisecond timer Interrupt Status - Read/Write to Clear.
This bit is set once every millisecond.
Software must write a one to clear this bit.
20
BSEIS
B Session End Interrupt Status - Read/Write to Clear.
This bit is set when VBus has fallen below the B session end threshold. Software must write a one to clear
this bit.
19
BSVIS
B Session Valid Interrupt Status - Read/Write to Clear.
This bit is set when VBus has either risen above or fallen below the B session valid threshold.
Software must write a one to clear this bit.
18
ASVIS
A Session Valid Interrupt Status - Read/Write to Clear.
This bit is set when VBus has either risen above or fallen below the A session valid threshold.
Software must write a one to clear this bit.
17
AVVIS
A VBus Valid Interrupt Status - Read/Write to Clear.
This bit is set when VBus has either risen above or fallen below the VBus valid threshold on an A device.
Software must write a one to clear this bit.
16
IDIS
USB ID Interrupt Status - Read/Write.
This bit is set when a change on the ID input has been detected.
Software must write a one to clear this bit.
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3870
NXP Semiconductors

<!-- page 3871 -->

USB_nOTGSC field descriptions (continued)
Field
Description
15
-
This field is reserved.
Reserved
14
DPS
Data Bus Pulsing Status - Read Only.
A '1' indicates data bus pulsing is being detected on the port.
13
TOG_1MS
1 millisecond timer toggle - Read Only.
This bit toggles once per millisecond.
12
BSE
B Session End - Read Only.
Indicates VBus is below the B session end threshold.
11
BSV
B Session Valid - Read Only.
Indicates VBus is above the B session valid threshold.
10
ASV
A Session Valid - Read Only.
Indicates VBus is above the A session valid threshold.
9
AVV
A VBus Valid - Read Only.
Indicates VBus is above the A VBus valid threshold.
8
ID
USB ID - Read Only.
0 = A device, 1 = B device
7–6
-
This field is reserved.
Reserved
5
IDPU
ID Pullup - Read/Write
This bit provide control over the ID pull-up resistor; 0 = off, 1 = on [default]. When this bit is 0, the ID input
will not be sampled.
4
DP
Data Pulsing - Read/Write.
Setting this bit causes the pullup on DP to be asserted for data pulsing during SRP.
3
OT
OTG Termination - Read/Write.
This bit must be set when the OTG device is in device mode, this controls the pulldown on DM.
2
-
This field is reserved.
Reserved
1
VC
VBUS Charge - Read/Write.
Setting this bit causes the VBus line to be charged. This is used for VBus pulsing during SRP.
0
VD
VBUS_Discharge - Read/Write.
Setting this bit causes VBus to discharge through a resistor.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3871

<!-- page 3872 -->

56.6.33
USB Device Mode (USB_nUSBMODE)
Address: 218_4000h base + 1A8h offset + (512d × i), where i=0d to 1d
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
Reserved
SDIS
SLOM
ES
CM
W
Reset
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
0
0
0
0
0
0
USB_nUSBMODE field descriptions
Field
Description
31–16
-
This field is reserved.
Reserved
15
-
This field is reserved.
Reserved
14–5
-
This field is reserved.
Reserved
4
SDIS
Stream Disable Mode. (0 - Inactive [default]; 1 - Active)
Device Mode: Setting to a '1' disables double priming on both RX and TX for low bandwidth systems. This
mode ensures that when the RX and TX buffers are sufficient to contain an entire packet that the standard
double buffering scheme is disabled to prevent overruns/underruns in bandwidth limited systems. Note: In
High Speed Mode, all packets received are responded to with a NYET handshake when stream disable is
active.
Host Mode: Setting to a '1' ensures that overruns/underruns of the latency FIFO are eliminated for low
bandwidth systems where the RX and TX buffers are sufficient to contain the entire packet. Enabling
stream disable also has the effect of ensuring the TX latency is filled to capacity before the packet is
launched onto the USB.
NOTE: Time duration to pre-fill the FIFO becomes significant when stream disable is active. See TX
FIFO Fill Tuning (USB_nTXFILLTUNING) and TXTTFILLTUNING [MPH Only] to characterize the
adjustments needed for the scheduler when using this feature.
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3872
NXP Semiconductors

<!-- page 3873 -->

USB_nUSBMODE field descriptions (continued)
Field
Description
NOTE: The use of this feature substantially limits of the overall USB performance that can be achieved.
3
SLOM
Setup Lockout Mode. In device mode, this bit controls behavior of the setup lock mechanism. See Control
Endpoint Operation Model .
0
Setup Lockouts On (default);
1
Setup Lockouts Off (DCD requires use of Setup Data Buffer Tripwire in USB Command Register
(USB_nUSBCMD) .
2
ES
Endian Select - Read/Write. This bit can change the byte alignment of the transfer buffers to match the
host microprocessor. The bit fields in the microprocessor interface and the data structures are unaffected
by the value of this bit because they are based upon the 32-bit word.
Bit Meaning
0
Little Endian [Default]
1
Big Endian
CM
Controller Mode - R/WO. Controller mode is defaulted to the proper mode for host only and device only
implementations. For those designs that contain both host & device capability, the controller defaults to an
idle state and needs to be initialized to the desired operating mode after reset. For combination host/
device controllers, this register can only be written once after reset. If it is necessary to switch modes,
software must reset the controller by writing to the RESET bit in the USBCMD register before
reprogramming this register.
For OTG controller core, reset value is '00b'.
00
Idle [Default for combination host/device]
01
Reserved
10
Device Controller [Default for device only controller]
11
Host Controller [Default for host only controller]
56.6.34
Endpoint Setup Status (USB_nENDPTSETUPSTAT)
Address: 218_4000h base + 1ACh offset + (512d × i), where i=0d to 1d
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
ENDPTSETUPSTAT
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
USB_nENDPTSETUPSTAT field descriptions
Field
Description
31–16
-
This field is reserved.
Reserved
ENDPTSETUPSTAT Setup Endpoint Status. For every setup transaction that is received, a corresponding bit in this register
is set to one. Software must clear or acknowledge the setup transfer by writing a one to a respective
bit after it has read the setup data from Queue head. The response to a setup packet as in the order of
operations and total response time is crucial to limit bus time outs while the setup lock our mechanism
is engaged. See Managing Endpoints in the Device Operational Model.
This register is only used in device mode.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3873

<!-- page 3874 -->

56.6.35
Endpoint Prime (USB_nENDPTPRIME)
This register is only used in device mode.
When software sets the prime bit for a given endpoint, the device controller loads the
transfer descriptor, pointed to by the queue head, such that the endpoint is ready to
transmit or receive when the host sends a request (IN/OUT token). The endpoint will
NAK all requests from the host until the endpoint is primed. The controller will
automatically re-prime the endpoint with a new transfer descriptor when one is found via
the next_dtd pointer of the current transfer descriptor. Hence, the prime bit must only be
set by software when a descriptor is added to the queue head.
Address: 218_4000h base + 1B0h offset + (512d × i), where i=0d to 1d
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
PETB
Reserved
PERB
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
USB_nENDPTPRIME field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–16
PETB
Prime Endpoint Transmit Buffer - R/WS. For each endpoint a corresponding bit is used to request that a
buffer is prepared for a transmit operation in order to respond to a USB IN/INTERRUPT transaction.
Software should write a one to the corresponding bit when posting a new transfer descriptor to an
endpoint queue head. Hardware automatically uses this bit to begin parsing for a new transfer descriptor
from the queue head and prepare a transmit buffer. Hardware clears this bit when the associated
endpoint(s) is (are) successfully primed.
NOTE: These bits are momentarily set by hardware during hardware re-priming operations when a dTD
is retired, and the dQH is updated.
PETB[N] - Endpoint #N, N is in 0..7
15–8
-
This field is reserved.
Reserved
PERB
Prime Endpoint Receive Buffer - R/WS. For each endpoint, a corresponding bit is used to request a buffer
prepare for a receive operation for when a USB host initiates a USB OUT transaction. Software should
write a one to the corresponding bit whenever posting a new transfer descriptor to an endpoint queue
head. Hardware automatically uses this bit to begin parsing for a new transfer descriptor from the queue
head and prepare a receive buffer. Hardware clears this bit when the associated endpoint(s) is (are)
successfully primed.
NOTE: These bits are momentarily set by hardware during hardware re-priming operations when a dTD
is retired, and the dQH is updated.
PERB[N] - Endpoint #N, N is in 0..7
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3874
NXP Semiconductors

<!-- page 3875 -->

56.6.36
Endpoint Flush (USB_nENDPTFLUSH)
This register is only used in device mode.
Address: 218_4000h base + 1B4h offset + (512d × i), where i=0d to 1d
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
FETB
Reserved
FERB
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
USB_nENDPTFLUSH field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–16
FETB
Flush Endpoint Transmit Buffer - R/WS. Writing one to a bit(s) in this register causes the associated
endpoint(s) to clear any primed buffers. If a packet is in progress for one of the associated endpoints, then
that transfer continues until completion. Hardware clears this register after the endpoint flush operation is
successful.
FETB[N] - Endpoint #N, N is in 0..7
15–8
-
This field is reserved.
Reserved
FERB
Flush Endpoint Receive Buffer - R/WS. Writing one to a bit(s) causes the assocUOGiated endpoint(s) to
clear any primed buffers. If a packet is in progress for one of the associated endpoints, then that transfer
continues until completion. Hardware clears this register after the endpoint flush operation is successful.
FERB[N] - Endpoint #N, N is in 0..7\
56.6.37
Endpoint Status (USB_nENDPTSTAT)
This register is only used in device mode.
Address: 218_4000h base + 1B8h offset + (512d × i), where i=0d to 1d
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
ETBR
Reserved
ERBR
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
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3875

<!-- page 3876 -->

USB_nENDPTSTAT field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–16
ETBR
Endpoint Transmit Buffer Ready -- Read Only. One bit for each endpoint indicates status of the respective
endpoint buffer. This bit is set to one by the hardware as a response to receiving a command from a
corresponding bit in the ENDPTPRIME register. There is always a delay between setting a bit in the
ENDPTPRIME register and endpoint indicating ready. This delay time varies based upon the current USB
traffic and the number of bits set in the ENDPRIME register. Buffer ready is cleared by USB reset, by the
USB DMA system, or through the ENDPTFLUSH register.
NOTE: These bits are momentarily cleared by hardware during hardware endpoint re-priming operations
when a dTD is retired, and the dQH is updated.
ETBR[N] - Endpoint #N, N is in 0..7
15–8
-
This field is reserved.
Reserved
ERBR
Endpoint Receive Buffer Ready -- Read Only. One bit for each endpoint indicates status of the respective
endpoint buffer. This bit is set to a one by the hardware as a response to receiving a command from a
corresponding bit in the ENDPRIME register. There is always a delay between setting a bit in the
ENDPRIME register and endpoint indicating ready. This delay time varies based upon the current USB
traffic and the number of bits set in the ENDPRIME register. Buffer ready is cleared by USB reset, by the
USB DMA system, or through the ENDPTFLUSH register.
NOTE: These bits are momentarily cleared by hardware during hardware endpoint re-priming operations
when a dTD is retired, and the dQH is updated.
ERBR[N] - Endpoint #N, N is in 0..7
56.6.38
Endpoint Complete (USB_nENDPTCOMPLETE)
This register is only used in device mode.
Address: 218_4000h base + 1BCh offset + (512d × i), where i=0d to 1d
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
ETCE
Reserved
ERCE
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
USB_nENDPTCOMPLETE field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–16
ETCE
Endpoint Transmit Complete Event - R/WC. Each bit indicates a transmit event (IN/INTERRUPT) occurred
and software should read the corresponding endpoint queue to determine the endpoint status. If the
corresponding IOC bit is set in the Transfer Descriptor, then this bit is set simultaneously with the
USBINT . Writing one clears the corresponding bit in this register.
ETCE[N] - Endpoint #N, N is in 0..7
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3876
NXP Semiconductors

<!-- page 3877 -->

USB_nENDPTCOMPLETE field descriptions (continued)
Field
Description
15–8
-
This field is reserved.
Reserved
ERCE
Endpoint Receive Complete Event - RW/C. Each bit indicates a received event (OUT/SETUP) occurred
and software should read the corresponding endpoint queue to determine the transfer status. If the
corresponding IOC bit is set in the Transfer Descriptor, then this bit is set simultaneously with the
USBINT . Writing one clears the corresponding bit in this register.
ERCE[N] - Endpoint #N, N is in 0..7
56.6.39
Endpoint Control0 (USB_nENDPTCTRL0)
Every Device implements Endpoint 0 as a control endpoint.
Address: 218_4000h base + 1C0h offset + (512d × i), where i=0d to 1d
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
TXE
Reserved
TXT
Reserved
TXS
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
RXE
Reserved
RXT
Reserved
RXS
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
USB_nENDPTCTRL0 field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
TXE
TX Endpoint Enable
1 Enabled
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3877

<!-- page 3878 -->

USB_nENDPTCTRL0 field descriptions (continued)
Field
Description
Endpoint0 is always enabled.
22–20
-
This field is reserved.
Reserved
19–18
TXT
TX Endpoint Type - Read/Write
00 - Control
Endpoint0 is fixed as a Control End Point.
17
-
This field is reserved.
Reserved
16
TXS
TX Endpoint Stall - Read/Write
0 End Point OK [Default]
1 End Point Stalled
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. It
continues returning STALL until the bit is cleared by software or it is automatically cleared upon receipt of
a new SETUP request.
After receiving a SETUP request, this bit will continue to be cleared by hardware until the associated
ENDPTSETUPSTAT bit is cleared.
NOTE: There is a slight delay (50 clocks max.) between the endptsetupstat being cleared and hardware
continuing to clear this bit. In most systems it is unlikely the DCD software will observe this delay.
However, should the dcd observe that the stall bit is not set after writing a one to it then follow this
procedure: continually write this stall bit until it is set or until a newsetup has been received by
checking the associated endptsetupstat bit.
15–8
-
This field is reserved.
Reserved
7
RXE
RX Endpoint Enable
1 Enabled
Endpoint0 is always enabled.
6–4
-
This field is reserved.
Reserved
3–2
RXT
RX Endpoint Type - Read/Write
00 Control
Endpoint0 is fixed as a Control End Point.
1
-
This field is reserved.
Reserved
0
RXS
RX Endpoint Stall - Read/Write
0 End Point OK. [Default]
1 End Point Stalled
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. It
continues returning STALL until the bit is cleared by software or it is automatically cleared upon receipt of
a new SETUP request.
After receiving a SETUP request, this bit will continue to be cleared by hardware until the associated
ENDPTSETUPSTAT bit is cleared.
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3878
NXP Semiconductors

<!-- page 3879 -->

USB_nENDPTCTRL0 field descriptions (continued)
Field
Description
NOTE: There is a slight delay (50 clocks max.) between the endptsetupstat being cleared and hardware
continuing to clear this bit. In most systems it is unlikely the dcd software will observe this delay.
However, should the dcd observe that the stall bit is not set after writing a one to it then follow this
procedure: continually write this stall bit until it is set or until a newsetup has been received by
checking the associated endptsetupstat bit.
56.6.40
Endpoint Control 1 (USB_nENDPTCTRL1)
This is endpoint control register for endpoint 1 in device operation mode.
NOTE
If one endpoint direction is enabled and the paired endpoint of
opposite direction is disabled then the unused direction type
must be changed from the default control-type to any other type
(that is Bulk-type). leaving an unconfigured endpoint control
causes undefined behavior for the data pid tracking on the
active endpoint/direction.
Address: 218_4000h base + 1C4h offset + (512d × i), where i=0d to 1d
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
TXE
TXR
TXI
Reserved
TXT
TXD
TXS
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
RXE
RXR
RXI
Reserved
RXT
RXD
RXS
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
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3879

<!-- page 3880 -->

USB_nENDPTCTRL1 field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
TXE
TX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
22
TXR
TX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the Host and device.
21
TXI
TX Data Toggle Inhibit
0 PID Sequencing Enabled. [Default]
1 PID Sequencing Disabled.
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always transmit DATA0 for a data packet.
20
-
This field is reserved.
Reserved
19–18
TXT
TX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
17
TXD
TX Endpoint Data Source - Read/Write
0 Dual Port Memory Buffer/DMA Engine [DEFAULT]
Should always be written as 0.
16
TXS
TX Endpoint Stall - Read/Write
0 End Point OK
1 End Point Stalled
This bit will be cleared automatically upon receipt of a SETUP request if this Endpoint is configured as a
Control Endpoint and this bit will continue to be cleared by hardware until the associated
ENDPTSETUPSTAT bit is cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
15–8
-
This field is reserved.
Reserved
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3880
NXP Semiconductors

<!-- page 3881 -->

USB_nENDPTCTRL1 field descriptions (continued)
Field
Description
7
RXE
RX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
6
RXR
RX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the host and device.
5
RXI
RX Data Toggle Inhibit
0 Disabled [Default]
1 Enabled
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always accept data packet regardless of their data PID.
4
-
This field is reserved.
Reserved.
3–2
RXT
RX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
1
RXD
RX Endpoint Data Sink - Read/Write
0 Dual Port Memory Buffer/DMA Engine [Default]
Should always be written as zero.
0
RXS
RX Endpoint Stall - Read/Write
0 End Point OK. [Default]
1 End Point Stalled
This bit is set automatically upon receipt of a SETUP request if this Endpoint is configured as a Control
Endpointand this bit will continue to be cleared by hardware until the associated ENDPTSETUPSTAT bit is
cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3881

<!-- page 3882 -->

56.6.41
Endpoint Control 2 (USB_nENDPTCTRL2)
This is endpoint control register for endpoint 2 in device operation mode.
NOTE
If one endpoint direction is enabled and the paired endpoint of
opposite direction is disabled then the unused direction type
must be changed from the default control-type to any other type
(that is Bulk-type). leaving an unconfigured endpoint control
causes undefined behavior for the data pid tracking on the
active endpoint/direction.
Address: 218_4000h base + 1C8h offset + (512d × i), where i=0d to 1d
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
TXE
TXR
TXI
Reserved
TXT
TXD
TXS
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
RXE
RXR
RXI
Reserved
RXT
RXD
RXS
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
USB_nENDPTCTRL2 field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
TXE
TX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3882
NXP Semiconductors

<!-- page 3883 -->

USB_nENDPTCTRL2 field descriptions (continued)
Field
Description
22
TXR
TX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the Host and device.
21
TXI
TX Data Toggle Inhibit
0 PID Sequencing Enabled. [Default]
1 PID Sequencing Disabled.
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always transmit DATA0 for a data packet.
20
-
This field is reserved.
Reserved
19–18
TXT
TX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
17
TXD
TX Endpoint Data Source - Read/Write
0 Dual Port Memory Buffer/DMA Engine [DEFAULT]
Should always be written as 0.
16
TXS
TX Endpoint Stall - Read/Write
0 End Point OK
1 End Point Stalled
This bit will be cleared automatically upon receipt of a SETUP request if this Endpoint is configured as a
Control Endpoint and this bit will continue to be cleared by hardware until the associated
ENDPTSETUPSTAT bit is cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
15–8
-
This field is reserved.
Reserved
7
RXE
RX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
6
RXR
RX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3883

<!-- page 3884 -->

USB_nENDPTCTRL2 field descriptions (continued)
Field
Description
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the host and device.
5
RXI
RX Data Toggle Inhibit
0 Disabled [Default]
1 Enabled
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always accept data packet regardless of their data PID.
4
-
This field is reserved.
Reserved.
3–2
RXT
RX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
1
RXD
RX Endpoint Data Sink - Read/Write
0 Dual Port Memory Buffer/DMA Engine [Default]
Should always be written as zero.
0
RXS
RX Endpoint Stall - Read/Write
0 End Point OK. [Default]
1 End Point Stalled
This bit is set automatically upon receipt of a SETUP request if this Endpoint is configured as a Control
Endpointand this bit will continue to be cleared by hardware until the associated ENDPTSETUPSTAT bit is
cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
56.6.42
Endpoint Control 3 (USB_nENDPTCTRL3)
This is endpoint control register for endpoint 3 in device operation mode.
NOTE
If one endpoint direction is enabled and the paired endpoint of
opposite direction is disabled then the unused direction type
must be changed from the default control-type to any other type
(that is Bulk-type). leaving an unconfigured endpoint control
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3884
NXP Semiconductors

<!-- page 3885 -->

causes undefined behavior for the data pid tracking on the
active endpoint/direction.
Address: 218_4000h base + 1CCh offset + (512d × i), where i=0d to 1d
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
TXE
TXR
TXI
Reserved
TXT
TXD
TXS
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
RXE
RXR
RXI
Reserved
RXT
RXD
RXS
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
USB_nENDPTCTRL3 field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
TXE
TX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
22
TXR
TX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the Host and device.
21
TXI
TX Data Toggle Inhibit
0 PID Sequencing Enabled. [Default]
1 PID Sequencing Disabled.
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always transmit DATA0 for a data packet.
20
-
This field is reserved.
Reserved
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3885

<!-- page 3886 -->

USB_nENDPTCTRL3 field descriptions (continued)
Field
Description
19–18
TXT
TX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
17
TXD
TX Endpoint Data Source - Read/Write
0 Dual Port Memory Buffer/DMA Engine [DEFAULT]
Should always be written as 0.
16
TXS
TX Endpoint Stall - Read/Write
0 End Point OK
1 End Point Stalled
This bit will be cleared automatically upon receipt of a SETUP request if this Endpoint is configured as a
Control Endpoint and this bit will continue to be cleared by hardware until the associated
ENDPTSETUPSTAT bit is cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
15–8
-
This field is reserved.
Reserved
7
RXE
RX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
6
RXR
RX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the host and device.
5
RXI
RX Data Toggle Inhibit
0 Disabled [Default]
1 Enabled
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always accept data packet regardless of their data PID.
4
-
This field is reserved.
Reserved.
3–2
RXT
RX Endpoint Type - Read/Write
00 Control
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3886
NXP Semiconductors

<!-- page 3887 -->

USB_nENDPTCTRL3 field descriptions (continued)
Field
Description
01 Isochronous
10 Bulk
11 Interrupt
1
RXD
RX Endpoint Data Sink - Read/Write
0 Dual Port Memory Buffer/DMA Engine [Default]
Should always be written as zero.
0
RXS
RX Endpoint Stall - Read/Write
0 End Point OK. [Default]
1 End Point Stalled
This bit is set automatically upon receipt of a SETUP request if this Endpoint is configured as a Control
Endpointand this bit will continue to be cleared by hardware until the associated ENDPTSETUPSTAT bit is
cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
56.6.43
Endpoint Control 4 (USB_nENDPTCTRL4)
This is endpoint control register for endpoint 4 in device operation mode.
NOTE
If one endpoint direction is enabled and the paired endpoint of
opposite direction is disabled then the unused direction type
must be changed from the default control-type to any other type
(that is Bulk-type). leaving an unconfigured endpoint control
causes undefined behavior for the data pid tracking on the
active endpoint/direction.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3887

<!-- page 3888 -->

Address: 218_4000h base + 1D0h offset + (512d × i), where i=0d to 1d
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
TXE
TXR
TXI
Reserved
TXT
TXD
TXS
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
RXE
RXR
RXI
Reserved
RXT
RXD
RXS
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
USB_nENDPTCTRL4 field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
TXE
TX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
22
TXR
TX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the Host and device.
21
TXI
TX Data Toggle Inhibit
0 PID Sequencing Enabled. [Default]
1 PID Sequencing Disabled.
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always transmit DATA0 for a data packet.
20
-
This field is reserved.
Reserved
19–18
TXT
TX Endpoint Type - Read/Write
00 Control
01 Isochronous
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3888
NXP Semiconductors

<!-- page 3889 -->

USB_nENDPTCTRL4 field descriptions (continued)
Field
Description
10 Bulk
11 Interrupt
17
TXD
TX Endpoint Data Source - Read/Write
0 Dual Port Memory Buffer/DMA Engine [DEFAULT]
Should always be written as 0.
16
TXS
TX Endpoint Stall - Read/Write
0 End Point OK
1 End Point Stalled
This bit will be cleared automatically upon receipt of a SETUP request if this Endpoint is configured as a
Control Endpoint and this bit will continue to be cleared by hardware until the associated
ENDPTSETUPSTAT bit is cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
15–8
-
This field is reserved.
Reserved
7
RXE
RX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
6
RXR
RX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the host and device.
5
RXI
RX Data Toggle Inhibit
0 Disabled [Default]
1 Enabled
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always accept data packet regardless of their data PID.
4
-
This field is reserved.
Reserved.
3–2
RXT
RX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3889

<!-- page 3890 -->

USB_nENDPTCTRL4 field descriptions (continued)
Field
Description
1
RXD
RX Endpoint Data Sink - Read/Write
0 Dual Port Memory Buffer/DMA Engine [Default]
Should always be written as zero.
0
RXS
RX Endpoint Stall - Read/Write
0 End Point OK. [Default]
1 End Point Stalled
This bit is set automatically upon receipt of a SETUP request if this Endpoint is configured as a Control
Endpointand this bit will continue to be cleared by hardware until the associated ENDPTSETUPSTAT bit is
cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
56.6.44
Endpoint Control 5 (USB_nENDPTCTRL5)
This is endpoint control register for endpoint 5 in device operation mode.
NOTE
If one endpoint direction is enabled and the paired endpoint of
opposite direction is disabled then the unused direction type
must be changed from the default control-type to any other type
(that is Bulk-type). leaving an unconfigured endpoint control
causes undefined behavior for the data pid tracking on the
active endpoint/direction.
Address: 218_4000h base + 1D4h offset + (512d × i), where i=0d to 1d
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
TXE
TXR
TXI
Reserved
TXT
TXD
TXS
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
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3890
NXP Semiconductors

<!-- page 3891 -->

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
RXE
RXR
RXI
Reserved
RXT
RXD
RXS
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
USB_nENDPTCTRL5 field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
TXE
TX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
22
TXR
TX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the Host and device.
21
TXI
TX Data Toggle Inhibit
0 PID Sequencing Enabled. [Default]
1 PID Sequencing Disabled.
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always transmit DATA0 for a data packet.
20
-
This field is reserved.
Reserved
19–18
TXT
TX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
17
TXD
TX Endpoint Data Source - Read/Write
0 Dual Port Memory Buffer/DMA Engine [DEFAULT]
Should always be written as 0.
16
TXS
TX Endpoint Stall - Read/Write
0 End Point OK
1 End Point Stalled
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3891

<!-- page 3892 -->

USB_nENDPTCTRL5 field descriptions (continued)
Field
Description
This bit will be cleared automatically upon receipt of a SETUP request if this Endpoint is configured as a
Control Endpoint and this bit will continue to be cleared by hardware until the associated
ENDPTSETUPSTAT bit is cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
15–8
-
This field is reserved.
Reserved
7
RXE
RX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
6
RXR
RX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the host and device.
5
RXI
RX Data Toggle Inhibit
0 Disabled [Default]
1 Enabled
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always accept data packet regardless of their data PID.
4
-
This field is reserved.
Reserved.
3–2
RXT
RX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
1
RXD
RX Endpoint Data Sink - Read/Write
0 Dual Port Memory Buffer/DMA Engine [Default]
Should always be written as zero.
0
RXS
RX Endpoint Stall - Read/Write
0 End Point OK. [Default]
1 End Point Stalled
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3892
NXP Semiconductors

<!-- page 3893 -->

USB_nENDPTCTRL5 field descriptions (continued)
Field
Description
This bit is set automatically upon receipt of a SETUP request if this Endpoint is configured as a Control
Endpointand this bit will continue to be cleared by hardware until the associated ENDPTSETUPSTAT bit is
cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
56.6.45
Endpoint Control 6 (USB_nENDPTCTRL6)
This is endpoint control register for endpoint 6 in device operation mode.
NOTE
If one endpoint direction is enabled and the paired endpoint of
opposite direction is disabled then the unused direction type
must be changed from the default control-type to any other type
(that is Bulk-type). leaving an unconfigured endpoint control
causes undefined behavior for the data pid tracking on the
active endpoint/direction.
Address: 218_4000h base + 1D8h offset + (512d × i), where i=0d to 1d
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
TXE
TXR
TXI
Reserved
TXT
TXD
TXS
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
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3893

<!-- page 3894 -->

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
RXE
RXR
RXI
Reserved
RXT
RXD
RXS
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
USB_nENDPTCTRL6 field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
TXE
TX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
22
TXR
TX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the Host and device.
21
TXI
TX Data Toggle Inhibit
0 PID Sequencing Enabled. [Default]
1 PID Sequencing Disabled.
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always transmit DATA0 for a data packet.
20
-
This field is reserved.
Reserved
19–18
TXT
TX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
17
TXD
TX Endpoint Data Source - Read/Write
0 Dual Port Memory Buffer/DMA Engine [DEFAULT]
Should always be written as 0.
16
TXS
TX Endpoint Stall - Read/Write
0 End Point OK
1 End Point Stalled
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3894
NXP Semiconductors

<!-- page 3895 -->

USB_nENDPTCTRL6 field descriptions (continued)
Field
Description
This bit will be cleared automatically upon receipt of a SETUP request if this Endpoint is configured as a
Control Endpoint and this bit will continue to be cleared by hardware until the associated
ENDPTSETUPSTAT bit is cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
15–8
-
This field is reserved.
Reserved
7
RXE
RX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
6
RXR
RX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the host and device.
5
RXI
RX Data Toggle Inhibit
0 Disabled [Default]
1 Enabled
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always accept data packet regardless of their data PID.
4
-
This field is reserved.
Reserved.
3–2
RXT
RX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
1
RXD
RX Endpoint Data Sink - Read/Write
0 Dual Port Memory Buffer/DMA Engine [Default]
Should always be written as zero.
0
RXS
RX Endpoint Stall - Read/Write
0 End Point OK. [Default]
1 End Point Stalled
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3895

<!-- page 3896 -->

USB_nENDPTCTRL6 field descriptions (continued)
Field
Description
This bit is set automatically upon receipt of a SETUP request if this Endpoint is configured as a Control
Endpointand this bit will continue to be cleared by hardware until the associated ENDPTSETUPSTAT bit is
cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
56.6.46
Endpoint Control 7 (USB_nENDPTCTRL7)
This is endpoint control register for endpoint 7 in device operation mode.
NOTE
If one endpoint direction is enabled and the paired endpoint of
opposite direction is disabled then the unused direction type
must be changed from the default control-type to any other type
(that is Bulk-type). leaving an unconfigured endpoint control
causes undefined behavior for the data pid tracking on the
active endpoint/direction.
Address: 218_4000h base + 1DCh offset + (512d × i), where i=0d to 1d
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
TXE
TXR
TXI
Reserved
TXT
TXD
TXS
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
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3896
NXP Semiconductors

<!-- page 3897 -->

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
RXE
RXR
RXI
Reserved
RXT
RXD
RXS
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
USB_nENDPTCTRL7 field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
TXE
TX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
22
TXR
TX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the Host and device.
21
TXI
TX Data Toggle Inhibit
0 PID Sequencing Enabled. [Default]
1 PID Sequencing Disabled.
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always transmit DATA0 for a data packet.
20
-
This field is reserved.
Reserved
19–18
TXT
TX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
17
TXD
TX Endpoint Data Source - Read/Write
0 Dual Port Memory Buffer/DMA Engine [DEFAULT]
Should always be written as 0.
16
TXS
TX Endpoint Stall - Read/Write
0 End Point OK
1 End Point Stalled
Table continues on the next page...
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3897

<!-- page 3898 -->

USB_nENDPTCTRL7 field descriptions (continued)
Field
Description
This bit will be cleared automatically upon receipt of a SETUP request if this Endpoint is configured as a
Control Endpoint and this bit will continue to be cleared by hardware until the associated
ENDPTSETUPSTAT bit is cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
15–8
-
This field is reserved.
Reserved
7
RXE
RX Endpoint Enable
0 Disabled [Default]
1 Enabled
An Endpoint should be enabled only after it has been configured.
6
RXR
RX Data Toggle Reset (WS)
Write 1 - Reset PID Sequence
Whenever a configuration event is received for this Endpoint, software must write a one to this bit in order
to synchronize the data PID's between the host and device.
5
RXI
RX Data Toggle Inhibit
0 Disabled [Default]
1 Enabled
This bit is only used for test and should always be written as zero. Writing a one to this bit causes this
endpoint to ignore the data toggle sequence and always accept data packet regardless of their data PID.
4
-
This field is reserved.
Reserved.
3–2
RXT
RX Endpoint Type - Read/Write
00 Control
01 Isochronous
10 Bulk
11 Interrupt
1
RXD
RX Endpoint Data Sink - Read/Write
0 Dual Port Memory Buffer/DMA Engine [Default]
Should always be written as zero.
0
RXS
RX Endpoint Stall - Read/Write
0 End Point OK. [Default]
1 End Point Stalled
Table continues on the next page...
USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3898
NXP Semiconductors

<!-- page 3899 -->

USB_nENDPTCTRL7 field descriptions (continued)
Field
Description
This bit is set automatically upon receipt of a SETUP request if this Endpoint is configured as a Control
Endpointand this bit will continue to be cleared by hardware until the associated ENDPTSETUPSTAT bit is
cleared.
Software can write a one to this bit to force the endpoint to return a STALL handshake to the Host. This
control will continue to STALL until this bit is either cleared by software or automatically cleared as above
for control endpoints.
NOTE: [CONTROL ENDPOINT TYPES ONLY]: there is a slight delay (50 clocks max) between the
ENDPTSETUPSTAT begin cleared and hardware continuing to clear this bit. In most systems, it
is unlikely the DCD software will observe this delay. However, should the DCD observe that the
stall bit is not set after writing a one to it then follow this procedure: continually write this stall bit
until it is set or until a new setup has been received by checking the associated endptsetupstat
bit.
Chapter 56 Universal Serial Bus Controller (USB)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3899

<!-- page 3900 -->

USB Core Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3900
NXP Semiconductors

