# Power-Down Mode

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 169–176

<!-- page 169 -->

Power-Down Mode
Power-down is synchronously entered when CKE is registered LOW coincident with a
NOP or DES command. CKE is not allowed to go LOW while an MRS, MPR, ZQCAL,
READ, or WRITE operation is in progress. CKE is allowed to go LOW while any of the
other legal operations (such as ROW ACTIVATION, PRECHARGE, auto precharge, or RE-
FRESH) are in progress. However, the power-down IDD specifications are not applicable
until such operations have completed. Depending on the previous DRAM state and the
command issued prior to CKE going LOW, certain timing constraints must be satisfied
(as noted in Table 78). Timing diagrams detailing the different power-down mode entry
and exits are shown in Figure 94 (page 171) through Figure 103 (page 175).
Table 78: Command to Power-Down Entry Parameters
DRAM Status
Last Command Prior to
CKE LOW1
Parameter (Min)
Parameter Value
Figure
Idle or active
ACTIVATE
tACTPDEN
1tCK
Figure 101 (page 174)
Idle or active
PRECHARGE
tPRPDEN
1tCK
Figure 102 (page 175)
Active
READ or READAP
tRDPDEN
RL + 4tCK + 1tCK
Figure 97 (page 172)
Active
WRITE: BL8OTF, BL8MRS,
BC4OTF
tWRPDEN
WL + 4tCK + tWR/tCK
Figure 98 (page 173)
Active
WRITE: BC4MRS
WL + 2tCK + tWR/tCK
Figure 98 (page 173)
Active
WRITEAP: BL8OTF, BL8MRS,
BC4OTF
tWRAPDEN
WL + 4tCK + WR + 1tCK
Figure 99 (page 173)
Active
WRITEAP: BC4MRS
WL + 2tCK + WR + 1tCK
Figure 99 (page 173)
Idle
REFRESH
tREFPDEN
1tCK
Figure 100 (page 174)
Power-down
REFRESH
tXPDLL
Greater of 10tCK or 24ns
Figure 104 (page 176)
Idle
MODE REGISTER SET
tMRSPDEN
tMOD
Figure 103 (page 175)
Note:
1. If slow-exit mode precharge power-down is enabled and entered, ODT becomes asyn-
chronous tANPD prior to CKE going LOW and remains asynchronous until tANPD +
tXPDLL after CKE goes HIGH.
Entering power-down disables the input and output buffers, excluding CK, CK#, ODT,
CKE, and RESET#. NOP or DES commands are required until tCPDED has been satis-
fied, at which time all specified input/output buffers are disabled. The DLL should be in
a locked state when power-down is entered for the fastest power-down exit timing. If
the DLL is not locked during power-down entry, the DLL must be reset after exiting
power-down mode for proper READ operation as well as synchronous ODT operation.
During power-down entry, if any bank remains open after all in-progress commands are
complete, the DRAM will be in active power-down mode. If all banks are closed after all
in-progress commands are complete, the DRAM will be in precharge power-down
mode. Precharge power-down mode must be programmed to exit with either a slow exit
mode or a fast exit mode. When entering precharge power-down mode, the DLL is
turned off in slow exit mode or kept on in fast exit mode.
The DLL also remains on when entering active power-down. ODT has special timing
constraints when slow exit mode precharge power-down is enabled and entered. Refer
to Asynchronous ODT Mode (page 193) for detailed ODT usage requirements in slow
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Power-Down Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
169
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 170 -->

exit mode precharge power-down. A summary of the two power-down modes is listed in 
Table 79 (page 170).
While in either power-down state, CKE is held LOW, RESET# is held HIGH, and a stable
clock signal must be maintained. ODT must be in a valid state but all other input signals
are “Don’t Care.” If RESET# goes LOW during power-down, the DRAM will switch out of
power-down mode and go into the reset state. After CKE is registered LOW, CKE must
remain LOW until tPD (MIN) has been satisfied. The maximum time allowed for power-
down duration is tPD (MAX) (9 × tREFI).
The power-down states are synchronously exited when CKE is registered HIGH (with a
required NOP or DES command). CKE must be maintained HIGH until tCKE has been
satisfied. A valid, executable command may be applied after power-down exit latency,
tXP, and tXPDLL have been satisfied. A summary of the power-down modes is listed be-
low.
For specific CKE-intensive operations, such as repeating a power-down-exit-to-refresh-
to-power-down-entry sequence, the number of clock cycles between power-down exit
and power-down entry may not be sufficient to keep the DLL properly updated. In addi-
tion to meeting tPD when the REFRESH command is used between power-down exit
and power-down entry, two other conditions must be met. First, tXP must be satisfied
before issuing the REFRESH command. Second, tXPDLL must be satisfied before the
next power-down may be entered. An example is shown in Figure 104 (page 176).
Table 79: Power-Down Modes
DRAM State
MR0[12]
DLL State
Power-
Down Exit
Relevant Parameters
Active (any bank open)
“Don’t Care”
On
Fast
tXP to any other valid command
Precharged
(all banks precharged)
1
On
Fast
tXP to any other valid command
0
Off
Slow
tXPDLL to commands that require the DLL to be
locked (READ, RDAP, or ODT on);
tXP to any other valid command
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Power-Down Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
170
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 171 -->

Figure 94: Active Power-Down Entry and Exit
CK
CK#
Command
NOP
NOP
NOP
NOP
Address
CKE
tCK
tCH
tCL
Enter power-down
mode
Exit power-down
mode
Don’t Care
Valid
Valid
Valid
tCPDED
Valid
tIS
tIH
tIH
tIS
T0
T1
T2
Ta0
Ta1
Ta2
Ta3
Ta4
NOP
tXP
tCKE (MIN)
Indicates break
in time scale
tPD
Figure 95: Precharge Power-Down (Fast-Exit Mode) Entry and Exit
CK
CK#
Command
NOP
NOP
NOP
NOP
CKE
tCK
tCH
tCL
Enter power-down
mode
Exit power-down
mode
tPD
Valid
tCPDED
tIS
tIH
tIS
T0
T1
T2
T3
T4
T5
Ta0
Ta1
NOP
Don’t Care
Indicates break
in time scale
tXP
tCKE (MIN)
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Power-Down Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
171
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 172 -->

Figure 96: Precharge Power-Down (Slow-Exit Mode) Entry and Exit
CK
CK#
Command
NOP
NOP
NOP
CKE
tCK
tCH
tCL
Enter power-down
mode
Exit power-down
mode
tPD
Valid2
Valid1
PRE
tXPDLL
tCPDED
tIS
tIH
tIS
T0
T1
T2
T3
T4
Ta
Ta1
Tb
NOP
Don’t Care
Indicates break
in time scale
tXP
tCKE (MIN)
Notes:
1. Any valid command not requiring a locked DLL.
2. Any valid command requiring a locked DLL.
Figure 97: Power-Down Entry After READ or READ with Auto Precharge (RDAP)
T0
T1
Ta0
Ta1
Ta2
Ta3
Ta4
Ta5
Ta6
Ta7
Ta8
Ta9
Don’t Care
Transitioning Data
Ta10
Ta11
Ta12
NOP
Valid
READ/
RDAP
NOP
NOP
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
DQ BL8
DQ BC4
DQS, DQS#
Address
CKE
tCPDED
tIS
tPD
Power-down or
self refresh entry
Indicates break
in time scale
tRDPDEN
DI
n + 3
DI
n + 1
DI
n + 2
DIn
RL = AL + CL
DI
n + 3
DI
n + 2
DI
n + 1
DIn
DI
n + 6
DI
n + 7
DI
n+ 5
DI
n + 4
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Power-Down Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
172
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 173 -->

Figure 98: Power-Down Entry After WRITE
T0
T1
Ta0
Ta1
Ta2
Ta3
Ta4
Ta5
Ta6
Ta7
Tb0
Tb1
Tb2
Tb3
Tb4
NOP
WRITE
Valid
NOP
NOP
NOP
NOP
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
DQ BL8
DQ BC4
DQS, DQS#
Address
CKE
tCPDED
Power-down or
self refresh entry1
Don’t Care
Transitioning Data
tWRPDEN
DI
n + 3
DI
n + 1
DI
n + 2
DIn
tPD
Indicates break
in time scale
DI
 n + 3
DI
 n + 2
DI
 n + 1
DI
 n
DI
 n + 6
DI
 n + 7
DI
 n + 5
DI
 n + 4
tIS
WL = AL + CWL
tWR
Note:
1. CKE can go LOW 2tCK earlier if BC4MRS.
Figure 99: Power-Down Entry After WRITE with Auto Precharge (WRAP)
T0
T1
Ta0
Ta1
Ta2
Ta3
Ta4
Ta5
Ta6
Ta7
Tb0
Tb1
Don’t Care
Transitioning Data
Tb2
Tb3
Tb4
NOP
WRAP
Valid
NOP
NOP
NOP
NOP
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
DQ BL8
DQ BC4
DQS, DQS#
Address
A10
CKE
tPD
tWRAPDEN
Power-down or
self refresh entry2
Start internal
precharge
tCPDED
tIS
Indicates break
in time scale
DI
 n + 3
DI
 n + 2
DI
 n + 1
DIn
DI
 n + 6
DI
 n + 7
DI
 n + 5
DI
 n + 4
DI
 n + 3
DI
 n + 2
DI
 n + 1
DI
 n
WR1
WL = AL + CWL
Notes:
1.
tWR is programmed through MR0[11:9] and represents tWRmin (ns)/tCK rounded up to
the next integer tCK.
2. CKE can go LOW 2tCK earlier if BC4MRS.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Power-Down Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
173
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 174 -->

Figure 100: REFRESH to Power-Down Entry
CK
CK#
Command
REFRESH
NOP
NOP
NOP
NOP
Valid
CKE
tCK
tCH
tCL
tCPDED
tREFPDEN
tIS
T0
T1
T2
T3
Ta0
Ta1
Ta2
Tb0
tXP (MIN)
tRFC (MIN)1
Don’t Care
Indicates break
in time scale
tCKE (MIN)
tPD
Note:
1. After CKE goes HIGH during tRFC, CKE must remain HIGH until tRFC is satisfied.
Figure 101: ACTIVATE to Power-Down Entry
CK
CK#
Command
Address
ACTIVE
NOP
NOP
CKE
tCK
tCH
tCL
Don’t Care
tCPDED
tACTPDEN
Valid
tIS
T0
T1
T2
T3
T4
T5
T6
T7
tPD
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Power-Down Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
174
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 175 -->

Figure 102: PRECHARGE to Power-Down Entry
CK
CK#
Command
Address
CKE
tCK
tCH
tCL
Don’t Care
tCPDED
tPREPDEN
tIS
T0
T1
T2
T3
T4
T5
T6
T7
tPD
All/single
bank
PRE
NOP
NOP
Figure 103: MRS Command to Power-Down Entry
CK
CK#
CKE
tCK
tCH
tCL
tCPDED
Address
tIS
T0
T1
T2
Ta0
Ta1
Ta2
Ta3
Ta4
tPD
Don’t Care
Indicates break
in time scale
Valid
Command
MRS
NOP
NOP
NOP
NOP
NOP
tMRSPDEN
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Power-Down Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
175
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 176 -->

Figure 104: Power-Down Exit to Refresh to Power-Down Entry
CK
CK#
CKE
tCK
tCH
tCL
Enter power-down
mode
Enter power-down
mode
Exit power-down
mode
tPD
tCPDED
tIS
tIH
tIS
T0
T1
T2
T3
T4
Ta0
Ta1
Tb0
Don’t Care
Indicates break
in time scale
Command
NOP
NOP
NOP
NOP
REFRESH
NOP
NOP
tXP1
tXPDLL2
Notes:
1.
tXP must be satisfied before issuing the command.
2.
tXPDLL must be satisfied (referenced to the registration of power-down exit) before the
next power-down can be entered.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Power-Down Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
176
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

