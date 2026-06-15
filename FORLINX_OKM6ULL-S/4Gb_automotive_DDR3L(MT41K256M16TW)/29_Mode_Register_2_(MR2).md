# Mode Register 2 (MR2)

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 130–132

<!-- page 130 -->

WRITE latency and AL, WL = AL + CWL (see Mode Register 2 (MR2) (page 130)). Exam-
ples of READ and WRITE latencies are shown in Figure 53 (page 130) and Figure 55
(page 131).
Figure 53: READ Latency (AL = 5, CL = 6)
CK
CK#
Command
DQ
DQS, DQS#
ACTIVE n
T0
T1
Don’t Care
NOP
NOP
T6
T12
NOP
READ n
T13
NOP
DO
n + 3
DO
n + 2
DO
n + 1
RL = AL + CL = 11
T14
NOP
DO
n
tRCD (MIN)
AL = 5
CL = 6
T11
BC4
Indicates break
in time scale
Transitioning Data
T2
NOP
Mode Register 2 (MR2)
The mode register 2 (MR2) controls additional functions and features not available in
the other mode registers. These additional functions are CAS WRITE latency (CWL), AU-
TO SELF REFRESH (ASR), SELF REFRESH TEMPERATURE (SRT), and DYNAMIC ODT
(RTT(WR)). These functions are controlled via the bits shown in Figure 54. The MR2 is
programmed via the MRS command and will retain the stored information until it is
programmed again or until the device loses power. Reprogramming the MR2 register
will not alter the contents of the memory array, provided it is performed correctly. The
MR2 register must be loaded when all banks are idle and no data bursts are in progress,
and the controller must wait the specified time tMRD and tMOD before initiating a sub-
sequent operation.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 2 (MR2)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
130
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 131 -->

Figure 54: Mode Register 2 (MR2) Definition
M14
0
1
0
1
M15
0
0
1
1
Mode Register 
Mode register set 0 (MR0)
Mode register set 1 (MR1)
Mode register set 2 (MR2)
Mode register set 3 (MR3)
A9
A7 A6
A5 A4 A3
A8
A2
A1 A0
Mode register 2 (MR2)
Address bus
9
7
6
5
4
3
8
2
1
0
A10
A12 A11
BA0
BA1
10
11
12
13
14
15
1
CWL
01
0
BA2
ASR
16
01
A13
01
01
01
01
01
01
SRT
RTT(WR)
M6
0
1
Auto Self Refresh
Disabled: Manual  
Enabled: Automatic
M7
0
1
 Self Refresh Temperature
Normal (0°C to 85°C)
Extended (0°C to 95°C)
  CAS Write Latency (CWL)
5 CK (tCK ≥2.5ns)
6 CK (2.5ns tCK ≥1.875ns)
7 CK (1.875ns tCK ≥1.5ns)
8 CK (1.5ns tCK ≥1.25ns)
9 CK (1.25ns tCK ≥1.07ns)
10 CK (1.07ns tCK ≥0.938ns)
Reserved
Reserved
M3
0
1
0
1
0
1
0
1
M4
0
0
1
1
0
0
1
1
M5
0
0
0
0
1
1
1
1
M9
0
1
0
1
M10
0
0
1
1
Dynamic ODT
(RTT(WR) )
RTT(WR) disabled
RZQ/4
RZQ/2
Reserved
Note:
1. MR2[18, 15:11, 8, and 2:0] are reserved for future use and must all be programmed to 0.
CAS WRITE Latency (CWL)
CWL is defined by MR2[5:3] and is the delay, in clock cycles, from the releasing of the
internal write to the latching of the first data in. CWL must be correctly set to the corre-
sponding operating clock frequency (see Figure 54 (page 131)). The overall WRITE la-
tency (WL) is equal to CWL + AL (Figure 52 (page 127)).
Figure 55: CAS WRITE Latency
CK
CK#
Command
DQ
DQS, DQS#
ACTIVE n
T0
T1
Don’t Care
NOP
NOP
T6
T12
NOP
WRITE n
T13
NOP
DI
 n + 3
DI
 n + 2
DI
 n + 1
T14
NOP
DI
 n
tRCD (MIN)
NOP
AL = 5
T11
Indicates break
in time scale
WL = AL + CWL = 11
Transitioning Data
T2
CWL = 6
AUTO SELF REFRESH (ASR)
Mode register MR2[6] is used to disable/enable the ASR function. When ASR is disabled,
the self refresh mode’s refresh rate is assumed to be at the normal 85°C limit (some-
times referred to as 1x refresh rate). In the disabled mode, ASR requires the user to en-
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 2 (MR2)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
131
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 132 -->

sure the DRAM never exceeds a TC of 85°C while in self refresh unless the user enables
the SRT feature listed below when the TC is between 85°C and 95°C.
Enabling ASR assumes the DRAM self refresh rate is changed automatically from 1x to
2x when the case temperature exceeds 85°C. This enables the user to operate the DRAM
beyond the standard 85°C limit up to the optional extended temperature range of 95°C
while in self refresh mode.
The standard self refresh current test specifies test conditions to normal case tempera-
ture (85°C) only, meaning if ASR is enabled, the standard self refresh current specifica-
tions do not apply (see Extended Temperature Usage).
SELF REFRESH TEMPERATURE (SRT)
Mode register MR2[7] is used to disable/enable the SRT function. When SRT is disabled,
the self refresh mode’s refresh rate is assumed to be at the normal 85°C limit (some-
times referred to as 1x refresh rate). In the disabled mode, SRT requires the user to en-
sure the DRAM never exceeds a TC of 85°C while in self refresh mode unless the user en-
ables ASR.
When SRT is enabled, the DRAM self refresh is changed internally from 1x to 2x, regard-
less of the case temperature. This enables the user to operate the DRAM beyond the
standard 85°C limit up to the optional extended temperature range of 95°C while in self
refresh mode. The standard self refresh current test specifies test conditions to normal
case temperature (85°C) only, meaning if SRT is enabled, the standard self refresh cur-
rent specifications do not apply (see Extended Temperature Usage).
SRT vs. ASR
If the normal case temperature limit of 85°C is not exceeded, then neither SRT nor ASR
is required, and both can be disabled throughout operation. However, if the extended
temperature option of 95°C is needed, the user is required to provide a 2x refresh rate
during (manual) refresh and to enable either the SRT or the ASR to ensure self refresh is
performed at the 2x rate.
SRT forces the DRAM to switch the internal self refresh rate from 1x to 2x. Self refresh is
performed at the 2x refresh rate regardless of the case temperature.
ASR automatically switches the DRAM’s internal self refresh rate from 1x to 2x. Howev-
er, while in self refresh mode, ASR enables the refresh rate to automatically adjust be-
tween 1x to 2x over the supported temperature range. One other disadvantage with ASR
is the DRAM cannot always switch from a 1x to a 2x refresh rate at an exact case temper-
ature of 85°C. Although the DRAM will support data integrity when it switches from a 1x
to a 2x refresh rate, it may switch at a lower temperature than 85°C.
Since only one mode is necessary, SRT and ASR cannot be enabled at the same time.
DYNAMIC ODT
The dynamic ODT (RTT(WR)) feature is defined by MR2[10, 9]. Dynamic ODT is enabled
when a value is selected. This new DDR3 SDRAM feature enables the ODT termination
value to change without issuing an MRS command, essentially changing the ODT ter-
mination on-the-fly.
With dynamic ODT (RTT(WR)) enabled, the DRAM switches from normal ODT (RTT,nom)
to dynamic ODT (RTT(WR)) when beginning a WRITE burst and subsequently switches
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 2 (MR2)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
132
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

