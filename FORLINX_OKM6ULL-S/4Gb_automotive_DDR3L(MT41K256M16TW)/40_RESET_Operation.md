# RESET Operation

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 177–178

<!-- page 177 -->

RESET Operation
The RESET signal (RESET#) is an asynchronous reset signal that triggers any time it
drops LOW, and there are no restrictions about when it can go LOW. After RESET# goes
LOW, it must remain LOW for 100ns. During this time, the outputs are disabled, ODT
(RTT) turns off (High-Z), and the DRAM resets itself. CKE should be driven LOW prior to
RESET# being driven HIGH. After RESET# goes HIGH, the DRAM must be re-initialized
as though a normal power-up was executed. All counters, except refresh counters, on
the DRAM are reset, and data stored in the DRAM is assumed unknown after RESET#
has gone LOW.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
RESET Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
177
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 178 -->

Figure 105: RESET Sequence
T = 10ns  (MIN)
T = 100ns (MIN)
T = 500μs (MIN)
tXPR
tMRD
tMRD
tMRD
tMOD
tCK
tIOZ = 20ns
CKE
RTT
BA[2:0]
All voltage
supplies valid
and stable
High-Z
DM
DQS
High-Z
Address
A10
CK
CK#
tCL
Command
NOP
T0
Ta0
Don’t Care
tCL
ODT
DQ
High-Z
Tb0
tDLLK
MR1 with
DLL ENABLE
MRS
MRS
BA0 = H
BA1 = L
BA2 = L
BA0 = L
BA1 = L
BA2 = L
Code 
Code 
Code 
Code 
Valid
Valid
Valid
Valid
 Normal
operation
MR2
MR3
MRS
MRS
BA0 = L
BA1 = H
BA2 = L
BA0 = H
BA1 = H
BA2 = L
Code 
Code 
Code 
Code 
Tc0
Td0
RESET#
Stable and
valid clock
Valid
DRAM ready
for external
commands
T1
tZQinit
A10 = H
ZQCL
tIS
Valid
System RESET
(warm boot)
ZQCAL
MR0 with
DLL RESET
Indicates break
in time scale
tCKSRX1
tIS
tIS
tIS
Static LOW in case RTT_Nom is enabled at time Ta0, otherwise static HIGH or LOW
Note:
1. The minimum time required is the longer of 10ns or 5 clocks.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
RESET Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
178
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

