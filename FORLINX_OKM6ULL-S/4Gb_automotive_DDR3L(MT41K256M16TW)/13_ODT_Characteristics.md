# ODT Characteristics

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 52–57

<!-- page 52 -->

ODT Characteristics
The ODT effective resistance RTT is defined by MR1[9, 6, and 2]. ODT is applied to the
DQ, DM, DQS, DQS#, and TDQS, TDQS# balls (x8 devices only). The ODT target values
and a functional representation are listed in Table 30 and Table 31 (page 53). The indi-
vidual pull-up and pull-down resistors (RTT(PU) and RTT(PD)) are defined as follows:
• RTT(PU) = (VDDQ - VOUT)/|IOUT|, under the condition that RTT(PD) is turned off
• RTT(PD) = (VOUT)/|IOUT|, under the condition that RTT(PU) is turned off
Figure 19: ODT Levels and I-V Characteristics
RTT(PU)
RTT(PD)
ODT
Chip in termination mode
VDDQ
DQ
VSSQ
IOUT = IPD - IPU
IPU
IPD
IOUT
VOUT
To
other
circuitry
such as 
RCV, . . .
Table 30: On-Die Termination DC Electrical Characteristics
Parameter/Condition
Symbol
Min
Nom
Max
Unit
Notes
RTT effective impedance
RTT(EFF)
See Table 31 (page 53)
1, 2
Deviation of VM with respect to
VDDQ/2
ΔVM
–5
 
5
%
1, 2, 3
Notes:
1. Tolerance limits are applicable after proper ZQ calibration has been performed at a
stable temperature and voltage (VDDQ = VDD, VSSQ = VSS). Refer to ODT Sensitivity (page
54) if either the temperature or voltage changes after calibration.
2. Measurement definition for RTT: Apply VIH(AC) to pin under test and measure current
I[VIH(AC)], then apply VIL(AC) to pin under test and measure current I[VIL(AC)]:
RTT = 
VIH(AC) - VIL(AC)
I(VIH(AC)) - I(VIL(AC)) 
3. Measure voltage (VM) at the tested pin with no load:
ΔVM = 
– 1
2 × VM
VDDQ
× 100
4. For IT and AT devices, the minimum values are derated by 6% when the device operates
between –40°C and 0°C (TC).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
ODT Characteristics
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
52
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 53 -->

1.35V ODT Resistors
Table 31 provides an overview of the ODT DC electrical characteristics. The values pro-
vided are not specification requirements; however, they can be used as design guide-
lines to indicate what RTT is targeted to provide:
• RTT 120Ω is made up of RTT120(PD240) and RTT120(PU240)
• RTT 60Ω is made up of RTT60(PD120) and RTT60(PU120)
• RTT 40Ω is made up of RTT40(PD80) and RTT40(PU80)
• RTT 30Ω is made up of RTT30(PD60) and RTT30(PU60)
• RTT 20Ω is made up of RTT20(PD40) and RTT20(PU40)
Table 31: 1.35V RTT Effective Impedance
MR1
[9, 6, 2]
RTT
Resistor
VOUT
Min
Nom
Max
Units
0, 1, 0
Ω
RTT,120PD240
0.2 × VDDQ
0.6
1.0
1.15
RZQ/1
0.5 × VDDQ
0.9
1.0
1.15
RZQ/1
0.8 × VDDQ
0.9
1.0
1.45
RZQ/1
RTT,120PU240
0.2 × VDDQ
0.9
1.0
1.45
RZQ/1
0.5 × VDDQ
0.9
1.0
1.15
RZQ/1
0.8 × VDDQ
0.6
1.0
1.15
RZQ/1
Ω
VIL(AC) to VIH(AC)
0.9
1.0
1.65
RZQ/2
0, 0, 1
Ω
RTT,60PD120
0.2 × VDDQ
0.6
1.0
1.15
RZQ/2
0.5 × VDDQ
0.9
1.0
1.15
RZQ/2
0.8 × VDDQ
0.9
1.0
1.45
RZQ/2
RTT,60PU120
0.2 × VDDQ
0.9
1.0
1.45
RZQ/2
0.5 × VDDQ
0.9
1.0
1.15
RZQ/2
0.8 × VDDQ
0.6
1.0
1.15
RZQ/2
Ω
VIL(AC) to VIH(AC)
0.9
1.0
1.65
RZQ/4
0, 1, 1
Ω
RTT,40PD80
0.2 × VDDQ
0.6
1.0
1.15
RZQ/3
0.5 × VDDQ
0.9
1.0
1.15
RZQ/3
0.8 × VDDQ
0.9
1.0
1.45
RZQ/3
RTT,40PU80
0.2 × VDDQ
0.9
1.0
1.45
RZQ/3
0.5 × VDDQ
0.9
1.0
1.15
RZQ/3
0.8 × VDDQ
0.6
1.0
1.15
RZQ/3
Ω
VIL(AC) to VIH(AC)
0.9
1.0
1.65
RZQ/6
1, 0, 1
Ω
RTT,30PD60
0.2 × VDDQ
0.6
1.0
1.15
RZQ/4
0.5 × VDDQ
0.9
1.0
1.15
RZQ/4
0.8 × VDDQ
0.9
1.0
1.45
RZQ/4
RTT,30PU60
0.2 × VDDQ
0.9
1.0
1.45
RZQ/4
0.5 × VDDQ
0.9
1.0
1.15
RZQ/4
0.8 × VDDQ
0.6
1.0
1.15
RZQ/4
Ω
VIL(AC) to VIH(AC)
0.9
1.0
1.65
RZQ/8
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
ODT Characteristics
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
53
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 54 -->

Table 31: 1.35V RTT Effective Impedance (Continued)
MR1
[9, 6, 2]
RTT
Resistor
VOUT
Min
Nom
Max
Units
1, 0, 0
Ω
RTT,20PD40
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
RTT,20PU40
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
Ω
VIL(AC) to VIH(AC)
0.9
1.0
1.65
RZQ/12
ODT Sensitivity
If either the temperature or voltage changes after I/O calibration, then the tolerance
limits listed in Table 30 and Table 31 can be expected to widen according to Table 32
and Table 33.
Table 32: ODT Sensitivity Definition
Symbol
Min
Max
Unit
RTT
0.9 - dRTTdT × |DT| - dRTTdV × |DV|
1.6 + dRTTdT × |DT| + dRTTdV × |DV|
RZQ/(2, 4, 6, 8, 12)
Note:
1. ΔT = T - T(@ calibration), ΔV = VDDQ - VDDQ(@ calibration) and VDD = VDDQ.
Table 33: ODT Temperature and Voltage Sensitivity
Change
Min
Max
Unit
dRTTdT
0
1.5
%/°C
dRTTdV
0
0.15
%/mV
Note:
1. ΔT = T - T(@ calibration), ΔV = VDDQ - VDDQ(@ calibration) and VDD = VDDQ.
ODT Timing Definitions
ODT loading differs from that used in AC timing measurements. The reference load for
ODT timings is shown in Figure 20. Two parameters define when ODT turns on or off
synchronously, two define when ODT turns on or off asynchronously, and another de-
fines when ODT turns on or off dynamically. Table 34 and Table 35 (page 55) outline
and provide definition and measurement references settings for each parameter.
ODT turn-on time begins when the output leaves High-Z and ODT resistance begins to
turn on. ODT turn-off time begins when the output leaves Low-Z and ODT resistance
begins to turn off.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
ODT Characteristics
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
54
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 55 -->

Figure 20: ODT Timing Reference Load
Timing reference point
DQ, DM
DQS, DQS#
TDQS, TDQS#
DUT
VREF
VTT = VSSQ
VDDQ/2
ZQ
RZQ = 240Ω
VSSQ 
RTT = 25Ω
CK, CK#
Table 34: ODT Timing Definitions
Symbol
Begin Point Definition
End Point Definition
Figure
tAON
Rising edge of CK – CK# defined by the end
point of ODTLon
Extrapolated point at VSSQ
Figure 21 (page 56)
tAOF
Rising edge of CK – CK# defined by the end
point of ODTLoff
Extrapolated point at VRTT,nom
Figure 21 (page 56)
tAONPD
Rising edge of CK – CK# with ODT first being
registered HIGH
Extrapolated point at VSSQ
Figure 22 (page 56)
tAOFPD
Rising edge of CK – CK# with ODT first being
registered LOW
Extrapolated point at VRTT,nom
Figure 22 (page 56)
tADC
Rising edge of CK – CK# defined by the end
point of ODTLcnw, ODTLcwn4, or ODTLcwn8
Extrapolated points at VRTT(WR) and
VRTT,nom
Figure 23 (page 57)
Table 35: DDR3L(1.35V) Reference Settings for ODT Timing Measurements
Measured
Parameter
RTT,nom Setting
RTT(WR) Setting
VSW1
VSW2
tAON
RZQ/4 (60Ω
N/A
50mV
100mV
RZQ/12 (20Ω
N/A
100mV
200mV
tAOF
RZQ/4 (60Ω
N/A
50mV
100mV
RZQ/12 (20Ω
N/A
100mV
200mV
tAONPD
RZQ/4 (60Ω
N/A
50mV
100mV
RZQ/12 (20Ω
N/A
100mV
200mV
tAOFPD
RZQ/4 (60Ω
N/A
50mV
100mV
RZQ/12 (20Ω
N/A
100mV
200mV
tADC
RZQ/12 (20Ω
RZQ/2 (20Ω
200mV
250mV
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
ODT Characteristics
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
55
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 56 -->

Figure 21: tAON and tAOF Definitions
CK
CK#
tAON
VSSQ
DQ, DM
DQS, DQS#
TDQS, TDQS#
Begin point: Rising edge of CK - CK# 
defined by the end point of ODTLon
VSW1
End point: Extrapolated point at VSSQ
TSW1
TSW2
CK
CK#
VDDQ/2
tAOF
Begin point: Rising edge of CK - CK# 
defined by the end point of ODTLoff
End point: Extrapolated point at VRTT,nom
VRTT,nom
VSSQ
tAON
tAOF
VSW2
VSW2
VSW1
TSW1
TSW1
Figure 22: tAONPD and tAOFPD Definitions
CK
CK#
tAONPD
VSSQ
DQ, DM 
DQS, DQS# 
TDQS, TDQS#
Begin point: Rising edge of CK - CK# 
with ODT first registered high
VSW1
End point: Extrapolated point at VSSQ
TSW2
CK
CK#
VDDQ/2
tAOFPD
Begin point: Rising edge of CK - CK# 
with ODT first registered low
End point: Extrapolated point at VRTT,nom
VRTT,nom
VSSQ
tAONPD
tAOFPD
TSW1
TSW2
TSW1
VSW2
VSW2
VSW1
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
ODT Characteristics
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
56
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 57 -->

Figure 23: tADC Definition
CK
CK#
tADC
DQ, DM 
DQS, DQS# 
TDQS, TDQS#
End point: 
Extrapolated 
point at VRTT,nom
TSW21
tADC
End point: Extrapolated point at VRTT(WR)
VDDQ/2
VSSQ
VRTT,nom
VRTT(WR)
VRTT,nom
Begin point: Rising edge of CK - CK# 
defined by the end point of ODTLcnw
Begin point: Rising edge of CK - CK# defined by 
the end point of ODTLcwn4 or ODTLcwn8
TSW11
VSW1
VSW2
TSW12
TSW22
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
ODT Characteristics
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
57
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

