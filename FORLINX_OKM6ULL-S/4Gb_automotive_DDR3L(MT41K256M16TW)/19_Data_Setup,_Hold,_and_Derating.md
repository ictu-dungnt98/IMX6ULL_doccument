# Data Setup, Hold, and Derating

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 91–98

<!-- page 91 -->

Data Setup, Hold, and Derating
The total tDS (setup time) and tDH (hold time) required is calculated by adding the data
sheet tDS (base) and tDH (base) values (see Table 62 (page 91); values come from the
Electrical Characteristics and AC Operating Conditions table) to the ΔtDS and ΔtDH de-
rating values (see Table 63 (page 92), Table 64 (page 92), or Table 65 (page 93)) re-
spectively. Example: tDS (total setup time) = tDS (base) + ΔtDS. For a valid transition, the
input signal has to remain above/below VIH(AC)/VIL(AC) for some time tVAC (see Table 66
(page 94)).
Although the total setup time for slow slew rates might be negative (for example, a valid
input signal will not have reached VIH(AC)/VIL(AC)) at the time of the rising clock transi-
tion), a valid input signal is still required to complete the transition and to reach
VIH/VIL(AC). For slew rates that fall between the values listed in Table 63 (page 92), Ta-
ble 64 (page 92), or Table 65 (page 93), the derating values may obtained by linear
interpolation.
Setup (tDS) nominal slew rate for a rising signal is defined as the slew rate between the
last crossing of VREF(DC) and the first crossing of VIH(AC)min. Setup (tDS) nominal slew
rate for a falling signal is defined as the slew rate between the last crossing of VREF(DC)
and the first crossing of VIL(AC)max. If the actual signal is always earlier than the nominal
slew rate line between the shaded VREF(DC)-to-AC region, use the nominal slew rate for
derating value (see Figure 34 (page 95)). If the actual signal is later than the nominal
slew rate line anywhere between the shaded VREF(DC)-to-AC region, the slew rate of a
tangent line to the actual signal from the AC level to the DC level is used for derating
value (see Figure 36 (page 97)).
Hold (tDH) nominal slew rate for a rising signal is defined as the slew rate between the
last crossing of VIL(DC)max and the first crossing of VREF(DC). Hold (tDH) nominal slew
rate for a falling signal is defined as the slew rate between the last crossing of VIH(DC)min
and the first crossing of VREF(DC). If the actual signal is always later than the nominal
slew rate line between the shaded DC-to-VREF(DC) region, use the nominal slew rate for
derating value (see Figure 35 (page 96)). If the actual signal is earlier than the nominal
slew rate line anywhere between the shaded DC-to-VREF(DC) region, the slew rate of a
tangent line to the actual signal from the DC-to-VREF(DC) region is used for derating val-
ue (see Figure 37 (page 98)).
Table 62: DDR3L Data Setup and Hold Values at 1 V/ns (DQS, DQS# at 2 V/ns) – AC/DC-Based
Symbol
800
1066
1333
1600
1866
2133
Unit
Reference
tDS (base) AC160
90
40
–
–
–
–
ps
VIH(AC)/VIL(AC)
tDS (base) AC135
140
90
45
25
–
–
ps
tDS (base) AC130
-
-
-
-
70
55
ps
tDH (base) DC90
160
110
75
55
–
–
ps
tDH (base) DC90
–
–
–
–
75
60
ps
Slew Rate Referenced
1
1
1
1
2
2
V/ns
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Data Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
91
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 92 -->

Table 63: DDR3L Derating Values for tDS/tDH – AC160/DC90-Based
ΔtDS, ΔtDH Derating (ps) – AC/DC-Based
DQ Slew
Rate V/ns
DQS, DQS# Differential Slew Rate
4.0 V/ns
3.0 V/ns
2.0 V/ns
1.8 V/ns
1.6 V/ns
1.4 V/ns
1.2 V/ns
1.0 V/ns
ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH
2.0
80
45
80
45
80
45
 
 
 
 
 
 
 
 
 
 
1.5
53
30
53
30
53
30
61
38
 
 
 
 
 
 
 
 
1.0
0
0
0
0
0
0
8
8
16
16
 
 
 
 
 
 
0.9
 
 
–1
–3
–1
–3
7
5
15
13
23
21
 
 
 
 
0.8
 
 
 
 
–3
–8
5
1
13
9
21
17
29
27
 
 
0.7
 
 
 
 
 
 
–3
–5
11
3
19
11
27
21
35
37
0.6
 
 
 
 
 
 
 
 
8
–4
16
4
24
14
32
30
0.5
 
 
 
 
 
 
 
 
 
 
4
6
12
4
20
20
0.4
 
 
 
 
 
 
 
 
 
 
 
 
–8
–11
0
5
Table 64: DDR3L Derating Values for tDS/tDH – AC135/DC90-Based
ΔtDS, ΔtDH Derating (ps) – AC/DC-Based
DQ Slew
Rate V/ns
DQS, DQS# Differential Slew Rate
4.0 V/ns
3.0 V/ns
2.0 V/ns
1.8 V/ns
1.6 V/ns
1.4 V/ns
1.2 V/ns
1.0 V/ns
ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH ΔtDS ΔtDH
2.0
68
45
68
45
68
45
 
 
 
 
 
 
 
 
 
 
1.5
45
30
45
30
45
30
53
38
 
 
 
 
 
 
 
 
1.0
0
0
0
0
0
0
8
8
16
16
 
 
 
 
 
 
0.9
 
 
2
–3
2
–3
10
5
18
13
26
21
 
 
 
 
0.8
 
 
 
 
3
–8
11
1
19
9
27
17
35
27
 
 
0.7
 
 
 
 
 
 
14
–5
22
3
30
11
38
21
46
37
0.6
 
 
 
 
 
 
 
 
25
–4
33
4
41
14
49
30
0.5
 
 
 
 
 
 
 
 
 
 
39
–6
37
4
45
20
0.4
 
 
 
 
 
 
 
 
 
 
 
 
30
–11
38
5
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Data Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
92
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 93 -->

Table 65: DDR3L Derating Values for tDS/tDH – AC130/DC90-Based at 2V/ns
Shaded cells indicate slew rate combinations not supported
ΔtDS, ΔtDH Derating (ps) – AC/DC-Based
DQ Slew Rate V/ns
DQS, DQS# Differential Slew Rate
8.0 V/ns
7.0 V/ns
6.0 V/ns
5.0 V/ns
4.0 V/ns
3.0 V/ns
2.0 V/ns
1.8 V/ns
1.6 V/ns
1.4 V/ns
1.2 V/ns
1.0 V/ns
Δ
tDS
Δ
tDH
Δ
tDS
Δ
tDH
Δ
tDS
Δ
tDH
Δ
tDS
Δ
tDH
Δ
tDS
Δ
tDH
Δ
tDS
Δ
tDH
Δ
tDS
Δ
tDH
Δ
tDS
Δ
tDH
Δ
tDS
Δ
tDH
Δ
tDS
Δ
tDH
Δ
tDS
Δ
tDH
Δ
tDS
Δ
tDH
4.0
33
23
33
23
33
23
3.5
28
19
28
19
28
19
28
19
3.0
22
15
22
15
22
15
22
15
22
15
2.5
13
9
13
9
13
9
13
9
13
9
2.0
0
0
0
0
0
0
0
0
0
0
1.5
–22
–15
–22
–15
–22
–15
–22
–15
–14
–7
1.0
–65
–45
–65
–45
–65
–45
–57
–37
–49
–29
0.9
–62
–48
–62
–48
–54
–40
–46
–32
–38
–24
0.8
–61
–53
–53
–45
–45
–37
–37
–29
–29
–19
0.7
–49
–50
–41
-42
–33
–34
–25
–24
–17
–8
0.6
–37
-49
–29
–41
–21
–31
–13
–15
0.5
–31
–51
–23
–41
–15
–25
0.4
–28
–56
–20
–40
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Data Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
93
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 94 -->

Table 66: DDR3L Minimum Required Time tVAC Above VIH(AC) (Below VIL(AC)) for Valid DQ Transition
Slew Rate (V/ns)
DDR3L-800/1066 160mV
(ps) min
DDR3L-800/1066/1333
135mV (ps) min
DDR3L-1866/2133
130mV (ps) min
>2.0
165
113
95
2.0
165
113
95
1.5
138
90
73
1.0
85
45
30
0.9
67
30
16
0.8
45
11
Note 1
0.7
16
Note 1
–
0.6
Note 1
Note 1
–
0.5
Note 1
Note 1
–
<0.5
Note 1
Note 1
–
Note:
1. Rising input signal shall become equal to or greater than VIH(AC) level and Falling input
signal shall become equal to or less than VIL(AC) level.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Data Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
94
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 95 -->

Figure 34: Nominal Slew Rate and tVAC for tDS (DQ – Strobe)
VSS
Setup slew rate
rising signal
Setup slew rate
falling signal
ΔTF
ΔTR
=
=
VDDQ
VIH(AC)min
VIH(DC)min
VREF(DC)
VIL(DC)max
VIL(AC)max
Nominal
slew rate
VREF to AC
 region
tVAC
tVAC
tDH
tDS
DQS
DQS#
tDH
tDS
CK#
CK
VREF to AC
 region
Nominal
slew rate
VIH(AC)min - VREF(DC)
ΔTR
VREF(DC) - VIL(AC)max
ΔTF
Note:
1. The clock and the strobe are drawn on different time scales.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Data Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
95
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 96 -->

Figure 35: Nominal Slew Rate for tDH (DQ – Strobe)
VSS
Hold slew rate
falling signal
Hold slew rate
rising signal
=
=
VDDQ
VIH(AC)min
VIH(DC)min
VREF(DC)
VIL(DC)max
VIL(AC)max
Nominal 
slew rate
DC to VREF
region
tDH
tDS
DQS
DQS#
tDH
tDS
CK#
CK
DC to VREF
region
Nominal 
slew rate
VREF(DC) - VIL(DC)max
VIL(DC)min - VREF(DC)
ΔTR
ΔTF
ΔTF
ΔTR
Note:
1. The clock and the strobe are drawn on different time scales.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Data Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
96
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 97 -->

Figure 36: Tangent Line for tDS (DQ – Strobe)
VSS
Setup slew rate
rising signal
Setup slew rate
falling signal
=
=
VDDQ
VIH(AC)min
VIH(DC)min
VREF(DC)
VIL(DC)max
VIL(AC)max
Tangent
line
VREF to AC
region
Nominal
line
tVAC
tVAC
tDH
tDS
DQS
DQS#
tDH
tDS
CK#
CK
VREF to AC
region
Tangent
line
Nominal
line
Tangent line (VREF(DC) - VIL(AC)max)
Tangent line (VIH(AC)min - VREF(DC))
ΔTR
ΔTR
ΔTF
ΔTF
Note:
1. The clock and the strobe are drawn on different time scales.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Data Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
97
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 98 -->

Figure 37: Tangent Line for tDH (DQ – Strobe)
VSS
Hold slew rate
falling signal
ΔTF
ΔTR
=
VDDQ
VIH(AC)min
VIH(DC)min
VREF(DC)
VIL(DC)max
VIL(AC)max
Tangent
line
DC to VREF
region
Hold slew rate
rising signal
=
DQS
DQS#
CK#
CK
DC to VREF
region
Tangent
line
Nominal
line
Nominal
line
Tangent line (VIH(DC)min - VREF(DC))
ΔTF
Tangent line (VREF(DC) - VIL(DC)max)
ΔTR
tDS
tDH
tDS
tDH
Note:
1. The clock and the strobe are drawn on different time scales.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Data Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
98
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

