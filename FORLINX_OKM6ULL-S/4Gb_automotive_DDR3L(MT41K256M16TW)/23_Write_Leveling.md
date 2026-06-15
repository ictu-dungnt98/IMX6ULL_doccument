# Write Leveling

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 112–116

<!-- page 112 -->

Write Leveling
For better signal integrity, DDR3 SDRAM memory modules have adopted fly-by topolo-
gy for the commands, addresses, control signals, and clocks. Write leveling is a scheme
for the memory controller to adjust or de-skew the DQS strobe (DQS, DQS#) to CK rela-
tionship at the DRAM with a simple feedback feature provided by the DRAM. Write lev-
eling is generally used as part of the initialization process, if required. For normal
DRAM operation, this feature must be disabled. This is the only DRAM operation where
the DQS functions as an input (to capture the incoming clock) and the DQ function as
outputs (to report the state of the clock). Note that nonstandard ODT schemes are re-
quired.
The memory controller using the write leveling procedure must have adjustable delay
settings on its DQS strobe to align the rising edge of DQS to the clock at the DRAM pins.
This is accomplished when the DRAM asynchronously feeds back the CK status via the
DQ bus and samples with the rising edge of DQS. The controller repeatedly delays the
DQS strobe until a CK transition from 0 to 1 is detected. The DQS delay established by
this procedure helps ensure tDQSS, tDSS, and tDSH specifications in systems that use
fly-by topology by de-skewing the trace length mismatch. A conceptual timing of this
procedure is shown in Figure 43.
Figure 43: Write Leveling Concept
CK
CK#
Source
Differential DQS
Differential DQS
Differential DQS
DQ
DQ
CK
CK#
Destination
Destination
Push DQS to capture 
0–1 transition
T0
T1
T2
T3
T4
T5
T6
T7
T0
T1
T2
T3
T4
T5
T6
Tn
CK
CK#
T0
T1
T2
T3
T4
T5
T6
Tn
Don’t Care
1
1
0
0
When write leveling is enabled, the rising edge of DQS samples CK, and the prime DQ
outputs the sampled CK’s status. The prime DQ for a x4 or x8 configuration is DQ0 with
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Write Leveling
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
112
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 113 -->

all other DQ (DQ[7:1]) driving LOW. The prime DQ for a x16 configuration is DQ0 for the
lower byte and DQ8 for the upper byte. It outputs the status of CK sampled by LDQS
and UDQS. All other DQ (DQ[7:1], DQ[15:9]) continue to drive LOW. Two prime DQ on a
x16 enable each byte lane to be leveled independently.
The write leveling mode register interacts with other mode registers to correctly config-
ure the write leveling functionality. Besides using MR1[7] to disable/enable write level-
ing, MR1[12] must be used to enable/disable the output buffers. The ODT value, burst
length, and so forth need to be selected as well. This interaction is shown in Table 72. It
should also be noted that when the outputs are enabled during write leveling mode, the
DQS buffers are set as inputs, and the DQ are set as outputs. Additionally, during write
leveling mode, only the DQS strobe terminations are activated and deactivated via the
ODT ball. The DQ remain disabled and are not affected by the ODT ball.
Table 72: Write Leveling Matrix
Note 1 applies to the entire table
MR1[7]
MR1[12]
MR1[2, 6, 9]
DRAM
ODT Ball
DRAM
RTT,nom
DRAM State
Case
Notes
Write
Leveling
Output
Buffers
RTT,nom
Value
DQS
DQ
Disabled
See normal operations
Write leveling not enabled
0
 
Enabled
(1)
Disabled
(1)
n/a
Low
Off
Off
DQS not receiving: not terminated
Prime DQ High-Z: not terminated
Other DQ High-Z: not terminated
1
2
ΩΩ
ΩΩ, or
120Ω
High
On
DQS not receiving: terminated by RTT
Prime DQ High-Z: not terminated
Other DQ High-Z: not terminated
2
Enabled
(0)
n/a
Low
Off
DQS receiving: not terminated
Prime DQ driving CK state: not terminated
Other DQ driving LOW: not terminated
3
3
ΩΩ, or
120Ω
High
On
DQS receiving: terminated by RTT
Prime DQ driving CK state: not terminated
Other DQ driving LOW: not terminated
4
Notes:
1. Expected usage if used during write leveling: Case 1 may be used when DRAM are on a
dual-rank module and on the rank not being leveled or on any rank of a module not
being leveled on a multislot system. Case 2 may be used when DRAM are on any rank of
a module not being leveled on a multislot system. Case 3 is generally not used. Case 4 is
generally used when DRAM are on the rank that is being leveled.
2. Since the DRAM DQS is not being driven (MR1[12] = 1), DQS ignores the input strobe,
and all RTT,nom values are allowed. This simulates a normal standby state to DQS.
3. Since the DRAM DQS is being driven (MR1[12] = 0), DQS captures the input strobe, and
only some RTT,nom values are allowed. This simulates a normal write state to DQS.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Write Leveling
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
113
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 114 -->

Write Leveling Procedure
A memory controller initiates the DRAM write leveling mode by setting MR1[7] to 1, as-
suming the other programable features (MR0, MR1, MR2, and MR3) are first set and the
DLL is fully reset and locked. The DQ balls enter the write leveling mode going from a
High-Z state to an undefined driving state, so the DQ bus should not be driven. During
write leveling mode, only the NOP or DES commands are allowed. The memory con-
troller should attempt to level only one rank at a time; thus, the outputs of other ranks
should be disabled by setting MR1[12] to 1 in the other ranks. The memory controller
may assert ODT after a tMOD delay, as the DRAM will be ready to process the ODT tran-
sition. ODT should be turned on prior to DQS being driven LOW by at least ODTLon
delay (WL - 2 tCK), provided it does not violate the aforementioned tMOD delay require-
ment.
The memory controller may drive DQS LOW and DQS# HIGH after tWLDQSEN has
been satisfied. The controller may begin to toggle DQS after tWLMRD (one DQS toggle
is DQS transitioning from a LOW state to a HIGH state with DQS# transitioning from a
HIGH state to a LOW state, then both transition back to their original states). At a mini-
mum, ODTLon and tAON must be satisfied at least one clock prior to DQS toggling.
After tWLMRD and a DQS LOW preamble (tWPRE) have been satisfied, the memory
controller may provide either a single DQS toggle or multiple DQS toggles to sample CK
for a given DQS-to-CK skew. Each DQS toggle must not violate tDQSL (MIN) and tDQSH
(MIN) specifications. tDQSL (MAX) and tDQSH (MAX) specifications are not applicable
during write leveling mode. The DQS must be able to distinguish the CK’s rising edge
within tWLS and tWLH. The prime DQ will output the CK’s status asynchronously from
the associated DQS rising edge CK capture within tWLO. The remaining DQ that always
drive LOW when DQS is toggling must be LOW within tWLOE after the first tWLO is sat-
isfied (the prime DQ going LOW). As previously noted, DQS is an input and not an out-
put during this process. Figure 44 (page 115) depicts the basic timing parameters for
the overall write leveling procedure.
The memory controller will most likely sample each applicable prime DQ state and de-
termine whether to increment or decrement its DQS delay setting. After the memory
controller performs enough DQS toggles to detect the CK’s 0-to-1 transition, the memo-
ry controller should lock the DQS delay setting for that DRAM. After locking the DQS
setting is locked, leveling for the rank will have been achieved, and the write leveling
mode for the rank should be disabled or reprogrammed (if write leveling of another
rank follows).
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Write Leveling
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
114
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 115 -->

Figure 44: Write Leveling Sequence
CK
CK#
Command
T1
T2
Early remaining DQ
Late remaining DQ
tWLOE
NOP2
NOP
MRS1
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
NOP
tWLS
tWLH
Don’t Care
Undefined Driving Mode
Indicates break
in time scale
Prime DQ5
Differential DQS4
ODT
tMOD
tDQSL3
tDQSL3
tDQSH3
tDQSH3
tWLO
tWLMRD
tWLDQSEN
tWLO
tWLO
tWLO
Notes:
1. MRS: Load MR1 to enter write leveling mode.
2. NOP: NOP or DES.
3. DQS, DQS# needs to fulfill minimum pulse width requirements tDQSH (MIN) and tDQSL
(MIN) as defined for regular writes. The maximum pulse width is system-dependent.
4. Differential DQS is the differential data strobe (DQS, DQS#). Timing reference points are
the zero crossings. The solid line represents DQS; the dotted line represents DQS#.
5. DRAM drives leveling feedback on a prime DQ (DQ0 for x4 and x8). The remaining DQ
are driven LOW and remain in this state throughout the leveling procedure.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Write Leveling
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
115
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 116 -->

Write Leveling Mode Exit Procedure
After the DRAM are leveled, they must exit from write leveling mode before the normal
mode can be used. Figure 45 depicts a general procedure for exiting write leveling
mode. After the last rising DQS (capturing a 1 at T0), the memory controller should stop
driving the DQS signals after tWLO (MAX) delay plus enough delay to enable the memo-
ry controller to capture the applicable prime DQ state (at ~Tb0). The DQ balls become
undefined when DQS no longer remains LOW, and they remain undefined until tMOD
after the MRS command (at Te1).
The ODT input should be de-asserted LOW such that ODTLoff (MIN) expires after the
DQS is no longer driving LOW. When ODT LOW satisfies tIS, ODT must be kept LOW (at
~Tb0) until the DRAM is ready for either another rank to be leveled or until the normal
mode can be used. After DQS termination is switched off, write level mode should be
disabled via the MRS command (at Tc2). After tMOD is satisfied (at Te1), any valid com-
mand may be registered by the DRAM. Some MRS commands may be issued after tMRD
(at Td1).
Figure 45: Write Leveling Exit Procedure
NOP
CK
T0
T1
T2
Ta0
Tb0
Tc0
Tc1
Tc2
Td0
Td1
Te0
Te1
CK#
Command
ODT
RTT(DQ)
NOP
NOP
NOP
NOP
NOP
NOP
MRS
NOP
NOP
Address
MR1
Valid
Valid
Valid
Valid
Don’t Care
Transitioning
RTT DQS, RTT DQS#
RTT,nom
Undefined Driving Mode
tAOF (MAX)
tMRD
Indicates break
in time scale
DQS, DQS#
CK = 1
DQ
tIS
tAOF (MIN)
tMOD
tWLO + tWLOE
ODTLoff
Note:
1. The DQ result, = 1, between Ta0 and Tc0, is a result of the DQS, DQS# signals capturing
CK HIGH just after the T0 state.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Write Leveling
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
116
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

