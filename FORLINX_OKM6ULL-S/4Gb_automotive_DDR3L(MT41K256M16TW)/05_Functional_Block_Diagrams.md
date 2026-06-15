# Functional Block Diagrams

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 14–15

<!-- page 14 -->

Functional Block Diagrams
DDR3 SDRAM is a high-speed, CMOS dynamic random access memory. It is internally
configured as an 8-bank DRAM.
Figure 3: 1 Gig x 4 Functional Block Diagram
Bank 5
Bank 6
Bank 7
Bank 4
Bank 7
Bank 4
Bank 5
Bank 6
16
Row-
address
MUX
Control
logic
Column-
address
counter/
latch
Mode registers
11
Command 
decode
A[15:0]
BA[2:0]
16
Address
register
19
256
(x32)
8,192
I/O gating
DM mask logic
Column
decoder
Bank 0
memory
array
(65,536 x 256 x 32)
Bank 0
row-
address
latch
and
decoder
65,536
Sense amplifiers
Bank
control
logic
19
Bank 1
Bank 2
Bank 3
16
8
3
3
Refresh
counter
4
32
32
32
DQS, DQS#
Columns 0, 1, and 2
Columns 0, 1, and 2
ZQCL, ZQCS
To pull-up/pull-down
networks
READ 
drivers
DQ[3:0]
READ
FIFO
and
data
MUX
Data
4
3
Bank 1
Bank 2
Bank 3
DM
DM
CK, CK#
DQS, DQS#
ZQ CAL
CS#
ZQ
RZQ
CK, CK#
RAS#
WE#
CAS#
ODT
CKE
RESET#
CK, CK#
DLL
DQ[3:0]
(1 . . . 4)
(1, 2)
sw1
sw2
VDDQ/2
RTT,nom
RTT(WR)
sw1
sw2
VDDQ/2
RTT,nom
RTT(WR)
sw1
sw2
VDDQ/2
RTT,nom
RTT(WR)
OTF
BC4 (burst chop)
BC4
Column 2
(select upper or
lower nibble for BC4)
Data
interface
 WRITE 
drivers
and 
input
logic
ODT
control
VSSQ
A12
OTF
BC4
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Functional Block Diagrams
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
14
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 15 -->

Figure 4: 512 Meg x 8 Functional Block Diagram
Bank 5
Bank 6
Bank 7
Bank 4
Bank 7
Bank 4
Bank 5
Bank 6
16
Row-
address
MUX
Control
logic
Column-
address
counter/
latch
Mode registers
10
Command 
decode
A[15:0]
BA[2:0]
16
19
8,192
I/O gating
DM mask logic
Column
decoder
Bank 0
Memory
array
(65,536  x 128 x 64)
Bank 0
row-
address
latch
and
decoder
65,536
Sense amplifiers
Bank 
control
logic
19
Bank 1
Bank 2
Bank 3
16
7
3
3
Refresh
counter
8
64
64
64
DQS, DQS#
Columns 0, 1, and 2
Columns 0, 1, and 2
ZQCL, ZQCS
To ODT/output drivers
Read 
drivers
DQ[7:0]
READ
FIFO
and
data
MUX
Data
8
3
Bank 1
Bank 2
Bank 3
DM/TDQS
(shared pin)
TDQS#
CK, CK#
DQS/DQS#
ZQ CAL
ZQ
RZQ
ODT
CKE
CK, CK#
RAS#
WE#
CAS#
CS#
RESET#
CK, CK#
DLL
DQ[7:0]
DQ8
(1 . . . 8)
(1, 2)
sw1
sw2
VDDQ/2
RTT(WR)
RTT,nom
sw1
sw2
VDDQ/2
RTT,nom
RTT(WR)
sw1
sw2
VDDQ/2
RTT,nom
RTT(WR)
BC4 (burst chop)
BC4
BC4
Write 
drivers
and
input
logic
Data
interface
Column 2
(select upper or
lower nibble for BC4)
(128
x64)
ODT
control
Address
register
A12
VSSQ
OTF
OTF
Figure 5: 256 Meg x 16 Functional Block Diagram
Bank 5
Bank 6
Bank 7
Bank 4
Bank 7
Bank 4
Bank 5
Bank 6
13
Row-
address
MUX
Control
logic
Column-
address
counter/
latch
Mode registers
10
Command 
decode
A[14:0]
BA[2:0]
15
Address
register
18
(128
x128)
16,384
I/O gating
DM mask logic
Column
decoder
Bank 0
memory
array
(32,768 x 128 x 128)
Bank 0
row-
address
latch
and
decoder
32,768
Sense amplifiers
Bank
control
logic
18
Bank 1
Bank 2
Bank 3
15
7
3
3
Refresh
counter
16
128
128
128
LDQS, LDQS#, UDQS, UDQS#
Column 0, 1, and 2
Columns 0, 1, and 2
ZQCL, ZQCS
To ODT/output drivers
BC4
READ 
drivers
DQ[15:0]
READ
FIFO
and
data
MUX
Data
16
BC4 (burst chop)
3
Bank 1
Bank 2
Bank 3
LDM/UDM
CK, CK#
LDQS, LDQS#
UDQS, UDQS#
ZQ CAL
ZQ
RZQ
ODT
CKE
CK, CK#
RAS#
WE#
CAS#
CS#
RESET#
CK, CK#
DLL
DQ[15:0]
(1 . . . 16)
(1 . . . 4)
(1, 2)
sw1
sw2
VDDQ/2
RTT,nom
RTT(WR)
BC4
sw1
sw2
VDDQ/2
RTT,nom
RTT(WR)
sw1
sw2
VDDQ/2
RTT,nom
RTT(WR)
Column 2
(select upper or
lower nibble for BC4)
Data
interface
 WRITE 
drivers
and
input
logic
ODT
control
VSSQ
A12
OTF
OTF
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Functional Block Diagrams
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
15
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

