# Electrical Specifications

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 24–25

<!-- page 24 -->

Electrical Specifications
Absolute Ratings
Stresses greater than those listed may cause permanent damage to the device. This is a
stress rating only, and functional operation of the device at these or any other condi-
tions outside those indicated in the operational sections of this specification is not im-
plied. Exposure to absolute maximum rating conditions for extended periods may ad-
versely affect reliability.
Table 5: Absolute Maximum Ratings
Symbol
Parameter
Min
Max
Unit
Notes
VDD
VDD supply voltage relative to VSS
–0.4
1.975
V
1
VDDQ
VDD supply voltage relative to VSSQ
–0.4
1.975
V
 
VIN, VOUT
Voltage on any pin relative to VSS
–0.4
1.975
V
 
TC
Operating case temperature – Commercial
0
95
°C
2, 3
Operating case temperature – Industrial
–40
95
°C
2, 3
Operating case temperature – Automotive
–40
105
°C
2, 3
Operating case temperature – Ultra-high
–40
125
°C
2, 3
TSTG
Storage temperature
–55
150
°C
 
Notes:
1. VDD and VDDQ must be within 300mV of each other at all times, and VREF must not be
greater than 0.6 × VDDQ. When VDD and VDDQ are <500mV, VREF can be ≤300mV.
2. MAX operating case temperature. TC is measured in the center of the package.
3. Device functionality is not guaranteed if the DRAM device exceeds the maximum TC dur-
ing operation.
4. Ultra-high temperature use based on automotive usage model. Please contact Micron
sales representative if you have questions.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
24
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 25 -->

Input/Output Capacitance
Table 6: DDR3L Input/Output Capacitance
Note 1 applies to the entire table
Capacitance
Parameters
Sym
DDR3L
-800
DDR3L
-1066
DDR3L
-1333
DDR3L
-1600
DDR3L
-1866
DDR3L
-2133
Unit Notes
Min
Max
Min
Max
Min
Max
Min
Max
Min
Max
Min
Max
CK and CK#
CCK
0.8
1.6
0.8
1.6
0.8
1.4
0.8
1.4
0.8
1.3
0.8
1.3
pF
 
ΔC: CK to CK#
CDCK
0.0
0.15
0.0
0.15
0.0
0.15
0.0
0.15
0.0
0.15
0.0
0.15
pF
 
Single-end
I/O: DQ, DM
CIO
1.4
2.5
1.4
2.5
1.4
2.3
1.4
2.2
1.4
2.1
1.4
2.1
pF
2
Differential
I/O: DQS,
DQS#, TDQS,
TDQS#
CIO
1.4
2.5
1.4
2.5
1.4
2.3
1.4
2.2
1.4
2.1
1.4
2.1
pF
3
ΔC: DQS to
DQS#, TDQS,
TDQS#
CDDQS
0.0
0.2
0.0
0.2
0.0
0.15
0.0
0.15
0.0
0.15
0.0
0.15
pF
3
ΔC: DQ to
DQS
CDIO
–0.5
0.3
–0.5
0.3
–0.5
0.3
–0.5
0.3
–0.5
0.3
–0.5
0.3
pF
4
Inputs (CTRL,
CMD, ADDR)
CI
0.75
1.3
0.75
1.3
0.75
1.3
0.75
1.2
0.75
1.2
0.75
1.2
pF
5
ΔC: CTRL to
CK
CDI_CTRL
–0.5
0.3
–0.5
0.3
–0.4
0.2
–0.4
0.2
–0.4
0.2
–0.4
0.2
pF
6
ΔC:
CMD_ADDR
to CK
CDI_CMD
_ADDR
–0.5
0.5
–0.5
0.5
–0.4
0.4
–0.4
0.4
–0.4
0.4
–0.4
0.4
pF
7
ZQ pin
capacitance
CZQ
–
3.0
–
3.0
–
3.0
–
3.0
–
3.0
–
3.0
pF
 
Reset pin
capacitance
CRE
–
3.0
–
3.0
–
3.0
–
3.0
–
3.0
–
3.0
pF
 
Notes:
1. VDD = 1.35V (1.283–1.45V), VDDQ = VDD, VREF = VSS, f = 100 MHz, TC = 25°C. VOUT(DC) = 0.5
× VDDQ, VOUT = 0.1V (peak-to-peak).
2. DM input is grouped with I/O pins, reflecting the fact that they are matched in loading.
3. Includes TDQS, TDQS#. CDDQS is for DQS vs. DQS# and TDQS vs. TDQS# separately.
4. CDIO = CIO(DQ) - 0.5 × (CIO(DQS) + CIO(DQS#)).
5. Excludes CK, CK#; CTRL = ODT, CS#, and CKE; CMD = RAS#, CAS#, and WE#; ADDR =
A[n:0], BA[2:0].
6. CDI_CTRL = CI(CTRL) - 0.5 × (CCK(CK) + CCK(CK#)).
7. CDI_CMD_ADDR = CI(CMD_ADDR) - 0.5 × (CCK(CK) + CCK(CK#)).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Electrical Specifications
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
25
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

