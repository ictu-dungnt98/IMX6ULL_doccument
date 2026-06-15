# Electrical Specifications – IDD Specifications and Conditions

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 28–38

<!-- page 28 -->

Electrical Specifications – IDD Specifications and Conditions
Within the following IDD measurement tables, the following definitions and conditions
are used, unless stated otherwise:
• LOW: VIN ≤ VIL(AC)max; HIGH: VIN ≥ VIH(AC)min.
• Midlevel: Inputs are VREF = VDD/2.
• RON set to RZQ/7 (34Ω).
• RTT,nom set to RZQ/6 (40Ω).
• RTT(WR) set to RZQ/2 (120Ω).
• QOFF is enabled in MR1.
• ODT is enabled in MR1 (RTT,nom) and MR2 (RTT(WR)).
• TDQS is disabled in MR1.
• External DQ/DQS/DM load resistor is 25Ω to VDDQ/2.
• Burst lengths are BL8 fixed.
• AL equals 0 (except in IDD7).
• IDD specifications are tested after the device is properly initialized.
• Input slew rate is specified by AC parametric test conditions.
• Optional ASR is disabled.
• Read burst type uses nibble sequential (MR0[3] = 0).
• Loop patterns must be executed at least once before current measurements begin.
Table 9: Timing Parameters Used for IDD Measurements – Clock Units
IDD
Parameter
DDR3L-800
DDR3L-1066
DDR3L-1333
DDR3L-1600
DDR3L
-1866
DDR3L
-2133
Unit
-25E
-25
-187E
-187
-15E
-15
-125E
-125
-107
-093
5-5-5
6-6-6
7-7-7
8-8-8
9-9-9
10-10-10 10-10-10 11-11-11 13-13-13 14-14-14
tCK (MIN) IDD
2.5
1.875
1.5
1.25
1.07
0.938
ns
CL IDD
5
6
7
8
9
10
10
11
13
14
CK
tRCD (MIN) IDD
5
6
7
8
9
10
10
11
13
14
CK
tRC (MIN) IDD
20
21
27
28
33
34
38
39
45
50
CK
tRAS (MIN) IDD
15
15
20
20
24
24
28
28
32
36
CK
tRP (MIN)
5
6
7
8
9
10
10
11
13
14
CK
tFAW
x4, x8
16
16
20
20
20
20
24
24
26
27
CK
x16
20
20
27
27
30
30
32
32
33
38
CK
tRRD
IDD
x4, x8
4
4
4
4
4
4
5
5
5
6
CK
x16
4
4
6
6
5
5
6
6
6
7
CK
tRFC
1Gb
44
44
59
59
74
74
88
88
103
118
CK
2Gb
64
64
86
86
107
107
128
128
150
172
CK
4Gb
104
104
139
139
174
174
208
208
243
279
CK
8Gb
140
140
187
187
234
234
280
280
328
375
CK
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – IDD Specifications and Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
28
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 29 -->

Table 10: IDD0 Measurement Loop
CK, CK#
CKE
Sub-
Loop
Cycle
Number
Command
CS#
RAS#
CAS#
WE#
ODT
BA[2:0]
A[15:11]
A[10]
A[9:7]
A[6:3]
A[2:0]
Data
Toggling
Static HIGH
0
0
ACT
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
–
1
D
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
–
2
D
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
–
3
D#
1
1
1
1
0
0
0
0
0
0
0
–
4
D#
1
1
1
1
0
0
0
0
0
0
0
–
 
Repeat cycles 1 through 4 until nRAS - 1; truncate if needed
nRAS
PRE
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
–
 
Repeat cycles 1 through 4 until nRC - 1; truncate if needed
nRC
ACT
0
0
1
1
0
0
0
0
0
F
0
–
nRC + 1
D
1
0
0
0
0
0
0
0
0
F
0
–
nRC + 2
D
1
0
0
0
0
0
0
0
0
F
0
–
nRC + 3
D#
1
1
1
1
0
0
0
0
0
F
0
–
nRC + 4
D#
1
1
1
1
0
0
0
0
0
F
0
–
 
Repeat cycles nRC + 1 through nRC + 4 until nRC - 1 + nRAS -1; truncate if needed
nRC + nRAS
PRE
0
0
1
0
0
0
0
0
0
F
0
–
 
Repeat cycles nRC + 1 through nRC + 4 until 2 × RC - 1; truncate if needed
1
2 × nRC
Repeat sub-loop 0, use BA[2:0] = 1
2
4 × nRC
Repeat sub-loop 0, use BA[2:0] = 2
3
6 × nRC
Repeat sub-loop 0, use BA[2:0] = 3
4
8 × nRC
Repeat sub-loop 0, use BA[2:0] = 4
5
10 × nRC
Repeat sub-loop 0, use BA[2:0] = 5
6
12 × nRC
Repeat sub-loop 0, use BA[2:0] = 6
7
14 × nRC
Repeat sub-loop 0, use BA[2:0] = 7
Notes:
1. DQ, DQS, DQS# are midlevel.
2. DM is LOW.
3. Only selected bank (single) active.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – IDD Specifications and Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
29
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 30 -->

Table 11: IDD1 Measurement Loop
CK, CK#
CKE
Sub-Loop
Cycle
Number
Command
CS#
RAS#
CAS#
WE#
ODT
BA[2:0]
A[15:11]
A[10]
A[9:7]
A[6:3]
A[2:0]
Data2
Toggling
Static HIGH
0
0
ACT
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
–
1
D
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
–
2
D
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
–
3
D#
1
1
1
1
0
0
0
0
0
0
0
–
4
D#
1
1
1
1
0
0
0
0
0
0
0
–
 
Repeat cycles 1 through 4 until nRCD - 1; truncate if needed
nRCD
RD
0
1
0
1
0
0
0
0
0
0
0
00000000
 
Repeat cycles 1 through 4 until nRAS - 1; truncate if needed
nRAS
PRE
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
–
 
Repeat cycles 1 through 4 until nRC - 1; truncate if needed
nRC
ACT
0
0
1
1
0
0
0
0
0
F
0
–
nRC + 1
D
1
0
0
0
0
0
0
0
0
F
0
–
nRC + 2
D
1
0
0
0
0
0
0
0
0
F
0
–
nRC + 3
D#
1
1
1
1
0
0
0
0
0
F
0
–
nRC + 4
D#
1
1
1
1
0
0
0
0
0
F
0
–
 
Repeat cycles nRC + 1 through nRC + 4 until nRC + nRCD - 1; truncate if needed
nRC + nRCD
RD
0
1
0
1
0
0
0
0
0
F
0
00110011
 
Repeat cycles nRC + 1 through nRC + 4 until nRC + nRAS - 1; truncate if needed
nRC + nRAS
PRE
0
0
1
0
0
0
0
0
0
F
0
–
 
Repeat cycle nRC + 1 through nRC + 4 until 2 × nRC - 1; truncate if needed
1
2 × nRC
Repeat sub-loop 0, use BA[2:0] = 1
2
4 × nRC
Repeat sub-loop 0, use BA[2:0] = 2
3
6 × nRC
Repeat sub-loop 0, use BA[2:0] = 3
4
8 × nRC
Repeat sub-loop 0, use BA[2:0] = 4
5
10 × nRC
Repeat sub-loop 0, use BA[2:0] = 5
6
12 × nRC
Repeat sub-loop 0, use BA[2:0] = 6
7
14 × nRC
Repeat sub-loop 0, use BA[2:0] = 7
Notes:
1. DQ, DQS, DQS# are midlevel unless driven as required by the RD command.
2. DM is LOW.
3. Burst sequence is driven on each DQ signal by the RD command.
4. Only selected bank (single) active.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – IDD Specifications and Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
30
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 31 -->

Table 12: IDD Measurement Conditions for Power-Down Currents
Name
IDD2P0 Precharge
Power-Down
Current (Slow Exit)1
IDD2P1 Precharge
Power-Down
Current (Fast Exit)1
IDD2Q Precharge
Quiet
Standby Current
IDD3P Active
Power-Down
Current
Timing pattern
N/A
N/A
N/A
N/A
CKE
LOW
LOW
HIGH
LOW
External clock
Toggling
Toggling
Toggling
Toggling
tCK
tCK (MIN) IDD
tCK (MIN) IDD
tCK (MIN) IDD
tCK (MIN) IDD
tRC
N/A
N/A
N/A
N/A
tRAS
N/A
N/A
N/A
N/A
tRCD
N/A
N/A
N/A
N/A
tRRD
N/A
N/A
N/A
N/A
tRC
N/A
N/A
N/A
N/A
CL
N/A
N/A
N/A
N/A
AL
N/A
N/A
N/A
N/A
CS#
HIGH
HIGH
HIGH
HIGH
Command inputs
LOW
LOW
LOW
LOW
Row/column addr
LOW
LOW
LOW
LOW
Bank addresses
LOW
LOW
LOW
LOW
DM
LOW
LOW
LOW
LOW
Data I/O
Midlevel
Midlevel
Midlevel
Midlevel
Output buffer DQ, DQS
Enabled
Enabled
Enabled
Enabled
ODT2
Enabled, off
Enabled, off
Enabled, off
Enabled, off
Burst length
8
8
8
8
Active banks
None
None
None
All
Idle banks
All
All
All
None
Special notes
N/A
N/A
N/A
N/A
Notes:
1. MR0[12] defines DLL on/off behavior during precharge power-down only; DLL on (fast
exit, MR0[12] = 1) and DLL off (slow exit, MR0[12] = 0).
2. “Enabled, off” means the MR bits are enabled, but the signal is LOW.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – IDD Specifications and Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
31
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 32 -->

Table 13: IDD2N and IDD3N Measurement Loop
CK, CK#
CKE
Sub-Loop
Cycle
Number
Command
CS#
RAS#
CAS#
WE#
ODT
BA[2:0]
A[15:11]
A[10]
A[9:7]
A[6:3]
A[2:0]
Data
Toggling
Static HIGH
0
0
D
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
–
1
D
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
–
2
D#
1
1
1
1
0
0
0
0
0
F
0
–
3
D#
1
1
1
1
0
0
0
0
0
F
0
–
1
4–7
Repeat sub-loop 0, use BA[2:0] = 1
2
8–11
Repeat sub-loop 0, use BA[2:0] = 2
3
12–15
Repeat sub-loop 0, use BA[2:0] = 3
4
16–19
Repeat sub-loop 0, use BA[2:0] = 4
5
20–23
Repeat sub-loop 0, use BA[2:0] = 5
6
24–27
Repeat sub-loop 0, use BA[2:0] = 6
7
28–31
Repeat sub-loop 0, use BA[2:0] = 7
Notes:
1. DQ, DQS, DQS# are midlevel.
2. DM is LOW.
3. All banks closed during IDD2N; all banks open during IDD3N.
Table 14: IDD2NT Measurement Loop
CK, CK#
CKE
Sub-Loop
Cycle
Number
Command
CS#
RAS#
CAS#
WE#
ODT
BA[2:0]
A[15:11]
A[10]
A[9:7]
A[6:3]
A[2:0]
Data
Toggling
Static HIGH
0
0
D
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
–
1
D
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
–
2
D#
1
1
1
1
0
0
0
0
0
F
0
–
3
D#
1
1
1
1
0
0
0
0
0
F
0
–
1
4–7
Repeat sub-loop 0, use BA[2:0] = 1; ODT = 0
2
8–11
Repeat sub-loop 0, use BA[2:0] = 2; ODT = 1
3
12–15
Repeat sub-loop 0, use BA[2:0] = 3; ODT = 1
4
16–19
Repeat sub-loop 0, use BA[2:0] = 4; ODT = 0
5
20–23
Repeat sub-loop 0, use BA[2:0] = 5; ODT = 0
6
24–27
Repeat sub-loop 0, use BA[2:0] = 6; ODT = 1
7
28–31
Repeat sub-loop 0, use BA[2:0] = 7; ODT = 1
Notes:
1. DQ, DQS, DQS# are midlevel.
2. DM is LOW.
3. All banks closed.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – IDD Specifications and Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
32
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 33 -->

Table 15: IDD4R Measurement Loop
CK, CK#
CKE
Sub-Loop
Cycle
Number
Command
CS#
RAS#
CAS#
WE#
ODT
BA[2:0]
A[15:11]
A[10]
A[9:7]
A[6:3]
A[2:0]
Data3
Toggling
Static HIGH
0
0
RD
0
1
0
1
0
0
0
0
0
0
0
00000000
1
D
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
–
2
D#
1
1
1
1
0
0
0
0
0
0
0
–
3
D#
1
1
1
1
0
0
0
0
0
0
0
–
4
RD
0
1
0
1
0
0
0
0
0
F
0
00110011
5
D
1
0
0
0
0
0
0
0
0
F
0
–
6
D#
1
1
1
1
0
0
0
0
0
F
0
–
7
D#
1
1
1
1
0
0
0
0
0
F
0
–
1
8–15
Repeat sub-loop 0, use BA[2:0] = 1
2
16–23
Repeat sub-loop 0, use BA[2:0] = 2
3
24–31
Repeat sub-loop 0, use BA[2:0] = 3
4
32–39
Repeat sub-loop 0, use BA[2:0] = 4
5
40–47
Repeat sub-loop 0, use BA[2:0] = 5
6
48–55
Repeat sub-loop 0, use BA[2:0] = 6
7
56–63
Repeat sub-loop 0, use BA[2:0] = 7
Notes:
1. DQ, DQS, DQS# are midlevel when not driving in burst sequence.
2. DM is LOW.
3. Burst sequence is driven on each DQ signal by the RD command.
4. All banks open.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – IDD Specifications and Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
33
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 34 -->

Table 16: IDD4W Measurement Loop
CK, CK#
CKE
Sub-Loop
Cycle
Number
Command
CS#
RAS#
CAS#
WE#
ODT
BA[2:0]
A[15:11]
A[10]
A[9:7]
A[6:3]
A[2:0]
Data3
Toggling
Static HIGH
0
0
WR
0
1
0
0
1
0
0
0
0
0
0
00000000
1
D
1
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
–
2
D#
1
1
1
1
1
0
0
0
0
0
0
–
3
D#
1
1
1
1
1
0
0
0
0
0
0
–
4
WR
0
1
0
0
1
0
0
0
0
F
0
00110011
5
D
1
0
0
0
1
0
0
0
0
F
0
–
6
D#
1
1
1
1
1
0
0
0
0
F
0
–
7
D#
1
1
1
1
1
0
0
0
0
F
0
–
1
8–15
Repeat sub-loop 0, use BA[2:0] = 1
2
16–23
Repeat sub-loop 0, use BA[2:0] = 2
3
24–31
Repeat sub-loop 0, use BA[2:0] = 3
4
32–39
Repeat sub-loop 0, use BA[2:0] = 4
5
40–47
Repeat sub-loop 0, use BA[2:0] = 5
6
48–55
Repeat sub-loop 0, use BA[2:0] = 6
7
56–63
Repeat sub-loop 0, use BA[2:0] = 7
Notes:
1. DQ, DQS, DQS# are midlevel when not driving in burst sequence.
2. DM is LOW.
3. Burst sequence is driven on each DQ signal by the WR command.
4. All banks open.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – IDD Specifications and Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
34
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 35 -->

Table 17: IDD5B Measurement Loop
CK, CK#
CKE
Sub-Loop
Cycle
Number
Command
CS#
RAS#
CAS#
WE#
ODT
BA[2:0]
A[15:11]
A[10]
A[9:7]
A[6:3]
A[2:0]
Data
Toggling
Static HIGH
0
0
REF
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
–
1a
1
D
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
–
2
D
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
–
3
D#
1
1
1
1
0
0
0
0
0
F
0
–
4
D#
1
1
1
1
0
0
0
0
0
F
0
–
1b
5–8
Repeat sub-loop 1a, use BA[2:0] = 1
1c
9–12
Repeat sub-loop 1a, use BA[2:0] = 2
1d
13–16
Repeat sub-loop 1a, use BA[2:0] = 3
1e
17–20
Repeat sub-loop 1a, use BA[2:0] = 4
1f
21–24
Repeat sub-loop 1a, use BA[2:0] = 5
1g
25–28
Repeat sub-loop 1a, use BA[2:0] = 6
1h
29–32
Repeat sub-loop 1a, use BA[2:0] = 7
2
33–nRFC - 1
Repeat sub-loop 1a through 1h until nRFC - 1; truncate if needed
Notes:
1. DQ, DQS, DQS# are midlevel.
2. DM is LOW.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – IDD Specifications and Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
35
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 36 -->

Table 18: IDD Measurement Conditions for IDD6, IDD6ET, and IDD8
IDD Test
IDD6: Self Refresh Current
Normal Temperature Range
TC = 0°C to +85°C
IDD6ET: Self Refresh Current
Extended Temperature Range
TC = 0°C to +95°C
IDD8: Reset2
CKE
LOW
LOW
Midlevel
External clock
Off, CK and CK# = LOW
Off, CK and CK# = LOW
Midlevel
tCK
N/A
N/A
N/A
tRC
N/A
N/A
N/A
tRAS
N/A
N/A
N/A
tRCD
N/A
N/A
N/A
tRRD
N/A
N/A
N/A
tRC
N/A
N/A
N/A
CL
N/A
N/A
N/A
AL
N/A
N/A
N/A
CS#
Midlevel
Midlevel
Midlevel
Command inputs
Midlevel
Midlevel
Midlevel
Row/column addresses
Midlevel
Midlevel
Midlevel
Bank addresses
Midlevel
Midlevel
Midlevel
Data I/O
Midlevel
Midlevel
Midlevel
Output buffer DQ, DQS
Enabled
Enabled
Midlevel
ODT1
Enabled, midlevel
Enabled, midlevel
Midlevel
Burst length
N/A
N/A
N/A
Active banks
N/A
N/A
None
Idle banks
N/A
N/A
All
SRT
Disabled (normal)
Enabled (extended)
N/A
ASR
Disabled
Disabled
N/A
Notes:
1. “Enabled, midlevel” means the MR command is enabled, but the signal is midlevel.
2. During a cold boot RESET (initialization), current reading is valid after power is stable
and RESET has been LOW for 1ms; During a warm boot RESET (while operating), current
reading is valid after RESET has been LOW for 200ns + tRFC.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – IDD Specifications and Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
36
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 37 -->

Table 19: IDD7 Measurement Loop
CK, CK#
CKE
Sub-Loop
Cycle
Number
Command
CS#
RAS#
CAS#
WE#
ODT
BA[2:0]
A[15:11]
A[10]
A[9:7]
A[6:3]
A[2:0]
Data3
Toggling
Static HIGH
0
0
ACT
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
–
1
RDA
0
1
0
1
0
0
0
1
0
0
0
00000000
2
D
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
–
3
Repeat cycle 2 until nRRD - 1
1
nRRD
ACT
0
0
1
1
0
1
0
0
0
F
0
–
nRRD + 1
RDA
0
1
0
1
0
1
0
1
0
F
0
00110011
nRRD + 2
D
1
0
0
0
0
1
0
0
0
F
0
–
nRRD + 3
Repeat cycle nRRD + 2 until 2 × nRRD - 1
2
2 × nRRD
Repeat sub-loop 0, use BA[2:0] = 2
3
3 × nRRD
Repeat sub-loop 1, use BA[2:0] = 3
4
4 × nRRD
D
1
0
0
0
0
3
0
0
0
F
0
–
4 × nRRD + 1
Repeat cycle 4 × nRRD until nFAW - 1, if needed
5
nFAW
Repeat sub-loop 0, use BA[2:0] = 4
6
nFAW + nRRD
Repeat sub-loop 1, use BA[2:0] = 5
7
nFAW + 2 × nRRD
Repeat sub-loop 0, use BA[2:0] = 6
8
nFAW + 3 × nRRD
Repeat sub-loop 1, use BA[2:0] = 7
9
nFAW + 4 × nRRD
D
1
0
0
0
0
7
0
0
0
F
0
–
nFAW + 4 × nRRD + 1
Repeat cycle nFAW + 4 × nRRD until 2 × nFAW - 1, if needed
10
2 × nFAW
ACT
0
0
1
1
0
0
0
0
0
F
0
–
2 × nFAW + 1
RDA
0
1
0
1
0
0
0
1
0
F
0
00110011
2 × nFAW + 2
D
1
0
0
0
0
0
0
0
0
F
0
–
2 × nFAW + 3
Repeat cycle 2 × nFAW + 2 until 2 × nFAW + nRRD - 1
11
2 × nFAW + nRRD
ACT
0
0
1
1
0
1
0
0
0
0
0
–
2 × nFAW + nRRD + 1
RDA
0
1
0
1
0
1
0
1
0
0
0
00000000
2 × nFAW + nRRD + 2
D
1
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
–
2 × nFAW + nRRD + 3
Repeat cycle 2 × nFAW + nRRD + 2 until 2 × nFAW + 2 × nRRD - 1
12
2 × nFAW + 2 × nRRD
Repeat sub-loop 10, use BA[2:0] = 2
13
2 × nFAW + 3 × nRRD
Repeat sub-loop 11, use BA[2:0] = 3
14
2 × nFAW + 4 × nRRD
D
1
0
0
0
0
3
0
0
0
0
0
–
2 × nFAW + 4 × nRRD + 1
Repeat cycle 2 × nFAW + 4 × nRRD until 3 × nFAW - 1, if needed
15
3 × nFAW
Repeat sub-loop 10, use BA[2:0] = 4
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – IDD Specifications and Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
37
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 38 -->

Table 19: IDD7 Measurement Loop (Continued)
CK, CK#
CKE
Sub-Loop
Cycle
Number
Command
CS#
RAS#
CAS#
WE#
ODT
BA[2:0]
A[15:11]
A[10]
A[9:7]
A[6:3]
A[2:0]
Data3
Toggling
Static HIGH
16
3 × nFAW + nRRD
Repeat sub-loop 11, use BA[2:0] = 5
17
3 × nFAW + 2 × nRRD
Repeat sub-loop 10, use BA[2:0] = 6
18
3 × nFAW + 3 × nRRD
Repeat sub-loop 11, use BA[2:0] = 7
19
3 × nFAW + 4 × nRRD
D
1
0
0
0
0
7
0
0
0
0
0
–
3 × nFAW + 4 × nRRD + 1
Repeat cycle 3 × nFAW + 4 × nRRD until 4 × nFAW - 1, if needed
Notes:
1. DQ, DQS, DQS# are midlevel unless driven as required by the RD command.
2. DM is LOW.
3. Burst sequence is driven on each DQ signal by the RD command.
4. AL = CL-1.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – IDD Specifications and Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
38
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

