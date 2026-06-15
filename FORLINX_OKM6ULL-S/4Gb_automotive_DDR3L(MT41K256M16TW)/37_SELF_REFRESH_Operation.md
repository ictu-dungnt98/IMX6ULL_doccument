# SELF REFRESH Operation

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 166–166

<!-- page 166 -->

PRECHARGE Operation
Input A10 determines whether one bank or all banks are to be precharged and, in the
case where only one bank is to be precharged, inputs BA[2:0] select the bank.
When all banks are to be precharged, inputs BA[2:0] are treated as “Don’t Care.” After a
bank is precharged, it is in the idle state and must be activated prior to any READ or
WRITE commands being issued.
SELF REFRESH Operation
The SELF REFRESH operation is initiated like a REFRESH command except CKE is LOW.
The DLL is automatically disabled upon entering SELF REFRESH and is automatically
enabled and reset upon exiting SELF REFRESH.
All power supply inputs (including VREFCA and VREFDQ) must be maintained at valid lev-
els upon entry/exit and during self refresh mode operation. VREFDQ may float or not
drive VDDQ/2 while in self refresh mode under certain conditions:
• VSS < VREFDQ < VDD is maintained.
• VREFDQ is valid and stable prior to CKE going back HIGH.
• The first WRITE operation may not occur earlier than 512 clocks after V REFDQ is valid.
• All other self refresh mode exit timing requirements are met.
The DRAM must be idle with all banks in the precharge state (tRP is satisfied and no
bursts are in progress) before a self refresh entry command can be issued. ODT must
also be turned off before self refresh entry by registering the ODT ball LOW prior to the
self refresh entry command (see On-Die Termination (ODT) ( for timing requirements).
If RTT,nom and RTT(WR) are disabled in the mode registers, ODT can be a “Don’t Care.”
After the self refresh entry command is registered, CKE must be held LOW to keep the
DRAM in self refresh mode.
After the DRAM has entered self refresh mode, all external control signals, except CKE
and RESET#, are “Don’t Care.” The DRAM initiates a minimum of one REFRESH com-
mand internally within the tCKE period when it enters self refresh mode.
The requirements for entering and exiting self refresh mode depend on the state of the
clock during self refresh mode. First and foremost, the clock must be stable (meeting
tCK specifications) when self refresh mode is entered. If the clock remains stable and
the frequency is not altered while in self refresh mode, then the DRAM is allowed to exit
self refresh mode after tCKESR is satisfied (CKE is allowed to transition HIGH tCKESR
later than when CKE was registered LOW). Since the clock remains stable in self refresh
mode (no frequency change), tCKSRE and tCKSRX are not required. However, if the
clock is altered during self refresh mode (if it is turned-off or its frequency changes),
then tCKSRE and tCKSRX must be satisfied. When entering self refresh mode, tCKSRE
must be satisfied prior to altering the clock's frequency. Prior to exiting self refresh
mode, tCKSRX must be satisfied prior to registering CKE HIGH.
When CKE is HIGH during self refresh exit, NOP or DES must be issued for tXS time. tXS
is required for the completion of any internal refresh already in progress and must be
satisfied before a valid command not requiring a locked DLL can be issued to the de-
vice. tXS is also the earliest time self refresh re-entry may occur. Before a command re-
quiring a locked DLL can be applied, a ZQCL command must be issued, tZQOPER tim-
ing must be met, and tXSDLL must be satisfied. ODT must be off during tXSDLL.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
PRECHARGE Operation
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
166
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

