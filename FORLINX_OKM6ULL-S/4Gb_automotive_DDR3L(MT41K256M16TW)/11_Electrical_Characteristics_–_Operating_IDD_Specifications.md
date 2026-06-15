# Electrical Characteristics – Operating IDD Specifications

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 39–40

<!-- page 39 -->

Electrical Characteristics – Operating IDD Specifications
Table 20: IDD Maximum Limits Die Rev. P for 1.35V/1.5V Operation
Speed Bin
DDR3/3L
-1866
Units
Notes
Parameter
Symbol
Width
Operating current 0: One bank ACTIVATE-to-PRE-
CHARGE
IDD0
x8
29
mA
1, 2
X16
TBD
Operating current 1: One bank ACTIVATE-to-
READ-to-PRECHARGE
IDD1
x8
44
mA
1, 2
x16
TBD
Precharge power-down current: Slow exit
IDD2P0
x8
11
mA
1, 2
x16
TBD
Precharge power-down current: Fast exit
IDD2P1
x8
11
mA
1, 2
x16
TBD
Precharge quiet standby current
IDD2Q
x8
15
mA
1, 2
x16
TBD
Precharge standby current
IDD2N
x8
17
mA
1, 2
x16
TBD
Precharge standby ODT current
IDD2NT
x8
22
mA
1, 2
x16
TBD
Active power-down current
IDD3P
x8
15
mA
1, 2
x16
TBD
Active standby current
IDD3N
x8
21
mA
1, 2
x16
TBD
Burst read operating current
IDD4R
x8
102
mA
1, 2
x16
TBD
Burst write operating current
IDD4W
x8
113
mA
1, 2
16
TBD
Burst refresh current
IDD5B
x8
152
mA
1, 2
x16
TBD
Self refresh
IDD6
x8
15
mA
1, 2, 3
x16
TBD
Extended temperature self refresh
IDD6ET
x8
23
mA
2, 4
x16
TBD
All banks interleaved read current
IDD7
x8
146
mA
1, 2
x16
TBD
Reset current
IDD8
All
IDD2P + 2mA
mA
1, 2
Notes:
1. TC = 85°C; SRT and ASR are disabled.
2. Enabling ASR could increase IDDx by up to an additional 2mA.
3. Restricted to TC (MAX) = 85°C.
4. TC = 85°C; ASR and ODT are disabled; SRT is enabled.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Characteristics – Operating IDD Specifications
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
39
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 40 -->

5. The IDD values must be derated (increased) on IT-option devices when operated outside
of the range 0°C ≤ TC ≤ +85°C:
5a. When TC < 0°C: IDD2P0, IDD2P1, and IDD3P must be derated by 4%; IDD4R and IDD4W must
be derated by 2%; and IDD6, IDD6ET, and IDD7 must be derated by 7%.
5b. When TC > 85°C: IDD0, IDD1, IDD2N, IDD2NT, IDD2Q, IDD3N, IDD3P, IDD4R, IDD4W, and IDD5B
must be derated by 2%; IDD2Px must be derated by 30%.
6. The IDD values must be derated (increased) on UT-option. When TC > +105°C: IDD2p0,
IDD2p1, IDD2N, IDD2NT, IDD2Q, IDD3P, and IDD3N must be derated by 60% from the 85°C speci-
fications.
7. When TC >105°C: 8X refresh is required, self refresh mode is not available.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Characteristics – Operating IDD Specifications
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
40
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

