# Mode Registers

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 121–121

<!-- page 121 -->

Mode Registers
Mode registers (MR0–MR3) are used to define various modes of programmable opera-
tions of the DDR3 SDRAM. A mode register is programmed via the mode register set
(MRS) command during initialization, and it retains the stored information (except for
MR0[8], which is self-clearing) until it is reprogrammed, RESET# goes LOW, the device
loses power.
Contents of a mode register can be altered by re-executing the MRS command. Even if
the user wants to modify only a subset of the mode register’s variables, all variables
must be programmed when the MRS command is issued. Reprogramming the mode
register will not alter the contents of the memory array, provided it is performed cor-
rectly.
The MRS command can only be issued (or re-issued) when all banks are idle and in the
precharged state (tRP is satisfied and no data bursts are in progress). After an MRS com-
mand has been issued, two parameters must be satisfied: tMRD and tMOD. The control-
ler must wait tMRD before initiating any subsequent MRS commands.
Figure 48: MRS to MRS Command Timing (tMRD)
Valid
Valid
MRS1
MRS2
NOP
NOP
NOP
NOP
T0
T1
T2
Ta0
Ta1
Ta2
CK#
CK
Command
Address
CKE3
Don’t Care
Indicates break
in time scale
tMRD
Notes:
1. Prior to issuing the MRS command, all banks must be idle and precharged, tRP (MIN)
must be satisfied, and no data bursts can be in progress.
2.
tMRD specifies the MRS to MRS command minimum cycle time.
3. CKE must be registered HIGH from the MRS command until tMRSPDEN (MIN) (see Pow-
er-Down Mode (page 169)).
4. For a CAS latency change, tXPDLL timing must be met before any non-MRS command.
The controller must also wait tMOD before initiating any non-MRS commands (exclud-
ing NOP and DES). The DRAM requires tMOD in order to update the requested features,
with the exception of DLL RESET, which requires additional time. Until tMOD has been
satisfied, the updated features are to be assumed unavailable.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Mode Registers
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
121
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

