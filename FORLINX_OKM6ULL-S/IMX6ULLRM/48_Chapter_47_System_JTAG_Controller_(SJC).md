# Chapter 47: System JTAG Controller (SJC)

> Nguồn: `IMX6ULLRM.pdf` — trang 3379–3414

<!-- page 3379 -->

Chapter 47
System JTAG Controller (SJC)
47.1
Overview
The System JTAG Controller (SJC) provides debug and test control with the maximum
security.
The test access port (TAP) is designed to support features compatible with the IEEE
Standard 1149.1 v2001 (JTAG).
The figure below shows an overview of the JTAG architecture.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3379

<!-- page 3380 -->

SDMA 
Bypass TAP
SJC TAP Ctlr 
ExtraDebug Registers
OnCE
SDMA
DAP
TDO 
TDI 
TDI 
TDI 
TDO 
TDO
PTM’s, CTI’s, ETB
I/O PINS
JTAG-AP
SJC
1
0
MPCore
Cortex-A7
APB
 
JTAG_TDO
JTAG_MOD
JTAG_TMS 
JTAG_TCK 
JTAG_TRSTB 
JTAG_TDI
Figure 47-1. System JTAG Controller (SJC) Block Diagram
47.1.1
Features
The System JTAG Controller (SJC) provides the following capabilities:
• JTAG IEEE1149.1 mandatory instructions, see EXTEST Instruction, SAMPLE/
PRELOAD Instruction , and BYPASS Instruction .
• JTAG IEEE1149.1 optional instructions, see ID_CODE Instruction (IDCODE) , and
HIGHZ Instruction.
• JTAG IEEE P1149.1 (standard JTAG) interface to off-chip test and development
equipment including an SJC-only mode for true IEEE 1149.1 compliance, used
primarily for board-level implementation of boundary scan.
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3380
NXP Semiconductors

<!-- page 3381 -->

• IEEE P1149.6 (JTAG) mandatory instructions, see EXTEST_PULSE instruction and
EXTEST_TRAIN instruction. These two instructions enable edge-detecting behavior
on the signal path containing AC pins.
• Debug-related control and status, such as putting selected cores into reset and/or
debug mode and the ability to monitor individual core status signals via JTAG.
• Provides means for accessing each OnCE/ICE TAP controller independently to
control a target system (see Modes of Operation).
• ExtraDebug logic (see ENABLE_ExtraDebug Instruction ).
• The maximum clock speed of the SJC is one-eight of the lowest frequency of the
accessed OnCE/ICE. For example in normal operation (no core in low-power mode),
this frequency is one-eight of the SDMA frequency if this core is present in the TDI-
TDO chain (serially connected with other cores or standalone). The user must also
consider the 25 MHz frequency limitation on the CE bus.
• Core compliant modes to support standalone core debuggers (see Modes of
Operation).
• Multi-cores daisy chained mode (default one) to support multi-core debuggers (see
Modes of Operation).
Detailed information about the SJC is provided in the Security Reference Manual.
Contact your NXP representative for information about obtaining this document.
47.1.2
Modes of Operation
The SJC modes are controlled through both the TAP select register (SJC_TSR) and the
MOD input port.
The MOD port (typically connected to pad of the same name) selects between two
possible topologies of TAP connections, as seen at SoC level:
• Negating it (this should be the default state) selects all the TAPs ( SJC, SDMA, DAP
and Arm/ETM) to be connected in the TDI-TDO chain, which is referred to as "daisy
chain" mode, throughout this chapter.
• Asserting it only selects the SJC TAP to be connected in the TDI-TDO chain.
IEEE1149.1 standard features are enabled by configuring the SJC input pin: MOD. Refer
to the following table for MOD settings details:
Table 47-1. SJC Modes
MOD
Name
Description
0
Daisy chain ALL
For common SW debug (High speed and production)
1
SJC only
IEEE 1149.1 JTAG compliant mode
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3381

<!-- page 3382 -->

The following figure shows the SJC mode selection flow. The numbers shown in
parenthesis below each block name indicates the TAP's IR length.
SJC 
(5)
SoC JTAG (SJC) 
(5)
MOD = 1
SDMA 
(4)
DAP_A7 
(4)
MOD = 0
TDI
TDI
TDO
TDO
(number in brackets lists IR length of given TAP)
DAP_M4 
(4)
Figure 47-2. SJC Mode Selection Using MOD Pin Sampling
The Connect SDMA bit inside TAP select register controls the SDMA TAP bypass.
• When negated (should be the default state), the SDMA TAP is bypassed with a
single D-FF (Flip-flop) during Shift-Dr path
• When asserted SDMA TAP is connected inside the chain
• When taking the SDMA into bypass or out of bypass (by writing to tapsel reg),
additional cycle with TMS '0' should be given
The TAP selection block (TSB) provides a simple method of integrating various pieces of
IP that have embedded TAPs.
• Provides a way to connect up multiple TAPs within a single SoC
• Identify the SJC TAP as the master TAP which controls the boundary chain (for
IEEE 1149.1 standard compliance)
• Follow the state of SJC TAP, and when the Test-Logic-Reset (TLR) state is reached,
reset all TAPs
The figure below shows the TAP Selection Block and SOC TAP Chain Scheme.
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3382
NXP Semiconductors

<!-- page 3383 -->

1 
0
SJC 
TAP
tdo
1 
0
sdma_bypass
Note: The default daisy chain connectivity is highlighted in yellow
TCK
SOC TDO
MOD
TDI
tdo
tdo
tdi
tck
tdi
tck
SJC
Alter. TAP
Bypass
SDMA
TAP
DAP
TAP
Figure 47-3. TAP Selection Block and SoC TAP Chain Scheme
NOTE
It is the responsibility of the user to ensure that in any
configuration of the TAP controllers chosen, all of the TAPs in
the chain comply with the demands of TCK clock frequency as
well as the required ratio between TCK clock frequency and
that of the core's to which the TAP refers.
47.2
External Signals
The table found here describes the external signals of SJC.
Table 47-2. SJC External Signals
Signal
Description
Pad
Mode
Direction
JTAG_DE_B
SoC debug request/acknowledge
pin. The DE_IN_B pin is used to
propagate an external debug
request event to the core(s). This
functionality must be enabled first,
by set of DE_to_ARM /
UART2_CTS_B
ALT7
IO
Table continues on the next page...
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3383

<!-- page 3384 -->

Table 47-2. SJC External Signals
(continued)
Signal
Description
Pad
Mode
Direction
DE_to_SDMA bits in SJC's DCR
register. It is SoC implementation
dependent, whether this pin can also
be used to reflect the debug
acknowledge event back from the
cores (in the case where an Open-
Drain scheme is used externally).
JTAG_MOD
SJC mode selection. This pin is
sampled at TRST reset to determine
two possible modes for the TAP
connection configuration.
JTAG_MOD
No muxing
I
JTAG_TCK
Test Clock (TCK). This is used to
synchronize the test logic and
includes an internal pull-up resistor
JTAG_TCK
ALT0
I
JTAG_TDI
Test Data Input (TDI). Serial test
instruction and data are received
through the test data input (TDI) pin.
TDI is sampled on the rising edge of
TCK and includes an internal pullup
resistor
JTAG_TDI
ALT0
I
JTAG_TDO
Test Data Output (TDO). The serial
output for test instructions and data.
TDO is tri-statable and is actively
driven in the shift-IR and shift-DR
controller states. TDO changes on
the falling edge of TCK
JTAG_TDO
ALT0
O
JTAG_TMS
Test Mode Select (TMS). This is
used to sequence the test
controller's state machine. TMS is
sampled on the rising edge of TCK
and includes an internal pullup
resistor
JTAG_TMS
ALT0
I
JTAG_TRSTB
Test Reset (TRST). This is used to
asynchronously initialize the test
controller. The TRST pin has an
internal pullup resistor
JTAG_TRST_B
ALT0
I
47.2.1
External Signal Overview
The SJC provides test and debug control with a minimum number of contacts.
The figure below shows SJC connections to external contacts and other chip blocks.
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3384
NXP Semiconductors

<!-- page 3385 -->

Security
Pads
Control
IO
Muxing
Boundary
Scan
DFT Control
Signals
CCM
Arm
Platform
SDMA
System JTAG
Controller
Memory
BISTs
JTAG_TMS 
JTAG_TCK 
JTAG_TRSTB 
JTAG_TDI
POR_B
 
JTAG_TDO
JTAG_MOD
JTAG_DE_B
Figure 47-4. SJC Connections
47.2.2
TAP Controller
The TAP controller is responsible for interpreting the sequence of logical values on the
TMS signal. It is a synchronous state machine that controls the operation of the JTAG
logic. The value shown adjacent to each arc represents the value of the TMS signal
sampled on the rising edge of TCK signal. For a description of the TAP controller states,
refer to the appropriate IEEE 1149.1 document.
The state machine is shown in the following figure.
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3385

<!-- page 3386 -->

TEST LOGIC 
RESET
RUN-TEST/IDLE
CAPTURE-DR
SHIFT-DR
EXIT1-DR
PAUSE-DR
EXIT2-DR
UPDATE-DR
SELECT-IR_SCAN
CAPTURE-IR
SHIFT-IR
EXIT1-IR
PAUSE-IR
EXIT2-IR
UPDATE-IR
SELECT-DR_SCAN
1
0
1
0
1
0
0
0
0
0
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
0
1
1
1
1
1
1
1
0
1
Figure 47-5. TAP Controller State Machine
The change of the JTAG state machine occurs on the rising edge of TCK. TMS and TDI
change on the falling edge of TCK. TDO also changes on the falling edge of TCK
following entry into the Shift_DR or Shift_IR states (TDO_EN is the enable of the
tristate buffer driving the TDO output).
The figure below shows the timings of the SJC signals.
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3386
NXP Semiconductors

<!-- page 3387 -->

RTI
Reset
Capture
DR
IR
Shift IR
EIR
Update
RTI
TRST_N
TCK
TMS
TAP_STATE
TDI
TDO
TDO_EN
Figure 47-6. SJC Signals Timing Diagram
47.2.3
Accessing ExtraDebug Registers
Accessed through the Select-DR-Scan path, the ExtraDebug shift register consists of 38
bits (maximum) comprising a 32-bit data field (max length, see extradebug register
description), a 5 bit address field and read/write bit.
The write actually takes place when the JTAG TAP controller enters the Update-DR
state. On a read, the data field is ignored (the user should shift only 5 times to enter
Read=1 and the address), the read takes place on the next path through DR at the
Capture-DR state, the data is shifted-out during the Shift-DR state.
On the second path for a read access, simultaneous write access is not supported:
command converter software shifts in zeros so the TAP decodes a write to the CSR (read-
only register) which does not have any effect on the circuit.
The number of shift depends on the width of the accessed register as explained in the
following diagrams.
First a write access (one path through Select-DR-Scan):
bit1
TDI
TDO (Don't care)
bit0
0
bit3
bit4
MSB
LSB
Write
access
data field (number of bits to be shifted in
depends on the width of the register
Adress
field
bit2
Figure 47-7. TDI/TDO on write access
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3387

<!-- page 3388 -->

Then a read access (requires two paths through Jtag DR Scan path):
bit1
TDI
TDO (Don't care)
bit0
1
bit3
bit4
Read
access
Adress
field
bit2
First path
Second path
TDO
MSB
LSB
data field (number of bits to be shifted in
depends on the width of the register
TDI
Figure 47-8. TDI/TDO on Read Access
For example, write value 0b1010_1100 to Debug Control Register (address = 0b00110).
ENABLE_EXTRADEBUG
Sel ect DRCapt ur eDR
Shi f t DR 
Exi t 2DR Updat eDR
Data
Address
Write bit
TCK
TMS
TDI
JTAG_IR
JTAG_TAP
Figure 47-9. Example: Write Access to DCR
The SJC registers have different levels of security (Refer to JTAG Security Modes ):
• Secured- accessible only in mode 2 (supposed correct response entered), mode 3 and
mode 4.
• Unsecured- accessible in all modes
The level of security of each register is indicated in its name or description, in
"Programmable Registers" section.
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3388
NXP Semiconductors

<!-- page 3389 -->

A single DE_B pin is dedicated for debug request input/output in bidirectional open drain
functionality (including an internal pull-up device).
Bits 6:5 in DCR register serve as mask bits, controlling the propagation of external debug
request to each recipients (Arm Platform, SDMA).
The bits 1:0 define the propagation enable of IR debug request to recipient cores.
For security reasons, bits for output and input propagation control are at their negated
values after reset. A user cannot put the cores in debug mode through DE_B without any
Jtag access.
The configuration after reset prevents propagation of debug requests / acknowledges to or
from the cores.
47.3
TAP Selection Block (TSB)
As described in Modes of Operation, the SJC can access cores in different modes selected
through a TSB.
47.3.1
Select Mode Using Software
Conceptually, the SJC_TSR is a data register which is accessed through Access TSR IR
instruction of SJC TAP.
The following figure shows the process of using reserved IR to access the SJC_TSR.
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3389

<!-- page 3390 -->

SJC JTAG 
IR space
Reserved
ACCESS_TSR IR
TDI
TDO
Shift-DR
TAP select shift register
TAP select register
Update-DR
Figure 47-10. Using Reserved IR to Access the TAP Select Register (SJC_TSR)
The SJC_TSR can only be changed during the update-DR state of the TSB JTAG state
machine. This is necessary to prevent a TAP that is being selected from losing
synchronization with the TSB state machine when the TSB state machine returns to run-
test-idle. Therefore, an associated shift register for the SJC_TSR is loaded into the
SJC_TSR during the update-DR state (see the figure above). The shift register must also
capture the state of the SJC_TSR when in the Capture-DR state for visibility of the
contents of the SJC_TSR. See TAP Select Instruction , for more information.
47.4
Boundary Scan Register (BSR)
The Boundary Scan Register (BSR) in the JTAG implementation contains bits for all
device signal and clock pins and associated control signals.
Boundary Scan Register (BSR)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3390
NXP Semiconductors

<!-- page 3391 -->

All SoC bidirectional pins have a single register bit in the boundary scan register for pin
data, and are controlled by an associated control bit in the boundary scan register.
47.5
SoC JTAG Instruction Register (SJIR)
The SoC JTAG Instruction register is provided in the following table. The SoC JTAG
Instruction register is 5 bits wide.
Table 47-3. SoC JTAG Instruction Register
(SJIR)
Code
SJC IR
B4
B3
B2
B1
B0
0
0
0
0
0
IDCODE
0
0
0
0
1
SAMPLE/PRELOAD
0
0
0
1
0
EXTEST
0
0
0
1
1
HI-Z
0
0
1
0
0
ENABLE_ExtraDebug
0
0
1
0
1
ENTER_DEBUG (secured)
0
0
1
1
0
Reserved
0
0
1
1
1
TAP select
0
1
0
0
0
EXTEST_PULSE
0
1
0
0
1
EXTEST_TRAIN
0
1
0
1
0
Reserved
0
1
0
1
1
Reserved
0
1
1
0
0
Security Output challenge
0
1
1
0
1
Security Enter response
-
Reserved
1
1
1
1
1
BYPASS
The instruction register is reset to 0b00000 in the test-logic-reset controller state which is
equivalent to the IDCODE instruction.
During the capture-IR controller state, the parallel inputs to the instruction register are
loaded with the code 01 in the least significant bits as required by the standard; the most
significant bits are loaded with the values 00, leading to a capture value of 0b00001.
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3391

<!-- page 3392 -->

47.5.1
ID_CODE Instruction (IDCODE)
Selects the ID register, and the system logic controls the I/O pins. This instruction is
provided as a public instruction to allow the manufacturer, part number and version of a
component to be determined through the TAP.
The table below shows the ID register configuration.
Table 47-4. ID Configuration Register (IDCODE)
IDCODE
ID Configuration Register
BIT
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
BIT
16
Version Information[3:0]
Part Number (Bits 27-16)
TYPE
r
r
r
r
r
r
r
r
r
r
r
r
r
r
r
r
RESET
0
0
0
0
x
x
x
x
x
x
x
x
x
x
x
x
Note:
BIT
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
BIT 0
Part Number (Bits 15-12)
Manufacturer Identity
1
TYPE
r
r
r
r
r
r
r
r
r
r
r
r
r
r
r
r
RESET
x
x
x
x
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
1
Note:
Table 47-5. ID Configuration Register Description (IDCODE)
Field
Description
31-28
Version Information
IC/SoC Version information number.
Initial value: '0000'
This number is subject to changes, for new IC/SoC (System On A Chip) revision releases.
27-12
Part Number
Customer Part Number
The 16-bit Part Number value is unique for every NXP SoC / IC.
See System Debug chapter for exact register value for a specific SoC.
11-1
Manufacturer Identity
Manufacturer Identity
NXP Manufacturer Identity code.
Bits [11:1] - 00000001110
0
Tied to logic 1.
One application of the ID register is to distinguish the manufacturer(s) of components on
a board when multiple sourcing is used. As more components emerge which conform to
the IEEE 1149.1 standard, it is desirable to allow for a system diagnostic controller unit
to blindly interrogate a board design to determine the type of each component in each
location. This information is also available for factory process monitoring and for failure
mode analysis of assembled boards.
SoC JTAG Instruction Register (SJIR)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3392
NXP Semiconductors

<!-- page 3393 -->

Once the IDCODE instruction is decoded, it selects the ID register which is a 32 Bit data
register. Because the bypass register loads a logic 0 at the start of a scan cycle, whereas
the ID register loads a logic 1 into its least significant bit, examination of the first bit of
data shifted out of a component during a test data scan sequence immediate following
exit from Test-Logic-Reset controller state shows whether such a register is included in
the design. When the IDCODE instruction is selected, the operation of the test logic has
no effect on the operation of the on-chip system logic as required by the IEEE 1149.1
standard.
47.5.2
SAMPLE/PRELOAD Instruction
Selects the boundary scan register and the system logic controls the I/O pins.
The SAMPLE/PRELOAD instruction provides two separate functions:
• First, it provides a means to obtain a snapshot of system data and control signals. The
snapshot occurs on the rising edge of TCK in the capture-DR controller state. The
data can be observed by shifting it transparently through the boundary scan register.
• The second function of SAMPLE/PRELOAD is to initialize the boundary scan
register output cells prior to selection of EXTEST. This initialization ensures that
known data appears on the outputs when entering the EXTEST instruction.
NOTE
Because there is no internal synchronization between the JTAG
clock (TCK) and the system clock (CLK), the user must
provide some form of external synchronization to achieve
meaningful results.
For more details on the function and use of SAMPLE/PRELOAD, refer to the appropriate
IEEE 1149.1 document.
47.5.3
EXTEST Instruction
Selects the boundary scan register, and the 1149.1 test logic has control of the I/O pins.
By using the TAP controller, the register is capable of:
• Scanning user-defined values into the output buffers,
• Capturing values presented to input pins
• Controlling the direction of bidirectional pins,
• Controlling the output drive of tri-statable output pins.
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3393

<!-- page 3394 -->

For more details on the function and use of EXTEST, refer to the appropriate IEEE
1149.1 document.
The EXTEST instruction also asserts internal reset for the cores (through CCM, refer to
Figure 47-13) to force a predictable internal state while performing external boundary
scan operations.
47.5.4
HIGHZ Instruction
All output drivers, including the two-state drivers, are turned off (that is, high
impedance). The instruction selects the bypass register.
In this mode, all internal pullup resistors on all the pins (except for the TMS, TDI, TCK,
TRSTB pins) are disabled. This disabling functionality is not built into SJC, but should
be implemented by some logic in the SOC/IO Pads.
For more details on the function and use of HIGHZ, refer to the IEEE 1149.1 document.
The HIGHZ instruction also asserts internal reset for the cores (through CCM, refer to
Figure 47-13) to force a predictable internal state while performing external boundary
scan operations.
47.5.5
BYPASS Instruction
Selects the single Bit bypass register and the system logic controls the I/O pins.
This creates a shift-register path from TDI to the bypass register and, finally, to TDO,
circumventing the boundary scan register. This instruction is used to enhance test
efficiency when a component other than the SoC Core based device becomes the device
under test.
When the bypass register is selected by the current instruction, the shift-register stage is
set to a logic zero on the rising edge of TCK in the capture-DR controller state.
Therefore, the first bit to be shifted out after selecting the bypass register is always a
logic zero.
For more details on the function and use of BYPASS, refer to the appropriate IEEE
1149.1 document.
SoC JTAG Instruction Register (SJIR)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3394
NXP Semiconductors

<!-- page 3395 -->

47.5.6
ENABLE_ExtraDebug Instruction
The TDI and TDO pins are connected directly to the ExtraDebug registers, the SJC TAP
controller remaining connected to TDI and TMS.
The ExtraDebug shift register consists of 38 bits (maximum) comprising a 32-bits data
field (maximum length, see Accessing ExtraDebug Registers,), a 5 bits address field and
read/write bit. On a register read, the data field does not need to be filled in. The
particular ExtraDebug register connected between TDI and TDO at a given time is
selected by the ExtraDebug controller depending on the ExtraDebug Address being
currently decoded. All communication with the ExtraDebug controller is done through
the Select-DR-Scan path of the JTAG TAP Controller.
47.5.7
ENTER_DEBUG instruction
The ENTER_DEBUG instruction is used to generate a debug request event to SDMA and
the Arm Core Platform simultaneously (practically, inherited minimal skew is expected,
due to difference in event signal propagation in the different modules).
The TDI and TDO are connected to the Instruction Register (IR). After the
acknowledgment of the Debug Mode is received (can be checked by reading the Core
Status Register part of the ExtraDebug logic), the user can perform system debug
functions on the cores.
NOTE
The ENTER_DEBUG event issue to the cores, can be masked,
by bits in DCR register.
NOTE
It is user's responsibility to shift-in another IR value (like
IDCODE) before trying to bring the cores out of debug mode,
as the debug request signals to the cores remains asserted as
long as ENTER_DEBUG IR is in place.
NOTE
The user need to check that cores are in debug mode (watching
debug acknowledge signal) before leaving ENTER_DEBUG
instruction, otherwise debug request might not take affect.
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3395

<!-- page 3396 -->

47.5.8
TAP Select Instruction
By means of TAP select instruction a user can access TAP select register and by
controlling its only bit SDMA Bypass, control whether SDMA TAP is bypassed or not.
Table 47-6. TAP Select Register (TSR)
TAP Select Register
BIT 0
Connect SDMA
TYPE
rw
RESET
0
Note:
Table 47-7. TAP Select Register Description
Field
Description
0
SDMA Bypass
Connect SDMA
Control whether SDMA TAP is bypassed or not:
• 0 - SDMA TAP is bypassed by the alternate TAP inside SJC (emulating 4-bit IR
and 1-bit bypass path).
• 1 - SDMA TAP is connected to the TDI-TDO chain.
NOTE: Additional cycle with TMS '0' should be inserted, after writing to this register, to
allow the SDMA tap be sync before SDMA get into / out of bypass.
47.5.9
EXTEST_PULSE instruction
The EXTEST_PULSE instruction implements test behaviors for AC pins and
simultaneously behaves identically to IEEE Std 1149.1 EXTEST for DC pins.
47.5.10
EXTEST_TRAIN instruction
The EXTEST_TRAIN instruction implements test behaviors for AC pins and
simultaneously behaves identically to IEEE Std 1149.1 EXTEST for DC pins.
47.6
Security
JTAG manipulation is one of the known hackers' ways of executing unauthorized
program code, getting control over the OS and run code in privileged modes.
Security
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3396
NXP Semiconductors

<!-- page 3397 -->

The SJC provides a debug access to several H/W blocks including the Arm processor and
the system bus. This allows for program control and manipulation as well as visibility
into system peripherals and memory. The ETM and NEXUS interfaces allow bus
transactions to be traced. Together these tools provide the hacker all the access needed to
completely comprise the system. Means must be provided to block any malicious JTAG
access.
The SJC provides a way of regulating the JTAG access.
The following are the different JTAG security modes:
• Mode #1: No Debug-Maximum Security. All security sensitive JTAG features are
permanently blocked.
• Mode #2: Secure JTAG-High security. JTAG use is regulated by secret key based
authentication mechanism.
• Mode #3: JTAG Enabled-Low security. JTAG always enabled.
The JTAG security modes are configured using eFUSEs which can burned after
packaging by applying electrical signals. The fuse burning is irreversible process, once a
fuse is burned (e-fuse or laser fuse) it is impossible to change the fuse back to the un-
burned state.
47.6.1
JTAG Security Modes
JTAG can be in one of JTAG security modes which is selected by setting the SJC eFUSE
configuration. The physical location of the fuses is not in the SJC.
47.6.1.1
Mode 1: No Debug - Maximum Security
No Debug JTAG security mode provides the highest security level.
In this mode, all JTAG features are disabled except for:
• ScanBoundary Scan
• MBIST, all modes except for debug modes which enable controlled memory contents
output
• PLL BIST
• BIST monitor mode, allowing routing to external pins BIST pass/fail/invoke
information
• PLL bypass- Bypass Arm or/and USB PLL.
• Visibility of the following status bits: power mode - normal, standby, stop, shutdown,
and so on
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3397

<!-- page 3398 -->

These features do not reduce the security level of the product, and they allows to perform
important tests and board connectivity checks.
47.6.1.2
Mode 2: Secure JTAG - High Security
The Secure JTAG mode limits the JTAG access by using challenge/response based
authentication mechanism. Any access to JTAG port is being checked. Only authorized
debug devices (that is, devices having the right response) can access the JTAG,
unauthorized JTAG access attempts are denied.
The intent of this mode is to allow return field testing. When a secured JTAG device is
being returned for debugging, this mode allows authorized re-activation of the JTAG.
47.6.1.2.1
Challenge/Response Mechanism in System JTAG Mode
When SJC is in Sysytem JTAG mode the authentication process is as follows:
1. Shift Output Challenge instruction to IR.
2. Passing through Capture-DR state of the SJC and by performing Shift-DR operations
Challenge code can be accessed from TDO.
3. Shift Enter Response instruction to IR. By performing Shift-DR, operations enter
Response code value through TDI. As Update-DR state is entered, Response code is
compared with the correct one.
In Fixed challenge-response pair mode, each part has its individual challenge - response
pair which is determined at manufacturing time, and does not change later on. The SJC
compares the user's response to the expected response.
Security
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3398
NXP Semiconductors

<!-- page 3399 -->

System JTAG
JTAG Port
Access Policy
User
Response
SJC
compare
Expected
Response
Challenge
Fixed Challenge-Response
External
Debug
Machine
Figure 47-11. Mode #2 - Secure JTAG with Fixed Challenge-response Pair
47.6.1.3
Mode 3: JTAG Enabled - Low Security
In the JTAG Enabled JTAG security mode, all JTAG features are enabled.
47.6.2
Software Enabled JTAG
To increase the flexibility of the SJC, an option to enable the JTAG via software is added
and is available only in Secure JTAG mode. By writing '1' to HAB_JDE (HAB JTAG
DEBUG ENABLE) bit in the e-fuse controller module, the JTAG is opened, regardless of
its security mode. It is the responsibility of software to assert or negate this bit.
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3399

<!-- page 3400 -->

Additionally, a corresponding lock bit is available (in the e-fuse control module) to
ensure that only trusted software is able to set the JDE bit. When the LOCK bit is set, no
future change of JDE is possible, until the next POR (power-on-reset) cycle.
The platform initialization software should set the LOCK bit for JDE bit before
transferring control to the application code.
The S/W JTAG enable allows JTAG enabling without activating the challenge-Response
mechanism (which requires JTAG access tool enhancement or special H/W). The JTAG
S/W enable does not allow debug in case of boot or memory fault as it requires reset
before entering debug.
This feature can be permanently blocked by burning the dedicated e-fuse.
NOTE
The S/W enabled JTAG feature reduces the overall security
level of the system as it relies on S/W protections. If this feature
is not required, it is strongly recommended to burn the
JTAG_HEO e-fuse which disables this feature.
47.6.3
Kill Trace
The kill trace signal disables any output of the ETM block. The ETM can be accessed
either via JTAG port and/or by direct software code. Blocking the JTAG port also yields
assertion of the kill trace signal. This resulted in blocking of trace port. The intention of
this action is to block any attempt to break into the system via software manipulation of
the debug modules. The kill trace, when active, prevents trace output even in case where
it can be activated via chip pin.
The kill trace feature needs to be activated by burning a dedicated e-fuse. If the fuse is
left intact, kill trace is never activated as seen in Figure 47-12.
Security
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3400
NXP Semiconductors

<!-- page 3401 -->

ETM
Kill Trace
JTAG access policy
(JTAG Block)
SJC
Kill Trace Enable
(KTE) fuse
Figure 47-12. Kill Trace eFUSE
The kill trace is asserted when "kill trace enable" fuse is burned and "ipt_secur_block"
signal in SJC is asserted, which happens when at least one of the following is true:
• Mode #2 (Secure JTAG) and no code has been entered
• Mode #2 (Secure JTAG) with burned Bypass and Re-enable fuses
• Mode #2 (Secure JTAG) with incorrect response entered
• Mode #1 (No debug)
• TRST_B signal is active
• POR has not ever been asserted
47.6.4
SJC Disable Fuse
In addition to the different JTAG security modes that are implemented internally in the
System JTAG Controller (SJC), there is an option to disable the SJC functionality by
eFUSE configuration. This creates additional JTAG mode that is, JTAG Disabled with
highest level of JTAG protection. In this mode all JTAG features are disabled.
Specifically, the following debug features are disabled in addition to the features that
were already disabled in No Debug JTAG mode:
• Memory BIST
• Boundary scan register (SJC_BSR)
• Non-Secure JTAG control registers (PLL configuration, Deterministic Reset, PLL
bypass)
• Non-Secure JTAG status registers (Core status)
• Chip Identification Code (IDCODE)
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3401

<!-- page 3402 -->

47.7
Functional Description
This section provides a complete functional description of the block.
47.7.1
Static Core Debug
The SJC JTAG TAP controller is fully compatible with the IEEE 1149.1a-2001 Standard
Test Access Port and Boundary Scan Architecture specifications.
The Arm platform has an integrated JTAG interface and a TAP controller to manage its
own ICE. Also it can access an embedded trace ETM interface, see Arm core and ETM
Technical reference guide for more information.
The SDMA has a TAP controller to manage its own OnCE, see SDMA OnCE
specifications for more details.
The OnCE and ICE provide a mean of interacting with the cores and their peripherals
non-intrusively so that a user may examine registers, memories to facilitate hardware and
software development. Refer to TAP Selection Block (TSB), for more information.
47.7.2
Reset Mechanism
The following figure shows the SJC reset logic
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3402
NXP Semiconductors

<!-- page 3403 -->

AND
IR!=
TSB TAP state!= TestLogicReset
AND
OnCE reset
Reset control
CCM
sjc_trst_b
EXTEST or HighZ
sjc_ieee_reset_b
SJC
POR
RESET_IN
reset
DAP
POR
TRST
SDMA CORE
OnCE TAP Controller
Figure 47-13. SJC Reset Logic
NOTE
• Asserting TRSTB in any scan mode resets the TCR loosing
the testmode configuration and selects default TAP.
• SJC generates an IEEE reset signal to the CCM when in
one of the IEEE modes HIGHZ or EXTEST. This signal
generates a system reset to the cores until exit from one of
these modes.
• The TSB generates Once/ICE reset (either TRSTB if
implemented or other) when its TAP state reaches Test-
Logic-Reset (meaning that TAP accessed is also reaching
Test-Logic-Reset).
47.8
Initialization/Application Information
The control afforded by the output enable signals using the boundary scan register and
the EXTEST instruction requires a compatible circuit-board test environment to avoid
device-destructive configurations. The user must avoid situations in which the SJC output
drivers are enabled into actively driven networks.
There are two constraints related to the JTAG interface:
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3403

<!-- page 3404 -->

• Ensure that the JTAG test logic is kept transparent to the system logic by forcing
TAP into the Test-Logic-Reset controller state. During power-up, SJC's internal
TRSTB is asserted as IC's POR_B is asserted which forces the TAP controller into
this state. After that, if TMS either remains unconnected or is connected to VCC,
then the TAP controller cannot leave the Test-Logic-Reset state, regardless of the
state of TCK.
• DE_B is an IO pin with pullup and care must be taken of the direction when driving
this signal.
47.9
SJC Memory Map/Register Definition
In addition to the standard accessible JTAG registers (per IEEE1149.1 standard) listed in
SoC JTAG Instruction Register (SJIR) , the chip contains the following registers accessed
using the ExtraDebug mechanism, controlled via "ENABLE_ExtraDebug" IR instruction.
NOTE
SJC registers are only accessible by JTAG interface. They are
not memory mapped to processor address space, so the absolute
addresses provided by default in the SJC memory map are not
valid.
This section assumes the JTAG controller is accessed in standalone mode or daisy
chained (defined by TAP Selection Block) using the appropriate TSB configuration.
See "System Debug" chapter for more details about the general purpose register
descriptions that are unique to this chip.
SJC memory map
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
General Purpose Unsecured Status Register 1
(SJC_GPUSR1)
32
R
0000_0000h
47.9.1/3405
1
General Purpose Unsecured Status Register 2
(SJC_GPUSR2)
32
R
0000_0000h
47.9.2/3407
2
General Purpose Unsecured Status Register 3
(SJC_GPUSR3)
32
R
0000_0000h
47.9.3/3407
3
General Purpose Secured Status Register (SJC_GPSSR)
32
R
0000_0000h
47.9.4/3408
4
Debug Control Register (SJC_DCR)
32
R/W
1F9E_0000h
47.9.5/3409
5
Security Status Register (SJC_SSR)
32
R
See section
47.9.6/3411
7
General Purpose Clocks Control Register (SJC_GPCCR)
32
R/W
0C00_05A0h
47.9.7/3414
SJC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3404
NXP Semiconductors

<!-- page 3405 -->

47.9.1
General Purpose Unsecured Status Register 1
(SJC_GPUSR1)
The General Purpose Unsecured Status Register 1 is a read only register used to check
the status of the different Cores and of the PLL. The rest of its bits are for general
purpose use.
Address: 0h base + 0h offset = 0h
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
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3405

<!-- page 3406 -->

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
PLL_LOCK
Reserved
Reserved
S_STAT
A_WFI
A_DBG
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
SJC_GPUSR1 field descriptions
Field
Description
31–9
-
This field is reserved.
Reserved.
8
PLL_LOCK
PLL_LOCK
A Combined PLL-Lock flag indicator, for all the PLL's.
7
-
This field is reserved.
Reserved
6–5
-
This field is reserved.
Reserved.
4–2
S_STAT
3 LSBits of SDMA core statusH.
1
A_WFI
Arm core wait-for interrupt bit
Bit 1 is the Arm core standbywfi (stand by wait-for interrupt). When this bit is HIGH, Arm core is in wait for
interrupt mode.
0
A_DBG
Arm core debug status bit
Bit 0 is the Arm core DBGACK (debug acknowledge)
DBGACK can be overwritten in the Arm core DCR to force a particular DBGACK value. Consequently
interpretation of the DBGACK value is highly dependent on the debug sequence. When this bit is HIGH,
Arm core is in debug.
SJC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3406
NXP Semiconductors

<!-- page 3407 -->

47.9.2
General Purpose Unsecured Status Register 2
(SJC_GPUSR2)
Address: 0h base + 1h offset = 1h
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
STBYWFE
S_STAT
STBYWFI
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
SJC_GPUSR2 field descriptions
Field
Description
31–12
-
This field is reserved.
Reserved
11–8
STBYWFE
STBYWFE[3:0]
Reflecting the "Standby Wait For Event" signals of all cores.
7–4
S_STAT
S_STAT[3:0]
SDMA debug status bits: debug_core_state[3:0]
STBYWFI
STBYWFI[3:0]
These bits provide status of "Standby Wait-For-Interrupt" state of all Arm cores.
47.9.3
General Purpose Unsecured Status Register 3
(SJC_GPUSR3)
Address: 0h base + 2h offset = 2h
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
SYS_
WAIT
IPG_
STOP
IPG_
WAIT
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
SJC_GPUSR3 field descriptions
Field
Description
31–3
-
This field is reserved.
Reserved
Table continues on the next page...
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3407

<!-- page 3408 -->

SJC_GPUSR3 field descriptions (continued)
Field
Description
2
SYS_WAIT
System In wait
Indication on System in wait mode (from CCM).
1
IPG_STOP
IPG_STOP
CCM's "ipg_stop" signal indication
0
IPG_WAIT
IPG_WAIT
CCM's "ipg_wait" signal indication
47.9.4
General Purpose Secured Status Register (SJC_GPSSR)
The General Purpose Secured Status Register is a read-only register used to check the
status of the different critical information in the SoC. This register cannot be accessed in
secure modes.
Address: 0h base + 3h offset = 3h
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
GPSSR
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
SJC_GPSSR field descriptions
Field
Description
GPSSR
General Purpose Secured Status Register
Register is used for testing and debug.
SJC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3408
NXP Semiconductors

<!-- page 3409 -->

47.9.5
Debug Control Register (SJC_DCR)
This register is used to control propagation of debug request from DE_B pad to the cores
and debug signals from internal logic to the DE_B pad.
Address: 0h base + 4h offset = 4h
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
1
1
1
1
1
0
0
1
1
1
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
DIRECT_ARM_REQ_EN
DIRECT_SDMA_REQ_EN
Reserved
DEBUG_OBS
Reserved
DE_TO_SDMA
DE_TO_ARM
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
SJC_DCR field descriptions
Field
Description
31–7
-
This field is reserved.
Reserved
6
DIRECT_ARM_
REQ_EN
Pass Debug Enable event from DE_B pin to Arm platform debug request signal(s).
This bit controls the propagation of debug request DE_B to the Arm platform.
0
Disable propagation of system debug to (DE_B pin) to Arm platform.
1
Enable propagation of system debug to (DE_B pin) to Arm platform.
5
DIRECT_SDMA_
REQ_EN
Debug enable of the sdma debug request
This bit controls the propagation of debug request DE_B to the sdma.
0
Disable propagation of system debug to (DE_B pin) to sdma.
1
Enable propagation of system debug to (DE_B pin) to sdma.
4
-
This field is reserved.
Reserved
Table continues on the next page...
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3409

<!-- page 3410 -->

SJC_DCR field descriptions (continued)
Field
Description
3
DEBUG_OBS
Debug observability
This bit controls the propagation of the "system debug" input to SJC (driven by the ECT logic), to the
DE_B pad.
(This logic can be used to pass debug acknowledge event from ECT out to the PAD, for example).
The SJC's "system_debug" input is tied to logic HIGH value, therefore, set of "debug_obs" bit, will result in
unconditional assertion of DE_B pad.
0
Disable propagation of system debug to DE_B pin
1
Unconditional assertion of pad DE_B
2
-
This field is reserved.
Reserved
1
DE_TO_SDMA
SDMA debug request input propagation
This bit controls the propagation of debug request to SDMA, when the JTAG state machine is put in
"ENTER_DEBUG" IR instruction..
0
Disable propagation of debug request to SDMA
1
Enable propagation of debug request to SDMA
0
DE_TO_ARM
Arm platform debug request input propagation
This bit controls the propagation of debug request to Arm platform ("dbgreq"), when the JTAG state
machine is put in "ENTER_DEBUG" IR instruction.
0
Disable propagation of debug request to Arm platform
1
Enable propagation of debug request to Arm platform
SJC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3410
NXP Semiconductors

<!-- page 3411 -->

47.9.6
Security Status Register (SJC_SSR)
Address: 0h base + 5h offset = 5h
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
-
Reserv
ed
W
Reset
0*
0*
0*
0*
0*
0*
0*
0*
0*
0*
0*
0*
0*
0*
0*
0*
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3411

<!-- page 3412 -->

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
Reserv
ed
BOOTIND
Reserved
RSSTAT
SJM
FT
Reserved
Reserved
EBG
EBF
SWE
SWF
KTA
KTF
W
Reset
0*
0*
0*
0*
0*
0*
0*
1*
0*
0*
0*
0*
0*
0*
0*
0*
* Notes:
The SJM reset value, reflects the JTAG security state, as defined by status of JTAG_SMODE[1:0] fuses. See the SJM
bitfield description for details on valid values.
•
SJC_SSR field descriptions
Field
Description
31–17
-
Reserved.
16–15
-
This field is reserved.
Reserved
14
BOOTIND
Boot Indication
Inverted Internal Boot indication, i.e inverse of SRC: "src_int_boot" signal
13
-
This field is reserved.
Reserved
12–11
RSSTAT
Response status
Response status bits
00
Response wasn't entered
01
Response was entered but not verified
Table continues on the next page...
SJC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3412
NXP Semiconductors

<!-- page 3413 -->

SJC_SSR field descriptions (continued)
Field
Description
10
Response was entered and is incorrect
11
Response is correct
10–9
SJM
SJC Secure mode
Secure JTAG mode, as set by external fuses.
00
No debug (#1)
01
Secure JTAG (#2)
10
Reserved
11
JTAG enabled (#3)
8
FT
Fuse type
Fuse type bit - e-fuse or laser fuse
0
E-fuse technology
1
Laser fuse technology
7
-
This field is reserved.
Reserved
6
-
This field is reserved.
Reserved
5
EBG
External boot granted
External boot enabled, requested and granted
1
granted
0
not granted
4
EBF
External Boot fuse
Status of the external boot disable fuse
0
(intact) - external boot is allowed
1
(burned) - external boot is disabled
3
SWE
SW enable
SW JTAG enable status
1
enabled
0
disabled
2
SWF
Software JTAG enable fuse
Status of the no SW disable JTAG fuse
0
(intact) - SW enable possible
1
(intact) - no SW enable possible
1
KTA
Kill Trace is active
1
active
0
not active
0
KTF
Kill Trace Enable fuse value
0
(intact) - kill trace is never active
1
(burned) - kill trace functionality enabled
Chapter 47 System JTAG Controller (SJC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3413

<!-- page 3414 -->

47.9.7
General Purpose Clocks Control Register (SJC_GPCCR)
This register is used to configure clock related modes in SOC, see System Configuration
chapter for more information. Those bits are directly connected to JTAG outputs. Bit 0 of
GPCCR controls SDMA clocks invocation. When out of reset, the SDMA is in sleep
mode with no SDMA clock running. Unlike events, debug requests does not wake
SDMA if it is in sleep mode. The debug request is recognized by the SDMA only when it
exits sleep mode upon reception of an event. To be able to enter debug mode even if no
event is triggered, the SDMA clock on bit needs to be set prior to sending the debug
request (clear at reset).
Address: 0h base + 7h offset = 7h
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
-
W
Reset
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
ACLKOFFDIS
SCLKR
W
Reset
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
0
0
0
0
SJC_GPCCR field descriptions
Field
Description
31–2
-
Reserved
1
ACLKOFFDIS
Disable/prevent Arm platform clock/power shutdown
0
SCLKR
SDMA Clock ON Register - This bit forces the clock on of the SDMA
SJC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3414
NXP Semiconductors

