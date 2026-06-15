# DC Electrical Specifications – Device Power

> Nguồn: `emmc_4gb_8gb_ps8225_v50_wt.pdf` — trang 21–22

<!-- page 21 -->

DC Electrical Specifications – Device Power
The device current consumption for various device configurations is defined in the
power class fields of the ECSD register.
VCC is used for the NAND Flash device and its interface voltage; VCCQ is used for the
controller and the e.MMC interface voltage.
Figure 6: Device Power Diagram
NAND
control signals
NAND Flash
MMC controller
Core regulator
NAND
I/O block
Core
logic block
CLK
CMD
DAT[7:0]
VCC
VDDIM
C3
C4
VCCQ
NAND
data bus
C1
C5
C2
VCCQ
C6
VCCQ
MMC
I/O block
CLK
CMD
RST_n
DS
Table 10: Absolute Maximum Ratings
Parameters
Symbol
Min
Max
Unit
Voltage input
VIN
–0.6
4.6
V
VCC supply
VCC
–0.6
4.6
V
VCCQ supply
VCCQ
–0.6
4.6
V
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
DC Electrical Specifications – Device Power
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
21
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 22 -->

Table 11: Capacitor and Resistance Specifications
Parameter
Symbol
Min
Max
Typ
Units
Notes
Pull-up resistance: CMD
R_CMD
4.7
50
10
kΩ
1
Pull-up resistance: DAT[7:0]
R_DAT
10
50
50
kΩ
1
Pull-up resistance: RST_n
R_RST_n
4.7
50
50
kΩ
2
CLK/CMD/DAT[7:0] impedance
 
45
55
50
Ω
3
Serial resistance on CLK
SR_CLK
0
47
22
Ω
 
Pull-down resistance: DS
R_DS
10
100
–
kΩ
 
VCCQ capacitor
C1
2.2
4.7
2.2
µF
4
C2
0.1
0.22
0.1
VCC capacitor
C3
2.2
4.7
2.2
µF
5
C4
0.1
0.22
0.1
VDDIM capacitor (Creg)
C5
1
4.7
1
µF
6
C6
0.1
0.1
0.1
Notes:
1. Used to prevent bus floating.
2. If host does not use H/W RESET (RST_n), pull-up resistance is not needed on RST_n line
(Extended_CSD[162] = 00h).
3. Impedance match.
4. The coupling capacitor should be connected with VCCQ and VSSQ as closely as possible.
5. The coupling capacitor should be connected with VCC and VSS as closely as possible.
6. The coupling capacitor should be connected with VDDIM and VSS as closely as possible.
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
DC Electrical Specifications – Device Power
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
22
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

