# Chapter 5:  Fusemap

> Nguồn: `IMX6ULLRM.pdf` — trang 215–234

<!-- page 215 -->

Chapter 5
Fusemap
5.1
Boot Fusemap
The following section details the various modes and selection of the required boot
devices.
A separate map is given for each and every boot device. The device select is specified by
BOOT_CFG1[6:4] fuses listed in Table 5-1.
Table 5-1. Boot Device Select
Boot
Device
BOOT_CF
G1[7]
BOOT_CF
G1[6]
BOOT_CF
G1[5]
BOOT_CF
G1[4]
BOOT_CF
G1[3]
BOOT_CF
G1[2]
BOOT_CF
G1[1]
BOOT_CF
G1[0]
QSPI
0
0
0
1
0 - QSPI0
DDRSMP:
000 -
Default
001 - 111
DDRSMP:
000 -
Default
001 - 111
DDRSMP:
000 -
Default
001 - 111
WEIM
0
0
0
0
Memory
Type:
0 - NOR
Flash
1 -
OneNAND
Reserved
Reserved
Reserved
Serial-ROM
0
0
1
1
Reserved
Reserved
Reserved
Reserved
SD/eSD
0
1
0
Fast boot:
0 - Regular
1 - Fast boot
SD/SDXC
speed:
00 - Normal/
SDR12
01 - High/
SDR25
10 - SDR50
11 -
SDR104
SD/SDXC
speed:
00 - Normal/
SDR12
01 - High/
SDR25
10 - SDR50
11 -
SDR104
SD power
cycle
enable:
0 - No
power cycle
1 - Enabled
via
USDHC_RS
T pad
(uSDHC3
and 4 only)
SD loopback
clock source
sel ( for
SDR50 and
SDR104
only):
0 - Through
SD pad
1 - Direct
Table continues on the next page...
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
215

<!-- page 216 -->

Table 5-1. Boot Device Select (continued)
Boot
Device
BOOT_CF
G1[7]
BOOT_CF
G1[6]
BOOT_CF
G1[5]
BOOT_CF
G1[4]
BOOT_CF
G1[3]
BOOT_CF
G1[2]
BOOT_CF
G1[1]
BOOT_CF
G1[0]
MMC/eMMC
0
1
1
Fast boot:
0 - Regular
1 - Fast boot
SD/MMC
speed:
0 - Normal
1 - High
Fast boot
acknowledg
e disable:
0 - Boot ack
enabled
1 - Boot ack
disabled
SD power
cycle
enable:
0 - No
power cycle
1 - Enabled
via
USDHC_RS
T pad
(uSDHC3
and 4 only)
SD loopback
clock source
sel ( for
SDR50 and
SDR104
only):
0 - Through
SD pad
1 - Direct
NAND
1
BT_TOGGL
EMODE
Pages in
block:
00 - 128
01 - 64
10 - 32
11 - 256
Pages in
block:
00 - 128
01 - 64
10 - 32
11 - 256
Nand
number of
devices:
00 - 1
01 - 2
10 - 4
11 -
Reserved
Nand
number of
devices:
00 - 1
01 - 2
10 - 4
11 -
Reserved
Nand_Row_
address_byt
es:
00 - 3
01 - 2
10 - 4
11 - 5
Nand_Row_
address_byt
es:
00 - 3
01 - 2
10 - 4
11 - 5
NOTE
Fuses marked as “Reserved” are reserved for NXP internal (and
future) use only. Customers should not attempt to burn these, as
the IC behavior may be unpredictable. The reserved fuses can
be read as either '0' or '1'.
Table 5-2. QSPI Boot Fusemap
Addr
7
6
5
4
3
2
1
0
0x450[7:0]
(BOOT_CFG1)
0
0
0
1
x
DDRSMP:
000 - Default
0x450[15:8]
(BOOT_CFG2)
Reserved
HSPHS:
Half Speed
Phase
Selection
0 - select
sampling at
non-
inverted
clock
1 - select
sampling at
inverted
clock
HSDLY:
Half Speed
Delay
selection
0 - one
clock delay
1 - two
clock delay
FSPHS: Full
Speed
Phase
Selection
0 - select
sampling at
non-
inverted
clock
1 - select
sampling at
inverted
clock
FSDLY: Full
Speed
Delay
selection
0 - one
clock delay
1 - two
clock delay
Boot
Frequencies
(ARM/DDR)
0 - 500 /
400 MHz
1 - 250 /
200 MHz
Reserved
Reserved
Table continues on the next page...
Boot Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
216
NXP Semiconductors

<!-- page 217 -->

Table 5-2. QSPI Boot Fusemap (continued)
Addr
7
6
5
4
3
2
1
0
0x450[23:16]
(BOOT_CFG3)
Reserved
0x460[7:0]
Reserved
FORCE_C
OLD_BOOT
BT_FUSE_
SEL
DIR_BT_DI
S
Reserved
SEC_CONF
IG[1]
Reserved
0x460[15:8]
Reserved
0x460[23:16]
JTAG_SMODE[1:0]
WDOG_EN
ABLE
0 - Disabled
1 - Enabled
SJC_DISAB
LE
Reserved
0x460[31:24]
Reserved
TZASC_EN
ABLE
JTAG_HEO
KTE
Reserved
DLL_ENAB
LE
0 - Disable
DLL for SD/
eMMC
1 - Enable
DLL for SD/
eMMC
0x470[7:0]
Not used
Reserved
L1 I-Cache
DISABLE
BT_MMU_D
ISABLE
Reserved
0x470[15:8]
Reserved
Not used
Reserved
ADD_DS__
SET_GPR1
_16
0 - Set
1 - Don't set
Reserved
0x470[23:16]
Reserved
LPB_BOOT (Core / DDR-
Bus)
00 - LPB Disable
01 - 1 GPIO (def freq)
10 - Div by2
11 - Div by 4
BT_LPB_P
OLARITY
(GPIO
polarity)
0 - Active
High
1 -Active
Low
Reserved
Table 5-3. EIM Boot Fusemap
Addr
7
6
5
4
3
2
1
0
0x450[7:0]
(BOOT_CFG1)
0
0
0
0
Memory
Type:
0 - NOR
Flash
1 -
OneNAND
Reserved
Reserved
Reserved
Table continues on the next page...
Chapter 5 Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
217

<!-- page 218 -->

Table 5-3. EIM Boot Fusemap (continued)
Addr
7
6
5
4
3
2
1
0
0x450[15:8]
(BOOT_CFG2)
Muxing Scheme:
00 - A/D16 (HW Default
in external boot)
01 - A+DH
10 - A+DL
11 - Reserved
OneNand Page Size:
00 - 1KB
01 - 2KB
10 - 4KB
11 - Reserved
Reserved
Boot
Frequencies
(ARM/DDR)
0 - 500 /
400 MHz
1 - 250 /
200 MHz
Reserved
Reserved
0x450[23:16]
(BOOT_CFG3)
Reserved
0x450[31:24]
(BOOT_CFG4)
Reserved
EEPROM
Recovery
Enable
0 - Disabled
1 - Enabled
Fuse is
Reserved
for 'Serial-
ROM' Boot
mode
eCSPI chip select:
00 - ECSPIx_SS0
(default)
01 - ECSPIx_SS1
10 - ECSPIx_SS2
11 - ECSPIx_SS3
eCSPI
Addressing:
0 - 2-bytes
(16-bit)
1 - 3-bytes
(24-bit)
Port Select:
000 - eCSPI1
001 - eCSPI2
010 - eCSPI3
011 - eCSPI4
100 - Reserved
101 - Reserved
110 - Reserved
111 - Reserved
0x460[7:0]
Reserved
FORCE_C
OLD_BOOT
BT_FUSE_
SEL
DIR_BT_DI
S
Reserved
SEC_CONF
IG[1]
Reserved
0x460[15:8]
Reserved
0x460[23:16]
JTAG_SMODE[1:0]
WDOG_EN
ABLE
0 - Disabled
1 - Enabled
SJC_DISAB
LE
Reserved
0x460[31:24]
Reserved
TZASC_EN
ABLE
JTAG_HEO
KTE
Reserved
DLL_ENAB
LE
0 - Disable
DLL for SD/
eMMC
1 - Enable
DLL for SD/
eMMC
0x470[7:0]
DLL
Override:
0 - DLL
Slave Mode
for SD/
eMMC
1 - DLL
Override
Mode for
SD/eMMC
SD1_RST_
POLARITY_
SELECT
0 - Reset
active low
1 - Reset
active high
SD2
VOLTAGE
SELECTIO
N
0 - 3.3V
1 - 1.8V
Reserved
Disable
SDMMC
Manufactur
e mode
0 - Enable
1 - Disable
L1 I-Cache
DISABLE
BT_MMU_D
ISABLE
Override SD
Pad
Settings
(using
PAD_SETTI
NGS value)
Table continues on the next page...
Boot Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
218
NXP Semiconductors

<!-- page 219 -->

Table 5-3. EIM Boot Fusemap (continued)
Addr
7
6
5
4
3
2
1
0
0x470[15:8]
SD2_RST_
POLARITY_
SELECT
0 - Reset
acitve low
1 - Reset
active high
eMMC 4.4 -
RESET TO
PRE-IDLE
STATE
Override
HYS bit for
SD/MMC
pads
USDHC_PA
D_PULL_D
OWN
0 - no
action
1 - pull
down
ENABLE_E
MMC_22K_
PULLUP
0 - 47K
pullup
1 - 22K
pullup
ADD_DS__
SET_GPR1
_16
0 - Set
1 - Do not
set
USDHC_IO
MUX_SION
_BIT_ENAB
LE
0 - Disable
1 - Enable
USDHC
IOMUX
SRE Enable
0 - Disable
1 - Enable
0x470[23:16]
Reserved
LPB_BOOT (Core / DDR-
Bus)
00 - LPB Disable
01 - 1 GPIO (def freq)
10 - Div by2
11 - Div by 4
BT_LPB_P
OLARITY
(GPIO
polarity)
0 - Active
High
1 -Active
Low
Reserved
0x470[31:24]
Override
NAND Pad
Settings
(Use
PAD_SETTI
NGS value)
MMC_DLL_DLY[6:0]
0x6D0[7:0]
RANDOMIZ
ER_ENABL
E
Reserved
PAD_SETTINGS[5:0]
Table 5-4. Serial-ROM Boot Fusemap
Addr
7
6
5
4
3
2
1
0
0x450[7:0]
(BOOT_CFG1)
0
0
1
1
Reserved
Reserved
Reserved
Reserved
0x450[15:8]
(BOOT_CFG2)
Reserved
Reserved
Reserved
Reserved
Reserved
Boot
Frequencies
(ARM/DDR)
0 - 500 /
400 MHz
1 - 250 /
200 MHz
Reserved
Reserved
0x450[23:16]
(BOOT_CFG3)
Reserved
0x450[31:24]
(BOOT_CFG4)
Reserved
EEPROM
Recovery
Enable
0 - Disabled
eCSPI chip select:
00 - ECSPIx_SS0
(default)
01 - ECSPIx_SS1
10 - ECSPIx_SS2
eCSPI
Addressing:
0 - 2-bytes
(16-bit)
1 - 3-bytes
(24-bit)
Port Select:
000 - eCSPI1
001 - eCSPI2
010 - eCSPI3
011 - eCSPI4
Table continues on the next page...
Chapter 5 Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
219

<!-- page 220 -->

Table 5-4. Serial-ROM Boot Fusemap (continued)
Addr
7
6
5
4
3
2
1
0
1 - Enabled
Fuse is
Reserved
for 'Serial-
ROM' Boot
mode
11 - ECSPIx_SS3
100 - Reserved
101 - Reserved
110 - Reserved
111 - Reserved
0x460[7:0]
Reserved
FORCE_C
OLD_BOOT
BT_FUSE_
SEL
DIR_BT_DI
S
Reserved
SEC_CONF
IG[1]
Reserved
0x460[15:8]
Reserved
0x460[23:16]
JTAG_SMODE[1:0]
WDOG_EN
ABLE
0 - Disabled
1 - Enabled
SJC_DISAB
LE
Reserved
0x460[31:24]
Reserved
TZASC_EN
ABLE
JTAG_HEO
KTE
Reserved
DLL_ENAB
LE
0 - Disable
DLL for SD/
eMMC
1 - Enable
DLL for SD/
eMMC
0x470[7:0]
DLL
Override:
0 - DLL
Slave Mode
for SD/
eMMC
1 - DLL
Override
Mode for
SD/eMMC
SD1_RST_
POLARITY_
SELECT
0 - Reset
active low
1 - Reset
active high
SD2
VOLTAGE
SELECTIO
N
0 - 3.3V
1 - 1.8V
Reserved
Disable
SDMMC
Manufactur
e mode
0 - Enable
1 - Disable
L1 I-Cache
DISABLE
BT_MMU_D
ISABLE
Override SD
Pad
Settings
(using
PAD_SETTI
NGS value)
0x470[15:8]
SD2_RST_
POLARITY_
SELECT
0 - Reset
acitve low
1 - Reset
active high
eMMC 4.4 -
RESET TO
PRE-IDLE
STATE
Override
HYS bit for
SD/MMC
pads
USDHC_PA
D_PULL_D
OWN
0 - no
action
1 - pull
down
ENABLE_E
MMC_22K_
PULLUP
0 - 47K
pullup
1 - 22K
pullup
ADD_DS__
SET_GPR1
_16
0 - Set
1 - Do not
set
USDHC_IO
MUX_SION
_BIT_ENAB
LE
0 - Disable
1 - Enable
USDHC
IOMUX
SRE Enable
0 - Disable
1 - Enable
0x470[23:16]
Reserved
LPB_BOOT (Core / DDR-
Bus)
00 - LPB Disable
01 - 1 GPIO (def freq)
10 - Div by2
11 - Div by 4
BT_LPB_P
OLARITY
(GPIO
polarity)
0 - Active
High
1 -Active
Low
Reserved
Table continues on the next page...
Boot Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
220
NXP Semiconductors

<!-- page 221 -->

Table 5-4. Serial-ROM Boot Fusemap (continued)
Addr
7
6
5
4
3
2
1
0
0x470[31:24]
Override
NAND Pad
Settings
(Use
PAD_SETTI
NGS value)
MMC_DLL_DLY[6:0]
0x6D0[7:0]
RANDOMIZ
ER_ENABL
E
Reserved
PAD_SETTINGS[5:0]
Table 5-5. SD/eSD Boot Fusemap
Addr
7
6
5
4
3
2
1
0
0x450[7:0]
(BOOT_CFG1)
0
1
0
Fast Boot:
0 - Regular
1 - Fast
Boot
SD/SDXC Speed
00 - Normal/SDR12
01 - High/SDR25
10 - SDR50
11 - SDR104
SD Power
Cycle
Enable
0 - No
power cycle
1 - Enabled
via
USDHC_RS
T pad
SD
Loopback
Clock
Source Sel
(for SDR50
and
SDR104
only)
0 - through
SD pad
1 - direct
0x450[15:8]
(BOOT_CFG2)
SD Calibration Step
00 - 1 delay cell
Bus Width:
0 - 1-bit
1 - 4-bit
Port Select:
00 - eSDHC1
01 - eSDHC2
10 - Reserved
11 - Reserved
Boot
Frequencies
(ARM/DDR)
0 - 500 /
400 MHz
1 - 250 /
200 MHz
SD
VOLTAGE
SELECTIO
N
0 - 3.3V
1 - 1.8V
Reserved
0x450[23:16]
(BOOT_CFG3)
Reserved
0x450[31:24]
(BOOT_CFG4)
Reserved
EEPROM
Recovery
Enable
0 - Disabled
1 - Enabled
Fuse is
Reserved
for 'Serial-
ROM' Boot
mode
eCSPI chip select:
00 - ECSPIx_SS0
(default)
01 - ECSPIx_SS1
10 - ECSPIx_SS2
11 - ECSPIx_SS3
eCSPI
Addressing:
0 - 2-bytes
(16-bit)
1 - 3-bytes
(24-bit)
Port Select:
000 - eCSPI1
001 - eCSPI2
010 - eCSPI3
011 - eCSPI4
100 - Reserved
101 - Reserved
110 - Reserved
111 - Reserved
0x460[7:0]
Reserved
FORCE_C
OLD_BOOT
BT_FUSE_
SEL
DIR_BT_DI
S
Reserved
SEC_CONF
IG[1]
Reserved
Table continues on the next page...
Chapter 5 Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
221

<!-- page 222 -->

Table 5-5. SD/eSD Boot Fusemap (continued)
Addr
7
6
5
4
3
2
1
0
0x460[15:8]
Reserved
0x460[23:16]
JTAG_SMODE[1:0]
WDOG_EN
ABLE
0 - Disabled
1 - Enabled
SJC_DISAB
LE
Reserved
0x460[31:24]
Reserved
TZASC_EN
ABLE
JTAG_HEO
KTE
Reserved
DLL
Enable:
0 - Disable
DLL for SD/
eMMC
1 - Enable
DLL for SD/
eMMC
0x470[7:0]
DLL
Override:
0 - DLL
Slave Mode
for SD/
eMMC
1 - DLL
Override
Mode for
SD/eMMC
SD1
RST_POLA
RITY_SELE
CT
0 - Reset
active-low
1 - Reset
active-high
SD2
VOLTAGE
SELECTIO
N
0 - 3.3V
1 - 1.8V
Reserved
Disable
SDMMC
Manufactur
e mode
0 - Enable
1 - Disable
L1 I-Cache
DISABLE
BT_MMU_D
ISABLE
Override SD
Pad
Settings
(using
PAD_SETTI
NGS value)
0x470[15:8]
SD2 Reset
Signal
Polarity:
0 - Reset
active-low
1 - Reset
active-high
eMMC 4.4 -
RESET TO
PRE-IDLE
STATE
Override
HYS bit for
SD/MMC
pads
USDHC_PA
D_PULL_D
OWN
0 - no
action
1 - pull
down
ENABLE_E
MMC_22K_
PULLUP
0 - 47K
pullup
1 - 22K
pullup
ADD_DS__
SET_GPR1
_16
0 - Set
1 - Don't set
USDHC_IO
MUX_SION
_BIT_ENAB
LE
0 - Disable
1 - Enable
USDHC
IOMUX
SRE Enable
0 - Disable
1 - Enable
0x470[23:16]
Reserved
LPB_BOOT (Core / DDR-
Bus)
00 - LPB Disable
01 - 1 GPIO (def freq)
10 - Div by2
11 - Div by 4
BT_LPB_P
OLARITY
(GPIO
polarity)
0 - Active
High
1 -Active
Low
Reserved
0x470[31:24]
Override
NAND Pad
Settings
(Use
PAD_SETTI
NGS value)
MMC_DLL_DLY[6:0]
Table continues on the next page...
Boot Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
222
NXP Semiconductors

<!-- page 223 -->

Table 5-5. SD/eSD Boot Fusemap (continued)
Addr
7
6
5
4
3
2
1
0
0x6D0[7:0]
RANDOMIZ
ER_ENABL
E
Reserved
PAD_SETTINGS[5:0]
Table 5-6. MMC/eMMC Boot Fusemap
Addr
7
6
5
4
3
2
1
0
0x450[7:0]
(BOOT_CFG1)
0
1
1
Fast Boot:
0 - Regular
1 - Fast
Boot
SD/MMC
Speed
0 - High
1- Normal
Fast Boot
Acknowledg
e Disable:
0 - Boot Ack
Enabled
1 - Boot Ack
Disabled
SD Power
Cycle
Enable
0 - No
power cycle
1 - Enabled
via
USDHC_RS
T pad
SD
Loopback
Clock
Source Sel
(for SDR50
and
SDR104
only)
0 - through
SD pad
1 - direct
0x450[15:8]
(BOOT_CFG2)
Bus Width:
000 - 1-bit
001 - 4-bit
010 - 8-bit
101 - 4-bit
DDR (MMC 4.4)
110 - 8-bit
DDR (MMC 4.4)
Else - Reserved
Port Select:
00 - eSDHC1
01 - eSDHC2
10 - Reserved
11 - Reserved
Boot
Frequencies
(ARM/DDR)
0 - 500 /
400 MHz
1 - 250 /
200 MHz
SD
VOLTAGE
SELECTIO
N
0 - 3.3V
1 - 1.8V
Reserved
0x450[23:16]
(BOOT_CFG3)
Reserved
0x450[31:24]
(BOOT_CFG4)
Reserved
EEPROM
Recovery
Enable
0 - Disabled
1 - Enabled
Fuse is
Reserved
for 'Serial-
ROM' Boot
mode
eCSPI chip select:
00 - ECSPIx_SS0
(default)
01 - ECSPIx_SS1
10 - ECSPIx_SS2
11 - ECSPIx_SS3
eCSPI
Addressing:
0 - 2-bytes
(16-bit)
1 - 3-bytes
(24-bit)
Port Select:
000 - eCSPI1
001 - eCSPI2
010 - eCSPI3
011 - eCSPI4
100 - Reserved
101 - Reserved
110 - Reserved
111 - Reserved
0x460[7:0]
Reserved
FORCE_C
OLD_BOOT
BT_FUSE_
SEL
DIR_BT_DI
S
Reserved
SEC_CONF
IG[1]
Reserved
0x460[15:8]
Reserved
Table continues on the next page...
Chapter 5 Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
223

<!-- page 224 -->

Table 5-6. MMC/eMMC Boot Fusemap (continued)
Addr
7
6
5
4
3
2
1
0
0x460[23:16]
JTAG_SMODE[1:0]
WDOG_EN
ABLE
0 - Disabled
1 - Enabled
SJC_DISAB
LE
Reserved
0x460[31:24]
Reserved
TZASC_EN
ABLE
JTAG_HEO
KTE
Reserved
DLL_ENAB
LE
0 - Disable
DLL for SD/
eMMC
1 - Enable
DLL for SD/
eMMC
0x470[7:0]
DLL
Override:
0 - DLL
Slave Mode
for SD/
eMMC
1 - DLL
Override
Mode for
SD/eMMC
SD1_RST_
POLARITY_
SELECT
0 - Reset
active low
1 - Reset
active high
SD2
VOLTAGE
SELECTIO
N
0 - 3.3V
1 - 1.8V
Reserved
Disable
SDMMC
Manufactur
e mode
0 - Enable
1 - Disable
L1 I-Cache
DISABLE
BT_MMU_D
ISABLE
Override SD
Pad
Settings
(using
PAD_SETTI
NGS value)
0x470[15:8]
SD2 Reset
Signal
Polarity:
0 - Reset
active-low
1 - Reset
active-high
eMMC 4.4 -
RESET TO
PRE-IDLE
STATE
Override
HYS bit for
SD/MMC
pads
USDHC_PA
D_PULL_D
OWN
0 - no
action
1 - pull
down
ENABLE_E
MMC_22K_
PULLUP
0 - 47K
pullup
1 - 22K
pullup
ADD_DS__
SET_GPR1
_16
0 - Set
1 - Don't set
USDHC_IO
MUX_SION
_BIT_ENAB
LE
0 - Disable
1 - Enable
USDHC
IOMUX
SRE Enable
0 - Disable
1 - Enable
0x470[23:16]
USDHC_C
MD_OE_PR
E_EN (SD/
eMMC
Debug)
0 - COM OE
Disabled
1 - COM OE
Enabled
LPB_BOOT (Core / DDR-
Bus)
00 - LPB Disable
01 - 1 GPIO (def freq)
10 - Div by2
11 - Div by 4
BT_LPB_P
OLARITY
(GPIO
polarity)
0 - Active
High
1 - Active
Low
Reserved
0x470[31:24]
Override
NAND Pad
Settings
(Use
PAD_SETTI
NGS value)
MMC_DLL_DLY[6:0]
0x6D0[7:0]
RANDOMIZ
ER_ENABL
E
Reserved
PAD_SETTINGS[5:0]
Boot Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
224
NXP Semiconductors

<!-- page 225 -->

Table 5-7. NAND Boot Fusemap
Addr
7
6
5
4
3
2
1
0
0x450[7:0]
(BOOT_CFG1)
1
BT_TOGGL
EMODE
Pages in Block:
00 - 128
01 - 64
10 - 32
11 - 256
Nand Number Of
Devices:
00 - 1
01 - 2
10 - 4
11 - Reserved
Nand_Row_address_byte
s:
00 - 3
01 - 2
10 - 4
11 - 5
0x450[15:8]
(BOOT_CFG2)
Toggle Mode 33 MHz Preamble Delay,
Read Latency:
000 - 16 GPMICLK cycles.
001 - 1 GPMICLK cycles.
010 - 2 GPMICLK cycles.
011 - 3 GPMICLK cycles.
100 - 4 GPMICLK cycles.
101 - 5 GPMICLK cycles.
110 - 6 GPMICLK cycles.
111 - 7 GPMICLK cycles.
Boot Search Count:
00 - 2
01 - 2
10 - 4
11 - 8
Boot
Frequencies
(ARM/DDR)
0 - 500 /
400 MHz
1 - 250 /
200 MHz
Reset Time
0 - 12 ms
1 - 22 ms
(LBA
NAND)
Reserved
0x450[23:16]
(BOOT_CFG3)
Reserved
0x450[31:24]
(BOOT_CFG4)
Reserved
EEPROM
Recovery
Enable
0 - Disabled
1 - Enabled
Fuse is
Reserved
for 'Serial-
ROM' Boot
mode
eCSPI chip select:
00 - ECSPIx_SS0
(default)
01 - ECSPIx_SS1
10 - ECSPIx_SS2
11 - ECSPIx_SS3
eCSPI
Addressing:
0 - 2-bytes
(16-bit)
1 - 3-bytes
(24-bit)
Port Select:
000 - eCSPI1
001 - eCSPI2
010 - eCSPI3
011 - eCSPI4
100 - Reserved
101 - Reserved
110 - Reserved
111 - Reserved
0x460[7:0]
Reserved
FORCE_C
OLD_BOOT
BT_FUSE_
SEL
DIR_BT_DI
S
Reserved
SEC_CONF
IG[1]
Reserved
0x460[15:8]
Reserved
0x460[23:16]
JTAG_SMODE[1:0]
WDOG_EN
ABLE
0 - Disabled
1 - Enabled
SJC_DISAB
LE
Reserved
0x460[31:24]
Reserved
TZASC_EN
ABLE
JTAG_HEO
KTE
Reserved
DLL_ENAB
LE
0 - Disable
DLL for SD/
eMMC
Table continues on the next page...
Chapter 5 Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
225

<!-- page 226 -->

Table 5-7. NAND Boot Fusemap (continued)
Addr
7
6
5
4
3
2
1
0
1 - Enable
DLL for SD/
eMMC
0x470[7:0]
DLL
Override:
0 - DLL
Slave Mode
for SD/
eMMC
1 - DLL
Override
Mode for
SD/eMMC
SD1_RST_
POLARITY_
SELECT
0 - Reset
active low
1 - Reset
active high
SD2
VOLTAGE
SELECTIO
N
0 - 3.3V
1 - 1.8V
Reserved
Disable
SDMMC
Manufactur
e mode
0 - Enable
1 - Disable
L1 I-Cache
DISABLE
BT_MMU_D
ISABLE
Override SD
Pad
Settings
(using
PAD_SETTI
NGS value)
0x470[15:8]
SD2_RST_
POLARITY_
SELECT
0 - Reset
acitve low
1 - Reset
active high
eMMC 4.4 -
RESET TO
PRE-IDLE
STATE
Override
HYS bit for
SD/MMC
pads
USDHC_PA
D_PULL_D
OWN
0 - no
action
1 - pull
down
ENABLE_E
MMC_22K_
PULLUP
0 - 47K
pullup
1 - 22K
pullup
ADD_DS__
SET_GPR1
_16
0 - Set
1 - Do not
set
USDHC_IO
MUX_SION
_BIT_ENAB
LE
0 - Disable
1 - Enable
USDHC
IOMUX
SRE Enable
0 - Disable
1 - Enable
0x470[23:16]
Reserved
LPB_BOOT (Core / DDR-
Bus)
00 - LPB Disable
01 - 1 GPIO (def freq)
10 - Div by2
11 - Div by 4
BT_LPB_P
OLARITY
(GPIO
polarity)
0 - Active
High
1 -Active
Low
Reserved
0x470[31:24]
Override
NAND Pad
Settings
(Use
PAD_SETTI
NGS value)
MMC_DLL_DLY[6:0]
0x6D0[7:0]
RANDOMIZ
ER_ENABL
E
Reserved
PAD_SETTINGS[5:0]
0x6D0[23:16]
NAND_READ_CMD_CODE1[7:0]
0x6D0[31:24]
NAND_READ_CMD_CODE2[7:0]
Lock Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
226
NXP Semiconductors

<!-- page 227 -->

5.2
Lock Fusemap
Table 5-8 describes the functions of a set of lock fuses.
Table 5-8. Lock Fuses
Addr
7
6
5
4
3
2
1
0
0x400[7:0]
Reserved
SJC_RESP
_LOCK
WRP,OP,R
DP
MEM_TRIM_LOCK
1x - OP
x1 - WP
BOOT_CFG_LOCK
1x - OP
x1 - WP
TESTER_LOCK
1x - OP
x1 - WP
00x400[15:8]
GP3_LOCK
1 - WP +
OP
SRK_LOCK
GP2_LOCK
1x - OP
x1 - WP
GP1_LOCK
1x - OP
x1 - WP
MAC_ADDR_LOCK
1x - OP
x1 - WP
0x400[23:16]
GP4_LOCK
1 - WP +
OP
MISC_CON
F_LOCK
1 - WP +
OP
ROM_PAT
CH_LOCK
1 - WP +
OP
OTPMK_C
RC_LOCK
1 - WP +
RP
ANALOG_LOCK
1x - OP
x1 - WP
OTPMK_LO
CK
1 - RP, WP,
OP
SW_GP_LO
CK
1 - WP +
OP of
SW_GP
fuses
0x400[31:24]
GP3_RLOC
K
1 - RP
GP4_RLOC
K
1 - RP
Reserved
Reserved
Reserved
(LOCK_PIN
)
Reserved
5.3
Fusemap Descriptions Table
Table 5-9. Fusemap Descriptions
Fuse
Address
Fuses Name
Numbe
r of
Fuses
Fuses Function
Setting
Used by
0x400[1:0]
TESTER_LOCK
2
OCOTP
0x400[3:2]
BOOT_CFG_LOCK 2
Perform lock on BOOT
related fuses.
0 - Unlock (The controlled
field can be read, sensed,
burned or overridden in the
corresponded IIM register) 1
- Lock (The controlled field
can be read or sensed only)
OCOTP
0x400[5:4]
MEM_TRIM_LOCK
2
Trimming fuses. Burnt on the
tester or by customer before
the final product shipment.
0 - Unlock (The controlled
field can be read, burned or
overridden in the
corresponded IIM register) 1
- Lock (The controlled field
can be read only)
OCOTP
0x400[6]
SJC_RESP_LOCK
1
OCOTP
0x400[9:8]
MAC_ADDR_LOCK 2
Lock MAC_ADDR fuses.
OCOTP
Table continues on the next page...
Chapter 5 Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
227

<!-- page 228 -->

Table 5-9. Fusemap Descriptions (continued)
Fuse
Address
Fuses Name
Numbe
r of
Fuses
Fuses Function
Setting
Used by
0x400[11:10]
GP1_LOCK
2
Lock for General Purpose
fuse register #1 (GP1)
OCOTP
0x400[13:12]
GP2_LOCK
2
Lock for General Purpose
fuse register #2 (GP2)
OCOTP
0x400[14]
SRK_LOCK
1
Locking SRK_HASH[255:0]
OCOTP
0x400[15]
GP3_LOCK
1
Lock for General Purpose
fuse register #3 (GP3)
OCOTP
0x400[19:18]
ANALOG_LOCK
2
OCOTP
0x400[22]
MISC_CONF_LOC
K
1
OCOTP
0x400[31]
GP4_RLOCK
1
Read protection for general
purpose fuse
OCOTP
0x410[10:0]
LOT_NO_ENC[42:0
] (SJC CHALL/
UNIQUE_ID[42:0])
43
FSL-wide unique, encoded
LOT ID STD II/SJC
CHALLENGE/ Unique ID
SJC, SW
0x420[15:11]
WAFER_NO[4:0]
( SJC_CHALL[47:4
3] /
UNIQUE_ID[47:43]
)
5
The wafer number of the
wafer on which the device
was fabricated/SJC
CHALLENGE/ Unique ID
SJC, SW
0x420[23:16]
DIE-Y-
CORDINATE[7:0]
( SJC_CHALL[55:4
8] /
UNIQUE_ID[55:48]
)
8
The Y-coordinate of the die
location on the wafer/SJC
CHALLENGE/ Unique ID
SJC, SW
0x420[31:24]
DIE-X-
CORDINATE[7:0]
( SJC_CHALL[63:5
6] /
UNIQUE_ID[63:56]
)
8
The X-coordinate of the die
location on the wafer/SJC
CHALLENGE/ Unique ID
SJC, SW
0x430[19:16]
SI_REV[3:0]
4
Silicon Revision number
SW
0x430[21:20]
TAMPER_PIN_DIS
ABLE[1:0]
2
Disable ten tamper pins
00 - enabled, TAMPER0-9
used as TAMPER detection
pins.
01 - disabled, TAMPER2-4
and TAMPER7-9 used as
GPIO.
10 - disabled, TAMPER0-1
and TAMPER5-6 used as
GPIO.
11 - disabled, TAMPER0-9
used as GPIO.
SNVS
Table continues on the next page...
Fusemap Descriptions Table
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
228
NXP Semiconductors

<!-- page 229 -->

Table 5-9. Fusemap Descriptions (continued)
Fuse
Address
Fuses Name
Numbe
r of
Fuses
Fuses Function
Setting
Used by
0x440[17:16]
SPEED_GRADING[
1:0]
2
Burned by tester program, for
indicating IC core speed (Hot
burn may not be used).
FH
A[3:
2]
FC
A[5:
4]
FR
AL[
0:1]
MH
z
P/N
Cod
e
xx
xx
00
Res
erv
ed
Res
erv
ed
xx
xx
01
528
05
xx
xx
10
800
08
xx
xx
11
900
09
PROD / SW
0x450[7:0]
BOOT_CFG1
8
BOOT configuration register
#1, Usage varies, depending
on selected boot device.
0x0000XXXX - WEIM (NOR/
OneNAND) boot
0x0011XXXX - Serial ROM
(I2C/SPI) boot
0x1XXXXXXX - NAND
FLASH boot 0x010XXXXX -
SD/eSD 0x011XXXXX -
MMC/eMMC boot Others -
Reserved Refer to Fuse
Map for details.
SRC
0x450[15:8]
BOOT_CFG2
8
BOOT configuration register
#2, Usage varies, depending
on selected boot device.
See fuse-map tab for details. SRC
0x450[23:16]
BOOT_CFG3
8
BOOT configuration register
#3
See fuse-map tab for details. SRC
0x450[31:24]
BOOT_CFG4
8
BOOT configuration register
#3
See fuse-map tab for details. SRC
0x460[1]
SEC_CONFIG[1]
1
Security Configuration (with
SEC_CONFIG[0])
00 - FAB (Open) 01 - Open -
allows any code to be
flashed and executed, even
if it has no valid signature.
1x - Closed (Security On)
SW (ROM), SRC,
SNVS, TPSMP
0x460[3]
DIR_BT_DIS
1
Direct External Memory Boot
Disable
0 - Direct boot from external
memory is allowed 1 - Direct
boot from external memory
is not allowed
SW(ROM), SRC
0x460[4]
BT_FUSE_SEL
1
Determines, whether using
fuses for boot configuration,
or GPIO /Serial loader.
If boot_mode="00"
(Development) 0=Boot
mode configuration is taken
from GPIOs. 1=Boot mode
configuration is taken from
fuses. If boot_mode="10"
(Production) 0 - Boot using
Serila Loader (USB) 1- Boot
mode configuration is taken
from fuses.
SRC SW(ROM)
0x460[5]
FORCE_COLD_BO
OT(SBMR)
1
Force cold boot when A9
core come out of reset.
Fuse Function: 0 – Default
behavior equivalent to the
SRC
Table continues on the next page...
Chapter 5 Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
229

<!-- page 230 -->

Table 5-9. Fusemap Descriptions (continued)
Fuse
Address
Fuses Name
Numbe
r of
Fuses
Fuses Function
Setting
Used by
Reflected in SBMR reg of
SRC
rest of the i.MX6 family
allowing a fast recovery from
low power modes. That is,
the ROM is allowed to jump
to the address previously
programmed in the SRC
persistent register. 1 – Fast
recovery path in the ROM is
not allowed and a cold boot
is always performed.
Customers wanting a higher
level of security should burn
this fuse.
0x460[15:8]
DDR3_CONFIG[7:0
]
8
DDR3 config options
SW(ROM)
0x460[16]
FORCE_INTERNAL
_BOOT
1
Once been blown, the
external BT_MODE[1:0] pins
will be ignored, BootROM
takes Boot Mode as "Internal
Boot"
0—Boot Mode from
BT_MODE pins
1—BT_MODE pins be
ignored, Boot Mode forced
to "Internal Boot"
SW(ROM)
0x460[17]
SDP_DISABLE
1
Disable/Enable serial
download support
0—Serial download
supported
1—No serial download
support
SW(ROM)
0x460[18]
SDP_READ_DISAB
LE
1
Disable/Enable serial
download READ_REGISTER
command
0—SDP READ_REGISTER
command is enabled
1—SDP READ_REGISTER
is disabled
SW(ROM)
0x460[20]
SJC_DISABLE
1
Disable/Enable the Secure
JTAG Controller module.
This fuse is used to create
highest JTAG security level,
where JTAG is totally
blocked.
0 - Secure JTAG Controller
is enabled
1 - Secure JTAG Controller
is disabled
Security logic
0x460[21]
WDOG_ENABLE
1
Watchdog Enable
Used to specify whether to
enable / not watchdog at
boot.
'0' - Watch-Dog is disabled.
'1' - Watch-Dog is enabled.
SW(ROM)
0x460[23:22]
JTAG_SMODE[1:0]
2
JTAG Security Mode.
Controls the security mode of
the JTAG debug interface
00 - JTAG enable mode 01 -
Secure JTAG mode 11 - No
debug mode
Security logic
0x460[24]
DLL_ENABLE
1
Controls the enable/disable
of the DLL for SD/eMMC
boot.
0 - Disable DLL for SD/
eMMC 1 - Enable DLL for
SD/eMMC
SW (ROM)
Table continues on the next page...
Fusemap Descriptions Table
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
230
NXP Semiconductors

<!-- page 231 -->

Table 5-9. Fusemap Descriptions (continued)
Fuse
Address
Fuses Name
Numbe
r of
Fuses
Fuses Function
Setting
Used by
0x460[26]
KTE
1
Kill Trace Enable. Enables
tracing capability on ETM,
and other modules.
0 - Bus tracing is allowed 1 -
Bus tracing is allowed in
case security state as
defined by Secure JTAG
allows it (for example,
JTAG_ENABLE or
NO_DEBUG)
SJC
0x460[27]
JTAG_HEO
1
JTAG HAB Enable Override.
Disallows HAB JTAG
enabling. The HAB may
normally enable JTAG
debugging by means of the
HAB_JDE-bit in the OCOTP
SCS register. The
JTAG_HEO-bit can override
this behavior.
0 - HAB may enable JTAG
debug access 1 - HAB JTAG
enable is overridden (HAB
may not enable JTAG debug
access)
SJC
0x460[28]
TZASC_ENABLE
1
TZASC enable fuse.
0 - TZASC module left in
disable and bypass state. 1 -
TZASC modules and
associated clocks and
muxing are enabled by Boot
ROM code.
SW (ROM)
0x460[29]
PWR_STABLE_CY
CLE_SELECTION
1
Select power stable cycle
0 - 5 ms
1 - 2.5 ms
SW (ROM)
0x470[0]
Override SD Pad
Settings
1
Overrides ROM default value
for SD PAD control register.
When set ROM will override
SD pad control register with
value programmed into
PAD_SETTINGS fuse bits.
SW (ROM)
0x470[1]
BT_MMU_DISABLE 1
The fuse bit is used for ROM
to not enable MMU
SW (ROM)
0x470[2]
L1 I-Cache
DISABLE
1
The fuse bit is used for ROM
to not enable L1 I-Cache
SW (ROM)
0x470[3]
Disable SDMMC
Manufacture mode
1
The fuse bit is used to
disable ROM feature
“SD/MMC Manufacturing
Mode”.
0 - Enable 1 – Disable
SW (ROM)
0x470[4]
UART Serial
Download Disable
1
Disable UART Serial
Download
0 - Enable 1 – Disable
SW (ROM)
0x470[5]
SD2 VOLTAGE
SELECTION
1
Fuse bit to change voltage
selection for SD2 pads.
When set ROM will select
1.8V for SD3 pads otherwise
3.3V
0 - 3.3V 1 - 1.8V
SW (ROM)
0x470[6]
SD1_RST_POLARI
TY_SELECT
1
Select reset polarity for SD1
0 - Reset active low
1 - Reset active high
SW (ROM)
Table continues on the next page...
Chapter 5 Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
231

<!-- page 232 -->

Table 5-9. Fusemap Descriptions (continued)
Fuse
Address
Fuses Name
Numbe
r of
Fuses
Fuses Function
Setting
Used by
0x470[7]
DLL Override
1
Select the DLL mode for SD/
eMMC.
0 - DLL Slave Mode for SD/
eMMC 1 - DLL Override
Mode for SD/eMMC
SW (ROM)
0x470[8]
USDHC IOMUX
SRE Enable
1
The fuse bit is used for ROM
to enable SRE bit for SD
pads
0 - Disable 1 - Enable
SW (ROM)
0x470[9]
USDHC_IOMUX_SI
ON_BIT_ENABLE
1
The fuse bit is used for ROM
to enable SION bit for MUX
control register.
0 - Disable 1 - Enable
SW (ROM)
0x470[10]
Boot Failure
Indicator Pin
Select[4]
1
Indicator boot failure
00000 - gpio1.IO00
00001 - gpio1.IO01
...
11111 _ gpio1.IO31
SW (ROM)
0x470[11]
ENABLE_EMMC_2
2K_PULLUP
1
The fuse bit is used for ROM
to enable 22K pullup for SD
pads.
0 - 47K pullup 1 - 22K pullup SW (ROM)
0x470[12]
USDHC_PAD_PUL
L_DOWN
1
The fuse bit is used for ROM
to enable pull down bit for SD
pads.
0 - no action 1 - pull down
SW (ROM)
0x470[13]
Override HYS bit for
SD/MMC pads
1
Once this fuse be blown, the
[HYS] bit of
IOMUXC_SW_PAD_CTL_P
AD_SDx_CLK(x is the SD
port which the ROM boot
from),
IOMUXC_SW_PAD_CTL_P
AD_SDx_CMD,
IOMUXC_SW_PAD_CTL_P
AD_SDx_DAT0-n(n will be 0,
3, or 7, depends on the bus
width selected) will be set.
SW (ROM)
0x470[14]
eMMC 4.4 - RESET
TO PRE-IDLE
STATE
1
Once this fuse be blown, the
CMD0 with argument
0xf0f0f0f0 will be sent to put
the eMMC card into pre-IDLE
state so that eMMC card’s
fast boot can work properly.
This is useful for the warm
boot, such as boot due to the
WDOG reset.
SW (ROM)
0x470[15]
SD2_RST_POLARI
TY_SELECT
1
select the polarity of SD2
0 – Active Low ; 1 – Active
high
SW (ROM)
0x470[19:16]
Boot Failure
Indicator Pin
Select[3:0]
4
Miscellaneous power
management configuration
bits.
00000 - gpio1.IO00
00001 - gpio1.IO01
...
11111 - gpio1.IO31
SW (ROM)
Table continues on the next page...
Fusemap Descriptions Table
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
232
NXP Semiconductors

<!-- page 233 -->

Table 5-9. Fusemap Descriptions (continued)
Fuse
Address
Fuses Name
Numbe
r of
Fuses
Fuses Function
Setting
Used by
0x470[20]
BT_LPB_POLARIT
Y
1
Define GPIO3 polarity, for
determining LPB boot mode.
0' - Active High '1' -Active
Low
SW (ROM)
0x470[22:21]
LPB_BOOT
2
Defined the LowPower Boot
options
(Core / DDR- Bus) '00' - LPB
Disable '01' - 1 GPIO (def
freq) '10' - Div by2 '11' - Div
by 4
SW (ROM)
0x470[30:24]
MMC_DLL_DLY[6:0
]
7
eMMC 4.4 delay line default
value (set by boot rom), used
in conjunction with "DLL
Override" = 1
(BOOT_CFG3[3])
Connected to LVDS module
SW (ROM)
0x470[31]
Override NAND Pad
Settings
1
Override pad settings for
NAND boot.
SW (ROM)
0x4F0[15:0]
USB_VID[31:0]
16
USB VID
SW
0x4F0[31:16]
USB_PID[31:0]
16
USB PID
SW
0x580[31:0]
SRK_HASH[255:0]
256
SRK key, no HW visible
lines. NO HW Visible signals
available
SW (HAB)
0x600[23:0]
SJC_RESP[55:0]
56
Response reference value
for the secure JTAG
controller
SJC
0x620[15:0]
MAC1_ADDR[47:0]
48
Ethernet1 MAC Address
SW
0x660[31:0]
GP1[31:0]
32
General Purpose fuse
register #1
PROD / SW
0x670[31:0]
GP2[31:0]
32
General Purpose fuse
register #2
PROD / SW
0x680[31:0]
SW_GP[159:0]
160
SW general purpose key
PROD / SW
0x6D0[5:0]
PAD_SETTINGS
6
Used with conjunction of
MMC/SD/Nand "Override
Pad Settings" fuse value, as
follow: '0' - Use IO default
settings for boot device IO
pads. '1' - Use "Override"
value, as set by this register.
IO pads settings of selected
boot interface, are override
with this fuses, as follow: [0]
- Slew Rate [3:1] Drive
Strength [5:4] - Speed
Settings. Refer to IO PAD
chapter for "Settings" fields
value
SW (ROM)
0x6D0[6]
USB_VBUS_EVEN
T_HANDLER_EN
1
ROM handle USB VBUS
attach or detach event
0 - ROM not handle USB
VBUS attach or detach
event
1 - ROM handle USB VBUS
attach or detach event
SW (ROM)
0x6D0[7]
Enable boot failure
indication pin
1
Enable boot failure indicator
pin
0 - disable
1 - enable
SW (ROM)
0x6D0[11:8]
READ_RETRY_SE
Q_ID[3:0]
4
Choose read retry sequence
0000 - don't use read
retry(RR) sequence
embedded in ROM
SW (ROM)
Table continues on the next page...
Chapter 5 Fusemap
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
233

<!-- page 234 -->

Table 5-9. Fusemap Descriptions (continued)
Fuse
Address
Fuses Name
Numbe
r of
Fuses
Fuses Function
Setting
Used by
0001 - Micron 20 nm RR
sequence
0010 - Toshiba A19 nm RR
sequence
0011 - Toshiba 19 nm RR
sequence
0100 - SanDisk 19 nm RR
sequence
0101 - SanDisk 1ynmRR
sequence
0110 - use Hynix 20 nm A
die read retry sequence
0111 - use Hynix 26 nm
read retry sequence
1000 - use Hynix 20 nm B
die read retry sequence
1001 - use Hynix 20 nm C
die read retry sequence
Others - Reserved
0x6D0[15:13] WDOG Timeout
Select
3
Select WDOG timeout
000 - 64s
001 - 32s
010 - 16s
011 - 8s
100 - 4s
Others - Reserved
SW (ROM)
0x6D0[23:16] NAND_READ_CMD
_CODE1[7:0]
8
NAND_READ_CMD_CODE1 First command word to be
used for Nand read.
SW (ROM)
0x6D0[31:24] NAND_READ_CMD
_CODE2[7:0]
8
NAND_READ_CMD_CODE2 Second command word to
be used for Nand read.
SW (ROM)
0x6E0[0]
FIELD_RETURN
1
Configure device for field
return testing. Fuse burning
is protected by CSF
command, with proper
parameter passed. Write/OP
protected by
FIELD_RETURN_LOCK bit
in control register.
0 - Device is in functional /
secure mode.
1 - Device is open for field-
return testing.
SW (ROM),
SNVS_HP,
SRC,
TPSMP,
Security Logic
0x880-0x8B0
GP3[127:0]
128
General Purpose fuse
Register #3
SW
0x8C0-0x8F0 GP4[127:0]
128
General Purpose fuse
Register #4
SW
Fusemap Descriptions Table
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
234
NXP Semiconductors

