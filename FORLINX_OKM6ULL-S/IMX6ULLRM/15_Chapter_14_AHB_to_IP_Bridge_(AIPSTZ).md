# Chapter 14: AHB to IP Bridge (AIPSTZ)

> Nguồn: `IMX6ULLRM.pdf` — trang 443–464

<!-- page 443 -->

Chapter 14
AHB to IP Bridge (AIPSTZ)
14.1
Overview
This section provides an overview of the AHB to IP Bridge (AIPSTZ). This particular
peripheral is designed as the bridge between AHB bus and peripherals with the lower
bandwidth IP Slave (IPS) buses.
14.1.1
Features
The following list summarizes the key features of the bridge:
• The bridge supports the IPS slave bus signals. This interface is only meant for slave
peripherals.
• The bridge supports 8-, 16-, and 32-bit IPS peripherals. (Accesses larger than the size
of a peripheral are not supported, except to 32-bit memory.)
• The bridge supports a pair of IPS accesses for 64-bit and certain misaligned AHB
transfers to 32-bit memory in 64-bit platforms.
• The bridge directly supports up to 32 16-Kbyte external IPS peripherals, and 2 global
external IPS peripheral spaces. The bridge occupies 1 MBytes of total address space.
• The bridge provides configurable per-block and per-master access protections.
Access permissions are based on bus master (e.g. DMA or core) privilege levels and
resource domain. More details on the protection features and configuration can be
found in the Security Reference Manual
• Peripheral read transactions require a minimum of 2 hclk clocks, and unbuffered
write transactions require a minimum of 3 hclk clocks.
• The bridge uses one single asynchronous reset and one global clock.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
443

<!-- page 444 -->

14.2
Clocks
The following table describes the clock sources for AIPSTZ. Please see Clock Controller
Module (CCM) for clock setting, configuration and gating information.
Table 14-1. AIPSTZ Clocks
Clock name
Clock Root
Description
hclk
ahb_clk_root
Module clock
14.3
Functional Description
The AIPS bridge serves as a protocol translator between the AHB system bus and the IP
bus.
Support is provided for generating a pair of 32-bit IP bus accesses when targeted by a 64-
bit system bus access, or a misaligned access which crosses a 32-bit boundary. No other
bus-sizing access support is provided.
The AHB to IP bridge is the interface between the AHB and on-chip IPS peripherals,
which are sub-blocks containing readable/writable control and status registers.
The AHB master reads and writes these registers through the AIPSTZ. The bridge
generates block enables, the block address, transfer attributes, byte enables and write data
as inputs to the IPS peripherals. The bridge captures read data from the IPS interface and
drives it on the AHB.
Each bridge that connects to the IPS (or peripherals) are referred as AIPS. The chip has
three separate AIPS modules, and peripherals are grouped and assigned under each AIPS
block. The list of peripherals are indicated as n-1, n-2, and n-3 for AIPS-1, AIPS-2, and
AIPS-3 respectively.
AIPS occupies a 1-Mbyte portion of the address space. The register maps of the IPS
peripherals are located on 16-Kbyte boundaries. Each IPS peripheral is allocated one 16-
Kbyte block of the memory map, and is activated by one of the block enables from the
bridge. Up to thirty-two 16-Kbyte external IPS peripherals may be implemented,
occupying contiguous blocks of 16-Kbytes. Two global external IPS block enables are
available for the remaining address space to allow for customization and expansion of
addressed peripheral devices. In addition, a single "non-global" block enable is also
asserted whenever any of the thirty-two non-global block enables is asserted.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
444
NXP Semiconductors

<!-- page 445 -->

The bridge is responsible for indicating to IPS peripherals if an access is in supervisor or
user mode. It may block user mode accesses to certain IPS peripherals or it may allow the
individual IPS peripherals to determine if user mode accesses are allowed. In addition,
peripherals may be designated as write-protected.
The bridge supports the notion of "trusted" masters for security purposes. Masters may be
individually designated as trusted for reads, trusted for writes, or trusted for both reads
and writes, as well as being forced to look as though all accesses from a master are in
user-mode privilege level. Refer to AIPSTZ Memory Map/Register Definition for more
information.
The AIPSTZ prevents access to a peripheral if the transaction originated from a source
from a resource domain that has been explicitly omitted. Resource domains are assigned
in the RDC submodule. Please refer to the RDC chapter for programming details.
All peripheral devices are expected to only require aligned accesses equal to or smaller in
size than the peripheral size. An exception to this rule is supported for 32-bit peripherals
to allow memory to be placed on the IPS.
14.4
Access Protections
The AIPSTZ bridge provides programmable access protections for both masters and
peripherals. It allows the privilege level of a master to be overridden, forcing it to user-
mode privilege, and allows masters to be designated as trusted or untrusted.
Peripherals may require supervisor privilege level for access, may restrict access to a
trusted master only, and may be write-protected. IP bus peripherals are subject to access
control policies set in both CSU registers and AIPSTZ registers. An access is blocked if it
is denied by either policy.
Masters and peripherals are assigned to one or more resource domains in the RDC
submodule (see the RDC chapter for details). Depending on RDC programming, masters
transactions through the AIPSTZ may or may not be allowed access to peripherals in
different resource domains.
14.5
Access Support
Aligned 64-bit accesses, aligned and misaligned word and half word accesses, as well as
byte accesses are supported for 32-bit peripherals. Misaligned accesses are supported to
allow memory to be placed on the IPS.
Chapter 14 AHB to IP Bridge (AIPSTZ)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
445

<!-- page 446 -->

Peripheral registers must not be misaligned, although no explicit checking is performed
by the AIPS bridge. The bridge will perform two IPS transfers for 64-bit accesses, word
accesses with byte offsets of 1, 2, or 3, and for half word accesses with a byte offset of 3.
All other accesses will be performed with a single IPS transfer.
Only aligned half word and byte accesses are supported for 16-bit peripherals. All other
accesses types are unsupported, and results of such accesses are undefined. They are not
terminated with an error response.
Only byte accesses are supported for 8-bit peripherals. All other accesses types are
unsupported, and results of such accesses are undefined. They are not terminated with an
error response.
14.6
Initialization Information
The AIPS bridge should be programmed before use.
The following registers should be initialized: The Master Privilege Registers
(AIPSTZ_MPRs), the Peripheral Access Control registers (AIPSTZ_PACRs), and the
Off-platform Peripheral Access Control registers (AIPSTZ_OPACRs) described in
AIPSTZ Memory Map/Register Definition.
14.6.1
Security Block
The AIPSTZ contains a security block that is connected to each off-platform peripheral.
This block filters accesses based on write/read, non-secure, and supervisor signals.
Each peripheral can be individually configured to allow or deny each of the following
transactions as described in the table below:
Table 14-2. Peripheral Access Configuration options
Config Bit
Write
Non-Secure
Supervisor
Meaning
0
0
0
0
Secure User Read
1
0
0
1
Secure Supervisor Read
2
0
1
0
Non-Secure User Read
3
0
1
1
Non-Secure Supervisor Read
4
1
0
0
Secure User Write
5
1
0
1
Secure Supervisor Write
6
1
1
0
Non-Secure User Write
7
1
1
1
Non-Secure Supervisor Write
Initialization Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
446
NXP Semiconductors

<!-- page 447 -->

Each peripheral has a security configuration (sec_config_X) input for determining
whether to allow or deny a given access type. These are 8-bit vectors, with each bit
corresponding to one of the transactions above as listed in the Config Bit column of
Table 14-2. If the bit is asserted (1'b1), the transaction is allowed. If the bit is negated
(1'b0), the transaction is not allowed.
For example, if peripheral 0 is configured as follows:
sec_config_0 [7:0] = 8'b0011_0011
This peripheral can only be accessed by secure transactions. Bits 0, 1, 4, and 5 are
asserted and these bits refer to the four types of secure transactions. If an insecure
transaction is attempted to this peripheral, it will result in an error.
Eight bits per peripheral across an entire system can result in a large number of
configuration bits that must be assigned and controlled, most likely in a series of registers
in another block. To reduce the number of register bits required predefined sets of
security profiles can be defined and encapsulated in an external security translation block.
The table below describes one set of security profiles that has been proposed for use with
the AIPSTZ.
Table 14-3. Security Levels
CSU_SEC_LEVEL
Non-Secure User
Non-Secure
Supervisor
Secure User
Secure Supervisor
0
RD+WR
RD+WR
RD+WR
RD+WR
1
NOT ALLOWED
RD+WR
RD+WR
RD+WR
2
Read Only
Read Only
RD+WR
RD+WR
3
NOT ALLOWED
Read Only
RD+WR
RD+WR
4
NOT ALLOWED
NOT ALLOWED
RD+WR
RD+WR
5
NOT ALLOWED
NOT ALLOWED
NOT ALLOWED
RD+WR
6
NOT ALLOWED
NOT ALLOWED
Read Only
Read Only
7
NOT ALLOWED
NOT ALLOWED
NOT ALLOWED
NOT ALLOWED
Information regarding CSU is provided in the Security Reference Manual. Contact your
NXP representative for information about obtaining this document.
A 3-bit input, 8-bit output translation block can be used such that only three register bits
are required to set the security profile and the translation block will drive the correct 8-bit
configuration vector. Each peripheral connected to the AIPSTZ would require this
translation block. The top level AIPSTZ has this three bit input line `csu_sec_level[2:0]'
corresponding to each peripheral X.
Chapter 14 AHB to IP Bridge (AIPSTZ)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
447

<!-- page 448 -->

14.7
AIPSTZ Memory Map/Register Definition
The memory map for the AIPS SW-visible registers is shown in the table below.
The MPROT and OPACR fields are 4 bits in width. Some bits may be reserved
depending on device.
AIPSTZ memory map
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
207_C000
Master Priviledge Registers (AIPSTZ1_MPR)
32
R/W
7700_0000h
14.7.1/449
207_C040
Off-Platform Peripheral Access Control Registers
(AIPSTZ1_OPACR)
32
R/W
4444_4444h
14.7.2/451
207_C044
Off-Platform Peripheral Access Control Registers
(AIPSTZ1_OPACR1)
32
R/W
4444_4444h
14.7.3/454
207_C048
Off-Platform Peripheral Access Control Registers
(AIPSTZ1_OPACR2)
32
R/W
4444_4444h
14.7.4/457
207_C04C
Off-Platform Peripheral Access Control Registers
(AIPSTZ1_OPACR3)
32
R/W
4444_4444h
14.7.5/460
207_C050
Off-Platform Peripheral Access Control Registers
(AIPSTZ1_OPACR4)
32
R/W
4444_4444h
14.7.6/463
217_C000
Master Priviledge Registers (AIPSTZ2_MPR)
32
R/W
7700_0000h
14.7.1/449
217_C040
Off-Platform Peripheral Access Control Registers
(AIPSTZ2_OPACR)
32
R/W
4444_4444h
14.7.2/451
217_C044
Off-Platform Peripheral Access Control Registers
(AIPSTZ2_OPACR1)
32
R/W
4444_4444h
14.7.3/454
217_C048
Off-Platform Peripheral Access Control Registers
(AIPSTZ2_OPACR2)
32
R/W
4444_4444h
14.7.4/457
217_C04C
Off-Platform Peripheral Access Control Registers
(AIPSTZ2_OPACR3)
32
R/W
4444_4444h
14.7.5/460
217_C050
Off-Platform Peripheral Access Control Registers
(AIPSTZ2_OPACR4)
32
R/W
4444_4444h
14.7.6/463
227_C000
Master Priviledge Registers (AIPSTZ3_MPR)
32
R/W
7700_0000h
14.7.1/449
227_C040
Off-Platform Peripheral Access Control Registers
(AIPSTZ3_OPACR)
32
R/W
4444_4444h
14.7.2/451
227_C044
Off-Platform Peripheral Access Control Registers
(AIPSTZ3_OPACR1)
32
R/W
4444_4444h
14.7.3/454
227_C048
Off-Platform Peripheral Access Control Registers
(AIPSTZ3_OPACR2)
32
R/W
4444_4444h
14.7.4/457
227_C04C
Off-Platform Peripheral Access Control Registers
(AIPSTZ3_OPACR3)
32
R/W
4444_4444h
14.7.5/460
227_C050
Off-Platform Peripheral Access Control Registers
(AIPSTZ3_OPACR4)
32
R/W
4444_4444h
14.7.6/463
AIPSTZ Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
448
NXP Semiconductors

<!-- page 449 -->

14.7.1
Master Priviledge Registers (AIPSTZx_MPR)
Each AIPSTZ_MPR specifies 16 4-bit fields defining the access privilege level
associated with a bus master in the platform, as well as specifying whether write accesses
from this master are bufferable shown in Table 14-4
The registers provide one field per bus master, where field 15 corresponds to master 15,
field 14 to master 14,... field 0 to master 0 (typically the processor core). The master
index allocation is shown in Table 14-5.
Table 14-4. MPROT Field
Bit
Field
Description
3
MBW
Master Buffer Writes - This bit determines whether the AIPSTZ is enabled to buffer writes
from this master.
2
MTR
Master Trusted for Reads - This bit determines whether the master is trusted for read
accesses.
1
MTW
Master Trusted for Writes - This bit determines whether the master is trusted for write
accesses.
0
MPL
Master Privilege Level - This bit determines how the privilege level of the master is
determined.
NOTE
The reset value is set to 0000_0000_7700_0000, which makes
master 0 and master 1 (Arm CORE) the trusted masters.
Trusted software can change the settings after reset.
Table 14-5. Master Index Allocation
Master Index
Master Name
Comments
Master 0
All masters excluding Arm core, SDMA and CAAM
Share the same number allocation.
Master 1
Arm A7 CORE
Master 2
CAAM
Master 3
SDMA
Master 4
Reserved
Master 5
Arm M4 Core
Master 6-15
Reserved
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
MPROT0
MPROT1
MPROT2
MPROT3
Reserved
MPROT5
Reserved
W
Reset 0
1
1
1
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
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 14 AHB to IP Bridge (AIPSTZ)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
449

<!-- page 450 -->

AIPSTZx_MPR field descriptions
Field
Description
31–28
MPROT0
Master 0 Priviledge, Buffer, Read, Write Control
xxx0
MPL — Accesses from this master are forced to user-mode (ips_supervisor_access is forced to
zero) regardless of the hprot[1] access attribute.
xxx1
MPL — Accesses from this master are not forced to user-mode. The hprot[1] access attribute is
used directly to determine ips_supervisor_access.
xx0x
MTW — This master is not trusted for write accesses.
xx1x
MTW — This master is trusted for write accesses.
x0xx
MTR — This master is not trusted for read accesses.
x1xx
MTR — This master is trusted for read accesses.
0xxx
MBW — Write accesses from this master are not bufferable
1xxx
MBW — Write accesses from this master are allowed to be buffered
27–24
MPROT1
Master 1 Priviledge, Buffer, Read, Write Control
xxx0
MPL — Accesses from this master are forced to user-mode (ips_supervisor_access is forced to
zero) regardless of the hprot[1] access attribute.
xxx1
MPL — Accesses from this master are not forced to user-mode. The hprot[1] access attribute is
used directly to determine ips_supervisor_access.
xx0x
MTW — This master is not trusted for write accesses.
xx1x
MTW — This master is trusted for write accesses.
x0xx
MTR — This master is not trusted for read accesses.
x1xx
MTR — This master is trusted for read accesses.
0xxx
MBW — Write accesses from this master are not bufferable
1xxx
MBW — Write accesses from this master are allowed to be buffered
23–20
MPROT2
Master 2 Priviledge, Buffer, Read, Write Control
xxx0
MPL — Accesses from this master are forced to user-mode (ips_supervisor_access is forced to
zero) regardless of the hprot[1] access attribute.
xxx1
MPL — Accesses from this master are not forced to user-mode. The hprot[1] access attribute is
used directly to determine ips_supervisor_access.
xx0x
MTW — This master is not trusted for write accesses.
xx1x
MTW — This master is trusted for write accesses.
x0xx
MTR — This master is not trusted for read accesses.
x1xx
MTR — This master is trusted for read accesses.
0xxx
MBW — Write accesses from this master are not bufferable
1xxx
MBW — Write accesses from this master are allowed to be buffered
19–16
MPROT3
Master 3 Priviledge, Buffer, Read, Write Control.
xxx0
MPL — Accesses from this master are forced to user-mode (ips_supervisor_access is forced to
zero) regardless of the hprot[1] access attribute.
xxx1
MPL — Accesses from this master are not forced to user-mode. The hprot[1] access attribute is
used directly to determine ips_supervisor_access.
xx0x
MTW — This master is not trusted for write accesses.
xx1x
MTW — This master is trusted for write accesses.
x0xx
MTR — This master is not trusted for read accesses.
x1xx
MTR — This master is trusted for read accesses.
0xxx
MBW — Write accesses from this master are not bufferable
1xxx
MBW — Write accesses from this master are allowed to be buffered
Table continues on the next page...
AIPSTZ Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
450
NXP Semiconductors

<!-- page 451 -->

AIPSTZx_MPR field descriptions (continued)
Field
Description
15–12
-
This field is reserved.
Reserved
11–8
MPROT5
Master 5 Priviledge, Buffer, Read, Write Control.
xxx0
MPL — Accesses from this master are forced to user-mode (ips_supervisor_access is forced to
zero) regardless of the hprot[1] access attribute.
xxx1
MPL — Accesses from this master are not forced to user-mode. The hprot[1] access attribute is
used directly to determine ips_supervisor_access.
xx0x
MTW — This master is not trusted for write accesses.
xx1x
MTW — This master is trusted for write accesses.
x0xx
MTR — This master is not trusted for read accesses.
x1xx
MTR — This master is trusted for read accesses.
0xxx
MBW — Write accesses from this master are not bufferable
1xxx
MBW — Write accesses from this master are allowed to be buffered
-
This field is reserved.
Reserved
14.7.2
Off-Platform Peripheral Access Control Registers
(AIPSTZx_OPACR)
Each of the off-platform peripherals have an Off-platform Peripheral Access Control
Register (AIPSTZ_OPACR) which defines the access levels supported by the given
block.
Each AIPSTZ_OPACR has the following format shown in Table 14-6
Table 14-6. OPAC Field
Bit
Field
Description
3
BW
Buffer Writes - This bit determines whether write accesses to this peripheral are allowed to
be buffered.1
2
SP
Supervisor Protect - This bit determines whether the peripheral requires supervisor privilege
level for access.
1
WP
Write Protect - This bit determines whether the peripheral allows write accesses.
0
TP
Trusted Protect - This bit determines whether the peripheral allows accesses from an
untrusted master.
1.
Buffered writes are not available for AIPSTZ. This bit should be set to '0'.
Address: Base address + 40h offset
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
OPAC0
OPAC1
OPAC2
OPAC3
OPAC4
OPAC5
OPAC6
OPAC7
W
Reset 0
1
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
0
1
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
0
1
0
0
0
1
0
0
Chapter 14 AHB to IP Bridge (AIPSTZ)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
451

<!-- page 452 -->

AIPSTZx_OPACR field descriptions
Field
Description
31–28
OPAC0
Off-platform Peripheral Access Control 0
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
27–24
OPAC1
Off-platform Peripheral Access Control 1
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
23–20
OPAC2
Off-platform Peripheral Access Control 2
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
19–16
OPAC3
Off-platform Peripheral Access Control 3
Table continues on the next page...
AIPSTZ Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
452
NXP Semiconductors

<!-- page 453 -->

AIPSTZx_OPACR field descriptions (continued)
Field
Description
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
15–12
OPAC4
Off-platform Peripheral Access Control 4
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
11–8
OPAC5
Off-platform Peripheral Access Control 5
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
7–4
OPAC6
Off-platform Peripheral Access Control 6
xxx0
TP — Accesses from an untrusted master are allowed.
Table continues on the next page...
Chapter 14 AHB to IP Bridge (AIPSTZ)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
453

<!-- page 454 -->

AIPSTZx_OPACR field descriptions (continued)
Field
Description
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
OPAC7
Off-platform Peripheral Access Control 7
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
14.7.3
Off-Platform Peripheral Access Control Registers
(AIPSTZx_OPACR1)
Each of the off-platform peripherals have an Off-platform Peripheral Access Control
Register (AIPSTZ_OPACR) which defines the access levels supported by the given
block.
Each AIPSTZ_OPACR has the following format shown in Table 14-6
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
OPAC8
OPAC9
OPAC10
OPAC11
OPAC12
OPAC13
OPAC14
OPAC15
W
Reset 0
1
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
0
1
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
0
1
0
0
0
1
0
0
AIPSTZ Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
454
NXP Semiconductors

<!-- page 455 -->

AIPSTZx_OPACR1 field descriptions
Field
Description
31–28
OPAC8
Off-platform Peripheral Access Control 8
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
27–24
OPAC9
Off-platform Peripheral Access Control 9
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
23–20
OPAC10
Off-platform Peripheral Access Control 10
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
19–16
OPAC11
Off-platform Peripheral Access Control 11
Table continues on the next page...
Chapter 14 AHB to IP Bridge (AIPSTZ)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
455

<!-- page 456 -->

AIPSTZx_OPACR1 field descriptions (continued)
Field
Description
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
15–12
OPAC12
Off-platform Peripheral Access Control 12
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
11–8
OPAC13
Off-platform Peripheral Access Control 13
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
7–4
OPAC14
Off-platform Peripheral Access Control 14
xxx0
TP — Accesses from an untrusted master are allowed.
Table continues on the next page...
AIPSTZ Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
456
NXP Semiconductors

<!-- page 457 -->

AIPSTZx_OPACR1 field descriptions (continued)
Field
Description
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
OPAC15
Off-platform Peripheral Access Control 15
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
14.7.4
Off-Platform Peripheral Access Control Registers
(AIPSTZx_OPACR2)
Each of the off-platform peripherals have an Off-platform Peripheral Access Control
Register (AIPSTZ_OPACR) which defines the access levels supported by the given
block.
Each AIPSTZ_OPACR has the following format shown in Table 14-6
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
OPAC16
OPAC17
OPAC18
OPAC19
OPAC20
OPAC21
OPAC22
OPAC23
W
Reset 0
1
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
0
1
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
0
1
0
0
0
1
0
0
Chapter 14 AHB to IP Bridge (AIPSTZ)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
457

<!-- page 458 -->

AIPSTZx_OPACR2 field descriptions
Field
Description
31–28
OPAC16
Off-platform Peripheral Access Control 16
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
27–24
OPAC17
Off-platform Peripheral Access Control 17
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
23–20
OPAC18
Off-platform Peripheral Access Control 18
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
19–16
OPAC19
Off-platform Peripheral Access Control 19
Table continues on the next page...
AIPSTZ Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
458
NXP Semiconductors

<!-- page 459 -->

AIPSTZx_OPACR2 field descriptions (continued)
Field
Description
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
15–12
OPAC20
Off-platform Peripheral Access Control 20
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
11–8
OPAC21
Off-platform Peripheral Access Control 21
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
7–4
OPAC22
Off-platform Peripheral Access Control 22
xxx0
TP — Accesses from an untrusted master are allowed.
Table continues on the next page...
Chapter 14 AHB to IP Bridge (AIPSTZ)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
459

<!-- page 460 -->

AIPSTZx_OPACR2 field descriptions (continued)
Field
Description
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
OPAC23
Off-platform Peripheral Access Control 23
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
14.7.5
Off-Platform Peripheral Access Control Registers
(AIPSTZx_OPACR3)
Each of the off-platform peripherals have an Off-platform Peripheral Access Control
Register (AIPSTZ_OPACR) which defines the access levels supported by the given
block.
Each AIPSTZ_OPACR has the following format shown in Table 14-6
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
OPAC24
OPAC25
OPAC26
OPAC27
OPAC28
OPAC29
OPAC30
OPAC31
W
Reset 0
1
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
0
1
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
0
1
0
0
0
1
0
0
AIPSTZ Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
460
NXP Semiconductors

<!-- page 461 -->

AIPSTZx_OPACR3 field descriptions
Field
Description
31–28
OPAC24
Off-platform Peripheral Access Control 24
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
27–24
OPAC25
Off-platform Peripheral Access Control 25
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
23–20
OPAC26
Off-platform Peripheral Access Control 26
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
19–16
OPAC27
Off-platform Peripheral Access Control 27
Table continues on the next page...
Chapter 14 AHB to IP Bridge (AIPSTZ)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
461

<!-- page 462 -->

AIPSTZx_OPACR3 field descriptions (continued)
Field
Description
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
15–12
OPAC28
Off-platform Peripheral Access Control 28
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
11–8
OPAC29
Off-platform Peripheral Access Control 29
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
7–4
OPAC30
Off-platform Peripheral Access Control 30
xxx0
TP — Accesses from an untrusted master are allowed.
Table continues on the next page...
AIPSTZ Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
462
NXP Semiconductors

<!-- page 463 -->

AIPSTZx_OPACR3 field descriptions (continued)
Field
Description
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
OPAC31
Off-platform Peripheral Access Control 31
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
14.7.6
Off-Platform Peripheral Access Control Registers
(AIPSTZx_OPACR4)
Each of the off-platform peripherals have an Off-platform Peripheral Access Control
Register (AIPSTZ_OPACR) which defines the access levels supported by the given
block.
Each AIPSTZ_OPACR has the following format shown in Table 14-6
Address: Base address + 50h offset
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
OPAC32
OPAC33
Reserved
W
Reset 0
1
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
0
1
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
0
1
0
0
0
1
0
0
Chapter 14 AHB to IP Bridge (AIPSTZ)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
463

<!-- page 464 -->

AIPSTZx_OPACR4 field descriptions
Field
Description
31–28
OPAC32
Off-platform Peripheral Access Control 32
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
27–24
OPAC33
Off-platform Peripheral Access Control 33
xxx0
TP — Accesses from an untrusted master are allowed.
xxx1
TP — Accesses from an untrusted master are not allowed. If an access is attempted by an
untrusted master, the access is terminated with an error response and no peripheral access is
initiated on the IPS bus.
xx0x
WP — This peripheral allows write accesses.
xx1x
WP — This peripheral is write protected. If a write access is attempted, the access is terminated
with an error response and no peripheral access is initiated on the IPS bus.
x0xx
SP — This peripheral does not require supervisor privilege level for accesses.
x1xx
SP — This peripheral requires supervisor privilege level for accesses. The master privilege level
must indicate supervisor via the hprot[1] access attribute, and the MPROTx[MPL] control bit for the
master must be set. If not, the access is terminated with an error response and no peripheral
access is initiated on the IPS bus.
0xxx
BW — Write accesses to this peripheral are not bufferable by the AIPSTZ.
1xxx
BW — Write accesses to this peripheral are allowed to be buffered by the AIPSTZ.
-
This field is reserved.
Reserved
AIPSTZ Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
464
NXP Semiconductors

