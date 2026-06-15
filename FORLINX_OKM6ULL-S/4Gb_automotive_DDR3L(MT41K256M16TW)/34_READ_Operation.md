# READ Operation

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 145–155

<!-- page 145 -->

READ Operation
READ bursts are initiated with a READ command. The starting column and bank ad-
dresses are provided with the READ command and auto precharge is either enabled or
disabled for that burst access. If auto precharge is enabled, the row being accessed is
automatically precharged at the completion of the burst. If auto precharge is disabled,
the row will be left open after the completion of the burst.
During READ bursts, the valid data-out element from the starting column address is
available READ latency (RL) clocks later. RL is defined as the sum of posted CAS additive
latency (AL) and CAS latency (CL) (RL = AL + CL). The value of AL and CL is programma-
ble in the mode register via the MRS command. Each subsequent data-out element is
valid nominally at the next positive or negative clock edge (that is, at the next crossing
of CK and CK#). Figure 65 shows an example of RL based on a CL setting of 8 and an AL
setting of 0.
Figure 65: READ Latency
CK
CK#
Command
READ
NOP
NOP
NOP
NOP
NOP
NOP
NOP
Address
Bank a,
Col n
CL = 8, AL = 0
DQ
DQS, DQS#
DO
n
T0
T7
T8
T9
T10
T11
Don’t Care
Transitioning Data
T12
T12
Indicates break
in time scale
Notes:
1. DO n = data-out from column n.
2. Subsequent elements of data-out appear in the programmed order following DO n.
DQS, DQS# is driven by the DRAM along with the output data. The initial LOW state on
DQS and HIGH state on DQS# is known as the READ preamble (tRPRE). The LOW state
on DQS and the HIGH state on DQS#, coincident with the last data-out element, is
known as the READ postamble (tRPST). Upon completion of a burst, assuming no other
commands have been initiated, the DQ goes High-Z. A detailed explanation of tDQSQ
(valid data-out skew), tQH (data-out window hold), and the valid data window are de-
picted in Figure 76 (page 153). A detailed explanation of tDQSCK (DQS transition skew
to CK) is also depicted in Figure 76 (page 153).
Data from any READ burst may be concatenated with data from a subsequent READ
command to provide a continuous flow of data. The first data element from the new
burst follows the last element of a completed burst. The new READ command should be
issued tCCD cycles after the first READ command. This is shown for BL8 in Figure 66
(page 147). If BC4 is enabled, tCCD must still be met, which will cause a gap in the data
output, as shown in Figure 67 (page 147). Nonconsecutive READ data is reflected in 
Figure 68 (page 148). DDR3 SDRAM does not allow interrupting or truncating any
READ burst.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
READ Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
145
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 146 -->

Data from any READ burst must be completed before a subsequent WRITE burst is al-
lowed. An example of a READ burst followed by a WRITE burst for BL8 is shown in Fig-
ure 69 (page 148) (BC4 is shown in Figure 70 (page 149)). To ensure the READ data is
completed before the WRITE data is on the bus, the minimum READ-to-WRITE timing
is RL + tCCD - WL + 2tCK.
A READ burst may be followed by a PRECHARGE command to the same bank, provided
auto precharge is not activated. The minimum READ-to-PRECHARGE command spac-
ing to the same bank is four clocks and must also satisfy a minimum analog time from
the READ command. This time is called tRTP (READ-to-PRECHARGE). tRTP starts AL
cycles later than the READ command. Examples for BL8 are shown in Figure 71 (page
149) and BC4 in Figure 72 (page 150). Following the PRECHARGE command, a subse-
quent command to the same bank cannot be issued until tRP is met. The PRECHARGE
command followed by another PRECHARGE command to the same bank is allowed.
However, the precharge period will be determined by the last PRECHARGE command
issued to the bank.
If A10 is HIGH when a READ command is issued, the READ with auto precharge func-
tion is engaged. The DRAM starts an auto precharge operation on the rising edge, which
is AL + tRTP cycles after the READ command. DRAM support a tRAS lockout feature (see 
Figure 74 (page 150)). If tRAS (MIN) is not satisfied at the edge, the starting point of the
auto precharge operation will be delayed until tRAS (MIN) is satisfied. If tRTP (MIN) is
not satisfied at the edge, the starting point of the auto precharge operation is delayed
until tRTP (MIN) is satisfied. In case the internal precharge is pushed out by tRTP, tRP
starts at the point at which the internal precharge happens (not at the next rising clock
edge after this event). The time from READ with auto precharge to the next ACTIVATE
command to the same bank is AL + (tRTP + tRP)*, where * means rounded up to the next
integer. In any event, internal precharge does not start earlier than four clocks after the
last 8n-bit prefetch.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
READ Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
146
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 147 -->

Figure 66: Consecutive READ Bursts (BL8)
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
Don’t Care
Transitioning Data
T12
T13
T14
tRPST
NOP
READ
READ
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
Bank,
Col n
Bank,
Col b
Address2
RL = 5
tRPRE
tCCD
RL = 5
DO
 n + 3
DO
 n + 2
DO
 n + 1
DO
 n
DO
 n + 7
DO
 n + 6
DO
 n + 5
DO 
n + 4
DO
 b + 3
DO
 b + 2
DO
 b + 1
DO
 b
DO
 b + 7
DO
 b + 6
DO
 b + 5
DO 
b + 4
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at these times.
2. The BL8 setting is activated by either MR0[1:0] = 00 or MR0[1:0] = 01 and A12 = 1 during READ command at T0
and T4.
3. DO n (or b) = data-out from column n (or column b).
4. BL8, RL = 5 (CL = 5, AL = 0).
Figure 67: Consecutive READ Bursts (BC4)
NOP
CK
CK#
Command1
DQ3
DQS, DQS#
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
Address2
T10
T11
Don’t Care
Transitioning Data
T12
T13
T14
READ
READ
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
Bank,
Col n
Bank,
Col b
tRPST
tRPRE
tRPST
tRPRE
RL = 5
DO
 n + 3
DO
 n + 2
DO
 n + 1
DO
 n
DO
 b + 3
DO
 b + 2
DO
 b + 1
DO
 b
RL = 5
tCCD
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at these times.
2. The BC4 setting is activated by either MR0[1:0] = 10 or MR0[1:0] = 01 and A12 = 0 during READ command at T0
and T4.
3. DO n (or b) = data-out from column n (or column b).
4. BC4, RL = 5 (CL = 5, AL = 0).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
READ Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
147
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 148 -->

Figure 68: Nonconsecutive READ Bursts
Don’t Care
Transitioning Data
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
DQS, DQS#
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
READ
NOP
READ
Address
Bank a,
Col n
Bank a,
Col b
CK
CK#
DQ
DO
n
DO
b
CL = 8 
CL = 8 
Notes:
1. AL = 0, RL = 8.
2. DO n (or b) = data-out from column n (or column b).
3. Seven subsequent elements of data-out appear in the programmed order following DO n.
4. Seven subsequent elements of data-out appear in the programmed order following DO b.
Figure 69: READ (BL8) to WRITE (BL8)
Don’t Care
Transitioning Data
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
CK
CK#
Command1
NOP
NOP
NOP
NOP
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
tWPST
tRPRE
tWPRE
tRPST
DQS, DQS#
DQ3
WL = 5
tWR
tWR
READ
DO
 n
DO
 n + 1
DO
 n + 2
DO
 n + 3
DO
 n + 4
DO
 n + 5
DO
 n + 6
DO
 n + 7
DI
 n
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
DI
 n + 7
READ-to-WRITE command delay = RL + tCCD + 2tCK - WL
tBL = 4 clocks
Address2
Bank,
Col b
Bank,
Col n
RL = 5
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at these times.
2. The BL8 setting is activated by either MR0[1:0] = 00 or MR0[1:0] = 01 and A12 = 1 during the READ command at
T0, and the WRITE command at T6.
3. DO n = data-out from column, DI b = data-in for column b.
4. BL8, RL = 5 (AL = 0, CL = 5), WL = 5 (AL = 0, CWL = 5).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
READ Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
148
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 149 -->

Figure 70: READ (BC4) to WRITE (BC4) OTF
Don’t Care
Transitioning Data
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
CK
CK#
Address2
Command1
tWPST
tWPRE
tRPST
DQS, DQS#
DQ3
WL = 5
tWR
tWTR
tBL = 4 clocks
tRPRE
RL = 5
READ-to-WRITE command delay = RL + tCCD/2 + 2tCK - WL
READ
DO
n
DO
n + 1
DO
n + 2
DO
n + 3
DIn
DI
n + 1
DI
n + 2
DI
n + 3
Bank,
Col b
Bank,
Col n
NOP
NOP
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
NOP
NOP
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at these times.
2. The BC4 OTF setting is activated by MR0[1:0] and A12 = 0 during READ command at T0 and WRITE command at
T4.
3. DO n = data-out from column n; DI n = data-in from column b.
4. BC4, RL = 5 (AL - 0, CL = 5), WL = 5 (AL = 0, CWL = 5).
Figure 71: READ to PRECHARGE (BL8)
tRAS
tRTP
CK
CK#
Command
NOP
NOP
NOP
NOP
Address
DQ
DQS, DQS#
Don’t Care
Transitioning Data
NOP
NOP
NOP
NOP
NOP
ACT
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
READ
Bank a,
Col n
NOP
PRE
Bank a,
(or all)
Bank a,
Row b
tRP
DO
n
DO
n + 1
DO
n + 2
DO
n + 3
DO
n + 4
DO
n + 5
DO
n + 6
DO
n + 7
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
READ Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
149
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 150 -->

Figure 72: READ to PRECHARGE (BC4)
CK
CK#
Don’t Care
Transitioning Data
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
ACT
NOP
NOP
NOP
NOP
NOP
READ
NOP
PRE
Address
Bank a,
Col n
Bank a,
(or all)
Bank a,
Row b
tRP
tRTP
DQS, DQS#
DQ
DO
n
DO
n + 1
DO
n + 2
DO
n + 3
tRAS
Figure 73: READ to PRECHARGE (AL = 5, CL = 6)
CK
CK#
Command
NOP
NOP
NOP
NOP
Address
DQ
DQS, DQS#
Don’t Care
Transitioning Data
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
NOP
READ
Bank a,
Col n
NOP
PRE
Bank a,
(or all)
ACT
Bank a,
Row b
NOP
NOP
tRAS
CL = 6
AL = 5
tRTP
tRP
DO
n + 3
DO
n + 2
DO
n
DO
n + 1
Figure 74: READ with Auto Precharge (AL = 4, CL = 6)
CK
CK#
Command
NOP
NOP
NOP
NOP
Address
DQ
DQS, DQS#
Don’t Care
Transitioning Data
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
Ta0
tRTP (MIN)
NOP
READ
NOP
AL = 4
NOP
NOP
CL = 6
NOP
tRAS (MIN)
ACT
Indicates break
in time scale
tRP
Bank a,
Col n
Bank a,
Row b
DO
n
DO
n + 1
DO
n + 2
DO
n + 3
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
READ Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
150
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 151 -->

DQS to DQ output timing is shown in Figure 75 (page 152). The DQ transitions between
valid data outputs must be within tDQSQ of the crossing point of DQS, DQS#. DQS must
also maintain a minimum HIGH and LOW time of tQSH and tQSL. Prior to the READ
preamble, the DQ balls will either be floating or terminated, depending on the status of
the ODT signal.
Figure 76 (page 153) shows the strobe-to-clock timing during a READ. The crossing
point DQS, DQS# must transition within ±tDQSCK of the clock crossing point. The data
out has no timing relationship to CK, only to DQS, as shown in Figure 76 (page 153).
Figure 76 (page 153) also shows the READ preamble and postamble. Typically, both
DQS and DQS# are High-Z to save power (VDDQ). Prior to data output from the DRAM,
DQS is driven LOW and DQS# is HIGH for tRPRE. This is known as the READ preamble.
The READ postamble, tRPST, is one half clock from the last DQS, DQS# transition. Dur-
ing the READ postamble, DQS is driven LOW and DQS# is HIGH. When complete, the
DQ is disabled or continues terminating, depending on the state of the ODT signal. Fig-
ure 79 (page 155) demonstrates how to measure tRPST.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
READ Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
151
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 152 -->

Figure 75: Data Output Timing – tDQSQ and Data Valid Window
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
Bank,
Col n
tRPST
NOP
READ
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
Address2
tDQSQ (MAX)
DQS, DQS#
DQ3 (last data valid)
DQ3 (first data no longer valid)
All DQ collectively
DO
n
DO
n + 3
DO
n + 2
DO
n + 1
DO
n + 7
DO
n + 6
DO
n + 5
DO
n + 4
DO
n + 2
DO
n + 1
DO
n + 7
DO
n + 6
DO
n + 5
DO
n + 4
DO
 n + 3
DO
 n + 2
DO
 n + 1
DO
 n
DO
 n + 7
DO
 n + 6
DO
 n + 5
DO
 n
DO
n + 3
tRPRE
Don’t Care
Data valid
Data valid
tQH
tQH
tHZDQ (MAX)
DO 
n + 4
RL = AL + CL
tDQSQ (MAX)
tLZDQ (MIN)
Notes:
1. NOP commands are shown for ease of illustration; other commands may be valid at these times.
2. The BL8 setting is activated by either MR0[1, 0] = 0, 0 or MR0[0, 1] = 0, 1 and A12 = 1 during READ command at
T0.
3. DO n = data-out from column n.
4. BL8, RL = 5 (AL = 0, CL = 5).
5. Output timings are referenced to VDDQ/2 and DLL on and locked.
6.
tDQSQ defines the skew between DQS, DQS# to data and does not define DQS, DQS# to CK.
7. Early data transitions may not always happen at the same DQ. Data transitions of a DQ can be early or late within
a burst.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
READ Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
152
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 153 -->

tHZ and tLZ transitions occur in the same access time as valid data transitions. These
parameters are referenced to a specific voltage level that specifies when the device out-
put is no longer driving tHZDQS and tHZDQ, or begins driving tLZDQS, tLZDQ. Figure
77 (page 154) shows a method of calculating the point when the device is no longer
driving tHZDQS and tHZDQ, or begins driving tLZDQS, tLZDQ, by measuring the signal
at two different voltages. The actual voltage measurement points are not critical as long
as the calculation is consistent. The parameters tLZDQS, tLZDQ, tHZDQS, and tHZDQ
are defined as single-ended.
Figure 76: Data Strobe Timing – READs
RL measured
to this point
DQS, DQS#
early strobe
CK
tLZDQS (MIN)
tHZDQS (MIN)
DQS, DQS#
late strobe
tLZDQS (MAX)
tHZDQS (MAX)
tDQSCK (MAX)
tDQSCK (MAX)
tDQSCK (MAX)
tDQSCK (MAX)
tDQSCK (MIN)
tDQSCK (MIN)
tDQSCK (MIN)
tDQSCK (MIN)
CK#
tRPRE
tQSH
tQSH
tQSL
tQSL
tQSL
tQSL
tQSH
tQSH
Bit 0
Bit 1
Bit 2
Bit 7
tRPRE
Bit 0
Bit 1
Bit 2
Bit 7
Bit 6
Bit 3
Bit 4
Bit 5
Bit 6
Bit 4
Bit 3
Bit 5
tRPST
tRPST
T0
T1
T2
T3
T4
T5
T6
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
READ Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
153
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 154 -->

Figure 77: Method for Calculating tLZ and tHZ
tHZDQS, tHZDQ
tHZDQS, tHZDQ end point = 2 × T1 - T2
VOH - xmV
VTT - xmV
VOL + xmV
VTT + xmV
VOH - 2xmV
VTT - 2xmV
VOL + 2xmV
VTT + 2xmV
tLZDQS, tLZDQ
tLZDQS, tLZDQ begin point = 2 × T1 - T2
T1
T1
T2
T2
Notes:
1. Within a burst, the rising strobe edge is not necessarily fixed at tDQSCK (MIN) or tDQSCK
(MAX). Instead, the rising strobe edge can vary between tDQSCK (MIN) and tDQSCK
(MAX).
2. The DQS HIGH pulse width is defined by tQSH, and the DQS LOW pulse width is defined
by tQSL. Likewise, tLZDQS (MIN) and tHZDQS (MIN) are not tied to tDQSCK (MIN) (early
strobe case), and tLZDQS (MAX) and tHZDQS (MAX) are not tied to tDQSCK (MAX) (late
strobe case); however, they tend to track one another.
3. The minimum pulse width of the READ preamble is defined by tRPRE (MIN). The mini-
mum pulse width of the READ postamble is defined by tRPST (MIN).
Figure 78: tRPRE Timing
tRPRE
DQS - DQS# 
DQS
DQS#
T1
tRPRE begins
T2
tRPRE ends
CK
CK#
VTT
Resulting differential 
signal relevant for 
tRPRE specification
tC
tA
tB
tD
Single-ended signal provided
as background information
0V
Single-ended signal provided
as background information
VTT
VTT
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
READ Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
154
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 155 -->

Figure 79: tRPST Timing
tRPST
DQS - DQS#
DQS 
DQS#
T1
tRPST begins
T2
tRPST ends
Resulting differential 
signal relevant for 
tRPST specification
CK
CK#
VTT
tC
tA
tB
tD
Single-ended signal, provided
as background information
Single-ended signal, provided
as background information
0V
VTT
VTT
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
READ Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
155
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

