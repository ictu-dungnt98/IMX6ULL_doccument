# CID Register

> Nguồn: `emmc_4gb_8gb_ps8225_v50_wt.pdf` — trang 11–11

<!-- page 11 -->

CID Register
The card identification (CID) register is 128 bits wide. It contains the device identifica-
tion information used during the card identification phase as required by e.MMC proto-
col. Each device is created with a unique identification number.
Table 7: CID Register Field Parameters
Name
Field
Width
CID Bits
CID Value
Manufacturer ID
MID
8
[127:120]
13h
Reserved
–
6
[119:114]
–
Card/BGA
CBX
2
[113:112]
01h
OEM/application ID
OID
8
[111:104]
-
Product name
PNM
48
[103:56]
-
Product revision
PRV
8
[55:48]
-
Product serial number
PSN
32
[47:16]
–
Manufacturing date
MDT
8
[15:8]
–
CRC7 checksum
CRC
7
[7:1]
–
Not used; always 1
–
1
[0]
–
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
CID Register
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
11
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

