# Output Driver Impedance

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 58–63

<!-- page 58 -->

Output Driver Impedance
The output driver impedance is selected by MR1[5,1] during initialization. The selected
value is able to maintain the tight tolerances specified if proper ZQ calibration is per-
formed. Output specifications refer to the default output driver unless specifically sta-
ted otherwise. A functional representation of the output buffer is shown below. The out-
put driver impedance RON is defined by the value of the external reference resistor RZQ
as follows:
• RON,x = RZQ/y (with RZQ = 240Ω ±1%; x = 34Ω or 40Ω with y = 7 or 6, respectively)
The individual pull-up and pull-down resistors RON(PU) and RON(PD) are defined as fol-
lows:
• RON(PU) = (VDDQ - VOUT)/|IOUT|, when RON(PD) is turned off
• RON(PD) = (VOUT)/|IOUT|, when RON(PU) is turned off
Figure 24: Output Driver
RON(PU)
RON(PD)
Output driver
To
other
circuitry
such as
RCV, . . .
Chip in drive mode
VDDQ
VSSQ
IPU
IPD
IOUT
VOUT
DQ
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Driver Impedance
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
58
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 59 -->

34 Ohm Output Driver Impedance
The 34Ω driver (MR1[5, 1] = 01) is the default driver. Unless otherwise stated, all timings
and specifications listed herein apply to the 34Ω driver only. Its impedance RON is de-
fined by the value of the external reference resistor RZQ as follows: RON34 = RZQ/7 (with
nominal RZQ = 240Ω ±1%) and is actually 34.3Ω ±1%.
Table 36: DDR3L 34 Ohm Driver Impedance Characteristics
MR1
[5, 1]
RON
Resistor
VOUT
Min
Nom
Max
Units
0, 1
Ω
RON,34PD
0.2 × VDDQ
0.6
1.0
1.15
RZQ/7
0.5 × VDDQ
0.9
1.0
1.15
RZQ/7
0.8 × VDDQ
0.9
1.0
1.45
RZQ/7
RON,34PU
0.2 × VDDQ
0.9
1.0
1.45
RZQ/7
0.5 × VDDQ
0.9
1.0
1.15
RZQ/7
0.8 × VDDQ
0.6
1.0
1.15
RZQ/7
Pull-up/pull-down mismatch (MMPUPD)
VIL(AC) to VIH(AC)
–10
N/A
10
%
Notes:
1. Tolerance limits assume RZQ of 240Ω ±1% and are applicable after proper ZQ calibra-
tion has been performed at a stable temperature and voltage: VDDQ = VDD; VSSQ = VSS).
Refer to DDR3L 34 Ohm Output Driver Sensitivity (page 61) if either the temperature
or the voltage changes after calibration.
2. Measurement definition for mismatch between pull-up and pull-down (MMPUPD). Meas-
ure both RON(PU) and RON(PD) at 0.5 × VDDQ:
MMPUPD = 
 
× 100
RON(PU) - RON(PD)
RON,nom
3. For IT and AT (1Gb only) devices, the minimum values are derated by 6% when the de-
vice operates between –40°C and 0°C (TC).
A larger maximum limit will result in slightly lower minimum currents.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Driver Impedance
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
59
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 60 -->

DDR3L 34 Ohm Driver
Using Table 37, the 34Ω driver’s current range has been calculated and summarized in 
Table 38 (page 60) VDD = 1.35V, Table 39 for VDD = 1.45V, and Table 40 (page 61) for
VDD = 1.283V. The individual pull-up and pull-down resistors RON34(PD) and RON34(PU)
are defined as follows:
• RON34(PD) = (VOUT)/|IOUT|; RON34(PU) is turned off
• RON34(PU) = (VDDQ - VOUT)/|IOUT|; RON34(PD) is turned off
Table 37: DDR3L 34 Ohm Driver Pull-Up and Pull-Down Impedance Calculations
RON
Min
Nom
Max
Unit
RZQ = 240Ω 
237.6
240
242.4
Ω
RZQ/7 = (240Ω 
33.9
34.3
34.6
Ω
MR1[5,1]
RON
Resistor
VOUT
Min
Nom
Max
Unit
0, 1
Ω
RON34(PD)
0.2 × VDDQ
20.4
34.3
38.1
Ω
0.5 × VDDQ
30.5
34.3
38.1
Ω
0.8 × VDDQ
30.5
34.3
48.5
Ω
RON34(PU)
0.2 × VDDQ
30.5
34.3
48.5
Ω
0.5 × VDDQ
30.5
34.3
38.1
Ω
0.8 × VDDQ
20.4
34.3
38.1
Ω
Table 38: DDR3L 34 Ohm Driver IOH/IOL Characteristics: VDD = VDDQ = DDR3L@1.35V
MR1[5,1]
RON
Resistor
VOUT
Max
Nom
Min
Unit
0, 1
Ω
RON34(PD)
IOL @ 0.2 × VDDQ
13.3
7.9
7.1
mA
IOL @ 0.5 × VDDQ
22.1
19.7
17.7
mA
IOL @ 0.8 × VDDQ
35.4
31.5
22.3
mA
RON34(PU)
IOH @ 0.2 × VDDQ
35.4
31.5
22.3
mA
IOH @ 0.5 × VDDQ
22.1
19.7
17.7
mA
IOH @ 0.8 × VDDQ
13.3
7.9
7.1
mA
Table 39: DDR3L 34 Ohm Driver IOH/IOL Characteristics: VDD = VDDQ = DDR3L@1.45V
MR1[5,1]
RON
Resistor
VOUT
Max
Nom
Min
Unit
0, 1
Ω
RON34(PD)
IOL @ 0.2 × VDDQ
14.2
8.5
7.6
mA
IOL @ 0.5 × VDDQ
23.7
21.1
19.0
mA
IOL @ 0.8 × VDDQ
38.0
33.8
23.9
mA
RON34(PU)
IOH @ 0.2 × VDDQ
38.0
33.8
23.9
mA
IOH @ 0.5 × VDDQ
23.7
21.1
19.0
mA
IOH @ 0.8 × VDDQ
14.2
8.5
7.6
mA
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Driver Impedance
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
60
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 61 -->

Table 40: DDR3L 34 Ohm Driver IOH/IOL Characteristics: VDD = VDDQ = DDR3L@1.283
MR1[5,1]
RON
Resistor
VOUT
Max
Nom
Min
Unit
0, 1
Ω
RON34(PD)
IOL @ 0.2 × VDDQ
12.6
7.5
6.7
mA
IOL @ 0.5 × VDDQ
21.0
18.7
16.8
mA
IOL @ 0.8 × VDDQ
33.6
29.9
21.2
mA
RON34(PU)
IOH @ 0.2 × VDDQ
33.6
29.9
21.2
mA
IOH @ 0.5 × VDDQ
21.0
18.7
16.8
mA
IOH @ 0.8 × VDDQ
12.6
7.5
6.7
mA
DDR3L 34 Ohm Output Driver Sensitivity
If either the temperature or the voltage changes after ZQ calibration, then the tolerance
limits listed in Table 36 (page 59) can be expected to widen according to Table 41 and 
Table 42.
Table 41: DDR3L 34 Ohm Output Driver Sensitivity Definition
Symbol
Min
Max
Unit
RON(PD) @ 0.2 × VDDQ
0.6 - dRONdTL × |ΔT| - dRONdVL × |ΔV|
1.1 + dRONdTL × |ΔT| + dRONdVL × |ΔV|
RZQ/7
RON(PD) @ 0.5 × VDDQ
0.9 - dRONdTM × |ΔT| - dRONdVM × |ΔV|
1.1 + dRONdTM × |ΔT| + dRONdVM × |ΔV|
RZQ/7
RON(PD) @ 0.8 × VDDQ
0.9 - dRONdTH × |ΔT| - dRONdVH × |ΔV|
1.4 + dRONdTH × |ΔT| + dRONdVH × |ΔV|
RZQ/7
RON(PU) @ 0.2 × VDDQ
0.9 - dRONdTL × |ΔT| - dRONdVL × |ΔV|
1.4 + dRONdTL × |ΔT| + dRONdVL × |ΔV|
RZQ/7
RON(PU) @ 0.5 × VDDQ
0.9 - dRONdTM × |ΔT| - dRONdVM × |ΔV|
1.1 + dRONdTM × |ΔT| + dRONdVM × |ΔV|
RZQ/7
RON(PU) @ 0.8 × VDDQ
0.6 - dRONdTH × |ΔT| - dRONdVH × |ΔV|
1.1 + dRONdTH × |ΔT| + dRONdVH × |ΔV|
RZQ/7
Note:
1. ΔT = T - T(@CALIBRATION)ΔV = VDDQ - VDDQ(@CALIBRATION); and VDD = VDDQ.
Table 42: DDR3L 34 Ohm Output Driver Voltage and Temperature Sensitivity
Change
Min
Max
Unit
dRONdTM
0
1.5
%/°C
dRONdVM
0
0.13
%/mV
dRONdTL
0
1.5
%/°C
dRONdVL
0
0.13
%/mV
dRONdTH
0
1.5
%/°C
dRONdVH
0
0.13
%/mV
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Driver Impedance
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
61
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 62 -->

DDR3L Alternative 40 Ohm Driver
Table 43: DDR3L 40 Ohm Driver Impedance Characteristics
MR1
[5, 1]
RON
Resistor
VOUT
Min
Nom
Max
Units
0, 0
Ω
RON,40PD
0.2 × VDDQ
0.6
1.0
1.15
RZQ/6
0.5 × VDDQ
0.9
1.0
1.15
RZQ/6
0.8 × VDDQ
0.9
1.0
1.45
RZQ/6
RON,40PU
0.2 × VDDQ
0.9
1.0
1.45
RZQ/6
0.5 × VDDQ
0.9
1.0
1.15
RZQ/6
0.8 × VDDQ
0.6
1.0
1.15
RZQ/6
Pull-up/pull-down mismatch (MMPUPD)
VIL(AC) to VIH(AC)
–10
N/A
10
%
Notes:
1. Tolerance limits assume RZQ of 240Ω ±1% and are applicable after proper ZQ calibra-
tion has been performed at a stable temperature and voltage (VDDQ = VDD; VSSQ = VSS).
Refer to DDR3L 40 Ohm Output Driver Sensitivity (page 62) if either the temperature
or the voltage changes after calibration.
2. Measurement definition for mismatch between pull-up and pull-down (MMPUPD). Meas-
ure both RON(PU) and RON(PD) at 0.5 × VDDQ:
MMPUPD = 
 
× 100
RON(PU) - RON(PD)
RON,nom
3. For IT and AT (1Gb only) devices, the minimum values are derated by 6% when the de-
vice operates between –40°C and 0°C (TC).
A larger maximum limit will result in slightly lower minimum currents.
DDR3L 40 Ohm Output Driver Sensitivity
If either the temperature or the voltage changes after I/O calibration, then the tolerance
limits listed in Table 43 can be expected to widen according to Table 44 and Table 45
(page 63).
Table 44: DDR3L 40 Ohm Output Driver Sensitivity Definition
Symbol
Min
Max
Unit
RON(PD) @ 0.2 × VDDQ
0.6 - dRONdTL × |ΔT| - dRONdVL × |ΔV|
1.1 + dRONdTL × |ΔT| + dRONdVL × |ΔV|
RZQ/6
RON(PD) @ 0.5 × VDDQ
0.9 - dRONdTM × |ΔT| - dRONdVM × |ΔV|
1.1 + dRONdTM × |ΔT| + dRONdVM × |ΔV|
RZQ/6
RON(PD) @ 0.8 × VDDQ
0.9 - dRONdTH × |ΔT| - dRONdVH × |ΔV|
1.4 + dRONdTH × |ΔT| + dRONdVH × |ΔV|
RZQ/6
RON(PU) @ 0.2 × VDDQ
0.9 - dRONdTL × |ΔT| - dRONdVL × |ΔV|
1.4 + dRONdTL × |ΔT| + dRONdVL × |ΔV|
RZQ/6
RON(PU) @ 0.5 × VDDQ
0.9 - dRONdTM × |ΔT| - dRONdVM × |ΔV|
1.1 + dRONdTM × |ΔT| + dRONdVM × |ΔV|
RZQ/6
RON(PU) @ 0.8 × VDDQ
0.6 - dRONdTH × |ΔT| - dRONdVH × |ΔV|
1.1 + dRONdTH × |ΔT| + dRONdVH × |ΔV|
RZQ/6
Note:
1. ΔT = T - T(@CALIBRATION)ΔV = VDDQ - VDDQ(@CALIBRATION); and VDD = VDDQ.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Driver Impedance
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
62
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 63 -->

Table 45: 40 Ohm Output Driver Voltage and Temperature Sensitivity
Change
Min
Max
Unit
dRONdTM
0
1.5
%/°C
dRONdVM
0
0.15
%/mV
dRONdTL
0
1.5
%/°C
dRONdVL
0
0.15
%/mV
dRONdTH
0
1.5
%/°C
dRONdVH
0
0.15
%/mV
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Output Driver Impedance
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
63
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

