# MODE REGISTER SET (MRS) Command

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 141–141

<!-- page 141 -->

MPR Read Predefined Pattern
The predetermined read calibration pattern is a fixed pattern of 0, 1, 0, 1, 0, 1, 0, 1. The
following is an example of using the read out predetermined read calibration pattern.
The example is to perform multiple reads from the multipurpose register to do system
level read timing calibration based on the predetermined and standardized pattern.
The following protocol outlines the steps used to perform the read calibration:
1. Precharge all banks
2. After tRP is satisfied, set MRS, MR3[2] = 1 and MR3[1:0] = 00. This redirects all sub-
sequent reads and loads the predefined pattern into the MPR. As soon as tMRD
and tMOD are satisfied, the MPR is available
3. Data WRITE operations are not allowed until the MPR returns to the normal
DRAM state
4. Issue a read with burst order information (all other address pins are “Don’t Care”):
• A[1:0] = 00 (data burst order is fixed starting at nibble)
• A2 = 0 (for BL8, burst order is fixed as 0, 1, 2, 3, 4, 5, 6, 7)
• A12 = 1 (use BL8)
5. After RL = AL + CL, the DRAM bursts out the predefined read calibration pattern
(0, 1, 0, 1, 0, 1, 0, 1)
6. The memory controller repeats the calibration reads until read data capture at
memory controller is optimized
7. After the last MPR READ burst and after tMPRR has been satisfied, issue MRS,
MR3[2] = 0, and MR3[1:0] = “Don’t Care” to the normal DRAM state. All subse-
quent read and write accesses will be regular reads and writes from/to the DRAM
array
8. When tMRD and tMOD are satisfied from the last MRS, the regular DRAM com-
mands (such as activate a memory bank for regular read or write access) are per-
mitted
MODE REGISTER SET (MRS) Command
The mode registers are loaded via inputs BA[2:0], A[13:0]. BA[2:0] determine which
mode register is programmed:
• BA2 = 0, BA1 = 0, BA0 = 0 for MR0
• BA2 = 0, BA1 = 0, BA0 = 1 for MR1
• BA2 = 0, BA1 = 1, BA0 = 0 for MR2
• BA2 = 0, BA1 = 1, BA0 = 1 for MR3
The MRS command can only be issued (or re-issued) when all banks are idle and in the
precharged state (tRP is satisfied and no data bursts are in progress). The controller
must wait the specified time tMRD before initiating a subsequent operation such as an
ACTIVATE command (see Figure 48 (page 121)). There is also a restriction after issuing
an MRS command with regard to when the updated functions become available. This
parameter is specified by tMOD. Both tMRD and tMOD parameters are shown in Figure
48 (page 121) and Figure 49 (page 122). Violating either of these requirements will result
in unspecified operation.
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
MODE REGISTER SET (MRS) Command
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
141
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

