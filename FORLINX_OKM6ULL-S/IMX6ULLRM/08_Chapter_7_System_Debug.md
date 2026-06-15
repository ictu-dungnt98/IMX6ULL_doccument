# Chapter 7: System Debug

> Nguồn: `IMX6ULLRM.pdf` — trang 239–248

<!-- page 239 -->

Chapter 7
System Debug
7.1
Overview
This section describes the hardware and software debug and application development
features and resources of the chip. It describes the following:
• Core/platform-specific resources
• Resources associated with complex IP blocks
• Chip-wide resources
• Interface to the external debug and development tools
The debug and trace architecture is designed around the following:
• ARM CoreSight architecture, adapted to SoC (for core debug), including a cross-
trigger subsystem for cross-domain triggering of debug resources
• JTAG port used to interact with core under the debug by means of SJC, the system
JTAG controller port
• DAP, the debug access port that supports the interface to the ARM RealView
Debugging tools and other third-party tools
• TPIU, a trace port interface unit that efficiently accesses the program trace
information from the system
• Various chip-wide resources, such as debug features built into the IP blocks and
critical signal visibility available through alternate pin functions or observability
muxes
7.2
Chip and ARM Platform Debug Architecture
The ARM Debug architecture is based on the CoreSight architecture by ARM. The
CoreSight architecture provides a system-wide solution to real-time debug and trace.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
239

<!-- page 240 -->

The CoreSight architecture is embodied in a set of CoreSight components and compliant
processors that form the CoreSight systems. Its architecture maintains the traditional
requirements of debug and trace:
• To access the debug functionality without software interaction
• To connect to a running system without performing a reset
Full access to the processor debug capability is available by the ARM debug register map
through the Advanced Peripheral Bus (APB) slave port. The core includes a Processor
Debug Unit which stops program execution, examines and alters the processor and
coprocessor state, examines and alters the memory and input/output peripheral state, and
restarts the processor core.
7.2.1
Debug Features
• CoreSight Embedded Trace Macrocell (ETM): trace generator for ARM processors
• Support for a TrustZone-related 3-level debug scheme:
• Debug in Non-Secure privileged and user, and Secure user
• Debug in Non-Secure only
• EmbeddedICE-RT logic
• Support for both the monitor-mode and halt-mode debugging:
• Core run/halt control, debug status/control
• Breakpoint/watchpoint control
• Core-mapped and memory-mapped resource examination/modification
• Data communication channel between the ARM core and the host debugger via
JTAG and the Debug Access Port (DAP) module
• PMU (Performance Metrics Unit) used for system profiling and debug
• CP15 register for debugging the MMU, I and D L1 cache, and TLB
The chip includes ARM CoreSight components for multicore debug and trace solutions.
7.2.2
Debug system components
The CoreSight components include:
• Embedded Trace Buffer (ETB): RAM array to be used for on-chip capture of trace
data output from the PTM
• ATB Replicator to connect the trace data to TPIU (Trace Port Interface) and ETB
(Embedded Trace Buffer)
• Cross Triggering logic for event routing, including CTIs and CTMs
Other related IPs and functionality:
Chip and ARM Platform Debug Architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
240
NXP Semiconductors

<!-- page 241 -->

• ROMPATCH module to support modification of program/data information in the
MCU ROM
• Debug Visibility which selects critical signals routed to the I/O pads as alternate
outputs for external visibility
7.2.2.1
AMBA Trace Bus (ATB)
ATB transfers trace data though the chip CoreSight infrastructure. The trace sources are
ATB masters and the sinks are ATB slaves. The ARM (via PTM) cores are the data
generators. Link components such as the Trace Funnel and Replicator provide both the
master and slave interfaces.
The ATB protocol supports:
• Stalling of trace sources to enable the CoreSight components to funnel and combine
the sources into a single trace stream
• Association of the trace data with the generating source using trace source IDs. The
CoreSight system can trace up to 111 different items at any time
• Capture and transfer of multiple byte bus widths, currently to 32 bits
• A flushing mechanism to force the historic trace to drain from any sources, links, or
sinks up to the point that the request is initiated
7.2.2.2
ATB replicator
The ATB replicator enables two trace sinks to be wired together and to operate from the
same incoming trace stream.
There are no programmable registers. This component is invisible to the user on a
particular trace path, from source to sink.
• Incoming ATB Interface—the ATB replicator accepts the trace data from the trace
source, either directly or through a trace funnel.
• Outgoing ATB Interfaces—the ATB replicator sends identical trace data on the
outgoing master port interfaces.
Chapter 7 System Debug
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
241

<!-- page 242 -->

7.2.2.3
Embedded Cross Triggering
The ECT is a modular component from ARM Limited that supports the interaction and
synchronization of multiple triggering events within a chip. The main function of the
ECT (CTI and CTM) is to pass debug events from one core to another. For example, the
ECT can communicate the debug state information from one core to another, so that the
program execution can be stopped on both processors at the same time (if required).
The ECT consists of these types of modules:
• Cross Trigger Interfaces (CTI)
• Cross Trigger Matrix (CTM)
The cross trigger interfaces provide the interface between the component or subsystem
and the cross trigger matrix. The system requires a CTI for each subsystem that supports
cross triggering. The CTI combines and maps the trigger requests, and broadcasts them to
all other interfaces on the ECT as channel events. When the CTI receives a channel
event, it maps it onto a trigger output. This enables the subsystems to cross trigger with
each other. The reception and transmission of triggers is performed through the trigger
interface.
The Cross Trigger Matrix (CTM) combines the trigger requests generated from the CTIs
and broadcasts them to all CTIs as channel triggers. The CTM controls the distribution of
channel events. It provides the Channel Interfaces (CIs) to connect to either the CTIs or
CTMs. This enables multiple CTIs to be linked together. The ECT is composed of three/
five CTIs (Cross Trigger Interface) and two CTMs (Cross Trigger Matrix). The ECT is
key in the multi-core and multi-IP debug strategy. The outcome is a software-controlled
debug signal matrix that receives signals from various sources (cores and peripherals) and
propagates/ routes them to the different debug resources of the SoC. These debug
resources include the time-stamping capability, profiling capabilities, real-time trace
(trace enabled or disabled), triggers, SOC level multiplexing, and debug interrupts.
NOTE
Because the ECT should only be used during the debug
sessions, it is disabled by default.
7.2.2.3.1
Cross-Trigger Matrix (CTM)
The CTM (Cross-Trigger Matrix) is provided by ARM. A brief description is provided
below. See the ARM documentation for more details.
The CTM is a relatively simple block with no configuration options. There are two CTM
instances in in the ARM platform.
Chip and ARM Platform Debug Architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
242
NXP Semiconductors

<!-- page 243 -->

One of them is used to route Core's CTI's, while the second one is used for the additional
CoreSight CTIs. Each CTI has four channel lines, to which the CTI events are mapped.
The exact mapping is configured in the CTI logic.
7.2.2.3.2
Cross-Trigger Interface (CTI)
The Cross-Trigger Interface (CTI) component is provided by ARM. A brief description
of the CTI is provided below.
There are CTIs in the chip's ARM platform. of which, dedicated to , while the is used for
various other signals routing.
Each of these CTIs has 8 trigger inputs and 8 trigger outputs that connect to logic in the
domain to be debugged or profiled. Each CTI also includes a 4 channel interface to the
CTM (4 inputs and 4 outputs).
For more information, see ARM platform chapter.
7.2.2.4
Debug Access Port (DAP)
The DAP enables debug access to the chip modules through APB-AP (the APB access
port) and APB-Mux (the APB multiplexer).
AHB-AP provides system access. Debug tools can use JTAG to connect to the chip.
DAP has the following features:
• AMBA 3 Peripheral Bus Multiplexor access though AMBA 3 APB Access Port,
providing debug peripheral access through the APB interface.
• External JTAG access using the JTAG Debug Port (JTAG-DP).
• Internal chip module access using:
• AHB Access Port (AHB-AP)
• APB Access Port (APB-AP)
• JTAG Access Port (JTAG-AP)
APB-Mux enables system access to CoreSight components connected to the Debug APB.
The ROM table provides a list of memory locations of CoreSight components connected
to the Debug APB. This is visible from both tools and system access and one configures
it during system implementation.
External read/write access to the internal interface is provided by JTAG-DP. JTAG-DP
provides a standard interface for debug access to the chip through DAP. It interfaces to
the DAP internal bus.
Chapter 7 System Debug
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
243

<!-- page 244 -->

Internal access to on-chip buses and other interfaces are provided by the access ports
(APs). The available APs are:
• AHB-AP which provides an AHB-Lite master for access to a system AHB bus.
• APB-AP which provides an AMBA 3 APB master for access to the Debug APB that
configures all CoreSight components.
• JTAG-AP which provides JTAG access to on-chip components and operates as a
JTAG master port to drive JTAG chains throughout the chip.
7.2.3
Chip-Specific SJC Features
7.2.3.1
JTAG Disable Mode
In addition to different JTAG security modes that are implemented internally in the
System JTAG Controller (SJC), there is an option to disable the SJC functionality by e-
fuse configuration.
This creates additional JTAG mode "JTAG Disabled" with highest level of JTAG
protection. In this mode all JTAG features are disabled. Specifically, the following debug
features are disabled in addition to the features that were already disabled in "No Debug"
JTAG mode:
• Non-Secure JTAG control registers (PLL configuration, Deterministic Reset, PLL
bypass)
• Non-Secure JTAG status registers (Core status)
• Chip Identification Code (IDCODE)
7.2.3.2
JTAG ID
Table 7-1. i.MX JTAG ID
Device
Silicon revision
JTAG ID
i.MX 6ULL
Rev 1.0
0891_E01Dh1
1.
In follow-on silicon revisions, the ID value is subject to change by incrementing the first nibble as follows: 1891_E01Dh for
Rev 1.1, 2891_E01Dh for Rev 1.2 , etc.
7.2.4
System JTAG Controller - SJC
The SJC module is the bridge between external development and test instrumentation and
the internal JTAG-accessible debug and test resources.
Chip and ARM Platform Debug Architecture
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
244
NXP Semiconductors

<!-- page 245 -->

It implements and manages the daisy-chained topology consisting of its own TAP and
those of the SDMA, and the ARM Debug Access Port (DAP).
NOTE
Single Wire Debug (SWD) protocol is not supported.
7.2.5
System JTAG controller main features
• IEEE P1149.1, 1149.6 (standard JTAG) interface to off-chip test and development
equipment
• Includes an SJC-only mode for true IEEE P1149.1 compliance, used primarily
for board-level implementation of boundary scan.
• Supports IEEE P1149.6 extensions to the JTAG standard for AC testing of
selected I/O signals.
• Debug-related control and status; puting selected cores into reset and/or debug mode
and monitoring individual core status signals by means of JTAG
• System status, such as the state of the PLLs (locked or not locked)
• levels of security, ranging from no security to no JTAG accessibility to the chip
7.2.6
SJC TAP Port
The SJC supports the following standard JTAG pins:
• TRSTB
• TDI
• TDO
• TCK
• TMS
7.2.7
SJC main blocks
• Interface to the outside world via the standard JTAG pins
• Interface to the external Debug_Event pin
• A master TAP controller which implements the standard JTAG state machine
• Implementation of the mandatory and optional IEEE P1149.1 (JTAG) instructions
• Mandatory: "EXTEST", "SAMPLE/PRELOAD", and "BYPASS"
• Optional: "ID_CODE" (SOC JTAG ID register), "HIGHZ"
• Supports the SDMA's DR-path-only JTAG architecture by implementing the
controller portion of its TAP (including "BYPASS" as the default state) within the
SJC
Chapter 7 System Debug
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
245

<!-- page 246 -->

• The ExtraDebug registers, which implement a variety of control and status features
• Three 32-bit insecure general purpose status registers
• Two 32-bit secure status registers - one predefined, one general purpose.
• Control and status registers for debug, core, charge pump, and PLL.
• Four levels of fuse-defined security, ranging from no security to no access.
Both predefined and user-defined control and status functions are supported by the SJC.
7.3
Smart DMA (SDMA) core
SDMA is a dedicated, programmable DMA engine. It is an integration of a 32-bit RISC
core and DMA-specific hardware. It includes ports for the AP domain and a peripheral
domain, along with a burst-capable port for direct external memory access.
NOTE
The SDMA and its integration in the chip is unchanged from
previous i.MX chips.
The main SDMA debug features are:
• OnCE - On Chip Emulator, provides the following capabilities:
• SDMA core control - run/halt/single-step
• SDMA core register/memory-map access
• Event detection, watchpoints, and hardware breakpoints
• Real time buffer and PC trace buffer capability
• Trace buffer
• Contains information to identify the 32 last changes of flow detected during a
program execution
• Context dump
• Includes information about all the channel dump activity
• Current contents of SDMA RAM
• ROMPATCH
7.3.1
SDMA On Chip Emulation Module (OnCE) Feature
Summary
The SDMA debug features are primarily defined by the OnCE portion of its design.
They are summarized as follows:
Smart DMA (SDMA) core
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
246
NXP Semiconductors

<!-- page 247 -->

• Memory And Register Access - dedicated logic enables user-access to SDMA
memory and register locations. These accesses are supported only when the
processor is in debug mode.
• Event Detection Unit - watches signals from the data memory bus (DMBus) which is
used by the RISC core to access its RAM, ROM, and memory-mapped registers
• Watchpoints - one output signal is available to watch event matching conditions at
the chip level. Match conditions are defined by programming memory-mapped
registers.
• Hardware Breakpoint - a counter is decremented after an event detection. A debug
request is sent to the SDMA core only when the counter reaches the value of zero. It
is possible to program the initial value of the counter or to disable the use of the
counter if a debug request must be generated after each event detection.
• Real Time Buffer - The Real Time Buffer Register (RTB) is a single 32-bit memory-
mapped register which can be accessed as a regular memory location during program
execution. It is used to store and retrieve run time information without putting the
SDMA in debug mode. Each write to this register causes an event. This register is, in
fact, located in the OnCE. Executing through JTAG, a buffer command exports the
content of this register through the JTAG port.
• Core Control (Core Status / Single Stepping) - Commands are provided to monitor
and control processor activity. The commands can halt the core, rerun the core from
another address location, and get processor status.
• Trace Buffer - a 32x32 buffer which records the last 32 changes of flow during
program execution. The buffer stores data in a modulo fashion (i.e. the 33rd
instruction change replaces the 1st). Captured trace information is retrieved via reads
to the Trace Buffer Register.
7.3.1.1
Other SDMA Debug Functionality
• Core Trace - basic core trace capability is available through debug visibility
functionality only. PTM trace capability does not exist.
• ROM Patch - can be accomplished by manipulating the CHN0ADDR register
through JTAG or via the MCU's ability to write to SDMA OnCE registers. This must
be done right after reset and before the SDMA core is enabled to begin processing
events.
• Additional debug control/status interaction with the SJC module
• SJC-controlled Debug Request
• SJC-readable Debug Acknowledge (in debug mode)
• Debug clock control - allows SJC to force clocks on for debug purposes
• Debug core state (SDMA RISC Core State) - 4 bits accessible from the SJC via
JTAG
Chapter 7 System Debug
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
247

<!-- page 248 -->

7.3.1.2
SDMA ROM Patching
After reset, the SDMA is in its IDLE_AFTER_RESET mode. A debug request also puts
the SDMA in its DEBUG_IN_IDLE_AFTER_RESET mode. The new address boot must
be stored in CHN0ADDR register (e.g., through the SDMA OnCE via debugger).
The user must then issue the exec_core <instruction> SDMA OnCE instruction to return
to the IDLE_AFTER_RESET mode. The very first instructions of the boot code fetches
the contents of this register (which is also mapped in the SDMA memory space) and
jumps to the given address.
7.4
Miscellaneous
The Miscellaneous function described in this section provide useful general capabilities.
7.4.1
Clock/Reset/Power
CDBGPWRUPREQ and CDBGPWRUPACK are the handshake signals between the
DAP and the clock control module to ensure debug power and clocks are turned on. If the
debug components are always powered on, the handshake becomes a mechanism to turn
debug clocks on. Similarly, there is a register bit in the CCM which allows internal
software to turn debug clocks on as well because the CDBGPWRUPREQ is in the TCLK
domain and is inaccessible to software.
The Cortex-A7 core can receive resets from the following sources:
• Debug Reset (CDBGRSTREQ bit within the SWJ-DP CTRL/STAT register of the
DAP) in the TCLK domain. This allows the debug tools to reset the debug logic.
• System POR reset
7.5
Supported tools
DS-5 ARM Debugger is supported.
The debugger is connected to the chip from the host by the DS-5 ICE protocol converter.
Other third party tools can be used via the standard JTAG interface, but may need to be
adapted for individual IC. It is important to check with tool vendors for specific tool
requirements, especially for on-chip IC.
Miscellaneous
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
248
NXP Semiconductors

