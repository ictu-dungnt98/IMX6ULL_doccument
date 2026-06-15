# CSD Register

> Nguồn: `emmc_4gb_8gb_ps8225_v50_wt.pdf` — trang 12–13

<!-- page 12 -->

CSD Register
The card-specific data (CSD) register provides information about accessing the device
contents. The CSD register defines the data format, error correction type, maximum da-
ta access time, and data transfer speed, as well as whether the DS register can be used.
The programmable part of the register (entries marked with W or E in the following ta-
ble) can be changed by the PROGRAM_CSD (CMD27) command.
Table 8: CSD Register Field Parameters
Name
Field
Size
(Bits)
Cell
Type1
CSD
Bits
CSD Value
CSD structure
CSD_STRUCTURE
2
R
[127:126]
3h
System specification version
SPEC_VERS
4
R
[125:122]
4h
Reserved2
–
2
–
[121:120]
–
Data read access time 1
TAAC
8
R
[119:112]
2Fh
Data read access time 2 in CLK cy-
cles (NSAC × 100)
NSAC
8
R
[111:104]
01h
Maximum bus clock frequency
TRAN_SPEED
8
R
[103:96]
32h
Card command classes
CCC
12
R
[95:84]
0F5h
Maximum read data block length
READ_BL_LEN
4
R
[83:80]
9h
Partial blocks for reads supported
READ_BL_PARTIAL
1
R
[79]
0h
Write block misalignment
WRITE_BLK_MISALIGN
1
R
[78]
0h
Read block misalignment
READ_BLK_MISALIGN
1
R
[77]
0h
DSR implemented
DSR_IMP
1
R
[76]
1h
Reserved
–
2
–
[75:74]
–
Device size
C_SIZE
12
R
[73:62]
FFFh
Maximum read current at VDD,min
VDD_R_CURR_MIN
3
R
[61:59]
7h
Maximum read current at VDD,max
VDD_R_CURR_MAX
3
R
[58:56]
7h
Maximum write current at VDD,min
VDD_W_CURR_MIN
3
R
[55:53]
7h
Maximum write current at VDD,max
VDD_W_CURR_MAX
3
R
[52:50]
7h
Device size multiplier
C_SIZE_MULT
3
R
[49:47]
7h
Erase group size
ERASE_GRP_SIZE
5
R
[46:42]
1Fh
Erase group size multiplier
ERASE_GRP_MULT
5
R
[41:37]
1Fh
Write protect group size
WP_GRP_SIZE
5
R
[36:32]
1Fh
Write protect group enable
WP_GRP_ENABLE
1
R
[31]
1h
Manufacturer default ECC
DEFAULT_ECC
2
R
[30:29]
0h
Write-speed factor
R2W_FACTOR
3
R
[28:26]
3h
Maximum write data block length
WRITE_BL_LEN
4
R
[25:22]
9h
Partial blocks for writes supported
WRITE_BL_PARTIAL
1
R
[21]
0h
Reserved
–
4
–
[20:17]
–
Content protection application
CONTENT_PROT_APP
1
R
[16]
0h
File-format group
FILE_FORMAT_GRP
1
R/W
[15]
0h
Copy flag (OTP)
COPY
1
R/W
[14]
0h
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
CSD Register
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
12
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 13 -->

Table 8: CSD Register Field Parameters (Continued)
Name
Field
Size
(Bits)
Cell
Type1
CSD
Bits
CSD Value
Permanent write protection
PERM_WRITE_PROTECT
1
R/W
[13]
0h
Temporary write protection
TMP_WRITE_PROTECT
1
R/W/E
[12]
0h
File format
FILE_FORMAT
2
R/W
[11:10]
0h
ECC
ECC
2
R/W/E
[9:8]
0h
CRC
CRC
7
R/W/E
[7:1]
-
Reserved
–
1
–
[0]
–
Notes:
1. R = Read-only;
R/W = One-time programmable and readable;
R/W/E = Multiple writable with value kept after a power cycle, assertion of the RST_n
signal, and any CMD0 reset, and readable
2. Reserved bits should be read as 0.
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
CSD Register
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
13
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

