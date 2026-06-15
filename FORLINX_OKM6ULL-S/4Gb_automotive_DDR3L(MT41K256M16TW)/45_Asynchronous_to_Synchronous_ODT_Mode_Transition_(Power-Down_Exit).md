# Asynchronous to Synchronous ODT Mode Transition (Power-Down Exit)

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 197–201

<!-- page 197 -->

Asynchronous to Synchronous ODT Mode Transition (Power-Down Exit)
The DRAM’s ODT can exhibit either asynchronous or synchronous behavior during
power-down exit (PDX). This transition period occurs if the DLL is selected to be off
when in precharge power-down mode by setting MR0[12] to 0. Power-down exit begins
tANPD prior to CKE first being registered HIGH, and ends tXPDLL after CKE is first reg-
istered HIGH. tANPD is equal to the greater of ODTLoff + 1tCK or ODTLon + 1tCK. The
transition period is tANPD + tXPDLL.
ODT assertion during power-down exit results in an RTT change as early as the lesser of
tAONPD (MIN) and ODTLon × tCK + tAON (MIN), or as late as the greater of tAONPD
(MAX) and ODTLon × tCK + tAON (MAX). ODT de-assertion during power-down exit
may result in an RTT change as early as the lesser of tAOFPD (MIN) and ODTLoff × tCK +
tAOF (MIN), or as late as the greater of tAOFPD (MAX) and ODTLoff × tCK + tAOF (MAX). 
Table 89 (page 196) summarizes these parameters.
If AL has a large value, the uncertainty of the RTT state becomes quite large. This is be-
cause ODTLon and ODTLoff are derived from WL, and WL is equal to CWL + AL. Figure
117 (page 198) shows three different cases:
• ODT C: Asynchronous behavior before tANPD.
• ODT B: ODT state changes during the transition period, with tAOFPD (MIN) < ODTL-
off × tCK + tAOF (MIN), and ODTLoff × tCK + tAOF (MAX) > tAOFPD (MAX).
• ODT A: ODT state changes after the transition period with synchronous response.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Asynchronous to Synchronous ODT Mode Transition (Power-
Down Exit)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
197
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 198 -->

Figure 117: Asynchronous to Synchronous Transition During Precharge Power-Down (DLL Off) Exit
T0
T1
T2
Ta0
Ta1
Ta2
Ta3
Ta4
Ta5
Ta6
Tb0
Tb1
Tb2
Tc0
Tc1
Td0
Td1
Tc2
CK
CK#
Don’t Care
Transitioning
ODT C
synchronous
NOP
NOP
NOP
COMMAND
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
RTT B
asynchronous
or synchronous
DRAM RTT A
asynchronous
DRAM RTT C
synchronous
RTT,nom
NOP
NOP
ODT B
asynchronous
or synchronous
CKE
tAOF (MIN)
RTT,nom
Indicates break
in time scale
ODTLoff + tAOF (MIN)
tAOFPD (MAX)
ODTLoff + tAOF (MAX)
tXPDLL
tAOF (MAX)
ODTLoff
ODT A
asynchronous
PDX transition period
tAOFPD (MIN)
tAOFPD (MAX)
RTT,nom
tANPD
tAOFPD (MIN)
Note:
1. CL = 6; AL = CL - 1; CWL = 5; ODTLoff = WL - 2 = 8.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Asynchronous to Synchronous ODT Mode Transition (Power-
Down Exit)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
198
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 199 -->

Asynchronous to Synchronous ODT Mode Transition (Short CKE Pulse)
If the time in the precharge power-down or idle states is very short (short CKE LOW
pulse), the power-down entry and power-down exit transition periods overlap. When
overlap occurs, the response of the DRAM’s RTT to a change in the ODT state can be
synchronous or asynchronous from the start of the power-down entry transition period
to the end of the power-down exit transition period, even if the entry period ends later
than the exit period.
If the time in the idle state is very short (short CKE HIGH pulse), the power-down exit
and power-down entry transition periods overlap. When this overlap occurs, the re-
sponse of the DRAM’s RTT to a change in the ODT state may be synchronous or asyn-
chronous from the start of power-down exit transition period to the end of the power-
down entry transition period.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Asynchronous to Synchronous ODT Mode Transition (Power-
Down Exit)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
199
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 200 -->

Figure 118: Transition Period for Short CKE LOW Cycles with Entry and Exit Period Overlapping
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
Ta0
Ta1
Ta2
Ta3
Ta4
CK
CK#
CKE
Command
Don’t Care
Transitioning
tXPDLL
tRFC (MIN)
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
REF
NOP
NOP
NOP
NOP
PDE transition period
PDX transition period
Indicates break
in time scale
tANPD
Short CKE low transition period (R TT change asynchronous or synchronous)
tANPD
Note:
1. AL = 0, WL = 5, tANPD = 4.
Figure 119: Transition Period for Short CKE HIGH Cycles with Entry and Exit Period Overlapping
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
CK
CK#
Command
Don’t Care
Transitioning
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
NOP
NOP
NOP
NOP
NOP
tANPD
tXPDLL
Indicates break
in time scale
Ta0
Ta1
Ta2
Ta3
Ta4
CKE
tANPD
Short CKE HIGH transition period (RTT change asynchronous or synchonous)
Note:
1. AL = 0, WL = 5, tANPD = 4.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Asynchronous to Synchronous ODT Mode Transition (Power-
Down Exit)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
200
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 201 -->

Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Asynchronous to Synchronous ODT Mode Transition (Power-
Down Exit)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
201
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

