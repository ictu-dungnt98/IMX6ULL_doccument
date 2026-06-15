# Chapter 18: Clock Controller Module (CCM)

> Nguồn: `IMX6ULLRM.pdf` — trang 625–750

<!-- page 625 -->

Chapter 18
Clock Controller Module (CCM)
18.1
Overview
The Clock Control Module (CCM) generates and controls clocks to the various modules
in the design and manages low power modes. This module uses the available clock
sources to generate the clock roots.
The Clock Controller Module controls the following functions:
• Uses the available clock sources to generate clock roots to various parts of the chip:
• PLL1 also referenced as ARM PLL
• PLL2 also referenced as System PLL
• PLL3 also referenced as USB1 PLL
• PLL4 also referenced as Audio PLL
• PLL5 also referenced as Video PLL
• PLL6 also referenced as ENET PLL
• PLL7 also referenced as USB2 PLL (This PLL is only used by the USB UTM
interface through a direct connection.)
• Uses programmable bits to control frequencies of the clock roots.
• Controls the low power mechanism.
• Provides control signals to LPCG for gating clocks.
• Provides handshake with SRC for reset performance.
• Provides handshake with GPC for support of power gating operations.
18.1.1
Features
The CCM includes these distinctive features:
• Provides root clock to SoC modules based on several source clocks.
• ARM core root clock is generated from a dedicated source clock.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
625

<!-- page 626 -->

• Includes separate dividers to control generation of core and bus root clocks (AXI,
AHB, IPG).
• Includes separate dividers and clock source selectors for each serial root clock.
• Optional external clocks to bypass PLL clocks.
• Selects clock signals to output on CCM_CLKO onto the pads for observability.
• Controllable registers are accessible via IP bus.
• Manages the Low Power Modes, namely RUN, WAIT and STOP. The gating of the
peripheral clocks is programmable in RUN and WAIT modes.
• Manages frequency scaling procedure for ARM core clock by shifting between PLL
sources, without loss of clocks.
• Manages frequency scaling procedure for peripheral root clock by programmable
divider. The division is done on the fly without loss of clocks.
• Interface for the following IPs:
• PLL - Interfaces for each PLL
• LPCG - Low Power Clock Gating unit
• SRC - System Reset Controller
• GPC - General Power Controller
18.1.2
CCM Block Diagram
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
626
NXP Semiconductors

<!-- page 627 -->

CCM_ANALOG
CCM_HND_SK
CCM_LPM
CCM_CLK_LOGIC
clk
enable
signals
Low Power
Clock Gating
(LPCG)
CLK_ROOTS
CCM_CLK_
ROOT_GEN
CCM_CLK_SWITCHER
CCM_CLK_IGNITION
CCM_CLK_SRC_DIV
CLKO1, CLKO2
RESET
GENERATOR
BOOT
DECODER
XTALOSC, PLLs
SRC
PLLs
System
Clocks
PGC
GPC
Figure 18-1. Block Diagram
CCM contains the following sub-blocks:
Table 18-1. CCM Sub-blocks
CCM_CLK_SRC_DIV Sub-block
Description
CCM_CLK_IGNITION
Manages the ignition process. This module starts its functionality once CCM comes out
of reset. It manages the process that begins with starting the OSC, PLLs and finishes
with creation of stable output root clocks after reset.
CCM_CLK_SWITCHER
Receives the clock outputs of the PLLs, together with the bypass clocks for the PLLs,
and generates switcher clock outputs (pll1_sw_clk, pll3_sw_clk) for the
CCM_CLK_ROOT_GEN sub-module.
CCM_CLK_ROOT_GEN
Receives the main clocks (PLLs / PFDs) and generates the output root clocks.
CCM_CLK_LOGIC
Generates the clock enables. It generates the clock enable signals based on info from
CCM_LPM and CCM_IP. The clock enables are used in LPCG to turn off and on the
split clocks.
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
627

<!-- page 628 -->

Table 18-1. CCM Sub-blocks (continued)
CCM_CLK_SRC_DIV Sub-block
Description
CCM_LPM
Manages the low power modes of the IC.
CCM_HND_SK
Manages the handshake when changing certain root clock dividers that require
handshake.
18.2
External Signals
The following table describes the external signals of CCM:
Table 18-2. CCM External Signals
Signal
Description
Pad
Mode
Direction
CCM_CLKO1
Observability clock 1 output
JTAG_TMS
ALT3
O
SD1_DATA2
ALT6
CCM_CLKO2
Observability clock 2 output
JTAG_TDO
ALT3
O
SD1_DATA3
ALT6
CCM_REF_EN_B
Enable external reference
clock (CKIH)
GPIO1_IO06
ALT7
O
18.3
CCM Clock Tree
The following figures (Part 1 and Part 2) show the clock tree configuration and clock
roots for CCM.
For detailed sub-block information, see:
• Clock Switcher
• Clock Root Generator
• Low Power Clock Gating module (LPCG)
• System Clocks
NOTE
The default frequency values (in MHz) for the PLLs and PFDs
are shown in the Clock Tree diagram that follows. The PLLs
and PFDs control registers may be reprogrammed according to
the speed grade of the SoC being used, but should not exceed
that maximum setting for that speed grade.
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
628
NXP Semiconductors

<!-- page 629 -->

CACRR[ARM_PODF]
CBCMR[PRE_PERIPH2_CLK_SEL]
CSCMR1[USDHCn_CLK_SEL]
/2
CBCDR[FABRIC_MMDC_PODF]
CBCDR[IPG_PODF]
AHB
CSCDR1[USDHCn_PODF]
PLL1 
PLL2 
PFD0
PFD1
PFD2
PFD3
996
528
352
594
400
200
*
PLL4 
PLL5 
650
650
* typical
CLOCK SWITCHER 
CLOCK ROOT GENERATOR
/1
ARM_CLK_ROOT
AHB_CLK_ROOT
IPG_CLK_ROOT
PERCLK_CLK_ROOT
USDHC1_CLK_ROOT
USDHC2_CLK_ROOT
BCH_CLK_ROOT
GPMI_CLK_ROOT
SYSTEM
CLOCKS
PLL3
PFD0
PFD1
PFD2
PFD3
480
720
540
508.2
454.7
/2
MMDC_CLK_ROOT
FABRIC_CLK_ROOT
/2
/2
/2
/2
/2
CSCMR1[ACLK_EIM_SEL]
CSCMR1[ACLK_EIM_SLOW_PODF]
ACLK_EIM_SLOW_CLK_ROOT
/2
/1
CSCMR1[PERCLK_PODF]
AXI_CLK_ROOT
AXI
PLL4
OSC
/2
CBCDR[AXI_PODF]
CBCMR[PRE_PERIPH_CLK_SEL]
/2
/8
SPDIF0_CLK_ROOT
CDCDR[SPDIF0_CLK_SEL]
CDCDR[SPDIF0_CLK_PODF]
CDCDR[SPDIF0_CLK_PRED]
USDHC1
USDHC2
APBHDMA
BCH
BCH
ARM
MMDC
TZASC
OCRAM
PXP
CSI
EIM
SPDIF
ARM
/1
/1
/1
/1
PLL_AUDIOn[POST_DIV_SELECT]
PLL_VIDEOn[POST_DIV_SELECT]
CCM_ANALOG_MISC2n[VIDEO_DIV]
CCM_ANALOG_MISC2n[MSB:LSB]
PLL5
PLL3 PFD3
PLL3 PFD2
PLL3 PFD1
PLL2 PFD3
PLL2 PFD2
PLL2 PFD1
PLL2 PFD0
PLL2
ADC -
WDOG
ARM -
uSDHC
EPIT -
I2C
CBCDR[AXI_CLK_SEL]
cg
cg
cg
cg
cg
cg
cg
cg
cg
cg
DIVIDER SELECT
REGISTER[BIT]
CLOCK ROOT OUT 
OF CCM
MUX SELECT 
REGISTER[BIT]
INDEX:
Static Divider
3-bit Divider
6-bit Divider
MUX
2-bit Divider
LPCG Gating
Option
cg
CCM_PLL3_BYP
CCSR[pll3_sw_clk_sel]
pll3_sw_clk
pll3_sw_clk
CBCDR[AXI_ALT_CLK_SEL]
CBCDR[PERIPH_CLK2_PODF]
OSC
CBCDR[PERIPH2_CLK_SEL]
CBCDR[PERIPH2_CLK2_PODF]
CBCMR[PERIPH2_CLK2_SEL]
CBCMR[PERIPH_CLK2_SEL]
/1
CBCDR[PERIPH_CLK_SEL]
OSC
cg
/1
CS1CDR[SAIn_CLK_PRED]
CS1CDR[SAIn_CLK_PODF]
CSCMR1[SAIn_CLK_SEL]
SAI1_CLK_ROOT
SAI2_CLK_ROOT
SAI3_CLK_ROOT
/4
/2
/4
/2
/4
/2
SAI1
SAI2
SAI3
cg
cg
cg
ARM domain divider
clock source goes to ARM Domain and returns to CCM
/2
/4
CBCDR[AHB_PODF]
/2
/8
ESAI_CLK_ROOT
cg
ESAI
CS1CDR[ESAI_CLK_PODF]
CS1CDR[ESAI_CLK_PRED]
CSCMR2[ESAI_CLK_SEL]
Figure 18-2. Clock Tree - Part 1
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
629

<!-- page 630 -->

ipp_di1_clk
ipp_di0_clk
CSCDR2[LCDIF1_PRED]
CSCDR2[LCDIF1_PRE_CLK_SEL]
CSCDR2[LCDIF1_CLK_SEL]
CSCMR2[LDB_DI1_IPU_DIV]
/2
CSCMR1[QSPI1_CLK_SEL]
ipp_di0_clk
ipp_di1_clk
CHSCCDR[EPDC_PODF]
CHSCCDR[EPDC_PRE_CLK_SEL]
CHSCCDR[EPDC_CLK_SEL]
/2
CS2CDR[ENFC_PODF]
CS2CDR[ENFC_PRED]
CS2CDR[ENFC_CLK_SEL]
/2
/1
CSCMR2[CAN_CLK_PODF]
CSCDR2[ECSPI_CLK_PODF]
CSCDR1[UART_CLK_PODF]
CAN_CLK_ROOT
ECSPI_CLK_ROOT
UART_CLK_ROOT
/1
/1
/2
EPDC_CLK_ROOT
OSC
OSC
OSC
CSCMR2[CAN_CLK_SEL]
CSCDR2[ECSPI_CLK_SEL]
CSCDR1[UART_CLK_SEL]
LCDIF1_CLK_ROOT
QSPI1_CLK_ROOT
ENFC_CLK_ROOT
CSCMR1[QSPI1_PODF]
/7
UART
eCSPI
FLEXCAN
IOMUXC
LCDIF1
EPDC
QSPI1
BCH
PLL5
PLL3 PFD3
PLL3 PFD2
PLL3 PFD1
pll3_sw_clk
PLL2 PFD2
PLL2 PFD1
PLL2 PFD0
PLL2
CLOCK ROOT GENERATOR
SYSTEM
CLOCKS
/6
/2
/2
CBCMR[LCDIF1_PODF]
/8
DIVIDER SELECT
REGISTER[BIT]
CLOCK ROOT OUT 
OF CCM
MUX SELECT 
REGISTER[BIT]
INDEX:
Static Divider
3-bit Divider
6-bit Divider
MUX
2-bit Divider
LPCG Gating
Option
cg
cg
cg
cg
cg
cg
cg
cg
CSCMR2[LDB_DI0_IPU_DIV]
CS2CDR[LDB_DI0_CLK_SEL]
/7
PLL2 PFD3
Figure 18-3. Clock Tree - Part 2
18.4
System Clocks
The table found here shows the CCM output clocks' system-level connectivity.
System Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
630
NXP Semiconductors

<!-- page 631 -->

The gating option in the table can either be CGR bit or clock enable from the block itself.
Applicable override bits are also shown.
Table 18-3. System Clocks, Gating, and Override
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
ADCn
IPG_CLK
IPG_CLK_ROOT
CCGR1[CG8]
(ADC1_CLK_ENABLE)
CCGR1[CG4]
(ADC2_CLK_ENABLE)
AIPSTZn
HCLK
AHB_CLK_ROOT
CCGR0[CG0]
(AIPS_TZ1_CLK_ENABL
E)
CCGR0[CG1]
(AIPS_TZ2_CLK_ENABL
E)
CCGR2[CG8]
(IPMUX1_CLK_ENABLE)
CCGR2[CG9]
(IPMUX2_CLK_ENABLE)
CCGR2[CG10]
(IPMUX3_CLK_ENABLE)
CCGR4[CG4]
(CXAPBSYNCBRIDGE_S
LAVE_CLK_ENABLE)
CCGR6[CG4]
(IPMUX4_CLK_ENABLE)
CCGR6[CG9]
(AIPS_TZ3_CLK_ENABL
E)
APBHDMA
HCLK
BCH_CLK_ROOT
CCGR0[CG2]
(APBHDMA_HCLK_ENAB
LE)
SEC_MST_HCLK
BCH_CLK_ROOT
CCGR0[CG2]
(APBHDMA_HCLK_ENAB
LE)
ARM
TRACE_CLK_IN
AHB_CLK_ROOT
CCGR0[CG11]
(ARM_DBG_CLK_ENABL
E)
CLKDIV_PATCH_IPG_CL
K
AHB_CLK_ROOT
CCGR3[CG9]
(A7CLKDIV_PATCH_CLK
_ENABLE)
ASRC
ASRCK_CLOCK_D
SPDIF0_CLK_ROOT
CCGR0[CG3]
(ASRC_CLK_ENABLE)
IPG_CLK
AHB_CLK_ROOT
CCGR0[CG3]
(ASRC_CLK_ENABLE)
MEM_CLK
AHB_CLK_ROOT
CCGR0[CG3]
(ASRC_CLK_ENABLE)
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
631

<!-- page 632 -->

Table 18-3. System Clocks, Gating, and Override (continued)
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
BCH
U_BCH_INPUT_APB_CL
K
BCH_CLK_ROOT
CCGR4[CG12]
(RAWNAND_U_BCH_INP
UT_APB_CLK_ENABLE)
U_GPMI_BCH_INPUT_B
CH_CLK
GPMI_CLK_ROOT
CCGR4[CG13]
(RAWNAND_U_GPMI_B
CH_INPUT_BCH_CLK_E
NABLE)
U_GPMI_BCH_INPUT_G
PMI_IO_CLK
ENFC_CLK_ROOT
CCGR4[CG14]
(RAWNAND_U_GPMI_B
CH_INPUT_GPMI_IO_CL
K_ENABLE)
U_GPMI_INPUT_APB_CL
K
BCH_CLK_ROOT
CCGR4[CG15]
(RAWNAND_U_GPMI_IN
PUT_APB_CLK_ENABLE
)
CCM
CCM_IPG_CLK_S
IPG_CLK_ROOT
IPG_CLK
IPG_CLK_ROOT
ANALOG_APB_CLK
IPG_CLK_ROOT
CCGR6[CG11]
(ANADIG_CLK_ENABLE)
CLK_APB_DBG
IPG_CLK_ROOT
CCGR3[CG4]
(CCM_DAP_CLK_ENABL
E)
CSI
CSI_HCLK
AXI_CLK_ROOT
CCGR2[CG1]
(CSI_CLK_ENABLE)
IPG_CLK
AXI_CLK_ROOT
CCGR2[CG1]
(CSI_CLK_ENABLE)
IPG_CLK_S
AXI_CLK_ROOT
CCGR2[CG1]
(CSI_CLK_ENABLE)
IPG_CLK_S_RAW
AXI_CLK_ROOT
CCGR2[CG1]
(CSI_CLK_ENABLE)
MEM_RXFIFO_CLK
AXI_CLK_ROOT
CCGR2[CG1]
(CSI_CLK_ENABLE)
CSU
AP_CKIL_CLK
CKIL_SYNC_CLK_ROOT
CCGR1[CG14]
(CSU_CLK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR1[CG14]
(CSU_CLK_ENABLE)
DCP
CLK
AHB_CLK_ROOT
CCGR0[CG5]
(DCP_CLK_ENABLE)
EPDC
ACLK
AXI_CLK_ROOT
CCGR3[CG2]
(EPDC_CLK_ENABLE)
PIXCLK
EPDC_CLK_ROOT
CCGR3[CG2]
(EPDC_CLK_ENABLE)
ESAI
IPG_CLK_ESAI
AHB_CLK_ROOT
CCGR2[CG0]
(ESAI_CLK_ENABLE)
EXTAL_CLK
ESAI_CLK_ROOT
CCGR2[CG0]
(ESAI_CLK_ENABLE)
Table continues on the next page...
System Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
632
NXP Semiconductors

<!-- page 633 -->

Table 18-3. System Clocks, Gating, and Override (continued)
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
IPG_CLK_S
IPG_CLK_ROOT
ECSPIn
IPG_CLK
IPG_CLK_ROOT
CCGR1[CG0]
(ECSPI1_CLK_ENABLE)
CCGR1[CG1]
(ECSPI2_CLK_ENABLE)
CCGR1[CG2]
(ECSPI3_CLK_ENABLE)
CCGR1[CG3]
(ECSPI4_CLK_ENABLE)
IPG_CLK_32K
CKIL_SYNC_CLK_ROOT
IPG_CLK_PER
ECSPI_CLK_ROOT
CCGR1[CG0]
(ECSPI1_CLK_ENABLE)
CCGR1[CG1]
(ECSPI2_CLK_ENABLE)
CCGR1[CG2]
(ECSPI3_CLK_ENABLE)
CCGR1[CG3]
(ECSPI4_CLK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR1[CG0]
(ECSPI1_CLK_ENABLE)
CCGR1[CG1]
(ECSPI2_CLK_ENABLE)
CCGR1[CG2]
(ECSPI3_CLK_ENABLE)
CCGR1[CG3]
(ECSPI4_CLK_ENABLE)
EIM
ACLK
ACLK_EIM_SLOW_CLK_
ROOT
CCGR6[CG5]
(EIM_SLOW_CLK_ENAB
LE)
ACLK_SLOW
ACLK_EIM_SLOW_CLK_
ROOT
CCGR6[CG5]
(EIM_SLOW_CLK_ENAB
LE)
IPG_CLK_S
IPG_CLK_ROOT
ACLK_EXSC
ACLK_EIM_SLOW_CLK_
ROOT
CCGR6[CG5]
(EIM_SLOW_CLK_ENAB
LE)
IPG_CLK
IPG_CLK_ROOT
ENETn
IPG_CLK
AHB_CLK_ROOT
CCGR0[CG6]
(ENET_CLK_ENABLE)
IPG_CLK_MAC0
AHB_CLK_ROOT
CCGR0[CG6]
(ENET_CLK_ENABLE)
IPG_CLK_MAC0_S
IPG_CLK_ROOT
CCGR0[CG6]
(ENET_CLK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR0[CG6]
(ENET_CLK_ENABLE)
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
633

<!-- page 634 -->

Table 18-3. System Clocks, Gating, and Override (continued)
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
IPG_CLK_TIME
REF_ENETPLL2_CLK
CCGR0[CG6]
(ENET_CLK_ENABLE)
MAC0_RXMEM_CLK
AHB_CLK_ROOT
CCGR0[CG6]
(ENET_CLK_ENABLE)
MAC0_TXMEM_CLK
AHB_CLK_ROOT
CCGR0[CG6]
(ENET_CLK_ENABLE)
EPITn
IPG_CLK
PERCLK_CLK_ROOT
CCGR1[CG6]
(EPIT1_CLK_ENABLE)
CCGR1[CG7]
(EPIT2_CLK_ENABLE)
CMEOR[MOD_EN_OV_E
PIT]
IPG_CLK_32K
CKIL_SYNC_CLK_ROOT
IPG_CLK_HIGHFREQ
PERCLK_CLK_ROOT
CCGR1[CG6]
(EPIT1_CLK_ENABLE)
CCGR1[CG7]
(EPIT2_CLK_ENABLE)
IPG_CLK_S
PERCLK_CLK_ROOT
CCGR1[CG6]
(EPIT1_CLK_ENABLE)
CCGR1[CG7]
(EPIT2_CLK_ENABLE)
FLEXCANn
IPG_CLK
IPG_CLK_ROOT
CCGR0[CG7]
(CAN1_CLK_ENABLE)
CCGR0[CG9]
(CAN2_CLK_ENABLE)
IPG_CLK_CHI
IPG_CLK_ROOT
CCGR0[CG7]
(CAN1_CLK_ENABLE)
CCGR0[CG9]
(CAN2_CLK_ENABLE)
IPG_CLK_PE
CAN_CLK_ROOT
CCGR0[CG8]
(CAN1_SERIAL_CLK_EN
ABLE)
CCGR0[CG10]
(CAN2_SERIAL_CLK_EN
ABLE)
CMEOR[MOD_EN_OV_C
ANn_CPI]
IPG_CLK_PE_NOGATE
CAN_CLK_ROOT
CCGR0[CG8]
(CAN1_SERIAL_CLK_EN
ABLE)
CCGR0[CG10]
(CAN2_SERIAL_CLK_EN
ABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR0[CG7]
(CAN1_CLK_ENABLE)
CCGR0[CG9]
(CAN2_CLK_ENABLE)
RAM_CLK
IPG_CLK_ROOT
CCGR0[CG7]
(CAN1_CLK_ENABLE)
Table continues on the next page...
System Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
634
NXP Semiconductors

<!-- page 635 -->

Table 18-3. System Clocks, Gating, and Override (continued)
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
CCGR0[CG9]
(CAN2_CLK_ENABLE)
GPC
IPG_CLK
IPG_CLK_ROOT
IPG_CLK_S
IPG_CLK_ROOT
PGC_CLK
IPG_CLK_ROOT
SPARE_IN[0]
CKIL_SYNC_CLK_ROOT
SYS_CLK
IPG_CLK_ROOT
GPIOn
IPG_CLK_S
IPG_CLK_ROOT
0
CCGR1[CG13]
(GPIO1_CLK_ENABLE)
CCGR0[CG15]
(GPIO2_CLK_ENABLE)
CCGR2[CG13]
(GPIO3_CLK_ENABLE)
CCGR3[CG6]
(GPIO4_CLK_ENABLE)
CCGR1[CG15]
(GPIO5_CLK_ENABLE)
GPTn
IPG_CLK
PERCLK_CLK_ROOT
CCGR1[CG10]
(GPT1_CLK_ENABLE)
CCGR0[CG12]
(GPT2_CLK_ENABLE)
CMEOR[MOD_EN_OV_G
PT]
IPG_CLK_24M
CKIH_SYNC_CLK_ROOT
CMEOR[MOD_EN_OV_G
PT]
IPG_CLK_32K
CKIL_SYNC_CLK_ROOT
IPG_CLK_HIGHFREQ
PERCLK_CLK_ROOT
CCGR1[CG11]
(GPT1_SERIAL_CLK_EN
ABLE)
CCGR0[CG13]
(GPT2_SERIAL_CLK_EN
ABLE)
IPG_CLK_S
PERCLK_CLK_ROOT
CCGR1[CG10]
(GPT1_CLK_ENABLE)
CCGR0[CG12]
(GPT2_CLK_ENABLE)
HS
CLK
IPG_CLK_ROOT
I2Cn
IPG_CLK_PATREF
PERCLK_CLK_ROOT
CCGR2[CG3]
(I2C1_SERIAL_CLK_ENA
BLE)
CCGR2[CG4]
(I2C2_SERIAL_CLK_ENA
BLE)
CCGR2[CG5]
(I2C3_SERIAL_CLK_ENA
BLE)
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
635

<!-- page 636 -->

Table 18-3. System Clocks, Gating, and Override (continued)
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
CCGR6[CG12]
(I2C4_SERIAL_CLK_ENA
BLE)
IPG_CLK_S
PERCLK_CLK_ROOT
CCGR2[CG3]
(I2C1_SERIAL_CLK_ENA
BLE)
CCGR2[CG4]
(I2C2_SERIAL_CLK_ENA
BLE)
CCGR2[CG5]
(I2C3_SERIAL_CLK_ENA
BLE)
CCGR6[CG12]
(I2C4_SERIAL_CLK_ENA
BLE)
IOMUXC
IPG_CLK_S
IPG_CLK_ROOT
CCGR2[CG2]
(IOMUXC_SNVS_CLK_E
NABLE)
IPT_CLK_IO
LCDIF_PIX_CLK_ROOT
CCGR2[CG7]
(IOMUX_IPT_CLK_IO_EN
ABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR3[CG15]
(IOMUXC_SNVS_GPR_C
LK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR4[CG1]
(IOMUXC_CLK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR4[CG2]
(IOMUXC_GPR_CLK_EN
ABLE)
KPPn
IPG_CLK_32K
CKIL_SYNC_CLK_ROOT
IPG_CLK_S
IPG_CLK_ROOT
CCGR5[CG4]
(KPP_CLK_ENABLE)
LCDIF
APB_CLK
AXI_CLK_ROOT
CCGR2[CG14]
(LCD_CLK_ENABLE)
PIX_CLK
LCDIF_CLK_ROOT
CCGR3[CG5]
(LCDIF_PIX_CLK_ENABL
E)
MMDC
ACLK_FAST_CORE_P0
MMDC_CLK_ROOT
CCGR3[CG10]
(MMDC_CORE_ACLK_F
AST_CORE_P0_ENABLE
)
ACLK_FAST_PHY_P0
MMDC_CLK_ROOT
CCGR3[CG10]
(MMDC_CORE_ACLK_F
AST_CORE_P0_ENABLE
)
CLK32
CKIL_SYNC_CLK_ROOT
CCGR3[CG13]
(MMDC_CORE_IPG_CLK
_P1_ENABLE)
Table continues on the next page...
System Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
636
NXP Semiconductors

<!-- page 637 -->

Table 18-3. System Clocks, Gating, and Override (continued)
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
IPG_CLK_P0
IPG_CLK_ROOT
CCGR3[CG12]
(MMDC_CORE_IPG_CLK
_P0_ENABLE)
ACLK_EXSC
MMDC_CLK_ROOT
CCGR3[CG10]
(MMDC_CORE_ACLK_F
AST_CORE_P0_ENABLE
)
NIC-301
AXI_A_SIM_S
FABRIC_CLK_ROOT
CCGR1[CG9]
(SIM_S_CLK_ENABLE)
AXI_A_SIM_CPU
FABRIC_CLK_ROOT
CCGR4[CG3]
(SIM_CPU_CLK_ENABLE
)
AXI_B_BCH
BCH_CLK_ROOT
CCGR4[CG6]
(PL301_MX6QPER1_BC
HCLK_ENABLE)
AXI_A_MAIN
FABRIC_CLK_ROOT
CCGR4[CG7]
(PL301_MX6QPER2_MAI
NCLK_ENABLE)
AXI_A_SIM_MAIN
FABRIC_CLK_ROOT
CCGR5[CG8]
(SIM_MAIN_CLK_ENABL
E)
OCOTP
IPG_CLK
IPG_CLK_ROOT
CCGR2[CG6]
(IIM_CLK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR2[CG6]
(IIM_CLK_ENABLE)
OCRAM
CTRL_CLK
AXI_CLK_ROOT
CCGR3[CG14]
(OCRAM_CLK_ENABLE)
ACLK_EXSC
AXI_CLK_ROOT
CCGR3[CG14]
(OCRAM_CLK_ENABLE)
MEM_CLK
AXI_CLK_ROOT
CCGR3[CG14]
(OCRAM_CLK_ENABLE)
PWMn
IPG_CLK
PERCLK_CLK_ROOT
CCGR4[CG11:CG8]
(PWM[4:1]_CLK_ENABLE
)
CCGR6[CG15:CG13]
(PWM[7:5]_CLK_ENABLE
)
CCGR6[CG8]
(PWM8_CLK_ENABLE)
IPG_CLK_32K
CKIL_SYNC_CLK_ROOT
IPG_CLK_HIGHFREQ
PERCLK_CLK_ROOT
CCGR4[CG11:CG8]
(PWM[4:1]_CLK_ENABLE
)
CCGR6[CG15:CG13]
(PWM[7:5]_CLK_ENABLE
)
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
637

<!-- page 638 -->

Table 18-3. System Clocks, Gating, and Override (continued)
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
CCGR6[CG8]
(PWM8_CLK_ENABLE)
IPG_CLK_S
PERCLK_CLK_ROOT
CCGR4[CG11:CG8]
(PWM[4:1]_CLK_ENABLE
)
CCGR6[CG15:CG13]
(PWM[7:5]_CLK_ENABLE
)
CCGR6[CG8]
(PWM8_CLK_ENABLE)
PXP
CLK
AXI_CLK_ROOT
CCGR2[CG15]
(PXP_CLK_ENABLE)
QSPI
AHB_CLK
AHB_CLK_ROOT
CCGR3[CG7]
(QSPI_CLK_ENABLE)
IPG_CLK
IPG_CLK_ROOT
CCGR3[CG7]
(QSPI_CLK_ENABLE)
IPG_CLK_4XSFIF
QSPIn_CLK_ROOT
CCGR3[CG7]
(QSPI_CLK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR3[CG7]
(QSPI_CLK_ENABLE)
SEC_IPG_CLK
IPG_CLK_ROOT
CCGR3[CG7]
(QSPI_CLK_ENABLE)
SEC_IPG_CLK_S
IPG_CLK_ROOT
CCGR3[CG7]
(QSPI_CLK_ENABLE)
MST_HCLK
AHB_CLK_ROOT
CCGR3[CG7]
(QSPI_CLK_ENABLE)
ROMCP
ROM_CLK
AHB_CLK_ROOT
CCGR5[CG0]
(ROM_CLK_ENABLE)
HCLK
AHB_CLK_ROOT
CCGR5[CG0]
(ROM_CLK_ENABLE)
HCLK_REG
IPG_CLK_ROOT
CCGR5[CG0]
(ROM_CLK_ENABLE)
MST_HCLK
AHB_CLK_ROOT
CCGR5[CG0]
(ROM_CLK_ENABLE)
SAIn
IPG_CLK
IPG_CLK_ROOT
CCGR5[CG14]
(SAI1_CLK_ENABLE)
CCGR5[CG15]
(SAI2_CLK_ENABLE)
CCGR5[CG11]
(SAI3_CLK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR5[CG14]
(SAI1_CLK_ENABLE)
CCGR5[CG15]
(SAI2_CLK_ENABLE)
Table continues on the next page...
System Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
638
NXP Semiconductors

<!-- page 639 -->

Table 18-3. System Clocks, Gating, and Override (continued)
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
CCGR5[CG11]
(SAI3_CLK_ENABLE)
IPG_CLK_SAI_MCLK1
SAIN_CLK_ROOT
CCGR5[CG14]
(SAI1_CLK_ENABLE)
CCGR5[CG15]
(SAI2_CLK_ENABLE)
CCGR5[CG11]
(SAI3_CLK_ENABLE)
IPT_CLK_SAI_BCLK
SAIN_CLK_ROOT
CCGR5[CG14]
(SAI1_CLK_ENABLE)
CCGR5[CG15]
(SAI2_CLK_ENABLE)
CCGR5[CG11]
(SAI3_CLK_ENABLE)
IPT_CLK_SAI_BCLK_B
SAIN_CLK_ROOT
CCGR5[CG14]
(SAI1_CLK_ENABLE)
CCGR5[CG15]
(SAI2_CLK_ENABLE)
CCGR5[CG11]
(SAI3_CLK_ENABLE)
IPT_CLK_SAI_MCLK
SAIN_CLK_ROOT
CCGR5[CG14]
(SAI1_CLK_ENABLE)
CCGR5[CG15]
(SAI2_CLK_ENABLE)
CCGR5[CG11]
(SAI3_CLK_ENABLE)
SDMA
IPS_HOSTCTRL_CLK
IPG_CLK_ROOT
CCGR5[CG3]
(SDMA_CLK_ENABLE)
SDMA_AP_AHB_CLK
AHB_CLK_ROOT
CCGR5[CG3]
(SDMA_CLK_ENABLE)
SDMA_CORE_CLK
IPG_CLK_ROOT
CCGR5[CG3]
(SDMA_CLK_ENABLE)
EVENTS_SYNC_CLK
AHB_CLK_ROOT
CCGR5[CG3]
(SDMA_CLK_ENABLE)
SNVS
HP_IPG_CLK
IPG_CLK_ROOT
CCGR5[CG9]
(SNVS_HP_CLK_ENABL
E)
HP_IPG_CLK_S
IPG_CLK_ROOT
CCGR5[CG9]
(SNVS_HP_CLK_ENABL
E)
HP_IPG_HP_RTC_CLK
CKIL_SYNC_CLK_ROOT
LP_IPG_CLK
IPG_CLK_ROOT
CCGR5[CG10]
(SNVS_LP_CLK_ENABL
E)
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
639

<!-- page 640 -->

Table 18-3. System Clocks, Gating, and Override (continued)
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
IPG_DRYICE_CLK_S
IPG_CLK_ROOT
CCGR5[CG2]
(SNVS_DRYICE_CLK_E
NABLE)
LP_IPG_CLK_S
IPG_CLK_ROOT
CCGR5[CG10]
(SNVS_LP_CLK_ENABL
E)
SPBA
IPG_CLK
IPG_CLK_ROOT
CCGR5[CG6]
(SPBA_CLK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR5[CG6]
(SPBA_CLK_ENABLE)
DISP_IPG_CLK
IPG_CLK_ROOT
CCGR5[CG6]
(SPBA_CLK_ENABLE)
DISP_IPG_CLK_S
IPG_CLK_ROOT
CCGR5[CG6]
(SPBA_CLK_ENABLE)
SPDIF
GCLKW_T0
IPG_CLK_ROOT
CCGR5[CG7]
(SPDIF_CLK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
TX_CLK
SPDIF0_CLK_ROOT
CCGR5[CG7]
(SPDIF_CLK_ENABLE)
SRC
IPG_CLK
IPG_CLK_ROOT
SRC_IPG_CLK_S
IPG_CLK_ROOT
SYS_CTR
SYS_CTR_BASE_CLK
24M OSC
CCGR5[CG1]
(SCTR_CLK_ENABLE)
SYS_CTR_SLOW_CLK
32K OSC
IPG_CLK
IPG_CLK_ROOT
CCGR5[CG1]
(SCTR_CLK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR5[CG1]
(SCTR_CLK_ENABLE)
TZASCn
ACLK
MMDC_CLK_ROOT
CCGR2[CG11]
(IPSYNC_IP2APB_TZAS
C1_IPG_MASTER_CLK_
ENABLE)
TSC_DIG
IPG_CLK_S
IPG_CLK_ROOT
CCGR4[CG5]
(TSC_CLK_ENABLE)
IPG_CLK
IPG_CLK_ROOT
CCGR4[CG5]
(TSC_CLK_ENABLE)
LP_CLK
CKIL_SYNC_CLK_ROOT
UARTn
IPG_CLK
IPG_CLK_ROOT
CCGR5[CG12]
(UART1_CLK_ENABLE)
CCGR0[CG14]
(UART2_CLK_ENABLE)
CCGR1[CG5]
(UART3_CLK_ENABLE)
CCGR1[CG12]
(UART4_CLK_ENABLE)
Table continues on the next page...
System Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
640
NXP Semiconductors

<!-- page 641 -->

Table 18-3. System Clocks, Gating, and Override (continued)
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
CCGR3[CG1]
(UART5_CLK_ENABLE)
CCGR3[CG3]
(UART6_CLK_ENABLE)
CCGR5[CG13]
(UART7_CLK_ENABLE)
CCGR6[CG7]
(UART8_CLK_ENABLE)
IPG_CLK_S
IPG_CLK_ROOT
CCGR5[CG12]
(UART1_CLK_ENABLE)
CCGR0[CG14]
(UART2_CLK_ENABLE)
CCGR1[CG5]
(UART3_CLK_ENABLE)
CCGR1[CG12]
(UART4_CLK_ENABLE)
CCGR3[CG1]
(UART5_CLK_ENABLE)
CCGR3[CG3]
(UART6_CLK_ENABLE)
CCGR5[CG13]
(UART7_CLK_ENABLE)
CCGR6[CG7]
(UART8_CLK_ENABLE)
IPG_PERCLK
UART_CLK_ROOT
CCGR5[CG12]
(UART1_CLK_ENABLE)
CCGR0[CG14]
(UART2_CLK_ENABLE)
CCGR1[CG5]
(UART3_CLK_ENABLE)
CCGR1[CG12]
(UART4_CLK_ENABLE)
CCGR3[CG1]
(UART5_CLK_ENABLE)
CCGR3[CG3]
(UART6_CLK_ENABLE)
CCGR5[CG13]
(UART7_CLK_ENABLE)
CCGR6[CG7]
(UART8_CLK_ENABLE)
USB
IPG_AHB_CLK
AHB_CLK_ROOT
CCGR6[CG0]
(USBOH3_CLK_ENABLE)
IPG_CLK_32KHZ
CKIL_SYNC_CLK_ROOT
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
641

<!-- page 642 -->

Table 18-3. System Clocks, Gating, and Override (continued)
Module
Module Clock
Clock Root
Module Clock Gating
Enable
Module Override Enable
IPG_CLK_S
IPG_CLK_ROOT
CCGR6[CG0]
(USBOH3_CLK_ENABLE)
IPG_CLK_S_PL301
IPG_CLK_ROOT
CCGR6[CG0]
(USBOH3_CLK_ENABLE)
TEST_CLK_240M
IPG_CLK_ROOT
CCGR6[CG0]
(USBOH3_CLK_ENABLE)
TEST_CLK_480M
IPG_CLK_ROOT
CCGR6[CG0]
(USBOH3_CLK_ENABLE)
TEST_CLK_60M
IPG_CLK_ROOT
CCGR6[CG0]
(USBOH3_CLK_ENABLE)
USDHCn
HCLK
AHB_CLK_ROOT
CCGR6[CG1]
(USDHC1_CLK_ENABLE)
CCGR6[CG2]
(USDHC2_CLK_ENABLE)
CMEOR[MOD_EN_OV_U
SDHC]
IPG_CLK
IPG_CLK_ROOT
CCGR6[CG1]
(USDHC1_CLK_ENABLE)
CCGR6[CG2]
(USDHC2_CLK_ENABLE)
CMEOR[MOD_EN_OV_U
SDHC]
IPG_CLK_PERCLK
USDHCn_CLK_ROOT
CCGR6[CG1]
(USDHC1_CLK_ENABLE)
CCGR6[CG2]
(USDHC2_CLK_ENABLE)
CMEOR[MOD_EN_OV_U
SDHC]
IPG_CLK_S
IPG_CLK_ROOT
CCGR6[CG1]
(USDHC1_CLK_ENABLE)
CCGR6[CG2]
(USDHC2_CLK_ENABLE)
WDOGn
IPG_CLK
IPG_CLK_ROOT
CCGR3[CG8]
WDOG1_CLK_ENABLE
CCGR5[CG5]
WDOG2_CLK_ENABLE
CCGR6[CG10]
WDOG3_CLK_ENABLE
IPG_CLK_32K
CKIL_SYNC_CLK_ROOT
IPG_CLK_S
IPG_CLK_ROOT
CCGR3[CG8]
WDOG1_CLK_ENABLE
CCGR5[CG5]
WDOG2_CLK_ENABLE
CCGR6[CG10]
WDOG3_CLK_ENABLE
Table 18-4. System Clock Frequency Values
Clock Root
Default Frequency (MHz)
Maximum Frequency (MHz)
ARM_CLK_ROOT
12
528
Table continues on the next page...
System Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
642
NXP Semiconductors

<!-- page 643 -->

Table 18-4. System Clock Frequency Values (continued)
Clock Root
Default Frequency (MHz)
Maximum Frequency (MHz)
MMDC_CLK_ROOT
FABRIC_CLK_ROOT
24
396
AXI_CLK_ROOT
12
264
AHB_CLK_ROOT
6
132
PERCLK_CLK_ROOT
3
66
IPG_CLK_ROOT
3
66
USDHCn_CLK_ROOT
12
198
ACLK_EIM_SLOW_CLK_ROOT
6
132
SPDIF0_CLK_ROOT
1.5
66.6
SAIn_CLK_ROOT
3
66.6
LCDIF_CLK_ROOT
6
150
EPDC_CLK_ROOT
12
264
QSPI_CLK_ROOT
12
396
ENFC_CLK_ROOT
12
198
CAN_CLK_ROOT
1.5
80
ECSPI_CLK_ROOT
3
60
UART_CLK_ROOT
4
80
NOTE
The default frequency is reset value after system power on
reset. It is different with the value initialized by ROM code,
which depends on boot CFG pins/fuse setting.
18.5
Functional Description
This section provides a complete functional description of the block.
18.5.1
Clock Generation
18.5.1.1
External Low Frequency Clock - CKIL
The chip can use a 32 kHz or 32.768 kHz crystal as the external low-frequency source
(XTALOSC). Throughout this chapter, the low-frequency crystal is referred to as the 32
kHz crystal.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
643

<!-- page 644 -->

This clock source should always be active when the chip is powered on. The 32 kHz
entering the CCM are referred to as CKIL. CKIL is synchronized to IPG_CLK and
supplied to modules that need it.
18.5.1.1.1
CKIL synchronizing to IPG_CLK
CKIL is synchronized to ipg_clk when the system is in functional mode. When the
system is in STOP mode (when there is no IPG_CLK) the CKIL synchronizer is
bypassed, and raw CKIL is supplied to the system.
18.5.1.2
External High Frequency Clock - CKIH and internal oscillator
The chip uses an internal oscillator to generate the reference clock (OSC). The internal
oscillator is connected to the external crystal (XTALOSC) which generates the 24 MHz
reference clock.
18.5.1.3
PLL reference clock
There are several PLLs in this chip.
PLL1 - ARM PLL (typical functional frequency )
PLL2 - System PLL (functional frequency 528 MHz)
PLL3 - USB1 PLL (functional frequency 480 MHz)
PLL4 - Audio PLL
PLL5 - Video PLL
PLL6 - ENET PLL
PLL7 - USB2 PLL (functional frequency 480 MHz)
Some of the PLLs are described in the sections below. See CCM Analog Memory Map/
Register Definition for register information.
18.5.1.3.1
ARM PLL
This PLL synthesizes a low jitter clock from a 24 MHz reference clock. The clock output
frequency for this PLL ranges from 650 MHz to 1.3 GHz. The output frequency is
selected by a 7-bit register field CCM_ANALOG_PLL_ARM[DIV_SELECT].
PLL output frequency = Fref * DIV_SEL/2
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
644
NXP Semiconductors

<!-- page 645 -->

NOTE
The upper frequency range may exceed the maximum
frequency supported. Please see the datasheet for more
information.
18.5.1.3.2
USB PLLs
These PLLs synthesize a low jitter clock from the 24 MHz reference clock. USB1 PLL
has 4 frequency-programmable PFD (phase fractional divider) outputs.
The output frequency of USB1 PLL is 480 MHz. Even though USB1 PLL has a
DIV_SELECT register field, this PLL should always be set to 480 MHz in normal
operation. USB2 PLL is only used by the USB UTM interface through a direct
connection.
18.5.1.3.3
System PLL
This PLL synthesizes a low jitter clock from the 24 MHz reference clock. The PLL has
one output clock, plus 4 PFD outputs. The System PLL supports spread spectrum
modulation for use in applications to minimize radiated emissions. The spread spectrum
PLL output clock is frequency modulated so that the energy is spread over a wider
bandwidth, thereby reducing peak radiated emissions. Due to this feature support, the
associated lock time of this PLL is longer than other PLLs in the SoC that do not support
spread spectrum modulation.
Spread spectrum operation is controlled by configuring the
CCM_ANALOG_PLL_SYS_SS register. When enabled, the PLL output frequency will
decrease by the amount defined in the STEP field, until it reaches the limiting frequency
in the STOP field. The frequency will then similarly return to the original nominal
frequency. The following equations control the spread-spectrum operation:
Spread spectrum range = Fref  x
CCM_ANALOG_PLL_SYS_SS[STOP]
CCM_ANALOG_PLL_SYS_DENOM[B]
Modulation frequency = Fref  x
CCM_ANALOG_PLL_SYS_SS[STEP]
2  x  CCM_ANALOG_PLL_SYS_SS[STOP]
Although this PLL does have a DIV_SELECT register field, it is intended that this PLL
will only be run at the default frequency of 528 MHz.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
645

<!-- page 646 -->

18.5.1.3.4
Audio / Video PLL
The audio PLL and video PLL each synthesize a low jitter clock from a 24 MHz
reference clock. The clock output frequency range for this PLL is from 650 MHz to 1.3
GHz. It has a Fractional-N synthesizer.
There are /1, /2, /4, /8, /16 post dividers for the Video PLL and /1, /2, /4 , /8, /16 post
dividers for the Audio PLL. The output frequency can be set by programming the fields
in the CCM_ANALOG_PLL_AUDIO, CCM_ANALOG_PLL_VIDEO, and
CCM_ANALOG_MISC2 register sets according to the following equation.
PLL output frequency = Fref * (DIV_SELECT + NUM/DENOM)
18.5.1.3.5
Ethernet PLL
This PLL synthesizes a low jitter clock from the 24 MHz reference clock.
The reference clocks generated by this PLL are:
• ref_enetpll0 programmable to 25, 50, 100 and 125 MHz by setting
CCM_ANALOG_PLL_ENET[DIV_SELECT] bitfield
• ref_enetpll1 programmable to 25, 50, 100 and 125 MHz by setting
CCM_ANALOG_PLL_ENET[DIV_SELECT] bitfield
• ref_enetpll2 fixed at 25 MHz
18.5.1.4
Phase Fractional Dividers (PFD)
There are several PFD outputs from the System PLL and USB1 PLL.
Each PFD output generates a fractional multiplication of the associated PLL’s VCO
frequency. Where the output frequency is equal to Fvco*18/N, N can range from 12-35.
The PFDs allow for clock frequency changes without forcing the relock of the root PLL.
This feature is useful in support of dynamic voltage and frequency scaling (DVFS). See
CCM Analog Memory Map/Register Definition.
When the related PLL is powered up from the power down state or made to go through a
relock cycle due to PLL regrogramming, it is required that the related PFDx_CLKGATE
bit in CCM_ANALOG_PFD_480n or CCM_ANALOG_PFD_528n, be cycled on and off
(1 to 0) after PLL lock. The PFDs can be in the clock gated state during PLL relock but
must be un-clock gated only after lock is achieved. See the engineering bulletin,
Configuration of Phase Fractional Dividers (EB790) at www.nxp.com for procedure
details.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
646
NXP Semiconductors

<!-- page 647 -->

18.5.1.5
CCM internal clock generation
The clock generation is comprised of two sub-modules:
CCM_CLK_SWITCHER
CCM_CLK_ROOT_GEN
18.5.1.5.1
Clock Switcher
The Clock Switcher (CCM_CLK_SWITCHER) sub-module receives the PLL output
clocks and the PLL bypass clocks.
Figure 18-4 describes the generation of the three switcher clocks.
The figure also includes the Frequency Switch Control sub-module responsible for
frequency change.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
647

<!-- page 648 -->

1
0
24MHz
OSC
PLL1
(996M)
CCSR: step_sel
osc_clk
CCM_PLL3_BYP
(pll3 bypass clock)
CCSR: pll3_sw_clk_sel
pll3_main_clk
pll3_sw_clk
CCM 
switcher
PLL3 Bypass (from jtag)
1
0
2 bit divider
default=1
PLL_VIDEOn: POST_DIV_SELECT
2 bit divider
default=1
PLL_AUDIOn: POST_DIV_SELECT
2 bit divider
default=1
CCM_ANALOG_MISC2n: VIDEO_DIV
2 bit divider
default=1
CCM_ANALOG_MISC2n: MSB:LSB
PLL 4
PLL 5
pll4_main_clk
pll5_main_clk
1
0
1
0
secondary_clk
CCSR: secondary_clk_sel
pll1_main_clk
CCSR: pll1_sw_clk_sel
pll1_sw_clk
step_clk
PFD2: 400M
PFD3: 200M 
PFD0: 352M
PFD1: 594M
PLL 2
(528M)
PFD2: 508.2M
PFD3: 454.7M
PFD0: 720M
PFD1: 540M
PLL3
(480M)
pll2_main_clk
GLITCHLESS MUX
GLITCHLESS MUX
Figure 18-4. Switcher clock generation
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
648
NXP Semiconductors

<!-- page 649 -->

18.5.1.5.2
PLL bypass procedure
In addition to PLL bypass options in CCM_ANALOG module, switcher and
clk_root_gen sub-modules includes capability for each of the PLL clocks to be bypassed
with an external bypass clock.
18.5.1.5.3
PLL clock change
In order to modify or stop the clock output of a specific PLL, all the clocks generated
from the current PLL must be transitioned to the new PLL whose frequency is not being
modified.
For clocks which can't be stopped (core and bus clocks), this should be done via the
glitchless mux. Before changing the PLL setting, power it down. Power up the PLL after
the change. See Disabling / Enabling PLLs for more information.
18.5.1.5.4
Clock Root Generator
The Clock Root Generator (CCM_CLK_ROOT_GEN) sub-module generates the root
clocks to be delivered to LPCG.
The following figures describe clock generation. The frequencies in parantheses are the
default typical frequencies.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
649

<!-- page 650 -->

1
0
1
0
1
0
1
0
1
0
CBCDR: axi_alt_clk_sel
GLITCHLESS MUX
GLITCHLESS MUX
GLITCHLESS MUX
CBCDR: axi_clk_sel
3 bit divider
default=1
CBCDR: axi_podf
CBCDR: ahb_podf
CBCDR: ipg_podf
CBCDR: fabric_mmdc_podf
3 bit divider
default=1
cg
MMDC_CLK_ROOT
FABRIC_CLK_ROOT
3 bit divider
default=2
AXI_CLK_ROOT
1
0
2
1
0
CBCMR:
periph_clk2_sel
PLL3_sw_clk
burn_in_bist
OSC_CLK
PLL2_bypass_clk
CBCMR:
periph2_clk2_sel
PLL3_sw_clk
CBCDR: periph2_clk2_podf
OSC_CLK
1
0
2
3
3 bit divider
default=4
AHB_CLK_ROOT
CBCDR: periph_clk2_podf
CBCMR:
pre_periph_clk_sel
CBCDR:
periph_clk_sel
PLL_bypass_en2 (from jtag)
3 bit divider
default=2
IPG_CLK_ROOT
1
0
2
3
PLL4_main_clk
CBCMR:
pre_periph2_clk_sel
3 bit divider
default=1
CBCDR:
periph2_clk_sel
PLL_bypass_en2 (from jtag)
periph_clk
OSC_CLK
PLL2
PLL2
PFD2
PLL2
PFD0
PLL2
PFD2
/2
PLL2
PFD2
PLL3
PFD1
PLL2
PLL2
PFD2
PLL2
PFD0
Figure 18-5. BUS clock generation
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
650
NXP Semiconductors

<!-- page 651 -->

NOTE
All 6-bit PODF dividers found in the diagrams above can
operate on low frequency.
18.5.1.5.5
Initial values controlled by the System JTAG Controller (SJC).
The initial values of the following dividers and muxes can be controlled by SJC.
In regular functional mode, the SJC will drive the reset values stated in the CCM register
memory map. If SJC is programmed to change those values, then the reset value for those
dividers/muxes will be taken from the SJC programability.
Software can update the changed reset value after reset sequence. The control signals and
the dividers/muxes are listed below:
• [2:0] init_periph2_clk2_podf
• [1:0] init_ipg_podf
• [2:0] init_ahb_podf
• [2:0] init_axi_podf
• [2:0] init_periph_clk2_podf
• init_periph_clk_sel
• init_periph2_clk_sel
18.5.1.5.6
Divider change handshake
Modifying the following dividers will start the handshake with MMDC.
• mmdc_podf
• periph_clk_sel
• periph2_clk_sel
• arm_podf
• ahb_podf
The dividers listed above are designed with a handshake. For dividers without a
handshake design, the following sequence must be performed when updating PODF
value:
1. Gate the output clock off before updating PODF value.
2. Gate the output clock on after the PODF value is updated and stable.
To update the PODF value without gating the output clock off will cause unpredictable
results such as no clock output.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
651

<!-- page 652 -->

18.5.1.6
Disabling / Enabling PLLs
PLL disabling and enabling is done via analog module.
Before disabling a PLL using the analog registers, software should first move all the
clocks generated from that specific PLL to another source. This alternate source could be
another PLL, or a PFD driven by another PLL. Alternatively, software can bypass the
PLL and use the PLL reference clock (usually 24 MHz) as the output clock. Bypassing
the PLL is done by setting the analog BYPASS bit in the control register for that PLL.
18.5.1.7
Clock Switching Multiplexers
There are a multitude of multiplexers available throughout the clock generation logic that
provide alternate clock sources for the system clocks controlled by the CCM. The CCM
uses several synchronous glitchless clock multiplexers as well as asynchronous glitchy
clock multiplexers.
Synchronous muxes ensure there are no glitches between the transition of two
asynchronous clocks and that there will be no pulses that are of a frequency higher than
either input clock. For the synchronous multiplexer to work properly, both the current
clock and the clock to be selected must remain active during the entire selection process.
There are five glitchless (synchronous) muxes used in the CCM. The table below lists the
muxes and the respective control bits.
Table 18-5. Glitchless Multiplexers
Glitchless Mux
Mux Select Bit
Handshake Bit
periph_clk_mux
CBCDR[periph_clk_sel]
CDHIPR[periph_clk_sel_busy]
periph2_clk_mux
CBCDR[periph2_clk_sel]
CDHIPR[periph2_clk_sel_busy]
axi_alt_clk_mux
CBCDR[ axi_sel]
pll3_sw_clk_mux
CCSR[pll3_sw_clk_sel]
pll1_sw_clk_mux
CCSR[pll1_sw_clk_sel]
NOTE
Any change of the periph_clk_sel and periph2_clk_sel sync
mux select will involve handshake with the MMDC. Refer to
the CCDR and CDHIPR registers for the handshake bypass and
busy bits.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
652
NXP Semiconductors

<!-- page 653 -->

For critical system bus clocks, changing the clock source can be done in the CCM using
the glitchless clock muxes in Figure 18-5. In the figure, the thick bar on the input side
indicates the glitchless muxes. Those without the thick bar are regular muxes (not
glitchless).
For example, before disabling PLL2, software can switch the FABRIC_CLK_ROOT
away from the PLL2 or one of its PFDs by programming
CBCMR[PERIPH2_CLK2_SEL] and CBCDR[PERIPH2_CLK2_PODF] to provide an
appropriate frequency clock, then glitchlessly switch to it by programming
CBCDR[PERIPH2_CLK_SEL].
Asynchronous multiplexers or glitchy multiplexers, allow the clock to switch
immediately after the multiplexer select changed. This immediate switch of two
asynchronous clock domains can cause the output clock to glitch. Since both clock
sources to the mux are asynchronous, switching the clocks from one source to the other
can cause a glitch to be generated, regardless of the input clock source.
The output clocks to the mux are required to be gated before switching the source clock
in the CCM clock mux. If the output clocks are not gated, clock glitches can propagate to
the logic that follows the clock mux, causing the logic to behave unpredictably.
For serial clocks, software should first disable the module, then gate its clock in the
LPCG. Then it should move the mux controlling the source of the clocks to another PLL,
and reset the module and its clocks. Only then is it safe to disable the PLL. The mux for
the serial clocks is not glitchless.
18.5.1.8
Low Power Clock Gating module (LPCG)
The LPCG module receives the root clocks and splits them to clock branches for each
module. The clock branches are gated clocks.
The enables for those gates can come from four sources:
1. Clock enable signal from CCM - this signal is generated by configuring of the CGR
bits in the CCM. It is based on the low power mode.
2. Clock enable signal from the module - this signal is generated by the module based
on internal logic of the module. Not every enable signal from the module is used. For
used clock enable signals from the module, CCM will generate an override signal
based on a programable bit in CCM (CMEOR).
3. Clock enable signal from Reset controller (SRC) - this signal will enable the clock
during the reset procedure. Please see the SRC chapter for details on the clock enable
signal during reset procedure.
4. Hard-coded enable from fuse box.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
653

<!-- page 654 -->

These enable signals are ANDed to generate the enable signal for the gating cell.
The enable signal for the gating cell is synchronized with the clock it needs to gate in
order to prevent glitches on the gated clock.
Notifications are generated for CCM to indicate when clock roots should be opened and
closed. All notifications that correspond to the same clock root will be ORed to generate
one notification signal to CCM for clock root gating.
The following figure describes the clock split inside the LPCG module. It describes the
case of two modules; one module is without an enable signal and one is shown with an
enable signal. SRC enable signals and sync flip flops are omitted from this figure.
CGR
Module 1
CGR
Module 2
ov_clk_en
Module 2
CGM
LPCG
Module 1
Module 2
enable module 1 clock
clock_root
enable module 2 clock
clock enable from module 2
Gated clock for module 2
Gated clock for module 1
Figure 18-6. Clock split in LPCG
18.5.1.9
MMDC handshake
CCM will assert the mmdc_freq_change_req signal.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
654
NXP Semiconductors

<!-- page 655 -->

MMDC will assert the mmdc_freq_change_ack signals to acknowledge that the
frequency change request has been received and that the frequency can now be changed
safely.
CCM will commence the actual change of division ratio of mmdc dividers or apply mux
change on root clocks once both of the non-masked acknowledges are asserted.
NOTE
MMDC handshakes can be masked.
NOTE
Set register CCDR[17] to 1 before beginning any operation that
initiates a handshake. It is acceptable to program and leave this
override bit asserted.
18.5.2
DVFS support
When performing DVFS, the frequency shift procedure for the ARM core clock domain
can be performed by software.
CPU PLL frequency and CCM ARM clock divider is controlled by CCM and CPU power
domain supply voltage value is controlled by CCM_ANALOG module.
NOTE
The frequency should be shifted down first and then voltage
value reduced, and vice-versa, when shifting the frequency up.
NOTE
CCM_ANALOG will not control the voltage value in Bypass
mode
18.5.3
Power modes
The chip supports 3 low power modes: RUN mode, WAIT mode, STOP mode.
18.5.3.1
RUN mode
This is the normal/functional operating mode. In this mode, the CPU runs in its normal
operational mode. Clocks to the modules can be gated by configuring the corresponding
CCGRx bits.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
655

<!-- page 656 -->

18.5.3.2
WAIT mode
In this mode the CPU clock is gated. All other clocks are functional and can be gated by
programming their CGR bits when all ARM cores are in WFI, and L2 cache and SCU are
idle.
18.5.3.2.1
Entering WAIT mode
If the CLPCR[LPM] bit is set by software to WAIT mode, when CPU executes the next
wait for interrupt (WFI) instruction, WAIT mode sequence will start.
As part of the WFI routine, alternative interrupt controller in GPC should be updated; the
CPU platform interrupt controller will be disabled first by software and will be not
functional, due to clock gating. Interrupts during WAIT mode are monitored by
alternative interrupt controller.
After execution of the WFI routine, the CPU platform will assert idle signals for each
component of the platform and CCM will gate clock to the platform.
The next actions can be programmed during WAIT mode:
1. CCM requests an acknowledge to close clocks to MMDC if its CGR bits indicate to
close its clocks on WAIT mode, and if those clocks are not already closed in run
mode. The request will be issued if the handshake is not bypassed by programing the
CLPCR register. If the corresponding bits are set, the request signal will not be
issued to the corresponding module and CCM will not wait for its acknowledge in
the process of entering low power mode. Once CCM receives all the acknowledge
signals needed, then it will enter WAIT mode.
2. Close the clocks to the modules which were defined to be shut at WAIT mode in the
CCGR bits.
3. Observability to indicate WAIT mode.
NOTE
Setting MMDC CGR bits to 01 can hang the entire system since
the MMDC clock and fabric clock share the same clock root.
Any enabled interrupt assertion will start the exit from WAIT mode.
18.5.3.2.2
Exiting WAIT mode
As soon as enabled interrupt is asserted, CPU supply will be restored if CPU SRPG was
applied and clocks are enabled to CPU and other modules.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
656
NXP Semiconductors

<!-- page 657 -->

18.5.3.3
STOP mode
In this mode all system clocks are stopped, along with the CPU, system buses and all
PLLs. Power gating can be applied for ARM platform. External supply voltage can be
reduced to decrease leakage.
18.5.3.3.1
Entering STOP mode
Procedure entering STOP mode is the same, as entering WAIT mode until the moment of
disabling clocks to modules. (LPM bit should be configured to STOP mode.)
After clocks to modules are gated, the following actions will be taken:
• PLLs are disabled
• CCM_PMIC_STBY_REQ asserted, if vstby bit is set
• osc_en signal is negated
• osc_pwrdn is asserted, if sbyos bit is set
Counter will be triggered after CCM_PMIC_STBY_REQ assertion to allow to external
regulator or PMIC to decrease voltage until valid voltage range. On counter completion,
stop_mode signal will be asserted, that will trigger disabling analog elements in anatop.
CCM's low power state machine will remain in state STOP_GPC until STOP mode is
exited.
18.5.3.3.2
Exiting STOP mode
As soon as an enabled interrupt is asserted, the CCM will begin the process of exiting
STOP mode.
The following will take place:
1. If vstby bit was set, deassert PMIC_STBY_REQ to notify power management IC to
change voltage from standby voltage to functional voltage.
2. If sbyos was set, and CCM closed either external oscillator or on board oscillator,
then CCM will start oscillator by asserting ref_en_b signal and deasserting
cosc_pwrdown signal respectively.
3. After the number of cycles of CKILs defined in stby_count bits, wait until PMIC
functional voltage is ready. This is the notification from power management IC that
the voltage is ready at its functional value. Only then will CCM continue the steps.
4. Start osc. If oscillator was started, wait until oscnt has finished its counting to make
sure that oscillator is ready.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
657

<!-- page 658 -->

5. Start PLLs. Only the PLLs that were configured to be on prior to the entrance to
STOP mode will be started.
6. CCM will request GPC to restore ARM power by GPC_PUP_REQ. If power was
removed from the ARM platform, GPC will notify CCM by asserting signal
GPC_PUP_ACK that power to ARM is back on, and its safe to exit from STOP
mode. Only then will the CCM progress to the next step.
7. Once assertion of notification from src that the resets for the power gated modules
has been finished, (src_power_gating_reset_done is set) negate the low power
request signals to all modules and enable all module clocks including ARM clocks
and CKIL sync, and return to run mode. (Clocks whose CCGR bits are not to be
opened in RUN mode will not be opened; they will continued to be gated.)
Once the system is in run mode, negate signals ccm_ipg_stop and system_in_stop_mode.
18.6
CCM Memory Map/Register Definition
NOTE
The register reset values for CCM change depending on the
boot configuration. See Clocks at boot time for more
information.
CCM memory map
Absolute
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
20C_4000
CCM Control Register (CCM_CCR)
32
R/W
0401_167Fh
18.6.1/660
20C_4004
CCM Control Divider Register (CCM_CCDR)
32
R/W
18.6.2/661
20C_4008
CCM Status Register (CCM_CSR)
32
R
0000_0010h
18.6.3/663
20C_400C
CCM Clock Switcher Register (CCM_CCSR)
32
R/W
0000_0100h
18.6.4/664
20C_4010
CCM Arm Clock Root Register (CCM_CACRR)
32
R/W
0000_0000h
18.6.5/665
20C_4014
CCM Bus Clock Divider Register (CCM_CBCDR)
32
R/W
0001_8D00h
18.6.6/666
20C_4018
CCM Bus Clock Multiplexer Register (CCM_CBCMR)
32
R/W
2486_0324h
18.6.7/669
20C_401C
CCM Serial Clock Multiplexer Register 1 (CCM_CSCMR1)
32
R/W
0490_0080h
18.6.8/670
20C_4020
CCM Serial Clock Multiplexer Register 2 (CCM_CSCMR2)
32
R/W
0319_2C06h
18.6.9/673
20C_4024
CCM Serial Clock Divider Register 1 (CCM_CSCDR1)
32
R/W
0049_0B00h
18.6.10/
674
20C_4028
CCM SAI1 Clock Divider Register (CCM_CS1CDR)
32
R/W
0EC1_02C1h
18.6.11/
676
20C_402C
CCM SAI2 Clock Divider Register (CCM_CS2CDR)
32
R/W
0003_36C1h
18.6.12/
678
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
658
NXP Semiconductors

<!-- page 659 -->

CCM memory map (continued)
Absolute
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
20C_4030
CCM D1 Clock Divider Register (CCM_CDCDR)
32
R/W
33F7_1F92h
18.6.13/
680
20C_4034
CCM HSC Clock Divider Register (CCM_CHSCCDR)
32
R/W
0002_9148h
18.6.14/
681
20C_4038
CCM Serial Clock Divider Register 2 (CCM_CSCDR2)
32
R/W
0002_9B48h
18.6.15/
682
20C_403C
CCM Serial Clock Divider Register 3 (CCM_CSCDR3)
32
R/W
0001_4841h
18.6.16/
684
20C_4048
CCM Divider Handshake In-Process Register
(CCM_CDHIPR)
32
R
0000_0000h
18.6.17/
685
20C_4054
CCM Low Power Control Register (CCM_CLPCR)
32
R/W
0000_0079h
18.6.18/
688
20C_4058
CCM Interrupt Status Register (CCM_CISR)
32
w1c
0000_0000h
18.6.19/
690
20C_405C
CCM Interrupt Mask Register (CCM_CIMR)
32
R/W
FFFF_FFFFh
18.6.20/
693
20C_4060
CCM Clock Output Source Register (CCM_CCOSR)
32
R/W
000A_0001h
18.6.21/
695
20C_4064
CCM General Purpose Register (CCM_CGPR)
32
R/W
0000_FE62h
18.6.22/
697
20C_4068
CCM Clock Gating Register 0 (CCM_CCGR0)
32
R/W
FFFF_FFFFh
18.6.23/
698
20C_406C
CCM Clock Gating Register 1 (CCM_CCGR1)
32
R/W
FFFF_FFFFh
18.6.24/
700
20C_4070
CCM Clock Gating Register 2 (CCM_CCGR2)
32
R/W
FC3F_FFFFh
18.6.25/
702
20C_4074
CCM Clock Gating Register 3 (CCM_CCGR3)
32
R/W
FFFF_FFFFh
18.6.26/
703
20C_4078
CCM Clock Gating Register 4 (CCM_CCGR4)
32
R/W
FFFF_FFFFh
18.6.27/
704
20C_407C
CCM Clock Gating Register 5 (CCM_CCGR5)
32
R/W
FFFF_FFFFh
18.6.28/
706
20C_4080
CCM Clock Gating Register 6 (CCM_CCGR6)
32
R/W
FFFF_FFFFh
18.6.29/
707
20C_4088
CCM Module Enable Overide Register (CCM_CMEOR)
32
R/W
FFFF_FFFFh
18.6.30/
709
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
659

<!-- page 660 -->

18.6.1
CCM Control Register (CCM_CCR)
The figure below represents the CCM Control Register (CCR), which contains bits to
control general operation of CCM. The table below provides its field descriptions.
Address: 20C_4000h base + 0h offset = 20C_4000h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
RBC_EN
REG_BYPASS_COUNT
0
W
Reset
0
0
0
0
0
1
0
0
0
0
0
0
0
0
0
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
COSC_EN
0
OSCNT
W
Reset
0
0
0
1
0
1
1
0
0
1
1
1
1
1
1
1
CCM_CCR field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27
RBC_EN
Enable for REG_BYPASS_COUNTER. If enabled, analog_reg_bypass signal will be asserted after
REG_BYPASS_COUNT clocks of CKIL, after standby voltage is requested. If standby voltage is not
requested analog_reg_bypass won't be asserted, event if counter is enabled.
1
REG_BYPASS_COUNTER enabled.
0
REG_BYPASS_COUNTER disabled
26–21
REG_BYPASS_
COUNT
Counter for analog_reg_bypass signal assertion after standby voltage request by PMIC_STBY_REQ.
Should be zeroed and reconfigured after exit from low power mode.
REG_BYPASS_COUNT can also be used for holding off interrupts when the PGC unit is sending signals
to power gate the core.
000000
no delay
000001
1 CKIL clock period delay
111111
63 CKIL clock periods delay
20–13
Reserved
This read-only field is reserved and always has the value 0.
12
COSC_EN
On chip oscillator enable bit - this bit value is reflected on the output cosc_en. The system will start with on
chip oscillator enabled to supply source for the PLLs. Software can change this bit if a transition to the
bypass PLL clocks was performed for all the PLLs. In cases that this bit is changed from '0' to '1' then
CCM will enable the on chip oscillator and after counting oscnt ckil clock cycles it will notify that on chip
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
660
NXP Semiconductors

<!-- page 661 -->

CCM_CCR field descriptions (continued)
Field
Description
oscillator is ready by a interrupt cosc_ready and by status bit cosc_ready. The cosc_en bit should be
changed only when on chip oscillator is not chosen as the clock source.
0
disable on chip oscillator
1
enable on chip oscillator
11–7
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
OSCNT
Oscillator ready counter value. These bits define value of 32KHz counter, that serve as counter for
oscillator lock time. This is used for oscillator lock time. Current estimation is ~5ms. This counter will be
used in ignition sequence and in wake from stop sequence if sbyos bit was defined, to notify that on chip
oscillator output is ready for the dpll_ip to use and only then the gate in dpll_ip can be opened.
0000000
count 1 ckil
1111111
count 128 ckil's
18.6.2
CCM Control Divider Register (CCM_CCDR)
The figure below represents the CCM Control Divider Register (CCDR), which contains
bits that control the loading of the dividers that need handshake with the modules they
affect. The table below provides its field descriptions.
Address: 20C_4000h base + 4h offset = 20C_4004h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
MMDC_CH0_
MASK
MMDC_CH1_
MASK
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
661

<!-- page 662 -->

CCM_CCDR field descriptions
Field
Description
31–18
Reserved
This read-only field is reserved and always has the value 0.
17
MMDC_CH0_
MASK
During divider ratio mmdc_ch0_axi_podf change or sync mux periph_clk_sel change (but not jtag) or SRC
request during warm reset, mask handshake with mmdc_ch0 module.
0
allow handshake with mmdc_ch0 module
1
mask handshake with mmdc_ch0. Request signal will not be generated.
16
MMDC_CH1_
MASK
During divider ratio mmdc_ch1_axi_podf change or sync mux periph2_clk_sel change (but not jtag) or
SRC request during warm reset, mask handshake with mmdc_ch1 module.
0
Allow handshake with mmdc_ch1 module.
1
Mask handshake with mmdc_ch1. Request signal will not be generated.
Reserved
This read-only field is reserved and always has the value 0.
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
662
NXP Semiconductors

<!-- page 663 -->

18.6.3
CCM Status Register (CCM_CSR)
The figure below represents the CCM status Register (CSR). The status bits are read-only
bits. The table below provides its field descriptions.
Address: 20C_4000h base + 8h offset = 20C_4008h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
COSC_READY
1
0
REF_EN_B
W
Reset
0
0
0
0
0
0
0
0
0
0
0
1
0
0
0
0
CCM_CSR field descriptions
Field
Description
31–6
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
663

<!-- page 664 -->

CCM_CSR field descriptions (continued)
Field
Description
5
COSC_READY
Status indication of on board oscillator. This bit will be asserted if on chip oscillator is enabled and on chip
oscillator is not powered down, and if oscnt counter has finished counting.
0
on board oscillator is not ready.
1
on board oscillator is ready.
4
Reserved
This read-only field is reserved and always has the value 1.
3–1
Reserved
This read-only field is reserved and always has the value 0.
0
REF_EN_B
Status of the value of CCM_REF_EN_B output of ccm
0
value of CCM_REF_EN_B is '0'
1
value of CCM_REF_EN_B is '1'
18.6.4
CCM Clock Switcher Register (CCM_CCSR)
The figure below represents the CCM Clock Switcher register (CCSR). The CCSR
register contains bits to control the switcher sub-module dividers and multiplexers. The
table below provides its field descriptions.
Address: 20C_4000h base + Ch offset = 20C_400Ch
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
STEP_SEL
0
SECONDARY_CLK_SEL
PLL1_SW_CLK_SEL
Reserved
PLL3_SW_CLK_SEL
W
Reset
0
0
0
0
0
0
0
1
0
0
0
0
0
0
0
0
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
664
NXP Semiconductors

<!-- page 665 -->

CCM_CCSR field descriptions
Field
Description
31–9
Reserved
This read-only field is reserved and always has the value 0.
8
STEP_SEL
Selects the option to be chosen for the step frequency when shifting ARM frequency. This will control the
step_clk.
NOTE: This mux is allowed to be changed only if its output is not used, i.e. ARM uses the output of pll1,
and step_clk is not used.
0
derive clock from osc_clk (24M) - source for lp_apm.
1
derive clock from secondary_clk
7–4
Reserved
This read-only field is reserved and always has the value 0.
3
SECONDARY_
CLK_SEL
Select source to generate secondary_clk
0
PLL2 PFD2 (400 M)
1
PLL2 (528 M)
2
PLL1_SW_CLK_
SEL
Selects source to generate pll1_sw_clk.
0
pll1_main_clk
1
step_clk
1
-
This field is reserved.
Reserved
0
PLL3_SW_CLK_
SEL
Selects source to generate pll3_sw_clk. This bit should only be used for testing purposes.
0
pll3_main_clk
1
pll3 bypass clock
18.6.5
CCM Arm Clock Root Register (CCM_CACRR)
The figure below represents the CCM Arm Clock Root register (CACRR). The CACRR
register contains bits to control the ARM clock root generation. The table below provides
its field descriptions.
Address: 20C_4000h base + 10h offset = 20C_4010h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
ARM_
PODF
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
665

<!-- page 666 -->

CCM_CACRR field descriptions
Field
Description
31–3
Reserved
This read-only field is reserved and always has the value 0.
ARM_PODF
Divider for ARM clock root.
NOTE: If arm_freq_shift_divider is set to '1' then any new write to arm_podf will be held until
arm_clk_switch_req signal is asserted.
NOTE: arm_podf should be >= 3 if fuse bit CPU_SPEED_LIMIT is set.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
18.6.6
CCM Bus Clock Divider Register (CCM_CBCDR)
The figure below represents the CCM Bus Clock Divider Register (CBCDR). The
CBCDR register contains bits to control the clock generation sub module dividers. The
table below provides its field descriptions.
Address: 20C_4000h base + 14h offset = 20C_4014h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
PERIPH_CLK2_
PODF
PERIPH2_CLK_
SEL
PERIPH_CLK_
SEL
Reserved
AXI_PODF
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
AHB_PODF
IPG_PODF
AXI_
ALT_
SEL
AXI_
SEL
FABRIC_MMDC_
PODF
PERIPH2_CLK2_
PODF
W
Reset
1
0
0
0
1
1
0
1
0
0
0
0
0
0
0
0
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
666
NXP Semiconductors

<!-- page 667 -->

CCM_CBCDR field descriptions
Field
Description
31–30
-
This field is reserved.
Reserved
29–27
PERIPH_CLK2_
PODF
Divider for periph_clk2_podf.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
26
PERIPH2_CLK_
SEL
Selector for peripheral2 main clock (source of mmdc_clk_root).
NOTE: Any change of this mux select will involve handshake with the MMDC. Refer to the CCDR and
CDHIPR registers for the handshake bypass and busy bits.
0
PLL2 (pll2_main_clk)
1
derive clock from periph2_clk2_clk clock source.
25
PERIPH_CLK_
SEL
Selector for peripheral main clock.
NOTE: Alternative clock source should be used when PLL is relocked. For PLL relock procedure pls refer
to the PLL chapter.
NOTE: Any change of this sync mux select will involve handshake with the MMDC. Refer to the CCDR
and CDHIPR registers for the handshake bypass and busy bits.
0
PLL2 (pll2_main_clk)
1
derive clock from periph_clk2_clk clock source.
24–19
-
This field is reserved.
Reserved
18–16
AXI_PODF
Divider for axi podf.
NOTE: Any change of this divider might involve handshake with EMI. See CDHIPR register for the
handshake busy bits.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
15–13
-
This field is reserved.
Reserved
12–10
AHB_PODF
Divider for AHB PODF.
NOTE: Any change of this divider might involve handshake with EMI. See CDHIPR register for the
handshake busy bits.
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
667

<!-- page 668 -->

CCM_CBCDR field descriptions (continued)
Field
Description
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
9–8
IPG_PODF
Divider for ipg podf.
NOTE: SDMA module will not support ratio of 1:3 and 1:4 for ahb_clk:ipg_clk. In case SDMA is used,
then those ratios should not be used.
00
divide by 1
01
divide by 2
10
divide by 3
11
divide by 4
7
AXI_ALT_SEL
AXI alternative clock select
0
PLL2 PFD2 will be selected as alternative clock for AXI root clock
1
PLL3 PFD1 will be selected as alternative clock for AXI root clock
6
AXI_SEL
AXI clock source select
0
Periph_clk output will be used as AXI clock root
1
AXI alternative clock will be used as AXI clock root
5–3
FABRIC_MMDC_
PODF
Post divider for fabric / mmdc clock.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
PERIPH2_CLK2_
PODF
Divider for periph2_clk2 podf.
NOTE: Divider should be updated when output clock is gated.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
668
NXP Semiconductors

<!-- page 669 -->

18.6.7
CCM Bus Clock Multiplexer Register (CCM_CBCMR)
The figure below represents the CCM Bus Clock Multiplexer Register (CBCMR). The
CBCMR register contains bits to control the multiplexers that generate the bus clocks.
The table below provides its field descriptions.
NOTE
Any change on the above multiplexer will have to be done
while the module that its clock is affected is not functional and
the respective clock is gated in LPCG. If the change will be
done during operation of the module, then it is not guaranteed
that the modules operation will not be harmed.
The change for arm_clk_sel should be done through sdma so that ARM will not use this
clock during the change and the clock will be gated in LPCG.
Address: 20C_4000h base + 18h offset = 20C_4018h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
LCDIF1_PODF
PRE_
PERIPH2_
CLK_SEL
PERIPH2_CLK2_
SEL
PRE_
PERIPH_
CLK_SEL
Reserved
W
Reset
0
0
1
0
0
1
0
0
1
0
0
0
0
1
1
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
PERIPH_
CLK2_SEL
Reserved
W
Reset
0
0
0
0
0
0
1
1
0
0
1
0
0
1
0
0
CCM_CBCMR field descriptions
Field
Description
31–26
-
This field is reserved.
Reserved
25–23
LCDIF1_PODF
Post-divider for LCDIF1 clock.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
669

<!-- page 670 -->

CCM_CBCMR field descriptions (continued)
Field
Description
101
divide by 6
110
divide by 7
111
divide by 8
22–21
PRE_PERIPH2_
CLK_SEL
Selector for pre_periph2 clock multiplexer
00
derive clock from PLL2
01
derive clock from PLL2 PFD2
10
derive clock from PLL2 PFD0
11
derive clock from PLL4
20
PERIPH2_CLK2_
SEL
Selector for periph2_clk2 clock multiplexer
0
derive clock from pll3_sw_clk
1
derive clock fromOSC
19–18
PRE_PERIPH_
CLK_SEL
Selector for pre_periph clock multiplexer
00
derive clock from PLL2
01
derive clock from PLL2 PFD2
10
derive clock from PLL2 PFD0
11
derive clock from divided (/2) PLL2 PFD2
17–14
-
This field is reserved.
Reserved
13–12
PERIPH_CLK2_
SEL
Selector for peripheral clk2 clock multiplexer
00
derive clock from pll3_sw_clk
01
derive clock from osc_clk (pll1_ref_clk)
10
derive clock from pll2_bypass_clk
11
reserved
-
This field is reserved.
Reserved
18.6.8
CCM Serial Clock Multiplexer Register 1 (CCM_CSCMR1)
The figure below represents the CCM Serial Clock Multiplexer Register 1 (CSCMR1).
The CSCMR1 register contains bits to control the multiplexers that generate the serial
clocks. The table below provides its field descriptions.
NOTE
Any change on the above multiplexer will have to be done
while the module that its clock is affected is not functional and
the clock is gated. If the change will be done during operation
of the module, then it is not guaranteed that the modules
operation will not be harmed.
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
670
NXP Semiconductors

<!-- page 671 -->

Address: 20C_4000h base + 1Ch offset = 20C_401Ch
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
ACLK_EIM_
SLOW_SEL
QSPI1_PODF
ACLK_EIM_SLOW_
PODF
Reserved
GPMI_CLK_SEL
BCH_CLK_SEL
USDHC2_CLK_
SEL
USDHC1_CLK_
SEL
W
Reset
0
0
0
0
0
1
0
0
1
0
0
1
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
SAI3_CLK_
SEL
SAI2_CLK_
SEL
SAI1_CLK_
SEL
QSPI1_CLK_SEL
PERCLK_CLK_
SEL
PERCLK_PODF
W
Reset
0
0
0
0
0
0
0
0
1
0
0
0
0
0
0
0
CCM_CSCMR1 field descriptions
Field
Description
31
Reserved
This read-only field is reserved and always has the value 0.
30–29
ACLK_EIM_
SLOW_SEL
Selector for aclk_eim_slow root clock multiplexer
00
derive clock from AXI
01
derive clock from pll3_sw_clk
10
derive clock from PLL2 PFD2
11
derive clock from PLL3 PFD0
28–26
QSPI1_PODF
Divider for QSPI1 clock root
000
divide by 1
001
divide by 2
111
divide by 8
25–23
ACLK_EIM_
SLOW_PODF
Divider for aclk_eim_slow clock root.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
22–20
-
This field is reserved.
Reserved
19
GPMI_CLK_SEL
Selector for gpmi clock multiplexer
0
derive clock from PLL2 PFD2
1
derive clock from PLL2 PFD0
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
671

<!-- page 672 -->

CCM_CSCMR1 field descriptions (continued)
Field
Description
18
BCH_CLK_SEL
Selector for bch clock multiplexer
0
derive clock from PLL2 PFD2
1
derive clock from PLL2 PFD0
17
USDHC2_CLK_
SEL
Selector for usdhc2 clock multiplexer
0
derive clock from PLL2 PFD2
1
derive clock from PLL2 PFD0
16
USDHC1_CLK_
SEL
Selector for usdhc1 clock multiplexer
0
derive clock from PLL2 PFD2
1
derive clock from PLL2 PFD0
15–14
SAI3_CLK_SEL
Selector for sai3 clock multiplexer
00
derive clock from PLL3 PFD2
01
derive clock from PLL5
10
derive clock from PLL4
11
Reserved
13–12
SAI2_CLK_SEL
Selector for sai2 clock multiplexer
00
derive clock from PLL3 PFD2
01
derive clock from PLL5
10
derive clock from PLL4
11
Reserved
11–10
SAI1_CLK_SEL
Selector for sai1 clock multiplexer
00
derive clock from PLL3 PFD2
01
derive clock from PLL5
10
derive clock from PLL4
11
Reserved
9–7
QSPI1_CLK_SEL
QSPI1 clock select
000
Derive clock from PLL3
001
Derive clock from PLL2 PFD0
010
Derive clock from PLL2 PFD2
011
Derive clock from PLL2
100
Derive clock from PLL3 PFD3
101
Derive clock from PLL3 PFD2
6
PERCLK_CLK_
SEL
Selector for the perclk clock multiplexor
0
derive clock from ipg clk root
1
derive clock from osc_clk
PERCLK_PODF Divider for perclk podf.
000000
divide by 1
000001
divide by 2
000010
divide by 3
000011
divide by 4
000100
divide by 5
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
672
NXP Semiconductors

<!-- page 673 -->

CCM_CSCMR1 field descriptions (continued)
Field
Description
000101
divide by 6
000110
divide by 7
111111
divide by 64
18.6.9
CCM Serial Clock Multiplexer Register 2 (CCM_CSCMR2)
The figure below represents the CCM Serial Clock Multiplexer Register 2 (CSCMR2).
The CSCMR2 register contains bits to control the multiplexers that generate the serial
clocks. The table below provides its field descriptions.
NOTE
Any change on the above multiplexer will have to be done
while the module that its clock is affected is not functional and
the clock is gated. If the change will be done during operation
of the module, then it is not guaranteed that the modules
operation will not be harmed.
Address: 20C_4000h base + 20h offset = 20C_4020h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
ESAI_CLK_
SEL
Reserved
W
Reset
0
0
0
0
0
0
1
1
0
0
0
1
1
0
0
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
LDB_
DI1_
DIV
LDB_
DI0_
DIV
CAN_CLK_
SEL
CAN_CLK_PODF
Reserved
W
Reset
0
0
1
0
1
1
0
0
0
0
0
0
0
1
1
0
CCM_CSCMR2 field descriptions
Field
Description
31–21
-
This field is reserved.
Reserved
20–19
ESAI_CLK_SEL
Selector for the ESAI clock
00
derive clock from PLL4 divided clock
01
derive clock from PLL3 PFD2 clock
10
derive clock from PLL5 clock
11
derive clock from pll3_sw_clk
18–12
-
This field is reserved.
Reserved
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
673

<!-- page 674 -->

CCM_CSCMR2 field descriptions (continued)
Field
Description
11
LDB_DI1_DIV
Control for divider of ldb clock for di1
0
divide by 3.5
1
divide by 7
10
LDB_DI0_DIV
Control for divider of ldb clock for di0
0
divide by 3.5
1
divide by 7
9–8
CAN_CLK_SEL
Selector for FlexCAN clock multiplexer
00
derive clock from pll3_sw_clk divided clock (60M)
01
derive clock from osc_clk (24M)
10
derive clock from pll3_sw_clk divided clock (80M)
11
Disable FlexCAN clock
7–2
CAN_CLK_
PODF
Divider for can clock podf.
000000
divide by 1
...
000111
divide by 8
...
111111
divide by 2^6
-
This field is reserved.
Reserved
18.6.10
CCM Serial Clock Divider Register 1 (CCM_CSCDR1)
The figure below represents the CCM Serial Clock Divider Register 1 (CSCDR1). The
CSCDR1 register contains bits to control the clock generation sub-module dividers. The
table below provides its field descriptions.
NOTE
Any change on the above dividers will have to be done while
the module that its clock is affected is not functional and the
affected clock is gated. If the change will be done during
operation of the module, then it is not guaranteed that the
modules operation will not be harmed.
Address: 20C_4000h base + 24h offset = 20C_4024h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
Reserved
GPMI_PODF
BCH_PODF
USDHC2_PODF
W
Reset
0
0
0
0
0
0
0
0
0
1
0
0
1
0
0
1
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
674
NXP Semiconductors

<!-- page 675 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
USDHC1_PODF
Reserved
UART_CLK_
SEL
UART_CLK_PODF
W
Reset
0
0
0
0
1
0
1
1
0
0
0
0
0
0
0
0
CCM_CSCDR1 field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27–25
-
This field is reserved.
Reserved
24–22
GPMI_PODF
Divider for gpmi clock pred.
NOTE: Divider should be updated when output clock is gated.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
21–19
BCH_PODF
Divider for bch clock podf.
NOTE: Divider should be updated when output clock is gated.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
18–16
USDHC2_PODF
Divider for usdhc2 clock.
NOTE: Divider should be updated when output clock is gated.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
675

<!-- page 676 -->

CCM_CSCDR1 field descriptions (continued)
Field
Description
15–14
-
This field is reserved.
Reserved
13–11
USDHC1_PODF
Divider for usdhc1 clock podf.
NOTE: Divider should be updated when output clock is gated.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
10–7
-
This field is reserved.
Reserved.
6
UART_CLK_SEL
Selector for the UART clock multiplexor
0
derive clock from pll3_80m
1
derive clock from osc_clk
UART_CLK_
PODF
Divider for uart clock podf.
000000
divide by 1
111111
divide by 2^6
18.6.11
CCM SAI1 Clock Divider Register (CCM_CS1CDR)
The figure below represents the CCM SAI1, and SAI3 Clock Divider Register
(CS1CDR). The CS1CDR register contains bits to control the SAI1 and SAI3 clock
generation dividers. The table below provides its field descriptions.
Address: 20C_4000h base + 28h offset = 20C_4028h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
ESAI_
CLK_
PODF
SAI3_
CLK_
PRED
SAI3_CLK_PODF
0
ESAI_
CLK_
PRED
SAI1_
CLK_
PRED
SAI1_CLK_PODF
W
Reset 0
0
0
0
1
1
1
0
1
1
0
0
0
0
0
1
0
0
0
0
0
0
1
0
1
1
0
0
0
0
0
1
CCM_CS1CDR field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
676
NXP Semiconductors

<!-- page 677 -->

CCM_CS1CDR field descriptions (continued)
Field
Description
27–25
ESAI_CLK_
PODF
Divider for ESAI clock
000
Divide by 1
001
Divide by 2
010
Divide by 3
011
Divide by 4
100
Divide by 5
101
Divide by 6
110
Divide by 7
111
Divide by 8
24–22
SAI3_CLK_
PRED
Divider for sai3 clock pred.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
21–16
SAI3_CLK_
PODF
Divider for sai3 clock podf.
The input clock to this divider should be lower than 300Mhz, the predivider can be used to achieve this.
000000
divide by 1
111111
divide by 2^6
15–12
Reserved
This read-only field is reserved and always has the value 0.
11–9
ESAI_CLK_
PRED
Divider for ESAI clock pred
000
Divide by 1
001
Divide by 2
010
Divide by 3
011
Divide by 4
100
Divide by 5
101
Divide by 6
110
Divide by 7
111
Divide by 8
8–6
SAI1_CLK_
PRED
Divider for sai1 clock pred.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
677

<!-- page 678 -->

CCM_CS1CDR field descriptions (continued)
Field
Description
SAI1_CLK_
PODF
Divider for sai1 clock podf.
The input clock to this divider should be lower than 300Mhz, the predivider can be used to achieve this.
000000
divide by 1
111111
divide by 2^6
18.6.12
CCM SAI2 Clock Divider Register (CCM_CS2CDR)
The figure below represents the CCM SAI2, LDB Clock Divider Register (CS2CDR).
The CS2CDR register contains bits to control the SAI2 clock generation dividers, and ldb
serial clocks select. The table below provides its field descriptions.
Address: 20C_4000h base + 2Ch offset = 20C_402Ch
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
ENFC_CLK_PODF
ENFC_
CLK_
PRED
ENFC_
CLK_SEL Reserved
LDB_
DI0_
CLK_SEL
SAI2_
CLK_
PRED
SAI2_CLK_PODF
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
1
0
0
1
1
0
1
1
0
1
1
0
0
0
0
0
1
CCM_CS2CDR field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 0.
26–21
ENFC_CLK_
PODF
Divider for enfc clock divider.
000000
divide by 1
000001
divide by 2
111111
divide by 2^6
20–18
ENFC_CLK_
PRED
Divider for enfc clock pred divider.
NOTE: Divider should be updated when output clock is gated.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
678
NXP Semiconductors

<!-- page 679 -->

CCM_CS2CDR field descriptions (continued)
Field
Description
17–15
ENFC_CLK_SEL Selector for enfc clock multiplexer
NOTE: Multiplexor should be updated when output clock is gated.
000
derive clock from PLL2 PFD0
001
derive clock from PLL2
010
derive clock from pll3_sw_clk
011
derive clock from PLL2 PFD2
100
derive clock from PLL3 PFD3
101
Reserved
110
derive clock from PLL3 PFD3
111
Reserved
14–12
-
This field is reserved.
Reserved
11–9
LDB_DI0_CLK_
SEL
Selector for ldb_di0 clock multiplexer
NOTE: Multiplexor should be updated when both input and output clocks are gated.
000
PLL5 clock
001
PLL2 PFD0
010
PLL2 PFD2
011
PLL2 PFD3
100
PLL2 PFD1
101
PLL3 PFD3
110
Reserved
111
Reserved
8–6
SAI2_CLK_
PRED
Divider for sai2 clock pred.
NOTE: Divider should be updated when output clock is gated.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
SAI2_CLK_
PODF
Divider for sai2 clock podf.
The input clock to this divider should be lower than 300Mhz, the predivider can be used to achieve this.
NOTE: Divider should be updated when output clock is gated.
000000
divide by 1
111111
divide by 2^6
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
679

<!-- page 680 -->

18.6.13
CCM D1 Clock Divider Register (CCM_CDCDR)
The figure below represents the CCM DI Clock Divider Register (CDCDR). The table
below provides its field descriptions.
Address: 20C_4000h base + 30h offset = 20C_4030h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
SPDIF0_CLK_PRED SPDIF0_CLK_PODF
SPDIF0_
CLK_SEL
Reserved
W
Reset
0
0
1
1
0
0
1
1
1
1
1
1
0
1
1
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
W
Reset
0
0
0
1
1
1
1
1
1
0
0
1
0
0
1
0
CCM_CDCDR field descriptions
Field
Description
31–28
-
This field is reserved.
Reserved
0
derive from pll3_120M clock
1
derive clock from PLL2 PFD2
27–25
SPDIF0_CLK_
PRED
Divider for spdif0 clock pred.
NOTE: Divider should be updated when output clock is gated.
000
divide by 1 (do not use with high input frequencies)
001
divide by 2
010
divide by 3
111
divide by 8
24–22
SPDIF0_CLK_
PODF
Divider for spdif0 clock podf.
NOTE: Divider should be updated when output clock is gated.
000
divide by 1
111
divide by 8
21–20
SPDIF0_CLK_
SEL
Selector for spdif0 clock multiplexer
00
derive clock from PLL4
01
derive clock from PLL3 PFD2
10
derive clock from PLL5
11
derive clock from pll3_sw_clk
-
This field is reserved.
Reserved
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
680
NXP Semiconductors

<!-- page 681 -->

18.6.14
CCM HSC Clock Divider Register (CCM_CHSCCDR)
The figure below represents the CCM HSC Clock Divider Register (CHSCCDR). The
CHSCCDR register contains bits to control the clock generation dividers. The table
below provides its field descriptions.
Address: 20C_4000h base + 34h offset = 20C_4034h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
EPDC_
PRE_
CLK_SEL
EPDC_
PODF
EPDC_
CLK_SEL
Reserved
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
0
1
0
0
1
0
0
0
1
0
1
0
0
1
0
0
0
CCM_CHSCCDR field descriptions
Field
Description
31–18
Reserved
This read-only field is reserved and always has the value 0.
17–15
EPDC_PRE_
CLK_SEL
Selector for EPDC root clock pre-multiplexer
000
Derive clock from PLL2
001
Derive clock from PLL3_SW_CLK
010
Derive clock from PLL5
011
Derive clock from PLL2 PFD0
100
Derive clock from PLL2 PFD2
101
Derive clock from PLL3 PFD2
110 - 111
Reserved
14–12
EPDC_PODF
Divider for EPDC clock divider.
NOTE: Divider should be updated when output clock is gated.
000
Divide by 1
001
Divide by 2
010
Divide by 3
011
Divide by 4
100
Divide by 5
101
Divide by 6
110
Divide by 7
111
Divide by 8
11–9
EPDC_CLK_SEL
Selector for EPDC root clock multiplexer
000
Derive clock from divided pre-muxed EPDC clock
001
Derive clock from ipp_di0_clk
010
Derive clock from ipp_di1_clk
011
Derive clock from ldb_di0_clk
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
681

<!-- page 682 -->

CCM_CHSCCDR field descriptions (continued)
Field
Description
100
Derive clock from ldb_di1_clk
101 - 111
Reserved
-
This field is reserved.
Reserved. Always set to 0.
18.6.15
CCM Serial Clock Divider Register 2 (CCM_CSCDR2)
The figure below represents the CCM Serial Clock Divider Register 2(CSCDR2). The
CSCDR2 register contains bits to control the clock generation sub-module dividers. The
table below provides its field descriptions.
Address: 20C_4000h base + 38h offset = 20C_4038h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
ECSPI_CLK_PODF
ECSPI_CLK_SEL
LCDIF1_PRE_
CLK_SEL
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
LCDIF1_PRE_
CLK_SEL
LCDIF1_PRED
LCDIF1_CLK_SEL
Reserved
W
Reset
1
0
0
1
1
0
1
1
0
1
0
0
1
0
0
0
CCM_CSCDR2 field descriptions
Field
Description
31–25
-
This field is reserved.
Reserved
24–19
ECSPI_CLK_
PODF
Divider for ecspi clock podf.
NOTE: Divider should be updated when output clock is gated.
NOTE: The input clock to this divider should be lower than 300Mhz, the predivider can be used to
achieve this.
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
682
NXP Semiconductors

<!-- page 683 -->

CCM_CSCDR2 field descriptions (continued)
Field
Description
000000
divide by 1
111111
divide by 2^6
18
ECSPI_CLK_
SEL
Selector for the ECSPI clock multiplexor
0
derive clock from pll3_60m
1
derive clock from osc_clk
17–15
LCDIF1_PRE_
CLK_SEL
Selector for lcdif1 root clock pre-multiplexer
000
derive clock from PLL2
001
derive clock from PLL3 PFD3
010
derive clock from PLL5
011
derive clock from PLL2 PFD0
100
derive clock from PLL2 PFD1
101
derive clock from PLL3 PFD1
110-111
Reserved
14–12
LCDIF1_PRED
Pre-divider for lcdif1 clock.
NOTE: Divider should be updated when output clock is gated.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
11–9
LCDIF1_CLK_SE
L
Selector for LCDIF1 root clock multiplexer
000
derive clock from divided pre-muxed LCDIF1 clock
001
derive clock from ipp_di0_clk
010
derive clock from ipp_di1_clk
011
derive clock from ldb_di0_clk
100
derive clock from ldb_di1_clk
101-111
Reserved
-
This field is reserved.
Reserved
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
683

<!-- page 684 -->

18.6.16
CCM Serial Clock Divider Register 3 (CCM_CSCDR3)
The figure below represents the CCM Serial Clock Divider Register 3(CSCDR3). The
CSCDR3 register contains bits to control the clock generation sub-module dividers. The
table below provides its field descriptions.
Address: 20C_4000h base + 3Ch offset = 20C_403Ch
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
CSI_
PODF
CSI_
CLK_
SEL
Reserved
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
0
1
0
0
1
0
0
0
0
1
0
0
0
0
0
1
CCM_CSCDR3 field descriptions
Field
Description
31–14
Reserved
This read-only field is reserved and always has the value 0.
13–11
CSI_PODF
Post divider for csi_mclk.
NOTE: Divider should be updated when output clock is gated.
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
10–9
CSI_CLK_SEL
Selector for csi_mclk multiplexer
00
derive clock from osc_clk (24M)
01
derive clock from PLL2 PFD2
10
derive clock from pll3_120M
11
derive clock from PLL3 PFD1
-
This field is reserved.
Reserved
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
684
NXP Semiconductors

<!-- page 685 -->

18.6.17
CCM Divider Handshake In-Process Register
(CCM_CDHIPR)
The figure below represents the CCM Divider Handshake In-Process Register
(CDHIPR). The CDHIPR register contains read-only bits that indicate that CCM is in the
process of updating dividers or muxes that might need handshake with modules.
Address: 20C_4000h base + 48h offset = 20C_4048h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
ARM_PODF_BUSY
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
685

<!-- page 686 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
PERIPH_CLK_SEL_BUSY
Reserved
PERIPH2_CLK_SEL_BUSY
MMDC_PODF_BUSY
AHB_PODF_BUSY
AXI_PODF_BUSY
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
CCM_CDHIPR field descriptions
Field
Description
31–17
Reserved
This read-only field is reserved and always has the value 0.
16
ARM_PODF_
BUSY
Busy indicator for arm_podf.
0
divider is not busy and its value represents the actual division.
1
divider is busy with handshake process with module. The value read in the divider represents the
previous value of the division factor, and after the handshake the written value of the arm_podf will be
applied.
15–6
Reserved
This read-only field is reserved and always has the value 0.
5
PERIPH_CLK_
SEL_BUSY
Busy indicator for periph_clk_sel mux control.
0
mux is not busy and its value represents the actual division.
1
mux is busy with handshake process with module. The value read in the periph_clk_sel represents the
previous value of select, and after the handshake periph_clk_sel value will be applied.
4
-
This field is reserved.
Reserved
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
686
NXP Semiconductors

<!-- page 687 -->

CCM_CDHIPR field descriptions (continued)
Field
Description
3
PERIPH2_CLK_
SEL_BUSY
Busy indicator for periph2_clk_sel mux control.
0
mux is not busy and its value represents the actual division.
1
mux is busy with handshake process with module. The value read in the periph2_clk_sel represents
the previous value of select, and after the handshake periph2_clk_sel value will be applied.
2
MMDC_PODF_
BUSY
Busy indicator for mmdc_axi_podf.
0
divider is not busy and its value represents the actual division.
1
divider is busy with handshake process with module. The value read in the divider represents the
previous value of the division factor, and after the handshake the written value of the mmdc_axi_podf
will be applied.
1
AHB_PODF_
BUSY
Busy indicator for ahb_podf.
0
divider is not busy and its value represents the actual division.
1
divider is busy with handshake process with module. The value read in the divider represents the
previous value of the division factor, and after the handshake the written value of the ahb_podf will be
applied.
0
AXI_PODF_
BUSY
Busy indicator for axi_podf.
0
divider is not busy and its value represents the actual division.
1
divider is busy with handshake process with module. The value read in the divider represents the
previous value of the division factor, and after the handshake the written value of the axi_podf will be
applied.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
687

<!-- page 688 -->

18.6.18
CCM Low Power Control Register (CCM_CLPCR)
The figure below represents the CCM Low Power Control Register (CLPCR). The
CLPCR register contains bits to control the low power modes operation.The table below
provides its field descriptions.
Address: 20C_4000h base + 54h offset = 20C_4054h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
MASK_L2CC_IDLE
MASK_SCU_IDLE
0
MASK_CORE0_WFI
BYPASS_MMDC_CH1_
LPM_HS
0
BYPASS_MMDC_CH0_
LPM_HS
Reserved
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
COSC_PWRDOWN
STBY_
COUNT
VSTBY
DIS_
REF_
OSC
SBYOS
ARM_CLK_DIS_ON_LPM
Reserved
Reserved
LPM
W
Reset
0
0
0
0
0
0
0
0
0
1
1
1
1
0
0
1
CCM_CLPCR field descriptions
Field
Description
31–28
Reserved
This read-only field is reserved and always has the value 0.
27
MASK_L2CC_
IDLE
Mask L2CC IDLE for entering low power mode.
NOTE: Assertion of all bits[27:22] will generate low power mode request
1
L2CC IDLE is masked
0
L2CC IDLE is not masked
26
MASK_SCU_
IDLE
Mask SCU IDLE for entering low power mode
NOTE: Assertion of all bits[27:22] will generate low power mode request
1
SCU IDLE is masked
0
SCU IDLE is not masked
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
688
NXP Semiconductors

<!-- page 689 -->

CCM_CLPCR field descriptions (continued)
Field
Description
25–23
Reserved
This read-only field is reserved and always has the value 0.
22
MASK_CORE0_
WFI
Mask WFI of core0 for entering low power mode
NOTE: Assertion of all bits[27:22] will generate low power mode request
0
WFI of core0 is not masked
1
WFI of core0 is masked
21
BYPASS_
MMDC_CH1_
LPM_HS
Bypass handshake with mmdc_ch1 on next entrance to low power mode (STOP or WAIT). CCM doesn't
wait for the module's acknowledge.
0
Handshake with mmdc_ch1 on next entrance to low power mode will be performed.
1
Handshake with mmdc_ch1 on next entrance to low power mode will be bypassed.
20
Reserved
This read-only field is reserved and always has the value 0.
19
BYPASS_
MMDC_CH0_
LPM_HS
Bypass handshake with mmdc_ch0 on next entrance to low power mode (STOP or WAIT). CCM doesn't
wait for the module's acknowledge. Handshake will also be bypassed, if CGR3 CG10 is set to gate fast
mmdc_ch0 clock.
NOTE: MMDC_CH0 clock is not used. This bit should always be programmed HIGH to let CCM know not
to wait for the acknowledge from MMDC_CH0, due to no connection.
0
Handshake with mmdc_ch0 on next entrance to low power mode will be performed.
1
Handshake with mmdc_ch0 on next entrance to low power mode will be bypassed.
18–12
-
This field is reserved.
Reserved
11
COSC_
PWRDOWN
In run mode, software can manually control powering down of on chip oscillator, i.e. generating '1' on
cosc_pwrdown signal. If software manually powered down the on chip oscillator, then sbyos functionality
for on chip oscillator will be bypassed.
The manual closing of onchip oscillator should be performed only in case the reference oscilator is not the
source of all the clocks generation.
0
On chip oscillator will not be powered down, i.e. cosc_pwrdown = '0'.
1
On chip oscillator will be powered down, i.e. cosc_pwrdown = '1'.
10–9
STBY_COUNT
Standby counter definition. These two bits define, in the case of stop exit (if VSTBY bit was set).
NOTE: Clock cycles ratio depends on pmic_delay_scaler, defined by CGPR[0] bit.
00
CCM will wait (1*pmic_delay_scaler)+1 ckil clock cycles
01
CCM will wait (3*pmic_delay_scaler)+1 ckil clock cycles
10
CCM will wait (7*pmic_delay_scaler)+1 ckil clock cycles
11
CCM will wait (15*pmic_delay_scaler)+1 ckil clock cycles
8
VSTBY
Voltage standby request bit. This bit defines if PMIC_STBY_REQ pin, which notifies external power
management IC to move from functional voltage to standby voltage, will be asserted in STOP mode.
0
Voltage will not be changed to standby voltage after next entrance to STOP mode.
( PMIC_STBY_REQ will remain negated - '0')
1
Voltage will be requested to change to standby voltage after next entrance to stop mode.
( PMIC_STBY_REQ will be asserted - '1').
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
689

<!-- page 690 -->

CCM_CLPCR field descriptions (continued)
Field
Description
7
DIS_REF_OSC
dis_ref_osc - in run mode, software can manually control closing of external reference oscillator clock, i.e.
generating '1' on CCM_REF_EN_B signal. If software closed manually the external reference clock, then
sbyos functionality will be bypassed.
The manual closing of external reference oscilator should be performed only in case the reference
oscilator is not the source of any clock generation.
NOTE: When returning from stop mode, the PMIC_STBY_REQ will be deasserted (if it was asserted
when entering stop mode). See stby_count bits.
0
external high frequency oscillator will be enabled, i.e. CCM_REF_EN_B = '0'.
1
external high frequency oscillator will be disabled, i.e. CCM_REF_EN_B = '1'
6
SBYOS
Standby clock oscillator bit. This bit defines if cosc_pwrdown, which power down the on chip oscillator, will
be asserted in STOP mode. This bit is discarded if cosc_pwrdown='1' for the on chip oscillator.
0
On-chip oscillator will not be powered down, after next entrance to STOP mode. (CCM_REF_EN_B
will remain asserted - '0' and cosc_pwrdown will remain de asserted - '0')
1
On-chip oscillator will be powered down, after next entrance to STOP mode. (CCM_REF_EN_B will
be deasserted - '1' and cosc_pwrdown will be asserted - '1'). When returning from STOP mode,
external oscillator will be enabled again, on-chip oscillator will return to oscillator mode, and after
oscnt count, CCM will continue with the exit from the STOP mode process.
5
ARM_CLK_DIS_
ON_LPM
Define if ARM clocks (arm_clk, soc_mxclk, soc_pclk, soc_dbg_pclk, vl_wrck) will be disabled on wait
mode. This is useful for debug mode, when the user still wants to simulate entering wait mode and still
keep ARM clock functioning.
NOTE: Software should not enable ARM power gating in wait mode if this bit is cleared.
0
ARM clock enabled on wait mode.
1
ARM clock disabled on wait mode. .
4–3
-
This field is reserved.
Reserved
2
-
This field is reserved.
Reserved
LPM
Setting the low power mode that system will enter on next assertion of dsm_request signal.
00
Remain in run mode
01
Transfer to wait mode
10
Transfer to stop mode
11
Reserved
18.6.19
CCM Interrupt Status Register (CCM_CISR)
The figure below represents the CCM Interrupt Status Register (CISR). This is a write
one to clear register. Once a interrupt is generated, software should write one to clear it.
The table below provides its field descriptions.
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
690
NXP Semiconductors

<!-- page 691 -->

NOTE
CCM interrupt request 1 can be masked by CCM interrupt
request 1 mask bit. CCM interrupt request 2 can be masked by
CCM interrupt request 2 mask bit.
Address: 20C_4000h base + 58h offset = 20C_4058h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
ARM_PODF_LOADED
0
Reserved
PERIPH_CLK_SEL_
LOADED
MMDC_PODF_LOADED
AHB_PODF_LOADED
PERIPH2_CLK_SEL_
LOADED
Reserved
AXI_PODF_LOADED
0
W
w1c
w1c
w1c
w1c
w1c
w1c
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
COSC_READY
0
LRF_PLL
W
w1c
w1c
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
691

<!-- page 692 -->

CCM_CISR field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 0.
26
ARM_PODF_
LOADED
CCM interrupt request 1 generated due to frequency change of arm_podf. The interrupt will commence
only if arm_podf is loaded during a DVFS operation.
0
interrupt is not generated due to frequency change of arm_podf
1
interrupt generated due to frequency change of arm_podf
25–24
Reserved
This read-only field is reserved and always has the value 0.
23
-
This field is reserved.
Reserved
22
PERIPH_CLK_
SEL_LOADED
CCM interrupt request 1 generated due to update of periph_clk_sel.
0
interrupt is not generated due to update of periph_clk_sel.
1
interrupt generated due to update of periph_clk_sel.
21
MMDC_PODF_
LOADED
CCM interrupt request 1 generated due to frequency change of mmdc_podf_ loaded
0
interrupt is not generated due to frequency change of mmdc_podf_ loaded
1
interrupt generated due to frequency change of mmdc_podf_ loaded
20
AHB_PODF_
LOADED
CCM interrupt request 1 generated due to frequency change of ahb_podf
0
interrupt is not generated due to frequency change of ahb_podf
1
interrupt generated due to frequency change of ahb_podf
19
PERIPH2_CLK_
SEL_LOADED
CCM interrupt request 1 generated due to frequency change of periph2_clk_sel
0
interrupt is not generated due to frequency change of periph2_clk_sel
1
interrupt generated due to frequency change of periph2_clk_sel
18
-
This field is reserved.
Reserved
17
AXI_PODF_
LOADED
CCM interrupt request 1 generated due to frequency change of axi_podf
0
interrupt is not generated due to frequency change of axi_podf
1
interrupt generated due to frequency change of axi_podf
16–7
Reserved
This read-only field is reserved and always has the value 0.
6
COSC_READY
CCM interrupt request 2 generated due to on board oscillator ready, i.e. oscnt has finished counting.
0
interrupt is not generated due to on board oscillator ready
1
interrupt generated due to on board oscillator ready
5–1
Reserved
This read-only field is reserved and always has the value 0.
0
LRF_PLL
CCM interrupt request 2 generated due to lock of all enabled and not bypaseed PLLs
0
interrupt is not generated due to lock ready of all enabled and not bypaseed PLLs
1
interrupt generated due to lock ready of all enabled and not bypaseed PLLs
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
692
NXP Semiconductors

<!-- page 693 -->

18.6.20
CCM Interrupt Mask Register (CCM_CIMR)
The figure below represents the CCM Interrupt Mask Register (CIMR). The table below
provides its field descriptions.
Address: 20C_4000h base + 5Ch offset = 20C_405Ch
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
1
ARM_PODF_LOADED
Reserved
MASK_PERIPH_CLK_
SEL_LOADED
MASK_MMDC_PODF_
LOADED
MASK_AHB_PODF_
LOADED
MASK_PERIPH2_CLK_
SEL_LOADED
Reserved
MASK_AXI_PODF_
LOADED
1
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
1
MASK_COSC_READY
1
MASK_LRF_PLL
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
CCM_CIMR field descriptions
Field
Description
31–27
Reserved
This read-only field is reserved and always has the value 1.
26
ARM_PODF_
LOADED
mask interrupt generation due to frequency change of arm_podf
0
don't mask interrupt due to frequency change of arm_podf - interrupt will be created
1
mask interrupt due to frequency change of arm_podf
25–23
-
This field is reserved.
Reserved
22
MASK_PERIPH_
CLK_SEL_
LOADED
mask interrupt generation due to update of periph_clk_sel.
0
don't mask interrupt due to update of periph_clk_sel - interrupt will be created
1
mask interrupt due to update of periph_clk_sel
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
693

<!-- page 694 -->

CCM_CIMR field descriptions (continued)
Field
Description
21
MASK_MMDC_
PODF_LOADED
mask interrupt generation due to update of mask_mmdc_podf
0
don't mask interrupt due to update of mask_mmdc_podf - interrupt will be created
1
mask interrupt due to update of mask_mmdc_podf
20
MASK_AHB_
PODF_LOADED
mask interrupt generation due to frequency change of ahb_podf
0
don't mask interrupt due to frequency change of ahb_podf - interrupt will be created
1
mask interrupt due to frequency change of ahb_podf
19
MASK_
PERIPH2_CLK_
SEL_LOADED
mask interrupt generation due to update of periph2_clk_sel.
0
don't mask interrupt due to update of periph2_clk_sel - interrupt will be created
1
mask interrupt due to update of periph2_clk_sel
18
-
This field is reserved.
Reserved
17
MASK_AXI_
PODF_LOADED
mask interrupt generation due to frequency change of axi_podf
0
don't mask interrupt due to frequency change of axi_podf - interrupt will be created
1
mask interrupt due to frequency change of axi_podf
16–7
Reserved
This read-only field is reserved and always has the value 1.
6
MASK_COSC_
READY
mask interrupt generation due to on board oscillator ready
0
don't mask interrupt due to on board oscillator ready - interrupt will be created
1
mask interrupt due to on board oscillator ready
5–1
Reserved
This read-only field is reserved and always has the value 1.
0
MASK_LRF_PLL
mask interrupt generation due to lrf of PLLs
0
don't mask interrupt due to lrf of PLLs - interrupt will be created
1
mask interrupt due to lrf of PLLs
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
694
NXP Semiconductors

<!-- page 695 -->

18.6.21
CCM Clock Output Source Register (CCM_CCOSR)
The figure below represents the CCM Clock Output Source Register (CCOSR). The
CCOSR register contains bits to control the clock that will be generated on the output
ipp_do_clko1 (CCM_CLKO).The table below provides its field descriptions.
Address: 20C_4000h base + 60h offset = 20C_4060h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
CLKO2_EN
CLKO2_DIV
CLKO2_SEL
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
1
0
1
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
0
CLK_OUT_
SEL
CLKO1_EN
CLKO1_DIV
CLKO_SEL
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
CCM_CCOSR field descriptions
Field
Description
31–25
Reserved
This read-only field is reserved and always has the value 0.
24
CLKO2_EN
Enable of CCM_CLKO2 clock
0
CCM_CLKO2 disabled.
1
CCM_CLKO2 enabled.
23–21
CLKO2_DIV
Setting the divider of CCM_CLKO2
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
20–16
CLKO2_SEL
Selection of the clock to be generated on CCM_CLKO2
00001
mmdc_clk_root
00010
gpmi_clk_root
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
695

<!-- page 696 -->

CCM_CCOSR field descriptions (continued)
Field
Description
00011
usdhc1_clk_root
00101
wrck_clk_root
00110
ecspi_clk_root
01000
bch_clk_root
01010
arm_clk_root
01011
csi_core
01110
osc_clk
10001
usdhc2_clk_root
10010
sai1_clk_root
10011
sai2_clk_root
10100
sai3_clk_root
10111
can_clk_root
11001
qspi1_clk_root
11011
aclk_eim_slow_clk_root
11100
uart_clk_root
11101
spdif0_clk_root
11111
Reserved
15–9
Reserved
This read-only field is reserved and always has the value 0.
8
CLK_OUT_SEL
CCM_CLKO1 output to reflect CCM_CLKO1 or CCM_CLKO2 clocks
0
CCM_CLKO1 output drives CCM_CLKO1 clock
1
CCM_CLKO1 output drives CCM_CLKO2 clock
7
CLKO1_EN
Enable of CCM_CLKO1 clock
0
CCM_CLKO1 disabled.
1
CCM_CLKO1 enabled.
6–4
CLKO1_DIV
Setting the divider of CCM_CLKO1
000
divide by 1
001
divide by 2
010
divide by 3
011
divide by 4
100
divide by 5
101
divide by 6
110
divide by 7
111
divide by 8
CLKO_SEL
Selection of the clock to be generated on CCM_CLKO1
0101
axi_clk_root
0110
enfc_clk_root
1000
epdc_clk_root
1001
1010
lcdif_pix_clk_root
1011
ahb_clk_root
1100
ipg_clk_root
1101
perclk_root
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
696
NXP Semiconductors

<!-- page 697 -->

CCM_CCOSR field descriptions (continued)
Field
Description
1110
ckil_sync_clk_root
1111
pll4_main_clk
18.6.22
CCM General Purpose Register (CCM_CGPR)
Fast PLL enable. Can be used to engage PLL faster after STOP mode, if 24MHz OSC
was active
Address: 20C_4000h base + 64h offset = 20C_4064h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
0
INT_MEM_CLK_LPM
FPL
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
SYS_MEM_
DS_CTRL
1
0
1
EFUSE_PROG_SUPPLY_
GATE
Reserved
MMDC_EXT_CLK_DIS
PMIC_DELAY_SCALER
W
1
Reset
1
1
1
1
1
1
1
0
0
1
1
0
0
0
1
0
CCM_CGPR field descriptions
Field
Description
31–18
Reserved
This read-only field is reserved and always has the value 0.
17
INT_MEM_CLK_
LPM
Control for the Deep Sleep signal to the ARM Platform memories with additional control logic based on the
ARM WFI signal. Used to keep the ARM Platform memory clocks enabled if an interrupt is pending when
entering low power mode.
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
697

<!-- page 698 -->

CCM_CGPR field descriptions (continued)
Field
Description
NOTE: This bit should always bet set when the CCM_CLPCR_LPM bits are set to 01(WAIT Mode) or 10
(STOP mode) without power gating. This bit does not have to be set for STOP mode entry.
0
Disable the clock to the ARM platform memories when entering Low Power Mode
1
Keep the clocks to the ARM platform memories enabled only if an interrupt is pending when entering
Low Power Modes (WAIT and STOP without power gating)
16
FPL
Fast PLL enable.
0
Engage PLL enable default way.
1
Engage PLL enable 3 CKIL clocks earlier at exiting low power mode (STOP). Should be used only if
24MHz OSC was active in low power mode.
15–14
SYS_MEM_DS_
CTRL
System memory DS control
00
Disable memory DS mode always
01
Enable memory (outside ARM platform) DS mode when system STOP and PLL are disabled
1x
enable memory (outside ARM platform) DS mode when system is in STOP mode
13–9
Reserved
This read-only field is reserved and always has the value 1.
8–7
Reserved
This read-only field is reserved and always has the value 0.
6–5
Reserved
This read-only field is reserved and always has the value 1.
4
EFUSE_PROG_
SUPPLY_GATE
Defines the value of the output signal cgpr_dout[4]. Gate of program supply for efuse programing
0
fuse programing supply voltage is gated off to the efuse module
1
allow fuse programing.
3
-
This field is reserved.
Reserved
2
MMDC_EXT_
CLK_DIS
Disable external clock driver of MMDC during STOP mode
1
disable during stop mode
0
don't disable during stop mode.
1
-
Reserved. Keep default value set to '1' for proper operation.
0
PMIC_DELAY_
SCALER
Defines clock dividion of clock for stby_count (pmic delay counter)
0
clock is not divided
1
clock is divided /8
18.6.23
CCM Clock Gating Register 0 (CCM_CCGR0)
CG(i) bits CCGR 0-6
These bits are used to turn on/off the clock to each module independently. The following
table details the possible clock activity conditions for each module.
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
698
NXP Semiconductors

<!-- page 699 -->

CGR value
Clock Activity Description
00
Clock is off during all modes. Stop enter hardware handshake is disabled.
01
Clock is on in run mode, but off in WAIT and STOP modes
10
Not applicable (Reserved).
11
Clock is on during all modes, except STOP mode.
Module should be stopped, before set its bits to "0"; clocks to the module will be stopped
immediately.
The tables above show the register mappings for the different CGRs. The clock
connectivity table should be used to match the "CCM output affected" to the actual
clocks going into the modules.
The figure below represents the CCM Clock Gating Register 0 (CCM_CCGR0). The
clock gating Registers define the clock gating for power reduction of each clock (CG(i)
bits). There are 7 CGR registers. The number of registers required is according to the
number of peripherals in the system.
Address: 20C_4000h base + 68h offset = 20C_4068h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
CG15
CG14
CG13
CG12
CG11
CG10
CG9
CG8
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CG7
CG6
CG5
CG4
CG3
CG2
CG1
CG0
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
CCM_CCGR0 field descriptions
Field
Description
31–30
CG15
gpio2_clocks (gpio2_clk_enable)
29–28
CG14
uart2 clock (uart2_clk_enable)
27–26
CG13
gpt2 serial clocks (gpt2_serial_clk_enable)
25–24
CG12
gpt2 bus clocks (gpt2_bus_clk_enable)
23–22
CG11
CPU debug clocks (arm_dbg_clk_enable)
21–20
CG10
can2_serial clock (can2_serial_clk_enable)
19–18
CG9
can2 clock (can2_clk_enable)
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
699

<!-- page 700 -->

CCM_CCGR0 field descriptions (continued)
Field
Description
17–16
CG8
can1_serial clock (can1_serial_clk_enable)
15–14
CG7
can1 clock (can1_clk_enable)
13–12
CG6
enet clock (enet_clk_enable)
11–10
CG5
dcp clock (dcp_clk_enable)
9–8
CG4
Reserved
7–6
CG3
asrc clock (asrc_clk_enable)
5–4
CG2
apbhdma hclk clock (apbhdma_hclk_enable)
3–2
CG1
aips_tz2 clocks (aips_tz2_clk_enable)
CG0
aips_tz1 clocks (aips_tz1_clk_enable)
18.6.24
CCM Clock Gating Register 1 (CCM_CCGR1)
The figure below represents the CCM Clock Gating Register 1(CCM_CCGR1). The
clock gating registers define the clock gating for power reduction of each clock (CG(i)
bits). There are 8 CGR registers. The number of registers required is determined by the
number of peripherals in the system.
Address: 20C_4000h base + 6Ch offset = 20C_406Ch
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
CG15
CG14
CG13
CG12
CG11
CG10
CG9
CG8
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CG7
CG6
CG5
CG4
CG3
CG2
CG1
CG0
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
CCM_CCGR1 field descriptions
Field
Description
31–30
CG15
Reserved
29–28
CG14
csu clock (csu_clk_enable)
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
700
NXP Semiconductors

<!-- page 701 -->

CCM_CCGR1 field descriptions (continued)
Field
Description
27–26
CG13
gpio1 clock (gpio1_clk_enable)
25–24
CG12
uart4 clock (uart4_clk_enable)
23–22
CG11
gpt serial clock (gpt_serial_clk_enable)
21–20
CG10
gpt bus clock (gpt_clk_enable)
19–18
CG9
sim_s clock (sim_s_clk_enable)
17–16
CG8
adc1 clock (adc1_clk_enable)
15–14
CG7
epit2 clocks (epit2_clk_enable)
13–12
CG6
epit1 clocks (epit1_clk_enable)
11–10
CG5
uart3 clock (uart3_clk_enable)
9–8
CG4
adc2 clock (adc2_clk_enable)
7–6
CG3
ecspi4 clocks (ecspi4_clk_enable)
5–4
CG2
ecspi3 clocks (ecspi3_clk_enable)
3–2
CG1
ecspi2 clocks (ecspi2_clk_enable)
CG0
ecspi1 clocks (ecspi1_clk_enable)
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
701

<!-- page 702 -->

18.6.25
CCM Clock Gating Register 2 (CCM_CCGR2)
The figure below represents the CCM Clock Gating Register 2 (CCM_CCGR2). The
clock gating registers define the clock gating for power reduction of each clock (CG(i)
bits). There are 8 CGR registers. The number of registers required is determined by the
number of peripherals in the system.
Address: 20C_4000h base + 70h offset = 20C_4070h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
CG15
CG14
CG13
CG12
CG11
CG10
CG9
CG8
W
Reset
1
1
1
1
1
1
0
0
0
0
1
1
1
1
1
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CG7
CG6
CG5
CG4
CG3
CG2
CG1
CG0
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
CCM_CCGR2 field descriptions
Field
Description
31–30
CG15
pxp clocks (pxp_clk_enable)
29–28
CG14
lcd clocks (lcd_clk_enable)
27–26
CG13
gpio3 clock (gpio3_clk_enable)
25–24
CG12
Reserved
23–22
CG11
ipsync_ip2apb_tzasc1_ipg clocks (ipsync_ip2apb_tzasc1_ipg_master_clk_enable)
21–20
CG10
ipmux3 clock (ipmux3_clk_enable)
19–18
CG9
ipmux2 clock (ipmux2_clk_enable)
17–16
CG8
ipmux1 clock (ipmux1_clk_enable)
15–14
CG7
iomux_ipt_clk_io clock (iomux_ipt_clk_io_enable)
13–12
CG6
OCOTP_CTRL clock (iim_clk_enable)
11–10
CG5
i2c3_serial clock (i2c3_serial_clk_enable)
9–8
CG4
i2c2_serial clock (i2c2_serial_clk_enable)
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
702
NXP Semiconductors

<!-- page 703 -->

CCM_CCGR2 field descriptions (continued)
Field
Description
7–6
CG3
i2c1_serial clock (i2c1_serial_clk_enable)
5–4
CG2
iomuxc_snvs clock (iomuxc_snvs_clk_enable)
3–2
CG1
csi clock (csi_clk_enable)
CG0
esai clock (esai_clk_enable)
18.6.26
CCM Clock Gating Register 3 (CCM_CCGR3)
The figure below represents the CCM Clock Gating Register 3 (CCM_CCGR3). The
clock gating Registers define the clock gating for power reduction of each clock (CG(i)
bits). There are 8 CGR registers. The number of registers required is determined by the
number of peripherals in the system.
Address: 20C_4000h base + 74h offset = 20C_4074h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
CG15
CG14
CG13
CG12
CG11
CG10
CG9
CG8
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CG7
CG6
CG5
CG4
CG3
CG2
CG1
CG0
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
CCM_CCGR3 field descriptions
Field
Description
31–30
CG15
iomuxc_snvs_gpr clock (iomuxc_snvs_gpr_clk_enable)
29–28
CG14
ocram clock (ocram_clk_enable)
27–26
CG13
mmdc_core_ipg_clk_p1 clock (mmdc_core_ipg_clk_p1_enable)
25–24
CG12
mmdc_core_ipg_clk_p0 clock (mmdc_core_ipg_clk_p0_enable)
23–22
CG11
Reserved
21–20
CG10
mmdc_core_aclk_fast_core_p0 clock (mmdc_core_aclk_fast_core_p0_enable)
19–18
CG9
a7 clkdiv patch clock (a7_clkdiv_patch_clk_enable)
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
703

<!-- page 704 -->

CCM_CCGR3 field descriptions (continued)
Field
Description
17–16
CG8
wdog1 clock (wdog1_clk_enable)
15–14
CG7
qspi clock (qspi_clk_enable)
13–12
CG6
gpio4 clock (gpio4_clk_enable)
11–10
CG5
lcdif1 pix clock (lcdif1_pix_clk_enable)
9–8
CG4
CA7 CCM DAP clock (ccm_dap_clk_enable)
7–6
CG3
uart6 clock (uart6_clk_enable)
5–4
CG2
epdc clock (epdc_clk_enable)
3–2
CG1
uart5 clock (uart5_clk_enable)
CG0
Reserved
18.6.27
CCM Clock Gating Register 4 (CCM_CCGR4)
The figure below represents the CCM Clock Gating Register 4 (CCM_CCGR4). The
clock gating Registers define the clock gating for power reduction of each clock (CG(i)
bits). There are 8 CGR registers. The number of registers required is determined by the
number of peripherals in the system.
Address: 20C_4000h base + 78h offset = 20C_4078h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
CG15
CG14
CG13
CG12
CG11
CG10
CG9
CG8
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CG7
CG6
CG5
CG4
CG3
CG2
CG1
CG0
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
CCM_CCGR4 field descriptions
Field
Description
31–30
CG15
rawnand_u_gpmi_input_apb clock (rawnand_u_gpmi_input_apb_clk_enable)
29–28
CG14
rawnand_u_gpmi_bch_input_gpmi_io clock (rawnand_u_gpmi_bch_input_gpmi_io_clk_enable)
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
704
NXP Semiconductors

<!-- page 705 -->

CCM_CCGR4 field descriptions (continued)
Field
Description
27–26
CG13
rawnand_u_gpmi_bch_input_bch clock (rawnand_u_gpmi_bch_input_bch_clk_enable)
25–24
CG12
rawnand_u_bch_input_apb clock (rawnand_u_bch_input_apb_clk_enable)
23–22
CG11
pwm4 clocks (pwm4_clk_enable)
21–20
CG10
pwm3 clocks (pwm3_clk_enable)
19–18
CG9
pwm2 clocks (pwm2_clk_enable)
17–16
CG8
pwm1 clocks (pwm1_clk_enable)
15–14
CG7
pl301_mx6qper2_mainclk_enable (pl301_mx6qper2_mainclk_enable)
13–12
CG6
pl301_mx6qper1_bch clocks (pl301_mx6qper1_bchclk_enable)
NOTE: This gates bch_clk_root to sim_m fabric.
11–10
CG5
tsc_dig clock (tsc_clk_enable)
9–8
CG4
cxapbsyncbridge slave clock (cxapbsyncbridge_slave_clk_enable)
7–6
CG3
sim_cpu clock(sim_cpu_clk_enable)
5–4
CG2
iomuxc gpr clock (iomuxc_gpr_clk_enable)
3–2
CG1
iomuxc clock (iomuxc_clk_enable)
CG0
Reserved
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
705

<!-- page 706 -->

18.6.28
CCM Clock Gating Register 5 (CCM_CCGR5)
The figure below represents the CCM Clock Gating Register 5 (CCM_CCGR5). The
clock gating Registers define the clock gating for power reduction of each clock (CG(i)
bits). There are 8 CGR registers. The number of registers required is determined by the
number of peripherals in the system.
Address: 20C_4000h base + 7Ch offset = 20C_407Ch
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
CG15
CG14
CG13
CG12
CG11
CG10
CG9
CG8
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CG7
CG6
CG5
CG4
CG3
CG2
CG1
CG0
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
CCM_CCGR5 field descriptions
Field
Description
31–30
CG15
sai2 clock (sai2_clk_enable)
29–28
CG14
sai1 clock (sai1_clk_enable)
27–26
CG13
uart7 clock (uart7_clk_enable)
25–24
CG12
uart1 clock (uart1_clk_enable)
23–22
CG11
sai3 clock (sai3_clk_enable)
21–20
CG10
snvs_lp clock (snvs_lp_clk_enable)
19–18
CG9
snvs_hp clock (snvs_hp_clk_enable)
17–16
CG8
sim_main clock (sim_main_clk_enable)
15–14
CG7
spdif / audio clock (spdif_clk_enable, audio_clk_root)
13–12
CG6
spba clock (spba_clk_enable)
11–10
CG5
wdog2 clock (wdog2_clk_enable)
9–8
CG4
kpp clock (kpp_clk_enable)
Table continues on the next page...
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
706
NXP Semiconductors

<!-- page 707 -->

CCM_CCGR5 field descriptions (continued)
Field
Description
7–6
CG3
sdma clock (sdma_clk_enable)
5–4
CG2
snvs dryice clock (snvs_dryice_clk_enable)
3–2
CG1
sctr clock (sctr_clk_enable)
CG0
rom clock (rom_clk_enable)
18.6.29
CCM Clock Gating Register 6 (CCM_CCGR6)
The figure below represents the CCM Clock Gating Register 6 (CCM_CCGR6). The
clock gating Registers define the clock gating for power reduction of each clock (CG(i)
bits). There are 8 CGR registers. The number of registers required is determined by the
number of peripherals in the system.
Address: 20C_4000h base + 80h offset = 20C_4080h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
CG15
CG14
CG13
CG12
CG11
CG10
CG9
CG8
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
CG7
CG6
CG5
CG4
CG3
CG2
CG1
CG0
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
CCM_CCGR6 field descriptions
Field
Description
31–30
CG15
pwm7 clocks (pwm7_clk_enable)
29–28
CG14
pwm6 clocks (pwm6_clk_enable)
27–26
CG13
pwm5 clocks (pwm5_clk_enable)
25–24
CG12
i2c4 serial clock (i2c4_serial_clk_enable)
23–22
CG11
anadig clocks (anadig_clk_enable)
21–20
CG10
wdog3 clock (wdog3_clk_enable)
19–18
CG9
aips_tz3 clock (aips_tz3_clk_enable)
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
707

<!-- page 708 -->

CCM_CCGR6 field descriptions (continued)
Field
Description
17–16
CG8
pwm8 clocks (pwm8_clk_enable)
15–14
CG7
uart8 clocks (uart8_clk_enable)
13–12
CG6
uart debug req gate
NOTE: This is not a clock, but a gate for the debug request signal to reach the UART module.
11–10
CG5
eim_slow clocks (eim_slow_clk_enable)
9–8
CG4
ipmux4 clock (ipmux4_clk_enable)
7–6
CG3
Reserved
5–4
CG2
usdhc2 clocks (usdhc2_clk_enable)
3–2
CG1
usdhc1 clocks (usdhc1_clk_enable)
CG0
usboh3 clock (usboh3_clk_enable)
CCM Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
708
NXP Semiconductors

<!-- page 709 -->

18.6.30
CCM Module Enable Overide Register (CCM_CMEOR)
The follow figure represents the CCM Module Enable Override Register (CMEOR). The
CMEOR register contains bits to override the clock enable signal from the module. This
bit will be applicable only for modules whose clock enable signals are used. The
following table provides its field descriptions.
Address: 20C_4000h base + 88h offset = 20C_4088h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
1
MOD_EN_OV_
CAN1_CPI
1
MOD_EN_OV_
CAN2_CPI
1
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
1
MOD_EN_USDHC
MOD_EN_OV_
EPIT
MOD_EN_OV_GPT
1
W
Reset
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
1
CCM_CMEOR field descriptions
Field
Description
31
Reserved
This read-only field is reserved and always has the value 1.
30
MOD_EN_OV_
CAN1_CPI
Overide clock enable signal from CAN1 - clock will not be gated based on CAN's signal 'enable_clk_cpi'.
0
don't overide module enable signal
1
overide module enable signal
29
Reserved
This read-only field is reserved and always has the value 1.
28
MOD_EN_OV_
CAN2_CPI
Overide clock enable signal from CAN2 - clock will not be gated based on CAN's signal 'enable_clk_cpi'.
0
don't override module enable signal
1
override module enable signal
27–8
Reserved
This read-only field is reserved and always has the value 1.
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
709

<!-- page 710 -->

CCM_CMEOR field descriptions (continued)
Field
Description
7
MOD_EN_
USDHC
overide clock enable signal from USDHC.
0
don't override module enable signal
1
override module enable signal
6
MOD_EN_OV_
EPIT
Overide clock enable signal from EPIT - clock will not be gated based on EPIT's signal 'ipg_enable_clk' .
0
don't override module enable signal
1
override module enable signal
5
MOD_EN_OV_
GPT
Overide clock enable signal from GPT - clock will not be gated based on GPT's signal 'ipg_enable_clk' .
0
don't override module enable signal
1
override module enable signal
Reserved
This read-only field is reserved and always has the value 1.
18.7
CCM Analog Memory Map/Register Definition
This section describes the registers for the analog PLLs. The registers which have the
same description are grouped within {}. The register offsets for the various PLLs are:
• ARM PLL: {0h000, 0h004, 0h008, 0h00C}.
• USB1 PLL: {0h010, 0h014, 0h018, 0h01C}, {0h0F0, 0h0F4, 0h0F8, 0h0FC}.
• System PLL: {0h030, 0h034, 0h038, 0h03C}, 0h040, 0h050, 0h060, {0h100, 0h104,
0h108, 0h10C}.
• Audio / Video PLL: {0h070, 0h074, 0h078, 0h07C}, 0h080, 0h090, {0h0A0, 0h0A4,
0h0A8, 0h0AC}, 0h0B0, 0h0C0
CCM_ANALOG memory map
Absolute
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
20C_8000
Analog ARM PLL control Register
(CCM_ANALOG_PLL_ARM)
32
R/W
0001_3063h
18.7.1/714
20C_8004
Analog ARM PLL control Register
(CCM_ANALOG_PLL_ARM_SET)
32
R/W
0001_3063h
18.7.1/714
20C_8008
Analog ARM PLL control Register
(CCM_ANALOG_PLL_ARM_CLR)
32
R/W
0001_3063h
18.7.1/714
20C_800C
Analog ARM PLL control Register
(CCM_ANALOG_PLL_ARM_TOG)
32
R/W
0001_3063h
18.7.1/714
20C_8010
Analog USB1 480MHz PLL Control Register
(CCM_ANALOG_PLL_USB1)
32
R/W
0001_2000h
18.7.2/716
Table continues on the next page...
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
710
NXP Semiconductors

<!-- page 711 -->

CCM_ANALOG memory map (continued)
Absolute
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
20C_8014
Analog USB1 480MHz PLL Control Register
(CCM_ANALOG_PLL_USB1_SET)
32
R/W
0001_2000h
18.7.2/716
20C_8018
Analog USB1 480MHz PLL Control Register
(CCM_ANALOG_PLL_USB1_CLR)
32
R/W
0001_2000h
18.7.2/716
20C_801C
Analog USB1 480MHz PLL Control Register
(CCM_ANALOG_PLL_USB1_TOG)
32
R/W
0001_2000h
18.7.2/716
20C_8020
Analog USB2 480MHz PLL Control Register
(CCM_ANALOG_PLL_USB2)
32
R/W
0001_2000h
18.7.3/718
20C_8024
Analog USB2 480MHz PLL Control Register
(CCM_ANALOG_PLL_USB2_SET)
32
R/W
0001_2000h
18.7.3/718
20C_8028
Analog USB2 480MHz PLL Control Register
(CCM_ANALOG_PLL_USB2_CLR)
32
R/W
0001_2000h
18.7.3/718
20C_802C
Analog USB2 480MHz PLL Control Register
(CCM_ANALOG_PLL_USB2_TOG)
32
R/W
0001_2000h
18.7.3/718
20C_8030
Analog System PLL Control Register
(CCM_ANALOG_PLL_SYS)
32
R/W
0001_3001h
18.7.4/720
20C_8034
Analog System PLL Control Register
(CCM_ANALOG_PLL_SYS_SET)
32
R/W
0001_3001h
18.7.4/720
20C_8038
Analog System PLL Control Register
(CCM_ANALOG_PLL_SYS_CLR)
32
R/W
0001_3001h
18.7.4/720
20C_803C
Analog System PLL Control Register
(CCM_ANALOG_PLL_SYS_TOG)
32
R/W
0001_3001h
18.7.4/720
20C_8040
528MHz System PLL Spread Spectrum Register
(CCM_ANALOG_PLL_SYS_SS)
32
R/W
0000_0000h
18.7.5/722
20C_8050
Numerator of 528MHz System PLL Fractional Loop Divider
Register (CCM_ANALOG_PLL_SYS_NUM)
32
R/W
0000_0000h
18.7.6/722
20C_8060
Denominator of 528MHz System PLL Fractional Loop
Divider Register (CCM_ANALOG_PLL_SYS_DENOM)
32
R/W
0000_0012h
18.7.7/723
20C_8070
Analog Audio PLL control Register
(CCM_ANALOG_PLL_AUDIO)
32
R/W
0001_1006h
18.7.8/724
20C_8074
Analog Audio PLL control Register
(CCM_ANALOG_PLL_AUDIO_SET)
32
R/W
0001_1006h
18.7.8/724
20C_8078
Analog Audio PLL control Register
(CCM_ANALOG_PLL_AUDIO_CLR)
32
R/W
0001_1006h
18.7.8/724
20C_807C
Analog Audio PLL control Register
(CCM_ANALOG_PLL_AUDIO_TOG)
32
R/W
0001_1006h
18.7.8/724
20C_8080
Numerator of Audio PLL Fractional Loop Divider Register
(CCM_ANALOG_PLL_AUDIO_NUM)
32
R/W
05F5_E100h
18.7.9/726
20C_8090
Denominator of Audio PLL Fractional Loop Divider Register
(CCM_ANALOG_PLL_AUDIO_DENOM)
32
R/W
2964_619Ch
18.7.10/
727
20C_80A0
Analog Video PLL control Register
(CCM_ANALOG_PLL_VIDEO)
32
R/W
0001_100Ch
18.7.11/
728
20C_80A4
Analog Video PLL control Register
(CCM_ANALOG_PLL_VIDEO_SET)
32
R/W
0001_100Ch
18.7.11/
728
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
711

<!-- page 712 -->

CCM_ANALOG memory map (continued)
Absolute
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
20C_80A8
Analog Video PLL control Register
(CCM_ANALOG_PLL_VIDEO_CLR)
32
R/W
0001_100Ch
18.7.11/
728
20C_80AC
Analog Video PLL control Register
(CCM_ANALOG_PLL_VIDEO_TOG)
32
R/W
0001_100Ch
18.7.11/
728
20C_80B0
Numerator of Video PLL Fractional Loop Divider Register
(CCM_ANALOG_PLL_VIDEO_NUM)
32
R/W
05F5_E100h
18.7.12/
730
20C_80C0
Denominator of Video PLL Fractional Loop Divider Register
(CCM_ANALOG_PLL_VIDEO_DENOM)
32
R/W
10A2_4447h
18.7.13/
731
20C_80E0
Analog ENET PLL Control Register
(CCM_ANALOG_PLL_ENET)
32
R/W
0001_1001h
18.7.14/
732
20C_80E4
Analog ENET PLL Control Register
(CCM_ANALOG_PLL_ENET_SET)
32
R/W
0001_1001h
18.7.14/
732
20C_80E8
Analog ENET PLL Control Register
(CCM_ANALOG_PLL_ENET_CLR)
32
R/W
0001_1001h
18.7.14/
732
20C_80EC
Analog ENET PLL Control Register
(CCM_ANALOG_PLL_ENET_TOG)
32
R/W
0001_1001h
18.7.14/
732
20C_80F0
480MHz Clock (PLL3) Phase Fractional Divider Control
Register (CCM_ANALOG_PFD_480)
32
R/W
1311_100Ch
18.7.15/
734
20C_80F4
480MHz Clock (PLL3) Phase Fractional Divider Control
Register (CCM_ANALOG_PFD_480_SET)
32
R/W
1311_100Ch
18.7.15/
734
20C_80F8
480MHz Clock (PLL3) Phase Fractional Divider Control
Register (CCM_ANALOG_PFD_480_CLR)
32
R/W
1311_100Ch
18.7.15/
734
20C_80FC
480MHz Clock (PLL3) Phase Fractional Divider Control
Register (CCM_ANALOG_PFD_480_TOG)
32
R/W
1311_100Ch
18.7.15/
734
20C_8100
528MHz Clock (PLL2) Phase Fractional Divider Control
Register (CCM_ANALOG_PFD_528)
32
R/W
1018_101Bh
18.7.16/
736
20C_8104
528MHz Clock (PLL2) Phase Fractional Divider Control
Register (CCM_ANALOG_PFD_528_SET)
32
R/W
1018_101Bh
18.7.16/
736
20C_8108
528MHz Clock (PLL2) Phase Fractional Divider Control
Register (CCM_ANALOG_PFD_528_CLR)
32
R/W
1018_101Bh
18.7.16/
736
20C_810C
528MHz Clock (PLL2) Phase Fractional Divider Control
Register (CCM_ANALOG_PFD_528_TOG)
32
R/W
1018_101Bh
18.7.16/
736
20C_8150
Miscellaneous Register 0 (CCM_ANALOG_MISC0)
32
R/W
0400_0000h
18.7.17/
739
20C_8154
Miscellaneous Register 0 (CCM_ANALOG_MISC0_SET)
32
R/W
0400_0000h
18.7.17/
739
20C_8158
Miscellaneous Register 0 (CCM_ANALOG_MISC0_CLR)
32
R/W
0400_0000h
18.7.17/
739
20C_815C
Miscellaneous Register 0 (CCM_ANALOG_MISC0_TOG)
32
R/W
0400_0000h
18.7.17/
739
20C_8160
Miscellaneous Register 1 (CCM_ANALOG_MISC1)
32
R/W
0000_0000h
18.7.18/
743
20C_8164
Miscellaneous Register 1 (CCM_ANALOG_MISC1_SET)
32
R/W
0000_0000h
18.7.18/
743
Table continues on the next page...
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
712
NXP Semiconductors

<!-- page 713 -->

CCM_ANALOG memory map (continued)
Absolute
address
(hex)
Register name
Width
(in bits)
Access
Reset value
Section/
page
20C_8168
Miscellaneous Register 1 (CCM_ANALOG_MISC1_CLR)
32
R/W
0000_0000h
18.7.18/
743
20C_816C
Miscellaneous Register 1 (CCM_ANALOG_MISC1_TOG)
32
R/W
0000_0000h
18.7.18/
743
20C_8170
Miscellaneous Register 2 (CCM_ANALOG_MISC2)
32
R/W
0027_2727h
18.7.19/
746
20C_8174
Miscellaneous Register 2 (CCM_ANALOG_MISC2_SET)
32
R/W
0027_2727h
18.7.19/
746
20C_8178
Miscellaneous Register 2 (CCM_ANALOG_MISC2_CLR)
32
R/W
0027_2727h
18.7.19/
746
20C_817C
Miscellaneous Register 2 (CCM_ANALOG_MISC2_TOG)
32
R/W
0027_2727h
18.7.19/
746
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
713

<!-- page 714 -->

18.7.1
Analog ARM PLL control Register
(CCM_ANALOG_PLL_ARMn)
The control register provides control for the system PLL.
Address: 20C_8000h base + 0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
LOCK
-
PLL_SEL
Reserved
BYPASS
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
BYPASS_
CLK_SRC
ENABLE
POWERDOWN
Reserved
DIV_SELECT
W
Reset
0
0
1
1
0
0
0
0
0
1
1
0
0
0
1
1
CCM_ANALOG_PLL_ARMn field descriptions
Field
Description
31
LOCK
1 - PLL is currently locked.
0 - PLL is not currently locked.
30–20
-
Always set to zero (0).
19
PLL_SEL
Reserved
Table continues on the next page...
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
714
NXP Semiconductors

<!-- page 715 -->

CCM_ANALOG_PLL_ARMn field descriptions (continued)
Field
Description
18–17
-
This field is reserved.
Reserved
16
BYPASS
Bypass the PLL.
15–14
BYPASS_CLK_
SRC
Determines the bypass source.
NOTE: Changing the Bypass clock source also changes the PLL reference clock source.
0x0
REF_CLK_24M — Select the 24MHz oscillator as source.
0x1
CLK1 — Select the CLK1_N / CLK1_P as source.
0x2
Reserved —
0x3
Reserved —
13
ENABLE
Enable the clock output.
12
POWERDOWN
Powers down the PLL.
11–7
-
This field is reserved.
Reserved.
DIV_SELECT
This field controls the PLL loop divider. Valid range for divider value: 54-108. Fout = Fin * div_select/2.0.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
715

<!-- page 716 -->

18.7.2
Analog USB1 480MHz PLL Control Register
(CCM_ANALOG_PLL_USB1n)
The control register provides control for USBPHY0 480MHz PLL.
Address: 20C_8000h base + 10h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
LOCK
-
BYPASS
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
BYPASS_
CLK_SRC
ENABLE
POWER
-
EN_USB_CLKS
-
DIV_SELECT
W
Reset
0
0
1
0
0
0
0
0
0
0
0
0
0
0
0
0
CCM_ANALOG_PLL_USB1n field descriptions
Field
Description
31
LOCK
1 - PLL is currently locked.
0 - PLL is not currently locked.
30–17
-
Always set to zero (0).
16
BYPASS
Bypass the PLL.
Table continues on the next page...
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
716
NXP Semiconductors

<!-- page 717 -->

CCM_ANALOG_PLL_USB1n field descriptions (continued)
Field
Description
15–14
BYPASS_CLK_
SRC
Determines the bypass source.
0x0
REF_CLK_24M — Select the 24MHz oscillator as source.
0x1
CLK1 — Select the CLK1_N / CLK1_P as source.
0x2
GPANAIO —
0x3
CHRG_DET_B —
13
ENABLE
Enable the PLL clock output.
12
POWER
Powers up the PLL. This bit will be set automatically when USBPHY0 remote wakeup event happens.
11–7
-
Always set to zero (0).
6
EN_USB_CLKS
Powers the 9-phase PLL outputs for USBPHYn. Additionally, the UTMI clock gate must be deasserted in
the USBPHYn to enable USBn operation (clear CLKGATE bit in USBPHYn_CTRL). This bit will be set
automatically when USBPHYn remote wakeup event occurs.
0
PLL outputs for USBPHYn off.
1
PLL outputs for USBPHYn on.
5–2
-
Always set to zero (0).
DIV_SELECT
This field controls the PLL loop divider. 0 - Fout=Fref*20; 1 - Fout=Fref*22.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
717

<!-- page 718 -->

18.7.3
Analog USB2 480MHz PLL Control Register
(CCM_ANALOG_PLL_USB2n)
The control register provides control for USBPHY1 480MHz PLL.
Address: 20C_8000h base + 20h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
LOCK
-
BYPASS
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
BYPASS_
CLK_SRC
ENABLE
POWER
-
EN_USB_CLKS
-
DIV_SELECT
W
Reset
0
0
1
0
0
0
0
0
0
0
0
0
0
0
0
0
CCM_ANALOG_PLL_USB2n field descriptions
Field
Description
31
LOCK
1 - PLL is currently locked.
0 - PLL is not currently locked.
30–17
-
Always set to zero (0).
16
BYPASS
Bypass the PLL.
Table continues on the next page...
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
718
NXP Semiconductors

<!-- page 719 -->

CCM_ANALOG_PLL_USB2n field descriptions (continued)
Field
Description
15–14
BYPASS_CLK_
SRC
Determines the bypass source.
0x0
REF_CLK_24M — Select the 24MHz oscillator as source.
0x1
CLK1 — Select the CLK1_N / CLK1_P as source.
0x2
Reserved —
0x3
Reserved —
13
ENABLE
Enable the PLL clock output.
12
POWER
Powers up the PLL. This bit will be set automatically when USBPHY1 remote wakeup event happens.
11–7
-
Always set to zero (0).
6
EN_USB_CLKS
0: 8-phase PLL outputs for USBPHY1 are powered down. If set to 1, 8-phase PLL outputs for USBPHY1
are powered up. Additionally, the utmi clock gate must be deasserted in the USBPHY1 to enable USB0
operation (clear CLKGATE bit in USBPHY1_CTRL).This bit will be set automatically when USBPHY1
remote wakeup event happens.
5–2
-
Always set to zero (0).
DIV_SELECT
This field controls the PLL loop divider. 0 - Fout=Fref*20; 1 - Fout=Fref*22.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
719

<!-- page 720 -->

18.7.4
Analog System PLL Control Register
(CCM_ANALOG_PLL_SYSn)
The control register provides control for the 528MHz PLL.
Address: 20C_8000h base + 30h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
LOCK
-
PFD_OFFSET_EN
Reserved
BYPASS
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
720
NXP Semiconductors

<!-- page 721 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
BYPASS_
CLK_SRC
ENABLE
POWERDOWN
Reserved
-
DIV_SELECT
W
Reset
0
0
1
1
0
0
0
0
0
0
0
0
0
0
0
1
CCM_ANALOG_PLL_SYSn field descriptions
Field
Description
31
LOCK
1 - PLL is currently locked; 0 - PLL is not currently locked.
30–19
-
Always set to zero (0).
18
PFD_OFFSET_
EN
Enables an offset in the phase frequency detector.
17
-
This field is reserved.
Reserved
16
BYPASS
Bypass the PLL.
15–14
BYPASS_CLK_
SRC
Determines the bypass source.
0x0
REF_CLK_24M — Select the 24MHz oscillator as source.
0x1
CLK1 — Select the CLK1_N / CLK1_P as source.
0x2
GPANAIO —
0x3
CHRG_DET_B —
13
ENABLE
Enable PLL output
12
POWERDOWN
Powers down the PLL.
11–7
-
This field is reserved.
Reserved.
6–1
-
Always set to zero (0).
0
DIV_SELECT
This field controls the PLL loop divider. 0 - Fout=Fref*20; 1 - Fout=Fref*22.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
721

<!-- page 722 -->

18.7.5
528MHz System PLL Spread Spectrum Register
(CCM_ANALOG_PLL_SYS_SS)
This register contains the 528 PLL spread spectrum controls.
Address: 20C_8000h base + 40h offset = 20C_8040h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
STOP
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
ENABLE
STEP
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
CCM_ANALOG_PLL_SYS_SS field descriptions
Field
Description
31–16
STOP
Frequency change = stop/CCM_ANALOG_PLL_SYS_DENOM[B]*24MHz.
15
ENABLE
Enable bit
0
— Spread spectrum modulation disabled
1
— Soread spectrum modulation enabled
STEP
Frequency change step = step/CCM_ANALOG_PLL_SYS_DENOM[B]*24MHz.
18.7.6
Numerator of 528MHz System PLL Fractional Loop Divider
Register (CCM_ANALOG_PLL_SYS_NUM)
This register contains the numerator of 528MHz PLL fractional loop divider (signed
number).
Absoulte value should be less than denominator
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
722
NXP Semiconductors

<!-- page 723 -->

Address: 20C_8000h base + 50h offset = 20C_8050h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
A
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
CCM_ANALOG_PLL_SYS_NUM field descriptions
Field
Description
31–30
-
Always set to zero (0).
A
30 bit numerator (A) of fractional loop divider (signed integer).
18.7.7
Denominator of 528MHz System PLL Fractional Loop
Divider Register (CCM_ANALOG_PLL_SYS_DENOM)
This register contains the Denominator of 528MHz PLL fractional loop divider.
Address: 20C_8000h base + 60h offset = 20C_8060h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
B
W
Reset 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
0
0
1
0
CCM_ANALOG_PLL_SYS_DENOM field descriptions
Field
Description
31–30
-
Always set to zero (0).
B
30 bit Denominator (B) of fractional loop divider (unsigned integer).
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
723

<!-- page 724 -->

18.7.8
Analog Audio PLL control Register
(CCM_ANALOG_PLL_AUDIOn)
The control register provides control for the audio PLL.
Address: 20C_8000h base + 70h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
LOCK
-
Reserved
POST_DIV_
SELECT
PFD_OFFSET_EN
Reserved
BYPASS
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
724
NXP Semiconductors

<!-- page 725 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
BYPASS_
CLK_SRC
ENABLE
POWERDOWN
Reserved
DIV_SELECT
W
Reset
0
0
0
1
0
0
0
0
0
0
0
0
0
1
1
0
CCM_ANALOG_PLL_AUDIOn field descriptions
Field
Description
31
LOCK
1 - PLL is currently locked.
0 - PLL is not currently locked.
30–22
-
Always set to zero (0).
21
-
This field is reserved.
Reserved
20–19
POST_DIV_
SELECT
These bits implement a divider after the PLL, but before the enable and bypass mux.
00
— Divide by 4.
01
— Divide by 2.
10
— Divide by 1.
11
— Reserved
18
PFD_OFFSET_
EN
Enables an offset in the phase frequency detector.
17
-
This field is reserved.
Revsered
16
BYPASS
Bypass the PLL.
15–14
BYPASS_CLK_
SRC
Determines the bypass source.
0x0
REF_CLK_24M — Select the 24MHz oscillator as source.
0x1
CLK1 — Select the CLK1_N / CLK1_P as source.
0x2
Reserved —
0x3
Reserved —
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
725

<!-- page 726 -->

CCM_ANALOG_PLL_AUDIOn field descriptions (continued)
Field
Description
13
ENABLE
Enable PLL output
12
POWERDOWN
Powers down the PLL.
11–7
-
This field is reserved.
Reserved.
DIV_SELECT
This field controls the PLL loop divider. Valid range for DIV_SELECT divider value: 27~54.
18.7.9
Numerator of Audio PLL Fractional Loop Divider Register
(CCM_ANALOG_PLL_AUDIO_NUM)
This register contains the numerator (A) of Audio PLL fractional loop divider.(Signed
number), absolute value should be less than denominator
Absolute value should be less than denominator
Address: 20C_8000h base + 80h offset = 20C_8080h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
A
W
Reset 0
0
0
0
0
1
0
1
1
1
1
1
0
1
0
1
1
1
1
0
0
0
0
1
0
0
0
0
0
0
0
0
CCM_ANALOG_PLL_AUDIO_NUM field descriptions
Field
Description
31–30
-
Always set to zero (0).
A
30 bit numerator of fractional loop divider.
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
726
NXP Semiconductors

<!-- page 727 -->

18.7.10
Denominator of Audio PLL Fractional Loop Divider
Register (CCM_ANALOG_PLL_AUDIO_DENOM)
This register contains the Denominator (B) of Audio PLL fractional loop divider.
(unsigned number)
Address: 20C_8000h base + 90h offset = 20C_8090h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
B
W
Reset 0
0
1
0
1
0
0
1
0
1
1
0
0
1
0
0
0
1
1
0
0
0
0
1
1
0
0
1
1
1
0
0
CCM_ANALOG_PLL_AUDIO_DENOM field descriptions
Field
Description
31–30
-
Always set to zero (0).
B
30 bit Denominator of fractional loop divider.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
727

<!-- page 728 -->

18.7.11
Analog Video PLL control Register
(CCM_ANALOG_PLL_VIDEOn)
The control register provides control for the Video PLL.
Address: 20C_8000h base + A0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
LOCK
-
Reserved
POST_DIV_
SELECT
PFD_OFFSET_EN
Reserved
BYPASS
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
728
NXP Semiconductors

<!-- page 729 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
BYPASS_
CLK_SRC
ENABLE
POWERDOWN
Reserved
DIV_SELECT
W
Reset
0
0
0
1
0
0
0
0
0
0
0
0
1
1
0
0
CCM_ANALOG_PLL_VIDEOn field descriptions
Field
Description
31
LOCK
1 - PLL is currently locked;
0 - PLL is not currently locked.
30–22
-
Always set to zero (0).
21
-
This field is reserved.
Revserved
20–19
POST_DIV_
SELECT
These bits implement a divider after the PLL, but before the enable and bypass mux.
00
— Divide by 4.
01
— Divide by 2.
10
— Divide by 1.
11
— Reserved
18
PFD_OFFSET_
EN
Enables an offset in the phase frequency detector.
17
-
This field is reserved.
Reserved
16
BYPASS
Bypass the PLL.
15–14
BYPASS_CLK_
SRC
Determines the bypass source.
0x0
REF_CLK_24M — Select the 24MHz oscillator as source.
0x1
CLK1 — Select the CLK1_N / CLK1_P as source.
0x2
Reserved —
0x3
Reserved —
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
729

<!-- page 730 -->

CCM_ANALOG_PLL_VIDEOn field descriptions (continued)
Field
Description
13
ENABLE
Enalbe PLL output
12
POWERDOWN
Powers down the PLL.
11–7
-
This field is reserved.
Reserved.
DIV_SELECT
This field controls the PLL loop divider. Valid range for DIV_SELECT divider value: 27~54.
18.7.12
Numerator of Video PLL Fractional Loop Divider Register
(CCM_ANALOG_PLL_VIDEO_NUM)
This register contains the numerator (A) of Video PLL fractional loop divider.(Signed
number)
Absolute value should be less than denominator
Address: 20C_8000h base + B0h offset = 20C_80B0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
A
W
Reset 0
0
0
0
0
1
0
1
1
1
1
1
0
1
0
1
1
1
1
0
0
0
0
1
0
0
0
0
0
0
0
0
CCM_ANALOG_PLL_VIDEO_NUM field descriptions
Field
Description
31–30
-
Always set to zero (0).
A
30 bit numerator of fractional loop divider(Signed number), absolute value should be less than
denominator
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
730
NXP Semiconductors

<!-- page 731 -->

18.7.13
Denominator of Video PLL Fractional Loop Divider
Register (CCM_ANALOG_PLL_VIDEO_DENOM)
This register contains the Denominator (B) of Video PLL fractional loop divider.
(Unsigned number)
Address: 20C_8000h base + C0h offset = 20C_80C0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
-
B
W
Reset 0
0
0
1
0
0
0
0
1
0
1
0
0
0
1
0
0
1
0
0
0
1
0
0
0
1
0
0
0
1
1
1
CCM_ANALOG_PLL_VIDEO_DENOM field descriptions
Field
Description
31–30
-
Always set to zero (0).
B
30 bit Denominator of fractional loop divider.
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
731

<!-- page 732 -->

18.7.14
Analog ENET PLL Control Register
(CCM_ANALOG_PLL_ENETn)
The control register provides control for the ENET PLL.
Address: 20C_8000h base + E0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
LOCK
-
ENET_25M_REF_EN
ENET2_125M_EN
ENABLE_125M
PFD_OFFSET_EN
Reserved
BYPASS
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
1
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
732
NXP Semiconductors

<!-- page 733 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
BYPASS_
CLK_SRC
ENET1_125M_EN
POWERDOWN
Reserved
-
ENET1_DIV_SELECT
ENET0_DIV_SELECT
W
Reset
0
0
0
1
0
0
0
0
0
0
0
0
0
0
0
1
CCM_ANALOG_PLL_ENETn field descriptions
Field
Description
31
LOCK
1 - PLL is currently locked; 0 - PLL is not currently locked.
30–22
-
Always set to zero (0).
21
ENET_25M_
REF_EN
Enable the PLL providing ENET 25 MHz reference clock
20
ENET2_125M_
EN
Enable the PLL providing the ENET2 125 MHz reference clock
19
ENABLE_125M
Enables an offset in the phase frequency detector.
18
PFD_OFFSET_
EN
Enables an offset in the phase frequency detector.
17
-
This field is reserved.
Reserved
16
BYPASS
Bypass the PLL.
15–14
BYPASS_CLK_
SRC
Determines the bypass source.
0x0
REF_CLK_24M — Select the 24MHz oscillator as source.
0x1
CLK1 — Select the CLK1_N / CLK1_P as source.
0x2
Reserved —
0x3
Reserved —
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
733

<!-- page 734 -->

CCM_ANALOG_PLL_ENETn field descriptions (continued)
Field
Description
13
ENET1_125M_
EN
Enable the PLL providing the ENET1 125 MHz reference clock.
12
POWERDOWN
Powers down the PLL.
11–7
-
This field is reserved.
Reserved.
6–4
-
Always set to zero (0).
3–2
ENET1_DIV_
SELECT
Controls the frequency of the ethernet1 reference clock.
00
25MHz
01
50MHz
10
100MHz (not 50% duty cycle)
11
125MHz
ENET0_DIV_
SELECT
Controls the frequency of the ethernet0 reference clock.
00
25MHz
01
50MHz
10
100MHz (not 50% duty cycle)
11
125MHz
18.7.15
480MHz Clock (PLL3) Phase Fractional Divider Control
Register (CCM_ANALOG_PFD_480n)
The PFD_480 control register provides control for PFD clock generation.
This register controls the 4-phase fractional clock dividers. The fractional clock
frequencies are a product of the values in these registers.
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
734
NXP Semiconductors

<!-- page 735 -->

Address: 20C_8000h base + F0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
PFD3_CLKGATE
PFD3_STABLE
PFD3_FRAC
PFD2_CLKGATE
PFD2_STABLE
PFD2_FRAC
W
Reset
0
0
0
1
0
0
1
1
0
0
0
1
0
0
0
1
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
PFD1_CLKGATE
PFD1_STABLE
PFD1_FRAC
PFD0_CLKGATE
PFD0_STABLE
PFD0_FRAC
W
Reset
0
0
0
1
0
0
0
0
0
0
0
0
1
1
0
0
CCM_ANALOG_PFD_480n field descriptions
Field
Description
31
PFD3_CLKGATE
IO Clock Gate. If set to 1, the 3rd fractional divider clock (reference ref_pfd3) is off (power savings). 0:
ref_pfd3 fractional divider clock is enabled.
Need to assert this bit before PLL is powered down
30
PFD3_STABLE
This read-only bitfield is for DIAGNOSTIC PURPOSES ONLY since the fractional divider should become
stable quickly enough that this field will never need to be used by either device driver or application code.
The value inverts when the new programmed fractional divide value has taken effect. Read this bit,
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
735

<!-- page 736 -->

CCM_ANALOG_PFD_480n field descriptions (continued)
Field
Description
program the new value, and when this bit inverts, the phase divider clock output is stable. Note that the
value will not invert when the fractional divider is taken out of or placed into clock-gated state.
29–24
PFD3_FRAC
This field controls the fractional divide value. The resulting frequency shall be 480*18/PFD3_FRAC where
PFD3_FRAC is in the range 12-35.
23
PFD2_CLKGATE
IO Clock Gate. If set to 1, the IO fractional divider clock (reference ref_pfd2) is off (power savings). 0:
ref_pfd2 fractional divider clock is enabled.
Need to assert this bit before PLL is powered down
22
PFD2_STABLE
This read-only bitfield is for DIAGNOSTIC PURPOSES ONLY since the fractional divider should become
stable quickly enough that this field will never need to be used by either device driver or application code.
The value inverts when the new programmed fractional divide value has taken effect. Read this bit,
program the new value, and when this bit inverts, the phase divider clock output is stable. Note that the
value will not invert when the fractional divider is taken out of or placed into clock-gated state.
21–16
PFD2_FRAC
This field controls the fractional divide value. The resulting frequency shall be 480*18/PFD2_FRAC where
PFD2_FRAC is in the range 12-35.
15
PFD1_CLKGATE
IO Clock Gate. If set to 1, the IO fractional divider clock (reference ref_pfd1) is off (power savings). 0:
ref_pfd1 fractional divider clock is enabled.
Need to assert this bit before PLL is powered down
14
PFD1_STABLE
This read-only bitfield is for DIAGNOSTIC PURPOSES ONLY since the fractional divider should become
stable quickly enough that this field will never need to be used by either device driver or application code.
The value inverts when the new programmed fractional divide value has taken effect. Read this bit,
program the new value, and when this bit inverts, the phase divider clock output is stable. Note that the
value will not invert when the fractional divider is taken out of or placed into clock-gated state.
13–8
PFD1_FRAC
This field controls the fractional divide value. The resulting frequency shall be 480*18/PFD1_FRAC where
PFD1_FRAC is in the range 12-35.
7
PFD0_CLKGATE
If set to 1, the IO fractional divider clock (reference ref_pfd0) is off (power savings). 0: ref_pfd0 fractional
divider clock is enabled.
Need to assert this bit before PLL is powered down
6
PFD0_STABLE
This read-only bitfield is for DIAGNOSTIC PURPOSES ONLY since the fractional divider should become
stable quickly enough that this field will never need to be used by either device driver or application code.
The value inverts when the new programmed fractional divide value has taken effect. Read this bit,
program the new value, and when this bit inverts, the phase divider clock output is stable. Note that the
value will not invert when the fractional divider is taken out of or placed into clock-gated state.
PFD0_FRAC
This field controls the fractional divide value. The resulting frequency shall be 480*18/PFD0_FRAC where
PFD0_FRAC is in the range 12-35.
18.7.16
528MHz Clock (PLL2) Phase Fractional Divider Control
Register (CCM_ANALOG_PFD_528n)
The PFD_528 control register provides control for PFD clock generation.
This register controls the 3-phase fractional clock dividers. The fractional clock
frequencies are a product of the values in these registers.
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
736
NXP Semiconductors

<!-- page 737 -->

Address: 20C_8000h base + 100h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
PFD3_CLKGATE
PFD3_STABLE
PFD3_FRAC
PFD2_CLKGATE
PFD2_STABLE
PFD2_FRAC
W
Reset
0
0
0
1
0
0
0
0
0
0
0
1
1
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
PFD1_CLKGATE
PFD1_STABLE
PFD1_FRAC
PFD0_CLKGATE
PFD0_STABLE
PFD0_FRAC
W
Reset
0
0
0
1
0
0
0
0
0
0
0
1
1
0
1
1
CCM_ANALOG_PFD_528n field descriptions
Field
Description
31
PFD3_CLKGATE
IO Clock Gate. If set to 1, the 3rd fractional divider clock (reference ref_pfd3) is off (power savings). 0:
ref_pfd3 fractional divider clock is enabled.
Need to assert this bit before PLL powered down
30
PFD3_STABLE
This read-only bitfield is for DIAGNOSTIC PURPOSES ONLY since the fractional divider should become
stable quickly enough that this field will never need to be used by either device driver or application code.
The value inverts when the new programmed fractional divide value has taken effect. Read this bit,
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
737

<!-- page 738 -->

CCM_ANALOG_PFD_528n field descriptions (continued)
Field
Description
program the new value, and when this bit inverts, the phase divider clock output is stable. Note that the
value will not invert when the fractional divider is taken out of or placed into clock-gated state.
29–24
PFD3_FRAC
This field controls the fractional divide value. The resulting frequency shall be 528*18/PFD3_FRAC where
PFD3_FRAC is in the range 12-35.
23
PFD2_CLKGATE
IO Clock Gate. If set to 1, the IO fractional divider clock (reference ref_pfd2) is off (power savings). 0:
ref_pfd2 fractional divider clock is enabled.
Need to assert this bit before PLL powered down
22
PFD2_STABLE
This read-only bitfield is for DIAGNOSTIC PURPOSES ONLY since the fractional divider should become
stable quickly enough that this field will never need to be used by either device driver or application code.
The value inverts when the new programmed fractional divide value has taken effect. Read this bit,
program the new value, and when this bit inverts, the phase divider clock output is stable. Note that the
value will not invert when the fractional divider is taken out of or placed into clock-gated state.
21–16
PFD2_FRAC
This field controls the fractional divide value. The resulting frequency shall be 528*18/PFD2_FRAC where
PFD2_FRAC is in the range 12-35.
NOTE: The maximum allowed frequency of PFD2 is 400MHz
15
PFD1_CLKGATE
IO Clock Gate. If set to 1, the IO fractional divider clock (reference ref_pfd1) is off (power savings). 0:
ref_pfd1 fractional divider clock is enabled.
Need to assert this bit before PLL powered down
14
PFD1_STABLE
This read-only bitfield is for DIAGNOSTIC PURPOSES ONLY since the fractional divider should become
stable quickly enough that this field will never need to be used by either device driver or application code.
The value inverts when the new programmed fractional divide value has taken effect. Read this bit,
program the new value, and when this bit inverts, the phase divider clock output is stable. Note that the
value will not invert when the fractional divider is taken out of or placed into clock-gated state.
13–8
PFD1_FRAC
This field controls the fractional divide value. The resulting frequency shall be 528*18/PFD1_FRAC where
PFD1_FRAC is in the range 12-35.
7
PFD0_CLKGATE
If set to 1, the IO fractional divider clock (reference ref_pfd0) is off (power savings). 0: ref_pfd0 fractional
divider clock is enabled.
Need to assert this bit before PLL powered down
6
PFD0_STABLE
This read-only bitfield is for DIAGNOSTIC PURPOSES ONLY since the fractional divider should become
stable quickly enough that this field will never need to be used by either device driver or application code.
The value inverts when the new programmed fractional divide value has taken effect. Read this bit,
program the new value, and when this bit inverts, the phase divider clock output is stable. Note that the
value will not invert when the fractional divider is taken out of or placed into clock-gated state.
PFD0_FRAC
This field controls the fractional divide value. The resulting frequency shall be 528*18/PFD0_FRAC where
PFD0_FRAC is in the range 12-35.
NOTE: For QSPI boot at 76 MHz, this PFD is relocked to 307MHz, so the default value for this field
(modified by ROM) would be 0x1f. Also for Low Freq Boot, ROM will relock this PFD to 307MHz,
hence default would be 0x1f.
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
738
NXP Semiconductors

<!-- page 739 -->

18.7.17
Miscellaneous Register 0 (CCM_ANALOG_MISC0n)
This register defines the control and status bits for miscellaneous analog blocks.
Address: 20C_8000h base + 150h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
VID_PLL_PREDIV
XTAL_24M_PWD
RTC_XTAL_SOURCE
CLKGATE_DELAY
CLKGATE_CTRL
Reserved
OSC_XTALOK_EN
W
Reset
0
0
0
0
0
1
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
OSC_XTALOK
OSC_I
DISCON_HIGH_SNVS
STOP_
MODE_
CONFIG
Reserved
REFTOP_VBGUP
REFTOP_VBGADJ
REFTOP_SELFBIASOFF
Reserved
REFTOP_PWD
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
739

<!-- page 740 -->

CCM_ANALOG_MISC0n field descriptions
Field
Description
31
VID_PLL_
PREDIV
Predivider for the source clock of the PLL's.
0
Divide by 1
1
Divide by 2
30
XTAL_24M_PWD
This field powers down the 24M crystal oscillator if set true.
NOTE: Not related to CCM. See Crystal Oscillator (XTALOSC)
29
RTC_XTAL_
SOURCE
This field indicates which chip source is being used for the rtc clock.
NOTE: Not related to CCM. See Crystal Oscillator (XTALOSC)
0
Internal ring oscillator
1
RTC_XTAL
28–26
CLKGATE_
DELAY
This field specifies the delay between powering up the XTAL 24MHz clock and releasing the clock to the
digital logic inside the analog block.
NOTE: Do not change the field during a low power event. This is not a field that the user would normally
need to modify.
NOTE: Not related to CCM. See Crystal Oscillator (XTALOSC)
000
0.5ms
001
1.0ms
010
2.0ms
011
3.0ms
100
4.0ms
101
5.0ms
110
6.0ms
111
7.0ms
25
CLKGATE_CTRL This bit allows disabling the clock gate (always ungated) for the xtal 24MHz clock that clocks the digital
logic in the analog block.
NOTE: Do not change the field during a low power event. This is not a field that the user would normally
need to modify.
NOTE: Not related to CCM. See Crystal Oscillator (XTALOSC)
0
ALLOW_AUTO_GATE — Allow the logic to automatically gate the clock when the XTAL is powered
down.
1
NO_AUTO_GATE — Prevent the logic from ever gating off the clock.
24–17
-
This field is reserved.
Always set to zero.
16
OSC_XTALOK_
EN
This bit enables the detector that signals when the 24MHz crystal oscillator is stable.
NOTE: Not related to CCM. See Crystal Oscillator (XTALOSC)
15
OSC_XTALOK
Status bit that signals that the output of the 24-MHz crystal oscillator is stable. Generated from a timer and
active detection of the actual frequency.
NOTE: Not related to CCM. See Crystal Oscillator (XTALOSC)
Table continues on the next page...
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
740
NXP Semiconductors

<!-- page 741 -->

CCM_ANALOG_MISC0n field descriptions (continued)
Field
Description
14–13
OSC_I
This field determines the bias current in the 24MHz oscillator. The aim is to start up with the highest bias
current, which can be decreased after startup if it is determined to be acceptable.
NOTE: Not related to CCM. See Crystal Oscillator (XTALOSC)
00
NOMINAL — Nominal
01
MINUS_12_5_PERCENT — Decrease current by 12.5%
10
MINUS_25_PERCENT — Decrease current by 25.0%
11
MINUS_37_5_PERCENT — Decrease current by 37.5%
12
DISCON_HIGH_
SNVS
This bit controls a switch from VDD_HIGH_IN to VDD_SNVS_IN.
0
Turn on the switch
1
Turn off the switch
11–10
STOP_MODE_
CONFIG
Configure the analog behavior in stop mode.
00
All analog except rtc powered down on stop mode assertion. XtalOsc=on, RCOsc=off;
01
Certain analog functions such as certain regulators left up. XtalOsc=on, RCOsc=off;
10
XtalOsc=off, RCOsc=on, Old BG=on, New BG=off.
11
XtalOsc=off, RCOsc=on, Old BG=off, New BG=on.
9–8
-
This field is reserved.
Reserved
7
REFTOP_
VBGUP
Status bit that signals the analog bandgap voltage is up and stable. 1 - Stable.
NOTE: Not related to CCM. See Power Management Unit (PMU)
6–4
REFTOP_
VBGADJ
NOTE: Not related to CCM. See Power Management Unit (PMU)
000
Nominal VBG
001
VBG+0.78%
010
VBG+1.56%
011
VBG+2.34%
100
VBG-0.78%
101
VBG-1.56%
110
VBG-2.34%
111
VBG-3.12%
3
REFTOP_
SELFBIASOFF
Control bit to disable the self-bias circuit in the analog bandgap. The self-bias circuit is used by the
bandgap during startup. This bit should be set after the bandgap has stabilized and is necessary for best
noise performance of analog blocks using the outputs of the bandgap.
NOTE: Value should be returned to zero before removing vddhigh_in or asserting bit 0 of this register
(REFTOP_PWD) to assure proper restart of the circuit.
NOTE: Not related to CCM. See Power Management Unit (PMU)
0
Uses coarse bias currents for startup
1
Uses bandgap-based bias currents for best performance.
2–1
-
This field is reserved.
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
741

<!-- page 742 -->

CCM_ANALOG_MISC0n field descriptions (continued)
Field
Description
0
REFTOP_PWD
Control bit to power-down the analog bandgap reference circuitry.
NOTE: A note of caution, the bandgap is necessary for correct operation of most of the LDO, PLL, and
other analog functions on the die.
NOTE: Not related to CCM. See Power Management Unit (PMU)
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
742
NXP Semiconductors

<!-- page 743 -->

18.7.18
Miscellaneous Register 1 (CCM_ANALOG_MISC1n)
This register defines the control and status bits for miscellaneous analog blocks.
Address: 20C_8000h base + 160h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
IRQ_DIG_BO
IRQ_ANA_BO
IRQ_TEMPHIGH
IRQ_TEMPLOW
IRQ_TEMPPANIC
Reserved
PFD_528_AUTOGATE_EN
PFD_480_AUTOGATE_EN
W
w1c
w1c
w1c
w1c
w1c
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
Reserved
LVDSCLK1_IBEN
Reserved
LVDSCLK1_OBEN
Reserved
LVDS1_CLK_SEL
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
743

<!-- page 744 -->

CCM_ANALOG_MISC1n field descriptions
Field
Description
31
IRQ_DIG_BO
This status bit is set to one when when any of the digital regulator brownout interrupts assert. Check the
regulator status bits to discover which regulator interrupt asserted.
NOTE: Not related to CCM. See Power Management Unit (PMU)
30
IRQ_ANA_BO
This status bit is set to one when when any of the analog regulator brownout interrupts assert. Check the
regulator status bits to discover which regulator interrupt asserted.
NOTE: Not related to CCM. See Power Management Unit (PMU)
29
IRQ_TEMPHIGH This status bit is set to one when the temperature sensor high interrupt asserts for high temperature.
NOTE: Not related to CCM. See Temperature Monitor (TEMPMON)
28
IRQ_TEMPLOW This status bit is set to one when the temperature sensor low interrupt asserts for low temperature.
NOTE: Not related to CCM. See Temperature Monitor (TEMPMON)
27
IRQ_
TEMPPANIC
This status bit is set to one when the temperature sensor panic interrupt asserts for a panic high
temperature.
NOTE: Not related to CCM. See Temperature Monitor (TEMPMON)
26–18
-
This field is reserved.
Reserved
17
PFD_528_
AUTOGATE_EN
This enables a feature that will clkgate (reset) all PFD_528 clocks anytime the PLL_528 is unlocked or
powered off.
16
PFD_480_
AUTOGATE_EN
This enables a feature that will clkgate (reset) all PFD_480 clocks anytime the USB1_PLL_480 is
unlocked or powered off.
15–14
-
This field is reserved.
Reserved
13
-
This field is reserved.
Reserved
12
LVDSCLK1_
IBEN
This enables the LVDS input buffer for anaclk1/1b. Do not enable input and output buffers simultaneously.
11
-
This field is reserved.
Reserved
10
LVDSCLK1_
OBEN
This enables the LVDS output buffer for anaclk1/1b. Do not enable input and output buffers
simultaneously.
9–5
-
This field is reserved.
Reserved
LVDS1_CLK_
SEL
This field selects the clk to be routed to anaclk1/1b.
00000
ARM_PLL — Arm PLL
00001
SYS_PLL — System PLL
00010
PFD4 — ref_pfd4_clk == pll2_pfd0_clk
Table continues on the next page...
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
744
NXP Semiconductors

<!-- page 745 -->

CCM_ANALOG_MISC1n field descriptions (continued)
Field
Description
00011
PFD5 — ref_pfd5_clk == pll2_pfd1_clk
00100
PFD6 — ref_pfd6_clk == pll2_pfd2_clk
00101
PFD7 — ref_pfd7_clk == pll2_pfd3_clk
00110
AUDIO_PLL — Audio PLL
00111
VIDEO_PLL — Video PLL
01001
ETHERNET_REF — ethernet ref clock (ENET_PLL)
01100
USB1_PLL — USB1 PLL clock
01101
USB2_PLL — USB2 PLL clock
01110
PFD0 — ref_pfd0_clk == pll3_pfd0_clk
01111
PFD1 — ref_pfd1_clk == pll3_pfd1_clk
10000
PFD2 — ref_pfd2_clk == pll3_pfd2_clk
10001
PFD3 — ref_pfd3_clk == pll3_pfd3_clk
10010
XTAL — xtal (24M)
10101 to 11111
ref_pfd7_clk == pll2_pfd3_clk
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
745

<!-- page 746 -->

18.7.19
Miscellaneous Register 2 (CCM_ANALOG_MISC2n)
This register defines the control for miscellaneous analog blocks.
NOTE
This register is shared with PMU.
Address: 20C_8000h base + 170h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
VIDEO_DIV
REG2_STEP_TIME
REG1_STEP_TIME
REG0_STEP_TIME
AUDIO_DIV_MSB
REG2_OK
REG2_ENABLE_BO
Reserved
REG2_BO_STATUS
REG2_BO_OFFSET
W
Reset
0
0
0
0
0
0
0
0
0
0
1
0
0
1
1
1
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
746
NXP Semiconductors

<!-- page 747 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
AUDIO_DIV_LSB
REG1_OK
REG1_ENABLE_BO
Reserved
REG1_BO_STATUS
REG1_BO_OFFSET
PLL3_disable
REG0_OK
REG0_ENABLE_BO
Reserved
REG0_BO_STATUS
REG0_BO_OFFSET
W
Reset
0
0
1
0
0
1
1
1
0
0
1
0
0
1
1
1
CCM_ANALOG_MISC2n field descriptions
Field
Description
31–30
VIDEO_DIV
Post-divider for video. The output clock of the video PLL should be gated prior to changing this divider to
prevent glitches. This divider is feed by PLL_VIDEOn[POST_DIV_SELECT] to achieve division ratios
of /1, /2, /4, /8, and /16.
00
divide by 1 (Default)
01
divide by 2
10
divide by 1
11
divide by 4
29–28
REG2_STEP_
TIME
Number of clock periods (24MHz clock).
NOTE: Not related to CCM. See Power Management Unit (PMU)
00
64_CLOCKS — 64
01
128_CLOCKS — 128
10
256_CLOCKS — 256
11
512_CLOCKS — 512
27–26
REG1_STEP_
TIME
Number of clock periods (24MHz clock).
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
747

<!-- page 748 -->

CCM_ANALOG_MISC2n field descriptions (continued)
Field
Description
NOTE: Not related to CCM. See Power Management Unit (PMU)
00
64_CLOCKS — 64
01
128_CLOCKS — 128
10
256_CLOCKS — 256
11
512_CLOCKS — 512
25–24
REG0_STEP_
TIME
Number of clock periods (24MHz clock).
NOTE: Not related to CCM. See Power Management Unit (PMU)
00
64_CLOCKS — 64
01
128_CLOCKS — 128
10
256_CLOCKS — 256
11
512_CLOCKS — 512
23
AUDIO_DIV_
MSB
MSB of Post-divider for Audio PLL. The output clock of the video PLL should be gated prior to changing
this divider to prevent glitches. This divider is feed by PLL_AUDIOn[POST_DIV_SELECT] to achieve
division ratios of /1, /2, /4, /8, and /16.
NOTE: MSB bit value pertains to the first bit, please program the LSB bit (bit 15) as well to change
divider value for more information.
00
divide by 1 (Default)
01
divide by 2
10
divide by 1
11
divide by 4
22
REG2_OK
Signals that the voltage is above the brownout level for the SOC supply. 1 = regulator output >
brownout_target
NOTE: Not related to CCM. See Power Management Unit (PMU)
21
REG2_ENABLE_
BO
Enables the brownout detection.
NOTE: Not related to CCM. See Power Management Unit (PMU)
20
-
This field is reserved.
19
REG2_BO_
STATUS
Reg2 brownout status bit.
NOTE: Not related to CCM. See Power Management Unit (PMU)
18–16
REG2_BO_
OFFSET
This field defines the brown out voltage offset for the xPU power domain. IRQ_DIG_BO is also asserted.
Single-bit increments reflect 25mV brownout voltage steps. The reset brown-offset is 175mV below the
programmed target code. Brownout target = OUTPUT_TRG - BO_OFFSET. Some steps may be
irrelevant because of input supply limitations or load operation.
NOTE: Not related to CCM. See Power Management Unit (PMU)
100
Brownout offset = 0.100V
111
Brownout offset = 0.175V
Table continues on the next page...
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
748
NXP Semiconductors

<!-- page 749 -->

CCM_ANALOG_MISC2n field descriptions (continued)
Field
Description
15
AUDIO_DIV_LSB
LSB of Post-divider for Audio PLL. The output clock of the video PLL should be gated prior to changing
this divider to prevent glitches. This divider is feed by PLL_AUDIOn[POST_DIV_SELECT] to achieve
division ratios of /1, /2, /4, /8, and /16.
NOTE: LSB bit value pertains to the last bit, please program the MSB bit (bit 23) as well, to change
divider value for more information.
00
divide by 1 (Default)
01
divide by 2
10
divide by 1
11
divide by 4
14
REG1_OK
GPU/VPU supply
NOTE: Not related to CCM. See Power Management Unit (PMU)
13
REG1_ENABLE_
BO
Enables the brownout detection.
NOTE: Not related to CCM. See Power Management Unit (PMU)
12
-
This field is reserved.
11
REG1_BO_
STATUS
Reg1 brownout status bit.
NOTE: Not related to CCM. See Power Management Unit (PMU)
1
Brownout, supply is below target minus brownout offset.
10–8
REG1_BO_
OFFSET
This field defines the brown out voltage offset for the xPU power domain. IRQ_DIG_BO is also asserted.
Single-bit increments reflect 25mV brownout voltage steps. The reset brown-offset is 175mV below the
programmed target code. Brownout target = OUTPUT_TRG - BO_OFFSET. Some steps may be
irrelevant because of input supply limitations or load operation.
NOTE: Not related to CCM. See Power Management Unit (PMU)
100
Brownout offset = 0.100V
111
Brownout offset = 0.175V
7
PLL3_disable
When USB is in low power suspend mode this Control bit is used to indicate if other system peripherals
require the USB PLL3 clock when the SoC is not in low power mode. A user needs to set this bit if they
want to optionally disable PLL3 while the SoC is not in any low power mode to save power. When the
system does go into low power mode this bit setting would not have any affect.
NOTE: When USB is in low power suspend mode users would need to ensure PLL3 is not being used
before setting this bit in RUN mode. Please refer to the correct PLL disabling procedure in
Disabling / Enabling PLLs
0
PLL3 is being used by peripherals and is enabled when SoC is not in any low power mode
1
PLL3 can be disabled when the SoC is not in any low power mode
6
REG0_OK
ARM supply
NOTE: Not related to CCM. See Power Management Unit (PMU)
Table continues on the next page...
Chapter 18 Clock Controller Module (CCM)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
749

<!-- page 750 -->

CCM_ANALOG_MISC2n field descriptions (continued)
Field
Description
5
REG0_ENABLE_
BO
Enables the brownout detection.
NOTE: Not related to CCM. See Power Management Unit (PMU)
4
-
This field is reserved.
3
REG0_BO_
STATUS
Reg0 brownout status bit.
NOTE: Not related to CCM. See Power Management Unit (PMU)
1
Brownout, supply is below target minus brownout offset.
REG0_BO_
OFFSET
This field defines the brown out voltage offset for the CORE power domain. IRQ_DIG_BO is also
asserted. Single-bit increments reflect 25mV brownout voltage steps. Some steps may be irrelevant
because of input supply limitations or load operation.
NOTE: Not related to CCM. See Power Management Unit (PMU)
100
Brownout offset = 0.100V
111
Brownout offset = 0.175V
CCM Analog Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
750
NXP Semiconductors

