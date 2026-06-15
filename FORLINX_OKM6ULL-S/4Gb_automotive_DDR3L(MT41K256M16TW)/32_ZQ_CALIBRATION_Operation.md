# ZQ CALIBRATION Operation

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 142–142

<!-- page 142 -->

ZQ CALIBRATION Operation
The ZQ CALIBRATION command is used to calibrate the DRAM output drivers (RON)
and ODT values (RTT) over process, voltage, and temperature, provided a dedicated
240Ω (±1%) external resistor is connected from the DRAM’s ZQ ball to VSSQ.
DDR3 SDRAM require a longer time to calibrate RON and ODT at power-up initialization
and self refresh exit, and a relatively shorter time to perform periodic calibrations.
DDR3 SDRAM defines two ZQ CALIBRATION commands: ZQCL and ZQCS. An example
of ZQ calibration timing is shown below.
All banks must be precharged and tRP must be met before ZQCL or ZQCS commands
can be issued to the DRAM. No other activities (other than issuing another ZQCL or
ZQCS command) can be performed on the DRAM channel by the controller for the du-
ration of tZQinit or tZQoper. The quiet time on the DRAM channel helps accurately cali-
brate RON and ODT. After DRAM calibration is achieved, the DRAM should disable the
ZQ ball’s current consumption path to reduce power.
ZQ CALIBRATION commands can be issued in parallel to DLL RESET and locking time.
Upon self refresh exit, an explicit ZQCL is required if ZQ calibration is desired.
In dual-rank systems that share the ZQ resistor between devices, the controller must not
enable overlap of tZQinit, tZQoper, or tZQCS between ranks.
Figure 62: ZQ CALIBRATION Timing (ZQCL and ZQCS)
NOP
ZQCL
NOP
NOP
Valid
Valid
ZQCS
NOP
NOP
NOP
Valid
Command
Indicates break
in time scale
T0
T1
Ta0
Ta1
Ta2
Ta3
Tb0
Tb1
Tc0
Tc1
Tc2
Address
Valid
Valid
Valid
A10
Valid
Valid
Valid
CK
CK#
Don’t Care
DQ
High-Z
High-Z
3
3
Activities
Activ-
ities
Valid
Valid
ODT
2
2
Valid
1
CKE
1
Valid
Valid
Valid
tZQCS
tZQinit or tZQoper
Notes:
1. CKE must be continuously registered HIGH during the calibration procedure.
2. ODT must be disabled via the ODT signal or the MRS during the calibration procedure.
3. All devices connected to the DQ bus should be High-Z during calibration.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
ZQ CALIBRATION Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
142
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

