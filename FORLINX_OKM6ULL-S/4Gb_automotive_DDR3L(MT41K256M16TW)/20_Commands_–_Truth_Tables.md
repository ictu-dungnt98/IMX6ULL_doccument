# Commands – Truth Tables

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 99–101

<!-- page 99 -->

Commands – Truth Tables
Table 67: Truth Table – Command
Notes 1–5 apply to the entire table
Function
Symbol
CKE
CS# RAS# CAS# WE#
BA
[2:0]
An
A12
A10
A[11,
9:0]
Notes
Prev.
Cycle
Next
Cycle
MODE REGISTER SET
MRS
H
H
L
L
L
L
BA
OP code
 
REFRESH
REF
H
H
L
L
L
H
V
V
V
V
V
 
Self refresh entry
SRE
H
L
L
L
L
H
V
V
V
V
V
6
Self refresh exit
SRX
L
H
H
V
V
V
V
V
V
V
V
6, 7
L
H
H
H
Single-bank PRECHARGE
PRE
H
H
L
L
H
L
BA
V
V
L
V
 
PRECHARGE all banks
PREA
H
H
L
L
H
L
V
V
H
V
 
Bank ACTIVATE
ACT
H
H
L
L
H
H
BA
Row address (RA)
 
WRITE
BL8MRS,
BC4MRS
WR
H
H
L
H
L
L
BA
RFU
V
L
CA
8
BC4OTF
WRS4
H
H
L
H
L
L
BA
RFU
L
L
CA
8
BL8OTF
WRS8
H
H
L
H
L
L
BA
RFU
H
L
CA
8
WRITE
with auto
precharge
BL8MRS,
BC4MRS
WRAP
H
H
L
H
L
L
BA
RFU
V
H
CA
8
BC4OTF
WRAPS4
H
H
L
H
L
L
BA
RFU
L
H
CA
8
BL8OTF
WRAPS8
H
H
L
H
L
L
BA
RFU
H
H
CA
8
READ
BL8MRS,
BC4MRS
RD
H
H
L
H
L
H
BA
RFU
V
L
CA
8
BC4OTF
RDS4
H
H
L
H
L
H
BA
RFU
L
L
CA
8
BL8OTF
RDS8
H
H
L
H
L
H
BA
RFU
H
L
CA
8
READ
with auto
precharge
BL8MRS,
BC4MRS
RDAP
H
H
L
H
L
H
BA
RFU
V
H
CA
8
BC4OTF
RDAPS4
H
H
L
H
L
H
BA
RFU
L
H
CA
8
BL8OTF
RDAPS8
H
H
L
H
L
H
BA
RFU
H
H
CA
8
NO OPERATION
NOP
H
H
L
H
H
H
V
V
V
V
V
9
Device DESELECTED
DES
H
H
H
X
X
X
X
X
X
X
X
10
Power-down entry
PDE
H
L
L
H
H
H
V
V
V
V
V
6
H
V
V
V
Power-down exit
PDX
L
H
L
H
H
H
V
V
V
V
V
6, 11
H
V
V
V
ZQ CALIBRATION LONG
ZQCL
H
H
L
H
H
L
X
X
X
H
X
12
ZQ CALIBRATION SHORT
ZQCS
H
H
L
H
H
L
X
X
X
L
X
 
Notes:
1. Commands are defined by the states of CS#, RAS#, CAS#, WE#, and CKE at the rising
edge of the clock. The MSB of BA, RA, and CA are device-, density-, and configuration-
dependent.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Commands – Truth Tables
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
99
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 100 -->

2. RESET# is enabled LOW and used only for asynchronous reset. Thus, RESET# must be
held HIGH during any normal operation.
3. The state of ODT does not affect the states described in this table.
4. Operations apply to the bank defined by the bank address. For MRS, BA selects one of
four mode registers.
5. “V” means “H” or “L” (a defined logic level), and “X” means “Don’t Care.”
6. See Table 68 (page 101) for additional information on CKE transition.
7. Self refresh exit is asynchronous.
8. Burst READs or WRITEs cannot be terminated or interrupted. MRS (fixed) and OTF BL/BC
are defined in MR0.
9. The purpose of the NOP command is to prevent the DRAM from registering any unwan-
ted commands. A NOP will not terminate an operation that is executing.
10. The DES and NOP commands perform similarly.
11. The power-down mode does not perform any REFRESH operations.
12. ZQ CALIBRATION LONG is used for either ZQinit (first ZQCL command during initializa-
tion) or ZQoper (ZQCL command after initialization).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Commands – Truth Tables
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
100
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 101 -->

Table 68: Truth Table – CKE
Notes 1–2 apply to the entire table; see Table 67 (page 99) for additional command details
Current State3
CKE
Command5
(RAS#, CAS#, WE#, CS#)
Action5
Notes
Previous Cycle4
(n - 1)
Present Cycle4
(n)
Power-down
L
L
“Don’t Care”
Maintain power-down
 
L
H
DES or NOP
Power-down exit
 
Self refresh
L
L
“Don’t Care”
Maintain self refresh
 
L
H
DES or NOP
Self refresh exit
 
Bank(s) active
H
L
DES or NOP
Active power-down entry
 
Reading
H
L
DES or NOP
Power-down entry
 
Writing
H
L
DES or NOP
Power-down entry
 
Precharging
H
L
DES or NOP
Power-down entry
 
Refreshing
H
L
DES or NOP
Precharge power-down entry
 
All banks idle
H
L
DES or NOP
Precharge power-down entry
6
H
L
REFRESH
Self refresh
Notes:
1. All states and sequences not shown are illegal or reserved unless explicitly described
elsewhere in this document.
2.
tCKE (MIN) means CKE must be registered at multiple consecutive positive clock edges.
CKE must remain at the valid input level the entire time it takes to achieve the required
number of registration clocks. Thus, after any CKE transition, CKE may not transition
from its valid level during the time period of tIS + tCKE (MIN) + tIH.
3. Current state = The state of the DRAM immediately prior to clock edge n.
4. CKE (n) is the logic state of CKE at clock edge n; CKE (n - 1) was the state of CKE at the
previous clock edge.
5. COMMAND is the command registered at the clock edge (must be a legal command as
defined in Table 67 (page 99)). Action is a result of COMMAND. ODT does not affect the
states described in this table and is not listed.
6. Idle state = All banks are closed, no data bursts are in progress, CKE is HIGH, and all tim-
ings from previous operations are satisfied. All self refresh exit and power-down exit pa-
rameters are also satisfied.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Commands – Truth Tables
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
101
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

