# Initialization

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 117–118

<!-- page 117 -->

Initialization
The following sequence is required for power-up and initialization, as shown in Figure
46 (page 118):
1. Apply power. RESET# is recommended to be below 0.2 × VDDQ during power ramp
to ensure the outputs remain disabled (High-Z) and ODT off (RTT is also High-Z).
All other inputs, including ODT, may be undefined.
During power-up, either of the following conditions may exist and must be met:
• Condition A:
– VDD and VDDQ are driven from a single-power converter output and are
ramped with a maximum delta voltage between them of ΔV ≤ 300mV. Slope re-
versal of any power supply signal is allowed. The voltage levels on all balls oth-
er than VDD, VDDQ, VSS, VSSQ must be less than or equal to VDDQ and VDD on
one side, and must be greater than or equal to VSSQ and VSS on the other side.
– Both VDD and VDDQ power supplies ramp to VDD,min and VDDQ,min within
tVDDPR = 200ms.
– VREFDQ tracks VDD × 0.5, VREFCA tracks VDD × 0.5.
– VTT is limited to 0.95V when the power ramp is complete and is not applied
directly to the device; however, tVTD should be greater than or equal to 0 to
avoid device latchup.
• Condition B:
– VDD may be applied before or at the same time as VDDQ.
– VDDQ may be applied before or at the same time as VTT, VREFDQ, and VREFCA.
– No slope reversals are allowed in the power supply ramp for this condition.
2. Until stable power, maintain RESET# LOW to ensure the outputs remain disabled
(High-Z). After the power is stable, RESET# must be LOW for at least 200μs to be-
gin the initialization process. ODT will remain in the High-Z state while RESET# is
LOW and until CKE is registered HIGH.
3. CKE must be LOW 10ns prior to RESET# transitioning HIGH.
4. After RESET# transitions HIGH, wait 500μs (minus one clock) with CKE LOW.
5. After the CKE LOW time, CKE may be brought HIGH (synchronously) and only
NOP or DES commands may be issued. The clock must be present and valid for at
least 10ns (and a minimum of five clocks) and ODT must be driven LOW at least
tIS prior to CKE being registered HIGH. When CKE is registered HIGH, it must be
continuously registered HIGH until the full initialization process is complete.
6. After CKE is registered HIGH and after tXPR has been satisfied, MRS commands
may be issued. Issue an MRS (LOAD MODE) command to MR2 with the applica-
ble settings (provide LOW to BA2 and BA0 and HIGH to BA1).
7. Issue an MRS command to MR3 with the applicable settings.
8. Issue an MRS command to MR1 with the applicable settings, including enabling
the DLL and configuring ODT.
9. Issue an MRS command to MR0 with the applicable settings, including a DLL RE-
SET command. tDLLK (512) cycles of clock input are required to lock the DLL.
10. Issue a ZQCL command to calibrate RTT and RON values for the process voltage
temperature (PVT). Prior to normal operation, tZQinit must be satisfied.
11. When tDLLK and tZQinit have been satisfied, the DDR3 SDRAM will be ready for
normal operation.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Initialization
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
117
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 118 -->

Figure 46: Initialization Sequence
CKE
RTT
BA[2:0]
All voltage
supplies valid
and stable
T = 200μs (MIN)
DM
DQS
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
tIS
tCK
ODT
DQ
Tb0
tDLLK
MR1 with
DLL enable
MR0 with
DLL reset
tMRD
tMOD
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
tMRD
tMRD
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
VTT
VREF
VDDQ
VDD
RESET#
T = 500μs (MIN)
tCKSRX
Stable and
valid clock
Valid
Power-up
ramp
T (MAX) = 200ms
DRAM ready for 
external commands
T1
tZQinit
ZQ calibration
A10 = H
ZQCL
tIS
See power-up
conditions 
in the 
initialization
sequence text, 
set up 1 
tXPR
Valid
tIOZ = 20ns
Indicates break
in time scale
T (MIN) = 10ns
tVTD
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Initialization
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
118
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

