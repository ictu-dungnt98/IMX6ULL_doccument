# Output Characteristics and Operating Conditions

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 64–69

<!-- page 64 -->

Output Characteristics and Operating Conditions
Table 46: DDR3L Single-Ended Output Driver Characteristics
All voltages are referenced to VSS
Parameter/Condition
Symbol
Min
Max
Unit
Notes
Output leakage current: DQ are disabled;
0V ≤ VOUT ≤ VDDQ; ODT is disabled; ODT is HIGH
IOZ
–5
5
μA
1
Output slew rate: Single-ended; For rising and falling edges,
measure between VOL(AC) = VREF - 0.09 × VDDQ and VOH(AC) =
VREF + 0.09 × VDDQ
SRQse
1.75
6
V/ns
1, 2, 3, 4
Single-ended DC high-level output voltage
VOH(DC)
0.8 × VDDQ
V
1, 2, 5
Single-ended DC mid-point level output voltage
VOM(DC)
0.5 × VDDQ
V
1, 2, 5
Single-ended DC low-level output voltage
VOL(DC)
0.2 × VDDQ
V
1, 2, 5
Single-ended AC high-level output voltage
VOH(AC)
VTT + 0.1 × VDDQ
V
1, 2, 3, 6
Single-ended AC low-level output voltage
VOL(AC)
VTT - 0.1 × VDDQ
V
1, 2, 3, 6
Delta RON between pull-up and pull-down for DQ/DQS
MMPUPD
–10
10
%
1, 7
Test load for AC timing and output slew rates
Output to VTT (VDDQ/2) via 25Ω resistor
3
Notes:
1. RZQ of 240Ω ±1% with RZQ/7 enabled (default 34Ω driver) and is applicable after prop-
er ZQ calibration has been performed at a stable temperature and voltage (VDDQ = VDD;
VSSQ = VSS).
2. VTT = VDDQ/2.
3. See Figure 27 (page 67) for the test load configuration.
4. The 6 V/ns maximum is applicable for a single DQ signal when it is switching either from
HIGH to LOW or LOW to HIGH while the remaining DQ signals in the same byte lane are
either all static or all switching in the opposite direction. For all other DQ signal switch-
ing combinations, the maximum limit of 6 V/ns is reduced to 5 V/ns.
5. See Figure 24 (page 58) for IV curve linearity. Do not use AC test load.
6. See Slew Rate Definitions for Single-Ended Output Signals (page 67) for output slew
rate.
7. See Figure 24 (page 58) for additional information.
8. See Figure 25 (page 65) for an example of a single-ended output signal.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Characteristics and Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
64
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 65 -->

Figure 25: DQ Output Signal
VOH(AC)
MIN output
MAX output
VOL(AC) 
Table 47: DDR3L Differential Output Driver Characteristics
All voltages are referenced to VSS
Parameter/Condition
Symbol
Min
Max
Unit
Notes
Output leakage current: DQ are disabled;
0V ≤ VOUT ≤ VDDQ; ODT is disabled; ODT is HIGH
IOZ
–5
5
μA
1
DDR3L Output slew rate: Differential; For rising and fall-
ing edges, measure between VOL,diff(AC) = –0.18 × VDDQ
and VOH,diff(AC) = 0.18 × VDDQ
SRQdiff
3.5
12
V/ns
1
Differential high-level output voltage
VOH,diff(AC)
+0.2 × VDDQ
V
1, 4
Differential low-level output voltage
VOL,diff(AC)
–0.2 × VDDQ
V
1, 4
Delta Ron between pull-up and pull-down for DQ/DQS
MMPUPD
–10
10
%
1, 5
Test load for AC timing and output slew rates
Output to VTT (VDDQ/2) via 25Ω resistor
3
Notes:
1. RZQ of 240Ω ±1% with RZQ/7 enabled (default 34Ω driver) and is applicable after prop-
er ZQ calibration has been performed at a stable temperature and voltage (VDDQ = VDD;
VSSQ = VSS).
2. VREF = VDDQ/2; slew rate @ 5 V/ns, interpolate for faster slew rate.
3. See Figure 27 (page 67) for the test load configuration.
4. See Table 50 (page 69) for the output slew rate.
5. See Table 36 (page 59) for additional information.
6. See Figure 26 (page 66) for an example of a differential output signal.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Characteristics and Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
65
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 66 -->

Table 48: DDR3L Differential Output Driver Characteristics VOX(AC)
All voltages are referenced to VSS
Parameter/
Condition
Symbol
DDR3L- 800/1066/1333 DQS/DQS# Differential Slew Rate
Unit
3.5V/ns
4V/ns
5V/ns
6V/ns
7V/ns
8V/ns
9V/ns
10V/ns
12V/ns
Output differential
crosspoint voltage
VOX(AC)
Max
115
130
135
195
205
205
205
205
205
mV
Min
–115
–130
–135
–195
–205
–205
–205
–205
–205
mV
Parameter/
Condition
Symbol
DDR3L-1600/1866/2133 DQS/DQS# Differential Slew Rate
Unit
3.5V/ns
4V/ns
5v/ns
6V/ns
7V/ns
8V/ns
9V/ns
10V/ns
12V/ns
Output differential
crosspoint voltage
VOX(AC)
Max
90
105
135
155
180
205
205
205
205
mV
Min
–90
–105
–135
–155
–180
–205
–205
–205
–205
mV
Notes:
1. RZQ of 240Ω ±1% with RZQ/7 enabled (default 34Ω driver) and is applicable after prop-
er ZQ calibration has been performed at a stable temperature and voltage (VDDQ = VDD;
VSSQ = VSS).
2. See Figure 27 (page 67) for the test load configuration.
3. See Figure 26 (page 66) for an example of a differential output signal.
4. For a differential slew rate between the list values, the VOX(AC) value may be obtained
by linear interpolation.
Figure 26: Differential Output Signal
VOH
MIN output
MAX output
VOL
VOX(AC)max
VOX(AC)min
X
X
X
X
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Characteristics and Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
66
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 67 -->

Reference Output Load
Figure 27 (page 67) represents the effective reference load of 25Ω used in defining the
relevant device AC timing parameters (except ODT reference timing) as well as the out-
put slew rate measurements. It is not intended to be a precise representation of a partic-
ular system environment or a depiction of the actual load presented by a production
tester. System designers should use IBIS or other simulation tools to correlate the tim-
ing reference load to a system environment.
Figure 27: Reference Output Load for AC Timing and Output Slew Rate
Timing reference point
DQ
DQS
DQS#
DUT
VREF
VTT = VDDQ/2
VDDQ/2
ZQ
RZQ = 240ȍ
VSS 
RTT = 25ȍ
Slew Rate Definitions for Single-Ended Output Signals
The single-ended output driver is summarized in Table 46 (page 64). With the reference
load for timing measurements, the output slew rate for falling and rising edges is de-
fined and measured between VOL(AC) and VOH(AC) for single-ended signals.
Table 49: Single-Ended Output Slew Rate Definition
Single-Ended Output Slew
Rates (Linear Signals)
Measured
Calculation
Output
Edge
From
To
DQ
Rising
VOL(AC)
VOH(AC)
VOH(AC) - VOL(AC)
ΔTRse
Falling
VOH(AC)
VOL(AC)
VOH(AC) - VOL(AC)
ΔTFse
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Characteristics and Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
67
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 68 -->

Figure 28: Nominal Slew Rate Definition for Single-Ended Output Signals
VOH(AC)
VOL(AC)
VTT
ΔTFse
ΔTRse
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Characteristics and Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
68
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 69 -->

Slew Rate Definitions for Differential Output Signals
The differential output driver is summarized in Table 47 (page 65). With the reference
load for timing measurements, the output slew rate for falling and rising edges is de-
fined and measured between VOL(AC) and VOH(AC) for differential signals.
Table 50: Differential Output Slew Rate Definition
Differential Output Slew
Rates (Linear Signals)
Measured
Calculation
Output
Edge
From
To
DQS, DQS#
Rising
VOL,diff(AC)
VOH,diff(AC)
VOH,diff(AC) - VOL,diff(AC)
ΔTRdiff
Falling
VOH,diff(AC)
VOL,diff(AC)
VOH,diff(AC) - VOL,diff(AC)
ΔTFdiff
Figure 29: Nominal Differential Output Slew Rate Definition for DQS, DQS#
ΔTRdiff
ΔTFdiff
VOH,diff(AC)
VOL,diff(AC)
0
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Characteristics and Operating Conditions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
69
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

