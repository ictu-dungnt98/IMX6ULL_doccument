# 153-Ball Signal Assignments

> Nguồn: `emmc_4gb_8gb_ps8225_v50_wt.pdf` — trang 7–7

<!-- page 7 -->

153-Ball Signal Assignments
Figure 3: 153 Ball (Top View, Ball Down)
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
Top View
1
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
1
2
NC
DAT3
VDDIM
NC
NC
NC
NC
NC
NC
NC
NC
NC
VSSQ
NC
2
3
DAT0
DAT4
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
VCCQ
3
4
DAT1
DAT5
VSSQ
NC
VCCQ
VCCQ
VSSQ
4
5
DAT2
DAT6
NC
RFU
VCC
VSS
DS
VSS
RST_n
CMD
VSSQ
VCCQ
5
6
VSS
DAT7
VCCQ
VCC
RFU
CLK
NC
VSSQ
6
7
RFU
NC
NC
VSS
RFU
NC
NC
NC
7
8
NC
NC
NC
RFU
VSS
NC
NC
NC
8
9
NC
NC
NC
RFU
VCC
NC
NC
NC
9
10
NC
NC
NC
RFU
RFU
RFU
VSS
VCC
RFU
NC
NC
RFU
10
11
NC
NC
NC
NC
NC
NC
11
12
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
12
13
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
13
14
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
NC
14
Notes:
1. Some previous versions of the JEDEC product or mechanical specification had defined
reserved for future use (RFU) balls as no connect (NC) balls. NC balls assigned in the pre-
vious specifications could have been connected to ground on the system board. To ena-
ble new feature introduction, some of these balls are assigned as RFU in the v4.4 me-
chanical specification. Any new PCB footprint implementations should use the new ball
assignments and leave the RFU balls floating on the system board.
2. VCC, VCCQ, VSS, and VSSQ balls must all be connected on the system board.
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
153-Ball Signal Assignments
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
7
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

