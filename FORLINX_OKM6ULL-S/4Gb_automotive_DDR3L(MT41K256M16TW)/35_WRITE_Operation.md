# WRITE Operation

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 156–165

<!-- page 156 -->

WRITE Operation
WRITE bursts are initiated with a WRITE command. The starting column and bank ad-
dresses are provided with the WRITE command, and auto precharge is either enabled or
disabled for that access. If auto precharge is selected, the row being accessed is pre-
charged at the end of the WRITE burst. If auto precharge is not selected, the row will
remain open for subsequent accesses. After a WRITE command has been issued, the
WRITE burst may not be interrupted. For the generic WRITE commands used in Figure
82 (page 158) through Figure 90 (page 163), auto precharge is disabled.
During WRITE bursts, the first valid data-in element is registered on a rising edge of
DQS following the WRITE latency (WL) clocks later and subsequent data elements will
be registered on successive edges of DQS. WRITE latency (WL) is defined as the sum of
posted CAS additive latency (AL) and CAS WRITE latency (CWL): WL = AL + CWL. The
values of AL and CWL are programmed in the MR0 and MR2 registers, respectively. Prior
to the first valid DQS edge, a full cycle is needed (including a dummy crossover of DQS,
DQS#) and specified as the WRITE preamble shown in Figure 82 (page 158). The half
cycle on DQS following the last data-in element is known as the WRITE postamble.
The time between the WRITE command and the first valid edge of DQS is WL clocks
±tDQSS. Figure 83 (page 159) through Figure 90 (page 163) show the nominal case
where tDQSS = 0ns; however, Figure 82 (page 158) includes tDQSS (MIN) and tDQSS
(MAX) cases.
Data may be masked from completing a WRITE using data mask. The data mask occurs
on the DM ball aligned to the WRITE data. If DM is LOW, the WRITE completes normal-
ly. If DM is HIGH, that bit of data is masked.
Upon completion of a burst, assuming no other commands have been initiated, the DQ
will remain High-Z, and any additional input data will be ignored.
Data for any WRITE burst may be concatenated with a subsequent WRITE command to
provide a continuous flow of input data. The new WRITE command can be tCCD clocks
following the previous WRITE command. The first data element from the new burst is
applied after the last element of a completed burst. Figure 83 (page 159) and Figure 84
(page 159) show concatenated bursts. An example of nonconsecutive WRITEs is shown
in Figure 85 (page 160).
Data for any WRITE burst may be followed by a subsequent READ command after tWTR
has been met (see Figure 86 (page 160), Figure 87 (page 161), and Figure 88 (page
162)).
Data for any WRITE burst may be followed by a subsequent PRECHARGE command,
providing tWR has been met, as shown in Figure 89 (page 163) and Figure 90 (page
163).
Both tWTR and tWR starting time may vary, depending on the mode register settings
(fixed BC4, BL8 versus OTF).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
WRITE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
156
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 157 -->

Figure 80: tWPRE Timing
DQS - DQS#
T1
tWPRE begins
T2
tWPRE ends
tWPRE
Resulting differential 
signal relevant for 
tWPRE specification
0V
CK
CK#
VTT
Figure 81: tWPST Timing
tWPST
DQS - DQS#
T1
tWPST begins
T2
tWPST ends
Resulting differential 
signal relevant for 
tWPST specification
0V
CK
CK#
VTT
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
WRITE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
157
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 158 -->

Figure 82: WRITE Burst
DI
n + 3
DI
 n + 2
DI
n + 1
DIn
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
Don’t Care
Transitioning Data
DI
n + 7
DI
 n + 6
DI
n + 5
DI
n + 4
Bank,
Col n
NOP
WRITE
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
Command1
DQ3
DQS, DQS#
Address2
tWPST
tWPRE
tWPST
tDQSL
DQ3
DQ3
tWPST
DQS, DQS#
DQS, DQS#
tDQSL
tWPRE
tDQSS
tDQSS tDSH
tDSH
tDSH
tDSH
tDSS
tDSS
tDSS
tDSS
tDSS
tDSS
tDSS
tDSS
tDSS
tDSS
tDSH
tDSH
tDSH
tDSH
tDQSL
tDQSH
tDQSL
tDQSH
tDQSL
tDQSH
tDQSH
tDQSL
tDQSL
tDQSL
tDQSL
tDQSH
tDQSH
tDQSH
tDQSH
tDQSL
tDQSH
tDQSL
tDQSH
tDQSH
tDQSL
tDQSH
tDQSL
tDQSH
tDQSL
tDQSH
tDQSH
WL = AL + CWL
tDQSS (MIN)
tDQSS (NOM)
tDQSS (MAX)
tDQSL
tWPRE
DI
 n + 3
DI
 n + 2
DI
 n + 1
DI
 n
DI
n + 7
DI
 n + 6
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
DI
n + 7
DI
n + 6
DI
n + 5
DI
n + 4
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at
these times.
2. The BL8 setting is activated by either MR0[1:0] = 00 or MR0[1:0] = 01 and A12 = 1 during
the WRITE command at T0.
3. DI n = data-in for column n.
4. BL8, WL = 5 (AL = 0, CWL = 5).
5.
tDQSS must be met at each rising clock edge.
6.
tWPST is usually depicted as ending at the crossing of DQS, DQS#; however, tWPST ac-
tually ends when DQS no longer drives LOW and DQS# no longer drives HIGH.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
WRITE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
158
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 159 -->

Figure 83: Consecutive WRITE (BL8) to WRITE (BL8)
WL = 5
WL = 5
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
tCCD
tWPRE
T10
T11
Don’t Care
Transitioning Data
T12
T13
T14
Valid
Valid
NOP
WRITE
WRITE
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
CK
CK#
Command1
DQ3
DQS, DQS#
Address2
tWPST
tWR
tWTR
tBL = 4 clocks
DI
 n + 3
DI
 n + 2
DI
 n + 1
DI
 n
DI
 n + 7
DI
 n + 6
DI
n + 5
DI
n + 4
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
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at these times.
2. The BL8 setting is activated by either MR0[1:0] = 00 or MR0[1:0] = 01 and A12 = 1 during the WRITE commands at
T0 and T4.
3. DI n (or b) = data-in for column n (or column b).
4. BL8, WL = 5 (AL = 0, CWL = 5).
Figure 84: Consecutive WRITE (BC4) to WRITE (BC4) via OTF
WL = 5
WL = 5
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
tCCD
tWPRE
T10
T11
Don’t Care
Transitioning Data
T12
T13
T14
Valid
Valid
NOP
WRITE
WRITE
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
CK
CK#
Command1
DQ3
DQS, DQS#
Address2
tWPST
tWR
tWTR
tWPST
tWPRE
DI
 n + 3
DI
 n + 2
DI
 n + 1
DIn
DI
 b + 3
DI
 b + 2
DI
 b + 1
DI
 b
tBL = 4 clocks
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at these times.
2. BC4, WL = 5 (AL = 0, CWL = 5).
3. DI n (or b) = data-in for column n (or column b).
4. The BC4 setting is activated by MR0[1:0] = 01 and A12 = 0 during the WRITE command at T0 and T4.
5. If set via MRS (fixed) tWR and tWTR would start T11 (2 cycles earlier).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
WRITE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
159
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 160 -->

Figure 85: Nonconsecutive WRITE to WRITE
CK
CK#
Command
NOP
NOP
NOP
Address
DQ
DM
DQS, DQS#
Transitioning Data
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
T16
T17
NOP
WRITE
NOP
WRITE
Valid
Valid
NOP
DIn
DI
n + 1
DI
n + 2
DI
n + 3
DI
n + 4
DI
n + 5
DI
n + 6
Don't Care
DI
n + 7
DIb
DI
b + 1
DI
b + 2
DI
b + 3
DI
b + 4
DI
b + 5
DI
b + 6
DI
b + 7
WL = CWL + AL  = 7
WL = CWL + AL  = 7
Notes:
1. DI n (or b) = data-in for column n (or column b).
2. Seven subsequent elements of data-in are applied in the programmed order following DO n.
3. Each WRITE command may be to any bank.
4. Shown for WL = 7 (CWL = 7, AL = 0).
Figure 86: WRITE (BL8) to READ (BL8)
WL = 5
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
tWPRE
T10
T11
Don’t Care
Transitioning Data
Ta0
NOP
WRITE
READ
Valid
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
CK
CK#
Command1
DQ4
DQS, DQS#
Address3
tWPST
tWTR2
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
n + 7
DI
n + 6
DI
n + 5
DI
n + 4
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at these times.
2.
tWTR controls the WRITE-to-READ delay to the same device and starts with the first rising clock edge after the last
write data shown at T9.
3. The BL8 setting is activated by either MR0[1:0] = 00 or MR0[1:0] = 01 and MR0[12] = 1 during the WRITE command
at T0. The READ command at Ta0 can be either BC4 or BL8, depending on MR0[1:0] and the A12 status at Ta0.
4. DI n = data-in for column n.
5. RL = 5 (AL = 0, CL = 5), WL = 5 (AL = 0, CWL = 5).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
WRITE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
160
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 161 -->

Figure 87: WRITE to READ (BC4 Mode Register Setting)
WL = 5
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
Don’t Care
Transitioning Data
NOP
WRITE
Valid
READ
Valid
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
Command1
DQ4
DQS, DQS#
Address3
tWPST
tWTR2
tWPRE
Indicates break
in time scale
DI
n + 3
DI
n + 2
DI
n + 1
DIn
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at these times.
2.
tWTR controls the WRITE-to-READ delay to the same device and starts with the first rising clock edge after the last
write data shown at T7.
3. The fixed BC4 setting is activated by MR0[1:0] = 10 during the WRITE command at T0 and the READ command at
Ta0.
4. DI n = data-in for column n.
5. BC4 (fixed), WL = 5 (AL = 0, CWL = 5), RL = 5 (AL = 0, CL = 5).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
WRITE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
161
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 162 -->

Figure 88: WRITE (BC4 OTF) to READ (BC4 OTF)
WL = 5
RL = 5
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
tWPRE
T10
T11
Don’t Care
Transitioning Data
Tn
NOP
WRITE
READ
Valid
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
CK
CK#
Command1
DQ4
DQS, DQS#
Address3
tWPST
tBL = 4 clocks
NOP
tWTR2
Indicates break
in time scale
DI
n + 3
DI
n + 2
DI
n + 1
DIn
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at these times.
2.
tWTR controls the WRITE-to-READ delay to the same device and starts after tBL.
3. The BC4 OTF setting is activated by MR0[1:0] = 01 and A12 = 0 during the WRITE command at T0 and the READ
command at Tn.
4. DI n = data-in for column n.
5. BC4, RL = 5 (AL = 0, CL = 5), WL = 5 (AL = 0, CWL = 5).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
WRITE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
162
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 163 -->

Figure 89: WRITE (BL8) to PRECHARGE
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
Ta0
Ta1
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
NOP
PRE
CK
CK#
Command
DQ BL8
DQS, DQS#
Address
Don’t Care
Transitioning Data
Indicates break
in time scale
tWR
WL = AL + CWL
Valid
Notes:
1. DI n = data-in from column n.
2. Seven subsequent elements of data-in are applied in the programmed order following
DO n.
3. Shown for WL = 7 (AL = 0, CWL = 7).
Figure 90: WRITE (BC4 Mode Register Setting) to PRECHARGE
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
Ta0
Ta1
DI
n + 3
DI
n + 2
DI
n + 1
DIn
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
NOP
PRE
CK
CK#
Command
DQ BC4
DQS, DQS#
Address
Don’t Care
Transitioning Data
Indicates break
in time scale
tWR
WL = AL + CWL
Valid
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at
these times.
2. The write recovery time (tWR) is referenced from the first rising clock edge after the last
write data is shown at T7. tWR specifies the last burst WRITE cycle until the PRECHARGE
command can be issued to the same bank.
3. The fixed BC4 setting is activated by MR0[1:0] = 10 during the WRITE command at T0.
4. DI n = data-in for column n.
5. BC4 (fixed), WL = 5, RL = 5.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
WRITE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
163
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 164 -->

Figure 91: WRITE (BC4 OTF) to PRECHARGE
WL = 5
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
Tn
Don’t Care
Transitioning Data
Bank,
Col n
NOP
WRITE
PRE
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
Command1
DQ4
DQS, DQS#
Address3
tWPST
tWPRE
Indicates break
in time scale
DI
n + 3
DI
n + 2
DI
n + 1
DIn
tWR2
Valid
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at
these times.
2. The write recovery time (tWR) is referenced from the rising clock edge at T9. tWR speci-
fies the last burst WRITE cycle until the PRECHARGE command can be issued to the same
bank.
3. The BC4 setting is activated by MR0[1:0] = 01 and A12 = 0 during the WRITE command
at T0.
4. DI n = data-in for column n.
5. BC4 (OTF), WL = 5, RL = 5.
DQ Input Timing
Figure 82 (page 158) shows the strobe-to-clock timing during a WRITE burst. DQS,
DQS# must transition within 0.25tCK of the clock transitions, as limited by tDQSS. All
data and data mask setup and hold timings are measured relative to the DQS, DQS#
crossing, not the clock crossing.
The WRITE preamble and postamble are also shown in Figure 82 (page 158). One clock
prior to data input to the DRAM, DQS must be HIGH and DQS# must be LOW. Then for
a half clock, DQS is driven LOW (DQS# is driven HIGH) during the WRITE preamble,
tWPRE. Likewise, DQS must be kept LOW by the controller after the last data is written
to the DRAM during the WRITE postamble, tWPST.
Data setup and hold times are also shown in Figure 82 (page 158). All setup and hold
times are measured from the crossing points of DQS and DQS#. These setup and hold
values pertain to data input and data mask input.
Additionally, the half period of the data input strobe is specified by tDQSH and tDQSL.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
WRITE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
164
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 165 -->

Figure 92: Data Input Timing
tDH
tDH
tDS
tDS
DM
DQ
DI
b
DQS, DQS#
Don’t Care
Transitioning Data
tDQSH
tDQSL
tWPRE
tWPST
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
WRITE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
165
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

