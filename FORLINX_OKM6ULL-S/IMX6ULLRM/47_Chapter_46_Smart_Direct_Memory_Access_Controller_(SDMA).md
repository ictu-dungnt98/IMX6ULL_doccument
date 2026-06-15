# Chapter 46: Smart Direct Memory Access Controller (SDMA)

> Nguồn: `IMX6ULLRM.pdf` — trang 3145–3378

<!-- page 3145 -->

Chapter 46
Smart Direct Memory Access Controller (SDMA)
46.1
Overview
The Smart Direct Memory Access (SDMA) controller offers highly-competitive DMA
features combined with software-based virtual-DMA flexibility. It enables data transfers
between peripheral I/O devices and internal/external memories.
The SDMA controller helps maximize system performance by off-loading the Arm core
in dynamic data routing.
46.1.1
Block Diagram
The figure below shows a block diagram of the SDMA controller. It includes the custom
RISC core along with its RAM, ROM, DMA units, and the scheduler.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3145

<!-- page 3146 -->

External to SDMA
Per #1
Per #...
Per #14
SPBA
RAM
ROM
SDMA
REGISTERS
AP
Control
Scheduler
SDMA Core
On CE
JTAG
Interface
data
instructions
System Bus
AP
Peripheral
Bus
DMA
Requests
Functional Units Bus
Peripheral
DMA
Burst
DMA
AP Peripherals
AP Memory
16
48
32
32
32
32
32
32
32
32
32
32
32
Figure 46-1. SDMA Block Diagram
The SDMA core executes short routines that perform DMA transfers; these routines are
called scripts. The SDMA core interfaces to its own memory via the SDMA system bus.
The SDMA system bus supports a 32-bit data path and a 16-bit address bus. The system
bus datapath is used for both 16-bit instruction (program) memory access and 32-bit data
access. DMA units interface to the core via the Functional Unit Bus and use dedicated
registers to perform DMA transfers.
The SDMA memory contains a ROM and a RAM. The ROM contains startup scripts (for
example, boot code) and other common utilities, which are referenced by the scripts that
reside in the RAM. The internal RAM is divided into a context area and a script area
(more details about this mapping are available in Instruction Memory Map and Data
Memory Map).
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3146
NXP Semiconductors

<!-- page 3147 -->

Every transfer channel requires one context area to keep the contents of all the core and
unit registers while inactive. Channel scripts are downloaded into the internal RAM by
the SDMA using a dedicated channel that is started during the boot sequence. Downloads
are invoked using commands and pointers provided by the Arm platform. Every channel
contains a corresponding channel script located in RAM and/or ROM that can be
reconfigured independently as-needed. Channel scripts can be stored in an external
memory and downloaded when needed. The SDMA can be configured with any mixture
of scripts to enable an endless combination of supported services.
The scheduler monitors and detects DMA requests, mapping them to channels, and
mapping individual channels to a pre-configured priority. At any given point, the
scheduler presents the highest priority channel that requires service to the SDMA core. A
special SDMA core instruction is used to "conditionally yield" the current channel being
executed to an eligible channel that requires service. If (and only if) there is an eligible
channel pending, will the current channel execution be preempted.
There are two yield instructions that differently determine the eligible channels: In the
first version, eligible channels are pending channels with a strictly higher priority than the
current channel priority. In the second version (yieldge), eligible channels are pending
channels with a priority that is greater or equal to the current channel priority. The
scheduler detects devices that need service through its 48 DMA request inputs. After a
request is detected, the scheduler determines the channel(s) that is (are) triggered by this
request and marks it (them) as pending in the "Channel Pending (EP)" register. The
priorities of all the pending channels are continuously evaluated in order to update the
highest pending priority. The channel pending flag is cleared by the channel script when
the transfer has completed.
The Arm platform control block contains the control registers used to configure the 32
individual channels. There are 48 Channel Enable registers, and every register maps one
DMA request to any desired combination of channels. The 32 Priority registers are used
to assign a programmable 1-of-7 level priority to every possible channel. This block also
contains all other control registers that the Arm platform can access.
The 48 DMA requests that are connected to the scheduler come from a variety of sources.
The "receive register full" and "transmit register empty" signals found in the UART and
USB ports are typical examples of DMA requests that can be connected to the SDMA.
These requests can be used to trigger a specific SDMA channel, or several channels.
There is an OnCE compatible debug port for product development. The OnCE includes
support for setting breakpoints, single-step and trace, and register dump capability. In
addition, all memory locations are accessible from the debug port.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3147

<!-- page 3148 -->

46.1.2
Features
The following are the SDMA features:
• Multi-channel DMA supporting up to 32 time-division multiplexed DMA channels
• Hardware or software driven triggers for each channel
• 48 hardware driven triggers that can be mapped to any channel.
• Memory accesses including linear addressing, FIFO addressing and 2D addressing
• Fast context-switching with two-level, priority-based preemptive multi-tasking
• 16-bit instruction-set micro-RISC engine (the SDMA core)
• Two DMA units with some or all the following features:
• Auto-flush and prefetch capability
• Flexible address management (increment, decrement, and no address changes on
source and destination address)
• Misaligned data-transfer support
• Uni-directional and bi-directional flows (copy mode)
• Up to eight-word buffers for configurable burst transfers
• Support of byte-swapping
• An available API and library of scripts
• Little-Endian and Big-Endian modes
• Hardware handshakes for low-power entry sequence
• Security support to lock contents of the SDMA script RAM.
• 4-Kbyte ROM containing startup scripts (for example, boot code) and other common
utilities that can be referenced by RAM-located scripts
• 8-Kbyte RAM area is divided into a processor context area and a code space area
used to store channel scripts that are downloaded from the system memory
• Debug support, including a OnCE port, real-time monitors, and embedded cross-
trigger events
• Supported clock frequencies in process:
• Configurable clock options for the SDMA core and the Arm platform DMA
units
• 1:2 ratio with maximum of SDMA core running at Arm platform Peripheral
Bus speed and DMA running at max DMA frequency.
• 1:1 ratio when both SDMA core and Arm platform DMA clocks are set to
the Arm platform Peripheral Bus speed.
• Peripheral bus interface for configuration register programming by the Arm platform
• The SDMA RISC engine (arithmetic and logic operations), which is referred to as the
"SDMA core."
• An internal peripheral bus connected to the Shared Peripherals Bus Interface (SPBA)
that enables access to up to 14 shared peripherals. SDMA supports 32-bit accesses to
word peripherals and 16-bit accesses to half-word peripherals.
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3148
NXP Semiconductors

<!-- page 3149 -->

• The peripheral DMA unit that is hooked-up to the Arm platform Crossbar Switch to
service Arm peripherals
• The burst DMA unit is able to perform burst accesses to the external memory
• All the DMA units are 32-bit AHB masters. They are connected to different buses,
thus allowing concurrent accesses.
46.2
External Signals
The table found here describes the external signals of SDMA.
Table 46-1. SDMA External Signals
Signal
Description
Pad
Mode
Direction
SDMA_EVENT0
Event0 signal
GPIO1_IO02
ALT6
I
JTAG_MOD
ALT6
SD1_CMD
ALT6
SDMA_EVENT1
Event1 signal
JTAG_TMS
ALT6
I
NAND_DQS
ALT6
46.3
Clocks
The following table describes the clock sources for SDMA. Please see Clock Controller
Module (CCM) for clock setting, configuration and gating information. For functional
information regarding module clocks, see SDMA Clocks and Low Power Modes.
Table 46-2. SDMA Clocks
Clock name
Clock Root
Description
events_sync_clk (clk)
ahb_clk_root
Arm peripheral / events clock
ips_hostctrl_clk
ipg_clk_root
Host control clock
ap_ahb_clk
ahb_clk_root
Arm platform bus clock
core_clk
ipg_clk_root
Module / Core clock
tck
-
JTAG access clock
46.4
Functional Description
The figure below shows the SDMA topology, and is composed of the following
components:
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3149

<!-- page 3150 -->

• SDMA Core (SDMA Core)
• SDMA Scheduler (Scheduler)
• Functional Units:
• Burst DMA (Burst DMA Unit)
• Peripheral DMA (Peripheral DMA Unit)
• Arm platform Control for Arm control register access.
• Internal RAM and ROM Memory (SDMA Programming Model)
• OnCE debug Port (The OnCE Controller)
The functional unit bus provides access by the SDMA core to the DMA units. The system
bus provides access to SDMA internal memory and also supports up to 14 peripherals.
Xbar
Switch
Per DMA
Unit
Burst DMA
unit
AP Control
SDMA
µRISC
core
ROM
RAM
Regs
OnCE
functional units bus
peripheral bus
SPBA
Per# 1
Per# 14
. . .
AP
Peripheral
Bus
AP Peripheral Bus
DMA Requests
EMI
External Memory
Xbar
Switch
AP
Platform
AIPS
MemCtrl
RAM
Periph
Periph
Periph
BP DMA
unit
BP
Peripheral
Bus
Scheduler
BP Control
BP Peripheral Bus
MemCtrl
AIPS
StarCore
Platform
Periph
Periph
Periph
M2/M1
Figure 46-2. SDMA Connections
46.4.1
SDMA Core
The SDMA core is a customized RISC-like processor that is specifically developed to
control DMA units and perform L1 tasks like byte-stuffing or framing.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3150
NXP Semiconductors

<!-- page 3151 -->

The SDMA core incorporates on-chip debug capability using the OnCE.
The SDMA core is based on a 32-bit register architecture with 16-bit instructions. There
are eight general purpose 32-bit registers, four flags (T, LM, SF, and DF), and four PCU
registers (PC, RPC, SPC, and EPC) that can address 16,384 16-bit instructions.
46.4.1.1
SDMA Core Structure
The figure found here shows the structure of the SDMA core. It also shows the different
registers, calculation resources, and possible data movements.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3151

<!-- page 3152 -->

GREG0
GREG1
GREG2
GREG3
GREG4
GREG5
GREG6
GREG7
General Registers
DECR
ALU
32
32
32
SF
DF
T
LM
Flags
Instruction Decoder
Instruction
AGU
8
5
PC
RPC
SPC
EPC
PCU
IBUS
16
14
data
address
DMBUS
FUBUS
32
16
address
data
data
address
(instruction)
32
8
14
32
32
Figure 46-3. SDMA Core
• The Program Control Unit (PCU) is described in Program Control Unit (PCU). It
handles the state of the core and generates the instruction fetch addresses.
Instructions are retrieved from the Instruction Bus (IBUS) and stored in the SDMA
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3152
NXP Semiconductors

<!-- page 3153 -->

core instruction register prior to their decoding. The PCU contains the following
registers:
• The Program Counter (PC) contains the address of the current instruction.
• The Return Program Counter (RPC) contains the address of the instruction that
follows a jump to the subroutine.
• The Start Program Counter (SPC) contains the address of the first instruction of
the current hardware loop.
• End Program Counter (EPC) contains the address of the last instruction of the
current hardware loop.
• The other core registers are the general purpose registers (GREGn) and the flags.
• The general purpose registers can be used to hold data and addresses. They can
be loaded with immediate values (for example, 8-bit data that are encoded in the
instruction), results of calculations that were performed with the ALU, 32-bit
data that comes from the memory or peripherals via the Data Memory Bus
(DMBUS), 32-bit data that comes from the DMAs via the Functional Units Bus
(FUBUS) or another general purpose register. Their content can be the operands
of the ALU, the data to send on either bus (DMBUS or FUBUS), or a pointer to
memory (DMBUS address).
• The general register 0 (GREG0) is also the hardware loop counter. In hardware
loops, it cannot be used for any other purpose. This register uses a dedicated
decrement unit (DECR) shown in Figure 46-3.
• The flags reflect the status of operations:
• SF and DF are set when the last load or store on either bus (FUBUS or
DMBUS) received an error response.
• LM is set when the core is executing instructions inside a hardware loop.
• T is set when the ALU operation result was 0 or the loop counter reaches 0
(the latter is preponderant when an ALU operation is the last instruction of a
hardware loop).
• The ALU has two operands: any general register and either a second general register
or an immediate value. The result is always stored into the first general register. A
NOP function can be utilized by moving a register's contents into itself (For example,
the instruction: mov R0,R0).
• The 16-bit instructions are fetched via the instruction bus (IBUS) whose address is
driven by the PC. The SDMA RAM and ROM are visible to the core as 16-bit
devices through this interface.
• The memory (RAM and ROM), memory mapped registers, and external peripherals
are accessed via the DMBUS. The address is always taken from a general register
whose content is added to a 5-bit immediate value. This is the only available
addressing mode. The DMBUS is a 32-bit data bus. Except for the peripherals that
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3153

<!-- page 3154 -->

are external to the SDMA, the address accuracy is the 32-bit word (for example,
adding 1 to an address points to the next word, not the next byte).
• The functional units are accessed via the FUBUS connection. The data is exchanged
with any general register, but the address (which in fact is the instruction and the
selector of the functional unit) comes from an 8-bit field of the corresponding load or
store.
46.4.1.2
Program Control Unit (PCU)
This part of the SDMA core is dedicated to the control of the RISC engine, as implied by
the instructions that are executed. Its behavior is determined by the instruction type and
the inputs of the SDMA.
It contains the PC, RPC, SPC, and EPC registers that are described in SDMA Core
Structure.
46.4.1.2.1
Instruction Types
The state sequence and the delay of execution vary according to the type of the
instruction. There are six possible categories of instructions, as follows:
1. Standard: Most of the instructions belong to this category, and always last 1 cycle.
2. ldf/stf: These are respectively the load and store instructions that access the
functional units. They last 1+n cycles where n is the number of wait-states of the
targeted functional unit.
3. ld/st: These are the load and store instructions that access the memory and
peripherals. They last 1+n cycles where n is the number of wait-states of the targeted
device (1 for the ROM, RAM, and memory mapped registers, 1 + the external
peripheral wait-states). These instructions always last at least two cycles, but the core
is able to handle them in one cycle. The first wait-state is inserted outside the core.
4. Branch: These are all the instructions that cause the Program Counter to point to
another instruction other than the following one (for example, one that breaks the
sequential flow). There are the absolute jumps, the conditional branches, the jump to
the sub-routines, and the return from the sub-routine.
5. Loop,Modified Load or Store: The hardware loop instruction modifies the potential
behavior of any load or store inside the loop (for example, when the LM flag is set).
A jump may be implied after any such load or store if it received an error. The error
causes an early exit of the loop, which means a jump to the instruction that follows
the one that is pointed to by EPC. An additional cycle is required by the PCU to
perform the jump (+1 to the ld/st/ldf/stf original execution delay). Although there is
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3154
NXP Semiconductors

<!-- page 3155 -->

usually an implicit jump after the last instruction of the loop when the PC goes back
to SPC, this is performed at no cycle cost.
6. Done: The done, yield, or yieldge instructions are used to control channel switching.
When no channel switching is performed, these instructions last a single cycle. When
there is a change of channel or context switch, the delay is variable and depends on
many factors (as detailed in Context Switching).
46.4.1.2.2
PCU States
The PCU state is visible through outputs of the SDMA (see Real-Time Debug Outputs)
or the OnCE status register(see OnCE Status Register (OSTAT)).
The PCU state is a four-bit field that can take the values shown in the following table.
Figure 46-4 shows the possible state transitions and the corresponding conditions.
Table 46-3. PCU States
Value
State
Description
0
Program
This is the usual instruction cycle.
1
Data
This state is inserted when there are wait-states during a load or a store on the
data bus (ld/st type).
2
Change of Flow
This is the second cycle of any instruction that breaks the sequence of
instructions (branch and done types). This state lasts only a single cycle; it is
always followed by the Program state.
3
Error in Loop
This state is used when an error causes a hardware loop exit (loop-modified load
or store type). This state only lasts a single cycle; it is always followed by the
Program state.
4
Debug
The SDMA is stopped in debug mode.
5
Functional Unit
This state is inserted when there are wait-states during a load or a store on the
functional units bus (ldf/stf type).
6
Sleep
No script is running: The core is idle after saving the last channel context.
7
Save
The context switch FSM is saving the current channel.
8
Program in Sleep
Same as Program except there is no associated channel, this state is used when
instructions are executed after entering debug mode, whereas the core was in
either Sleep mode.
9
Data in Sleep
This is the same as Data except there is no associated channel.
10
Change of Flow in Sleep
This is the same as Change of Flow except there is no associated channel. This
state only lasts a single cycle, and is always followed by the Program in Sleep
state.
11
Error in Loop in Sleep
This is the same as Error in Loop except there is no associated. channel. This
state only lasts a single cycle, and is always followed by the Program in Sleep
state.
12
Debug in Sleep
This is the same as Debug except the core was put in debug mode when no
channel was active.
13
Functional Unit in Sleep
This is the same as Functional Unit except there is no associated channel.
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3155

<!-- page 3156 -->

Table 46-3. PCU States (continued)
Value
State
Description
14
Sleep after Reset
This shows that no script is running, and the core is idle after a reset. When a
channel becomes active, no context is restored but the core starts its boot
program located at address 0 (or the address available in register in Channel 0
Boot Address (SDMAARM_CHN0ADDR)).
15
Restore
The context switch FSM is restoring the next channel context.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3156
NXP Semiconductors

<!-- page 3157 -->

Data
Error in Loop
Functional Unit
Change of Flow
Program
Save
Restore
Sleep
After Reset
Debug
in Sleep
Sleep
Program
in Sleep
Change of Flow
in Sleep
Functional Unit
in Sleep
Error in Loop
in Sleep
Data
in Sleep
Id/st
loop-modified
error in
Idf/stf
loop-modified
error in
load/store
loop-modified
error in
branch
ack
in Id/st
wait-states
in Idf/stf
wait-states
ack
PC is
Restored
pending
channel(s)
no more
channels
run_core
when coming from
Sleep
pending
channel(s)
debug
request
run_core
when coming from
Sleep after Reset
debug
request
pending
channel(s)
reset
debug
request or
exec_once
completed
exec_once or
exec_core
done
debug
request or
exec_once
completed
debug
request or
exec_once
completed
wait-states
in Idf/stf
ack
branch
debug
request
debug
request
wait-states
in Id/st
error in
loop-modified
load/store
error in
loop-modified
ldf/stf
ack
context
switch
(done)
error in
loop-modified
ld/st
Figure 46-4. PCU State Diagram
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3157

<!-- page 3158 -->

46.4.1.3
SDMA Core Memory
The SDMA has two memory spaces: one for the instructions and one for the data. As
both spaces share the same resources (ROM and RAM devices), the system bus manages
possible conflicts when the core accesses the same resource for both an instruction read
and a data read or write.
Program and data memory is further described in Address Space.
Instructions of 16-bit width are stored in 32-bit wide devices and can be accessed as data.
The mapping is Big Endian: an even instruction address (terminated by 0) accesses the
most significant part of the 32-bit data (bits [31:16]), and an odd instruction address
(terminated by 1) accesses the least significant part of the 32-bit data (bits [15:0]).
Instructions can be fetched out of internal ROM or RAM.
Data can be read from ROM, RAM, memory mapped registers, and external peripherals,
and written to the same devices (except the ROM).
The ROM contains bootload scripts, channel scripts, and common subroutines which may
be referenced by channel scripts elsewhere in the ROM or RAM.
The RAM is divided into a context area and a code space area which may be used to store
channel scripts. The RAM contains undefined values after a hardware reset. Channel
scripts and initial context values are downloaded into RAM using channel 0 which is
reserved for bootload functions.
46.4.2
Scheduler
All channel scheduling hardware is included in the Scheduler.
46.4.2.1
Primary Functions
The scheduler is a hardware-based design used to coordinate the timely execution of 32
virtual DMA channels by the SDMA core on the basis of channel status and priority.
The scheduler performs the following functions:
• Monitors, detects, and registers the occurrence of any one of the 48 DMA requests
• Links a specific request to a channel or group of channels (channel mapping)
• Ignores requests that are not mapped to a previously configured channel
• Maintains a list of all the channels that are requesting service
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3158
NXP Semiconductors

<!-- page 3159 -->

• Assigns a pre-programmed priority level (1 of 7) to every channel requesting service
• Detects and flags overrun/underrun conditions
46.4.2.2
Channels and DMA Requests
46.4.2.2.1
Channels
A Virtual Channel (hereafter simply called a channel) manages a flow of data through the
SDMA. Flows are typically unidirectional.
The SDMA can have up to 32 simultaneously operating channels, numbered from 0 to
31. Channel 0 is usually dedicated to control the SDMA script downloading. All the
channels can be assigned by the Arm platform software.
46.4.2.2.2
DMA Requests
A DMA request is caused by externally (for example, external to the SDMA) controlled
conditions (for example, UART receive FIFO reaches a threshold). The SDMA currently
supports up to 48 DMA requests.
46.4.2.2.3
Mapping from DMA Requests to Channels and Priorities
A channel can stall waiting on a single DMA request. A single DMA request can awake
more than one channel (in fact, any request can awake any combination of channels).
The mapping between DMA requests and channels is program-controlled. There is a
storage element assigned for each of the 48 requests that contains a bitmap table of the
channels that are awakened by the event.
Every channel also has a three-bit register that indicates its priority.
46.4.2.3
Scheduler Functional Description
Scheduler Overview describes the behavior of the SDMA scheduler-from the channel
enabling conditions to the highest priority pending channel selection.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3159

<!-- page 3160 -->

46.4.2.3.1
Scheduler Overview
The scheduler algorithm is built in hardware. It is provided with possibilities for the Arm
platform to control its behavior.
The scheduler processes incoming DMA requests, maps detected requests to 0, one, or
several channels, maintains a list of channels that are requesting service (pending
channels), identifies the top priority and its associated channel, and selects the next active
channel when the current channel yields.
The following figure shows a functional overview.
DMA requests
scanning
DMA request
to pending channel
mapping
Channel overflow
detection
48
6
32
32
CHNERR
Channel Error
48
CHNENBL_47
CHNENBL_46
CHNENBL_0
Channel Enable for DMA request 0
Channel Enable for DMA request 46
Channel Enable for DMA request 47
32
EP
Channel Pending from External DMA Requests
32
Runnable channels
evaluation
32
Next channel
decision tree
32
32
32
32
32
32
EO
HE
HO
CHNPRI31
CHNPRI30
CHNPRI0
External DMA request Override
Arm Platform Channel Enable
Arm Channel Enable Overide
Channel 31 Priority
Channel 30 Priority
Channel 0 Priority
Current Channel
Current Channel
5
Next Channel
PSW
Decision Status
16
5
5
DMA
requests
Figure 46-5. SDMA Hardware Scheduler
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3160
NXP Semiconductors

<!-- page 3161 -->

46.4.2.3.2
DMA Requests Scanning
The scheduler contains a 48-bit edge detection device that detects the rising edge of every
DMA request and transmits the request number to the next stage.
The DMA requests are assumed to be generated on the same reference clock as the
SDMA core clock; they are detected as soon as the signal goes from a 1-to-n-cycles low
state to a 1-to-m-cycles high state.
This system is able to detect single-cycle pulses as well as level-based DMA requests
such as a FIFO threshold crossing. In this case, the SDMA provides a memory mapped
register that can be used by the channel script to monitor the DMA requests lines, and
thus determines whether the data transfer is done or not done, and then continues with the
transfer or closes the channel.
When several DMA requests are detected at the same time, they are forwarded to the next
scheduler stage at the rate of one request per cycle. No request is lost.
SDMA clock
Long Pulse
Level
Short Pulse
Requests are detected here
Figure 46-6. Examples of Valid DMA Requests
The DMA request inputs are connected to various sources that depend on the SoC. The
exact list of DMA request inputs and their associated number is available in each
respective project-specific chapter.
46.4.2.3.3
Mapping DMA Requests to Pending Channels
Whenever a DMA request is detected by the first stage, its number is used in the second
stage to determine the channels that have to be activated.
This is performed with an array of 48 registers that are 32 bits wide: There are 48
Channel Enable Registers (CHNENBLn), one register per DMA request. The DMA
request number selects the Channel Enable Registers, and every bit of this 32-bit register
indicates that the corresponding channel must be activated when it is a 1.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3161

<!-- page 3162 -->

This information is passed on the EP register. For every bit of the Channel Enable
Register that is set, the corresponding bit of the EP register is also set, and the remaining
bits of EP are left unchanged. The transformation of EP is summarized by the following
equation:
EP = EP or CHNENBLn
The EP register is used to know which channels require service because they received a
DMA request.
Typical contents of the CHNENBLn registers are all 0s, except for a single bit set. For
example, a DMA request triggers one channel, but all 0s or several 1s are possible. One
DMA request could activate several channels, and the channel execution sequence can be
controlled by the channel priorities and numbers, as explained in the next sections. The
following table illustrates an example configuration.
NOTE
From the table, the DMA request 0 is programmed to
simultaneously trigger channels 0, 1, and 31. Also, DMA
requests 30-47 are not used in this example. The remaining
channels 2 to 30, are configured to be triggered by DMA
requests 29 to 1, respectively.
Table 46-4. Channel Enable RAM Programming Example
DMA Request Number
Channel
3
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
0
0
0
0
0
0
0
0
0
0
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
0
0
0
0
0
0
0
0
0
0
0
0
0
2
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
0
0
0
0
0
0
0
0
0
0
0
0
3
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
0
0
0
0
0
0
0
0
0
0
0
4
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
0
0
0
0
0
0
0
0
0
0
5
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
0
0
0
0
0
0
0
0
0
6
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
0
0
0
0
0
0
0
0
7
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
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
8
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
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
9
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
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
10 0
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
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3162
NXP Semiconductors

<!-- page 3163 -->

Table 46-4. Channel Enable RAM Programming Example (continued)
DMA Request Number
Channel
3
1
0
11 0
0
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
0
0
0
0
0
0
0
0
0
0
0
0
0
12 0
0
0
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
0
0
0
0
0
0
0
0
0
0
0
0
13 0
0
0
0
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
0
0
0
0
0
0
0
0
0
0
0
14 0
0
0
0
0
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
0
0
0
0
0
0
0
0
0
0
15 0
0
0
0
0
0
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
0
0
0
0
0
0
0
0
0
16 0
0
0
0
0
0
0
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
0
0
0
0
0
0
0
0
17 0
0
0
0
0
0
0
0
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
0
0
0
0
0
0
0
18 0
0
0
0
0
0
0
0
0
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
0
0
0
0
0
0
19 0
0
0
0
0
0
0
0
0
0
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
0
0
0
0
0
20 0
0
0
0
0
0
0
0
0
0
0
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
0
0
0
0
21 0
0
0
0
0
0
0
0
0
0
0
0
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
0
0
0
22 0
0
0
0
0
0
0
0
0
0
0
0
0
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
0
0
23 0
0
0
0
0
0
0
0
0
0
0
0
0
0
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
0
24 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
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
25 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
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
26 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
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
27 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
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
28 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
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
29 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
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
30 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
31 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
32 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
33 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
34 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
35 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
36 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
37 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
38 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
39 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
40 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
41 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
42 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
43 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3163

<!-- page 3164 -->

Table 46-4. Channel Enable RAM Programming Example (continued)
DMA Request Number
Channel
3
1
0
44 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
45 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
46 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
47 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
46.4.2.3.4
Channel Overflow
A channel overflow occurs when a DMA request requires service from channel n by
setting bit n of the register EP, but this bit is already set, meaning channel n is already
pending. This can come from an overrun/underrun condition.
This detection is possible only when the DMA requests are pulses, because a level-based
DMA request stays high until it is serviced, even though an underrun or overrun
condition occurs, thus preventing another edge detection of the DMA request.
The channel overflow information is saved in the 32-bit CHNERR register (1 bit per
channel). You can configure the SDMA to trigger an interrupt to the Arm platform when
there are 1s in CHNERR. Every bit of CHNERR is masked with the corresponding bit of
INTRMASK and if it gives a 1, the corresponding bit of INTR is set, triggering the
interrupt.
46.4.2.3.5
Runnable Channels Evaluation
The EP register is used in conjunction with several other 32-bit registers to determine the
channels that are runnable.
Registers EO, DO, HO and HE, are controlled by the Arm platform. EP is controlled by
the DMA requests and their mapping to channels.
Several channels may be runnable at any given time. The ith channel is runnable if (and
only if) the condition below is true:
(HE[i] or HO[i]) and (DO[i]) and (EP[i] or EO[i])
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3164
NXP Semiconductors

<!-- page 3165 -->

After reset, the HE[i], HO[i], EP[i], and EO[i] bits are all cleared whereas the DO[i] bits
are all set. The functions associated with DO are not available for this device. When
DO[i] is set, the scheduler condition becomes:
(HE[i] or HO[i]) and (EP[i] or EO[i])
The registers in these equations are controlled as follows:
• Arm platform (host) channel enable flag HE[i] may be set or cleared by the Arm
platform with the HSTART and STOP_STAT registers. It can also be cleared by the
ith channel script.
Typical usage is for the Arm platform to set this flag to activate the channel. The flag
is cleared by the SDMA core when the transfer is done.
• Externally triggered channel pending flag EP[i] is set by the scheduler when the
channel was activated by a DMA request. It can be cleared by the ith channel script.
• The Arm platform channel override flag HO[i] may be set or cleared by the Arm
platform. When set, it enables the ith channel to run without the involvement of the
Arm platform.
Typical usage is for the Arm platform to set this flag for channels that do not need
Arm platform supervision such as channels that are controlled by DMA request
events (EP).
• DO should always be set to 1 so that the runnable channel evaluation considers only
HO, HE, EP, and EO.
• Externally triggered channel override flag EO[i] may be set or cleared by the Arm
platform. When set, it prevents the ith channel from stopping and stalling on
incoming peripheral DMA requests. This is the case when the channel is not handling
data transfers with peripherals (for example, a memory to memory transfer).
The SDMA can clear the HE[i], and EP[i] bits by means of a done or notify instruction.
The done instruction causes a reschedule; thus, enabling another channel to preempt the
current one, while the notify instruction does not. The done and notify instructions can
clear either HE[i] or EP[i] (never more than one at a time).
Table 46-5. Runnable Channel Selection Control
Register
Set by
Cleared By
HO
Write to HOSTOVR register
Write to HOSTOVR register
HE
Write to HSTART register
Write to STOP_STAT register or by the channel script
with the done or notify instructions.
DO
Write to DSPOVR register
Write to DSPOVR register
EO
Write to EVTOVER register
Write to EVTOVER register
EP
Set by external DMA request event input.
By the channel script with the done or notify instructions
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3165

<!-- page 3166 -->

46.4.2.3.6
Next Channel Decision Tree
The next channel number is computed from the runnable channels list, the current
channel number, and their respective priorities.
It is re-evaluated every cycle, but is only used when the current channel yields or
terminates by executing a yield, yieldge, or done instruction.
The decision tree is based on the selection of the runnable channel that has the highest
priority.
The highest priority channel is selected according to the following rules:
• Runnable channels are sorted by priority.
• If one of the channels with the highest priority had been preempted by a channel with
a higher priority, but did not want to yield to a channel of the same priority (for
example, it executed a yield, not a yieldge), it is elected as the next channel.
• The channels that belong to the highest priority group are sorted by their number and
the channel that has the highest number in this group becomes the next channel. For
example, if priorities are the same, channel 31 will be selected before channel 30.
When the current channel requires a reschedule with a yield(ge) or a done instruction, the
context switch decision is based on the instruction parameter, the current channel number
and priority, and the next channel number and priority. The possible cases are all listed in
the following table. The grayed cells correspond to unusual cases that should not occur
with a typical usage of the SDMA.
Table 46-6. Channel Switching Decision with a yield, yield(ge), or done
Instruction
Current
Channel
Next Channel
Priorities
Comparison
New Running Channel/Comments
yield (done 0)
Runnable
Not runnable
none
Current
Runnable
Runnable
Current > Next
Current
Current = Next
Current
Current < Next
Next, 1
Not runnable
Not runnable
none
none, 2
(occurs when the channel was disabled by the
Arm platform)
Not runnable
Runnable
none
Next1
(occurs when the channel was disabled by the
Arm platform)
yieldge (done 1)
Runnable
Not runnable
none
Current
Runnable
Runnable
Current > Next
Current
Current = Next
Next1
Current < Next
Next1
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3166
NXP Semiconductors

<!-- page 3167 -->

Table 46-6. Channel Switching Decision with a yield, yield(ge), or done (continued)
Instruction
Current
Channel
Next Channel
Priorities
Comparison
New Running Channel/Comments
Not runnable
Not runnable
none
none2
(occurs when the channel was disabled by the
Arm platform)
Not runnable
Runnable
none
Next1
(occurs when the channel was disabled by the
Arm platform)
done (done>1)
Not runnable
Not runnable
none
none2
Runnable
Not runnable
none
Current3
(occurs when the done instruction does not
disable the channel runnable condition)
Not runnable
Runnable
none
Next1
Runnable
Runnable
none
Current3
(occurs when the done instruction does not
disable the channel runnable condition)
1.
Current channel script execution is stopped, its context is saved; the next channel context is restored and its script
execution resumes
2.
Current channel context is saved and SDMA enters IDLE mode
3.
Current channel context is saved, then restored, and the current channel script resumes execution
Finally, when the SDMA is in IDLE mode and a runnable channel is elected as the next
channel, its context is immediately restored and the script execution resumes.
The combinatorial-decision tree supports dynamic modifications of the EP, EO, HE, HO,
and DO flags as well as dynamic modifications of the channel priorities. The propagation
times are detailed in Scheduler Pipeline Timing Diagram.
The decision tree status is available in the PSW register, which is continuously updated.
It contains the next channel priority, the next channel number, the current channel
priority, and the current channel number. When a priority is read as 0, it means the
channel is not runnable.
A few examples of decisions are presented below:
• Channel 31 is running with priority 5, channels 13 and 24 are pending with the same
priority 5; channel 24 is eligible as the next channel since 24 > 13.
• Channel 31 is running with priority 7, channels 13 and 24 are pending with priority
5; channel 31 is the next channel because its priority is greater than the other pending
channels.
• Channels 7, 23, and 29 are pending with the same priority. Channel 7 is active and
runs a yieldge; it is preempted by channel 29. After a period of time, channel 29 runs
a yieldge, it is then preempted by channel 23 that is the selected channel since
channel 29 is the current channel. Later, channel 23 runs a yieldge and is preempted
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3167

<!-- page 3168 -->

by channel 29. Channels 23 and 29 will go on switching after every yieldge until one
of them terminates. It is only at that point that channel 7 becomes eligible again.
• Channel 11 is running with priority 3, and channel 15 is pending with priority 4.
When the channel 31 script executes a yield instruction, it gets preempted by channel
15; then channels 6 and 18 with priority 3 become pending. Because channel 11 was
preempted after executing a yield and there is no pending channel with a strictly
greater priority, it is eligible as the next channel (although its number 11 < 18).
46.4.2.3.7
Scheduler State Diagram
The Figure 46-7 summarizes the behavior of the SDMA scheduler with details about the
exact mechanism of the priority decision tree. It is important to understand the scheduler
is a hardwired pipeline, which means all the stages are performed simultaneously every
cycle, but a change on any given stage is reflected on the next stage after the delays
presented in Scheduler Pipeline Timing Diagram.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3168
NXP Semiconductors

<!-- page 3169 -->

DMA
request
#n
Mapping to new
pending channels
Repeat 32 times
for every channel #i
Sort channels
per priority
Sort highest priority
channels per number
Next channel =
highest number among
highest priority channels
yield AND
INT (priority(current))>
INT(priority(next))
yieldge AND
priority (current)>
priority (next)
No
No
No
No
Yes
Yes
Yes
Yes
done
is the
current channel active:
priority (current)>0?
Stop the current channel
and save its context
is the next
channel active:
priority (current)>0?
Restore the next channel
context and run it
SDMA core
is in IDLE mode
END
No
Yes
Channel #i
priority(i) = priority(i) + 0.25
Yes
No
Channel #i
was preempted
after a yield?
Channel #i
priority(i) = priority(i) + 0.5
No
Yes
is channel #i the
current channel
Channel #i
priority(i) = CHNPRI(i)
Yes
is channel #i
runnable?
Channel #i
priority(i) = 0
No
No
Evaluate channel #i
runnable condition
Set error for
channel #i
Yes
is channel #i
already
pending?
done
SDMA
ctrl regs
update
AP
ctrl regs
update
Figure 46-7. Scheduler State Diagram
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3169

<!-- page 3170 -->

46.4.2.3.8
Scheduler Pipeline Timing Diagram
The SDMA scheduler process of DMA-request and control-register modifications is not
immediate.
The figure below shows the exact delays of all the tasks. The reference clock is the
SDMA core clock.
SDMA Clock
DMA Request
mapping to EP
control regs update 
(EP, HE, DO, HO)
runnable channels 
decision
next channel
1
2
3
4
5
6
1
2
3
Figure 46-8. Scheduler Timing Diagram
Two numbers can be inferred from this timing diagram. First, it takes six SDMA core
clock cycles to update the next channel from a DMA request. Second, it takes three
SDMA core clock cycles to update the next channel from a direct modification of the
condition registers (EP, DO, HE, or HO) by any processor. The processors that can
modify these bits include SDMA with a done instruction or the Arm platform with a
write access through the corresponding control port on their respective peripheral bus).
46.4.2.3.9
Channel-DMA Request Mapping
The 48 DMA request inputs to the SDMA scheduler are listed in project-specific
chapters. Refer to the respective chapters for this information.
46.4.2.3.10
Examples: How to Start a Channel
A channel can be started when the following equation is true for channel i:
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3170
NXP Semiconductors

<!-- page 3171 -->

(HE[i] or HO[i]) and (DO[i]) and (EP[i] or EO[i])
Once this equation is true, the scheduler can start this channel according to the priority of
all pending channels. Several examples of configuration are listed below:
1. To start a channel triggered by Arm platform software:
• Initially, configure HO[i]=0, DO[i]=1, and EO[i]=1 using registers indicated in
Table 46-5.
• Arm platform software triggers the channel by writing to the HSTART register
to set HE[i]=1, thereby setting the above equation true.
2. To start a channel triggered by DMA request event.
• Initially, configure HO[i]=1, DO[i]=1, and EO[i]=0 using registers indicated in
Table 46-5.
• The DMA request is asserted to trigger the channel by setting EP[i]=1, which
makes the above equation true.
46.4.2.4
Context Switching
On execution of a done or yield(ge) instruction, the current channel may be changed
either because it has finished (which necessarily happens when the done instruction is
executed), or it was preempted by a higher priority channel (which is possible but not
systematic when the yield(ge) is executed).
Upon a channel change the SDMA goes through a context switch procedure.
When the current channel yields or ends, the context for that channel is saved into the
context RAM locations for that channel. When the next channel starts running, its context
is first restored from RAM.
Since context RAM is not yet initialized by reset, there will be no context restore at the
beginning of the first channel (bootload channel) run after reset. It is expected that the
bootload channel will be used to initialize the context for all other channels. When the
bootload channel finishes running or yields, SDMA will enter its SAVE state and save
that channel's context into RAM. Then, if the bootload channel is called again later, the
context will be restored from RAM when the channel starts again.
The context structure for each channel is defined in Context Switching-Programming and
Table 46-11. There will be one context area reserved for each channel. When a channel
ends or yields, the SDMA core registers are automatically saved into the context RAM
and later restored from the context RAM when the channel is next run. The total RAM
space reserved for 32-channel contexts is either 3K or 4K depending on whether the
SMSZ bit is set in the CHN0ADDR register, which enables an additional 8 words of
scratch RAM for each context.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3171

<!-- page 3172 -->

46.4.2.4.1
Context Switch Modes
The exact procedure to save the context of the old channel, and to restore the context of
the new channel depends on the context switch mode selected by the Arm platform in the
CONFIG control register.
The following are the context switch modes:
• By default, the "dynamic" context switch is set. This mode provides the most
efficient context switch for an average of eight cycles to stop the current channel,
save its context, restore the next channel context, and resume its execution. It
consists of saving modified registers of the current channel in the background (for
example, during the channel execution)-which leaves very few registers to save when
the switch is decided-resuming execution of the next channel as soon as possible (for
example, when the minimal set of registers is restored), and continuing the restore
phase during this execution.
• In "dynamic with no loop" mode, the same principle is followed except the modified
registers are only saved in the background when the loop flag is not set. This mode
offers almost the same effectiveness as the previous one, but it prevents the system
from accessing the RAM during loops to save power. This is the recommended mode
for an efficient context-switch when the loop bodies are short.
• In "dynamic power" mode, no background saving is performed, which reduces power
consumption to the minimum. The modified registers are only saved when the
context switch starts. The restore phase is the same as before. This is the mode that
achieves the optimal power consumption at the cost of a slower context-switch.
• In a "static" context switch, all the registers are saved when a context switch is
decided, and all the registers are restored before starting the execution of the new
channel. This mode enables a predictable behavior of the context switch since all the
registers are restored prior to the channel start and all registers are saved after the
channel termination.
NOTE
Static context mode should be used for the first channel called
after reset to ensure that the all context RAM for that channel is
initialized during the context SAVE phase when the channel is
done or yields. Subsequent calls to the same channel or
different channels may use any of the dynamic context modes.
This will ensure that all context locations for the bootload
channel are initialized, and prevent undefined values in context
RAM from being loaded during the context restore if the
channel is re-started later.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3172
NXP Semiconductors

<!-- page 3173 -->

46.4.2.4.2
Context Switch Procedure
The Program Control Unit goes into the save state, the current context is spilled into
memory, and the next channel context is restored according to the context-switch mode
that was selected by the Arm platform.
The context switch procedure is as follows:
1. Load the current context's spill base address.
2. Spill the modified registers of the current channel to memory according to the
selected context switch mode while the channel is running.
On a done or yield(ge) that causes the channel preemption, the PCU goes into the
save state. In static mode, all the registers are saved; whereas, in either dynamic
mode, the registers that were modified but not yet saved are then saved, and the PCU
registers and flags are finally saved.
3. Put the SDMA core into sleep and wait for new channels to be serviced. This step is
skipped if there are pending channels when the current channel is saved.
As soon as there is at least one pending channel, the PCU goes into its restore state to
restore the context of the channel that was elected by the scheduler.
Once a channel is elected, it remains the current channel until its script requests a
rescheduling operation with a done or yield(ge) instruction. That means the current
channel cannot be modified by the Arm platform, even if it is no more runnable or if
its priority is modified.
The Arm platform can however force a reschedule by writing the corresponding bit
in the CONFIG register, which has the same effect as if the script had executed a
done instruction. That feature should only be used to stop the SDMA in emergency
cases.
4. Load the context base-address of the new channel.
In "static" mode, all the registers are restored. In either "dynamic" modes, only the
PCU registers are restored.
The new channel is running. In "static" mode, no more activity regarding context
restoring or saving is performed. In either "dynamic" modes, the registers are
restored in the background every time an access to the context RAM is possible, and
priority is given to restoring the registers that are required by the next instruction to
be executed. When a register has not been restored and the next instruction needs it,
this instruction gets stalled until the register was restored.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3173

<!-- page 3174 -->

In "dynamic" and "dynamic with no loop" modes, background saving of dirty
registers is performed every time an access to the context RAM is possible and
allowed by the context switch mode.
NOTE
The contents of a channel context space in the context
RAM depends on the selected context switch mode. In
"dynamic" and "dynamic with no loop" modes, the contents
of the context RAM tend to match the contents of the
SDMA registers (except for the PCU registers and flags
that are never saved in the background). In "dynamic
power" and "static" modes, the contents of the context
RAM remain unchanged until the channel terminates with a
done or gets preempted.
46.4.2.4.3
Context Map in Memory
Refer to Context Switching-Programming.
46.4.3
Functional Units
The functional units are small systems that are used by the SDMA core to handle data
transfers between the core and a bus domain external to the SDMA.
The SDMA core is able to control and exchange data with these systems by sending
instructions and reading or writing data from/to the functional units' registers via the
FUBUS. This is done with the ldf and stf instructions.
The following sections provide introductions to the available functional units. Functional
Units Programming Model provides descriptions the functional units' behaviors.
46.4.3.1
Burst DMA Unit
The burst DMA unit enables the SDMA core to perform data transfers to and from the
Arm platform memory.
It is optimized for accessing SDRAM-like devices. It does not provide control to assign a
privilege level to the DMA access. The burst DMA unit provides the SDMA with means
to do the following:
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3174
NXP Semiconductors

<!-- page 3175 -->

• Perform up to 8-beat read and write bursts to the Arm platform memory, which
optimizes throughput when accessing SDRAM-type devices because of an internal,
36-byte FIFO
• Access the Arm platform memory at once or twice the SDMA core frequency
• Copy data from one Arm platform memory location to another Arm platform
memory location at the Arm platform bus speed, which provides a very high
throughput
• Control the method for addressing the Arm platform memory (automatic increment
of addresses or frozen addresses-the former aimed at accessing RAM-like memory
and the latter aimed at accessing single-address FIFOs)
• Enable or disable automatic prefetch when reading data from the Arm platform
memory. When the prefetch mode is selected, the burst DMA automatically triggers
external bursts to fill its FIFO without waiting for the SDMA core to request the
corresponding data, greatly improving throughput.
• Rely on the DMA to automatically flush its FIFO content when there is enough data
to generate an 8-beat burst to the Arm platform memory. Or, it forces a flush when a
data transfer must terminate.
• In the former case, the SDMA core may only be stalled when it tries writing data and
there is not enough room left in the FIFO. In the latter case, the core is stalled until
the data is effectively written to the Arm platform memory.
In automatic flush mode, the core receives an acknowledge that does not reflect the
actual error status when the data is effectively written into the Arm platform
memory. This error status is retrieved by a later access to the burst DMA.
Terminating a write data transfer with a forced flush command guarantees that any
bus error to the Arm platform memory is caught.
• Handle address alignment issues between the Arm platform memory map and the
SDMA core data. This enables the core to read or write 32-bit data from the burst
DMA, whereas the corresponding Arm platform address is not 32-bit aligned. This
drastically improves the SDMA scripts' efficiency since the same loop that transfers
32 bits at a time can be used regardless of the start and end addresses in the Arm
platform memory space.
This unit structure and registers are described in Burst DMA Structure and Burst DMA
Registers.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3175

<!-- page 3176 -->

46.4.3.1.1
Burst DMA Structure
The burst DMA is essentially made up of a 36-byte FIFO, address registers, and a
controlling state-machine. The 36-byte FIFO enables eight-word buffering with address
alignment, and the state-machine manages clock adaptation when required.
The burst DMA is depicted in the figure below.
Setup and FSM State (MS)
Source Address (MSA)
Destination Address (MDA)
32
address
Burst DMA
Control
36-byte
FIFO
(MD)
32
read and write
data
32
32
32
FUBUS
DMA interface to AP memory
control
Figure 46-9. Burst DMA Structure
46.4.3.1.2
Burst DMA Registers
There are four registers, as follows, that may be accessed from the SDMA core:
• MSA (Memory Source Address) - Holds the source byte address in the Arm platform
memory map for reading data from this location. This register is automatically
modified every time the core reads new data from the FIFO.
• MDA (Memory Destination Address) - Holds the destination byte address in the Arm
platform memory map for writing data to this location. This register is automatically
modified every time the core writes new data into the FIFO.
• MD (Memory Data) - Labels the 36-byte FIFO access point: Reading a byte,
halfword, or word from MD respectively retrieves the first 1, 2, or 4 bytes of the
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3176
NXP Semiconductors

<!-- page 3177 -->

FIFO (for example, the bytes that were stored first by the DMA state-machine when
transferring data from the Arm platform memory).
• When the FIFO does not hold as many bytes as required by the SDMA core, the core
is stalled until the missing bytes are read from the Arm platform memory. In the case
of prefetch mode, the DMA controller decides when it should start a burst to Arm
platform memory in order to reduce the risk to not have the required data for the
future accesses of the core. When there is no prefetching, a burst is triggered when
the required data is not available in the FIFO.
Writing a byte, halfword, or word to MD stores 1, 2, or 4 bytes, respectively, at the
end of the FIFO (for example, these bytes are transmitted to the Arm platform
memory after all the other bytes that were previously stored in the FIFO). When the
FIFO does not have enough room left to hold the written data, the SDMA core is
stalled until a sufficient amount of FIFO contents are flushed out to the Arm platform
memory. Flushing is decided by the DMA controller when there are enough bytes in
the FIFO to perform the largest allowed burst to Arm platform memory (the exact
size depends on the burst start address and the AHB 1 Kbyte boundary rule).
However, the SDMA core has the ability to force the flushing operation at any time,
for example, when at the end of the data transfer, prior to channel closure.
• MS (Memory Setup) - Contains the state of the burst DMA control, the two flags that
define whether each address register is incremented after every access to the external
memory, and another flag that is set when a bus error occurred.
46.4.3.1.3
Burst DMA Data Transfers
Three typical usages have been identified that involve the burst DMA: the data transfer
startpoint, the endpoint, or both.
Every case requires a different procedure, as listed in the following sections:
46.4.3.1.3.1
Data Retrieval from the Arm platform Memory
The following steps retrieve data from Arm platform memory using the burst DMA unit:
• Set up the MS flags to reflect the mode for the source address (incremented or frozen
according to the type of accessed device: memory or peripheral FIFO), then initialize
the source address register itself (MSA).
• Read data from the FIFO using the ldf MD instruction as many times as needed. If an
error occurred during the fetch from Arm platform memory, the DMA control tags
the error status on the data and the SDMA core SF flag is set when reading this data
from the FIFO.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3177

<!-- page 3178 -->

46.4.3.1.3.2
Storing Data Into the Arm platform Memory
The following steps store data from Arm platform memory using the burst DMA unit:
• Set up the MS flags to reflect the mode for the destination address (incremented or
frozen according to the type of accessed device: memory or peripheral FIFO), then
initialize the destination address register itself (MDA).
• Store data into the FIFO using the stf MD instruction as many times as needed.
• When the transfer is finished and if the DMA worked in automatic flush mode, force
the flush of the FIFO. This instruction is stalled until all the FIFO data is effectively
sent to the Arm platform memory and the error status of the transfer is available in
the DF flag.
46.4.3.1.3.3
Transferring Data Between Two Arm platform Memory Locations-
Burst DMA Unit
The following steps copy data between two Arm platform memory locations using the
burst DMA unit:
• Set up the MS flags to reflect the modes for the source and destination addresses (all
the combinations are possible), then initialize the source address register (MSA) and
the destination address register (MDA). Both addresses must be word-aligned.
• Use as many stf MD instructions with the COPY flag as needed. Every instruction
triggers a burst read of a given number of words from the source address (this
number is provided to the burst DMA via the SDMA core general purpose register,
which is referenced in the stf instruction). Once all the data is loaded into the FIFO,
the DMA empties it with a write burst of the same count to the destination address.
The DMA acknowledges prior to instruction completion, which frees the SDMA core
for other tasks at no delay cost.
• Once the transfer is done, there should be a final access to the burst DMA to check
the error status.
46.4.3.2
Peripheral DMA Unit
The peripheral DMA unit is the second functional unit that connects the SDMA to the
Arm platform memory.
Unlike the burst DMA, it does not support burst transfers and is optimized for accessing
peripherals. It does not provide control to assign a privilege level to the DMA access. Its
feature list comprises the following:
• Access to the Arm platform peripherals or memory at once or twice the SDMA core
frequency
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3178
NXP Semiconductors

<!-- page 3179 -->

• Data copy from one Arm platform memory location to another Arm platform
memory location at memory bus speed, improving throughput
• Control of the method for addressing the Arm platform memory (automatic
increment or decrement of addresses or frozen addresses, the first ones aimed at
accessing RAM-like memory and the last one aimed at accessing single-address
FIFOs)
• Selectable automatic prefetch when reading data from the Arm platform memory. In
prefetch mode, the peripheral DMA automatically fetches another data-without
waiting for the SDMA core to request it-when its data register is empty, which
improves the throughput
• Selectable automatic flush. In this mode, the SDMA core may only be stalled when it
tries writing data and the previous write operation is not finished yet; whereas, in
forced flush mode, the core is stalled until the data is effectively written to the Arm
platform memory.
• In automatic flush mode, the core receives an acknowledge that does not reflect the
actual error status when the data is effectively written into the Arm platform memory
or the peripheral. This error status is retrieved by a later access to the peripheral
DMA. Terminating a write data transfer with a forced flush command guarantees that
any bus error to the Arm platform memory has been caught.
This unit structure and registers are described in Peripheral DMA Structure and
Peripheral DMA Registers.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3179

<!-- page 3180 -->

46.4.3.2.1
Peripheral DMA Structure
The peripheral DMA is made up of a 32-bit data register, two address registers, and a
controlling state-machine. The state-machine manages clock adaptation, when required.
It is shown in the following figure.
Setup and FSM State (PS)
Source Address (PSA)
Destination Address (PDA)
32
address
Peripheral DMA
Control
32
read and write
data
32
32
32
FUBUS
DMA interface to AP memory and peripherals
control
Data Register (PD)
Figure 46-10. Peripheral DMA structure
46.4.3.2.2
Peripheral DMA Registers
According to Figure 46-10, the peripheral DMA has four registers that may be read or
written by the SDMA core:
• PD (Peripheral Data) is the DMA 32-bit data register.
• PSA (Peripheral Source Address) holds the source byte address in the Arm platform
memory map for reading data from this location. This register is automatically
modified every time the core reads a new data from PD.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3180
NXP Semiconductors

<!-- page 3181 -->

• PDA (Peripheral Destination Address) holds the destination byte address in the Arm
platform memory map for writing data to this location. This register is automatically
modified every time the core writes a new data into PD.
• PS (Peripheral Setup) contains the state of the peripheral DMA control, two
configuration fields that define the way address registers are modified after every
data access, two additional configuration fields that define the data size to access the
source and destination devices, and another field that contains the latest transfer error
status.
46.4.3.2.3
Peripheral DMA Data Transfers
There are three typical usages that involve the peripheral DMA, whether it is the data
transfer start-point, endpoint, or both.
Every case requires a different procedure, as described in Data Retrieval from the Arm
platform Memory or Peripheral, Storing Data into the Arm platform Memory or
Peripheral, and Transferring Data Between Two Arm platform Memory Locations-
Peripheral DMA Unit.
46.4.3.2.3.1
Data Retrieval from the Arm platform Memory or Peripheral
The following steps retrieve data from Arm platform memory using the peripheral DMA
unit:
• Set up the PS fields to reflect the mode and data size for the source (incremented,
decremented, or frozen address register; 8-bit, 16-bit, or 32-bit data transfers), then
initialize the source address register itself (PSA) with an address that is aligned to the
programmed data size.
• Read data from PD using the ldf PD instruction as many times as needed. If an error
occurs during the fetch from the Arm platform memory or peripheral, the DMA
control tags the error status on the data and the SDMA core SF flag is set when
reading this data from PD.
46.4.3.2.3.2
Storing Data into the Arm platform Memory or Peripheral
The following steps store data to Arm platform memory using the peripheral DMA unit:
• Set up the PS fields to reflect the mode and data size for the destination
(incremented, decremented, or frozen address register; 8-bit, 16-bit, or 32-bit data
transfers), then initialize the destination address register itself (PDA) with an address
that is aligned to the programmed data size.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3181

<!-- page 3182 -->

• Store data into PD using the stf PD instruction as many times as needed.
• When the transfer is finished and if the peripheral DMA worked in automatic flush
mode, force the flush of PD. This instruction is stalled until PD contents are
effectively sent to the Arm platform memory or peripheral, and the error status of the
transfer is available in the DF flag.
46.4.3.2.3.3
Transferring Data Between Two Arm platform Memory Locations-
Peripheral DMA Unit
The following steps copy data between two Arm platform memory locations using the
peripheral DMA unit:
• Set up the PS fields to reflect the modes and data size for the source and destination
addresses (all the combinations of addressing modes are possible, but both data sizes
must be identical), then initialize the source address register (PSA) and the
destination address register (PDA). Both addresses must be aligned with the
programmed data size.
• Use as many stf PD instructions with the COPY flag as needed. Every instruction
triggers a single read from the source address; a single write of the received data
immediately follows. The DMA acknowledges prior to instruction completion, which
frees the SDMA core for other tasks at no delay cost.
• Once the transfer is done, there should be a final access to the peripheral DMA to
check the error status.
46.4.4
SDMA Security Support
The SDMA provides support to SDMA software to block unauthorized updates to the
scripts in RAM.
SDMA supports the following Security modes:
• Open Mode: has full control to load scripts and context into SDMA RAM. This is the
default mode.
• Locked Mode: The Arm platform loads scripts and channel contexts at startup when
it is still executing known safe software. When finished, it locks the SDMA to
prevent further updates to RAM and selected registers. More details described in
Locked Mode.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3182
NXP Semiconductors

<!-- page 3183 -->

46.4.4.1
Locked Mode
The LOCK bit in the SDMA_LOCK register provides support for SDMA scripts to
freeze RAM contents after the initial bootload routine to prevent future unauthorized
updates to SDMA RAM.
After initial RAM contents are uploaded, Arm platform software can set the LOCK bit to
secure the RAM contents to prevent future updates by an unauthorized. After the LOCK
bit is written with a '1', the SDMA is "locked" until reset.
The LOCK bit can be read in the SDMA's internal memory map in the LOCK register
(see Section SDMA LOCK (SDMAARM_SDMA_LOCK)). SDMA scripts which load
information into RAM can check the value of the LOCK bit to determine if an upload to
RAM is allowed. If not allowed, the script can refuse to allow the request to copy data
into the RAM to continue. The exact use of the LOCK bit in SDMA scripts for security
control will be described in SDMA software documentation (see SDMA Scripts).
While SDMA is locked, attempts to write to the SDMA_LOCK, CHN0ADR,
ILLINSTADDR, and ONCE_ENB registers will be ignored. All registers remain
readable. Writes to other registers are still allowed.
Once the SDMA is locked, the LOCK bit can only be cleared by a reset. A hardware reset
will always clear the LOCK bit. A software reset initiated by writing to the RESET
register will only clear the LOCK bit if the SRESET_LOCK_CLR bit in the
SDMA_LOCK register is set. Since SDMA_LOCK register cannot be updated if SDMA
is locked, the SRESET_LOCK_CLR bit must be configured before setting the LOCK bit.
The SREST_LOCK_CLR bit will also be cleared by resets that clear the LOCK bit.
The SDMA RISC core uses the ILLINST and CHN0ADDR registers as pointers to
determine where to jump to after an illegal instruction or upon boot after a reset. The
LOCK bit prevents updates to these registers to protect against unauthorized changes to
these pointers.
While SDMA is locked, the ONCE_ENB register cannot be written to prevent the OnCE
under Arm platform control from being used to gain access to SDMA internal memory. If
Arm platform control of the OnCE is enabled before setting the LOCK bit, the Arm
platform can use the ONCE for debug purpose after LOCK is set.
46.4.5
OnCE and PCU Debug States
The SDMA has two different debug modes in which the OnCE performs debug
instructions.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3183

<!-- page 3184 -->

Refer to Figure 46-4 for an example of the PCU states in debug. The following are the
two debug states:
• When a channel is running (that is, when CCR and CCPRI are different from 0,
which can be read in the PSW register), SDMA can execute a SoftBkpt instruction
from the channel script or receive a debug request. When either happens, the SDMA
enters its "Classical" Debug state, which is described in OnCE and Real-Time
Debug.
• When a channel is not running, the SDMA can be in Sleep state or in Sleep after
Reset state. If a debug request is sent to the core, it enters its Debug in Sleep state.
This debug mode works similarly to the "Classical" Debug state, except it returns to
the original state (Sleep or Sleep after Reset) when the debug mode is left via the
exec_core instruction of the OnCE. From this Debug in Sleep state, the SDMA can
execute a program whereas no channel is running. If a new debug request is sent to
the core or if a SoftBkpt is executed, it comes back to this Debug in Sleep state.
The OnCE is provided with several instructions that can be executed when the core is in
either debug state. The following table summarizes the behavior of these OnCE debug
instructions. There exists other secondary OnCE instructions that are described in OnCE
and Real-Time Debug.
Table 46-7. SDMA in Debug Mode
Instruction
Debug
Debug in Sleep
exec_once
exec_once <instruction>
SDMA executes the <instruction> and returns to the
Debug state. The Program Counter (PC) is not
incremented. This command must not be used with an
instruction that modifies the PC value.
exec_once <instruction>
SDMA executes the <instruction> and returns to the
Debug in Sleep state. The Program Counter (PC) is
not incremented. This command must not be used
with an instruction that modifies the PC value.
run_core
run_core <instruction>
SDMA executes the <instruction>, leaves the Debug
state and continues executing the channel script from
the position where it stopped. This command must not
be used with an instruction that modifies the PC
value.
run_core <instruction>
SDMA executes the <instruction> and returns to its
Sleep or Sleep after Reset initial state. This command
must not be used with an instruction that modifies the
PC value.
exec_core
exec_core <instruction>
It is similar to run_core except it requires an
instruction that changes the PC value (jump,
branch...): the SDMA jumps to the new PC value,
leaves the Debug state and starts executing
instructions from this new PC value.
exec_core <instruction>
If the previous state was Sleep after Reset, the SDMA
returns to this state, and Chn0Addr value overrides
the PC value.
Otherwise, the SDMA jumps to the new PC value and
starts executing instructions from this new PC.
NOTE
The feature exec_core in Debug in Sleep after Sleep after Reset
was added for the Channel boot (channel 0) to allow the
debugger to return to Sleep after Reset state with a new PC
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3184
NXP Semiconductors

<!-- page 3185 -->

value. The SDMA will be ready to boot at the Chn0Addr
address.
46.4.6
SDMA Clocks and Low Power Modes
The SDMA receives several root clocks from the SoC clock controller block and
performs adaptive clock gating to optimize its power consumption. From a user
standpoint, clock gating and power mode selection are fully automatized inside the
SDMA.
Root clock control is available from the SoC clock controller block.
There are numerous clock sources that are used in the SDMA. They belong to one of two
possible clock domains listed in the following table, and have frequency constraints
within each domain. Clocks are considered asynchronous between domains.
Within the Arm platform/SDMA clock domain, all clocks must come from the same
DPLL. The Arm platform DMA interfaces (peripheral DMA and burst DMA) receive
their clock from the Arm platform DMA clock source whose frequency can be once or
twice the frequency of the SDMA core clock. The DMA interfaces are designed to work
at the Arm platform DMA frequency, but the SDMA core is physically limited to a
maximum 104 MHz frequency. Since this is lower than the maximum Arm platform
DMA frequency, the SDMA core clock is tied to the Arm platform peripheral clock
frequency.
The Arm platform Peripheral Bus Clock source must be an exact sub-frequency of the
SDMA Core clock source (any integer value greater or equal to 1).
Table 46-8. Clocking Scheme
Clock Domain
Source Clock
Comments
Arm platform
SDMA core
(SDMA main core)
Source clock for the core and all its operations; this clock is thus used by most
of the SDMA sub-blocks.
Arm platform DMA
DMA interface for the peripheral DMA and the burst DMA. It is balanced with
the main clock source, and its frequency is either once or twice the main clock
frequency.
Arm platform peripheral Connection to the Arm platform peripheral bus. It is a sub-frequency of the
main clock frequency.
JTAG
TCK
Clock for JTAG access, limited to maximum of 1/8 of the SDMA core clock
frequency.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3185

<!-- page 3186 -->

The JTAG clock is sampled by the SDMA main clock to determine its rising edge. This
simplifies design and clock management, but it also adds a ratio constraint between those
two clocks. It is guaranteed the JTAG interface works properly when the frequency of
TCK is lower than 1/8th of the frequency of the SDMA main clock (which is about 8
MHz when the SDMA core clock frequency is 66 MHz).
46.4.6.1
Clock Gating and Low Power Modes
The SDMA automatically performs power saving without requiring user involvement. It
implements two levels of automatic clock gating.
46.4.6.1.1
Coarse Clock Gating
Every sub-block clock comes from one of the five available sources, and is gated with the
sub-block specific enabling condition.
The following table displays the sub-block clocks and their source. It also indicates the
relationships that may exist between different sub-blocks clock enables.
Table 46-9. Sub-blocks Clocks
Sub-block
Source Clocks
Enabling Condition and Comments
Related Enabling
Conditions
Core
SDMA Main
Core
The core sub-block clock is running when the core is not in one of
its sleep states (Sleep or Sleep after Reset) or there is a pending
channel. Typically, the core sub-block clock is stopped once all the
channels are processed and the core enters its sleep state. A new
pending channel awakes the core sub-block clock.
None
Memories
SDMA Main
Core
The clock activation only occurs during a core access.
Disabled when
Core sub-block
clock is disabled or
no memory access
in progress
Scheduler
SDMA Main
Core
Its clock only runs when scheduling is needed: for example, when
there are pending channels, upon reception of a DMA request, and
anytime the Arm platform modifies the channel running conditions.
None
Arm platform
Control
SDMA Main
Core
&
Arm platform
peripheral
The Arm platform peripheral clock is solely used to determine the
frequency ratio with the SDMA main clock. The control registers'
clock is based on SDMA main clock; it is active when the Arm
platform or the SDMA modifies the contents of one of these
registers.
None
Burst DMA
SDMA Main
Core
&
Arm platform
DMA
The burst DMA has two clocks: The first clock is derived from the
SDMA main core clock and drives registers that are connected to
the FUBUS. The second clock is derived from the Arm platform
DMA clock and drives registers that are connected to the Arm
platform DMA bus outside the SDMA. Both clocks are enabled
Disabled when
Core sub-block
clock is disabled
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3186
NXP Semiconductors

<!-- page 3187 -->

Table 46-9. Sub-blocks Clocks (continued)
Sub-block
Source Clocks
Enabling Condition and Comments
Related Enabling
Conditions
during active phases of data transfers (for example, these clocks
are turned off when the burst DMA is not used by the running
channel script).
Peripheral DMA
SDMA Main
Core
&
Arm platform
DMA
The peripheral DMA has two clocks: The first clock is derived from
SDMA main clock and drives registers that are connected to the
FUBUS. The second clock is derived from the Arm platform DMA
clock and drives registers that are connected to the Arm platform
DMA bus outside the SDMA. Both clocks are enabled during active
phases of data transfers (for example, these clocks are turned off
when the peripheral DMA is not used by the running channel
script).
Disabled when
Core sub-block
clock is disabled
OnCE
SDMA Main
Core
The OnCE clock is derived from main source clock. It is disabled by
default. In order to use the OnCE, its clock must be explicitly turned
on, either by enabling the OnCE access from the Arm platform
peripheral bus (register ONCE_ENB), or by driving the
clk_gating_off input pin high. This is a SDMA input whose driver
depends on the SoC implementation (typically a JTAG controller).
The OnCE also receives the TCK input, which is the JTAG clock. It
does not use it as a functional clock; the TCK input is sampled
instead. Refer to Synchronization Implementation.
When enabled, all
other clocks are
systematically on
(clock gating is off)
46.4.6.1.2
Refined Clock Gating
The SDMA implements a second level of clock gating on a register-per-register basis.
Unlike the first level that covers all the SDMA flip-flops, except the synchronizers (only
five flip-flops are always running), the second level is only available for eligible
registers, which amounts to about 90% of the SDMA flip-flops.
These gated registers are only clocked when the hardware logic detects a new data
loading. This additional gating further reduces dynamic power consumption.
46.4.6.1.3
Low Power Modes and User Control
Power savings are automatically managed by the SDMA hardware without any user
involvement; however, one can distinguish three different power modes: SLEEP, RUN,
and DEBUG.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3187

<!-- page 3188 -->

The following table describes these modes, and shows how to switch from one mode to
another.
Table 46-10. Power Modes
Power
Mode
Sub-blocks
Comments
Core
Mem
ories
Sche
duler
Arm
platf
orm
Cont
rol
Burs
t
DMA
Perip
heral
DMA
OnC
E
SLEEP
off1
off
wait2
wait
off
off
off
Set when the PCU state is either Sleep or Sleep after Reset
and the SDMA is not in DEBUG mode. This is the default
mode after reset.
RUN
on3
wait
wait
wait
wait
wait
off
Set for the other PCU states that are reachable out of debug:
Program, Data, Change of Flow, Error in Loop, Debug,
Functional Unit, Save, or Restore.
DEBUG
on
on
on
on
on
on
on
Set regardless of the PCU state when clock gating is turned
off to use the OnCE features (either clk_gating_off pin high
or ONCE_ENB[0] set).
1.
off: no clock
2.
wait: only clocked when accessed or stimulated
3.
on: clock is always running
It is possible to control the SDMA power mode. The procedures to force the SDMA into
either mode are described in SLEEP Mode.
46.4.6.1.3.1
SLEEP Mode
This is the default mode after reset; therefore, resetting the SDMA forces this mode.
However, the common procedure is as follows:
• Ensure the clk_gating_off pin is low and ONCE_ENB[0] is cleared.
• Disable all channels (via the STOP_STAT control register, and the HO, DO, EO if
necessary).
• Wait for the active channels to complete or force a reschedule via the reschedule bit
in the RESET register.
• The SDMA is in SLEEP mode making it possible to completely shut off its clock
from the chip level clock controller using the procedure described in Stop Mode
Response.
46.4.6.1.3.2
RUN Mode
This is the default mode when a channel is running:
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3188
NXP Semiconductors

<!-- page 3189 -->

• Ensure the clk_gating_off pin is low and ONCE_ENB[0] is cleared.
• Activate at least one channel (via the HSTART control registers, a DMA request,
and/or the HO, DO, EO register bits).
46.4.6.1.3.3
DEBUG Mode
The DEBUG mode must be set when one needs to use the debugging facilities of the
SDMA.
• Ensure the SDMA clocks are running from the CCM.
• Set the clk_gating_off pin high or use the SDMA to set ONCE_ENB[0].
46.4.6.1.4
Stop Mode Response
The SDMA receives a stop request from the chip level clock controller. This request may
be asserted when the chip enters the stop low power mode.
If the SDMA is running when the request is received, then the SDMA will complete all
pending channels before returning to the SLEEP state. The SDMA sends an
acknowledgement to the clock controller when the SLEEP state is entered indicating that
the SDMAs clocks can be turned off.
46.4.6.2
Reset
After reset (either received from the reset block or a software reset required by the Arm
platform), the SDMA is in IDLE mode. It will start its boot code located at address 0
once a channel is activated.
Activating a channel can be done by the Arm platform after programming a positive
priority and setting the channel bit in the EVTPEND register.
There will not be a context RESTORE for the first channel (bootload channel) called
after a reset because the context data in RAM has not been initialized. Static context
mode should be used for the first channel called after reset to ensure that the all context
RAM for that channel is initialized. Subsequent calls to the same channel or different
channels may use any of the dynamic context modes
46.4.7
Software Interface
Appendix A fully describes the SDMA Application Programming Interface (API).
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3189

<!-- page 3190 -->

46.4.8
Initialization Information
This section discusses the following:
• Hardware Reset
• Channel Script Execution
• Initialization and Script Execution Setup Sequence
46.4.8.1
Hardware Reset
After reset, the program RAM, context RAM, data RAM, and RAM containing the
channel enable registers (CHNENBLn) have unpredictable contents.
The active register set is assigned to channel 0 and the PC is initialized to all zeros.
However, since the channel enable register is all zeros, there are no active channels and
the SDMA is halted waiting for the boot channel to start.
The Arm platform will have to setup the SDMA in order to boot it. The CONFIG register
must be initialized to determine the DMA/core clock ratio (1 or 2). Channel Enable
Registers must also be initialized.
To start up the SDMA, the Arm platform first creates some channel control blocks (CCB)
and buffer descriptors (BD) in Arm platform memory for the boot channel (channel 0)
and then initializes the channel 0 pointer register (SDMA_MC0PTR) to the address of the
first control block. Data Structures for Boot Code and Channel Scripts provides an
overview of the data structure for the CCB and BD's. The SDMA_HSTART,
SDMA_HOSTOVR and SDMA_EVTOVR registers are then configured according to
Runnable Channels Evaluation to allow channel 0 to run.
Upon being enabled, the SDMA begins executing the script located at the address
indicated by the Channel 0 Boot Address register (SDMA_CHN0ADDR) in the program
memory. The reset value of SDMA_CHN0ADDR points to the default bootload script in
ROM. This ROM script will read the channel 0 pointer register (SDMA_MC0PTR) to
determine the location of the Channel Control Block (SDMA_CCB) in Arm platform
memory. The script will then begin fetching by DMA the first channel control block
which contains a pointer to the location channel 0 Buffer Descriptor chain which is also
fetched via DMA. If the buffer descriptor contains a valid command, the script interprets
the command in each buffer descriptor and proceeds to implement the command and
move on to the next buffer descriptor control block. The buffer descriptor commands for
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3190
NXP Semiconductors

<!-- page 3191 -->

channel zero are typically set up to load SDMA's program RAM, Data RAM, and initial
values for the channel contexts. Some channel scripts expect particular parameters to be
passed
There are two ways to make the SDMA boot on a user-defined script. The OnCE (either
via its JTAG interface or its Arm platform Control interface) can be used to download
any code in the SDMA RAM and force the SDMA to boot on that code. Also, the
SDMA_CHN0ADDR register in the Arm platform programming model can be modified
to point to user code in RAM which would need to either have been loaded via the ONCE
or default bootload routine (ex before a S/W reset).
46.4.8.2
Channel Script Execution
The execution of an SDMA script depends on both the instructions that make up the
script, the data context upon which it operates, and commands or parameters allowed to
the buffer. All these items must be initialized before the script is allowed to execute.
Each of the 32 channels has a separate context, but may share scripts and locations in
data RAM.
Channels are initialized by the Arm platform by using channel 0 to download any
required scripts and data values and the channels initial context. The context contains all
the initial values of the SDMA core registers. This includes the Program Counter (PC)
which is set to the start of the desired script in SDMA program memory.
The Arm platform selects which trigger conditions that must occur for the channel to start
by configuring the SDMA_CHNENBL, SDMA_HOSTOVR and SDMA_EVTOVR
registers. The trigger events include Arm platform setting HE (SDMA_HSTART) or a
hardware DMA request asserts an event input to SDMA. The channel can become active
according to its priority compared with other runnable channels when the selected
trigger(s) cause the condition described in Runnable Channels Evaluation to evaluate as
true.
The specific parameters to be passed to each script in the buffer descriptor or context are
documented in the software documentation for each script. Please refer to SDMA Scripts
for complete script documentation. Buffer Descriptor Format provides an overview of the
buffer descriptor format.
46.4.8.3
Initialization and Script Execution Setup Sequence
To summarize, the following steps are minimally required to setup SDMA and run
channel scripts.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3191

<!-- page 3192 -->

• Perform Hardware Reset. The program RAM, context RAM, data RAM and
SDMA_CHNENBLn registers have unpredictable contents after this reset.
• Initialize SDMA_CHNENBLn registers to map DMA request events to desired
channels.
• Configure SDMA_CHNPRIn registers to select priority for runnable channels. A
non-zero priority is required for the channel to run.
• Configure the SDMA_CONFIG register to select DMA to SDMA core clock ratio .
• Set up channel control blocks and buffer descriptors in Arm platform to specify the
loading of SDMA program RAM and channel contexts for each SDMA channel to be
used. Reference Data Structures for Boot Code and Channel Scripts.
• Configure SDMA_MC0PTR register with base address of Arm platform Channel
Control Block base address.
• Initialize SDMA_CHNENBLn registers to map DMA request events to associated
channel. Reference Mapping DMA Requests to Pending Channels.
• Configure SDMA_CHNPRIn registers to set priority for each channel to be run.
• For each channel to be run, configure SDMA_HOSTOVR (HO) and
SDMA_EVTOVR (EO) registers to select which events (hardware and/or software
trigger events) must occur for the channel to be runnable. Reference Runnable
Channels Evaluation.
• Set bit 0 of the SDMA_HSTART register to set HE[0] and allow Channel 0 to run
(assumes EO[0] andDO[0] were both set in previous step). This will cause SDMA to
load the program RAM and channel contexts configured previously.
• Wait for Channel 0 to finish running. This is indicated by HI[0]=1 in the
SDMA_SDMA_INTR register, or by optional interrupt to the Arm platform.
• Set the LOCK bit in the SDMA_SDMA_LOCK register to prevent un-authorized
uploads of data to SDMA RAM.
• Additional channel scripts can now be run by enabling the selected software or
hardware trigger event according to Runnable Channels Evaluation.
46.4.9
SDMA Programming Model
This section describes the programming model for the SDMA RISC engine, including its
processor, memory, and internal control registers.
All addresses are related to the internal SDMA memory map, which is completely
different from the Arm platform memory maps. The Arm platform processor has no
access to any hardware resource described, except when those resources are described in
Arm Platform Memory Map and Control Register Summary. .
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3192
NXP Semiconductors

<!-- page 3193 -->

46.4.9.1
State and Registers Per Channel
The SDMA can be seen as a set of 32 identical devices that are able to perform one data
transfer channel each. Only one channel can work at a time, but every channel state is
available at any time.
This chapter lists the components of every channel state.
46.4.9.2
General Purpose Registers
Each channel has eight general purpose registers of 32 bits for use by scripts. General
register 0 has a dedicated function for the loop instruction, but otherwise can be used for
any purpose.
46.4.9.3
Functional Unit State
Each channel context has some state that is part of the functional units.
The specific allocation of this state is part of the functional unit definition that is
described in Burst DMA Unit Programming, Peripheral DMA Unit Programming .
This state must be saved/restored on context switches.
46.4.9.3.1
Program Counter Register (PC)
The PC is 14 bits. Since instructions are 16 bits in width and all memory in the SDMA is
32 bits in width, the low order bit of the PC selects which half of the 32-bit word contains
the current instruction.
A low order bit of zero selects the most significant half of the word.1
46.4.9.3.2
Flags
Each channel has the following four flags:
• The T bit reflects the status of some arithmetic and test instructions. It is set when the
result of an addition or a subtraction is zero and cleared otherwise. It is also the copy
of the tested bits. Finally, it can also be set when the loop counter (GReg0) reaches
zero. When the last instruction of the hardware loop is an operation that can modify
the T flag, its effect on T is discarded and replaced by the GReg0 status.
1.
For example, big-Endian.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3193

<!-- page 3194 -->

• Two additional bits, SF and DF, are used to indicate error conditions resulting from
loading data sources and storing to destinations, respectively. Access errors set these
bits, and successful transactions clear them. They can also be cleared by specific
instructions (CLRF and loop). The source fault (SF) is updated by the loads LD and
LDF; the destination fault (DF) is updated by the stores ST and STF.
• Access errors are caused by several conditions including writing to the ROM, writing
to a read-only memory mapped register, accessing an unmapped address, or any
transfer error received by a peripheral when it is accessed.
The SF and DF flags have a major impact on the behavior of the hardware loop: If
SF or DF is set when starting a hardware loop and it is not masked by the loop
instruction, the loop body will not be executed. Inside the loop body, if a load or
store sets the corresponding SF or DF flag, the loop exits immediately. Testing the
status of the T flag at the end of the loop (as well as testing both SF and DF) tells if
the loop exited abnormally as any anticipated exit prevents GReg0 from reaching the
zero value and thus setting the T flag. This is also valid if the fault occurs at the last
instruction of the last loop.
• The last flag is the loop mode flag, LM, which is composed of two bits. The most
significant bit indicates when the processor is currently operating in loop mode. It is
set by the loop instruction and is cleared after execution of the last instruction of the
last loop. The least significant bit is set when the program counter points to the last
instruction of a loop on the last path. It is used for a channel that is restored with this
configuration to know that the next program counter is EPC. As with the dynamic
context switch Greg0, which indicates when the program must get out of the loop, it
can be restored only on the last instruction of the loop. This, however, is too late to
fetch the next instruction after the loop.
46.4.9.3.3
Return Program Counter (RPC)
The RPC is 14 bits. It is set by the jump to the subroutine instructions and used by the
return from the subroutine instructions.
Instructions are available to transfer its contents to and from a general register.
46.4.9.3.4
Loop Mode Start Program Counter (SPC)
The SPC is 14 bits. It is set by the loop instruction to the location immediately following
it.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3194
NXP Semiconductors

<!-- page 3195 -->

46.4.9.3.5
Loop Mode End Program Counter (EPC)
The EPC is 14 bits. It is set by the loop instruction to the location of the next instruction
after the loop.
46.4.9.4
Context Switching-Programming
Each channel has a separate context consisting of the eight general purpose registers and
additional registers representing the state of the functional units.
The active registers and functional units contain the context of the active channel. The
context of inactive channels is stored in SDMA RAM, which is part of the SDMA
address space.
In a function of the selected context switching mode (Context Switching), modified
registers by the program can be saved in the channel RAM space while the program is
going on. In every cycle, a write access to the RAM is possible.
On a done or yield(ge) instruction, SDMA goes into "real" context switching. In one of
the dynamic modes, modified registers not previously saved, as well as the PC-Loop
registers, are stored into the context area of the channel that will be closed. The new PC-
Loop registers are loaded from the context area of the new channel. All other registers are
restored while the program is executed, giving priority to registers used by the decoded
instruction. Therefore, in the best case, only the PC and Loop registers should be saved
and restored during this context-switching phase, which only requires five SDMA cycles.
In static mode, the context switch stores all registers in the old channel RAM space, and
restores all registers from the new channel RAM space. It requires 26 SDMA cycles.
The address of the context memory for channel i is CONTEXT_BASE + 24*i or
CONTEXT_BASE + 32*i where CONTEXT_BASE equals 0x0800. The table below
presents the layout of a channel context in memory:
Table 46-11. Layout of a Channel Context in Memory for SDMA
OFFSET
31
30
29-16
15
14
13-0
0
SF
-
RPC
T
-
PC
1
LM
EPC
DF
-
SPC
2
GR0
3
GR1
4
GR2
5
GR3
6
GR4
7
GR5
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3195

<!-- page 3196 -->

Table 46-11. Layout of a Channel Context in Memory for SDMA (continued)
8
GR6
9
GR7
10
MDA (burst DMA)
11
MSA (burst DMA)
12
MS (burst DMA)
13
MD (burst DMA)
14
PDA (peripheral DMA)
15
PSA (peripheral DMA)
16
PS (peripheral DMA)
17
PD (peripheral DMA)
18
19
20
Reserved1
21
Reserved1
22
Reserved1
23
Reserved1
24
Scratch RAM (optional)
25
Scratch RAM (optional)
26
Scratch RAM (optional)
27
Scratch RAM (optional)
28
Scratch RAM (optional)
29
Scratch RAM (optional)
30
Scratch RAM (optional)
31
Scratch RAM (optional)
46.4.9.5
Address Space
The SDMA has four internal buses which are listed here.
• The Instruction bus reads instructions from the memory. Its address map is described
in Instruction Memory Map.
• The Data bus (DMBUS) accesses the same memories as those visible on the
Instruction bus, some memory-mapped registers (scheduler status and OnCE
registers), and up to 14 peripherals. Its address map is described in Data Memory
Map.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3196
NXP Semiconductors

<!-- page 3197 -->

• The Functional Units bus (FUBUS) accesses the , Burst DMA, Peripheral DMA .
The addressing mechanism is further detailed in Functional Units Programming
Model.
• The Context Switch bus reads/writes registers into context-switch RAM space. It is a
64-bit bus dedicated for accessing this RAM space for updating the context of the
running channel. While the program is going on, this bus has the lowest priority
compared to the Instruction and Data buses, except for restoring a register needed for
the decoded instruction to be executed. On the save part of a context switch (when
the PCU is in its slave state), this is the only one used. On the restore part, the
Instruction bus has the priority to read the next instruction at the restored PC and
otherwise the Context Switch bus is used. It is not possible to control the actual data
transfers that occur on this bus.
46.4.9.5.1
Instruction Memory Map
The instruction memory map is based on a 14-bit address bus and a 16-bit data
(instruction) bus.
Instructions are fetched from either program ROM or program RAM. An SDMA script is
able to change the contents of the program RAM, which is also visible from the data bus.
The first two instruction locations (at 0 and 1) are special. Location 0 is where the PC is
set on reset. Location 1 is where the PC is set upon the execution of an illegal instruction.
It is expected that both of these locations will contain a jmp to handle routines.
Table 46-12. SDMA Instruction Memory Space
Device
SDMA
Address (Hex)
Base Address Label
Block
Name
WS
Description
ROM
0x0000 ↓
0x07FF
SDMA_IBUS_ROM_ADDR
-
0
4 Kbyte internal ROM with
boot code and standard
routines.
RAM
0x1000 ↓
0x1FFF
SDMA_IBUS_RAM_ADDR
-
0
8 Kbyte internal RAM with
channels context and user
data/routines.
46.4.9.5.2
Data Memory Map
All of the data accessible to SDMA scripts make up the data memory space of the
SDMA.
This address space has several components:
• ROM (also visible on the Instruction bus)
• RAM (also visible on the Instruction bus)
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3197

<!-- page 3198 -->

• Shared Peripherals Registers
• SDMA Internal Registers (scheduler, OnCE, and registers that are also accessible by
the Arm platform)
SDMA scripts can read and write to the context RAM, data RAM, shared peripheral
registers, and internal registers.
The address range is 16 bits and the data width is 32 bits. When accessing peripheral
registers (USB and so on), the data width may be different. The exact address map for the
peripherals depends on the project (as presented in each respective chapter).
Data access is performed with ld and st instructions that take the address from a general
purpose register in the core (GRegn). The mapping between the general purpose register
contents and the address bus is given in the following table:
Table 46-13. GRegn to DMBUS Address Mapping
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
sz
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
address
Grayed bits are simply discarded but they must be cleared to ensure forward-script
compatibility.
• sz (bit 31) indicates the peripheral data width: 0 is used for a 32-bit peripheral and 1
is used for a 16-bit peripheral.
• address (bits 15 down to 0) is the address of the accessed resource (internal memory,
internal register, or shared peripheral).
Table 46-14. SDMA Data Memory Space
Device
SDMA Address (Hex)
Size
Description
ROM
0x0000 → 0x03FF
4 Kbyte
4 Kbyte internal ROM with boot code and standard routines
Reserved
0x0400 → 0x07FF
4 Kbyte
4 Kbyte Reserved
RAM
0x0800 → 0x0FFF
8 Kbyte
8 Kbyte internal RAM with channels contexts and user data/routines
per1
0x1000 → 0x1FFF
16 Kbyte
peripheral 1 memory space (4 Kbyte peripheral's address space)
per2
0x2000 → 0x2FFF
16 Kbyte
peripheral 2 memory space (4 Kbyte peripheral's address space)
per3
0x3000 → 0x3FFF
16 Kbyte
peripheral 3 memory space (4 Kbyte peripheral's address space)
per4
0x4000 → 0x4FFF
16 Kbyte
peripheral 4 memory space (4 Kbyte peripheral's address space)
per5
0x5000 → 0x5FFF
16 Kbyte
peripheral 5 memory space (4 Kbyte peripheral's address space)
per6
0x6000 → 0x6FFF
16 Kbyte
peripheral 6 memory space (4 Kbyte peripheral's address space)
Registers
0x7000 → 0x7FFF
16 Kbyte
Memory mapped registers
per7
0x8000 → 0x8FFF
16 Kbyte
peripheral 7 memory space (4 Kbyte peripheral's address space)
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3198
NXP Semiconductors

<!-- page 3199 -->

Table 46-14. SDMA Data Memory Space (continued)
Device
SDMA Address (Hex)
Size
Description
per8
0x9000 → 0x9FFF
16 Kbyte
peripheral 8 memory space (4 Kbyte peripheral's address space)
per9
0xA000 → 0xAFFF
16 Kbyte
peripheral 9 memory space (4 Kbyte peripheral's address space)
per10
0xB000 → 0xBFFF
16 Kbyte
peripheral 10 memory space (4 Kbyte peripheral's address space)
per11
0xC000 → 0xCFFF
16 Kbyte
peripheral 11 memory space (4 Kbyte peripheral's address space)
per12
0xD000 → 0xDFFF
16 Kbyte
peripheral 12 memory space (4 Kbyte peripheral's address space)
per13
0xE000 → 0xEFFF
16 Kbyte
peripheral 13 memory space (4 Kbyte peripheral's address space)
per14
0xF000 → 0xFFFF
16 Kbyte
peripheral 14 memory space (4 Kbyte peripheral's address space)
46.4.10
SDMA Initialization
Appendix A describes the setup of the SDMA . This section provides a quick description
of several initialization procedures.
NOTE
There may be differences with the actual implementation in the
API.
46.4.10.1
Hardware Reset-SDMA
After reset, the RAM that holds contexts, data, scripts, and the DMA request-channels
matrix has unpredictable content.
The core registers are all reset to 0, including the PC; the PCU state is Sleep after Reset.
No channel can be activated because all of the priorities are also reset to 0.
46.4.10.2
Standard Boot Sequence
The following is the standard boot sequence:
1. Initialize the CONFIG register-detailed in Configuration Register
(SDMAARM_CONFIG)-to determine the Arm platform DMA/core clock ratio (1 or
2)
2. Initialize the DMA request-channels matrix (seeChannel Enable RAM
(SDMAARM_CHNENBLn) ).
3. Program the channel control registers-Channel Event Override
(SDMAARM_EVTOVR), Channel BP Override (SDMAARM_DSPOVR), Channel
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3199

<!-- page 3200 -->

BP Override (SDMA_HOSTOVR), and Channel Event Pending
(SDMAARM_EVTPEND)-according to the channel allocation.
4. Perform any necessary setup as required by the standard boot script in ROM (this is
described in Appendix A).
5. Trigger channel 0 with the Channel Start (SDMAARM_HSTART) register, which
starts the execution of the ROM script starting at address 0. This boot downloads
channel scripts and contexts in RAM.
46.4.10.3
User-Defined Boot Sequence
The following is a user-defined boot sequence:
1. Initialize the Configuration Register (SDMAARM_CONFIG)Channel Enable RAM
(SDMAARM_CHNENBLn), Channel Event Override (SDMAARM_EVTOVR),
Channel BP Override (SDMAARM_DSPOVR), Channel Arm platform Override
(SDMAARM_HOSTOVR), and Channel Event Pending (SDMAARM_EVTPEND).
2. Use the OnCE (either via its JTAG interface or its Arm platform control registers) to
download any code in the SDMA RAM. Accessing the Memory describes how to
write data to the RAM via the OnCE.
3. Use the OnCE instructions to make the PC default value point to the new boot script
start address, or rely on the ROM startup script, which first jumps to the address in
Channel 0 Boot Address (SDMAARM_CHN0ADDR). (This register default address
points to the standard boot script.)
46.4.10.4
Script Loading and Context Initialization
The execution of an SDMA script depends on both the instructions that make up the
script and the data context upon which it operates. Both must be initialized before the
script is allowed to execute.
Each of the 32 channels has a separate data context, but may share scripts and locations
in the data RAM.
The Arm platform manages the space in program RAM and data RAM. It also manages
the assignment of SDMA channels to the device drivers that need them. Channels are
initialized by the Arm platform via the channel 0 boot script. The boot channel
downloads any required scripts with their data and the channels' initial contexts. Every
context contains all the initial values of the registers, including the PC. Then the Arm
platform can enable any channel that becomes active and begins fetching and executing
instructions from its script.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3200
NXP Semiconductors

<!-- page 3201 -->

46.4.11
Instruction Description
The following sections introduce the instruction of the SDMA.
Instruction set details are available in Instruction Set.
46.4.11.1
Scheduling Instructions
The following are scheduling instructions:
• done-The instruction causes certain scheduling or interrupt bits to be set or cleared,
which may cause a change in the schedule-ability of the running channel. Then the
instruction causes the SDMA to evaluate the current scheduling priorities and to
choose the highest priority ready channel. If this channel is not the current channel, a
context switch will take place. If there are no runnable channels, the SDMA will
enter the stopped mode. The done 5 has a special usage reserved for debug, as
explained in Debug Instructions.
• yield-These instructions are special cases of the done instruction. They do not modify
the scheduling bits, but allow the highest pending channel (if it exists) to preempt the
current channel if the pending channel priority is strictly greater than the current
channel priority.
• yieldge-These instructions are special cases of the done instruction. They do not
modify the scheduling bits, but allow the highest pending channel (if it exists) to
preempt the current channel if the pending channel priority is strictly greater or equal
to the current channel priority.
• notify-The notify instruction affects the scheduling bits, but does not cause
rescheduling.
46.4.11.2
Conditional Branch Instructions
The conditional branch instructions of an 8-bit displacement, which is sign-extended and
added to the current PC (which points to the next instruction) if the condition is satisfied.
Otherwise, control passes to the next sequential instruction.
• BF-Branch if False. The branch is taken if the T bit in the processor status is zero
(false).
• BT-Branch if True. The branch is taken if the T bit in the processor status is one
(true).
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3201

<!-- page 3202 -->

• BSF-Branch if Source Fault. The branch is taken if the SF bit in the processor status
is one.
• BDF-Branch if Destination Fault. The branch is taken if the DF bit in the processor
status is one.
46.4.11.3
Unconditional Jump Instructions
There are two varieties of unconditional control transfers: an absolute transfer and a
through-register transfer.
Absolute transfers have a 14-bit address field that replaces the current PC.
• JMP-Jump. Causes the processor to jump to an absolute address encoded in the
instruction itself.
• JSR-Jump to Subroutine. Causes the processor to jump to a subroutine, the address of
which is encoded in the instruction itself.
• JMPR-Jump through Register. Causes the processor to jump to an absolute address
contained in a General register. This instruction is meant to be used when more than
one level of subroutines are required.
• JSRR-Jump to Subroutine through Register. Causes the processor to jump to a
subroutine, the address of which is contained in a General register. This instruction is
meant to be used when more than one level of subroutines are required.
46.4.11.4
Subroutine Return Instructions
The following are subroutine return instructions:
• RET-Return from Subroutine. The RET restores the contents of RPC to PC.
• LDRPC-Load from RPC to Register. THe LDRPC instruction is meant to be used
when more than one level of subroutines are required. It stores the contents of RPC
in any General register.
46.4.11.5
Loop Instruction
The following is a loop instruction:
LOOP-Enters Loop Mode. Before entering loop mode, the loop instruction can optionally
clear the fault flags (SF and/or DF) based on a 2-bit field in the instruction. This feature is
linked to the fact that setting SF or DF in loop mode will cause an immediate exit of the
loop.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3202
NXP Semiconductors

<!-- page 3203 -->

46.4.11.6
Miscellaneous Instructions
The following are miscellaneous instructions:
• CLRF-Clear Fault Flags. This instruction clears any combination of SF and DF.
• MOV r,s-This moves data from GReg[s] to GReg[r].
• LDI r,immediate-This loads GReg[r] with a zero-extended immediate value.
46.4.11.7
Logic Instructions
The following are logic instructions:
• XORr,s-This performs an exclusive or between GReg[r] and GReg[s], and stores the
result in GReg[r].
• XORIr,immediate-This performs an exclusive or between GReg[r] and a zero-
extended immediate value, and stores the result in GReg[r].
• ORr,s-This performs an or between GReg[r] and GReg[s], and stores the result in
GReg[r].
• ORIr,immediate-This performs an or between GReg[r] and a zero-extended
immediate value and, stores the result in GReg[r].
• ANDNr,s-This performs an and between GReg[r] and the negated GReg[s], and
stores the result in GReg[r].
• ANDNIr,immediate-This performs an and between GReg[r] and the negated zero-
extended immediate value, and stores the result in GReg[r].
• ANDr,s-This performs an and between GReg[r] and GReg[s], and stores the result in
GReg[r].
• ANDIr,immediate-This performs an and between GReg[r] and a zero-extended
immediate value, and stores the result in GReg[r].
46.4.11.8
Arithmetic Instructions
Arithmetic instructions modify the T bit in the processor status according to the result of
the operation. The T bit is set if the result is zero, otherwise it is cleared.
• ADD r,s-This performs the addition of GReg[r] and GReg[s], and stores the result in
GReg[r].
• ADDI r,immediate-This performs the addition of GReg[r] and a zero-extended
immediate value, and stores the result in GReg[r].
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3203

<!-- page 3204 -->

• SUB r,s-This performs the subtraction of GReg[s] from GReg[r], and stores the result
in GReg[r].
• SUBIr,immediate-This performs the subtraction of a zero-extended immediate value
from GReg[r], and stores the result in GReg[r].
46.4.11.9
Compare Instructions
Compare instructions modify the T bit in the processor status according to the result of
the operation. The T bit is set if the comparison is true, otherwise it is cleared.
NOTE
Only one version of the immediate form is implemented. Non-
equality comparisons to immediate values will require two
instructions.
• CMPEQ r,s-This sets T when registers GReg[r] and GReg[s] are equal.
• CMPEQIr,immediate-This sets T when register GReg[r] and the zero-extended
immediate value are equal.
• CMPLTr,s-This sets T when register GReg[r] is less than and not equal to GReg[s].
The comparison is signed.
• CMPHS r,s-This sets T when register GReg[r] is greater than or equal to GReg[s].
The comparison is signed.
46.4.11.10
Test Instructions
Test instructions modify the T bit in the processor status according to the result of the
operation. The T bit is set if any bit in the result is one, otherwise it is cleared.
• TSTr,s-This performs an and between GReg[r] and GReg[s], and sets T if the result
is not zero.
• TSTIr,immediate-This performs an and between GReg[r] and a zero-extended
immediate value, and sets T if the result is not zero.
46.4.11.11
Byte Permutation Instructions
These instructions shuffle the bytes in a register. For the purpose of describing these
instructions, have the bytes in a register be numbered from the most significant as b3, b2,
b1, b0.
• RORBr-The rotate right byte. The result is b0, b3, b2, b1.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3204
NXP Semiconductors

<!-- page 3205 -->

• REVBr-The reverse bytes in word. The result is b0, b1, b2, b3.
• REVBLOr-The reverse, two low-order bytes. The result is b3, b2, b0, b1.
46.4.11.12
Bit Shift Instructions
The following are bit shift instructions:
• ROR1r-The rotate right 1 bit. This instruction does a circular right shift of 1 bit.
• LSR1r-The logical shift right 1 bit. This instruction shifts all bits to the right by 1.
The high order bit is replaced by a 0.
• ASR1r-The arithmetic shift right 1 bit. This instruction shifts all bits to the right by 1.
The high order bit is replaced by itself.
• LSL1r-The logical shift left 1 bit. This instruction shifts all bits to the left by 1. The
low order bit is replaced by zero.
46.4.11.13
Bit Manipulation Instructions
• BCLRIr,n-The bit clear is immediate; clears bit number i in register r.
• BSETIr,n-The bit set is immediate; sets bit number i in register r.
• BTSTIr,n-The bit test is immediate; tests bit number i in register r (T becomes equal
to the selected register bit).
46.4.11.14
SDMA Memory Access Instructions
All memory accesses are 32 bits.
Any memory location that is implemented with less than 32 bits (for example, peripheral
registers) causes unimplemented bits to be read as 0s.
All memory accesses will cause either the SF or DF flags in the processor status to be set
if they cause a fault.
What constitutes a fault, especially when accessing peripheral registers, is a property of
the memory location.
• LDr,(b,d)-The load instruction creates an address by adding the displacement field
(d) to the contents of the base register (b). The SDMA location at the resulting
address is read and placed in the destination register (r).
• STr,(b,d)-The store instruction creates an address in the same manner as the load
instruction. The register (r) is stored in the SDMA location at the resulting address.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3205

<!-- page 3206 -->

46.4.11.15
Functional Unit Instructions
The functional unit instructions have an 8-bit field that is placed on the functional unit
bus.
Some of these bits are used to select which functional unit should be involved in the
transfer. The remaining bits are decoded by the selected functional unit so their specific
use depends on the functional unit. See Functional Units Programming Model.
There are two functional unit instructions, as follows:
• LDFr,fub-The 8-bit field is placed on the functional unit bus and a read is issued to
the selected functional unit. As a result of this instruction, the SF may be set in the
processor status.
• STFr,fub-The 8-bit field is placed on the functional unit bus and a write is issued to
the selected functional unit. As a result of this instruction, the DF may be set in the
processor status.
46.4.11.16
Illegal Instructions
All instruction encodings that are illegal cause the following actions:
• The current PC (which points to one beyond the offending instruction) is put in the
EPC register.
• The loop mode bit is cleared.
• The PC is set to the value stored in the Illegal Instruction Trap Address
(SDMAARM_ILLINSTADDR) register (the default value is 0x0001).
ILLEGAL-Although any instruction other than those indicated in the SDMA
specification will trigger the illegal instruction mechanism, the ILLEGAL instruction
code is preferred as it will always be kept as illegal in the possible future versions of the
SDMA core.
46.4.11.17
Debug Instructions
The following are debug instructions:
• SOFTBKPT-The software breakpoint instruction causes the core to stop and enter
debug mode. The core can then be accessed and started by the OnCE debug block
only.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3206
NXP Semiconductors

<!-- page 3207 -->

• done 5-This instruction is used for debugging, as it copies the contents of the PCU
registers and flags to the context memory. Information on this instruction is
described in Saving the Context.
• CpShReg-This instruction copies the context memory into the PCU registers and
flags. Modifying the corresponding memory location before executing this
instruction enables you to have the channel continue from a new instruction address.
This instruction is described in Restoring the Context.
46.4.12
Functional Units Programming Model
The functional unit instructions cause an 8-bit code, found in the low eight bits of the
instruction, to be asserted on the functional unit control bus.
Some of these bits are used to select one of several functional units. Functional units
which can be selected include SDMA registers such as MSA and MSD which are not
mapped in the SDMA memory map, and are accessible only through the functional unit
bus. These Functional Unit Registers are listed in the following table. In order to establish
a programming convention, assume the selection bits are some number of the most
significant bits of the 8-bit code. Furthermore, some number of the least significant bits is
decoded by a given functional unit to establish the type of operation to perform.
Table 46-15. Functional Unit Registers
Functional Unit
Register
Register Name
Section/Page
Burst DMA Unit
Programming
SDMSA
Memory Source Address Register
Memory Source Address
Register (MSA)
MDA
Memory Destination Address Register
Memory Destination
Address Register (MDA)
MD
Memory Data Buffer Register
Memory Data Buffer
Register (MD)
(Write) Burst DMA Write
(stf)
(Read) Burst DMA Read
(ldf)
MS
Memory State Register
State Register (MS)
Peripheral DMA Unit
Programming
PSA
Peripheral Source Address Register
Peripheral Source Address
Register (PSA)
PDA
Peripheral Destination Address Register
Peripheral Destination
Address Register (PDA)
PD
Peripheral Data Buffer Register
Peripheral Data Register
(PD)
(Write) Peripheral DMA
Write (stf)-Write Mode
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3207

<!-- page 3208 -->

Table 46-15. Functional Unit Registers (continued)
Functional Unit
Register
Register Name
Section/Page
(Read) Peripheral DMA
Read (ldf)-Read Mode
PS
Peripheral State Register
Peripheral State Register
(PS)
More information regarding the functional units can be found in Peripheral DMA Unit,
and Burst DMA Unit.
46.4.12.1
Burst DMA Unit Programming
The DMA instructions control the DMA state machine and may cause a DMA cycle on
the associated memory bus.
There are four registers associated with the burst DMA unit: a Memory Source Address
register (MSA), a Memory Destination Address register (MDA), a Memory Data buffer
(MD), and a state register (MS). The burst DMA has two different uses:
• A data transfer between External Memory Interface and SDMA general register
• A data transfer in copy mode where blocks of data are transferred from the source
address to the destination address
46.4.12.1.1
Memory Source Address Register (MSA)
The source address register contains the pointer into EXTMC memory associated with
the next read data transfer. It has byte granularity.
Reading the register with the ldf instruction has no side effects, and gives the address
value in the EXTMC memory of the next data that is read by the SDMA during an ldf
MD instruction.
Writing the source address register has two side effects: If the prefetch bit is set, a DMA
read cycle (8-word read access) is issued with the new address. Any data still located in
the buffer is lost. If there is valid write data in the buffer, it is necessary to force the
DMA to completely flush it out before modifying MSA to guarantee all the data is
effectively written to memory.
The MSA register has two modes of programming:
• Frozen-In frozen mode, the MSA register is not modified after DMA accesses.
• Incremented (default mode)-In incremental mode, MSA is incremented by the
number of bytes transferred during read cycles.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3208
NXP Semiconductors

<!-- page 3209 -->

46.4.12.1.2
Memory Destination Address Register (MDA)
The destination address register contains the pointer into EXTMC memory associated
with the next write data transfer. It has byte granularity.
Reading the MDA register with the ldf instruction has no side effects. It gives the address
value in the EXTMC memory where the next SDMA data (stf r,MD instruction) is stored
when MD FIFO is flushed.
Writing the destination address register has one side effect. Any data still located in the
buffer is lost. If there is valid write data in the buffer, it is necessary to force the DMA to
completely flush it out before modifying MDA to guarantee all the data is effectively
written to memory.
The MDA register has two modes of programming:
• Frozen-In frozen mode, the MDA register is not modified after DMA accesses.
• Incremented (default mode)-The MDA register is incremented by the number of
bytes transferred during write cycles.
46.4.12.1.3
Memory Data Buffer Register (MD)
The data buffer register consists of a bank of 36 bytes that behave like FIFO.
This FIFO stores the eight words received when a read burst is triggered by the DMA
(DMA is in read mode).
The MD register is in write mode after a writing in MDA or after an stf MD instruction.
In that case, a burst write access is automatically triggered when there are more than eight
words in MD. For bandwidth optimization, any transfers between DMA and the EXTMC
controller are based on burst accesses.
An ldf r,MD|SIZE instruction that reads the data buffer may cause a DMA cycle, as
follows:
• If there are less bytes in the FIFO than the size parameter of the instruction. For
instance, if only two bytes are available in MD and a 4-byte read is requested, a burst
read access is executed to complete the two bytes.
• If the prefetch bit is set, and after reading there is enough space in the FIFO to store a
full burst, a burst read access is triggered.
An stf r,MD|SIZE instruction that writes to the data buffer may cause a DMA cycle if the
number of written bytes in MD is higher than 32 (eight words) or if the flush bit is set.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3209

<!-- page 3210 -->

When DMA is used for data transfer between SDMA and EXTMC (reading or writing),
no immediate error is possible because the block manages a data misalignment issue;
therefore, it is allowed to read/write a word to/from a half-word address. However, the
addresses (source or destination) must belong to the EXTMC memory mapping. The only
potential error, in this mode, would be the error sent back by the EXTMC controller
when an access to a super-user page is detected. The whole transfer on the DMA
associated bus will be considered successful when there are no errors seen on the bus
during the transfer. In copy mode, an immediate error could be returned to SDMA as
described in Burst DMA Unit Error Management.
46.4.12.1.4
State Register (MS)
The state register contains the DMA state-machine value. It can be accessed in case of an
error received during a transfer. MS is also accessed to set-up the conditional yielding
feature.
The initialization value of this register is 0 and it consists of the following:
Table 46-16. SDMA_MS Structure
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
0
0
0
0
0
0
0
0
0
spriv
stype
0
0
dpriv
dtype
W
R
0
0
0
0
y
d
e
0
0
n
W
Table 46-17. SDMA_MS Field Descriptions
Field
Description
31-22
Reserved
21
spriv
The spriv value is ignored for this device.
0 = valid value
1 = Reserved
20
stype
Source Mode. Indicates if MSA has to be incremented (or not) during accesses.
0 Frozen-MSA is not modified.
1 Incremented-MSA is incremented by the number of transferred bytes during read access.
19-18
Reserved
17
dpriv
The dpriv value is ignored for this device.
0 = valid value
1 = Reserved
16
Destination Mode. Indicates if MDA has to be incremented (or not) during accesses.
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3210
NXP Semiconductors

<!-- page 3211 -->

Table 46-17. SDMA_MS Field Descriptions
(continued)
Field
Description
dtype
0 Frozen-MDA is not modified.
1 Incremented-MDA is incremented by the number of transferred bytes during write access.
15-12
Reserved
11
y
Conditional Yielding selector. When selected, theyield/yieldge instructions will not switch channels if
the Burst DMA is in Write Mode, and it has less than four bytes in its FIFO. This is aimed at
reducing the number of inefficient FIFO flushes due to context switches.
0 Always yields
1 Yields conditionally (when there are less than four bytes in the FIFO in write mode)
10
d
Access Direction or DMA Mode. DMA is in write mode when data was written into MD by stf MD
instructions, or if a previous DMA cycle on the external bus was a write access. Writing MDA or
MSA changes the DMA mode to the respective value. DMA is in read mode when a previous DMA
cycle was a read access, and DMA stays in read mode when data is read by SDMA with an ldf MD
instruction. Reading MDA or MSA does not change the DMA mode.
0 Read Mode
1 Write Mode
9-8
e
Error. Indicates if the previous access was acknowledged with a bus error.
00 No error was received.
01 reserved
10 Error mode
11 error read burst
7-6
Reserved
5-0
n
Number of bytes in the MD FIFO.
46.4.12.1.5
Burst DMA Write (stf)
When received from a stf instruction, the function code bits are interpreted as follows,
depending on the addressed register:
Table 46-18. STF Code Bits
Register
7
6
5
4
3
2
1
0
MSA
s
p
freeze
r
spriv
MDA
dpriv
MD
f
cpy
sz
MS
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3211

<!-- page 3212 -->

Table 46-19. STF Code Bit Field Descriptions
Field
Description
7-6
s
Functional Unit selector
00 for Burst DMA
5
p (MSA)
Prefetch Flag
0 No prefetch
1 Prefetch required from new MSA
5
f (MD)
Forced Flush Flag
0 Automatic flush
1 FIFO contents are flushed (including the new written data).
4
freeze (MSA/MDA)
Address Freeze Mode
0 Address is normally incremented.
1 Address is frozen.
4
cpy (MD)
Copy Mode selection
0 Write Mode
1 Copy Mode
3-2
r
Register selection
00 MSA
01 MDA
10 MD
11 MS
1-0
sz (MD/MS)
Transfer Size
00 size 0 (no data stored in the FIFO)
01 byte (8 bits)
10 half-word (16 bits)
11 word (32 bits)
0
spriv (MSA)
The spriv value is ignored for this device.
0 = valid value
1 = Reserved
0
dpriv (MDA)
The dpriv value is ignored for this device.
0 = valid value
1 = Reserved
The possible write instructions are listed in the table below (unused bits should always be
cleared).
Table 46-20. Burst DMA STF Instruction List
Binary
Assembly
Comments
00_0_0_00_00
stf r,MSA
Writes content of the SDMA general register (r) to the source address
register. MSA is in incremented mode.
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3212
NXP Semiconductors

<!-- page 3213 -->

Table 46-20. Burst DMA STF Instruction List
(continued)
Binary
Assembly
Comments
00_0_1_00_00
stf r,MSA|FR
Writes content of the SDMA general register (r) to the source address
register. MSA is in frozen mode.
00_1_0_00_00
stf r,MSA|PF
Writes content of the SDMA general register (r) to the source address
register, and starts a read burst access. MSA is in incremented mode.
00_1_1_00_00
stf r,MSA|PF|FR
Writes content of the SDMA general register (r) to the source address
register, and starts a read burst access.
00_0_0_01_00
stf r,MDA
Writes content of the SDMA general register (r) to the destination address
register. MDA is in incremented mode.
00_0_1_01_00
stf r,MDA|FR
Writes content of the SDMA general register (r) to the destination address
register. MDA is in frozen mode.
00_1_0_10_00
stf r,MD|SZ0|FL
No data transfers between the SDMA and MD, but all valid written data of
the MD is flushed to the memory. An acknowledge or error is sent back to
the SDMA core on transfer completion.
00_0_0_10_01
stf r,MD|SZ8
8-bit (byte) transfer to write buffer MD
00_1_0_10_01
stf r,MD|SZ8|FL
8-bit (byte) transfer to write buffer MD and flush after transfer. All valid
written data of the MD is flushed to memory.
00_0_0_10_10
stf r,MD|SZ16
16-bit (half-word) transfer to write buffer MD
00_1_0_10_10
stf r,MD|SZ16|FL
16-bit (half-word) transfer to write buffer MD and flush after transfer. All
valid written data of the MD is flushed to memory.
00_0_0_10_11
stf r,MD|SZ32
32-bit (word) transfer to write buffer MD
00_1_0_10_11
stf r,MD|SZ32|FL
32-bit (word) transfer to write buffer MD and flush after transfer. All valid
written data of MD is flushed to memory.
00_0_1_10_00
stf r,MD|CPY
No data transfer between SDMA and MD but starts a copy transfer whose
length is given by the 4 LSB of r register. (Maximum burst length is eight
words.)
00_0_0_11_11
stf r,MS
32-bit (word) transfer to status register MS
00_0_0_11_00
stf r,MS|SZ0
Clears the error flag (if set). Other MS bits are unchanged; this instruction is
also known as clref MS.
NOTE
When a flush bit is set, the SDMA flushes the FIFO including
the newly written data. An acknowledge is sent to the core
before the flush completes (except if size 0 is used). The goal of
this flush bit is to force a flush, but it is recommended to use it
only when needed (for example, when finishing a row of pixels
during 2D data transfers). Indeed, if this bit is omitted and if
there are more than 32 bytes in the FIFO, a burst write access is
automatically triggered.
Since all the stf r,MD instructions (including the copy mode)
acknowledge the SDMA core before the store is effective
(except if size 0 is used), it is recommended to perform an ldf
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3213

<!-- page 3214 -->

from MS before terminating a channel in order to check the
final error status. (The ldf from MS will stall the core until all
the data was flushed out and the transfer status is known.)
After every stf MD instruction, the MDA is incremented by the
number of bytes that are written in MD, except when it is
programmed in frozen mode.
46.4.12.1.6
Burst DMA Read (ldf)
When received from an ldf instruction, the function code bits are interpreted as follows,
depending on the addressed register:
Table 46-21. LDF Code Bits
Register
7
6
5
4
3
2
1
0
MSA
s
r
MDA
MD
p
sz
MS
Table 46-22. LDF Code Bit Field Descriptions
Field
Description
7-6
s
Functional Unit selector
00 for Burst DMA
5
p (MD)
Prefetch Flag
0 no prefetch
1 automatic prefetch
3-2
r
Register selection
00 MSA
01 MDA
10 MD
11 MS
1-0
sz (MD)
Transfer Size
00 reserved
01 byte (8 bits)
10 half-word (16 bits)
11 word (32 bits)
The table below lists the possible write instructions (unused bits should always be
cleared).
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3214
NXP Semiconductors

<!-- page 3215 -->

Table 46-23. Burst DMA LDF Instruction List
Binary
Assembly
Comments
00_0_0_00_00
ldf r,MSA
Copies the source address register value into an SDMA general register. It
gives the memory address of the next data that will be read with an ldf MD
instruction.
00_0_0_01_00
ldf r,MDA
Copies the destination address register value into an SDMA general
register. It gives the memory address where the next incoming data will be
flushed.
00_0_0_10_01
ldf r,MD|SZ8
8-bit (byte) read
00_1_0_10_01
ldf r,MD|SZ8|PF
8-bit (byte) read. If after this reading and the MD FIFO is empty, a burst
read access at the MSA address is triggered.
00_0_0_10_10
ldf r,MD|SZ16
16-bit (half-word) read
00_1_0_10_10
ldf r,MD|SZ16|PF
16-bit (half-word) read. If after this reading, and the MD FIFO is empty, a
burst read access at the MSA address is triggered.
00_0_0_10_11
ldf r,MD|SZ32
32-bit (word) read
00_1_0_10_11
ldf r,MD|SZ32|PF
32-bit (word) read. If after this reading and the MD FIFO is empty, a burst
read access at the MSA address is triggered.
00_0_0_11_00
ldf r,MS
Copy the status register value into an SDMA general register.
NOTE
Read data is 0-extended before writing in the SDMA general
registers. When reading the MD register, the DMA takes data
from the FIFO if it is available. If part or whole data is not in
the FIFO, an external burst read access is performed to provide
the missing data. The SDMA is stalled as long as the required
read data is not complete.
After every reading, MSA is incremented by the number of read
bytes from MD FIFO, except when MSA is programmed in
frozen mode.
46.4.12.1.7
Prefetch/Flush and Auto-Flush Management-Burst DMA Unit
The prefetch and auto-flush management enables the SDMA RISC machine to go on
while a DMA access is performed.
When the RISC core requires a prefetch (p = 1) to the Burst DMA, it will receive an
immediate transfer acknowledge before the DMA has finished the external access. This
enables the RISC core to do other things like accessing another DMA machine.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3215

<!-- page 3216 -->

The basic principle in prefetch mode is for the DMA to anticipate data reads from the
SDMA RISC engine by fetching external bursts of data as soon as there is enough space
in the DMA FIFO to store it. If ever the RISC engine required data that is not available in
the FIFO, the read acknowledge is delayed until the data is available, but it does not have
to wait until the burst completes.
The auto-flush basic principle is similar: An automatic flush is triggered every time there
are eight words to be written in the FIFO. If the FIFO is full and the RISC engine
requires another write, it is stalled until the burst has started and enough space was freed
in the FIFO to store that new data. This means the SDMA RISC engine does not have to
wait for the completion of a burst to receive its acknowledge and continue its processing.
In particular, an auto-flush is executed when DMA is in write mode and if the following
is true:
• If the FIFO is empty and the first write is to a word-aligned address of any size (ex:
the 2 LSB of MDA[1:0]= 0x0), the auto-flush is triggered immediately after the write
of the 32'nd byte.
• If the FIFO is empty, and if MDA is an odd byte address (1, 3, 5, 7,...) and an stf
MD|SZ8 is executed, the byte is flushed to memory. Once MDA increments to a
word aligned address, the auto-flush will be triggered every 32 bytes.
• If the FIFO is empty, and if MDA is a half-word address (2, 6, 0xA,...) and an stf
MD|SZ16 is executed, the two bytes of the incoming data are flushed to memory.
Once MDA increments to a word aligned address, the auto-flush will be triggered
every 32 bytes.
• If the FIFO is empty, and if MDA is not a word-aligned address (ex 1, 2, 3, 5, 6, 7,
9,...), and an stf MD|SZ32 is executed, the first 1 to 3 bytes will be flushed up to the
next word aligned address. Afterwards, an auto-flush will be triggered each time the
FIFO receives 32-bytes.
• Therefore, if an stf MD|SZ32 is executed with MDA equal to 0x1 and with an empty
MD FIFO, the bytes located at addresses 1, 2, and 3 are flushed, and the byte located
at address 4 remains in MD FIFO. This solves the misalignment issue. Additionally,
the next write instructions (stf) complete the FIFO until it contains eight words; then
a burst write is executed by the DMA to empty the FIFO. Protocol on the external
bus does not support bursts of different data types (byte, half-word, or word).
For example, consider the case where data is written using a byte access, stf MD|
SZ8. The value of MDA during the very first byte write determines when the auto-
flush will occur as follows:
• If MDA=0x0, the flush occurs following the write of byte 32
• If MDA=0x1, the flush occurs following the write of byte 1, byte 3 and byte 35.
• If MDA=0x2, the flush occurs following the write of byte 2 and byte 34.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3216
NXP Semiconductors

<!-- page 3217 -->

• If MDA=0x3, the flush occurs following the write of byte 1 and byte 33.
• If MDA=0x4, the flush occurs following the write of byte 32
The flush command forces the DMA to flush all MD valid bytes to the EXTMC
controller. An acknowledge is sent immediately to the SDMA, and any potential error is
reported on a future access. It is thus essential to conclude a transfer with a last read from
MS, which will stall the core until all data was flushed out and returned to the transfer
status (acknowledge or error).
NOTE
During this kind of auto-flush (which occurs only at the
beginning of a misaligned write transfer) no acknowledge is
sent back to the SDMA, which is stalled until a flush is
completed.
46.4.12.1.8
Data Alignment and Endianness-Burst DMA Unit
46.4.12.1.8.1
Burst DMA in Read Mode
For every read access to MD, the data returned to the SDMA core and the new FIFO state
depends on the MSA status and the access size.
The FIFO is considered as a stack of 36 bytes: Data is fetched externally on a 32-bit bus,
but the valid bytes only are stored in the FIFO and left-aligned (for a transfer of
consecutive words, it is only the first word that may be truncated). The following table
shows the FIFO byte alignment strategy and the corresponding MSA, the returned data,
and the new FIFO state for any access size of an internal read from MD.
Table 46-24. FIFO Read Configuration
Before read
Internal read
access size
Read data
After read
MSA[1:0]
FIFO state
MSA[1:0]
FIFO state
00
x0 x1 x2 x3
y0 y1 y2 y3
z0 z1 z2 z3
and so on...
sz8
00 00 00 x0
01
x1 x2 x3 y0
y1 y2 y3 z0
sz16
00 00 x0 x1
10
x2 x3 y0 y1
y2 y3 z0 z1
sz32
x0 x1 x2 x3
00
y0 y1 y2 y3
z0 z1 z2 z3
01
x1 x2 x3 y0
y1 y2 y3 z0
z1 z2 z3 t0
and so on...
sz8
00 00 00 x1
10
x2 x3 y0 y1
y2 y3 z0 z1
sz16
00 00 x1 x2
11
x3 y0 y1 y2
y3 z0 z1 z2
sz32
x1 x2 x3 y0
01
y1 y2 y3 z0
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3217

<!-- page 3218 -->

Table 46-24. FIFO Read Configuration (continued)
Before read
Internal read
access size
Read data
After read
MSA[1:0]
FIFO state
MSA[1:0]
FIFO state
z1 z2 z3 t0
10
x2 x3 y0 y1
y2 y3 z0 z1
z2 z3 t0 t1
and so on...
sz8
00 00 00 x2
11
x3 y0 y1 y2
y3 z0 z1 z2
sz16
00 00 x2 x3
00
y0 y1 y2 y3
z0 z1 z2 z3
sz32
x2 x3 y0 y1
10
y2 y3 z0 z1
z2 z3 t0 t1
11
x3 y0 y1 y2
y3 z0 z1 z2
z3 t0 t1 t2
and so on...
sz8
00 00 00 x3
00
y0 y1 y2 y3
z0 z1 z2 z3
sz16
00 00 x3 y0
01
y1 y2 y3 z0
z1 z2 z3 t0
sz32
x3 y0 y1 y2
11
y3 z0 z1 z2
z3 t0 t1 t2
46.4.12.1.8.2
Burst DMA in Write Mode
For every write access to the MD, the new FIFO state depends on the MDA status and the
access size.
The FIFO is considered as a stack of 36 bytes: Data is stored in the FIFO according to the
internal access size and the former MDA value. The following table shows the FIFO byte
alignment strategy corresponding to MDA, as well as the new FIFO state for any access
size of an internal write to MD.
Table 46-25. FIFO Write Configuration
Before write
Internal write
access size
Written data
After write
MDA[1:0]
FIFO state
MDA[1:0]
FIFO state
00
tt uu vv ww
?? ?? ?? ??
?? ?? ?? ??
and so on...
sz8
?? ?? ?? x0
01
tt uu vv ww
x0 ?? ?? ??
?? ?? ?? ??
sz16
?? ?? x0 x1
10
tt uu vv ww
x0 x1 ?? ??
?? ?? ?? ??
sz32
x0 x1 x2 x3
00
tt uu vv ww
x0 x1 x2 x3
?? ?? ?? ??
01
tt uu vv ww
sz8
?? ?? ?? x0
10
tt uu vv ww
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3218
NXP Semiconductors

<!-- page 3219 -->

Table 46-25. FIFO Write Configuration (continued)
Before write
Internal write
access size
Written data
After write
MDA[1:0]
FIFO state
MDA[1:0]
FIFO state
xx ?? ?? ??
?? ?? ?? ??
and so on...
xx x0 ?? ??
?? ?? ?? ??
sz16
?? ?? x0 x1
11
tt uu vv ww
xx x0 x1 ??
?? ?? ?? ??
sz32
x0 x1 x2 x3
01
tt uu vv ww
xx x0 x1 x2
x3 ?? ?? ??
10
tt uu vv ww
xx yy ?? ??
?? ?? ?? ??
and so on...
sz8
?? ?? ?? x0
11
tt uu vv ww
xx yy x0 ??
?? ?? ?? ??
sz16
?? ?? x0 x1
00
tt uu vv ww
xx yy x0 x1
?? ?? ?? ??
sz32
x0 x1 x2 x3
10
tt uu vv ww
xx yy x0 x1
x2 x3 ?? ??
11
tt uu vv ww
xx yy zz ??
?? ?? ?? ??
and so on...
sz8
?? ?? ?? x0
00
tt uu vv ww
xx yy zz x0
?? ?? ?? ??
sz16
?? ?? x0 x1
01
tt uu vv ww
xx yy zz x0
x1 ?? ?? ??
sz32
x0 x1 x2 x3
11
tt uu vv ww
xx yy zz x0
x1 x2 x3 ??
NOTE
If the FIFO mode changes from a write to a read mode, all
remaining written bytes in MD are lost but no error is returned.
Typically, this happens if an ldf MD is executed after stf MD
instructions. Before a mode change, it is recommended to force
the flush of a potential remaining byte by a stfMD|SZ0|FL
instruction. In the same way, if a FIFO mode changes from a
read to a write mode, all prefetched data present in the FIFO is
lost and no error is returned.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3219

<!-- page 3220 -->

46.4.12.1.8.3
Endianness-Burst DMA Unit
Big and Little Endian are supported by the Burst DMA, but data is always stored in MD
in Big Endian.
Byte manipulation is performed when data is exchanged with an Burst controller (for
example, during read or write burst accesses).
46.4.12.1.9
Burst DMA Unit Copy Mode
A mechanism is available to perform fast Arm-to-Arm transfers.
Data does not flow through the SDMA core: It is kept in the DMA FIFO. This
mechanism is selected when writing MD with a special option in the instruction code
(copy flag).
It is possible to transfer up to eight words in one SDMA instruction (this does not mean
in one cycle). In this mode, every time an stf MD|CPY is executed, a read burst is
executed and directly followed by a write burst transfer. Burst transfers are limited to
eight words. The size of the transfer (in words)-given by the SDMA general register (4
LSB)-is also limited to eight. The following SDMA code shows how 100 bytes could be
copied from the MSA address to the MDA address. This is sample code only.
Burst DMA copy mode example
          ldi r0,@src
          stf r0,MSA                           // Source address setup
          ldi r1,@dst     
          stf r1,MSA                           // Destination address setup
          ldi r0,0x64                          // data transfer counter
          ldi r1,0x8
MAIN_XFER:
          cmphs r0,r1                          // Is r0 >= 0x8
          bf LAST_XFER                     // If not, jump to last transfer label
          stf r1,MD|CPY                         // Copy 8 words from MSA to MDA address.
          subi r0,0x8                          // Decrement counter
          jmp MAIN_XFER                     // return to main transfer loop
LAST_XFER:
          stf r0,MD|CPY
The main transfer loop is executed 12 times; then r0 equals 4 and the last transfer loop is
run.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3220
NXP Semiconductors

<!-- page 3221 -->

In this mode, an acknowledge is transmitted to the core as soon as the read burst can start;
thus, a first copy instruction returns an immediate acknowledge and subsequent copy
instructions will be acknowledged as soon as the previous copy has finished.
46.4.12.1.10
Burst DMA Unit Error Management
Another point to consider is the management of errors.
Because the DMA immediately sends an acknowledge to the RISC core (except for the
stf MS|SZ0|FLS instruction), it assumes no error will occur. If an error occurs, it is
flagged (transfer error acknowledge) for the following DMA access.
This should not be a problem if the DMA is used properly. The MD accesses are meant to
stall the SDMA as little as possible to optimize throughput and hide calculation time.
Therefore, final access to MS should be performed before closing a channel. This access
waits until any pending operation is finished in the burst DMA and gather any remaining
error.
In copy mode, an error could be immediately returned to the SDMA on execution of the
ldf copy or stf copy instruction. It happens when MSA or MDA are not word addresses
(for example, 0[4]). This is because copy mode must only be used for transferring a large
packet of aligned data.
When an error is received during a read transfer to the external bus, which may occur
during the burst accesses, the MD FIFO contains the valid beats of the burst, and the error
flag of MS is set to 2'b11 (error read burst). It is possible to read MS ("n" field) to know
how much valid data remains in MD and when MD is empty (after ldf instructions). The
next read MD instruction sets the MS error flag to 2'b10 (error mode), and an error is sent
back to the SDMA core. In error mode, it is possible to read MSA, which gives the
address of the error data. Any attempt to read or write MD, or to modify MDA or MSA in
error mode, gives rise to an error; therefore, an error flag must be reset by clearing MS at
the end of the SDMA code section responsible for error management.
In "error read burst" mode, writing MDA, MSA, or MD, or starting a copy transfer by a
stf MD|COPY instruction will cancel the error mode. The following table shows when an
immediate error is sent back according to the executed instruction.
Table 46-26. Possibilities in ERROR READ BURST Mode
DMA Instruction
Immediate Error
Comments
stf rn, MD stf rn, MSA (|U |PF) stf rn,
MDA
stf rn,MD|COPY
NO
Error mode is reset. MSA, MDA, or MD are updated and a
DMA cycle may start. For the stf MD|COPY, a copy loop is
executed.
stf rn, MS
NO
MS is updated.
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3221

<!-- page 3222 -->

Table 46-26. Possibilities in ERROR READ BURST Mode
(continued)
DMA Instruction
Immediate Error
Comments
ldf rn, MS ldf rn, MSA ldf rn, MDA
NO
MS, MSA, and MDA could be read in ERROR READ mode
without any side effects (for example, no DMA cycle is
triggered).
ldf rn, MD
YES/NO
Immediate error if there is no more data available for read in
the FIFO.
When an error is received during a write transfer, the error is reported to the next DMA
access. In this case, an error is sent to the SDMA core and the DMA goes to its error
mode. Reading MS gives the number of bytes that remain in MD; reading MDA gives the
address of the error data. Any attempt to read or write MD, or to modify MDA or MSA in
error mode, give rise to an error; therefore, an error flag must be reset by clearing MS at
the end of the SDMA code section responsible for error management.
Table 46-27. Possibilities in ERROR Mode
DMA Instruction
Immediate Error
Comments
stf rn, MD stf rn, MSA stf rn, MDA
Yes
Any attempt to modify MD, MSA, MDA will raise an
immediate error and burst DMA remains in error mode. When
address registers are write-accessed, an error is returned.
stf rn, MS
No
This is the only way to exit error mode. MS[9:8] must be reset
by an stf MS|SZ0 instruction.
ldf rn, MS ldf rn, MSA ldf rn, MDA
No
MS, MSA, and MDA could be read in error mode without any
side effects (for example, no DMA cycle is triggered).
ldf rn, MD
Yes
Whatever the DMA direction (read or write), an ldf rn triggers
an immediate error.
46.4.12.1.11
Conditional Yielding-Burst DMA Unit
The standard SDMA transfer is based upon a hardware loop that has the following
structure:
Hardware Loop
          loop
          load Rn,source            // can be ldf or ld
          <computation>            // can be done through functional units
          store Rn,dest              // can be st or stf
          done 0               // yield
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3222
NXP Semiconductors

<!-- page 3223 -->

This structure needs to be kept independent of the functional units' particularities
regarding the context switch. However, there can be variations in the context switch's
efficiency, which can depend on the number of data received up to that point, and on the
data itself.
The DMA, with its 8-word burst capability, has a preferable context switch period when
its address register is 8-word aligned: It is the only moment that occurs once every eight
loops when the succession of bursts is not broken by the context switch. When this is not
the case, a context switch requires the storing (or loading) of less than eight words, which
requires separate accesses and is far less efficient. The rest of the 8-word packet is stored
(or loaded) after the context restore, and this is done as separate accesses.
The proposed solution is a conditional yielding, which occurs only when the DMA is in
an optimum state. It does not require any modification to the scripts. The condition is
decided at the DMA level.
The DMA can be programmed in two modes-conditional or always-true-for every
channel, which provides complete flexibility. By default, the DMA is not in conditional
mode.
The DMA condition is computed from the FIFO fill level and the various modes, as
follows:
• When copy mode is selected, regardless of the transfer direction ('read' or 'write'), the
condition is always true.
• In read mode, the condition is always true.
• In write mode, the condition is true when there are four bytes or less in the FIFO; it is
false when there are more than four bytes. The 4-byte limit comes from the
possibility of saving those bytes as MD with absolutely no impact on the bus
accesses.
The aim at conditional yielding is to avoid splitting bus accesses (especially bursts).
46.4.12.2
Peripheral DMA Unit Programming
The peripheral DMA unit is connected to the Multi-Layer DMA Crossbar Switch of the
Arm platform.
Its goal is to perform data transfers between any blocks connected to the DMA bus of this
platform. These blocks are either peripherals or memories. The peripheral DMA could be
seen as the Arm platform DMA controller.
The DMA performs data transfers in three modes:
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3223

<!-- page 3224 -->

• Read mode, where data is read from peripherals or from memory connected to the
Arm platform and copied in a SDMA general register.
• Write mode, where data of a general register has to be written in a peripheral or a
memory.
• Copy mode, where data is read from a peripheral (or memory) at a source address
(PSA) and automatically written to a peripheral (or memory) at a destination address
(PDA).
In copy mode, no SDMA general register is involved as transferred data only goes
through the data register of the DMA.
The peripheral DMA has three addressing modes: frozen, incremented, and decremented,
as follows:
• Frozen mode-When source or destination addresses are frozen, their value is not
modified after a transfer. This mode is typically used for addressing peripheral FIFOs
located at a fixed address.
• Incremented mode-When source or destination addresses are in incremented mode,
after every transfer they are incremented by the number of bytes transferred.
• Decremented mode-In decremented mode, addresses are decremented by the number
of bytes transferred.
The peripheral DMA registers are as follows:
• Two, 32-bit address registers (PSA and PDA) that respectively contain the source
address for a read access and the destination address for a write access
• A 32-bit status register (PS) that contains information on the peripheral DMA
configuration, such as the number of valid bytes in the data register, the error flag,
the source and destination address mode, and so on.
• A 32-bit data register (PD) that stores data involved in a data transfer
46.4.12.2.1
Peripheral Source Address Register (PSA)
The source address register contains a pointer to a source peripheral or a memory
associated with the next read data transfer. It has byte granularity.
It is based on the following:
• A 32-bit register (PSA) to store the address value
• A 2-bit register (stype) to store the source address mode (frozen, incremented, or
decremented)
• A 2-bit register (ssize) to store the source target data path size (byte, half-word, or
word)
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3224
NXP Semiconductors

<!-- page 3225 -->

Reading the register with the ldf instruction has no side effects and gives the address
value of the next data that will be read by the SDMA during an ldf MD instruction.
Writing the source address register may have side effects. If there is valid write data in
the data register and the source address is changed, the write data is discarded. If the
prefetch bit is set, a DMA read cycle is issued with the new address.
When PSA is to be written, you must specify the source target address mode, providing
its size (byte, half-word, or word). This enables omission of the size field in all ldf MD
instructions. When DMA performs a read cycle, its size is given by the value of the PSA
source size register (ssize). If source is a memory in incremented mode, first programmed
in word mode (stf PSA|SZ32|I), and if an SDMA script needs to read bytes from this
memory, the size of the source target must be updated before executing new accesses.
The source address mode and its size are given by labels added to the stf PSA instruction
as described in the write section. The ssize and stype registers are part of the DMA status
register (PS).
Writing to PSA may issue an immediate error if the source size is not compatible with the
value to be written into the PSA register. For instance, writing a 2 in PSA and specifying
that it is memory-accessed in word mode creates an immediate error.
46.4.12.2.2
Peripheral Destination Address Register (PDA)
The destination address register contains a pointer to a source peripheral or a memory
associated with the next write data transfer. It has byte granularity.
It is based on the following:
• A 32-bit register (PDA) to store the address value
• A 2-bit register (dtype) to store the destination address mode (frozen, incremented, or
decremented)
• A 2-bit register (dsize) to store the destination target data path size (byte, half-word,
or word)
Reading the register with the ldf instruction has no side effects, and gives the address
value of the next data that will be written by SDMA during an stfMD instruction. Writing
the destination register has no side effect. Similar to the PSA register, the destination
address mode and source are specified in the stf PDA instruction and may also generate
an error in case of incorrect programming.
46.4.12.2.3
Peripheral Data Register (PD)
The data register of the peripheral DMA is a 32-bit register. When the destination address
is correctly set up, any writing to PD will automatically flush the new input data.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3225

<!-- page 3226 -->

The number of SDMA bytes that will be transferred is given by the PDA size register.
Unlike other SDMA DMAs, PD is not a FIFO: It is not used to accumulate bytes that
from the SDMA and must be packed before being sent to external memories. In read
mode, and if the source address is correctly set up, an ldf instruction will empty PD. If a
prefetch is required along with the instruction, the DMA will initiate a new read transfer.
Reading PD in prefetch mode only stalls the SDMA when the prefetched data is not yet
available. Writing PD only stalls the SDMA if the previous write operation was not
completed. As soon as the previous operation is over, the acknowledge is sent back to the
SDMA RISC engine.
An error flag-part of PS-is set when an external access fails. The error is thus reported to
the next SDMA instruction that involves the peripheral DMA.
46.4.12.2.4
Peripheral State Register (PS)
The state register contains the DMA state-machine value. It can be accessed in case of an
error received during a transfer.
Although all PS fields can be written by an stf instruction, it is recommended to access
only the error bit (to reset it). Modifying other PS fields will provide an un-guaranteed
DMA behavior.
The initialization value of PS is 0, and it consists of the following structure:
Table 46-28. PS Structure
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
R 0
0
0
0
0
0
0
0
ssize
stype
dsize
dtype
W
R 0
0
0
0
0
d
e
0
0
0
0
0
n
W
Table 46-29. PS Field Descriptions
Field
Description
31-24
Reserved
23-22
ssize
Source Target Size. Determines the size of the read transfers on the external bus. It should
match the accessed device characteristics.
00 reserved
01 Byte (8 bits)
10 half-word (16 bits)
11 word (32 bits)
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3226
NXP Semiconductors

<!-- page 3227 -->

Table 46-29. PS Field Descriptions (continued)
Field
Description
21-20
stype
Source address Mode. Determines whether PSA is incremented, decremented, or kept
unmodified after every read from the external bus.
00 Frozen Mode
01 Incremented Mode
10 Decremented Mode
11 reserved
19-18
dsize
Destination Target Size. Determines the size of the write transfers on the external bus. It should
match the accessed device characteristics.
00 reserved
01 Byte (8 bits)
10 half-word (16 bits)
11 word (32 bits)
17-16
dtype
Destination address Mode. Determines whether PDA is incremented, decremented, or kept
unmodified after every write on the external bus.
00 Frozen Mode
01 Incremented Mode
10 Decremented Mode
11 reserved
15-11
Reserved
10
d
Direction Flag or DMA Mode. DMA is in write mode when data was written into PD by stf PD
instructions, or if a previous DMA cycle on the external bus was a write access. Writing PDA or
PSA does not change the DMA mode.
DMA is in read mode when a previous DMA cycle was a read access, and DMA stays in read
mode when data is read by the SDMA with an ldf PD instruction. Reading PDA or PSA does not
change the DMA mode.
0 Read Mode
1 Write Mode
9-8
e
Error. Indicates if the previous access was acknowledged with a bus error.
00 No error was received.
01 reserved
10 Error mode
11 Error read
7-3
Reserved
2-0
n
number of bytes in PD
NOTE
dtype, dsize, stype, and ssize are updated when PSA and PDA
are written.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3227

<!-- page 3228 -->

46.4.12.2.5
Peripheral DMA Write (stf)-Write Mode
When written by an stf instruction, the function code bits are interpreted as follows:
Table 46-30. STF Code Bits
Register
7
6
5
4
3
2
1
0
PSA
s
p
ar
am
sz
PDA
PD
pdsel
PS
pssel
Table 46-31. STF Code Bits Field Descriptions
Field
Description
7-6
s
Functional Unit selector
11 for Peripheral DMA
5
p (PSA)
Prefetch Flag
0 no prefetch
1 automatic prefetch
4
ar (PSA/PDA)
Address Register Selector
0 PSA
1 PDA
3-2
am (PSA/PDA)
Address Mode. Determines how PSA or PDA is modified after every read or write access to the
PD.
00 Frozen-Address registers are not modified after the transfer.
01 Incremented-Address registers are incremented by the number of transferred bytes.
10 Decremented-Address registers are decremented by the number of transferred bytes.
11 Updated-PSA and PDA are not modified. Either address mode is not modified, but the width
of the data path is updated by the sz field.
1-0
sz
Transfer Size
00 reserved
01 byte (8 bits)
10 half-word (16 bits)
11 word (32 bits)
5-0
pdsel
PD access selector
001000 is the only valid option
5-0
pssel
PS access selector
111111 writes to PS
001100 only clears the error flag in PS
Due to the large number of possible stf instructions, the following table provides only a
short list of all the possible write instructions:
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3228
NXP Semiconductors

<!-- page 3229 -->

Table 46-32. Peripheral DMA STF Instruction List
Binary
Assembly
Comments
11_00_00_01
11_00_00_10
11_00_00_11
stf Rn, PSA|SZ8 |F
stf Rn, PSA|SZ16|F
stf Rn, PSA|SZ32|F
• Source is a byte, half-word, or word target at the Rn address. Any
further PD read instructions will trigger a byte, half-word, or word
access to the source.
• Source address is frozen.
11_10_00_01
11_10_00_10
11_10_00_11
stf Rn,PSA|SZ8 |F|PF stf
Rn,PSA |SZ16|F|PF
stf Rn,PSA |SZ32|F|PF
• Source is a byte, half-word, or word target at the Rn address. Any
further PD read instructions will trigger a byte, half-word, or word
access to the source.
• 1, 2, or 4 bytes are fetched from the peripheral source.
• Source address is frozen.
11_00_01_01
11_00_01_10
11_00_01_11
stf Rn, PSA|SZ8 |I stf Rn,
PSA|SZ16|I stf Rn, PSA|
SZ32|I
• Source is a byte, half-word, or word target at the Rn address. Any
further PD read instructions will trigger a byte, half-word, or word
access to the source.
• Source address is in incremented mode: PSA = PSA + 1,2 or 4
after read PD.
11_10_01_01
11_10_01_10
11_10_01_11
stf Rn, PSA|SZ8 |I|PF stf
Rn, PSA|SZ16|I|PF stf Rn,
PSA|SZ32|I|PF
• Source is a byte, half-word, or word target at the Rn address. Any
further PD read instructions will trigger a byte, half-word, or word
access to the source.
• Source address is in incremented mode: PSA = PSA + 1, 2, or 4
after read PD.
• 1, 2, or 4 bytes are fetched from the peripheral source.
11_00_10_01
11_00_10_10
11_00_10_11
stf Rn, PSA|SZ8 |D
stf Rn, PSA|SZ16|D
stf Rn, PSA|SZ32|D
• Source is a byte, half-word, or word target at the Rn address. Any
further PD read instructions will trigger a byte, half-word, or word
access to the source.
• Source address is in incremented mode: PSA = PSA-1,2, or 4 after
read PD.
11_10_10_01
11_10_10_10
11_10_10_11
stf Rn, PSA|SZ8 |D|PF
stf Rn, PSA|SZ16|D|PF
stf Rn, PSA|SZ32|D|PF
• Source is a byte, half-word, or word target at the Rn address. Any
further PD read instructions will trigger a byte, half-word, or word
access to the source.
• Source address is in incremented mode: PSA = PSA-1,2, or 4 after
read PD.
• 1, 2, or 4 bytes are fetched from the peripheral source.
11_00_11_01
11_00_11_10
11_00_11_11
stf Rn, PSA|SZ8 |U stf Rn,
PSA|SZ16 |U stf Rn, PSA|
SZ32 |U
• Update source pointer to memory, which becomes a pointer to a
memory accessed in byte, half-word, or word.
• PSA value is not modified by Rn.
• Bytes present in PD are lost.
11_10_11_01
11_10_11_10
11_10_11_11
stf Rn, PSA|SZ8 |PF|U stf
Rn, PSA|SZ16 |PF|U
stf Rn, PSA|SZ32 |PF|U
• Update source pointer, which becomes a pointer to a target
accessed in byte, half-word, or word.
• PSA value is not modified by Rn.
• Bytes present in PD are lost.
• 1, 2, or 4 bytes are fetched from the memory source.
11_01_00_01
11_01_00_10
11_01_00_11
stf Rn, PDA|SZ8 |F
stf Rn, PDA|SZ16|F
stf Rn, PDA|SZ32|F
• Destination is a byte, half-word, or word target at the Rn address,
and any further PD write instructions will trigger byte, half-word, or
word access to the destination.
• Destination address is frozen.
11_01_01_01
11_01_01_10
11_01_01_11
stf Rn, PDA|SZ8 |I stf Rn,
PDA|SZ16|I stf Rn, PDA|
SZ32|I
• Destination is a byte, half-word, or word target at the Rn address,
and any further PD write instructions will trigger byte, half-word, or
word access to the destination.
• Destination address is in incremented mode: PDA = PDA + 1, 2, or
4 after write PD.
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3229

<!-- page 3230 -->

Table 46-32. Peripheral DMA STF Instruction List (continued)
Binary
Assembly
Comments
11_01_10_01
11_01_10_10
11_01_10_11
stf Rn, PDA|SZ8 |D
stf Rn, PDA|SZ16|D
stf Rn, PDA|SZ32|D
• Destination is a byte, half-word, or word target at the Rn address,
and any further PD write instructions will trigger byte, half-word, or
word access to the destination.
• Destination address is in incremented mode: PDA = PDA-1, 2, or 4
after write PD.
11_01_11_01
11_01_11_10
11_01_11_11
stf Rn, PDA|SZ8 |U stf Rn,
PDA|SZ16 |U stf Rn, PDA|
SZ32 |U
• Update destination pointer to memory, which becomes a pointer to
a memory accessed in byte, half-word, or word.
• PDA value is not modified by Rn
• bytes present in PD are lost
11_00_10_00
stf Rn, PD
• Write "dsize" bytes of Rn in PD and automatically flush to
destination target
11_11_11_11
stf Rn, PS
• Write status register
11_00_11_00
stf Rn,clrefPS
• Clear error flag if set
NOTE
When writing PD, size information is not important: It is
embedded in the dsize field of PDA register. If dsize is 1, 2, or
4, then one, two, or four bytes from Rn is written to the PD
register, and automatically flushed out to the destination target.
46.4.12.2.6
Peripheral DMA Read (ldf)-Read Mode
When received from an ldf instruction, the function code bits are interpreted as follows.
Table 46-33. LDF Code Bits
Register
7
6
5
4
3
2
1
0
PSA
s
ar
a
PDA
PD
p
cpy
PS
pssel
Table 46-34. LDF Code Bits Descriptions
Field
Description
7-6
s
Functional Unit selector
11 for Peripheral DMA
5
p (PD)
Prefetch Flag
0 no prefetch
1 automatic prefetch
4
ar (PSA/PDA)
Address Register Selector
0 PSA
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3230
NXP Semiconductors

<!-- page 3231 -->

Table 46-34. LDF Code Bits Descriptions (continued)
Field
Description
1 PDA
4
cpy (PD)
Copy Mode
0 standard access
1 copy mode access
3
a
Register Set selection
0 PSA or PDA
1 PD or PS
5-0
pssel
PS access selector
111111 is the only valid option to read PS
Table 46-35. Peripheral DMA LDF Instruction List
Binary
Assembly
Comments
11_0_0_0_000
ldf Rn, PSA
Reads 32-bit of PSA value
11_0_1_0_000
ldf Rn, PDA
Reads 32-bit of PDA value
11_0_0_1_000
ldf Rn, PD
Reads programmed source size bytes of PD (0-extended)
11_1_0_1_000
ldf Rn, PD|PF
Reads programmed source size bytes of PD (0-extended), and starts a
prefetch at PSA address.
11_0_1_1_000
ldf Rn, PD|COPY
Starts a copy transfer from the source target at the PSA address to the
destination target at the PDA address. No data transmits through Rn, but
Rn contents are lost (Rn is loaded with PD temporary contents that are
not the copied data).
11_111111
ldf Rn, PS
Reads 32-bit of PS value
NOTE
When reading PD, size information is not important: It is
embedded in the ssize field of the PSA register. If ssize is 1, 2,
or 4, the one, two, or four bytes is transferred from PD to Rn.
Read data is 0-extended.
46.4.12.2.7
Peripheral DMA Unit Copy Mode
Like burst DMA, the peripheral DMA unit has a copy mode that is used when data
transfers do not involve SDMA general registers.
Data is read from the source target at a PSA address, stored in PD, and then automatically
flushed to the destination target at the PDA address. Copy mode is only available for
transfers that involve two targets of the same data path width.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3231

<!-- page 3232 -->

Since copy mode is invoked with an ldf instruction, the loaded general purpose register
loses its previous contents. (However, the new contents are unpredictable as they depend
on temporary values that are seen on the external DMA bus.)
46.4.12.2.8
Error Management
Peripheral DMA generates two kinds of errors: the immediate error that sanctioned
incorrect register programming; and the error triggered by the previous access and stored
in the error flag of PS until a DMA instruction is executed.
46.4.12.2.8.1
Immediate Errors
The following table lists all incorrect DMA register setups.
Table 46-36. Immediate Errors with Peripheral DMA
Rn[1:0] values
DMA instruction
Comments
0x01
0x11
stf Rn, PSA|SZ16|F
stf Rn, PSA|SZ16|I
stf Rn, PDA|SZ16|F
stf Rn, PDA|SZ16|I
If PSA points to a half-word peripheral or to a half-word
address in memory, its value must be 0 modulo 2.
0x01
0x10
0x11
stf Rn, PSA|SZ32|F
stf Rn, PSA|SZ32|I
stf Rn, PDA|SZ32|F
stf Rn, PDA|SZ32|I
If PSA points to a word peripheral or to a word address in
memory, its value must be 0 modulo 4.
PSA[1:0]-PDA[1:0]
DMA instruction
Comments
0x01
0x10
0x11
stf Rn, PSA|SZ32|U stf
Rn, PDA|SZ32|U
When PDA or PSA is updated and becomes a pointer to a
word address in memory, its content must be 0 modulo 4.
0x01
0x11
stf Rn, PSA|SZ16|U
stf Rn, PDA|SZ16|U
When PDA or PSA is updated and becomes a pointer to a
half-word address in memory, its content must be 0 modulo
2.
Read/Write PD instruction
Comments
stf Rn,PD
ldf Rn,PD
If PDA size (dsize) has never been set up before an stf PD instruction (dsize=0) If
PSA size (ssize) has never been set up before an ldf PD instruction (ssize=0)
ldf Rn,PD|CPY
Copy mode is possible only between two targets whose data path width is identical.
It is P8↔P8, P16↔P16, or P32↔P32 regardless of the way the address registers are
incremented.
46.4.12.2.8.2
Data Transfer Errors
When PSA and PDA are correctly set up, the only error that may arise for an ldf PD or stf
PD instruction would be the error of the previous DMA cycle.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3232
NXP Semiconductors

<!-- page 3233 -->

Error handling is driven by a single consideration: When an error occurred during a data
read on the DMA interface, this error should appear as a transfer error to the core when
the core attempts to retrieve the data that was not successfully read from the accessed
device (memory or peripheral).
When an error occurred during a write access to the DMA interface, the data is still
available in PD and should not be destroyed by subsequent core accesses: The core must
be warned about the error issue.
There are three error handling mechanisms for each case: Read Error (First Phase), Write
Error and Read Error (Second Phase), and Copy Mode Errors handling.
46.4.12.2.8.3
Read Error (First Phase)
If an error occurred during a prefetch command, the peripheral DMA enters its ERROR
READ mode (PS[9:8]=11). In this mode, the error is reported on the next ldf PD
instruction and writing PSA, PDA, or PD will cancel the error flag.
The block returns no error mode and instructions are normally executed (a DMA cycle
may be triggered). Similarly, initiating a copy transfer will reset the error flag and start a
copy transfer. The following table details which instructions can be executed in this
mode.
Table 46-37. Possibilities in ERROR READ Mode
DMA Instruction
Immediate Error
Comments
stf rn, PD stf rn, PSA (|U |PF) stf rn,
PDA
ldf rn,PD|COPY
NO
Error mode is reset, PSA or PDA are updated, or a write
cycle is started. For the ldf PD|COPY, a copy loop is
executed.
stf rn, PS
NO
PS is updated.
ldf rn, PS ldf rn, PSA ldf rn, PDA
NO
PS, PSA, and PDA could be read in ERROR READ mode
without any side effects (for example, no DMA cycle is
triggered).
ldf rn, PD
YES
Error of the previous read access is reported here and the
peripheral DMA enters its ERROR mode.
46.4.12.2.8.4
Write Error and Read Error (Second Phase)
The peripheral DMA enters its ERROR mode (PS[9:8]=10) when the previous DMA
write cycle failed, or, as explained in Read Error (First Phase), when an ldf PD is
executed while the block is in ERROR READ mode. When a DMA cycle failed, address
registers (PSA, PDA) are not modified and continue to point to the problematic address.
In ERROR mode, stf instructions may raise an immediate error, and ldf instructions will
not (as detailed in the table below).
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3233

<!-- page 3234 -->

Table 46-38. Possibilities in ERROR Mode
DMA Instruction
Immediate Error
Comments
stf rn, PD stf rn, PSA stf rn, PDA
YES
Any attempt to modify PD, PSA, or PDA will raise an
immediate error, and the peripheral DMA stays in ERROR
mode. When address registers are write accessed, an error
is returned.
stf rn, PS
NO
This is the only way to exit the ERROR mode. PS[3] must be
reset by an stf PS instruction.
ldf rn, PS ldf rn, PSA ldf rn, PDA
NO
PS, PSA, and PDA could be read in ERROR mode without
any side effects (for example, no DMA cycle is triggered).
ldf rn, PD
YES
Whatever the DMA direction (read or write), an ldf rn, PD
instruction will show an immediate error.
46.4.12.2.8.5
Copy Mode Errors
Because copy mode is a write access that follows a read access, there are two possible
cases of bus error.
When the read access incurs a bus error, the peripheral DMA behaves exactly as
described in Read Error (First Phase) and Write Error and Read Error (Second Phase) : It
enters its ERROR READ mode, and so on.
When the error occurred during the write access of the copy transfer, the DMA enables
the core to retrieve the data that was read because it is assumed the read from the
peripheral removed the data from its source device. Therefore, the data to be flushed is
still in PD. Any subsequent access to PD triggers an error to the core, which should
execute its error handling procedure.
Once the ERROR mode is left (after writing to PS), it is possible for the core to retrieve
the data in PD with an ldf instruction or try to flush PD contents once again (for example,
when the error was due to a full FIFO and the script waited for the FIFO to be emptied)
with another ldf instruction in copy mode. This latter instruction detects that there is valid
data in PD, tries to flush it, and thus skips the read phase of the copy instruction. This is a
different behavior from the usual stf PD instruction that overwrites PD with the selected
General Purpose register contents. The same mechanism can be used any time PD holds
data that is not written because of a bus error on the DMA interface; when the data was
written via a copy instruction, or via the usual stf PD instruction.
46.4.12.2.8.6
Error Check Example
The following code illustrates an example checking for both immediate and data transfer
errors on a store to the PD register. The first bdf instruction checks for an immediate
error, but if a data transfer error occurred it is reported until the next instruction to access
the Peripheral DMA. A second check of the error flags is done after the ldf PS
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3234
NXP Semiconductors

<!-- page 3235 -->

instruction. The value of PS here can be ignored. The act of reading any register in
Peripheral DMA while it is in an error mode that returns the error to the core to set either
the SF or DF flag. Any error returned on an ldf command sets the SF flag and any error
returned on an stf instruction sets the DF flag. This can create a situation as shown in the
example where a bus error during a DMA write which would normally be considered as a
destination fault is reported as a source fault because the error was reported to the SDMA
core during an ldf instruction.
Peripheral DMA Error Check
        clrf    0            // Clear SF and DF flags
     stf    R4, PD        // Write data to memory
    bdf    error_routine    // Check for immediate error from write to PD.
    ldf    r3, PS        // Read PS (PS value in R3 can be ignored)
        bsf    error_routine    // Check for bus error from "stf R4,PD"
                // SF is set because it is a ldf instruction, even though
                // the original error was a destination fault
      
46.4.12.2.9
Peripheral DMA Unit Prefetch/Flush Management
There is no flush bit because every time data is stored in PD by a stf PD instruction-
assuming PDA is correctly programmed-it is automatically flushed to the destination.
An acknowledge is returned in the cycle of the DMA instruction, and the SDMA is only
stalled by an instruction that addresses the peripheral DMA when the previous DMA
access is not over.
46.4.12.3
OnCE and Real-Time Debug
The On-Chip Emulation block (OnCE) is the debug interface to the SDMA.
It supports the access to all core internal devices (registers, memory, and so on), and
provides a set of mechanisms that control the core. The OnCE is accessed by JTAG ports
at the chip's board level, or by the host via its peripheral bus.
To reduce the size of the hardware material involved, all tasks supported by the OnCE are
performed on the SDMA core. The architecture of the SDMA OnCE is relatively simple
and very flexible.
The commands supported by the SDMA OnCE are listed in the following sections.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3235

<!-- page 3236 -->

46.4.12.3.1
Memory and Register Access
A set of mechanisms is provided to access SDMA memory and register locations. Both
reading and writing are allowed. The access is supported if the processor is in debug
mode.
Those registers can also be accessed through the Arm platform Control interface when
the OnCE is controlled by the Arm platform, as described in the "Using BP" section.
46.4.12.3.2
Hardware Breakpoints
An event detection unit is implemented to support memory breakpoints. The unit watches
the data exchanged between the SDMA memory bus and the core.
A debug request is sent to the core when matching conditions occur. The unit supports
mixed conditions based on address range, access type, and data value. Event detection
unit configuration registers are memory mapped in the SDMA space (see Arm platform
Channel 0 Pointer (SDMAARM_MC0PTR)): You can modify them through a regular
memory access or the Arm platform control interface.
46.4.12.3.3
Watchpoints
One output pin is provided to monitor matching trigger conditions that are defined in the
event detection unit.
46.4.12.3.4
Software Breakpoints
The SDMA instruction set contains a software breakpoint. Upon executing a software
breakpoint instruction, the core suspends normal execution and enters debug mode.
No hardware step execution mode is implemented in the OnCE, but this feature may be
implemented at the software level with this instruction.
46.4.12.3.5
Core Control
Commands are provided to monitor and control processor activity. You can halt the core,
rerun the core from another address location, and get processor status.
Any hardware breakpoint on the instruction bus is not supported, but this feature may be
implemented by inserting a software breakpoints program.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3236
NXP Semiconductors

<!-- page 3237 -->

46.4.13
The OnCE Controller
The OnCE controller receives commands from the Arm platform or from the JTAG
controller. Each command is interpreted before being sent to the core.
46.4.13.1
OnCE Commands
A small set of commands supports the communication between the OnCE and the
external world.
This command set enables you to perform any of the following tasks: control processor
activity, save core context, and execute an SDMA instruction from the OnCE. Combined
together, these tasks perform more complex commands.
A full OnCE command contains a 4-bit instruction (the OnCE command opcode) and a
variable length data field (the OnCE data). During command execution, the OnCE data is
transferred in a OnCE internal register before being exchanged with the SDMA. Some
data values are also exported. This mechanism creates a link between the processor and
the external world. Nine commands are defined: The following table presents their
formats.
Table 46-39. OnCE Command Opcode Values
Instruction
Opcode
Name
Action
Register
Data
Field Size
Mode
0000
rstatus
Reads the OnCE status register
STATUS
16-bit
normal/debug
0001
dmov
Updates general register GReg1
GREG1
32-bit
debug
0010
exec_once
Runs the instruction from the SDMA
instruction register
INSTRUCTION
16-bit
debug
0011
run_core
Returns to normal execution
BYPASS
1-bit
debug
0100
exec_core
Returns to normal execution via a jump
instruction that specifies the new address
INSTRUCTION
16-bit
debug
0101
debug_rqst
Stops the core after execution of current
instruction
BYPASS
1-bit
normal
0110
rbuffer
Reads the real time buffer
RTB
32-bit
normal/debug
0111-1110
reserved
Reserved
BYPASS
1-bit
normal/debug
1111
bypass
Bypasses TARM platform controller
BYPASS
1-bit
normal/debug
Each instruction corresponds to a specific action performed on the OnCE. The nature of
the associated data field is clearly identified. The dmov command is followed by a 32-bit
data value (which is a data value for the SDMA); the exec_once and the exec_core
commands are followed by a 16-bit data value (which is an instruction for the SDMA);
the rstatus command is followed by a 16-bit control value (which is the content of the
OnCE status register); the rbuffer command is followed by a 32-bit data value. The
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3237

<!-- page 3238 -->

debug_rqst and the run_core commands are followed by a single bit data field (this is a
bypass value). Finally, the bypass instruction enables the SDMA JTAG TAP controller to
be daisy-chained with another JTAG TAP controller. This is a JTAG-only feature. The
set of commands is simple, but enables you to perform any possible task on the SDMA
during a debug process.
46.4.13.2
Sending Commands to the OnCE Controller
The JTAG access is the standard access to the OnCE, but sometimes the JTAG is not
available to fix some bugs (if the chip is in production for instance), an additional access
is then required. Therefore, one Arm platform access to the OnCE is provided.
46.4.13.2.1
Using the JTAG Interface
A serial access is performed through the five JTAG pins TCK, TRST, TMS, TDI, and
TDO. A Test Access Port controller is provided to decode the TMS control signal.
It produces shift-enable signals (shift_ir and shift_dr), and updates enable signals
(update_ir and update_dr). It is fully compliant with the IEEE 1149.1 testability (JTAG)
standard.
During the shift_ir state, the command opcode is shifted into the OnCE controller (for
example, the signal from the TDI pin is shifted into the command register and the TDO
pin receives the signal shifted out). After transferring the four bits of the command, an
update_ir signal is asserted and the command is decoded. The target data register is now
clearly identified and the corresponding control signal is produced, as follows: bypass
enable signal (bp_en), instruction enable signal (inst_en), data enable (data_en), and
status enable signal (stat_en).
During the shift_dr state, the TDI signal is shifted into one of the following target
registers: bypass register (1 bit), SDMA instruction register (16 bits), SDMA data register
(32 bits), or OnCE status register (16 bits). The TDO pin is connected to the output of the
selected register to receive the signals shifted out.
The JTAG access is disabled when the Arm platform access is enabled.
46.4.13.2.2
Using the Arm platform
The Arm platform access to the OnCE is not the standard access, but it is required if the
JTAG is not available.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3238
NXP Semiconductors

<!-- page 3239 -->

For example, if the SDMA ROM is out of use on a chip in production, and the Arm
platform needs to download new code and restart the SDMA, the OnCE can easily
perform this operation. This type of debug operation justifies the use of an Arm platform
access to the OnCE.
To drive the OnCE, the Arm platform uses some registers contained in the Arm platform
Control block of the SDMA. These registers are accessed through the Arm platform
peripheral bus. Most of these registers are connected to another register in the OnCE
controller. Thus, accessing one of these registers is equivalent to accessing the associated
register in the OnCE controller.
The set of registers in the Arm platform Control block is listed below:
• ONCE_ENB register (1 bit, read/write)-This 1-bit register enables the Arm platform
access to the OnCE. When this bit is set, the signals from the JTAG are ignored.
When it is cleared, all writing operations to the following registers through the Host
Control interface are ignored. This register is reset on a JTAG reset.
• ONCE_CMD register (4 bits, read/write)-This 4-bit register receives the command
opcode. It is connected to the command register in the controller. A write access to
this register causes the associated command to be executed on the OnCE. For
example, after writing "0001" in this register, a dmov command is executed.
NOTE
On the Arm platform side, the rstatus and bypass commands are
not supported. This register is reset on a JTAG reset.
• ONCE_DATA register (32 bits, read/write)-This 32-bit register is connected to the
SDMA data register. This register is used when executing a dmov or rbuffer
command.
NOTE
Before requesting a dmov command, the 32-bit data to transfer
must be written in the ONCE_DATA register. At the end of the
execution, the register is updated with GReg1 former value.
This register is reset on a JTAG reset.
• ONCE_INSTR register (16 bits, read/write)-This 16-bit register is connected to the
SDMA instruction register. This register is used when executing an exec_core or an
exec_once command.
NOTE
Before requesting an exec_core or an exec_once command, the
appropriate instruction must be written in the ONCE_INSTR
register. This register is reset on a JTAG reset.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3239

<!-- page 3240 -->

• ONCE_STAT register (16 bits, read only)-A read access to the ONCE_STAT
register returns the content of the OnCE status register (OSTAT). This register is
read only.
• The bypass register is not useful when the Arm platform controls the OnCE,
therefore no register is defined in the Arm platform Control block to access the
bypass register.
46.4.13.2.3
Conflicts Between the JTAG and the Arm platform Accesses
When Arm platform access to the SDMA OnCE is enabled (that is, when the bit in the
ONCE_ENB register is set), the JTAG access is disabled. This guarantees that the block
is not accessed at the same time on both sides.
It is possible to check whether the JTAG access to the SDMA OnCE is enabled from the
JTAG port. When the JTAG access is disabled, the SDMA TDO always returns 1. The
check requires the following steps:
• Execute a dmov command from debug mode (with neither 0xffffffff nor 0x0 as dmov
value: 0x5a5a5a5a is good).
• Execute another dmov command (the value here is not important).
• The returned value from the latter dmov command should be the original one if the
JTAG access is enabled; if it is 0xffffffff instead of the original input value, this
means the JTAG access is disabled.
46.4.13.3
Executing a Command from the OnCE
All the commands defined in OnCE Commands can be accessed through the JTAG. The
Arm platform can access all these commands except the rstatus command.
On the Arm platform side, the OnCE status is directly accessed by reading the
ONCE_STAT register.
46.4.13.3.1
Nature of the Commands
Two types of commands may be distinguished. First, there are two commands that do not
interact with the core: rstatus and rbuffer. Those commands may be requested at any
time: They do not depend on the core status.
NOTE
Each of these commands exports a data value or a status value
from the SDMA.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3240
NXP Semiconductors

<!-- page 3241 -->

There are also commands that interact with the core: dmov, run_core, exec_core,
exec_once, and debug_rqst. These commands are core status dependent, as follows:
• During user mode only the debug_rqst is taken into account.
• During debug mode, all these commands are taken into account except the
debug_rqst. For example, an exec_once command requested while not in debug
mode has no effect.
46.4.13.3.2
Execution Request
The SDMA starts executing a task in debug mode when requested by the OnCE
controller. The execution starting time depends on the type of access used to
communicate with the OnCE.
If the JTAG is used, the request is send after decoding the update_dr state in the TAP
controller. Therefore, always cross this state when sending a command through the
JTAG. If the OnCE is driven from the Arm platform side, the request is sent after
detecting a write access to the ONCE_CMD register. All the registers involved in this
operation must be loaded first.
The following is an example of an exec_core command execution from the Arm platform
side: After writing '010' in the ONCE_CMD register, the OnCE controller asks the
SDMA to execute the instruction contained in the ONCE_INSTR register. The
instruction involved should be available in the ONCE_INSTR register before the
beginning of the execution.
46.4.13.3.3
Command Execution
The following list shows the commands and details how each command is executed:
• rstatus command execution-The rstatus command exports the content of the OnCE
status register (OSR). If the JTAG is used, the status information is captured in the
OnCE status register during the capture_dr state, and shifted out after 16 TCK clock
cycles in the shift_dr state. The rstatus command is not supported on the Arm
platform side, but a status register is provided instead. The rstatus may be performed
in both debug and user modes.
• dmov command execution-The dmov command accesses SDMA internal registers.
Executing a dmov instruction exchanges the 32-bit data values between the SDMA
data register and the general register GReg[1].
• If the JTAG is used, the content of GReg1 is captured in the SDMA data register
during the capture_dr state, then it is shifted out after 32 TCK clock cycles in the
shift_dr state. During the update_dr state, GReg1 is updated with the new, shifted-in
32-bit data value. If the OnCE is driven from the Arm platform side, the data values
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3241

<!-- page 3242 -->

contained in GReg1 and the SDMA data register are exchanged after detecting a
write access to the ONCE_CMD register. The ONCE_DATA register must therefore
be loaded first.
• exec_once command execution-The exec_once command executes the instruction
loaded in the SDMA instruction register. The command may only be requested from
debug mode. The SDMA returns to debug mode at the end of the execution.
• Change of flow instructions as well as instructions that may cause a context switch
are not supported: The comprehensive list comprises done/yield/yiedge (except done
5), BF, BT, BSF, BDF, JMP, JSR, JMPR, JSRR, RET, and LOOP, as well as all the
illegal instructions.
No other command should be requested before the SDMA returns to debug mode.
The SDMA status (for example, whether it is in debug mode or not) can be detected
by polling with the rstatus OnCE command, monitoring the debug_mode pin, or
checking the OnCE Status Register (SDMAARM_ONCE_STAT) register via the
Arm platform control interface.
NOTE
Most of the instructions are single-cycle, which omits the
step of polling the status. Loads and stores to DMA units
are typical instructions that might require this polling.
If the JTAG is used, the 16-bit instruction is shifted in the SDMA instruction register
after 16 TCK clock cycles in the shift_dr state. A request is sent to the core when the
update_dr state is decoded in the TAP controller. If the OnCE is driven from the Arm
platform side, the request is sent to the SDMA when detecting a write access to the
ONCE_CMD register. The ONCE_INSTR register must be therefore be loaded first.
• run_core command execution-The run_core command leaves debug mode and
resume normal program execution. The next instruction executed is the last
instruction decoded before entering debug mode. Be sure to restore core context
before re-running the core. This procedure is detailed in Restoring the Context.
• If the JTAG is used, a 1-bit bypass value is shifted in the bypass register in the
shift_dr state. The SDMA is rerun when the update_dr state is decoded in the TAP
controller. If the OnCE is driven from the Arm platform side, the core is rerun when
detecting a write access to the ONCE_CMD register.
• exec_core command execution-The exec_core command resumes program execution
from any address. The 16-bit instruction provided with the exec_core overwrites the
last instruction decoded before entering debug mode. This command is designed to
support change of flow instructions, so that a program execution can be restarted
from any address. After executing an exec_core command, the SDMA leaves debug
mode. The exec_core command is usually used with a jmp instruction.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3242
NXP Semiconductors

<!-- page 3243 -->

• If the JTAG is used, the 16-bit branch instruction is shifted in the SDMA instruction
register after 16 TCK clock cycles in the shift_dr state. The SDMA is rerun when the
update_dr state is decoded in the TAP controller. If the OnCE is driven from the Arm
platform side, the SDMA reruns when detecting a write access to the ONCE_CMD
register. The ONCE_INSTR register must therefore be loaded first. For example, to
restart the SDMA from the program address 0x100, the instruction loaded should be
a jump to address 0x100 instruction.
• debug_rqst command execution-The debug_rqst command puts the SDMA in debug
mode. If the JTAG is used, a 1-bit bypass value is shifted in the bypass register
during the shift_dr state. A debug request is sent to the SDMA when the update_dr
state is decoded in the TAP controller. If the OnCE is driven from the Arm platform
side, the debug request is sent when detecting a write access to the ONCE_CMD
register. When the SDMA is already in debug mode, this command is simply
ignored.
• rbuffer command execution-The rbuffer command exports the content of the real
time buffer (RTB). If the JTAG is used, the content of the real time buffer (RTB) is
captured in the SDMA data register during the capture_dr state. The register is
completely shifted out after maintaining the shift_dr state during 32 TCK clock
cycles. If the OnCE is driven from the Arm platform side, the content of the RTB is
captured in the ONCE_DATA register after detecting a write access to the
ONCE_CMD register.
• bypass command execution-This command is only available from the JTAG
interface. It enables daisy-chaining of the SDMA JTAG TAP controller with other
JTAG TAP controllers. This command does not change the SDMA state and can be
executed in any mode (run, debug, or sleep). It selects the bypass register of the TAP
controller.
46.4.13.4
Registers Descriptions
See SDMACORE, and SDMAARM, for detailed information on each register.
46.4.13.4.1
Event Cell Counter Register (ECOUNT)
The event cell counter register is a 16-bit register that contains the number of times minus
one that an event detection occurs before generating a debug request.
This register should be written before attempting to use the event detection counter
during an event detection process. The event cell counter register is cleared on a JTAG
reset.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3243

<!-- page 3244 -->

46.4.13.4.2
Event Cell Address Registers (EAA or EAB)
The event cell contains two address registers-the event cell address register (a), called
EAA, and the event cell address register (b), called EAB. Every address register is a 16-
bit register that stores a user-defined address value. This value computes one of the
following address conditions: addra_cond or addrb_cond. Every address register is
cleared on a JTAG reset.
46.4.13.4.3
Event Cell Address Mask Register (EAM)
The event cell address mask register is a 16-bit register that contains a user-defined
address mask value. This mask is applied to the address value latched from the memory
address bus before comparing addresses.
NOTE
There is a common address mask value for the two address
comparators. If bit i of this register is set, then bit i of the
address value latched from the memory bus does not influence
the result of the address comparison. The event cell address
mask register is cleared on a JTAG reset.
46.4.13.4.4
Event Cell Data Register (ED)
The event cell data register is a 32-bit register that contains a user-defined data value.
This data value is an input for the data comparator, which generates the data_cond
condition.
The event cell data register is cleared on a JTAG reset.
46.4.13.4.5
Event Cell Data Mask Register (EDM)
The event cell data mask register is a 32-bit register that contains a user-defined data
mask value. This mask is applied to the data value latched from the memory bus before
comparing data.
Setting bit i of the event cell data mask register means that bit i of the data value latched
from the address bus does not influence the result of the data comparison. The event cell
data mask register is cleared on a JTAG reset.
46.4.13.4.6
Real Time Buffer Register (RTB)
The real Time Buffer register is a 32-bit register that stores and retrieves run-time
information without putting the SDMA in debug mode.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3244
NXP Semiconductors

<!-- page 3245 -->

Refer to Real Time Buffer for more details.
46.4.13.4.7
Event Control Register (ECTL)
The event cell control register is a 16-bit register that defines cell event occurrence
conditions.
The event cell control register is cleared on a JTAG reset. See also OnCE Event
Detection Unit for more details.
46.4.13.4.8
Trace Buffer (TB)
The Trace Buffer register retrieves the information in the Trace Buffer.
See Trace Buffer for more details.
46.4.13.4.9
OnCE Status Register (OSTAT)
The OnCE status register is a 16-bit register that contains processor and event detection
unit status. The OSTAT is a read-only register.
Refer to OnCE Status Register (SDMAARM_ONCE_STAT) for detailed description of
the individual fields in the OSTAT register.
The following figure shows the OSTAT structure.
Table 46-40. OnCE Status Register (OnCE)
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
PST[3:0]
RCV
EDR
ODR
SWB
MST
ECDR[2:0]
Where PST[3:0] is the SDMA core state, RCV is set when the real-time buffer (RTB) is
modified. EDR, ODR, and SWB are set, respectively, when the SDMA has entered debug
mode because of an external debug request, a OnCE debug_rqst command, or a software
breakpoint. MST is set when the OnCE is controlled from the Arm platform control
interface, and when ECDR is a three-flag set that shows the event cell condition(s) that
put the core in debug mode. The OSTAT never provides more than one reason for
entering debug mode.
There are two ways of accessing OSTAT content, as follows:
1. Send an rstatus command to the OnCE controller through the JTAG, or read the
ONCE_STAT register through the Arm platform access. Executing the rstatus
command through the JTAG can be performed in both user and debug modes.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3245

<!-- page 3246 -->

2. Perform an SDMA read access to the location in the SDMA core memory map
(OSTAT register) debug mode using the exec_once command. With this method of
access, the SDMA state reflected by the PST (processor status bit) is always DATA.
The register may also be accessed by a running application.
46.4.13.5
JTAG Interface Requirements
Because the signals received from the JTAG (running on TCK) are transferred to the
OnCE controller (running on the SDMA clock), a synchronization mechanism is
required.
46.4.13.5.1
TCK Speed Limitation
In the JTAG top-level layer, the TDO signal is always captured on a TCK falling edge.
To guarantee a stable TDO signal from the SDMA during this operation, a falling edge
detection is performed on TCK.
Before being latched in the I flip-flop (see Figure 46-11) on TCK falling edge, the TDO
signal must be stable at the input of the flip-flop. This condition is verified if the TCK
period is superior to the following delay:
worst-case edge detection delay + negative-edge signal propagation delay + JTAG top-
level logic propagation delay
The frequency relationship, TCK < CLK/8, limitation guarantees that all operations are
performed as expected.
46.4.13.5.2
Synchronization Implementation
The figure found here shows the synchronization mechanism.
Flip-flops tck0, tck1, and tck2 perform falling- and rising-edge detections on TCK. They
generate the posedge_detected and negedge_detected nets that are used to sample the TDI
and TMS inputs into the respective tdi and tms flip-flops, and update the tdo flip-flop to
yield the TDO output. In the design, the only signal that might go metastable is the output
of the tck0 flip-flop. This signal is captured in the tck1 flip-flop and no logical operation
is performed on it to minimize a metastability propagation risk.
The TDI and TMS flip-flops also cannot go metastable: The propagation time of the
rising-edge detection signal through tck0, tck1, and tck2 guarantees that the TDI and
TMS inputs are stable when captured in the TDI and TMS flip-flops.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3246
NXP Semiconductors

<!-- page 3247 -->

tck0
tck1
tck2
'0'
'1'
'0'
'1'
tdo
tms
tdi
TMS/TDI
TCK
TDO
TMS/TDI internals
posedge_detected
negedge_detected
TDO internal
Figure 46-11. OnCE Synchronization Layer
The following figure shows synchronization timings. It takes three CLK clock cycles to
synchronize TDI on the SDMA clock.
TCK
CLK
posedge_det
TDI
internal TDI
negedge_det
TDO
tdo set-up
tdo set-up
Figure 46-12. Synchronization Timings
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3247

<!-- page 3248 -->

46.4.13.5.3
JTAG Controller Start-Up Recommended Procedure
To ensure correct TAP controller initialization, it is recommended to use the following
procedure:
1. Assert JTAG reset TRSTB (for example, set low).
2. Set TMS low.
3. Wait for 1 TCK clock.
4. Release JTAG reset TRSTB (for example, set high).
5. Wait for a minimum of five TCK cycles.
46.4.14
Using the OnCE
This section provides the elements necessary to run the OnCE during a debug process.
In addition to the basic set of commandsdescribed in OnCE Commands, more complex
commands can be built to meet users' requirements.
46.4.14.1
Activating Clocks in Debug Mode
For power consumption issues, some clocks in the SDMA are disabled when not needed.
This is the case for instances when the SDMA is in sleep mode. Clock gating
management depends on the interface used to control the OnCE.
• For the JTAG access, the SDMA clock gating must be turned off via the
clk_gating_off input.
• For the Arm platform access, the SDMA clock gating is automatically turned off
when the Arm platform access is enabled (see OnCE Enable
(SDMAARM_ONCE_ENB)).
46.4.14.2
Getting the Current Status
Most of the commands the OnCE supports have an impact on the status of the SDMA.
It is not permissible to request the execution of an instruction on the SDMA from the
OnCE while the SDMA is not in debug mode. Such a violation may cause unpredictable
behavior, and it might be necessary to reset the SDMA.
Therefore, the value of the PST bits provided in the OnCE status register should always
be checked before sending any request to the SDMA.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3248
NXP Semiconductors

<!-- page 3249 -->

46.4.14.3
Methods of Entering Debug Mode
A debug request may be asserted at any time, but it is not always taken into account
immediately. Debug mode cannot be entered in the middle of an instruction, or during the
save or restore states of a context switch.
The request is ignored when the core is already in debug mode. Refer to Figure 46-4,
which shows all possible transitions to the debug state, as there are several ways to enter
debug mode.
46.4.14.3.1
External Debug Request During Reset
To enter debug mode after exiting reset, the external debug line has to be maintained
high. This line is handled by the JTAG top-level block.
NOTE
The SDMA detects the debug requests only if the SDMA clock
is running (see Activating Clocks in Debug Mode). The debug
request line should be not be maintained high when the SDMA
is in debug mode.
NOTE
The debug_rqst command (from the OnCE command set) is not
supported during system reset.
46.4.14.3.2
Debug Request During Normal Activity
During normal activity, the SDMA enters debug mode when the following is true:
1. If the debug request line from the JTAG top-level is asserted, or
2. If the OnCE controller receives a debug_rqst command.
The debug_rqst command can be sent by the JTAG access or by an access on the
Arm platform side (if the Arm platform access is enabled).
46.4.14.3.3
Software Breakpoint Instruction
The SDMA enters debug mode at the end of the execution of a software breakpoint
instruction. This instruction must be inserted in program flow executed by the core.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3249

<!-- page 3250 -->

46.4.14.3.4
Event Detection Unit Matching Condition
If the event detection is enabled, a debug request is sent to the core after detecting a
matching condition on the SDMA memory bus.
See OnCE Event Detection Unit for more details.
46.4.14.4
Executing Instructions in Debug Mode
The OnCE supports a mechanism to execute instructions in debug mode. If the SDMA is
in debug mode, then the exec_once command can be used to execute an SDMA
instruction from the OnCE controller. The SDMA returns to debug mode at the end of
each execution.
Some instructions are not supported by the exec_once command: done/yield/yiedge
(except done 5), BF, BT, BSF, BDF, JMP, JSR, JMPR, JSRR, RET, and LOOP, as well
as all the illegal instructions are not supported.
NOTE
While instructions are executed in debug mode from the OnCE,
the program counter of the SDMA is not incremented.
46.4.14.5
Command Sequences Examples
This section provides examples of command sequences that run the SDMA in debug
mode. These sequences are available for both the Arm platform and JTAG accesses.
The following presents the syntax used in this section. The data field provided with each
command is put in parenthesis with the command name. A '-' is used if the data field
provided is a don't care value.
my_command(data_field);                 // executing my_command with a data field
my_command(-);                       // executing my_command with a don't care data field
The value returned by the command (if there is one) is referred by an assignment. In case
the value returned by the command is not used, the assignment is omitted. For an Arm
platform access, the value returned (it is always a data value) is obtained by reading back
into the SDMA data register.
data_out = my_command(data_in); // returning a data value
To clarify the syntax, the instructions' opcodes are referred to by their names. In practice,
use the corresponding 16-bit encoding.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3250
NXP Semiconductors

<!-- page 3251 -->

46.4.14.5.1
Getting the SDMA Status
NOTE
Before executing any command that affects the SDMA (like
dmov or exec_once), check that the SDMA is in debug mode.
Use the following snippet:
rstatus();        // read SDMA status until the SDMA is in debug mode
...
rstatus(); 
If the SDMA is not in debug mode, then a debug request must be generated. In this case,
the SDMA enters debug mode at the end of the execution of the current instruction. Use
this snippet:
debug_rqst(-);   // debug request 
In the following sections, it is assumed that the SDMA was successfully put into debug
mode.
46.4.14.5.2
Saving the Context
The first debug task is to save the SDMA context, which is the content of the eight
general-purpose registers, the loop and PC-related registers, and the flags.
Use the general register GReg[1] as an intermediate register to export the entire context
of the SDMA.
The following example shows how to save GReg[0], GReg[1], GReg[2] and GReg[3].
The sequence of commands used to export additional general registers is very similar to
this.
Save GReg[0], GReg[1], GReg[2], and GReg[3]
GReg1_data = dmov(-);                           // the value exported is the content of 
GReg[1]
exec_once("mov GReg1,GReg0");                       // puts the content of GReg[0] into 
GReg[1]
GReg0_data = dmov(-);                           // the value exported is the content of 
GReg[0]
exec_once("mov GReg1, GReg2");                      // puts the content of GReg[2] into 
GReg[1]
GReg2_data = dmov(-);                           // the value exported is the content of 
GReg[2]
exec_once("mov GReg1, GReg3");                      // puts the content of GReg[3] into 
GReg[1]
GReg3_data = dmov(-);                           // the value exported is the content of 
GReg[3]
Get the value of the internal flags (SF, DF, T, and LM), of the loop related registers (EPC
and SPC), and of the PC-related registers (PC and RPC). Use a done 5, which is the
formatting instruction dedicated to the debug. This instruction formats the flags and the
values contained in the registers. It also writes the resulting values into the channel
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3251

<!-- page 3252 -->

context memory. It should not be used when entering debug from the IDLE state (for
example, with no active channel script running on the SDMA), because it will update a
channel context that may belong to any channel.
exec_once("done 5");                   // formatting the value of flags and registers
At this point, the channel context should be up-to-date in memory, and debug operations
should now be possible. However, the context can be exported with the following
instructions:
Exporting the Context
dmov(ctx_base_addr);                               // loading GReg[1] with the channel 
context base address
exec_once("ld GReg0,(GReg1,0)");                       // get RPC-PC into GReg0
exec_once("ld GReg1, (GReg1,1)");                      // get SPC-EPC into GReg1
Loop_data = dmov(-);                            // read back the value of Loop registers
exec_once("mov GReg1, GReg0");                      // puts the PC info into GReg1
PC_data = dmov(-);                              // reads back the content of the PC registers
After this sequence of operations, the entire SDMA context is exported via the OnCE.
46.4.14.5.3
Restoring the Context
At this point in the operation, restore the context of the SDMA. It can be different from
the original context located in memory, and the content previously saved into the
debugging application via the OnCE.
The example found hereshows how it is possible to modify the current channel context.
Modifying the Current Channel Context
dmov(Loop_data);                               // put Loop former value into GReg[1]
exec_once("mov GReg0, GReg1");                      // copy to GReg[0]
dmov(PC_data);                                 // put PC former value into GReg[1]
exec_once("mov GReg2, GReg1");                      // copy to GReg[2]
dmov(ctx_base_addr);                               // put channel context base address into 
GReg[1]
exec_once("st GReg0, (GReg1,1)");                       // restore Loop context
exec_once("st GReg2, (GReg1,0)");                       // restore PC context
Once the context in memory is the desired context (with or without applying the previous
instruction sequence), it can be restored to the real PC and loop registers in the SDMA
core:
exec_once("cpShReg");                   // restore flags and PC & loop related registers
After this command, the SDMA core PC, RPC, SPC, EPC registers, as well as the flags
contain the same data as what is stored in the context RAM for the current channel.
The following example shows how to restore the context of general registers GReg[0],
GReg[1], GReg[2] and GReg[3].
Restoring the General Register Context
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3252
NXP Semiconductors

<!-- page 3253 -->

dmov(GReg3_data);                   // put GReg[3] restore value in GReg[1]
exec_once("mov GReg3, GReg1"); // restore GReg[3]
dmov(GReg2_data);                   // put GReg[2] restore value in GReg[1]
exec_once("mov GReg2, GReg1"); // restore GReg[2]
dmov(GReg0_data);                   // put GReg[0] restore value in GReg[1]
exec_once("mov GReg0, GReg1"); // restore GReg[0]
dmov(GReg1_data);                   // restore GReg[1]
At this point, it is possible to restart the normal program execution.
NOTE
Every SDMA core general register value can be modified by a
mov instruction, which makes modification of these registers
easy during debug. Unfortunately, there is no such instruction
as a mov to directly modify the contents of either PCU register
or flag (PC, RPC, SPC, EPC, T, LM, SF, or DF). The cpShReg
instruction is meant to provide a means for changing these
register contents via the context memory.
46.4.14.5.4
Accessing the Memory
In the example shown here, it is assumed that the SDMA context is entirely saved. If true,
it is permissible to modify the general purpose registers during debugging activity.
To perform a memory read access, the target address is stored via the OnCE in GReg[1],
then the load instruction is executed on the SDMA (the data loaded from the memory
overwrites the address contained in GReg[1]), and then the result value is read back via
the OnCE.
macro READ:            dmov(target_addr);                                 // put the target 
address in GReg[1]
                    exec_once("ld GReg1,(GReg1,0)");                        // execute the 
load instruction
                    res_data = dmov(-);                                // exports the result 
data value
For a memory write access, the target address is written in GReg[0], and the value to
store is written in GReg[1]. Then the store instruction is executed on the SDMA.
macro WRITE:            dmov(target_addr);                                 // puts the 
target address in GReg[1]
                    exec_once("mov GReg0,GReg1");                        // puts the target 
address in GReg[0]
                    dmov(target_data);                                 // puts the target 
data in GReg[1]
                    exec_once("st GReg1,(GReg0,0)");                         // performs the 
store operation
This sequence is shown as an example; however, many other sequences are possible.
NOTE
This sequence of commands can also be applied to memory-
mapped registers.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3253

<!-- page 3254 -->

46.4.14.5.5
Resuming Program Execution
Before resuming program execution, it is assumed that the SDMA context is properly
restored. There are two ways to restart the SDMA.
Start by executing the last instruction fetched before entering debug mode, as follows.
run_core(-);                          // resume execution from where we stopped before
If necessary, restart the execution from a different address. In this case, use the exec_core
command. The data field provided with this command must be the encoding of a jump
instruction.
exec_core("jmp start_addr"); // rerun the SDMA from another address
In these two examples, the SDMA exits debug mode and keeps executing the code
fetched from the memory.
46.4.14.5.6
Single Stepping in RAM
To execute a program step-by-step from the RAM, insert software breakpoints in the
program flow at appropriate places so that the SDMA only executes one instruction
before returning to debug mode.
First, read the next instruction to execute in the RAM. Then, depending on the value of
this instruction, compute the address where a software breakpoint instruction should be
inserted. The instruction at the corresponding address must be saved, and, the software
breakpoint instruction is inserted. After restarting the SDMA, there is only one
instruction executed before meeting the software breakpoint.
The following example shows the macro functions READ and WRITE, which correspond
to the sequence of commands (described above) used to access the memory.
NOTE
The data read from the memory are 32-bit values, while the
instructions are 16-bit values only. This is why it is best to only
use addresses divided by two when accessing the memory.
READ and WRITE Macro Functions
next_instr = READ(run_addr/2);                        // read the next instruction to execute
// the tool now has to compute the address where the breakpoint
// instruction should be inserted, this address is the "bkpt_addr"
instr_save = READ(bkpt_addr/2);                        // save the instruction before 
overwriting
STORE("bkpt instruction",bkpt_addr/2);                       // store the bkpt instruction 
in memory
exec_core("jmp run_addr");                            // rerun the SDMA
rstatus(-);                                        // wait for the SDMA to enter debug mode
...
rstatus(-);
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3254
NXP Semiconductors

<!-- page 3255 -->

STORE(instr_save,bpkt_addr/2);                          // restore the instruction 
overwritten
In case of branched conditional instructions, a breakpoint instruction should be written at
the two possible target addresses.
46.4.14.5.7
Single Stepping in ROM
No single-step mechanism is supported in ROM. The program code can be loaded in the
RAM, where the single-step mechanism can be executed.
46.4.14.6
OnCE Event Detection Unit
The event detection unit watches signals from the data memory bus (DMBUS), which the
SDMA core uses to access its RAM, ROM, and memory mapped registers.
A debug request is sent to the OnCE controller when user-defined conditions on address
and/or data values are true.
Event
Detection
Cell
Event
Cell
Counter
Event
Detection
Logic
detect
event
dbg_rqst
DMBUS
Figure 46-13. Event Detection Unit
A counter, provided with the detection cell, is decreased after an event detection. A
debug request is sent to the core only when the counter reaches the value of 0. It is
possible to disable the use of the counter if a debug request has to be generated after each
event detection.
The event cell is the basic block that supports hardware breakpoints on an address value
and/or data values coming from the SDMA memory bus. The trigger condition that
generates the debug request is a mixed condition based on those values.
The following figure shows the event cell architecture. The event cell contains the
address (stored in the memory address register) and the data (stored in the memory data
register) used during the last memory access. There are some user-defined reference
values located in memory mapped registers-the event cell addresses, the event cell
address mask, the event cell data, and the event cell data mask. These registers are
accessed by standard load/store instructions just like regular memory locations.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3255

<!-- page 3256 -->

Event Cell Control Register
Event Cell Data Register
Event Cell Data Mask Register
Event Cell Address Register (a)
Event Cell Address Mask Register
Event Cell Address Register (b)
Data Comparator
Address Comparator (a)
Address Comparator (b)
Logic
Logic
addra_cond
addrb_cond
addr_cond
event_detect
data_cond
Memory Data Register
Memory Access Type Register
Memory Access Register
Figure 46-14. Event Cell Architecture
To define a memory breakpoint, three conditions are taken into account: The first two
conditions are comparisons of the current memory address with user-defined reference
addresses (these conditions are called addressA and addressB). The third condition
consists of a comparison between the data received on the DMBUS and a user-defined
reference data (this condition is called data). An intermediate address condition is set to
express a dependency between addressA and addressB conditions.
46.4.14.7
Clock Gating and Reset
This section details how to use the clocks and handle the reset signals.
46.4.14.7.1
Clocks
Because the SDMA uses clock gating to save power, it is necessary to disable the clock
gating and force the clocks to be enabled when using the OnCE.
When the OnCE is accessed through its JTAG interface, clock gating must be disabled
outside the SDMA via a dedicated SDMA input port clk_gating_off. The reason why
detection is not performed automatically by the SDMA internal hardware is that it would
cost power to monitor activity on the JTAG interface.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3256
NXP Semiconductors

<!-- page 3257 -->

When the OnCE is accessed through the Arm platform Control interface, clock gating is
automatically turned off. This is done when bit 0 of the ONCE_ENB register (see OnCE
Enable (SDMAARM_ONCE_ENB)) is set. A write access to this register is possible
even when the OnCE clock is not running. If the Arm platform access is used, the bit in
the ONCE_ENB register must be set before any attempt to access any other OnCE
register.
46.4.14.7.2
Resets
The OnCE reset is different from the SDMA main reset.
Normally, activating the SDMA reset while keeping the OnCE reset inactive (when
possible) enables you to reset the core without having to reprogram the OnCE.
46.4.14.8
Real Time Features
To rebuild the skeleton of a program execution, it is necessary to store the addresses of
the program instructions where jumps are taken: A trace buffer is therefore provided. A
real time buffer has also been added to receive data values written during a program
execution.
The content of this register may be exported through JTAG ports without stopping the
core.
46.4.14.8.1
Trace Buffer
The Trace Buffer is a 32-stage buffer that contains appropriate information to identify the
32 last changes of flow detected during a program execution.
The following figure shows an overview of the Trace Buffer.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3257

<!-- page 3258 -->

Trace buffer cell #0
Trace buffer cell #1
. . .
Trace buffer cell #30
Trace buffer cell #31
input change of flow addresses
output change of flow addresses
shift
Figure 46-15. Trace Buffer
Each cell of the trace buffer contains two reference addresses and a flag. The flag is set
when the addresses stored in the cell correspond to a valid change of flow; otherwise, the
flag is cleared. The three most significant bits are unused.
After every change of flow detection, the address of current instruction and the address of
the target instruction are stored at the top of the Trace Buffer (cell #0). The flag in the
cell is set to indicate that a valid change of flow was detected. Former cell values are
shifted one level down. The Trace Buffer contains the 32 last changes of flow. All the
flags are reset on a software or a hardware reset, and after each transition from debug
mode to user mode.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3258
NXP Semiconductors

<!-- page 3259 -->

A memory mapped register of SDMA core, the Trace Buffer register (TB), is provided to
read the content of the Trace Buffer. This operation should be done in debug mode.
Performing a read access to the Trace Buffer register returns the content of the bottom of
the Trace Buffer (cell #31). After every read access, the trace buffer is shifted one level
down, and the flag at the top of the trace buffer is cleared.
A typical OnCE command sequence that retrieves the oldest change-of-flow information
is a follows:
exec_once("mov r1, TB");                             // stores the oldest change-of-flow in 
GReg1
dmov(-);                                       // retrieves GReg1 contents
This sequence requires the SDMA to be put in debug mode.
46.4.14.8.2
Real Time Buffer
The Real Time Buffer register (RTB) is a memory mapped register that can be accessed
as a regular memory location by the SDMA core during program execution. This register
is located in the OnCE.
Executing ar rbuffer command (see The OnCE Controller for further details) exports the
content of this register through JTAG ports.
When a write access is performed at the memory location corresponding to the RTB, the
receive flag (for example, the RCV bit) is set in the OnCE Status Register (OSR). This
flag is cleared at the end of the execution of a rbuffer command.
NOTE
Every write access to the RTB memory location updates the
RTB register even if the RCV flag is set. The RTB is cleared on
a JTAG reset.
46.4.14.8.3
Emulation Pin
The debug_matched_event emulation pin reflects the matching condition status detected
by the Event Detection Unit.
Since it can be necessary to detect conditions without triggering debug requests, it is
possible to disable the generation of debug requests by the Event Detection Unit and still
have the matching condition available on the emulation pin. This can be done by clearing
the EN flag in the ECTL register.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3259

<!-- page 3260 -->

46.4.14.8.4
Real-Time Debug Outputs
The table found here shows the debug signals that are available at the SDMA boundaries.
Their availability at chip boundaries depends on the project.
Table 46-41. Real-Time Debug Output Pins
Pin
Description
debug_core_state[3:0]
The core_state bits reflect the state of the SDMA core.
• The "Program" state is the usual instruction execution cycle.
• The "Data" state is inserted when there are wait-states during a load or a store on the
data bus (ld or st).
• The "Change of Flow" state is the second cycle of any instruction that breaks the
sequence of instructions (jumps and channel switching instructions).
• The "Change of Flow in Loop" state is used when an error causes a hardware loop exit.
• The "Debug" state means the SDMA is in debug mode.
• The "Functional Unit" state is inserted when there are wait-states during a load or a
store on the functional units bus (ldf or stf).
• In "Sleep" modes, no script is running (this is the core idle state); the "after Reset" is
slightly different because no context restoring phase will happen when a channel is
triggered: The script located at address 0 is executed (boot operation).
• The "in Sleep" states are the same as above except they do not have any
corresponding channel: they are used when entering debug mode after reset; the
reason is that it is necessary to return to the "Sleep after Reset" state when leaving
debug mode.
0 Program
1 Data
2 Change of Flow
3 Change of Flow in Loop
4 Debug
5 Functional Unit
6 Sleep
7 Context Switch Saving Channel
8 Program in Sleep
9 Data in Sleep
10 Change of Flow in Sleep
11 Change of Flow in Loop in Sleep
12 Debug in Sleep
13 Functional Unit in Sleep
14 Sleep after Reset
15 Context Switch Restoring Channel
debug_yield
Pulse that is active when a yield (done 0) or a yieldge (done 1) instruction is executed.
0 -
1 yield/yieldge executed
debug_core_run
Active when the SDMA core is executing instructions.
0 Debug or sleep mode
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3260
NXP Semiconductors

<!-- page 3261 -->

Table 46-41. Real-Time Debug Output Pins (continued)
Pin
Description
1 Run mode
debug_event_channel_sel
Indicates if debug_event_channel displays current channel or last received event
0- debug_event_channel[5:0] gives the number of the current channel
1- debug_event_channel[5:0] gives the number of the last received event
debug_event_channel[5:0]
Gives the number of any DMA request as soon as it is received or the number of the current
channel.
The value of debug_event_channel_sel indicates if debug_event_channel displays the
current channel or last received event. The signal debug_event_channel_sel must be
observed to determine what information is provided on debug_event_chanel at any given
time.
debug_pc[13:0]
Program Counter value; it has a meaning when the core is in run mode.
debug_mode
Set when the core is in debug.
0 -
1 Core is in debug
debug_bus_error
Set when an error was received during a load or a store (ld, st, ldf, or stf instruction) and
registered in SF or DF flag.
0 No error during last load/store
1 Error during last load/store
debug_bus_device[4:0]
Indicates the device or functional unit that is accessed by the current instruction. The
debug_bus_device output is always valid when in sleep mode, debug mode, or executing any
instruction that does not access the functional units or the memory mapped devices, "no
access" is output.
0 No access
1 MSA
2 MDA
3 MD
4 MS
5 PSA
6 PDA
7 PD
8 PS
9 RESERVED
10 RESERVED
11 RESERVED
12 RESERVED
13 CA
14 CS
15 Reserved
16 Memory (RAM or ROM)
17 Memory mapped register
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3261

<!-- page 3262 -->

Table 46-41. Real-Time Debug Output Pins (continued)
Pin
Description
18 Peripheral #1
19 Peripheral #2
20 Peripheral #3
21 Peripheral #4
22 Peripheral #5
23 Peripheral #6
24 Peripheral #7
25 Peripheral #8
26 Peripheral #9
27 Peripheral #10
28 Peripheral #11
29 Peripheral #12
30 Peripheral #13
31 Peripheral #14
debug_bus_rwb
Indicates the direction of the access given by debug_bus_device
0 Write access (st or stf)
1 Read access (ld or ldf)
debug_matched_dmbus
Pulse indicating the OnCE event detection unit has detected a match on the data bus during
an access to memory (RAM or ROM), a memory mapped register or a peripheral that is
hooked to the SDMA.
0 -
1 data bus match detected
debug_rtbuffer_write
Pulse indicating when the real-time buffer is written by the core.
0 -
1 RTB was modified
debug_evt_chn_lines[7:0]
Eight lines that generate short pulses when DMA requests are received or channels are
(re)started. Every line is controlled through two parameters defined in registers Cross-Trigger
Events Configuration Register 1 (SDMAARM_XTRIG_CONF1) (as described in SDMAARM).
The following two parameters are available for every line:
• CNF-Indicates what is monitored on the line: 0 for a channel start, 1 for a DMA request
reception
• NUM[ 5:0]-Gives the number of the DMA request or channel to monitor
The matched_event emulation pin reflects the matching condition status detected by the
Event Detection Unit. Because it can be necessary to detect conditions without triggering
debug requests, it is possible to disable the generation of debug requests by the Event
Detection Unit and still have the matching condition available on the emulation pin. This
can be done by clearing the EN flag in the ECTL register.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3262
NXP Semiconductors

<!-- page 3263 -->

All real-time debug outputs are disabled by default (for example, they are stuck to 0) to
avoid power consumption when they are not used. They are enabled when bit 11
(RTDOBS) of the Configuration Register (SDMAARM_CONFIG) is set. Signals
provided to the system JTAG controller for SDMA debug mode status will also be
enabled when the clk_gating_off input is asserted.
46.5
Instruction Set
46.5.1
Instruction Encoding
This section presents a short summary of the instruction codes. All context switch
instructions are listed for information only; they cannot function properly out of the
context switch routine.
          x...x - don't care
          rrr - destination/source general register
          sss - additional source general register
          bbb - general register used as address base register
          ddddd - address displacement
          nnnnn - bit number
          uuuuuuuu - function unit command bits
          pppppppp - branch displacement (signed)
          iiiiiiii - 8-bit immediate
          jjj - control bit to clear
          ff - flag to clear
          00000jjj00000000        - done (done,yield,wait)
          00000jjj00000001        - notify
          00000xxx00000010        - reserved
          00000xxx00000011        - reserved
          00000xxx00000100        - reserved
          0000000000000101     - softBkpt
          0000000100000101     - reserved
          0000001000000101     - reserved
          0000001100000101     - reserved
          0000010000000101     - reserved
          0000010100000101     - reserved
          0000011000000101     - reserved
          0000011100000101     - reserved
          0000000000000110     - ret
          0000000100000110     - reserved
          0000001000000110     - reserved
          0000001100000110     - reserved
          0000010000000110     - reserved
          0000010100000110     - reserved
          0000011000000110     - reserved
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3263

<!-- page 3264 -->

          0000011100000110     - reserved
          000000ff00000111       - clrf ff
          0000010000000111     - reserved
          0000010100000111     - reserved
          0000011000000111     - reserved
          0000011100000111     - illegal
          00000rrr00001000        - jmpr r
          00000rrr00001001        - jsrr
          00000rrr00001010        - ldrpc r
          00000rrr00001011        - reserved
          00000rrr000011xx          - reserved
          00000rrr00010000        - revb 
          00000rrr00010001        - revblo
          00000rrr00010010        - rorb 
          00000rrr00010011        - reserved
          00000rrr00010100        - ror1 
          00000rrr00010101        - lsr1 
          00000rrr00010110        - asr1 
          00000rrr00010111        - lsl1 
          00000rrr001nnnnn        - bclri r,n 
          00000rrr010nnnnn        - bseti r,n 
          00000rrr011nnnnn        - btsti r,n 
          00000xxx10000xxx           - reserved
          00000rrr10001sss           - mov         
          00000rrr10010sss           - xor          
          00000rrr10011sss           - add        
          00000rrr10100sss           - sub 
          00000rrr10101sss           - or
          00000rrr10110sss           - andn       
          00000rrr10111sss           - and        
          00000rrr11000sss           - tst           
          00000rrr11001sss           - cmpeq       
          00000rrr11010sss           - cmplt         
          00000rrr11011sss           - cmphs        
          0000011011100000     - reserved
          0000011011100001     - reserved
          0000011011100010     - cpShReg
          0000011011100011     - reserved
          0000011011100100     - reserved
          0000011011100101     - reserved
          0000011011100110     - reserved
          0000011011100111     - reserved
          00000xxx11101xxx           - reserved
          00000xxx11110xxx           - reserved
          00000xxx11111xxx           - reserved
          00001rrriiiiiiii                - ldi r,i
          00010rrriiiiiiii                - xori r,i
          00011rrriiiiiiii                - addi r,i
          00100rrriiiiiiii                - subi r,i
          00101rrriiiiiiii                - ori r,i
          00110rrriiiiiiii                - andni r,i
          00111rrriiiiiiii                - andi r,i
          01000rrriiiiiiii                - tsti r,i
          01001rrriiiiiiii                - cmpeqi r,i
          01010rrrdddddbbb        - ld r,(d,b)
          01011rrrdddddbbb        - st r,u
          01100rrruuuuuuuu        - ldf r,u
          01101rrruuuuuuuu        - stf r,u 
          011100xxxxxxxxxx               - reserved
          011101xxxxxxxxxx               - reserved
          011110ffnnnnnnnn       - Loop ff flags are reset
          01111100pppppppp     - bf pc=pc+signed(pppppppp)+1
          01111101pppppppp     - bt pc=pc+signed(pppppppp)+1 
          01111110pppppppp     - bsf pc=pc+signed(pppppppp)+1
          01111111pppppppp     - bdf pc=pc+signed(pppppppp)+1
          10aaaaaaaaaaaaaa     - jmp absolute 
          11aaaaaaaaaaaaaa     - jsr absolute 
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3264
NXP Semiconductors

<!-- page 3265 -->

46.5.2
SDMA Instruction Set
This section describes all the useful instructions from the SDMA set.
Table 46-42. SDMA Instruction List
Instruction
Description
Page
ADD
Addition
ADD (Addition)
ADDI
Add with Immediate Value
ADDI (Add with Immediate Value)
AND
Logical AND
AND (Logical AND)
ANDI
Logical AND with Immediate Value
ANDI (Logical AND with Immediate
Value)
ANDN
Logical AND NOT
ANDN (Logical AND NOT)
ANDNI
Logical AND with Negated Immediate
Value
ANDNI (Logical AND with Negated
Immediate Value)
ASR1
Arithmetic Shift Right by 1 Bit
ASR1 (Arithmetic Shift Right by 1 Bit)
BCLRI
Bit Clear Immediate
BCLRI1 (Bit Clear Immediate)
BDF
Conditional Branch if Destination Fault
BDF (Conditional Branch if Destination
Fault)
BF
Conditional Branch if False
Functional Units Programming Model
BSETI
Bit Set Immediate
BSETI (Bit Set Immediate)
BSF
Conditional Branch if Source Fault
BSF (Conditional Branch if Source Fault)
BT
Conditional Branch if True
BT (Conditional Branch if True)
BTSTI
Bit Test immediate
BTSTI (Bit Test immediate)
CLRF
Clear Arm platform flags
CLRF (Clear Arm platform flags)
CMPEQ
Compare for Equal
CMPEQ (Compare for Equal)
CMPEQI
Compare with Immediate for Equal
CMPEQI (Compare with Immediate for
Equal)
CMPHS
Compare for Higher or Same
CMPHS (Compare for Higher or Same)
CMPLT
Compare for Less Than
CMPLT (Compare for Less Than)
cpShReg
Update Context of PCU Registers and
Flags
cpShReg (Update Context of PCU
Registers and Flag)
DONE
DONE, Yield
DONE (DONE, Yield)
ILLEGAL
ILLEGAL Instruction
ILLEGAL (ILLEGAL Instruction)
JMP
Unconditional Jump Immediate
JMP (Unconditional Jump Immediate)
JMPR
Unconditional Jump
JMPR (Unconditional Jump)
JSR
Unconditional Jump to Subroutine
Immediate
JSR (Unconditional Jump to Subroutine
Immediate)
JSRR
Unconditional Jump to Subroutine
JSRR (Unconditional Jump to
Subroutine)
LD
Load Register
LD (Load Register)
LDF
Load Register from Functional Unit
LDF (Load Register from Functional
Unit)
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3265

<!-- page 3266 -->

Table 46-42. SDMA Instruction List
(continued)
Instruction
Description
Page
LDI
Load Register with Immediate Value
LDI (Load Register with Immediate
Value)
LDRPC
Load from RPC to Register
LDRPC (Load from RPC to Register)
LOOP
Hardware Loop
LOOP (Hardware Loop)
LSL1
Logical Shift Left by 1 Bit
LSL1 (Logical Shift Left by 1 Bit)
LSR1
Logical Shift Right by 1 Bit
LSR1 (Logical Shift Right by 1 Bit)
MOV
Logical Move
MOV (Logical Move)
NOTIFY
Notify to Arm platform
NOTIFY (Notify to Arm platform)
OR
Logical OR
OR (Logical OR)
ORI
Logical OR with Immediate Value
ORI (Logical OR with Immediate Value)
RET
Return from Subroutine
RET (Return from Subroutine)
REVB
Reverse Byte Order
REVB (Reverse Byte Order)
REVBLO
Reverse Low Order Bytes
Reverse Low Order Bytes(REVBLO)
ROR1
Rotate Right by 1 Bit
ROR1 (Rotate Right by 1 Bit)
RORB
Rotate Right by 1 Byte
RORB (Rotate Right by 1 Byte)
SOFTBKPT
Software Breakpoint
SOFTBKPT (Software Breakpoint)
ST
Store Register
ST (Store Register)
STF
Store Register in Functional Unit
STF (Store Register in Functional Unit)
SUB
Subtract
SUB (Subtract)
SUBI
Subtract with Immediate
SUBI (Subtract with Immediate)
TST
Test with Zero
TST (Test with Zero)
TSTI
Test Immediate
TSTI (Test Immediate)
XOR
Logical Exclusive OR
XOR (Logical Exclusive OR)
XORI
Exclusive OR with Immediate
XORI (Exclusive OR with Immediate)
46.5.2.1
ADD (Addition)
Operation:
GReg[r] ← GReg[s] + GReg[r] 
T ← (GReg[r] == 0)
Assembler:
Syntax: add r,s
Example: add 0,3 
ADD GReg[3] and GReg[0] and store the result in GReg[0]
CPU Flags: T
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3266
NXP Semiconductors

<!-- page 3267 -->

Cycles: 1
Description: Performs the ADDition of the source general register s and the destination
general register r, and stores the result in the destination general register r. The T flag is
set if the result of the operation is 0. It is cleared if the result is not 0.
Instruction Format:
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
0
0
0
0
0
r
r
r
1
0
0
1
1
s
s
s
Instruction Fields:
rrr / sss - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.2
ADDI (Add with Immediate Value)
Operation:
GReg[r] ← GReg[r] + immediate
T ← (GReg[r] == 0)
Assembler:
Syntax: addi r,immediate 
Example: add 6,112 
ADD GReg[6] and decimal value 112 and store the result in GReg[6]
CPU Flags: T
Cycles: 1
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3267

<!-- page 3268 -->

Description: Adds a 0-extended immediate value to a general register; stores the result in
the general register. The flag T is set when the result of the operation is 0; otherwise, it is
cleared. The immediate value is the low-order byte of the instruction and has a maximum
value of 255 (0xFF).
Instruction Format
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
0
0
0
1
1
r
r
r
i
i
i
i
i
i
i
i
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
iiiiiiii - immediate value:
00000000 - 0 
00000001 - 1 
 ... 
11111110 - 254
11111111 - 255
46.5.2.3
AND (Logical AND)
Operation:
GReg[r] ← GReg[s] & GReg[r]
Assembler:
Syntax: and r,s
Example: and 1,2 
AND GReg[1] and GReg[2] and store the result in GReg[1]
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3268
NXP Semiconductors

<!-- page 3269 -->

CPU Flags: Unaffected
Cycles: 1
Description: Performs the AND of the source general register s and the destination
general register r, and stores the result in the destination general register r.
Instruction Format
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
0
0
0
0
0
r
r
r
1
0
1
1
1
s
s
s
Instruction Fields:
rrr / sss - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.4
ANDI (Logical AND with Immediate Value)
Operation:
GReg[r] ← GReg[r] & immediate
Assembler:
Syntax: andi r,immediate
Example: andi 7,45
AND GReg[7] and decimal value 45 and store the result in GReg[7]
CPU Flags: unaffected
Cycles: 1
Description: Performs an AND between a 0-extended immediate value and a general
register; stores the result in the general register. The immediate value is the low-order
byte of the instruction and has a maximum value of 255 (0xFF).
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3269

<!-- page 3270 -->

Instruction Format
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
0
0
1
1
1
r
r
r
i
i
i
i
i
i
i
i
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
iiiiiiii - immediate value:
00000000 - 0 
00000001 - 1 
... 
11111110 - 254
11111111 - 255
46.5.2.5
ANDN (Logical AND NOT)
Operation:
GReg[r] ← ~GReg[s] & GReg[r]
Assembler:
Syntax:andn r,s
Example: andn 3,4
AND GReg[3] and NOT GReg[4] (bit inverted) and store the result in GReg[3]
CPU Flags: Unaffected
Cycles: 1
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3270
NXP Semiconductors

<!-- page 3271 -->

Description: Performs the AND of the negation of the source general register s and the
destination general register r, and stores the result in the destination general register r.
Instruction Format:
Table 46-43. Instruction Format
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
0
0
0
0
0
r
r
r
1
0
1
1
0
s
s
s
Instruction Fields:
rrr /sss - destination register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.6
ANDNI (Logical AND with Negated Immediate Value)
Operation:
GReg[r] ← GReg[r] & ~immediate
Assembler:
Syntax: andni r,immediate
Example: andni 0,2 
AND GReg[0] and decimal value -3 (inverted 32-bit value 2) and store the result in
GReg[0]
CPU Flags: unaffected
Cycles: 1
Description: Performs an AND between the negation of a 0-extended 8-bit immediate
value and a general register; stores the result in the general register. The immediate value
is the low-order byte of the instruction and has a maximum value of 255 (0xFF).
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3271

<!-- page 3272 -->

Instruction Format
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
0
0
1
1
0
r
r
r
i
i
i
i
i
i
i
i
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
iiiiiiii - immediate value:
00000000 - 0 
00000001 - 1 
... 
11111110 - 254
11111111 - 255
46.5.2.7
ASR1 (Arithmetic Shift Right by 1 Bit)
Operation:
GReg[r]:{b31,b30,...,b1,b0} ← GReg[r]:{b31,b31,b30,...,b1}
Assembler:
Syntax: asr1 r
Example: asr1 3 
divide by 2 the signed value of GReg[3] and store the result in GReg[3]
CPU Flags: Unaffected
Cycles: 1
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3272
NXP Semiconductors

<!-- page 3273 -->

Description: Shift the bits of any general register to the right and keep the same sign: The
left bit (bit 31) is kept untouched.
Instruction Format:
Table 46-44. Instruction Format
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
0
0
0
0
0
r
r
r
0
0
0
1
0
1
1
0
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.8
BCLRI1 (Bit Clear Immediate)
Operation:
GReg[r]:{b31,...,b(i+1),0,b(i-1),...,b0} ← GReg[r]:{b31,...,b(i+1),b(i),b(i-1),...,b0}
Assembler:
Syntax: bclri r,i
Example: bclri 1,12
clear bit 12 in GReg[1]
CPU Flags: Unaffected
Cycles: 1
Description: Clear the bit of register r specified by the 5-bit immediate field
Instruction Format
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
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3273

<!-- page 3274 -->

0
0
0
0
0
r
r
r
0
0
1
i
i
i
i
i
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
iiiii - immediate value:
00000 - 0 
00001 - 1 
... 
11110 - 30
11111 - 31
46.5.2.9
BDF (Conditional Branch if Destination Fault)
Operation:
if (DF == 1) PC ← PC + 1 + displacement else PC ← PC + 1
Assembler:
Syntax:bdf label
Example: bdf LLL 
Jump to LLL if DF is set, or go to the next instruction if DF is cleared; the displacement
value is calculated by the assembler.
CPU Flags: Unaffected
Cycles: 2 when the branch is done, 1 otherwise
Description: If flag DF is set, jump to the new address that is calculated by adding the
sign-extended 8-bit displacement to the next PC address. If flag DF is cleared, no jump is
performed: The next instruction is located at the next PC address.
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3274
NXP Semiconductors

<!-- page 3275 -->

Instruction Format
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
0
1
1
1
1
1
1
1
p
p
p
p
p
p
p
p
Instruction Fields:
pppppppp - signed displacement field:
00000000 - 0 
00000001 - 1 
... 
01111110 - 126 
01111111 - 127
10000000 - (-128)
10000001 - (-127)
... 
11111110 - (-2)
11111111 - (-1) 
46.5.2.10
BF (Conditional Branch if False)
Operation:
if (T == 0) 
PC ← PC + 1 + displacement 
else 
PC ← PC + 1
Assembler:
Syntax: bf label 
Example: bf LLL
Jump to LLL if T is cleared, or go to the next instruction if T is set. The displacement
value is calculated by the assembler.
CPU Flags: Unaffected
Cycles: 2 when the branch is done, 1 otherwise
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3275

<!-- page 3276 -->

Description: Conditional branch: If flag T is cleared, jump to the new address that is
calculated by adding the sign-extended 8-bit displacement to the next PC address. If flag
T is set, no jump is performed: The next instruction is located at the next PC address.
Instruction Format
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
0
1
1
1
1
1
0
0
p
p
p
p
p
p
p
p
Instruction Fields:
pppppppp - signed displacement field:
00000000 - 0 
00000001 - 1 
... 
01111110 - 126 
01111111 - 127
10000000 - (-128)
10000001 - (-127)
... 
11111110 - (-2)
11111111 - (-1) 
46.5.2.11
BSETI (Bit Set Immediate)
Operation:
GReg[r]:{b31,...,b(i+1),1,b(i-1),...,b0} ← GReg[r]:{b31,...,b(i+1),b(i),b(i-1),...,b0}
Assembler:
Syntax: bseti r,i
Example: bseti 6,5
Set bit 5 in GReg[6]
CPU Flags: Unaffected
Cycles: 1
Description: Sets bit number i in the selected General Register.
Instruction Format
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3276
NXP Semiconductors

<!-- page 3277 -->

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
0
0
0
0
0
r
r
r
0
1
0
i
i
i
i
i
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
iiiii - bit number field:
00000 - 0 
00001 - 1 
... 
11110 - 30 
11111 - 31
46.5.2.12
BSF (Conditional Branch if Source Fault)
Operation:
if (SF == 1) PC ← PC + 1 + displacement else PC ← PC + 1
Assembler:
Syntax: bsf label
Example: bsf LLL
Jump to LLL if SF is set, or go to the next instruction if SF is cleared. The displacement
value is calculated by the assembler.
CPU Flags: Unaffected
Cycles: 2 when the branch is done, 1 otherwise
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3277

<!-- page 3278 -->

Description: Conditional branch: If flag SF is set, jump to the new address that is
calculated by adding the sign-extended 8-bit displacement to the next PC address. If flag
SF is cleared, no jump is performed: The next instruction is located at the next PC
address.
Instruction Format
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
0
1
1
1
1
1
1
0
p
p
p
p
p
p
p
p
Instruction Fields:
pppppppp - signed displacement field:
00000000 - 0 
00000001 - 1 
... 
01111110 - 126 
01111111 - 127
10000000 - (-128)
10000001 - (-127)
... 
11111110 - (-2)
11111111 - (-1) 
46.5.2.13
BT (Conditional Branch if True)
Operation
if (T == 1) 
PC ← PC + 1 + displacement
else 
PC ← PC + 1
Assembler
Syntax: bt label
bt LLL
Jump to LLL if T is set, or go to the next instruction if T is cleared. The displacement
value is calculated by the assembler.
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3278
NXP Semiconductors

<!-- page 3279 -->

CPU Flags: Unaffected
Cycles: 2 when the branch is done, 1 otherwise
Description: Conditional branch: If flag T is set, jump to the new address that is
calculated by adding the sign-extended 8-bit displacement to the next PC address. If flag
T is cleared, no jump is performed: The next instruction is located at the next PC address.
Instruction Format
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
0
1
1
1
1
1
0
1
p
p
p
p
p
p
p
p
pppppppp - signed displacement field:
00000000 - 0
00000001 - 1
... 
01111110- 126 
01111111 - 127 
10000000 - (-128) 
10000001 - (-127) 
...
11111110 -  (-2)
11111111 - (-1)
46.5.2.14
BTSTI (Bit Test immediate)
Operation:
T ← GReg[r]:b(i)
Assembler:
Syntax: btsti r,i
Example: btsti 2,29 
Test bit 29 in GReg[2] and copy its value in flag T
CPU flags: T
Cycles: 1
Description: T is loaded with the value of bit number i from the selected general register.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3279

<!-- page 3280 -->

Instruction Format:
Table 46-45. Instruction Format
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
0
0
0
0
0
r
r
r
0
1
1
i
i
i
i
i
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
iiiii - bit number field:
0000 - 0 
0001 - 1 
... 
11110 - 30 
11111 - 31 
46.5.2.15
CLRF (Clear Arm platform flags)
Operation:
 if (ff%2 == 0)
SF ← 0 
if (ff/2 == 0) 
DF ← 0
Assembler:
Syntax: clrf ff
Example: clrf 2 
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3280
NXP Semiconductors

<!-- page 3281 -->

Clear flag SF and keep flag DF unchanged
CPU Flags: SF, DF
Cycles: 1
Description: Clears a selection of the Arm platform fault flags: SF, DF, both SF and DF
or none can be cleared.
Instruction Format
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
0
0
0
0
0
0
f
f
0
0
0
0
0
1
1
1
Instruction Fields:
ff - flags field:
00 - clear SF and clear DF
01 - clear DF 
10 - clear
SF 11 - no clear
46.5.2.16
CMPEQ (Compare for Equal)
Operation:
T ← (GReg[s] == GReg[r])
Assembler:
Syntax: cmpeq r,s
Example: cmpeq 7,5 
Compare GReg[7] and GReg[5] and set flag T if they are equal
CPU flags: T
Cycles: 1
Description: Subtracts the destination general register r from the source general register s,
and sets T if the result is 0, clears T if the result is not 0.
Instruction Format
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
0
0
0
0
0
r
r
r
1
1
0
0
1
s
s
s
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3281

<!-- page 3282 -->

Instruction Fields:
rrr / sss - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.17
CMPEQI (Compare with Immediate for Equal)
Operation:
T ← (GReg[r] == immediate)
Assembler:
Syntax: cmpeqi r,immediate
Example: cmpeqi 2,13
Compare GReg[2] and decimal value 13 and set flag T if they are equal
CPU Flags: T
Cycles: 1
Description: Subtracts the 0-extended 8-bit immediate value from the general register,
and sets T if the result is 0, clears T if the result is not 0. The immediate value is the low-
order byte of the instruction.
Instruction Format
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
0
1
0
0
1
r
r
r
i
i
i
i
i
i
i
i
Instruction Fields:
rrr - destination register field:
000 - GReg[0] 
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3282
NXP Semiconductors

<!-- page 3283 -->

001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
iiiiiiii - immediate value:
00000000 - 0
00000001 - 1
... 
11111110 - 254
11111111 - 255
46.5.2.18
CMPHS (Compare for Higher or Same)
Operation:
T ← (GReg[r] ≥ GReg[s])
Assembler:
Syntax: cmphs r,s
Example: cmphs 0,1 
Compare GReg[0] and GReg[1] and set flag T if GReg[0] is higher than or equal to
GReg[1]
CPU Flags: T
Cycles: 1
Description: Compares the destination general register r and the source general register s,
and sets T if the destination general register r is higher than or equal to the source general
register s, clears T otherwise. The comparison is unsigned.
Instruction Format
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
0
0
0
0
0
r
r
r
1
1
0
1
1
s
s
s
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3283

<!-- page 3284 -->

Instruction Fields:
rrr / sss - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.19
CMPLT (Compare for Less Than)
Operation:
T ← (GReg[r] < GReg[s])
Assembler:
Syntax: cmplt r,s
Example: cmplt 7,4
Compare GReg[7] and GReg[4] and set flag T if GReg[7] is lower than GReg[4]
CPU Flags: T
Cycles: 1
Description: Compares the destination general register r and the source general register s,
and sets T if the destination general register r is lower than the source general register s,
clears T otherwise. The comparison is signed.
Instruction Format
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
0
0
0
0
0
r
r
r
1
1
0
1
0
s
s
s
rrr / sss - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3284
NXP Semiconductors

<!-- page 3285 -->

011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.20
cpShReg (Update Context of PCU Registers and Flag)
Assembler:
Syntax: cpShReg
CPU Flags: none
Cycles: 1
Description: SF, RPC, T, PC,LM, EPC, DF, and SPC registers are updated according to
the value of their corresponding bits in the context memory. This instruction must only be
used in debug mode via the OnCE. It reverses the done 5 operation.
Instruction Format
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
0
0
0
0
0
1
1
0
1
1
1
0
0
0
1
0
46.5.2.21
DONE (DONE, Yield)
Operation:
if (jjj&6 == 2) HE[CCR] ← 0 
if (jjj == 3) HI[CCR] ← 1 
if (jjj == 4) EP[CCR] ← 0 
if ((jjj == 0) && (NCP > CCP)) CCR ← NCR 
else if ((jjj == 1) && (NCP >= CCP)) 
CCR ← NCR 
else 
CCR ← NCR
(CCR stands for Current Channel Register; NCR stands for Next Channel Register)
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3285

<!-- page 3286 -->

Assembler:
Syntax: done jjj
Example: done 3 
Clear HE bit for the current channel, send an interrupt to the Arm platform for the current
channel and reschedule.
CPU Flags: Unaffected
Cycles: Variable if a context switch is done, 1 otherwise
Description: Clears one of the channel enabling bits (HE or EP for the corresponding
channel number) if required. Sends an interrupt to the corresponding Arm platform by
setting the appropriate flag, if required (HI for the corresponding channel number).
Reschedules according to the mode and the NCP (Next Channel Priority) and CCP
(Current Channel Priority) values. According to the scheduling decision, the NCR (Next
Channel Register) is copied to the CCR (Current Channel Register) and channel contexts
are switched. If several channels with the same highest priority are pending, they are
ordered by their number from 31 down to 0. The higher number is selected (for example,
channel 26 is selected if channels 3, 12, 14, and 26 with the same highest priority are
pending). If no flag is modified, the reschedule can allow the replacement of the current
channel by another channel with a priority strictly greater than the current channel
priority (yield). Or, it can allow the replacement of the current channel by another
channel with a priority greater than or equal to the current channel priority (yieldge). In
the latter case, the selected channel will always be the first one with the same priority,
starting from channel number 31 down to channel 0 (the current channel does not belong
to the set of selectable channels).
Instruction Format
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
0
0
0
0
0
j
j
j
0
0
0
0
0
0
0
0
jjj - Channel Flags field:
000 - No channel flags affected: Reschedule only if the next channel priority is greater
than current channel priority (yield)
001 - No channel flags affected: Reschedule only if the next channel priority is greater
than or equal to the current channel priority (yieldge)
010 - Clear HE for the current channel and reschedule 011 - Clear HE, set HI for the
current channel and reschedule 100 - Clear EP for the current channel and reschedule
101 - Reserved for debug to copy relevant registers into context memory
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3286
NXP Semiconductors

<!-- page 3287 -->

110 - RESERVED
111 - RESERVED
For the scheduling rules, refer to Scheduler Functional Description. Every possible done
instruction is further described as follows:
• done 0/yield is executed by a channel script when it accepts preemption by a higher
priority channel;
• done 1/yieldge is executed by a channel script when it accepts preemption by a
higher priority channel and it also accepts a roll-up with other channels that have the
same priority;
• done 2 is executed by a channel script that was triggered by a Arm platform start via
the Channel Start (SDMAARM_HSTART) register, when its task is completed and it
requires termination;
• done 3 is executed by a channel script that was triggered by a Arm platform start via
the Channel Start (SDMAARM_HSTART) register, when its task is completed, it
requires termination and it needs to trigger an interrupt to the Arm platform upon
closure;
• done 4 is executed by a channel script that was triggered by a DMA request, when its
task is completed and it requires termination;
• done 5 is used in debug mode only; it copies the PCU registers and flags to the
context memory of the current channel;
46.5.2.22
ILLEGAL (ILLEGAL Instruction)
Operation:
PC ← 0001
Assembler:
Syntax: illegal
CPU Flags: Unaffected
Cycles: 2
Description: Jumps to the Illegal instruction routine located at address 0001. All
unauthorized instructions result in an Illegal instruction behavior; however, the
ILLEGAL instruction must be used to guarantee software compatibility with future
versions of the SDMA.
Instruction Format
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3287

<!-- page 3288 -->

Table 46-46. Instruction Format
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
0
0
1
1
1
46.5.2.23
JMP (Unconditional Jump Immediate)
Operation:
PC ← absolute_address
Assembler:
Syntax: jmp label
Example: jmp LLL 
The assembler translates the label to the exact address
CPU Flags:Unaffected
Cycles: 2
Description: Jumps to the absolute address contained the lower 14 bits of the instruction
(the PC is a 14-bit register).
Instruction Format
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
1
0
a
a
a
a
a
a
a
a
a
a
a
a
a
a
aaaaaaaaaaaaaa - address field:
00000000000000 - 0
00000000000001 - 1
...
11111111111110 - 16382
11111111111111 - 16383
46.5.2.24
JMPR (Unconditional Jump)
Operation:
PC ← GReg[r]
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3288
NXP Semiconductors

<!-- page 3289 -->

Assembler:
Syntax: jmpr r
Example: jmpr 0
Jump to address stored in GReg[0]
CPU Flags: Unaffected
Cycles: 2
Description: Jumps to the absolute address contained in a General Register.
Instruction Format
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
0
0
0
0
0
r
r
r
0
0
0
0
1
0
0
0
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.25
JSR (Unconditional Jump to Subroutine Immediate)
Operation:
RPC ← PC + 1
PC ← absolute_address
Assembler:
Syntax: jsr r
Example:jsr LLL 
Jumps to subroutine starting at LLL; the assembler translates the label to exact address
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3289

<!-- page 3290 -->

CPU Flags: Unaffected
Cycles: 2
Description: Jumps to the subroutine located at the absolute address contained the lower
14 bits of the instruction (the PC is a 14-bit register).
Instruction Format
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
1
1
a
a
a
a
a
a
a
a
a
a
a
a
a
a
aaaaaaaaaaaaaa - address field:
00000000000000 - 0
00000000000001 - 1
...
11111111111110 - 16382
11111111111111 - 16383
46.5.2.26
JSRR (Unconditional Jump to Subroutine)
Operation:
RPC ← PC + 1
PC ← GReg[r]
Assembler:
Syntax: jsrr r
Example:jsrr 5
Jumps to subroutine located at address stored in GReg[5]
CPU Flags: Unaffected
Cycles: 2
Description: Jumps to the subroutine at address contained in a General Register
Instruction Format
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
0
0
0
0
0
r
r
r
0
0
0
0
1
0
0
1
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3290
NXP Semiconductors

<!-- page 3291 -->

Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.27
LD (Load Register)
Operation:
GReg[r] ← [GReg[b] + displacement]
if (transfer_error)
SF ← 1 
else
SF ← 0
Assembler:
Syntax: ld r,(b,displacement)
Example: ld 1,(2,23)
Loads data into GReg[1]; the data is located at address obtained by adding decimal value
23 to GReg[2]
CPU Flags: SF
Cycles: 2+n where n is 0 for ROM, RAM or memory mapped registers, and n is the
number of wait-states of the peripheral for a peripheral access
Description: Adds a 5-bit 0-extended displacement to a base address in General Register
b; the result is the address of the data to fetch on the DM bus. The data received from the
bus is stored in the destination General Register r. If an error occurs during the transfer,
the flag SF is set, else it is cleared.
Instruction Format
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3291

<!-- page 3292 -->

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
0
1
0
1
0
r
r
r
d
d
d
d
d
b
b
b
rrr / bbb - register field:
 000 - GReg[0]
 001 - GReg[1]
 ...
 111 - GReg[7]
ddddd - displacement value:
00000 - 0 
00001 - 1 
...
11111 - 31
46.5.2.28
LDF (Load Register from Functional Unit)
Operation:
GReg[r] ← [fu_address]
if (transfer_error)
SF ← 1 
else 
SF ←0
fu_address is an 8-bit field and depends on addressed functional unit
Assembler:
Syntax: ldf r,fu_address 
Example: ldf 0,13 
Loads data coming from the Burst DMA register MD into GReg[0]; it is a 32-bit access
with no prefetch
CPU Flags: SF
Cycles: 1+n where n is the number of wait-states that may be inserted by the functional
unit
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3292
NXP Semiconductors

<!-- page 3293 -->

Description: Sends an 8-bit address on the Functional Unit Bus (FU bus) and stores the
data received from the bus in the destination General Register r. If an error occurs during
the transfer, the flag SF is set, else it is cleared.
Instruction Format
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
0
1
1
0
0
r
r
r
f
f
f
f
f
f
f
f
See the following sections for more details of the LDF instruction usage with each
functional unit:
• Burst DMA Read (ldf) for Burst DMA
• Peripheral DMA Read (ldf)-Read Mode for Peripheral DMA
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
ffffffff - functional unit source register and action (unspecified values are reserved):
00000000 - MSA
00000100 - MDA
00001001 - MD byte
00001010 - MD halfword
00001011 - MD word
00001100 - MS
00101001 - MD byte - prefetch
00101010 - MD halfword - prefetch
00101011 - MD word - prefetch
01000000 - DSA
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3293

<!-- page 3294 -->

11000000 - PSA
11001000 - PD
11010000 - PDA
11011000 - PD in copy mode (rrr contents are lost)
11101000 - PD - prefetch next data
11111111 - PS 
46.5.2.29
LDI (Load Register with Immediate Value)
Operation:
GReg[r] ← immediate 
Assembler:
Syntax: ldi r,immediate
Example: ldi 6,1
loads decimal value 1 into GReg[6]
CPU Flags: Unaffected
Cycles: 1
Description: Stores a 0-extended immediate value in a General Register. The immediate
value is the low-order byte of the instruction and has a maximum value of 255 (0xFF).
Instruction Format
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
0
0
0
0
1
r
r
r
i
i
i
i
i
i
i
i
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3294
NXP Semiconductors

<!-- page 3295 -->

110 - GReg[6] 
111 - GReg[7] 
iiiiiiii - immediate value:
00000000 - 0
00000001 - 1
... 
11111110 - 254
11111111 - 255
46.5.2.30
LDRPC (Load from RPC to Register)
Operation:
GReg[r] ← RPC
Assembler:
Syntax: ldrpc r
Example: ldrpc 3
copies RPC to GReg[3]
CPU Flags: Unaffected
Cycles: 1
Description: Stores the contents of the RPC in a General Register. That instruction may
be used to have more than one level of subroutines.
Instruction Format
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
0
0
0
0
0
r
r
r
0
0
0
0
1
0
1
0
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3295

<!-- page 3296 -->

101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.31
LOOP (Hardware Loop)
Operation:
if (ff%2 == 0)
   SF ← 0
if (ff/2 == 0) 
  DF ← 0
if ((GReg[0] == 0) || (SF == 1) || (DF == 1))
   PC ← PC + loop_size + 1
else 
   {  
      SPC ← PC + 1  
      EPC ← PC + loop_size + 1  
      LM ← 1  
      PC ← PC + 1 
   }
during every instruction execution in the loop:
if ((SF == 1) || (DF == 1)) 
 {  
    LM ← 0  
    PC ← EPC  
  } 
else if ((PC + 1) == EPC) 
 {  
    GReg[0] ← GReg[0] - 1  
    if (GReg[0] == 0)
      {  
         LM ← 0  
         PC ← EPC  
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3296
NXP Semiconductors

<!-- page 3297 -->

       }  
     else 
         PC ← SPC  
   } 
else 
  PC ← nextPC(instruction)
after the execution of the last instruction of the loop body:
if (GReg[0] == 0)  
   T ← 1 
else  
   T ← 0
Assembler:
Syntax: loop n{,ff}
Example: loop 3,1 
Executes GReg[0] times the instructions comprised between PC+1 and PC+3 (included);
ff=1 clears the DF flag before starting the loop. When omitted, the ff field is set to 0
(clearing both SF and DF).
CPU Flags: LM[1:0], T
Cycles: 2 when the loop count (GReg[0]) is 0 or SF or DF is set at loop start, 1+1 when
the loop starts but exits abnormally (SF or DF set inside the loop which adds 1 cycle to
the offending load or store to jump to EPC), 1 when the loop is executed normally
Description: The loop instruction executes a sequence of instructions several times. The
number of times is given by the contents of GReg[0], the loop counter. SDMA will jump
to the first instruction after the end of the loop if the value in GReg[0] is 0. Otherwise the
SDMA enters loop mode. It sets the most significant bit of the LM flag that will only be
reset once the last instruction of the last loop is executed. The instructions in the loop are
executed GReg[0] times. The management of fault flags (SF and DF) is as follows. When
entering the hardware loop, SF and DF can be cleared according to the ff field of the
instruction. After that operation, if any flag is still set the loop will not be executed. The
SDMA will jump to the first instruction after the end of the loop without entering loop
mode. During the execution of the loop, if any fault flag is set by a LD, LDF, ST, or STF
instruction, the SDMA will immediately exit loop mode and jump to the first instruction
after the end of the loop. In that case, GReg0 is not decremented for that last piece of the
loop body execution (even if the SF or DF flag is set at the last instruction of the loop
body). The T flag reflects the state of GReg[0] after the end of the loop, which is an
indicator of the complete execution of the loop. If the loop exited because of an error (SF
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3297

<!-- page 3298 -->

or DF set), GReg[0] will not be 0 at the end of the loop, hence T will be cleared. If the
loop executes without fault, GReg[0] will be 0 at the end of the loop, hence T will be set.
The boundary case when a source or destination fault occurs at the last instruction of the
last loop is considered as an anticipated exit of the loop, which causes the T flag to be
cleared. If the last instruction executed before leaving the hardware loop also tries to
modify the T flag, the flag is updated according to the value of GReg[0], NOT according
to the result of the last executed instruction.
Limitations:
1. 1. Jump instructions (JMP, JMPR, JSR, JSRR, BF, BT, BSF, BDF) are not allowed
inside the hardware loop.
2. 2. GReg[0] cannot be written to inside the hardware loop (it can be read).
3. 3. The empty loop (0 instruction in the body) is forbidden.
4. 4. If GReg[0] == 0 at the start of the loop, which causes a jump to EPC, the T flag is
not updated.
Instruction Format
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
0
1
1
1
1
0
f
f
n
n
n
n
n
n
n
n
Instruction Fields:
ff - flags field: 
00 - clear SF and clear DF 
01 - clear DF 
10 - clear SF 
11 - no clear
nnnnnnnn - loop size
00000000 - empty loop: forbidden value 
00000001 - 1 instruction in the loop 
00000010 - 2 instructions in the loop 
...
11111111 - 255 instructions in the loop
46.5.2.32
LSL1 (Logical Shift Left by 1 Bit)
Operation:
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3298
NXP Semiconductors

<!-- page 3299 -->

GReg[r]:{b30,...,b1,b0,0} ← GReg[r]:{b31,b30,...,b1,b0}
Assembler:
Syntax: lsl1 r
Example: lsl1 2 
multiplies by 2 the value in GReg[2]
CPU Flags: Unaffected
Cycles: 1
Description: Shift the bits of any General Register to the left. The right bit (bit 0) is set to
0. No overflow is detected by the hardware.
Instruction Format
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
0
0
0
0
0
r
r
r
0
0
0
1
0
1
1
1
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.33
LSR1 (Logical Shift Right by 1 Bit)
Operation:
GReg[r]:{0,b31,b30,...,b1} ← GReg[r]:{b31,b30,...,b1,b0}
Assembler:
Syntax: lsr1 r
Example: lsr1 4 
divides by 2 the unsigned value contained in GReg[4]
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3299

<!-- page 3300 -->

CPU Flags: Unaffected
Cycles: 1
Description: Shift the bits of any General Register to the right. The left bit (bit 31) is set
to 0.
Instruction Format
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
0
0
0
0
0
r
r
r
0
0
0
1
0
1
0
1
Instruction Fields:
rrr - destination register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.34
MOV (Logical Move)
Operation:
GReg[r] ← GReg[s]
Assembler:
Syntax: mov r,s
Example: mov 4,0
copies GReg[0] to GReg[4]
CPU Flags: Unaffected
Cycles: 1
Description: Move the contents of the source General Register s to the destination
General Register r.
Instruction Format
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3300
NXP Semiconductors

<!-- page 3301 -->

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
0
0
0
0
0
r
r
r
1
0
0
0
1
s
s
s
Instruction Fields:
rrr / sss - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.35
NOTIFY (Notify to Arm platform)
Operation:
 if (jjj & 4 == 0) 
 {
   if (jjj&2 == 2)
      HE[CCR] ← 0
   if (jjj&1== 1)
       HI[CCR] ← 1
  }
else if (jjj == 4)
   EP[CCR] ← 0
else 
(CCR stands for Current Channel Register)
Assembler:
Syntax: notify jjj
Example: notify 3
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3301

<!-- page 3302 -->

clears the HE bit for the current channel and sends an interrupt to the Host for the current
channel
CPU Flags: Unaffected
Cycles: 1
Description: Clears one of the channel enabling bits (HE or EP for the corresponding
channel number) if required, sends an interrupt to the corresponding Arm platform by
setting the appropriate flag if required (HI for the corresponding channel number).
Instruction Format
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
0
0
0
0
0
j
j
j
0
0
0
0
0
0
0
1
jjj - Channel Flags field:
000 - unused 
001 - set HI for the current channel 
010 - clear HE for the current channel 
011 - clear HE, set HI for the current channel 
100 - clear EP for the current channel 
101 - RESERVED 
110 - RESERVED 
111 - RESERVED
46.5.2.36
OR (Logical OR)
Operation:
GReg[r] ← GReg[s] | GReg[r]
Assembler:
Syntax: or r,s
Example: or 3,6
ORs GReg[3] and GReg[6] and stores the result in GReg[3]
CPU Flags: Unaffected
Cycles: 1
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3302
NXP Semiconductors

<!-- page 3303 -->

Description: Performs the OR of the source General Register s and the destination
General Register r, and stores the result in the destination General Register r.
Instruction Format
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
0
0
0
0
0
r
r
r
1
0
1
0
1
s
s
s
Instruction Fields:
rrr / sss - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.37
ORI (Logical OR with Immediate Value)
Operation:
GReg[r] ← GReg[r] | immediate
Assembler:
Syntax: ori r,immediate
Example: ori 1,56
ORs GReg[1] and the decimal value 56 and stores the result in GReg[1]
CPU Flags: unaffected
Cycles: 1
Description: Performs an OR between a 0-extended 8-bit immediate value and a General
Register; stores the result in the General Register. The immediate value is the low-order
byte of the instruction and has a maximum value of 255 (0xFF).
Instruction Format
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3303

<!-- page 3304 -->

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
0
0
1
0
1
r
r
r
i
i
i
i
i
i
i
i
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
iiiiiiii - immediate value:
00000000 - 0 
00000001 - 1 
... 
11111110 - 254
11111111 - 255
46.5.2.38
RET (Return from Subroutine)
Operation:
PC ← RPC
Assembler:
Syntax: ret
CPU Flags: Unaffected
Cycles: 2
Description: Return from subroutine.
Instruction Format
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
0
0
0
0
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
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3304
NXP Semiconductors

<!-- page 3305 -->

46.5.2.39
REVB (Reverse Byte Order)
Operation:
GReg[r]:{B3,B2,B1,B0} ← GReg[r]:{B0,B1,B2,B3}
Assembler:
Syntax: revb r
Example:  revb 5
reverses bytes order in GReg[5]
CPU Flags: Unaffected
Cycles: 1
Description: Reverse the byte order of any General Register.
Instruction Format
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
0
0
0
0
0
r
r
r
0
0
0
1
0
0
0
0
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.40
Reverse Low Order Bytes(REVBLO)
Operation:
GReg[r]:{B3,B2,B0,B1} ← GReg[r]:{B3,B2,B1,B0}
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3305

<!-- page 3306 -->

Assembler:
Syntax: revblo r
Example: revblo 0
reverses low order bytes in GReg[0]
CPU Flags: Unaffected
Cycles: 1
Description: Reverse both low order bytes of any General Register.
Instruction Format
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
0
0
0
0
0
r
r
r
0
0
0
1
0
0
0
1
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.41
ROR1 (Rotate Right by 1 Bit)
Operation:
GReg[r]:{b0,b31,b30,...,b1} ← GReg[r]:{b31,b30,...,b1,b0}
Assembler:
Syntax: ror1 r
Example: ror1 3
rotates bits to the right in GReg[3]
CPU Flags: Unaffected
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3306
NXP Semiconductors

<!-- page 3307 -->

Cycles: 1
Description: Rotate the bits of any General Register to the right.
Instruction Format
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
0
0
0
0
0
r
r
r
0
0
0
1
0
1
0
0
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.42
RORB (Rotate Right by 1 Byte)
Operation:
GReg[r]:{B0,B3,B2,B1} ← GReg[r]:{B3,B2,B1,B0}
Assembler:
Syntax: rorb r
Example: rorb 2
rotates bytes to the right in GReg[2]
CPU Flags: Unaffected
Cycles: 1
Description: Rotate the bytes of any General Register to the right.
Instruction Format
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
0
0
0
0
0
r
r
r
0
0
0
1
0
0
1
0
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3307

<!-- page 3308 -->

Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.43
SOFTBKPT (Software Breakpoint)
Operation:
Stops the current script and enters debug mode
Assembler:
softbkpt
CPU Flags: Unaffected
Description: When the core executes this instruction, it has the same effect as receiving a
debug request from the OnCE or via the external debug request input: the script execution
halts, the PCU enters its debug state and waits for the OnCE commands that are described
in OnCE and Real-Time Debug.
Instruction Format
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
0
0
0
0
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
46.5.2.44
ST (Store Register)
Operation:
[GReg[b] + displacement] ← GReg[r]
if (transfer_error)  
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3308
NXP Semiconductors

<!-- page 3309 -->

 DF ← 1 
 else
DF ← 0
Assembler:
Syntax: st r,(b,displacement)
Example: st 7,(0,9) 
stores the value from GReg[7] into memory at address obtained by adding decimal value
9 to GReg[0]
CPU Flags: DF
Cycles: 2+n where n is 0 for ROM, RAM or memory mapped registers, and n is the
number of wait-states of the peripheral for a peripheral access
Description: Adds a 5-bit 0-extended displacement to a base address in General Register
b; the result is the address of the data to store on the DM bus. The data sent on the bus
comes from the source General Register r. If an error occurs during the transfer, the flag
DF is set, else it is cleared.
Instruction Format
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
0
1
0
1
1
r
r
r
d
d
d
d
d
b
b
b
Instruction Fields:
rrr / bbb - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
ddddd - displacement value:
00000 - 0
00001 - 1 
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3309

<!-- page 3310 -->

... 
11111 - 31
46.5.2.45
STF (Store Register in Functional Unit)
Operation:
[fu_address] ← GReg[r] 0
if (transfer_error) 0
DF ← 1 0
else 0
DF ← 0
fu_address is an 8-bit field
Assembler:
Syntax: stf r,fu_address
Example: stf 3,0x2B 
stores the 32-bit contents of GReg[3] to the Burst DMA register MD; waits until the flush
to external memory is completed
CPU Flags: DF
Cycles: 1+n where n is the number of wait-states that may be inserted by the functional
unit
Description: Sends an 8-bit address on the Functional Unit Bus (FU bus) and sends the
contents of the source General Register r on the bus. If an error occurs during the transfer,
the flag DF is set, else it is cleared.
Table 46-47. Instruction Format
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
0
1
1
0
1
r
r
r
f
f
f
f
f
f
f
f
See the following sections for more details of the STF instruction usage with each
functional unit:
• Burst DMA Write (stf) for Burst DMA
• Peripheral DMA Write (stf)-Write Mode for Peripheral DMA
Instruction Fields:
rrr - register field:
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3310
NXP Semiconductors

<!-- page 3311 -->

000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
ffffffff - functional unit destination register and action (unspecified values are reserved):
00000000 - MSA in incremented mode
00000100 - MDA in incremented mode
00001001 - MD byte
00001010 - MD halfword
00001011 - MD word
00001100 - clear MS error flag
00001111 - MS
00010000 - MSA in frozen mode
00010100 - MDA in frozen mode
00011000 - MD in copy mode - number of words in rrr
00100000 - MSA in incremented mode - start prefetch
00101000 - MD no data - flush
00101001 - MD byte - flush
00101010 - MD halfword - flush
00101011 - MD word - flush
00110000 - MSA in frozen mode - start prefetch
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3311

<!-- page 3312 -->

11000001 - PSA in frozen mode - 8-bit data width
11000010 - PSA in frozen mode - 16-bit data width
11000011 - PSA in frozen mode - 32-bit data width
11000101 - PSA in incremented mode - 8-bit data width
11000110 - PSA in incremented mode - 16-bit data width
11000111 - PSA in incremented mode - 32-bit data width
11001000 - PD
11001001 - PSA in decremented mode - 8-bit data width
11001010 - PSA in decremented mode - 16-bit data width
11001011 - PSA in decremented mode - 32-bit data width
11001100 - clear PS error flag
11001101 - PSA data width becomes 8-bit
11001110 - PSA data width becomes 16-bit
11001111 - PSA data width becomes 32-bit
11010001 - PDA in frozen mode - 8-bit data width
11010010 - PDA in frozen mode - 16-bit data width
11010011 - PDA in frozen mode - 32-bit data width
11010101 - PDA in incremented mode - 8-bit data width
11010110 - PDA in incremented mode - 16-bit data width
11010111 - PDA in incremented mode - 32-bit data width
11011001 - PDA in decremented mode - 8-bit data width
11011010 - PDA in decremented mode - 16-bit data width
11011011 - PDA in decremented mode - 32-bit data width
11011101 - PDA data width becomes 8-bit
11011110 - PDA data width becomes 16-bit
11011111 - PDA data width becomes 32-bit
11100001 - PSA in frozen mode - 8-bit data width - prefetch data
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3312
NXP Semiconductors

<!-- page 3313 -->

11100010 - PSA in frozen mode - 16-bit data width - prefetch data
11100011 - PSA in frozen mode - 32-bit data width - prefetch data
11100101 - PSA in incremented mode - 8-bit data width - prefetch data
11100110 - PSA in incremented mode - 16-bit data width - prefetch data
11100111 - PSA in incremented mode - 32-bit data width - prefetch data
11101001 - PSA in decremented mode - 8-bit data width - prefetch data
11101010 - PSA in decremented mode - 16-bit data width - prefetch data
11101011 - PSA in decremented mode - 32-bit data width - prefetch data
11101101 - PSA data width becomes 8-bit - prefetch data
11101110 - PSA data width becomes 16-bit - prefetch data
11101111 - PSA data width becomes 32-bit - prefetch data
11111111- PS
46.5.2.46
SUB (Subtract)
Operation:
GReg[r] ← GReg[r] - GReg[s]
T ← (GReg[r] == 0)
Assembler:
Syntax: sub r,s
Example: sub 4,7 
SUBtracts GReg[7] from GReg[4] and stores the result in GReg[4]
CPU Flags: T
Cycles: 1
Description: Subtracts the source General Register s from the destination General
Register r, and stores the result in the destination General Register r. The T flag is set if
the result of the operation is 0; it is cleared if the result is not 0.
Instruction Format
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
0
0
0
0
0
r
r
r
1
0
1
0
0
s
s
s
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3313

<!-- page 3314 -->

Instruction Fields:
rrr / sss - register fields:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.47
SUBI (Subtract with Immediate)
Operation:
GReg[r] ← GReg[r] - immediate
T ← (GReg[r] == 0)
Assembler:
Syntax: sub r,immediate
Example: sub 1,255 
SUBtracts decimal value 255 from GReg[1] and stores the result in GReg[1]
CPU Flags: T
Cycles: 1
Description: Subtracts a 0-extended 8-bit immediate value from a General Register;
stores the result in the General Register. The flag T is set when the result of the operation
is 0; otherwise, it is cleared. The immediate value is the low-order byte of the instruction
and has a maximum value of 255 (0xFF).
Instruction Format
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
0
0
1
0
0
r
r
r
i
i
i
i
i
i
i
i
Instruction Fields:
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3314
NXP Semiconductors

<!-- page 3315 -->

rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
iiiiiiii - immediate value:
00000000 - 0 
00000001 - 1 
... 
11111110 - 254
11111111 - 255
46.5.2.48
TST (Test with Zero)
Operation:
T ← ((GReg[s] & GReg[r]) != 0)
Assembler:
Syntax: tst r,s
Example: tst 2,3 
ANDs GReg[2] and GReg[3] and sets T if the result is non-null
CPU Flags: T
Cycles: 1
Description: Performs the AND of the source General Register s and the destination
General Register r, and sets T if the result is not 0, clears T if the result is 0.
Instruction Format
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
0
0
0
0
0
r
r
r
1
1
0
0
0
s
s
s
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3315

<!-- page 3316 -->

Instruction Fields:
rrr / sss - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.49
TSTI (Test Immediate)
Operation:
T ← ((GReg[r] & immediate) != 0)
Assembler:
Syntax: tsti r,immediate
Example: tsti 5,13 
ANDs GReg[5] and decimal value 13 and sets T if the result is non-null
CPU Flags: T
Cycles: 1
Description: Performs the AND of a 0-extended 8-bit immediate value and the
destination General Register r, and sets T if the result is not 0, clears T if the result is 0.
The immediate value is the low-order byte of the instruction and has a maximum value of
255 (0xFF).
Instruction Format
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
0
1
0
0
0
r
r
r
i
i
i
i
i
i
i
i
Instruction Fields:
rrr - destination register field:
000 - GReg[0] 
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3316
NXP Semiconductors

<!-- page 3317 -->

001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
iiiiiiii - immediate value:
00000000 - 0 
00000001 - 1 
... 
11111110 - 254
11111111 - 255
46.5.2.50
XOR (Logical Exclusive OR)
Operation:
GReg[r] ← GReg[s] ^ GReg[r]
Assembler:
Syntax: xor r,s
Example: xor 0,3 
XORs GReg[0] and GReg[3] and stores the result in GReg[0]
CPU Flags: Unaffected
Cycles: 1
Description: Performs the eXclusive OR of the source General Register s and the
destination General Register r, and stores the result in the destination General Register r.
Instruction Format
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
0
0
0
0
0
r
r
r
1
0
0
1
0
s
s
s
Instruction Fields:
rrr / sss - register field:
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3317

<!-- page 3318 -->

000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
46.5.2.51
XORI (Exclusive OR with Immediate)
Operation:
GReg[r] ← GReg[r] ^ immediate
Assembler:
Syntax: xori r,immediate
Example: xor 7,5 
XORs GReg[5] and decimal value 5 and stores the result in GReg[7]
CPU Flags: Unaffected
Cycles: 1
Description: Performs an eXclusive OR between a 0-extended 8-bit immediate value and
a General Register; stores the result in the General Register. The immediate value is the
low-order byte of the instruction and has a maximum value of 255 (0xFF).
Instruction Format
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
0
0
0
1
0
r
r
r
i
i
i
i
i
i
i
i
Instruction Fields:
rrr - register field:
000 - GReg[0] 
001 - GReg[1] 
010 - GReg[2] 
011 - GReg[3] 
Instruction Set
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3318
NXP Semiconductors

<!-- page 3319 -->

100 - GReg[4] 
101 - GReg[5] 
110 - GReg[6] 
111 - GReg[7] 
iiiiiiii - immediate value:
00000000 - 0 
00000001 - 1 
... 
11111110 - 254
11111111 - 255
46.5.2.52
YIELD, YIELDGE (DONE, Yield)
By default, unsupported assembler syntax. Can be aliased to the corresponding done
instructions (yield = done 0; yieldge = done 1). Refer to the done instruction description
DONE (DONE, Yield) .
46.6
Software Restrictions
46.6.1
Unsupported Burst DMA Access Sequence
The SDMA does not support triggering a pre-fetch followed by a flush of the Burst DMA
without reading or writing any data. If the flush occurs while the background pre-fetch
DMA operation is still in progress, it could result in un-defined behavior.
An example of the sequence which could result in undefined results is shown in the
following example:
Instruction sequence not supported
          stf r1, MSA|PF         ; Update source address, triggers data pre-fetch in the
                                 ; background
          mov R0,R0              ; Execute multiple assembly instructions, none of which
                                 ; read
          mov R0,R0              ; or write data to/from MD
          stf MD|SZ0|FL          ; Flush FIFO without writing data. If the pre-fetch is still
                                 ; in progress when this instruction is executed, there
                                 ; could be undefined operation
        
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3319

<!-- page 3320 -->

A work-around to avoid any undesirable results is to first read MD to ensure the pre-fetch
is complete before the flush is attempted.
Work-Around to previous example
          stf r1, MSA|PF         ; Update source address, triggers data pre-fetch.
          mov R0,R0              ; Execute multiple assembly instructions, none of which
                                 ; read 
          mov R0,R0              ; or write data to/from MD
          ldf r2, MD             ; dummy read of MD to ensure pre-fetch is complete
                                 ; before the next instruction
          stf MD|SZ0|FL          ; Flush FIFO without writing data
        
46.7
Application Notes
46.7.1
Data Structures for Boot Code and Channel Scripts
SDMA boot code downloads the different channel contexts and the scripts that will be
executed on SDMA channels during the application.
The boot code is run after reset when channel 0 is started by the Arm platform. The boot
code is also known as channel 0 script.
The boot code is based on the Channel Control Block (CCB) and Buffer Descriptor (BD)
mechanisms that are data structures located into the Arm platform memory space. With
these data structures, it is possible to instruct SDMA to download scripts and contexts but
also to dump a context or a script to a destination data buffer. Channel scripts also use the
CCB and BD data structures to pass instructions and/or pointers to data to be copied.
The format, processing, and field definition of the CCB and BD are defined and
performed entirely by the software script rather than the SDMA hardware. An overview
of the format and structure is provided here, but for complete details refer to the SDMA
software documentation (see SDMA Scripts).
The CCB and BD data structures are accessed by SDMA using DMA and processed by
the SDMA scripts. The ROM contains common sub-routines for processing these data
structures which may be called by the bootload and channel scripts.
Application Notes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3320
NXP Semiconductors

<!-- page 3321 -->

currentBDptr
baseBDptr
chanDesc
status
currentBDptr
baseBDptr
chanDesc
status
currentBDptr
baseBDptr
chanDesc
status
CCB0
CCB1
CCB31
Command
Flags
Count
Buffer Address
Extended Buffer Address
Command
Flags
Count
Buffer Address
Extended Buffer Address
Data Buffer
Data Buffer
Buffer Descriptor Array
Channel Control Block
MC0PTR
Figure 46-16. Data Structures Layout
The previous figure shows an example how these data structures are linked to pass
command and pointers to data buffers. The SDMA's MC0PTR register holds the base
address of the Channel 0 Control Block (CCB0). The Channel 0 control block holds a
pointer to the array of buffer descriptors. The buffer descriptors are used to tell the
channel 0 (boot channel) what to do as described Buffer Descriptor Format.
46.7.1.1
Buffer Descriptor Format
Buffer descriptors are three longs (32-bit words) in size as, shown in the figure found
here.
A buffer descriptor describes the properties of the data buffer it points to. The buffer
descriptors can be used for linear or circular data buffers in the Arm platform processor
memory. The CCB contains a pointer to the base BD as well as the current BD.
Table 46-48. Buffer Descriptor
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
Command
-
-
L
R
I
C
W
D
Count
Buffer Address
Extended Buffer Address
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3321

<!-- page 3322 -->

Table 46-49. Buffer Descriptor Field Descriptions
Field
Description
31-24
Command
Command. The command field is used to differentiate operations performed within a script when the script
accesses this particular buffer descriptor. The use of this field can be defined by the script. The command values
defined for the bootload script are defined in Buffer Descriptor Commands for Bootload scripts. Refer to the
individual script definition in script library documents in SDMA Scripts for command field definitions for other
scripts.
23
Reserved
22
Reserved
21
L
Last Buffer Descriptor: This bit is set in SDMA IPC scripts to indicate to the receiving Core that the transfer has
ended. Whenever the source finishes transferring the count it wanted to transfer, it sets LAST_BIT in the
destination BD, to let the destination know that transfer is over.This bit also tells the destination software that
when it processes the destination BDs, they need not process any BD after the BD with the LAST_BIT set.For
example, when the DSP prepares a single buffer descriptor with count equals to 25 and Arm platform prepares a
single buffer descriptor with count equals 100. When 25 bytes have been transferred from DSP to Arm platform,
the DSP buffer descriptor is normally closed while the Arm platform buffer descriptor will have the L bit set and
the byte count updated to 25.
20
R
erroR. Indicates an error occurred on the channel's buffer descriptor requested command. Some scripts may
overwrite the command field with an error code indicating the source of the error.
0 No Error
1 Error
19
I
Interrupt. When SDMA has finished to process data transfer attached to this buffer descriptor, send an interrupt
to the Arm platform.
0 No Interrupt
1 Interrupt the processor when BD is complete
18
C
Continuous. This buffer is allowed to receive multiple transmit buffers or is allowed to transmit to multiple receive
buffers.The Continuous bit is decoded at the end of the processing of a BD to determine if the SDMA script must
open a new BD to potentially continue the data transfer.
0 No further buffer descriptors
1 SDMA should move to the next Buffer descriptor after this one
17
W
Wrap. Indicates if this buffer descriptor is the last one for the channel control block. When encountering this bit
set, the SDMA scripts updates the CurrentBD pointer to point to the first Buffer Descriptor of the array. This bit is
set if the Arm platform wants to organize the array of BD in a circular way (like a ring). When all BD have been
processed and if Wrap bit and CONtinuous bit are set in the last BD, the SDMA script will wrap around and it will
try to re-open the first BD.
0 No Error
1 Wrap to first buffer descriptor after this one is processed.
16
D
D - "Done": bit 16: indicates the "ownership" of the buffer descriptor. When D=0 the host owns the buffer
descriptor; when D=1 SDMA owns the buffer descriptor. In the case of the channel 0, D=1 indicates the SDMA
has not yet processed this buffer, D=0 indicates the SDMA has processed this buffer.
0 Arm platform owns the buffer.
1 SDMA owns the buffer
15-0
Count
Count. the count field (bit 15-0) indicates the size of the data to be transmitted, the size of the data buffer pointed
to by the buffer descriptor. The SDMA memory structure is different for program memory (16-bits shorts/half-
words) and data memory (32-bits long). For channel 0 buffer descriptors, Count is expressed in 16-bit half-words
when PM is addressed and in 32-bit words when DM is addressed. Count is typically expressed in bytes for
other channel scripts, but the unit is dependant on the script.
31-0
Buffer address. Address pointer to the data buffer.
31-0
Extended buffer address. Additional pointer or other information required by some scripts.
Application Notes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3322
NXP Semiconductors

<!-- page 3323 -->

The buffer descriptors form an array of programmable size. If the last buffer descriptor is
marked by the Wrap flag-bit W=1, the array of buffer descriptor is treated as a ring with
some logically continuous portion owned by the Arm platform with D=0, and the
remainder owned by the SDMA with D=1. The count field of the buffer descriptor
indicates how much data has been transmitted.
If Arm platform has prepared 3 buffers to be filled by the SDMA script, it has also
prepared 3 BD, one for each buffer. The Cont and Wrap bits are used to organize the
buffers in a circular way. For example, CONTinous bit is set to 1 in the 2 first BDs and
Wrap is set in the 3rd BD. The SDMA script opens and processes BD#1. Since
CONTinous bit is set for this BD, the SDMA will open the second BD and it will process
it. Each time a BD is processed, its Done bit is reset by the SDMA. After the 3rd BD, if
CONTinous is not set but if Wrap is set, the SDMA script stops here and the next time the
channel will be triggered, the script will open the BD pointed by the currentBDptr pointer
of the CCB and it will correspond to the first buffer descriptor.
If the CONTinous bit and Wrap bits are both set in the 3rd BD, the script will close it and
it will try to open the first BD. An error may occur at this point if the BD#1 has already
been processed and its Done bit is 0. The SDMA script cannot process a BD with a Done
bit to 0. It means the BD is not ready to be processed. To avoid this situation, the
CONTinous bit should not be set for the last BD if Wrap is set, and the Interrupt flag
must set for the last BD. It will warn the owner of the BD that all the BDs have been
processed and it has to re-set to 1 the Done bit of all the BD's if it desires the SDMA to
fill them again. Basically, if the Arm platform expects the SDMA to fill up the buffers in
a circular fashion, then it's the responsibility of the Arm platform to set the Done bit of a
buffer descriptor at an appropriate time.
AP  BD1, BD2 & BD3 
CD
25
CD
50
IWD
Buffer 1
(25 bytes)
Buffer 2
(50 bytes)
Buffer 3
(25 bytes)
25
Interrupt to AP
(HI)
SDMA
Incoming Data
AP MEM
Figure 46-17. Buffer Descriptor Flow
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3323

<!-- page 3324 -->

The previous figure shows an example buffer descriptor flow. When the incoming data is
stored and fills the first buffer of 25 bytes, the SDMA script opens the second BD
because the CONTinuous bit was set. Then next incoming data is put in the second
buffer. After receiving 50 bytes, the second buffer descriptor is also closed. The Done bit
is reset and the third BD is opened. After receiving another 25 bytes, the third buffer is
full and an interrupt is sent to the Arm platform because the Interrupt flag is set in the 3rd
BD. The CONTinuous flag is not present the transfer is over. The next time the script will
be triggered, the BD to be opened will be the first buffer descriptor since the Wrap flag
was set in the 3rd BD. It is the Arm platform responsibility to set the Done bit of all the
BD if it wants to use the same buffers.
46.7.1.2
Buffer Descriptor Commands for Bootload scripts
The command field of the buffer descriptor is defined separately for each script.
The following table lists the buffer descriptor commands defined for the channel 0
bootload script.
Table 46-50. Channel Zero Buffer Descriptor Commands
Command
Field
(binary)
Command
Description
Buffer Address
Extended Buffer
Address
0000_0001
(0x01)
C0_SET_DM
Load SDMA data memory (RAM) from Arm
platform memory buffer
Arm platform memory
source address
SDMA memory
destination address
0000_0010
(0x02)
C0_GET_DM
Copy SDMA data memory (RAM) to Arm
platform memory buffer
Arm platform memory
destination address
SDMA memory source
address
0000_0100
(0x04)
C0_SET_PM
Load SDMA program memory (RAM) from
Arm platform memory buffer
Arm platform memory
source address
SDMA memory
destination address
0000_0110
(0x06)
C0_GET_PM
Copy SDMA program memory (RAM) to Arm
platform memory buffer
Arm platform memory
destination address
SDMA memory source
address
cccc_c111
(0x07 | CHN)
C0_SETCTX
Load Context for channel cccc into SDMA
RAM from Arm platform memory buffer
Arm Platform memory
source address
-
cccc_c011
(0x03 | CHN)
C0_GETCTXT Copy Context for channel ccccc from SDMA
RAM to Arm platform memory buffer
Arm platform memory
destination address
-
The Channel 0 bootload commands are summarized as follows:
• C0_SET_[PM-DM]: load the buffer descriptor data in the SDMA local memory at
the address pointed to by the "extended buffer address" field. The SDMA RAM can
be seen as a Program Memory (PM, 16-bit address) or Data Memory (DM 32-bit
address). When C0_SET_PM is used, the count field is expressed in "shorts" (16-bit
Application Notes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3324
NXP Semiconductors

<!-- page 3325 -->

half words), this command can be used to download scripts. When C0_SET_DM is
used, the count field is expressed in "long" (32-bit words), this command can be used
to download channel contexts to the context channel area in RAM.
• C0_GET_[PM-DM]: write to the buffer descriptor's data buffer the content of the
SDMA local memory from the address pointed to by the "extended buffer address"
field for the length defined by the count in the buffer descriptor. C0_GET_PM is
used to dump some part of the Program Memory (may be used to dump context of a
channel), therefore count is expressed in "shorts"; while C0_GET_DM is used to
dump to the buffer descriptor's data buffer, so the count field is in "longs."
• C0_SETCTX: load a context into the SDMA context page area. The handling script
decodes the channel number from the 5 MSB of the command field of the buffer
descriptor. Using the channel number the script computes the offset of the context
data pointer for the channel relative to the context page base to use as the destination
address in SDMA memory. Then the C0_SET_DM command explained above is
invoked to load SDMA RAM from memory. The counter indicates the size in words
of the context structure.
• Command value: (in binary) cccc c111, where ccccc is the channel number (5 bits).
For instance, 0x0F means set context for channel 1, 0xFF means set context for
channel 31.
• C0_GETCTX: write to the buffer descriptor's data buffer the content of the SDMA
context page area. The handling script decodes the channel number from the 5 MSB
of the command field of the buffer descriptor. Using this channel number, the script
computes the offset of the context data pointer for the channel relative to the context
page base to use as the source address for the copy. Then the C0_GET_DM
command explained above is invoked to copy the context to memory. The counter
indicates the size in words of the context structure.
• Command value: (in binary): cccc c011, where ccccc is the channel number (5 bits).
For instance, 0x03 means get context of channel 1, 0xFB means get context of
channel 31.
NOTE
To download channel context, C0_SETDM and
C0_SETCTXT command can be used but the second one is
easier because the channel number is embedded into the
command field, whereas with the C0_SETDM, the pointer
to the channel context area must be written into the
extended buffer address field of the buffer descriptor.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3325

<!-- page 3326 -->

46.7.1.3
Example of Buffer Descriptors for Channel 0.
Figure 46-19 illustrates the buffer descriptors that must be set in Arm platform memory
space, before execution of boot code, to download contexts and scripts of channels 1, 4,
and 10. After boot code execution, SDMA memory will be populated with the different
contexts and scripts as presented in the following figure.
Channel 1 Context
Channel 4 Context
Channel 10 Context
Channel 1 Script
Channel 4 Script
Channel 10 Script
0x800
0x820
0x880
0x960
0xC00
Content
Area
Scripts and Data
Area
SDMA RAM
Figure 46-18. Example of SDMA RAM After Boot Session
Application Notes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3326
NXP Semiconductors

<!-- page 3327 -->

0
0
1
Buffer Address
Extended Buffer Address (Unused)
0
0
1
Buffer Address
Extended Buffer Address
0
0
1
0
1
Buffer Address
Extended Buffer Address
31
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
0
01010111
20
00000100
10
00000100
40
AP Memory Space
Channel 1 context
(32 longs)
Channel 4 context
(32) longs)
Channel 10 context
(32 longs)
Channel 1 script
(16 shorts)
Channel 4 script
(64 shorts)
Channel 10 script
(80 shorts)
SDMA Register
Channel 0 Buffer Descriptor Array
MC0PTR
Channel Control Block
CurrentBDptr
BaseBDptr
chanDesc
status
BD1 - SET CONTEXT CH#1
BD2 - SET CONTEXT CH#4
BD3 - SET CONTEXT CH#10
BD4 - SET_PM
BD5 - SET_PM
BD6 - SET_PM
Interrupt = 0,
Cont=1, Done = 1
Interrupt = 0,
Cont=1, Done = 1
Interrupt = 0,
Cont=1, Done = 1
Interrupt = 0,
Cont=1, Done = 1
Interrupt = 0,
Cont=1, Done = 1
Interrupt = 1,
Cont=0, Done = 1
SDMA RAM
Context Area
Scripts Area
0
0
1
Buffer Address
Extended Buffer Address (Unused)
00100111
20
0
0
1
Buffer Address
1
0
0
0
0
1
1
1
Extended Buffer Address (Unused)
00001111
20
0
0
1
0
1
Buffer Address
Extended Buffer Address
00000100
50
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3327

<!-- page 3328 -->

46.7.1.4
Channel Context
There are 32 channel context memory structures pointed to by the local save area pointer.
These channel context memory structures are fixed.
The script in the SDMA computes the memory offset for a given channel based on the
structure length and channel number. Figure below shows the structure of the channel
context as it is saved in the SDMA local memory (RAM).
A channel context consists in 24 words, one per register. A total of 32 words are reserved
for every channel. The additional 8 words are called scratch ram and they are dedicated to
each channel. This memory area is commonly used for stack management.
The structure is divided in 4 areas:
• Channel status registers
• General purpose registers
• Functional units state registers reflecting the state of the Arm platform DMAs (Burst
and Peripheral DMA).
• Scratch RAM
The details of the channel context status registers are described in the following figure.
The PC field of the first long register must point to the SDMA RAM address where the
script that will be executed on the channel is located and this value equals the one stored
in the extended buffer address of the buffer descriptor with C0_SETPM command.
SF: Source fault while loading data
RPC: Return program counter
T: Test bit: status of arithmetic and test instructions
PC: Program counter
LM: Loop mode
EPC: Loop end program counter
DF: Destination fault while storing data
SPC: Loop Start program counter 
SF _
LM
RPC
EPC
T
_
PC
SPC
_
DF
31
30
29
16 15
14
13
0
Figure 46-20. SDMA State Registers (ShPC, ShLoop)
Application Notes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3328
NXP Semiconductors

<!-- page 3329 -->

46.7.2
Typical Data Transfer Supported by SDMA DMA Units
This section presents a library of SDMA scripts that perform data transfers through the
peripheral DMA and the burst DMA units.
The Arm platform memory and peripherals are devices that either the peripheral DMA or
the burst DMA can access. The scripts are given for a peripheral DMA whose address
registers are programmed in incremented mode when internal memory is involved. See
the following table for the summary.
Table 46-51. Typical Data Transfers Summary
Data Transfer
Peripheral DMA
Burst DMA
Comments
Arm platform External Memory ↔
Arm platform External Memory
3
Copy mode
Script example, see Burst DMA Unit Copy
Mode and External Memory to External
Memory.
Arm platform Peripheral ↔ Arm
platform Peripheral
3
Copy mode if same data path width
Script example, see Peripheral to Peripheral
Transfer.
Arm platform External Memory ↔
Arm platform Peripheral
3
3
Data transit through SDMA
Script example, see Transfer Between
Peripheral and External Memory.
Arm platform External Memory ↔
Arm platform Internal Memory
3
Copy mode
Script example, see Transfer Between
External Memory and Internal Memory.
Arm platform Internal Memory ↔ Arm
platform Internal Memory
3
Copy mode
Script example, see Internal Memory to
Internal Memory.
Arm platform Internal memory ↔ Arm
platform Peripheral
3
Data transit through SDMA
Script example, see Transfer Between
Peripheral and Internal Memory.
NOTE
These scripts are provided as examples of how to use DMA
blocks to perform required data transfers: They are not
"official" programs.
46.7.2.1
External Memory to External Memory
This section describes the SDMA script that performs data moves in external memory.
For this particular data transfer, only the burst DMA is used. It is programmed in copy
mode, so no data transmits through an SDMA general register.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3329

<!-- page 3330 -->

The SDMA core only monitors data transfer status. It is assumed source and destination
address values are already present in two SDMA general registers (r1 and r2). For this
example, it is also assumed that a 32-bit word-to-move for source-to-destination address
is present in r0 and equals 64.
Data Moves in External Memory
1         stf r1,MSA                           // Source address setup
2         stf r2,MDA                           // Destination address setup
3         ldi r0,0x64                          // 64 words must be transferred from MSA to 
MDA
4         ldi r1,0x8
MAIN_XFER:
5         cmphs r0,r1                          // Is r0 >= 0x8
6         bf LAST_XFER                     // If not, jump to last transfer label
7         stf r1,MD|CPY                         // Copy 8 words from MSA to MDA address.
8         subi r0,0x8                          // Decrement counter
9         jmp MAIN_XFER                     // return to main transfer loop
LAST_XFER:
10        stf r0,MD|CPY                         // perform last transfer
All instructions are performed in one cycle (jumps excepted). Instruction 7 triggers a
copy transfer: A read burst access of 8-word starts, data is staged in MD and then a write
burst of 8 words is executed. Instruction 8, 9, 5, and 6 are executed while the burst access
is in progress. If this access is not complete when instruction 7 is executed a second time,
SDMA stalls on this instruction as long as the previous copy transfer is not over. In this
case, the instruction is no longer a one-cycle instruction.
During the main loop (MAIN_XFER), r1 always equals 8, so burst lengths are 8 words.
On the last ldf |CPY instruction (10), r1 equals the reminder of r0 divided by 8; therefore,
the length of bursts triggered in copy mode equal r1 value, which is between 1 and 7.
46.7.2.2
Peripheral to Peripheral Transfer
For this data transfer, only the peripheral DMA is used.
It is programmed in copy mode, so no data will transmit through the SDMA general
register used in the ldf instruction, but the contents of the general register are lost. The
SDMA core only monitors the transfer.
Application Notes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3330
NXP Semiconductors

<!-- page 3331 -->

46.7.2.2.1
Source and Destination Target Have the Same Data Path Width
When the source and destination target have the same data path width, the following is
true:
• Source target is a half-word (16-bit) peripheral located at address 0x1002.
• Destination is a half-word (16-bit) peripheral located at address 0x2006.
It is assumed the address values are already present in two SDMA general registers (r1,
r2). The script for a transfer of 10 half-word is as follows:
Same Data Path Width for Source and Destination
//SETUP SECTION
1         stf r1, PSA|SZ16|F                     //r1=0x1002 Source address register setup
2         stf r2, PDA|SZ16|F                     //r2=0x2006 Destination address register 
setup
3         bdf ERROR_ADDR_SETUP
4         ldi r0,0xa                           //loop counter is 10
//MAIN LOOP TRANFER
copy_loop:
5         loop 2,0
6           ldf r7,PD|CPY                      //Reads 1 half-word from src and writes to 
dest.
7           yield
8         bdf ERROR_DURING_XFER
ERROR_ADDR_SETUP:
                    //correction of PSA/PDA setup and jumps to main loop transfer
ERROR_DURING_XFER:
//flag error is set,
//PS can be read to know if error occurs during read or write access.
If a data transfer must occur between two word peripherals, only the setup section should
be updated. The transfer itself is always performed by the hardware loop instruction.
All instructions are executed in one cycle (change of flow excepted). On instruction 6, a
single read access is triggered, read data is staged in PD, and a write-to-destination is
executed. When the transfers are in progress, the SDMA can execute he next instructions
in parallel. If instruction 6, which performs the copy transfer, is executed while the
previous access is not over, SDMA is stalled and instruction ldf is a multi-cycle
instruction.
46.7.2.2.2
Source and Destination Target Have a Different Data Path Width
When the source and destination target have a different data path width, copy mode
cannot be used, and any attempt to initiate a copy transfer immediately raises an error,
which is stored in the SF flag.
The following example shows the SDMA code that could transfer 10 words from a word
(32-bit) peripheral to a half-word peripheral whose addresses are preliminary and stored
in r1 and r2.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3331

<!-- page 3332 -->

Different Data Path Width for Source and Destination
//SETUP SECTION
1         stf r1, PSA|SZ32|F|PF                   //r1=0x1000 and prefetch data
2         stf r2, PDA|SZ16|F                     //r2=0x2006
3         bdf ERROR_ADDR_SETUP
4         ldi r0,0xa                           //loop counter is 10
//MAIN LOOP TRANFER
main_loop_xfer_16_16:
5         loop 6,0
6           ldf r7,PD                         //copy 32-bit of PD in r7
7           stf r7,PD                          //store 16 LSB of r7 in PD and a flush is 
executed
8           rorb r7
9           rorb r7                          //16 MSB --> 16 LSB
10          stf r7,PD                          //store 16 LSB of r6 in PD and a flush.
11          yield
On instruction 1, when the source address register is programmed and a data prefetch is
required, a read access is executed. In parallel, the SDMA executes instructions 2 to 5.
On instruction 6, the SDMA tries to read data that was fetched by instruction 1. If data is
ready, the ldf will be a one cycle instruction; otherwise, the SDMA is stalled as long as
the read access is not finished. Then, the 16 LSB of the read data is stored in PD and
automatically flushed to the destination peripheral. In parallel, the SDMA executes the
rotation instructions (8, 9), and stores the 16 MSB of the read data into PD. If a previous
write access is finished, instruction 10 will be a one-cycle instruction.
The main loop transfer may appear inefficient, but due to wait states imposed to the
peripheral DMA each time an external access is performed, a software pipeline is in
place. During the time needed to flush PD, the SDMA executes the move and rotation
operations. SDMA executes instructions in parallel with DMA accesses.
46.7.2.3
Transfer Between Peripheral and External Memory
46.7.2.3.1
Peripheral to External Memory Transfer
A transfer from a peripheral to the external memory controller involves the peripheral
DMA and the burst DMA.
The code for transferring 100 word from word peripheral to the external memory would
be as follows:
Peripheral to External Memory Transfer
//SETUP SECTION source and destination addresses are already in r1 and r2
1         stf r1, PSA|SZ16|F|PF                   //r1=0x1000 and prefetch 32-bit data
2         stf r2, MDA                          //r2=0x2000, setup burst DMA destination 
address
3         bdf ERROR_ADDR_SETUP
4         ldi r0,0x64                          //loop counter is 100
5
          //MAIN LOOP TRANFER
6         loop 3,0
Application Notes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3332
NXP Semiconductors

<!-- page 3333 -->

7           ldf r1,PD|PF                       // read 32 bits of PD and initiate a new read 
access.
8           stf r1,MD|32                        // store 32 bits of r1 in the MD fifo.
9           yield
10        ldf r1,PD                           // last word data is read
11        stf r1,MD|32|FL                        // to flush all remaining bytes of MD
On instruction 1, the source address register of the peripheral DMA is programmed and
data is fetched. This data is stored in PD and the SDMA reads PD during instruction 7,
which is a one-cycle instruction that is read-access finished. On the same instruction (7),
a data prefetch is required and a read access to the source peripheral is executed. In
parallel, the SDMA stored the previous read data into the data register of MD. When MD
(which is an eight-word FIFO) is full, a burst write access is executed to empty the FIFO.
As long as the next SDMA instructions do not access the burst DMA, they will be one-
cycle instructions. The following figures show how the peripheral DMA and burst DMA
work in parallel.
1
2
3
data 0
data 1
ldf PD
stf MD
yield
ldf PD
stf MD
yield
stf MD
yield
Idf PD
1 wait state
2 wait states
data -1
data 0
data 1
data -1
data 0
data 1
data -1
Clk
PD
r1
MD
data -1
data 0
data -1
data 0
data 1
SDMA
Instruction
peripheral
DMA port
Figure 46-21. Peripheral to External Memory Example (1)
As seen in the figure above, the read access triggered by the ldf PD instruction is
symbolized by the blue bar when in progress. After wait states, the read data (data 0, data
1) is stored in PD on the clk rising edge. On edge 2, data 0 is available in PD so it can be
transferred to the SDMA general register r1, and then stored in MD FIFO. On edge 3,
data 1 is not in PD; therefore, SDMA is stalled on the ldf instruction, which lasts two
cycles. The figure below shows an example of when MD FIFO is full with data.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3333

<!-- page 3334 -->

1
2
3
data 8
data9
ldf PD
stf MD
yield
ldf PD
stf MD
yield
Idf PD
data 7
data 8
data 9
data 7
data 8
data 9
Clk
PD
r1
MD
SDMA
Instruction
peripheral
DMA port
Burst DMA 
port
 
8-word burst
4 wait-states
ack
ack
ack
ack
stf MD
data 0
data 1
data 2
data 3
data 4
data 5
data 6
data 7
data 1
data 2
data 3
data 4
data 5
data 6
data 7
data 8
data 2
data 3
data 4
data 5
data 6
data 7
data 8
data 3
data 4
data 5
data 6
data 7
data 8
Figure 46-22. Peripheral to External Memory Example (2)
In the previous figure, the write bar means the burst DMA is performing a write burst
access. The latency to have the first write acknowledge is four cycles. SDMA is stalled
on instruction stf because no acknowledge was received, MD FIFO is full, and there is no
empty slot to store data 9. When an acknowledge is sampled by the burst DMA, FIFO is
shifted and data 8 is written. As long as there is at least one empty slot in MD FIFO, the
stf MD instruction lasts one cycle.
46.7.2.3.2
External Memory to Peripheral Transfer
A transfer from the external memory to a peripheral involves the peripheral DMA and the
burst DMA.
The code for transferring 100 word from external memory to a word peripheral would be
as follows:
External Memory to Peripheral Transfer
//SETUP SECTION source and destination addresses are already in r1 and r2
1         stf r1, MSA|PF             //r1=0x1000 and starts a 8-word read burst
2         stf r2, PDA|SZ32|P          //r2=0x2010, setup peripheral DMA destination address
3         bdf ERROR_ADDR_SETUP
4         ldi r0,0x64               //loop counter is 100
//MAIN LOOP TRANFER
6         loop 3,0
Application Notes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3334
NXP Semiconductors

<!-- page 3335 -->

7           ldf r1,MD|32|PF          // read 32 bits of MD and initiate a new read access
                               // if MD is empty after this reading.
8           stf r1,PD               // store 32 bits of r1 in the PD.
9           yield
          10 ldf r1,MD|32            // last word data is read
11        stf r1,PD                 // last write access
On instruction 1, a read burst of 8 words begins. Read data is staged into MD. On
instruction 7 (and if data is available in MD), 32 bits are copied into r1. Then instruction
8 writes them into PD and an automatic flush is executed. The SDMA core, peripheral
DMA, and burst DMA can work in parallel as long as no SDMA instruction tries to start
a new write access on the peripheral DMA while the previous access is still in progress,
or as long as there is data in MD when the SDMA tries to read it.
46.7.2.4
Transfer Between External Memory and Internal Memory
Since the internal memory (Arm platform RAM) is accessed via the peripheral DMA and
the external memory is accessed via the burst DMA, the SDMA scripts that are described
in Transfer Between Peripheral and External Memory can be reused. The exception is
that the peripheral DMA address registers (PSA or PDA, depending on the script) should
be programmed in incremented mode rather than frozen mode.
46.7.2.4.1
Internal Memory to Internal Memory
The internal memory can only be accessed via the peripheral DMA, so the script
described in Peripheral to Peripheral Transfer can be reused with a different
programming of the peripheral DMA address registers.
46.7.2.4.2
Transfer Between Peripheral and Internal Memory
For this transfer, the peripheral DMA is also used in copy mode.
The SDMA script is very similar to the one described in Peripheral to Peripheral
Transfer, except for the peripheral DMA address registers programming.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3335

<!-- page 3336 -->

46.8
Arm Platform Memory Map and Control Register
Definitions
The Arm platform controls the SDMA by means of several interface registers. Those
registers are described in the current section.
All registers are clocked with the SDMA clock (which means the Arm platform must
ensure that the SDMA clock is running when it wants to access any register).
SDMAARM memory map
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
20E_C000
Arm platform Channel 0 Pointer (SDMAARM_MC0PTR)
32
R/W
0000_0000h
46.8.1/3341
20E_C004
Channel Interrupts (SDMAARM_INTR)
32
w1c
0000_0000h
46.8.2/3341
20E_C008
Channel Stop/Channel Status (SDMAARM_STOP_STAT)
32
w1c
0000_0000h
46.8.3/3341
20E_C00C
Channel Start (SDMAARM_HSTART)
32
R/W
0000_0000h
46.8.4/3342
20E_C010
Channel Event Override (SDMAARM_EVTOVR)
32
R/W
0000_0000h
46.8.5/3342
20E_C014
Channel BP Override (SDMAARM_DSPOVR)
32
R/W
FFFF_FFFFh 46.8.6/3343
20E_C018
Channel Arm platform Override (SDMAARM_HOSTOVR)
32
R/W
0000_0000h
46.8.7/3343
20E_C01C
Channel Event Pending (SDMAARM_EVTPEND)
32
w1c
0000_0000h
46.8.8/3343
20E_C024
Reset Register (SDMAARM_RESET)
32
R
0000_0000h
46.8.9/3344
20E_C028
DMA Request Error Register (SDMAARM_EVTERR)
32
R
0000_0000h
46.8.10/
3345
20E_C02C
Channel Arm platform Interrupt Mask
(SDMAARM_INTRMASK)
32
R/W
0000_0000h
46.8.11/
3345
20E_C030
Schedule Status (SDMAARM_PSW)
32
R
0000_0000h
46.8.12/
3346
20E_C034
DMA Request Error Register (SDMAARM_EVTERRDBG)
32
R
0000_0000h
46.8.13/
3346
20E_C038
Configuration Register (SDMAARM_CONFIG)
32
R/W
0000_0003h
46.8.14/
3347
20E_C03C
SDMA LOCK (SDMAARM_SDMA_LOCK)
32
R/W
0000_0000h
46.8.15/
3348
20E_C040
OnCE Enable (SDMAARM_ONCE_ENB)
32
R/W
0000_0000h
46.8.16/
3349
20E_C044
OnCE Data Register (SDMAARM_ONCE_DATA)
32
R/W
0000_0000h
46.8.17/
3350
20E_C048
OnCE Instruction Register (SDMAARM_ONCE_INSTR)
32
R/W
0000_0000h
46.8.18/
3350
20E_C04C
OnCE Status Register (SDMAARM_ONCE_STAT)
32
R
0000_E000h
46.8.19/
3350
20E_C050
OnCE Command Register (SDMAARM_ONCE_CMD)
32
R/W
0000_0000h
46.8.20/
3352
Table continues on the next page...
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3336
NXP Semiconductors

<!-- page 3337 -->

SDMAARM memory map (continued)
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
20E_C058
Illegal Instruction Trap Address (SDMAARM_ILLINSTADDR)
32
R/W
0000_0001h
46.8.21/
3353
20E_C05C
Channel 0 Boot Address (SDMAARM_CHN0ADDR)
32
R/W
0000_0050h
46.8.22/
3353
20E_C060
DMA Requests (SDMAARM_EVT_MIRROR)
32
R
0000_0000h
46.8.23/
3354
20E_C064
DMA Requests 2 (SDMAARM_EVT_MIRROR2)
32
R
0000_0000h
46.8.24/
3354
20E_C070
Cross-Trigger Events Configuration Register 1
(SDMAARM_XTRIG_CONF1)
32
R/W
0000_0000h
46.8.25/
3355
20E_C074
Cross-Trigger Events Configuration Register 2
(SDMAARM_XTRIG_CONF2)
32
R/W
0000_0000h
46.8.26/
3357
20E_C100
Channel Priority Registers (SDMAARM_SDMA_CHNPRI0)
32
R/W
0000_0000h
46.8.27/
3358
20E_C104
Channel Priority Registers (SDMAARM_SDMA_CHNPRI1)
32
R/W
0000_0000h
46.8.27/
3358
20E_C108
Channel Priority Registers (SDMAARM_SDMA_CHNPRI2)
32
R/W
0000_0000h
46.8.27/
3358
20E_C10C
Channel Priority Registers (SDMAARM_SDMA_CHNPRI3)
32
R/W
0000_0000h
46.8.27/
3358
20E_C110
Channel Priority Registers (SDMAARM_SDMA_CHNPRI4)
32
R/W
0000_0000h
46.8.27/
3358
20E_C114
Channel Priority Registers (SDMAARM_SDMA_CHNPRI5)
32
R/W
0000_0000h
46.8.27/
3358
20E_C118
Channel Priority Registers (SDMAARM_SDMA_CHNPRI6)
32
R/W
0000_0000h
46.8.27/
3358
20E_C11C
Channel Priority Registers (SDMAARM_SDMA_CHNPRI7)
32
R/W
0000_0000h
46.8.27/
3358
20E_C120
Channel Priority Registers (SDMAARM_SDMA_CHNPRI8)
32
R/W
0000_0000h
46.8.27/
3358
20E_C124
Channel Priority Registers (SDMAARM_SDMA_CHNPRI9)
32
R/W
0000_0000h
46.8.27/
3358
20E_C128
Channel Priority Registers (SDMAARM_SDMA_CHNPRI10)
32
R/W
0000_0000h
46.8.27/
3358
20E_C12C
Channel Priority Registers (SDMAARM_SDMA_CHNPRI11)
32
R/W
0000_0000h
46.8.27/
3358
20E_C130
Channel Priority Registers (SDMAARM_SDMA_CHNPRI12)
32
R/W
0000_0000h
46.8.27/
3358
20E_C134
Channel Priority Registers (SDMAARM_SDMA_CHNPRI13)
32
R/W
0000_0000h
46.8.27/
3358
20E_C138
Channel Priority Registers (SDMAARM_SDMA_CHNPRI14)
32
R/W
0000_0000h
46.8.27/
3358
20E_C13C
Channel Priority Registers (SDMAARM_SDMA_CHNPRI15)
32
R/W
0000_0000h
46.8.27/
3358
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3337

<!-- page 3338 -->

SDMAARM memory map (continued)
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
20E_C140
Channel Priority Registers (SDMAARM_SDMA_CHNPRI16)
32
R/W
0000_0000h
46.8.27/
3358
20E_C144
Channel Priority Registers (SDMAARM_SDMA_CHNPRI17)
32
R/W
0000_0000h
46.8.27/
3358
20E_C148
Channel Priority Registers (SDMAARM_SDMA_CHNPRI18)
32
R/W
0000_0000h
46.8.27/
3358
20E_C14C
Channel Priority Registers (SDMAARM_SDMA_CHNPRI19)
32
R/W
0000_0000h
46.8.27/
3358
20E_C150
Channel Priority Registers (SDMAARM_SDMA_CHNPRI20)
32
R/W
0000_0000h
46.8.27/
3358
20E_C154
Channel Priority Registers (SDMAARM_SDMA_CHNPRI21)
32
R/W
0000_0000h
46.8.27/
3358
20E_C158
Channel Priority Registers (SDMAARM_SDMA_CHNPRI22)
32
R/W
0000_0000h
46.8.27/
3358
20E_C15C
Channel Priority Registers (SDMAARM_SDMA_CHNPRI23)
32
R/W
0000_0000h
46.8.27/
3358
20E_C160
Channel Priority Registers (SDMAARM_SDMA_CHNPRI24)
32
R/W
0000_0000h
46.8.27/
3358
20E_C164
Channel Priority Registers (SDMAARM_SDMA_CHNPRI25)
32
R/W
0000_0000h
46.8.27/
3358
20E_C168
Channel Priority Registers (SDMAARM_SDMA_CHNPRI26)
32
R/W
0000_0000h
46.8.27/
3358
20E_C16C
Channel Priority Registers (SDMAARM_SDMA_CHNPRI27)
32
R/W
0000_0000h
46.8.27/
3358
20E_C170
Channel Priority Registers (SDMAARM_SDMA_CHNPRI28)
32
R/W
0000_0000h
46.8.27/
3358
20E_C174
Channel Priority Registers (SDMAARM_SDMA_CHNPRI29)
32
R/W
0000_0000h
46.8.27/
3358
20E_C178
Channel Priority Registers (SDMAARM_SDMA_CHNPRI30)
32
R/W
0000_0000h
46.8.27/
3358
20E_C17C
Channel Priority Registers (SDMAARM_SDMA_CHNPRI31)
32
R/W
0000_0000h
46.8.27/
3358
20E_C200
Channel Enable RAM (SDMAARM_CHNENBL0)
32
R/W
0000_0000h
46.8.28/
3358
20E_C204
Channel Enable RAM (SDMAARM_CHNENBL1)
32
R/W
0000_0000h
46.8.28/
3358
20E_C208
Channel Enable RAM (SDMAARM_CHNENBL2)
32
R/W
0000_0000h
46.8.28/
3358
20E_C20C
Channel Enable RAM (SDMAARM_CHNENBL3)
32
R/W
0000_0000h
46.8.28/
3358
20E_C210
Channel Enable RAM (SDMAARM_CHNENBL4)
32
R/W
0000_0000h
46.8.28/
3358
20E_C214
Channel Enable RAM (SDMAARM_CHNENBL5)
32
R/W
0000_0000h
46.8.28/
3358
Table continues on the next page...
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3338
NXP Semiconductors

<!-- page 3339 -->

SDMAARM memory map (continued)
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
20E_C218
Channel Enable RAM (SDMAARM_CHNENBL6)
32
R/W
0000_0000h
46.8.28/
3358
20E_C21C
Channel Enable RAM (SDMAARM_CHNENBL7)
32
R/W
0000_0000h
46.8.28/
3358
20E_C220
Channel Enable RAM (SDMAARM_CHNENBL8)
32
R/W
0000_0000h
46.8.28/
3358
20E_C224
Channel Enable RAM (SDMAARM_CHNENBL9)
32
R/W
0000_0000h
46.8.28/
3358
20E_C228
Channel Enable RAM (SDMAARM_CHNENBL10)
32
R/W
0000_0000h
46.8.28/
3358
20E_C22C
Channel Enable RAM (SDMAARM_CHNENBL11)
32
R/W
0000_0000h
46.8.28/
3358
20E_C230
Channel Enable RAM (SDMAARM_CHNENBL12)
32
R/W
0000_0000h
46.8.28/
3358
20E_C234
Channel Enable RAM (SDMAARM_CHNENBL13)
32
R/W
0000_0000h
46.8.28/
3358
20E_C238
Channel Enable RAM (SDMAARM_CHNENBL14)
32
R/W
0000_0000h
46.8.28/
3358
20E_C23C
Channel Enable RAM (SDMAARM_CHNENBL15)
32
R/W
0000_0000h
46.8.28/
3358
20E_C240
Channel Enable RAM (SDMAARM_CHNENBL16)
32
R/W
0000_0000h
46.8.28/
3358
20E_C244
Channel Enable RAM (SDMAARM_CHNENBL17)
32
R/W
0000_0000h
46.8.28/
3358
20E_C248
Channel Enable RAM (SDMAARM_CHNENBL18)
32
R/W
0000_0000h
46.8.28/
3358
20E_C24C
Channel Enable RAM (SDMAARM_CHNENBL19)
32
R/W
0000_0000h
46.8.28/
3358
20E_C250
Channel Enable RAM (SDMAARM_CHNENBL20)
32
R/W
0000_0000h
46.8.28/
3358
20E_C254
Channel Enable RAM (SDMAARM_CHNENBL21)
32
R/W
0000_0000h
46.8.28/
3358
20E_C258
Channel Enable RAM (SDMAARM_CHNENBL22)
32
R/W
0000_0000h
46.8.28/
3358
20E_C25C
Channel Enable RAM (SDMAARM_CHNENBL23)
32
R/W
0000_0000h
46.8.28/
3358
20E_C260
Channel Enable RAM (SDMAARM_CHNENBL24)
32
R/W
0000_0000h
46.8.28/
3358
20E_C264
Channel Enable RAM (SDMAARM_CHNENBL25)
32
R/W
0000_0000h
46.8.28/
3358
20E_C268
Channel Enable RAM (SDMAARM_CHNENBL26)
32
R/W
0000_0000h
46.8.28/
3358
20E_C26C
Channel Enable RAM (SDMAARM_CHNENBL27)
32
R/W
0000_0000h
46.8.28/
3358
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3339

<!-- page 3340 -->

SDMAARM memory map (continued)
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
20E_C270
Channel Enable RAM (SDMAARM_CHNENBL28)
32
R/W
0000_0000h
46.8.28/
3358
20E_C274
Channel Enable RAM (SDMAARM_CHNENBL29)
32
R/W
0000_0000h
46.8.28/
3358
20E_C278
Channel Enable RAM (SDMAARM_CHNENBL30)
32
R/W
0000_0000h
46.8.28/
3358
20E_C27C
Channel Enable RAM (SDMAARM_CHNENBL31)
32
R/W
0000_0000h
46.8.28/
3358
20E_C280
Channel Enable RAM (SDMAARM_CHNENBL32)
32
R/W
0000_0000h
46.8.28/
3358
20E_C284
Channel Enable RAM (SDMAARM_CHNENBL33)
32
R/W
0000_0000h
46.8.28/
3358
20E_C288
Channel Enable RAM (SDMAARM_CHNENBL34)
32
R/W
0000_0000h
46.8.28/
3358
20E_C28C
Channel Enable RAM (SDMAARM_CHNENBL35)
32
R/W
0000_0000h
46.8.28/
3358
20E_C290
Channel Enable RAM (SDMAARM_CHNENBL36)
32
R/W
0000_0000h
46.8.28/
3358
20E_C294
Channel Enable RAM (SDMAARM_CHNENBL37)
32
R/W
0000_0000h
46.8.28/
3358
20E_C298
Channel Enable RAM (SDMAARM_CHNENBL38)
32
R/W
0000_0000h
46.8.28/
3358
20E_C29C
Channel Enable RAM (SDMAARM_CHNENBL39)
32
R/W
0000_0000h
46.8.28/
3358
20E_C2A0
Channel Enable RAM (SDMAARM_CHNENBL40)
32
R/W
0000_0000h
46.8.28/
3358
20E_C2A4
Channel Enable RAM (SDMAARM_CHNENBL41)
32
R/W
0000_0000h
46.8.28/
3358
20E_C2A8
Channel Enable RAM (SDMAARM_CHNENBL42)
32
R/W
0000_0000h
46.8.28/
3358
20E_C2AC
Channel Enable RAM (SDMAARM_CHNENBL43)
32
R/W
0000_0000h
46.8.28/
3358
20E_C2B0
Channel Enable RAM (SDMAARM_CHNENBL44)
32
R/W
0000_0000h
46.8.28/
3358
20E_C2B4
Channel Enable RAM (SDMAARM_CHNENBL45)
32
R/W
0000_0000h
46.8.28/
3358
20E_C2B8
Channel Enable RAM (SDMAARM_CHNENBL46)
32
R/W
0000_0000h
46.8.28/
3358
20E_C2BC
Channel Enable RAM (SDMAARM_CHNENBL47)
32
R/W
0000_0000h
46.8.28/
3358
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3340
NXP Semiconductors

<!-- page 3341 -->

46.8.1
Arm platform Channel 0 Pointer (SDMAARM_MC0PTR)
Address: 20E_C000h base + 0h offset = 20E_C000h
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
MC0PTR
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
SDMAARM_MC0PTR field descriptions
Field
Description
MC0PTR
Channel 0 Pointer contains the 32-bit address, in Arm platform memory, of channel 0 control block (the
boot channel). Appendix A fully describes the SDMA Application Programming Interface (API). The Arm
platform has a read/write access and the SDMA has a read-only access.
46.8.2
Channel Interrupts (SDMAARM_INTR)
Address: 20E_C000h base + 4h offset = 20E_C004h
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
HI[31:0]
W
w1c
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
SDMAARM_INTR field descriptions
Field
Description
HI[31:0]
The Arm platform Interrupts register contains the 32 HI[i] bits. If any bit is set, it will cause an interrupt to
the Arm platform. This register is a "write-ones" register to the Arm platform. When the Arm platform sets a
bit in this register the corresponding HI[i] bit is cleared. The interrupt service routine should clear individual
channel bits when their interrupts are serviced, failure to do so will cause continuous interrupts. The
SDMA is responsible for setting the HI[i] bit corresponding to the current channel when the corresponding
done instruction is executed.
46.8.3
Channel Stop/Channel Status (SDMAARM_STOP_STAT)
Address: 20E_C000h base + 8h offset = 20E_C008h
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
HE
W
w1c
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
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3341

<!-- page 3342 -->

SDMAARM_STOP_STAT field descriptions
Field
Description
HE
This 32-bit register gives access to the Arm platform Enable bits. There is one bit for every channel. This
register is a "write-ones" register to the Arm platform. When the Arm platform writes 1 in bit i of this
register, it clears the HE[i] and HSTART[i] bits. Reading this register yields the current state of the HE[i]
bits.
46.8.4
Channel Start (SDMAARM_HSTART)
Address: 20E_C000h base + Ch offset = 20E_C00Ch
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
HSTART_HE
W
w1c
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
SDMAARM_HSTART field descriptions
Field
Description
HSTART_HE
The HSTART_HE registers are 32 bits wide with one bit for every channel. When a bit is written to 1, it
enables the corresponding channel. Two physical registers are accessed with that address (HSTART and
HE), which enables the Arm platform to trigger a channel a second time before the first trigger is
processed.
• This register is a "write-ones" register to the Arm platform. Neither HSTART[i] bit can be set while
the corresponding HE[i] bit is cleared.
• When the Arm platform tries to set the HSTART[i] bit by writing a one (if the corresponding HE[i] bit
is clear), the bit in the HSTART[i] register will remain cleared and the HE[i] bit will be set.
• If the corresponding HE[i] bit was already set, the HSTART[i] bit will be set. The next time the SDMA
channel i attempts to clear the HE[i] bit by means of a done instruction, the bit in the HSTART[i]
register will be cleared and the HE[i] bit will take the old value of the HSTART[i] bit.
• Reading this register yields the current state of the HSTART[i] bits. This mechanism enables the
Arm platform to pipeline two HSTART commands per channel.
46.8.5
Channel Event Override (SDMAARM_EVTOVR)
Address: 20E_C000h base + 10h offset = 20E_C010h
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
EO
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
SDMAARM_EVTOVR field descriptions
Field
Description
EO
The Channel Event Override register contains the 32 EO[i] bits. A bit set in this register causes the SDMA
to ignore DMA requests when scheduling the corresponding channel.
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3342
NXP Semiconductors

<!-- page 3343 -->

46.8.6
Channel BP Override (SDMAARM_DSPOVR)
Address: 20E_C000h base + 14h offset = 20E_C014h
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
DO
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
SDMAARM_DSPOVR field descriptions
Field
Description
DO
This register is reserved. All DO bits should be set to the reset value of 1. A setting of 0 will prevent SDMA
channels from starting according to the condition described in Runnable Channels Evaluation.
0
- Reserved
1
- Reset value.
46.8.7
Channel Arm platform Override (SDMAARM_HOSTOVR)
Address: 20E_C000h base + 18h offset = 20E_C018h
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
HO
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
SDMAARM_HOSTOVR field descriptions
Field
Description
HO
The Channel Arm platform Override register contains the 32 HO[i] bits. A bit set in this register causes the
SDMA to ignore the Arm platform enable bit (HE) when scheduling the corresponding channel.
46.8.8
Channel Event Pending (SDMAARM_EVTPEND)
Address: 20E_C000h base + 1Ch offset = 20E_C01Ch
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
EP
W
w1c
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
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3343

<!-- page 3344 -->

SDMAARM_EVTPEND field descriptions
Field
Description
EP
The Channel Event Pending register contains the 32 EP[i] bits. Reading this register enables the Arm
platform to determine what channels are pending after the reception of a DMA request.
• Setting a bit in this register causes the SDMA to reevaluate scheduling as if a DMA request mapped
on this channel had occurred. This is useful for starting up channels, so that initialization is done
before awaiting the first request. The scheduler can also set bits in the EVTPEND register according
to the received DMA requests.
• The EP[i] bit may be cleared by the done instruction when running the channel i script. This a "write-
ones" mechanism: Writing a '0' does not clear the corresponding bit.
46.8.9
Reset Register (SDMAARM_RESET)
Address: 20E_C000h base + 24h offset = 20E_C024h
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
RESCHED
RESET
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
SDMAARM_RESET field descriptions
Field
Description
31–2
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3344
NXP Semiconductors

<!-- page 3345 -->

SDMAARM_RESET field descriptions (continued)
Field
Description
1
RESCHED
When set, this bit forces the SDMA to reschedule as if a script had executed a done instruction. This
enables the Arm platform to recover from a runaway script on a channel by clearing its HE[i] bit via the
STOP register, and then forcing a reschedule via the RESCHED bit. The RESCHED bit is cleared when
the context switch starts.
0
RESET
When set, this bit causes the SDMA to be held in a software reset. The internal reset signal is held low 16
cycles; the RESET bit is automatically cleared when the internal reset signal rises.
46.8.10
DMA Request Error Register (SDMAARM_EVTERR)
Address: 20E_C000h base + 28h offset = 20E_C028h
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
CHNERR
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
SDMAARM_EVTERR field descriptions
Field
Description
CHNERR
This register is used by the SDMA to warn the Arm platform when an incoming DMA request was detected
and it triggers a channel that is already pending or being serviced. This probably means there is an
overflow of data for that channel.
• An interrupt is sent to the Arm platform if the corresponding channel bit is set in the INTRMASK
register.
• This is a "write-ones" register for the scheduler. It is only able to set the flags. The flags are cleared
when the register is read by the Arm platform or during SDMA reset.
• The CHNERR[i] bit is set when a DMA request that triggers channel i is received through the
corresponding input pins and the EP[i] bit is already set; the EVTERR[i] bit is unaffected if the Arm
platform tries to set the EP[i] bit, whereas, that EP[i] bit is already set.
46.8.11
Channel Arm platform Interrupt Mask
(SDMAARM_INTRMASK)
Address: 20E_C000h base + 2Ch offset = 20E_C02Ch
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
HIMASK
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
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3345

<!-- page 3346 -->

SDMAARM_INTRMASK field descriptions
Field
Description
HIMASK
The Interrupt Mask Register contains 32 interrupt generation mask bits. If bit HIMASK[i] is set, the HI[i] bit
is set and an interrupt is sent to the Arm platform when a DMA request error is detected on channel i (for
example, EVTERR[i] is set).
46.8.12
Schedule Status (SDMAARM_PSW)
Address: 20E_C000h base + 30h offset = 20E_C030h
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
NCP[2:0]
NCR[4:0]
CCP[2:0]
CCR[4:0]
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
SDMAARM_PSW field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–13
NCP[2:0]
The Next Channel Priority gives the next pending channel priority. When the priority is 0, it means there is
no pending channel and the NCR value has no meaning.
0
No running channel
1
Active channel priority
12–8
NCR[4:0]
The Next Channel Register indicates the number of the next scheduled pending channel with the highest
priority.
7–4
CCP[2:0]
The Current Channel Priority indicates the priority of the current active channel. When the priority is 0, no
channel is running: The SDMA is idle and the CCR value has no meaning. In the case that the SDMA has
finished running the channel and has entered sleep state, CCP will indicate the priority of previous running
channel.
0
No running channel
1
Active channel priority
CCR[4:0]
The Current Channel Register indicates the number of the channel that is being executed by the SDMA.
SDMA. In the case that the SDMA has finished running the channel and has entered sleep state, CCR will
indicate the previous running channel.
46.8.13
DMA Request Error Register (SDMAARM_EVTERRDBG)
Address: 20E_C000h base + 34h offset = 20E_C034h
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
CHNERR
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
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3346
NXP Semiconductors

<!-- page 3347 -->

SDMAARM_EVTERRDBG field descriptions
Field
Description
CHNERR
This register is the same as EVTERR, except reading it does not clear its contents. This address is meant
to be used in debug mode. The Arm platform OnCE may check this register value without modifying it.
46.8.14
Configuration Register (SDMAARM_CONFIG)
Address: 20E_C000h base + 38h offset = 20E_C038h
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
DSPDMA
RTDOBS
0
ACR
0
CSM
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
1
SDMAARM_CONFIG field descriptions
Field
Description
31–13
Reserved
This read-only field is reserved and always has the value 0.
12
DSPDMA
This bit's function is reserved and should be configured as zero.
0
- Reset Value
1
- Reserved
11
RTDOBS
Indicates if Real-Time Debug pins are used: They do not toggle by default in order to reduce power
consumption.
0
RTD pins disabled
1
RTD pins enabled
10–5
Reserved
This read-only field is reserved and always has the value 0.
4
ACR
Arm platform DMA / SDMA Core Clock Ratio. Selects the clock ratio between Arm platform DMA
interfaces (burst DMA and peripheral DMA) and the internal SDMA core clock. The frequency selection is
determined separately by the chip clock controller. This bit has to match the configuration of the chip clock
controller that generates the clocks used in the SDMA.
0
Arm platform DMA interface frequency equals twice core frequency
1
Arm platform DMA interface frequency equals core frequency
3–2
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3347

<!-- page 3348 -->

SDMAARM_CONFIG field descriptions (continued)
Field
Description
CSM
Selects the Context Switch Mode. The Arm platform has a read/write access. The SDMA cannot modify
that register. The value at reset is 3, which selects the dynamic context switch by default. That register can
be modified at anytime but the new context switch configuration will only be taken into account at the start
of the next restore phase.
NOTE: The first call to SDMA's channel 0 Bootload script after reset should use static context switch mode
to ensure the context RAM for channel 0 is initialized in the channel SAVE Phase. After Channel 0 is run
once, then any of the dynamic context modes can be used.
0
static
1
dynamic low power
2
dynamic with no loop
3
dynamic
46.8.15
SDMA LOCK (SDMAARM_SDMA_LOCK)
Address: 20E_C000h base + 3Ch offset = 20E_C03Ch
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
SRESET_LOCK_
CLR
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
0
0
SDMAARM_SDMA_LOCK field descriptions
Field
Description
31–2
Reserved
This read-only field is reserved and always has the value 0.
1
SRESET_LOCK_
CLR
The SRESET_LOCK_CLR bit determine if the LOCK bit is cleared on a software reset triggered by writing
to the RESET register. This bit cannot be changed if LOCK=1. SREST_LOCK_CLR is cleared by
conditions that clear the LOCK bit.
0
Software Reset does not clear the LOCK bit.
1
Software Reset clears the LOCK bit.
Table continues on the next page...
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3348
NXP Semiconductors

<!-- page 3349 -->

SDMAARM_SDMA_LOCK field descriptions (continued)
Field
Description
0
LOCK
The LOCK bit is used to restrict access to update SDMA script memory through ROM channel zero scripts
and through the OnCE interface under Arm platform control.
The LOCK bit is set:
• The SDMA_LOCK, ONCE_ENB,CH0ADDR, and ILLINSTADDR registers cannot be written. These
registers can be read, but writes are ignored.
• SDMA software executing out of ROM or RAM may check the LOCK bit in the LOCK register Lock
Status Register (SDMACORE_SDMA_LOCK) to determine if certain operations are allowed, such
as up-loading new scripts.
Once the LOCK bit is set to 1, only a reset can clear it. The LOCK bit is cleared by a hardware reset.
LOCK is cleared by a software reset only if SRESET_LOCK_CLR is set.
0
LOCK disengaged.
1
LOCK enabled.
46.8.16
OnCE Enable (SDMAARM_ONCE_ENB)
Address: 20E_C000h base + 40h offset = 20E_C040h
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
ENB
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
SDMAARM_ONCE_ENB field descriptions
Field
Description
31–1
Reserved
This read-only field is reserved and always has the value 0.
0
ENB
The OnCE Enable register selects the OnCE control source: When cleared (0), the OnCE registers are
accessed through the JTAG interface; when set (1), the OnCE registers may be accessed by the Arm
platform through the addresses described, as follows.
• After reset, the OnCE registers are accessed through the JTAG interface.
• Writing a 1 to ENB enables the Arm platform to access the ONCE_* as any other SDMA control
register.
• When cleared (0), all the ONCE_xxx registers cannot be written.
The value of ENB cannot be changed if the LOCK bit in the SDMA_LOCK register is set.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3349

<!-- page 3350 -->

46.8.17
OnCE Data Register (SDMAARM_ONCE_DATA)
Address: 20E_C000h base + 44h offset = 20E_C044h
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
SDMAARM_ONCE_DATA field descriptions
Field
Description
DATA
Data register of the OnCE JTAG controller. Refer to OnCE and Real-Time Debug for information on this
register.
46.8.18
OnCE Instruction Register (SDMAARM_ONCE_INSTR)
Address: 20E_C000h base + 48h offset = 20E_C048h
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
INSTR
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
SDMAARM_ONCE_INSTR field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
INSTR
Instruction register of the OnCE JTAG controller. Refer to OnCE and Real-Time Debug for information on
this register.
46.8.19
OnCE Status Register (SDMAARM_ONCE_STAT)
Address: 20E_C000h base + 4Ch offset = 20E_C04Ch
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
PST[3:0]
RCV
EDR
ODR
SWB
MST
0
ECDR
W
Reset
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
0
0
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3350
NXP Semiconductors

<!-- page 3351 -->

SDMAARM_ONCE_STAT field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–12
PST[3:0]
The Processor Status bits reflect the state of the SDMA RISC engine. Its states are as follows:
• The "Program" state is the usual instruction execution cycle.
• The "Data" state is inserted when there are wait-states during a load or a store on the data bus (ld or
st).
• The "Change of Flow" state is the second cycle of any instruction that breaks the sequence of
instructions (jumps and channel switching instructions).
• The "Change of Flow in Loop" state is used when an error causes a hardware loop exit.
• The "Debug" state means the SDMA is in debug mode.
• The "Functional Unit" state is inserted when there are wait-states during a load or a store on the
functional units bus (ldf or stf).
• In "Sleep" modes, no script is running (this is the RISC engine idle state). The "after Reset" is
slightly different because no context restoring phase will happen when a channel is triggered: The
script located at address 0 will be executed (boot operation).
• The "in Sleep" states are the same as above except they do not have any corresponding channel:
They are used when entering debug mode after reset. The reason is that it is necessary to return to
the "Sleep after Reset" state when leaving debug mode.
0
Program
1
Data
2
Change of Flow
3
Change of Flow in Loop
4
Debug
5
Functional Unit
6
Sleep
7
Save
8
Program in Sleep
9
Data in Sleep
10
Change of Flow in Sleep
11
Change Flow in Loop in Sleep
12
Debug in Sleep
13
Functional Unit in Sleep
14
Sleep after Reset
15
Restore
11
RCV
After each write access to the real time buffer (RTB), the RCV bit is set. This bit is cleared after execution
of an rbuffer command and on a JTAG reset.
10
EDR
This flag is raised when the SDMA has entered debug mode after an external debug request.
9
ODR
This flag is raised when the SDMA has entered debug mode after a OnCE debug request.
8
SWB
This flag is raised when the SDMA has entered debug mode after a software breakpoint.
7
MST
This flag is raised when the OnCE is controlled from the Arm platform peripheral interface.
0
The JTAG interface controls the OnCE.
1
The Arm platform peripheral interface controls the OnCE.
6–3
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3351

<!-- page 3352 -->

SDMAARM_ONCE_STAT field descriptions (continued)
Field
Description
ECDR
Event Cell Debug Request. If the debug request comes from the event cell, the reason for entering debug
mode is given by the EDR bits. If all three bits of the EDR are reset, then it did not generate any debug
request. If the cell did generate a debug request, then at least one of the EDR bits is set (the meaning of
the encoding is given below). The encoding of the EDR bits is useful to find out more precisely why the
debug request was generated. A debug request from an event cell is generated for a specific combination
of the addra_cond, addrb_cond, and data_cond conditions. The value of those fields is given by the EDR
bits.
0
1 matched addra_cond
1
1 matched addrb_cond
2
1 matched data_cond
46.8.20
OnCE Command Register (SDMAARM_ONCE_CMD)
Address: 20E_C000h base + 50h offset = 20E_C050h
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
CMD
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
SDMAARM_ONCE_CMD field descriptions
Field
Description
31–4
Reserved
This read-only field is reserved and always has the value 0.
CMD
Writing to this register will cause the OnCE to execute the command that is written. When needed, the
ONCE_DATA and ONCE_INSTR registers should be loaded with the correct value before writing the
command to that register. For a list of the OnCE commands and their usage, see OnCE and Real-Time
Debug.
NOTE: 7-15 reserved
0
rstatus
1
dmov
2
exec_once
3
run_core
4
exec_core
5
debug_rqst
6
rbuffer
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3352
NXP Semiconductors

<!-- page 3353 -->

46.8.21
Illegal Instruction Trap Address
(SDMAARM_ILLINSTADDR)
Address: 20E_C000h base + 58h offset = 20E_C058h
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
ILLINSTADDR
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
1
SDMAARM_ILLINSTADDR field descriptions
Field
Description
31–14
Reserved
This read-only field is reserved and always has the value 0.
ILLINSTADDR
The Illegal Instruction Trap Address is the address where the SDMA jumps when an illegal instruction is
executed. It is 0x0001 after reset.
The value of ILLINSTADDR cannot be changed if the LOCK bit in the SDMA_LOCK register is set.
46.8.22
Channel 0 Boot Address (SDMAARM_CHN0ADDR)
Address: 20E_C000h base + 5Ch offset = 20E_C05Ch
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
SMSZ
CHN0ADDR
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
1
0
1
0
0
0
0
SDMAARM_CHN0ADDR field descriptions
Field
Description
31–15
Reserved
This read-only field is reserved and always has the value 0.
14
SMSZ
The bit 14 (Scratch Memory Size) determines if scratch memory must be available after every channel
context. After reset, it is equal to 0, which defines a RAM space of 24 words for each channel. All of this
area stores the channel context. By setting this bit, 32 words are reserved for every channel context,
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3353

<!-- page 3354 -->

SDMAARM_CHN0ADDR field descriptions (continued)
Field
Description
which gives eight additional words that can be used by the channel script to store any type of data. Those
words are never erased by the context switching mechanism.
The value of SMSZ cannot be changed if the LOCK bit in the SDMA_LOCK register is set.
0
24 words per context
1
32 words per context
CHN0ADDR
This 14-bit register is used by the boot code of the SDMA. After reset, it points to the standard boot routine
in ROM (channel 0 routine). By changing this address, you can perform a boot sequence with your own
routine. The very first instructions of the boot code fetch the contents of this register (it is also mapped in
the SDMA memory space) and jump to the given address. The reset value is 0x0050 (decimal 80).
The value of CHN0ADDR cannot be changed if the LOCK bit in the SDMA_LOCK register is set.
46.8.23
DMA Requests (SDMAARM_EVT_MIRROR)
Address: 20E_C000h base + 60h offset = 20E_C060h
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
EVENTS
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
SDMAARM_EVT_MIRROR field descriptions
Field
Description
EVENTS
This register reflects the DMA requests received by the SDMA for events 31-0. The Arm platform and the
SDMA have a read-only access. There is one bit associated with each of 32 DMA request events. This
information may be useful during debug of the blocks that generate the DMA requests. The EVT_MIRROR
register is cleared following read access.
0
DMA request event not pending
1
DMA request event pending
46.8.24
DMA Requests 2 (SDMAARM_EVT_MIRROR2)
Address: 20E_C000h base + 64h offset = 20E_C064h
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
EVENTS[47:32]
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
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3354
NXP Semiconductors

<!-- page 3355 -->

SDMAARM_EVT_MIRROR2 field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
EVENTS[47:32]
This register reflects the DMA requests received by the SDMA for events 47-32. The Arm platform and the
SDMA have a read-only access. There is one bit associated with each of DMA request events. This
information may be useful during debug of the blocks that generate the DMA requests. The
EVT_MIRROR2 register is cleared following read access.
0
- DMA request event not pending
1-
DMA request event pending
46.8.25
Cross-Trigger Events Configuration Register 1
(SDMAARM_XTRIG_CONF1)
Address: 20E_C000h base + 70h offset = 20E_C070h
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
CNF3
NUM3[5:0]
0
CNF2
NUM2[5:0]
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
CNF1
NUM1[5:0]
0
CNF0
NUM0[5:0]
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
SDMAARM_XTRIG_CONF1 field descriptions
Field
Description
31
Reserved
This read-only field is reserved and always has the value 0.
30
CNF3
Configuration of the SDMA event line number i that is connected to the cross-trigger. It determines
whether the event line pulse is generated by the reception of a DMA request or by the starting of a
channel script execution.
0
channel
1
DMA request
29–24
NUM3[5:0]
Contains the number of the DMA request or channel that triggers the pulse on the cross-trigger event line
number i.
23
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3355

<!-- page 3356 -->

SDMAARM_XTRIG_CONF1 field descriptions (continued)
Field
Description
22
CNF2
Configuration of the SDMA event line number i that is connected to the cross-trigger. It determines
whether the event line pulse is generated by receiving a DMA request or by starting a channel script
execution.
0
channel
1
DMA request
21–16
NUM2[5:0]
Contains the number of the DMA request or channel that triggers the pulse on the cross-trigger event line
number i.
15
Reserved
This read-only field is reserved and always has the value 0.
14
CNF1
Configuration of the SDMA event line number i that is connected to the cross-trigger. It determines
whether the event line pulse is generated by receiving a DMA request or by starting a channel script
execution.
0
channel
1
DMA request
13–8
NUM1[5:0]
Contains the number of the DMA request or channel that triggers the pulse on the cross-trigger event line
number i.
7
Reserved
This read-only field is reserved and always has the value 0.
6
CNF0
Configuration of the SDMA event line number i that is connected to the cross-trigger. It determines
whether the event line pulse is generated by receiving a DMA request or by starting a channel script
execution.
0
channel
1
DMA request
NUM0[5:0]
Contains the number of the DMA request or channel that triggers the pulse on the cross-trigger event line
number i.
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3356
NXP Semiconductors

<!-- page 3357 -->

46.8.26
Cross-Trigger Events Configuration Register 2
(SDMAARM_XTRIG_CONF2)
Address: 20E_C000h base + 74h offset = 20E_C074h
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
CNF7
NUM7[5:0]
0
CNF6
NUM6[5:0]
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
CNF5
NUM5[5:0]
0
CNF4
NUM4[5:0]
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
SDMAARM_XTRIG_CONF2 field descriptions
Field
Description
31
Reserved
This read-only field is reserved and always has the value 0.
30
CNF7
Configuration of the SDMA event line number i that is connected to the cross-trigger. It determines
whether the event line pulse is generated by receiving a DMA request or by starting a channel script
execution.
0
channel
1
DMA request
29–24
NUM7[5:0]
Contains the number of the DMA request or channel that triggers the pulse on the cross-trigger event line
number i.
23
Reserved
This read-only field is reserved and always has the value 0.
22
CNF6
Configuration of the SDMA event line number i that is connected to the cross-trigger. It determines
whether the event line pulse is generated by receiving a DMA request or by starting a channel script
execution.
0
channel
1
DMA request
21–16
NUM6[5:0]
Contains the number of the DMA request or channel that triggers the pulse on the cross-trigger event line
number i.
15
Reserved
This read-only field is reserved and always has the value 0.
14
CNF5
Configuration of the SDMA event line number i that is connected to the cross-trigger. It determines
whether the event line pulse is generated by receiving a DMA request or by starting a channel script
execution
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3357

<!-- page 3358 -->

SDMAARM_XTRIG_CONF2 field descriptions (continued)
Field
Description
0
channel
1
DMA request
13–8
NUM5[5:0]
Contains the number of the DMA request or channel that triggers the pulse on the cross-trigger event line
number i.
7
Reserved
This read-only field is reserved and always has the value 0.
6
CNF4
Configuration of the SDMA event line number i that is connected to the cross-trigger. It determines
whether the event line pulse is generated by receiving a DMA request or by starting a channel script
execution.
0
channel
1
DMA request
NUM4[5:0]
Contains the number of the DMA request or channel that triggers the pulse on the cross-trigger event line
number i.
46.8.27
Channel Priority Registers (SDMAARM_SDMA_CHNPRIn)
Address: 20E_C000h base + 100h offset + (4d × i), where i=0d to 31d
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
CHNPRIn
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
SDMAARM_SDMA_CHNPRIn field descriptions
Field
Description
31–3
Reserved
This read-only field is reserved and always has the value 0.
CHNPRIn
This contains the priority of channel number n. Useful values are between 1 and 7; 0 is reserved by the
SDMA hardware to determine when there is no pending channel. Reset value is 0, which prevents the
channels from starting.
46.8.28
Channel Enable RAM (SDMAARM_CHNENBLn)
Address: 20E_C000h base + 200h offset + (4d × i), where i=0d to 47d
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
ENBLn
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
Arm Platform Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3358
NXP Semiconductors

<!-- page 3359 -->

SDMAARM_CHNENBLn field descriptions
Field
Description
ENBLn
This 32-bit value selects the channels that are triggered by the DMA request number n. If ENBLn[i] is set
to 1, bit EP[i] will be set when the DMA request n is received. These 48 32-bit registers are physically
located in a RAM, with no known reset value. It is thus essential for the Arm platform to program them
before any DMA request is triggered to the SDMA, otherwise an unpredictable combination of channels
may be started.
46.9
BP Memory Map and Control Register Definitions
The following section describes SDMA control registers available to the BP.
NOTE
These registers are physically implemented in all platforms, but
are not accessible when the SDMA BP control port is not
connected. Reset values are calculated to allow the system to
work when those registers cannot be accessed.
All registers are clocked with the SDMA clock (which means the SDMA clock must be
running when the BP wants to access any register).
SDMABP memory map
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
Channel 0 Pointer (SDMABP_DC0PTR)
32
R/W
0000_0000h
46.9.1/3359
4
Channel Interrupts (SDMABP_INTR)
32
w1c
0000_0000h
46.9.2/3360
8
Channel Stop/Channel Status (SDMABP_STOP_STAT)
32
R/W
0000_0000h
46.9.3/3360
C
Channel Start (SDMABP_DSTART)
32
R
0000_0000h
46.9.4/3361
28
DMA Request Error Register (SDMABP_EVTERR)
32
R
0000_0000h
46.9.5/3361
2C
Channel DSP Interrupt Mask (SDMABP_INTRMASK)
32
R/W
0000_0000h
46.9.6/3362
34
DMA Request Error Register (SDMABP_EVTERRDBG)
32
R
0000_0000h
46.9.7/3362
46.9.1
Channel 0 Pointer (SDMABP_DC0PTR)
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
DC0PTR
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
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3359

<!-- page 3360 -->

SDMABP_DC0PTR field descriptions
Field
Description
DC0PTR
Channel 0 Pointer contains the 32-bit address, in BP memory, of the array of channel control blocks
starting with the one for channel 0 (the control channel). This register should be initialized by the BP
before it enables a channel (for example, channel 0). See the API document SDMA Scripts User Manual
for the use of this register. The BP has a read/write access and the SDMA has a read-only access.
46.9.2
Channel Interrupts (SDMABP_INTR)
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
DI
W
w1c
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
SDMABP_INTR field descriptions
Field
Description
DI
The BP Interrupts register contains the 32 DI[i] bits. If any bit is set, it will cause an interrupt to the BP.
• This register is a "write-ones" register to the BP. When the BP sets a bit in this register, the
corresponding DI[i] bit is cleared.
• The interrupt service routine should clear individual channel bits when their interrupts are serviced;
failure to do so will cause continuous interrupts.
• The SDMA is responsible for setting the DI[i] bit corresponding to the current channel when the
corresponding done instruction is executed.
46.9.3
Channel Stop/Channel Status (SDMABP_STOP_STAT)
Address: 0h base + 8h offset = 8h
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
DE
W
w1c
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
SDMABP_STOP_STAT field descriptions
Field
Description
DE
This 32-bit register gives access to the BP (DSP) Enable bits, DE. There is one bit for every channel.
• This register is a "write-ones" register to the BP.
• When the BP writes 1 in bit i of this register, it clears the DE[i] and DSTART[i] bits.
• Reading this register yields the current state of the DE[i] bits.
BP Memory Map and Control Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3360
NXP Semiconductors

<!-- page 3361 -->

46.9.4
Channel Start (SDMABP_DSTART)
Address: 0h base + Ch offset = Ch
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
DSTART_DE
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
SDMABP_DSTART field descriptions
Field
Description
DSTART_DE
The DSTART_DE registers are 32 bits wide with one bit for every channel.
• When a bit is written to 1, it enables the corresponding channel.
• Two physical registers are accessed with that address (DSTART and DE), which enables the BP to
trigger a channel a second time before the first trigger was processed.
• This register is a "write-ones" register to the BP. Neither DSTART[i] bit can be set while the
corresponding DE[i] bit is cleared.
• When the BP tries to set the DSTART[i] bit by writing a one (if the corresponding DE[i] bit is clear),
the bit in the DSTART[i] register will remain cleared and the DE[i] bit will be set. If the corresponding
DE[i] bit was already set, the DSTART[i] bit will be set.
• The next time the SDMA channel i attempts to clear the DE[i] bit by means of a done instruction, the
bit in the DSTART[i] register will be cleared and the DE[i] bit will take the old value of the DSTART[i]
bit.
• Reading this register yields the current state of the DSTART[i] bits. This mechanism enables the BP
to pipeline two DSTART commands per channel.
46.9.5
DMA Request Error Register (SDMABP_EVTERR)
Address: 0h base + 28h offset = 28h
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
CHNERR
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
SDMABP_EVTERR field descriptions
Field
Description
CHNERR
This register is used by the SDMA to warn the BP when an incoming DMA request was detected; it then
triggers a channel that is already pending or being serviced, which may mean there is an overflow of data
for that channel. An interrupt is sent to the BP if the corresponding channel bit is set in the INTRMASK
register.
• This is a "write-ones" register for the scheduler. It is only able to set the flags. The flags are cleared
when the register is read by the BP or during an SDMA reset.
• The CHNERR[i] bit is set when a DMA request that triggers channel i is received through the
corresponding input pins and the EP[i] bit is already set. The EVTERR[i] bit is unaffected if the BP
tries to set the EP[i] bit when that EP[i] bit is already set.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3361

<!-- page 3362 -->

46.9.6
Channel DSP Interrupt Mask (SDMABP_INTRMASK)
Address: 0h base + 2Ch offset = 2Ch
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
DIMASK
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
SDMABP_INTRMASK field descriptions
Field
Description
DIMASK
The Interrupt Mask Register contains 32 interrupt generation mask bits. If bit DIMASK[i] is set, the DI[i] bit
is set and an interrupt is sent to the BP when a DMA request error is detected on channel i (for example,
EVTERR[i] is set).
46.9.7
DMA Request Error Register (SDMABP_EVTERRDBG)
Address: 0h base + 34h offset = 34h
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
CHNERR
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
SDMABP_EVTERRDBG field descriptions
Field
Description
CHNERR
This register is the same as EVTERR except reading it does not clear its contents. This address is meant
to be used in debug mode. The BP OnCE may check this register value without modifying it.
46.10
SDMA Internal (Core) Memory Map and Internal
Register Definitions
The actual SDMA memory mapped registers are summarized in the following sections;
for peripherals' memory maps, refer to the respective chapters.
The following definitions serve as a key for the SDMA internal register summary.
SDMA Internal (Core) Memory Map and Internal Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3362
NXP Semiconductors

<!-- page 3363 -->

SDMACORE memory map
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
201_C000
Arm platform Channel 0 Pointer (SDMACORE_MC0PTR)
32
R
0000_0000h
46.10.1/
3364
201_C008
Current Channel Pointer (SDMACORE_CCPTR)
32
R
0000_0000h
46.10.2/
3364
201_C00C
Current Channel Register (SDMACORE_CCR)
32
R
0000_0000h
46.10.3/
3364
201_C010
Highest Pending Channel Register (SDMACORE_NCR)
32
R
0000_0000h
46.10.4/
3365
201_C014
External DMA Requests Mirror (SDMACORE_EVENTS)
32
R
0000_0000h
46.10.5/
3366
201_C018
Current Channel Priority (SDMACORE_CCPRI)
32
R
0000_0000h
46.10.6/
3367
201_C01C
Next Channel Priority (SDMACORE_NCPRI)
32
R
0000_0000h
46.10.7/
3367
201_C020
OnCE Event Cell Counter (SDMACORE_ECOUNT)
32
R/W
0000_0000h
46.10.8/
3368
201_C024
OnCE Event Cell Control Register (SDMACORE_ECTL)
32
R/W
0000_0000h
46.10.9/
3368
201_C028
OnCE Event Address Register A (SDMACORE_EAA)
32
R/W
0000_0000h
46.10.10/
3370
201_C02C
OnCE Event Cell Address Register B (SDMACORE_EAB)
32
R/W
0000_0000h
46.10.11/
3370
201_C030
OnCE Event Cell Address Mask (SDMACORE_EAM)
32
R/W
0000_0000h
46.10.12/
3370
201_C034
OnCE Event Cell Data Register (SDMACORE_ED)
32
R/W
0000_0000h
46.10.13/
3371
201_C038
OnCE Event Cell Data Mask (SDMACORE_EDM)
32
R/W
0000_0000h
46.10.14/
3371
201_C03C
OnCE Real-Time Buffer (SDMACORE_RTB)
32
R/W
0000_0000h
46.10.15/
3372
201_C040
OnCE Trace Buffer (SDMACORE_TB)
32
R
0000_0000h
46.10.16/
3372
201_C044
OnCE Status (SDMACORE_OSTAT)
32
R
0000_0000h
46.10.17/
3373
201_C048
Channel 0 Boot Address (SDMACORE_MCHN0ADDR)
32
R
0000_0000h
46.10.18/
3375
201_C04C
ENDIAN Status Register (SDMACORE_ENDIANNESS)
32
R
0000_0001h
46.10.19/
3376
201_C054
Lock Status Register (SDMACORE_SDMA_LOCK)
32
R
0000_0000h
46.10.20/
3377
201_C058
External DMA Requests Mirror #2 (SDMACORE_EVENTS2)
32
R
0000_0000h
46.10.21/
3378
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3363

<!-- page 3364 -->

46.10.1
Arm platform Channel 0 Pointer (SDMACORE_MC0PTR)
Address: 201_C000h base + 0h offset = 201_C000h
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
MC0PTR
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
SDMACORE_MC0PTR field descriptions
Field
Description
MC0PTR
Contains the address-in the Arm platform memory space-of the initial SDMA context and scripts that are
loaded by the SDMA boot script running on channel 0.
46.10.2
Current Channel Pointer (SDMACORE_CCPTR)
Address: 201_C000h base + 8h offset = 201_C008h
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
CCPTR
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
SDMACORE_CCPTR field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
CCPTR
Contains the start address of the context data for the current channel: Its value is CONTEXT_BASE + 24*
CCR or CONTEXT_BASE + 32* CCR where CONTEXT_BASE = 0x0800. The value 24 or 32 is selected
according to the programmed channel scratch RAM size in the register shown in Channel 0 Boot Address
(SDMAARM_CHN0ADDR) .
46.10.3
Current Channel Register (SDMACORE_CCR)
Address: 201_C000h base + Ch offset = 201_C00Ch
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
CCR
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
SDMA Internal (Core) Memory Map and Internal Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3364
NXP Semiconductors

<!-- page 3365 -->

SDMACORE_CCR field descriptions
Field
Description
31–5
Reserved
This read-only field is reserved and always has the value 0.
CCR
Contains the number of the current running channel whose context is installed. In the case that the SDMA
has finished running the channel and has entered sleep state, CCR will indicate the previous running
channel. The PST bits in the OSTAT register indicate when the SDMA is in sleep state.
46.10.4
Highest Pending Channel Register (SDMACORE_NCR)
Address: 201_C000h base + 10h offset = 201_C010h
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
NCR
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
SDMACORE_NCR field descriptions
Field
Description
31–5
Reserved
This read-only field is reserved and always has the value 0.
NCR
Contains the number of the pending channel that the scheduler has selected to run next.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3365

<!-- page 3366 -->

46.10.5
External DMA Requests Mirror (SDMACORE_EVENTS)
NOTE
This register is very useful in the case of DMA requests that are
active when a peripheral FIFO level is above the programmed
watermark. The activation of the DMA request (rising edge) is
detected by the SDMA logic and it can enable one or several
channels. One of the channels accesses the peripheral and reads
or writes a number of data that matches the watermark level
(for example, if the watermark is four words, the channel reads
or writes four words).
If the channel is effectively executed long after the DMA
request was received, reading or writing the watermark number
of data may not be sufficient to reset the DMA request (for
example, if the FIFO watermark is four and at the channel
execution it already contains nine pieces of data). This means
no new rising edge may be detected by the SDMA, although
there still remains transfers to perform. Therefore, if the
channel were terminated at that time, it would not be restarted,
causing potential overrun or underrun of the peripheral.
The proposed mechanism is for the channel to check this
register after it has performed the "watermark" number of
accesses to the peripheral. If the bit for the DMA request that
triggers this channel is set, it means there is still another
watermark number of data to transfer. This goes on until the bit
is cleared. The same script can be used for multiple channels
that require this behavior. The script can determine its channel
number from the CCR register and infer the corresponding
DMA request bit to check. It needs a reference table that is
coherent with the request-channel matrix that the Arm platform
programmed.
Address: 201_C000h base + 14h offset = 201_C014h
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
EVENTS
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
SDMA Internal (Core) Memory Map and Internal Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3366
NXP Semiconductors

<!-- page 3367 -->

SDMACORE_EVENTS field descriptions
Field
Description
EVENTS
Reflects the status of the SDMA's external DMA requests. It is meant to allow any channel to monitor the
states of these SDMA inputs.
This register displays EVENTS 0-31. The EVENTS2 register displays events 32-47.
46.10.6
Current Channel Priority (SDMACORE_CCPRI)
Address: 201_C000h base + 18h offset = 201_C018h
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
CCPRI
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
SDMACORE_CCPRI field descriptions
Field
Description
31–3
Reserved
This read-only field is reserved and always has the value 0.
CCPRI
Contains the 3-bit priority of the channel whose context is installed. It is 0 when no channel is running.
NOTE: 1-7 current channel priority
0
no running channel
46.10.7
Next Channel Priority (SDMACORE_NCPRI)
Address: 201_C000h base + 1Ch offset = 201_C01Ch
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
NCPRI
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
SDMACORE_NCPRI field descriptions
Field
Description
31–3
Reserved
This read-only field is reserved and always has the value 0.
NCPRI
Contains the 3-bit priority of the channel the scheduler has selected to run next. It is 0 when no other
channel is pending.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3367

<!-- page 3368 -->

46.10.8
OnCE Event Cell Counter (SDMACORE_ECOUNT)
Address: 201_C000h base + 20h offset = 201_C020h
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
ECOUNT
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
SDMACORE_ECOUNT field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
ECOUNT
The event cell counter contains the number of times minus one that an event detection must occur before
generating a debug request.
• This register should be written before any attempt to use the event detection counter during an
event detection process.
• The counter is cleared on a JTAG reset.
46.10.9
OnCE Event Cell Control Register (SDMACORE_ECTL)
Address: 201_C000h base + 24h offset = 201_C024h
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
EN
CNT
ECTC[1:0]
DTC[1:0]
ATC[1:0]
ABTC[1:0]
AATC[1:0]
ATS[1:0]
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
SDMACORE_ECTL field descriptions
Field
Description
31–14
Reserved
This read-only field is reserved and always has the value 0.
13
EN
Event Cell Enable. If the EN bit is set, the event cell is allowed to generate debug requests (the cell is
awakened). If it is cleared, the event detection unit is disabled and no hardware breakpoint is generated,
but matching conditions are still reflected on the emulation pin.
0
Cell is disabled.
1
Cell is enabled.
12
CNT
Event Counter Enable. The event counter enable bit determines if the cell counter is used during the event
detection. In order to use the event counter during an event detection process, the event cell counter
register should be loaded with a value equal to the number of times minus one that an event occurs before
Table continues on the next page...
SDMA Internal (Core) Memory Map and Internal Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3368
NXP Semiconductors

<!-- page 3369 -->

SDMACORE_ECTL field descriptions (continued)
Field
Description
a debug request is sent. After every event detection, the counter is decreased. When the counter reaches
the value 0, the event detection cell sends a debug request to the core. The event counter register should
be written and the EN bit should be set before each new event detection process uses the event counter.
0
Counter is disabled.
1
Counter is enabled.
11–10
ECTC[1:0]
The event cell trigger condition bits select the combination of address and data matching conditions that
generate the final address/data condition. During program execution, if this event cell trigger condition
goes to 1, a debug request is sent to the SDMA. The EN bit must be set to enable the debug request
generation.
00
address ONLY
01
data ONLY
10
address AND data
11
address OR data
9–8
DTC[1:0]
The data trigger condition bits define when data is considered matching after comparison with the data
register of the event detection unit. The operations are performed on unsigned values.
00
equal
01
not equal
10
greater than
11
less than
7–6
ATC[1:0]
The address trigger condition bits select how the two address conditions (addressA and addressB) are
combined to define the global address matching condition. The supported combinations are described, as
follows.
00
addressA ONLY
01
addrA AND addrB
10
addrA OR addrB
11
reserved
5–4
ABTC[1:0]
The Address B Trigger Condition (ABTC) controls the operations performed by address comparator B. All
operations are performed on unsigned values. This comparator B outputs the addressB condition.
00
equal
01
not equal
10
greater than
11
less than
3–2
AATC[1:0]
The Address A Trigger Condition (AATC) controls the operations performed by address comparator A. All
operations are performed on unsigned values. This comparator A outputs the addressA condition.
00
equal
01
not equal
10
greater than
11
less than
ATS[1:0]
The access type select bits define the memory access type required on the SDMA memory bus.
00
read ONLY
01
write ONLY
10
read or write
11
-
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3369

<!-- page 3370 -->

46.10.10
OnCE Event Address Register A (SDMACORE_EAA)
Address: 201_C000h base + 28h offset = 201_C028h
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
EAA
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
SDMACORE_EAA field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
EAA
Event Cell Address Register A computes an address A condition. It is cleared on a JTAG reset.
46.10.11
OnCE Event Cell Address Register B
(SDMACORE_EAB)
Address: 201_C000h base + 2Ch offset = 201_C02Ch
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
EAB
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
SDMACORE_EAB field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
EAB
Event Cell Address Register B computes an address B condition. It is cleared on a JTAG reset.
46.10.12
OnCE Event Cell Address Mask (SDMACORE_EAM)
Address: 201_C000h base + 30h offset = 201_C030h
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
EAM
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
SDMA Internal (Core) Memory Map and Internal Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3370
NXP Semiconductors

<!-- page 3371 -->

SDMACORE_EAM field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
EAM
The Event Cell Address Mask contains a user-defined address mask value. This mask is applied to the
address value latched from the memory address bus before performing the address comparison.
NOTE: There is a common address mask value for both address comparators. If bit i of this register is
set, then bit i of the address value latched from the memory bus does not influence the result of
the address comparison. The register is cleared on a JTAG reset.
46.10.13
OnCE Event Cell Data Register (SDMACORE_ED)
Address: 201_C000h base + 34h offset = 201_C034h
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
ED
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
SDMACORE_ED field descriptions
Field
Description
ED
The event cell data register contains a user defined data value. This data value is an input for the data
comparator which generates the data condition. It is cleared on a JTAG reset.
46.10.14
OnCE Event Cell Data Mask (SDMACORE_EDM)
Address: 201_C000h base + 38h offset = 201_C038h
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
EDM
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
SDMACORE_EDM field descriptions
Field
Description
EDM
The event cell data mask register contains the user-defined data mask value.
• This mask is applied to the data value latched from the memory bus before performing the data
comparison.
• Setting bit i of the event cell data mask register means that bit i of the data value latched from the
address bus does not influence the result of the data comparison.
• The data mask is cleared on a JTAG reset.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3371

<!-- page 3372 -->

46.10.15
OnCE Real-Time Buffer (SDMACORE_RTB)
Address: 201_C000h base + 3Ch offset = 201_C03Ch
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
RTB
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
SDMACORE_RTB field descriptions
Field
Description
RTB
The Real Time Buffer register stores and retrieves run time information without putting the SDMA in debug
mode. Writing to that register triggers a pulse on a specific real-time debug pin whose connection depends
on the chip implementation.
The RTB value can be accessed by the OnCE under Arm platform or JTAG control using the rbuffer
command.
46.10.16
OnCE Trace Buffer (SDMACORE_TB)
Address: 201_C000h base + 40h offset = 201_C040h
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
TBF
TADDR
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
TADDR
CHFADDR
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
SDMACORE_TB field descriptions
Field
Description
31–29
Reserved
This read-only field is reserved and always has the value 0.
28
TBF
The Trace Buffer Flag is set when the buffer contains the addresses of a valid change of flow. The
contents of the buffer should be ignored otherwise.
0
Invalid information
1
Valid information
27–14
TADDR
The target address is the address taken after the execution of the change of flow instruction.
CHFADDR
The change of flow address is the address where the change of flow is taken when executing a change of
flow instruction.
SDMA Internal (Core) Memory Map and Internal Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3372
NXP Semiconductors

<!-- page 3373 -->

46.10.17
OnCE Status (SDMACORE_OSTAT)
Address: 201_C000h base + 44h offset = 201_C044h
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
PST[3:0]
RCV
EDR
ODR
SWB
MST
0
ECDR[2:0]
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
SDMACORE_OSTAT field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
15–12
PST[3:0]
The Processor Status bits reflect the state of the SDMA RISC engine.
• The "Program" state is the usual instruction execution cycle.
• The "Data" state is inserted when there are wait-states during a load or a store on the data bus (ld or
st).
• The "Change of Flow" state is the second cycle of any instruction that breaks the sequence of
instructions (jumps and channel-switching instructions).
• The "Change of Flow in Loop" state is used when an error causes a hardware loop exit.
• The "Debug" state means the SDMA is in debug mode.
• The "Functional Unit" state is inserted when there are wait-states during a load or a store on the
functional units bus (ldf or stf).
• In "Sleep" modes, no script is running (this is the RISC engine idle state). The "after Reset" is
slightly different because no context restoring phase will happen when a channel is triggered: The
script located at address 0 will be executed (boot operation).
• The "in Sleep" states are the same as above except they do not have any corresponding channel.
They are used when entering debug mode after reset; the reason is that it is necessary to return to
the "Sleep after Reset" state when leaving debug mode.
0
Program
1
Data
2
Change of Flow
3
Change of Flow in Loop
4
Debug
5
Functional Unit
6
Sleep
7
Save
8
Program in Sleep
9
Data in Sleep
10
Change of Flow in Sleep
11
Change Flow Loop Sleep
12
Debug in Sleep
13
Functional Unit in Sleep
Table continues on the next page...
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3373

<!-- page 3374 -->

SDMACORE_OSTAT field descriptions (continued)
Field
Description
14
Sleep after Reset
15
Restore
11
RCV
After each write access to the real time buffer (RTB), the RCV bit is set. This bit is cleared after execution
of an rbuffer command and on a JTAG reset.
10
EDR
This flag is raised when the SDMA has entered debug mode after an external debug request.
9
ODR
This flag is raised when the SDMA has entered debug mode after a OnCE debug request.
8
SWB
This flag is raised when the SDMA has entered debug mode after a software breakpoint.
7
MST
This flag is raised when the OnCE is controlled from the Arm platform peripheral interface.
0
JTAG interface controls the OnCE.
1
Arm platform peripheral interface controls the OnCE.
6–3
Reserved
This read-only field is reserved and always has the value 0.
ECDR[2:0]
Event Cell Debug Request. If the debug request comes from the event cell, the reason for entering debug
mode is given by the EDR bits. The encoding of the EDR bits is useful to find out more precisely why the
debug request was generated. A debug request from an event cell is generated for a specific combination
of the addressA, addressB, and data conditions; the value of those fields is given by the EDR bits. If all
three bits of the EDR are reset, then it did not generate any debug request. If the cell did generate a
debug request, then at least one EDR bit is set; the meaning of the encoding is as follows:
0
1 matched addressA condition
1
1 matched addressB condition
2
1 matched data condition
SDMA Internal (Core) Memory Map and Internal Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3374
NXP Semiconductors

<!-- page 3375 -->

46.10.18
Channel 0 Boot Address (SDMACORE_MCHN0ADDR)
Address: 201_C000h base + 48h offset = 201_C048h
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
SMSZ
CHN0ADDR[13:0]
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
SDMACORE_MCHN0ADDR field descriptions
Field
Description
31–15
Reserved
This read-only field is reserved and always has the value 0.
14
SMSZ
The bit 14 (Scratch Memory Size) determines if scratch memory must be available after every channel
context. After reset, it is equal to 0, which defines a RAM space of 24 words for each channel. All of
this area stores the channel context. By setting this bit, 32 words are reserved for every channel
context, which gives eight additional words that can be used by the channel script to store any type of
data. Those words are never erased by the context switching mechanism.
0
24 words per context
1
32 words per context
CHN0ADDR[13:0]
Contains the address of the channel 0 routine programmed by the Arm platform; it is loaded into a
general register at the very start of the boot and the SDMA jumps to the address it contains. By default,
it points to the standard boot routine in ROM.
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3375

<!-- page 3376 -->

46.10.19
ENDIAN Status Register (SDMACORE_ENDIANNESS)
Address: 201_C000h base + 4Ch offset = 201_C04Ch
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
0
APEND
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
SDMACORE_ENDIANNESS field descriptions
Field
Description
31–3
Reserved
This read-only field is reserved and always has the value 0.
2–1
Reserved
This read-only field is reserved and always has the value 0.
0
APEND
APEND indicates the endian mode of the Peripheral and Burst DMA interfaces. This bit is tied to logic '1'
indicating little-endian mode.
0
- Arm platform is in big-endian mode
1
- Arm platform is in little-endian mode
SDMA Internal (Core) Memory Map and Internal Register Definitions
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3376
NXP Semiconductors

<!-- page 3377 -->

46.10.20
Lock Status Register (SDMACORE_SDMA_LOCK)
Address: 201_C000h base + 54h offset = 201_C054h
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
0
0
SDMACORE_SDMA_LOCK field descriptions
Field
Description
31–1
Reserved
This read-only field is reserved and always has the value 0.
0
LOCK
The LOCK bit reports the value of the LOCK bit in the SDMA_LOCK status register. SDMA software may
use this value to determine if certain operations such as loading of new scripts is allowed.
0
- LOCK bit clear
1
- LOCK bit set
Chapter 46 Smart Direct Memory Access Controller (SDMA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3377

<!-- page 3378 -->

46.10.21
External DMA Requests Mirror #2
(SDMACORE_EVENTS2)
Address: 201_C000h base + 58h offset = 201_C058h
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
EVENTS
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
SDMACORE_EVENTS2 field descriptions
Field
Description
31–16
Reserved
This read-only field is reserved and always has the value 0.
EVENTS
Reflects the status of the SDMA's external DMA requests. It is meant to allow any channel to monitor the
states of these SDMA inputs.
This register displays EVENTS 32-47. The separate EVENTS register displays events 0-31.
46.11
SDMA Peripheral Registers
Refer to the respective peripherals' chapters for more information.
SDMA Peripheral Registers
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3378
NXP Semiconductors

