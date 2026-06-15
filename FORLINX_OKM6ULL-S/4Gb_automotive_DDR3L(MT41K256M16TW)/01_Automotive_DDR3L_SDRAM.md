# Automotive DDR3L SDRAM

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 1–1

<!-- page 1 -->

Automotive DDR3L SDRAM
MT41K512M8 – 64 Meg x 8 x 8 banks
MT41K256M16 – 32 Meg x 16 x 8 banks
Description
DDR3L SDRAM (1.35V) is a low voltage version of the
DDR3 (1.5V) SDRAM. Refer to DDR3 (1.5V) SDRAM
(Die Rev :E) data sheet specifications when running in
1.5V compatible mode.
Features
• VDD = VDDQ = 1.35V (1.283–1.45V)
• Backward compatible to VDD = VDDQ = 1.5V ±0.075V
– Supports DDR3L devices to be backward com-
patible in 1.5V applications
• Differential bidirectional data strobe
• 8n-bit prefetch architecture
• Differential clock inputs (CK, CK#)
• 8 internal banks
• Nominal and dynamic on-die termination (ODT)
for data, strobe, and mask signals
• Programmable CAS (READ) latency (CL)
• Programmable posted CAS additive latency (AL)
• Programmable CAS (WRITE) latency (CWL)
• Fixed burst length (BL) of 8 and burst chop (BC) of 4
(via the mode register set [MRS])
• Selectable BC4 or BL8 on-the-fly (OTF)
• Self refresh mode
• TC of -40°C to +125°C
– 64ms, 8192-cycle refresh at 0°C to +85°C
– 32ms at +85°C to +95°C
– 16ms at +95°C to +105°C
– 8ms at +105°C to +125°C
• Self refresh temperature (SRT)
• Automatic self refresh (ASR)
• Write leveling
• Multipurpose register
• Output driver calibration
• AEC-Q100
• PPAP submission
• 8D response time
Options
Marking
• Configuration
 
– 512 Meg x 8
512M8
– 256 Meg x 16
256M16
• FBGA package (Pb-free) – x8
 
– 78-ball (8mm x 10.5mm)
DA
• FBGA package (Pb-free) – x16
 
– 96-ball (8mm x 14mm)
TW
• Timing – cycle time
 
– 1.07ns @ CL = 13 (DDR3-1866)
-107
• Product certification
 
– Automotive
A
• Operating temperature
 
– Industrial (–40°C ≤ TC ≤ +95°C)
IT
– Automotive (–40°C ≤ TC ≤ +105°C)
AT
– Ultra-high (–40°C ≤ TC ≤ +125°C)3
UT
• Revision
:P
Note:
1. Not all options listed can be combined to de-
fine an offered product. Use the part catalog
search on http://www.micron.com for availa-
ble offerings.
2. The datasheet does not support ×4 mode
even though ×4 mode description exists in the
following sections.
3. The UT option use based on automotive us-
age model. Please contact Micron sales repre-
sentative if you have questions.
Table 1: Key Timing Parameters
Speed Grade
Data Rate (MT/s)
Target tRCD-tRP-CL
tRCD (ns)
tRP (ns)
CL (ns)
-107
1866
13-13-13
13.91
13.91
13.91
Preliminary‡
4Gb: x8, x16 Automotive DDR3L SDRAM
Description
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
1
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.
‡Products and specifications discussed herein are for evaluation and reference purposes only and are subject to change by
Micron without notice. Products are only warranted by Micron to meet Micron’s production data sheet specifications.

