# Mode Register 3 (MR3)

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 133–140

<!-- page 133 -->

back to ODT (RTT,nom) at the completion of the WRITE burst. If RTT,nom is disabled, the
RTT,nom value will be High-Z. Special timing parameters must be adhered to when dy-
namic ODT (RTT(WR)) is enabled: ODTLcnw, ODTLcnw4, ODTLcnw8, ODTH4, ODTH8,
and tADC.
Dynamic ODT is only applicable during WRITE cycles. If ODT (RTT,nom) is disabled, dy-
namic ODT (RTT(WR)) is still permitted. RTT,nom and RTT(WR) can be used independent of
one other. Dynamic ODT is not available during write leveling mode, regardless of the
state of ODT (RTT,nom). For details on dynamic ODT operation, refer to Dynamic ODT
(page 182).
Mode Register 3 (MR3)
The mode register 3 (MR3) controls additional functions and features not available in
the other mode registers. Currently defined is the MULTIPURPOSE REGISTER (MPR).
This function is controlled via the bits shown in Figure 56 (page 133). The MR3 is pro-
grammed via the LOAD MODE command and retains the stored information until it is
programmed again or until the device loses power. Reprogramming the MR3 register
will not alter the contents of the memory array, provided it is performed correctly. The
MR3 register must be loaded when all banks are idle and no data bursts are in progress,
and the controller must wait the specified time tMRD and tMOD before initiating a sub-
sequent operation.
Figure 56: Mode Register 3 (MR3) Definition
A9
A7
A6
A5
A4
A3
A8
A2
A1
A0
Mode register 3 (MR3)
Address bus
9
7
6
5
4
3
8
2
1
0
A10
A12 A11
BA0
BA1
10
11
12
13
14
15
A13
A14
A15
01
01
01
01
01
01
01
01
01
MPR 
1
1
BA2
16
17
18
01
01
01
01
01
M2
0
1
MPR Enable
Normal DRAM operations2
Dataflow from MPR
MPR_RF
M16
0
1
0
1
M17
0
0
1
1
Mode Register 
Mode register set (MR0)
Mode register set 1 (MR1)
Mode register set 2 (MR2)
Mode register set 3 (MR3)
MPR READ Function
Predefined  pattern3
Reserved
Reserved
Reserved
M0
0
1
0
1
M1
0
0
1
1
Notes:
1. MR3[18 and 15:3] are reserved for future use and must all be programmed to 0.
2. When MPR control is set for normal DRAM operation, MR3[1, 0] will be ignored.
3. Intended to be used for READ synchronization.
MULTIPURPOSE REGISTER (MPR)
The MULTIPURPOSE REGISTER function is used to output a predefined system timing
calibration bit sequence. Bit 2 is the master bit that enables or disables access to the
MPR register, and bits 1 and 0 determine which mode the MPR is placed in. The basic
concept of the multipurpose register is shown in Figure 57 (page 134).
If MR3[2] is a 0, then the MPR access is disabled, and the DRAM operates in normal
mode. However, if MR3[2] is a 1, then the DRAM no longer outputs normal read data
but outputs MPR data as defined by MR3[0, 1]. If MR3[0, 1] is equal to 00, then a prede-
fined read pattern for system calibration is selected.
To enable the MPR, the MRS command is issued to MR3, and MR3[2] = 1. Prior to issu-
ing the MRS command, all banks must be in the idle state (all banks are precharged,
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 3 (MR3)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
133
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 134 -->

and tRP is met). When the MPR is enabled, any subsequent READ or RDAP commands
are redirected to the multipurpose register. The resulting operation when either a READ
or a RDAP command is issued, is defined by MR3[1:0] when the MPR is enabled (see 
Table 75 (page 135)). When the MPR is enabled, only READ or RDAP commands are al-
lowed until a subsequent MRS command is issued with the MPR disabled (MR3[2] = 0).
Power-down mode, self refresh, and any other nonREAD/RDAP commands are not al-
lowed during MPR enable mode. The RESET function is supported during MPR enable
mode.
Figure 57: Multipurpose Register (MPR) Block Diagram
Memory core
MR3[2] = 0 (MPR off)
DQ, DM, DQS, DQS#
Multipurpose register
predefined data for READs
MR3[2] = 1 (MPR on)
Notes:
1. A predefined data pattern can be read out of the MPR with an external READ com-
mand.
2. MR3[2] defines whether the data flow comes from the memory core or the MPR. When
the data flow is defined, the MPR contents can be read out continuously with a regular
READ or RDAP command.
Table 74: MPR Functional Description of MR3 Bits
MR3[2]
MR3[1:0]
Function
MPR
MPR READ Function
0
“Don’t Care”
Normal operation, no MPR transaction
All subsequent READs come from the DRAM memory array
All subsequent WRITEs go to the DRAM memory array
1
A[1:0]
(see Table 75 (page 135))
Enable MPR mode, subsequent READ/RDAP commands defined by bits 1 and
2
MPR Functional Description
The MPR JEDEC definition enables either a prime DQ (DQ0 on a x4 and a x8; on a x16,
DQ0 = lower byte and DQ8 = upper byte) to output the MPR data with the remaining
DQs driven LOW, or for all DQs to output the MPR data . The MPR readout supports
fixed READ burst and READ burst chop (MRS and OTF via A12/BC#) with regular READ
latencies and AC timings applicable, provided the DLL is locked as required.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 3 (MR3)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
134
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 135 -->

MPR addressing for a valid MPR read is as follows:
• A[1:0] must be set to 00 as the burst order is fixed per nibble
• A2 selects the burst order:
– BL8, A2 is set to 0, and the burst order is fixed to 0, 1, 2, 3, 4, 5, 6, 7
• For burst chop 4 cases, the burst order is switched on the nibble base along with the
following:
– A2 = 0; burst order = 0, 1, 2, 3
– A2 = 1; burst order = 4, 5, 6, 7
• Burst order bit 0 (the first bit) is assigned to LSB, and burst order bit 7 (the last bit) is
assigned to MSB
• A[9:3] are a “Don’t Care”
• A10 is a “Don’t Care”
• A11 is a “Don’t Care”
• A12: Selects burst chop mode on-the-fly, if enabled within MR0
• A13 is a “Don’t Care”
• BA[2:0] are a “Don’t Care”
MPR Register Address Definitions and Bursting Order
The MPR currently supports a single data format. This data format is a predefined read
pattern for system calibration. The predefined pattern is always a repeating 0–1 bit pat-
tern.
Examples of the different types of predefined READ pattern bursts are shown in the fol-
lowing figures.
Table 75: MPR Readouts and Burst Order Bit Mapping
MR3[2]
MR3[1:0]
Function
Burst
Length
Read
A[2:0]
Burst Order and Data Pattern
1
00
READ predefined pattern
for system calibration
BL8
000
Burst order: 0, 1, 2, 3, 4, 5, 6, 7
Predefined pattern: 0, 1, 0, 1, 0, 1, 0, 1
BC4
000
Burst order: 0, 1, 2, 3
Predefined pattern: 0, 1, 0, 1
BC4
100
Burst order: 4, 5, 6, 7
Predefined pattern: 0, 1, 0, 1
1
01
RFU
N/A
N/A
N/A
N/A
N/A
N/A
N/A
N/A
N/A
1
10
RFU
N/A
N/A
N/A
N/A
N/A
N/A
N/A
N/A
N/A
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 3 (MR3)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
135
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 136 -->

Table 75: MPR Readouts and Burst Order Bit Mapping (Continued)
MR3[2]
MR3[1:0]
Function
Burst
Length
Read
A[2:0]
Burst Order and Data Pattern
1
11
RFU
N/A
N/A
N/A
N/A
N/A
N/A
N/A
N/A
N/A
Note:
1. Burst order bit 0 is assigned to LSB, and burst order bit 7 is assigned to MSB of the selec-
ted MPR agent.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 3 (MR3)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
136
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 137 -->

Figure 58: MPR System Read Calibration with BL8: Fixed Burst Order Single Readout
T0
Ta0
Tb0
Tb1
Tc0
Tc1
Tc2
Tc3
Tc4
Tc5
Tc6
Tc7
Tc8
Tc9
Tc10
CK
CK#
MRS
PREA
READ1
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
MRS
NOP
NOP
Valid
Command
tMPRR
Don’t Care
Indicates break
in time scale
DQS, DQS#
Bank address
3
Valid
3
0
A[1:0]
Valid
02
1
A2
02
0
00
A[9:3]
Valid
00
0
1
A10/AP
Valid
0
0
A11
Valid
0
0
A12/BC#
Valid1
0
0
A[15:13]
Valid
0
DQ 
tMOD
tRP
tMOD
RL
Notes:
1. READ with BL8 either by MRS or OTF.
2. Memory controller must drive 0 on A[2:0].
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 3 (MR3)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
137
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 138 -->

Figure 59: MPR System Read Calibration with BL8: Fixed Burst Order, Back-to-Back Readout
T0
Ta
Tb
Tc0
Tc1
Tc2
Tc3
Tc4
Tc5
Tc6
Tc7
Tc8
Tc9
Tc10
Td
CK
CK#
tMPRR
Don’t Care
Indicates break
in time scale
RL
3
Valid
3
Bank address
Valid
A[1:0]
Valid
02
02
0
A2
12
02
1
0
0
A[15:13]
Valid
Valid
0
A[9:3]
Valid
Valid
00
00
A11
Valid
Valid
0
0
A12/BC#
Valid1
0
0
A10/AP
Valid
Valid
0
0
1
RL
PREA
READ1
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
MRS
Valid
Command
READ1
MRS
DQ 
Valid
DQS, DQS#
tRP
tMOD
tCCD
tMOD
Notes:
1. READ with BL8 either by MRS or OTF.
2. Memory controller must drive 0 on A[2:0].
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 3 (MR3)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
138
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 139 -->

Figure 60: MPR System Read Calibration with BC4: Lower Nibble, Then Upper Nibble
T0
Ta
Tb
CK
CK#
DQ 
DQS, DQS#
tMOD
tMPRR
Don’t Care
Tc0
Tc1
Tc2
Tc3
Tc4
Tc5
Tc6
Tc7
Tc8
Tc9
Tc10
Td
NOP
NOP
NOP
NOP
NOP
MRS
NOP
NOP
Valid
Command
MRS
PREA
READ1
READ1
NOP
NOP
Indicates break
in time scale
Bank address
3
Valid
3
Valid
0
A[1:0]
Valid
02
02
1
A2
14
03
0
00
A[9:3]
Valid
Valid
00
0
1
A10/AP
Valid
Valid
0
0
A11
Valid
Valid
0
0
A12/BC#
Valid1
Valid1
0
0
A[15:13]
Valid
Valid
0
RL
RL
tRF
tMOD
tCCD
Notes:
1. READ with BC4 either by MRS or OTF.
2. Memory controller must drive 0 on A[1:0].
3. A2 = 0 selects lower 4 nibble bits 0 . . . 3.
4. A2 = 1 selects upper 4 nibble bits 4 . . . 7.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 3 (MR3)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
139
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 140 -->

Figure 61: MPR System Read Calibration with BC4: Upper Nibble, Then Lower Nibble
T0
Ta
Tb
0
1
A10/AP
Valid
Valid
0
CK
CK#
MRS
PREA
READ1
READ1
NOP
NOP
NOP
NOP
NOP
NOP
NOP
MRS
NOP
NOP
Valid
Command
0
04
13
1
A2
tMOD
tMPRR
3
Valid
3
Bank address
Valid
02
02
0
A[1:0]
Valid
0
0
A[15:13]
Valid
Valid
0
0
A11
Valid
Valid
00
00
A[9:3]
Valid
Valid
Don’t Care
Tc0
Tc1
Tc2
Tc3
Tc4
Tc5
Tc6
Tc7
Tc8
Tc9
Tc10
Td
Indicates break
in time scale
RL
DQ 
DQS, DQS#
0
A12/BC#
Valid1
Valid1
0
RL
tRF
tMOD
tCCD
Notes:
1. READ with BC4 either by MRS or OTF.
2. Memory controller must drive 0 on A[1:0].
3. A2 = 1 selects upper 4 nibble bits 4 . . . 7.
4. A2 = 0 selects lower 4 nibble bits 0 . . . 3.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 3 (MR3)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
140
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

