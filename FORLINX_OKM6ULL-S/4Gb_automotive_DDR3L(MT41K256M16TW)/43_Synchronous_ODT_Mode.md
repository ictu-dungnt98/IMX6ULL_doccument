# Synchronous ODT Mode

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 188–192

<!-- page 188 -->

Synchronous ODT Mode
Synchronous ODT mode is selected whenever the DLL is turned on and locked and
when either RTT,nom or RTT(WR) is enabled. Based on the power-down definition, these
modes are:
• Any bank active with CKE HIGH
• Refresh mode with CKE HIGH
• Idle mode with CKE HIGH
• Active power-down mode (regardless of MR0[12])
• Precharge power-down mode if DLL is enabled by MR0[12] during precharge power-
down
ODT Latency and Posted ODT
In synchronous ODT mode, RTT turns on ODTLon clock cycles after ODT is sampled
HIGH by a rising clock edge and turns off ODTLoff clock cycles after ODT is registered
LOW by a rising clock edge. The actual on/off times varies by tAON and tAOF around
each clock edge (see Table 87 (page 189)). The ODT latency is tied to the WRITE latency
(WL) by ODTLon = WL - 2 and ODTLoff = WL - 2.
Since write latency is made up of CAS WRITE latency (CWL) and additive latency (AL),
the AL programmed into the mode register (MR1[4, 3]) also applies to the ODT signal.
The device’s internal ODT signal is delayed a number of clock cycles defined by the AL
relative to the external ODT signal. Thus, ODTLon = CWL + AL - 2 and ODTLoff = CWL +
AL - 2.
Timing Parameters
Synchronous ODT mode uses the following timing parameters: ODTLon, ODTLoff,
ODTH4, ODTH8, tAON, and tAOF. The minimum RTT turn-on time (tAON [MIN]) is the
point at which the device leaves High-Z and ODT resistance begins to turn on. Maxi-
mum RTT turn-on time (tAON [MAX]) is the point at which ODT resistance is fully on.
Both are measured relative to ODTLon. The minimum RTT turn-off time (tAOF [MIN]) is
the point at which the device starts to turn off ODT resistance. The maximum RTT turn
off time (tAOF [MAX]) is the point at which ODT has reached High-Z. Both are measured
from ODTLoff.
When ODT is asserted, it must remain HIGH until ODTH4 is satisfied. If a WRITE com-
mand is registered by the DRAM with ODT HIGH, then ODT must remain HIGH until
ODTH4 (BC4) or ODTH8 (BL8) after the WRITE command (see Figure 113 (page 190)).
ODTH4 and ODTH8 are measured from ODT registered HIGH to ODT registered LOW
or from the registration of a WRITE command until ODT is registered LOW.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Synchronous ODT Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
188
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 189 -->

Table 87: Synchronous ODT Parameters
Symbol
Description
Begins at
Defined to
Definition for All
DDR3L Speed Bins
Unit
ODTLon
ODT synchronous turn-on delay
ODT registered HIGH
RTT(ON) ±tAON
CWL + AL - 2
tCK
ODTLoff
ODT synchronous turn-off delay
ODT registered HIGH
RTT(OFF) ±tAOF
CWL +AL - 2
tCK
ODTH4
ODT minimum HIGH time after ODT
assertion or WRITE (BC4)
ODT registered HIGH or write regis-
tration with ODT HIGH
ODT registered LOW
4tCK
tCK
ODTH8
ODT minimum HIGH time after WRITE
(BL8)
Write registration with ODT HIGH
ODT registered LOW
6tCK
tCK
tAON
ODT turn-on relative to ODTLon
completion
Completion of ODTLon
RTT(ON)
See Electrical Charac-
teristics and AC Oper-
ating Conditions ta-
ble
ps
tAOF
ODT turn-off relative to ODTLoff
completion
Completion of ODTLoff
RTT(OFF)
0.5tCK ± 0.2tCK
tCK
Figure 112: Synchronous ODT
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
CWL - 2
AL = 3
AL = 3
tAON (MAX)
tAOF (MAX)
T10
T11
T12
T13
T14
T15
CK
CK#
RTT
ODT
Don’t Care
Transitioning
RTT,nom
CKE
tAOF (MIN)
ODTLoff = CWL + AL - 2
ODTLon = CWL + AL - 2
ODTH4 (MIN)
tAON (MIN)
Note:
1. AL = 3; CWL = 5; ODTLon = WL = 6.0; ODTLoff = WL - 2 = 6. RTT,nom is enabled.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Synchronous ODT Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
189
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 190 -->

Figure 113: Synchronous ODT (BC4)
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
tAOF (MAX)
tAOF (MIN)
tAON (MAX)
tAOF (MAX)
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
CKE
NOP
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
NOP
NOP
NOP
NOP
NOP
Command
Don’t Care
Transitioning
tAON (MIN)
RTT,nom
ODTLoff = WL - 2
ODTH4 (MIN) 
ODTH4 
ODTLoff = WL - 2
ODTLon = WL - 2
tAON (MIN)
tAON (MAX)
ODTH4 
ODTLon = WL - 2
tAOF (MIN)
ODT
RTT,nom
Notes:
1. WL = 7. RTT,nom is enabled. RTT(WR) is disabled.
2. ODT must be held HIGH for at least ODTH4 after assertion (T1).
3. ODT must be kept HIGH ODTH4 (BC4) or ODTH8 (BL8) after the WRITE command (T7).
4. ODTH is measured from ODT first registered HIGH to ODT first registered LOW or from the registration of the
WRITE command with ODT HIGH to ODT registered LOW.
5. Although ODTH4 is satisfied from ODT registered HIGH at T6, ODT must not go LOW before T11 as ODTH4 must
also be satisfied from the registration of the WRITE command at T7.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Synchronous ODT Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
190
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 191 -->

ODT Off During READs
Because the device cannot terminate and drive at the same time, RTT must be disabled
at least one-half clock cycle before the READ preamble by driving the ODT ball LOW (if
either RTT,nom or RTT(WR) is enabled). RTT may not be enabled until the end of the post-
amble, as shown in the following example.
Note: ODT may be disabled earlier and enabled later than shown in Figure 114
(page 192).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Synchronous ODT Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
191
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 192 -->

Figure 114: ODT During READs
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
Valid
Address
DI
b + 3
DI
b + 2
DI
b + 1
DI
b
DI
b + 7
DI
b + 6
DI
b + 5
DI
b + 4
DQ
DQS, DQS#
Don’t Care
Transitioning
Command
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
NOP
READ
ODTLon = CWL + AL - 2
ODT
tAON (MAX)
RL = AL + CL
ODTLoff = CWL + AL - 2
tAOF (MIN)
RTT
RTT,nom
RTT,nom
tAOF (MAX)
Note:
1. ODT must be disabled externally during READs by driving ODT LOW. For example, CL = 6; AL = CL - 1 = 5; RL = AL
+ CL = 11; CWL = 5; ODTLon = CWL + AL - 2 = 8; ODTLoff = CWL + AL - 2 = 8. RTT,nom is enabled. RTT(WR) is a “Don’t
Care.”
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Synchronous ODT Mode
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
192
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

