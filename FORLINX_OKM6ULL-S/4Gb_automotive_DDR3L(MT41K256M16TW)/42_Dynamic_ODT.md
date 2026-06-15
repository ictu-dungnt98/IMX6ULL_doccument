# Dynamic ODT

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 182–187

<!-- page 182 -->

Dynamic ODT
In certain application cases, and to further enhance signal integrity on the data bus, it is
desirable that the termination strength of the DDR3 SDRAM can be changed without
issuing an MRS command, essentially changing the ODT termination on the fly. With
dynamic ODT RTT(WR)) enabled, the DRAM switches from nominal ODT RTT,nom) to dy-
namic ODT RTT(WR)) when beginning a WRITE burst and subsequently switches back to
nominal ODT RTT,nom) at the completion of the WRITE burst. This requirement is sup-
ported by the dynamic ODT feature, as described below.
Dynamic ODT Special Use Case
When DDR3 devices are architect as a single rank memory array, dynamic ODT offers a
special use case: the ODT ball can be wired high (via a current limiting resistor prefer-
red) by having RTT,nom disabled via MR1 and RTT(WR) enabled via MR2. This will allow
the ODT signal not to have to be routed yet the DRAM can provide ODT coverage dur-
ing write accesses.
When enabling this special use case, some standard ODT spec conditions may be viola-
ted: ODT is sometimes suppose to be held low. Such ODT spec violation (ODT not
LOW) is allowed under this special use case. Most notably, if Write Leveling is used, this
would appear to be a problem since RTT(WR) can not be used (should be disabled) and
RTT(NOM) should be used. For Write leveling during this special use case, with the DLL
locked, then RTT(NOM) maybe enabled when entering Write Leveling mode and disabled
when exiting Write Leveling mode. More so, RTT(NOM) must be enabled when enabling
Write Leveling, via same MR1 load, and disabled when disabling Write Leveling, via
same MR1 load if RTT(NOM) is to be used.
ODT will turn-on within a delay of ODTLon + tAON + tMOD + 1CK (enabling via MR1)
or turn-off within a delay of ODTLoff + tAOF + tMOD + 1CK. As seen in the table below,
between the Load Mode of MR1 and the previously specified delay, the value of ODT is
uncertain. this means the DQ ODT termination could turn-on and then turn-off again
during the period of stated uncertainty.
Table 82: Write Leveling with Dynamic ODT Special Case
Begin RTT,nom Uncertainty
End RTT,nom Uncertainty
I/Os
RTT,nom Final State
MR1 load mode command:
Enable Write Leveling and RTT(NOM)
ODTLon + tAON + tMOD + 1CK
DQS, DQS#
Drive RTT,nom value
DQs
No RTT,nom
MR1 load mode command:
Disable Write Leveling and RTT(NOM)
ODTLoff + tAOFF + tMOD + 1CK
DQS, DQS#
No RTT,nom
DQs
No RTT,nom
Functional Description
The dynamic ODT mode is enabled if either MR2[9] or MR2[10] is set to 1. Dynamic
ODT is not supported during DLL disable mode so RTT(WR) must be disabled. The dy-
namic ODT function is described below:
• Two RTT values are available—RTT,nom and RTT(WR).
– The value for RTT,nom is preselected via MR1[9, 6, 2].
– The value for RTT(WR) is preselected via MR2[10, 9].
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Dynamic ODT
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
182
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 183 -->

• During DRAM operation without READ or WRITE commands, the termination is con-
trolled.
– Nominal termination strength RTT,nom is used.
– Termination on/off timing is controlled via the ODT ball and latencies ODTLon and
ODTLoff.
• When a WRITE command (WR, WRAP, WRS4, WRS8, WRAPS4, WRAPS8) is registered,
and if dynamic ODT is enabled, the ODT termination is controlled.
– A latency of ODTLcnw after the WRITE command: termination strength RTT,nom
switches to RTT(WR)
– A latency of ODTLcwn8 (for BL8, fixed or OTF) or ODTLcwn4 (for BC4, fixed or OTF)
after the WRITE command: termination strength RTT(WR) switches back to RTT,nom.
– On/off termination timing is controlled via the ODT ball and determined by ODT-
Lon, ODTLoff, ODTH4, and ODTH8.
– During the tADC transition window, the value of RTT is undefined.
ODT is constrained during writes and when dynamic ODT is enabled (see the table be-
low, Dynamic ODT Specific Parameters). ODT timings listed in the ODT Parameters ta-
ble in On-Die Termination (ODT) also apply to dynamic ODT mode.
Table 83: Dynamic ODT Specific Parameters
Symbol
Description
Begins at
Defined to
Definition for All
DDR3L Speed
Bins
Unit
ODTLcnw
Change from RTT,nom to
RTT(WR)
Write registration
RTT switched from RTT,nom
to RTT(WR)
WL - 2
tCK
ODTLcwn4
Change from RTT(WR) to
RTT,nom (BC4)
Write registration
RTT switched from RTT(WR)
to RTT,nom
4tCK + ODTL off
tCK
ODTLcwn8
Change from RTT(WR) to
RTT,nom (BL8)
Write registration
RTT switched from RTT(WR)
to RTT,nom
6tCK + ODTL off
tCK
tADC
RTT change skew
ODTLcnw completed
RTT transition complete
0.5tCK ± 0.2tCK
tCK
Table 84: Mode Registers for RTT,nom
MR1 (RTT,nom)
RTT,nom (RZQ)
RTT,nom (Ohm)
RTT,nom Mode Restriction
M9
M6
M2
0
0
0
Off
Off
n/a
0
0
1
RZQ/4
60
Self refresh
0
1
0
RZQ/2
120
0
1
1
RZQ/6
40
1
0
0
RZQ/12
20
Self refresh, write
1
0
1
RZQ/8
30
1
1
0
Reserved
Reserved
n/a
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Dynamic ODT
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
183
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 184 -->

Table 84: Mode Registers for RTT,nom (Continued)
MR1 (RTT,nom)
RTT,nom (RZQ)
RTT,nom (Ohm)
RTT,nom Mode Restriction
M9
M6
M2
1
1
1
Reserved
Reserved
n/a
Note:
1. RZQ = 240Ω. If RTT,nom is used during WRITEs, only RZQ/2, RZQ/4, RZQ/6 are allowed.
Table 85: Mode Registers for RTT(WR)
MR2 (RTT(WR))
RTT(WR) (RZQ)
RTT(WR) (Ohm)
M10
M9
0
0
Dynamic ODT off: WRITE does not affect RTT,nom
0
1
RZQ/4
60
1
0
RZQ/2
120
1
1
Reserved
Reserved
Table 86: Timing Diagrams for Dynamic ODT
Figure and Page
Title
Figure 107 (page 185)
Dynamic ODT: ODT Asserted Before and After the WRITE, BC4
Figure 108 (page 185)
Dynamic ODT: Without WRITE Command
Figure 109 (page 186)
Dynamic ODT: ODT Pin Asserted Together with WRITE Command for 6 Clock Cycles, BL8
Figure 110 (page 187)
Dynamic ODT: ODT Pin Asserted with WRITE Command for 6 Clock Cycles, BC4
Figure 111 (page 187)
Dynamic ODT: ODT Pin Asserted with WRITE Command for 4 Clock Cycles, BC4
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Dynamic ODT
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
184
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 185 -->

Figure 107: Dynamic ODT: ODT Asserted Before and After the WRITE, BC4
T0
T1
T2
T3
T4
T5
T6
T7
T8
T9
ODTLon
ODTLcwn4
ODTLcnw
WL
ODTLoff
T10
T11
T12
T13
T14
T15
T17
T16
CK
CK#
Command
Address
RTT
ODT
DQ 
DQS, DQS#
Valid
WRS4
NOP
NOP
NOP
NOP
NOP
NOP
NOP
Don’t Care
Transitioning
RTT(WR)
RTT,nom
RTT,nom
DI
n + 3
DI
n + 2
DI
n + 1
DIn
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
ODTH4
ODTH4
tAON (MIN)
tADC (MIN)
tADC (MIN)
tAOF (MIN)
tAON (MAX)
tADC (MAX)
tADC (MAX)
tAOF (MAX)
Notes:
1. Via MRS or OTF. AL = 0, CWL = 5. RTT,nom and RTT(WR) are enabled.
2. ODTH4 applies to first registering ODT HIGH and then to the registration of the WRITE command. In this example,
ODTH4 is satisfied if ODT goes LOW at T8 (four clocks after the WRITE command).
Figure 108: Dynamic ODT: Without WRITE Command
T0
T1
T2
T3
T4
T5
T6
T7
T8
T9
ODTLoff 
T10
T11
CK
CK#
RTT
Don’t Care
Transitioning
Command
Valid
Valid
Valid
Valid
Valid
Valid
Valid
Valid
Valid
Valid
Valid
Valid
Address
DQS, DQS#
DQ
ODTH4
ODTLon
tAON (MAX)
tAON (MIN)
tAOF (MIN)
tAOF (MAX)
ODT
RTT,nom
Notes:
1. AL = 0, CWL = 5. RTT,nom is enabled and RTT(WR) is either enabled or disabled.
2. ODTH4 is defined from ODT registered HIGH to ODT registered LOW; in this example, ODTH4 is satisfied. ODT reg-
istered LOW at T5 is also legal.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Dynamic ODT
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
185
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 186 -->

Figure 109: Dynamic ODT: ODT Pin Asserted Together with WRITE Command for 6 Clock Cycles, BL8
T0
T1
T2
T3
T4
T5
T6
T7
T8
T9
ODTLcwn8
ODTLon
ODTLcnw
WL
tAOF (MAX)
T10
T11
CK
CK#
Address
RTT
ODT
DQ
DQS, DQS#
DI
b + 3
DI
b + 2
DI
b + 1
DIb
DI
b + 7
DI
b + 6
DI
b + 5
DI
 b + 4
Valid
Don’t Care
Transitioning
Command
WRS8
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
RTT(WR)
ODTH8
ODTLoff
tADC (MAX)
tAON (MIN)
tAOF (MIN)
Notes:
1. Via MRS or OTF; AL = 0, CWL = 5. If RTT,nom can be either enabled or disabled, ODT can be HIGH. RTT(WR) is enabled.
2. In this example, ODTH8 = 6 is satisfied exactly.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Dynamic ODT
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
186
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 187 -->

Figure 110: Dynamic ODT: ODT Pin Asserted with WRITE Command for 6 Clock Cycles, BC4
T0
T1
T2
T3
T4
T5
T6
T7
T8
T9
ODTLon
ODTLcnw
WL
T10
T11
CK
CK#
ODTLcwn4
DQS, DQS#
Address
Valid
Don’t Care
Transitioning
ODTLoff 
Command
WRS4
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
DQ
DI
n + 3
DI
n + 2
DI
n + 1
DIn
tADC (MIN)
tAOF (MIN)
tAOF (MAX)
tADC (MAX)
tADC (MAX)
tAON (MIN)
ODTH4
ODT
RTT
RTT(WR)
RTT,nom
Notes:
1. Via MRS or OTF. AL = 0, CWL = 5. RTT,nom and RTT(WR) are enabled.
2. ODTH4 is defined from ODT registered HIGH to ODT registered LOW, so in this example,
ODTH4 is satisfied. ODT registered LOW at T5 is also legal.
Figure 111: Dynamic ODT: ODT Pin Asserted with WRITE Command for 4 Clock Cycles, BC4
T0
T1
T2
T3
T4
T5
T6
T7
T8
T9
ODTLon
ODTLcnw
WL
T10
T11
CK
CK#
ODTLcwn4
DQS, DQS#
Address
Valid
Command
WRS4
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
Don’t Care
Transitioning
DQ
DI
n
DI
n + 3
DI
n + 2
DI
n + 1
ODTH4
tADC (MAX)
tAON (MIN)
tAOF (MIN)
tAOF (MAX)
ODTLoff 
RTT
RTT(WR)
ODT
Notes:
1. Via MRS or OTF. AL = 0, CWL = 5. RTT,nom can be either enabled or disabled. If disabled,
ODT can remain HIGH. RTT(WR) is enabled.
2. In this example ODTH4 = 4 is satisfied exactly.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Dynamic ODT
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
187
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

