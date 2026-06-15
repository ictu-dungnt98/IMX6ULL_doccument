# Asynchronous ODT Mode

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 193–196

<!-- page 193 -->

Asynchronous ODT Mode
Asynchronous ODT mode is available when the DRAM runs in DLL on mode and when
either RTT,nom or RTT(WR) is enabled; however, the DLL is temporarily turned off in pre-
charged power-down standby (via MR0[12]). Additionally, ODT operates asynchronous-
ly when the DLL is synchronizing after being reset. See Power-Down Mode (page 169)
for definition and guidance over power-down details.
In asynchronous ODT timing mode, the internal ODT command is not delayed by AL
relative to the external ODT command. In asynchronous ODT mode, ODT controls RTT
by analog time. The timing parameters tAONPD and tAOFPD replace ODTLon/tAON
and ODTLoff/tAOF, respectively, when ODT operates asynchronously.
The minimum RTT turn-on time (tAONPD [MIN]) is the point at which the device termi-
nation circuit leaves High-Z and ODT resistance begins to turn on. Maximum RTT turn-
on time (tAONPD [MAX]) is the point at which ODT resistance is fully on. tAONPD
(MIN) and tAONPD (MAX) are measured from ODT being sampled HIGH.
The minimum RTT turn-off time (tAOFPD [MIN]) is the point at which the device termi-
nation circuit starts to turn off ODT resistance. Maximum RTT turn-off time (tAOFPD
[MAX]) is the point at which ODT has reached High-Z. tAOFPD (MIN) and tAOFPD
(MAX) are measured from ODT being sampled LOW.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Asynchronous ODT Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
193
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 194 -->

Figure 115: Asynchronous ODT Timing with Fast ODT Transition
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
tAONPD (MAX)
tAOFPD (MAX)
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
RTT
ODT
RTT,nom
Don’t Care
Transitioning
CKE
tIH
tIS
tIH
tIS
tAOFPD (MIN)
tAONPD (MIN)
Note:
1. AL is ignored.
Table 88: Asynchronous ODT Timing Parameters for All Speed Bins
Symbol
Description
Min
Max
Unit
tAONPD
Asynchronous RTT turn-on delay (power-down with DLL off)
2
8.5
ns
tAOFPD
Asynchronous RTT turn-off delay (power-down with DLL off)
2
8.5
ns
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Asynchronous ODT Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
194
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 195 -->

Synchronous to Asynchronous ODT Mode Transition (Power-Down Entry)
There is a transition period around power-down entry (PDE) where the DRAM’s ODT
may exhibit either synchronous or asynchronous behavior. This transition period oc-
curs if the DLL is selected to be off when in precharge power-down mode by the setting
MR0[12] = 0. Power-down entry begins tANPD prior to CKE first being registered LOW,
and ends when CKE is first registered LOW. tANPD is equal to the greater of ODTLoff +
1tCK or ODTLon + 1tCK. If a REFRESH command has been issued, and it is in progress
when CKE goes LOW, power-down entry ends tRFC after the REFRESH command, rath-
er than when CKE is first registered LOW. Power-down entry then becomes the greater
of tANPD and tRFC - REFRESH command to CKE registered LOW.
ODT assertion during power-down entry results in an RTT change as early as the lesser
of tAONPD (MIN) and ODTLon × tCK + tAON (MIN), or as late as the greater of tAONPD
(MAX) and ODTLon × tCK + tAON (MAX). ODT de-assertion during power-down entry
can result in an RTT change as early as the lesser of tAOFPD (MIN) and ODTLoff × tCK +
tAOF (MIN), or as late as the greater of tAOFPD (MAX) and ODTLoff × tCK + tAOF (MAX). 
Table 89 (page 196) summarizes these parameters.
If AL has a large value, the uncertainty of the state of RTT becomes quite large. This is
because ODTLon and ODTLoff are derived from the WL; and WL is equal to CWL + AL. 
Figure 116 (page 196) shows three different cases:
• ODT_A: Synchronous behavior before tANPD.
• ODT_B: ODT state changes during the transition period with tAONPD (MIN) <
ODTLon × tCK + tAON (MIN) and tAONPD (MAX) > ODTLon × tCK + tAON (MAX).
• ODT_C: ODT state changes after the transition period with asynchronous behavior.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Asynchronous ODT Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
195
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 196 -->

Table 89: ODT Parameters for Power-Down (DLL Off) Entry and Exit Transition Period
Description
Min
Max
Power-down entry transition period
(power-down entry)
Greater of: tANPD or tRFC - refresh to CKE LOW
Power-down exit transition period
(power-down exit)
tANPD + tXPDLL
ODT to RTT turn-on delay
(ODTLon = WL - 2)
Lesser of: tAONPD (MIN) (2ns) or
ODTLon × tCK + tAON (MIN)
Greater of: tAONPD (MAX) (8.5ns) or
ODTLon × tCK + tAON (MAX)
ODT to RTT turn-off delay
(ODTLoff = WL - 2)
Lesser of: tAOFPD (MIN) (2ns) or
ODTLoff × tCK + tAOF (MIN)
Greater of: tAOFPD (MAX) (8.5ns) or
ODTLoff × tCK + tAOF (MAX)
tANPD
WL - 1 (greater of ODTLoff + 1 or ODTLon + 1)
Figure 116: Synchronous to Asynchronous Transition During Precharge Power-Down (DLL Off) Entry
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
tAOFPD (MAX)
ODTLoff
T10
T11
T12
T13
Ta0
Ta1
Ta3
Ta2
CK
CK#
DRAM RTT B 
asynchronous 
or synchronous
RTT,nom
DRAM RTT C
asynchronous
RTT,nom
Don’t Care
Transitioning
CKE
NOP
NOP
NOP
NOP
NOP
Command
NOP
REF
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
PDE transition period
Indicates break
in time scale
ODTLoff + tAOFPD (MIN)
tAOFPD (MAX)
tAOFPD (MIN)
ODTLoff + tAOFPD (MAX)
tAOFPD (MIN)
tANPD
tAOF (MIN)
tAOF (MAX)
DRAM RTT A 
synchronous
RTT,nom
ODT A 
synchronous
ODT C 
asynchronous
ODT B 
asynchronous 
or synchronous
tRFC (MIN)
Note:
1. AL = 0; CWL = 5; ODTL(off) = WL - 2 = 3.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Asynchronous ODT Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
196
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

