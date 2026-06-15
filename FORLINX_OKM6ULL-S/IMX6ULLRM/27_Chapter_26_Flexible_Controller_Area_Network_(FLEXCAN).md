# Chapter 26: Flexible Controller Area Network (FLEXCAN)

> Nguồn: `IMX6ULLRM.pdf` — trang 1245–1324

<!-- page 1245 -->

Chapter 26
Flexible Controller Area Network (FLEXCAN)
26.1
Overview
The Flexible Controller Area Network (FLEXCAN) module is a communication
controller implementing the CAN protocol according to the CAN 2.0B protocol
specification.
The CAN protocol was primarily designed to be used as a vehicle serial data bus meeting
the specific requirements of this field: real-time processing, reliable operation in the EMI
environment of a vehicle, cost-effectiveness and required bandwidth. The FLEXCAN
module is a full implementation of the CAN protocol specification, which supports both
standard and extended message frames. 64 Message Buffers are supported by the Flexcan
module.
26.1.1
Block Diagram
A general block diagram is shown in the figure below,which describes the main sub-
blocks implemented in the FLEXCAN module, including the associated memory for
storing Mailboxes, Rx Global Mask Registers, Rx Individual Mask Registers, Rx FIFO
and Rx FIFO ID Filters.
Support for 64 Mailboxes and 6-deep Rx FIFO is provided. The functions of the sub-
modules are described in subsequent sections.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1245

<!-- page 1246 -->

MB 0
MB 1
MB 5
MB 63
IPS
CAN Bus
Tx Pin
RX Pin
Protocol
Engine
FlexCAN
IRQs
Registers
Rx
Match
Tx
Arbitration
Control 
Host
Interface
RAM
Figure 26-1. FLEXCAN Block Diagram
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1246
NXP Semiconductors

<!-- page 1247 -->

26.1.2
FLEXCAN Module Features
The FLEXCAN module includes these distinctive legacy features:
• Version 2.0B
• Standard data and remote frames
• Extended data and remote frames
• Zero to eight bytes data length
• Programmable bit rate up to 1 Mb/sec
• Content-related addressing
• Flexible Mailboxes of eight bytes data length
• Each Mailbox is configurable as Rx or Tx, all supporting standard and extended
messages
• Individual Rx Mask Registers per Mailbox
• Full featured Rx FIFO with storage capacity for 6 frames and internal pointer
handling
• Transmission abort capability
• Powerful Rx FIFO ID filtering, capable of matching incoming IDs against either 128
extended, 256 standard or 512 partial (8 bits) IDs, with up to 32 individual masking
capability
• 100% backwards compatibility with previous FLEXCAN version
• Unused structures space can be used as general purpose RAM space
• Listen only mode capability
• Programmable loop-back mode supporting self-test operation
• Programmable transmission priority scheme: lowest ID, lowest buffer number or
highest priority
• Time Stamp based on 16-bit free-running timer
• Global network time, synchronized by a specific message
• Maskable interrupts independent of the transmission medium (an external transceiver
is assumed)
• Short latency time due to an arbitration scheme for high-priority messages
• Low power modes, with programmable wake up on bus activity
• Configurable Glitch filter width to filter the noise on CAN bus when waking up
• Remote request frames may be handled automatically or by software.
• ID filter configuration in Normal Mode
• CAN bit time settings and configuration bits can only be written in Freeze Mode
• Tx mailbox status (Lowest priority buffer or empty buffer)
• SYNC bit status to inform that the module is synchronous with CAN bus
• CRC status for transmitted message
• Selectable priority between Mailboxes and Rx FIFO during matching process
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1247

<!-- page 1248 -->

26.1.3
Modes of Operation
The FLEXCAN module has four functional modes: Normal Mode (User and Supervisor),
Freeze Mode, Listen-Only Mode and Loop-Back Mode. There are also two low power
modes: Disable Mode and Stop Mode.
• Normal Mode (User or Supervisor):
In Normal Mode, the module operates receiving and/or transmitting message frames,
errors are handled normally and all the CAN Protocol functions are enabled. User and
Supervisor Modes differ in the access to some restricted control registers.
• Freeze Mode:
It is enabled when the FRZ bit in the MCR Register is asserted. If enabled, Freeze Mode
is entered when the HALT bit in MCR is set or when Debug Mode is requested at MCU
level and the FRZ_ACK bit in the MCR Register is asserted by the FlexCAN. In this
mode, no transmission or reception of frames is done and synchronicity to the CAN bus
is lost. See Freeze Mode for more information.
• Listen-Only Mode:
The module enters this mode when the LOM bit in the Control Register is asserted. In
this mode, transmission is disabled, all error counters are frozen and the module operates
in a CAN Error Passive mode. Only messages acknowledged by another CAN station
will be received. If FLEXCAN detects a message that has not been acknowledged, it will
flag a BIT0 error (without changing the REC), as if it was trying to acknowledge the
message.
• Loop-Back Mode:
The module enters this mode when the LPB bit in the Control Register is asserted. In this
mode, FLEXCAN performs an internal loop back that can be used for self test operation.
The bit stream output of the transmitter is internally fed back to the receiver input. The
FLEXCAN_RX input pin is ignored and the FLEXCAN_TX output goes to the recessive
state (logic '1'). FLEXCAN behaves as it normally does when transmitting and treats its
own transmitted message as a message received from a remote node. In this mode,
FLEXCAN ignores the bit sent during the ACK slot in the CAN frame acknowledge field
to ensure proper reception of its own message. Both transmit and receive interrupts are
generated.
• Module Disable Mode:
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1248
NXP Semiconductors

<!-- page 1249 -->

This low power mode is entered when the MDIS bit in the MCR Register is asserted and
the LPM_ACK is asserted by the FlexCAN. When disabled, the module requests to
disable the clocks to the CAN Protocol Engine and Controller Host Interface sub-
modules. Exit from this mode is done by negating the MDIS bit in the MCR Register. See
Module Disable Mode for more information.
• Stop Mode:
This low power mode is entered when Stop Mode is requested at Arm level and the
LPM_ACK bit in the MCR Register is asserted by the FlexCAN. When in Stop Mode,
the module puts itself in an inactive state and then informs the Arm that the clocks can be
shut down globally. Exit from this mode happens when the Stop Mode request is
removed or when activity is detected on the CAN bus and the Self Wake Up mechanism
is enabled. See Stop Mode for more information.
26.2
External Signals
The FLEXCAN module has two I/O signals.
Table 26-1. FLEXCAN External Signals
Signal
Description
Pad
Mode
Direction
FLEXCAN1_RX
FLEXCAN receive pin. This pin is
the receive pin from the CAN bus
transceiver. Dominant state is
represented by logic level '0'.
Recessive state is represented by
logic level '1'.
ENET1_RX_DATA1
ALT4
I
LCD_DATA09
ALT8
SD1_DATA1
ALT3
UART3_RTS_B
ALT2
FLEXCAN1_TX
FLEXCAN transmit pin. This pin is
the transmit pin to the CAN bus
transceiver. Dominant state is
represented by logic level '0'.
Recessive state is represented by
logic level '1'.
ENET1_RX_DATA0
ALT4
O
LCD_DATA08
ALT8
SD1_DATA0
ALT3
UART3_CTS_B
ALT2
FLEXCAN2_RX
FLEXCAN receive pin. This pin is
the receive pin from the CAN bus
transceiver. Dominant state is
represented by logic level '0'.
Recessive state is represented by
logic level '1'.
ENET1_TX_DATA0
ALT4
I
LCD_DATA11
ALT8
SD1_DATA3
ALT3
UART2_RTS_B
ALT2
FLEXCAN2_TX
FLEXCAN transmit pin. This pin is
the transmit pin to the CAN bus
transceiver. Dominant state is
represented by logic level '0'.
Recessive state is represented by
logic level '1'.
ENET1_RX_EN
ALT4
O
LCD_DATA10
ALT8
SD1_DATA2
ALT3
UART2_CTS_B
ALT2
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1249

<!-- page 1250 -->

26.3
Clocks
The table found here describes the clock sources for FLEXCAN.
Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 26-2. FLEXCAN Clocks
Clock name
Clock Root
Description
ipg_clk
ipg_clk_root
Peripheral clock
ipg_clk_chi
ipg_clk_root
CHI clock
ipg_clk_pe
can_clk_root
Protocol Engine clock
ipg_clk_pe_nogate
can_clk_root
Protocol Engine clock (no gating)
ipg_clk_s
ipg_clk_root
Peripheral access clock
mem_ram_CLK
ipg_clk_root
RAM clock
26.4
Message Buffer Structure
Message Buffer Address: Base + 0x0080-0x047C.
The Message Buffer structure used by the FLEXCAN module is represented in the
following table.
Both Extended and Standard Frames (29-bit Identifier and 11-bit Identifier, respectively)
used in the CAN specification are represented.
Each individual Message buffer is formed by 16 bytes.
Table 26-3. Message Buffer Structure
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
0x0
CODE
S
R
R
I
D
E
R
T
R
DLC
TIME STAMP
0x4
PRIO
ID Standard
ID Extended
0x8
DATA BYTE 0
DATA BYTE 1
DATA BYTE 2
DATA BYTE 3
0xC DATA BYTE 4
DATA BYTE 5
DATA BYTE 6
DATA BYTE 7
CODE - Message Buffer Code
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1250
NXP Semiconductors

<!-- page 1251 -->

This 4-bit field can be accessed (read or write) by the CPU and by the FLEXCAN
module itself, as part of the message buffer matching and arbitration process. The
encoding is shown in the following tables. See Functional Description for additional
information.
Table 26-4. Message Buffer Code for Rx buffers
CODE Description
Rx Code
BEFORE
receive
New
Frame
SRV1
Rx Code
AFTER
successfu
l
reception2
RRS3
Comment
0b0000: INACTIVE-
MB is not active.
INACTIVE
-
-
-
MB does not participate in the matching
process.
0b0100: EMPTY -
MB is active and
empty.
EMPTY
-
FULL
-
When a frame is received successfully (after
move-in process. Refer to Move-in for details),
the CODE field is automatically updated to
FULL.
0b0010: FULL -
MB is full.
FULL
Yes
FULL
-
The act of reading the C/S word followed by
unlocking the MB (SRV) does not make the
code return to EMPTY. It remains FULL. If a
new frame is moved to the MB after the MB
was serviced, the code still remains FULL.
Refer to Matching Process for matching details
related to FULL code.
No
OVERRUN
-
If the MB is FULL and a new frame is moved to
this MB before the CPU services it, the CODE
field is automatically updated to OVERRUN.
Refer to Matching Process for details about
overrun behavior.
0b0110: OVERRUN -
MB is being overwritten
into a full buffer.
OVERRUN
Yes
FULL
-
If the CODE field indicates OVERRUN and
CPU has serviced the MB, when a new frame
is moved to the MB, the code returns to FULL.
No
OVERRUN
-
If the CODE field already indicates OVERRUN,
and another new frame must be moved, the MB
will be overwritten again, and the code will
remain OVERRUN. Refer to Matching Process
for details about overrun behavior.
0b1010: RANSWER4 -
A frame was configured
to recognize a Remote
Request Frame and
transmit a Response
Frame in return.
RANSWER
-
TANSWER(
0b1110)
0
A Remote Answer was configured to recognize
a remote request frame received, after that a
MB is set to transmit a response frame. The
code is automatically changed to TANSWER
(0b1110). Refer to Matching Process for
details.
If CTRL2[RRS] is negated, transmit a response
frame whenever a remote request frame with
the same ID is received.
-
1
This code is ignored during matching and
arbitration process. Refer to Matching Process
for details.
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1251

<!-- page 1252 -->

Table 26-4. Message Buffer Code for Rx buffers (continued)
CODE Description
Rx Code
BEFORE
receive
New
Frame
SRV1
Rx Code
AFTER
successfu
l
reception2
RRS3
Comment
CODE[0]=1b1: BUSY -
FlexCAN is updating
the contents of the MB.
The CPU must not
access the MB.
BUSY5
-
FULL
-
Indicates that the MB is being updated, it will be
negated automatically and does not interfere on
the next CODE.
OVERRUN
-
1.
SRV: Serviced MB. MB was read and unlocked by reading TIMER or other MB.
2.
A frame is considered successful reception after the frame to be moved to MB (move-in process). Refer to Move-in for
details)
3.
Remote Request Stored bit from CTRL2 register. Refer to CTRL2 for details.
4.
Code 4'b1010 is not considered as a Tx and a MB with this code should not to be aborted.
5.
Note that for Tx MBs, the BUSY bit should be ignored upon read, except when AEN bit is set in the MCR register. If this bit
is asserted, the corresponding MB does not participate in the matching process.
Table 26-5. Message Buffer Code for Tx buffers
CODE Description
Tx Code
BEFORE tx
frame
MB
RT
R
Tx Code
AFTER
successful
transmissio
n
Comment
0b1000: INACTIVE -
MB is not active
INACTIVE
-
-
MB does not participate in the arbitration process.
0b1001: ABORT -
MB is aborted
ABORT
-
-
MB does not participate in the arbitration process.
0b1100: DATA -
MB is a Tx Data
Frame (MB RTR
must be 0)
DATA
0
INACTIVE
Transmit data frame unconditionally once. After transmission, the
MB automatically returns to the INACTIVE state.
0b1100: REMOTE -
MB is a Tx Remote
Request Frame (MB
RTR must be 1)
REMOTE
1
EMPTY
Transmit remote request frame unconditionally once. After
transmission, the MB automatically becomes an Rx Empty MB
with the same ID.
0b1110: TANSWER
- MB is a Tx
Response Frame
from an incoming
Remote Request
Frame
TANSWER
-
RANSWER
This is an intermediate code that is automatically written to the
MB by the CHI as a result of match to a remote request frame.
The remote response frame will be transmitted unconditionally
once and then the code will automatically return to RANSWER
(0b1010). The CPU can also write this code with the same effect.
The remote response frame can be either a data frame or
another remote request frame depending on the RTR bit value.
Refer to Matching Process and Arbitration process for details.
SRR - Substitute Remote Request
Message Buffer Structure
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1252
NXP Semiconductors

<!-- page 1253 -->

Fixed recessive bit, used only in extended format. It must be set to '1' by the user for
transmission (Tx Buffers) and will be stored with the value received on the CAN bus for
Rx receiving buffers. It can be received as either recessive or dominant. If FLEXCAN
receives this bit as dominant, then it is interpreted as arbitration loss.
1= Recessive value is compulsory for transmission in Extended Format frames
0= Dominant is not a valid value for transmission in Extended Format frames
IDE - ID Extended Bit
This bit identifies whether the frame format is standard or extended. It is also used as part
of the reception filter.
1= Frame format is extended
0= Frame format is standard
RTR - Remote Transmission Request
This bit affects the behavior of Remote Frames and is part of the reception filter. Refer to
the tables above and RRS bit in Control 2 Register (FLEXCAN_CTRL2) for additional
details.
If FLEXCAN transmits this bit as '1' (recessive) and receives it as '0' (dominant), it is
interpreted as arbitration loss. If this bit is transmitted as '0' (dominant), then if it is
received as '1' (recessive), the FLEXCAN module treats it as bit error. If the value
received matches the value transmitted, it is considered as a successful bit transmission.
1= Indicates the current MB has a Remote Frame to be transmitted if MB is Tx. If the
MB is Rx then incoming Remote Request Frames may be stored.
0= Indicates the current MB has a Data Frame to be transmitted. In Rx MB it may be
considered in matching processes.
DLC - Length of Data in Bytes
This 4-bit field is the length (in bytes) of the Rx or Tx data, which is located in offset
0x08 through 0x0F of the MB space (see the first table above). In reception, this field is
written by the FLEXCAN module, copied from the DLC (Data Length Code) field of the
received frame. In transmission, this field is written by the Arm and corresponds to the
DLC field value of the frame to be transmitted. When RTR=1, the Frame to be
transmitted is a Remote Frame and does not include the data field, regardless of the
Length field. The DLC field indicates which DATA BYTEs are valid as shown in the
table below.
TIME STAMP - Free-Running Counter Time Stamp
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1253

<!-- page 1254 -->

This 16-bit field is a copy of the Free-Running Timer, captured for Tx and Rx frames at
the time when the beginning of the Identifier field appears on the CAN bus.
PRIO - Local priority
This 3-bit field is only used when MCR[LPRIO_EN] bit is asserted and it only makes
sense for Tx mailboxes. These bits are not transmitted. They are appended to the regular
ID to define the transmission priority. See Arbitration process.
ID - Frame Identifier
In Standard Frame format, only the 11 most significant bits (28 to 18) are used for frame
identification in both receive and transmit cases. The 18 least significant bits are ignored.
In Extended Frame format, all bits are used for frame identification in both receive and
transmit cases.
DATA BYTE 0-7 - Data Field
Up to eight bytes can be used for a data frame.
For Rx frames, the data is stored as it is received from the CAN bus. DATA BYTE (n) is
valid only if n is less than DLC as shown in the table below.
For Tx frames, the CPU prepares the data field to be transmitted within the frame.
Table 26-6. DATA BYTEs validity
DLC
Valid DATA BYTEs
0
none
1
DATA BYTE 0
2
DATA BYTE 0-1
3
DATA BYTE 0-2
4
DATA BYTE 0-3
5
DATA BYTE 0-4
6
DATA BYTE 0-5
7
DATA BYTE 0-6
8
DATA BYTE 0-7
26.5
Rx FIFO Structure
When the MCR[RFEN] bit is set, the memory area from 0x80 to 0xDC (which is
normally occupied by MBs 0 to 5) is used by the reception FIFO engine.
Rx FIFO Structure
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1254
NXP Semiconductors

<!-- page 1255 -->

The region 0x80-0x8C contains the output of the FIFO which must be read by the CPU as
a Message Buffer. This output contains the oldest message received and not read yet. The
region 0x90-0xDC is reserved for internal use of the FIFO engine.
An additional memory area, that starts at 0xE0 and may extend up to 0x2DC (normally
occupied by MBs 6 up to 37) depending on the CTRL2[RFFN] field setting, contains the
ID Filter Table (configurable from 8 to 128 memory positions) that specifies filtering
criteria for accepting frames into the FIFO.Table 26-7 shows the Rx FIFO data structure.
Each ID Filter Table Element occupies an entire 32-bit word and can be compounded by
one, two or four Identifier Acceptance Filters (IDAF) depending on the MCR[IDAM]
field setting. Table 26-8, Table 26-9 and Table 26-10 show the IDAF indexation. Table
26-11 show the three different formats that the IDAF can assume, depending on the
MCR[IDAM] field setting. Note that all elements of the table must have the same format.
See Rx FIFO for more information.
Out of reset, the ID Filter Table flexible memory area defaults to 0xE0 and only extends
to 0xFC, which corresponds to MBs 6 to 7 for RFFN=0.
Table 26-7. Rx FIFO Structure
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
0x80
S
R
R
I
D
E
R
T
R
DLC
TIME STAMP
0x84
ID Standard
ID Extended
0x88
Data Byte 0
Data Byte 1
Data Byte 2
Data Byte 3
0x8C
Data Byte 4
Data Byte 5
Data Byte 6
Data Byte 7
0x90
to
0xDC
Reserved
0xE0
ID Filter Table Element 0
0xE4
ID Filter Table Element 1
0xE8
to
0x2D
4
ID Filter Table Elements 2 through 125
0x2D
8
ID Filter Table Element 126
0x2D
C
ID Filter Table Element 127
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1255

<!-- page 1256 -->

Table 26-8. Position of ID Filter Table Elements in format A
Element 31
0
0
IDAF0
1
IDAF1
2
through
125
Identifier Acceptance Filter 2 through 125
126
IDAF126
127
IDAF127
Table 26-9. Position of ID Filter Table Elements in format B
Element 31
16 15
0
0
IDAF0
IDAF1
1
IDAF2
IDAF3
2
through
125
Identifier Acceptance Filter 4 through 251
126
IDAF252
IDAF253
127
IDAF254
IDAF255
Table 26-10. Position of ID Filter Table Elements in format C
Element 31
24 23
16 15
8
7
0
0
IDAF0
IDAF1
IDAF2
IDAF3
1
IDAF4
IDAF5
IDAF6
IDAF7
2
through
125
Identifier Acceptance Filter 8 through 503
126
IDAF504
IDAF505
IDAF506
IDAF507
127
IDAF508
IDAF509
IDAF510
IDAF511
Table 26-11. Identifier Acceptance Filter Format A,B and C
Format 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9
8
7
6
5
4
3
2
1
0
A
R
T
R
ID
E
RXIDA
(Standard = 29-19, Extended = 29-1)
B
R
T
R
ID
E
RXIDB_0
(Standard = 29-19, Extended = 29-16)
R
T
R
ID
E
RXIDB_1
(Standard = 13-3, Extended = 13-0)
C
RXIDC_0
RXIDC_1
RXIDC_2
RXIDC_3
Rx FIFO Structure
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1256
NXP Semiconductors

<!-- page 1257 -->

Table 26-11. Identifier Acceptance Filter Format A,B and C
(Std/Ext = 31-24)
(Std/Ext = 23-16)
(Std/Ext = 15-8)
(Std/Ext = 7-0)
RTR - Remote Frame
This bit specifies whether Remote Request Frames are accepted into the FIFO if they
match the target ID in Formats A and B. If Format C is chosen the acceptance does not
depend on whether the frame is a Remote Request Frame or not.
1= Remote Frames can be accepted and data frames are rejected
0= Remote Frames are rejected and data frames can be accepted
IDE - Extended Frame
Specifies if either Extended or Standard Format frames are accepted into the FIFO if they
match the target ID in Formats A and B. If Format C is chosen the acceptance does not
depend on whether the frame is of the Extended or Standard Format.
1= Extended frames can be accepted and standard frames are rejected
0= Extended frames are rejected and standard frames can be accepted
RXIDA - Rx Frame Identifier (Format A)
Specifies an ID to be used as acceptance criteria for the FIFO. In the Standard Format
(IDAF's or incoming frame's IDE bit is negated), only the 11 most significant bits (29 to
19 ) are used for frame identification. In the Extended Format (both IDAF's and incoming
frame's IDE are asserted), all bits are used.
RXIDB_0, RXIDB_1 - Rx Frame Identifier (Format B)
Specifies an ID to be used as acceptance criteria for the FIFO. In the Standard Format
(IDAF's or incoming frame's IDE bit is negated), the 11 most significant bits (29 to 19
and 13 to 3 ) are used for frame identification. In the Extended Format (both IDAF's and
incoming frame's IDE are asserted), all 14 bits of the field are compared with the 14 most
significant bits of the Identifier of the incoming frame. The 15 least significant bits of the
Identifier of an incoming Extended Format frame do not affect the acceptance.
RXIDC_0, RXIDC_1, RXIDC_2, RXIDC_3 - Rx Frame Identifier (Format C)
Specifies an ID to be used as acceptance criteria for the FIFO. In both Standard Format
and Extended Format, all 8 bits of the field are compared to the 8 most significant bits of
the Identifier of the incoming frame. The 3 least significant bits of the Identifier of an
incoming Standard Format frame and the 21 least significant bits of the Identifier of an
incoming Extended Format frame do not affect the acceptance.
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1257

<!-- page 1258 -->

26.6
Functional Description
This section provides a complete functional description of the block.
26.6.1
Functional Overview
The FLEXCAN module is a CAN protocol engine with a very flexible mailbox system
for transmitting and receiving CAN frames. The mailbox system consists of a set of 64
Message Buffers (MB) that store configuration and control data, time stamp, message ID
and data (see Message Buffer Structure). The memory corresponding to the first 38 MBs
can be configured to support a FIFO reception scheme with a powerful ID filtering
mechanism, capable of checking incoming frames against a table of IDs (up to 128
extended IDs or 256 standard IDs or 512 8-bit ID slices), with individual mask register
for up to 32 ID Filter Table elements. Simultaneous reception through FIFO and mailbox
is supported. For mailbox reception, a matching algorithm makes it possible to store
received frames only into MBs that have the same ID. A masking scheme makes it
possible to match the ID programmed on the MB with a range of Identifiers on received
CAN frames. For transmission, an arbitration algorithm decides the prioritization of MBs
to be transmitted based on the message ID (optionally augmented by 3 local priority bits)
or the MB ordering.
Before proceeding with the functional description, an important concept must be
explained. A Message Buffer is said to be "active" at a given time if it can participate in
both the Matching and Arbitration processes. An Rx MB with a 0b0000 code is inactive
(refer to Table 26-4). Similarly, a Tx MB with a 0b1000 or 0b1001 code is also inactive
(refer to Table 26-5).
26.6.2
Transmit Process
In order to transmit a CAN frame, the CPU must prepare a Message Buffer for
transmission by executing the procedure found here.
1. Check if the respective interruption bit is set and clear it.
2. If the MB is active (transmission pending), write the ABORT code (0b1001) to the
CODE field of the Control and Status word to request an abortion of the
transmission. Wait for the corresponding IFLAG to be asserted by polling the IFLAG
register or by the interrupt request if enabled by the respective IMASK. Then read
back the CODE field to check if the transmission was aborted or transmitted (see
Transmission Abort Mechanism). If backwards compatibility is desired (MCR[AEN]
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1258
NXP Semiconductors

<!-- page 1259 -->

bit negated), just write the INACTIVE code (0b1000) to the CODE field to inactivate
the MB but then the pending frame may be transmitted without notification (see
Message Buffer Inactivation).
3. Write the ID word.
4. Write the data bytes.
5. Write the DLC, Control and Code fields of the Control and Status word to activate
the MB.
Once the MB is activated, it will participate into the arbitration process and eventually be
transmitted according to its priority.
At the end of the successful transmission, the value of the Free Running Timer at the time
of the second bit of frame's Identifier field is written into the MB's Time Stamp field, the
CODE field in the Control and Status word is updated, the CRC Register is updated, a
status flag is set in the Interrupt Flag Register and an interrupt is generated if allowed by
the corresponding Interrupt Mask Register bit. The new CODE field after transmission
depends on the code that was used to activate the MB in step four (see Table 26-4 and
Table 26-5 in Message Buffer Structure).
When the Abort feature is enabled (MCR[AEN] bit is asserted), after the Interrupt Flag is
asserted for a Mailbox configured as transmit buffer, the Mailbox is blocked, therefore
the CPU is not able to update it until it negates the Interrupt Flag. It means that the CPU
must clear the corresponding IFLAG before starting to prepare this MB for a new
transmission or reception.
26.6.3
Arbitration process
The arbitration process scans the Mailboxes searching the Tx one that holds the message
to be sent in the next opportunity. This Mailbox is called the arbitration winner.
The scan starts from the lowest Mailbox number and runs toward the higher ones.
The arbitration process is triggered in the following events:
• From the CRC field of the CAN frame. The start point depends on the
CTRL2[TASD] field value. See Control 2 Register (FLEXCAN_CTRL2) for details.
• During the error delimiter field of the CAN frame
• During the Overload Delimiter field of a CAN frame.
• When the winner is inactivated and the CAN bus has still not reached the first bit of
the Intermission field.
• When Arm write to the C/S word of a winner MB and the CAN bus has still not
reached the first bit of the Intermission field.
• When CHI is in Idle state and Arm writes to the C/S word of any MB.
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1259

<!-- page 1260 -->

• When FlexCAN exits Bus Off state
• Upon leaving Freeze Mode or Low Power Mode
If the arbitration process does not manage to evaluate all Mailboxes before the CAN bus
has reached the first bit of the Intermission field the temporary arbitration winner is
invalidated and the FlexCAN will not compete for the CAN bus in the next opportunity.
The arbitration process selects the winner among the active Tx Mailboxes at the end of
the scan according to both CTRL1[LBUF] and MCR[LPRIO_EN] bits settings.
26.6.3.1
Lowest Mailbox number first
If CTRL1[LBUF] bit is asserted the first (lowest number) active Tx Mailbox found is the
arbitration winner. MCR[LPRIO_EN] bit has no effect when CTRL1[LBUF] is asserted.
26.6.3.2
Highest Mailbox priority first
If CTRL1[LBUF] bit is negated then the arbitration process searches the active Tx
Mailbox with the highest priority, and this Mailbox would have a higher probability to
win the arbitration on CAN bus.
The sequence of bits considered for this arbitration is called the arbitration value of the
Mailbox. The highest priority Tx Mailbox is the one that has the least arbitration value
among all Tx Mailboxes.
If two or more Mailboxes have equivalent arbitration values the lowest Mailbox number
is the arbitration winner.
The composition of the arbitration value depends on MCR[LPRIO_EN] bit setting.
26.6.3.2.1
Local Priority disabled
If MCR[LPRIO_EN] bit is negated the arbitration value is built in the exact sequence of
bits as they would be transmitted in a CAN frame (see Table 26-12) in such a way that
the Local Priority is disabled.
Table 26-12. Composition of the arbitration value when Local Priority is disabled
Format
Mailbox Arbitration Value (32 bits)
Standard
(IDE = 0)
Standard ID
(11 bits)
RTR
(1 bit)
IDE
(1 bit)
-
(18 bits)
-
(1 bit)
Extended
(IDE = 1)
Extended ID[28:18 ]
(11 bits)
SRR
(1 bit)
IDE
(1 bit)
Extended ID[17:0 ]
(18 bits)
RTR
(1 bit)
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1260
NXP Semiconductors

<!-- page 1261 -->

26.6.3.2.2
Local Priority enabled
If Local Priority is desired MCR[LPRIO_EN] must be asserted.
In this case the Mailbox PRIO field is included at the very left of the arbitration value
(see the table below).
Table 26-13. Composition of the arbitration value when Local Priority is enabled
Format
Mailbox Arbitration Value (35 bits)
Standard
(IDE = 0)
PRIO
(3 bits)
Standard ID
(11 bits)
RTR
(1 bit)
IDE
(1 bit)
-
(18 bits)
-
(1 bit)
Extended
(IDE = 1)
PRIO
(3 bits)
Extended ID[28:18 ](11 bits)
SRR
(1 bit)
IDE
(1 bit)
Extended ID[17:0 ]
(18 bits)
RTR
(1 bit)
As the PRIO field is the most significant part of the arbitration value Mailboxes with low
PRIO values have higher priority than Mailboxes with high PRIO values regardless the
rest of their arbitration values.
Note that the PRIO field is not part of the frame on the CAN bus. Its purpose is only to
affect the internal arbitration process.
Once the arbitration winner is found, its content is copied to a hidden auxiliary MB called
Tx Serial Message Buffer (Tx SMB), which has the same structure as a normal MB but is
not user accessible. This operation is called "move-out" and after it is done, write access
to the corresponding MB is blocked (if the AEN bit in MCR is asserted). The write
access is released in the following events:
• After the MB is transmitted
• FlexCAN enters in Freeze Mode or Bus Off
• FlexCAN loses the bus arbitration or there is an error during the transmission
At the first opportunity window on the CAN bus, the message on the Tx SMB is
transmitted according to the CAN protocol rules. FlexCAN transmits up to eight data
bytes, even if the DLC (Data Length Code) field value is greater than that.
Arbitration process can be triggered in the following situations:
• During Rx and Tx frames from CAN CRC field to end of frame. Arbitration start
point depends on instantiation parameters NUMBER_OF_MB and TASD.
Additionally, TASD value may be changed (see Control 2 Register
(FLEXCAN_CTRL2)) to optimize the arbitration start point.
• During CAN Bus Off state from TX_ERR_CNT=124 to 128. Arbitration start point
depends on instantiation parameters NUMBER_OF_MB and TASD. Additionally,
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1261

<!-- page 1262 -->

TASD value may be changed(see Control 2 Register (FLEXCAN_CTRL2)) to
optimize the arbitration start point.
• During C/S write by CPU in Bus Idle. First C/S write starts arbitration process and a
second C/S write during this same arbitration restarts the process. If other C/S writes
are performed, Tx arbitration process is pending. If there is no arbitration winner
after arbitration process has finished, then TX arbitration machine begins a new
arbitration process.
• Arbitration winner deactivation during a valid arbitration window.
• Upon Leave Freeze Mode. If there is a re-synchronization during WaitForBusIdle
arbitration process is restarted.
Arbitration process stops in the following situation:
• All Mailboxes were scanned.
• A Tx active Mailbox is found in case of Lowest Buffer feature enabled.
• Arbitration winner inactivation or abort during any arbitration process.
• There was not enough time to finish Tx arbitration process. For instance, a
deactivation was performed near the end of frame). In this case arbitration process is
pending.
• Error or Overload flag in the bus.
• Low Power or Freeze Mode request in Idle state
Arbitration is considered pending as described below:
• It was not possible to finish arbitration process in time.
• C/S write during arbitration if write is performed in a MB which number is lower
than the Tx arbitration pointer.
• Any C/S write if there is no Tx Arbitration process in progress.
• Rx Match has just updated a Rx Code to Tx Code.
• Entering Bus off state.
C/S write during arbitration has the following effect:
• If C/S write is performed in the arbitration winner, a new process is restarted
immediately.
• C/S write during arbitration if write is performed in a MB which number is higher
than the Tx arbitration pointer.
26.6.4
Receive Process
To be able to receive CAN frames into a Mailbox, the CPU must prepare it for reception
by executing the steps listed here.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1262
NXP Semiconductors

<!-- page 1263 -->

1. If the Mailbox is active (either Tx or Rx) inactivate the Mailbox (see Message Buffer
Inactivation), preferably with a safe inactivation (see Transmission Abort
Mechanism);
2. Write the ID word;
3. Write the EMPTY code (0b0100) to the CODE field of the Control and Status word
to activate the Mailbox.
Once the Mailbox is activated in the third step, it will be able to receive frames that
match the programmed filter. At the end of a successful reception, the Mailbox is updated
by the move-in process (see Move-in) as follows:
1. The received Data field (8 bytes at most) is stored;
2. The received Identifier field is stored;
3. The value of the Free Running Timer at the time of the second bit of frame's
Identifier field is written into the Mailbox Time Stamp field;
4. The received SRR, IDE, RTR and DLC fields are stored;
5. The CODE field in the Control and Status word is updated. (see Table 26-4 and
Table 26-5 in Section Message Buffer Structure)
6. A status flag is set in the Interrupt Flag Register and an interrupt is generated if
allowed by the corresponding Interrupt Mask Register bit.
The recommended way for the CPU servicing (read) the frame received in a Mailbox is
using the following procedure:
1. Read the Control and Status word of that Mailbox;
2. Check if the BUSY bit is deasserted, indicating that the Mailbox is locked. Repeat
step 1) while it is asserted. See Message Buffer Lock Mechanism;
3. Read the contents of the Mailbox. Once Mailbox is locked now, its contents won't be
modified by FlexCAN Move-in processes. See Move-in;
4. Acknowledge the proper flag at IFLAG registers;
5. Read the Free Running Timer. It is optional but recommended to unlock Mailbox as
soon as possible and make it available for reception.
The CPU should synchronize to frame reception by the status flag bit for the specific
Mailbox in one of the IFLAG Registers and not by the CODE field of that Mailbox.
Polling the CODE field does not work because once a frame was received and the CPU
services the Mailbox (by reading the C/S word followed by unlocking the Mailbox), the
CODE field will not return to EMPTY. It will remain FULL. If the CPU tries to
workaround this behavior by writing to the C/S word to force an EMPTY code after
reading the Mailbox without a prior safe inactivation, a newly received message
matching the filter of that Mailbox may be lost.
In summary: never do polling by reading directly the C/S word of the Mailboxes. Instead,
read the IFLAG registers.
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1263

<!-- page 1264 -->

Note that the received frame's Identifier field is always stored in the matching Mailbox,
thus the contents of the ID field in a Mailbox may change if the match was due to
masking. Note also that FlexCAN does receive frames transmitted by itself if there exists
a matching Rx Mailbox, provided the MCR[SRX_DIS] bit is not asserted. If
MCR[SRX_DIS] bit is asserted, FlexCAN will not store messages transmitted by itself in
any MB, even if it contains a matching MB, and no interrupt flag or interrupt signal will
be generated due to the frame reception.
To be able to receive CAN messages through the Rx FIFO, the CPU must enable and
configure the Rx FIFO during Freeze Mode(see Rx FIFO). Upon receiving the Frames
Available in Rx FIFO interrupt(see Interrupt Masks 1 Register (FLEXCAN_IMASK1),
bit IFLAG[BUF5I] - Frames available in Rx FIFO), the CPU should service the received
frame using the following procedure:
1. Read the Control and Status word (optional - needed only if a mask was used for IDE
and RTR bits);
2. Read the ID field (optional - needed only if a mask was used);
3. Read the Data field;
4. Read the RXFIR register (optional);
5. Clear the Frames Available in Rx FIFO interrupt by writing 1 to IFLAG[BUF5I] bit
(mandatory - releases the MB and allows the CPU to read the next Rx FIFO entry)
26.6.5
Matching Process
The matching process scans the MB memory looking for Rx MBs programmed with the
same ID as the one received from the CAN bus. If the FIFO is enabled, the priority of
scanning can be selected between Mailboxes and FIFO filters. In any case, the matching
starts from the lowest number Message Buffer toward the higher ones. If no match is
found within the first structure then the other is scanned subsequently. In the event that
the FIFO is full, the matching algorithm will always look for a matching MB outside the
FIFO region.
As the frame is being received, it is stored in a hidden auxiliary MB called Rx Serial
Message Buffer (Rx SMB).
The matching process start point depends on the following conditions:
• if the received frame is a remote frame, the start point is the CRC field of the frame;
• if the received frame is a data frame with DLC field equal to zero, the start point is
the CRC field of the frame;
• if the received frame is a data frame with DLC field different than zero, the start
point is the DATA field of the frame;
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1264
NXP Semiconductors

<!-- page 1265 -->

If a matching ID is found in the FIFO table or in one of the Mailboxes, the contents of the
SMB will be transferred to the FIFO or to the matched Mailbox by the move-in process.
If any CAN protocol error is detected then no match results will be transferred to the
FIFO or to the matched Mailbox at the end of reception.
The matching process scans all matching elements of both Rx FIFO (if enabled) and
active Rx Mailboxes (CODE is EMPTY, FULL, OVERRUN or RANSWER) in search of
a successful comparison with the matching elements of the Rx SMB that is receiving the
frame on the CAN bus. The SMB has the same structure of a Mailbox. The reception
structures (Rx FIFO or Mailboxes) associated with the matching elements that had a
successful comparison are the matched structures. The matching winner is selected at the
end of the scan among those matched structures and depends on conditions described
ahead. Refer to the following table for details.
Table 26-14. Matching architecture
Structure
SMB[RTR]
CTRL2[RRS]
CTRL2[EACEN]
MB[IDE]
MB[RTR]
MB[ID]1
MB[CODE]
Mailbox
0
-
0
cmp2
no_cmp3
cmp_msk4
EMPTY or
FULL or
OVERRUN
Mailbox
0
-
1
cmp_msk
cmp_msk
cmp_msk
EMPTY or
FULL or
OVERRUN
Mailbox
1
0
-
cmp
no_cmp
cmp
RANSWER
Mailbox
1
1
0
cmp
no_cmp
cmp_msk
EMPTY or
FULL or
OVERRUN
Mailbox
1
1
1
cmp_msk
cmp_msk
cmp_msk
EMPTY or
FULL or
OVERRUN
FIFO5
-
-
-
cmp_msk
cmp_msk
cmp_msk
-
1.
For Mailbox structure, If SMB[IDE] is asserted, the ID is 29 bits (ID Standard + ID Extended). In case of SMB[IDE] to be
negated, the ID is only 11 bits (ID Standard). Please, refer to Message Buffer Structure for ID details. For FIFO structure,
the ID depends on IDAM. Please, refer to Rx FIFO Structure for IDAM details.
2.
cmp: Compares the SMB contents with the MB contents regardless the masks.
3.
no_cmp: The SMB contents are not compared with the MB contents.
4.
cmp_msk: Compares the SMB contents with MB contents taking into account the masks.
5.
SMB[IDE] and SMB[RTR] are not taken into account when IDAM is type C.
A reception structure is free-to-receive when any of the following conditions is satisfied:
• the CODE field of the Mailbox is EMPTY;
• the CODE field of the Mailbox is either FULL or OVERRUN and it has already been
serviced (the C/S word was read by the Arm and unlocked as described in Message
Buffer Lock Mechanism);
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1265

<!-- page 1266 -->

• the CODE field of the Mailbox is either FULL or OVERRUN and an inactivation is
performed. (see Message Buffer Inactivation)
• the Rx FIFO is not full.
The scan order for Mailboxes and Rx FIFO is from the matching element with lowest
number to the higher ones.
The matching winner search for Mailboxes is affected by the MCR[IRMQ] bit. If it is
negated the matching winner is the first matched Mailbox regardless if it is free-to-
receive or not . If it is asserted, the matching winner is selected according to the priority
below:
1. the first free-to-receive matched Mailbox;
2. the last non free-to-receive matched Mailbox.
It is possible to select the priority of scan between Mailboxes and Rx FIFO by the
CTRL2[MRP] bit.
If the selected priority is Rx FIFO first:
• if the Rx FIFO is a matched structure and is free-to-receive then the Rx FIFO is the
matching winner regardless of the scan for Mailboxes;
• otherwise (the Rx FIFO is not a matched structure or is not free-to-receive), then the
matching winner is searched among Mailboxes as described above.
If the selected priority is Mailboxes first:
• if a free-to-receive matched Mailbox is found, it is the matching winner regardless
the scan for Rx FIFO;
• if no matched Mailbox is found, then the matching winner is searched in the scan for
the Rx FIFO;
• if both conditions above are not satisfied and a non free-to-receive matched Mailbox
is found then the matching winner determination is conditioned by the MCR[IRMQ]
bit:
• if MCR[IRMQ] bit is negated the matching winner is the first matched Mailbox;
• if MCR[IRMQ] bit is asserted the matching winner is the Rx FIFO if it is a free-
to-receive matched structure, otherwise the matching winner is the last non free-
to-receive matched Mailbox.
Please, refer to the table below for a summary of matching possibilities.
If a non-safe Mailbox inactivation (see Message Buffer Inactivation) occurs during
matching process and the Mailbox inactivated is the temporary matching winner then the
temporary matching winner is invalidated. The matching elements scan is not stopped nor
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1266
NXP Semiconductors

<!-- page 1267 -->

restarted, it continues normally. The consequence is that the current matching process
works as if the matching elements compared before the inactivation did not exist,
therefore a message may be lost.
Suppose, for example, that the FIFO is disabled, IRMQ is enabled and there are two MBs
with the same ID, and FlexCAN starts receiving messages with that ID. Let us say that
these MBs are the second and the fifth in the array. When the first message arrives, the
matching algorithm will find the first match in MB number 2. The code of this MB is
EMPTY, so the message is stored there. When the second message arrives, the matching
algorithm will find MB number 2 again, but it is not "free-to-receive", so it will keep
looking and find MB number 5 and store the message there. If yet another message with
the same ID arrives, the matching algorithm finds out that there are no matching MBs
that are "free-to-receive", so it decides to overwrite the last matched MB, which is
number 5. In doing so, it sets the CODE field of the MB to indicate OVERRUN.
Table 26-15. Matching Possibilities and Resulting Reception Structures
RFEN
IRMQ
MRP
Matched in MB
Matched in
FIFO
Reception
Structure
Description
No FIFO, only MB, match is always MB first
0
0
X1
None2
-3
None
Frame lost by no match
0
0
X
Free4
-
FirstMB
0
1
X
None
-
None
Frame lost by no match
0
1
X
Free
-
FirstMB
0
1
X
NotFree
-
LastMB
Overrun
FIFO enabled, no match in FIFO is as if FIFO does not exist
1
0
X
None
None5
None
Frame lost by no match
1
0
X
Free
None
FirstMB
1
1
X
None
None
None
Frame lost by no match
1
1
X
Free
None
FirstMB
1
1
X
NotFree
None
LastMB
Overrun
FIFO enabled, Queue disabled
1
0
0
X
NotFull6
FIFO
1
0
0
None
Full7
None
Frame lost by FIFO full (FIFO Overflow)
1
0
0
Free
Full
FirstMB
1
0
0
NotFree
Full
FirstMB
1
0
1
None
NotFull
FIFO
1
0
1
None
Full
None
Frame lost by FIFO full (FIFO Overflow)
1
0
1
Free
X
FirstMB
1
0
1
NotFree
X
FirtsMB
Overrun
FIFO enabled, Queue enabled
1
1
0
X
NotFull
FIFO
1
1
0
None
Full
None
Frame lost by FIFO full (FIFO Overflow)
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1267

<!-- page 1268 -->

Table 26-15. Matching Possibilities and Resulting Reception Structures
(continued)
RFEN
IRMQ
MRP
Matched in MB
Matched in
FIFO
Reception
Structure
Description
1
1
0
Free
Full
FirstMB
1
1
0
NotFree
Full
LastMB
Overrun
1
1
1
None
NotFull
FIFO
1
1
1
Free
X
FirstMB
1
1
1
NotFree
NotFull
FIFO
1
1
1
NotFree
Full
LastMB
Overrun
1.
It is a don't care condition.
2.
Matched in MB "None" means that the frame has not matched any MB (free-to-receive or non-free-to-receive).
3.
It is a forbidden condition.
4.
Matched in MB "Free" means that the frame matched at least one MB free-to-receive regardless it has matched MBs non-
free-to-receive.
5.
Matched in FIFO "None" means that the frame has not matched any filter in FIFO. It is as the FIFO didn't exist
(CTRL2[RFEN]=0).
6.
Matched in FIFO "NotFull" means that the frame has matched a FIFO filter and has empty slots to receive it.
7.
Matched in FIFO "Full" means that the frame has matched a FIFO filter but couldn't store it because it has no empty slots
to receive it.
The ability to match the same ID in more than one MB can be exploited to implement a
reception queue (in addition to the full featured FIFO) to allow more time for Arm to
service the MBs. By programming more than one MB with the same ID, received
messages will be queued into the MBs. Arm can examine the Time Stamp field of the
MBs to determine the order in which the messages arrived.
Matching to a range of IDs is possible by using ID Acceptance Masks. FlexCAN
supports individual masking per MB. Please refer to Rx Mailboxes Global Mask Register
(FLEXCAN_RXMGMASK). During the matching algorithm, if a mask bit is asserted,
then the corresponding ID bit is compared. If the mask bit is negated, the corresponding
ID bit is "don't care". Please note that the Individual Mask Registers are implemented in
RAM, so they are not initialized out of reset. Also, they can only be programmed while
the module is in Freeze Mode,, otherwise they are blocked by hardware.
FlexCAN also supports an alternate masking scheme with only four mask registers
(RGXMASK, RX14MASK, RX15MASK and RXFGMASK) for backward
compatibility. This alternate masking scheme is enabled when the IRMQ bit in the MCR
Register is negated.
26.6.6
Move Process
There are two types of move process, namely move-in and move-out.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1268
NXP Semiconductors

<!-- page 1269 -->

26.6.6.1
Move-in
The move-in process is the copy of a message received by an Rx SMB to a Rx Mailbox
or FIFO that has matched it. If the move destination is the Rx FIFO, attributes of the
message are also copied to the RXFIR FIFO. Each Rx SMB has its own move-in process,
but only one is performed at a given time as described ahead. The move-in starts only
when the message held by the Rx SMB has a corresponding matching winner (see
Matching Process) and all of the following conditions are true:
• the CAN bus has reached or let past either:
• the second bit of Intermission field next to the frame that carried the message
that is in the Rx SMB;
• the first bit of an overload frame next to the frame that carried the message that
is in the Rx SMB;
• there is no ongoing matching process;
• the destination Mailbox is not locked by Arm;
• there is no ongoing move-in process from another Rx SMB. If more than one move-
in processes are to be started at the same time both are performed and the newest
substitutes the oldest.
The term pending move-in is used throughout the document and stands for a move-to-be
that still does not satisfy all of the aforementioned conditions.
The move-in is cancelled and the Rx SMB is able to receive another message if any of
the following conditions is satisfied:
• the destination Mailbox is inactivated after the CAN bus has reached the first bit of
Intermission field next to the frame that carried the message and its matching process
has finished;
• there is a previous pending move-in to the same destination Mailbox.
• the Rx SMB is receiving a frame transmitted by the FlexCAN itself and the self-
reception is disabled;
• any CAN protocol error is detected.
Note that the pending move-in is not cancelled if the module enters in Freeze or Low
Power Mode. It only stays on hold waiting for exiting Low Power Mode and to be
unlocked. If an MB is unlocked during Freeze Mode, the move-in happens immediately.
The move-in process consists of the following steps:
1. if the message is destined to the Rx FIFO, push IDHIT into the RXFIR FIFO;
2. reads the words DATA0-3 and DATA4-7 from the Rx SMB;
3. writes it in the words DATA0-3 and DATA4-7 of the Rx Mailbox;
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1269

<!-- page 1270 -->

4. reads the words Control/Status and ID from the Rx SMB;
5. writes it in the words Control/Status and ID of the Rx Mailbox, updating the CODE
field according to Table 26-4.
The move-in process is not atomic, in such a way that it is immediately cancelled by the
inactivation of the destination Mailbox (see Message Buffer Inactivation) and in this case
the Mailbox may be left partially updated, thus incoherent. The exception is if the move-
in destination is an Rx FIFO Message Buffer, then the process cannot be cancelled.
The BUSY Bit (least significant bit of the CODE field) of the destination Message Buffer
is asserted while the move-in is being performed in such a way that Arm beware that the
Message Buffer content is temporarily incoherent.
26.6.6.2
Move-out
The move-out process is the copy of the content from a Tx Mailbox to the Tx SMB when
a message for transmission is available (see Arbitration process). The move-out occurs in
the following conditions:
• the first bit of Intermission field;
• during Bus off field when TX Error Counter is in the 124 to 128 range;
• during BusIdle field;
• during Wait For Bus Idle field.
The move-out process is not atomic. Only Arm has priority to access the memory
concurrently out of BusIdle state. In BusIdle, the move-out has the lowest priority to the
concurrent memory accesses.
26.6.7
Data Coherence
In order to maintain data coherency and FlexCAN proper operation, the Arm must obey
the rules described in the Transmit Process and Receive Process.
Any form of Arm accessing an MB structure within FlexCAN other than those specified
may cause FlexCAN to behave in an unpredictable way.
26.6.7.1
Transmission Abort Mechanism
The abort mechanism provides a safe way to request the abortion of a pending
transmission. A feedback mechanism is provided to inform Arm if the transmission was
aborted or if the frame could not be aborted and was transmitted instead.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1270
NXP Semiconductors

<!-- page 1271 -->

In order to abort a transmission, Arm must write a specific abort code (0b1001) to the
CODE field of the Control and Status word. The active MBs configured as transmission
must be aborted first and then they may be updated. If the abort code is written to a
Mailbox that is currently being transmitted, or to a Mailbox that was already loaded into
the SMB for transmission, the write operation is blocked and the MB is kept active, but
the abort request is captured and kept pending until one of the following conditions are
satisfied:
• The module loses the bus arbitration
• There is an error during the transmission
• The module is put into Freeze Mode
• The module enters in BusOff state
• There is an overload frame
If none of conditions above are reached, the MB is transmitted correctly, the interrupt
flag is set in the IFLAG register and an interrupt to the Arm is generated (if enabled). The
abort request is automatically cleared when the interrupt flag is set. In the other hand, if
one of the above conditions is reached, the frame is not transmitted, therefore the abort
code is written into the CODE field, the interrupt flag is set in the IFLAG and an interrupt
is (optionally) generated to Arm.
If Arm writes the ABORT code before the transmission begins internally, then the write
operation is not blocked, therefore the MB is updated and the interrupt flag is set. In this
way Arm just needs to read the abort code to make sure the active MB was safely
inactivated. Although the AEN bit is asserted and Arm wrote the abort code, in this case
the MB is inactivated and not aborted, because the transmission did not start yet. One
Mailbox is only aborted when the abort request is captured and kept pending until one of
the previous conditions are satisfied.
The abort procedure can be summarized as follows:
1. Arm checks the corresponding IFLAG and clears it, if asserted.
2. Arm writes 0b1001 into the CODE field of the C/S word.
3. Arm waits for the corresponding IFLAG indicating that the frame was either
transmitted or aborted.
4. Arm reads the CODE field to check if the frame was either transmitted
(CODE=0b1000) or aborted (CODE=0b1001).
5. It is necessary to clear the corresponding IFLAG in order to allow the MB to be
reconfigured.
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1271

<!-- page 1272 -->

26.6.7.2
Message Buffer Inactivation
Inactivation is a mechanism provided to protect the Mailbox against updates by the
FlexCAN internal processes, thus allowing Arm to rely on Mailbox data coherence after
having updated it, even in Normal Mode.
If a Mailbox is inactivated it does not participate neither in the arbitration nor in the
matching process until it is reactivated. See Transmit Process and Receive Process for
more detailed instruction on how to inactivate and reactivate a Mailbox.
In order to inactivate a Mailbox Arm must update its CODE field to INACTIVE (either
0b0000 or 0b1000).
As the user is not able to synchronize the CODE field update with the FlexCAN internal
processes an inactivation can lead to undesirable results:
• a frame in the bus that matches the filtering of the inactivated Rx Mailbox may be
lost without notice, even if there are other Mailboxes with the same filter;
• a frame containing the message within the inactivated Tx Mailbox may be
transmitted without notice.
In order to eliminate such risk and perform a safe inactivation Arm must use the
following mechanism along with the inactivation itself:
• for Tx Mailboxes, the Transmission Abort (see Transmission Abort Mechanism);
The inactivation automatically unlocks the Mailbox (see Message Buffer Lock
Mechanism).
Message Buffers that are part of the Rx FIFO cannot be inactivated. There is no write
protection on FIFO region by FlexCAN. Arm must keep the data coherence into FIFO
region when RFEN is asserted.
26.6.7.3
Message Buffer Lock Mechanism
Besides MB inactivation, FlexCAN has another data coherence mechanism for the
receive process. When Arm reads the Control and Status word of an Rx MB with codes
FULL or OVERRUN, FlexCAN assumes that Arm wants to read the whole MB in an
atomic operation, and thus it sets an internal lock flag for that MB. The lock is released
when Arm reads the Free Running Timer (global unlock operation), or when it reads the
Control and Status word of another MB regardless of its code or when Arm writes into
C/S word from locked MB. The MB locking is done to prevent a new frame to be written
into the MB while Arm is reading it.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1272
NXP Semiconductors

<!-- page 1273 -->

The locking mechanism only applies to Rx MBs that are not part of FIFO and have a
code different than INACTIVE (0b0000) or EMPTY1 (0b0100). Also, Tx MBs can not
be locked.
Suppose, for example, that the FIFO is disabled and the second and the fifth MBs of the
array are programmed with the same ID, and FlexCAN has already received and stored
messages into these two MBs. Suppose now that the Arm decides to read MB number 5
and at the same time another message with the same ID is arriving. When Arm reads the
Control and Status word of MB number 5, this MB is locked. The new message arrives
and the matching algorithm finds out that there are no "free-to-receive" MBs, so it
decides to override MB number 5. However, this MB is locked, so the new message can
not be written there. It will remain in the SMB waiting for the MB to be unlocked, and
only then will be written to the MB. If the MB is not unlocked in time and yet another
new message with the same ID arrives, then the new message overwrites the one on the
SMB and there will be no indication of lost messages either in the CODE field of the MB
or in the Error and Status Register.
While the message is being moved-in from the SMB to the MB, the BUSY bit on the
CODE field is asserted. If Arm reads the Control and Status word and finds out that the
BUSY bit is set, it should defer accessing the MB until the BUSY bit is negated.
If the BUSY bit is asserted or if the MB is empty, then reading the Control and Status
word does not lock the MB.
Inactivation takes precedence over locking. If Arm inactivates a locked Rx Mailbox, then
its lock status is negated and the Mailbox is marked as invalid for the current matching
round. Any pending message on the SMB will not be transferred anymore to the
Mailbox.An MB is unlocked when Arm reads the Free Running Timer Register (see Free
Running Timer Register (FLEXCAN_TIMER)), or the C/S word of another MB.
Lock and unlock mechanisms have the same functionality in both Normal and Freeze
modes.
An unlock during Normal or Freeze mode results in the move-in of the pending message.
However, the move-in is postponed if an unlock occurs during any of the low power
modes (see in Modes of Operation specific information on Module Disable or Stop
modes) and it will take place only when the module resumes to Normal or Freeze modes.
26.6.8
Rx FIFO
The receive-only FIFO is enabled by asserting the RFEN bit in the MCR.
1.
In previous FlexCAN versions, reading the C/S word locks the MB even if it is EMPTY. This behavior is maintained when
the IRMQ bit is negated.
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1273

<!-- page 1274 -->

The reset value of this bit is zero to maintain software backward compatibility with
previous versions of the module that did not have the FIFO feature. The FIFO is 6-
message deep, therefore when the FIFO is enabled, the memory region occupied by the
first 6 Message Buffers is reserved for use of the FIFO engine (see Rx FIFO Structure).
Arm can read the received messages sequentially, in the order they were received, by
repeatedly reading a Message Buffer structure at the output of the FIFO.
The IFLAG[BUF5I] (Frames available in Rx FIFO) is asserted when there is at least one
frame available to be read from the FIFO. An interrupt is generated if it is enabled by the
corresponding mask bit. Upon receiving the interrupt, Arm can read the message
(accessing the output of the FIFO as a Message Buffer) and the RXFIR register and then
clear the interrupt. If there are more messages in the FIFO the act of clearing the interrupt
updates the output of the FIFO with the next message and update the RXFIR with the
attributes of that message, reissuing the interrupt to Arm. Otherwise, the flag remains
negated. The output of the FIFO is only valid when the IFLAG[BUF5I] is asserted.
The IFLAG[BUF6I] (Rx FIFO Warning) is asserted when the number of unread
messages within the Rx FIFO is increased to 5 from 4 due to the reception of a new one,
meaning that the Rx FIFO is almost full. The flag remains asserted until Arm clears it.
The IFLAG[BUF7I] (Rx FIFO Overflow) is asserted when an incoming message was lost
because the Rx FIFO is full. Note that the flag will not be asserted when the Rx FIFO is
full and the message was captured by a Mailbox. The flag remains asserted until the Arm
clears it.
Clearing one of those three flags does not affect the state of the other two.
An interrupt is generated if an IFLAG bit is asserted and the corresponding mask bit is
asserted too.
A powerful filtering scheme is provided to accept only frames intended for the target
application, thus reducing the interrupt servicing work load. The filtering criteria is
specified by programming a table of up to 128 32-bit registers, according to
CTRL2[RFFN] setting, that can be configured to one of the following formats (see also
Rx FIFO Structure):
• Format A: 128 IDAFs (extended or standard IDs including IDE and RTR)
• Format B: 256 IDAFs (standard IDs or extended 14-bit ID slices including IDE and
RTR)
• Format C: 512 IDAFs (standard or extended 8-bit ID slices)
Every frame available in the FIFO has a corresponding IDHIT (Identifier Acceptance
Filter Hit Indicator) that can be read by accessing the RXFIR register. The
RXFIR[IDHIT] field refers to the message at the output of the FIFO and is valid whilst
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1274
NXP Semiconductors

<!-- page 1275 -->

the IFLAG[BUF5I] flag is asserted. The RXFIR register must be read only before
clearing the flag, which guarantees that the information refers to the correct frame within
the FIFO.
Up to thirty two elements of the ID Filter Table are individually affected by the
Individual Mask Registers (RXIMR0 - RXIMR31), according to CTRL2[RFFN] setting
(refer to Control 2 Register (FLEXCAN_CTRL2)), allowing very powerful filtering
criteria to be defined. If the MCR[IRMQ] bit is negated (or if the RXIMR are not
available for the particular MCU), then the FIFO ID Filter Table is affected by
RXFGMASK.
26.6.9
CAN Protocol Related Features
26.6.9.1
Remote Frames
Remote frame is a special kind of frame. The user can program a mailbox to be a Remote
Request Frame by writing the mailbox as Transmit with the RTR bit set to '1'. After the
remote request frame is transmitted successfully, the mailbox becomes a Receive
Message Buffer, with the same ID as before.
When a remote request frame is received by FlexCAN, it can be treated in three ways,
depending on Remote Request Storing (CTRL2[RRS]) and Rx FIFO Enable
(MCR[RFEN]) bits:
• If RRS is negated the frame's ID is compared to the IDs of the Transmit Message
Buffers with the CODE field 0b1010. If there is a matching ID, then this mailbox
frame will be transmitted. Note that if the matching mailbox has the RTR bit set, then
FlexCAN will transmit a remote frame as a response. The received remote request
frame is not stored in a receive buffer. It is only used to trigger a transmission of a
frame in response. The mask registers are not used in remote frame matching, and all
ID bits (except RTR) of the incoming received frame should match. In the case that a
remote request frame was received and matched a mailbox, this message buffer
immediately enters the internal arbitration process, but is considered as normal Tx
mailbox, with no higher priority. The data length of this frame is independent of the
DLC field in the remote frame that initiated its transmission.
• If RRS is asserted the frame's ID is compared to the IDs of the receive mailboxes
with the CODE field 0b0100, 0b0010 or 0b0110. If there is a matching ID, then this
mailbox will store the remote frame in the same fashion of a data frame. No
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1275

<!-- page 1276 -->

automatic remote response frame will be generated. The mask registers are used in
the matching process.
• If RFEN is asserted FlexCAN will not generate an automatic response for remote
request frames that match the FIFO filtering criteria. If the remote frame matches one
of the target IDs, it will be stored in the FIFO and presented to the Arm. Note that for
filtering formats A and B, it is possible to select whether remote frames are accepted
or not. For format C, remote frames are always accepted (if they match the
ID).Remote Request Frames are considered as normal frames, and generate a FIFO
overflow when a successful reception occurs and the FIFO is already full.
26.6.9.2
Overload Frames
FLEXCAN does transmit overload frames due to detection of following conditions on
CAN bus:
• Detection of a dominant bit in the first/second bit of Intermission
• Detection of a dominant bit at the 7th bit (last) of End of Frame field (Rx frames)
• Detection of a dominant bit at the 8th bit (last) of Error Frame Delimiter or Overload
Frame Delimiter
26.6.9.3
Time Stamp
The value of the Free Running Timer is sampled at the beginning of the Identifier field on
the CAN bus, and is stored at the end of "move-in" in the TIME STAMP field, providing
network behavior with respect to time.
Note that the Free Running Timer can be reset upon a specific frame reception, enabling
network time synchronization. Refer to TSYN description in Control 1 Register
(FLEXCAN_CTRL1).
26.6.9.4
Protocol Timing
The FLEXCAN module supports a variety of means to setup bit timing parameters that
are required by the CAN protocol. The Control Register has various fields used to control
bit timing parameters: PRESDIV, PROPSEG, PSEG1, PSEG2 and RJW. See Control 1
Register (FLEXCAN_CTRL1).
The PRESDIV field controls a prescaler that generates the Serial Clock (Sclock), whose
period defines the 'time quantum' used to compose the CAN waveform. A time quantum
is the atomic unit of time handled by the CAN engine.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1276
NXP Semiconductors

<!-- page 1277 -->

fTq =
fCANCLK
(Prescaler value)
A bit time is subdivided into three segments2 (reference Table 26-16):
• SYNC_SEG: This segment has a fixed length of one time quantum. Signal edges are
expected to happen within this section.
• Time Segment 1: This segment includes the Propagation Segment and the Phase
Segment 1 of the CAN standard. It can be programmed by setting the PROPSEG and
the PSEG1 fields of the CTRL Register so that their sum (plus 2) is in the range of 4
to 16 time quanta.
• Time Segment 2: This segment represents the Phase Segment 2 of the CAN standard.
It can be programmed by setting the PSEG2 field of the CTRL Register (plus 1) to be
2 to 8 time quanta long.
fTq
=
(number of Time Quanta)
Bit Rate
2.
For further explanation of the underlying concepts please refer to ISO/DIS 11519-1, Section 10.3. Reference also the
Bosch CAN 2.0A/B protocol specification dated September 1991 for bit timing.
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1277

<!-- page 1278 -->

NRZ Signal
SYNC_SEG
Time Segment 1
(PROP_SEG + PSEG1 +2)
TIme Segment 2
(PSEG2 +1)
1
4 ... 16
2 ... 8
8 ... 25 Time Quanta
= 1 Bit Time
Transmit Point
Sample Point
(single or triple sampling)
Figure 26-2. Segments within the Bit Time
Whenever CAN bit is used as a measure of duration (e.g. MCR[FRZ_ACK] and
MCR[LPM_ACK] in Module Configuration Register (FLEXCAN_MCR)), the number
of peripheral clocks in one CAN bit can be calculated as:
NCCP =
fCANCLK
fsys x [1 + (PSEG1 + 1) + (PSEG2 + 1) + (PROPSEG + 1)] x (PRESDIV + 1)
where:
NCCP is the number of peripheral clocks in one CAN bit;
fCANCLK is the Protocol Engine (PE) Clock in Hz;
fSYS is the frequency of operation of the system (CHI) clock, in Hz;
PSEG1 is the value in CTRL1[PSEG1] field;
PSEG2 is the value in CTRL1[PSEG2] field;
PROPSEG is the value in CTRL1[PROPSEG] field;
PRESDIV is the value in CTRL1[PRESDIV] field.
For example, 180 CAN bits = 180 x NCCP peripheral clock periods.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1278
NXP Semiconductors

<!-- page 1279 -->

Figure 26-2 gives an overview of the CAN compliant segment settings and the related
parameter values.
Table 26-16. Time Segment Syntax
Syntax
Description
SYNC_SEG
System expects transitions to occur on the bus during this period.
Transmit Point
A node in transmit mode transfers a new value to the CAN bus at this point.
Sample Point
A node samples the bus at this point. If the three samples per bit option is selected, then this
point marks the position of the third sample.
Table 26-17. CAN Standard Compliant Bit Time Segment Settings
Time Segment 1
Time Segment 2
Re-synchronization Jump Width
5 .. 10
2
1 .. 2
4 .. 11
3
1 .. 3
5 .. 12
4
1 .. 4
6 .. 13
5
1 .. 4
7 .. 14
6
1 .. 4
8 .. 15
7
1 .. 4
9 .. 16
8
1 .. 4
26.6.9.5
Arbitration and Matching Timing
During normal reception and transmission of frames, the matching, arbitration, move-in
and move-out processes are executed during certain time windows inside the CAN frame,
as shown in the following figures.
DLC (4)
DATA and/ or CRC (15 to79)
EOF (7)
Interm
Move-in
Window
Start Move
(bit 2)
Matching WIndow (26 to90 bits)
Figure 26-3. Matching and Move-In Time Windows
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1279

<!-- page 1280 -->

 CRC (15)
EOF (7)
Interm
Move-out
Window
Start Move
(bit 1)
Arb 
Process
Start Arbitration
(delayed by TASD)
Arbitration Window (25 bits)
Figure 26-4. Arbitration and Move-Out Time Windows
Move-out
Window
BusOff
Arb
Process
TASD
Count
0
1
2
3
...
123
124
125
126
...
128
ECR [TX_ERR_CNT]
(Transmit Error Counter)
Figure 26-5. Arbitration at the end of Bus Off and Move-Out Time Windows
When doing matching and arbitration, FlexCAN needs to scan the whole Message Buffer
memory during the available time window. In order to have sufficient time to do that, the
following requirements must be observed:
• A valid CAN bit timing must be programmed, as indicated in Table 26-17
• The peripheral clock frequency can not be smaller than the oscillator clock
frequency, i.e. the PLL can not be programmed to divide down the oscillator clock
• There must be a minimum ratio between the peripheral clock frequency and the CAN
bit rate, as specified in the following table.
Table 26-18. Minimum Ratio Between Peripheral Clock Frequency and CAN Bit Rate
Number of Message Buffers
RFEN
Minimum Number of Peripheral
Clocks per CAN bit
16 and 32
0
16
64
0
25
16
1
16
32
1
17
64
1
30
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1280
NXP Semiconductors

<!-- page 1281 -->

A direct consequence of the first requirement is that the minimum number of time quanta
per CAN bit must be 8, so the oscillator clock frequency should be at least 8 times the
CAN bit rate. The minimum frequency ratio specified in Table 26-18 can be achieved by
choosing a high enough peripheral clock frequency when compared to the oscillator clock
frequency, or by adjusting one or more of the bit timing parameters (PRESDIV,
PROPSEG, PSEG1, PSEG2). As an example, taking the case of 64 MBs, if the oscillator
and peripheral clock frequencies are equal and the CAN bit timing is programmed to
have 8 time quanta per bit, then the prescaler factor (PRESDIV + 1) should be at least 2.
For prescaler factor equal to one and CAN bit timing with 8 time quanta per bit, the ratio
between peripheral and oscillator clock frequencies should be at least 2.
26.6.10
Modes of Operation Details
The FlexCAN module has four functional modes (Normal Mode, Freeze Mode, Listen-
Only Mode and Loop-Back Mode) and two low power modes (Disable Mode and Stop
Mode).See in Modes of Operation an introductory description of all these modes of
operation. The following sub-sections bring functional details on Freeze mode and the
low power modes.
26.6.10.1
Freeze Mode
This mode is requested by Arm through the assertion of the HALT bit in the MCR
Register or when the MCU is put into Debug Mode . In both cases it is also necessary
that the FRZ bit is asserted in the MCR Register and the module is not in any of the low
power modes (Disable, Stop). The acknowledgement is obtained through the assertion by
the FlexCAN of FRZ_ACK bit in the same register. The Arm must only consider the
FlexCAN in Freeze Mode when both request and acknowledgement conditions are
satisfied.
When Freeze Mode is requested during transmission or reception, FlexCAN does the
following:
• Waits to be in either Intermission, Passive Error, Bus Off or Idle state
• Waits for all internal activities like arbitration, matching, move-in and move-out to
finish. Pending move-in is not taken in account
• Ignores the FLEXCAN_RX input pin and drives the FLEXCAN_TX pin as recessive
• Stops the prescaler, thus halting all CAN protocol activities
• Grants write access to the Error Counters Register, which is read-only in other modes
• Sets the NOT_RDY and FRZ_ACK bits in MCR
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1281

<!-- page 1282 -->

After requesting Freeze Mode, the user must wait for the FRZ_ACK bit to be asserted in
MCR before executing any other action, otherwise FlexCAN may operate in an
unpredictable way. In Freeze mode, all memory mapped registers are accessible, except
for CTRL1[CLK_SRC] bit that can be read but cannot be written.
Exiting Freeze Mode is done in one of the following ways:
• Arm negates the FRZ bit in the MCR Register
• The Arm is removed from Debug Mode and the HALT bit is negated
The FRZ_ACK bit is negated after protocol engine recognizes the negation of freeze
request. Once out of Freeze Mode, FlexCAN tries to re-synchronize to the CAN bus by
waiting for 11 consecutive recessive bits.
26.6.10.2
Module Disable Mode
This low power mode is normally used to temporarily disable a complete FlexCAN
block, with no power consumption. It is requested by the Arm through the assertion of
the MDIS bit in the MCR Register and the acknowledgement is obtained through the
assertion by the FlexCAN of the LPM_ACK bit in the same register. The Arm must only
consider the FlexCAN in Disable Mode when both request and acknowledgement
conditions are satisfied.
If the module is disabled during Freeze Mode, it requests to disable the clocks to the PE
and CHI sub-modules, sets the LPM_ACK bit and negates the FRZ_ACK bit. The ability
to shut down the clocks depends on how FlexCAN is integrated into the MCU. If the
module is disabled during transmission or reception, FlexCAN does the following:
• Waits to be in either Idle or Bus Off state, or else waits for the third bit of
Intermission and then checks it to be recessive
• Waits for all internal activities like arbitration, matching, move-in and move-out to
finish. Pending move-in is not taken in account
• Ignores its FLEXCAN_RX input pin and drives its FLEXCAN_TX pin as recessive
• May shut down the clocks to the PE and CHI sub-modules, depending on how
FlexCAN is integrated into the MCU
• Sets the NOT_RDY and LPM_ACK bits in MCR
The Bus Interface Unit continues to operate, enabling the Arm to access memory mapped
registers, except the Rx Mailboxes Global Mask Registers, the Rx Buffer 14 Mask
Register, the Rx Buffer 15 Mask Register, the Rx FIFO Global Mask Register. The Rx
FIFO Information Register, the Message Buffers, the Rx Individual Mask Registers, and
the reserved words within RAM may not be accessed when the module is in Disable
Mode depending on how FlexCAN RAM is integrated into the Arm. Exiting from this
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1282
NXP Semiconductors

<!-- page 1283 -->

mode is done by negating the MDIS bit by Arm, which make FlexCAN requests to
resume the clocks and negates the LPM_ACK bit after CAN protocol engine recognizes
the negation of disable mode requested by Arm.
26.6.10.3
Stop Mode
This is a system low power mode in which system clocks can be stopped for maximum
power savings. To enter stop mode, the CPU should manually assert a global Stop Mode
request (see the CAN1_STOP_REQ and CAN2_STOP_REQ bit in the register
IOMUXC_GPR4) and check the acknowledgement asserted by the FlexCAN (see the
CAN1_STOP_ACK and CAN2_STOP_ACK in the register IOMUXC_GPR4). The CPU
must only consider the FlexCAN in Stop Mode when both request and acknowledgement
conditions are satisfied.
If FlexCAN receives the global Stop Mode request during Freeze Mode, it sets the
LPM_ACK bit, negates the FRZ_ACK bit and then sends the Stop Acknowledge signal
to the CPU, in order to shut down the clocks globally. If Stop Mode is requested during
transmission or reception, FlexCAN does the following:
• Waits to be in either Idle or Bus Off state, or else waits for the third bit of
Intermission and checks it to be recessive
• Waits for all internal activities like arbitration, matching, move-in and move-out to
finish. Pending move-in is not taken in account
• Ignores its FLEXCAN_RX input pin and drives its FLEXCAN_TX pin as recessive
• Sets the NOT_RDY and LPM_ACK bits in MCR
• Sends a Stop Acknowledge signal to the CPU, so that it can shut down the clocks
globally
Exiting Stop Mode is done in one of the following ways:
• Arm resuming the clocks and removing the Stop Mode request
• Arm resuming the clocks and Stop Mode request as a result of the Self Wake
mechanism
In the Self Wake mechanism, if the SLF_WAK bit in MCR Register was set at the time
FlexCAN entered Stop Mode, then upon detection of a recessive to dominant transition
on the CAN bus, FlexCAN sets the WAK_INT bit in the ESR Register and, if enabled by
the WAK_MSK bit in MCR, generates a Wake Up interrupt to the Arm. Upon receiving
the interrupt, the Arm should resume the clocks and remove the Stop Mode request
manually. FlexCAN will then wait for 11 consecutive recessive bits to synchronize to the
CAN bus. As a consequence, it will not receive the frame that woke it up .
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1283

<!-- page 1284 -->

The sensitivity to CAN bus activity can be modified by applying a low-pass filter
function to the FLEXCAN_RX input line while in Stop Mode. See the WAK_SRC bit in
Module Configuration Register (FLEXCAN_MCR) . This feature can be used to protect
FlexCAN from waking up due to short glitches on the CAN bus lines. Such glitches can
result from electromagnetic interference within noisy environments, the glitch filter width
can be set in Glitch Filter Width Register (FLEXCAN_GFWR).
26.6.11
Interrupts
The module can generate up to 70 interrupt sources (64 interrupts due to message buffers
and 6 interrupts due to Ored interrupts from MBs, Bus Off, Error, Tx Warning, Rx
Warning and Wake Up)).
The number of actual sources depends on the configured number of message buffers.
Each one of the message buffers can be an interrupt source, if its corresponding IMASK
bit is set. There is no distinction between Tx and Rx interrupts for a particular buffer,
under the assumption that the buffer is initialized for either transmission or reception.
Each of the buffers has assigned a flag bit in the IFLAG Registers. The bit is set when the
corresponding buffer completes a successful transmission/reception and is cleared when
the Arm writes it to '1' (unless another interrupt is generated at the same time).
If the Rx FIFO is enabled (bit RFEN on MCR set), the interrupts corresponding to MBs 0
to 7 have a different behavior. Bit 7 of the IFLAG1 becomes the "FIFO Overflow" flag;
bit 6 becomes the FIFO Warning flag, bit 5 becomes the "Frames Available in FIFO flag"
and bits 4-0 are unused. See Interrupt Flags 1 Register (FLEXCAN_IFLAG1) for more
information.
A combined interrupt for all MBs is also generated by an Or of all the interrupt sources
from MBs. This interrupt gets generated when any of the Mailboxes or FIFO generates an
interrupt. The Arm must read the IFLAG Registers to determine which MB or FIFO
caused the interrupt.
The other 5 interrupt sources (Bus Off, Error, Tx Warning, Rx Warning and Wake Up
generate interrupts like the MB ones, and can be read from both the Error and Status
Register 1 and 2. The Bus Off, Error, Tx Warning and Rx Warning interrupt mask bits
are located in the Control 1 Register and the Wake-Up interrupt mask bit is located in the
MCR.
Initialization/Application Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1284
NXP Semiconductors

<!-- page 1285 -->

26.7
Initialization/Application Information
This section provide instructions for initializing the FLEXCAN module.
26.7.1
FLEXCAN Initialization Sequence
The FLEXCAN module may be reset in two ways:
• SOC level hard reset which resets all memory mapped registers asynchronously
• SOFT_RST bit in MCR, which resets some of the memory mapped registers
synchronously
Soft reset is synchronous and has to follow an internal request/acknowledge procedure
across clock domains. Therefore, it may take some time to fully propagate its effects. The
SOFT_RST bit remains asserted while soft reset is pending, so software can poll this bit
to know when the reset has completed. Also, soft reset can not be applied while clocks
are shut down in any of the low power modes. The low power mode should be exited and
the clocks resumed before applying soft reset.
After the module is enabled (MDIS bit negated), FLEXCAN automatically goes to
Freeze Mode. In Freeze Mode, FLEXCAN is un-synchronized to the CAN bus, the
HALT and FRZ bits in MCR Register are set, the internal state machines are disabled and
the FRZ_ACK and NOT_RDY bits in the MCR Register are set. The FLEXCAN_TX pin
is in recessive state and FLEXCAN does not initiate any transmission or reception of
CAN frames. Note that the Message Buffers and the Rx Individual Mask Registers are
not affected by reset, so they are not automatically initialized.
For any configuration change/initialization it is required that FLEXCAN is put into
Freeze Mode. The following is a generic initialization sequence applicable to the
FLEXCAN module:
• Initialize the Module Configuration Register
• Enable the individual filtering per MB and reception queue features by setting
the IRMQ bit
• Enable the warning interrupts by setting the WRN_EN bit
• If required, disable frame self reception by setting the SRX_DIS bit
• Enable the FIFO by setting the RFEN bit
• Enable the abort mechanism by setting the AEN bit
• Enable the local priority feature by setting the LPRIO_EN bit
• Initialize the Control Register
• Determine the bit timing parameters: PROPSEG, PSEG1, PSEG2, RJW
• Determine the bit rate by programming the PRESDIV field
• Determine the internal arbitration mode (LBUF bit)
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1285

<!-- page 1286 -->

• Initialize the Message Buffers
• The Control and Status word of all Message Buffers must be initialized
• If FIFO was enabled, the 8-entry ID table must be initialized
• Other entries in each Message Buffer should be initialized as required
• Initialize the Rx Individual Mask Registers
• Set required interrupt mask bits in the IMASK Registers (for all MB interrupts), in
CTRL Register (for Bus Off and Error interrupts) and in MCR Register for Wake-Up
interrupt
• Negate the HALT bit in MCR
Starting with the last event, FLEXCAN attempts to synchronize to the CAN bus.
26.8
FLEXCAN Memory Map/Register Definition
The complete memory map for a FLEXCAN module with 64 MBs capability is shown in
the following table. Each individual register is identified by its complete name and the
corresponding mnemonic. The access type can be Supervisor (S) or Unrestricted (U).
Most of the registers can be configured to have either Supervisor or Unrestricted access
by programming the SUPV bit in the MCR Register. The MCR register allows only
Supervisor access regardless the SUPV bit state.
The FLEXCAN module stores CAN messages for transmission and reception using a
Mailboxes and Rx FIFO structure.
FLEXCAN memory map
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
209_0000
Module Configuration Register (FLEXCAN1_MCR)
32
R/W
5980_000Fh
26.8.1/1293
209_0004
Control 1 Register (FLEXCAN1_CTRL1)
32
R/W
0000_0000h
26.8.2/1298
209_0008
Free Running Timer Register (FLEXCAN1_TIMER)
32
R/W
0000_0000h
26.8.3/1301
209_0010
Rx Mailboxes Global Mask Register
(FLEXCAN1_RXMGMASK)
32
R/W
FFFF_FFFFh 26.8.4/1301
209_0014
Rx Buffer 14 Mask Register (FLEXCAN1_RX14MASK)
32
R/W
FFFF_FFFFh 26.8.5/1302
209_0018
Rx Buffer 15 Mask Register (FLEXCAN1_RX15MASK)
32
R/W
FFFF_FFFFh 26.8.6/1303
209_001C
Error Counter Register (FLEXCAN1_ECR)
32
R/W
0000_0000h
26.8.7/1304
209_0020
Error and Status 1 Register (FLEXCAN1_ESR1)
32
R/W
0000_0000h
26.8.8/1305
209_0024
Interrupt Masks 2 Register (FLEXCAN1_IMASK2)
32
R/W
0000_0000h
26.8.9/1309
209_0028
Interrupt Masks 1 Register (FLEXCAN1_IMASK1)
32
R/W
0000_0000h
26.8.10/
1309
Table continues on the next page...
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1286
NXP Semiconductors

<!-- page 1287 -->

FLEXCAN memory map (continued)
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
209_002C
Interrupt Flags 2 Register (FLEXCAN1_IFLAG2)
32
R/W
0000_0000h
26.8.11/
1310
209_0030
Interrupt Flags 1 Register (FLEXCAN1_IFLAG1)
32
R/W
0000_0000h
26.8.12/
1310
209_0034
Control 2 Register (FLEXCAN1_CTRL2)
32
R/W
0000_0000h
26.8.13/
1312
209_0038
Error and Status 2 Register (FLEXCAN1_ESR2)
32
R
0000_0000h
26.8.14/
1318
209_0044
CRC Register (FLEXCAN1_CRCR)
32
R
0000_0000h
26.8.15/
1320
209_0048
Rx FIFO Global Mask Register (FLEXCAN1_RXFGMASK)
32
R/W
FFFF_FFFFh
26.8.16/
1321
209_004C
Rx FIFO Information Register (FLEXCAN1_RXFIR)
32
R
0000_0000h
26.8.17/
1322
209_0880
Rx Individual Mask Registers (FLEXCAN1_RXIMR0)
32
R/W
0000_0000h
26.8.18/
1323
209_0884
Rx Individual Mask Registers (FLEXCAN1_RXIMR1)
32
R/W
0000_0000h
26.8.18/
1323
209_0888
Rx Individual Mask Registers (FLEXCAN1_RXIMR2)
32
R/W
0000_0000h
26.8.18/
1323
209_088C
Rx Individual Mask Registers (FLEXCAN1_RXIMR3)
32
R/W
0000_0000h
26.8.18/
1323
209_0890
Rx Individual Mask Registers (FLEXCAN1_RXIMR4)
32
R/W
0000_0000h
26.8.18/
1323
209_0894
Rx Individual Mask Registers (FLEXCAN1_RXIMR5)
32
R/W
0000_0000h
26.8.18/
1323
209_0898
Rx Individual Mask Registers (FLEXCAN1_RXIMR6)
32
R/W
0000_0000h
26.8.18/
1323
209_089C
Rx Individual Mask Registers (FLEXCAN1_RXIMR7)
32
R/W
0000_0000h
26.8.18/
1323
209_08A0
Rx Individual Mask Registers (FLEXCAN1_RXIMR8)
32
R/W
0000_0000h
26.8.18/
1323
209_08A4
Rx Individual Mask Registers (FLEXCAN1_RXIMR9)
32
R/W
0000_0000h
26.8.18/
1323
209_08A8
Rx Individual Mask Registers (FLEXCAN1_RXIMR10)
32
R/W
0000_0000h
26.8.18/
1323
209_08AC
Rx Individual Mask Registers (FLEXCAN1_RXIMR11)
32
R/W
0000_0000h
26.8.18/
1323
209_08B0
Rx Individual Mask Registers (FLEXCAN1_RXIMR12)
32
R/W
0000_0000h
26.8.18/
1323
209_08B4
Rx Individual Mask Registers (FLEXCAN1_RXIMR13)
32
R/W
0000_0000h
26.8.18/
1323
209_08B8
Rx Individual Mask Registers (FLEXCAN1_RXIMR14)
32
R/W
0000_0000h
26.8.18/
1323
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1287

<!-- page 1288 -->

FLEXCAN memory map (continued)
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
209_08BC
Rx Individual Mask Registers (FLEXCAN1_RXIMR15)
32
R/W
0000_0000h
26.8.18/
1323
209_08C0
Rx Individual Mask Registers (FLEXCAN1_RXIMR16)
32
R/W
0000_0000h
26.8.18/
1323
209_08C4
Rx Individual Mask Registers (FLEXCAN1_RXIMR17)
32
R/W
0000_0000h
26.8.18/
1323
209_08C8
Rx Individual Mask Registers (FLEXCAN1_RXIMR18)
32
R/W
0000_0000h
26.8.18/
1323
209_08CC
Rx Individual Mask Registers (FLEXCAN1_RXIMR19)
32
R/W
0000_0000h
26.8.18/
1323
209_08D0
Rx Individual Mask Registers (FLEXCAN1_RXIMR20)
32
R/W
0000_0000h
26.8.18/
1323
209_08D4
Rx Individual Mask Registers (FLEXCAN1_RXIMR21)
32
R/W
0000_0000h
26.8.18/
1323
209_08D8
Rx Individual Mask Registers (FLEXCAN1_RXIMR22)
32
R/W
0000_0000h
26.8.18/
1323
209_08DC
Rx Individual Mask Registers (FLEXCAN1_RXIMR23)
32
R/W
0000_0000h
26.8.18/
1323
209_08E0
Rx Individual Mask Registers (FLEXCAN1_RXIMR24)
32
R/W
0000_0000h
26.8.18/
1323
209_08E4
Rx Individual Mask Registers (FLEXCAN1_RXIMR25)
32
R/W
0000_0000h
26.8.18/
1323
209_08E8
Rx Individual Mask Registers (FLEXCAN1_RXIMR26)
32
R/W
0000_0000h
26.8.18/
1323
209_08EC
Rx Individual Mask Registers (FLEXCAN1_RXIMR27)
32
R/W
0000_0000h
26.8.18/
1323
209_08F0
Rx Individual Mask Registers (FLEXCAN1_RXIMR28)
32
R/W
0000_0000h
26.8.18/
1323
209_08F4
Rx Individual Mask Registers (FLEXCAN1_RXIMR29)
32
R/W
0000_0000h
26.8.18/
1323
209_08F8
Rx Individual Mask Registers (FLEXCAN1_RXIMR30)
32
R/W
0000_0000h
26.8.18/
1323
209_08FC
Rx Individual Mask Registers (FLEXCAN1_RXIMR31)
32
R/W
0000_0000h
26.8.18/
1323
209_0900
Rx Individual Mask Registers (FLEXCAN1_RXIMR32)
32
R/W
0000_0000h
26.8.18/
1323
209_0904
Rx Individual Mask Registers (FLEXCAN1_RXIMR33)
32
R/W
0000_0000h
26.8.18/
1323
209_0908
Rx Individual Mask Registers (FLEXCAN1_RXIMR34)
32
R/W
0000_0000h
26.8.18/
1323
209_090C
Rx Individual Mask Registers (FLEXCAN1_RXIMR35)
32
R/W
0000_0000h
26.8.18/
1323
209_0910
Rx Individual Mask Registers (FLEXCAN1_RXIMR36)
32
R/W
0000_0000h
26.8.18/
1323
Table continues on the next page...
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1288
NXP Semiconductors

<!-- page 1289 -->

FLEXCAN memory map (continued)
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
209_0914
Rx Individual Mask Registers (FLEXCAN1_RXIMR37)
32
R/W
0000_0000h
26.8.18/
1323
209_0918
Rx Individual Mask Registers (FLEXCAN1_RXIMR38)
32
R/W
0000_0000h
26.8.18/
1323
209_091C
Rx Individual Mask Registers (FLEXCAN1_RXIMR39)
32
R/W
0000_0000h
26.8.18/
1323
209_0920
Rx Individual Mask Registers (FLEXCAN1_RXIMR40)
32
R/W
0000_0000h
26.8.18/
1323
209_0924
Rx Individual Mask Registers (FLEXCAN1_RXIMR41)
32
R/W
0000_0000h
26.8.18/
1323
209_0928
Rx Individual Mask Registers (FLEXCAN1_RXIMR42)
32
R/W
0000_0000h
26.8.18/
1323
209_092C
Rx Individual Mask Registers (FLEXCAN1_RXIMR43)
32
R/W
0000_0000h
26.8.18/
1323
209_0930
Rx Individual Mask Registers (FLEXCAN1_RXIMR44)
32
R/W
0000_0000h
26.8.18/
1323
209_0934
Rx Individual Mask Registers (FLEXCAN1_RXIMR45)
32
R/W
0000_0000h
26.8.18/
1323
209_0938
Rx Individual Mask Registers (FLEXCAN1_RXIMR46)
32
R/W
0000_0000h
26.8.18/
1323
209_093C
Rx Individual Mask Registers (FLEXCAN1_RXIMR47)
32
R/W
0000_0000h
26.8.18/
1323
209_0940
Rx Individual Mask Registers (FLEXCAN1_RXIMR48)
32
R/W
0000_0000h
26.8.18/
1323
209_0944
Rx Individual Mask Registers (FLEXCAN1_RXIMR49)
32
R/W
0000_0000h
26.8.18/
1323
209_0948
Rx Individual Mask Registers (FLEXCAN1_RXIMR50)
32
R/W
0000_0000h
26.8.18/
1323
209_094C
Rx Individual Mask Registers (FLEXCAN1_RXIMR51)
32
R/W
0000_0000h
26.8.18/
1323
209_0950
Rx Individual Mask Registers (FLEXCAN1_RXIMR52)
32
R/W
0000_0000h
26.8.18/
1323
209_0954
Rx Individual Mask Registers (FLEXCAN1_RXIMR53)
32
R/W
0000_0000h
26.8.18/
1323
209_0958
Rx Individual Mask Registers (FLEXCAN1_RXIMR54)
32
R/W
0000_0000h
26.8.18/
1323
209_095C
Rx Individual Mask Registers (FLEXCAN1_RXIMR55)
32
R/W
0000_0000h
26.8.18/
1323
209_0960
Rx Individual Mask Registers (FLEXCAN1_RXIMR56)
32
R/W
0000_0000h
26.8.18/
1323
209_0964
Rx Individual Mask Registers (FLEXCAN1_RXIMR57)
32
R/W
0000_0000h
26.8.18/
1323
209_0968
Rx Individual Mask Registers (FLEXCAN1_RXIMR58)
32
R/W
0000_0000h
26.8.18/
1323
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1289

<!-- page 1290 -->

FLEXCAN memory map (continued)
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
209_096C
Rx Individual Mask Registers (FLEXCAN1_RXIMR59)
32
R/W
0000_0000h
26.8.18/
1323
209_0970
Rx Individual Mask Registers (FLEXCAN1_RXIMR60)
32
R/W
0000_0000h
26.8.18/
1323
209_0974
Rx Individual Mask Registers (FLEXCAN1_RXIMR61)
32
R/W
0000_0000h
26.8.18/
1323
209_0978
Rx Individual Mask Registers (FLEXCAN1_RXIMR62)
32
R/W
0000_0000h
26.8.18/
1323
209_097C
Rx Individual Mask Registers (FLEXCAN1_RXIMR63)
32
R/W
0000_0000h
26.8.18/
1323
209_09E0
Glitch Filter Width Registers (FLEXCAN1_GFWR)
32
R/W
0000_007Fh
26.8.19/
1323
209_4000
Module Configuration Register (FLEXCAN2_MCR)
32
R/W
5980_000Fh
26.8.1/1293
209_4004
Control 1 Register (FLEXCAN2_CTRL1)
32
R/W
0000_0000h
26.8.2/1298
209_4008
Free Running Timer Register (FLEXCAN2_TIMER)
32
R/W
0000_0000h
26.8.3/1301
209_4010
Rx Mailboxes Global Mask Register
(FLEXCAN2_RXMGMASK)
32
R/W
FFFF_FFFFh 26.8.4/1301
209_4014
Rx Buffer 14 Mask Register (FLEXCAN2_RX14MASK)
32
R/W
FFFF_FFFFh 26.8.5/1302
209_4018
Rx Buffer 15 Mask Register (FLEXCAN2_RX15MASK)
32
R/W
FFFF_FFFFh 26.8.6/1303
209_401C
Error Counter Register (FLEXCAN2_ECR)
32
R/W
0000_0000h
26.8.7/1304
209_4020
Error and Status 1 Register (FLEXCAN2_ESR1)
32
R/W
0000_0000h
26.8.8/1305
209_4024
Interrupt Masks 2 Register (FLEXCAN2_IMASK2)
32
R/W
0000_0000h
26.8.9/1309
209_4028
Interrupt Masks 1 Register (FLEXCAN2_IMASK1)
32
R/W
0000_0000h
26.8.10/
1309
209_402C
Interrupt Flags 2 Register (FLEXCAN2_IFLAG2)
32
R/W
0000_0000h
26.8.11/
1310
209_4030
Interrupt Flags 1 Register (FLEXCAN2_IFLAG1)
32
R/W
0000_0000h
26.8.12/
1310
209_4034
Control 2 Register (FLEXCAN2_CTRL2)
32
R/W
0000_0000h
26.8.13/
1312
209_4038
Error and Status 2 Register (FLEXCAN2_ESR2)
32
R
0000_0000h
26.8.14/
1318
209_4044
CRC Register (FLEXCAN2_CRCR)
32
R
0000_0000h
26.8.15/
1320
209_4048
Rx FIFO Global Mask Register (FLEXCAN2_RXFGMASK)
32
R/W
FFFF_FFFFh
26.8.16/
1321
209_404C
Rx FIFO Information Register (FLEXCAN2_RXFIR)
32
R
0000_0000h
26.8.17/
1322
209_4880
Rx Individual Mask Registers (FLEXCAN2_RXIMR0)
32
R/W
0000_0000h
26.8.18/
1323
209_4884
Rx Individual Mask Registers (FLEXCAN2_RXIMR1)
32
R/W
0000_0000h
26.8.18/
1323
Table continues on the next page...
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1290
NXP Semiconductors

<!-- page 1291 -->

FLEXCAN memory map (continued)
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
209_4888
Rx Individual Mask Registers (FLEXCAN2_RXIMR2)
32
R/W
0000_0000h
26.8.18/
1323
209_488C
Rx Individual Mask Registers (FLEXCAN2_RXIMR3)
32
R/W
0000_0000h
26.8.18/
1323
209_4890
Rx Individual Mask Registers (FLEXCAN2_RXIMR4)
32
R/W
0000_0000h
26.8.18/
1323
209_4894
Rx Individual Mask Registers (FLEXCAN2_RXIMR5)
32
R/W
0000_0000h
26.8.18/
1323
209_4898
Rx Individual Mask Registers (FLEXCAN2_RXIMR6)
32
R/W
0000_0000h
26.8.18/
1323
209_489C
Rx Individual Mask Registers (FLEXCAN2_RXIMR7)
32
R/W
0000_0000h
26.8.18/
1323
209_48A0
Rx Individual Mask Registers (FLEXCAN2_RXIMR8)
32
R/W
0000_0000h
26.8.18/
1323
209_48A4
Rx Individual Mask Registers (FLEXCAN2_RXIMR9)
32
R/W
0000_0000h
26.8.18/
1323
209_48A8
Rx Individual Mask Registers (FLEXCAN2_RXIMR10)
32
R/W
0000_0000h
26.8.18/
1323
209_48AC
Rx Individual Mask Registers (FLEXCAN2_RXIMR11)
32
R/W
0000_0000h
26.8.18/
1323
209_48B0
Rx Individual Mask Registers (FLEXCAN2_RXIMR12)
32
R/W
0000_0000h
26.8.18/
1323
209_48B4
Rx Individual Mask Registers (FLEXCAN2_RXIMR13)
32
R/W
0000_0000h
26.8.18/
1323
209_48B8
Rx Individual Mask Registers (FLEXCAN2_RXIMR14)
32
R/W
0000_0000h
26.8.18/
1323
209_48BC
Rx Individual Mask Registers (FLEXCAN2_RXIMR15)
32
R/W
0000_0000h
26.8.18/
1323
209_48C0
Rx Individual Mask Registers (FLEXCAN2_RXIMR16)
32
R/W
0000_0000h
26.8.18/
1323
209_48C4
Rx Individual Mask Registers (FLEXCAN2_RXIMR17)
32
R/W
0000_0000h
26.8.18/
1323
209_48C8
Rx Individual Mask Registers (FLEXCAN2_RXIMR18)
32
R/W
0000_0000h
26.8.18/
1323
209_48CC
Rx Individual Mask Registers (FLEXCAN2_RXIMR19)
32
R/W
0000_0000h
26.8.18/
1323
209_48D0
Rx Individual Mask Registers (FLEXCAN2_RXIMR20)
32
R/W
0000_0000h
26.8.18/
1323
209_48D4
Rx Individual Mask Registers (FLEXCAN2_RXIMR21)
32
R/W
0000_0000h
26.8.18/
1323
209_48D8
Rx Individual Mask Registers (FLEXCAN2_RXIMR22)
32
R/W
0000_0000h
26.8.18/
1323
209_48DC
Rx Individual Mask Registers (FLEXCAN2_RXIMR23)
32
R/W
0000_0000h
26.8.18/
1323
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1291

<!-- page 1292 -->

FLEXCAN memory map (continued)
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
209_48E0
Rx Individual Mask Registers (FLEXCAN2_RXIMR24)
32
R/W
0000_0000h
26.8.18/
1323
209_48E4
Rx Individual Mask Registers (FLEXCAN2_RXIMR25)
32
R/W
0000_0000h
26.8.18/
1323
209_48E8
Rx Individual Mask Registers (FLEXCAN2_RXIMR26)
32
R/W
0000_0000h
26.8.18/
1323
209_48EC
Rx Individual Mask Registers (FLEXCAN2_RXIMR27)
32
R/W
0000_0000h
26.8.18/
1323
209_48F0
Rx Individual Mask Registers (FLEXCAN2_RXIMR28)
32
R/W
0000_0000h
26.8.18/
1323
209_48F4
Rx Individual Mask Registers (FLEXCAN2_RXIMR29)
32
R/W
0000_0000h
26.8.18/
1323
209_48F8
Rx Individual Mask Registers (FLEXCAN2_RXIMR30)
32
R/W
0000_0000h
26.8.18/
1323
209_48FC
Rx Individual Mask Registers (FLEXCAN2_RXIMR31)
32
R/W
0000_0000h
26.8.18/
1323
209_4900
Rx Individual Mask Registers (FLEXCAN2_RXIMR32)
32
R/W
0000_0000h
26.8.18/
1323
209_4904
Rx Individual Mask Registers (FLEXCAN2_RXIMR33)
32
R/W
0000_0000h
26.8.18/
1323
209_4908
Rx Individual Mask Registers (FLEXCAN2_RXIMR34)
32
R/W
0000_0000h
26.8.18/
1323
209_490C
Rx Individual Mask Registers (FLEXCAN2_RXIMR35)
32
R/W
0000_0000h
26.8.18/
1323
209_4910
Rx Individual Mask Registers (FLEXCAN2_RXIMR36)
32
R/W
0000_0000h
26.8.18/
1323
209_4914
Rx Individual Mask Registers (FLEXCAN2_RXIMR37)
32
R/W
0000_0000h
26.8.18/
1323
209_4918
Rx Individual Mask Registers (FLEXCAN2_RXIMR38)
32
R/W
0000_0000h
26.8.18/
1323
209_491C
Rx Individual Mask Registers (FLEXCAN2_RXIMR39)
32
R/W
0000_0000h
26.8.18/
1323
209_4920
Rx Individual Mask Registers (FLEXCAN2_RXIMR40)
32
R/W
0000_0000h
26.8.18/
1323
209_4924
Rx Individual Mask Registers (FLEXCAN2_RXIMR41)
32
R/W
0000_0000h
26.8.18/
1323
209_4928
Rx Individual Mask Registers (FLEXCAN2_RXIMR42)
32
R/W
0000_0000h
26.8.18/
1323
209_492C
Rx Individual Mask Registers (FLEXCAN2_RXIMR43)
32
R/W
0000_0000h
26.8.18/
1323
209_4930
Rx Individual Mask Registers (FLEXCAN2_RXIMR44)
32
R/W
0000_0000h
26.8.18/
1323
209_4934
Rx Individual Mask Registers (FLEXCAN2_RXIMR45)
32
R/W
0000_0000h
26.8.18/
1323
Table continues on the next page...
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1292
NXP Semiconductors

<!-- page 1293 -->

FLEXCAN memory map (continued)
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
209_4938
Rx Individual Mask Registers (FLEXCAN2_RXIMR46)
32
R/W
0000_0000h
26.8.18/
1323
209_493C
Rx Individual Mask Registers (FLEXCAN2_RXIMR47)
32
R/W
0000_0000h
26.8.18/
1323
209_4940
Rx Individual Mask Registers (FLEXCAN2_RXIMR48)
32
R/W
0000_0000h
26.8.18/
1323
209_4944
Rx Individual Mask Registers (FLEXCAN2_RXIMR49)
32
R/W
0000_0000h
26.8.18/
1323
209_4948
Rx Individual Mask Registers (FLEXCAN2_RXIMR50)
32
R/W
0000_0000h
26.8.18/
1323
209_494C
Rx Individual Mask Registers (FLEXCAN2_RXIMR51)
32
R/W
0000_0000h
26.8.18/
1323
209_4950
Rx Individual Mask Registers (FLEXCAN2_RXIMR52)
32
R/W
0000_0000h
26.8.18/
1323
209_4954
Rx Individual Mask Registers (FLEXCAN2_RXIMR53)
32
R/W
0000_0000h
26.8.18/
1323
209_4958
Rx Individual Mask Registers (FLEXCAN2_RXIMR54)
32
R/W
0000_0000h
26.8.18/
1323
209_495C
Rx Individual Mask Registers (FLEXCAN2_RXIMR55)
32
R/W
0000_0000h
26.8.18/
1323
209_4960
Rx Individual Mask Registers (FLEXCAN2_RXIMR56)
32
R/W
0000_0000h
26.8.18/
1323
209_4964
Rx Individual Mask Registers (FLEXCAN2_RXIMR57)
32
R/W
0000_0000h
26.8.18/
1323
209_4968
Rx Individual Mask Registers (FLEXCAN2_RXIMR58)
32
R/W
0000_0000h
26.8.18/
1323
209_496C
Rx Individual Mask Registers (FLEXCAN2_RXIMR59)
32
R/W
0000_0000h
26.8.18/
1323
209_4970
Rx Individual Mask Registers (FLEXCAN2_RXIMR60)
32
R/W
0000_0000h
26.8.18/
1323
209_4974
Rx Individual Mask Registers (FLEXCAN2_RXIMR61)
32
R/W
0000_0000h
26.8.18/
1323
209_4978
Rx Individual Mask Registers (FLEXCAN2_RXIMR62)
32
R/W
0000_0000h
26.8.18/
1323
209_497C
Rx Individual Mask Registers (FLEXCAN2_RXIMR63)
32
R/W
0000_0000h
26.8.18/
1323
209_49E0
Glitch Filter Width Registers (FLEXCAN2_GFWR)
32
R/W
0000_007Fh
26.8.19/
1323
26.8.1
Module Configuration Register (FLEXCANx_MCR)
This register defines global system configurations, such as the module operation mode
(e.g., low power) and maximum message buffer configuration.
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1293

<!-- page 1294 -->

Address: Base address + 0h offset
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
MDIS
FRZ
RFEN
HALT
NOT_RDY
WAK_MSK
SOFT_RST
FRZ_ACK
SUPV
SLF_
WAK
WRN_EN
LPM_ACK
WAK_SRC
Reserved
SRX_DIS
IRMQ
W
Reset
0
1
0
1
1
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
LPRIO_EN
AEN
Reserved
IDAM
Reserved
MAXMB
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
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1294
NXP Semiconductors

<!-- page 1295 -->

FLEXCANx_MCR field descriptions
Field
Description
31
MDIS
This bit controls whether FLEXCAN is enabled or not. When disabled, FLEXCAN shuts down the clocks to
the CAN Protocol Interface and Message Buffer Management sub-modules. This is the only bit in MCR not
affected by soft reset. See Module Disable Mode for more information.
1
Disable the FLEXCAN module
0
Enable the FLEXCAN module
30
FRZ
The FRZ bit specifies the FLEXCAN behavior when the HALT bit in the MCR Register is set or when
Debug Mode is requested at Arm level. When FRZ is asserted, FLEXCAN is enabled to enter Freeze
Mode. Negation of this bit field causes FLEXCAN to exit from Freeze Mode.
1
Enabled to enter Freeze Mode
0
Not enabled to enter Freeze Mode
29
RFEN
This bit controls whether the Rx FIFO feature is enabled or not. When RFEN is set, MBs 0 to 5 cannot be
used for normal reception and transmission because the corresponding memory region (0x80-0xDC) is
used by the FIFO engine as well as additional MBs (up to 32, depending on CTRL2[RFFN] setting) which
are used as Rx FIFO ID Filter Table elements.RFEN also impacts the definition of the minimum number of
peripheral clocks per CAN bit as described in Table 26-18 (see Arbitration and Matching Timing).This bit
can only be written in Freeze mode as it is blocked by hardware in other modes.
1
FIFO enabled
0
FIFO not enabled
28
HALT
Assertion of this bit puts the FLEXCAN module into Freeze Mode. The Arm should clear it after initializing
the Message Buffers and Control Register. No reception or transmission is performed by FLEXCAN before
this bit is cleared. Freeze Mode can not be entered while FLEXCAN is in any of the low power modes.See
Freeze Mode for more information
1
Enters Freeze Mode if the FRZ bit is asserted.
0
No Freeze Mode request.
27
NOT_RDY
This read-only bit indicates that FLEXCAN is either in Disable Mode, Stop Mode or Freeze Mode. It is
negated once FLEXCAN has exited these modes.
1
FLEXCAN module is either in Disable Mode, Stop Mode or Freeze Mode
0
FLEXCAN module is either in Normal Mode, Listen-Only Mode or Loop-Back Mode
26
WAK_MSK
This bit enables the Wake Up Interrupt generation.
1
Wake Up Interrupt is enabled
0
Wake Up Interrupt is disabled
25
SOFT_RST
When this bit is asserted, FlexCAN resets its internal state machines and some of the memory mapped
registers. The following registers are reset: MCR (except the MDIS bit), TIMER, ECR, ESR1, ESR2,
IMASK1, IMASK2, IFLAG1, IFLAG2 and CRCR. Configuration registers that control the interface to the
CAN bus are not affected by soft reset. The following registers are unaffected:
CTRL1, CTRL2, RXIMR0_RXIMR63, RXGMASK, RX14MASK, RX15MASK, RXFGMASK, RXFIR and all
Message Buffers
The SOFT_RST bit can be asserted directly by the Arm when it writes to the MCR Register. It may take
some time to fully propagate its effect. The SOFT_RST bit remains asserted while reset is pending, and is
automatically negated when reset completes. Therefore, software can poll this bit to know when the soft
reset has completed.
Soft reset cannot be applied while clocks are shut down in any of the low power modes. The module
should be first removed from low power mode, and then soft reset can be applied.
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1295

<!-- page 1296 -->

FLEXCANx_MCR field descriptions (continued)
Field
Description
1
Reset the registers
0
No reset request
24
FRZ_ACK
This read-only bit indicates that FLEXCAN is in Freeze Mode and its prescaler is stopped. The Freeze
Mode request cannot be granted until current transmission or reception processes have finished.
Therefore the software can poll the FRZ_ACK bit to know when FLEXCAN has actually entered Freeze
Mode. If Freeze Mode request is negated, then this bit is negated once the FLEXCAN prescaler is running
again. If Freeze Mode is requested while FLEXCAN is in any of the low power modes, then the FRZ_ACK
bit will only be set when the low power mode is exited. See Freeze Mode for more information
1
FLEXCAN in Freeze Mode, prescaler stopped
0
FLEXCAN not in Freeze Mode, prescaler running
23
SUPV
This bit configures some of the FLEXCAN registers to be either in Supervisor or User Mode. Reset value
of this bit is '1', so the affected registers start with Supervisor access allowance only. This bit can only be
written in Freeze mode as it is blocked by hardware in other modes.
1
FlexCAN is in Supervisor Mode. Affected registers allow only Supervisor access. Unrestricted access
behaves as though the access was done to an unimplemented register location
0
FlexCAN is in User Mode. Affected registers allow both Supervisor and Unrestricted accesses
22
SLF_WAK
This bit enables the Self Wake Up feature when FLEXCAN is in Stop Mode. If this bit had been asserted
by the time FLEXCAN entered Stop Mode, then FLEXCAN will look for a recessive to dominant transition
on the bus during these modes. If a transition from recessive to dominant is detected during Stop Mode,
then FLEXCAN generates, if enabled to do so, a Wake Up interrupt to the Arm so that it can resume the
clocks globally and FlexCAN can request to resume the clocks. This bit can not be written while the
module is in Stop Mode.
1
FLEXCAN Self Wake Up feature is enabled
0
FLEXCAN Self Wake Up feature is disabled
21
WRN_EN
When asserted, this bit enables the generation of the TWRN_INT and RWRN_INT flags in the Error and
Status Register. If WRN_EN is negated, the TWRN_INT and RWRN_INT flags will always be zero,
independent of the values of the error counters, and no warning interrupt will ever be generated.This bit
can only be written in Freeze mode as it is blocked by hardware in other modes.
1
TWRN_INT and RWRN_INT bits are set when the respective error counter transition from <96 to ≥ 96.
0
TWRN_INT and RWRN_INT bits are zero, independent of the values in the error counters.
20
LPM_ACK
This read-only bit indicates that FLEXCAN is either in Disable Mode or Stop Mode. Either of these low
power modes can not be entered until all current transmission or reception processes have finished, so
the Arm can poll the LPM_ACK bit to know when FLEXCAN has actually entered low power mode. See
Module Disable Mode, and Stop Mode for more information
1
FLEXCAN is either in Disable Mode, or Stop mode
0
FLEXCAN not in any of the low power modes
19
WAK_SRC
This bit defines whether the integrated low-pass filter is applied to protect the FLEXCAN_RX input from
spurious wake up. See Stop Mode for more information. This bit can only be written in Freeze mode as it
is blocked by hardware in other modes.
1
FLEXCAN uses the filtered FLEXCAN_RX input to detect recessive to dominant edges on the CAN
bus
0
FLEXCAN uses the unfiltered FLEXCAN_RX input to detect recessive to dominant edges on the CAN
bus.
18
-
This field is reserved.
Reserved
Table continues on the next page...
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1296
NXP Semiconductors

<!-- page 1297 -->

FLEXCANx_MCR field descriptions (continued)
Field
Description
17
SRX_DIS
This bit defines whether FlexCAN is allowed to receive frames transmitted by itself. If this bit is asserted,
frames transmitted by the module will not be stored in any MB, regardless if the MB is programmed with
an ID that matches the transmitted frame, and no interrupt flag or interrupt signal will be generated due to
the frame reception. This bit can only be written in Freeze mode as it is blocked by hardware in other
modes.
1
Self reception disabled
0
Self reception enabled
16
IRMQ
This bit indicates whether Rx matching process will be based either on individual masking and queue or
on masking scheme with RXMGMASK, RX14MASK and RX15MASK, RXFGMASK. This bit can only be
written in Freeze mode as it is blocked by hardware in other modes.
1
Individual Rx masking and queue feature are enabled.
0
Individual Rx masking and queue feature are disabled.For backward compatibility, the reading of C/S
word locks the MB even if it is EMPTY.
15–14
-
This field is reserved.
Reserved
13
LPRIO_EN
This bit is provided for backwards compatibility reasons. It controls whether the local priority feature is
enabled or not. It is used to extend the ID used during the arbitration process. With this extended ID
concept, the arbitration process is done based on the full 32-bit word, but the actual transmitted ID still has
11-bit for standard frames and 29-bit for extended frames.This bit can only be written in Freeze mode as it
is blocked by hardware in other modes.
1
Local Priority enabled
0
Local Priority disabled
12
AEN
This bit is supplied for backwards compatibility reasons. When asserted, it enables the Tx abort feature.
This feature guarantees a safe procedure for aborting a pending transmission, so that no frame is sent in
the CAN bus without notification. This bit can only be written in Freeze mode as it is blocked by hardware
in other modes.Write Abort code into Rx Mailboxes can cause unpredictable results when the MCR[AEN]
is asserted.
1
Abort enabled
0
Abort disabled
11–10
-
This field is reserved.
Reserved
9–8
IDAM
This 2-bit field identifies the format of the elements of the Rx FIFO filter table, as shown below. Note that
all elements of the table are configured at the same time by this field (they are all the same format). See
Rx FIFO Structure. This bit can only be written in Freeze mode as it is blocked by hardware in other
modes.
00
Format A One full ID (standard or extended) per ID filter Table element.
01
Format B Two full standard IDs or two partial 14-bit extended IDs per ID filter Table element.
10
Format C Four partial 8-bit IDs (standard or extended) per ID filter Table element.
11
Format D All frames rejected.
7
-
This field is reserved.
Reserved
MAXMB
This 7-bit field defines the number of the last Message Buffers that will take part in the matching and
arbitration processes. The reset value (0x0F) is equivalent to 16 MB configuration. This field can only be
written in Freeze Mode as it is blocked by hardware in other modes
Number of the last MB = MAXMB.
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1297

<!-- page 1298 -->

FLEXCANx_MCR field descriptions (continued)
Field
Description
NOTE: Additionally, the value of MAXMB must encompass the FIFO size defined by CTRL2[RFFN]
MAXMB also impacts the definition of the minimum number of peripheral clocks per CAN bit as described
in Table 26-18 (see Arbitration and Matching Timing).
26.8.2
Control 1 Register (FLEXCANx_CTRL1)
This register is defined for specific FLEXCAN control features related to the CAN bus,
such as bit-rate, programmable sampling point within an Rx bit, Loop Back Mode, Listen
Only Mode, Bus Off recovery behavior and interrupt enabling (Bus-Off, Error, Warning).
It also determines the Division Factor for the clock prescaler.
Address: Base address + 4h offset
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
PRESDIV
RJW
PSEG1
PSEG2
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
BOFF_MSK
ERR_
MSK
Reserved
LPB
TWRN_MSK
RWRN_MSK
Reserved
SMP
BOFF_REC
TSYN LBUF
LOM
PROP_SEG
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
FLEXCANx_CTRL1 field descriptions
Field
Description
31–24
PRESDIV
This 8-bit field defines the ratio between the PE clock frequency and the Serial Clock (Sclock) frequency.
The Sclock period defines the time quantum of the CAN protocol. For the reset value, the Sclock
frequency is equal to the PE clock frequency. The Maximum value of this register is 0xFF, that gives a
minimum Sclock frequency equal to the PE clock frequency divided by 256.For more information refer to
Protocol Timing. This field can only be written in Freeze mode as it is blocked by hardware in other
modes.
Table continues on the next page...
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1298
NXP Semiconductors

<!-- page 1299 -->

FLEXCANx_CTRL1 field descriptions (continued)
Field
Description
Sclock frequency = CPI clock frequency / (PRESDIV+1)
23–22
RJW
This 2-bit field defines the maximum number of time quanta1 that a bit time can be changed by one re-
synchronization. The valid programmable values are 0-3. This field can only be written in Freeze mode as
it is blocked by hardware in other modes
Resync Jump Width = RJW + 1.
21–19
PSEG1
This 3-bit field defines the length of Phase Buffer Segment 1 in the bit time . The valid programmable
values are 0-7. This field can only be written in Freeze mode as it is blocked by hardware in other modes
Phase Buffer Segment 1 = (PSEG1 + 1) x Time-Quanta.
18–16
PSEG2
This 3-bit field defines the length of Phase Buffer Segment 2 in the bit time . The valid programmable
values are 1-7. This field can only be written in Freeze mode as it is blocked by hardware in other modes
Phase Buffer Segment 2 = (PSEG2 + 1) x Time-Quanta.
15
BOFF_MSK
This bit provides a mask for the Bus Off Interrupt.
1
Bus Off interrupt enabled
0
Bus Off interrupt disabled
14
ERR_MSK
This bit provides a mask for the Error Interrupt.
1
Error interrupt enabled
0
Error interrupt disabled
13
-
This field is reserved.
Reserved
12
LPB
This bit configures FlexCAN to operate in Loop-Back Mode. In this mode, FlexCAN performs an internal
loop back that can be used for self test operation. The bit stream output of the transmitter is fed back
internally to the receiver input. The FLEXCAN_RX input pin is ignored and the FLEXCAN_TX output goes
to the recessive state (logic '1'). FlexCAN behaves as it normally does when transmitting, and treats its
own transmitted message as a message received from a remote node. In this mode, FlexCAN ignores the
bit sent during the ACK slot in the CAN frame acknowledge field, generating an internal acknowledge bit to
ensure proper reception of its own message. Both transmit and receive interrupts are generated. This bit
can only be written in Freeze mode as it is blocked by hardware in other modes.
1
Loop Back enabled
0
Loop Back disabled
11
TWRN_MSK
This bit provides a mask for the Tx Warning Interrupt associated with the TWRN_INT flag in the Error and
Status Register. This bit is read as zero when MCR[WRN_EN] bit is negated. This bit can only be written if
MCR[WRN_EN] bit is asserted.
1
Tx Warning Interrupt enabled
0
Tx Warning Interrupt disabled
10
RWRN_MSK
This bit provides a mask for the Rx Warning Interrupt associated with the RWRN_INT flag in the Error and
Status Register. This bit is read as zero when MCR[WRN_EN] bit is negated. This bit can only be written if
MCR[WRN_EN] bit is asserted.
1
Rx Warning Interrupt enabled
0
Rx Warning Interrupt disabled
9–8
-
This field is reserved.
Reserved
7
SMP
This bit defines the sampling mode of CAN bits at the FLEXCAN_RX. This bit can only be written in
Freeze mode as it is blocked by hardware in other modes.
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1299

<!-- page 1300 -->

FLEXCANx_CTRL1 field descriptions (continued)
Field
Description
1
Three samples are used to determine the value of the received bit: the regular one (sample point) and
2 preceding samples, a majority rule is used
0
Just one sample is used to determine the bit value
6
BOFF_REC
This bit defines how FLEXCAN recovers from Bus Off state. If this bit is negated, automatic recovering
from Bus Off state occurs according to the CAN Specification 2.0B. If the bit is asserted, automatic
recovering from Bus Off is disabled and the module remains in Bus Off state until the bit is negated by the
user. If the negation occurs before 128 sequences of 11 recessive bits are detected on the CAN bus, then
Bus Off recovery happens as if the BOFF_REC bit had never been asserted. If the negation occurs after
128 sequences of 11 recessive bits occurred, then FLEXCAN will re-synchronize to the bus by waiting for
11 recessive bits before joining the bus. After negation, the BOFF_REC bit can be re-asserted again
during Bus Off, but it will only be effective the next time the module enters Bus Off. If BOFF_REC was
negated when the module entered Bus Off, asserting it during Bus Off will not be effective for the current
Bus Off recovery.
1
Automatic recovering from Bus Off state disabled
0
Automatic recovering from Bus Off state enabled, according to CAN Spec 2.0 part B
5
TSYN
This bit enables a mechanism that resets the free-running timer each time a message is received in
Message Buffer 0. This feature provides means to synchronize multiple FLEXCAN stations with a special
"SYNC" message (i.e., global network time). If the RFEN bit in MCR is set (FIFO enabled), the first
available Mailbox, according to CTRL2[RFFN] setting, is used for timer synchronization instead of
MB0.This bit can only be written in Freeze mode as it is blocked by hardware in other modes.
1
Timer Sync feature enabled
0
Timer Sync feature disabled
4
LBUF
This bit defines the ordering mechanism for Message Buffer transmission. When asserted, the LPRIO_EN
bit does not affect the priority arbitration.This bit can only be written in Freeze mode as it is blocked by
hardware in other modes.
1
Lowest number buffer is transmitted first
0
Buffer with highest priority is transmitted first
3
LOM
This bit configures FLEXCAN to operate in Listen Only Mode. In this mode, transmission is disabled, all
error counters are frozen and the module operates in a CAN Error Passive mode. Only messages
acknowledged by another CAN station will be received. If FLEXCAN detects a message that has not been
acknowledged, it will flag a BIT0 error (without changing the REC), as if it was trying to acknowledge the
message.
Listen-Only Mode acknowledgement can be obtained by the state of ESR1[FLT_CONF] field which is
Passive Error when Listen-Only Mode is entered. There can be some delay between the Listen-Only
Mode request and acknowledge.
This bit can only be written in Freeze mode as it is blocked by hardware in other modes.
1
FLEXCAN module operates in Listen Only Mode
0
Listen Only Mode is deactivated
PROP_SEG
This 3-bit field defines the length of the Propagation Segment in the bit time. The valid programmable
values are 0-7. This field can only be written in Freeze mode as it is blocked by hardware in other modes
Propagation Segment Time = (PROPSEG + 1) * Time-Quanta.
Time-Quantum = one Sclock period.
1. One time quantum is equal to the Sclock period.
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1300
NXP Semiconductors

<!-- page 1301 -->

26.8.3
Free Running Timer Register (FLEXCANx_TIMER)
This register represents a 16-bit free running counter that can be read and written by the
Arm. The timer starts from $0000 after Reset, counts linearly to $FFFF, and wraps
around.
The timer is clocked by the FLEXCAN bit-clock (which defines the baud rate on the
CAN bus). During a message transmission/reception, it increments by one for each bit
that is received or transmitted. When there is no message on the bus, it counts using the
previously programmed baud rate. During Freeze Mode, disable, and stop mode, the
timer is not incremented.
The timer value is captured at the beginning of the identifier field of any frame on the
CAN bus. This captured value is written into the Time Stamp entry in a message buffer
after a successful reception or transmission of a message.
If bit CTRL1[TSYN] is asserted the Timer is reset whenever a message is received in the
first available Mailbox, according to CTRL2[RFFN] setting.
Arm can write to this register anytime. However, if the write occurs at the same time that
the Timer is being reset by a reception in the first Mailbox, then the write value is
discarded.
Reading this register affects the Mailbox Unlocking procedure. For additional details,
refer to Message Buffer Lock Mechanism.
Address: Base address + 8h offset
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
TIMER
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
FLEXCANx_TIMER field descriptions
Field
Description
31–16
-
This field is reserved.
Reserved
TIMER
TIMER
26.8.4
Rx Mailboxes Global Mask Register
(FLEXCANx_RXMGMASK)
RXMGMASK is provided for legacy support. Asserting the MCR[IRMQ] bit causes the
RXMGMASK Register to have no effect on the module operation.
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1301

<!-- page 1302 -->

RXMGMASK is used to mask the filter fields of all Rx MBs, excluding MBs 14-15,
which have individual mask registers.
This register can only be written in Freeze mode as it is blocked by hardware in other
modes.
Table 26-19. Rx Mailboxes Global Mask usage
SMB[RTR]1
CTRL2[RRS]
CTRL2[EACEN]
Mailbox filter fields
MB[RTR]
MB[IDE]
MB[ID]
reserved
0
-
0
-
Note2
-
Note3
MG[28:0]
MG[31:29]
0
-
1
MG[31]
MG[30]
MG[28:0]
MG[29]
1
0
-
-
-
-
MG[31:0]
1
1
0
-
-
MG[28:0]
MG[31:29]
1
1
1
MG[31]
MG[30]
MG[28:0]
MG[29]
1.
RTR bit of the Incoming Frame. It is saved into an auxiliary MB called Rx Serial Message Buffer (Rx SMB).
2.
If CTRL2[EACEN] bit is negated the RTR bit of Mailbox is never compared with the RTR bit of the Incoming Frame (Rx
SMB[RTR]).
3.
If CTRL2[EACEN] bit is negated the IDE bit of Mailbox is always compared with the IDE bit of the Incoming Frame (Rx
SMB[IDE]).
Address: Base address + 10h offset
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
MG31_MG0
W
Reset 1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
FLEXCANx_RXMGMASK field descriptions
Field
Description
MG31_MG0
These bits mask the Mailbox filter bits as shown in the figure above. Note that the alignment with the ID
word of the Mailbox is not perfect as the two most significant MG bits affect the fields RTR and IDE which
are located in the Control and Status word of the Mailbox. Rx Mailboxes Global Mask Register
(FLEXCAN_RXMGMASK) shows in detail which MG bits mask each Mailbox filter field.
1
The corresponding bit in the filter is checked against the one received
0
the corresponding bit in the filter is "don't care"
26.8.5
Rx Buffer 14 Mask Register (FLEXCANx_RX14MASK)
RX14MASK is provided for legacy support, asserting the MCR[IRMQ] bit causes the
RX14MASK to have no effect on the module operation.
RX14MASK is used to mask the filter fields of Message Buffer 14.
This register can only be programmed while the module is in Freeze Mode as it is
blocked by hardware in other modes.
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1302
NXP Semiconductors

<!-- page 1303 -->

Address: Base address + 14h offset
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
RX14M31_RX14M0
W
Reset 1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
FLEXCANx_RX14MASK field descriptions
Field
Description
RX14M31_
RX14M0
These bits mask Mailbox 14 filter bits in the same fashion as RXMGMASK masks other Mailboxes filters
(see Rx Mailboxes Global Mask Register (FLEXCAN_RXMGMASK))
1
The corresponding bit in the filter is checked
0
the corresponding bit in the filter is "don't care"
26.8.6
Rx Buffer 15 Mask Register (FLEXCANx_RX15MASK)
RX15MASK is provided for legacy support, asserting the MCR[IRMQ] bit causes the
RX15MASK Register to have no effect on the module operation.
RX15MASK is used to mask the filter fields of Message Buffer 15.
This register can only be programmed while the module is in Freeze Mode as it is
blocked by hardware in other modes.
Address: Base address + 18h offset
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
RX15M31_RX15M0
W
Reset 1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
FLEXCANx_RX15MASK field descriptions
Field
Description
RX15M31_
RX15M0
These bits mask Mailbox 15 filter bits in the same fashion as RXMGMASK masks other Mailboxes filters
(see Rx Mailboxes Global Mask Register (FLEXCAN_RXMGMASK)).
1
The corresponding bit in the filter is checked
0
the corresponding bit in the filter is "don't care"
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1303

<!-- page 1304 -->

26.8.7
Error Counter Register (FLEXCANx_ECR)
This register has 2 8-bit fields reflecting the value of two FLEXCAN error counters:
Transmit Error Counter (Tx_Err_Counter field) and Receive Error Counter
(Rx_Err_Counter field). The rules for increasing and decreasing these counters are
described in the CAN protocol and are completely implemented in the FLEXCAN
module. Both counters are read only except in Freeze Mode, where they can be written
by the Arm.
FLEXCAN responds to any bus state as described in the protocol, e.g. transmit 'Error
Active' or 'Error Passive' flag, delay its transmission start time ('Error Passive') and avoid
any influence on the bus when in 'Bus Off' state. The following are the basic rules for
FLEXCAN bus state transitions.
• If the value of Tx_Err_Counter or Rx_Err_Counter increases to be greater than or
equal to 128, the FLT_CONF field in the Error and Status Register is updated to
reflect 'Error Passive' state.
• If the FLEXCAN state is 'Error Passive', and either Tx_Err_Counter or
Rx_Err_Counter decrements to a value less than or equal to 127 while the other
already satisfies this condition, the FLT_CONF field in the Error and Status Register
is updated to reflect 'Error Active' state.
• If the value of Tx_Err_Counter increases to be greater than 255, the FLT_CONF
field in the Error and Status Register is updated to reflect 'Bus Off' state, and an
interrupt may be issued. The value of Tx_Err_Counter is then reset to zero.
• If FLEXCAN is in 'Bus Off' state, then Tx_Err_Counter is cascaded together with
another internal counter to count the 128th occurrences of 11 consecutive recessive
bits on the bus. Hence, Tx_Err_Counter is reset to zero and counts in a manner where
the internal counter counts 11 such bits and then wraps around while incrementing
the Tx_Err_Counter. When Tx_Err_Counter reaches the value of 128, the
FLT_CONF field in the Error and Status Register is updated to be 'Error Active' and
both error counters are reset to zero. At any instance of dominant bit following a
stream of less than 11 consecutive recessive bits, the internal counter resets itself to
zero without affecting the Tx_Err_Counter value.
• If during system start-up, only one node is operating, then its Tx_Err_Counter
increases in each message it is trying to transmit, as a result of acknowledge errors
(indicated by the ACK_ERR bit in the Error and Status Register). After the transition
to 'Error Passive' state, the Tx_Err_Counter does not increment anymore by
acknowledge errors. Therefore the device never goes to the 'Bus Off' state.
• If the Rx_Err_Counter increases to a value greater than 127, it is not incremented
further, even if more errors are detected while being a receiver. At the next
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1304
NXP Semiconductors

<!-- page 1305 -->

successful message reception, the counter is set to a value between 119 and 127 to
resume to 'Error Active' state.
Address: Base address + 1Ch offset
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
RX_ERR_COUNTER
TX_ERR_COUNTER
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
FLEXCANx_ECR field descriptions
Field
Description
31–16
-
This field is reserved.
Reserved
15–8
RX_ERR_
COUNTER
Rx_Err_Counter
TX_ERR_
COUNTER
Tx_Err_Counter
26.8.8
Error and Status 1 Register (FLEXCANx_ESR1)
This register reflects various error conditions, some general status of the device and it is
the source of four interrupts to the Arm.
The Arm read action clears bits 15-10, therefore the reported error conditions(bits 15-10)
are those that occurred since the last time the Arm read this register. Bits 9-3 are status
bits .
Some bits in this register are read-only and some are not .
Table 26-20. FlexCAN State
SYNCH
IDLE
TX
RX
FlexCAN state
0
0
0
0
Not synchronized to CAN bus
1
1
x
x
Idle
1
0
1
0
Transmitting
1
0
0
1
Receiving
other combinations
Reserved
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1305

<!-- page 1306 -->

Address: Base address + 20h offset
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
SYNCH
TWRN_INT
RWRN_INT
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
BIT1_ERR
BIT0_ERR
ACK_ERR
CRC_ERR
FRM_ERR
STF_
ERR
TX_WRN
RX_WRN
IDLE
TX
FLT_CONF
RX
BOFF_INT
ERR_INT
WAK_INT
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
FLEXCANx_ESR1 field descriptions
Field
Description
31–19
-
This field is reserved.
Reserved
18
SYNCH
This read-only flag indicates whether the FlexCAN is synchronized to the CAN bus and able to participate
in the communication process. It is set and cleared by the FlexCAN. Refer to Table 26-20
1
FlexCAN is synchronized to the CAN bus
0
FlexCAN is not synchronized to the CAN bus
17
TWRN_INT
If the WRN_EN bit in MCR is asserted, the TWRN_INT bit is set when the TX_WRN flag transition from '0'
to '1', meaning that the Tx error counter reached 96. If the corresponding mask bit in the Control Register
(TWRN_MSK) is set, an interrupt is generated to the Arm. This bit is cleared by writing it to '1'. When
WRN_EN is negated, this flag is masked. Arm must clear this flag before disabling the bit. Otherwise it will
be set when the WRN_EN is set again. Writing '0' has no effect. This flag is not generated during "Bus Off"
state. This bit is not updated during Freeze mode.
1
The Tx error counter transition from < 96 to >= 96
0
No such occurrence
Table continues on the next page...
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1306
NXP Semiconductors

<!-- page 1307 -->

FLEXCANx_ESR1 field descriptions (continued)
Field
Description
16
RWRN_INT
If the WRN_EN bit in MCR is asserted, the RWRN_INT bit is set when the RX_WRN flag transition from '0'
to '1', meaning that the Rx error counters reached 96. If the corresponding mask bit in the Control Register
(RWRN_MSK) is set, an interrupt is generated to the Arm. This bit is cleared by writing it to '1'. When
WRN_EN is negated, this flag is masked. Arm must clear this flag before disabling the bit. Otherwise it will
be set when the WRN_EN is set again. Writing '0' has no effect. This bit is not updated during Freeze
mode.
1
The Rx error counter transition from < 96 to >= 96
0
No such occurrence
15
BIT1_ERR
This bit indicates when an inconsistency occurs between the transmitted and the received bit in a
message.
This bit is not set by a transmitter in case of arbitration field or ACK slot, or in case of a node sending a
passive error flag that detects dominant bits.
1
At least one bit sent as recessive is received as dominant
0
No such occurrence
14
BIT0_ERR
This bit indicates when an inconsistency occurs between the transmitted and the received bit in a
message.
1
At least one bit sent as dominant is received as recessive
0
No such occurrence
13
ACK_ERR
This bit indicates that an Acknowledge Error has been detected by the transmitter node, i.e., a dominant
bit has not been detected during the ACK SLOT.
1
An ACK error occurred since last read of this register
0
No such occurrence
12
CRC_ERR
This bit indicates that a CRC Error has been detected by the receiver node, i.e., the calculated CRC is
different from the received.
1
A CRC error occurred since last read of this register.
0
No such occurrence
11
FRM_ERR
This bit indicates that a Form Error has been detected by the receiver node, i.e., a fixed-form bit field
contains at least one illegal bit.
1
A Form Error occurred since last read of this register
0
No such occurrence
10
STF_ERR
This bit indicates that a Stuffing Error has been detected.
1
A Stuffing Error occurred since last read of this register.
0
No such occurrence.
9
TX_WRN
This bit indicates when repetitive errors are occurring during message transmission.
1
TX_Err_Counter ≥ 96
0
No such occurrence
8
RX_WRN
This bit indicates when repetitive errors are occurring during message reception.
1
Rx_Err_Counter ≥ 96
0
No such occurrence
7
IDLE
This bit indicates when CAN bus is in IDLE state.Refer to Table 26-20.
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1307

<!-- page 1308 -->

FLEXCANx_ESR1 field descriptions (continued)
Field
Description
1
CAN bus is now IDLE
0
No such occurrence
6
TX
This bit indicates if FLEXCAN is transmitting a message.Refer to Table 26-20.
1
FLEXCAN is transmitting a message
0
FLEXCAN is receiving a message
5–4
FLT_CONF
If the LOM bit in the Control Register is asserted, after some delay that depends on the CAN bit timing the
FLT_CONF field will indicate "Error Passive". The very same delay affects the way how FLT_CONF
reflects an update to ECR register by the Arm. It may be necessary up to one CAN bit time to get them
coherent again.
Since the Control Register is not affected by soft reset, the FLT_CONF field will not be affected by soft
reset if the LOM bit is asserted.
This 2-bit field indicates the Confinement State of the FLEXCAN module, as shown in below:
00
Error Active
01
Error Passive
1x
Bus off
3
RX
This bit indicates if FlexCAN is receiving a message. Refer to Table 26-20.
1
FLEXCAN is transmitting a message
0
FLEXCAN is receiving a message
2
BOFF_INT
This bit is set when FLEXCAN enters 'Bus Off' state. If the corresponding mask bit in the Control Register
(BOFF_MSK) is set, an interrupt is generated to the Arm. This bit is cleared by writing it to '1'. Writing '0'
has no effect.
1
FLEXCAN module entered 'Bus Off' state
0
No such occurrence
1
ERR_INT
This bit indicates that at least one of the Error Bits (bits 15-10) is set. If the corresponding mask bit in the
Control Register (ERR_MSK) is set, an interrupt is generated to the Arm. This bit is cleared by writing it to
'1'.Writing '0' has no effect.
1
Indicates setting of any Error Bit in the Error and Status Register
0
No such occurrence
0
WAK_INT
When FLEXCAN is Stop Mode and a recessive to dominant transition is detected on the CAN bus and if
the WAK_MSK bit in the MCR Register is set, an interrupt is generated to the Arm. This bit is cleared by
writing it to '1'. When SLF_WAK is negated, this flag is masked. Arm must clear this flag before disabling
the bit. Otherwise it will be set when the SLF_WAK is set again. Writing '0' has no effect
1
Indicates a recessive to dominant transition received on the CAN bus when the FLEXCAN module is
in Stop Mode
0
No such occurrence
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1308
NXP Semiconductors

<!-- page 1309 -->

26.8.9
Interrupt Masks 2 Register (FLEXCANx_IMASK2)
This register allows any number of a range of 32 Message Buffer Interrupts to be enabled
or disabled. It contains one interrupt mask bit per buffer, enabling the Arm to determine
which buffer generates an interrupt after a successful transmission or reception (i.e. when
the corresponding IFLAG2 bit is set).
Address: Base address + 24h offset
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
BUF63M_BUF32M
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
FLEXCANx_IMASK2 field descriptions
Field
Description
BUF63M_
BUF32M
Each bit enables or disables the respective FLEXCAN Message Buffer (MB32 to MB63) Interrupt.
Setting or clearing a bit in the IMASK2 Register can assert or negate an interrupt request, if the
corresponding IFLAG2 bit is set.
1
The corresponding buffer Interrupt is enabled
0
The corresponding buffer Interrupt is disabled
26.8.10
Interrupt Masks 1 Register (FLEXCANx_IMASK1)
This register allows to enable or disable any number of a range of 32 Message Buffer
Interrupts. It contains one interrupt mask bit per buffer, enabling the Arm to determine
which buffer generates an interrupt after a successful transmission or reception (i.e.,
when the corresponding IFLAG1 bit is set).
Address: Base address + 28h offset
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
BUF31M_BUF0M
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
FLEXCANx_IMASK1 field descriptions
Field
Description
BUF31M_BUF0M Each bit enables or disables the respective FLEXCAN Message Buffer (MB0 to MB31) Interrupt.
Setting or clearing a bit in the IMASK1 Register can assert or negate an interrupt request, if the
corresponding IFLAG1 bit is set
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1309

<!-- page 1310 -->

FLEXCANx_IMASK1 field descriptions (continued)
Field
Description
1
The corresponding buffer Interrupt is enabled
0
The corresponding buffer Interrupt is disabled
26.8.11
Interrupt Flags 2 Register (FLEXCANx_IFLAG2)
This register defines the flags for 32 Message Buffer interrupts. It contains one interrupt
flag bit per buffer. Each successful transmission or reception sets the corresponding
IFLAG2 bit. If the corresponding IMASK2 bit is set, an interrupt will be generated. The
interrupt flag must be cleared by writing it to '1'. Writing '0' has no effect.Before updating
MCR[MAXMB] field, Arm must treat the IFLAG2 bits which MB value is greater than
the MCR[MAXMB] to be updated, otherwise they will keep set and be inconsistent with
the amount of MBs available.
Address: Base address + 2Ch offset
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
BUF63I_BUF32I
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
FLEXCANx_IFLAG2 field descriptions
Field
Description
BUF63I_BUF32I
Each bit flags the respective FLEXCAN Message Buffer (MB32 to MB63) interrupt.
1
The corresponding buffer has successfully completed transmission or reception
0
No such occurrence
26.8.12
Interrupt Flags 1 Register (FLEXCANx_IFLAG1)
This register defines the flags for 32 Message Buffer interrupts and FIFO interrupts. It
contains one interrupt flag bit per buffer. Each successful transmission or reception sets
the corresponding IFLAG1 bit. If the corresponding IMASK1 bit is set, an interrupt will
be generated. The Interrupt flag must be cleared by writing it to '1'. Writing '0' has no
effect.
When the RFEN bit in the MCR is set (Rx FIFO enabled), the function of the 8 least
significant interrupt flags (BUF7I - BUF0I) is changed to support the FIFO operation.
BUF7I, BUF6I and BUF5I indicate operating conditions of the FIFO, while BUF4I to
BUF0I are not used. Before enabling the RFEN, Arm must service the IFLAGS asserted
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1310
NXP Semiconductors

<!-- page 1311 -->

in the Rx FIFO region (see Rx FIFO). Otherwise, these IFLAGS will mistakenly show
the related MBs now belonging to FIFO as having contents to be serviced. When the
RFEN is negated, the FIFO flags must be cleared. The same care must be taken when a
RFFN value is selected extending Rx FIFO filters beyond MB7 (see Control 2 Register
(FLEXCAN_CTRL2)). For example, when RFFN is 0x8, the MB0-23 range is occupied
by Rx FIFO filters and related IFLAGS must be cleared.
Before updating MCR[MAXMB] field, Arm must service the IFLAG1 which MB value
is greater than the MCR[MAXMB] to be updated, otherwise they will keep set and be
inconsistent with the amount of MBs available.
Address: Base address + 30h offset
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
BUF31I_BUF8I
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
BUF31I_BUF8I
BUF7I
BUF6I
BUF5I
BUF4I_BUF0I
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
FLEXCANx_IFLAG1 field descriptions
Field
Description
31–8
BUF31I_BUF8I
Each bit flags the respective FLEXCAN Message Buffer (MB8 to MB31) interrupt.
1
The corresponding MB has successfully completed transmission or reception
0
No such occurrence
7
BUF7I
If the Rx FIFO is not enabled, this bit flags the interrupt for MB7.
If the MCR[RFEN] bit is asserted, this flag indicates that a message was lost because Rx FIFO is full. Note
that the flag will not be asserted when the Rx FIFO is full and the message was captured by a Mailbox.
This flag is cleared by the FlexCAN whenever the bit MCR[RFEN] is changed by Arm writes.
1
MB7 completed transmission/reception or FIFO overflow
0
No such occurrence
6
BUF6I
If the Rx FIFO is not enabled, this bit flags the interrupt for MB6.
If the MCR[RFEN] bit is asserted, this flag indicates when the number of unread messages within the Rx
FIFO is increased to 5 from 4 due to the reception of a new one, meaning that the Rx FIFO is almost full.
Note that if the flag is cleared while the number of unread messages is greater than 4 it will not assert
again until the number of unread messages within the Rx FIFO is decreased to equal or less than 4.
This flag is cleared by the FlexCAN whenever the bit MCR[RFEN] is changed by Arm writes.
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1311

<!-- page 1312 -->

FLEXCANx_IFLAG1 field descriptions (continued)
Field
Description
1
MB6 completed transmission/reception or FIFO almost full
0
No such occurrence
5
BUF5I
If the Rx FIFO is not enabled, this bit flags the interrupt for MB5. If the Rx FIFO is enabled, this flag
indicates that at least one frame is available to be read from the Rx FIFO.
This flag is cleared by the FlexCAN whenever the bit MCR[RFEN] is changed by Arm writes.
1
MB5 completed transmission/reception or frames available in the FIFO
0
No such occurrence
BUF4I_BUF0I
If the Rx FIFO is not enabled, these bits flag the interrupts for MB0 to MB4 . If the Rx FIFO is enabled,
these flags are not used and must be considered as reserved locations.
These flags are cleared by the FlexCAN whenever the bit MCR[RFEN] is changed by Arm writes.
1
Corresponding MB completed transmission/reception
0
No such occurrence
26.8.13
Control 2 Register (FLEXCANx_CTRL2)
This register contains control bits for CAN errors, FIFO features and mode selection.
Table 26-21. Rx FIFO Filters
RFFN[3:0]
Number of Rx FIFO
filters
Message Buffers
occupied by Rx
FIFO and ID Filter
Table
Remaining
Available
Mailboxes1
Rx FIFO ID Filter
Table Elements
Affected by Rx
Individual Masks2
Rx FIFO ID Filter
Table Elements
Affected by Rx
FIFO Global Mask2
0x0
8
MB 0-7
MB 8-63
Elements 0-7
none
0x1
16
MB 0-9
MB 10-63
Elements 0-9
Elements 10-15
0x2
24
MB 0-11
MB 12-63
Elements 0-11
Elements 12-23
0x3
32
MB 0-13
MB 14-63
Elements 0-13
Elements 14-31
0x4
40
MB 0-15
MB 16-63
Elements 0-15
Elements 16-39
0x5
48
MB 0-17
MB 18-63
Elements 0-17
Elements 18-47
0x6
56
MB 0-19
MB 20-63
Elements 0-19
Elements 20-55
0x7
64
MB 0-21
MB 22-63
Elements 0-21
Elements 22-63
0x8
72
MB 0-23
MB 24-63
Elements 0-23
Elements 24-71
0x9
80
MB 0-25
MB 26-63
Elements 0-25
Elements 26-79
0xA
88
MB 0-27
MB 28-63
Elements 0-27
Elements 28-87
0xB
96
MB 0-29
MB 30-63
Elements 0-29
Elements 30-95
0xC
104
MB 0-31
MB 32-63
Elements 0-31
Elements 32-103
0xD
112
MB 0-33
MB 34-63
Elements 0-31
Elements 32-111
0xE
120
MB 0-35
MB 36-63
Elements 0-31
Elements 32-119
0xF
128
MB 0-37
MB 38-63
Elements 0-31
Elements 32-127
1.
The number of the last remaining available mailboxes is defined by the MCR[MAXMB] field.
2.
If Rx Individual Mask Registers are not enabled then all Rx FIFO filters are affected by the Rx FIFO Global Mask.
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1312
NXP Semiconductors

<!-- page 1313 -->

Each group of eight filters occupies a memory space equivalent to two Message Buffers
which means that the more filters are implemented the less Mailboxes will be available.
Considering that the Rx FIFO occupies the memory space originally reserved for MB0-5,
RFFN should be programmed with a value corresponding to a number of filters not
greater than the number of available memory words which can be calculated as follows:
(SETUP_MB - 6) x 4
where SETUP_MB is MAXMB.
The number of remaining Mailboxes available will be:
SETUP_MB - 8 - (RFFN x 2)
If the Number of Rx FIFO Filters programmed through RFFN exceeds the SETUP_MB
value, the exceeding ones will not be functional.Unshaded regions in Table 26-22
indicate the valid combinations of MAXMB, RFEN and RFFN, shaded regions are not
functional.
Table 26-22. Valid Combinations of MAXMB, RFEN and RFFN
RFF
N
0
0
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
RFE
N
0
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
MAX
MB
0 - 6
7 - 8
9 - 10
11 -
12
13
-14
15 -
16
17
-18
19 -
20
21 -
22
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1313

<!-- page 1314 -->

Table 26-22. Valid Combinations of MAXMB, RFEN and RFFN (continued)
RFF
N
0
0
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
RFE
N
0
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
MAX
MB
23 -
24
25 -
26
27 -
28
29
-30
31 -
32
33 -
34
35 -
36
37 -
63
Address: Base address + 34h offset
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
WRMFRZ
RFFN
TASD
MRP
RRS
EACEN
W
0
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
FLEXCANx_CTRL2 field descriptions
Field
Description
31
-
must be written as 0
30–29
-
This field is reserved.
Reserved
Table continues on the next page...
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1314
NXP Semiconductors

<!-- page 1315 -->

FLEXCANx_CTRL2 field descriptions (continued)
Field
Description
28
WRMFRZ
Enable unrestricted write access to FlexCAN memory in Freeze mode. This bit can only be written in
Freeze mode and has no effect out of Freeze mode.
1
Enable unrestricted write access to FlexCAN memory
0
Keep the write access restricted in some regions of FlexCAN memory
27–24
RFFN
This 4-bit field defines the number of Rx FIFO filters according to Table 26-21 . The maximum selectable
number of filters is determined by the Arm. This field can only be written in Freeze mode as it is blocked
by hardware in other modes. RFFN defines a number of Message Buffers occupied by Rx FIFO and ID
Filter (see Table 26-21) that may not exceed the number of available Mailboxes present in module,
defined by MCR[MAXMB].Default RFFN value is 0x0, which leads to a total of 8 Rx FIFO filters, occupies
the first 8 Message Buffers (MB 0-7) and makes available the next Message Buffers (MB 8-63) for
Mailboxes. As a second example, when RFFN is set to 0xD, there will be 112 Rx FIFO filters, located in
MB 0-33, and MB 34-63 are available for Mailboxes. Notice that, in this case, individual masks (RXIMR)
will just cover Rx FIFO filters in 0-31 range, and filters 32-111 will use RXFGMASK. In case of reducing
the number of last Message Buffers, MCR[MAXMB] (see Module Configuration Register
(FLEXCAN_MCR)) can be adjusted by the application to minimum of 33, in order to give room to the Rx
FIFO and its ID Filter Table defined by RFFN. On the contrary, if the application sets MCR[MAXMB] to 16,
for instance, the maximum RFFN is limited to 0x4. RFFN also impacts the definition of the minimum
number of peripheral clocks per CAN bit as described in Table 26-18 (see Arbitration and Matching
Timing).
23–19
TASD
This 5-bit field indicates how many CAN bits the Tx arbitration process start point can be delayed from the
first bit of CRC field on CAN bus. This field can only be written in Freeze mode as it is blocked by
hardware in other modes.
This field is useful to optimize the transmit performance based on factors such as: peripheral/serial clock
ratio, CAN bit timing and number of MBs . The duration of an arbitration process, in terms of CAN bits, is
directly proportional to the number of available MBs and CAN baud rate and inversely proportional to the
peripheral clock frequency.
The optimal arbitration timing is that in which the last MB is scanned right before the first bit of the
Intermission field of a CAN frame. Therefore, if there are few MBs and the system/serial clock ratio is high
and the CAN baud rate is low then the arbitration can be delayed and vice-versa.
If TASD is 0 then the arbitration start is not delayed, thus Arm has less time to configure a Tx MB for the
next arbitration, but more time is reserved for arbitration . In the other hand, if TASD is 24 then Arm can
configure a Tx MB later and less time is reserved for arbitration.
If too little time is reserved for arbitration the FlexCAN may be not able to find winner MBs in time to
compete with other nodes for the CAN bus. If the arbitration ends too much time before the first bit of
Intermission field then there is a chance that Arm reconfigure some Tx MBs and the winner MB is not the
best to be transmitted.
The reset value is different on various platforms, according to their peripheral clock frequency, number of
MBs and target CAN baud rate.
The optimal configuration for TASD can be calculated as:
Table continues on the next page...
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1315

<!-- page 1316 -->

FLEXCANx_CTRL2 field descriptions (continued)
Field
Description
TASD =
fCANCLK x [MAXMB + 3 - (RFEN x 8) - (RFEN x RFFN x 2)] x 2 
fsys x [1 + (PSEG1 + 1) + (PSEG2 + 1) + (PROPSEG + 1)] x (PRESDIV + 1)
25 - 
where:
fCANCLK is the Protocol Engine (PE) Clock in Hz; PE clock is derrived from CAN_CLK_ROOT in CCM. See
the Clock controller module.
fSYS is the peripheral clock in Hz;
MAXMB is the value in CTRL1[MAXMB] field;
RFEN is the value in CTRL1[RFEN] bit;
RFFN is the value in CTRL2[RFFN] field;
PSEG1 is the value in CTRL1[PSEG1] field;
PSEG2 is the value in CTRL1[PSEG2] field;
PROPSEG is the value in CTRL1[PROPSEG] field;
PRESDIV is the value in CTRL1[PRESDIV] field.
Please refer to Arbitration process and Protocol Timing for more details.
18
MRP
If this bit is set the matching process starts from the Mailboxes and if no match occurs the matching
continues on the Rx FIFO. This bit can only be written in Freeze mode as it is blocked by hardware in
other modes.
1
Matching starts from Mailboxes and continues on Rx FIFO
0
Matching starts from Rx FIFO and continues on Mailboxes
17
RRS
If this bit is asserted Remote Request Frame is submitted to a matching process and stored in the
corresponding Message Buffer in the same fashion of a Data Frame. No automatic Remote Response
Frame will be generated.
If this bit is negated the Remote Request Frame is submitted to a matching process and an automatic
Remote Response Frame is generated if a Message Buffer with CODE=0b1010 is found with the same ID.
This bit can only be written in Freeze mode as it is blocked by hardware in other modes.
1
Remote Request Frame is stored
0
Remote Response Frame is generated
16
EACEN
This bit controls the comparison of IDE and RTR bits within Rx Mailboxes filters with their corresponding
bits in the incoming frame by the matching process. This bit does not affect matching for Rx FIFO. This bit
can only be written in Freeze mode as it is blocked by hardware in other modes.
1
Enables the comparison of both Rx Mailbox filter's IDE and RTR bit with their corresponding bits within
the incoming frame. Mask bits do apply.
0
Rx Mailbox filter's IDE bit is always compared and RTR is never compared despite mask bits.
-
This field is reserved.
Table continues on the next page...
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1316
NXP Semiconductors

<!-- page 1317 -->

FLEXCANx_CTRL2 field descriptions (continued)
Field
Description
Reserved
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1317

<!-- page 1318 -->

26.8.14
Error and Status 2 Register (FLEXCANx_ESR2)
This register reflects various interrupt flags and some general status.
Address: Base address + 38h offset
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
LPTM
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
VPS
IMB
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
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1318
NXP Semiconductors

<!-- page 1319 -->

FLEXCANx_ESR2 field descriptions
Field
Description
31–23
-
This field is reserved.
Reserved
22–16
LPTM
If ESR2[VPS] is asserted, his 7-bit field indicates the lowest number inactive Mailbox (refer to IMB bit
description). If there is no inactive Mailbox then the Mailbox indicated depends on CTRL1[LBUF] bit
value . If CTRL1[LBUF] bit is negated then the Mailbox indicated is the one which has the greatest
arbitration value (see Highest Mailbox priority first). If CTRL1[LBUF] bit is asserted then the Mailbox
indicated is the highest number active Tx Mailbox. If a Tx Mailbox is being transmitted it is not considered
in LPTM calculation. If ESR2[IMB] is not asserted and a frame is transmitted successfully, LPTM is
updated with its Mailbox number.
15
-
This field is reserved.
Reserved
14
VPS
This bit indicates whether IMB and LPTM contents are currently valid or not. VPS is asserted upon every
complete Tx arbitration process unless the Arm writes to Control and Status word of a Mailbox that has
already been scanned (i.e. it is behind Tx Arbitration Pointer) during the Tx arbitration process . If there is
no inactive Mailbox and only one Tx Mailbox which is being transmitted then VPS is not asserted. VPS is
negated upon the start of every Tx arbitration process or upon a write to Control and Status word of any
Mailbox.ESR2[VPS] is not affected by any Arm write into Control Status (C/S) of a MB which is blocked by
abort mechanism. When MCR[AEN] is asserted, the abort code write in C/S of a MB that is been
transmitted (pending abort), or any write attempt into a Tx MB with IFLAG set is blocked.
1
Contents of IMB and LPTM are valid
0
Contents of IMB and LPTM are invalid
13
IMB
If ESR2[VPS] is asserted, this bit indicates whether there is any inactive Mailbox (CODE field is either
0b1000 or 0b0000).
This bit is asserted in the following cases:
(1) During arbitration, if a LPTM is found and it is inactive.
(2) If IMB is not asserted and a frame is transmitted successfully.
(3) This bit is cleared in all start of arbitration (see Arbitration process).
LPTM mechanism have the following behavior: if a MB is successfully transmitted and ESR2[IMB]=0 (no
inactive Mailbox), then ESR2[VPS] and ESR2[IMB] are asserted and the index related to the MB just
transmitted is loaded into ESR2[LPTM].
1
If ESR2[VPS] is asserted, there is at least one inactive Mailbox. LPTM content is the number of the
first one.
0
If ESR2[VPS] is asserted, the ESR2[LPTM] is not an inactive Mailbox.
-
This field is reserved.
Reserved
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1319

<!-- page 1320 -->

26.8.15
CRC Register (FLEXCANx_CRCR)
This register provides information about the CRC of transmitted messages
Address: Base address + 44h offset
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
MBCRC
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
TXCRC
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
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1320
NXP Semiconductors

<!-- page 1321 -->

FLEXCANx_CRCR field descriptions
Field
Description
31–23
-
This field is reserved.
Reserved
22–16
MBCRC
This field indicates the number of the Mailbox corresponding to the value in TXCRC field.
15
-
This field is reserved.
Reserved
TXCRC
This field indicates the CRC value of the last message transmitted. This field is updated at the same time
the Tx Interrupt Flag is asserted.
26.8.16
Rx FIFO Global Mask Register (FLEXCANx_RXFGMASK)
If Rx FIFO is enabled RXFGMASK is used to mask the Rx FIFO ID Filter Table
elements that do not have a corresponding RXIMR according to CTRL2[RFFN] field
setting.
This register can only be written in Freeze Mode as it is blocked by hardware in other
modes.
Table 26-23. Rx FIFO Global Mask usage
Rx FIFO
ID Filter Table
Elements Format
(MCR[IDAM])
Identifier Acceptance Filter fields
RTR
IDE
RXIDA
RXIDB
RXIDC
reserved
A
FGM[31]
FGM[30]
FGM[29:1]
-
-
FGM[0]
B
FGM[31]
FGM[15]
FGM[30]
FGM[14]
-
FGM[29:16]
FGM[13:0]
1
-
C
-
-
-
FGM[31:24]
FGM[23:16]
FGM[15:8]
FGM[7:0]
2
1.
If MCR[IDAM] field is equivalent to the format B only the fourteen most significant bits of the Identifier of the incoming
frame are compared with the Rx FIFO filter.
2.
If MCR[IDAM] field is equivalent to the format C only the eight most significant bits of the Identifier of the incoming frame
are compared with the Rx FIFO filter.
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1321

<!-- page 1322 -->

Address: Base address + 48h offset
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
FGM31_FGM0
W
Reset 1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
FLEXCANx_RXFGMASK field descriptions
Field
Description
FGM31_FGM0
These bits mask the ID Filter Table elements bits in a perfect alignment.Rx FIFO Global Mask Register
(FLEXCAN_RXFGMASK) shows in detail which FGM bits mask each IDAF field. Clear this register has
the effect of disabling the ID Filter.
1
The corresponding bit in the filter is checked
0
The corresponding bit in the filter is "don't care"
26.8.17
Rx FIFO Information Register (FLEXCANx_RXFIR)
RXFIR provides information on Rx FIFO.
This register is the port through which Arm accesses the output of the RXFIR FIFO
located in RAM. The RXFIR FIFO is written by the FlexCAN whenever a new message
is moved into the Rx FIFO as well as its output is updated whenever the output of the Rx
FIFO is updated with the next message. Refer to Rx FIFO to find instructions on reading
this register.
Address: Base address + 4Ch offset
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
IDHIT
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
FLEXCANx_RXFIR field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved
IDHIT
This 9-bit field indicates which Identifier Acceptance Filter (see Rx FIFO Structure) was hit by the received
message that is in the output of the Rx FIFO . (refer to Rx FIFO for details) If multiple filters match the
incoming message ID then the first matching IDAF found (lowest number) by the matching process is
indicated. This field is valid only while the IFLAG[BUF5I] is asserted.
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1322
NXP Semiconductors

<!-- page 1323 -->

26.8.18
Rx Individual Mask Registers (FLEXCANx_RXIMRn)
RXIMR are used as acceptance masks for ID filtering in Rx MBs and the Rx FIFO . If
the Rx FIFO is not enabled, one mask register is provided for each available Mailbox,
providing ID masking capability on a per Mailbox basis.
When the Rx FIFO is enabled (MCR[RFEN] bit is asserted), up to 32 Rx Individual
Mask Registers can apply to the Rx FIFO ID Filter Table elements on a one-to-one
correspondence depending on CTRL2[RFFN] setting. Refer to Control 2 Register
(FLEXCAN_CTRL2) for details .
RXIMR can only be written by the Arm while the module is in Freeze Mode, otherwise
they are blocked by hardware .
The Individual Rx Mask Registers are not affected by reset and must be explicitly
initialized prior to any reception.
Address: Base address + 880h offset + (4d × i), where i=0d to 63d
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
MI31_MI0
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
FLEXCANx_RXIMRn field descriptions
Field
Description
MI31_MI0
These bits mask both Mailbox filter and Rx FIFO ID Filter Table element in distinct ways.
For Mailbox filter refer to Rx Mailboxes Global Mask Register (FLEXCAN_RXMGMASK).
For Rx FIFO ID Filter Table element refer to Rx FIFO Global Mask Register (FLEXCAN_RXFGMASK).
1
The corresponding bit in the filter is checked
0
the corresponding bit in the filter is "don't care"
26.8.19
Glitch Filter Width Registers (FLEXCANx_GFWR)
The Glitch Filter just takes effects when FLEXCAN enters the STOP mode.
Address: Base address + 9E0h offset
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
0
GFWR
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
1
1
1
1
1
1
1
Chapter 26 Flexible Controller Area Network (FLEXCAN)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1323

<!-- page 1324 -->

FLEXCANx_GFWR field descriptions
Field
Description
31–8
Reserved
This read-only field is reserved and always has the value 0.
GFWR
It determines the Glitch Filter Width. The width will be divided from Oscillator clock by GFWR values. By
default, it is 5.33 μs when the oscillator is 24 MHz.
Filter Pulse Width = [(GFWR FIELD + 1) x (1 / Osc. Frequency)]
FLEXCAN Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1324
NXP Semiconductors

