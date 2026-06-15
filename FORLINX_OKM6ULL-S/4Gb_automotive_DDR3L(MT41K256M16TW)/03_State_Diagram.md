# State Diagram

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 11–11

<!-- page 11 -->

State Diagram
Figure 2: Simplified State Diagram
SRX = Self refresh exit
WRITE = WR, WRS4, WRS8
WRITE AP = WRAP, WRAPS4, WRAPS8
ZQCL = ZQ LONG CALIBRATION
ZQCS = ZQ SHORT CALIBRATION
Bank
active
Reading
Writing
Activating
Refreshing
Self
refresh
Idle
Active 
power-
down
ZQ
calibration
From any
state
Power
applied
Reset 
procedure
  Power 
on
Initial-
ization
MRS, MPR, 
write
leveling
Precharge
power-
down
Writing
Reading
Automatic
sequence
Command
sequence
Precharging
READ
READ
READ
READ AP
READ AP
READ AP
PRE, PREA
PRE,  PREA
PRE,  PREA
WRITE
WRITE
CKE L
CKE L
CKE L
WRITE
WRITE AP
WRITE AP
WRITE AP
PDE
PDE
PDX
PDX
SRX
SRE
REF
MRS
ACT
RESET
ZQCL
ZQCL/ZQCS
ACT = ACTIVATE
MPR = Multipurpose register
MRS = Mode register set
PDE = Power-down entry
PDX = Power-down exit
PRE = PRECHARGE
PREA = PRECHARGE ALL
READ = RD, RDS4, RDS8 
READ AP = RDAP, RDAPS4, RDAPS8
REF = REFRESH
RESET = START RESET PROCEDURE
SRE = Self refresh entry
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
State Diagram
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
11
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

