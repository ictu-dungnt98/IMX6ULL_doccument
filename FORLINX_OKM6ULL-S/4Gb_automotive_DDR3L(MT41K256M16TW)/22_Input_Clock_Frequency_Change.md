# Input Clock Frequency Change

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 110–111

<!-- page 110 -->

Input Clock Frequency Change
When the DDR3 SDRAM is initialized, the clock must be stable during most normal
states of operation. This means that after the clock frequency has been set to the stable
state, the clock period is not allowed to deviate, except for what is allowed by the clock
jitter and spread spectrum clocking (SSC) specifications.
The input clock frequency can be changed from one stable clock rate to another under
two conditions: self refresh mode and precharge power-down mode. It is illegal to
change the clock frequency outside of those two modes. For the self refresh mode con-
dition, when the DDR3 SDRAM has been successfully placed into self refresh mode and
tCKSRE has been satisfied, the state of the clock becomes a “Don’t Care.” When the
clock becomes a “Don’t Care,” changing the clock frequency is permissible if the new
clock frequency is stable prior to tCKSRX. When entering and exiting self refresh mode
for the sole purpose of changing the clock frequency, the self refresh entry and exit
specifications must still be met.
The precharge power-down mode condition is when the DDR3 SDRAM is in precharge
power-down mode (either fast exit mode or slow exit mode). Either ODT must be at a
logic LOW or RTT,nom and RTT(WR) must be disabled via MR1 and MR2. This ensures
RTT,nom and RTT(WR) are in an off state prior to entering precharge power-down mode,
and CKE must be at a logic LOW. A minimum of tCKSRE must occur after CKE goes LOW
before the clock frequency can change. The DDR3 SDRAM input clock frequency is al-
lowed to change only within the minimum and maximum operating frequency speci-
fied for the particular speed grade (tCK [AVG] MIN to tCK [AVG] MAX). During the input
clock frequency change, CKE must be held at a stable LOW level. When the input clock
frequency is changed, a stable clock must be provided to the DRAM tCKSRX before pre-
charge power-down may be exited. After precharge power-down is exited and tXP has
been satisfied, the DLL must be reset via the MRS. Depending on the new clock fre-
quency, additional MRS commands may need to be issued. During the DLL lock time,
RTT,nom and RTT(WR) must remain in an off state. After the DLL lock time, the DRAM is
ready to operate with a new clock frequency.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Input Clock Frequency Change
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
110
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 111 -->

Figure 42: Change Frequency During Precharge Power-Down
CK
CK#
Command
NOP
NOP
NOP
Address
CKE
DQ
DM
DQS, DQS#
NOP
tCK
Enter precharge
power-down mode
Exit precharge
power-down mode
T0
T1
Ta0
Tc0
Tb0
T2
Don’t Care
tCKE
tXP
MRS
DLL RESET
Valid
Valid
NOP
tCH
tIH
tIS
tCL
Tc1
Td0
Te1
Td1
tCKSRE
tCHb
tCLb
tCKb
tCHb
tCLb
tCKb
tCHb
tCLb
tCKb
tCPDED
ODT
NOP
Te0
Previous clock frequency
New clock frequency
Frequency
change
Indicates break
in time scale
tIH
tIS
tIH
tIS
tDLLK
tAOFPD/tAOF
tCKSRX
High-Z
High-Z
Notes:
1. Applicable for both SLOW-EXIT and FAST-EXIT precharge power-down modes.
2.
tAOFPD and tAOF must be satisfied and outputs High-Z prior to T1 (see On-Die Termina-
tion (ODT) for exact requirements).
3. If the RTT,nom feature was enabled in the mode register prior to entering precharge
power-down mode, the ODT signal must be continuously registered LOW, ensuring RTT
is in an off state. If the RTT,nom feature was disabled in the mode register prior to enter-
ing precharge power-down mode, RTT will remain in the off state. The ODT signal can
be registered LOW or HIGH in this case.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Input Clock Frequency Change
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
111
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

