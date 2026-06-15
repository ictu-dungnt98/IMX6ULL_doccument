# Mode Register 0 (MR0)

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 122–126

<!-- page 122 -->

Figure 49: MRS to nonMRS Command Timing (tMOD)
Valid
Valid
MRS
non
MRS
NOP
NOP
NOP
NOP
T0
T1
T2
Ta0
Ta1
Ta2
CK#
CK
Command
Address
CKE
Valid
Old 
setting
New 
setting
Indicates break
in time scale
tMOD
Updating setting
Don’t Care
Notes:
1. Prior to issuing the MRS command, all banks must be idle (they must be precharged, tRP
must be satisfied, and no data bursts can be in progress).
2. Prior to Ta2 when tMOD (MIN) is being satisfied, no commands (except NOP/DES) may be
issued.
3. If RTT was previously enabled, ODT must be registered LOW at T0 so that ODTL is satis-
fied prior to Ta1. ODT must also be registered LOW at each rising CK edge from T0 until
tMODmin is satisfied at Ta2.
4. CKE must be registered HIGH from the MRS command until tMRSPDEN (MIN), at which
time power-down may occur (see Power-Down Mode (page 169)).
Mode Register 0 (MR0)
The base register, mode register 0 (MR0), is used to define various DDR3 SDRAM modes
of operation. These definitions include the selection of a burst length, burst type, CAS
latency, operating mode, DLL RESET, write recovery, and precharge power-down mode
(see Figure 50 (page 123)).
Burst Length
Burst length is defined by MR0[1:0]. Read and write accesses to the DDR3 SDRAM are
burst-oriented, with the burst length being programmable to 4 (chop) mode, 8 (fixed)
mode, or selectable using A12 during a READ/WRITE command (on-the-fly). The burst
length determines the maximum number of column locations that can be accessed for
a given READ or WRITE command. When MR0[1:0] is set to 01 during a READ/WRITE
command, if A12 = 0, then BC4 mode is selected. If A12 = 1, then BL8 mode is selected.
Specific timing diagrams, and turnaround between READ/WRITE, are shown in the
READ/WRITE sections of this document.
When a READ or WRITE command is issued, a block of columns equal to the burst
length is effectively selected. All accesses for that burst take place within this block,
meaning that the burst will wrap within the block if a boundary is reached. The block is
uniquely selected by A[i:2] when the burst length is set to 4 and by A[i:3] when the burst
length is set to 8, where Ai is the most significant column address bit for a given config-
uration. The remaining (least significant) address bit(s) is (are) used to select the start-
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 0 (MR0)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
122
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 123 -->

ing location within the block. The programmed burst length applies to both READ and
WRITE bursts.
Figure 50: Mode Register 0 (MR0) Definitions
BL
CAS# latency
CL
BT
PD
A9
A7 A6
A5 A4 A3
A8
A2
A1 A0
Mode register 0 (MR0)
Address bus
9
7
6
5
4
3
8
2
1
0
A10
A12 A11
BA0
BA1
10
11
12
15–13
M3 
0
1
READ Burst Type
 
Sequential (nibble)
Interleaved
CAS Latency
Reserved
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
M2
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
M4
0
1
0
1
0
1
0
1
0
1
0
M5
0
0
1
1
0
0
1
1
0
0
1
M6
0
0
0
0
1
1
1
1
0
0
0
17
DLL
Write Recovery
16
5
6
7
8
10
12
14
WR
0
0
M12
0 
1
Precharge PD
DLL off (slow exit)
DLL on (fast exit)
BA2
18
01
Burst Length
Fixed BL8
4 or 8 (on-the-fly via A12)
Fixed BC4 (chop)
Reserved
M0
0
1
0
1
M1
0
0
1
1
M9
0
1
0
1
0
1
0
1
M10
0
0
1
1
0
0
1
1
M11
0
0
0
0
1
1
1
1
M14 
0
1
0
1
M15
0
0
1
1
Mode Register 
Mode register 0 (MR0)
Mode register 1 (MR1)
Mode register 2 (MR2)
Mode register 3 (MR3)
A[15:13]
16
01
01
M8
0
1
DLL Reset
No
Yes
Note:
1. MR0[18, 15:13, 7] are reserved for future use and must be programmed to 0.
Burst Type
Accesses within a given burst can be programmed to either a sequential or an inter-
leaved order. The burst type is selected via MR0[3] (see Figure 50 (page 123)). The order-
ing of accesses within a burst is determined by the burst length, the burst type, and the
starting column address. DDR3 only supports 4-bit burst chop and 8-bit burst access
modes. Full interleave address ordering is supported for READs, while WRITEs are re-
stricted to nibble (BC4) or word (BL8) boundaries.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 0 (MR0)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
123
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 124 -->

Table 73: Burst Order
Burst
Length
READ/
WRITE
Starting
Column Address
(A[2, 1, 0])
Burst Type = Sequential
(Decimal)
Burst Type = Interleaved
(Decimal)
Notes
4 (chop)
READ
0 0 0
0, 1, 2, 3, Z, Z, Z, Z
0, 1, 2, 3, Z, Z, Z, Z
1, 2
0 0 1
1, 2, 3, 0, Z, Z, Z, Z
1, 0, 3, 2, Z, Z, Z, Z
1, 2
0 1 0
2, 3, 0, 1, Z, Z, Z, Z
2, 3, 0, 1, Z, Z, Z, Z
1, 2
0 1 1
3, 0, 1, 2, Z, Z, Z, Z
3, 2, 1, 0, Z, Z, Z, Z
1, 2
1 0 0
4, 5, 6, 7, Z, Z, Z, Z
4, 5, 6, 7, Z, Z, Z, Z
1, 2
1 0 1
5, 6, 7, 4, Z, Z, Z, Z
5, 4, 7, 6, Z, Z, Z, Z
1, 2
1 1 0
6, 7, 4, 5, Z, Z, Z, Z
6, 7, 4, 5, Z, Z, Z, Z
1, 2
1 1 1
7, 4, 5, 6, Z, Z, Z, Z
7, 6, 5, 4, Z, Z, Z, Z
1, 2
WRITE
0 V V
0, 1, 2, 3, X, X, X, X
0, 1, 2, 3, X, X, X, X
1, 3, 4
1 V V
4, 5, 6, 7, X, X, X, X
4, 5, 6, 7, X, X, X, X
1, 3, 4
8 (fixed)
READ
0 0 0
0, 1, 2, 3, 4, 5, 6, 7
0, 1, 2, 3, 4, 5, 6, 7
1
0 0 1
1, 2, 3, 0, 5, 6, 7, 4
1, 0, 3, 2, 5, 4, 7, 6
1
0 1 0
2, 3, 0, 1, 6, 7, 4, 5
2, 3, 0, 1, 6, 7, 4, 5
1
0 1 1
3, 0, 1, 2, 7, 4, 5, 6
3, 2, 1, 0, 7, 6, 5, 4
1
1 0 0
4, 5, 6, 7, 0, 1, 2, 3
4, 5, 6, 7, 0, 1, 2, 3
1
1 0 1
5, 6, 7, 4, 1, 2, 3, 0
5, 4, 7, 6, 1, 0, 3, 2
1
1 1 0
6, 7, 4, 5, 2, 3, 0, 1
6, 7, 4, 5, 2, 3, 0, 1
1
1 1 1
7, 4, 5, 6, 3, 0, 1, 2
7, 6, 5, 4, 3, 2, 1, 0
1
WRITE
V V V
0, 1, 2, 3, 4, 5, 6, 7
0, 1, 2, 3, 4, 5, 6, 7
1, 3
Notes:
1. Internal READ and WRITE operations start at the same point in time for BC4 as they do
for BL8.
2. Z = Data and strobe output drivers are in tri-state.
3. V = A valid logic level (0 or 1), but the respective input buffer ignores level-on input
pins.
4. X = “Don’t Care.”
DLL RESET
DLL RESET is defined by MR0[8] (see Figure 50 (page 123)). Programming MR0[8] to 1
activates the DLL RESET function. MR0[8] is self-clearing, meaning it returns to a value
of 0 after the DLL RESET function has been initiated.
Anytime the DLL RESET function is initiated, CKE must be HIGH and the clock held
stable for 512 (tDLLK) clock cycles before a READ command can be issued. This is to
allow time for the internal clock to be synchronized with the external clock. Failing to
wait for synchronization can result in invalid output timing specifications, such as
tDQSCK timings.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 0 (MR0)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
124
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 125 -->

Write Recovery
WRITE recovery time is defined by MR0[11:9] (see Figure 50 (page 123)). Write recovery
values of 5, 6, 7, 8, 10, or 12 can be used by programming MR0[11:9]. The user is re-
quired to program the correct value of write recovery, which is calculated by dividing
tWR (ns) by tCK (ns) and rounding up a noninteger value to the next integer:
WR (cycles) = roundup (tWR (ns)/tCK (ns)).
Precharge Power-Down (Precharge PD)
The precharge power-down (precharge PD) bit applies only when precharge power-
down mode is being used. When MR0[12] is set to 0, the DLL is off during precharge
power-down, providing a lower standby current mode; however, tXPDLL must be satis-
fied when exiting. When MR0[12] is set to 1, the DLL continues to run during precharge
power-down mode to enable a faster exit of precharge power-down mode; however, tXP
must be satisfied when exiting (see Power-Down Mode (page 169)).
CAS Latency (CL)
CAS latency (CL) is defined by MR0[6:4], as shown in Figure 50 (page 123). CAS latency
is the delay, in clock cycles, between the internal READ command and the availability of
the first bit of output data. CL can be set to 5 through 14. DDR3 SDRAM do not support
half-clock latencies.
Examples of CL = 6 and CL = 8 are shown below. If an internal READ command is regis-
tered at clock edge n, and the CAS latency is m clocks, the data will be available nomi-
nally coincident with clock edge n + m. See Speed Bin Tables for the CLs supported at
various operating frequencies.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 0 (MR0)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
125
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 126 -->

Figure 51: READ Latency
READ
NOP
NOP
NOP
NOP
NOP
NOP
NOP
CK
CK#
Command
DQ
DQS, DQS#
DQS, DQS#
T0
T1
T2
T3
T4
T5
T6
T7
T8
Don’t Care
CK
CK#
Command
DQ
READ
NOP
NOP
NOP
NOP
NOP
NOP
NOP
T0
T1
T2
T3
T4
T5
T6
T7
T8
DI
 n + 3
DI
 n + 1
DI
 n + 2
DI
 n + 4
DI
n
DI
n
NOP
NOP
AL = 0, CL = 8
AL = 0, CL = 6
Transitioning Data
Notes:
1. For illustration purposes, only CL = 6 and CL = 8 are shown. Other CL values are possible.
2. Shown with nominal tDQSCK and nominal tDSDQ.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 0 (MR0)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
126
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

