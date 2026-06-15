# On-Die Termination (ODT)

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 179–181

<!-- page 179 -->

On-Die Termination (ODT)
On-die termination (ODT) is a feature that enables the DRAM to enable/disable and
turn on/off termination resistance for each DQ, DQS, DQS#, and DM for the x4 and x8
configurations (and TDQS, TDQS# for the x8 configuration, when enabled). ODT is ap-
plied to each DQ, UDQS, UDQS#, LDQS, LDQS#, UDM, and LDM signal for the x16 con-
figuration.
ODT is designed to improve signal integrity of the memory channel by enabling the
DRAM controller to independently turn on/off the DRAM’s internal termination resist-
ance for any grouping of DRAM devices. ODT is not supported during DLL disable
mode (simple functional representation shown below). The switch is enabled by the in-
ternal ODT control logic, which uses the external ODT ball and other control informa-
tion.
Figure 106: On-Die Termination
ODT
VDDQ/2
RTT
Switch
DQ, DQS, DQS#, 
DM, TDQS, TDQS#
To other
circuitry
such as
RCV, 
. . . 
Functional Representation of ODT
The value of RTT (ODT termination resistance value) is determined by the settings of
several mode register bits (see Table 85 (page 184)). The ODT ball is ignored while in
self refresh mode (must be turned off prior to self refresh entry) or if mode registers
MR1 and MR2 are programmed to disable ODT. ODT is comprised of nominal ODT and
dynamic ODT modes and either of these can function in synchronous or asynchronous
mode (when the DLL is off during precharge power-down or when the DLL is synchro-
nizing). Nominal ODT is the base termination and is used in any allowable ODT state.
Dynamic ODT is applied only during writes and provides OTF switching from no RTT or
RTT,nom to RTT(WR).
The actual effective termination, RTT(EFF), may be different from RTT targeted due to
nonlinearity of the termination. For RTT(EFF) values and calculations, see Table 31 (page
53).
Nominal ODT
ODT (NOM) is the base termination resistance for each applicable ball; it is enabled or
disabled via MR1[9, 6, 2] (see Mode Register 1 (MR1) Definition), and it is turned on or
off via the ODT ball.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
On-Die Termination (ODT)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
179
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 180 -->

Table 80: Truth Table – ODT (Nominal)
Note 1 applies to the entire table
MR1[9, 6, 2]
ODT Pin
DRAM Termination State
DRAM State
Notes
000
0
RTT,nom disabled, ODT off
Any valid
2
000
1
RTT,nom disabled, ODT on
Any valid except self refresh, read
3
000–101
0
RTT,nom enabled, ODT off
Any valid
2
000–101
1
RTT,nom enabled, ODT on
Any valid except self refresh, read
3
110 and 111
X
RTT,nom reserved, ODT on or off
Illegal
 
Notes:
1. Assumes dynamic ODT is disabled (see Dynamic ODT (page 182) when enabled).
2. ODT is enabled and active during most writes for proper termination, but it is not illegal
for it to be off during writes.
3. ODT must be disabled during reads. The RTT,nom value is restricted during writes. Dynam-
ic ODT is applicable if enabled.
Nominal ODT resistance RTT,nom is defined by MR1[9, 6, 2], as shown in Mode Register 1
(MR1) Definition. The RTT,nom termination value applies to the output pins previously
mentioned. DDR3 SDRAM supports multiple RTT,nom values based on RZQ/n where n
can be 2, 4, 6, 8, or 12 and RZQ is 240Ω. RTT,nom termination is allowed any time after the
DRAM is initialized, calibrated, and not performing read access, or when it is not in self
refresh mode.
Write accesses use RTT,nom if dynamic ODT (RTT(WR)) is disabled. If RTT,nom is used dur-
ing writes, only RZQ/2, RZQ/4, and RZQ/6 are allowed (see Table 84 (page 183)). ODT
timings are summarized in Table 81 (page 180), as well as listed in the Electrical Char-
acteristics and AC Operating Conditions table.
Examples of nominal ODT timing are shown in conjunction with the synchronous
mode of operation in Synchronous ODT Mode (page 188).
Table 81: ODT Parameters
Symbol
Description
Begins at
Defined to
Definition for All
DDR3L Speed Bins
Unit
ODTLon
ODT synchronous turn-on delay
ODT registered HIGH
RTT(ON) ±tAON
CWL + AL - 2
tCK
ODTLoff
ODT synchronous turn-off delay
ODT registered HIGH
RTT(OFF) ±tAOF
CWL + AL - 2
tCK
tAONPD
ODT asynchronous turn-on delay
ODT registered HIGH
RTT(ON)
2–8.5
ns
tAOFPD
ODT asynchronous turn-off delay
ODT registered HIGH
RTT(OFF)
2–8.5
ns
ODTH4
ODT minimum HIGH time after ODT
assertion or write (BC4)
ODT registered HIGH
or write registration
with ODT HIGH
ODT registered
LOW
4tCK
tCK
ODTH8
ODT minimum HIGH time after
write (BL8)
Write registration
with ODT HIGH
ODT registered
LOW
6tCK
tCK
tAON
ODT turn-on relative to ODTLon
completion
Completion of
ODTLon
RTT(ON)
See Electrical Charac-
teristics and AC Oper-
ating Conditions table
ps
tAOF
ODT turn-off relative to ODTLoff
completion
Completion of
ODTLoff
RTT(OFF)
0.5tCK ± 0.2tCK
tCK
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
On-Die Termination (ODT)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
180
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 181 -->

Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
On-Die Termination (ODT)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
181
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

