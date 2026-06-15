# Chapter 49: Shared Peripheral Bus Arbiter (SPBA)

> Nguồn: `IMX6ULLRM.pdf` — trang 3451–3464

<!-- page 3451 -->

Chapter 49
Shared Peripheral Bus Arbiter (SPBA)
49.1
Overview
The Shared Peripheral Bus Arbiter (SPBA) is a three-to-one IP Bus interface arbiter.
Three masters arbitrate for shared peripheral access through the SPBA.
The SPBA has three primary functions:
• The IP Bus Line switches a master to one peripheral
• The Masters arbiter arbitrates between the three masters to solve concurrent access or
restricted access to peripherals
• The Control Registers and Ownership Control includes a set of registers which are
reachable through software and permit the access scheme to be defined for each
peripheral (Resource Ownership and Access Control). It generates signals for the
external steering logic of interrupts and DMA signals.
The figure below shows the SPBA block diagram
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3451

<!-- page 3452 -->

MASTER A
MASTER B
MASTER C
Control
Registers 
+ 
Ownership
Control
Masters
Arbitration
SPBA
ma_dead_owner
mb_dead_owner
mc_dead_owner
IOSRTR
module
IPMUX
Per0
Per30
IP-bus interface
Out-of-band signals
obsc0
obsc31
Figure 49-1. SPBA Block Diagram
49.1.1
Features
The SPBA includes the following features:
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3452
NXP Semiconductors

<!-- page 3453 -->

• Three IP Bus masters arbitration: Master A, B and C
• Support for DMA masters
• 32-bit data
• Supports up to 31 shared peripherals, each consuming 16 kilobytes of address space
• SPBA can be considered the 32nd peripheral, used for resource ownership and access
control of the 31 peripherals
• Provides 31 sets of out of band steering control (OBSC) signals to the off-block
steering logic
• Operating frequency up to 67 MHz
• Clocks: ipg_clk, ipg_clk_s
49.1.2
Modes of operation
SPBA behavior is transparent when accessing a peripheral, though it has these distinct
modes of operation.
Reset/Abort
The SPBA has a hardware reset which initializes all registers, arbitration and
peripherals rights registers (PRRs).
An abort signal input is provided allowing each master to abort its current access and
release ownership (in case of master reset sequence).
Functional
Once a master request is granted, its IP Bus signals are steered to the requested
peripheral.
Standby
No clock needed. The SPBA needs clocks only during access to the PRRs, arbitration,
and abort phases. It generates two clock enable signals indicating when the clocks
must be provided.
Configuration
During this phase, a master accesses the SPBA PRRs. The SPBA memory-mapped
registers are seen as a shared peripheral.
49.2
Clocks
The table found here describes the clock sources for SPBA.
Chapter 49 Shared Peripheral Bus Arbiter (SPBA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3453

<!-- page 3454 -->

Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 49-1. SPBA Clocks
Clock name
Clock Root
Description
ipg_clk
ipg_clk_root
Peripheral clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
49.3
Functional description
49.3.1
Masters arbitration
The arbitration mechanism determines which port will control the master port, based on a
simple round-robin arbitration scheme.
There are several use cases to consider.
• Only one master request per access. The master is switched to the shared peripheral
bus, without arbitration. Figure 49-2 shows the MB request on the global module
enable signal, served without wait state.
• If two masters simultaneously access SPBA, the last granted master is held off using
the <master>_ips_xfr_wait output signal (default value is high). When the master is
granted sips_xfr_wait, shared IP Bus peripheral is connected to
<master>_ips_xfr_wait outputs.
• If three masters simultaneously access SPBA, then the last two granted masters are
held off using <master>_ips_xfr_wait. Figure 49-3 shows a case in which the last
two accesses granted are MA and MB. The requests are used even if they are in the
same cycle.
• If after reset, at the first multiple access, no master has been granted, the priority is
static: Master A (MA), Master B (MB) and last Master C (MC) port.
• No master request. No master switch to shared peripherals.
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3454
NXP Semiconductors

<!-- page 3455 -->

0x0000000
valid data
valid data
ipg_clk
mb_ips_module_en
mb_ips_addr[24:0]
mb_ips_xfr_wait
mb_ips_rdata[31:0]
sips_module_en[0]
sips_ips_xfr_wait
sips_rdata[31:0]
Figure 49-2. Example of one master request, no SPBA arbitration
The following figure assumes MA and MB have been the last two masters granted in the
previous transfers (MA then MB).
Chapter 49 Shared Peripheral Bus Arbiter (SPBA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3455

<!-- page 3456 -->

0x0000000
valid data
0x004000
valid data
0x0008000
valid data
MC
MA
MB
clk
mb_ips_module_en
mb_ips_addr[24:0]
mb_ips_xfer_wait
mb_ips_rdata[31:0]
ma_ips_module_en
ma_ips_addr[24:0]
ma_ips_xfer_wait
ma_ips_rdata[31:0]
mc_ips_module_en
mc_ips_addr[24:0]
mc_ips_xfer_wait
mc_ips_rdata[31:0]
sips_module_en[0]
sips_module_en[1]
sips_module_en[2]
MASTER_GRANTED
Figure 49-3. Example of three master requests: Masters already granted are "waited";
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3456
NXP Semiconductors

<!-- page 3457 -->

49.4
Resource ownership control
The resource ownership control regulates access to the shared peripherals and determines
the steering of out-of-band signals.
49.4.1
Access control
Chapter 49 Shared Peripheral Bus Arbiter (SPBA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3457

<!-- page 3458 -->

49.4.1.1
Peripheral access
The peripheral access (resource access) of the requesting master is given by the
corresponding RAR bit of the Peripheral Right Register. It determines if the master has
access privilege to the resource.
Any attempt at access made by a requesting master whose access privilege bit is not set
(in the PRR) is terminated with a bus error (<master>_ips_xfr_err is asserted by SPBA
logic). The master that owns the resource can lock the peripheral for itself and/or grant
other masters access to the peripheral by setting the appropriate bit(s) in the RAR field.
0x3C008
31'd2
ipg_clk_s
mb_ips_module_en
mb_ips_addr[24:0]
mb_ips_wdata[31:0]
mb_ips_rwb
mb_ips_xfr_wait
obsc2[4:0]
5'b10010
Master B is taking ownership of peripheral 2 by writing 3'b010 in the SPBA peripheral 2 right register (rarfield)
This ownership can be checked on obsc2 output as roi2[1:0] = 2'b10 and rar2[2:0] = 3'b010
(obsc[4:0] = {roi2[1], roi2[0], rar2[2], rar2[1], rar2[0]})
Figure 49-4. Example of one master B gaining ownership of peripheral 2
49.4.1.2
Peripheral Right Register access
The ROI bits of the Peripheral Right Register (PRR) determine which master is allowed
to make write access to PRR. The identification of the requesting master is compared to
the ROI bits of the PRR to determine if the master has ownership of the corresponding
register.
Resource ownership control
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3458
NXP Semiconductors

<!-- page 3459 -->

Any attempted write access to a PRR already owned by another master will be ignored.
49.4.2
Owner election
When the peripheral is not owned by any master (ROI="00", after coming out of reset for
instance), the first master to perform successfully a write to the RAR bits of the PRR is
granted ownership of the peripheral and its associated PRR.
After writing to the PRR (RAR bit(s)), the master must read it back to make sure that it
was granted ownership. If the RMO field is 2'b11, then the ownership claim is successful.
If RMO is 2'b10, another master claimed ownership before this master was able to
complete its write. This resolves the case in which two or more masters attempt to write
the PRR at the same time; only the first master will be granted ownership. However all
masters must read the PRR to determine if this case occurred, and if so, whether they
were the first master which was granted ownership.
NOTE
A master that has been granted ownership of the PRR does not
automatically have the right access to the peripheral; it must
still set its own RAR bits in the PRR to access the peripheral.
49.4.3
Ending ownership
Ownership may be voluntarily ended by the owning master, or automatically upon
assertion of a master-specific dead_owner signal.
The former is appropriate for software-controlled yielding of ownership. The latter is
appropriate for automatic yielding of ownership when the owner has gone into reset.
When a master is reset, it clears the ROI bits of the PRRs owned by the corresponding
master. When the owner is dead (in reset), all peripherals previously owned by that
master must be changed to the un-owned state.
NOTE
It is the programmer's responsibility to make sure the
peripherals are placed in an appropriate state before ending
ownership.
Chapter 49 Shared Peripheral Bus Arbiter (SPBA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3459

<!-- page 3460 -->

49.4.3.1
Software Controlled Ownership Ending
The ROI bits will be automatically cleared when the master that owns the PRR access
right clears (write) the RAR bits (Table 2).
It will then end the ownership of the PRR.
49.4.4
The Un-owned State
During the time when the peripheral is un-owned (i.e the ROI field contains all 0's), all
masters have full access to it (RAR bits can then be modified by a master if ROI[1:0] =
2'b0).
In such cases it is necessary for software to ensure any necessary coherency in the
resource, there is no hardware protection.
49.5
SPBA Memory Map/Register Definition
The SPBA control registers (Peripheral Right Registers) are mapped as a virtual shared
peripheral.
SPBA can support up to 31 shared peripherals. Each of them has its own Peripheral Right
Register (PRR) accessible within the SPBA memory-mapped registers, and consists of
the Requesting Master Owner, the Resource Owner ID and the Resource Access Right
fields.
SPBA memory map
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
203_C000
Peripheral Rights Register (SPBA_PRR0)
32
R/W
0000_0007h
49.5.1/3462
203_C004
Peripheral Rights Register (SPBA_PRR1)
32
R/W
0000_0007h
49.5.1/3462
203_C008
Peripheral Rights Register (SPBA_PRR2)
32
R/W
0000_0007h
49.5.1/3462
203_C00C
Peripheral Rights Register (SPBA_PRR3)
32
R/W
0000_0007h
49.5.1/3462
203_C010
Peripheral Rights Register (SPBA_PRR4)
32
R/W
0000_0007h
49.5.1/3462
203_C014
Peripheral Rights Register (SPBA_PRR5)
32
R/W
0000_0007h
49.5.1/3462
203_C018
Peripheral Rights Register (SPBA_PRR6)
32
R/W
0000_0007h
49.5.1/3462
203_C01C
Peripheral Rights Register (SPBA_PRR7)
32
R/W
0000_0007h
49.5.1/3462
203_C020
Peripheral Rights Register (SPBA_PRR8)
32
R/W
0000_0007h
49.5.1/3462
Table continues on the next page...
SPBA Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3460
NXP Semiconductors

<!-- page 3461 -->

SPBA memory map (continued)
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
203_C024
Peripheral Rights Register (SPBA_PRR9)
32
R/W
0000_0007h
49.5.1/3462
203_C028
Peripheral Rights Register (SPBA_PRR10)
32
R/W
0000_0007h
49.5.1/3462
203_C02C
Peripheral Rights Register (SPBA_PRR11)
32
R/W
0000_0007h
49.5.1/3462
203_C030
Peripheral Rights Register (SPBA_PRR12)
32
R/W
0000_0007h
49.5.1/3462
203_C034
Peripheral Rights Register (SPBA_PRR13)
32
R/W
0000_0007h
49.5.1/3462
203_C038
Peripheral Rights Register (SPBA_PRR14)
32
R/W
0000_0007h
49.5.1/3462
203_C03C
Peripheral Rights Register (SPBA_PRR15)
32
R/W
0000_0007h
49.5.1/3462
203_C040
Peripheral Rights Register (SPBA_PRR16)
32
R/W
0000_0007h
49.5.1/3462
203_C044
Peripheral Rights Register (SPBA_PRR17)
32
R/W
0000_0007h
49.5.1/3462
203_C048
Peripheral Rights Register (SPBA_PRR18)
32
R/W
0000_0007h
49.5.1/3462
203_C04C
Peripheral Rights Register (SPBA_PRR19)
32
R/W
0000_0007h
49.5.1/3462
203_C050
Peripheral Rights Register (SPBA_PRR20)
32
R/W
0000_0007h
49.5.1/3462
203_C054
Peripheral Rights Register (SPBA_PRR21)
32
R/W
0000_0007h
49.5.1/3462
203_C058
Peripheral Rights Register (SPBA_PRR22)
32
R/W
0000_0007h
49.5.1/3462
203_C05C
Peripheral Rights Register (SPBA_PRR23)
32
R/W
0000_0007h
49.5.1/3462
203_C060
Peripheral Rights Register (SPBA_PRR24)
32
R/W
0000_0007h
49.5.1/3462
203_C064
Peripheral Rights Register (SPBA_PRR25)
32
R/W
0000_0007h
49.5.1/3462
203_C068
Peripheral Rights Register (SPBA_PRR26)
32
R/W
0000_0007h
49.5.1/3462
203_C06C
Peripheral Rights Register (SPBA_PRR27)
32
R/W
0000_0007h
49.5.1/3462
203_C070
Peripheral Rights Register (SPBA_PRR28)
32
R/W
0000_0007h
49.5.1/3462
203_C074
Peripheral Rights Register (SPBA_PRR29)
32
R/W
0000_0007h
49.5.1/3462
203_C078
Peripheral Rights Register (SPBA_PRR30)
32
R/W
0000_0007h
49.5.1/3462
203_C07C
Peripheral Rights Register (SPBA_PRR31)
32
R/W
0000_0007h
49.5.1/3462
Chapter 49 Shared Peripheral Bus Arbiter (SPBA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3461

<!-- page 3462 -->

49.5.1
Peripheral Rights Register (SPBA_PRRn)
This register controls master ownership and access for a peripheral.
Address: 203_C000h base + 0h offset + (4d × i), where i=0d to 31d
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
RMO
Reserved
ROI
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
RARC
RARB
RARA
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
1
SPBA_PRRn field descriptions
Field
Description
31–30
RMO
Requesting Master Owner. This 2-bit register field indicates if the corresponding resource is owned by the
requesting master or not. This register is reset to 2'b0 if ROI = 2'b0.
00
UNOWNED — The resource is unowned.
01
Reserved.
10
ANOTHER_MASTER — The resource is owned by another master.
11
REQUESTING_MASTER — The resource is owned by the requesting master.
29–18
-
This field is reserved.
Reserved
17–16
ROI
Resource Owner ID. This field indicates which master (one at a time) can access to the PRR for rights
modification. This is a read-only register.
After reset, ROI bits are cleared ("00" -> un-owned resource).
Table continues on the next page...
SPBA Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3462
NXP Semiconductors

<!-- page 3463 -->

SPBA_PRRn field descriptions (continued)
Field
Description
A master performing a write access to the an un-owned PRR will get its ID automatically written into ROI,
while modifying RARx bits. It can then read back the RMO, RAR, ROI bits to make sure RMO returns the
right value, ROI bits contain its ID and RARx bits are correctly asserted. Then no other master (whom ID is
different from the one stored in ROI) will be able to modify RAR fields.
Owner master of a peripheral can assert its dead_owner signal, or write 1'b0 in the RARx to release the
ownership (ROI[1:0] reset to 2'b0).
00
UNOWNED — Unowned resource.
01
MASTER_A — The resource is owned by master A port.
10
MASTER_B — The resource is owned by master B port.
11
MASTER_C — The resource is owned by master C port.
15–3
-
This field is reserved.
Reserved
2
RARC
Resource Access Right. Control and Status bit for master C.
This field indicates whether master C can access the peripheral. From 0 up to 3 masters can have
permission to access a resource (all the master can be granted on a peripheral, but only one access at a
time will be granted by SPBA).
0
PROHIBITED — Access to peripheral is not allowed.
1
ALLOWED — Access to peripheral is granted.
1
RARB
Resource Access Right. Control and Status bit for master B.
This field indicates whether master B can access the peripheral. From 0 up to 3 masters can have
permission to access a resource (all the master can be granted on a peripheral, but only one access at a
time will be granted by SPBA).
0
PROHIBITED — Access to peripheral is not allowed.
1
ALLOWED — Access to peripheral is granted.
0
RARA
Resource Access Right. Control and Status bit for master A.
This field indicates whether master A can access the peripheral. From 0 up to 3 masters can have
permission to access a resource (all the master can be granted on a peripheral, but only one access at a
time will be granted by SPBA).
0
PROHIBITED — Access to peripheral is not allowed.
1
ALLOWED — Access to peripheral is granted.
Chapter 49 Shared Peripheral Bus Arbiter (SPBA)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3463

<!-- page 3464 -->

SPBA Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3464
NXP Semiconductors

