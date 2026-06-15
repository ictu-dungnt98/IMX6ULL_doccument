# Voltage Initialization / Change

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 119–120

<!-- page 119 -->

Voltage Initialization / Change
If the SDRAM is powered up and initialized for the 1.35V operating voltage range, volt-
age can be increased to the 1.5V operating range provided the following conditions are
met (See Figure 47 (page 120)):
• Just prior to increasing the 1.35V operating voltages, no further commands are issued,
other than NOPs or COMMAND INHIBITs, and all banks are in the precharge state.
• The 1.5V operating voltages are stable prior to issuing new commands, other than
NOPs or COMMAND INHIBITs.
• The DLL is reset and relocked after the 1.5V operating voltages are stable and prior to
any READ command.
• The ZQ calibration is performed. tZQinit must be satisfied after the 1.5V operating
voltages are stable and prior to any READ command.
If the SDRAM is powered up and initialized for the 1.5V operating voltage range, voltage
can be reduced to the 1.35V operation range provided the following conditions are met
(See Figure 47 (page 120)) :
• Just prior to reducing the 1.5V operating voltages, no further commands are issued,
other than NOPs or COMMAND INHIBITs, and all banks are in the precharge state.
• The 1.35V operating voltages are stable prior to issuing new commands, other than
NOPs or COMMAND INHIBITs.
• The DLL is reset and relocked after the 1.35V operating voltages are stable and prior to
any READ command.
• The ZQ calibration is performed. tZQinit must be satisfied after the 1.35V operating
voltages are stable and prior to any READ command.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Voltage Initialization / Change
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
119
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 120 -->

VDD Voltage Switching
After the DDR3L DRAM is powered up and initialized, the power supply can be altered
between the DDR3L and DDR3 levels, provided the sequence in Figure 47 is main-
tained.
Figure 47: VDD Voltage Switching
(
)
(
)
(
)
(
)
CKE
RTT
BA
(
)
(
)
(
)
(
)
CK, CK#
Command
Note 1 
Note 1 
(
)
(
)
(
)
(
)
Td
Tc
Tg
Don’t Care
(
)
(
)
(
)
(
)
(
)
(
)
tIS
ODT
(
)
(
)
(
)
(
)
Th
tMRD
tMOD
(
)
(
)
(
)
(
)
MRS
MRS
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
tMRD
tMRD
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
MRS
MR0
MR1
MR3
MRS
MR2
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
Ti
Tj
Tk
(
)
(
)
(
)
(
)
RESET#
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
T = 500μs
(
)
(
)
(
)
(
)
(
)
(
)
Te
Ta
Tb
Tf
(
)
(
)
(
)
(
)
ZQCL
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
tIS
Static LOW in case RTT,nom is enabled at time Tg, otherwise static HIGH or LOW 
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
tIS
tIS
tXPR
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
()()
()()
Time break
TMIN = 10ns
TMIN = 10ns
TMIN = 10ns
TMIN = 200μs 
tCKSRX
VDD, VDDQ (DDR3)
(
)
(
)
(
)
(
)
tDLLK
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
tZQinit
()()
()()
()()
()()
()()
()()
()()
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
VDD, VDDQ (DDR3L)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
Valid
Valid
Valid
Valid
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
(
)
Note:
1. From time point Td until Tk, NOP or DES commands must be applied between MRS and
ZQCL commands.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Voltage Initialization / Change
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
120
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

