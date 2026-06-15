# Mode Register 1 (MR1)

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 127–129

<!-- page 127 -->

Mode Register 1 (MR1)
The mode register 1 (MR1) controls additional functions and features not available in
the other mode registers: Q OFF (OUTPUT DISABLE), TDQS (for the x8 configuration
only), DLL ENABLE/DLL DISABLE, RTT,nom value (ODT), WRITE LEVELING, POSTED
CAS ADDITIVE latency, and OUTPUT DRIVE STRENGTH. These functions are control-
led via the bits shown in Figure 52 (page 127). The MR1 register is programmed via the
MRS command and retains the stored information until it is reprogrammed, until RE-
SET# goes LOW, or until the device loses power. Reprogramming the MR1 register will
not alter the contents of the memory array, provided it is performed correctly.
The MR1 register must be loaded when all banks are idle and no bursts are in progress.
The controller must satisfy the specified timing parameters tMRD and tMOD before ini-
tiating a subsequent operation.
Figure 52: Mode Register 1 (MR1) Definition
AL
RTT
Q Off
A9
A7 A6
A5 A4 A3
A8
A2
A1 A0
Mode register 1 (MR1)
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
A12
A11
BA0
BA1
10
11
12
13
M0
0
1
DLL Enable
Enable (normal)
Disable
M5
0
0
1
1
Output Drive St rength
RZQ/6 (40Ω [NOM])
RZQ/7 (34Ω [NOM])
Reserved
Reserved
14
WL
01
01
1
0
ODS DLL
RTT
TDQS
M12
0
1
Q Off
Enabled
Disabled
BA2
15
01
M7
0
1
Write Levelization
Disable (normal)
Enable
Additive Latency (AL)
Disabled (AL = 0)
AL = CL - 1
AL = CL - 2
Reserved
M3
0
1
0
1
M4
0
0
1
1
RTT
ODS
M1
0
1
0
1
A13
A14
A15
16
17
18
01
M11
0
1
TDQS 
Disabled
Enabled
01
01
RTT,nom (ODT) 2
Non- Writes
RTT,nom disabled
RZQ/4 (60Ω [NOM])
RZQ/2 (120Ω [NOM])
RZQ/6 (40Ω [NOM])
RZQ/12 (20Ω [NOM])
RZQ/8 (30Ω [NOM])
Reserved
Reserved
RTT,nom (ODT) 3
Writes
RTT,nom disabled
RZQ/4 (60Ω [NOM])
RZQ/2 (120Ω [NOM])
RZQ/6 (40Ω [NOM])
n/a
n/a
Reserved
Reserved
M2
0
1
0
1
0
1
0
1
M6
0
0
1
1
0
0
1
1
M9
0
0
0
0
1
1
1
1
Mode Register 
Mode register set 0 (MR0)
Mode register set 1 (MR1)
Mode register set 2 (MR2)
Mode register set 3 (MR3)
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
Notes:
1. MR1[18, 15:13, 10, 8] are reserved for future use and must be programmed to 0.
2. During write leveling, if MR1[7] and MR1[12] are 1, then all RTT,nom values are available
for use.
3. During write leveling, if MR1[7] is a 1, but MR1[12] is a 0, then only RTT,nom write values
are available for use.
DLL Enable/DLL Disable
The DLL may be enabled or disabled by programming MR1[0] during the LOAD MODE
command, as shown in Figure 52 (page 127). The DLL must be enabled for normal oper-
ation. DLL enable is required during power-up initialization and upon returning to nor-
mal operation after having disabled the DLL for the purpose of debugging or evalua-
tion. Enabling the DLL should always be followed by resetting the DLL using the appro-
priate LOAD MODE command.
If the DLL is enabled prior to entering self refresh mode, the DLL is automatically disa-
bled when entering SELF REFRESH operation and is automatically re-enabled and reset
upon exit of SELF REFRESH operation. If the DLL is disabled prior to entering self re-
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 1 (MR1)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
127
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 128 -->

fresh mode, the DLL remains disabled even upon exit of SELF REFRESH operation until
it is re-enabled and reset.
The DRAM is not tested to check—nor does Micron warrant compliance with—normal
mode timings or functionality when the DLL is disabled. An attempt has been made to
have the DRAM operate in the normal mode where reasonably possible when the DLL
has been disabled; however, by industry standard, a few known exceptions are defined:
• ODT is not allowed to be used
• The output data is no longer edge-aligned to the clock
• CL and CWL can only be six clocks
When the DLL is disabled, timing and functionality can vary from the normal operation
specifications when the DLL is enabled (see DLL Disable Mode (page 106)). Disabling
the DLL also implies the need to change the clock frequency (see Input Clock Frequen-
cy Change (page 110)).
Output Drive Strength
The DDR3 SDRAM uses a programmable impedance output buffer. The drive strength
mode register setting is defined by MR1[5, 1]. RZQ/7 (34Ω [NOM]) is the primary output
driver impedance setting for DDR3 SDRAM devices. To calibrate the output driver im-
pedance, an external precision resistor (RZQ) is connected between the ZQ ball and
VSSQ. The value of the resistor must be 240Ω ±1%.
The output impedance is set during initialization. Additional impedance calibration up-
dates do not affect device operation, and all data sheet timings and current specifica-
tions are met during an update.
To meet the 34Ω specification, the output drive strength must be set to 34Ω during initi-
alization. To obtain a calibrated output driver impedance after power-up, the DDR3
SDRAM needs a calibration command that is part of the initialization and reset proce-
dure.
OUTPUT ENABLE/DISABLE
The OUTPUT ENABLE function is defined by MR1[12], as shown in Figure 52 (page
127). When enabled (MR1[12] = 0), all outputs (DQ, DQS, DQS#) function when in the
normal mode of operation. When disabled (MR1[12] = 1), all DDR3 SDRAM outputs
(DQ and DQS, DQS#) are tri-stated. The output disable feature is intended to be used
during IDD characterization of the READ current and during tDQSS margining (write
leveling) only.
TDQS Enable
Termination data strobe (TDQS) is a feature of the x8 DDR3 SDRAM configuration that
provides termination resistance (RTT) and may be useful in some system configurations.
TDQS is not supported in x4 or x16 configurations. When enabled via the mode register
(MR1[11]), the RTT that is applied to DQS and DQS# is also applied to TDQS and TDQS#.
In contrast to the RDQS function of DDR2 SDRAM, DDR3’s TDQS provides the termina-
tion resistance RTT only. The OUTPUT DATA STROBE function of RDQS is not provided
by TDQS; thus, RON does not apply to TDQS and TDQS#. The TDQS and DM functions
share the same ball. When the TDQS function is enabled via the mode register, the DM
function is not supported. When the TDQS function is disabled, the DM function is pro-
vided, and the TDQS# ball is not used. The TDQS function is available in the x8 DDR3
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 1 (MR1)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
128
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 129 -->

SDRAM configuration only and must be disabled via the mode register for the x4 and
x16 configurations.
On-Die Termination
ODT resistance RTT,nom is defined by MR1[9, 6, 2] (see Figure 52 (page 127)). The RTT
termination value applies to the DQ, DM, DQS, DQS#, and TDQS, TDQS# balls. DDR3
supports multiple RTT termination values based on RZQ/n where n can be 2, 4, 6, 8, or
12 and RZQ is 240Ω.
Unlike DDR2, DDR3 ODT must be turned off prior to reading data out and must remain
off during a READ burst. RTT,nom termination is allowed any time after the DRAM is ini-
tialized, calibrated, and not performing read access, or when it is not in self refresh
mode. Additionally, write accesses with dynamic ODT (RTT(WR)) enabled temporarily re-
places RTT,nom with RTT(WR).
The actual effective termination, RTT(EFF), may be different from the RTT targeted due to
nonlinearity of the termination. For RTT(EFF) values and calculations (see On-Die Termi-
nation (ODT) (page 179)).
The ODT feature is designed to improve signal integrity of the memory channel by ena-
bling the DDR3 SDRAM controller to independently turn on/off ODT for any or all devi-
ces. The ODT input control pin is used to determine when RTT is turned on (ODTL on)
and off (ODTL off), assuming ODT has been enabled via MR1[9, 6, 2].
Timings for ODT are detailed in On-Die Termination (ODT) (page 179).
WRITE LEVELING
The WRITE LEVELING function is enabled by MR1[7], as shown in Figure 52 (page 127).
Write leveling is used (during initialization) to deskew the DQS strobe to clock offset as
a result of fly-by topology designs. For better signal integrity, DDR3 SDRAM memory
modules adopted fly-by topology for the commands, addresses, control signals, and
clocks.
The fly-by topology benefits from a reduced number of stubs and their lengths. Howev-
er, fly-by topology induces flight time skews between the clock and DQS strobe (and
DQ) at each DRAM on the DIMM. Controllers will have a difficult time maintaining
tDQSS, tDSS, and tDSH specifications without supporting write leveling in systems
which use fly-by topology-based modules. Write leveling timing and detailed operation
information is provided in Write Leveling (page 112).
POSTED CAS ADDITIVE Latency
POSTED CAS ADDITIVE latency (AL) is supported to make the command and data bus
efficient for sustainable bandwidths in DDR3 SDRAM. MR1[4, 3] define the value of AL,
as shown in Figure 53 (page 130). MR1[4, 3] enable the user to program the DDR3
SDRAM with AL = 0, CL - 1, or CL - 2.
With this feature, the DDR3 SDRAM enables a READ or WRITE command to be issued
after the ACTIVATE command for that bank prior to tRCD (MIN). The only restriction is
ACTIVATE to READ or WRITE + AL ≥ tRCD (MIN) must be satisfied. Assuming tRCD
(MIN) = CL, a typical application using this feature sets AL = CL - 1tCK = tRCD (MIN) - 1
tCK. The READ or WRITE command is held for the time of the AL before it is released
internally to the DDR3 SDRAM device. READ latency (RL) is controlled by the sum of
the AL and CAS latency (CL), RL = AL + CL. WRITE latency (WL) is the sum of CAS
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Register 1 (MR1)
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
129
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

