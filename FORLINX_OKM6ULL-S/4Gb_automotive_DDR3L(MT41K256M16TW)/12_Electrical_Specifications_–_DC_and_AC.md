# Electrical Specifications – DC and AC

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 41–51

<!-- page 41 -->

Electrical Specifications – DC and AC
DC Operating Conditions
Table 21: DDR3L 1.35V DC Electrical Characteristics and Operating Conditions
All voltages are referenced to VSS
Parameter/Condition
Symbol
Min
Nom
Max
Unit
Notes
Supply voltage
VDD
1.283
1.35
1.45
V
1–7
I/O supply voltage
VDDQ
1.283
1.35
1.45
V
1–7
Input leakage current
Any input 0V ≤ VIN ≤ VDD, VREF pin 0V ≤ VIN ≤ 1.1V
(All other pins not under test = 0V)
II
–2
–
2
μA
 
VREF supply leakage current
VREFDQ = VDD/2 or VREFCA = VDD/2
(All other pins not under test = 0V)
IVREF
–1
–
1
μA
8, 9
Notes:
1. VDD and VDDQ must track one another. VDDQ must be ≤ VDD. VSS = VSSQ.
2. VDD and VDDQ may include AC noise of ±50mV (250 kHz to 20 MHz) in addition to the
DC (0 Hz to 250 kHz) specifications. VDD and VDDQ must be at same level for valid AC
timing parameters.
3. Maximum DC value may not be greater than 1.425V. The DC value is the linear average
of VDD/VDDQ(t) over a very long period of time (for example, 1 second).
4. Under these supply voltages, the device operates to this DDR3L specification.
5. If the maximum limit is exceeded, input levels shall be governed by DDR3 specifications.
6. Under 1.5V operation, this DDR3L device operates in accordance with the DDR3 specifi-
cations under the same speed timings as defined for this device.
7. Once initialized for DDR3L operation, DDR3 operation may only be used if the device is
in reset while VDD and VDDQ are changed for DDR3 operation (see VDD Voltage Switch-
ing (page 120)).
8. The minimum limit requirement is for testing purposes. The leakage current on the VREF
pin should be minimal.
9. VREF (see Table 22).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – DC and AC
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
41
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 42 -->

Input Operating Conditions
Table 22: DDR3L 1.35V DC Electrical Characteristics and Input Conditions
All voltages are referenced to VSS
Parameter/Condition
Symbol
Min
Nom
Max
Unit
Notes
VIN low; DC/commands/address busses
VIL
VSS
N/A
See Table 23
V
 
VIN high; DC/commands/address busses
VIH
See Table 23
N/A
VDD
V
 
Input reference voltage command/address bus
VREFCA(DC)
0.49 × VDD
0.5 × VDD
0.51 × VDD
V
1, 2
I/O reference voltage DQ bus
VREFDQ(DC)
0.49 × VDD
0.5 × VDD
0.51 × VDD
V
2, 3
I/O reference voltage DQ bus in SELF REFRESH
VREFDQ(SR)
VSS
0.5 × VDD
VDD
V
4
Command/address termination voltage
(system level, not direct DRAM input)
VTT
–
0.5 × VDDQ
–
V
5
Notes:
1. VREFCA(DC) is expected to be approximately 0.5 × VDD and to track variations in the DC
level. Externally generated peak noise (non-common mode) on VREFCA may not exceed
±1% × VDD around the VREFCA(DC) value. Peak-to-peak AC noise on VREFCA should not ex-
ceed ±2% of VREFCA(DC).
2. DC values are determined to be less than 20 MHz in frequency. DRAM must meet specifi-
cations if the DRAM induces additional AC noise greater than 20 MHz in frequency.
3. VREFDQ(DC) is expected to be approximately 0.5 × VDD and to track variations in the DC
level. Externally generated peak noise (non-common mode) on VREFDQ may not exceed
±1% × VDD around the VREFDQ(DC) value. Peak-to-peak AC noise on VREFDQ should not ex-
ceed ±2% of VREFDQ(DC).
4. VREFDQ(DC) may transition to VREFDQ(SR) and back to VREFDQ(DC) when in SELF REFRESH,
within restrictions outlined in the SELF REFRESH section.
5. VTT is not applied directly to the device. VTT is a system supply for signal termination re-
sistors. Minimum and maximum values are system-dependent.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – DC and AC
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
42
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 43 -->

Table 23: DDR3L 1.35V Input Switching Conditions – Command and Address
Parameter/Condition
Symbol
DDR3L-800/1066
DDR3L-1333/1600
DDR3L-1866/2133
Units
Command and Address
Input high AC voltage: Logic 1
VIH(AC160),min5
160
160
–
mV
VIH(AC135),min5
135
135
135
mV
VIH(AC125),min5
–
–
125
mV
Input high DC voltage: Logic 1
VIH(DC90),min
90
90
90
mV
Input low DC voltage: Logic 0
VIL(DC90),min
–90
–90
–90
mV
Input low AC voltage: Logic 0
VIL(AC125),min5
–
–
–125
mV
VIL(AC135),min5
–135
–135
–135
mV
VIL(AC160),min5
–160
–160
–
mV
DQ and DM
Input high AC voltage: Logic 1
VIH(AC160),min5
160
160
–
mV
VIH(AC135),min5
135
135
135
mV
VIH(AC125),min5
–
–
130
mV
Input high DC voltage: Logic 1
VIH(DC90),min
90
90
90
mV
Input low DC voltage: Logic 0
VIL(DC90),min
–90
–90
–90
mV
Input low AC voltage: Logic 0
VIL(AC125),min5
–
–
–130
mV
VIL(AC135),min5
–135
–135
–135
mV
VIL(AC160),min5
–160
–160
–
mV
Notes:
1. All voltages are referenced to VREF. VREF is VREFCA for control, command, and address. All
slew rates and setup/hold times are specified at the DRAM ball. VREF is VREFDQ for DQ
and DM inputs.
2. Input setup timing parameters (tIS and tDS) are referenced at VIL(AC)/VIH(AC), not VREF(DC).
3. Input hold timing parameters (tIH and tDH) are referenced at VIL(DC)/VIH(DC), not VREF(DC).
4. Single-ended input slew rate = 1 V/ns; maximum input voltage swing under test is
900mV (peak-to-peak).
5. When two VIH(AC) values (and two corresponding VIL(AC) values) are listed for a specific
speed bin, the user may choose either value for the input AC level. Whichever value is
used, the associated setup time for that AC level must also be used. Additionally, one
VIH(AC) value may be used for address/command inputs and the other VIH(AC) value may
be used for data inputs.
For example, for DDR3-800, two input AC levels are defined: VIH(AC160),min and
VIH(AC135),min (corresponding VIL(AC160),min and VIL(AC135),min). For DDR3-800, the address/
command inputs must use either VIH(AC160),min with tIS(AC160) of 210ps or VIH(AC150),min
with tIS(AC135) of 365ps; independently, the data inputs must use either VIH(AC160),min
with tDS(AC160) of 75ps or VIH(AC150),min with tDS(AC150) of 125ps.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – DC and AC
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
43
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 44 -->

Table 24: DDR3L 1.35V Differential Input Operating Conditions (CK, CK# and DQS, DQS#)
Parameter/Condition
Symbol
Min
Max
Units
Notes
Differential input logic high – slew
VIH,diff(AC)slew
180
N/A
mV
4
Differential input logic low – slew
VIL,diff(AC)slew
N/A
–180
mV
4
Differential input logic high
VIH,diff(AC)
2 × (VIH(AC) - VREF)
VDD/VDDQ
mV
5
Differential input logic low
VIL,diff(AC)
VSS/VSSQ
2 × (VIL(AC) - VREF)
mV
6
Differential input crossing voltage
relative to VDD/2 for DQS, DQS#; CK,
CK#
VIX
VREF(DC) - 150
VREF(DC) + 150
mV
5, 7, 9
Differential input crossing voltage
relative to VDD/2 for CK, CK#
VIX (175)
VREF(DC) - 175
VREF(DC) + 175
mV
5, 7–9
Single-ended high level for strobes
VSEH
VDDQ/2 + 160
VDDQ
mV
5
Single-ended high level for CK, CK#
VDD/2 + 160
VDD
mV
5
Single-ended low level for strobes
VSEL
VSSQ
VDDQ/2 - 160
mV
6
Single-ended low level for CK, CK#
VSS
VDD/2 - 160
mV
6
Notes:
1. Clock is referenced to VDD and VSS. Data strobe is referenced to VDDQ and VSSQ.
2. Reference is VREFCA(DC) for clock and VREFDQ(DC) for strobe.
3. Differential input slew rate = 2 V/ns.
4. Defines slew rate reference points, relative to input crossing voltages.
5. Minimum DC limit is relative to single-ended signals; overshoot specifications are appli-
cable.
6. Maximum DC limit is relative to single-ended signals; undershoot specifications are ap-
plicable.
7. The typical value of VIX(AC) is expected to be about 0.5 × VDD of the transmitting device,
and VIX(AC) is expected to track variations in VDD. VIX(AC) indicates the voltage at which
differential input signals must cross.
8. The VIX extended range (±175mV) is allowed only for the clock; this VIX extended range
is only allowed when the following conditions are met: The single-ended input signals
are monotonic, have the single-ended swing VSEL, VSEH of at least VDD/2 ±250mV, and
the differential slew rate of CK, CK# is greater than 3 V/ns.
9. VIX must provide 25mV (single-ended) of the voltages separation.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – DC and AC
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
44
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 45 -->

Figure 11: DDR3L 1.35V Input Signal
0.0V
VREF - 90mV
VREF = VDD/2
VDD
  .51 x
VIL(AC)
VIL(DC)
VREFDQ - AC noise
VREFDQ - DC error
VREFDQ + DC error
VREFDQ + AC noise
VIH(DC)
VIH(AC)
VDD
VDD + 0.4V
Narrow pulse width
VSS - 0.40V
Narrow pulse width
VDDQ
VDDQ + 0.4V
Overshoot
VSS - 0.40V
Undershoot
VSS
VIL MIN(AC)
VIL MIN(DC)
MAX 2% Total
DC MIN
VREF
VREF DC MAX
MAX 2% Total
VIH MIN(DC)
VIH MIN(AC)
Minimum VIL and VIH levels
VIH(DC)
VIH(AC)
VIL(AC)
VIL(DC)
VIL and VIH levels with ringback
VREF DC MAX + 1%
VREF DC MIN - 1% VDD
VREF + 90mV
VREF + 125/135/160mV
VREF - 125/135/160mV
VDD
  .49 x
Note:
1. Numbers in diagrams reflect nominal values.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – DC and AC
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
45
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 46 -->

DDR3L 1.35V AC Overshoot/Undershoot Specification
Table 25: DDR3L Control and Address Pins
Parameter
DDR3L-800
DRR3L-1066
DDR3L-1333
DDR3L-1600
DDR3L-1866
DDR3L-2133
Maximum peak ampli-
tude allowed for over-
shoot area
(see Figure 12)
0.4V
0.4V
0.4V
0.4V
0.4V
0.4V
Maximum peak ampli-
tude allowed for under-
shoot area
(see Figure 13)
0.4V
0.4V
0.4V
0.4V
0.4V
0.4V
Maximum overshoot area
above VDD (see Figure 12)
0.67 V/ns
0.5 V/ns
0.4 V/ns
0.33 V/ns
0.28 V/ns
0.25 V/ns
Maximum undershoot
area below VSS (see Fig-
ure 13)
0.67 V/ns
0.5 V/ns
0.4 V/ns
0.33 V/ns
0.28 V/ns
0.25 V/ns
Table 26: DDR3L 1.35V Clock, Data, Strobe, and Mask Pins
Parameter
DDR3L-800
DDR3L-1066
DDR3L-1333
DDR3L-1600
DDR3L-1866
DDR3L-2133
Maximum peak ampli-
tude allowed for over-
shoot area
(see Figure 12)
0.4V
0.4V
0.4V
0.4V
0.4V
0.4V
Maximum peak ampli-
tude allowed for under-
shoot area
(see Figure 13)
0.4V
0.4V
0.4V
0.4V
0.4V
0.4V
Maximum overshoot area
above VDD/VDDQ (see Fig-
ure 12)
0.25 V/ns
0.19 V/ns
0.15 V/ns
0.13 V/ns
0.11 V/ns
0.10 V/ns
Maximum undershoot
area below VSS/VSSQ (see 
Figure 13)
0.25 V/ns
0.19 V/ns
0.15 V/ns
0.13 V/ns
0.11 V/ns
0.10 V/ns
Figure 12: Overshoot
Maximum amplitude
Overshoot area
VDD/VDDQ
Time (ns)
Volts (V)
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – DC and AC
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
46
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 47 -->

Figure 13: Undershoot
Maximum amplitude
Undershoot area
VSS/VSSQ
Time (ns)
Volts (V)
Figure 14: VIX for Differential Signals
CK, DQS
VDD/2, VDDQ/2
VDD/2, VDDQ/2
VIX
VIX
CK#, DQS#
VDD, VDDQ
CK, DQS
VDD, VDDQ
VSS, VSSQ
CK#, DQS#
VSS, VSSQ
X
X
X
X
VIX
VIX
Figure 15: Single-Ended Requirements for Differential Signals
VSS or VSSQ
VDD or VDDQ
VSEL,max
VSEH,min
VSEH
VSEL
CK or DQS
VDD/2 or VDDQ/2
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – DC and AC
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
47
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 48 -->

Figure 16: Definition of Differential AC-Swing and tDVAC
VIH,diff(AC)min
0.0
VIL,diff,max
tDVAC
VIH,diff,min
VIL,diff(AC)max
Half cycle
tDVAC
CK - CK#
DQS - DQS#
Table 27: DDR3L 1.35V – Minimum Required Time tDVAC for CK/CK#, DQS/DQS# Differential for AC
Ringback
Slew Rate (V/ns)
DDR3L-800/1066/1333/1600
DDR3L-1866/2133
tDVAC at
320mV (ps)
tDVAC at
270mV (ps)
tDVAC at
270mV (ps)
tDVAC at
250mV (ps)
tDVAC at
260mV (ps)
>4.0
189
201
163
168
176
4.0
189
201
163
168
176
3.0
162
179
140
147
154
2.0
109
134
95
105
111
1.8
91
119
80
91
97
1.6
69
100
62
74
78
1.4
40
76
37
52
55
1.2
Note 1
44
5
22
24
1.0
Note 1
<1.0
Note 1
Note:
1. Rising input signal shall become equal to or greater than VIH(AC) level and Falling input
signal shall become equal to or less than VIL(AC) level.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – DC and AC
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
48
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 49 -->

DDR3L 1.35V Slew Rate Definitions for Single-Ended Input Signals
Setup (tIS and tDS) nominal slew rate for a rising signal is defined as the slew rate be-
tween the last crossing of VREF and the first crossing of VIH(AC)min. Setup (tIS and tDS)
nominal slew rate for a falling signal is defined as the slew rate between the last crossing
of VREF and the first crossing of VIL(AC)max.
Hold (tIH and tDH) nominal slew rate for a rising signal is defined as the slew rate be-
tween the last crossing of VIL(DC)max and the first crossing of VREF. Hold (tIH and tDH)
nominal slew rate for a falling signal is defined as the slew rate between the last crossing
of VIH(DC)min and the first crossing of VREF (see Figure 17 (page 50)).
Table 28: Single-Ended Input Slew Rate Definition
Input Slew Rates
(Linear Signals)
Measured
Calculation
Input
Edge
From
To
Setup
Rising
VREF
VIH(AC),min
VIH(AC),min - VREF
ΔTRSse
Falling
VREF
VIL(AC),max
VREF - VIL(AC),max
ΔTFSse
Hold
Rising
VIL(DC),max
VREF
VREF - VIL(DC),max
ΔTFHse
Falling
VIH(DC),min
VREF
VIH(DC),min - VREF
ΔTRSHse
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – DC and AC
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
49
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 50 -->

Figure 17: Nominal Slew Rate Definition for Single-Ended Input Signals
ΔTRSse
ΔTFSse
ΔTRHse
ΔTFHse
VREFDQ or
VREFCA
VIH(AC)min
VIH(DC)min
VIL(AC)max
VIL(DC)max
VREFDQ or 
VREFCA
VIH(AC)min
VIH(DC)min
VIL(AC)max
VIL(DC)max
Setup
Hold
Single-ended input voltage (DQ,  CMD,  ADDR)
Single-ended input voltage (DQ, CMD,  ADDR)
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – DC and AC
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
50
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 51 -->

DDR3L 1.35V Slew Rate Definitions for Differential Input Signals
Input slew rate for differential signals (CK, CK# and DQS, DQS#) are defined and meas-
ured, as shown in Table 29 and Figure 18. The nominal slew rate for a rising signal is
defined as the slew rate between VIL,diff,max and VIH,diff,min. The nominal slew rate for a
falling signal is defined as the slew rate between VIH,diff,min and VIL,diff,max.
Table 29: DDR3L 1.35V Differential Input Slew Rate Definition
Differential Input
Slew Rates
(Linear Signals)
Measured
Calculation
Input
Edge
From
To
CK and
DQS
reference
Rising
VIL,diff,max
VIH,diff,min
VIH,diff,min - VIL,diff,max
ΔTRdiff
Falling
VIH,diff,min
VIL,diff,max
VIH,diff,min - VIL,diff,max
ΔTFdiff
Figure 18: DDR3L 1.35V Nominal Differential Input Slew Rate Definition for DQS, DQS# and CK, CK#
ΔTRdiff
ΔTFdiff
VIH,diff,min
VIL,diff,max
0
Differential input voltage (DQS, DQS#; CK, CK#)
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications – DC and AC
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
51
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

