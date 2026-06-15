# ECSD Register

> Nguồn: `emmc_4gb_8gb_ps8225_v50_wt.pdf` — trang 14–20

<!-- page 14 -->

ECSD Register
The 512-byte extended card-specific data (ECSD) register defines device properties and
selected modes. The most significant 320 bytes are the properties segment. This seg-
ment defines device capabilities and cannot be modified by the host. The lower 192
bytes are the modes segment. The modes segment defines the configuration in which
the device is working. The host can change the properties of modes segments using the
SWITCH command.
Table 9: ECSD Register Field Parameters
Name
Field
Size
(Bytes)
Cell
Type2
ECSD
Bytes
ECSD
Value
Properties Segment
Reserved3
–
6
–
[511:506]
-
Extended security commands error
EXT_SECURITY_ERR
1
R
[505]
00h
Supported command sets
S_CMD_SET
1
R
[504]
01h
HPI features
HPI_FEATURES
1
R
[503]
01h
Background operations support
BKOPS_SUPPORT
1
R
[502]
01h
Max-packed read commands
MAX_PACKED_READS
1
R
[501]
3Fh
Max-packed write commands
MAX_PACKED_WRITES
1
R
[500]
3Fh
Data tag support
DATA_TAG_SUPPORT
1
R
[499]
01h
Tag unit size
TAG_UNIT_SIZE
1
R
[498]
03h
Tag resources size
TAG_RES_SIZE
1
R
[497]
00h
Context management capabilities
CONTEXT_CAPABILITIES
1
R
[496]
05h
Large Unit Size
LARGE_UNIT_SIZE_M1
4G
1
R
[495]
01h
8G
07h
Extended partitions attribute sup-
port
EXT_SUPPORT
1
R
[494]
03h
Supported modes
SUPPORTED_MODES
1
R
[493]
03h
Field firmware update features
FFU_FEATURES
1
R
[492]
00h
Operation code timeout
OPERATION_CODE_TIMEOUT
1
R
[491]
00h
Field firmware update arguments
FFU_ARG
4
R
[490:487]
0000FF
FFh
Reserved
–
181
–
[486:306]
-
Number of firmware sectors cor-
rectly programmed
NUMBER_OF_FW_SECTORS_CORRECT-
LY_PROGRAMMED
4
R
[305:302]
00h
Device health report
VENDOR_PROPRIETARY_HEALTH_RE-
PORT
32
R
[301:270]
00h
Device life time estimation type B
DEVICE_LIFE_TIME_EST_TYP_B
1
R
[269]
01h
Device life time estimation type A
DEVICE_LIFE_TIME_EST_TYP_A
1
R
[268]
01h
Pre-end of life information
PRE_EOL_INFO
1
R
[267]
01h
Optimal READ size
OPTIMAL_READ_SIZE
1
R
[266]
01h
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
ECSD Register
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
14
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 15 -->

Table 9: ECSD Register Field Parameters (Continued)
Name
Field
Size
(Bytes)
Cell
Type2
ECSD
Bytes
ECSD
Value
Optimal WRITE size
OPTIMAL_WRITE_SIZE
4G
1
R
[265]
04h
8G
08h
Optimal trim unit size
OPTIMAL_TRIM_UNIT_SIZE
1
R
[264]
01h
Device version
DEVICE_VERSION
2
R
[263:262]
0000h
Firmware version
FIRMWARE_VERSION
8
R
[261:254]
-
Power class for 200MHz, DDR at
VCC= 3.6V
PWR_CL_DDR_200_360
1
R
[253]
00h
Cache size
CACHE_SIZE
4
R
[252:249]
000002
00h
Generic CMD6 timeout
GENERIC_CMD6_TIME
1
R
[248]
19h
Power-off notification (long) time-
out
POWER_OFF_LONG_TIME
1
R
[247]
FFh
Background operations status
BKOPS_STATUS
1
R
[246]
00h
Number of correctly programmed
sectors
CORRECTLY_PROG_SECTORS_NUM
4
R
[245:242]
00h
First initialization time after parti-
tioning (first CMD1 to device ready)
INI_TIMEOUT_AP
1
R
[241]
64h
Reserved
–
1
–
[240]
-
Power class for 52 MHz, DDR at
3.6V
PWR_CL_DDR_52_360
1
R
[239]
00h
Power class for 52 MHz, DDR at
1.95V
PWR_CL_DDR_52_195
1
R
[238]
00h
Power class for 200 MHz at 1.95V
PWR_CL_200_195
1
R
[237]
00h
Power class for 200 MHz, at 1.3V
PWR_CL_200_130
1
R
[236]
00h
Minimum write performance for
8bit at 52MHz in DDR mode
MIN_PERF_DDR_W_8_52
4G
1
R
[235]
0Bh
8G
13h
Minimum read performance for 8-
bit at 52 MHz in DDR mode
MIN_PERF_DDR_R_8_52
1
R
[234]
00h
Reserved
–
1
–
[233]
-
Trim multiplier
TRIM_MULT
1
R
[232]
11h
Secure feature support
SEC_FEATURE_SUPPORT
1
R
[231]
55h
Secure erase multiplier
SEC_ERASE_MULT
4G
1
R
[230]
18h
8G
3Ah
Secure trim multiplier
SEC_TRIM_MULT
4G
1
R
[229]
18h
8G
3Ah
Boot information
BOOT_INFO
1
R
[228]
07h
Reserved
–
1
–
[227]
-
Boot partition size
BOOT_SIZE_MULT
1
R
[226]
10h
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
ECSD Register
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
15
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 16 -->

Table 9: ECSD Register Field Parameters (Continued)
Name
Field
Size
(Bytes)
Cell
Type2
ECSD
Bytes
ECSD
Value
Access size
ACC_SIZE
4G
1
R
[225]
06h
8G
07h
High-capacity erase unit size
HC_ERASE_GRP_SIZE
1
R
[224]
01h
High-capacity erase timeout
ERASE_TIMEOUT_MULT
1
R
[223]
11h
Reliable write-sector count
REL_WR_SEC_C
1
R
[222]
01h
High-capacity write protect group
size
HC_WP_GRP_SIZE
1
R
[221]
10h
Sleep current (VCC)
S_C_VCC
1
R
[220]
08h
Sleep current (VCCQ)
S_C_VCCQ
1
R
[219]
08h
Production state awareness time-
out
PRODUCTION_STATE_AWARE-
NESS_TIMEOUT
1
R
[218]
14h
Sleep/awake timeout
S_A_TIMEOUT
1
R
[217]
13h
Sleep notification time
SLEEP_NOTIFICATION_TIME
1
R
[216]
0Fh
Sector Count
SEC_COUNT
4G
4
R
[215:212]
007480
00h
8G
00E400
00h
Reserved
–
1
–
[211]
-
Minimum write performance for
8bit at 52MHz
MIN_PERF_W_8_52
4G
1
R
[210]
0Bh
8G
13h
Minimum read performance for 8-
bit at 52 MHz
MIN_PERF_R_8_52
1
R
[209]
08h
Minimum write performance for
8bit at 26MHz, for 4bit at 52MHz
MIN_PERF_W_8_26_4_52
4G
1
R
[208]
0Ch
8G
14h
Minimum read performance for 8-
bit at 26 MHz and 4-bit at 52 MHz
MIN_PERF_R_8_26_4_52
1
R
[207]
08h
Minimum write performance for
4bit at 26MHz
MIN_PERF_W_4_26
4G
1
R
[206]
0Bh
8G
13h
Minimum read performance for 4-
bit at 26 MHz
MIN_PERF_R_4_26
1
R
[205]
08h
Reserved
–
1
–
[204]
-
Power class for 26 MHz at 3.6V
PWR_CL_26_360
1
R
[203]
00h
Power class for 52 MHz at 3.6V
PWR_CL_52_360
1
R
[202]
00h
Power class for 26 MHz at 1.95V
PWR_CL_26_195
1
R
[201]
00h
Power class for 52 MHz at 1.95V
PWR_CL_52_195
1
R
[200]
00h
Partition switching timing
PARTITION_SWITCH_TIME
1
R
[199]
03h
Out-of-interrupt busy timing
OUT_OF_INTERRUPT_TIME
1
R
[198]
0Ah
I/O driver strength
DRIVER_STRENGTH
1
R
[197]
1Fh
Device type
DEVICE_TYPE
1
R
[196]
57h
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
ECSD Register
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
16
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 17 -->

Table 9: ECSD Register Field Parameters (Continued)
Name
Field
Size
(Bytes)
Cell
Type2
ECSD
Bytes
ECSD
Value
Reserved
–
1
–
[195]
-
CSD structure version
CSD_STRUCTURE
1
R
[194]
02h
Reserved
–
1
–
[193]
-
Extended CSD revision
EXT_CSD_REV
1
R
[192]
07h
Modes Segment
Command set
CMD_SET
1
R/W/E_P
[191]
00h
Reserved
–
1
–
[190]
-
Command set revision
CMD_SET_REV
1
R
[189]
00h
Reserved
–
1
–
[188]
-
Power class
POWER_CLASS
1
R/W/E_P
[187]
00h
Reserved
–
1
–
[186]
-
High-speed interface timing
HS_TIMING
1
R/W/E_P
[185]
00h
Reserved
–
1
–
[184]
-
Bus width mode
BUS_WIDTH
1
W/E_P
[183]
00h
Reserved
–
1
–
[182]
-
Erased memory content
ERASED_MEM_CONT
1
R
[181]
00h
Reserved
–
1
–
[180]
-
Partition configuration
PARTITION_CONFIG
1
R/W/E,
R/W/E_P
[179]
00h
Boot configuration protection
BOOT_CONFIG_PROT
1
R/W,
R/W/C_P
[178]
00h
Boot bus width
BOOT_BUS_WIDTH
1
R/W/E
[177]
00h
Reserved
–
1
–
[176]
-
High-density erase group definition ERASE_GROUP_DEF
1
R/W/E_P
[175]
00h
Boot write protection status regis-
ters
BOOT_WP_STATUS
1
R
[174]
00h
Boot area write protection register
BOOT_WP
1
R/W,
R/W/C_P
[173]
00h
Reserved
–
1
–
[172]
-
User write protection register
USER_WP
1
R/W,
R/W/C_P,
R/W/E_P
[171]
00h
Reserved
–
1
–
[170]
-
Firmware configuration
FW_CONFIG
1
R/W
[169]
00h
RPMB Size
RPMB_SIZE_MULT
4G
1
R
[168]
04h
8G
20h
Write reliability setting register4
WR_REL_SET
1
R/W
[167]
1Fh
Write reliability parameter register
WR_REL_PARAM
1
R
[166]
15h
SANITIZE START operation
SANITIZE_START
1
W/E_P
[165]
00h
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
ECSD Register
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
17
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 18 -->

Table 9: ECSD Register Field Parameters (Continued)
Name
Field
Size
(Bytes)
Cell
Type2
ECSD
Bytes
ECSD
Value
Manually start background opera-
tions
BKOPS_START
1
W/E_P
[164]
00h
Enable background operations
handshake
BKOPS_EN
1
R/W
[163]
00h
Hardware reset function
RST_n_FUNCTION
1
R/W
[162]
00h
HPI management
HPI_MGMT
1
R/W/E_P
[161]
00h
Partitioning support
PARTITIONING_SUPPORT
1
R
[160]
07h
Max enhanced area size
MAX_ENH_SIZE_MULT
4G
3
R
[159:157]
0000E9
h
8G
0001C8
h
Partitions attribute
PARTITIONS_ATTRIBUTE
1
R/W
[156]
00h
Partitioning setting
PARTITION_SETTING_COMPLETED
1
R/W
[155]
00h
General-purpose partition size
GP_SIZE_MULT_GP3
12
R/W
[154:152]
00h
GP_SIZE_MULT_GP2
[151:149]
00h
GP_SIZE_MULT_GP1
[148:146]
00h
GP_SIZE_MULT_GP0
[145:143]
00h
Enhanced user data area size
ENH_SIZE_MULT
3
R/W
[142:140]
00h
Enhanced user data start address
ENH_START_ADDR
4
R/W
[139:136]
00h
Reserved
–
1
–
[135]
-
Bad block management mode
SEC_BAD_BLK_MGMNT
1
R/W
[134]
00h
Production state awareness
PRODUCTION_STATE_AWARENESS
1
R/W/E
[133]
00h
Package case temperature is con-
trolled
TCASE_SUPPORT
1
W/E_P
[132]
00h
Periodic wake-up
PERIODIC_WAKEUP
1
R/W/E
[131]
00h
Program CID/CSD in DDR mode sup-
port
PROGRAM_CID_CSD_DDR_SUPPORT
1
R
[130]
01h
Reserved
–
2
-
[129:128]
-
Vendor specific fields
VENDOR_SPECIFIC_FIELD
64
<vendor
specific>
[127:64]
-
Native sector size
NATIVE_SECTOR_SIZE
1
R
[63]
00h
Sector size emulation
USE_NATIVE_SECTOR
1
R/W
[62]
00h
Sector size
DATA_SECTOR_SIZE
1
R
[61]
00h
1st initialization after disabling sec-
tor size emulation
INI_TIMEOUT_EMU
1
R
[60]
00h
Class 6 commands control
CLASS_6_CTRL
1
R/W/E_P
[59]
00h
Number of addressed group to be
released
DYNCAP_NEEDED
1
R
[58]
00h
Exception events control
EXCEPTION_EVENTS_CTRL
2
R/W/E_P
[57:56]
00h
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
ECSD Register
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
18
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 19 -->

Table 9: ECSD Register Field Parameters (Continued)
Name
Field
Size
(Bytes)
Cell
Type2
ECSD
Bytes
ECSD
Value
Exception events status
EXCEPTION_EVENTS_STATUS
2
R
[55:54]
00h
Extended partitions attribute
EXT_PARTITIONS_ATTRIBUTE
2
R/W
[53:52]
00h
Context configuration
CONTEXT_CONF ID#14
15
R/W/E_P
[51]
00h
CONTEXT_CONF ID#13
[50]
00h
CONTEXT_CONF ID#12
[49]
00h
CONTEXT_CONF ID#11
[48]
00h
CONTEXT_CONF ID#10
[47]
00h
CONTEXT_CONF ID#9
[46]
00h
CONTEXT_CONF ID#8
[45]
00h
CONTEXT_CONF ID#7
[44]
00h
CONTEXT_CONF ID#6
[43]
00h
CONTEXT_CONF ID#5
[42]
00h
CONTEXT_CONF ID#4
[41]
00h
CONTEXT_CONF ID#3
[40]
00h
CONTEXT_CONF ID#2
[39]
00h
CONTEXT_CONF ID#1
[38]
00h
CONTEXT_CONF ID#0
[37]
00h
Packed command status
PACKED_COMMAND_STATUS
1
R
[36]
00h
Packed command failure index
PACKED_FAILURE_INDEX
1
R
[35]
00h
Power-off notification
POWER_OFF_NOTIFICATION
1
R/W/E_P
[34]
00h
Control to turn the Cache ON/OFF
CACHE_CTRL
1
R/W/E_P
[33]
00h
Flushing of the cache
FLUSH_CACHE
1
W/E_P
[32]
00h
Reserved
–
1
–
[31]
-
Mode configuration
MODE_CONFIG
1
R/W/E_P
[30]
00h
Mode operation codes
MODE_OPERATION_CODES
1
W/E_P
[29]
00h
Reserved
–
2
–
[28:27]
-
Field firmware update status
FFU_STATUS
1
R
[26]
00h
Pre-loading data size
PRE_LOADING_DATA_SIZE
4
R/W/E_P
[25:22]
00h
Max pre-loading data size
MAX_PRE_LOADING_DA-
TA_SIZE
4G
4
R
[21:18]
0039C0
00h
8G
007000
00h
Product state awareness enable-
ment
PRODUCT_STATE_AWARENESS_ENABLE-
MENT
1
R/W/E & R
[17]
01h
Secure removal type
SECURE_REMOVAL_TYPE
1
R/W/E & R
[16]
01h
Reserved
–
16
–
[15:0]
-
Notes:
1. Some of the register values in this table are not valid. They will be updated in the future
with the correct values.
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
ECSD Register
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
19
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 20 -->

2. R = Read-only;
R/W = One-time programmable and readable;
R/W/E = Multiple writable with the value kept after a power cycle, assertion of the
RST_n signal, and any CMD0 reset, and readable;
R/W/C_P = Writable after the value is cleared by a power cycle and assertion of the
RST_n signal (the value not cleared by CMD0 reset) and readable;
R/W/E_P = Multiple writable with the value reset after a power cycle, assertion of the
RST_n signal, and any CMD0 reset, and readable;
W/E_P = Multiple writable with the value reset after power cycle, assertion of the RST_n
signal, and any CMD0 reset, and not readable
3. Reserved bits should be read as 0.
4. Micron has tested power failure under best-application knowledge conditions with posi-
tive results. Customers may request a dedicated test for their specific application condi-
tion. Micron set this register during factory test and used the one-time programming
option.
Micron Confidential and Proprietary
4GB, 8GB: e·MMC
ECSD Register
PDF: 09005aef86582cce
emmc_4_8GB_ps8225_v50_wt.pdf – Rev. D 2/16 EN
20
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

