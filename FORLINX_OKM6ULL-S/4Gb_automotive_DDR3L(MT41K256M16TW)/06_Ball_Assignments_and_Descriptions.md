# Ball Assignments and Descriptions

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 16–21

<!-- page 16 -->

Ball Assignments and Descriptions
Figure 6: 78-Ball FBGA – x4, x8 (Top View)
1
2
3
4
6
7
8
9
5
VSS
VSS
VDDQ
VSSQ
VREFDQ
NC
ODT
NC
VSS
VDD
VSS
VDD
VSS
VDD
VSSQ
DQ2
NF, DQ6
VDDQ
VSS
VDD
CS#
BA0
A3
A5
A7
RESET#
NC
DQ0
DQS
DQS#
NF, DQ4
RAS#
CAS#
WE#
BA2
A0
A2
A9
A13
NF, NF/TDQS#
DM, DM/TDQS
DQ1
VDD
NF, DQ7
CK
CK#
A10/AP
A15
A12/BC#
A1
A11
A14
VDD
VDDQ
VSSQ
VSSQ
VDDQ
NC
CKE
NC
VSS
VDD
VSS
VDD
VSS
VSS
VSSQ
DQ3
VSS
NF, DQ5
VSS
VDD
ZQ
VREFCA
BA1
A4
A6
A8
A
B
C
D
E
F
G
H
J
K
L
M
N
Notes:
1. Ball descriptions listed in Table 3 (page 18) are listed as “x4, x8” if unique; otherwise,
x4 and x8 are the same.
2. A comma separates the configuration; a slash defines a selectable function.
Example D7 = NF, NF/TDQS#. NF applies to the x4 configuration only. NF/TDQS# applies
to the x8 configuration only—selectable between NF or TDQS# via MRS (symbols are de-
fined in Table 3).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Ball Assignments and Descriptions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
16
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 17 -->

Figure 7: 96-Ball FBGA – x16 (Top View)
1
2
3
4
6
7
8
9
5
A
B
C
D
E
F
G
H
J
K
L
M
N
P
R
T
VDDQ
VSSQ
VDDQ
VSSQ
VSS
VDDQ
VSSQ
VREFDQ
NC
ODT
NC
VSS
VDD
VSS
VDD
VSS
DQ13
VDD
DQ11
VDDQ
VSSQ
DQ2
DQ6
VDDQ
VSS
VDD
CS#
BA0
A3
A5
A7
RESET#
DQ15
VSS
DQ9
UDM
DQ0
LDQS
LDQS#
DQ4
RAS#
CAS#
WE#
BA2
A0
A2
A9
A13
DQ12
UDQS#
UDQS
DQ8
LDM
DQ1
VDD
DQ7
CK
CK#
A10/AP
NC
A12/BC#
A1
A11
A14
VDDQ
DQ14
DQ10
VSSQ
VSSQ
DQ3
VSS
DQ5
VSS
VDD
ZQ
VREFCA
BA1
A4
A6
A8
VSS
VSSQ
VDDQ
VDD
VDDQ
VSSQ
VSSQ
VDDQ
NC
CKE
NC
VSS
VDD
VSS
VDD
VSS
Notes:
1. Ball descriptions listed in Table 4 (page 20) are listed as “x4, x8” if unique; otherwise,
x4 and x8 are the same.
2. A comma separates the configuration; a slash defines a selectable function.
Example D7 = NF, NF/TDQS#. NF applies to the x4 configuration only. NF/TDQS# applies
to the x8 configuration only—selectable between NF or TDQS# via MRS (symbols are de-
fined in Table 3).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Ball Assignments and Descriptions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
17
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 18 -->

Table 3: 78-Ball FBGA – x4, x8 Ball Descriptions
Symbol
Type
Description
A[15:13], A12/BC#,
A11, A10/AP, A[9:0]
Input
Address inputs: Provide the row address for ACTIVATE commands, and the column
address and auto precharge bit (A10) for READ/WRITE commands, to select one
location out of the memory array in the respective bank. A10 sampled during a
PRECHARGE command determines whether the PRECHARGE applies to one bank
(A10 LOW, bank selected by BA[2:0]) or all banks (A10 HIGH). The address inputs also
provide the op-code during a LOAD MODE command. Address inputs are referenced
to VREFCA. A12/BC#: When enabled in the mode register (MR), A12 is sampled during
READ and WRITE commands to determine whether burst chop (on-the-fly) will be
performed (HIGH = BL8 or no burst chop, LOW = BC4). See Table 67 (page 99).
BA[2:0]
Input
Bank address inputs: BA[2:0] define the bank to which an ACTIVATE, READ,
WRITE, or PRECHARGE command is being applied. BA[2:0] define which mode
register (MR0, MR1, MR2, or MR3) is loaded during the LOAD MODE command.
BA[2:0] are referenced to VREFCA.
CK, CK#
Input
Clock: CK and CK# are differential clock inputs. All control and address input signals
are sampled on the crossing of the positive edge of CK and the negative edge of
CK#. Output data strobe (DQS, DQS#) is referenced to the crossings of CK and CK#.
CKE
Input
Clock enable: CKE enables (registered HIGH) and disables (registered LOW)
internal circuitry and clocks on the DRAM. The specific circuitry that is enabled/
disabled is dependent upon the DDR3 SDRAM configuration and operating mode.
Taking CKE LOW provides PRECHARGE POWER-DOWN and SELF REFRESH operations
(all banks idle), or active power-down (row active in any bank). CKE is synchronous
for power-down entry and exit and for self refresh entry. CKE is asynchronous for
self refresh exit. Input buffers (excluding CK, CK#, CKE, RESET#, and ODT) are
disabled during POWER-DOWN. Input buffers (excluding CKE and RESET#) are disa-
bled during SELF REFRESH. CKE is referenced to VREFCA.
CS#
Input
Chip select: CS# enables (registered LOW) and disables (registered HIGH) the
command decoder. All commands are masked when CS# is registered HIGH. CS#
provides for external rank selection on systems with multiple ranks. CS# is considered
part of the command code. CS# is referenced to VREFCA.
DM
Input
Input data mask: DM is an input mask signal for write data. Input data is masked
when DM is sampled HIGH along with the input data during a write access.
Although the DM ball is input-only, the DM loading is designed to match that of the
DQ and DQS balls. DM is referenced to VREFDQ. DM has an optional use as TDQS on
the x8.
ODT
Input
On-die termination: ODT enables (registered HIGH) and disables (registered LOW)
termination resistance internal to the DDR3 SDRAM. When enabled in normal
operation, ODT is only applied to each of the following balls: DQ[7:0], DQS, DQS#,
and DM for the x8; DQ[3:0], DQS, DQS#, and DM for the x4. The ODT input is
ignored if disabled via the LOAD MODE command. ODT is referenced to VREFCA.
RAS#, CAS#, WE#
Input
Command inputs: RAS#, CAS#, and WE# (along with CS#) define the command
being entered and are referenced to VREFCA.
RESET#
Input
Reset: RESET# is an active LOW CMOS input referenced to VSS. The RESET# input re-
ceiver is a CMOS input defined as a rail-to-rail signal with DC HIGH ≥ 0.8 × VDD and
DC LOW ≤ 0.2 × VDDQ. RESET# assertion and desertion are asynchronous.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Ball Assignments and Descriptions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
18
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 19 -->

Table 3: 78-Ball FBGA – x4, x8 Ball Descriptions (Continued)
Symbol
Type
Description
DQ[3:0]
I/O
Data input/output: Bidirectional data bus for the x4 configuration. DQ[3:0] are
referenced to VREFDQ.
DQ[7:0]
I/O
Data input/output: Bidirectional data bus for the x8 configuration. DQ[7:0] are
referenced to VREFDQ.
DQS, DQS#
I/O
Data strobe: Output with read data. Edge-aligned with read data. Input with write
data. Center-aligned to write data.
TDQS, TDQS#
Output
Termination data strobe: Applies to the x8 configuration only. When TDQS is
enabled, DM is disabled, and the TDQS and TDQS# balls provide termination
resistance.
VDD
Supply
Power supply: 1.5V ±0.075V.
VDDQ
Supply
DQ power supply: 1.5V ±0.075V. Isolated on the device for improved noise immuni-
ty.
VREFCA
Supply
Reference voltage for control, command, and address: VREFCA must be
maintained at all times (including self refresh) for proper device operation.
VREFDQ
Supply
Reference voltage for data: VREFDQ must be maintained at all times (excluding self
refresh) for proper device operation.
VSS
Supply
Ground.
VSSQ
Supply
DQ ground: Isolated on the device for improved noise immunity.
ZQ
Reference
External reference ball for output drive calibration: This ball is tied to an
external 240Ω resistor (RZQ), which is tied to VSSQ.
NC
–
No connect: These balls should be left unconnected (the ball has no connection to
the DRAM or to other balls).
NF
–
No function: When configured as a x4 device, these balls are NF. When configured
as a x8 device, these balls are defined as TDQS#, DQ[7:4].
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Ball Assignments and Descriptions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
19
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 20 -->

Table 4: 96-Ball FBGA – x16 Ball Descriptions
Symbol
Type
Description
A[14:13], A12/BC#,
A11, A10/AP, A[9:0]
Input
Address inputs: Provide the row address for ACTIVATE commands, and the column
address and auto precharge bit (A10) for READ/WRITE commands, to select one
location out of the memory array in the respective bank. A10 sampled during a
PRECHARGE command determines whether the PRECHARGE applies to one bank
(A10 LOW, bank selected by BA[2:0]) or all banks (A10 HIGH). The address inputs also
provide the op-code during a LOAD MODE command. Address inputs are referenced
to VREFCA. A12/BC#: When enabled in the mode register (MR), A12 is sampled during
READ and WRITE commands to determine whether burst chop (on-the-fly) will be
performed (HIGH = BL8 or no burst chop, LOW = BC4). See Table 67 (page 99).
BA[2:0]
Input
Bank address inputs: BA[2:0] define the bank to which an ACTIVATE, READ,
WRITE, or PRECHARGE command is being applied. BA[2:0] define which mode
register (MR0, MR1, MR2, or MR3) is loaded during the LOAD MODE command.
BA[2:0] are referenced to VREFCA.
CK, CK#
Input
Clock: CK and CK# are differential clock inputs. All control and address input signals
are sampled on the crossing of the positive edge of CK and the negative edge of
CK#. Output data strobe (DQS, DQS#) is referenced to the crossings of CK and CK#.
CKE
Input
Clock enable: CKE enables (registered HIGH) and disables (registered LOW) internal
circuitry and clocks on the DRAM. The specific circuitry that is enabled/disabled is de-
pendent upon the DDR3 SDRAM configuration and operating mode. Taking CKE
LOW provides PRECHARGE POWER-DOWN and SELF REFRESH operations (all banks
idle),or active power-down (row active in any bank). CKE is synchronous for power-
down entry and exit and for self refresh entry. CKE is asynchronous for self refresh
exit. Input buffers (excluding CK, CK#, CKE, RESET#, and ODT) are disabled during
POWER-DOWN. Input buffers (excluding CKE and RESET#) are disabled during SELF
REFRESH. CKE is referenced to VREFCA.
CS#
Input
Chip select: CS# enables (registered LOW) and disables (registered HIGH) the
command decoder. All commands are masked when CS# is registered HIGH. CS# pro-
vides for external rank selection on systems with multiple ranks. CS# is considered
part of the command code. CS# is referenced to VREFCA.
LDM
Input
Input data mask: LDM is a lower-byte, input mask signal for write data. Lower-byte
input data is masked when LDM is sampled HIGH along with the input data during a
write access. Although the LDM ball is input-only, the LDM loading is
designed to match that of the DQ and DQS balls. LDM is referenced to VREFDQ.
ODT
Input
On-die termination: ODT enables (registered HIGH) and disables (registered LOW)
termination resistance internal to the DDR3 SDRAM. When enabled in normal
operation, ODT is only applied to each of the following balls: DQ[15:0], LDQS,
LDQS#, UDQS, UDQS#, LDM, and UDM for the x16; DQ0[7:0], DQS, DQS#, DM/TDQS,
and NF/TDQS# (when TDQS is enabled) for the x8; DQ[3:0], DQS, DQS#, and DM for
the x4. The ODT input is ignored if disabled via the LOAD MODE command. ODT is
referenced to VREFCA.
RAS#, CAS#, WE#
Input
Command inputs: RAS#, CAS#, and WE# (along with CS#) define the command
being entered and are referenced to VREFCA.
RESET#
Input
Reset: RESET# is an active LOW CMOS input referenced to VSS. The RESET# input re-
ceiver is a CMOS input defined as a rail-to-rail signal with DC HIGH ≥ 0.8 × VDD and
DC LOW ≤ 0.2 × VDDQ. RESET# assertion and desertion are asynchronous.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Ball Assignments and Descriptions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
20
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 21 -->

Table 4: 96-Ball FBGA – x16 Ball Descriptions (Continued)
Symbol
Type
Description
UDM
Input
Input data mask: UDM is an upper-byte, input mask signal for write data. Upper-
byte input data is masked when UDM is sampled HIGH along with that input data
during a WRITE access. Although the UDM ball is input-only, the UDM loading is
designed to match that of the DQ and DQS balls. UDM is referenced to VREFDQ.
DQ[7:0]
I/O
Data input/output: Lower byte of bidirectional data bus for the x16 configuration.
DQ[7:0] are referenced to VREFDQ.
DQ[15:8]
I/O
Data input/output: Upper byte of bidirectional data bus for the x16 configuration.
DQ[15:8] are referenced to VREFDQ.
LDQS, LDQS#
I/O
Lower byte data strobe: Output with read data. Edge-aligned with read data.
Input with write data. Center-aligned to write data.
UDQS, UDQS#
I/O
Upper byte data strobe: Output with read data. Edge-aligned with read data.
Input with write data. DQS is center-aligned to write data.
VDD
Supply
Power supply: 1.5V ±0.075V.
VDDQ
Supply
DQ power supply: 1.5V ±0.075V. Isolated on the device for improved noise immuni-
ty.
VREFCA
Supply
Reference voltage for control, command, and address: VREFCA must be
maintained at all times (including self refresh) for proper device operation.
VREFDQ
Supply
Reference voltage for data: VREFDQ must be maintained at all times (excluding self
refresh) for proper device operation.
VSS
Supply
Ground.
VSSQ
Supply
DQ ground: Isolated on the device for improved noise immunity.
ZQ
Reference
External reference ball for output drive calibration: This ball is tied to an
external 240Ω resistor (RZQ), which is tied to VSSQ.
NC
–
No connect: These balls should be left unconnected (the ball has no connection to
the DRAM or to other balls).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Ball Assignments and Descriptions
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
21
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

