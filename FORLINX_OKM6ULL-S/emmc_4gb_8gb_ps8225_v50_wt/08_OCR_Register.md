# OCR Register

> Nguồn: `emmc_4gb_8gb_ps8225_v50_wt.pdf` — trang 10–10

<!-- page 10 -->

OCR Register
The 32-bit operation conditions register (OCR) stores the voltage profile of the card and
the access mode indication. In addition, this register includes a status information bit.
Table 6: OCR Parameters
OCR Bits
OCR Value
Description
[31]
1b (ready)/0b (busy)1
Device power-on status bit
[30:29]
10b
Sector mode
[28:24]
0 0000b
Reserved
[23:15]
1 1111 1111b
2.7–3.6V voltage range
[14:8]
000 0000b
2.0–2.7V voltage range
[7]
1b
1.70–1.95V voltage range
[6:0]
000 0000b
Reserved
Note:
1. OCR = C0FF8080h after the device has completed power-up.
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
OCR Register
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
10
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

