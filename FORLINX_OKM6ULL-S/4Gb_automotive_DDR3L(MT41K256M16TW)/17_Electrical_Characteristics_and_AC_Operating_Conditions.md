# Electrical Characteristics and AC Operating Conditions

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 75–83

<!-- page 75 -->

Electrical Characteristics and AC Operating Conditions
Table 56: Electrical Characteristics and AC Operating Conditions for Speed Extensions
Notes 1–8 apply to the entire table
Parameter
Symbol
DDR3L-1866
Unit
Notes
Min
Max
Clock Timing
Clock period average: DLL
disable mode
–40°C ≤ TC ≤ 85°C
tCK (DLL_DIS)
8
7800
ns
9, 42
85°C < TC ≤ 95°C
8
3900
ns
42
95°C < TC ≤ 105°C
8
3900
ns
42
105°C < TC ≤ 125°C
8
3900
ns
42
Clock period average: DLL enable mode
tCK (AVG)
See Speed Bin Tables for
tCK range allowed
ns
10, 11
High pulse width average
tCH (AVG)
0.47
0.53
CK
12
Low pulse width average
tCL (AVG)
0.47
0.53
CK
12
Clock period jitter
DLL locked
tJITper
–60
60
ps
13
DLL locking
tJITper,lck
–50
50
ps
13
Clock absolute period
tCK (ABS)
MIN = tCK (AVG) MIN
+tJITper MIN;
MAX = tCK (AVG) MAX +
tJITper MAX
ps
 
Clock absolute high pulse width
tCH (ABS)
0.43
–
tCK (AVG)
14
Clock absolute low pulse width
tCL (ABS)
0.43
–
tCK (AVG)
15
Cycle-to-cycle jitter
DLL locked
tJITcc
120
ps
16
DLL locking
tJITcc,lck
100
ps
16
Cumulative error across
2 cycles
tERR2per
–88
88
ps
17
3 cycles
tERR3per
–105
105
ps
17
4 cycles
tERR4per
–117
117
ps
17
5 cycles
tERR5per
–126
126
ps
17
6 cycles
tERR6per
–133
133
ps
17
7 cycles
tERR7per
–139
139
ps
17
8 cycles
tERR8per
–145
145
ps
17
9 cycles
tERR9per
–150
150
ps
17
10 cycles
tERR10per
–154
154
ps
17
11 cycles
tERR11per
–158
158
ps
17
12 cycles
tERR12per
–161
161
ps
17
n = 13, 14 . . . 49, 50
cycles
tERRnper
tERRnper MIN = (1 +
0.68ln[n]) × tJITper MIN
tERRnper MAX = (1 +
0.68ln[n]) × tJITper MAX
ps
17
DQ Input Timing
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Characteristics and AC Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
75
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 76 -->

Table 56: Electrical Characteristics and AC Operating Conditions for Speed Extensions (Continued)
Notes 1–8 apply to the entire table
Parameter
Symbol
DDR3L-1866
Unit
Notes
Min
Max
Data setup time to DQS,
DQS#
Base (specification) @
2 V/ns
tDS
(AC130)
70
–
ps
18, 19
VREF @ 2 V/ns
135
–
ps
19, 20
Data hold time from DQS,
DQS#
Base (specification) @
2 V/ns
tDH
(DC90)
75
–
ps
18, 19
VREF @ 2 V/ns
110
–
ps
19, 20
Minimum data pulse width
tDIPW
320
–
ps
41
DQ Output Timing
DQS, DQS# to DQ skew, per access
tDQSQ
–
85
ps
 
DQ output hold time from DQS, DQS#
tQH
0.38
–
tCK (AVG)
21
DQ Low-Z time from CK, CK#
tLZDQ
–390
195
ps
22, 23
DQ High-Z time from CK, CK#
tHZDQ
–
195
ps
22, 23
DQ Strobe Input Timing
DQS, DQS# rising to CK, CK# rising
tDQSS
–0.27
0.27
CK
25
DQS, DQS# differential input low pulse width
tDQSL
0.45
0.55
CK
 
DQS, DQS# differential input high pulse width
tDQSH
0.45
0.55
CK
 
DQS, DQS# falling setup to CK, CK# rising
tDSS
0.18
–
CK
25
DQS, DQS# falling hold from CK, CK# rising
tDSH
0.18
–
CK
25
DQS, DQS# differential WRITE preamble
tWPRE
0.9
–
CK
 
DQS, DQS# differential WRITE postamble
tWPST
0.3
–
CK
 
DQ Strobe Output Timing
DQS, DQS# rising to/from rising CK, CK#
tDQSCK
–195
195
ps
23
DQS, DQS# rising to/from rising CK, CK# when
DLL is disabled
tDQSCK
(DLL_DIS)
1
10
ns
26
DQS, DQS# differential output high time
tQSH
0.40
–
CK
21
DQS, DQS# differential output low time
tQSL
0.40
–
CK
21
DQS, DQS# Low-Z time (RL - 1)
tLZDQS
–390
195
ps
22, 23
DQS, DQS# High-Z time (RL + BL/2)
tHZDQS
–
195
ps
22, 23
DQS, DQS# differential READ preamble
tRPRE
0.9
Note 24
CK
23, 24
DQS, DQS# differential READ postamble
tRPST
0.3
Note 27
CK
23, 27
Command and Address Timing
DLL locking time
tDLLK
512
–
CK
28
CTRL, CMD, ADDR
setup to CK,CK#
Base (specification)
tIS
(AC135)
65
–
ps
29, 30, 44
VREF @ 1 V/ns
200
–
ps
20, 30
CTRL, CMD, ADDR
setup to CK,CK#
Base (specification)
tIS
(AC125)
150
–
ps
29, 30, 44
VREF @ 1 V/ns
275
–
ps
20, 30
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Characteristics and AC Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
76
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 77 -->

Table 56: Electrical Characteristics and AC Operating Conditions for Speed Extensions (Continued)
Notes 1–8 apply to the entire table
Parameter
Symbol
DDR3L-1866
Unit
Notes
Min
Max
CTRL, CMD, ADDR hold
from CK,CK#
Base (specification)
tIH
(DC90)
110
–
ps
29, 30
VREF @ 1 V/ns
200
–
ps
20, 30
Minimum CTRL, CMD, ADDR pulse width
tIPW
535
–
ps
41
ACTIVATE to internal READ or WRITE delay
tRCD
See Speed Bin Tables for
tRCD
ns
31
PRECHARGE command period
tRP
See Speed Bin Tables for
tRP
ns
31
ACTIVATE-to-PRECHARGE command period
tRAS
See Speed Bin Tables for
tRAS
ns
31, 32
ACTIVATE-to-ACTIVATE command period
tRC
See Speed Bin Tables for
tRC
ns
31, 43
ACTIVATE-to-ACTIVATE
minimum command period
1KB page size
tRRD
MIN = greater of 4CK or
5ns
CK
31
2KB page size
MIN = greater of 4CK or
6ns
CK
31
Four ACTIVATE
windows
1KB page size
tFAW
27
–
ns
31
2KB page size
35
–
ns
31
Write recovery time
tWR
MIN = 15ns; MAX = N/A
ns
31, 32, 33
Delay from start of internal WRITE transaction to
internal READ command
tWTR
MIN = greater of 4CK or
7.5ns; MAX = N/A
CK
31, 34
READ-to-PRECHARGE time
tRTP
MIN = greater of 4CK or
7.5ns; MAX = N/A
CK
31, 32
CAS#-to-CAS# command delay
tCCD
MIN = 4CK; MAX = N/A
CK
 
Auto precharge write recovery + precharge time
tDAL
MIN = WR + tRP/tCK (AVG);
MAX = N/A
CK
 
MODE REGISTER SET command cycle time
tMRD
MIN = 4CK; MAX = N/A
CK
 
MODE REGISTER SET command update delay
tMOD
MIN = greater of 12CK or
15ns; MAX = N/A
CK
 
MULTIPURPOSE REGISTER READ burst end to
mode register set for multipurpose register exit
tMPRR
MIN = 1CK; MAX = N/A
CK
 
Calibration Timing
ZQCL command: Long cali-
bration time
POWER-UP and RE-
SET operation
tZQinit
MIN = N/A
MAX = MAX(512nCK,
640ns)
CK
 
Normal operation
tZQoper
MIN = N/A
MAX = MAX(256nCK,
320ns)
CK
 
ZQCS command: Short calibration time
MIN = N/A
MAX = MAX(64nCK, 80ns) tZQCS
CK
 
Initialization and Reset Timing
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Characteristics and AC Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
77
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 78 -->

Table 56: Electrical Characteristics and AC Operating Conditions for Speed Extensions (Continued)
Notes 1–8 apply to the entire table
Parameter
Symbol
DDR3L-1866
Unit
Notes
Min
Max
Exit reset from CKE HIGH to a valid command
tXPR
MIN = greater of 5CK or
tRFC + 10ns; MAX = N/A
CK
 
Begin power supply ramp to power supplies sta-
ble
tVDDPR
MIN = N/A; MAX = 200
ms
 
RESET# LOW to power supplies stable
tRPS
MIN = 0; MAX = 200
ms
 
RESET# LOW to I/O and RTT High-Z
tIOZ
MIN = N/A; MAX = 20
ns
35
Refresh Timing
REFRESH-to-ACTIVATE or REFRESH
command period
tRFC – 1Gb
MIN = 110; MAX = 70,200
ns
 
tRFC – 2Gb
MIN = 160; MAX = 70,200
ns
 
tRFC – 4Gb
MIN = 260; MAX = 70,200
ns
 
tRFC – 8Gb
MIN = 350; MAX = 70,200
ns
 
Maximum refresh
period
TC ≤ 85°C
–
64 (1X)
ms
36
TC > 85°C
32 (2X)
ms
36
TC > 105°C
8 (8X)
ms
36
Maximum average
periodic refresh
TC ≤ 85°C
tREFI
7.8 (64ms/8192)
μs
36
TC > 85°C
3.9 (32ms/8192)
μs
36
TC >105°C
0.977 (8ms/8192)
μs
36
Self Refresh Timing45
Exit self refresh to commands not requiring a
locked DLL
tXS
MIN = greater of 5CK or
tRFC + 10ns; MAX = N/A
CK
 
Exit self refresh to commands requiring a
locked DLL
tXSDLL
MIN = tDLLK (MIN);
MAX = N/A
CK
28
Minimum CKE low pulse width for self refresh
entry to self refresh exit timing
tCKESR
MIN = tCKE (MIN) + CK;
MAX = N/A
CK
 
Valid clocks after self refresh entry or power-
down entry
tCKSRE
MIN = greater of 5CK or
10ns; MAX = N/A
CK
 
Valid clocks before self refresh exit,
power-down exit, or reset exit
tCKSRX
MIN = greater of 5CK or
10ns; MAX = N/A
CK
 
Power-Down Timing
CKE MIN pulse width
tCKE (MIN)
Greater of 3CK or 5ns
CK
 
Command pass disable delay
tCPDED
MIN = 2;
MAX = N/A
CK
 
Power-down entry to power-down exit timing
tPD
MIN = tCKE (MIN);
MAX = 9 × tREFI
CK
 
Begin power-down period prior to CKE
registered HIGH
tANPD
WL - 1CK
CK
 
Power-down entry period: ODT either
synchronous or asynchronous
PDE
Greater of tANPD or tRFC -
REFRESH command to CKE
LOW time
CK
 
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Characteristics and AC Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
78
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 79 -->

Table 56: Electrical Characteristics and AC Operating Conditions for Speed Extensions (Continued)
Notes 1–8 apply to the entire table
Parameter
Symbol
DDR3L-1866
Unit
Notes
Min
Max
Power-down exit period: ODT either
synchronous or asynchronous
PDX
tANPD + tXPDLL
CK
 
Power-Down Entry Minimum Timing
ACTIVATE command to power-down entry
tACTPDEN
MIN = 2
CK
 
PRECHARGE/PRECHARGE ALL command to
power-down entry
tPRPDEN
MIN = 2
CK
 
REFRESH command to power-down entry
tREFPDEN
MIN = 2
CK
37
MRS command to power-down entry
tMRSPDEN
MIN = tMOD (MIN)
CK
 
READ/READ with auto precharge command to
power-down entry
tRDPDEN
MIN = RL + 4 + 1
CK
 
WRITE command to pow-
er-down entry
BL8 (OTF, MRS)
BC4OTF
tWRPDEN
MIN = WL + 4 +
tWR/tCK (AVG)
CK
 
BC4MRS
tWRPDEN
MIN = WL + 2 +
tWR/tCK (AVG)
CK
 
WRITE with auto pre-
charge command to pow-
er-down entry
BL8 (OTF, MRS)
BC4OTF
tWRAPDEN
MIN = WL + 4 + WR + 1
CK
 
BC4MRS
tWRAPDEN
MIN = WL + 2 + WR + 1
CK
 
Power-Down Exit Timing
DLL on, any valid command, or DLL off to
commands not requiring locked DLL
tXP
MIN = greater of 3CK or
6ns;
MAX = N/A
CK
 
Precharge power-down with DLL off to
commands requiring a locked DLL
tXPDLL
MIN = greater of 10CK or
24ns; MAX = N/A
CK
28
ODT Timing
RTT synchronous turn-on delay
ODTL on
CWL + AL - 2CK
CK
38
RTT synchronous turn-off delay
ODTL off
CWL + AL - 2CK
CK
40
RTT turn-on from ODTL on reference
tAON
–195
195
ps
23, 38
RTT turn-off from ODTL off reference
tAOF
0.3
0.7
CK
39, 40
Asynchronous RTT turn-on delay
(power-down with DLL off)
tAONPD
MIN = 2; MAX = 8.5
ns
38
Asynchronous RTT turn-off delay
(power-down with DLL off)
tAOFPD
MIN = 2; MAX = 8.5
ns
40
ODT HIGH time with WRITE command and BL8
ODTH8
MIN = 6; MAX = N/A
CK
 
ODT HIGH time without WRITE command or with
WRITE command and BC4
ODTH4
MIN = 4; MAX = N/A
CK
 
Dynamic ODT Timing
RTT,nom-to-RTT(WR) change skew
ODTLcnw
WL - 2CK
CK
 
RTT(WR)-to-RTT,nom change skew - BC4
ODTLcwn4
4CK + ODTLoff
CK
 
RTT(WR)-to-RTT,nom change skew - BL8
ODTLcwn8
6CK + ODTLoff
CK
 
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Characteristics and AC Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
79
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 80 -->

Table 56: Electrical Characteristics and AC Operating Conditions for Speed Extensions (Continued)
Notes 1–8 apply to the entire table
Parameter
Symbol
DDR3L-1866
Unit
Notes
Min
Max
RTT dynamic change skew
tADC
0.3
0.7
CK
39
Write Leveling Timing
First DQS, DQS# rising edge
tWLMRD
40
–
CK
 
DQS, DQS# delay
tWLDQSEN
25
–
CK
 
Write leveling setup from rising CK, CK#
crossing to rising DQS, DQS# crossing
tWLS
140
–
ps
 
Write leveling hold from rising DQS, DQS#
crossing to rising CK, CK# crossing
tWLH
140
–
ps
 
Write leveling output delay
tWLO
0
7.5
ns
 
Write leveling output error
tWLOE
0
2
ns
 
Notes:
1. AC timing parameters are valid from specified TC MIN to TC MAX values.
2. All voltages are referenced to VSS.
3. Output timings are only valid for RON34 output buffer selection.
4. The unit tCK (AVG) represents the actual tCK (AVG) of the input clock under operation.
The unit CK represents one clock cycle of the input clock, counting the actual clock
edges.
5. AC timing and IDD tests may use a VIL-to-VIH swing of up to 900mV in the test environ-
ment, but input timing is still referenced to VREF (except tIS, tIH, tDS, and tDH use the
AC/DC trip points and CK, CK# and DQS, DQS# use their crossing points). The minimum
slew rate for the input signals used to test the device is 1 V/ns for single-ended inputs
(DQs are at 2V/ns for DDR3-1866 and DDR3-2133) and 2 V/ns for differential inputs in
the range between VIL(AC) and VIH(AC).
6. All timings that use time-based values (ns, μs, ms) should use tCK (AVG) to determine the
correct number of clocks (Table 56 (page 75) uses CK or tCK [AVG] interchangeably). In
the case of noninteger results, all minimum limits are to be rounded up to the nearest
whole integer, and all maximum limits are to be rounded down to the nearest whole
integer.
7. Strobe or DQSdiff refers to the DQS and DQS# differential crossing point when DQS is
the rising edge. Clock or CK refers to the CK and CK# differential crossing point when
CK is the rising edge.
8. This output load is used for all AC timing (except ODT reference timing) and slew rates.
The actual test load may be different. The output signal voltage reference point is
VDDQ/2 for single-ended signals and the crossing point for differential signals (see Figure
2).
9. When operating in DLL disable mode, Micron does not warrant compliance with normal
mode timings or functionality.
10. The clock’s tCK (AVG) is the average clock over any 200 consecutive clocks and tCK (AVG)
MIN is the smallest clock rate allowed, with the exception of a deviation due to clock
jitter. Input clock jitter is allowed provided it does not exceed values specified and must
be of a random Gaussian distribution in nature.
11. Spread spectrum is not included in the jitter specification values. However, the input
clock can accommodate spread-spectrum at a sweep rate in the range of 20–60 kHz with
an additional 1% of tCK (AVG) as a long-term jitter component; however, the spread
spectrum may not use a clock rate below tCK (AVG) MIN.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Characteristics and AC Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
80
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 81 -->

12. The clock’s tCH (AVG) and tCL (AVG) are the average half clock period over any 200 con-
secutive clocks and is the smallest clock half period allowed, with the exception of a de-
viation due to clock jitter. Input clock jitter is allowed provided it does not exceed values
specified and must be of a random Gaussian distribution in nature.
13. The period jitter (tJITper) is the maximum deviation in the clock period from the average
or nominal clock. It is allowed in either the positive or negative direction.
14.
tCH (ABS) is the absolute instantaneous clock high pulse width as measured from one
rising edge to the following falling edge.
15.
tCL (ABS) is the absolute instantaneous clock low pulse width as measured from one fall-
ing edge to the following rising edge.
16. The cycle-to-cycle jitter tJITcc is the amount the clock period can deviate from one cycle
to the next. It is important to keep cycle-to-cycle jitter at a minimum during the DLL
locking time.
17. The cumulative jitter error tERRnper, where n is the number of clocks between 2 and 50,
is the amount of clock time allowed to accumulate consecutively away from the average
clock over n number of clock cycles.
18.
tDS (base) and tDH (base) values are for a single-ended 1 V/ns slew rate DQs (DQs are at
2V/ns for DDR3-1866 and DDR3-2133) and 2 V/ns slew rate differential DQS, DQS#; when
DQ single-ended slew rate is 2V/ns, the DQS differential slew rate is 4V/ns.
19. These parameters are measured from a data signal (DM, DQ0, DQ1, and so forth) transi-
tion edge to its respective data strobe signal (DQS, DQS#) crossing.
20. The setup and hold times are listed converting the base specification values (to which
derating tables apply) to VREF when the slew rate is 1 V/ns (DQs are at 2V/ns for
DDR3-1866 and DDR3-2133). These values, with a slew rate of 1 V/ns (DQs are at 2V/ns
for DDR3-1866 and DDR3-2133), are for reference only.
21. When the device is operated with input clock jitter, this parameter needs to be derated
by the actual tJITper (larger of tJITper (MIN) or tJITper (MAX) of the input clock (output
deratings are relative to the SDRAM input clock).
22. Single-ended signal parameter.
23. The DRAM output timing is aligned to the nominal or average clock. Most output pa-
rameters must be derated by the actual jitter error when input clock jitter is present,
even when within specification. This results in each parameter becoming larger. The fol-
lowing parameters are required to be derated by subtracting tERR10per (MAX): tDQSCK
(MIN), tLZDQS (MIN), tLZDQ (MIN), and tAON (MIN). The following parameters are re-
quired to be derated by subtracting tERR10per (MIN): tDQSCK (MAX), tHZ (MAX), tLZDQS
(MAX), tLZDQ (MAX), and tAON (MAX). The parameter tRPRE (MIN) is derated by sub-
tracting tJITper (MAX), while tRPRE (MAX) is derated by subtracting tJITper (MIN).
24. The maximum preamble is bound by tLZDQS (MAX).
25. These parameters are measured from a data strobe signal (DQS, DQS#) crossing to its re-
spective clock signal (CK, CK#) crossing. The specification values are not affected by the
amount of clock jitter applied, as these are relative to the clock signal crossing. These
parameters should be met whether clock jitter is present.
26. The tDQSCK (DLL_DIS) parameter begins CL + AL - 1 cycles after the READ command.
27. The maximum postamble is bound by tHZDQS (MAX).
28. Commands requiring a locked DLL are: READ (and RDAP) and synchronous ODT com-
mands. In addition, after any change of latency tXPDLL, timing must be met.
29.
tIS (base) and tIH (base) values are for a single-ended 1 V/ns control/command/address
slew rate and 2 V/ns CK, CK# differential slew rate.
30. These parameters are measured from a command/address signal transition edge to its
respective clock (CK, CK#) signal crossing. The specification values are not affected by
the amount of clock jitter applied as the setup and hold times are relative to the clock
signal crossing that latches the command/address. These parameters should be met
whether clock jitter is present.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Characteristics and AC Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
81
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 82 -->

31. For these parameters, the DDR3 SDRAM device supports tnPARAM (nCK) = RU(tPARAM
[ns]/tCK[AVG] [ns]), assuming all input clock jitter specifications are satisfied. For exam-
ple, the device will support tnRP (nCK) = RU(tRP/tCK[AVG]) if all input clock jitter specifi-
cations are met. This means that for DDR3-800 6-6-6, of which tRP = 5ns, the device will
support tnRP = RU(tRP/tCK[AVG]) = 6 as long as the input clock jitter specifications are
met. That is, the PRECHARGE command at T0 and the ACTIVATE command at T0 + 6 are
valid even if six clocks are less than 15ns due to input clock jitter.
32. During READs and WRITEs with auto precharge, the DDR3 SDRAM will hold off the in-
ternal PRECHARGE command until tRAS (MIN) has been satisfied.
33. When operating in DLL disable mode, the greater of 4CK or 15ns is satisfied for tWR.
34. The start of the write recovery time is defined as follows:
• For BL8 (fixed by MRS or OTF): Rising clock edge four clock cycles after WL
• For BC4 (OTF): Rising clock edge four clock cycles after WL
• For BC4 (fixed by MRS): Rising clock edge two clock cycles after WL
35. RESET# should be LOW as soon as power starts to ramp to ensure the outputs are in
High-Z. Until RESET# is LOW, the outputs are at risk of driving and could result in exces-
sive current, depending on bus activity.
36. The refresh period is 64ms when TC is less than or equal to 85°C. This equates to an aver-
age refresh rate of 7.8125μs. However, nine REFRESH commands should be asserted at
least once every 70.3μs. When TC is greater than 85°C, the refresh period is 32ms. When
TC is greater than 105°C, the refresh period is 8ms.
37. Although CKE is allowed to be registered LOW after a REFRESH command when
tREFPDEN (MIN) is satisfied, there are cases where additional time such as tXPDLL (MIN)
is required.
38. ODT turn-on time MIN is when the device leaves High-Z and ODT resistance begins to
turn on. ODT turn-on time maximum is when the ODT resistance is fully on. The ODT
reference load is shown in Figure 20 (page 55). Designs that were created prior to JEDEC
tightening the maximum limit from 9ns to 8.5ns will be allowed to have a 9ns maxi-
mum.
39. Half-clock output parameters must be derated by the actual tERR10per and tJITdty when
input clock jitter is present. This results in each parameter becoming larger. The parame-
ters tADC (MIN) and tAOF (MIN) are each required to be derated by subtracting both
tERR10per (MAX) and tJITdty (MAX). The parameters tADC (MAX) and tAOF (MAX) are
required to be derated by subtracting both tERR10per (MAX) and tJITdty (MAX).
40. ODT turn-off time minimum is when the device starts to turn off ODT resistance. ODT
turn-off time maximum is when the DRAM buffer is in High-Z. The ODT reference load is
shown in Figure 20 (page 55). This output load is used for ODT timings (see Figure 3).
41. Pulse width of a input signal is defined as the width between the first crossing of
VREF(DC) and the consecutive crossing of VREF(DC).
42. Should the clock rate be larger than tRFC (MIN), an AUTO REFRESH command should
have at least one NOP command between it and another AUTO REFRESH command. Ad-
ditionally, if the clock rate is slower than 40ns (25 MHz), all REFRESH commands should
be followed by a PRECHARGE ALL command.
43. DRAM devices should be evenly addressed when being accessed. Disproportionate ac-
cesses to a particular row address may result in a reduction of REFRESH characteristics or
product lifetime.
44. When two VIH(AC) values (and two corresponding VIL(AC) values) are listed for a specific
speed bin, the user may choose either value for the input AC level. Whichever value is
used, the associated setup time for that AC level must also be used. Additionally, one
VIH(AC) value may be used for address/command inputs and the other VIH(AC) value may
be used for data inputs.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Characteristics and AC Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
82
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 83 -->

For example, for DDR3-800, two input AC levels are defined: VIH(AC175),min and
VIH(AC150),min (corresponding VIL(AC175),min and VIL(AC150),min). For DDR3-800, the address/
command inputs must use either VIH(AC175),min with tIS(AC175) of 200ps or VIH(AC150),min
with tIS(AC150) of 350ps; independently, the data inputs must use either VIH(AC175),min
with tDS(AC175) of 75ps or VIH(AC150),min with tDS(AC150) of 125ps.
45. Self refresh is not available when TC > 105°C.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Characteristics and AC Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
83
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

