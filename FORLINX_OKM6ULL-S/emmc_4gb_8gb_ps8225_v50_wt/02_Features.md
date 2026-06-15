# Features

> Nguồn: `emmc_4gb_8gb_ps8225_v50_wt.pdf` — trang 1–4

<!-- page 1 -->

e·MMC™ Memory
MTFC4GACAJCN-1M WT, MTFC8GAKAJCN-1M WT
Features
• MultiMediaCard (MMC) controller and NAND Flash
• 153-ball FBGA
(RoHS compliant, "green package")
• VCC: 2.7–3.6V
• VCCQ (dual voltage): 1.65–1.95V; 2.7–3.6V
• Temperature ranges
– Operating temperature: –25˚C to +85˚C
– Storage temperature: –40˚C to +85˚C
MMC-Specific Features
• JEDEC/MMC standard version 5.0-compliant
(JEDEC Standard No. JESD84-B50)1
– Advanced 12-signal interface
– x1, x4, and x8 I/Os, selectable by host
– SDR/DDR modes up to 52 MHz clock speed
– HS200/HS400 modes
– Real-time clock
– Command classes: class 0 (basic); class 2 (block
read); class 4 (block write); class 5 (erase);
class 6 (write protection); class 7 (lock card)
– Temporary write protection
– Boot operation (high-speed boot)
– Sleep mode
– Replay-protected memory block (RPMB)
– Secure erase and secure trim
– Hardware reset signal
– Multiple partitions with enhanced attribute
– Permanent and power-on write protection
– High-priority interrupt (HPI)
– Background operation
– Reliable write
– Discard and sanitize
– Extended partitioning
– Context ID
Figure 1: Micron e·MMC Device
MMC controller
MMC
power
NAND Flash
power
MMC
interface
NAND Flash
MMC-Specific Features (Continued)
– Data TAG
– Packed commands
– Dynamic device capacity
– Backward compatible with previous MMC
– Cache
– Field firmware update (FFU)
– Device Health Report
– Sleep notification
– Power-off notification
• ECC and block management implemented
Note:
1. The JEDEC specification is available at 
www.jedec.org/sites/default/files/docs/
JESD84-B50.pdf.
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
Features
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
1
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.
Products and specifications discussed herein are subject to change by Micron without notice.

<!-- page 2 -->

e·MMC Performance and Current Consumption
Table 1: MLC Partition Sequential Performance
Condition 1
Typical Values (MB/s)
4GB
8GB
HS400
Write
14
22
Read
160
190
HS200
Write
14
22
Read
150
170
DDR 52
Write
14
20
Read
90
90
Note:
1. Bus in x8 I/O mode. Sequential access of 1MB chunk. Additional performance data, such as system perform-
ance on a specific application board, will be provided in a separate document upon customer request.
Table 2: MLC Partition Random Performance
Condition 1
Typical Values (IOPS)
4GB
8GB
Burst
Sustained
Burst
Sustained
HS400
Write (Cache On)
2000 - 3500
500 - 2800
3500 - 5000
500 - 3500
Write (Cache Off)
1000 - 1300
400 - 1100
1000 - 1300
400 - 1100
Read
n/a
3000 - 6000
n/a
3800 - 6500
HS200
Write (Cache On)
2000 - 3500
500 - 2800
3000 - 4800
500 - 3500
Write (Cache Off)
1000 - 1300
400 - 1100
1000 - 1300
400 - 1100
Read
n/a
3000 - 6000
n/a
3500 - 6000
DDR 52
Write (Cache On)
2000 - 3000
500 - 2800
3000 - 4500
500 - 3500
Write (Cache Off)
1000 - 1300
400 - 1100
1000 - 1300
400 - 1100
Read
n/a
2500 - 5000
n/a
3000 - 5000
Note:
1. Bus in x8 I/O mode. Random access of 4KB chunk over various spans (1GB to full card). Additional perform-
ance data, such as system performance on a specific application board, will be provided in a separate docu-
ment upon customer request.
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
Features
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
2
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 3 -->

Table 3: Current Consumption
Condition 1
Typical Values (ICC/ICCQ)
Unit
4GB
8GB
HS400
Write
40/70
40/70
mA
Read
50/100
50/100
mA
HS200
Write
40/70
40/70
mA
Read
50/100
50/100
mA
DDR 52
Write
30/60
30/60
mA
Read
20/70
20/70
mA
Idle/Standby
Sleep
0/200
0/200
uA
Auto-Standby
35/230
35/230
uA
Note:
1. Bus in x8 I/O mode. VCC = 3.6V and VCCQ = 1.95V. 25°C. Measurements done as average RMS current con-
sumption. ICCQ in READ operation measurements with tester load disconnected.
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
Features
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
3
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 4 -->

Part Numbering Information
Micron® e·MMC memory devices are available in different configurations and densities.
Figure 2: e·MMC Part Numbering
 MT FC 
 
 
 - 
 
 
 
Micron Technology
Product Family
FC = NAND Flash + controller
NAND Density
NAND Component
Controller ID
Production Status
Blank = Production
ES = Engineering sample
Operating Temperature Range
Special Options
Package Codes
xx
xx
xx
xx
xx
xx
All packages are Pb free
xx
Table 4: Ordering Information
Base Part Number
Density
Package
Shipping
MTFC4GACAJCN-1M WT
4GB
153-ball VFBGA
11.5mm x 13.0mm x 1.0mm
Tray
Tape and reel
MTFC8GAKAJCN-1M WT
8GB
153-ball VFBGA
11.5mm x 13.0mm x 1.0mm
Tray
Tape and reel
Device Marking
Due to the size of the package, the Micron-standard part number is not printed on the top of the device. Instead,
an abbreviated device mark consisting of a 5-digit alphanumeric code is used. The abbreviated device marks are
cross-referenced to the Micron part numbers at the FBGA Part Marking Decoder site: www.micron.com/decoder.
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
Features
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
4
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

