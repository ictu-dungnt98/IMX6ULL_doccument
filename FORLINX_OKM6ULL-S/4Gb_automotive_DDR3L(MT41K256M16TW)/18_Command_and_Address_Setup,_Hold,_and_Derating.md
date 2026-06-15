# Command and Address Setup, Hold, and Derating

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 84–90

<!-- page 84 -->

Command and Address Setup, Hold, and Derating
The total tIS (setup time) and tIH (hold time) required is calculated by adding the data
sheet tIS (base) and tIH (base) values (see Table 57; values come from the Electrical
Characteristics and AC Operating Conditions table) to the ΔtIS and ΔtIH derating values
(see Table 58 (page 85), Table 59 (page 85) or Table 60 (page 85)) respectively. Ex-
ample: tIS (total setup time) = tIS (base) + ΔtIS. For a valid transition, the input signal
has to remain above/below VIH(AC)/VIL(AC) for some time tVAC (see Table 61 (page 86)).
Although the total setup time for slow slew rates might be negative (for example, a valid
input signal will not have reached VIH(AC)/VIL(AC) at the time of the rising clock transi-
tion), a valid input signal is still required to complete the transition and to reach
VIH(AC)/VIL(AC) (see Figure 11 (page 45) for input signal requirements). For slew rates that
fall between the values listed in Table 58 (page 85) and Table 60 (page 85), the derat-
ing values may be obtained by linear interpolation.
Setup (tIS) nominal slew rate for a rising signal is defined as the slew rate between the
last crossing of VREF(DC) and the first crossing of VIH(AC)min. Setup (tIS) nominal slew rate
for a falling signal is defined as the slew rate between the last crossing of VREF(DC) and
the first crossing of VIL(AC)max. If the actual signal is always earlier than the nominal slew
rate line between the shaded VREF(DC)-to-AC region, use the nominal slew rate for derat-
ing value (see Figure 30 (page 87)). If the actual signal is later than the nominal slew
rate line anywhere between the shaded VREF(DC)-to-AC region, the slew rate of a tangent
line to the actual signal from the AC level to the DC level is used for derating value (see 
Figure 32 (page 89)).
Hold (tIH) nominal slew rate for a rising signal is defined as the slew rate between the
last crossing of VIL(DC)max and the first crossing of VREF(DC). Hold (tIH) nominal slew rate
for a falling signal is defined as the slew rate between the last crossing of VIH(DC)min and
the first crossing of VREF(DC). If the actual signal is always later than the nominal slew
rate line between the shaded DC-to-VREF(DC) region, use the nominal slew rate for derat-
ing value (see Figure 31 (page 88)). If the actual signal is earlier than the nominal slew
rate line anywhere between the shaded DC-to-VREF(DC) region, the slew rate of a tangent
line to the actual signal from the DC level to the VREF(DC) level is used for derating value
(see Figure 33 (page 90)).
Table 57: DDR3L Command and Address Setup and Hold Values 1 V/ns Referenced – AC/DC-Based
Symbol
800
1066
1333
1600
1866
2133
Unit
Reference
tIS(base, AC160)
215
140
80
60
–
–
ps
VIH(AC)/VIL(AC)
tIS(base, AC135)
365
290
205
185
65
60
ps
VIH(AC)/VIL(AC)
tIS(base, AC125)
–
–
–
–
150
135
ps
VIH(AC)/VIL(AC)
tIH(base, DC90)
285
210
150
130
110
105
ps
VIH(DC)/VIL(DC)
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Command and Address Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
84
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 85 -->

Table 58: DDR3L-800/1066 Derating Values tIS/tIH – AC160/DC90-Based
ΔtIS, ΔtIH Derating (ps) – AC/DC-Based
CMD/ADDR
Slew Rate
V/ns
CK, CK# Differential Slew Rate
4.0 V/ns
3.0 V/ns
2.0 V/ns
1.8 V/ns
1.6 V/ns
1.4 V/ns
1.2 V/ns
1.0 V/ns
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
2.0
80
45
80
45
80
45
88
53
96
61
104
69
112
79
120
95
1.5
53
30
53
30
53
30
61
38
69
46
77
54
85
64
93
80
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
24
24
32
34
40
50
0.9
–1
–3
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
31
31
39
47
0.8
–3
–8
–3
–8
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
37
43
0.7
–5
–13
–5
–13
–5
–13
3
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
–8
–20
–8
–20
–8
–20
0
–12
8
–4
16
4
24
14
32
30
0.5
–20
–30
–20
–30
–20
–30
–12
–22
–4
–14
4
–6
12
4
20
20
0.4
–40
–45
–40
–45
–40
–45
–32
–37
–24
–29
–16
–21
–8
–11
0
5
Table 59: DDR3L-800/1066/1333/1600 Derating Values for tIS/tIH – AC135/DC90-Based
ΔtIS, ΔtIH Derating (ps) – AC/DC-Based
CMD/ADDR
Slew Rate
V/ns
CK, CK# Differential Slew Rate
4.0 V/ns
3.0 V/ns
2.0 V/ns
1.8 V/ns
1.6 V/ns
1.4 V/ns
1.2 V/ns
1.0 V/ns
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
2.0
68
45
68
45
68
45
76
53
84
61
92
69
100
79
108
95
1.5
45
30
45
30
45
30
53
38
61
46
69
54
77
64
85
80
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
24
24
32
34
40
50
0.9
2
–3
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
34
31
42
47
0.8
3
–8
3
–8
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
43
43
0.7
6
–13
6
–13
6
–13
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
9
–20
9
–20
9
–20
17
–12
25
–4
33
4
41
14
49
30
0.5
5
–30
5
–30
5
–30
13
–22
21
–14
29
–6
37
4
45
20
0.4
–3
–45
–3
–45
–3
–45
6
–37
14
–29
22
–21
30
–11
38
5
Table 60: DDR3L-1866/2133 Derating Values for tIS/tIH – AC125/DC90-Based
ΔtIS, ΔtIH Derating (ps) – AC/DC-Based
CMD/ADDR
Slew Rate
V/ns
CK, CK# Differential Slew Rate
4.0 V/ns
3.0 V/ns
2.0 V/ns
1.8 V/ns
1.6 V/ns
1.4 V/ns
1.2 V/ns
1.0 V/ns
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
2.0
63
45
63
45
63
45
71
53
79
61
87
69
95
79
103
95
1.5
42
30
42
30
42
30
50
38
58
46
66
54
74
64
82
80
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Command and Address Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
85
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 86 -->

Table 60: DDR3L-1866/2133 Derating Values for tIS/tIH – AC125/DC90-Based (Continued)
ΔtIS, ΔtIH Derating (ps) – AC/DC-Based
CMD/ADDR
Slew Rate
V/ns
CK, CK# Differential Slew Rate
4.0 V/ns
3.0 V/ns
2.0 V/ns
1.8 V/ns
1.6 V/ns
1.4 V/ns
1.2 V/ns
1.0 V/ns
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
ΔtIS
ΔtIH
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
24
24
32
34
40
50
0.9
3
–3
3
–3
3
–3
11
5
19
13
27
21
35
31
43
47
0.8
6
–8
6
–8
6
–8
14
1
22
9
30
17
38
27
46
43
0.7
10
–13
10
–13
10
–13
18
–5
26
3
34
11
42
21
50
37
0.6
16
–20
16
–20
16
–20
24
–12
32
–4
40
4
48
14
56
30
0.5
15
–30
15
–30
15
–30
23
–22
31
–14
39
–6
47
4
55
20
0.4
13
–45
13
–45
13
–45
21
–37
29
–29
37
–21
45
–11
53
5
Table 61: DDR3L Minimum Required Time tVAC Above VIH(AC) (Below VIL[AC]) for Valid ADD/CMD
Transition
Slew Rate (V/ns)
DDR3L-800/1066/1333/1600
DDR3L-1866/2133
tVAC at 160mV (ps) tVAC at 135mV (ps) tVAC at 135mV (ps) tVAC at 125mV (ps)
>2.0
200
213
200
205
2.0
200
213
200
205
1.5
173
190
178
184
1.0
120
145
133
143
0.9
102
130
118
129
0.8
80
111
99
111
0.7
51
87
75
89
0.6
13
55
43
59
0.5
Note 1
10
Note 1
18
<0.5
Note 1
10
Note 1
18
Note:
1. Rising input signal shall become equal to or greater than VIH(AC) level and Falling input
signal shall become equal to or less than VIL(AC) level.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Command and Address Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
86
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 87 -->

Figure 30: Nominal Slew Rate and tVAC for tIS (Command and Address – Clock)
VSS
Setup slew rate
rising signal
Setup slew rate
falling signal
∆TF
∆TR
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
DQS
DQS#
CK#
CK
tIS
tIH
tIS
tIH
Nominal
slew rate
VREF to AC
region
VREF(DC) - VIL(AC)max
∆TF
VIH(AC)min - VREF(DC)
∆TR
Note:
1. The clock and the strobe are drawn on different time scales.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Command and Address Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
87
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 88 -->

Figure 31: Nominal Slew Rate for tIH (Command and Address – Clock)
VSS
Hold slew rate
falling signal
Hold slew rate
rising signal 
ΔTR
ΔTF
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
DQS
DQS#
CK#
CK
tIS
tIH
tIS
tIH
DC to VREF
region
Nominal
slew rate
VREF(DC) - VIL(DC)max
ΔTR
VIH(DC)min - VREF(DC)
ΔTF
Note:
1. The clock and the strobe are drawn on different time scales.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Command and Address Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
88
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 89 -->

Figure 32: Tangent Line for tIS (Command and Address – Clock)
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
DQS
DQS#
CK#
CK
tIS
tIH
tIS
tIH
VREF to AC
region
Tangent
line
Nominal
line
Tangent line (VIH(DC)min - VREF(DC))
Tangent line (VREF(DC) - VIL(AC)max)
∆TR
∆TR
∆TF
∆TF
Note:
1. The clock and the strobe are drawn on different time scales.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Command and Address Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
89
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 90 -->

Figure 33: Tangent Line for tIH (Command and Address – Clock)
VSS
Hold slew rate
falling signal
=
VDDQ
 VIH(AC)min
VIH(DC)min
VREF(DC)
VIL(DC)max
VIL(AC)max
Tangen t
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
tIS
tIH
tIS
tIH
DC to VREF
region
Tangen t
line
Nominal
line
Nominal
line
Tangent line (VREF(DC) - VIL(DC)max)
Tangent line (VIH(DC)min - VREF(DC))
ΔTR
ΔTR
ΔTR
ΔTF
Note:
1. The clock and the strobe are drawn on different time scales.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Command and Address Setup, Hold, and Derating
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
90
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

