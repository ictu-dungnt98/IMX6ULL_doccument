# Chapter 37: On-Chip OTP Controller (OCOTP_CTRL)

> Nguồn: `IMX6ULLRM.pdf` — trang 2381–2434

<!-- page 2381 -->

Chapter 37
On-Chip OTP Controller (OCOTP_CTRL)
37.1
Overview
This section contains information describing the requirements for the on-chip eFuse OTP
controller along with details about the block functionality and implementation.
In this document, the words "eFuse" and "OTP" are interchangeable. OCOTP refers to
the hardware block itself.
37.1.1
Features
The OCOTP provides the following features:
• Loading and housing of fuse content into shadow registers.
• Generation of HWV_FUSE (hardware visible fuse bus) and the HWV_REG bus
which is made up of volatile PIO register based "fuses". The HWV_REG bits come
from the SCS (Software Controllable Signals) register.
• Generation of STICKY_REG which is consist of sticky register bits.
• Provide program-protect and read-protect eFuse.
• Provide override and read protection of shadow register.
• CRC32 test for read-lock fuse content.
37.2
Clocks
The table found here describes the clock sources for OCOTP.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2381

<!-- page 2382 -->

Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 37-1. OCOTP Clocks
Clock name
Clock Root
Description
ipg_clk
ipg_clk_root
Peripheral clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
37.3
Top-Level Symbol and Functional Overview
The figure found here shows the OCOTP system level diagram.
Ocotp Controller/State Machine
Shadow Regs
Ocotp control register
5
APB Interface
HWV_REG Bus
STICKY_REG Bus
HW Capability Bus
ip2apb
Other
Blocks
To SJC
Blocks
Other
Blocks
IP bus
512x8 OTP
FUSE
OCOTP_CTRL
Figure 37-1. OCOTP System Level Diagram
37.3.1
Operation
The IP bus interface of the OCOTP provides two functions.
• Configure control registers for programming and reading fuse .
• Override and read shadow registers.
Top-Level Symbol and Functional Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2382
NXP Semiconductors

<!-- page 2383 -->

37.3.1.1
Shadow Register Reload
All fuse words in are shadowed. Therefore, fuse information is available through memory
mapped shadow registers. If fuses are subsequently programmed, the shadow registers
should be reloaded to keep them coherent with the fuse bank arrays.
The "reload shadows" feature allows the user to force a reload of the shadow registers
(including HW_OCOTP_LOCK) without having to reset the device. To force a reload,
complete the following steps:
1. Check that HW_OCOTP_CTRL[BUSY] and HW_OCOTP_CTRL[ERROR] are
clear. Overlapped accesses are not supported by the controller. Any pending write ,
read or reload must be completed before a new access can be requested.
2. Set the HW_OCOTP_CTRL[RELOAD_SHADOWS] bit. OCOTP will read all the
fuse one by one and put it into corresponding shadow register.
3. Wait for HW_OCOTP_CTRL[BUSY] and
HW_OCOTP_CTRL[RELOAD_SHADOWS] to be cleared by the controller.
The controller will automatically clear the HW_OCOTP_CTRL[RELOAD_SHADOWS]
bit after the successful completion of the operation.
37.3.1.2
Fuse and Shadow Register Read
All shadow registers are always readable through the APB bus except some secret keys
regions. When their corresponding fuse lock bits are set, the shadow registers also
become read locked. After read locking, reading from these registers will return
0xBADABADA.
In addition HW_OCOTP_CTRL[ERROR] will be set. It must be cleared by software
before any new write , read or reload access can be issued. Subsequent reads to unlocked
shadow locations will still work successfully however.
To read fuse words directly from correctly complete the following steps:
1. Check that HW_OCOTP_CTRL[BUSY] and HW_OCOTP_CTRL[ERROR] are
clear. Overlapped accesses are not supported by the controller. Any pending write,
read or reload must be completed before a read access can be requested.
2. Write the requested to HW_OCOTP_CTRL[ADDR].
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2383

<!-- page 2384 -->

37.3.1.3
Fuse and Shadow Register Writes
Shadow register bits can be overridden by software until the corresponding fuse lock bit
for the region is set. When the lock shadow bit is set, the shadow registers for that lock
region become write locked. The LOCK shadow register also has no shadow or fuse lock
bits but it is always read only.
In order to avoid "rogue" code performing erroneous writes to OTP, a special unlocking
sequence is required for writes to the fuse banks. To program fuse bank correctly
complete the following steps:
1. Program HW_OCOTP_TIMING[STROBE_PROG] and
HW_OCOTP_TIMING[RELAX]HW_OCOTP_TIMING2[RELAX_PEOG] fields
with timing values to match the current frequency of the ipg_clk. OTP writes will
work at maximum bus frequencies as long as the HW_OCOTP_TIMING2
parameters are set correctly.
2. Check that HW_OCOTP_CTRL[BUSY] and HW_OCOTP_CTRL[ERROR] are
clear. Overlapped accesses are not supported by the controller. Any pending write or
reload must be completed before a write access can be requested.
3. Write the requested to HW_OCOTP_CTRL[ADDR] and program the unlock code
into HW_OCOTP_CTRL[WR_UNLOCK]. This must be programmed for each write
access. The lock code is documented in the register description. Both the unlock code
and address can be written in the same operation.
4. Write the data to the HW_OCOTP_DATA register. This will automatically set
HW_OCOTP_CTRL[BUSY] and clear HW_OCOTP_CTRL[WR_UNLOCK]. To
protect programming same OTP bit twice, before program OCOTP will
automatically read fuse value in OTP and use read value to mask program data. The
controller will use masked program data to program a 32-bit word in the OTP per the
address in HW_OCOTP_CTRL[ADDR]. Bit fields with 1's will result in that OTP
bit being programmed. Bit fields with 0's will be ignored. At the same time that the
write is accepted, the controller makes an internal copy of
HW_OCOTP_CTRL[ADDR] which cannot be updated until the next write sequence
is initiated. This copy guarantees that erroneous writes to
HW_OCOTP_CTRL[ADDR] will not affect an active write operation. It should also
be noted that during the programming HW_OCOTP_DATA will shift right (with
zero fill). This shifting is required to program the OTP serially. During the write
operation, HW_OCOTP_DATA cannot be modified.
5. Once complete, the controller will clear BUSY. A write request to a protected or
locked region will result in no OTP access and no setting of
HW_OCOTP_CTRL[BUSY]. In addition HW_OCOTP_CTRL[ERROR] will be set.
It must be cleared by software before any new write access can be issued.
Top-Level Symbol and Functional Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2384
NXP Semiconductors

<!-- page 2385 -->

It should be noted that write latencies to OTP are numbers of 10 micro-seconds. Write
latencies is based on amount of bit filed which is 1. For example : program half fuse bits
in one word need 10 us x 16.
For further details of OTP read/write operations see [eFUSE].
HW_OCOTP_CTRL[ERROR] will be set under the following conditions:
• A write is performed to a shadow register during a shadow reload (essentially, while
HW_OCOTP_CTRL[RELOAD_SHADOWS] is set. In addition, the contents of the
shadow register shall not be updated.
• A write is performed to a shadow register which has been locked.
• A read is performed to from a shadow register which has been read locked.
• A program is performed to a fuse which has been .
• A read is performed to from a fuse which has been read locked.
37.3.1.4
Write Postamble
Due to internal electrical characteristics of the OTP during writes, all OTP operations
following a write must be separated by 2 us after the clearing of
HW_OCOTP_CTRL_BUSY following the write. This guarantees programming voltages
on-chip to reach a steady state when exiting a write sequence. This includes reads,
shadow reloads, or other writes.
A recommended software sequence to meet the postamble requirements is as follows:
• Issue the write and poll for BUSY (as per Fuse Shadow Memory Footprint).
• Once BUSY is clear, use HW_DIGCTL_MICROSECONDS to wait 2 us.
• Perform the next OTP operation.
37.3.2
Fuse Shadow Memory Footprint
The OTP memory footprint shows in the following figure. The registers are grouped by
lock region. Their names correspond to the PIO register and fusemap names.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2385

<!-- page 2386 -->

GP2
GP1
OTPMK_CRC
MAC
SJC
SJC
SRK
SRK
SRK
SRK
SRK
SRK
SRK
SRK
RESERVED
RESERVED
RESERVED
RESERVED
RESERVED
RESERVED
RESERVED
RESERVED
ANALOG
ANALOG
ANALOG
MEM
MEM
MEM
MEM
MEM
BOOT_CFG
BOOT_CFG
BOOT_CFG
TESTER
TESTER
TESTER
TESTER
LOCK
0x27
0x26
0x25
0x24
0x23
0x22
0x21
0x20
0x1F
0x1E
0x1D
0x1C
0x1B
0x1A
0x19
0x18
0x17
0x16
0x15
0x14
0x13
0x12
0x11
0x10
0x0F
0x0E
0x0D
0x0C
0x0B
0x0A
0x09
0x08
0x07
0x06
0x05
0x04
0x03
0x02
0x01
0x00
MAC
MAC
SRK_REVOKE
FIELD_RETURN
MISC_CONF
0x4F
0x4E
0x4D
0x4C
0x4B
0x4A
0x49
0x48
0x2F
0x2E
0x2D
0x2C
0x2A
0x29
0x28
0x2B
Shadow
Regs
SW_GP
GP4
GP4
GP4
GP4
GP3
GP3
GP3
GP3
SW_GP
SW_GP
SW_GP
SW_GP
Figure 37-2. OTP Memory Footprint
Top-Level Symbol and Functional Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2386
NXP Semiconductors

<!-- page 2387 -->

37.3.3
OTP Read/Write Timing Parameters
There are three timing fields contained in the HW_OCOTP_TIMING and
HW_OCOTP_TIMING2 register that specify counter limit values, which are used to
specify the signal timing.
Both two timing parameters are specified in ipg_clk cycles. Since the ipg_clk frequency
can be set to a range of values, these parameters must be adjusted with the clock to yield
the appropriate delay.
37.3.4
Hardware Visible Fuses
The hwv_fuse bus emanates from the OCOTP block and goes to various other blocks
inside the chip. This bus is made up of all the shadow register bits for all the 16 fuse
banks.
Only a subset of these fuse bits are currently used by the hardware. The fuse bits are
initially copied from the banks after reset is deasserted. When all fuse bits are loaded into
their shadow registers, the OCOTP asserts the fuse_latched output signal.
The hwv_reg bus also comes from the OCOTP. Its source is the HW_OCOTP_SCS
register. This register has 1 defined bit, the HAB_JDE bit, that is connected to the SJC
block. The SCS bits are intended to be used as volatile fuse bits under software control.
Additional bits will be defined as needed in future implementations.
The system-wide reset sequence must be coordinated by the system reset controller, so
that the hwv_fuse and hwv_reg buses are stable and reflect the values of the fuses before
they are used by the rest of the system.
37.3.5
Behavior During Reset
The OCOTP is always active. The shadow registers automatically load the appropriate
OTP contents after reset is deasserted. During this load-time
HW_OCOTP_CTRL_BUSY is set. The load time is similar to that of a "reload shadow"
operation.
37.3.6
Secure JTAG control
The JTAG control fuses are used to allow or disallow JTAG access to secured resources.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2387

<!-- page 2388 -->

Three JTAG security levels are envisioned, as shown in the table below.
Table 37-2. JTAG Security Level Control Bits
Security Mode
JTAG_SMODE
Description
No Debug
2'b11
The highest security level.
Secure JTAG
2'b01
Limit the JTAG access by using key based authentication
mechanism.
JTAG Enable
2'b00
Low Security, all JTAG features are enabled.
37.4
Fuse Map
See the Fusemap chapter of this reference manual for more information.
37.5
OCOTP Memory Map/Register Definition
NOTE
When write/read unimplemented register address in ocotp_ctrl,
ocotp_ctrl will not send error and read data will be 0.
OCOTP Hardware Register Format Summary
OCOTP memory map
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
21B_C000
OTP Controller Control Register (OCOTP_CTRL)
32
R/W
0000_0000h
37.5.1/2392
21B_C004
OTP Controller Control Register (OCOTP_CTRL_SET)
32
R/W
0000_0000h
37.5.1/2392
21B_C008
OTP Controller Control Register (OCOTP_CTRL_CLR)
32
R/W
0000_0000h
37.5.1/2392
21B_C00C
OTP Controller Control Register (OCOTP_CTRL_TOG)
32
R/W
0000_0000h
37.5.1/2392
21B_C010
OTP Controller Timing Register (OCOTP_TIMING)
32
R/W
02C6_4116h
37.5.2/2394
21B_C020
OTP Controller Write Data Register (OCOTP_DATA)
32
R/W
0000_0000h
37.5.3/2394
21B_C030
OTP Controller Read Control Register
(OCOTP_READ_CTRL)
32
R/W
0000_0000h
37.5.4/2395
21B_C040
OTP Controller Read Fuse Data Register
(OCOTP_READ_FUSE_DATA)
32
R/W
0000_0000h
37.5.5/2396
21B_C050
Sticky bit Register (OCOTP_SW_STICKY)
32
R/W
0000_0000h
37.5.6/2396
21B_C060
Software Controllable Signals Register (OCOTP_SCS)
32
R/W
0000_0000h
37.5.7/2397
21B_C064
Software Controllable Signals Register (OCOTP_SCS_SET)
32
R/W
0000_0000h
37.5.7/2397
Table continues on the next page...
Fuse Map
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2388
NXP Semiconductors

<!-- page 2389 -->

OCOTP memory map (continued)
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
21B_C068
Software Controllable Signals Register (OCOTP_SCS_CLR)
32
R/W
0000_0000h
37.5.7/2397
21B_C06C
Software Controllable Signals Register
(OCOTP_SCS_TOG)
32
R/W
0000_0000h
37.5.7/2397
21B_C070
OTP Controller CRC Test Address (OCOTP_CRC_ADDR)
32
R/W
0000_0000h
37.5.8/2398
21B_C080
OTP Controller CRC Value Register
(OCOTP_CRC_VALUE)
32
R/W
0000_0000h
37.5.9/2399
21B_C090
OTP Controller Version Register (OCOTP_VERSION)
32
R/W
0300_0000h
37.5.10/
2400
21B_C100
OTP Controller Timing Register 2 (OCOTP_TIMING2)
32
R/W
01C1_0042h
37.5.11/
2400
21B_C400
Value of OTP Bank0 Word0 (Lock controls)
(OCOTP_LOCK)
32
R
0000_0000h
37.5.12/
2401
21B_C410
Value of OTP Bank0 Word1 (Configuration and
Manufacturing Info.) (OCOTP_CFG0)
32
R/W
0000_0000h
37.5.13/
2404
21B_C420
Value of OTP Bank0 Word2 (Configuration and
Manufacturing Info.) (OCOTP_CFG1)
32
R/W
0000_0000h
37.5.14/
2405
21B_C430
Value of OTP Bank0 Word3 (Configuration and
Manufacturing Info.) (OCOTP_CFG2)
32
R/W
0000_0000h
37.5.15/
2405
21B_C440
Value of OTP Bank0 Word4 (Configuration and
Manufacturing Info.) (OCOTP_CFG3)
32
R/W
0000_0000h
37.5.16/
2406
21B_C450
Value of OTP Bank0 Word5 (Configuration and
Manufacturing Info.) (OCOTP_CFG4)
32
R/W
0000_0000h
37.5.17/
2406
21B_C460
Value of OTP Bank0 Word6 (Configuration and
Manufacturing Info.) (OCOTP_CFG5)
32
R/W
0000_0000h
37.5.18/
2407
21B_C470
Value of OTP Bank0 Word7 (Configuration and
Manufacturing Info.) (OCOTP_CFG6)
32
R/W
0000_0000h
37.5.19/
2407
21B_C480
Value of OTP Bank1 Word0 (Memory Related Info.)
(OCOTP_MEM0)
32
R/W
0000_0000h
37.5.20/
2408
21B_C490
Value of OTP Bank1 Word1 (Memory Related Info.)
(OCOTP_MEM1)
32
R/W
0000_0000h
37.5.21/
2408
21B_C4A0
Value of OTP Bank1 Word2 (Memory Related Info.)
(OCOTP_MEM2)
32
R/W
0000_0000h
37.5.22/
2409
21B_C4B0
Value of OTP Bank1 Word3 (Memory Related Info.)
(OCOTP_MEM3)
32
R/W
0000_0000h
37.5.23/
2409
21B_C4C0
Value of OTP Bank1 Word4 (Memory Related Info.)
(OCOTP_MEM4)
32
R/W
0000_0000h
37.5.24/
2410
21B_C4D0
Value of OTP Bank1 Word5 (Memory Related Info.)
(OCOTP_ANA0)
32
R/W
0000_0000h
37.5.25/
2410
21B_C4E0
Value of OTP Bank1 Word6 (General Purpose Customer
Defined Info.) (OCOTP_ANA1)
32
R/W
0000_0000h
37.5.26/
2411
21B_C4F0
Value of OTP Bank1 Word7 (General Purpose Customer
Defined Info.) (OCOTP_ANA2)
32
R/W
0000_0000h
37.5.27/
2411
21B_C500
Value of OTP Bank2 Word0 (OTPMK Key)
(OCOTP_OTPMK0)
32
R/W
0000_0000h
37.5.28/
2412
Table continues on the next page...
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2389

<!-- page 2390 -->

OCOTP memory map (continued)
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
21B_C510
Value of OTP Bank2 Word1 (OTPMK Key)
(OCOTP_OTPMK1)
32
R/W
0000_0000h
37.5.29/
2412
21B_C520
Value of OTP Bank2 Word2 (OTPMK Key)
(OCOTP_OTPMK2)
32
R/W
0000_0000h
37.5.30/
2413
21B_C530
Value of OTP Bank2 Word3 (OTPMK Key)
(OCOTP_OTPMK3)
32
R/W
0000_0000h
37.5.31/
2413
21B_C540
Value of OTP Bank2 Word4 (OTPMK Key)
(OCOTP_OTPMK4)
32
R/W
0000_0000h
37.5.32/
2414
21B_C550
Value of OTP Bank2 Word5 (OTPMK Key)
(OCOTP_OTPMK5)
32
R/W
0000_0000h
37.5.33/
2414
21B_C560
Value of OTP Bank2 Word6 (OTPMK Key)
(OCOTP_OTPMK6)
32
R/W
0000_0000h
37.5.34/
2415
21B_C570
Value of OTP Bank2 Word7 (OTPMK Key)
(OCOTP_OTPMK7)
32
R/W
0000_0000h
37.5.35/
2415
21B_C580
Shadow Register for OTP Bank3 Word0 (SRK Hash)
(OCOTP_SRK0)
32
R/W
0000_0000h
37.5.36/
2416
21B_C590
Shadow Register for OTP Bank3 Word1 (SRK Hash)
(OCOTP_SRK1)
32
R/W
0000_0000h
37.5.37/
2416
21B_C5A0
Shadow Register for OTP Bank3 Word2 (SRK Hash)
(OCOTP_SRK2)
32
R/W
0000_0000h
37.5.38/
2417
21B_C5B0
Shadow Register for OTP Bank3 Word3 (SRK Hash)
(OCOTP_SRK3)
32
R/W
0000_0000h
37.5.39/
2417
21B_C5C0
Shadow Register for OTP Bank3 Word4 (SRK Hash)
(OCOTP_SRK4)
32
R/W
0000_0000h
37.5.40/
2418
21B_C5D0
Shadow Register for OTP Bank3 Word5 (SRK Hash)
(OCOTP_SRK5)
32
R/W
0000_0000h
37.5.41/
2418
21B_C5E0
Shadow Register for OTP Bank3 Word6 (SRK Hash)
(OCOTP_SRK6)
32
R/W
0000_0000h
37.5.42/
2419
21B_C5F0
Shadow Register for OTP Bank3 Word7 (SRK Hash)
(OCOTP_SRK7)
32
R/W
0000_0000h
37.5.43/
2419
21B_C600
Value of OTP Bank4 Word0 (Secure JTAG Response Field)
(OCOTP_SJC_RESP0)
32
R/W
0000_0000h
37.5.44/
2420
21B_C610
Value of OTP Bank4 Word1 (Secure JTAG Response Field)
(OCOTP_SJC_RESP1)
32
R/W
0000_0000h
37.5.45/
2420
21B_C620
Value of OTP Bank4 Word2 (MAC Address)
(OCOTP_MAC0)
32
R/W
0000_0000h
37.5.46/
2421
21B_C630
Value of OTP Bank4 Word3 (MAC Address)
(OCOTP_MAC1)
32
R/W
0000_0000h
37.5.47/
2421
21B_C640
Value of OTP Bank4 Word4 (MAC Address)
(OCOTP_RESERVED) (OCOTP_MAC)
32
R/W
0000_0000h
37.5.48/
2421
21B_C650
Value of OTP Bank4 Word5 (CRC Key) (OCOTP_CRC)
32
R/W
0000_0000h
37.5.49/
2422
21B_C660
Value of OTP Bank4 Word6 (General Purpose Customer
Defined Info) (OCOTP_GP1)
32
R/W
0000_0000h
37.5.50/
2422
Table continues on the next page...
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2390
NXP Semiconductors

<!-- page 2391 -->

OCOTP memory map (continued)
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
21B_C670
Value of OTP Bank4 Word7 (General Purpose Customer
Defined Info) (OCOTP_GP2)
32
R/W
0000_0000h
37.5.51/
2423
21B_C680
Value of OTP Bank5 Word0 (SW GP) (OCOTP_SW_GP0)
32
R/W
0000_0000h
37.5.52/
2423
21B_C690
Value of OTP Bank5 Word1 (SW GP) (OCOTP_SW_GP1)
32
R/W
0000_0000h
37.5.53/
2424
21B_C6A0
Value of OTP Bank5 Word2 (SW GP) (OCOTP_SW_GP2)
32
R/W
0000_0000h
37.5.54/
2424
21B_C6B0
Value of OTP Bank5 Word3 (SW GP) (OCOTP_SW_GP3)
32
R/W
0000_0000h
37.5.55/
2424
21B_C6C0
Value of OTP Bank5 Word4 (SW GP) (OCOTP_SW_GP4)
32
R/W
0000_0000h
37.5.56/
2425
21B_C6D0
Value of OTP Bank5 Word5 (Misc Conf)
(OCOTP_MISC_CONF)
32
R/W
0000_0000h
37.5.57/
2425
21B_C6E0
Value of OTP Bank5 Word6 (Field Return)
(OCOTP_FIELD_RETURN)
32
R/W
0000_0000h
37.5.58/
2426
21B_C6F0
Value of OTP Bank5 Word7 (SRK Revoke)
(OCOTP_SRK_REVOKE)
32
R/W
0000_0000h
37.5.59/
2426
21B_C800
Value of OTP Bank6 Word0 (ROM Patch)
(OCOTP_ROM_PATCH0)
32
R/W
0000_0000h
37.5.60/
2427
21B_C810
Value of OTP Bank6 Word1 (ROM Patch)
(OCOTP_ROM_PATCH1)
32
R/W
0000_0000h
37.5.61/
2427
21B_C820
Value of OTP Bank6 Word2 (ROM Patch)
(OCOTP_ROM_PATCH2)
32
R/W
0000_0000h
37.5.62/
2427
21B_C830
Value of OTP Bank6 Word3 (ROM Patch)
(OCOTP_ROM_PATCH3)
32
R/W
0000_0000h
37.5.63/
2428
21B_C840
Value of OTP Bank6 Word4 (ROM Patch)
(OCOTP_ROM_PATCH4)
32
R/W
0000_0000h
37.5.64/
2428
21B_C850
Value of OTP Bank6 Word5 (ROM Patch)
(OCOTP_ROM_PATCH5)
32
R/W
0000_0000h
37.5.65/
2429
21B_C860
Value of OTP Bank6 Word6 (ROM Patch)
(OCOTP_ROM_PATCH6)
32
R/W
0000_0000h
37.5.66/
2429
21B_C870
Value of OTP Bank6 Word7 (ROM Patch)
(OCOTP_ROM_PATCH7)
32
R/W
0000_0000h
37.5.67/
2430
21B_C880
Value of OTP Bank7 Word0 (General Purpose Customer
Defined Info) (OCOTP_GP3_0)
32
R/W
0000_0000h
37.5.68/
2430
21B_C890
Value of OTP Bank7 Word1 (General Purpose Customer
Defined Info) (OCOTP_GP3_1)
32
R/W
0000_0000h
37.5.69/
2430
21B_C8A0
Value of OTP Bank7 Word2 (General Purpose Customer
Defined Info) (OCOTP_GP3_2)
32
R/W
0000_0000h
37.5.70/
2431
21B_C8B0
Value of OTP Bank7 Word3 (General Purpose Customer
Defined Info) (OCOTP_GP3_3)
32
R/W
0000_0000h
37.5.71/
2431
21B_C8C0
Value of OTP Bank8 Word4 (General Purpose Customer
Defined Info) (OCOTP_GP4_0)
32
R/W
0000_0000h
37.5.72/
2432
Table continues on the next page...
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2391

<!-- page 2392 -->

OCOTP memory map (continued)
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
21B_C8D0
Value of OTP Bank7 Word5 (General Purpose Customer
Defined Info) (OCOTP_GP4_1)
32
R/W
0000_0000h
37.5.73/
2432
21B_C8E0
Value of OTP Bank7 Word6 (General Purpose Customer
Defined Info) (OCOTP_GP4_2)
32
R/W
0000_0000h
37.5.74/
2433
21B_C8F0
Value of OTP Bank7 Word7 (General Purpose Customer
Defined Info) (OCOTP_GP4_3)
32
R/W
0000_0000h
37.5.75/
2433
37.5.1
OTP Controller Control Register (OCOTP_CTRLn)
The OCOTP Control and Status Register specifies the copy state, as well as the control
required for random access of the OTP memory
OCOTP_CTRL: 0x000
OCOTP_CTRL_SET: 0x004
OCOTP_CTRL_CLR: 0x008
OCOTP_CTRL_TOG: 0x00C
The OCOTP Control and Status Register provides the necessary software interface for
performing read and write operations to the On-Chip OTP (One-Time Programmable
ROM). The control fields such as WR_UNLOCK, ADDR and BUSY/ERROR may be
used in conjunction with the OCOTP_DATA register to perform write operations. Read
operations to the On-Chip OTP are involving ADDR, BUSY/ERROR bit field and
OCOTP_READ_CTRL register. Read value is saved in OCOTP_READ_FUSE_DATA
register.
Address: 21B_C000h base + 0h offset + (4d × i), where i=0d to 3d
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
WR_UNLOCK
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
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2392
NXP Semiconductors

<!-- page 2393 -->

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
RSVD1
CRC_FAIL
CRC_TEST
RELOAD_SHADOWS
ERROR
BUSY
RSVD0
ADDR
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
OCOTP_CTRLn field descriptions
Field
Description
31–16
WR_UNLOCK
Write 0x3E77 to enable OTP write accesses. NOTE: This register must be unlocked on a write-by-write
basis (a write is initiated when HW_OCOTP_DATA is written), so the UNLOCK bitfield must contain the
correct key value during all writes to HW_OCOTP_DATA, otherwise a write shall not be initiated. This field
is automatically cleared after a successful write completion (clearing of BUSY).
0x3E77
KEY — Key needed to unlock HW_OCOTP_DATA register.
15–13
RSVD1
Reserved
12
CRC_FAIL
Set by controller when calculated CRC value is not equal to appointed CRC fuse word
11
CRC_TEST
Set to calculate CRC according to start address and end address in CRC_ADDR register. And compare
with CRC fuse word according CRC address in CRC_ADDR register to generate CRC_FAIL flag
10
RELOAD_
SHADOWS
Set to force re-loading the shadow registers (HW/SW capability and LOCK). This operation will
automatically set BUSY. Once the shadow registers have been re-loaded, BUSY and
RELOAD_SHADOWS are automatically cleared by the controller.
9
ERROR
Set by the controller when an access to a locked region(OTP or shadow register) is requested. Must be
cleared before any further access can be performed. This bit can only be set by the controller. This bit is
also set if the Pin interface is active and software requests an access to the OTP. In this instance, the
ERROR bit cannot be cleared until the Pin interface access has completed. Reset this bit by writing a one
to the SCT clear address space and not by a general write.
8
BUSY
OTP controller status bit. When active, no new write access or read access to OTP(including
RELOAD_SHADOWS) can be performed. Cleared by controller when access complete. After reset (or
after setting RELOAD_SHADOWS), this bit is set by the controller until the HW/SW and LOCK registers
are successfully copied, after which time it is automatically cleared by the controller.
7
RSVD0
Reserved
ADDR
OTP write and read access address register. Specifies one of 64 word address locations (0x00 - 0x3f). If a
valid access is accepted by the controller, the controller makes an internal copy of this value. This internal
copy will not update until the access is complete.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2393

<!-- page 2394 -->

37.5.2
OTP Controller Timing Register (OCOTP_TIMING)
The OCOTP Data Register is used for OTP Programming
This register specifies timing parameters for programming and reading the OCOTP fuse
array.
Address: 21B_C000h base + 10h offset = 21B_C010h
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
RSRVD0
WAIT
STROBE_READ
RELAX
STROBE_PROG
W
Reset 0
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
1
1
0
0
1
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
0
1
1
0
OCOTP_TIMING field descriptions
Field
Description
31–28
RSRVD0
These bits always read back zero.
27–22
WAIT
This count value specifies time interval between auto read and write access in one time program. It is
given in number of ipg_clk periods.
21–16
STROBE_READ
This count value specifies the strobe period in one time read OTP. Trd = ((STROBE_READ+1)- 2 *
(RELAX_READ + 1)) / ipg_clk_freq. It is given in number of IPG_CLK periods.
15–12
RELAX
This count value specifies the time to add to all default timing parameters other than the Tpgm and Trd. It
is given in number of ipg_clk periods.
STROBE_PROG This count value specifies the strobe period in one time write OTP. Tpgm = ((STROBE_PROG+1)- 2 *
(RELAX_PROG + 1)) / ipg_clk_freq. It is given in number of ipg_clk periods.
37.5.3
OTP Controller Write Data Register (OCOTP_DATA)
The OCOTP Data Register is used for OTP Programming
This register is used in conjunction with OCOTP_CTRL to perform one-time writes to
the OTP. Please see the "Software Write Sequence" section for operating details.
Address: 21B_C000h base + 20h offset = 21B_C020h
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
OCOTP_DATA field descriptions
Field
Description
DATA
Used to initiate a write to OTP. Please see the "Software Write Sequence" section for operating details.
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2394
NXP Semiconductors

<!-- page 2395 -->

37.5.4
OTP Controller Read Control Register
(OCOTP_READ_CTRL)
The Register is used for OTP Read Control.
This register is used in conjunction with OCOTP_CTRL to perform one time read to the
OTP. Please see the "Software read Sequence" section for operating details.
Address: 21B_C000h base + 30h offset = 21B_C030h
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
READ_FUSE
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
OCOTP_READ_CTRL field descriptions
Field
Description
31–1
RSVD0
Reserved
0
READ_FUSE
Used to initiate a read to OTP. Please see the "Software read Sequence" section for operating details.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2395

<!-- page 2396 -->

37.5.5
OTP Controller Read Fuse Data Register
(OCOTP_READ_FUSE_DATA)
The register is used for OTP read fuse data.
The data read from OTP
Address: 21B_C000h base + 40h offset = 21B_C040h
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
OCOTP_READ_FUSE_DATA field descriptions
Field
Description
DATA
The data read from OTP
37.5.6
Sticky bit Register (OCOTP_SW_STICKY)
Some SW sticky bits .
Some sticky bits are used by SW to lock some fuse area, shadow registers and other
features.
Address: 21B_C000h base + 50h offset = 21B_C050h
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
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2396
NXP Semiconductors

<!-- page 2397 -->

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
-
FIELD_RETURN_LOCK
SRK_REVOKE_LOCK
-
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
OCOTP_SW_STICKY field descriptions
Field
Description
31–5
RSVD0
Reserved
4–3
-
Reserved
2
FIELD_
RETURN_LOCK
Shadow register write and OTP write lock for FIELD_RETURN region. When set, the writing of this
region's shadow register and OTP fuse word are blocked. Once this bit is set, it is always high unless a
POR is issued.
1
SRK_REVOKE_
LOCK
Shadow register write and OTP write lock for SRK_REVOKE region. When set, the writing of this region's
shadow register and OTP fuse word are blocked. Once this bit is set, it is always high unless a POR is
issued.
0
-
Reserved
37.5.7
Software Controllable Signals Register (OCOTP_SCSn)
OCOTP_SCS: 0x060
OCOTP_SCS_SET: 0x064
OCOTP_SCS_CLR: 0x068
OCOTP_SCS_TOG: 0x06C
This register holds volatile configuration values that can be set and locked by trusted
software. All values are returned to their default values after POR.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2397

<!-- page 2398 -->

Address: 21B_C000h base + 60h offset + (4d × i), where i=0d to 3d
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
LOCK
SPARE
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
SPARE
HAB_JDE
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
OCOTP_SCSn field descriptions
Field
Description
31
LOCK
When set, all of the bits in this register are locked and can not be changed through SW programming. This
bit is only reset after a POR is issued.
30–1
SPARE
Unallocated read/write bits for implementation specific software use.
0
HAB_JDE
HAB JTAG Debug Enable. This bit is used by the HAB to enable JTAG debugging, assuming that a
properly signed command to do so is found and validated by the HAB.
The HAB must lock the register before passing control to the OS whether or not JTAG debugging has
been enabled.
Once JTAG is enabled by this bit, it can not be disabled unless the system is reset by POR. 0: JTAG
debugging is not enabled by the HAB (it may still be enabled by other mechanisms).
1: JTAG debugging is enabled by the HAB (though this signal may be gated off).
37.5.8
OTP Controller CRC Test Address (OCOTP_CRC_ADDR)
The address for CRC calculation
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2398
NXP Semiconductors

<!-- page 2399 -->

Address: 21B_C000h base + 70h offset = 21B_C070h
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
RSVD0
OTPMK_CRC
CRC_ADDR
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
DATA_END_ADDR
DATA_START_ADDR
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
OCOTP_CRC_ADDR field descriptions
Field
Description
31–20
RSVD0
Reserved
19
OTPMK_CRC
Enable bit for CRC32 calculation address
When OTPMK_CRC_ADDR_OTPMK_CRC bit sets to 1, calculation address sets to OTPMK_CRC
(recommend).
18–16
CRC_ADDR
Address of 32-bit CRC result for comparing
15–8
DATA_END_
ADDR
Start address of fuse location for CRC calculation
DATA_START_
ADDR
End address of fuse location for CRC calculation
37.5.9
OTP Controller CRC Value Register
(OCOTP_CRC_VALUE)
The CRC32 value is based on CRC_ADDR.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2399

<!-- page 2400 -->

Address: 21B_C000h base + 80h offset = 21B_C080h
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
OCOTP_CRC_VALUE field descriptions
Field
Description
DATA
The crc32 value based on CRC_ADDR
37.5.10
OTP Controller Version Register (OCOTP_VERSION)
This register always returns a known read value for debug purposes it indicates the
version of the block.
This register indicates the RTL version in use.
Address: 21B_C000h base + 90h offset = 21B_C090h
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
0
0
0
0
0
0
0
0
0
0
0
0
OCOTP_VERSION field descriptions
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
37.5.11
OTP Controller Timing Register 2 (OCOTP_TIMING2)
Address: 21B_C000h base + 100h offset = 21B_C100h
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
RELAX1
RELAX_READ
Reserved
RELAX_PROG
W
Reset 0
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
1
0
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2400
NXP Semiconductors

<!-- page 2401 -->

OCOTP_TIMING2 field descriptions
Field
Description
31–29
Reserved
This field is reserved.
28–22
RELAX1
Not used, preserved
21–16
RELAX_READ
This count value specifies the time to add to read OTP for complement address enable cycle time.
15–12
Reserved
This field is reserved.
RELAX_PROG
This count value specifies the time to add to write OTP for complement address enable time.
37.5.12
Value of OTP Bank0 Word0 (Lock controls)
(OCOTP_LOCK)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 0, word 0 (ADDR = 0x00).
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2401

<!-- page 2402 -->

Address: 21B_C000h base + 400h offset = 21B_C400h
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
GP3_RLOCK
GP4_RLOCK
Reserved
PIN
Reserved
GP4
MISC_CONF
ROM_PATCH
OTPMK_CRC
ANALOG
OTPMK
SW_GP
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
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2402
NXP Semiconductors

<!-- page 2403 -->

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
GP3
SRK
GP2
GP1
MAC_ADDR
RSVD0
SJC_RESP
MEM_TRIM
BOOT_CFG
TESTER
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
OCOTP_LOCK field descriptions
Field
Description
31
GP3_RLOCK
Status of shadow register and OTP read lock for GP3 region. When set, the reading of this region's
shadow register and OTP fuse word are blocked.
30
GP4_RLOCK
Status of shadow register and OTP read lock for GP4 region. When set, the reading of this region's
shadow register and OTP fuse word are blocked.
29–26
Reserved
This field is reserved.
25
PIN
Status of Pin access lock bit. When set, pin access is disabled.
24
Reserved
This field is reserved.
23
GP4
Status of shadow register and OTP write lock for GP4 region. When set, the writing of this region's shadow
register and OTP fuse word are blocked.
22
MISC_CONF
Status of shadow register and OTP write lock for misc_conf region. When set, the writing of this region's
shadow register and OTP fuse word are blocked.
21
ROM_PATCH
Status of shadow register and OTP write lock for rom_patch region. When set, the writing of this region's
shadow register and OTP fuse word are blocked.
20
OTPMK_CRC
Status of shadow register and OTP write lock for otpmk crc region. When set, the writing of this region's
shadow register and OTP fuse word are blocked.
Table continues on the next page...
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2403

<!-- page 2404 -->

OCOTP_LOCK field descriptions (continued)
Field
Description
19–18
ANALOG
Status of shadow register and OTP write lock for analog region. When bit 1 is set, the writing of this
region's shadow register is blocked. When bit 0 is set, the writing of this region's OTP fuse word is
blocked.
17
OTPMK
Status of shadow register and OTP write lock for OTPMK region. When set, the writing of this region's
shadow register and OTP fuse word are blocked.
16
SW_GP
Status of shadow register and OTP write lock for SW_GP region. When set, the writing of this region's
shadow register and OTP fuse word are blocked.
15
GP3
Status of shadow register and OTP write lock for GP3 region. When set, the writing of this region's shadow
register and OTP fuse word are blocked.
14
SRK
Status of shadow register and OTP write lock for srk region. When set, the writing of this region's shadow
register and OTP fuse word are blocked.
13–12
GP2
Status of shadow register and OTP write lock for gp2 region. When bit 1 is set, the writing of this region's
shadow register is blocked. When bit 0 is set, the writing of this region's OTP fuse word is blocked.
11–10
GP1
Status of shadow register and OTP write lock for gp2 region. When bit 1 is set, the writing of this region's
shadow register is blocked. When bit 0 is set, the writing of this region's OTP fuse word is blocked.
9–8
MAC_ADDR
Status of shadow register and OTP write lock for mac_addr region. When bit 1 is set, the writing of this
region's shadow register is blocked. When bit 0 is set, the writing of this region's OTP fuse word is
blocked.
7
RSVD0
Reserved
6
SJC_RESP
Status of shadow register read and write, OTP read and write lock for sjc_resp region. When set, the
writing of this region's shadow register and OTP fuse word are blocked. The read of this region's shadow
register and OTP fuse word are also blocked.
5–4
MEM_TRIM
Status of shadow register and OTP write lock for mem_trim region. When bit 1 is set, the writing of this
region's shadow register is blocked. When bit 0 is set, the writing of this region's OTP fuse word is
blocked.
3–2
BOOT_CFG
Status of shadow register and OTP write lock for boot_cfg region. When bit 1 is set, the writing of this
region's shadow register is blocked. When bit 0 is set, the writing of this region's OTP fuse word is
blocked.
TESTER
Status of shadow register and OTP write lock for tester region. When bit 1 is set, the writing of this region's
shadow register is blocked. When bit 0 is set, the writing of this region's OTP fuse word is blocked.
37.5.13
Value of OTP Bank0 Word1 (Configuration and
Manufacturing Info.) (OCOTP_CFG0)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 0, word 1 (ADDR = 0x01).
Address: 21B_C000h base + 410h offset = 21B_C410h
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
BITS
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
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2404
NXP Semiconductors

<!-- page 2405 -->

OCOTP_CFG0 field descriptions
Field
Description
BITS
This register contains 32 bits of the Unique ID and SJC_CHALLENGE field. Reflects value of OTP Bank 0,
word 1 (ADDR = 0x01). These bits become read-only after the HW_OCOTP_LOCK_TESTER[1] bit is set.
37.5.14
Value of OTP Bank0 Word2 (Configuration and
Manufacturing Info.) (OCOTP_CFG1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 0, word 2 (ADDR = 0x02).
Address: 21B_C000h base + 420h offset = 21B_C420h
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
BITS
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
OCOTP_CFG1 field descriptions
Field
Description
BITS
This register contains 32 bits of the Unique ID and SJC_CHALLENGE field. Reflects value of OTP Bank 0,
word 2 (ADDR = 0x02). These bits become read-only after the HW_OCOTP_LOCK_TESTER[1] bit is set.
37.5.15
Value of OTP Bank0 Word3 (Configuration and
Manufacturing Info.) (OCOTP_CFG2)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 0, word 3 (ADDR = 0x03).
Address: 21B_C000h base + 430h offset = 21B_C430h
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
BITS
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
OCOTP_CFG2 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 0, word 3 (ADDR = 0x03). These bits become read-only after the
HW_OCOTP_LOCK_TESTER[1] bit is set.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2405

<!-- page 2406 -->

37.5.16
Value of OTP Bank0 Word4 (Configuration and
Manufacturing Info.) (OCOTP_CFG3)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Non-shadowed memory mapped access to OTP Bank 0, word 4 (ADDR = 0x04).
Address: 21B_C000h base + 440h offset = 21B_C440h
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
BITS
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
OCOTP_CFG3 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 0, word 4 (ADDR = 0x04). These bits become read-only after the
HW_OCOTP_LOCK_TESTER[1] bit is set.
37.5.17
Value of OTP Bank0 Word5 (Configuration and
Manufacturing Info.) (OCOTP_CFG4)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 0, word 5 (ADDR = 0x05).
Address: 21B_C000h base + 450h offset = 21B_C450h
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
BITS
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
OCOTP_CFG4 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 0, word 5 (ADDR = 0x05). These bits become read-only after the
HW_OCOTP_LOCK_BOOT_CFG[1] bit is set.
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2406
NXP Semiconductors

<!-- page 2407 -->

37.5.18
Value of OTP Bank0 Word6 (Configuration and
Manufacturing Info.) (OCOTP_CFG5)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 0, word 6 (ADDR = 0x06).
Address: 21B_C000h base + 460h offset = 21B_C460h
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
BITS
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
OCOTP_CFG5 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 0, word 6 (ADDR = 0x06). These bits become read-only after the
HW_OCOTP_LOCK_BOOT_CFG[1] bit is set.
37.5.19
Value of OTP Bank0 Word7 (Configuration and
Manufacturing Info.) (OCOTP_CFG6)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 0, word 7 (ADDR = 0x07).
Address: 21B_C000h base + 470h offset = 21B_C470h
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
BITS
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
OCOTP_CFG6 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 0, word 7 (ADDR = 0x07). These bits become read-only after the
HW_OCOTP_LOCK_BOOT_CFG[1] bit is set.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2407

<!-- page 2408 -->

37.5.20
Value of OTP Bank1 Word0 (Memory Related Info.)
(OCOTP_MEM0)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 1, word 0 (ADDR = 0x08).
Address: 21B_C000h base + 480h offset = 21B_C480h
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
BITS
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
OCOTP_MEM0 field descriptions
Field
Description
BITS
Reflects value of OTP bank 1, word 0 (ADDR = 0x08). These bits become read-only after the
HW_OCOTP_LOCK_MEM_TRIM[1] bit is set.
37.5.21
Value of OTP Bank1 Word1 (Memory Related Info.)
(OCOTP_MEM1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 1, word 1 (ADDR = 0x09).
Address: 21B_C000h base + 490h offset = 21B_C490h
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
BITS
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
OCOTP_MEM1 field descriptions
Field
Description
BITS
Reflects value of OTP bank 1, word 1 (ADDR = 0x09). These bits become read-only after the
HW_OCOTP_LOCK_MEM_TRIM[1] bit is set.
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2408
NXP Semiconductors

<!-- page 2409 -->

37.5.22
Value of OTP Bank1 Word2 (Memory Related Info.)
(OCOTP_MEM2)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 1, word 2 (ADDR = 0x0A).
Address: 21B_C000h base + 4A0h offset = 21B_C4A0h
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
BITS
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
OCOTP_MEM2 field descriptions
Field
Description
BITS
Reflects value of OTP bank 1, word 2 (ADDR = 0x0A). These bits become read-only after the
HW_OCOTP_LOCK_MEM_TRIM[1] bit is set.
37.5.23
Value of OTP Bank1 Word3 (Memory Related Info.)
(OCOTP_MEM3)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 1, word 3 (ADDR = 0x0B).
Address: 21B_C000h base + 4B0h offset = 21B_C4B0h
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
BITS
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
OCOTP_MEM3 field descriptions
Field
Description
BITS
Reflects value of OTP bank 1, word 3 (ADDR = 0x0B). These bits become read-only after the
HW_OCOTP_LOCK_MEM_TRIM[1] bit is set.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2409

<!-- page 2410 -->

37.5.24
Value of OTP Bank1 Word4 (Memory Related Info.)
(OCOTP_MEM4)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 1, word 4 (ADDR = 0x0C).
Address: 21B_C000h base + 4C0h offset = 21B_C4C0h
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
BITS
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
OCOTP_MEM4 field descriptions
Field
Description
BITS
Reflects value of OTP bank 1, word 4 (ADDR = 0x0C). These bits become read-only after the
HW_OCOTP_LOCK_MEM_TRIM[1] bit is set.
37.5.25
Value of OTP Bank1 Word5 (Memory Related Info.)
(OCOTP_ANA0)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 1, word 5 (ADDR = 0x0D).
Address: 21B_C000h base + 4D0h offset = 21B_C4D0h
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
BITS
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
OCOTP_ANA0 field descriptions
Field
Description
BITS
Reflects value of OTP bank 1, word 5 (ADDR = 0x0D). These bits become read-only after the
HW_OCOTP_LOCK_ANALOG[1] bit is set.
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2410
NXP Semiconductors

<!-- page 2411 -->

37.5.26
Value of OTP Bank1 Word6 (General Purpose Customer
Defined Info.) (OCOTP_ANA1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 1, word 6 (ADDR = 0x0E).
Address: 21B_C000h base + 4E0h offset = 21B_C4E0h
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
BITS
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
OCOTP_ANA1 field descriptions
Field
Description
BITS
Reflects value of OTP bank 1, word 6 (ADDR = 0x0E). These bits become read-only after the
HW_OCOTP_LOCK_ANALOG[1] bit is set.
37.5.27
Value of OTP Bank1 Word7 (General Purpose Customer
Defined Info.) (OCOTP_ANA2)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 1, word 7 (ADDR = 0x0F).
Address: 21B_C000h base + 4F0h offset = 21B_C4F0h
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
BITS
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
OCOTP_ANA2 field descriptions
Field
Description
BITS
Reflects value of OTP bank 1, word 7 (ADDR = 0x0F). These bits become read-only after the
HW_OCOTP_LOCK_ANALOG[1] bit is set.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2411

<!-- page 2412 -->

37.5.28
Value of OTP Bank2 Word0 (OTPMK Key)
(OCOTP_OTPMK0)
Shadow register for the OTPMK Key word0 (Copy of OTP Bank 2, word 0 (ADDR =
0x10)). These bits can not be read and written after the HW_OCOTP_LOCK_OTPMK
bit is set. If read, returns 0xBADA_BADA and sets HW_OCOTP_CTRL[ERROR].
Address: 21B_C000h base + 500h offset = 21B_C500h
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
BITS
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
OCOTP_OTPMK0 field descriptions
Field
Description
BITS
Shadow register for the OTPMK Key word0 (Copy of OTP Bank 2, word 0 (ADDR = 0x10)). These bits can
not be read and written after the HW_OCOTP_LOCK_OTPMK bit is set. If read, returns 0xBADA_BADA
and sets HW_OCOTP_CTRL[ERROR].
37.5.29
Value of OTP Bank2 Word1 (OTPMK Key)
(OCOTP_OTPMK1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 2, word 1 (ADDR = 0x11).
Address: 21B_C000h base + 510h offset = 21B_C510h
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
BITS
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
OCOTP_OTPMK1 field descriptions
Field
Description
BITS
Shadow register for the OTPMK Key word0 (Copy of OTP Bank 2, word 1 (ADDR = 0x11)). These bits can
not be read and written after the HW_OCOTP_LOCK_OTPMK bit is set. If read, returns 0xBADA_BADA
and sets HW_OCOTP_CTRL[ERROR].
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2412
NXP Semiconductors

<!-- page 2413 -->

37.5.30
Value of OTP Bank2 Word2 (OTPMK Key)
(OCOTP_OTPMK2)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 2, word 2 (ADDR = 0x12).
Address: 21B_C000h base + 520h offset = 21B_C520h
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
BITS
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
OCOTP_OTPMK2 field descriptions
Field
Description
BITS
Shadow register for the OTPMK Key word0 (Copy of OTP Bank 2, word 2 (ADDR = 0x12)). These bits can
not be read and written after the HW_OCOTP_LOCK_OTPMK bit is set. If read, returns 0xBADA_BADA
and sets HW_OCOTP_CTRL[ERROR].
37.5.31
Value of OTP Bank2 Word3 (OTPMK Key)
(OCOTP_OTPMK3)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 2, word 3 (ADDR = 0x13).
Address: 21B_C000h base + 530h offset = 21B_C530h
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
BITS
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
OCOTP_OTPMK3 field descriptions
Field
Description
BITS
Shadow register for the OTPMK Key word0 (Copy of OTP Bank 2, word 3 (ADDR = 0x13)). These bits can
not be read and written after the HW_OCOTP_LOCK_OTPMK bit is set. If read, returns 0xBADA_BADA
and sets HW_OCOTP_CTRL[ERROR].
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2413

<!-- page 2414 -->

37.5.32
Value of OTP Bank2 Word4 (OTPMK Key)
(OCOTP_OTPMK4)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 2, word 4 (ADDR = 0x14).
Address: 21B_C000h base + 540h offset = 21B_C540h
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
BITS
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
OCOTP_OTPMK4 field descriptions
Field
Description
BITS
Shadow register for the OTPMK Key word0 (Copy of OTP Bank 2, word 4 (ADDR = 0x14)). These bits can
not be read and written after the HW_OCOTP_LOCK_OTPMK bit is set. If read, returns 0xBADA_BADA
and sets HW_OCOTP_CTRL[ERROR].
37.5.33
Value of OTP Bank2 Word5 (OTPMK Key)
(OCOTP_OTPMK5)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 2, word 5 (ADDR = 0x15).
Address: 21B_C000h base + 550h offset = 21B_C550h
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
BITS
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
OCOTP_OTPMK5 field descriptions
Field
Description
BITS
Shadow register for the OTPMK Key word0 (Copy of OTP Bank 2, word 4 (ADDR = 0x14)). These bits can
not be read and written after the HW_OCOTP_LOCK_OTPMK bit is set. If read, returns 0xBADA_BADA
and sets HW_OCOTP_CTRL[ERROR].
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2414
NXP Semiconductors

<!-- page 2415 -->

37.5.34
Value of OTP Bank2 Word6 (OTPMK Key)
(OCOTP_OTPMK6)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 2, word 6 (ADDR = 0x16).
Address: 21B_C000h base + 560h offset = 21B_C560h
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
BITS
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
OCOTP_OTPMK6 field descriptions
Field
Description
BITS
Shadow register for the OTPMK Key word0 (Copy of OTP Bank 2, word 6 (ADDR = 0x16)). These bits can
not be read and written after the HW_OCOTP_LOCK_OTPMK bit is set. If read, returns 0xBADA_BADA
and sets HW_OCOTP_CTRL[ERROR].
37.5.35
Value of OTP Bank2 Word7 (OTPMK Key)
(OCOTP_OTPMK7)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP bank 2, word 7 (ADDR = 0x17).
Address: 21B_C000h base + 570h offset = 21B_C570h
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
BITS
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
OCOTP_OTPMK7 field descriptions
Field
Description
BITS
Shadow register for the OTPMK Key word0 (Copy of OTP Bank 2, word 7 (ADDR = 0x17)). These bits can
not be read and written after the HW_OCOTP_LOCK_OTPMK bit is set. If read, returns 0xBADA_BADA
and sets HW_OCOTP_CTRL[ERROR].
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2415

<!-- page 2416 -->

37.5.36
Shadow Register for OTP Bank3 Word0 (SRK Hash)
(OCOTP_SRK0)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS].
Shadowed memory mapped access to OTP Bank 3, word 0 (ADDR = 0x18).
Address: 21B_C000h base + 580h offset = 21B_C580h
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
BITS
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
OCOTP_SRK0 field descriptions
Field
Description
BITS
Shadow register for the hash of the Super Root Key word0 (Copy of OTP Bank 3, word 0 (ADDR = 0x18)).
These bits become read-only after the HW_OCOTP_LOCK_SRK bit is set.
37.5.37
Shadow Register for OTP Bank3 Word1 (SRK Hash)
(OCOTP_SRK1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS].
Shadowed memory mapped access to OTP Bank 3, word 1 (ADDR = 0x19).
Address: 21B_C000h base + 590h offset = 21B_C590h
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
BITS
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
OCOTP_SRK1 field descriptions
Field
Description
BITS
Shadow register for the hash of the Super Root Key word1 (Copy of OTP Bank 3, word 1 (ADDR = 0x19)).
These bits become read-only after the HW_OCOTP_LOCK_SRK bit is set.
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2416
NXP Semiconductors

<!-- page 2417 -->

37.5.38
Shadow Register for OTP Bank3 Word2 (SRK Hash)
(OCOTP_SRK2)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS].
Shadowed memory mapped access to OTP Bank 3, word 2 (ADDR = 0x1A).
Address: 21B_C000h base + 5A0h offset = 21B_C5A0h
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
BITS
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
OCOTP_SRK2 field descriptions
Field
Description
BITS
Shadow register for the hash of the Super Root Key word2 (Copy of OTP Bank 3, word 2 (ADDR = 0x1A)).
These bits become read-only after the HW_OCOTP_LOCK_SRK bit is set.
37.5.39
Shadow Register for OTP Bank3 Word3 (SRK Hash)
(OCOTP_SRK3)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS].
Shadowed memory mapped access to OTP Bank 3, word 3 (ADDR = 0x1B).
Address: 21B_C000h base + 5B0h offset = 21B_C5B0h
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
BITS
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
OCOTP_SRK3 field descriptions
Field
Description
BITS
Shadow register for the hash of the Super Root Key word3 (Copy of OTP Bank 3, word 3 (ADDR = 0x1B)).
These bits become read-only after the HW_OCOTP_LOCK_SRK bit is set.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2417

<!-- page 2418 -->

37.5.40
Shadow Register for OTP Bank3 Word4 (SRK Hash)
(OCOTP_SRK4)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS].
Shadowed memory mapped access to OTP Bank 3, word 4 (ADDR = 0x1C).
Address: 21B_C000h base + 5C0h offset = 21B_C5C0h
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
BITS
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
OCOTP_SRK4 field descriptions
Field
Description
BITS
Shadow register for the hash of the Super Root Key word4 (Copy of OTP Bank 3, word 4 (ADDR =
0x1C)). These bits become read-only after the HW_OCOTP_LOCK_SRK bit is set.
37.5.41
Shadow Register for OTP Bank3 Word5 (SRK Hash)
(OCOTP_SRK5)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS].
Shadowed memory mapped access to OTP Bank 3, word 5 (ADDR = 0x1D).
Address: 21B_C000h base + 5D0h offset = 21B_C5D0h
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
BITS
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
OCOTP_SRK5 field descriptions
Field
Description
BITS
Shadow register for the hash of the Super Root Key word5 (Copy of OTP Bank 3, word 5 (ADDR =
0x1D)). These bits become read-only after the HW_OCOTP_LOCK_SRK bit is set.
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2418
NXP Semiconductors

<!-- page 2419 -->

37.5.42
Shadow Register for OTP Bank3 Word6 (SRK Hash)
(OCOTP_SRK6)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS].
Shadowed memory mapped access to OTP Bank 3, word 6 (ADDR = 0x1E).
Address: 21B_C000h base + 5E0h offset = 21B_C5E0h
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
BITS
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
OCOTP_SRK6 field descriptions
Field
Description
BITS
Shadow register for the hash of the Super Root Key word6 (Copy of OTP Bank 3, word 6 (ADDR = 0x1E)).
These bits become read-only after the HW_OCOTP_LOCK_SRK bit is set.
37.5.43
Shadow Register for OTP Bank3 Word7 (SRK Hash)
(OCOTP_SRK7)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS].
Shadowed memory mapped access to OTP Bank 3, word 7 (ADDR = 0x1F).
Address: 21B_C000h base + 5F0h offset = 21B_C5F0h
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
BITS
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
OCOTP_SRK7 field descriptions
Field
Description
BITS
Shadow register for the hash of the Super Root Key word7 (Copy of OTP Bank 3, word 7 (ADDR = 0x1F)).
These bits become read-only after the HW_OCOTP_LOCK_SRK bit is set.
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2419

<!-- page 2420 -->

37.5.44
Value of OTP Bank4 Word0 (Secure JTAG Response
Field) (OCOTP_SJC_RESP0)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 4, word 0 (ADDR = 0x20).
Address: 21B_C000h base + 600h offset = 21B_C600h
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
BITS
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
OCOTP_SJC_RESP0 field descriptions
Field
Description
BITS
Shadow register for the SJC_RESP Key word0 (Copy of OTP Bank 4, word 0 (ADDR = 0x20)). These bits
can be not read and written after the HW_OCOTP_LOCK_SJC_RESP bit is set. If read, returns
0xBADA_BADA and sets HW_OCOTP_CTRL[ERROR].
37.5.45
Value of OTP Bank4 Word1 (Secure JTAG Response
Field) (OCOTP_SJC_RESP1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 4, word 1 (ADDR = 0x21).
Address: 21B_C000h base + 610h offset = 21B_C610h
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
BITS
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
OCOTP_SJC_RESP1 field descriptions
Field
Description
BITS
Shadow register for the SJC_RESP Key word1 (Copy of OTP Bank 4, word 1 (ADDR = 0x21)). These bits
can be not read and written after the HW_OCOTP_LOCK_SJC_RESP bit is set. If read, returns
0xBADA_BADA and sets HW_OCOTP_CTRL[ERROR].
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2420
NXP Semiconductors

<!-- page 2421 -->

37.5.46
Value of OTP Bank4 Word2 (MAC Address)
(OCOTP_MAC0)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 4, word 2 (ADDR = 0x22).
Address: 21B_C000h base + 620h offset = 21B_C620h
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
BITS
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
OCOTP_MAC0 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 4, word 2 (ADDR = 0x22).
37.5.47
Value of OTP Bank4 Word3 (MAC Address)
(OCOTP_MAC1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 4, word 3 (ADDR = 0x23).
Address: 21B_C000h base + 630h offset = 21B_C630h
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
BITS
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
OCOTP_MAC1 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 4, word 3 (ADDR = 0x23).
37.5.48
Value of OTP Bank4 Word4 (MAC Address)
(OCOTP_RESERVED) (OCOTP_MAC)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2421

<!-- page 2422 -->

Shadowed memory mapped access to OTP Bank 4, word 4 (ADDR = 0x24).
Address: 21B_C000h base + 640h offset = 21B_C640h
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
BITS
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
OCOTP_MAC field descriptions
Field
Description
BITS
Reflects value of OTP Bank 4, word 4 (ADDR = 0x24).
37.5.49
Value of OTP Bank4 Word5 (CRC Key) (OCOTP_CRC)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 4, word 5 (ADDR = 0x25).
Address: 21B_C000h base + 650h offset = 21B_C650h
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
BITS
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
OCOTP_CRC field descriptions
Field
Description
BITS
Reflects value of OTP Bank 4, word 5 (ADDR = 0x25).
37.5.50
Value of OTP Bank4 Word6 (General Purpose Customer
Defined Info) (OCOTP_GP1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 4, word 6 (ADDR = 0x26).
Address: 21B_C000h base + 660h offset = 21B_C660h
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
BITS
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
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2422
NXP Semiconductors

<!-- page 2423 -->

OCOTP_GP1 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 4, word 6 (ADDR = 0x26).
37.5.51
Value of OTP Bank4 Word7 (General Purpose Customer
Defined Info) (OCOTP_GP2)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 4, word 7 (ADDR = 0x27).
Address: 21B_C000h base + 670h offset = 21B_C670h
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
BITS
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
OCOTP_GP2 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 4, word 7 (ADDR = 0x27).
37.5.52
Value of OTP Bank5 Word0 (SW GP) (OCOTP_SW_GP0)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 5, word 0 (ADDR = 0x28).
Address: 21B_C000h base + 680h offset = 21B_C680h
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
BITS
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
OCOTP_SW_GP0 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 5, word 0 (ADDR = 0x28).
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2423

<!-- page 2424 -->

37.5.53
Value of OTP Bank5 Word1 (SW GP) (OCOTP_SW_GP1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 5, word 1 (ADDR = 0x29).
Address: 21B_C000h base + 690h offset = 21B_C690h
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
BITS
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
OCOTP_SW_GP1 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 5, word 1 (ADDR = 0x29).
37.5.54
Value of OTP Bank5 Word2 (SW GP) (OCOTP_SW_GP2)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 5, word 2 (ADDR = 0x2a).
Address: 21B_C000h base + 6A0h offset = 21B_C6A0h
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
BITS
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
OCOTP_SW_GP2 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 5, word 2 (ADDR = 0x2a).
37.5.55
Value of OTP Bank5 Word3 (SW GP) (OCOTP_SW_GP3)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 5, word 3 (ADDR = 0x2b).
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2424
NXP Semiconductors

<!-- page 2425 -->

Address: 21B_C000h base + 6B0h offset = 21B_C6B0h
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
BITS
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
OCOTP_SW_GP3 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 5, word 3 (ADDR = 0x2b).
37.5.56
Value of OTP Bank5 Word4 (SW GP) (OCOTP_SW_GP4)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 5, word 4 (ADDR = 0x2c).
Address: 21B_C000h base + 6C0h offset = 21B_C6C0h
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
BITS
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
OCOTP_SW_GP4 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 5, word 4 (ADDR = 0x2c).
37.5.57
Value of OTP Bank5 Word5 (Misc Conf)
(OCOTP_MISC_CONF)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 5, word 5 (ADDR = 0x2d).
Address: 21B_C000h base + 6D0h offset = 21B_C6D0h
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
BITS
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
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2425

<!-- page 2426 -->

OCOTP_MISC_CONF field descriptions
Field
Description
BITS
Reflects value of OTP Bank 5, word 5 (ADDR = 0x2d).
37.5.58
Value of OTP Bank5 Word6 (Field Return)
(OCOTP_FIELD_RETURN)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 5, word 6 (ADDR = 0x2e).
Address: 21B_C000h base + 6E0h offset = 21B_C6E0h
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
BITS
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
OCOTP_FIELD_RETURN field descriptions
Field
Description
BITS
Reflects value of OTP Bank 5, word 6 (ADDR = 0x2e).
37.5.59
Value of OTP Bank5 Word7 (SRK Revoke)
(OCOTP_SRK_REVOKE)
Copied from the OTP automatically after reset. Can be re-loaded by setting
OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 5, word 7 (ADDR = 0x2f).
Address: 21B_C000h base + 6F0h offset = 21B_C6F0h
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
BITS
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
OCOTP_SRK_REVOKE field descriptions
Field
Description
BITS
Reflects value of OTP Bank 5, word 7 (ADDR = 0x2f).
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2426
NXP Semiconductors

<!-- page 2427 -->

37.5.60
Value of OTP Bank6 Word0 (ROM Patch)
(OCOTP_ROM_PATCH0)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 6, word 0 (ADDR = 0x30).
Address: 21B_C000h base + 800h offset = 21B_C800h
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
BITS
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
OCOTP_ROM_PATCH0 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 6, word 0 (ADDR = 0x30).
37.5.61
Value of OTP Bank6 Word1 (ROM Patch)
(OCOTP_ROM_PATCH1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 6, word 1 (ADDR = 0x31).
Address: 21B_C000h base + 810h offset = 21B_C810h
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
BITS
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
OCOTP_ROM_PATCH1 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 6, word 1 (ADDR = 0x31).
37.5.62
Value of OTP Bank6 Word2 (ROM Patch)
(OCOTP_ROM_PATCH2)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2427

<!-- page 2428 -->

Shadowed memory mapped access to OTP Bank 6, word 2 (ADDR = 0x32).
Address: 21B_C000h base + 820h offset = 21B_C820h
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
BITS
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
OCOTP_ROM_PATCH2 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 6, word 2 (ADDR = 0x32).
37.5.63
Value of OTP Bank6 Word3 (ROM Patch)
(OCOTP_ROM_PATCH3)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 6, word 3 (ADDR = 0x33).
Address: 21B_C000h base + 830h offset = 21B_C830h
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
BITS
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
OCOTP_ROM_PATCH3 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 6, word 3 (ADDR = 0x33).
37.5.64
Value of OTP Bank6 Word4 (ROM Patch)
(OCOTP_ROM_PATCH4)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 6, word 4 (ADDR = 0x34).
Address: 21B_C000h base + 840h offset = 21B_C840h
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
BITS
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
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2428
NXP Semiconductors

<!-- page 2429 -->

OCOTP_ROM_PATCH4 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 6, word 4 (ADDR = 0x34).
37.5.65
Value of OTP Bank6 Word5 (ROM Patch)
(OCOTP_ROM_PATCH5)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 6, word 5 (ADDR = 0x35).
Address: 21B_C000h base + 850h offset = 21B_C850h
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
BITS
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
OCOTP_ROM_PATCH5 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 6, word 5 (ADDR = 0x35).
37.5.66
Value of OTP Bank6 Word6 (ROM Patch)
(OCOTP_ROM_PATCH6)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 6, word 6 (ADDR = 0x36).
Address: 21B_C000h base + 860h offset = 21B_C860h
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
BITS
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
OCOTP_ROM_PATCH6 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 6, word 6 (ADDR = 0x36).
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2429

<!-- page 2430 -->

37.5.67
Value of OTP Bank6 Word7 (ROM Patch)
(OCOTP_ROM_PATCH7)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 6, word 7 (ADDR = 0x37).
Address: 21B_C000h base + 870h offset = 21B_C870h
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
BITS
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
OCOTP_ROM_PATCH7 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 6, word 7 (ADDR = 0x37).
37.5.68
Value of OTP Bank7 Word0 (General Purpose Customer
Defined Info) (OCOTP_GP3_0)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 7, word 0 (ADDR = 0x38).
Address: 21B_C000h base + 880h offset = 21B_C880h
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
BITS
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
OCOTP_GP3_0 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 8, word 0 (ADDR = 0x40).
37.5.69
Value of OTP Bank7 Word1 (General Purpose Customer
Defined Info) (OCOTP_GP3_1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2430
NXP Semiconductors

<!-- page 2431 -->

Shadowed memory mapped access to OTP Bank 7, word 1 (ADDR = 0x39).
Address: 21B_C000h base + 890h offset = 21B_C890h
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
BITS
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
OCOTP_GP3_1 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 8, word 1 (ADDR = 0x41).
37.5.70
Value of OTP Bank7 Word2 (General Purpose Customer
Defined Info) (OCOTP_GP3_2)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 7, word 2 (ADDR = 0x3A).
Address: 21B_C000h base + 8A0h offset = 21B_C8A0h
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
BITS
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
OCOTP_GP3_2 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 8, word 2 (ADDR = 0x42).
37.5.71
Value of OTP Bank7 Word3 (General Purpose Customer
Defined Info) (OCOTP_GP3_3)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 7, word 3 (ADDR = 0x3B).
Address: 21B_C000h base + 8B0h offset = 21B_C8B0h
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
BITS
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
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2431

<!-- page 2432 -->

OCOTP_GP3_3 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 8, word 3 (ADDR = 0x43).
37.5.72
Value of OTP Bank8 Word4 (General Purpose Customer
Defined Info) (OCOTP_GP4_0)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 7, word 4 (ADDR = 0x3C).
Address: 21B_C000h base + 8C0h offset = 21B_C8C0h
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
BITS
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
OCOTP_GP4_0 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 8, word 4 (ADDR = 0x44).
37.5.73
Value of OTP Bank7 Word5 (General Purpose Customer
Defined Info) (OCOTP_GP4_1)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 7, word 5 (ADDR = 0x3D).
Address: 21B_C000h base + 8D0h offset = 21B_C8D0h
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
BITS
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
OCOTP_GP4_1 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 8, word 5 (ADDR = 0x45).
OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2432
NXP Semiconductors

<!-- page 2433 -->

37.5.74
Value of OTP Bank7 Word6 (General Purpose Customer
Defined Info) (OCOTP_GP4_2)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 7, word 6 (ADDR = 0x3E).
Address: 21B_C000h base + 8E0h offset = 21B_C8E0h
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
BITS
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
OCOTP_GP4_2 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 8, word 6 (ADDR = 0x46).
37.5.75
Value of OTP Bank7 Word7 (General Purpose Customer
Defined Info) (OCOTP_GP4_3)
Copied from the OTP automatically after reset. Can be re-loaded by setting
HW_OCOTP_CTRL[RELOAD_SHADOWS]
Shadowed memory mapped access to OTP Bank 7, word 7 (ADDR = 0x3F).
Address: 21B_C000h base + 8F0h offset = 21B_C8F0h
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
BITS
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
OCOTP_GP4_3 field descriptions
Field
Description
BITS
Reflects value of OTP Bank 8, word 7 (ADDR = 0x47).
Chapter 37 On-Chip OTP Controller (OCOTP_CTRL)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2433

<!-- page 2434 -->

OCOTP Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2434
NXP Semiconductors

