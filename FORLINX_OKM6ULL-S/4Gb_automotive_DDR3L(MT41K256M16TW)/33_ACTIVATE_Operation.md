# ACTIVATE Operation

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 143–144

<!-- page 143 -->

ACTIVATE Operation
Before any READ or WRITE commands can be issued to a bank within the DRAM, a row
in that bank must be opened (activated). This is accomplished via the ACTIVATE com-
mand, which selects both the bank and the row to be activated.
After a row is opened with an ACTIVATE command, a READ or WRITE command may
be issued to that row, subject to the tRCD specification. However, if the additive latency
is programmed correctly, a READ or WRITE command may be issued prior to tRCD
(MIN). In this operation, the DRAM enables a READ or WRITE command to be issued
after the ACTIVATE command for that bank, but prior to tRCD (MIN) with the require-
ment that (ACTIVATE-to-READ/WRITE) + AL ≥ tRCD (MIN) (see Posted CAS Additive
Latency). tRCD (MIN) should be divided by the clock period and rounded up to the next
whole number to determine the earliest clock edge after the ACTIVATE command on
which a READ or WRITE command can be entered. The same procedure is used to con-
vert other specification limits from time units to clock cycles.
When at least one bank is open, any READ-to-READ command delay or WRITE-to-
WRITE command delay is restricted to tCCD (MIN).
A subsequent ACTIVATE command to a different row in the same bank can only be is-
sued after the previous active row has been closed (precharged). The minimum time in-
terval between successive ACTIVATE commands to the same bank is defined by tRC.
A subsequent ACTIVATE command to another bank can be issued while the first bank is
being accessed, which results in a reduction of total row-access overhead. The mini-
mum time interval between successive ACTIVATE commands to different banks is de-
fined by tRRD. No more than four bank ACTIVATE commands may be issued in a given
tFAW (MIN) period, and the tRRD (MIN) restriction still applies. The tFAW (MIN) param-
eter applies, regardless of the number of banks already opened or closed.
Figure 63: Example: Meeting tRRD (MIN) and tRCD (MIN)
Command
Don’t Care
T1
T0
T2
T3
T4
T5
T8
T9
tRRD
Row
Row
Col
Bank x
Bank y
Bank y
NOP
ACT
NOP
NOP
ACT
NOP
NOP
RD/WR
tRCD
BA[2:0]
CK#
Address
CK
T10
T11
NOP
NOP
Indicates break
in time scale
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
ACTIVATE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
143
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 144 -->

Figure 64: Example: tFAW
Command
Don’t Care
T1
T0
T4
T5
T8
T9
T10
T11
tRRD
Row
Row
Bank a
Bank b
Row
Bank c
Row
Bank d
Bank y
Row
Bank y
NOP
ACT
NOP
ACT
ACT
NOP
NOP
tFAW
BA[2:0]
CK#
Address
CK
T19
T20
NOP
ACT
ACT
Bank e
Indicates break
in time scale
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
ACTIVATE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
144
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

