# Architecture

> Nguồn: `emmc_4gb_8gb_ps8225_v50_wt.pdf` — trang 9–9

<!-- page 9 -->

Architecture
Figure 5: e.MMC Functional Block Diagram
RST_n
CMD
CLK
VDDIM
VCCM
VCCQM
DAT[7:0]
VSS
1
VSSQ
1
MMC
controller
e.MMC
NAND Flash
Registers
OCR
CSD
RCA
CID
ECSD
DSR
DS
Note:
1. VSS and VSSQ are internally connected.
MMC Protocol Independent of NAND Flash Technology
The MMC specification defines the communication protocol between a host and a de-
vice. The protocol is independent of the NAND Flash features included in the device.
The device has an intelligent on-board controller that manages the MMC communica-
tion protocol.
The controller also handles block management functions such as logical block alloca-
tion and wear leveling. These management functions require complex algorithms and
depend entirely on NAND Flash technology (generation or memory cell type).
The device handles these management functions internally, making them invisible to
the host processor.
Defect and Error Management
Micron e.MMC incorporates advanced technology for defect and error management. If
a defective block is identified, the device completely replaces the defective block with
one of the spare blocks. This process is invisible to the host and does not affect data
space allocated for the user.
The device also includes a built-in error correction code (ECC) algorithm to ensure that
data integrity is maintained.
To make the best use of these advanced technologies and ensure proper data loading
and storage over the life of the device, the host must exercise the following precautions:
• Check the status after WRITE, READ, and ERASE operations.
• Avoid power-down during WRITE and ERASE operations.
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
Architecture
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
9
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

