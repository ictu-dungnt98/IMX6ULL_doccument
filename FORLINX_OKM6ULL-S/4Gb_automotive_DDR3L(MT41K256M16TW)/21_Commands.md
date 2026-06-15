# Commands

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 102–109

<!-- page 102 -->

Commands
DESELECT
The DESELT (DES) command (CS# HIGH) prevents new commands from being execu-
ted by the DRAM. Operations already in progress are not affected.
NO OPERATION
The NO OPERATION (NOP) command (CS# LOW) prevents unwanted commands from
being registered during idle or wait states. Operations already in progress are not affec-
ted.
ZQ CALIBRATION LONG
The ZQ CALIBRATION LONG (ZQCL) command is used to perform the initial calibra-
tion during a power-up initialization and reset sequence (see Figure 46 (page 118)).
This command may be issued at any time by the controller, depending on the system
environment. The ZQCL command triggers the calibration engine inside the DRAM. Af-
ter calibration is achieved, the calibrated values are transferred from the calibration en-
gine to the DRAM I/O, which are reflected as updated RON and ODT values.
The DRAM is allowed a timing window defined by either tZQinit or tZQoper to perform
a full calibration and transfer of values. When ZQCL is issued during the initialization
sequence, the timing parameter tZQinit must be satisfied. When initialization is com-
plete, subsequent ZQCL commands require the timing parameter tZQoper to be satis-
fied.
ZQ CALIBRATION SHORT
The ZQ CALIBRATION SHORT (ZQCS) command is used to perform periodic calibra-
tions to account for small voltage and temperature variations. A shorter timing window
is provided to perform the reduced calibration and transfer of values as defined by tim-
ing parameter tZQCS. A ZQCS command can effectively correct a minimum of 0.5% RON
and RTT impedance error within 64 clock cycles, assuming the maximum sensitivities
specified in DDR3L 34 Ohm Output Driver Sensitivity (page 61).
ACTIVATE
The ACTIVATE command is used to open (or activate) a row in a particular bank for a
subsequent access. The value on the BA[2:0] inputs selects the bank, and the address
provided on inputs A[n:0] selects the row. This row remains open (or active) for accesses
until a PRECHARGE command is issued to that bank.
A PRECHARGE command must be issued before opening a different row in the same
bank.
READ
The READ command is used to initiate a burst read access to an active row. The address
provided on inputs A[2:0] selects the starting column address, depending on the burst
length and burst type selected (see Burst Order table for additional information). The
value on input A10 determines whether auto precharge is used. If auto precharge is se-
lected, the row being accessed will be precharged at the end of the READ burst. If auto
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Commands
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
102
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 103 -->

precharge is not selected, the row will remain open for subsequent accesses. The value
on input A12 (if enabled in the mode register) when the READ command is issued de-
termines whether BC4 (chop) or BL8 is used. After a READ command is issued, the
READ burst may not be interrupted.
Table 69: READ Command Summary
Function
Symbol
CKE
CS#
RAS#
CAS#
WE#
BA
[2:0]
An
A12
A10
A[11,
9:0]
Prev.
Cycle
Next
Cycle
READ
BL8MRS,
BC4MRS
RD
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
BC4OTF
RDS4
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
BL8OTF
RDS8
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
READ with
auto
precharge
BL8MRS,
BC4MRS
RDAP
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
BC4OTF
RDAPS4
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
BL8OTF
RDAPS8
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
WRITE
The WRITE command is used to initiate a burst write access to an active row. The value
on the BA[2:0] inputs selects the bank. The value on input A10 determines whether auto
precharge is used. The value on input A12 (if enabled in the MR) when the WRITE com-
mand is issued determines whether BC4 (chop) or BL8 is used.
Input data appearing on the DQ is written to the memory array subject to the DM input
logic level appearing coincident with the data. If a given DM signal is registered LOW,
the corresponding data will be written to memory. If the DM signal is registered HIGH,
the corresponding data inputs will be ignored and a WRITE will not be executed to that
byte/column location.
Table 70: WRITE Command Summary
Function
Symbol
CKE
CS# RAS# CAS#
WE#
BA
[2:0]
An
A12
A10
A[11,
9:0]
Prev.
Cycle
Next
Cycle
WRITE
BL8MRS,
BC4MRS
WR
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
BC4OTF
WRS4
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
BL8OTF
WRS8
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
WRITE with
auto
precharge
BL8MRS,
BC4MRS
WRAP
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
BC4OTF
WRAPS4
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
BL8OTF
WRAPS8
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
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Commands
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
103
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 104 -->

PRECHARGE
The PRECHARGE command is used to de-activate the open row in a particular bank or
in all banks. The bank(s) are available for a subsequent row access a specified time (tRP)
after the PRECHARGE command is issued, except in the case of concurrent auto pre-
charge. A READ or WRITE command to a different bank is allowed during a concurrent
auto precharge as long as it does not interrupt the data transfer in the current bank and
does not violate any other timing parameters. Input A10 determines whether one or all
banks are precharged. In the case where only one bank is precharged, inputs BA[2:0] se-
lect the bank; otherwise, BA[2:0] are treated as “Don’t Care.”
After a bank is precharged, it is in the idle state and must be activated prior to any READ
or WRITE commands being issued to that bank. A PRECHARGE command is treated as
a NOP if there is no open row in that bank (idle state) or if the previously open row is
already in the process of precharging. However, the precharge period is determined by
the last PRECHARGE command issued to the bank.
REFRESH
The REFRESH command is used during normal operation of the DRAM and is analo-
gous to CAS#-before-RAS# (CBR) refresh or auto refresh. This command is nonpersis-
tent, so it must be issued each time a refresh is required. The addressing is generated by
the internal refresh controller. This makes the address bits a “Don’t Care” during a RE-
FRESH command. The DRAM requires REFRESH cycles at an average interval of 7.8μs
(maximum when TC ≤ 85°C or 3.9μs maximum when TC ≤ 95°C). The REFRESH period
begins when the REFRESH command is registered and ends tRFC (MIN) later.
To allow for improved efficiency in scheduling and switching between tasks, some flexi-
bility in the absolute refresh interval is provided. A maximum of eight REFRESH com-
mands can be posted to any given DRAM, meaning that the maximum absolute interval
between any REFRESH command and the next REFRESH command is nine times the
maximum average interval refresh rate. Self refresh may be entered with up to eight RE-
FRESH commands being posted. After exiting self refresh (when entered with posted
REFRESH commands), additional posting of REFRESH commands is allowed to the ex-
tent that the maximum number of cumulative posted REFRESH commands (both pre-
and post-self refresh) does not exceed eight REFRESH commands.
At any given time, a maximum of 16 REFRESH commands can be issued within
2 x tREFI.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Commands
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
104
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 105 -->

Figure 38: Refresh Mode
NOP1
NOP1
NOP1
PRE
RA
Bank(s)3
BA
REF
NOP5
REF2
NOP5
ACT
NOP5
One bank
All banks
tCK
tCH
tCL
RA
tRFC2
tRP
tRFC (MIN)
T0
T1
T2
T3
T4
Ta0
Tb0
Ta1
Tb1
Tb2
Don’t Care
Indicates break
in time scale
Valid5
Valid5
Valid5
CK
CK#
Command
CKE
Address
A10
BA[2:0]
DQ4
DM4
DQS, DQS#4
Notes:
1. NOP commands are shown for ease of illustration; other valid commands may be possi-
ble at these times. CKE must be active during the PRECHARGE, ACTIVATE, and REFRESH
commands, but may be inactive at other times (see Power-Down Mode (page 169)).
2. The second REFRESH is not required, but two back-to-back REFRESH commands are
shown.
3. “Don’t Care” if A10 is HIGH at this point; however, A10 must be HIGH if more than one
bank is active (must precharge all active banks).
4. For operations shown, DM, DQ, and DQS signals are all “Don’t Care”/High-Z.
5. Only NOP and DES commands are allowed after a REFRESH command and until tRFC
(MIN) is satisfied.
SELF REFRESH
The SELF REFRESH command is used to retain data in the DRAM, even if the rest of the
system is powered down. When in self refresh mode, the DRAM retains data without ex-
ternal clocking. Self refresh mode is also a convenient method used to enable/disable
the DLL as well as to change the clock frequency within the allowed synchronous oper-
ating range (see Input Clock Frequency Change (page 110)). All power supply inputs
(including VREFCA and VREFDQ) must be maintained at valid levels upon entry/exit and
during self refresh mode operation. VREFDQ may float or not drive VDDQ/2 while in self
refresh mode under the following conditions:
• VSS < VREFDQ < VDD is maintained
• VREFDQ is valid and stable prior to CKE going back HIGH
• The first WRITE operation may not occur earlier than 512 clocks after V REFDQ is valid
• All other self refresh mode exit timing requirements are met
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Commands
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
105
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 106 -->

DLL Disable Mode
If the DLL is disabled by the mode register (MR1[0] can be switched during initialization
or later), the DRAM is targeted, but not guaranteed, to operate similarly to the normal
mode, with a few notable exceptions:
• The DRAM supports only one value of CAS latency (CL = 6) and one value of CAS
WRITE latency (CWL = 6).
• DLL disable mode affects the read data clock-to-data strobe relationship (tDQSCK),
but not the read data-to-data strobe relationship (tDQSQ, tQH). Special attention is
required to line up the read data with the controller time domain when the DLL is dis-
abled.
• In normal operation (DLL on), tDQSCK starts from the rising clock edge AL + CL
cycles after the READ command. In DLL disable mode, tDQSCK starts AL + CL - 1 cy-
cles after the READ command. Additionally, with the DLL disabled, the value of
tDQSCK could be larger than tCK.
The ODT feature (including dynamic ODT) is not supported during DLL disable mode.
The ODT resistors must be disabled by continuously registering the ODT ball LOW by
programming RTT,nom MR1[9, 6, 2] and RTT(WR) MR2[10, 9] to 0 while in the DLL disable
mode.
Specific steps must be followed to switch between the DLL enable and DLL disable
modes due to a gap in the allowed clock rates between the two modes (tCK [AVG] MAX
and tCK [DLL_DIS] MIN, respectively). The only time the clock is allowed to cross this
clock rate gap is during self refresh mode. Thus, the required procedure for switching
from the DLL enable mode to the DLL disable mode is to change frequency during self
refresh:
1. Starting from the idle state (all banks are precharged, all timings are fulfilled, ODT
is turned off, and RTT,nom and RTT(WR) are High-Z), set MR1[0] to 1 to disable the
DLL.
2. Enter self refresh mode after tMOD has been satisfied.
3. After tCKSRE is satisfied, change the frequency to the desired clock rate.
4. Self refresh may be exited when the clock is stable with the new frequency for
tCKSRX. After tXS is satisfied, update the mode registers with appropriate values.
5. The DRAM will be ready for its next command in the DLL disable mode after the
greater of tMRD or tMOD has been satisfied. A ZQCL command should be issued
with appropriate timings met.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Commands
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
106
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 107 -->

Figure 39: DLL Enable Mode to DLL Disable Mode
Command
T0
T1
Ta0
Ta1
Tb0
Tc0
Td0
Td1
Te0
Te1
Tf0
CK
CK#
ODT9
Valid1
Don’t Care
Valid1
SRE3
NOP
MRS2
NOP
SRX4
MRS5
Valid1
NOP
NOP
Indicates break
in time scale
tMOD
tCKSRE
tMOD
tXS
tCKESR 
CKE
tCKSRX8
7
6
Notes:
1. Any valid command.
2. Disable DLL by setting MR1[0] to 1.
3. Enter SELF REFRESH.
4. Exit SELF REFRESH.
5. Update the mode registers with the DLL disable parameters setting.
6. Starting with the idle state, RTT is in the High-Z state.
7. Change frequency.
8. Clock must be stable tCKSRX.
9. Static LOW in the case that RTT,nom or RTT(WR) is enabled; otherwise, static LOW or HIGH.
A similar procedure is required for switching from the DLL disable mode back to the
DLL enable mode. This also requires changing the frequency during self refresh mode
(see Figure 40 (page 108)).
1. Starting from the idle state (all banks are precharged, all timings are fulfilled, ODT
is turned off, and RTT,nom and RTT(WR) are High-Z), enter self refresh mode.
2. After tCKSRE is satisfied, change the frequency to the new clock rate.
3. Self refresh may be exited when the clock is stable with the new frequency for
tCKSRX. After tXS is satisfied, update the mode registers with the appropriate val-
ues. At a minimum, set MR1[0] to 0 to enable the DLL. Wait tMRD, then set MR0[8]
to 1 to enable DLL RESET.
4. After another tMRD delay is satisfied, update the remaining mode registers with
the appropriate values.
5. The DRAM will be ready for its next command in the DLL enable mode after the
greater of tMRD or tMOD has been satisfied. However, before applying any com-
mand or function requiring a locked DLL, a delay of tDLLK after DLL RESET must
be satisfied. A ZQCL command should be issued with the appropriate timings
met.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Commands
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
107
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 108 -->

Figure 40: DLL Disable Mode to DLL Enable Mode
CKE
T0
Ta0
Ta1
Tb0
Tc0
Tc1
Td0
Te0
Tf0
Tg0
CK
CK#
ODT10
SRE1
NOP
Command
NOP
SRX2
MRS3
MRS4
MRS5
Valid6
Valid
Don’t Care
Indicates break
in time scale
tCKSRE
tCKSRX9
8
7
tXS
tMRD
tMRD
tCKESR 
ODTLoff + 1 × tCK
Th0
tDLLK
Notes:
1. Enter SELF REFRESH.
2. Exit SELF REFRESH.
3. Wait tXS, then set MR1[0] to 0 to enable DLL.
4. Wait tMRD, then set MR0[8] to 1 to begin DLL RESET.
5. Wait tMRD, update registers (CL, CWL, and write recovery may be necessary).
6. Wait tMOD, any valid command.
7. Starting with the idle state.
8. Change frequency.
9. Clock must be stable at least tCKSRX.
10. Static LOW in the case that RTT,nom or RTT(WR) is enabled; otherwise, static LOW or HIGH.
The clock frequency range for the DLL disable mode is specified by the parameter tCK
(DLL_DIS). Due to latency counter and timing restrictions, only CL = 6 and CWL = 6 are
supported.
DLL disable mode will affect the read data clock to data strobe relationship (tDQSCK)
but not the data strobe to data relationship (tDQSQ, tQH). Special attention is needed to
line up read data to the controller time domain.
Compared to the DLL on mode where tDQSCK starts from the rising clock edge AL + CL
cycles after the READ command, the DLL disable mode tDQSCK starts AL + CL - 1 cycles
after the READ command.
WRITE operations function similarly between the DLL enable and DLL disable modes;
however, ODT functionality is not allowed with DLL disable mode.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Commands
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
108
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 109 -->

Figure 41: DLL Disable tDQSCK
T0
T1
T2
T3
T4
T5
T6
T7
T8
T9
T10
Don’t Care
Transitioning Data
Valid
NOP
READ
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
CK
CK#
Command
Address
DI
b + 3
DI
b + 2
DI
b + 1
DIb
DI
b + 7
DI
b + 6
DI
b + 5
DI
b + 4
DQ BL8 DLL on
DQS, DQS# DLL on
DQ BL8 DLL disable
DQS, DQS# DLL off
DQ BL8 DLL disable
DQS, DQS# DLL off
RL = AL + CL = 6 (CL = 6, AL = 0)
CL = 6 
DI
b + 3
DI
b + 2
DI
b + 1
DIb
DI
b + 7
DI
b + 6
DI
b + 5
DI
b + 4
DI
b + 3
DI
b + 2
DI
b + 1
DIb
DI
b + 7
DI
b + 6
DI
b + 5
DI
b + 4
tDQSCK (DLL_DIS) MIN
tDQSCK (DLL_DIS) MAX
RL (DLL_DIS) = AL + (CL - 1) = 5 
Table 71: READ Electrical Characteristics, DLL Disable Mode
Parameter
Symbol
Min
Max
Unit
Access window of DQS from CK, CK#
tDQSCK (DLL_DIS)
1
10
ns
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Commands
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
109
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

