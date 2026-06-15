# Chapter 32: IOMUX Controller (IOMUXC)

> Nguồn: `IMX6ULLRM.pdf` — trang 1469–2110

<!-- page 1469 -->

Chapter 32
IOMUX Controller (IOMUXC)
32.1
Overview
The IOMUX Controller (IOMUXC), together with the IOMUX, enables the IC to share
one pad to several functional blocks. This sharing is done by multiplexing the pad's input
and output signals.
Every module requires a specific pad setting (such as pull up or keeper), and for each
pad, there are up to 8 muxing options (called ALT modes). The pad settings parameters
are controlled by the IOMUXC.
The IOMUX consists only of combinatorial logic combined from several basic IOMUX
cells. Each basic IOMUX cell handles only one pad signal's muxing.
Figure 32-1 illustrates the IOMUX/IOMUXC connectivity in the system.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1469

<!-- page 1470 -->

PAD Settings
Registers
MUX Control
Registers
IOMUXC
IOMUX
Cells
IO Pad
Cells
IOMUX
IORING
.
.
.
.
.
.
HW
signal
moduleY
CFG
Reg
moduleX
IPMUX
AIPS
module
#1
module
#2
module
#N
Arm PLATFORM + AHBMAX
PAD Settings
Figure 32-1. IOMUX SoC Level Block Diagram
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1470
NXP Semiconductors

<!-- page 1471 -->

32.1.1
Features
The IOMUXC features are:
• 32-bit software mux control registers (IOMUXC_SW_MUX_CTL_PAD_<PAD
NAME> or IOMUXC_SW_MUX_CTL_GRP_<GROUP NAME>) to configure 1 of
8 alternate (ALT) MUX_MODE feilds of each pad or a predefined group of pads and
to enable the forcing of an input path of the pad(s) (SION bit).
• 32-bit software pad control registers
(IOMUXC_SW_PAD_CTL_PAD_<PAD_NAME> or
IOMUXC_SW_PAD_CTL_GRP_<GROUP NAME>) to configure specific pad
settings of each pad, or a predefined group of pads.
• 32-bit general purpose registers - 14 (GPR0 to GPR13) 32-bit registers according to
SoC requirements for any usage.
• 32-bit input select control registers to control the input path to a module when more
than one pad drives this module input.
Each SW MUX/PAD CTL IOMUXC register handles only one pad or one pad's group.
Only the minimum number of registers required by software are implemented by
hardware. For example, if only ALT0 and ALT1 modes are used on Pad x then only one
bit register will be generated as the MUX_MODE control field in the software mux
control register of Pad x.
The software mux control registers may allow the forcing of pads to become input (input
path enabled) regardless of the functional direction driven. This may be useful for
loopback and GPIO data capture.
32.2
Clocks
The table found here describes the clock sources for IOMUXC.
Please see Clock Controller Module (CCM) for clock setting, configuration and gating
information.
Table 32-1. IOMUXC Clocks
Clock name
Clock Root
Description
ipt_clk_io
IO clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1471

<!-- page 1472 -->

32.3
Functional description
This section provides a complete functional description of the block.
The IOMUXC consists of two sub-blocks:
• IOMUXC_REGISTERS includes all of the IOMUXC registers (see Features).
• IOMUXC_LOGIC includes all of the IOMUXC combinatorial logic (IP interface
controls, address decoder, observability muxes).
The IOMUX consists of a number (about the number of pads in the SoC) of basic
iomux_cell units. If only one functional mode is required for a specific pad, there is no
need for IOMUX and the signals can be connected directly from the module to the I/O.
The IOMUX cell is required whenever two or more functional modes are required for a
specific pad or when one functional mode and the one test mode are required.
The basic iomux_cell design, which allows two levels of HW signal control (in ALT6
and ALT7 modes - ALT7 gets highest priority) is shown in Figure 32-2.
PAD0
PAD1
SW_PAD_CTL
DATA_IN
SW_PAD_CTL
ALT0
ALT1
ALTn
ALT0
ALT1
ALTn
ALT0
ALT1
ALTn
ALT0
ALT1
ALTn
:
:
:
:
Peripheral1
:
:
:
:
<SOURCE>_SELECT_INPUT
 IOMUXC_SW_MUX_CTRL_<PAD>[MUX_MODE]
 IOMUXC_SW_MUX_CTRL_<PAD>[MUX_MODE]
Figure 32-2. IOMUX Cell Block Diagram
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1472
NXP Semiconductors

<!-- page 1473 -->

32.3.1
ALT6 and ALT7 extended muxing modes
The ALT7 and ALT6 extended muxing modes allow any signal in the system (such as
fuse, pad input, JTAG, or software register) to override any software configuration and to
force the ALT6/ALT7 muxing mode.
It also allows an IOMUX software register to control a group of pads.
32.3.2
SW Loopback through SION bit
A limited option exists to override the default pad functionality and force the input path
to be active (ipp_ibe==1'b1) regardless of the value driven by the corresponding module.
This can be done by setting the SION (Software Input On) bit in the
IOMUXC_SW_MUX_CTL register (when available) to "1".
Uses include:
• LoopBack - Module x drives the pad and also receives pad value as an input.
• GPIO Capture - Module x drives the pad and the value is captured by GPIO.
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1473

<!-- page 1474 -->

32.3.3
Daisy chain - multi pads driving same module input pin
In some cases, more than one pad may drive a single module input pin. Such cases
require the addition of one more level of IOMUXing; all of these input signals are
muxed, and a dedicated software controlled register controls the mux in order to select
the required input path.
A module port involved in "daisy chain" requires two software configuration commands,
one for selecting the mode for this pad (programable via the
IOMUXC_SW_MUX_CTL_<PAD> registers) and one for defining it as the input path
(via the daisy chain registers).
This means that a module port involved in "daisy chain" requires two software
configuration commands, one for selecting the mode for this pad (programable via the
IOMUXC_SW_MUX_CTL_<PAD> registers) and one for defining it as the input path
(via the daisy chain registers). The daisy chain is illustrated in the figure below.
To module D
To module F
To module G
To module H
To module M
To module N
To module X
To module X
To module X
ALT x select
ALT x select
ALT x select
Daisy Chain
select
IOMUX Cells
A
B
C
IOMUX
IORING
Module X
Figure 32-3. Daisy chain illustration
IOMUXC GPR Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1474
NXP Semiconductors

<!-- page 1475 -->

32.4
IOMUXC GPR Memory Map/Register Definition
IOMUXC_GPR memory map
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
20E_4000
GPR0 General Purpose Register (IOMUXC_GPR_GPR0)
32
R/W
0000_0000h
32.4.1/1475
20E_4004
GPR1 General Purpose Register (IOMUXC_GPR_GPR1)
32
R/W
0F40_0005h
32.4.2/1478
20E_4008
GPR2 General Purpose Register (IOMUXC_GPR_GPR2)
32
R/W
0000_0000h
32.4.3/1481
20E_400C
GPR3 General Purpose Register (IOMUXC_GPR_GPR3)
32
R/W
0000_0FFFh
32.4.4/1484
20E_4010
GPR4 General Purpose Register (IOMUXC_GPR_GPR4)
32
R/W
0000_0000h
32.4.5/1487
20E_4014
GPR5 General Purpose Register (IOMUXC_GPR_GPR5)
32
R/W
0000_0000h
32.4.6/1490
20E_4024
GPR9 General Purpose Register (IOMUXC_GPR_GPR9)
32
R/W
0000_0000h
32.4.7/1493
20E_4028
GPR10 General Purpose Register (IOMUXC_GPR_GPR10)
32
R/W
0000_0007h
32.4.8/1494
20E_4038
GPR14 General Purpose Register (IOMUXC_GPR_GPR14)
32
R/W
0000_0000h
32.4.9/1495
32.4.1
GPR0 General Purpose Register (IOMUXC_GPR_GPR0)
GPR Register
Address: 20E_4000h base + 0h offset = 20E_4000h
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
DMAREQ_MUX_
SEL22
DMAREQ_MUX_
SEL21
DMAREQ_MUX_
SEL20
DMAREQ_MUX_
SEL19
DMAREQ_MUX_
SEL18
DMAREQ_MUX_
SEL17
DMAREQ_MUX_
SEL16
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
DMAREQ_MUX_
SEL15
DMAREQ_MUX_
SEL14
DMAREQ_MUX_
SEL13
DMAREQ_MUX_
SEL12
DMAREQ_MUX_
SEL11
DMAREQ_MUX_
SEL10
DMAREQ_MUX_
SEL9
DMAREQ_MUX_
SEL8
DMAREQ_MUX_
SEL7
DMAREQ_MUX_
SEL6
DMAREQ_MUX_
SEL5
DMAREQ_MUX_
SEL4
DMAREQ_MUX_
SEL3
DMAREQ_MUX_
SEL2
DMAREQ_MUX_
SEL1
DMAREQ_MUX_
SEL0
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
IOMUXC_GPR_GPR0 field descriptions
Field
Description
31–23
-
Reserved
This field is reserved.
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1475

<!-- page 1476 -->

IOMUXC_GPR_GPR0 field descriptions (continued)
Field
Description
22
DMAREQ_MUX_
SEL22
Reserved
21
DMAREQ_MUX_
SEL21
Reserved
20
DMAREQ_MUX_
SEL20
Reserved
19
DMAREQ_MUX_
SEL19
Reserved
18
DMAREQ_MUX_
SEL18
Reserved
17
DMAREQ_MUX_
SEL17
Reserved
16
DMAREQ_MUX_
SEL16
Reserved
15
DMAREQ_MUX_
SEL15
Selects between two possible sources for SDMA_EVENT[47]:
0
uart6.ipd_uart_tx_dmareq_b
1
esai.ipd_esai_tx_b
14
DMAREQ_MUX_
SEL14
Selects between two possible sources for SDMA_EVENT[0]:
0
uart6.ipd_uart_rx_dmareq_b
1
esai.ipd_easi_rx_b
13
DMAREQ_MUX_
SEL13
Selects between two possible sources for SDMA_EVENT[34]:
0
uart5.ipd_uart_rx_dmareq_b
1
epdc.epdc_irq
12
DMAREQ_MUX_
SEL12
Reserved
11
DMAREQ_MUX_
SEL11
Selects between two possible sources for SDMA_EVENT[46]:
0
uart8.ipd_uart_tx_dmareq_b
1
enet2.ipd_req_mac0_timer[1]
10
DMAREQ_MUX_
SEL10
Selects between two possible sources for SDMA_EVENT[45]:
0
uart8.ipd_uart_rx_dmareq_b
1
enet2.ipd_req_mac0_timer[0]
9
DMAREQ_MUX_
SEL9
Selects between two possible sources for SDMA_EVENT[44]:
0
uart7.ipd_uart_tx_dmareq_b
1
enet1.ipd_req_mac0_timer[1]
Table continues on the next page...
IOMUXC GPR Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1476
NXP Semiconductors

<!-- page 1477 -->

IOMUXC_GPR_GPR0 field descriptions (continued)
Field
Description
8
DMAREQ_MUX_
SEL8
Selects between two possible sources for SDMA_EVENT[43]:
0
uart7.ipd_uart_rx_dmareq_b
1
enet1.ipd_req_mac0_timer[0]
7
DMAREQ_MUX_
SEL7
Selects between two possible sources for SDMA_EVENT[13]:
0
adc2.ipd_req
1
tsc.irq
6
DMAREQ_MUX_
SEL6
Selects between two possible sources for SDMA_EVENT[24]:
0
gpt2.ipi_int_gpt
1
lcdif.lcdif_irq
5
DMAREQ_MUX_
SEL5
Selects between two possible sources for SDMA_EVENT[16]:
0
epit1.ipi_int_epit_oc
1
csi.ipi_csi_int_b
4
DMAREQ_MUX_
SEL4
Selects between two possible sources for SDMA_EVENT[10]:
0
ecspi4.ipd_req_cspi_tdma_b
1
i2c4.ipi_int_b
3
DMAREQ_MUX_
SEL3
Selects between two possible sources for SDMA_EVENT[9]:
0
ecspi4.ipd_req_cspi_rdma_b
1
i2c3.ipi_int_b
2
DMAREQ_MUX_
SEL2
Selects between two possible sources for SDMA_EVENT[8]:
0
ecspi3.ipd_req_cspi_tdma_b
1
i2c2.ipi_int_b
1
DMAREQ_MUX_
SEL1
Selects between two possible sources for SDMA_EVENT[7]:
0
ecspi3.ipd_req_cspi_rdma_b
1
i2c1.ipi_int_b
0
DMAREQ_MUX_
SEL0
Selects between two possible sources for SDMA_EVENT[2]:
0
epit2.ipi_int_epit_oc
1
pxp.pxp_irq
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1477

<!-- page 1478 -->

32.4.2
GPR1 General Purpose Register (IOMUXC_GPR_GPR1)
GPR Register
Address: 20E_4000h base + 4h offset = 20E_4004h
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
ARMA7_CLK_AHB_
EN
ARMA7_CLK_ATB_
EN
ARMA7_CLK_APB_
DBG_EN
TZASC1_BOOT_
LOCK
EXC_
MON
SAI3_MCLK_DIR
SAI2_MCLK_DIR
SAI1_MCLK_DIR
ENET2_TX_CLK_DIR
ENET1_TX_CLK_DIR
ADD_DS
W
Reset
0
0
0
0
1
1
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
USB_EXP_MODE
ENET2_CLK_SEL
ENET1_CLK_SEL
GINT
ADDRS3[10]
ACT_CS3
ADDRS2[10]
ACT_CS2
ADDRS1[10]
ACT_CS1
ADDRS0[10]
ACT_CS0
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
1
0
1
IOMUXC_GPR_GPR1 field descriptions
Field
Description
31–27
-
Reserved
This field is reserved.
26
ARMA7_CLK_
AHB_EN
ARM A7 platform AHB clock enable
0
AHB clock is not running (gated)
1
AHB clock is running (enabled)
25
ARMA7_CLK_
ATB_EN
ARM A7 platform ATB clock enable
0
ATB clock is not running (gated)
1
ATB clock is running (enabled)
24
ARMA7_CLK_
APB_DBG_EN
ARM A7 platform APB clock enable
0
APB clock is not running (gated)
1
APB clock is running (enabled)
23
TZASC1_BOOT_
LOCK
TZASC-1 secure boot lock
0
secure boot lock is disabled
1
secure boot lock is enabled
Table continues on the next page...
IOMUXC GPR Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1478
NXP Semiconductors

<!-- page 1479 -->

IOMUXC_GPR_GPR1 field descriptions (continued)
Field
Description
22
EXC_MON
Exclusive monitor response select of illegal command
0
OKAY response
1
SLVError response (default)
21
SAI3_MCLK_DIR
LCD_CLK data direction control when sai3.MCLK is selected (ALT3)
0
LCD_CLK output driver is disabled when configured for ALT3
1
LCD_CLK output driver is enabled when configured for ALT3
20
SAI2_MCLK_DIR
SD1_CLK data direction control when sai2.MCLK is selected (ALT2)
0
SD1_CLK output driver is disabled when configured for ALT2
1
SD1_CLK output driver is enabled when configured for ALT2
19
SAI1_MCLK_DIR
LCD_DATA00 data direction control when sai1.MCLK is selected (ALT8)
0
LCD_DATA00 output driver is disabled when configured for ALT8
1
LCD_DATA00 output driver is enabled when configured for ALT8
18
ENET2_TX_
CLK_DIR
ENET2_TX_CLK data direction control when anatop. ENET_REF_CLK2 is selected (ALT1)
0
ENET2_TX_CLK output driver is disabled when configured for ALT1
1
ENET2_TX_CLK output driver is enabled when configured for ALT1
17
ENET1_TX_
CLK_DIR
ENET1_TX_CLK data direction control when anatop. ENET_REF_CLK1 is selected (ALT1)
0
ENET1_TX_CLK output driver is disabled when configured for ALT1
1
ENET1_TX_CLK output driver is enabled when configured for ALT1
16
ADD_DS
Setting ADD_DS to 0 will make the output driver of the SD3 pins ~10% stronger at highest drive strength
(DSE=111). This is for use if the I/O buffer operation at WCS and 200 MHz is marginal.
0
output driver ~10% stronger
1
output driver is normal
15
USB_EXP_
MODE
USB Exposure mode
0
Exposure mode is disabled.
1
Exposure mode is enabled.
14
ENET2_CLK_
SEL
ENET2 reference clock mode select.
0
ENET2 TX reference clock driven by ref_enetpll. This clock is also output to pins via the IOMUX.
ENET_REF_CLK2 function.
1
Gets ENET2 TX reference clk from the ENET2_TX_CLK pin. In this use case, an external OSC
provides the clock for both the external PHY and the internal controller
13
ENET1_CLK_
SEL
ENET1 reference clock mode select.
0
ENET1 TX reference clock driven by ref_enetpll. This clock is also output to pins via the IOMUX.
ENET_REF_CLK1 function.
1
Gets ENET1 TX reference clk from the ENET1_TX_CLK pin. In this use case, an external OSC
provides the clock for both the external PHY and the internal controller
12
GINT
Global interrupt "0" bit (connected to ARM A7 IRQ#0 and GPC)
0
Global interrupt request is not asserted
1
Global interrupt request is asserted
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1479

<!-- page 1480 -->

IOMUXC_GPR_GPR1 field descriptions (continued)
Field
Description
11–10
ADDRS3[10]
Active Chip Select and Address Space.
Each of the ACT_CSx represents one of the four chip selects of the EIM. When ACT_CSx=1'b1, the
corresponding chip select is active and has a valid address space according to its address space
configuration determined by ADDRSx[10] bits
ADDRSx[10] is setting the space for each chip select which is active. The address space of the first active
chip select must be the biggest one, the following active chip select address spaces may be equal or
lower.
Total address space size is 128 MByte.
The supported configurations are:
CS0(128M), CS1 (0M), CS2 (0M), CS3(0M) [default configuration]
CS0(64M), CS1(64M), CS2(0M), CS3(0M)
CS0(64M), CS1(32M), CS2(32M), CS3(0M)
CS0(32M), CS1(32M), CS2(32M), CS3(32M)
Address Space Configuration options (ADDRSx[10]):
00
32 MByte
01
64 MByte
10
128 MByte
11
Reserved
9
ACT_CS3
See description for ADDRS3[10]
8–7
ADDRS2[10]
See description for ADDRS3[10]
6
ACT_CS2
See description for ADDRS3[10]
5–4
ADDRS1[10]
See description for ADDRS3[10]
3
ACT_CS1
See description for ADDRS3[10]
2–1
ADDRS0[10]
See description for ADDRS3[10]
0
ACT_CS0
See description for ADDRS3[10]
IOMUXC GPR Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1480
NXP Semiconductors

<!-- page 1481 -->

32.4.3
GPR2 General Purpose Register (IOMUXC_GPR_GPR2)
GPR Register
Address: 20E_4000h base + 8h offset = 20E_4008h
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
DRAM_CKE_BYPASS
DRAM_CKE1
DRAM_CKE0
DRAM_RESET
DRAM_RESET_
BYPASS
MQS_OVERSAMPLE
MQS_EN
MQS_SW_RST
MQS_CLK_DIV
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
L2_MEM_LIGHTSLEEP
L2_MEM_DEEPSLEEP
L2_MEM_SHUTDOWN
L2_MEM_EN_
POWERSAVING
LCDIF2_MEM_
LIGHTSLEEP
LCDIF2_MEM_
DEEPSLEEP
LCDIF2_MEM_
SHUTDOWN
LCDIF2_MEM_EN_
POWERSAVING
LCDIF1_MEM_
LIGHTSLEEP
LCDIF1_MEM_
DEEPSLEEP
LCDIF1_MEM_
SHUTDOWN
LCDIF1_MEM_EN_
POWERSAVING
PXP_MEM_
LIGHTSLEEP
PXP_MEM_
DEEPSLEEP
PXP_MEM_
SHUTDOWN
PXP_MEM_EN_
POWERSAVING
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
IOMUXC_GPR_GPR2 field descriptions
Field
Description
31
DRAM_CKE_
BYPASS
DRAM CKE Bypass Select
0
DRAM CKE1, CKE0 driven by MMDC PHY Controller
1
DRAM CKE1, CKE0 driven by GPR2 register bits [30:29]
30
DRAM_CKE1
CKE1 Bypass Value
0
Drive CKE1 with 0
1
Drive CKE1 with 1
29
DRAM_CKE0
CKE0 Bypass Value
0
Drive CKE0 with 0
1
Drive CKE0 with 1
28
DRAM_RESET
DRAM Reset Value
0
Drive DRAM reset with 0
1
Drive DRAM reset with 1
27
DRAM_RESET_
BYPASS
DRAM Reset Bypass Select
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1481

<!-- page 1482 -->

IOMUXC_GPR_GPR2 field descriptions (continued)
Field
Description
0
DRAM reset driven by MMDC PHY Controller
1
DRAM reset driven by GPR2 register bit [28]
26
MQS_
OVERSAMPLE
Used to control the PWM oversampling rate compared with mclk.
0
32
1
64
25
MQS_EN
MQS enable.
0
Disable MQS
1
Enable MQS
24
MQS_SW_RST
MQS software reset.
0
Exit software reset for MQS
1
Enable software reset for MQS
23–16
MQS_CLK_DIV
Divider ratio control for mclk from hmclk. mclk frequency = 1/(n+1) * hmclk frequency.
00000000
mclk frequency = hmclk frequency
00000001
mclk frequency = 1/2 * hmclk frequency
00000010
mclk frequency = 1/3 * hmclk frequency
11111111
mclk frequency = 1/256 * hmclk frequency
15
L2_MEM_
LIGHTSLEEP
set to bring memory to light sleep state (Low leakage mode, maintain memory contents, no change to
memory output)
14
L2_MEM_
DEEPSLEEP
control how memory enter Deep Sleep mode (shutdown periphery power, but maintain memory contents,
outputs of memory are pulled low)
0
no force sleep control supported, memory deep sleep mode only entered when whole system in stop
mode
1
force memory into deep sleep mode
13
L2_MEM_
SHUTDOWN
set to bring memory to shutdown state (most power saving state, Shut Down periphery and core, no
memory retention)
12
L2_MEM_EN_
POWERSAVING
enable power saving features on L2 memory
0
none memory power saving features enabled, SHUTDOWN/DEEPSLEEP/LIGHTSLEEP will have no
effect
1
memory power saving features enabled, set SHUTDOWN/DEEPSLEEP/LIGHTSLEEP(priority high to
low) to enable power saving levels
11
LCDIF2_MEM_
LIGHTSLEEP
set to bring memory to light sleep state (Low leakage mode, maintain memory contents, no change to
memory output)
10
LCDIF2_MEM_
DEEPSLEEP
control how memory enter Deep Sleep mode (shutdown periphery power, but maintain memory contents,
outputs of memory are pulled low)
0
no force sleep control supported, memory deep sleep mode only entered when whole system in stop
mode
1
force memory into deep sleep mode
9
LCDIF2_MEM_
SHUTDOWN
set to bring memory to shutdown state (most power saving state, Shut Down periphery and core, no
memory retention)
Table continues on the next page...
IOMUXC GPR Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1482
NXP Semiconductors

<!-- page 1483 -->

IOMUXC_GPR_GPR2 field descriptions (continued)
Field
Description
8
LCDIF2_MEM_
EN_
POWERSAVING
enable power saving features on LCDIF memory
0
none memory power saving features enabled, SHUTDOWN/DEEPSLEEP/LIGHTSLEEP will have no
effect
1
memory power saving features enabled, set SHUTDOWN/DEEPSLEEP/LIGHTSLEEP(priority high to
low) to enable power saving levels
7
LCDIF1_MEM_
LIGHTSLEEP
set to bring memory to light sleep state (Low leakage mode, maintain memory contents, no change to
memory output)
6
LCDIF1_MEM_
DEEPSLEEP
control how memory enter Deep Sleep mode (shutdown periphery power, but maintain memory contents,
outputs of memory are pulled low)
0
no force sleep control supported, memory deep sleep mode only entered when whole system in stop
mode
1
force memory into deep sleep mode
5
LCDIF1_MEM_
SHUTDOWN
set to bring memory to shutdown state (most power saving state, Shut Down periphery and core, no
memory retention)
4
LCDIF1_MEM_
EN_
POWERSAVING
enable power saving features on LCDIF memory
0
none memory power saving features enabled, SHUTDOWN/DEEPSLEEP/LIGHTSLEEP will have no
effect
1
memory power saving features enabled, set SHUTDOWN/DEEPSLEEP/LIGHTSLEEP(priority high to
low) to enable power saving levels
3
PXP_MEM_
LIGHTSLEEP
set to bring memory to light sleep state (Low leakage mode, maintain memory contents, no change to
memory output)
2
PXP_MEM_
DEEPSLEEP
control how memory enter Deep Sleep mode (shutdown periphery power, but maintain memory contents,
outputs of memory are pulled low)
0
no force sleep control supported, memory deep sleep mode only entered when whole system in stop
mode
1
force memory into deep sleep mode
1
PXP_MEM_
SHUTDOWN
set to bring memory to shutdown state (most power saving state, Shut Down periphery and core, no
memory retention)
0
PXP_MEM_EN_
POWERSAVING
enable power saving features on PXP memory
0
none memory power saving features enabled, SHUTDOWN/DEEPSLEEP/LIGHTSLEEP will have no
effect
1
memory power saving features enabled, set SHUTDOWN/DEEPSLEEP/LIGHTSLEEP(priority high to
low) to enable power saving levels
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1483

<!-- page 1484 -->

32.4.4
GPR3 General Purpose Register (IOMUXC_GPR_GPR3)
GPR Register
Address: 20E_4000h base + Ch offset = 20E_400Ch
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
OCRAM_STATUS
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
CORE_DBG_ACK_EN
Reserved
Reserved
OCRAM_CTL
W
Reset
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
1
1
1
1
1
1
IOMUXC GPR Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1484
NXP Semiconductors

<!-- page 1485 -->

IOMUXC_GPR_GPR3 field descriptions
Field
Description
31–20
-
This field is reserved.
Reserved
19–16
OCRAM_
STATUS
This field shows the OCRAM pipeline settings status, controlled by OCRAM_CTL[24:21] bits respectively.
When the control bit is changed, the corresponding status bit goes high and keeps high until this new
configuration is applied the internal logic. This provides a way for software to detect that the configuration
has become valid. The suggested flow for changing the configuration in software is:
• set/clear the control bit
• poll the status bit until it goes to 0
OCRAM_STATUS[19] shows the write address pipeline status. This bit value reflects the propagation of
the respective control bit to OCRAM memory.
OCRAM_STATUS[18] shows the write data pipeline status. This bit value reflects the propagation of the
respective control bit to OCRAM memory.
OCRAM_STATUS[17] shows the read address pipeline status. This bit value reflects the propagation of
the respective control bit to OCRAM memory.
OCRAM_STATUS[16] shows the read data pipeline status. This bit value reflects the propagation of the
respective control bit to OCRAM memory.
0
read data pipeline configuration valid
1
read data pipeline control bit changed
15–14
-
This field is reserved.
Reserved
13
CORE_DBG_
ACK_EN
Mask control of Core debug acknowledge to global debug acknowledge
0
Core debug acknowledge is part of global acknowledge.
1
Core debug acknowledge is masked by this bit, and it is not part of global acknowledge.
12
-
This field is reserved.
Reserved
11–4
-
This field is reserved.
Reserved
OCRAM_CTL
OCRAM_CTL[3] write address pipeline control bit.
When this feature is enabled, the write address from the AXI master would be delayed 1 cycle before it
can be accepted by the on-chip RAM. This can avoid setup time issue for the write access on the memory
cell at high frequency. Enable this feature would cost at most 1 more clock cycle for each AXI write
transaction, i.e., at most 1 more clock cycle for each write burst with multiple beats of data. When this
feature is disabled, the write address from the AXI master can be accepted by the on-chip RAM without
delay, and data can be written to memory at this cycle (if no other access and write data is also ready at
this cycle).
0 write address pipeline is disabled
1 write address pipeline is enabled
OCRAM_CTL[2] - write data pipeline control bit
When this feature is enabled, the write data from the AXI master would be delayed 1 cycle before it can be
accepted by the on-chip RAM. This can avoid setup time issue for the write access on the memory cell at
high frequency. Enabling this feature would cost at most 1 more clock cycle for each AXI write transaction,
i.e., at most 1 more clock cycle for each write burst with multiple beats of data.
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1485

<!-- page 1486 -->

IOMUXC_GPR_GPR3 field descriptions (continued)
Field
Description
When this feature is disabled, the write data from the AXI master can be accepted by the on-chip RAM
without delay, and data can be written to memory at this cycle (if no other access and write address is also
ready at this cycle).
0 write data pipeline is disabled
1 write data pipeline is enabled
OCRAM_CTL[1] read address pipeline control bit.
When this feature is enabled, the read address from the AXI master would be delayed 1 cycle before it
can be accepted by the on-chip RAM. This can avoid setup time issue for the read access on the memory
cell at high frequency. Enable this feature would cost at most 1 more clock cycle for each AXI read
transaction, i.e., at most 1 more clock cycle for each read burst with multiple beats of data. When this
feature is disabled, the read address from the AXI master can be accepted by the on-chip RAM without
delay, and data can become ready for master at next clock cycle (if no other access and no read data
wait).
0 read address pipeline is disabled
1 read address pipeline is enabled
OCRAM_CTL[0] - read data wait state control bit
When thread data wait state is enabled, it will cost 2 cycles for each read access, (each beat of a read
burst). This can avoid the potential timing problem caused by the relatively longer memory access time at
higher frequency. When this feature is disabled, it only costs 1 clock cycle to finish a read transaction, i.e.,
get read data back in the next cycle of read request becomes valid on the bus.
0
read data pipeline is disabled
1
read data pipeline is enabled
IOMUXC GPR Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1486
NXP Semiconductors

<!-- page 1487 -->

32.4.5
GPR4 General Purpose Register (IOMUXC_GPR_GPR4)
GPR Register
Address: 20E_4000h base + 10h offset = 20E_4010h
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
ARM_WFE
ARM_WFI
Reserved
SAI3_STOP_ACK
SAI2_STOP_ACK
SAI1_STOP_ACK
ENET2_STOP_ACK
ENET1_STOP_ACK
CAN2_STOP_ACK
CAN1_STOP_ACK
SDMA_STOP_ACK
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1487

<!-- page 1488 -->

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
ENET_IPG_CLK_S_EN
SAI3_STOP_REQ
SAI2_STOP_REQ
SAI1_STOP_REQ
ENET2_STOP_REQ
ENET1_STOP_REQ
CAN2_STOP_REQ
CAN1_STOP_REQ
SDMA_STOP_REQ
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
IOMUXC_GPR_GPR4 field descriptions
Field
Description
31
ARM_WFE
ARM A7 WFE event out indication on WFE state of the cores (these are status, read only bits)
0
ARM Core[GPR5-index - 4] is not in WFE mode
1
ARM Core[GPR5-index - 4] is in WFE mode
30
ARM_WFI
ARM A7 WFI event out indicating on WFI state of the cores (these are status, read only bits)
0
ARM Core[GPR5-index] is not in WFI mode
1
ARM Core[GPR5-index] is in WFI mode
29–24
-
This field is reserved.
Reserved
23
SAI3_STOP_
ACK
SAI3 stop acknowledge. This is a status (read-only) bit
0
SAI3 stop acknowledge is not asserted
1
SAI3 stop acknowledge is asserted, SDMA is in STOP mode
22
SAI2_STOP_
ACK
SAI2 stop acknowledge. This is a status (read-only) bit
0
SAI2 stop acknowledge is not asserted
1
SAI2 stop acknowledge is asserted, SDMA is in STOP mode
21
SAI1_STOP_
ACK
SAI1 stop acknowledge. This is a status (read-only) bit
0
SAI1 stop acknowledge is not asserted
1
SAI1 stop acknowledge is asserted, SDMA is in STOP mode
Table continues on the next page...
IOMUXC GPR Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1488
NXP Semiconductors

<!-- page 1489 -->

IOMUXC_GPR_GPR4 field descriptions (continued)
Field
Description
20
ENET2_STOP_
ACK
ENET2 stop acknowledge. This is a status (read-only) bit
0
ENET2 stop acknowledge is not asserted
1
ENET2 stop acknowledge is asserted, SDMA is in STOP mode
19
ENET1_STOP_
ACK
ENET1 stop acknowledge. This is a status (read-only) bit
0
ENET1 stop acknowledge is not asserted
1
ENET1 stop acknowledge is asserted, SDMA is in STOP mode
18
CAN2_STOP_
ACK
CAN2 stop acknowledge. This is a status (read-only) bit
0
CAN2 stop acknowledge is not asserted
1
CAN2 stop acknowledge is asserted, SDMA is in STOP mode
17
CAN1_STOP_
ACK
CAN1 stop acknowledge. This is a status (read-only) bit
0
CAN1 stop acknowledge is not asserted
1
CAN1 stop acknowledge is asserted, SDMA is in STOP mode
16
SDMA_STOP_
ACK
SDMA stop acknowledge. This is a status (read-only) bit
0
SDMA stop acknowledge is not asserted
1
SDMA stop acknowledge is asserted, SDMA is in STOP mode
15–9
-
This field is reserved.
Reserved
8
ENET_IPG_
CLK_S_EN
ENET ipg_clk_s clock gating enable
0
ipg_clk_s is gated when there’s no IPS access
1
ipg_clk_s is always on
7
SAI3_STOP_
REQ
SAI3 stop request.
0
stop request off
1
stop request on
6
SAI2_STOP_
REQ
SAI2 stop request.
0
stop request off
1
stop request on
5
SAI1_STOP_
REQ
SAI1 stop request.
0
stop request off
1
stop request on
4
ENET2_STOP_
REQ
ENET2 stop request.
0
stop request off
1
stop request on
3
ENET1_STOP_
REQ
ENET1 stop request.
0
stop request off
1
stop request on
2
CAN2_STOP_
REQ
CAN2 stop request.
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1489

<!-- page 1490 -->

IOMUXC_GPR_GPR4 field descriptions (continued)
Field
Description
0
stop request off
1
stop request on
1
CAN1_STOP_
REQ
CAN1 stop request.
0
stop request off
1
stop request on
0
SDMA_STOP_
REQ
SDMA stop request.
0
stop request off
1
stop request on
32.4.6
GPR5 General Purpose Register (IOMUXC_GPR_GPR5)
GPR Register
Address: 20E_4000h base + 14h offset = 20E_4014h
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
REF_1M_CLK_EPIT2
REF_1M_CLK_EPIT1
VREF_1M_CLK_GPT2
VREF_1M_CLK_GPT1
Reserved
ENET2_EVENT3IN_SEL
ENET1_EVENT3IN_SEL
GPT2_CAPIN2_SEL
GPT2_CAPIN1_SEL
Reserved
WDOG3_MASK
Reserved
LCDIF_HANDSHAKE_
PXP
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
LCDIF_HANDSHAKE_
LCDIF
Reserved
LCDIF_HANDSHAKE_CSI
WDOG2_MASK
WDOG1_MASK
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
IOMUXC_GPR_GPR5 field descriptions
Field
Description
31
REF_1M_CLK_
EPIT2
EPIT2 1 MHz clock source select
Table continues on the next page...
IOMUXC GPR Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1490
NXP Semiconductors

<!-- page 1491 -->

IOMUXC_GPR_GPR5 field descriptions (continued)
Field
Description
0
EPIT2 ipg_clk_highfreq driven by IPG_PERCLK
1
EPIT2 ipg_clk_highfreq driven by anatop 1 MHz clock
30
REF_1M_CLK_
EPIT1
EPIT1 1 MHz clock source select
0
EPIT1 ipg_clk_highfreq driven by IPG_PERCLK
1
EPIT1 ipg_clk highfreq driven by anatop 1 MHz clock
29
VREF_1M_CLK_
GPT2
GPT2 1 MHz clock source select
0
GPT2 ipg_clk_highfreq driven by IPG_PERCLK
1
GPT2 ipg_clk_highfreq driven by anatop 1 MHz clock
28
VREF_1M_CLK_
GPT1
GPT1 1 MHz clock source select
0
GPT1 ipg_clk_highfreq driven by IPG_PERCLK
1
GPT1 ipg_clk_highfreq driven by anatop 1 MHz clock
27
-
This field is reserved.
Reserved
26
ENET2_
EVENT3IN_SEL
ENET2 input timer event3 source select
0
event3 source input from pad
1
event3 source input from gpt2.ipp_do_cmpout2
25
ENET1_
EVENT3IN_SEL
ENET1 input timer event3 source select
0
event3 source input from pad
1
event3 source input from gpt2.ipp_do_cmpout1
24
GPT2_CAPIN2_
SEL
GPT2 input capture channel 2 source select
0
source from pad
1
source from enet2.ipp_do_mac0_timer[3]
23
GPT2_CAPIN1_
SEL
GPT2 input capture channel 1 source select
0
source from pad
1
source from enet1.ipp_do_mac0_timer[3]
22–21
-
This field is reserved.
Reserved
20
WDOG3_MASK
WDOG3 Timeout Mask
0
WDOG3 Timeout behaves normally
1
WDOG3 Timeout is masked
19–18
-
This field is reserved.
Reserved
17–16
LCDIF_
HANDSHAKE_
PXP
PXP Input Handshake Select
00
LCDIF done input to PXP comes from LCDIF
01
LCDIF done input to PXP tied to GND
10
LCDIF done input to PXP tied to GND
11
LCDIF done input to PXP tied to GND
15–14
-
This field is reserved.
Reserved
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1491

<!-- page 1492 -->

IOMUXC_GPR_GPR5 field descriptions (continued)
Field
Description
13–12
LCDIF_
HANDSHAKE_
LCDIF
LCDIF Input Handshake Select
00
LCDIF input handshake signals come from CSI
01
LCDIF input handshake signals tied to GND
10
LCDIF input handshake signals come from PXP
11
LCDIF input handshake signals tied to GND
11–10
-
This field is reserved.
Reserved
9–8
LCDIF_
HANDSHAKE_
CSI
CSI Input Handshake Select
00
LCDIF done input to CSI comes from LCDIF
01
LCDIF done input to CSI tied to GND
10
LCDIF done input to CSI tied to GND
11
LCDIF done input to CSI tied to GND
7
WDOG2_MASK
WDOG2 Timeout Mask
0
WDOG2 Timeout behaves normally
1
WDOG2 Timeout is masked
6
WDOG1_MASK
WDOG1 Timeout Mask
0
WDOG1 Timeout behaves normally
1
WDOG1 Timeout is masked
-
This field is reserved.
Reserved
IOMUXC GPR Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1492
NXP Semiconductors

<!-- page 1493 -->

32.4.7
GPR9 General Purpose Register (IOMUXC_GPR_GPR9)
GPR Register
Address: 20E_4000h base + 24h offset = 20E_4024h
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
TZASC1_BYP
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
IOMUXC_GPR_GPR9 field descriptions
Field
Description
31–1
Reserved
This read-only field is reserved and always has the value 0.
0
TZASC1_BYP
TZASC-1 BYPASS MUX control
0
The TZASC-1 is bypassed and the transactions to DDR are not being checked.
1
The TZASC-1 is not bypassed and the transactions to DDR are being monitored / checked.
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1493

<!-- page 1494 -->

32.4.8
GPR10 General Purpose Register (IOMUXC_GPR_GPR10)
GPR Register
Address: 20E_4000h base + 28h offset = 20E_4028h
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
OCRAM_TZ_ADDR
OCRAM_TZ_
EN
Reserved
SEC_
ERR_
RESP
DBG_CLK_EN
DBG_EN
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
1
1
1
IOMUXC_GPR_GPR10 field descriptions
Field
Description
31–16
-
This field is reserved.
Reserved
15–11
OCRAM_TZ_
ADDR
OCRAM TrustZone (TZ) start address. This is the start address of the secure memory region within the
OCRAM memory space is 4KB granularity. The start address affects the OCRAM transactions only if
OCRAM_TZ_EN bit is set. The OCRAM TZ ENDADDR is not configurable and is set to the end of
OCRAM memory space.
10
OCRAM_TZ_EN
OCRAM TrustZone (TZ) enable.
0
The TrustZone feature is disabled. Entire OCRAM space is available for all access types (secure/non-
secure/user/supervisor).
1
The TrustZone feature is enabled. Access to address in the range specified by
[ENDADDR:STARTADDR] follows the execution mode access policy described in CSU chapter.
9–3
-
This field is reserved.
Reserved
2
SEC_ERR_
RESP
Security error response enable for all security gaskets (on both AHB and AXI busses)
0
OKEY response
1
SLVError (default)
1
DBG_CLK_EN
ARM Debug clock enable
0
Debug turned off.
1
Debug enabled (default).
0
DBG_EN
ARM non secure (non-invasive) debug enable
0
Debug turned off.
1
Debug enabled (default).
IOMUXC GPR Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1494
NXP Semiconductors

<!-- page 1495 -->

32.4.9
GPR14 General Purpose Register (IOMUXC_GPR_GPR14)
GPR Register
Address: 20E_4000h base + 38h offset = 20E_4038h
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
GPR
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
GPR
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
IOMUXC_GPR_GPR14 field descriptions
Field
Description
31–2
GPR
General purpose bits
General purpose bits to be used by SoC integration. Bit Type: DEFAULT
-
This field is reserved.
Reserved
32.5
IOMUXC SNVS Memory Map/Register Definition
IOMUXC_SNVS memory map
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
229_0000
SW_MUX_CTL_PAD_BOOT_MODE0 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_BOOT_MODE0)
32
R/W
0000_0000h
32.5.1/1497
229_0004
SW_MUX_CTL_PAD_BOOT_MODE1 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_BOOT_MODE1)
32
R/W
0000_0000h
32.5.2/1498
229_0008
SW_MUX_CTL_PAD_SNVS_TAMPER0 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER0)
32
R/W
0000_0000h
32.5.3/1499
229_000C
SW_MUX_CTL_PAD_SNVS_TAMPER1 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER1)
32
R/W
0000_0000h
32.5.4/1500
229_0010
SW_MUX_CTL_PAD_SNVS_TAMPER2 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER2)
32
R/W
0000_0000h
32.5.5/1501
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1495

<!-- page 1496 -->

IOMUXC_SNVS memory map (continued)
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
229_0014
SW_MUX_CTL_PAD_SNVS_TAMPER3 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER3)
32
R/W
0000_0000h
32.5.6/1502
229_0018
SW_MUX_CTL_PAD_SNVS_TAMPER4 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER4)
32
R/W
0000_0000h
32.5.7/1503
229_001C
SW_MUX_CTL_PAD_SNVS_TAMPER5 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER5)
32
R/W
0000_0000h
32.5.8/1504
229_0020
SW_MUX_CTL_PAD_SNVS_TAMPER6 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER6)
32
R/W
0000_0000h
32.5.9/1505
229_0024
SW_MUX_CTL_PAD_SNVS_TAMPER7 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER7)
32
R/W
0000_0000h
32.5.10/
1506
229_0028
SW_MUX_CTL_PAD_SNVS_TAMPER8 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER8)
32
R/W
0000_0000h
32.5.11/
1507
229_002C
SW_MUX_CTL_PAD_SNVS_TAMPER9 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER9)
32
R/W
0000_0000h
32.5.12/
1508
229_0030
SW_PAD_CTL_PAD_TEST_MODE SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_TEST_MODE)
32
R/W
0000_30A0h
32.5.13/
1509
229_0034
SW_PAD_CTL_PAD_POR_B SW PAD Control Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_POR_B)
32
R/W
0001_B0A0h
32.5.14/
1511
229_0038
SW_PAD_CTL_PAD_ONOFF SW PAD Control Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_ONOFF)
32
R/W
0001_B0A0h
32.5.15/
1513
229_003C
SW_PAD_CTL_PAD_SNVS_PMIC_ON_REQ SW PAD
Control Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_PMIC_ON_
REQ)
32
R/W
0000_B8A0h
32.5.16/
1515
229_0040
SW_PAD_CTL_PAD_CCM_PMIC_STBY_REQ SW PAD
Control Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_CCM_PMIC_STBY
_REQ)
32
R/W
0000_20A0h
32.5.17/
1517
229_0044
SW_PAD_CTL_PAD_BOOT_MODE0 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_BOOT_MODE0)
32
R/W
0001_30A0h
32.5.18/
1519
229_0048
SW_PAD_CTL_PAD_BOOT_MODE1 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_BOOT_MODE1)
32
R/W
0001_30A0h
32.5.19/
1521
229_004C
SW_PAD_CTL_PAD_SNVS_TAMPER0 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER0)
32
R/W
0001_10A0h
32.5.20/
1523
Table continues on the next page...
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1496
NXP Semiconductors

<!-- page 1497 -->

IOMUXC_SNVS memory map (continued)
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
229_0050
SW_PAD_CTL_PAD_SNVS_TAMPER1 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER1)
32
R/W
0001_10A0h
32.5.21/
1525
229_0054
SW_PAD_CTL_PAD_SNVS_TAMPER2 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER2)
32
R/W
0001_10A0h
32.5.22/
1527
229_0058
SW_PAD_CTL_PAD_SNVS_TAMPER3 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER3)
32
R/W
0001_10A0h
32.5.23/
1529
229_005C
SW_PAD_CTL_PAD_SNVS_TAMPER4 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER4)
32
R/W
0001_10A0h
32.5.24/
1531
229_0060
SW_PAD_CTL_PAD_SNVS_TAMPER5 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER5)
32
R/W
0001_10A0h
32.5.25/
1533
229_0064
SW_PAD_CTL_PAD_SNVS_TAMPER6 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER6)
32
R/W
0001_10A0h
32.5.26/
1535
229_0068
SW_PAD_CTL_PAD_SNVS_TAMPER7 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER7)
32
R/W
0001_10A0h
32.5.27/
1537
229_006C
SW_PAD_CTL_PAD_SNVS_TAMPER8 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER8)
32
R/W
0001_10A0h
32.5.28/
1539
229_0070
SW_PAD_CTL_PAD_SNVS_TAMPER9 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER9)
32
R/W
0001_10A0h
32.5.29/
1541
32.5.1
SW_MUX_CTL_PAD_BOOT_MODE0 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_BOOT_MODE0)
SW_MUX_CTL Register
Address: 229_0000h base + 0h offset = 229_0000h
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
SION
MUX_MODE
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1497

<!-- page 1498 -->

IOMUXC_SNVS_SW_MUX_CTL_PAD_BOOT_MODE0 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad BOOT_MODE0
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field
NOTE: ALT5 mode is only valid when BOOT MODE PIN is used as GPIO.
101
ALT5 — Select mux mode: ALT5 mux port, GPIO5_IO10 of instance - gpio5
Other
Reserved
32.5.2
SW_MUX_CTL_PAD_BOOT_MODE1 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_BOOT_MODE1)
SW_MUX_CTL Register
Address: 229_0000h base + 4h offset = 229_0004h
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
SION
MUX_MODE
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
IOMUXC_SNVS_SW_MUX_CTL_PAD_BOOT_MODE1 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad BOOT_MODE1
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field
NOTE: ALT5 mode is only valid when BOOT MODE PIN is used as GPIO.
Table continues on the next page...
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1498
NXP Semiconductors

<!-- page 1499 -->

IOMUXC_SNVS_SW_MUX_CTL_PAD_BOOT_MODE1 field descriptions (continued)
Field
Description
101
ALT5 — Select mux mode: ALT5 mux port, GPIO5_IO11 of instance - gpio5
Other
Reserved
32.5.3
SW_MUX_CTL_PAD_SNVS_TAMPER0 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER0)
SW_MUX_CTL Register
Address: 229_0000h base + 8h offset = 229_0008h
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
SION
MUX_MODE
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
IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER0 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SNVS_TAMPER0
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field
NOTE: ALT5 mode is only valid when TAMPER PIN is used as GPIO. This depends on FUSE setting
"TAMPER_PIN_DISABLE[1:0]".
Following is the mux information when TAMPER PIN is used as GPIO: SNVS_TAMPER0 ==> GPIO5_00
101
ALT5 — Select mux mode: ALT5 mux port, GPIO5_IO00 of instance - gpio5
Other
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1499

<!-- page 1500 -->

32.5.4
SW_MUX_CTL_PAD_SNVS_TAMPER1 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER1)
SW_MUX_CTL Register
Address: 229_0000h base + Ch offset = 229_000Ch
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
SION
MUX_MODE
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
IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER1 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SNVS_TAMPER1
0
DISABLED — Input Path is determined by functionality
MUX_MODE
NOTE: ALT5 mode is only valid when TAMPER PIN is used as GPIO. This depends on FUSE setting
"TAMPER_PIN_DISABLE[1:0]".
Following is the mux information when TAMPER PIN is used as GPIO: SNVS_TAMPER1 ==> GPIO5_01
101
ALT5 — Select mux mode: ALT5 mux port, GPIO5_IO01 of instance - gpio5
Other
Reserved
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1500
NXP Semiconductors

<!-- page 1501 -->

32.5.5
SW_MUX_CTL_PAD_SNVS_TAMPER2 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER2)
SW_MUX_CTL Register
Address: 229_0000h base + 10h offset = 229_0010h
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
SION
MUX_MODE
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
IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER2 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SNVS_TAMPER2
0
DISABLED — Input Path is determined by functionality
MUX_MODE
NOTE: ALT5 mode is only valid when TAMPER PIN is used as GPIO. This depends on FUSE setting
"TAMPER_PIN_DISABLE[1:0]".
Following is the mux information when TAMPER PIN is used as GPIO: SNVS_TAMPER2 ==> GPIO5_02
101
ALT5 — Slect mux mode: ALT5 mux port, GPIO5_IO02 of instance - gpio5
Other
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1501

<!-- page 1502 -->

32.5.6
SW_MUX_CTL_PAD_SNVS_TAMPER3 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER3)
SW_MUX_CTL Register
Address: 229_0000h base + 14h offset = 229_0014h
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
SION
MUX_MODE
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
IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER3 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SNVS_TAMPER3
0
DISABLED — Input Path is determined by functionality
MUX_MODE
Mux Mode Select Field
NOTE: ALT5 mode is only valid when TAMPER PIN is used as GPIO. This depends on FUSE setting
"TAMPER_PIN_DISABLE[1:0]".
Following is the mux information when TAMPER PIN is used as GPIO: SNVS_TAMPER3 ==> GPIO5_03
101
ALT5 — Select mux mode: ALT5 mux port, GPIO5_IO03 of instance - gpio
Other
Reserved
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1502
NXP Semiconductors

<!-- page 1503 -->

32.5.7
SW_MUX_CTL_PAD_SNVS_TAMPER4 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER4)
SW_MUX_CTL Register
Address: 229_0000h base + 18h offset = 229_0018h
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
SION
MUX_MODE
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
IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER4 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SNVS_TAMPER4
0
DISABLED — Input Path is determined by functionality
MUX_MODE
NOTE: ALT5 mode is only valid when TAMPER PIN is used as GPIO. This depends on FUSE setting
"TAMPER_PIN_DISABLE[1:0]".
Following is the mux information when TAMPER PIN is used as GPIO: SNVS_TAMPER4 ==> GPIO5_04
101
ALT5 — Select mux mode: ALT5 mux port, GPIO5_IO04 of instance - gpio5
Other
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1503

<!-- page 1504 -->

32.5.8
SW_MUX_CTL_PAD_SNVS_TAMPER5 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER5)
SW_MUX_CTL Register
Address: 229_0000h base + 1Ch offset = 229_001Ch
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
SION
MUX_MODE
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
IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER5 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SNVS_TAMPER5
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field
NOTE: ALT5 mode is only valid when TAMPER PIN is used as GPIO. This depends on FUSE setting
"TAMPER_PIN_DISABLE[1:0]".
Following is the mux information when TAMPER PIN is used as GPIO: SNVS_TAMPER5 ==> GPIO5_05
101
ALT5 — Select mux mode: ALT5 mux port, GPIO5_IO05 of instance - gpio5
Other
Reserved
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1504
NXP Semiconductors

<!-- page 1505 -->

32.5.9
SW_MUX_CTL_PAD_SNVS_TAMPER6 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER6)
SW_MUX_CTL Register
Address: 229_0000h base + 20h offset = 229_0020h
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
SION
MUX_MODE
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
IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER6 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SNVS_TAMPER6
0
DISABLED — Input Path is determined by functionality
MUX_MODE
NOTE: ALT5 mode is only valid when TAMPER PIN is used as GPIO. This depends on FUSE setting
"TAMPER_PIN_DISABLE[1:0]".
Following is the mux information when TAMPER PIN is used as GPIO: SNVS_TAMPER6 ==> GPIO5_06
101
ALT5 — Select mux mode: ALT5 mux port, GPIO5_IO06 of instance - gpio5
Other
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1505

<!-- page 1506 -->

32.5.10
SW_MUX_CTL_PAD_SNVS_TAMPER7 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER7)
SW_MUX_CTL Register
Address: 229_0000h base + 24h offset = 229_0024h
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
SION
MUX_MODE
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
IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER7 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SNVS_TAMPER7
0
DISABLED — Input Path is determined by functionality
MUX_MODE
NOTE: ALT5 mode is only valid when TAMPER PIN is used as GPIO. This depends on FUSE setting
"TAMPER_PIN_DISABLE[1:0]".
Following is the mux information when TAMPER PIN is used as GPIO: SNVS_TAMPER7 ==> GPIO5_07
101
ALT5 — Select mux mode: ALT5 mux port, GPIO5_IO07 of instance - gpio5
Other
Reserved
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1506
NXP Semiconductors

<!-- page 1507 -->

32.5.11
SW_MUX_CTL_PAD_SNVS_TAMPER8 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER8)
SW_MUX_CTL Register
Address: 229_0000h base + 28h offset = 229_0028h
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
SION
MUX_MODE
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
IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER8 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SNVS_TAMPER8
0
DISABLED — Input Path is determined by functionality
MUX_MODE
NOTE: ALT5 mode is only valid when TAMPER PIN is used as GPIO. This depends on FUSE setting
"TAMPER_PIN_DISABLE[1:0]".
Following is the mux information when TAMPER PIN is used as GPIO: SNVS_TAMPER8 ==> GPIO5_08
101
ALT5 — Select mux moe: ALT5 mux port, GPIO05_IO08 of instance - gpio5
Other
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1507

<!-- page 1508 -->

32.5.12
SW_MUX_CTL_PAD_SNVS_TAMPER9 SW MUX Control
Register
(IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER9)
SW_MUX_CTL Register
Address: 229_0000h base + 2Ch offset = 229_002Ch
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
SION
MUX_MODE
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
IOMUXC_SNVS_SW_MUX_CTL_PAD_SNVS_TAMPER9 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SNVS_TAMPER9
0
DISABLED — Input Path is determined by functionality
MUX_MODE
NOTE: ALT5 mode is only valid when TAMPER PIN is used as GPIO. This depends on FUSE setting
"TAMPER_PIN_DISABLE[1:0]".
Following is the mux information when TAMPER PIN is used as GPIO: SNVS_TAMPER9 ==> GPIO5_09
101
ALT5 — Select mux mode: ALT5 mux port, GPIO5_IO09 of instance - gpio9
Other
Reserved
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1508
NXP Semiconductors

<!-- page 1509 -->

32.5.13
SW_PAD_CTL_PAD_TEST_MODE SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_TEST_MODE)
SW_PAD_CTL Register
Address: 229_0000h base + 30h offset = 229_0030h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_TEST_MODE field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: TEST_MODE
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: TEST_MODE
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: TEST_MODE
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: TEST_MODE
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1509

<!-- page 1510 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_TEST_MODE field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: TEST_MODE
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: TEST_MODE
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: TEST_MODE
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1510
NXP Semiconductors

<!-- page 1511 -->

32.5.14
SW_PAD_CTL_PAD_POR_B SW PAD Control Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_POR_B)
SW_PAD_CTL Register
Address: 229_0000h base + 34h offset = 229_0034h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
W
Reset
1
0
1
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
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_POR_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: POR_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: POR_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: POR_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: POR_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1511

<!-- page 1512 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_POR_B field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: POR_B
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: POR_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: POR_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1512
NXP Semiconductors

<!-- page 1513 -->

32.5.15
SW_PAD_CTL_PAD_ONOFF SW PAD Control Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_ONOFF)
SW_PAD_CTL Register
Address: 229_0000h base + 38h offset = 229_0038h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
W
Reset
1
0
1
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
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_ONOFF field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ONOFF
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ONOFF
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ONOFF
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ONOFF
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1513

<!-- page 1514 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_ONOFF field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ONOFF
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ONOFF
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ONOFF
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1514
NXP Semiconductors

<!-- page 1515 -->

32.5.16
SW_PAD_CTL_PAD_SNVS_PMIC_ON_REQ SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_PMIC_ON_REQ)
SW_PAD_CTL Register
Address: 229_0000h base + 3Ch offset = 229_003Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
W
Reset
1
0
1
1
1
0
0
0
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_PMIC_ON_REQ field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SNVS_PMIC_ON_REQ
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SNVS_PMIC_ON_REQ
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SNVS_PMIC_ON_REQ
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SNVS_PMIC_ON_REQ
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1515

<!-- page 1516 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_PMIC_ON_REQ field descriptions
(continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SNVS_PMIC_ON_REQ
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SNVS_PMIC_ON_REQ
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SNVS_PMIC_ON_REQ
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1516
NXP Semiconductors

<!-- page 1517 -->

32.5.17
SW_PAD_CTL_PAD_CCM_PMIC_STBY_REQ SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_CCM_PMIC_STBY_REQ)
SW_PAD_CTL Register
Address: 229_0000h base + 40h offset = 229_0040h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_CCM_PMIC_STBY_REQ field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CCM_PMIC_STBY_REQ
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CCM_PMIC_STBY_REQ
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CCM_PMIC_STBY_REQ
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CCM_PMIC_STBY_REQ
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1517

<!-- page 1518 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_CCM_PMIC_STBY_REQ field descriptions
(continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CCM_PMIC_STBY_REQ
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CCM_PMIC_STBY_REQ
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CCM_PMIC_STBY_REQ
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1518
NXP Semiconductors

<!-- page 1519 -->

32.5.18
SW_PAD_CTL_PAD_BOOT_MODE0 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_BOOT_MODE0)
SW_PAD_CTL Register
Address: 229_0000h base + 44h offset = 229_0044h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_BOOT_MODE0 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: BOOT_MODE0
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: BOOT_MODE0
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: BOOT_MODE0
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: BOOT_MODE0
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1519

<!-- page 1520 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_BOOT_MODE0 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: BOOT_MODE0
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: BOOT_MODE0
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: BOOT_MODE0
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1520
NXP Semiconductors

<!-- page 1521 -->

32.5.19
SW_PAD_CTL_PAD_BOOT_MODE1 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_BOOT_MODE1)
SW_PAD_CTL Register
Address: 229_0000h base + 48h offset = 229_0048h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_BOOT_MODE1 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: BOOT_MODE1
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: BOOT_MODE1
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: BOOT_MODE1
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: BOOT_MODE1
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1521

<!-- page 1522 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_BOOT_MODE1 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: BOOT_MODE1
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: BOOT_MODE1
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: BOOT_MODE1
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1522
NXP Semiconductors

<!-- page 1523 -->

32.5.20
SW_PAD_CTL_PAD_SNVS_TAMPER0 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER0)
SW_PAD_CTL Register
Address: 229_0000h base + 4Ch offset = 229_004Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER0 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SNVS_TAMPER0
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SNVS_TAMPER0
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SNVS_TAMPER0
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SNVS_TAMPER0
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1523

<!-- page 1524 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER0 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SNVS_TAMPER0
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SNVS_TAMPER0
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SNVS_TAMPER0
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1524
NXP Semiconductors

<!-- page 1525 -->

32.5.21
SW_PAD_CTL_PAD_SNVS_TAMPER1 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER1)
SW_PAD_CTL Register
Address: 229_0000h base + 50h offset = 229_0050h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER1 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SNVS_TAMPER1
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SNVS_TAMPER1
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SNVS_TAMPER1
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SNVS_TAMPER1
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1525

<!-- page 1526 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER1 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SNVS_TAMPER1
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SNVS_TAMPER1
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SNVS_TAMPER1
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1526
NXP Semiconductors

<!-- page 1527 -->

32.5.22
SW_PAD_CTL_PAD_SNVS_TAMPER2 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER2)
SW_PAD_CTL Register
Address: 229_0000h base + 54h offset = 229_0054h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER2 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SNVS_TAMPER2
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SNVS_TAMPER2
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SNVS_TAMPER2
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SNVS_TAMPER2
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1527

<!-- page 1528 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER2 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SNVS_TAMPER2
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SNVS_TAMPER2
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SNVS_TAMPER2
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1528
NXP Semiconductors

<!-- page 1529 -->

32.5.23
SW_PAD_CTL_PAD_SNVS_TAMPER3 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER3)
SW_PAD_CTL Register
Address: 229_0000h base + 58h offset = 229_0058h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER3 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SNVS_TAMPER3
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SNVS_TAMPER3
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SNVS_TAMPER3
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SNVS_TAMPER3
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1529

<!-- page 1530 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER3 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SNVS_TAMPER3
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SNVS_TAMPER3
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SNVS_TAMPER3
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1530
NXP Semiconductors

<!-- page 1531 -->

32.5.24
SW_PAD_CTL_PAD_SNVS_TAMPER4 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER4)
SW_PAD_CTL Register
Address: 229_0000h base + 5Ch offset = 229_005Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER4 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SNVS_TAMPER4
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SNVS_TAMPER4
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SNVS_TAMPER4
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SNVS_TAMPER4
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1531

<!-- page 1532 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER4 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SNVS_TAMPER4
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SNVS_TAMPER4
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SNVS_TAMPER4
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1532
NXP Semiconductors

<!-- page 1533 -->

32.5.25
SW_PAD_CTL_PAD_SNVS_TAMPER5 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER5)
SW_PAD_CTL Register
Address: 229_0000h base + 60h offset = 229_0060h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER5 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SNVS_TAMPER5
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SNVS_TAMPER5
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SNVS_TAMPER5
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SNVS_TAMPER5
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1533

<!-- page 1534 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER5 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SNVS_TAMPER5
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SNVS_TAMPER5
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SNVS_TAMPER5
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1534
NXP Semiconductors

<!-- page 1535 -->

32.5.26
SW_PAD_CTL_PAD_SNVS_TAMPER6 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER6)
SW_PAD_CTL Register
Address: 229_0000h base + 64h offset = 229_0064h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER6 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SNVS_TAMPER6
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SNVS_TAMPER6
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SNVS_TAMPER6
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SNVS_TAMPER6
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1535

<!-- page 1536 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER6 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SNVS_TAMPER6
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SNVS_TAMPER6
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SNVS_TAMPER6
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1536
NXP Semiconductors

<!-- page 1537 -->

32.5.27
SW_PAD_CTL_PAD_SNVS_TAMPER7 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER7)
SW_PAD_CTL Register
Address: 229_0000h base + 68h offset = 229_0068h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER7 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SNVS_TAMPER7
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SNVS_TAMPER7
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SNVS_TAMPER7
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SNVS_TAMPER7
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1537

<!-- page 1538 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER7 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SNVS_TAMPER7
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SNVS_TAMPER7
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SNVS_TAMPER7
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1538
NXP Semiconductors

<!-- page 1539 -->

32.5.28
SW_PAD_CTL_PAD_SNVS_TAMPER8 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER8)
SW_PAD_CTL Register
Address: 229_0000h base + 6Ch offset = 229_006Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER8 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SNVS_TAMPER8
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SNVS_TAMPER8
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SNVS_TAMPER8
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SNVS_TAMPER8
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1539

<!-- page 1540 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER8 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SNVS_TAMPER8
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SNVS_TAMPER8
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SNVS_TAMPER8
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC SNVS Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1540
NXP Semiconductors

<!-- page 1541 -->

32.5.29
SW_PAD_CTL_PAD_SNVS_TAMPER9 SW PAD Control
Register
(IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER9)
SW_PAD_CTL Register
Address: 229_0000h base + 70h offset = 229_0070h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
0
0
0
0
0
IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER9 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SNVS_TAMPER9
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SNVS_TAMPER9
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SNVS_TAMPER9
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SNVS_TAMPER9
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1541

<!-- page 1542 -->

IOMUXC_SNVS_SW_PAD_CTL_PAD_SNVS_TAMPER9 field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SNVS_TAMPER9
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SNVS_TAMPER9
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SNVS_TAMPER9
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
32.6
IOMUXC Memory Map/Register Definition
IOMUXC memory map
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
20E_0044
SW_MUX_CTL_PAD_JTAG_MOD SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_JTAG_MOD)
32
R/W
0000_0000h
32.6.1/1562
20E_0048
SW_MUX_CTL_PAD_JTAG_TMS SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_JTAG_TMS)
32
R/W
0000_0000h
32.6.2/1563
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1542
NXP Semiconductors

<!-- page 1543 -->

IOMUXC memory map (continued)
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
20E_004C
SW_MUX_CTL_PAD_JTAG_TDO SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_JTAG_TDO)
32
R/W
0000_0000h
32.6.3/1564
20E_0050
SW_MUX_CTL_PAD_JTAG_TDI SW MUX Control Register
(IOMUXC_SW_MUX_CTL_PAD_JTAG_TDI)
32
R/W
0000_0000h
32.6.4/1565
20E_0054
SW_MUX_CTL_PAD_JTAG_TCK SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_JTAG_TCK)
32
R/W
0000_0000h
32.6.5/1566
20E_0058
SW_MUX_CTL_PAD_JTAG_TRST_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_JTAG_TRST_B)
32
R/W
0000_0000h
32.6.6/1567
20E_005C
SW_MUX_CTL_PAD_GPIO1_IO00 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO00)
32
R/W
0000_0005h
32.6.7/1568
20E_0060
SW_MUX_CTL_PAD_GPIO1_IO01 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO01)
32
R/W
0000_0005h
32.6.8/1569
20E_0064
SW_MUX_CTL_PAD_GPIO1_IO02 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO02)
32
R/W
0000_0005h
32.6.9/1570
20E_0068
SW_MUX_CTL_PAD_GPIO1_IO03 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO03)
32
R/W
0000_0005h
32.6.10/
1571
20E_006C
SW_MUX_CTL_PAD_GPIO1_IO04 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO04)
32
R/W
0000_0005h
32.6.11/
1572
20E_0070
SW_MUX_CTL_PAD_GPIO1_IO05 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO05)
32
R/W
0000_0005h
32.6.12/
1573
20E_0074
SW_MUX_CTL_PAD_GPIO1_IO06 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO06)
32
R/W
0000_0005h
32.6.13/
1574
20E_0078
SW_MUX_CTL_PAD_GPIO1_IO07 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO07)
32
R/W
0000_0005h
32.6.14/
1575
20E_007C
SW_MUX_CTL_PAD_GPIO1_IO08 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO08)
32
R/W
0000_0005h
32.6.15/
1576
20E_0080
SW_MUX_CTL_PAD_GPIO1_IO09 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO09)
32
R/W
0000_0005h
32.6.16/
1577
20E_0084
SW_MUX_CTL_PAD_UART1_TX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART1_TX_DATA)
32
R/W
0000_0005h
32.6.17/
1578
20E_0088
SW_MUX_CTL_PAD_UART1_RX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART1_RX_DATA)
32
R/W
0000_0005h
32.6.18/
1579
20E_008C
SW_MUX_CTL_PAD_UART1_CTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART1_CTS_B)
32
R/W
0000_0005h
32.6.19/
1580
20E_0090
SW_MUX_CTL_PAD_UART1_RTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART1_RTS_B)
32
R/W
0000_0005h
32.6.20/
1581
20E_0094
SW_MUX_CTL_PAD_UART2_TX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART2_TX_DATA)
32
R/W
0000_0005h
32.6.21/
1582
20E_0098
SW_MUX_CTL_PAD_UART2_RX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART2_RX_DATA)
32
R/W
0000_0005h
32.6.22/
1583
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1543

<!-- page 1544 -->

IOMUXC memory map (continued)
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
20E_009C
SW_MUX_CTL_PAD_UART2_CTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART2_CTS_B)
32
R/W
0000_0005h
32.6.23/
1584
20E_00A0
SW_MUX_CTL_PAD_UART2_RTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART2_RTS_B)
32
R/W
0000_0005h
32.6.24/
1585
20E_00A4
SW_MUX_CTL_PAD_UART3_TX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART3_TX_DATA)
32
R/W
0000_0005h
32.6.25/
1586
20E_00A8
SW_MUX_CTL_PAD_UART3_RX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART3_RX_DATA)
32
R/W
0000_0005h
32.6.26/
1587
20E_00AC
SW_MUX_CTL_PAD_UART3_CTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART3_CTS_B)
32
R/W
0000_0005h
32.6.27/
1588
20E_00B0
SW_MUX_CTL_PAD_UART3_RTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART3_RTS_B)
32
R/W
0000_0005h
32.6.28/
1589
20E_00B4
SW_MUX_CTL_PAD_UART4_TX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART4_TX_DATA)
32
R/W
0000_0005h
32.6.29/
1590
20E_00B8
SW_MUX_CTL_PAD_UART4_RX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART4_RX_DATA)
32
R/W
0000_0005h
32.6.30/
1591
20E_00BC
SW_MUX_CTL_PAD_UART5_TX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART5_TX_DATA)
32
R/W
0000_0005h
32.6.31/
1592
20E_00C0
SW_MUX_CTL_PAD_UART5_RX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART5_RX_DATA)
32
R/W
0000_0005h
32.6.32/
1593
20E_00C4
SW_MUX_CTL_PAD_ENET1_RX_DATA0 SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_DATA0)
32
R/W
0000_0005h
32.6.33/
1594
20E_00C8
SW_MUX_CTL_PAD_ENET1_RX_DATA1 SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_DATA1)
32
R/W
0000_0005h
32.6.34/
1595
20E_00CC
SW_MUX_CTL_PAD_ENET1_RX_EN SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_EN)
32
R/W
0000_0005h
32.6.35/
1596
20E_00D0
SW_MUX_CTL_PAD_ENET1_TX_DATA0 SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_DATA0)
32
R/W
0000_0005h
32.6.36/
1597
20E_00D4
SW_MUX_CTL_PAD_ENET1_TX_DATA1 SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_DATA1)
32
R/W
0000_0005h
32.6.37/
1598
20E_00D8
SW_MUX_CTL_PAD_ENET1_TX_EN SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_EN)
32
R/W
0000_0005h
32.6.38/
1599
20E_00DC
SW_MUX_CTL_PAD_ENET1_TX_CLK SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_CLK)
32
R/W
0000_0005h
32.6.39/
1600
20E_00E0
SW_MUX_CTL_PAD_ENET1_RX_ER SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_ER)
32
R/W
0000_0005h
32.6.40/
1601
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1544
NXP Semiconductors

<!-- page 1545 -->

IOMUXC memory map (continued)
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
20E_00E4
SW_MUX_CTL_PAD_ENET2_RX_DATA0 SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_DATA0)
32
R/W
0000_0005h
32.6.41/
1602
20E_00E8
SW_MUX_CTL_PAD_ENET2_RX_DATA1 SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_DATA1)
32
R/W
0000_0005h
32.6.42/
1603
20E_00EC
SW_MUX_CTL_PAD_ENET2_RX_EN SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_EN)
32
R/W
0000_0005h
32.6.43/
1604
20E_00F0
SW_MUX_CTL_PAD_ENET2_TX_DATA0 SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_DATA0)
32
R/W
0000_0005h
32.6.44/
1605
20E_00F4
SW_MUX_CTL_PAD_ENET2_TX_DATA1 SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_DATA1)
32
R/W
0000_0005h
32.6.45/
1606
20E_00F8
SW_MUX_CTL_PAD_ENET2_TX_EN SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_EN)
32
R/W
0000_0005h
32.6.46/
1607
20E_00FC
SW_MUX_CTL_PAD_ENET2_TX_CLK SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_CLK)
32
R/W
0000_0005h
32.6.47/
1608
20E_0100
SW_MUX_CTL_PAD_ENET2_RX_ER SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_ER)
32
R/W
0000_0005h
32.6.48/
1609
20E_0104
SW_MUX_CTL_PAD_LCD_CLK SW MUX Control Register
(IOMUXC_SW_MUX_CTL_PAD_LCD_CLK)
32
R/W
0000_0005h
32.6.49/
1610
20E_0108
SW_MUX_CTL_PAD_LCD_ENABLE SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_ENABLE)
32
R/W
0000_0005h
32.6.50/
1611
20E_010C
SW_MUX_CTL_PAD_LCD_HSYNC SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_HSYNC)
32
R/W
0000_0005h
32.6.51/
1612
20E_0110
SW_MUX_CTL_PAD_LCD_VSYNC SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_VSYNC)
32
R/W
0000_0005h
32.6.52/
1613
20E_0114
SW_MUX_CTL_PAD_LCD_RESET SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_RESET)
32
R/W
0000_0005h
32.6.53/
1614
20E_0118
SW_MUX_CTL_PAD_LCD_DATA00 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA00)
32
R/W
0000_0005h
32.6.54/
1615
20E_011C
SW_MUX_CTL_PAD_LCD_DATA01 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA01)
32
R/W
0000_0005h
32.6.55/
1616
20E_0120
SW_MUX_CTL_PAD_LCD_DATA02 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA02)
32
R/W
0000_0005h
32.6.56/
1617
20E_0124
SW_MUX_CTL_PAD_LCD_DATA03 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA03)
32
R/W
0000_0005h
32.6.57/
1618
20E_0128
SW_MUX_CTL_PAD_LCD_DATA04 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA04)
32
R/W
0000_0005h
32.6.58/
1619
20E_012C
SW_MUX_CTL_PAD_LCD_DATA05 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA05)
32
R/W
0000_0005h
32.6.59/
1620
20E_0130
SW_MUX_CTL_PAD_LCD_DATA06 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA06)
32
R/W
0000_0005h
32.6.60/
1621
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1545

<!-- page 1546 -->

IOMUXC memory map (continued)
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
20E_0134
SW_MUX_CTL_PAD_LCD_DATA07 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA07)
32
R/W
0000_0005h
32.6.61/
1622
20E_0138
SW_MUX_CTL_PAD_LCD_DATA08 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA08)
32
R/W
0000_0005h
32.6.62/
1623
20E_013C
SW_MUX_CTL_PAD_LCD_DATA09 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA09)
32
R/W
0000_0005h
32.6.63/
1624
20E_0140
SW_MUX_CTL_PAD_LCD_DATA10 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA10)
32
R/W
0000_0005h
32.6.64/
1625
20E_0144
SW_MUX_CTL_PAD_LCD_DATA11 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA11)
32
R/W
0000_0005h
32.6.65/
1626
20E_0148
SW_MUX_CTL_PAD_LCD_DATA12 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA12)
32
R/W
0000_0005h
32.6.66/
1627
20E_014C
SW_MUX_CTL_PAD_LCD_DATA13 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA13)
32
R/W
0000_0005h
32.6.67/
1628
20E_0150
SW_MUX_CTL_PAD_LCD_DATA14 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA14)
32
R/W
0000_0005h
32.6.68/
1629
20E_0154
SW_MUX_CTL_PAD_LCD_DATA15 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA15)
32
R/W
0000_0005h
32.6.69/
1630
20E_0158
SW_MUX_CTL_PAD_LCD_DATA16 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA16)
32
R/W
0000_0005h
32.6.70/
1631
20E_015C
SW_MUX_CTL_PAD_LCD_DATA17 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA17)
32
R/W
0000_0005h
32.6.71/
1632
20E_0160
SW_MUX_CTL_PAD_LCD_DATA18 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA18)
32
R/W
0000_0005h
32.6.72/
1633
20E_0164
SW_MUX_CTL_PAD_LCD_DATA19 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA19)
32
R/W
0000_0005h
32.6.73/
1634
20E_0168
SW_MUX_CTL_PAD_LCD_DATA20 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA20)
32
R/W
0000_0005h
32.6.74/
1635
20E_016C
SW_MUX_CTL_PAD_LCD_DATA21 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA21)
32
R/W
0000_0005h
32.6.75/
1636
20E_0170
SW_MUX_CTL_PAD_LCD_DATA22 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA22)
32
R/W
0000_0005h
32.6.76/
1637
20E_0174
SW_MUX_CTL_PAD_LCD_DATA23 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA23)
32
R/W
0000_0005h
32.6.77/
1638
20E_0178
SW_MUX_CTL_PAD_NAND_RE_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_RE_B)
32
R/W
0000_0005h
32.6.78/
1639
20E_017C
SW_MUX_CTL_PAD_NAND_WE_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_WE_B)
32
R/W
0000_0005h
32.6.79/
1640
20E_0180
SW_MUX_CTL_PAD_NAND_DATA00 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA00)
32
R/W
0000_0005h
32.6.80/
1641
20E_0184
SW_MUX_CTL_PAD_NAND_DATA01 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA01)
32
R/W
0000_0005h
32.6.81/
1642
20E_0188
SW_MUX_CTL_PAD_NAND_DATA02 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA02)
32
R/W
0000_0005h
32.6.82/
1643
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1546
NXP Semiconductors

<!-- page 1547 -->

IOMUXC memory map (continued)
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
20E_018C
SW_MUX_CTL_PAD_NAND_DATA03 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA03)
32
R/W
0000_0005h
32.6.83/
1644
20E_0190
SW_MUX_CTL_PAD_NAND_DATA04 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA04)
32
R/W
0000_0005h
32.6.84/
1645
20E_0194
SW_MUX_CTL_PAD_NAND_DATA05 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA05)
32
R/W
0000_0005h
32.6.85/
1646
20E_0198
SW_MUX_CTL_PAD_NAND_DATA06 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA06)
32
R/W
0000_0005h
32.6.86/
1647
20E_019C
SW_MUX_CTL_PAD_NAND_DATA07 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA07)
32
R/W
0000_0005h
32.6.87/
1648
20E_01A0
SW_MUX_CTL_PAD_NAND_ALE SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_ALE)
32
R/W
0000_0005h
32.6.88/
1649
20E_01A4
SW_MUX_CTL_PAD_NAND_WP_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_WP_B)
32
R/W
0000_0005h
32.6.89/
1650
20E_01A8
SW_MUX_CTL_PAD_NAND_READY_B SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_NAND_READY_B)
32
R/W
0000_0005h
32.6.90/
1651
20E_01AC
SW_MUX_CTL_PAD_NAND_CE0_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_CE0_B)
32
R/W
0000_0005h
32.6.91/
1652
20E_01B0
SW_MUX_CTL_PAD_NAND_CE1_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_CE1_B)
32
R/W
0000_0005h
32.6.92/
1653
20E_01B4
SW_MUX_CTL_PAD_NAND_CLE SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_CLE)
32
R/W
0000_0005h
32.6.93/
1654
20E_01B8
SW_MUX_CTL_PAD_NAND_DQS SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DQS)
32
R/W
0000_0005h
32.6.94/
1655
20E_01BC
SW_MUX_CTL_PAD_SD1_CMD SW MUX Control Register
(IOMUXC_SW_MUX_CTL_PAD_SD1_CMD)
32
R/W
0000_0005h
32.6.95/
1656
20E_01C0
SW_MUX_CTL_PAD_SD1_CLK SW MUX Control Register
(IOMUXC_SW_MUX_CTL_PAD_SD1_CLK)
32
R/W
0000_0005h
32.6.96/
1657
20E_01C4
SW_MUX_CTL_PAD_SD1_DATA0 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_SD1_DATA0)
32
R/W
0000_0005h
32.6.97/
1658
20E_01C8
SW_MUX_CTL_PAD_SD1_DATA1 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_SD1_DATA1)
32
R/W
0000_0005h
32.6.98/
1659
20E_01CC
SW_MUX_CTL_PAD_SD1_DATA2 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_SD1_DATA2)
32
R/W
0000_0005h
32.6.99/
1660
20E_01D0
SW_MUX_CTL_PAD_SD1_DATA3 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_SD1_DATA3)
32
R/W
0000_0005h
32.6.100/
1661
20E_01D4
SW_MUX_CTL_PAD_CSI_MCLK SW MUX Control Register
(IOMUXC_SW_MUX_CTL_PAD_CSI_MCLK)
32
R/W
0000_0005h
32.6.101/
1662
20E_01D8
SW_MUX_CTL_PAD_CSI_PIXCLK SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_PIXCLK)
32
R/W
0000_0005h
32.6.102/
1663
20E_01DC
SW_MUX_CTL_PAD_CSI_VSYNC SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_VSYNC)
32
R/W
0000_0005h
32.6.103/
1664
20E_01E0
SW_MUX_CTL_PAD_CSI_HSYNC SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_HSYNC)
32
R/W
0000_0005h
32.6.104/
1665
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1547

<!-- page 1548 -->

IOMUXC memory map (continued)
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
20E_01E4
SW_MUX_CTL_PAD_CSI_DATA00 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA00)
32
R/W
0000_0005h
32.6.105/
1666
20E_01E8
SW_MUX_CTL_PAD_CSI_DATA01 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA01)
32
R/W
0000_0005h
32.6.106/
1667
20E_01EC
SW_MUX_CTL_PAD_CSI_DATA02 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA02)
32
R/W
0000_0005h
32.6.107/
1668
20E_01F0
SW_MUX_CTL_PAD_CSI_DATA03 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA03)
32
R/W
0000_0005h
32.6.108/
1669
20E_01F4
SW_MUX_CTL_PAD_CSI_DATA04 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA04)
32
R/W
0000_0005h
32.6.109/
1670
20E_01F8
SW_MUX_CTL_PAD_CSI_DATA05 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA05)
32
R/W
0000_0005h
32.6.110/
1671
20E_01FC
SW_MUX_CTL_PAD_CSI_DATA06 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA06)
32
R/W
0000_0005h
32.6.111/
1672
20E_0200
SW_MUX_CTL_PAD_CSI_DATA07 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA07)
32
R/W
0000_0005h
32.6.112/
1673
20E_0204
SW_PAD_CTL_PAD_DRAM_ADDR00 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR00)
32
R/W
0000_8000h
32.6.113/
1674
20E_0208
SW_PAD_CTL_PAD_DRAM_ADDR01 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR01)
32
R/W
0000_8000h
32.6.114/
1677
20E_020C
SW_PAD_CTL_PAD_DRAM_ADDR02 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR02)
32
R/W
0000_8000h
32.6.115/
1680
20E_0210
SW_PAD_CTL_PAD_DRAM_ADDR03 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR03)
32
R/W
0000_8000h
32.6.116/
1683
20E_0214
SW_PAD_CTL_PAD_DRAM_ADDR04 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR04)
32
R/W
0000_8000h
32.6.117/
1686
20E_0218
SW_PAD_CTL_PAD_DRAM_ADDR05 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR05)
32
R/W
0000_8000h
32.6.118/
1689
20E_021C
SW_PAD_CTL_PAD_DRAM_ADDR06 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR06)
32
R/W
0000_8000h
32.6.119/
1692
20E_0220
SW_PAD_CTL_PAD_DRAM_ADDR07 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR07)
32
R/W
0000_8000h
32.6.120/
1695
20E_0224
SW_PAD_CTL_PAD_DRAM_ADDR08 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR08)
32
R/W
0000_8000h
32.6.121/
1698
20E_0228
SW_PAD_CTL_PAD_DRAM_ADDR09 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR09)
32
R/W
0000_8000h
32.6.122/
1701
20E_022C
SW_PAD_CTL_PAD_DRAM_ADDR10 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR10)
32
R/W
0000_8000h
32.6.123/
1704
20E_0230
SW_PAD_CTL_PAD_DRAM_ADDR11 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR11)
32
R/W
0000_8000h
32.6.124/
1707
20E_0234
SW_PAD_CTL_PAD_DRAM_ADDR12 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR12)
32
R/W
0000_8000h
32.6.125/
1710
20E_0238
SW_PAD_CTL_PAD_DRAM_ADDR13 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR13)
32
R/W
0000_8000h
32.6.126/
1713
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1548
NXP Semiconductors

<!-- page 1549 -->

IOMUXC memory map (continued)
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
20E_023C
SW_PAD_CTL_PAD_DRAM_ADDR14 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR14)
32
R/W
0000_8000h
32.6.127/
1716
20E_0240
SW_PAD_CTL_PAD_DRAM_ADDR15 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR15)
32
R/W
0000_8000h
32.6.128/
1719
20E_0244
SW_PAD_CTL_PAD_DRAM_DQM0 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM0)
32
R/W
0000_8030h
32.6.129/
1722
20E_0248
SW_PAD_CTL_PAD_DRAM_DQM1 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM1)
32
R/W
0000_8030h
32.6.130/
1725
20E_024C
SW_PAD_CTL_PAD_DRAM_RAS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_RAS_B)
32
R/W
0000_8030h
32.6.131/
1728
20E_0250
SW_PAD_CTL_PAD_DRAM_CAS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_CAS_B)
32
R/W
0000_8030h
32.6.132/
1731
20E_0254
SW_PAD_CTL_PAD_DRAM_CS0_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_CS0_B)
32
R/W
0000_8000h
32.6.133/
1734
20E_0258
SW_PAD_CTL_PAD_DRAM_CS1_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_CS1_B)
32
R/W
0000_8000h
32.6.134/
1737
20E_025C
SW_PAD_CTL_PAD_DRAM_SDWE_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_SDWE_B)
32
R/W
0000_8000h
32.6.135/
1740
20E_0260
SW_PAD_CTL_PAD_DRAM_ODT0 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ODT0)
32
R/W
0000_3030h
32.6.136/
1743
20E_0264
SW_PAD_CTL_PAD_DRAM_ODT1 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ODT1)
32
R/W
0000_3030h
32.6.137/
1746
20E_0268
SW_PAD_CTL_PAD_DRAM_SDBA0 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA0)
32
R/W
0000_8000h
32.6.138/
1749
20E_026C
SW_PAD_CTL_PAD_DRAM_SDBA1 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA1)
32
R/W
0000_8000h
32.6.139/
1752
20E_0270
SW_PAD_CTL_PAD_DRAM_SDBA2 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA2)
32
R/W
0000_B000h
32.6.140/
1755
20E_0274
SW_PAD_CTL_PAD_DRAM_SDCKE0 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCKE0)
32
R/W
0000_3000h
32.6.141/
1758
20E_0278
SW_PAD_CTL_PAD_DRAM_SDCKE1 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCKE1)
32
R/W
0000_3000h
32.6.142/
1761
20E_027C
SW_PAD_CTL_PAD_DRAM_SDCLK0_P SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCLK0_P)
32
R/W
0000_8030h
32.6.143/
1764
20E_0280
SW_PAD_CTL_PAD_DRAM_SDQS0_P SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS0_P)
32
R/W
0000_2030h
32.6.144/
1767
20E_0284
SW_PAD_CTL_PAD_DRAM_SDQS1_P SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS1_P)
32
R/W
0000_2030h
32.6.145/
1770
20E_0288
SW_PAD_CTL_PAD_DRAM_RESET SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_RESET)
32
R/W
0008_3030h
32.6.146/
1773
20E_02D0
SW_PAD_CTL_PAD_JTAG_MOD SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_JTAG_MOD)
32
R/W
0000_B0A0h
32.6.147/
1775
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1549

<!-- page 1550 -->

IOMUXC memory map (continued)
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
20E_02D4
SW_PAD_CTL_PAD_JTAG_TMS SW PAD Control Register
(IOMUXC_SW_PAD_CTL_PAD_JTAG_TMS)
32
R/W
0000_70A0h
32.6.148/
1777
20E_02D8
SW_PAD_CTL_PAD_JTAG_TDO SW PAD Control Register
(IOMUXC_SW_PAD_CTL_PAD_JTAG_TDO)
32
R/W
0000_90B1h
32.6.149/
1779
20E_02DC
SW_PAD_CTL_PAD_JTAG_TDI SW PAD Control Register
(IOMUXC_SW_PAD_CTL_PAD_JTAG_TDI)
32
R/W
0000_70A0h
32.6.150/
1781
20E_02E0
SW_PAD_CTL_PAD_JTAG_TCK SW PAD Control Register
(IOMUXC_SW_PAD_CTL_PAD_JTAG_TCK)
32
R/W
0000_70A0h
32.6.151/
1783
20E_02E4
SW_PAD_CTL_PAD_JTAG_TRST_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_JTAG_TRST_B)
32
R/W
0000_70A0h
32.6.152/
1785
20E_02E8
SW_PAD_CTL_PAD_GPIO1_IO00 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO00)
32
R/W
0000_10B0h
32.6.153/
1787
20E_02EC
SW_PAD_CTL_PAD_GPIO1_IO01 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO01)
32
R/W
0000_10B0h
32.6.154/
1789
20E_02F0
SW_PAD_CTL_PAD_GPIO1_IO02 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO02)
32
R/W
0000_10B0h
32.6.155/
1791
20E_02F4
SW_PAD_CTL_PAD_GPIO1_IO03 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO03)
32
R/W
0000_10B0h
32.6.156/
1793
20E_02F8
SW_PAD_CTL_PAD_GPIO1_IO04 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO04)
32
R/W
0000_10B0h
32.6.157/
1795
20E_02FC
SW_PAD_CTL_PAD_GPIO1_IO05 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO05)
32
R/W
0000_10B0h
32.6.158/
1797
20E_0300
SW_PAD_CTL_PAD_GPIO1_IO06 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO06)
32
R/W
0000_10B0h
32.6.159/
1799
20E_0304
SW_PAD_CTL_PAD_GPIO1_IO07 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO07)
32
R/W
0000_10B0h
32.6.160/
1801
20E_0308
SW_PAD_CTL_PAD_GPIO1_IO08 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO08)
32
R/W
0000_10B0h
32.6.161/
1803
20E_030C
SW_PAD_CTL_PAD_GPIO1_IO09 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO09)
32
R/W
0000_10B0h
32.6.162/
1805
20E_0310
SW_PAD_CTL_PAD_UART1_TX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART1_TX_DATA)
32
R/W
0000_10B0h
32.6.163/
1807
20E_0314
SW_PAD_CTL_PAD_UART1_RX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART1_RX_DATA)
32
R/W
0000_10B0h
32.6.164/
1809
20E_0318
SW_PAD_CTL_PAD_UART1_CTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART1_CTS_B)
32
R/W
0000_10B0h
32.6.165/
1811
20E_031C
SW_PAD_CTL_PAD_UART1_RTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART1_RTS_B)
32
R/W
0000_10B0h
32.6.166/
1813
20E_0320
SW_PAD_CTL_PAD_UART2_TX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART2_TX_DATA)
32
R/W
0000_10B0h
32.6.167/
1815
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1550
NXP Semiconductors

<!-- page 1551 -->

IOMUXC memory map (continued)
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
20E_0324
SW_PAD_CTL_PAD_UART2_RX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART2_RX_DATA)
32
R/W
0000_10B0h
32.6.168/
1817
20E_0328
SW_PAD_CTL_PAD_UART2_CTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART2_CTS_B)
32
R/W
0000_10B0h
32.6.169/
1819
20E_032C
SW_PAD_CTL_PAD_UART2_RTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART2_RTS_B)
32
R/W
0000_10B0h
32.6.170/
1821
20E_0330
SW_PAD_CTL_PAD_UART3_TX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART3_TX_DATA)
32
R/W
0000_10B0h
32.6.171/
1823
20E_0334
SW_PAD_CTL_PAD_UART3_RX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART3_RX_DATA)
32
R/W
0000_10B0h
32.6.172/
1825
20E_0338
SW_PAD_CTL_PAD_UART3_CTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART3_CTS_B)
32
R/W
0000_10B0h
32.6.173/
1827
20E_033C
SW_PAD_CTL_PAD_UART3_RTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART3_RTS_B)
32
R/W
0000_10B0h
32.6.174/
1829
20E_0340
SW_PAD_CTL_PAD_UART4_TX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART4_TX_DATA)
32
R/W
0000_10B0h
32.6.175/
1831
20E_0344
SW_PAD_CTL_PAD_UART4_RX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART4_RX_DATA)
32
R/W
0000_10B0h
32.6.176/
1833
20E_0348
SW_PAD_CTL_PAD_UART5_TX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART5_TX_DATA)
32
R/W
0000_10B0h
32.6.177/
1835
20E_034C
SW_PAD_CTL_PAD_UART5_RX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART5_RX_DATA)
32
R/W
0000_10B0h
32.6.178/
1837
20E_0350
SW_PAD_CTL_PAD_ENET1_RX_DATA0 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_DATA0)
32
R/W
0000_10B0h
32.6.179/
1839
20E_0354
SW_PAD_CTL_PAD_ENET1_RX_DATA1 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_DATA1)
32
R/W
0000_10B0h
32.6.180/
1841
20E_0358
SW_PAD_CTL_PAD_ENET1_RX_EN SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_EN)
32
R/W
0000_10B0h
32.6.181/
1843
20E_035C
SW_PAD_CTL_PAD_ENET1_TX_DATA0 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_DATA0)
32
R/W
0000_10B0h
32.6.182/
1845
20E_0360
SW_PAD_CTL_PAD_ENET1_TX_DATA1 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_DATA1)
32
R/W
0000_10B0h
32.6.183/
1847
20E_0364
SW_PAD_CTL_PAD_ENET1_TX_EN SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_EN)
32
R/W
0000_10B0h
32.6.184/
1849
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1551

<!-- page 1552 -->

IOMUXC memory map (continued)
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
20E_0368
SW_PAD_CTL_PAD_ENET1_TX_CLK SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_CLK)
32
R/W
0000_10B0h
32.6.185/
1851
20E_036C
SW_PAD_CTL_PAD_ENET1_RX_ER SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_ER)
32
R/W
0000_10B0h
32.6.186/
1853
20E_0370
SW_PAD_CTL_PAD_ENET2_RX_DATA0 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_DATA0)
32
R/W
0000_10B0h
32.6.187/
1855
20E_0374
SW_PAD_CTL_PAD_ENET2_RX_DATA1 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_DATA1)
32
R/W
0000_10B0h
32.6.188/
1857
20E_0378
SW_PAD_CTL_PAD_ENET2_RX_EN SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_EN)
32
R/W
0000_10B0h
32.6.189/
1859
20E_037C
SW_PAD_CTL_PAD_ENET2_TX_DATA0 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_DATA0)
32
R/W
0000_10B0h
32.6.190/
1861
20E_0380
SW_PAD_CTL_PAD_ENET2_TX_DATA1 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_DATA1)
32
R/W
0000_10B0h
32.6.191/
1863
20E_0384
SW_PAD_CTL_PAD_ENET2_TX_EN SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_EN)
32
R/W
0000_10B0h
32.6.192/
1865
20E_0388
SW_PAD_CTL_PAD_ENET2_TX_CLK SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_CLK)
32
R/W
0000_10B0h
32.6.193/
1867
20E_038C
SW_PAD_CTL_PAD_ENET2_RX_ER SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_ER)
32
R/W
0000_10B0h
32.6.194/
1869
20E_0390
SW_PAD_CTL_PAD_LCD_CLK SW PAD Control Register
(IOMUXC_SW_PAD_CTL_PAD_LCD_CLK)
32
R/W
0000_10B0h
32.6.195/
1871
20E_0394
SW_PAD_CTL_PAD_LCD_ENABLE SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_ENABLE)
32
R/W
0000_10B0h
32.6.196/
1873
20E_0398
SW_PAD_CTL_PAD_LCD_HSYNC SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_HSYNC)
32
R/W
0000_10B0h
32.6.197/
1875
20E_039C
SW_PAD_CTL_PAD_LCD_VSYNC SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_VSYNC)
32
R/W
0000_10B0h
32.6.198/
1877
20E_03A0
SW_PAD_CTL_PAD_LCD_RESET SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_RESET)
32
R/W
0000_10B0h
32.6.199/
1879
20E_03A4
SW_PAD_CTL_PAD_LCD_DATA00 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA00)
32
R/W
0000_10B0h
32.6.200/
1881
20E_03A8
SW_PAD_CTL_PAD_LCD_DATA01 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA01)
32
R/W
0000_10B0h
32.6.201/
1883
20E_03AC
SW_PAD_CTL_PAD_LCD_DATA02 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA02)
32
R/W
0000_10B0h
32.6.202/
1885
20E_03B0
SW_PAD_CTL_PAD_LCD_DATA03 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA03)
32
R/W
0000_10B0h
32.6.203/
1887
20E_03B4
SW_PAD_CTL_PAD_LCD_DATA04 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA04)
32
R/W
0000_10B0h
32.6.204/
1889
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1552
NXP Semiconductors

<!-- page 1553 -->

IOMUXC memory map (continued)
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
20E_03B8
SW_PAD_CTL_PAD_LCD_DATA05 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA05)
32
R/W
0000_10B0h
32.6.205/
1891
20E_03BC
SW_PAD_CTL_PAD_LCD_DATA06 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA06)
32
R/W
0000_10B0h
32.6.206/
1893
20E_03C0
SW_PAD_CTL_PAD_LCD_DATA07 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA07)
32
R/W
0000_10B0h
32.6.207/
1895
20E_03C4
SW_PAD_CTL_PAD_LCD_DATA08 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA08)
32
R/W
0000_10B0h
32.6.208/
1897
20E_03C8
SW_PAD_CTL_PAD_LCD_DATA09 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA09)
32
R/W
0000_10B0h
32.6.209/
1899
20E_03CC
SW_PAD_CTL_PAD_LCD_DATA10 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA10)
32
R/W
0000_10B0h
32.6.210/
1901
20E_03D0
SW_PAD_CTL_PAD_LCD_DATA11 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA11)
32
R/W
0000_10B0h
32.6.211/
1903
20E_03D4
SW_PAD_CTL_PAD_LCD_DATA12 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA12)
32
R/W
0000_10B0h
32.6.212/
1905
20E_03D8
SW_PAD_CTL_PAD_LCD_DATA13 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA13)
32
R/W
0000_10B0h
32.6.213/
1907
20E_03DC
SW_PAD_CTL_PAD_LCD_DATA14 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA14)
32
R/W
0000_10B0h
32.6.214/
1909
20E_03E0
SW_PAD_CTL_PAD_LCD_DATA15 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA15)
32
R/W
0000_10B0h
32.6.215/
1911
20E_03E4
SW_PAD_CTL_PAD_LCD_DATA16 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA16)
32
R/W
0000_10B0h
32.6.216/
1913
20E_03E8
SW_PAD_CTL_PAD_LCD_DATA17 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA17)
32
R/W
0000_10B0h
32.6.217/
1915
20E_03EC
SW_PAD_CTL_PAD_LCD_DATA18 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA18)
32
R/W
0000_10B0h
32.6.218/
1917
20E_03F0
SW_PAD_CTL_PAD_LCD_DATA19 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA19)
32
R/W
0000_10B0h
32.6.219/
1919
20E_03F4
SW_PAD_CTL_PAD_LCD_DATA20 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA20)
32
R/W
0000_10B0h
32.6.220/
1921
20E_03F8
SW_PAD_CTL_PAD_LCD_DATA21 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA21)
32
R/W
0000_10B0h
32.6.221/
1923
20E_03FC
SW_PAD_CTL_PAD_LCD_DATA22 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA22)
32
R/W
0000_10B0h
32.6.222/
1925
20E_0400
SW_PAD_CTL_PAD_LCD_DATA23 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA23)
32
R/W
0000_10B0h
32.6.223/
1927
20E_0404
SW_PAD_CTL_PAD_NAND_RE_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_RE_B)
32
R/W
0000_10B0h
32.6.224/
1929
20E_0408
SW_PAD_CTL_PAD_NAND_WE_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_WE_B)
32
R/W
0000_10B0h
32.6.225/
1931
20E_040C
SW_PAD_CTL_PAD_NAND_DATA00 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_DATA00)
32
R/W
0000_10B0h
32.6.226/
1933
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1553

<!-- page 1554 -->

IOMUXC memory map (continued)
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
20E_0410
SW_PAD_CTL_PAD_NAND_DATA01 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_DATA01)
32
R/W
0000_10B0h
32.6.227/
1935
20E_0414
SW_PAD_CTL_PAD_NAND_DATA02 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_DATA02)
32
R/W
0000_10B0h
32.6.228/
1937
20E_0418
SW_PAD_CTL_PAD_NAND_DATA03 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_DATA03)
32
R/W
0000_10B0h
32.6.229/
1939
20E_041C
SW_PAD_CTL_PAD_NAND_DATA04 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_DATA04)
32
R/W
0000_10B0h
32.6.230/
1941
20E_0420
SW_PAD_CTL_PAD_NAND_DATA05 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_DATA05)
32
R/W
0000_10B0h
32.6.231/
1943
20E_0424
SW_PAD_CTL_PAD_NAND_DATA06 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_DATA06)
32
R/W
0000_10B0h
32.6.232/
1945
20E_0428
SW_PAD_CTL_PAD_NAND_DATA07 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_DATA07)
32
R/W
0000_10B0h
32.6.233/
1947
20E_042C
SW_PAD_CTL_PAD_NAND_ALE SW PAD Control Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_ALE)
32
R/W
0000_10B0h
32.6.234/
1949
20E_0430
SW_PAD_CTL_PAD_NAND_WP_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_WP_B)
32
R/W
0000_10B0h
32.6.235/
1951
20E_0434
SW_PAD_CTL_PAD_NAND_READY_B SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_READY_B)
32
R/W
0000_10B0h
32.6.236/
1953
20E_0438
SW_PAD_CTL_PAD_NAND_CE0_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_CE0_B)
32
R/W
0000_10B0h
32.6.237/
1955
20E_043C
SW_PAD_CTL_PAD_NAND_CE1_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_CE1_B)
32
R/W
0000_10B0h
32.6.238/
1957
20E_0440
SW_PAD_CTL_PAD_NAND_CLE SW PAD Control Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_CLE)
32
R/W
0000_10B0h
32.6.239/
1959
20E_0444
SW_PAD_CTL_PAD_NAND_DQS SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_DQS)
32
R/W
0000_10B0h
32.6.240/
1961
20E_0448
SW_PAD_CTL_PAD_SD1_CMD SW PAD Control Register
(IOMUXC_SW_PAD_CTL_PAD_SD1_CMD)
32
R/W
0000_10B0h
32.6.241/
1963
20E_044C
SW_PAD_CTL_PAD_SD1_CLK SW PAD Control Register
(IOMUXC_SW_PAD_CTL_PAD_SD1_CLK)
32
R/W
0000_10B0h
32.6.242/
1965
20E_0450
SW_PAD_CTL_PAD_SD1_DATA0 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_SD1_DATA0)
32
R/W
0000_10B0h
32.6.243/
1967
20E_0454
SW_PAD_CTL_PAD_SD1_DATA1 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_SD1_DATA1)
32
R/W
0000_10B0h
32.6.244/
1969
20E_0458
SW_PAD_CTL_PAD_SD1_DATA2 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_SD1_DATA2)
32
R/W
0000_10B0h
32.6.245/
1971
20E_045C
SW_PAD_CTL_PAD_SD1_DATA3 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_SD1_DATA3)
32
R/W
0000_10B0h
32.6.246/
1973
20E_0460
SW_PAD_CTL_PAD_CSI_MCLK SW PAD Control Register
(IOMUXC_SW_PAD_CTL_PAD_CSI_MCLK)
32
R/W
0000_10B0h
32.6.247/
1975
20E_0464
SW_PAD_CTL_PAD_CSI_PIXCLK SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_PIXCLK)
32
R/W
0000_10B0h
32.6.248/
1977
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1554
NXP Semiconductors

<!-- page 1555 -->

IOMUXC memory map (continued)
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
20E_0468
SW_PAD_CTL_PAD_CSI_VSYNC SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_VSYNC)
32
R/W
0000_10B0h
32.6.249/
1979
20E_046C
SW_PAD_CTL_PAD_CSI_HSYNC SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_HSYNC)
32
R/W
0000_10B0h
32.6.250/
1981
20E_0470
SW_PAD_CTL_PAD_CSI_DATA00 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA00)
32
R/W
0000_10B0h
32.6.251/
1983
20E_0474
SW_PAD_CTL_PAD_CSI_DATA01 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA01)
32
R/W
0000_10B0h
32.6.252/
1985
20E_0478
SW_PAD_CTL_PAD_CSI_DATA02 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA02)
32
R/W
0000_10B0h
32.6.253/
1987
20E_047C
SW_PAD_CTL_PAD_CSI_DATA03 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA03)
32
R/W
0000_10B0h
32.6.254/
1989
20E_0480
SW_PAD_CTL_PAD_CSI_DATA04 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA04)
32
R/W
0000_10B0h
32.6.255/
1991
20E_0484
SW_PAD_CTL_PAD_CSI_DATA05 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA05)
32
R/W
0000_10B0h
32.6.256/
1993
20E_0488
SW_PAD_CTL_PAD_CSI_DATA06 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA06)
32
R/W
0000_10B0h
32.6.257/
1995
20E_048C
SW_PAD_CTL_PAD_CSI_DATA07 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA07)
32
R/W
0000_10B0h
32.6.258/
1997
20E_0490
SW_PAD_CTL_GRP_ADDDS SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_ADDDS)
32
R/W
0000_0030h
32.6.259/
1998
20E_0494
SW_PAD_CTL_GRP_DDRMODE_CTL SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDRMODE_CTL)
32
R/W
0000_0000h
32.6.260/
1999
20E_0498
SW_PAD_CTL_GRP_B0DS SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_B0DS)
32
R/W
0000_0030h
32.6.261/
2000
20E_049C
SW_PAD_CTL_GRP_DDRPK SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDRPK)
32
R/W
0000_2000h
32.6.262/
2001
20E_04A0
SW_PAD_CTL_GRP_CTLDS SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_CTLDS)
32
R/W
0000_0030h
32.6.263/
2001
20E_04A4
SW_PAD_CTL_GRP_B1DS SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_B1DS)
32
R/W
0000_0030h
32.6.264/
2002
20E_04A8
SW_PAD_CTL_GRP_DDRHYS SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDRHYS)
32
R/W
0000_0000h
32.6.265/
2003
20E_04AC
SW_PAD_CTL_GRP_DDRPKE SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDRPKE)
32
R/W
0000_1000h
32.6.266/
2004
20E_04B0
SW_PAD_CTL_GRP_DDRMODE SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDRMODE)
32
R/W
0000_0000h
32.6.267/
2005
20E_04B4
SW_PAD_CTL_GRP_DDR_TYPE SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDR_TYPE)
32
R/W
0008_0000h
32.6.268/
2006
20E_04B8
USB_OTG1_ID_SELECT_INPUT DAISY Register
(IOMUXC_ANATOP_USB_OTG_ID_SELECT_INPUT)
32
R/W
0000_0000h
32.6.269/
2007
20E_04BC
USB_OTG2_ID_SELECT_INPUT DAISY Register
(IOMUXC_USB_OTG2_ID_SELECT_INPUT)
32
R/W
0000_0000h
32.6.270/
2007
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1555

<!-- page 1556 -->

IOMUXC memory map (continued)
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
20E_04C0
CCM_PMIC_READY_SELECT_INPUT DAISY Register
(IOMUXC_CCM_PMIC_READY_SELECT_INPUT)
32
R/W
0000_0000h
32.6.271/
2008
20E_04C4
CSI_DATA02_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA02_SELECT_INPUT)
32
R/W
0000_0000h
32.6.272/
2009
20E_04C8
CSI_DATA03_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA03_SELECT_INPUT)
32
R/W
0000_0000h
32.6.273/
2010
20E_04CC
CSI_DATA05_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA05_SELECT_INPUT)
32
R/W
0000_0000h
32.6.274/
2011
20E_04D0
CSI_DATA00_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA00_SELECT_INPUT)
32
R/W
0000_0000h
32.6.275/
2012
20E_04D4
CSI_DATA01_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA01_SELECT_INPUT)
32
R/W
0000_0000h
32.6.276/
2013
20E_04D8
CSI_DATA04_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA04_SELECT_INPUT)
32
R/W
0000_0000h
32.6.277/
2014
20E_04DC
CSI_DATA06_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA06_SELECT_INPUT)
32
R/W
0000_0000h
32.6.278/
2015
20E_04E0
CSI_DATA07_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA07_SELECT_INPUT)
32
R/W
0000_0000h
32.6.279/
2016
20E_04E4
CSI_DATA08_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA08_SELECT_INPUT)
32
R/W
0000_0000h
32.6.280/
2017
20E_04E8
CSI_DATA09_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA09_SELECT_INPUT)
32
R/W
0000_0000h
32.6.281/
2018
20E_04EC
CSI_DATA10_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA10_SELECT_INPUT)
32
R/W
0000_0000h
32.6.282/
2019
20E_04F0
CSI_DATA11_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA11_SELECT_INPUT)
32
R/W
0000_0000h
32.6.283/
2020
20E_04F4
CSI_DATA12_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA12_SELECT_INPUT)
32
R/W
0000_0000h
32.6.284/
2021
20E_04F8
CSI_DATA13_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA13_SELECT_INPUT)
32
R/W
0000_0000h
32.6.285/
2022
20E_04FC
CSI_DATA14_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA14_SELECT_INPUT)
32
R/W
0000_0000h
32.6.286/
2023
20E_0500
CSI_DATA15_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA15_SELECT_INPUT)
32
R/W
0000_0000h
32.6.287/
2024
20E_0504
CSI_DATA16_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA16_SELECT_INPUT)
32
R/W
0000_0000h
32.6.288/
2025
20E_0508
CSI_DATA17_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA17_SELECT_INPUT)
32
R/W
0000_0000h
32.6.289/
2026
20E_050C
CSI_DATA18_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA18_SELECT_INPUT)
32
R/W
0000_0000h
32.6.290/
2027
20E_0510
CSI_DATA19_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA19_SELECT_INPUT)
32
R/W
0000_0000h
32.6.291/
2028
20E_0514
CSI_DATA20_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA20_SELECT_INPUT)
32
R/W
0000_0000h
32.6.292/
2029
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1556
NXP Semiconductors

<!-- page 1557 -->

IOMUXC memory map (continued)
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
20E_0518
CSI_DATA21_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA21_SELECT_INPUT)
32
R/W
0000_0000h
32.6.293/
2030
20E_051C
CSI_DATA22_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA22_SELECT_INPUT)
32
R/W
0000_0000h
32.6.294/
2031
20E_0520
CSI_DATA23_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA23_SELECT_INPUT)
32
R/W
0000_0000h
32.6.295/
2032
20E_0524
CSI_HSYNC_SELECT_INPUT DAISY Register
(IOMUXC_CSI_HSYNC_SELECT_INPUT)
32
R/W
0000_0000h
32.6.296/
2033
20E_0528
CSI_PIXCLK_SELECT_INPUT DAISY Register
(IOMUXC_CSI_PIXCLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.297/
2034
20E_052C
CSI_VSYNC_SELECT_INPUT DAISY Register
(IOMUXC_CSI_VSYNC_SELECT_INPUT)
32
R/W
0000_0000h
32.6.298/
2035
20E_0530
CSI_FIELD_SELECT_INPUT DAISY Register
(IOMUXC_CSI_FIELD_SELECT_INPUT)
32
R/W
0000_0000h
32.6.299/
2036
20E_0534
ECSPI1_SCLK_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI1_SCLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.300/
2037
20E_0538
ECSPI1_MISO_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI1_MISO_SELECT_INPUT)
32
R/W
0000_0000h
32.6.301/
2038
20E_053C
ECSPI1_MOSI_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI1_MOSI_SELECT_INPUT)
32
R/W
0000_0000h
32.6.302/
2039
20E_0540
ECSPI1_SS0_B_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI1_SS0_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.303/
2040
20E_0544
ECSPI2_SCLK_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI2_SCLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.304/
2041
20E_0548
ECSPI2_MISO_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI2_MISO_SELECT_INPUT)
32
R/W
0000_0000h
32.6.305/
2042
20E_054C
ECSPI2_MOSI_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI2_MOSI_SELECT_INPUT)
32
R/W
0000_0000h
32.6.306/
2043
20E_0550
ECSPI2_SS0_B_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI2_SS0_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.307/
2044
20E_0554
ECSPI3_SCLK_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI3_SCLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.308/
2045
20E_0558
ECSPI3_MISO_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI3_MISO_SELECT_INPUT)
32
R/W
0000_0000h
32.6.309/
2046
20E_055C
ECSPI3_MOSI_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI3_MOSI_SELECT_INPUT)
32
R/W
0000_0000h
32.6.310/
2047
20E_0560
ECSPI3_SS0_B_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI3_SS0_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.311/
2048
20E_0564
ECSPI4_SCLK_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI4_SCLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.312/
2049
20E_0568
ECSPI4_MISO_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI4_MISO_SELECT_INPUT)
32
R/W
0000_0000h
32.6.313/
2050
20E_056C
ECSPI4_MOSI_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI4_MOSI_SELECT_INPUT)
32
R/W
0000_0000h
32.6.314/
2051
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1557

<!-- page 1558 -->

IOMUXC memory map (continued)
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
20E_0570
ECSPI4_SS0_B_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI4_SS0_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.315/
2052
20E_0574
ENET1_REF_CLK1_SELECT_INPUT DAISY Register
(IOMUXC_ENET1_REF_CLK1_SELECT_INPUT)
32
R/W
0000_0000h
32.6.316/
2052
20E_0578
ENET1_MAC0_MDIO_SELECT_INPUT DAISY Register
(IOMUXC_ENET1_MAC0_MDIO_SELECT_INPUT)
32
R/W
0000_0000h
32.6.317/
2053
20E_057C
ENET2_REF_CLK2_SELECT_INPUT DAISY Register
(IOMUXC_ENET2_REF_CLK2_SELECT_INPUT)
32
R/W
0000_0000h
32.6.318/
2054
20E_0580
ENET2_MAC0_MDIO_SELECT_INPUT DAISY Register
(IOMUXC_ENET2_MAC0_MDIO_SELECT_INPUT)
32
R/W
0000_0000h
32.6.319/
2055
20E_0584
FLEXCAN1_RX_SELECT_INPUT DAISY Register
(IOMUXC_FLEXCAN1_RX_SELECT_INPUT)
32
R/W
0000_0000h
32.6.320/
2055
20E_0588
FLEXCAN2_RX_SELECT_INPUT DAISY Register
(IOMUXC_FLEXCAN2_RX_SELECT_INPUT)
32
R/W
0000_0000h
32.6.321/
2056
20E_058C
GPT1_CAPTURE1_SELECT_INPUT DAISY Register
(IOMUXC_GPT1_CAPTURE1_SELECT_INPUT)
32
R/W
0000_0000h
32.6.322/
2057
20E_0590
GPT1_CAPTURE2_SELECT_INPUT DAISY Register
(IOMUXC_GPT1_CAPTURE2_SELECT_INPUT)
32
R/W
0000_0000h
32.6.323/
2058
20E_0594
GPT1_CLK_SELECT_INPUT DAISY Register
(IOMUXC_GPT1_CLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.324/
2059
20E_0598
GPT2_CAPTURE1_SELECT_INPUT DAISY Register
(IOMUXC_GPT2_CAPTURE1_SELECT_INPUT)
32
R/W
0000_0000h
32.6.325/
2060
20E_059C
GPT2_CAPTURE2_SELECT_INPUT DAISY Register
(IOMUXC_GPT2_CAPTURE2_SELECT_INPUT)
32
R/W
0000_0000h
32.6.326/
2061
20E_05A0
GPT2_CLK_SELECT_INPUT DAISY Register
(IOMUXC_GPT2_CLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.327/
2062
20E_05A4
I2C1_SCL_SELECT_INPUT DAISY Register
(IOMUXC_I2C1_SCL_SELECT_INPUT)
32
R/W
0000_0000h
32.6.328/
2062
20E_05A8
I2C1_SDA_SELECT_INPUT DAISY Register
(IOMUXC_I2C1_SDA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.329/
2063
20E_05AC
I2C2_SCL_SELECT_INPUT DAISY Register
(IOMUXC_I2C2_SCL_SELECT_INPUT)
32
R/W
0000_0000h
32.6.330/
2064
20E_05B0
I2C2_SDA_SELECT_INPUT DAISY Register
(IOMUXC_I2C2_SDA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.331/
2064
20E_05B4
I2C3_SCL_SELECT_INPUT DAISY Register
(IOMUXC_I2C3_SCL_SELECT_INPUT)
32
R/W
0000_0000h
32.6.332/
2065
20E_05B8
I2C3_SDA_SELECT_INPUT DAISY Register
(IOMUXC_I2C3_SDA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.333/
2066
20E_05BC
I2C4_SCL_SELECT_INPUT DAISY Register
(IOMUXC_I2C4_SCL_SELECT_INPUT)
32
R/W
0000_0000h
32.6.334/
2066
20E_05C0
I2C4_SDA_SELECT_INPUT DAISY Register
(IOMUXC_I2C4_SDA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.335/
2067
20E_05C4
KPP_COL0_SELECT_INPUT DAISY Register
(IOMUXC_KPP_COL0_SELECT_INPUT)
32
R/W
0000_0000h
32.6.336/
2068
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1558
NXP Semiconductors

<!-- page 1559 -->

IOMUXC memory map (continued)
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
20E_05C8
KPP_COL1_SELECT_INPUT DAISY Register
(IOMUXC_KPP_COL1_SELECT_INPUT)
32
R/W
0000_0000h
32.6.337/
2069
20E_05CC
KPP_COL2_SELECT_INPUT DAISY Register
(IOMUXC_KPP_COL2_SELECT_INPUT)
32
R/W
0000_0000h
32.6.338/
2070
20E_05D0
KPP_ROW0_SELECT_INPUT DAISY Register
(IOMUXC_KPP_ROW0_SELECT_INPUT)
32
R/W
0000_0000h
32.6.339/
2071
20E_05D4
KPP_ROW1_SELECT_INPUT DAISY Register
(IOMUXC_KPP_ROW1_SELECT_INPUT)
32
R/W
0000_0000h
32.6.340/
2072
20E_05D8
KPP_ROW2_SELECT_INPUT DAISY Register
(IOMUXC_KPP_ROW2_SELECT_INPUT)
32
R/W
0000_0000h
32.6.341/
2073
20E_05DC
LCD_BUSY_SELECT_INPUT DAISY Register
(IOMUXC_LCD_BUSY_SELECT_INPUT)
32
R/W
0000_0000h
32.6.342/
2074
20E_05E0
SAI1_MCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI1_MCLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.343/
2075
20E_05E4
SAI1_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_SAI1_RX_DATA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.344/
2076
20E_05E8
SAI1_TX_BCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI1_TX_BCLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.345/
2077
20E_05EC
SAI1_TX_SYNC_SELECT_INPUT DAISY Register
(IOMUXC_SAI1_TX_SYNC_SELECT_INPUT)
32
R/W
0000_0000h
32.6.346/
2078
20E_05F0
SAI2_MCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI2_MCLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.347/
2079
20E_05F4
SAI2_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_SAI2_RX_DATA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.348/
2080
20E_05F8
SAI2_TX_BCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI2_TX_BCLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.349/
2081
20E_05FC
SAI2_TX_SYNC_SELECT_INPUT DAISY Register
(IOMUXC_SAI2_TX_SYNC_SELECT_INPUT)
32
R/W
0000_0000h
32.6.350/
2082
20E_0600
SAI3_MCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI3_MCLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.351/
2083
20E_0604
SAI3_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_SAI3_RX_DATA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.352/
2084
20E_0608
SAI3_TX_BCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI3_TX_BCLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.353/
2085
20E_060C
SAI3_TX_SYNC_SELECT_INPUT DAISY Register
(IOMUXC_SAI3_TX_SYNC_SELECT_INPUT)
32
R/W
0000_0000h
32.6.354/
2086
20E_0610
SDMA_EVENTS0_SELECT_INPUT DAISY Register
(IOMUXC_SDMA_EVENTS0_SELECT_INPUT)
32
R/W
0000_0000h
32.6.355/
2086
20E_0614
SDMA_EVENTS1_SELECT_INPUT DAISY Register
(IOMUXC_SDMA_EVENTS1_SELECT_INPUT)
32
R/W
0000_0000h
32.6.356/
2087
20E_0618
SPDIF_IN_SELECT_INPUT DAISY Register
(IOMUXC_SPDIF_IN_SELECT_INPUT)
32
R/W
0000_0000h
32.6.357/
2088
20E_061C
SPDIF_EXT_CLK_SELECT_INPUT DAISY Register
(IOMUXC_SPDIF_EXT_CLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.358/
2089
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1559

<!-- page 1560 -->

IOMUXC memory map (continued)
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
20E_0620
UART1_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART1_RTS_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.359/
2089
20E_0624
UART1_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART1_RX_DATA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.360/
2090
20E_0628
UART2_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART2_RTS_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.361/
2091
20E_062C
UART2_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART2_RX_DATA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.362/
2091
20E_0630
UART3_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART3_RTS_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.363/
2092
20E_0634
UART3_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART3_RX_DATA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.364/
2093
20E_0638
UART4_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART4_RTS_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.365/
2093
20E_063C
UART4_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART4_RX_DATA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.366/
2094
20E_0640
UART5_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART5_RTS_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.367/
2095
20E_0644
UART5_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART5_RX_DATA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.368/
2095
20E_0648
UART6_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART6_RTS_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.369/
2096
20E_064C
UART6_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART6_RX_DATA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.370/
2097
20E_0650
UART7_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART7_RTS_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.371/
2097
20E_0654
UART7_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART7_RX_DATA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.372/
2098
20E_0658
UART8_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART8_RTS_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.373/
2099
20E_065C
UART8_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART8_RX_DATA_SELECT_INPUT)
32
R/W
0000_0000h
32.6.374/
2099
20E_0660
USB_OTG2_OC_SELECT_INPUT DAISY Register
(IOMUXC_USB_OTG2_OC_SELECT_INPUT)
32
R/W
0000_0000h
32.6.375/
2100
20E_0664
USB_OTG_OC_SELECT_INPUT DAISY Register
(IOMUXC_USB_OTG_OC_SELECT_INPUT)
32
R/W
0000_0000h
32.6.376/
2101
20E_0668
USDHC1_CD_B_SELECT_INPUT DAISY Register
(IOMUXC_USDHC1_CD_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.377/
2101
20E_066C
USDHC1_WP_SELECT_INPUT DAISY Register
(IOMUXC_USDHC1_WP_SELECT_INPUT)
32
R/W
0000_0000h
32.6.378/
2102
20E_0670
USDHC2_CLK_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_CLK_SELECT_INPUT)
32
R/W
0000_0000h
32.6.379/
2103
20E_0674
USDHC2_CD_B_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_CD_B_SELECT_INPUT)
32
R/W
0000_0000h
32.6.380/
2103
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1560
NXP Semiconductors

<!-- page 1561 -->

IOMUXC memory map (continued)
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
20E_0678
USDHC2_CMD_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_CMD_SELECT_INPUT)
32
R/W
0000_0000h
32.6.381/
2104
20E_067C
USDHC2_DATA0_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA0_SELECT_INPUT)
32
R/W
0000_0000h
32.6.382/
2105
20E_0680
USDHC2_DATA1_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA1_SELECT_INPUT)
32
R/W
0000_0000h
32.6.383/
2105
20E_0684
USDHC2_DATA2_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA2_SELECT_INPUT)
32
R/W
0000_0000h
32.6.384/
2106
20E_0688
USDHC2_DATA3_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA3_SELECT_INPUT)
32
R/W
0000_0000h
32.6.385/
2107
20E_068C
USDHC2_DATA4_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA4_SELECT_INPUT)
32
R/W
0000_0000h
32.6.386/
2107
20E_0690
USDHC2_DATA5_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA5_SELECT_INPUT)
32
R/W
0000_0000h
32.6.387/
2108
20E_0694
USDHC2_DATA6_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA6_SELECT_INPUT)
32
R/W
0000_0000h
32.6.388/
2109
20E_0698
USDHC2_DATA7_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA7_SELECT_INPUT)
32
R/W
0000_0000h
32.6.389/
2109
20E_069C
USDHC2_WP_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_WP_SELECT_INPUT)
32
R/W
0000_0000h
32.6.390/
2110
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1561

<!-- page 1562 -->

32.6.1
SW_MUX_CTL_PAD_JTAG_MOD SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_JTAG_MOD)
SW_MUX_CTL Register
Address: 20E_0000h base + 44h offset = 20E_0044h
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
SION
Reserved
MUX_MODE
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
IOMUXC_SW_MUX_CTL_PAD_JTAG_MOD field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad JTAG_MOD
0
DISABLED — Input Path is determined by functionality
3
-
This field is reserved.
Reserved
MUX_MODE
MUX Mode Select Field.
Select 1 of 7 iomux modes to be used for pad: JTAG_MOD.
000
ALT0 — Select mux mode: ALT0 mux port: SJC_MOD of instance: sjc
001
ALT1 — Select mux mode: ALT1 mux port: GPT2_CLK of instance: gpt2
010
ALT2 — Select mux mode: ALT2 mux port: SPDIF_OUT of instance: spdif
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1562
NXP Semiconductors

<!-- page 1563 -->

IOMUXC_SW_MUX_CTL_PAD_JTAG_MOD field descriptions (continued)
Field
Description
011
ALT3 — Select mux mode: ALT3 mux port: ENET1_REF_CLK_25M of instance: enet1
100
ALT4 — Select mux mode: ALT4 mux port: CCM_PMIC_RDY of instance: ccm
101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO10 of instance: gpio1
110
ALT6 — Select mux mode: ALT6 mux port: SDMA_EXT_EVENT00 of instance: sdma
32.6.2
SW_MUX_CTL_PAD_JTAG_TMS SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_JTAG_TMS)
SW_MUX_CTL Register
Address: 20E_0000h base + 48h offset = 20E_0048h
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
SION
MUX_MODE
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
IOMUXC_SW_MUX_CTL_PAD_JTAG_TMS field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad JTAG_TMS
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 8 iomux modes to be used for pad: JTAG_TMS.
0000
ALT0 — Select mux mode: ALT0 mux port: SJC_TMS of instance: sjc
0001
ALT1 — Select mux mode: ALT1 mux port: GPT2_CAPTURE1 of instance: gpt2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_MCLK of instance: sai2
0011
ALT3 — Select mux mode: ALT3 mux port: CCM_CLKO1 of instance: ccm
0100
ALT4 — Select mux mode: ALT4 mux port: CCM_WAIT of instance: ccm
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO11 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: SDMA_EXT_EVENT01 of instance: sdma
1000
ALT8 — Select mux mode: ALT8 mux port: EPIT1_OUT of instance: epit1
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1563

<!-- page 1564 -->

32.6.3
SW_MUX_CTL_PAD_JTAG_TDO SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_JTAG_TDO)
SW_MUX_CTL Register
Address: 20E_0000h base + 4Ch offset = 20E_004Ch
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
SION
MUX_MODE
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
IOMUXC_SW_MUX_CTL_PAD_JTAG_TDO field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad JTAG_TDO
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 8 iomux modes to be used for pad: JTAG_TDO.
0000
ALT0 — Select mux mode: ALT0 mux port: SJC_TDO of instance: sjc
0001
ALT1 — Select mux mode: ALT1 mux port: GPT2_CAPTURE2 of instance: gpt2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_TX_SYNC of instance: sai2
0011
ALT3 — Select mux mode: ALT3 mux port: CCM_CLKO2 of instance: ccm
0100
ALT4 — Select mux mode: ALT4 mux port: CCM_STOP of instance: ccm
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO12 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: MQS_RIGHT of instance: mqs
1000
ALT8 — Select mux mode: ALT8 mux port: EPIT2_OUT of instance: epit2
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1564
NXP Semiconductors

<!-- page 1565 -->

32.6.4
SW_MUX_CTL_PAD_JTAG_TDI SW MUX Control Register
(IOMUXC_SW_MUX_CTL_PAD_JTAG_TDI)
SW_MUX_CTL Register
Address: 20E_0000h base + 50h offset = 20E_0050h
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
SION
Reserved
MUX_MODE
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
IOMUXC_SW_MUX_CTL_PAD_JTAG_TDI field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad JTAG_TDI
0
DISABLED — Input Path is determined by functionality
3
-
This field is reserved.
Reserved
MUX_MODE
MUX Mode Select Field.
Select 1 of 7 iomux modes to be used for pad: JTAG_TDI.
0000
ALT0 — Select mux mode: ALT0 mux port: SJC_TDI of instance: sjc
0001
ALT1 — Select mux mode: ALT1 mux port: GPT2_COMPARE1 of instance: gpt2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_TX_BCLK of instance: sai2
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1565

<!-- page 1566 -->

IOMUXC_SW_MUX_CTL_PAD_JTAG_TDI field descriptions (continued)
Field
Description
0100
ALT4 — Select mux mode: ALT4 mux port: PWM6_OUT of instance: pwm6
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO13 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: MQS_LEFT of instance: mqs
1000
ALT8 — Select mux mode: ALT8 mux port: SIM1_POWER_FAIL of instance: sim1
32.6.5
SW_MUX_CTL_PAD_JTAG_TCK SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_JTAG_TCK)
SW_MUX_CTL Register
Address: 20E_0000h base + 54h offset = 20E_0054h
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
SION
Reserved
MUX_MODE
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
IOMUXC_SW_MUX_CTL_PAD_JTAG_TCK field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad JTAG_TCK
0
DISABLED — Input Path is determined by functionality
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1566
NXP Semiconductors

<!-- page 1567 -->

IOMUXC_SW_MUX_CTL_PAD_JTAG_TCK field descriptions (continued)
Field
Description
3
-
This field is reserved.
Reserved
MUX_MODE
MUX Mode Select Field.
Select 1 of 7 iomux modes to be used for pad: JTAG_TCK.
0000
ALT0 — Select mux mode: ALT0 mux port: SJC_TCK of instance: sjc
0001
ALT1 — Select mux mode: ALT1 mux port: GPT2_COMPARE2 of instance: gpt2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_RX_DATA of instance: sai2
0100
ALT4 — Select mux mode: ALT4 mux port: PWM7_OUT of instance: pwm7
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO14 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: SIM2_POWER_FAIL of instance: sim2
32.6.6
SW_MUX_CTL_PAD_JTAG_TRST_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_JTAG_TRST_B)
SW_MUX_CTL Register
Address: 20E_0000h base + 58h offset = 20E_0058h
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
SION
Reserved
MUX_MODE
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1567

<!-- page 1568 -->

IOMUXC_SW_MUX_CTL_PAD_JTAG_TRST_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad JTAG_TRST_B
0
DISABLED — Input Path is determined by functionality
3
-
This field is reserved.
Reserved
MUX_MODE
MUX Mode Select Field.
Select 1 of 7 iomux modes to be used for pad: JTAG_TRST_B.
0000
ALT0 — Select mux mode: ALT0 mux port: SJC_TRSTB of instance: sjc
0001
ALT1 — Select mux mode: ALT1 mux port: GPT2_COMPARE3 of instance: gpt2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_TX_DATA of instance: sai2
0100
ALT4 — Select mux mode: ALT4 mux port: PWM8_OUT of instance: pwm8
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO15 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: CAAM_RNG_OSC_OBS of instance: caam
32.6.7
SW_MUX_CTL_PAD_GPIO1_IO00 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO00)
SW_MUX_CTL Register
Address: 20E_0000h base + 5Ch offset = 20E_005Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO00 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1568
NXP Semiconductors

<!-- page 1569 -->

IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO00 field descriptions (continued)
Field
Description
1
ENABLED — Force input path of pad GPIO1_IO00
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: GPIO1_IO00.
0000
ALT0 — Select mux mode: ALT0 mux port: I2C2_SCL of instance: i2c2
0001
ALT1 — Select mux mode: ALT1 mux port: GPT1_CAPTURE1 of instance: gpt1
0010
ALT2 — Select mux mode: ALT2 mux port: ANATOP_OTG1_ID of instance: anatop
0011
ALT3 — Select mux mode: ALT3 mux port: ENET1_REF_CLK1 of instance: enet1
0100
ALT4 — Select mux mode: ALT4 mux port: MQS_RIGHT of instance: mqs
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO00 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: ENET1_1588_EVENT0_IN of instance: enet1
0111
ALT7 — Select mux mode: ALT7 mux port: SRC_SYSTEM_RESET of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: WDOG3_WDOG_B of instance: wdog3
32.6.8
SW_MUX_CTL_PAD_GPIO1_IO01 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO01)
SW_MUX_CTL Register
Address: 20E_0000h base + 60h offset = 20E_0060h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO01 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad GPIO1_IO01
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: GPIO1_IO01.
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1569

<!-- page 1570 -->

IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO01 field descriptions (continued)
Field
Description
0000
ALT0 — Select mux mode: ALT0 mux port: I2C2_SDA of instance: i2c2
0001
ALT1 — Select mux mode: ALT1 mux port: GPT1_COMPARE1 of instance: gpt1
0010
ALT2 — Select mux mode: ALT2 mux port: USB_OTG1_OC of instance: usb
0011
ALT3 — Select mux mode: ALT3 mux port: ENET2_REF_CLK2 of instance: enet2
0100
ALT4 — Select mux mode: ALT4 mux port: MQS_LEFT of instance: mqs
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO01 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: ENET1_1588_EVENT0_OUT of instance: enet1
0111
ALT7 — Select mux mode: ALT7 mux port: SRC_EARLY_RESET of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: WDOG1_WDOG_B of instance: wdog1
32.6.9
SW_MUX_CTL_PAD_GPIO1_IO02 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO02)
SW_MUX_CTL Register
Address: 20E_0000h base + 64h offset = 20E_0064h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO02 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad GPIO1_IO02
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: GPIO1_IO02.
0000
ALT0 — Select mux mode: ALT0 mux port: I2C1_SCL of instance: i2c1
0001
ALT1 — Select mux mode: ALT1 mux port: GPT1_COMPARE2 of instance: gpt1
0010
ALT2 — Select mux mode: ALT2 mux port: USB_OTG2_PWR of instance: usb
0011
ALT3 — Select mux mode: ALT3 mux port: ENET1_REF_CLK_25M of instance: enet1
0100
ALT4 — Select mux mode: ALT4 mux port: USDHC1_WP of instance: usdhc1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO02 of instance: gpio1
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1570
NXP Semiconductors

<!-- page 1571 -->

IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO02 field descriptions (continued)
Field
Description
0110
ALT6 — Select mux mode: ALT6 mux port: SDMA_EXT_EVENT00 of instance: sdma
0111
ALT7 — Select mux mode: ALT7 mux port: SRC_ANY_PU_RESET of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: UART1_TX of instance: uart1
32.6.10
SW_MUX_CTL_PAD_GPIO1_IO03 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO03)
SW_MUX_CTL Register
Address: 20E_0000h base + 68h offset = 20E_0068h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO03 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad GPIO1_IO03
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: GPIO1_IO03.
0000
ALT0 — Select mux mode: ALT0 mux port: I2C1_SDA of instance: i2c1
0001
ALT1 — Select mux mode: ALT1 mux port: GPT1_COMPARE3 of instance: gpt1
0010
ALT2 — Select mux mode: ALT2 mux port: USB_OTG2_OC of instance: usb
0100
ALT4 — Select mux mode: ALT4 mux port: USDHC1_CD_B of instance: usdhc1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO03 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: CCM_DI0_EXT_CLK of instance: ccm
0111
ALT7 — Select mux mode: ALT7 mux port: SRC_TESTER_ACK of instance: src
NOTE: ALT7 mode will be automatically active when system reset. The PAD setting will be 100 K
pull down and input enable during reset period. Once system reset is completed, the state
of GPIO1_IO03 will be output keeper and input enable.
1000
ALT8 — Select mux mode: ALT8 mux port: UART1_RX of instance: uart1
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1571

<!-- page 1572 -->

32.6.11
SW_MUX_CTL_PAD_GPIO1_IO04 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO04)
SW_MUX_CTL Register
Address: 20E_0000h base + 6Ch offset = 20E_006Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO04 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad GPIO1_IO04
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: GPIO1_IO04.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET1_REF_CLK1 of instance: enet1
0001
ALT1 — Select mux mode: ALT1 mux port: PWM3_OUT of instance: pwm3
0010
ALT2 — Select mux mode: ALT2 mux port: USB_OTG1_PWR of instance: usb
0100
ALT4 — Select mux mode: ALT4 mux port: USDHC1_RESET_B of instance: usdhc1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO04 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: ENET2_1588_EVENT0_IN of instance: enet2
1000
ALT8 — Select mux mode: ALT8 mux port: UART5_TX of instance: uart5
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1572
NXP Semiconductors

<!-- page 1573 -->

32.6.12
SW_MUX_CTL_PAD_GPIO1_IO05 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO05)
SW_MUX_CTL Register
Address: 20E_0000h base + 70h offset = 20E_0070h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO05 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad GPIO1_IO05
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: GPIO1_IO05.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET2_REF_CLK2 of instance: enet2
0001
ALT1 — Select mux mode: ALT1 mux port: PWM4_OUT of instance: pwm4
0010
ALT2 — Select mux mode: ALT2 mux port: ANATOP_OTG2_ID of instance: anatop
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_FIELD of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: USDHC1_VSELECT of instance: usdhc1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO05 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: ENET2_1588_EVENT0_OUT of instance: enet2
1000
ALT8 — Select mux mode: ALT8 mux port: UART5_RX of instance: uart5
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1573

<!-- page 1574 -->

32.6.13
SW_MUX_CTL_PAD_GPIO1_IO06 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO06)
SW_MUX_CTL Register
Address: 20E_0000h base + 74h offset = 20E_0074h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO06 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad GPIO1_IO06
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: GPIO1_IO06.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET1_MDIO of instance: enet1
0001
ALT1 — Select mux mode: ALT1 mux port: ENET2_MDIO of instance: enet2
0010
ALT2 — Select mux mode: ALT2 mux port: USB_OTG_PWR_WAKE of instance: usb
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_MCLK of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: USDHC2_WP of instance: usdhc2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO06 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: CCM_WAIT of instance: ccm
0111
ALT7 — Select mux mode: ALT7 mux port: CCM_REF_EN_B of instance: ccm
1000
ALT8 — Select mux mode: ALT8 mux port: UART1_CTS_B of instance: uart1
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1574
NXP Semiconductors

<!-- page 1575 -->

32.6.14
SW_MUX_CTL_PAD_GPIO1_IO07 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO07)
SW_MUX_CTL Register
Address: 20E_0000h base + 78h offset = 20E_0078h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO07 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad GPIO1_IO07
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: GPIO1_IO07.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET1_MDC of instance: enet1
0001
ALT1 — Select mux mode: ALT1 mux port: ENET2_MDC of instance: enet2
0010
ALT2 — Select mux mode: ALT2 mux port: USB_OTG_HOST_MODE of instance: usb
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_PIXCLK of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: USDHC2_CD_B of instance: usdhc2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO07 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: CCM_STOP of instance: ccm
1000
ALT8 — Select mux mode: ALT8 mux port: UART1_RTS_B of instance: uart1
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1575

<!-- page 1576 -->

32.6.15
SW_MUX_CTL_PAD_GPIO1_IO08 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO08)
SW_MUX_CTL Register
Address: 20E_0000h base + 7Ch offset = 20E_007Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO08 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad GPIO1_IO08
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: GPIO1_IO08.
0000
ALT0 — Select mux mode: ALT0 mux port: PWM1_OUT of instance: pwm1
0001
ALT1 — Select mux mode: ALT1 mux port: WDOG1_WDOG_B of instance: wdog1
0010
ALT2 — Select mux mode: ALT2 mux port: SPDIF_OUT of instance: spdif
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_VSYNC of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: USDHC2_VSELECT of instance: usdhc2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO08 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: CCM_PMIC_RDY of instance: ccm
1000
ALT8 — Select mux mode: ALT8 mux port: UART5_RTS_B of instance: uart5
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1576
NXP Semiconductors

<!-- page 1577 -->

32.6.16
SW_MUX_CTL_PAD_GPIO1_IO09 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO09)
SW_MUX_CTL Register
Address: 20E_0000h base + 80h offset = 20E_0080h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_GPIO1_IO09 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad GPIO1_IO09
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: GPIO1_IO09.
0000
ALT0 — Select mux mode: ALT0 mux port: PWM2_OUT of instance: pwm2
0001
ALT1 — Select mux mode: ALT1 mux port: WDOG1_WDOG_ANY of instance: wdog1
0010
ALT2 — Select mux mode: ALT2 mux port: SPDIF_IN of instance: spdif
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_HSYNC of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: USDHC2_RESET_B of instance: usdhc2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO09 of instance: gpio1
0110
ALT6 — Select mux mode: ALT6 mux port: USDHC1_RESET_B of instance: usdhc1
1000
ALT8 — Select mux mode: ALT8 mux port: UART5_CTS_B of instance: uart5
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1577

<!-- page 1578 -->

32.6.17
SW_MUX_CTL_PAD_UART1_TX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART1_TX_DATA)
SW_MUX_CTL Register
Address: 20E_0000h base + 84h offset = 20E_0084h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART1_TX_DATA field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART1_TX_DATA
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: UART1_TX_DATA.
0000
ALT0 — Select mux mode: ALT0 mux port: UART1_TX of instance: uart1
0001
ALT1 — Select mux mode: ALT1 mux port: ENET1_RDATA02 of instance: enet1
0010
ALT2 — Select mux mode: ALT2 mux port: I2C3_SCL of instance: i2c3
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA02 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: GPT1_COMPARE1 of instance: gpt1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO16 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: SPDIF_OUT of instance: spdif
1001
ALT9 — Select mux mode: ALT9 mux port: UART5_TX of instance: uart5
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1578
NXP Semiconductors

<!-- page 1579 -->

32.6.18
SW_MUX_CTL_PAD_UART1_RX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART1_RX_DATA)
SW_MUX_CTL Register
Address: 20E_0000h base + 88h offset = 20E_0088h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART1_RX_DATA field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART1_RX_DATA
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: UART1_RX_DATA.
0000
ALT0 — Select mux mode: ALT0 mux port: UART1_RX of instance: uart1
0001
ALT1 — Select mux mode: ALT1 mux port: ENET1_RDATA03 of instance: enet1
0010
ALT2 — Select mux mode: ALT2 mux port: I2C3_SDA of instance: i2c3
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA03 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: GPT1_CLK of instance: gpt1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO17 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: SPDIF_IN of instance: spdif
1001
ALT9 — Select mux mode: ALT9 mux port: UART5_RX of instance: uart5
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1579

<!-- page 1580 -->

32.6.19
SW_MUX_CTL_PAD_UART1_CTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART1_CTS_B)
SW_MUX_CTL Register
Address: 20E_0000h base + 8Ch offset = 20E_008Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART1_CTS_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART1_CTS_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: UART1_CTS_B.
0000
ALT0 — Select mux mode: ALT0 mux port: UART1_CTS_B of instance: uart1
0001
ALT1 — Select mux mode: ALT1 mux port: ENET1_RX_CLK of instance: enet1
0010
ALT2 — Select mux mode: ALT2 mux port: USDHC1_WP of instance: usdhc1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA04 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: ENET2_1588_EVENT1_IN of instance: enet2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO18 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_WP of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: UART5_CTS_B of instance: uart5
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1580
NXP Semiconductors

<!-- page 1581 -->

32.6.20
SW_MUX_CTL_PAD_UART1_RTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART1_RTS_B)
SW_MUX_CTL Register
Address: 20E_0000h base + 90h offset = 20E_0090h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART1_RTS_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART1_RTS_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: UART1_RTS_B.
0000
ALT0 — Select mux mode: ALT0 mux port: UART1_RTS_B of instance: uart1
0001
ALT1 — Select mux mode: ALT1 mux port: ENET1_TX_ER of instance: enet1
0010
ALT2 — Select mux mode: ALT2 mux port: USDHC1_CD_B of instance: usdhc1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA05 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: ENET2_1588_EVENT1_OUT of instance: enet2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO19 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_CD_B of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: UART5_RTS_B of instance: uart5
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1581

<!-- page 1582 -->

32.6.21
SW_MUX_CTL_PAD_UART2_TX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART2_TX_DATA)
SW_MUX_CTL Register
Address: 20E_0000h base + 94h offset = 20E_0094h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART2_TX_DATA field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART2_TX_DATA
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: UART2_TX_DATA.
0000
ALT0 — Select mux mode: ALT0 mux port: UART2_TX of instance: uart2
0001
ALT1 — Select mux mode: ALT1 mux port: ENET1_TDATA02 of instance: enet1
0010
ALT2 — Select mux mode: ALT2 mux port: I2C4_SCL of instance: i2c4
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA06 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: GPT1_CAPTURE1 of instance: gpt1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO20 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI3_SS0 of instance: ecspi3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1582
NXP Semiconductors

<!-- page 1583 -->

32.6.22
SW_MUX_CTL_PAD_UART2_RX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART2_RX_DATA)
SW_MUX_CTL Register
Address: 20E_0000h base + 98h offset = 20E_0098h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART2_RX_DATA field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART2_RX_DATA
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: UART2_RX_DATA.
0000
ALT0 — Select mux mode: ALT0 mux port: UART2_RX of instance: uart2
0001
ALT1 — Select mux mode: ALT1 mux port: ENET1_TDATA03 of instance: enet1
0010
ALT2 — Select mux mode: ALT2 mux port: I2C4_SDA of instance: i2c4
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA07 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: GPT1_CAPTURE2 of instance: gpt1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO21 of instance: gpio1
0111
ALT7 — Select mux mode: ALT7 mux port: SJC_DONE of instance: sjc
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI3_SCLK of instance: ecspi3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1583

<!-- page 1584 -->

32.6.23
SW_MUX_CTL_PAD_UART2_CTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART2_CTS_B)
SW_MUX_CTL Register
Address: 20E_0000h base + 9Ch offset = 20E_009Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART2_CTS_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART2_CTS_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: UART2_CTS_B.
0000
ALT0 — Select mux mode: ALT0 mux port: UART2_CTS_B of instance: uart2
0001
ALT1 — Select mux mode: ALT1 mux port: ENET1_CRS of instance: enet1
0010
ALT2 — Select mux mode: ALT2 mux port: FLEXCAN2_TX of instance: flexcan2
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA08 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: GPT1_COMPARE2 of instance: gpt1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO22 of instance: gpio1
0111
ALT7 — Select mux mode: ALT7 mux port: SJC_DE_B of instance: sjc
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI3_MOSI of instance: ecspi3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1584
NXP Semiconductors

<!-- page 1585 -->

32.6.24
SW_MUX_CTL_PAD_UART2_RTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART2_RTS_B)
SW_MUX_CTL Register
Address: 20E_0000h base + A0h offset = 20E_00A0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART2_RTS_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART2_RTS_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: UART2_RTS_B.
0000
ALT0 — Select mux mode: ALT0 mux port: UART2_RTS_B of instance: uart2
0001
ALT1 — Select mux mode: ALT1 mux port: ENET1_COL of instance: enet1
0010
ALT2 — Select mux mode: ALT2 mux port: FLEXCAN2_RX of instance: flexcan2
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA09 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: GPT1_COMPARE3 of instance: gpt1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO23 of instance: gpio1
0111
ALT7 — Select mux mode: ALT7 mux port: SJC_FAIL of instance: sjc
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI3_MISO of instance: ecspi3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1585

<!-- page 1586 -->

32.6.25
SW_MUX_CTL_PAD_UART3_TX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART3_TX_DATA)
SW_MUX_CTL Register
Address: 20E_0000h base + A4h offset = 20E_00A4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART3_TX_DATA field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART3_TX_DATA
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 8 iomux modes to be used for pad: UART3_TX_DATA.
0000
ALT0 — Select mux mode: ALT0 mux port: UART3_TX of instance: uart3
0001
ALT1 — Select mux mode: ALT1 mux port: ENET2_RDATA02 of instance: enet2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA01 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: UART2_CTS_B of instance: uart2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO24 of instance: gpio1
0111
ALT7 — Select mux mode: ALT7 mux port: SJC_JTAG_ACT of instance: sjc
NOTE: ALT7 mode will be automatically active (output SJC.SJC_JTAG_ACT) when system
reset. Once system reset is completed, the state of UART3_TX_DATA will be output
keeper and input enenable.
1000
ALT8 — Select mux mode: ALT8 mux port: ANATOP_OTG1_ID of instance: anatop
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1586
NXP Semiconductors

<!-- page 1587 -->

32.6.26
SW_MUX_CTL_PAD_UART3_RX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART3_RX_DATA)
SW_MUX_CTL Register
Address: 20E_0000h base + A8h offset = 20E_00A8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART3_RX_DATA field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART3_RX_DATA
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 8 iomux modes to be used for pad: UART3_RX_DATA.
0000
ALT0 — Select mux mode: ALT0 mux port: UART3_RX of instance: uart3
0001
ALT1 — Select mux mode: ALT1 mux port: ENET2_RDATA03 of instance: enet2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA00 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: UART2_RTS_B of instance: uart2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO25 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: EPIT1_OUT of instance: epit1
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1587

<!-- page 1588 -->

32.6.27
SW_MUX_CTL_PAD_UART3_CTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART3_CTS_B)
SW_MUX_CTL Register
Address: 20E_0000h base + ACh offset = 20E_00ACh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART3_CTS_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART3_CTS_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: UART3_CTS_B.
0000
ALT0 — Select mux mode: ALT0 mux port: UART3_CTS_B of instance: uart3
0001
ALT1 — Select mux mode: ALT1 mux port: ENET2_RX_CLK of instance: enet2
0010
ALT2 — Select mux mode: ALT2 mux port: FLEXCAN1_TX of instance: flexcan1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA10 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: ENET1_1588_EVENT1_IN of instance: enet1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO26 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: EPIT2_OUT of instance: epit2
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1588
NXP Semiconductors

<!-- page 1589 -->

32.6.28
SW_MUX_CTL_PAD_UART3_RTS_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_UART3_RTS_B)
SW_MUX_CTL Register
Address: 20E_0000h base + B0h offset = 20E_00B0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART3_RTS_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART3_RTS_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: UART3_RTS_B.
0000
ALT0 — Select mux mode: ALT0 mux port: UART3_RTS_B of instance: uart3
0001
ALT1 — Select mux mode: ALT1 mux port: ENET2_TX_ER of instance: enet2
0010
ALT2 — Select mux mode: ALT2 mux port: FLEXCAN1_RX of instance: flexcan1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA11 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: ENET1_1588_EVENT1_OUT of instance: enet1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO27 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: WDOG1_WDOG_B of instance: wdog1
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1589

<!-- page 1590 -->

32.6.29
SW_MUX_CTL_PAD_UART4_TX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART4_TX_DATA)
SW_MUX_CTL Register
Address: 20E_0000h base + B4h offset = 20E_00B4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART4_TX_DATA field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART4_TX_DATA
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: UART4_TX_DATA.
0000
ALT0 — Select mux mode: ALT0 mux port: UART4_TX of instance: uart4
0001
ALT1 — Select mux mode: ALT1 mux port: ENET2_TDATA02 of instance: enet2
0010
ALT2 — Select mux mode: ALT2 mux port: I2C1_SCL of instance: i2c1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA12 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: CSU_CSU_ALARM_AUT02 of instance: csu
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO28 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI2_SCLK of instance: ecspi2
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1590
NXP Semiconductors

<!-- page 1591 -->

32.6.30
SW_MUX_CTL_PAD_UART4_RX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART4_RX_DATA)
SW_MUX_CTL Register
Address: 20E_0000h base + B8h offset = 20E_00B8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART4_RX_DATA field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART4_RX_DATA
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: UART4_RX_DATA.
0000
ALT0 — Select mux mode: ALT0 mux port: UART4_RX of instance: uart4
0001
ALT1 — Select mux mode: ALT1 mux port: ENET2_TDATA03 of instance: enet2
0010
ALT2 — Select mux mode: ALT2 mux port: I2C1_SDA of instance: i2c1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA13 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: CSU_CSU_ALARM_AUT01 of instance: csu
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO29 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI2_SS0 of instance: ecspi2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_PWRCTRL01 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1591

<!-- page 1592 -->

32.6.31
SW_MUX_CTL_PAD_UART5_TX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART5_TX_DATA)
SW_MUX_CTL Register
Address: 20E_0000h base + BCh offset = 20E_00BCh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART5_TX_DATA field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART5_TX_DATA
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: UART5_TX_DATA.
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO30 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI2_MOSI of instance: ecspi2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_PWRCTRL02 of instance: epdc
0000
ALT0 — Select mux mode: ALT0 mux port: UART5_TX of instance: uart5
0001
ALT1 — Select mux mode: ALT1 mux port: ENET2_CRS of instance: enet2
0010
ALT2 — Select mux mode: ALT2 mux port: I2C2_SCL of instance: i2c2
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA14 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: CSU_CSU_ALARM_AUT00 of instance: csu
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1592
NXP Semiconductors

<!-- page 1593 -->

32.6.32
SW_MUX_CTL_PAD_UART5_RX_DATA SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_UART5_RX_DATA)
SW_MUX_CTL Register
Address: 20E_0000h base + C0h offset = 20E_00C0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_UART5_RX_DATA field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad UART5_RX_DATA
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: UART5_RX_DATA.
0000
ALT0 — Select mux mode: ALT0 mux port: UART5_RX of instance: uart5
0001
ALT1 — Select mux mode: ALT1 mux port: ENET2_COL of instance: enet2
0010
ALT2 — Select mux mode: ALT2 mux port: I2C2_SDA of instance: i2c2
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA15 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: CSU_CSU_INT_DEB of instance: csu
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO1_IO31 of instance: gpio1
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI2_MISO of instance: ecspi2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_PWRCTRL03 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1593

<!-- page 1594 -->

32.6.33
SW_MUX_CTL_PAD_ENET1_RX_DATA0 SW MUX
Control Register
(IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_DATA0)
SW_MUX_CTL Register
Address: 20E_0000h base + C4h offset = 20E_00C4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_DATA0 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET1_RX_DATA0
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: ENET1_RX_DATA0.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET1_RDATA00 of instance: enet1
0001
ALT1 — Select mux mode: ALT1 mux port: UART4_RTS_B of instance: uart4
0010
ALT2 — Select mux mode: ALT2 mux port: PWM1_OUT of instance: pwm1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA16 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: FLEXCAN1_TX of instance: flexcan1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO00 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_ROW00 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC1_LCTL of instance: usdhc1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDCE04 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1594
NXP Semiconductors

<!-- page 1595 -->

32.6.34
SW_MUX_CTL_PAD_ENET1_RX_DATA1 SW MUX
Control Register
(IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_DATA1)
SW_MUX_CTL Register
Address: 20E_0000h base + C8h offset = 20E_00C8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_DATA1 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET1_RX_DATA1
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: ENET1_RX_DATA1.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET1_RDATA01 of instance: enet1
0001
ALT1 — Select mux mode: ALT1 mux port: UART4_CTS_B of instance: uart4
0010
ALT2 — Select mux mode: ALT2 mux port: PWM2_OUT of instance: pwm2
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA17 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: FLEXCAN1_RX of instance: flexcan1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO01 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_COL00 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_LCTL of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDCE05 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1595

<!-- page 1596 -->

32.6.35
SW_MUX_CTL_PAD_ENET1_RX_EN SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_EN)
SW_MUX_CTL Register
Address: 20E_0000h base + CCh offset = 20E_00CCh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_EN field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET1_RX_EN
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: ENET1_RX_EN.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET1_RX_EN of instance: enet1
0001
ALT1 — Select mux mode: ALT1 mux port: UART5_RTS_B of instance: uart5
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA18 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: FLEXCAN2_TX of instance: flexcan2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO02 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_ROW01 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC1_VSELECT of instance: usdhc1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDCE06 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1596
NXP Semiconductors

<!-- page 1597 -->

32.6.36
SW_MUX_CTL_PAD_ENET1_TX_DATA0 SW MUX
Control Register
(IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_DATA0)
SW_MUX_CTL Register
Address: 20E_0000h base + D0h offset = 20E_00D0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_DATA0 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET1_TX_DATA0
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: ENET1_TX_DATA0.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET1_TDATA00 of instance: enet1
0001
ALT1 — Select mux mode: ALT1 mux port: UART5_CTS_B of instance: uart5
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA19 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: FLEXCAN2_RX of instance: flexcan2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO03 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_COL01 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_VSELECT of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDCE07 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1597

<!-- page 1598 -->

32.6.37
SW_MUX_CTL_PAD_ENET1_TX_DATA1 SW MUX
Control Register
(IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_DATA1)
SW_MUX_CTL Register
Address: 20E_0000h base + D4h offset = 20E_00D4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_DATA1 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET1_TX_DATA1
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: ENET1_TX_DATA1.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET1_TDATA01 of instance: enet1
0001
ALT1 — Select mux mode: ALT1 mux port: UART6_CTS_B of instance: uart6
0010
ALT2 — Select mux mode: ALT2 mux port: PWM5_OUT of instance: pwm5
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA20 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: ENET2_MDIO of instance: enet2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO04 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_ROW02 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: WDOG1_WDOG_RST_B_DEB of instance: wdog1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDCE08 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1598
NXP Semiconductors

<!-- page 1599 -->

32.6.38
SW_MUX_CTL_PAD_ENET1_TX_EN SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_EN)
SW_MUX_CTL Register
Address: 20E_0000h base + D8h offset = 20E_00D8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_EN field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET1_TX_EN
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: ENET1_TX_EN.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET1_TX_EN of instance: enet1
0001
ALT1 — Select mux mode: ALT1 mux port: UART6_RTS_B of instance: uart6
0010
ALT2 — Select mux mode: ALT2 mux port: PWM6_OUT of instance: pwm6
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA21 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: ENET2_MDC of instance: enet2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO05 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_COL02 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: WDOG2_WDOG_RST_B_DEB of instance: wdog2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDCE09 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1599

<!-- page 1600 -->

32.6.39
SW_MUX_CTL_PAD_ENET1_TX_CLK SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_CLK)
SW_MUX_CTL Register
Address: 20E_0000h base + DCh offset = 20E_00DCh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET1_TX_CLK field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET1_TX_CLK
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: ENET1_TX_CLK.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET1_TX_CLK of instance: enet1
0001
ALT1 — Select mux mode: ALT1 mux port: UART7_CTS_B of instance: uart7
0010
ALT2 — Select mux mode: ALT2 mux port: PWM7_OUT of instance: pwm7
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA22 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: ENET1_REF_CLK1 of instance: enet1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO06 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_ROW03 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: GPT1_CLK of instance: gpt1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDOED of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1600
NXP Semiconductors

<!-- page 1601 -->

32.6.40
SW_MUX_CTL_PAD_ENET1_RX_ER SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_ER)
SW_MUX_CTL Register
Address: 20E_0000h base + E0h offset = 20E_00E0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET1_RX_ER field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET1_RX_ER
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: ENET1_RX_ER.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET1_RX_ER of instance: enet1
0001
ALT1 — Select mux mode: ALT1 mux port: UART7_RTS_B of instance: uart7
0010
ALT2 — Select mux mode: ALT2 mux port: PWM8_OUT of instance: pwm8
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA23 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_CRE of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO07 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_COL03 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: GPT1_CAPTURE2 of instance: gpt1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDOEZ of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1601

<!-- page 1602 -->

32.6.41
SW_MUX_CTL_PAD_ENET2_RX_DATA0 SW MUX
Control Register
(IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_DATA0)
SW_MUX_CTL Register
Address: 20E_0000h base + E4h offset = 20E_00E4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_DATA0 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET2_RX_DATA0
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: ENET2_RX_DATA0.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET2_RDATA00 of instance: enet2
0001
ALT1 — Select mux mode: ALT1 mux port: UART6_TX of instance: uart6
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: I2C3_SCL of instance: i2c3
0100
ALT4 — Select mux mode: ALT4 mux port: ENET1_MDIO of instance: enet1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO08 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_ROW04 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: USB_OTG1_PWR of instance: usb
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO08 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1602
NXP Semiconductors

<!-- page 1603 -->

32.6.42
SW_MUX_CTL_PAD_ENET2_RX_DATA1 SW MUX
Control Register
(IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_DATA1)
SW_MUX_CTL Register
Address: 20E_0000h base + E8h offset = 20E_00E8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_DATA1 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET2_RX_DATA1
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: ENET2_RX_DATA1.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET2_RDATA01 of instance: enet2
0001
ALT1 — Select mux mode: ALT1 mux port: UART6_RX of instance: uart6
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: I2C3_SDA of instance: i2c3
0100
ALT4 — Select mux mode: ALT4 mux port: ENET1_MDC of instance: enet1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO09 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_COL04 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: USB_OTG1_OC of instance: usb
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO09 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1603

<!-- page 1604 -->

32.6.43
SW_MUX_CTL_PAD_ENET2_RX_EN SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_EN)
SW_MUX_CTL Register
Address: 20E_0000h base + ECh offset = 20E_00ECh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_EN field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET2_RX_EN
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: ENET2_RX_EN.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET2_RX_EN of instance: enet2
0001
ALT1 — Select mux mode: ALT1 mux port: UART7_TX of instance: uart7
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: I2C4_SCL of instance: i2c4
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ADDR26 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO10 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_ROW05 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: ENET1_REF_CLK_25M of instance: enet1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO10 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1604
NXP Semiconductors

<!-- page 1605 -->

32.6.44
SW_MUX_CTL_PAD_ENET2_TX_DATA0 SW MUX
Control Register
(IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_DATA0)
SW_MUX_CTL Register
Address: 20E_0000h base + F0h offset = 20E_00F0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_DATA0 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET2_TX_DATA0
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: ENET2_TX_DATA0.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET2_TDATA00 of instance: enet2
0001
ALT1 — Select mux mode: ALT1 mux port: UART7_RX of instance: uart7
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: I2C4_SDA of instance: i2c4
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_EB_B02 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO11 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_COL05 of instance: kpp
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO11 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1605

<!-- page 1606 -->

32.6.45
SW_MUX_CTL_PAD_ENET2_TX_DATA1 SW MUX
Control Register
(IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_DATA1)
SW_MUX_CTL Register
Address: 20E_0000h base + F4h offset = 20E_00F4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_DATA1 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET2_TX_DATA1
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: ENET2_TX_DATA1.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET2_TDATA01 of instance: enet2
0001
ALT1 — Select mux mode: ALT1 mux port: UART8_TX of instance: uart8
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI4_SCLK of instance: ecspi4
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_EB_B03 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO12 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_ROW06 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: USB_OTG2_PWR of instance: usb
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO12 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1606
NXP Semiconductors

<!-- page 1607 -->

32.6.46
SW_MUX_CTL_PAD_ENET2_TX_EN SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_EN)
SW_MUX_CTL Register
Address: 20E_0000h base + F8h offset = 20E_00F8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_EN field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET2_TX_EN
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: ENET2_TX_EN.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET2_TX_EN of instance: enet2
0001
ALT1 — Select mux mode: ALT1 mux port: UART8_RX of instance: uart8
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI4_MOSI of instance: ecspi4
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ACLK_FREERUN of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO13 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_COL06 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: USB_OTG2_OC of instance: usb
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO13 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1607

<!-- page 1608 -->

32.6.47
SW_MUX_CTL_PAD_ENET2_TX_CLK SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_CLK)
SW_MUX_CTL Register
Address: 20E_0000h base + FCh offset = 20E_00FCh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET2_TX_CLK field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET2_TX_CLK
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: ENET2_TX_CLK.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET2_TX_CLK of instance: enet2
0001
ALT1 — Select mux mode: ALT1 mux port: UART8_CTS_B of instance: uart8
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI4_MISO of instance: ecspi4
0100
ALT4 — Select mux mode: ALT4 mux port: ENET2_REF_CLK2 of instance: enet2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO14 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_ROW07 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: ANATOP_OTG2_ID of instance: anatop
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO14 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1608
NXP Semiconductors

<!-- page 1609 -->

32.6.48
SW_MUX_CTL_PAD_ENET2_RX_ER SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_ER)
SW_MUX_CTL Register
Address: 20E_0000h base + 100h offset = 20E_0100h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_ENET2_RX_ER field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad ENET2_RX_ER
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: ENET2_RX_ER.
0000
ALT0 — Select mux mode: ALT0 mux port: ENET2_RX_ER of instance: enet2
0001
ALT1 — Select mux mode: ALT1 mux port: UART8_RTS_B of instance: uart8
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI4_SS0 of instance: ecspi4
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ADDR25 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO15 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: KPP_COL07 of instance: kpp
1000
ALT8 — Select mux mode: ALT8 mux port: WDOG1_WDOG_ANY of instance: wdog1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO15 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1609

<!-- page 1610 -->

32.6.49
SW_MUX_CTL_PAD_LCD_CLK SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_CLK)
SW_MUX_CTL Register
Address: 20E_0000h base + 104h offset = 20E_0104h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_CLK field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_CLK
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_CLK.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_CLK of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: LCDIF_WR_RWN of instance: lcdif
0010
ALT2 — Select mux mode: ALT2 mux port: UART4_TX of instance: uart4
0011
ALT3 — Select mux mode: ALT3 mux port: SAI3_MCLK of instance: sai3
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_CS2_B of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO00 of instance: gpio3
1000
ALT8 — Select mux mode: ALT8 mux port: WDOG1_WDOG_RST_B_DEB of instance: wdog1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDCLK of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1610
NXP Semiconductors

<!-- page 1611 -->

32.6.50
SW_MUX_CTL_PAD_LCD_ENABLE SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_ENABLE)
SW_MUX_CTL Register
Address: 20E_0000h base + 108h offset = 20E_0108h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_ENABLE field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_ENABLE
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_ENABLE.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_ENABLE of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: LCDIF_RD_E of instance: lcdif
0010
ALT2 — Select mux mode: ALT2 mux port: UART4_RX of instance: uart4
0011
ALT3 — Select mux mode: ALT3 mux port: SAI3_TX_SYNC of instance: sai3
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_CS3_B of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO01 of instance: gpio3
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI2_RDY of instance: ecspi2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDLE of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1611

<!-- page 1612 -->

32.6.51
SW_MUX_CTL_PAD_LCD_HSYNC SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_HSYNC)
SW_MUX_CTL Register
Address: 20E_0000h base + 10Ch offset = 20E_010Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_HSYNC field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_HSYNC
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_HSYNC.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_HSYNC of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: LCDIF_RS of instance: lcdif
0010
ALT2 — Select mux mode: ALT2 mux port: UART4_CTS_B of instance: uart4
0011
ALT3 — Select mux mode: ALT3 mux port: SAI3_TX_BCLK of instance: sai3
0100
ALT4 — Select mux mode: ALT4 mux port: WDOG3_WDOG_RST_B_DEB of instance: wdog3
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO02 of instance: gpio3
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI2_SS1 of instance: ecspi2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDOE of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1612
NXP Semiconductors

<!-- page 1613 -->

32.6.52
SW_MUX_CTL_PAD_LCD_VSYNC SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_VSYNC)
SW_MUX_CTL Register
Address: 20E_0000h base + 110h offset = 20E_0110h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_VSYNC field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_VSYNC
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_VSYNC.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_VSYNC of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: LCDIF_BUSY of instance: lcdif
0010
ALT2 — Select mux mode: ALT2 mux port: UART4_RTS_B of instance: uart4
0011
ALT3 — Select mux mode: ALT3 mux port: SAI3_RX_DATA of instance: sai3
0100
ALT4 — Select mux mode: ALT4 mux port: WDOG2_WDOG_B of instance: wdog2
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO03 of instance: gpio3
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI2_SS2 of instance: ecspi2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDCE00 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1613

<!-- page 1614 -->

32.6.53
SW_MUX_CTL_PAD_LCD_RESET SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_RESET)
SW_MUX_CTL Register
Address: 20E_0000h base + 114h offset = 20E_0114h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_RESET field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_RESET
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_RESET.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_RESET of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: LCDIF_CS of instance: lcdif
0010
ALT2 — Select mux mode: ALT2 mux port: CA7_MX6ULL_EVENTI of instance: ca7_mx6ull
0011
ALT3 — Select mux mode: ALT3 mux port: SAI3_TX_DATA of instance: sai3
0100
ALT4 — Select mux mode: ALT4 mux port: WDOG1_WDOG_ANY of instance: wdog1
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO04 of instance: gpio3
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI2_SS3 of instance: ecspi2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_GDOE of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1614
NXP Semiconductors

<!-- page 1615 -->

32.6.54
SW_MUX_CTL_PAD_LCD_DATA00 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA00)
SW_MUX_CTL Register
Address: 20E_0000h base + 118h offset = 20E_0118h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA00 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA00
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA00.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA00 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: PWM1_OUT of instance: pwm1
0011
ALT3 — Select mux mode: ALT3 mux port: ENET1_1588_EVENT2_IN of instance: enet1
0100
ALT4 — Select mux mode: ALT4 mux port: I2C3_SDA of instance: i2c3
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO05 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG00 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: SAI1_MCLK of instance: sai1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO00 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1615

<!-- page 1616 -->

32.6.55
SW_MUX_CTL_PAD_LCD_DATA01 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA01)
SW_MUX_CTL Register
Address: 20E_0000h base + 11Ch offset = 20E_011Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA01 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA01
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA01.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA01 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: PWM2_OUT of instance: pwm2
0011
ALT3 — Select mux mode: ALT3 mux port: ENET1_1588_EVENT2_OUT of instance: enet1
0100
ALT4 — Select mux mode: ALT4 mux port: I2C3_SCL of instance: i2c3
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO06 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG01 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: SAI1_TX_SYNC of instance: sai1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO01 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1616
NXP Semiconductors

<!-- page 1617 -->

32.6.56
SW_MUX_CTL_PAD_LCD_DATA02 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA02)
SW_MUX_CTL Register
Address: 20E_0000h base + 120h offset = 20E_0120h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA02 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA02
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA02.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA02 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: PWM3_OUT of instance: pwm3
0011
ALT3 — Select mux mode: ALT3 mux port: ENET1_1588_EVENT3_IN of instance: enet1
0100
ALT4 — Select mux mode: ALT4 mux port: I2C4_SDA of instance: i2c4
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO07 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG02 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: SAI1_TX_BCLK of instance: sai1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO02 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1617

<!-- page 1618 -->

32.6.57
SW_MUX_CTL_PAD_LCD_DATA03 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA03)
SW_MUX_CTL Register
Address: 20E_0000h base + 124h offset = 20E_0124h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA03 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA03
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA03.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA03 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: PWM4_OUT of instance: pwm4
0011
ALT3 — Select mux mode: ALT3 mux port: ENET1_1588_EVENT3_OUT of instance: enet1
0100
ALT4 — Select mux mode: ALT4 mux port: I2C4_SCL of instance: i2c4
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO08 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG03 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: SAI1_RX_DATA of instance: sai1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO03 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1618
NXP Semiconductors

<!-- page 1619 -->

32.6.58
SW_MUX_CTL_PAD_LCD_DATA04 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA04)
SW_MUX_CTL Register
Address: 20E_0000h base + 128h offset = 20E_0128h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA04 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA04
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA04.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA04 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: UART8_CTS_B of instance: uart8
0011
ALT3 — Select mux mode: ALT3 mux port: ENET2_1588_EVENT2_IN of instance: enet2
0100
ALT4 — Select mux mode: ALT4 mux port: SPDIF_SR_CLK of instance: spdif
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO09 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG04 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: SAI1_TX_DATA of instance: sai1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO04 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1619

<!-- page 1620 -->

32.6.59
SW_MUX_CTL_PAD_LCD_DATA05 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA05)
SW_MUX_CTL Register
Address: 20E_0000h base + 12Ch offset = 20E_012Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA05 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA05
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA05.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA05 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: UART8_RTS_B of instance: uart8
0011
ALT3 — Select mux mode: ALT3 mux port: ENET2_1588_EVENT2_OUT of instance: enet2
0100
ALT4 — Select mux mode: ALT4 mux port: SPDIF_OUT of instance: spdif
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO10 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG05 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI1_SS1 of instance: ecspi1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO05 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1620
NXP Semiconductors

<!-- page 1621 -->

32.6.60
SW_MUX_CTL_PAD_LCD_DATA06 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA06)
SW_MUX_CTL Register
Address: 20E_0000h base + 130h offset = 20E_0130h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA06 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA06
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA06.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA06 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: UART7_CTS_B of instance: uart7
0011
ALT3 — Select mux mode: ALT3 mux port: ENET2_1588_EVENT3_IN of instance: enet2
0100
ALT4 — Select mux mode: ALT4 mux port: SPDIF_LOCK of instance: spdif
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO11 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG06 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI1_SS2 of instance: ecspi1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO06 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1621

<!-- page 1622 -->

32.6.61
SW_MUX_CTL_PAD_LCD_DATA07 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA07)
SW_MUX_CTL Register
Address: 20E_0000h base + 134h offset = 20E_0134h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA07 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA07
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA07.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA07 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: UART7_RTS_B of instance: uart7
0011
ALT3 — Select mux mode: ALT3 mux port: ENET2_1588_EVENT3_OUT of instance: enet2
0100
ALT4 — Select mux mode: ALT4 mux port: SPDIF_EXT_CLK of instance: spdif
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO12 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG07 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI1_SS3 of instance: ecspi1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDDO07 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1622
NXP Semiconductors

<!-- page 1623 -->

32.6.62
SW_MUX_CTL_PAD_LCD_DATA08 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA08)
SW_MUX_CTL Register
Address: 20E_0000h base + 138h offset = 20E_0138h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA08 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA08
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA08.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA08 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: SPDIF_IN of instance: spdif
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA16 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA00 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO13 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG08 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: FLEXCAN1_TX of instance: flexcan1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_PWRIRQ of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1623

<!-- page 1624 -->

32.6.63
SW_MUX_CTL_PAD_LCD_DATA09 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA09)
SW_MUX_CTL Register
Address: 20E_0000h base + 13Ch offset = 20E_013Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA09 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA09
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA09.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA09 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: SAI3_MCLK of instance: sai3
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA17 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA01 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO14 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG09 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: FLEXCAN1_RX of instance: flexcan1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_PWRWAKE of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1624
NXP Semiconductors

<!-- page 1625 -->

32.6.64
SW_MUX_CTL_PAD_LCD_DATA10 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA10)
SW_MUX_CTL Register
Address: 20E_0000h base + 140h offset = 20E_0140h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA10 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA10
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA10.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA10 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: SAI3_RX_SYNC of instance: sai3
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA18 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA02 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO15 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG10 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: FLEXCAN2_TX of instance: flexcan2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_PWRCOM of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1625

<!-- page 1626 -->

32.6.65
SW_MUX_CTL_PAD_LCD_DATA11 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA11)
SW_MUX_CTL Register
Address: 20E_0000h base + 144h offset = 20E_0144h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA11 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA11
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA11.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA11 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: SAI3_RX_BCLK of instance: sai3
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA19 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA03 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO16 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG11 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: FLEXCAN2_RX of instance: flexcan2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_PWRSTAT of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1626
NXP Semiconductors

<!-- page 1627 -->

32.6.66
SW_MUX_CTL_PAD_LCD_DATA12 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA12)
SW_MUX_CTL Register
Address: 20E_0000h base + 148h offset = 20E_0148h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA12 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA12
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA12.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA12 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: SAI3_TX_SYNC of instance: sai3
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA20 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA04 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO17 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG12 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI1_RDY of instance: ecspi1
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_PWRCTRL00 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1627

<!-- page 1628 -->

32.6.67
SW_MUX_CTL_PAD_LCD_DATA13 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA13)
SW_MUX_CTL Register
Address: 20E_0000h base + 14Ch offset = 20E_014Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA13 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA13
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA13.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA13 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: SAI3_TX_BCLK of instance: sai3
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA21 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA05 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO18 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG13 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_RESET_B of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_BDR00 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1628
NXP Semiconductors

<!-- page 1629 -->

32.6.68
SW_MUX_CTL_PAD_LCD_DATA14 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA14)
SW_MUX_CTL Register
Address: 20E_0000h base + 150h offset = 20E_0150h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA14 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA14
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA14.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA14 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: SAI3_RX_DATA of instance: sai3
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA22 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA06 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO19 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG14 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_DATA4 of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDSHR of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1629

<!-- page 1630 -->

32.6.69
SW_MUX_CTL_PAD_LCD_DATA15 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA15)
SW_MUX_CTL Register
Address: 20E_0000h base + 154h offset = 20E_0154h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA15 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA15
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA15.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA15 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: SAI3_TX_DATA of instance: sai3
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA23 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA07 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO20 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG15 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_DATA5 of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_GDRL of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1630
NXP Semiconductors

<!-- page 1631 -->

32.6.70
SW_MUX_CTL_PAD_LCD_DATA16 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA16)
SW_MUX_CTL Register
Address: 20E_0000h base + 158h offset = 20E_0158h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA16 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA16
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA16.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA16 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: UART7_TX of instance: uart7
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA01 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA08 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO21 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG24 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_DATA6 of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_GDCLK of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1631

<!-- page 1632 -->

32.6.71
SW_MUX_CTL_PAD_LCD_DATA17 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA17)
SW_MUX_CTL Register
Address: 20E_0000h base + 15Ch offset = 20E_015Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA17 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA17
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA17.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA17 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: UART7_RX of instance: uart7
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA00 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA09 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO22 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG25 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_DATA7 of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_GDSP of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1632
NXP Semiconductors

<!-- page 1633 -->

32.6.72
SW_MUX_CTL_PAD_LCD_DATA18 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA18)
SW_MUX_CTL Register
Address: 20E_0000h base + 160h offset = 20E_0160h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA18 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA18
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA18.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA18 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: PWM5_OUT of instance: pwm5
0010
ALT2 — Select mux mode: ALT2 mux port: CA7_MX6ULL_EVENTO of instance: ca7_mx6ull
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA10 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA10 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO23 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG26 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_CMD of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_BDR01 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1633

<!-- page 1634 -->

32.6.73
SW_MUX_CTL_PAD_LCD_DATA19 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA19)
SW_MUX_CTL Register
Address: 20E_0000h base + 164h offset = 20E_0164h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA19 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA19
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA19.
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA11 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO24 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG27 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_CLK of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_VCOM00 of instance: epdc
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA19 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: PWM6_OUT of instance: pwm6
0010
ALT2 — Select mux mode: ALT2 mux port: WDOG1_WDOG_ANY of instance: wdog1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA11 of instance: csi
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1634
NXP Semiconductors

<!-- page 1635 -->

32.6.74
SW_MUX_CTL_PAD_LCD_DATA20 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA20)
SW_MUX_CTL Register
Address: 20E_0000h base + 168h offset = 20E_0168h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA20 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA20
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA20.
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA12 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO25 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG28 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_DATA0 of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_VCOM01 of instance: epdc
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA20 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: UART8_TX of instance: uart8
0010
ALT2 — Select mux mode: ALT2 mux port: ECSPI1_SCLK of instance: ecspi1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA12 of instance: csi
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1635

<!-- page 1636 -->

32.6.75
SW_MUX_CTL_PAD_LCD_DATA21 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA21)
SW_MUX_CTL Register
Address: 20E_0000h base + 16Ch offset = 20E_016Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA21 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA21
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA21.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA21 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: UART8_RX of instance: uart8
0010
ALT2 — Select mux mode: ALT2 mux port: ECSPI1_SS0 of instance: ecspi1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA13 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA13 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO26 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG29 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_DATA1 of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDCE01 of instance: epdc
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1636
NXP Semiconductors

<!-- page 1637 -->

32.6.76
SW_MUX_CTL_PAD_LCD_DATA22 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA22)
SW_MUX_CTL Register
Address: 20E_0000h base + 170h offset = 20E_0170h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA22 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA22
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA22.
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA22 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: MQS_RIGHT of instance: mqs
0010
ALT2 — Select mux mode: ALT2 mux port: ECSPI1_MOSI of instance: ecspi1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA14 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA14 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO27 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG30 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_DATA2 of instance: usdhc2
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDCE02 of instance: epdc
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1637

<!-- page 1638 -->

32.6.77
SW_MUX_CTL_PAD_LCD_DATA23 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_LCD_DATA23)
SW_MUX_CTL Register
Address: 20E_0000h base + 174h offset = 20E_0174h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_LCD_DATA23 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad LCD_DATA23
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: LCD_DATA23.
1001
ALT9 — Select mux mode: ALT9 mux port: EPDC_SDCE03 of instance: epdc
0000
ALT0 — Select mux mode: ALT0 mux port: LCDIF_DATA23 of instance: lcdif
0001
ALT1 — Select mux mode: ALT1 mux port: MQS_LEFT of instance: mqs
0010
ALT2 — Select mux mode: ALT2 mux port: ECSPI1_MISO of instance: ecspi1
0011
ALT3 — Select mux mode: ALT3 mux port: CSI_DATA15 of instance: csi
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DATA15 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO3_IO28 of instance: gpio3
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_BT_CFG31 of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC2_DATA3 of instance: usdhc2
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1638
NXP Semiconductors

<!-- page 1639 -->

32.6.78
SW_MUX_CTL_PAD_NAND_RE_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_RE_B)
SW_MUX_CTL Register
Address: 20E_0000h base + 178h offset = 20E_0178h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_RE_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_RE_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_RE_B.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_RE_B of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_CLK of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_B_SCLK of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: KPP_ROW00 of instance: kpp
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_EB_B00 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO00 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI3_SS2 of instance: ecspi3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1639

<!-- page 1640 -->

32.6.79
SW_MUX_CTL_PAD_NAND_WE_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_WE_B)
SW_MUX_CTL Register
Address: 20E_0000h base + 17Ch offset = 20E_017Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_WE_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_WE_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_WE_B.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_WE_B of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_CMD of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_B_SS0_B of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: KPP_COL00 of instance: kpp
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_EB_B01 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO01 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI3_SS3 of instance: ecspi3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1640
NXP Semiconductors

<!-- page 1641 -->

32.6.80
SW_MUX_CTL_PAD_NAND_DATA00 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA00)
SW_MUX_CTL Register
Address: 20E_0000h base + 180h offset = 20E_0180h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_DATA00 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_DATA00
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_DATA00.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_DATA00 of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA0 of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_B_SS1_B of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: KPP_ROW01 of instance: kpp
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD08 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO02 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI4_RDY of instance: ecspi4
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1641

<!-- page 1642 -->

32.6.81
SW_MUX_CTL_PAD_NAND_DATA01 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA01)
SW_MUX_CTL Register
Address: 20E_0000h base + 184h offset = 20E_0184h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_DATA01 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_DATA01
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_DATA01.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_DATA01 of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA1 of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_B_DQS of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: KPP_COL01 of instance: kpp
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD09 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO03 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI4_SS1 of instance: ecspi4
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1642
NXP Semiconductors

<!-- page 1643 -->

32.6.82
SW_MUX_CTL_PAD_NAND_DATA02 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA02)
SW_MUX_CTL Register
Address: 20E_0000h base + 188h offset = 20E_0188h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_DATA02 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_DATA02
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_DATA02.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_DATA02 of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA2 of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_B_DATA00 of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: KPP_ROW02 of instance: kpp
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD10 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO04 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI4_SS2 of instance: ecspi4
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1643

<!-- page 1644 -->

32.6.83
SW_MUX_CTL_PAD_NAND_DATA03 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA03)
SW_MUX_CTL Register
Address: 20E_0000h base + 18Ch offset = 20E_018Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_DATA03 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_DATA03
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_DATA03.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_DATA03 of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA3 of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_B_DATA01 of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: KPP_COL02 of instance: kpp
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD11 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO05 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI4_SS3 of instance: ecspi4
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1644
NXP Semiconductors

<!-- page 1645 -->

32.6.84
SW_MUX_CTL_PAD_NAND_DATA04 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA04)
SW_MUX_CTL Register
Address: 20E_0000h base + 190h offset = 20E_0190h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_DATA04 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_DATA04
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_DATA04.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_DATA04 of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA4 of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_B_DATA02 of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI4_SCLK of instance: ecspi4
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD12 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO06 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: UART2_TX of instance: uart2
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1645

<!-- page 1646 -->

32.6.85
SW_MUX_CTL_PAD_NAND_DATA05 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA05)
SW_MUX_CTL Register
Address: 20E_0000h base + 194h offset = 20E_0194h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_DATA05 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_DATA05
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_DATA05.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_DATA05 of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA5 of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_B_DATA03 of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI4_MOSI of instance: ecspi4
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD13 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO07 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: UART2_RX of instance: uart2
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1646
NXP Semiconductors

<!-- page 1647 -->

32.6.86
SW_MUX_CTL_PAD_NAND_DATA06 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA06)
SW_MUX_CTL Register
Address: 20E_0000h base + 198h offset = 20E_0198h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_DATA06 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_DATA06
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_DATA06.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_DATA06 of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA6 of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_RX_BCLK of instance: sai2
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI4_MISO of instance: ecspi4
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD14 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO08 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: UART2_CTS_B of instance: uart2
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1647

<!-- page 1648 -->

32.6.87
SW_MUX_CTL_PAD_NAND_DATA07 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DATA07)
SW_MUX_CTL Register
Address: 20E_0000h base + 19Ch offset = 20E_019Ch
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_DATA07 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_DATA07
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_DATA07.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_DATA07 of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA7 of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_A_SS1_B of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI4_SS0 of instance: ecspi4
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD15 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO09 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: UART2_RTS_B of instance: uart2
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1648
NXP Semiconductors

<!-- page 1649 -->

32.6.88
SW_MUX_CTL_PAD_NAND_ALE SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_ALE)
SW_MUX_CTL Register
Address: 20E_0000h base + 1A0h offset = 20E_01A0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_ALE field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_ALE
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_ALE.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_ALE of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_RESET_B of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_A_DQS of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: PWM3_OUT of instance: pwm3
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ADDR17 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO10 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI3_SS1 of instance: ecspi3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1649

<!-- page 1650 -->

32.6.89
SW_MUX_CTL_PAD_NAND_WP_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_WP_B)
SW_MUX_CTL Register
Address: 20E_0000h base + 1A4h offset = 20E_01A4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_WP_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_WP_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_WP_B.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_WP_B of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC1_RESET_B of instance: usdhc1
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_A_SCLK of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: PWM4_OUT of instance: pwm4
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_BCLK of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO11 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: ECSPI3_RDY of instance: ecspi3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1650
NXP Semiconductors

<!-- page 1651 -->

32.6.90
SW_MUX_CTL_PAD_NAND_READY_B SW MUX Control
Register
(IOMUXC_SW_MUX_CTL_PAD_NAND_READY_B)
SW_MUX_CTL Register
Address: 20E_0000h base + 1A8h offset = 20E_01A8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_READY_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_READY_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_READY_B.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_READY_B of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC1_DATA4 of instance: usdhc1
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_A_DATA00 of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI3_SS0 of instance: ecspi3
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_CS1_B of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO12 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: UART3_TX of instance: uart3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1651

<!-- page 1652 -->

32.6.91
SW_MUX_CTL_PAD_NAND_CE0_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_CE0_B)
SW_MUX_CTL Register
Address: 20E_0000h base + 1ACh offset = 20E_01ACh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_CE0_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_CE0_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_CE0_B.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_CE0_B of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC1_DATA5 of instance: usdhc1
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_A_DATA01 of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI3_SCLK of instance: ecspi3
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_DTACK_B of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO13 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: UART3_RX of instance: uart3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1652
NXP Semiconductors

<!-- page 1653 -->

32.6.92
SW_MUX_CTL_PAD_NAND_CE1_B SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_CE1_B)
SW_MUX_CTL Register
Address: 20E_0000h base + 1B0h offset = 20E_01B0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_CE1_B field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_CE1_B
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_CE1_B.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_CE1_B of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC1_DATA6 of instance: usdhc1
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_A_DATA02 of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI3_MOSI of instance: ecspi3
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ADDR18 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO14 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: UART3_CTS_B of instance: uart3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1653

<!-- page 1654 -->

32.6.93
SW_MUX_CTL_PAD_NAND_CLE SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_CLE)
SW_MUX_CTL Register
Address: 20E_0000h base + 1B4h offset = 20E_01B4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_CLE field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_CLE
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_CLE.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_CLE of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC1_DATA7 of instance: usdhc1
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_A_DATA03 of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI3_MISO of instance: ecspi3
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ADDR16 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO15 of instance: gpio4
1000
ALT8 — Select mux mode: ALT8 mux port: UART3_RTS_B of instance: uart3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1654
NXP Semiconductors

<!-- page 1655 -->

32.6.94
SW_MUX_CTL_PAD_NAND_DQS SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_NAND_DQS)
SW_MUX_CTL Register
Address: 20E_0000h base + 1B8h offset = 20E_01B8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_NAND_DQS field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad NAND_DQS
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: NAND_DQS.
0000
ALT0 — Select mux mode: ALT0 mux port: RAWNAND_DQS of instance: rawnand
0001
ALT1 — Select mux mode: ALT1 mux port: CSI_FIELD of instance: csi
0010
ALT2 — Select mux mode: ALT2 mux port: QSPI_A_SS0_B of instance: qspi
0011
ALT3 — Select mux mode: ALT3 mux port: PWM5_OUT of instance: pwm5
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_WAIT of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO16 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: SDMA_EXT_EVENT01 of instance: sdma
1000
ALT8 — Select mux mode: ALT8 mux port: SPDIF_EXT_CLK of instance: spdif
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1655

<!-- page 1656 -->

32.6.95
SW_MUX_CTL_PAD_SD1_CMD SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_SD1_CMD)
SW_MUX_CTL Register
Address: 20E_0000h base + 1BCh offset = 20E_01BCh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_SD1_CMD field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SD1_CMD
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: SD1_CMD.
0000
ALT0 — Select mux mode: ALT0 mux port: USDHC1_CMD of instance: usdhc1
0001
ALT1 — Select mux mode: ALT1 mux port: GPT2_COMPARE1 of instance: gpt2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_RX_SYNC of instance: sai2
0011
ALT3 — Select mux mode: ALT3 mux port: SPDIF_OUT of instance: spdif
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ADDR19 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO16 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: SDMA_EXT_EVENT00 of instance: sdma
1000
ALT8 — Select mux mode: ALT8 mux port: USB_OTG1_PWR of instance: usb
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1656
NXP Semiconductors

<!-- page 1657 -->

32.6.96
SW_MUX_CTL_PAD_SD1_CLK SW MUX Control Register
(IOMUXC_SW_MUX_CTL_PAD_SD1_CLK)
SW_MUX_CTL Register
Address: 20E_0000h base + 1C0h offset = 20E_01C0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_SD1_CLK field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SD1_CLK
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: SD1_CLK.
0000
ALT0 — Select mux mode: ALT0 mux port: USDHC1_CLK of instance: usdhc1
0001
ALT1 — Select mux mode: ALT1 mux port: GPT2_COMPARE2 of instance: gpt2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_MCLK of instance: sai2
0011
ALT3 — Select mux mode: ALT3 mux port: SPDIF_IN of instance: spdif
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ADDR20 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO17 of instance: gpio2
1000
ALT8 — Select mux mode: ALT8 mux port: USB_OTG1_OC of instance: usb
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1657

<!-- page 1658 -->

32.6.97
SW_MUX_CTL_PAD_SD1_DATA0 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_SD1_DATA0)
SW_MUX_CTL Register
Address: 20E_0000h base + 1C4h offset = 20E_01C4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_SD1_DATA0 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SD1_DATA0
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: SD1_DATA0.
0000
ALT0 — Select mux mode: ALT0 mux port: USDHC1_DATA0 of instance: usdhc1
0001
ALT1 — Select mux mode: ALT1 mux port: GPT2_COMPARE3 of instance: gpt2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_TX_SYNC of instance: sai2
0011
ALT3 — Select mux mode: ALT3 mux port: FLEXCAN1_TX of instance: flexcan1
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ADDR21 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO18 of instance: gpio2
1000
ALT8 — Select mux mode: ALT8 mux port: ANATOP_OTG1_ID of instance: anatop
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1658
NXP Semiconductors

<!-- page 1659 -->

32.6.98
SW_MUX_CTL_PAD_SD1_DATA1 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_SD1_DATA1)
SW_MUX_CTL Register
Address: 20E_0000h base + 1C8h offset = 20E_01C8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_SD1_DATA1 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SD1_DATA1
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: SD1_DATA1.
0000
ALT0 — Select mux mode: ALT0 mux port: USDHC1_DATA1 of instance: usdhc1
0001
ALT1 — Select mux mode: ALT1 mux port: GPT2_CLK of instance: gpt2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_TX_BCLK of instance: sai2
0011
ALT3 — Select mux mode: ALT3 mux port: FLEXCAN1_RX of instance: flexcan1
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ADDR22 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO19 of instance: gpio2
1000
ALT8 — Select mux mode: ALT8 mux port: USB_OTG2_PWR of instance: usb
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1659

<!-- page 1660 -->

32.6.99
SW_MUX_CTL_PAD_SD1_DATA2 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_SD1_DATA2)
SW_MUX_CTL Register
Address: 20E_0000h base + 1CCh offset = 20E_01CCh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_SD1_DATA2 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SD1_DATA2
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: SD1_DATA2.
0000
ALT0 — Select mux mode: ALT0 mux port: USDHC1_DATA2 of instance: usdhc1
0001
ALT1 — Select mux mode: ALT1 mux port: GPT2_CAPTURE1 of instance: gpt2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_RX_DATA of instance: sai2
0011
ALT3 — Select mux mode: ALT3 mux port: FLEXCAN2_TX of instance: flexcan2
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ADDR23 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO20 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: CCM_CLKO1 of instance: ccm
1000
ALT8 — Select mux mode: ALT8 mux port: USB_OTG2_OC of instance: usb
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1660
NXP Semiconductors

<!-- page 1661 -->

32.6.100
SW_MUX_CTL_PAD_SD1_DATA3 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_SD1_DATA3)
SW_MUX_CTL Register
Address: 20E_0000h base + 1D0h offset = 20E_01D0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_SD1_DATA3 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad SD1_DATA3
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: SD1_DATA3.
0000
ALT0 — Select mux mode: ALT0 mux port: USDHC1_DATA3 of instance: usdhc1
0001
ALT1 — Select mux mode: ALT1 mux port: GPT2_CAPTURE2 of instance: gpt2
0010
ALT2 — Select mux mode: ALT2 mux port: SAI2_TX_DATA of instance: sai2
0011
ALT3 — Select mux mode: ALT3 mux port: FLEXCAN2_RX of instance: flexcan2
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_ADDR24 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO2_IO21 of instance: gpio2
0110
ALT6 — Select mux mode: ALT6 mux port: CCM_CLKO2 of instance: ccm
1000
ALT8 — Select mux mode: ALT8 mux port: ANATOP_OTG2_ID of instance: anatop
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1661

<!-- page 1662 -->

32.6.101
SW_MUX_CTL_PAD_CSI_MCLK SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_MCLK)
SW_MUX_CTL Register
Address: 20E_0000h base + 1D4h offset = 20E_01D4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_MCLK field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_MCLK
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: CSI_MCLK.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_MCLK of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_CD_B of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: RAWNAND_CE2_B of instance: rawnand
0011
ALT3 — Select mux mode: ALT3 mux port: I2C1_SDA of instance: i2c1
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_CS0_B of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO17 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: SNVS_HP_VIO_5_CTL of instance: snvs_hp
1000
ALT8 — Select mux mode: ALT8 mux port: UART6_TX of instance: uart6
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_TX3_RX2 of instance: esai
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1662
NXP Semiconductors

<!-- page 1663 -->

32.6.102
SW_MUX_CTL_PAD_CSI_PIXCLK SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_PIXCLK)
SW_MUX_CTL Register
Address: 20E_0000h base + 1D8h offset = 20E_01D8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_PIXCLK field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_PIXCLK
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 10 iomux modes to be used for pad: CSI_PIXCLK.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_PIXCLK of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_WP of instance: usdhc2
0010
ALT2 — Select mux mode: ALT2 mux port: RAWNAND_CE3_B of instance: rawnand
0011
ALT3 — Select mux mode: ALT3 mux port: I2C1_SCL of instance: i2c1
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_OE of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO18 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: SNVS_HP_VIO_5 of instance: snvs_hp
1000
ALT8 — Select mux mode: ALT8 mux port: UART6_RX of instance: uart6
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_TX2_RX3 of instance: esai
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1663

<!-- page 1664 -->

32.6.103
SW_MUX_CTL_PAD_CSI_VSYNC SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_VSYNC)
SW_MUX_CTL Register
Address: 20E_0000h base + 1DCh offset = 20E_01DCh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_VSYNC field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_VSYNC
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: CSI_VSYNC.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_VSYNC of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_CLK of instance: usdhc2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: I2C2_SDA of instance: i2c2
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_RW of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO19 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: PWM7_OUT of instance: pwm7
1000
ALT8 — Select mux mode: ALT8 mux port: UART6_RTS_B of instance: uart6
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_TX4_RX1 of instance: esai
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1664
NXP Semiconductors

<!-- page 1665 -->

32.6.104
SW_MUX_CTL_PAD_CSI_HSYNC SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_HSYNC)
SW_MUX_CTL Register
Address: 20E_0000h base + 1E0h offset = 20E_01E0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_HSYNC field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_HSYNC
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: CSI_HSYNC.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_HSYNC of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_CMD of instance: usdhc2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: I2C2_SCL of instance: i2c2
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_LBA_B of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO20 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: PWM8_OUT of instance: pwm8
1000
ALT8 — Select mux mode: ALT8 mux port: UART6_CTS_B of instance: uart6
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_TX1 of instance: esai
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1665

<!-- page 1666 -->

32.6.105
SW_MUX_CTL_PAD_CSI_DATA00 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA00)
SW_MUX_CTL Register
Address: 20E_0000h base + 1E4h offset = 20E_01E4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_DATA00 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_DATA00
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: CSI_DATA00.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_DATA02 of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA0 of instance: usdhc2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI2_SCLK of instance: ecspi2
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD00 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO21 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: SRC_INT_BOOT of instance: src
1000
ALT8 — Select mux mode: ALT8 mux port: UART5_TX of instance: uart5
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_TX_HF_CLK of instance: esai
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1666
NXP Semiconductors

<!-- page 1667 -->

32.6.106
SW_MUX_CTL_PAD_CSI_DATA01 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA01)
SW_MUX_CTL Register
Address: 20E_0000h base + 1E8h offset = 20E_01E8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_DATA01 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_DATA01
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: CSI_DATA01.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_DATA03 of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA1 of instance: usdhc2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI2_SS0 of instance: ecspi2
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD01 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO22 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: SAI1_MCLK of instance: sai1
1000
ALT8 — Select mux mode: ALT8 mux port: UART5_RX of instance: uart5
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_RX_HF_CLK of instance: esai
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1667

<!-- page 1668 -->

32.6.107
SW_MUX_CTL_PAD_CSI_DATA02 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA02)
SW_MUX_CTL Register
Address: 20E_0000h base + 1ECh offset = 20E_01ECh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_DATA02 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_DATA02
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: CSI_DATA02.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_DATA04 of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA2 of instance: usdhc2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI2_MOSI of instance: ecspi2
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD02 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO23 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: SAI1_RX_SYNC of instance: sai1
1000
ALT8 — Select mux mode: ALT8 mux port: UART5_RTS_B of instance: uart5
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_RX_FS of instance: esai
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1668
NXP Semiconductors

<!-- page 1669 -->

32.6.108
SW_MUX_CTL_PAD_CSI_DATA03 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA03)
SW_MUX_CTL Register
Address: 20E_0000h base + 1F0h offset = 20E_01F0h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_DATA03 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_DATA03
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: CSI_DATA03.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_DATA05 of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA3 of instance: usdhc2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI2_MISO of instance: ecspi2
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD03 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO24 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: SAI1_RX_BCLK of instance: sai1
1000
ALT8 — Select mux mode: ALT8 mux port: UART5_CTS_B of instance: uart5
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_RX_CLK of instance: esai
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1669

<!-- page 1670 -->

32.6.109
SW_MUX_CTL_PAD_CSI_DATA04 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA04)
SW_MUX_CTL Register
Address: 20E_0000h base + 1F4h offset = 20E_01F4h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_DATA04 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_DATA04
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: CSI_DATA04.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_DATA06 of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA4 of instance: usdhc2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI1_SCLK of instance: ecspi1
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD04 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO25 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: SAI1_TX_SYNC of instance: sai1
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC1_WP of instance: usdhc1
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_TX_FS of instance: esai
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1670
NXP Semiconductors

<!-- page 1671 -->

32.6.110
SW_MUX_CTL_PAD_CSI_DATA05 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA05)
SW_MUX_CTL Register
Address: 20E_0000h base + 1F8h offset = 20E_01F8h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_DATA05 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_DATA05
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: CSI_DATA05.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_DATA07 of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA5 of instance: usdhc2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI1_SS0 of instance: ecspi1
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD05 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO26 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: SAI1_TX_BCLK of instance: sai1
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC1_CD_B of instance: usdhc1
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_TX_CLK of instance: esai
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1671

<!-- page 1672 -->

32.6.111
SW_MUX_CTL_PAD_CSI_DATA06 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA06)
SW_MUX_CTL Register
Address: 20E_0000h base + 1FCh offset = 20E_01FCh
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_DATA06 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_DATA06
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: CSI_DATA06.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_DATA08 of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA6 of instance: usdhc2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI1_MOSI of instance: ecspi1
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD06 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO27 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: SAI1_RX_DATA of instance: sai1
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC1_RESET_B of instance: usdhc1
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_TX5_RX0 of instance: esai
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1672
NXP Semiconductors

<!-- page 1673 -->

32.6.112
SW_MUX_CTL_PAD_CSI_DATA07 SW MUX Control
Register (IOMUXC_SW_MUX_CTL_PAD_CSI_DATA07)
SW_MUX_CTL Register
Address: 20E_0000h base + 200h offset = 20E_0200h
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
SION
MUX_MODE
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
1
0
1
IOMUXC_SW_MUX_CTL_PAD_CSI_DATA07 field descriptions
Field
Description
31–5
-
This field is reserved.
Reserved
4
SION
Software Input On Field.
Force the selected mux mode Input path no matter of MUX_MODE functionality.
1
ENABLED — Force input path of pad CSI_DATA07
0
DISABLED — Input Path is determined by functionality
MUX_MODE
MUX Mode Select Field.
Select 1 of 9 iomux modes to be used for pad: CSI_DATA07.
0000
ALT0 — Select mux mode: ALT0 mux port: CSI_DATA09 of instance: csi
0001
ALT1 — Select mux mode: ALT1 mux port: USDHC2_DATA7 of instance: usdhc2
0010
ALT2 — Reserved
0011
ALT3 — Select mux mode: ALT3 mux port: ECSPI1_MISO of instance: ecspi1
0100
ALT4 — Select mux mode: ALT4 mux port: EIM_AD07 of instance: eim
0101
ALT5 — Select mux mode: ALT5 mux port: GPIO4_IO28 of instance: gpio4
0110
ALT6 — Select mux mode: ALT6 mux port: SAI1_TX_DATA of instance: sai1
1000
ALT8 — Select mux mode: ALT8 mux port: USDHC1_VSELECT of instance: usdhc1
1001
ALT9 — Select mux mode: ALT9 mux port: ESAI_TX0 of instance: esai
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1673

<!-- page 1674 -->

32.6.113
SW_PAD_CTL_PAD_DRAM_ADDR00 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR00)
SW_PAD_CTL Register
Address: 20E_0000h base + 204h offset = 20E_0204h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1674
NXP Semiconductors

<!-- page 1675 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR00 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR00
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR00
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR00
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1675

<!-- page 1676 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR00 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1676
NXP Semiconductors

<!-- page 1677 -->

32.6.114
SW_PAD_CTL_PAD_DRAM_ADDR01 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR01)
SW_PAD_CTL Register
Address: 20E_0000h base + 208h offset = 20E_0208h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1677

<!-- page 1678 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR01 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR01
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR01
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR01
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1678
NXP Semiconductors

<!-- page 1679 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR01 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1679

<!-- page 1680 -->

32.6.115
SW_PAD_CTL_PAD_DRAM_ADDR02 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR02)
SW_PAD_CTL Register
Address: 20E_0000h base + 20Ch offset = 20E_020Ch
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1680
NXP Semiconductors

<!-- page 1681 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR02 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR02
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR02
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR02
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1681

<!-- page 1682 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR02 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1682
NXP Semiconductors

<!-- page 1683 -->

32.6.116
SW_PAD_CTL_PAD_DRAM_ADDR03 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR03)
SW_PAD_CTL Register
Address: 20E_0000h base + 210h offset = 20E_0210h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1683

<!-- page 1684 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR03 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR03
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR03
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR03
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1684
NXP Semiconductors

<!-- page 1685 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR03 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1685

<!-- page 1686 -->

32.6.117
SW_PAD_CTL_PAD_DRAM_ADDR04 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR04)
SW_PAD_CTL Register
Address: 20E_0000h base + 214h offset = 20E_0214h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1686
NXP Semiconductors

<!-- page 1687 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR04 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR04
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR04
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR04
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1687

<!-- page 1688 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR04 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1688
NXP Semiconductors

<!-- page 1689 -->

32.6.118
SW_PAD_CTL_PAD_DRAM_ADDR05 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR05)
SW_PAD_CTL Register
Address: 20E_0000h base + 218h offset = 20E_0218h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1689

<!-- page 1690 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR05 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR05
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR05
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR05
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1690
NXP Semiconductors

<!-- page 1691 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR05 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1691

<!-- page 1692 -->

32.6.119
SW_PAD_CTL_PAD_DRAM_ADDR06 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR06)
SW_PAD_CTL Register
Address: 20E_0000h base + 21Ch offset = 20E_021Ch
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1692
NXP Semiconductors

<!-- page 1693 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR06 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR06
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR06
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR06
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1693

<!-- page 1694 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR06 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1694
NXP Semiconductors

<!-- page 1695 -->

32.6.120
SW_PAD_CTL_PAD_DRAM_ADDR07 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR07)
SW_PAD_CTL Register
Address: 20E_0000h base + 220h offset = 20E_0220h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1695

<!-- page 1696 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR07 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR07
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR07
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR07
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1696
NXP Semiconductors

<!-- page 1697 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR07 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1697

<!-- page 1698 -->

32.6.121
SW_PAD_CTL_PAD_DRAM_ADDR08 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR08)
SW_PAD_CTL Register
Address: 20E_0000h base + 224h offset = 20E_0224h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1698
NXP Semiconductors

<!-- page 1699 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR08 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR08
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR08
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR08
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1699

<!-- page 1700 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR08 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1700
NXP Semiconductors

<!-- page 1701 -->

32.6.122
SW_PAD_CTL_PAD_DRAM_ADDR09 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR09)
SW_PAD_CTL Register
Address: 20E_0000h base + 228h offset = 20E_0228h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1701

<!-- page 1702 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR09 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR09
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR09
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR09
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1702
NXP Semiconductors

<!-- page 1703 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR09 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1703

<!-- page 1704 -->

32.6.123
SW_PAD_CTL_PAD_DRAM_ADDR10 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR10)
SW_PAD_CTL Register
Address: 20E_0000h base + 22Ch offset = 20E_022Ch
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1704
NXP Semiconductors

<!-- page 1705 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR10 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_ADDR10
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR10
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR10
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR10
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1705

<!-- page 1706 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR10 field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1706
NXP Semiconductors

<!-- page 1707 -->

32.6.124
SW_PAD_CTL_PAD_DRAM_ADDR11 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR11)
SW_PAD_CTL Register
Address: 20E_0000h base + 230h offset = 20E_0230h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1707

<!-- page 1708 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR11 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_ADDR11
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR11
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR11
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR11
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1708
NXP Semiconductors

<!-- page 1709 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR11 field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1709

<!-- page 1710 -->

32.6.125
SW_PAD_CTL_PAD_DRAM_ADDR12 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR12)
SW_PAD_CTL Register
Address: 20E_0000h base + 234h offset = 20E_0234h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1710
NXP Semiconductors

<!-- page 1711 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR12 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_ADDR12
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR12
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR12
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR12
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1711

<!-- page 1712 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR12 field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1712
NXP Semiconductors

<!-- page 1713 -->

32.6.126
SW_PAD_CTL_PAD_DRAM_ADDR13 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR13)
SW_PAD_CTL Register
Address: 20E_0000h base + 238h offset = 20E_0238h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1713

<!-- page 1714 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR13 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_ADDR13
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR13
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR13
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR13
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1714
NXP Semiconductors

<!-- page 1715 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR13 field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1715

<!-- page 1716 -->

32.6.127
SW_PAD_CTL_PAD_DRAM_ADDR14 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR14)
SW_PAD_CTL Register
Address: 20E_0000h base + 23Ch offset = 20E_023Ch
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1716
NXP Semiconductors

<!-- page 1717 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR14 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_ADDR14
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR14
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR14
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR14
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1717

<!-- page 1718 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR14 field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1718
NXP Semiconductors

<!-- page 1719 -->

32.6.128
SW_PAD_CTL_PAD_DRAM_ADDR15 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR15)
SW_PAD_CTL Register
Address: 20E_0000h base + 240h offset = 20E_0240h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1719

<!-- page 1720 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR15 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_ADDR15
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ADDR15
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ADDR15
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_ADDR15
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1720
NXP Semiconductors

<!-- page 1721 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ADDR15 field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1721

<!-- page 1722 -->

32.6.129
SW_PAD_CTL_PAD_DRAM_DQM0 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM0)
SW_PAD_CTL Register
Address: 20E_0000h base + 244h offset = 20E_0244h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1722
NXP Semiconductors

<!-- page 1723 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM0 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_DQM0
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_DQM0
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_DQM0
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1723

<!-- page 1724 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM0 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for pad: DRAM_DQM0
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1724
NXP Semiconductors

<!-- page 1725 -->

32.6.130
SW_PAD_CTL_PAD_DRAM_DQM1 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM1)
SW_PAD_CTL Register
Address: 20E_0000h base + 248h offset = 20E_0248h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1725

<!-- page 1726 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM1 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Read Only Field
0
DO_TRIM — min delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_DQM1
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_DQM1
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_DQM1
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1726
NXP Semiconductors

<!-- page 1727 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_DQM1 field descriptions (continued)
Field
Description
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for pad: DRAM_DQM1
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1727

<!-- page 1728 -->

32.6.131
SW_PAD_CTL_PAD_DRAM_RAS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_RAS_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 24Ch offset = 20E_024Ch
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1728
NXP Semiconductors

<!-- page 1729 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_RAS_B field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_RAS_B
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_RAS_B
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_RAS_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_RAS_B
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1729

<!-- page 1730 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_RAS_B field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for pad: DRAM_RAS_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1730
NXP Semiconductors

<!-- page 1731 -->

32.6.132
SW_PAD_CTL_PAD_DRAM_CAS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_CAS_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 250h offset = 20E_0250h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1731

<!-- page 1732 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_CAS_B field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_CAS_B
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_CAS_B
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_CAS_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_CAS_B
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1732
NXP Semiconductors

<!-- page 1733 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_CAS_B field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for pad: DRAM_CAS_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1733

<!-- page 1734 -->

32.6.133
SW_PAD_CTL_PAD_DRAM_CS0_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_CS0_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 254h offset = 20E_0254h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1734
NXP Semiconductors

<!-- page 1735 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_CS0_B field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_CS0_B
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_CS0_B
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_CS0_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_CS0_B
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1735

<!-- page 1736 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_CS0_B field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1736
NXP Semiconductors

<!-- page 1737 -->

32.6.134
SW_PAD_CTL_PAD_DRAM_CS1_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_CS1_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 258h offset = 20E_0258h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1737

<!-- page 1738 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_CS1_B field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_CS1_B
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_CS1_B
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_CS1_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_CS1_B
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1738
NXP Semiconductors

<!-- page 1739 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_CS1_B field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1739

<!-- page 1740 -->

32.6.135
SW_PAD_CTL_PAD_DRAM_SDWE_B SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_SDWE_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 25Ch offset = 20E_025Ch
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1740
NXP Semiconductors

<!-- page 1741 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDWE_B field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_SDWE_B
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_SDWE_B
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_SDWE_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_SDWE_B
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1741

<!-- page 1742 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDWE_B field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1742
NXP Semiconductors

<!-- page 1743 -->

32.6.136
SW_PAD_CTL_PAD_DRAM_ODT0 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ODT0)
SW_PAD_CTL Register
Address: 20E_0000h base + 260h offset = 20E_0260h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
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
1
1
0
0
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1743

<!-- page 1744 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ODT0 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_ODT0
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ODT0
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ODT0
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: DRAM_ODT0
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: DRAM_ODT0
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: DRAM_ODT0
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1744
NXP Semiconductors

<!-- page 1745 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ODT0 field descriptions (continued)
Field
Description
Select one out of next values for pad: DRAM_ODT0
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for pad: DRAM_ODT0
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1745

<!-- page 1746 -->

32.6.137
SW_PAD_CTL_PAD_DRAM_ODT1 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_ODT1)
SW_PAD_CTL Register
Address: 20E_0000h base + 264h offset = 20E_0264h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
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
1
1
0
0
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1746
NXP Semiconductors

<!-- page 1747 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ODT1 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_ODT1
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_ODT1
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_ODT1
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: DRAM_ODT1
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: DRAM_ODT1
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: DRAM_ODT1
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1747

<!-- page 1748 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_ODT1 field descriptions (continued)
Field
Description
Select one out of next values for pad: DRAM_ODT1
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for pad: DRAM_ODT1
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1748
NXP Semiconductors

<!-- page 1749 -->

32.6.138
SW_PAD_CTL_PAD_DRAM_SDBA0 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA0)
SW_PAD_CTL Register
Address: 20E_0000h base + 268h offset = 20E_0268h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1749

<!-- page 1750 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA0 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_SDBA0
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_SDBA0
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_SDBA0
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_SDBA0
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1750
NXP Semiconductors

<!-- page 1751 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA0 field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1751

<!-- page 1752 -->

32.6.139
SW_PAD_CTL_PAD_DRAM_SDBA1 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA1)
SW_PAD_CTL Register
Address: 20E_0000h base + 26Ch offset = 20E_026Ch
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1752
NXP Semiconductors

<!-- page 1753 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA1 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_SDBA1
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_SDBA1
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_SDBA1
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_SDBA1
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1753

<!-- page 1754 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA1 field descriptions (continued)
Field
Description
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1754
NXP Semiconductors

<!-- page 1755 -->

32.6.140
SW_PAD_CTL_PAD_DRAM_SDBA2 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA2)
SW_PAD_CTL Register
Address: 20E_0000h base + 270h offset = 20E_0270h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1755

<!-- page 1756 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA2 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_SDBA2
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_SDBA2
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_SDBA2
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: DRAM_SDBA2
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: DRAM_SDBA2
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_SDBA2
000
ODT_0_off — off
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1756
NXP Semiconductors

<!-- page 1757 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDBA2 field descriptions (continued)
Field
Description
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1757

<!-- page 1758 -->

32.6.141
SW_PAD_CTL_PAD_DRAM_SDCKE0 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCKE0)
SW_PAD_CTL Register
Address: 20E_0000h base + 274h offset = 20E_0274h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
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
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1758
NXP Semiconductors

<!-- page 1759 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCKE0 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_SDCKE0
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_SDCKE0
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_SDCKE0
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: DRAM_SDCKE0
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: DRAM_SDCKE0
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: DRAM_SDCKE0
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1759

<!-- page 1760 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCKE0 field descriptions (continued)
Field
Description
Select one out of next values for pad: DRAM_SDCKE0
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1760
NXP Semiconductors

<!-- page 1761 -->

32.6.142
SW_PAD_CTL_PAD_DRAM_SDCKE1 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCKE1)
SW_PAD_CTL Register
Address: 20E_0000h base + 278h offset = 20E_0278h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
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
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1761

<!-- page 1762 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCKE1 field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_SDCKE1
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_SDCKE1
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_SDCKE1
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: DRAM_SDCKE1
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: DRAM_SDCKE1
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: DRAM_SDCKE1
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1762
NXP Semiconductors

<!-- page 1763 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCKE1 field descriptions (continued)
Field
Description
Select one out of next values for pad: DRAM_SDCKE1
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Read Only Field
0
DSE — output driver disabled;
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1763

<!-- page 1764 -->

32.6.143
SW_PAD_CTL_PAD_DRAM_SDCLK0_P SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCLK0_P)
SW_PAD_CTL Register
Address: 20E_0000h base + 27Ch offset = 20E_027Ch
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
DO_TRIM_
PADN
Reserved
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
W
Reset
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
0
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1764
NXP Semiconductors

<!-- page 1765 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCLK0_P field descriptions
Field
Description
31–26
-
This field is reserved.
Reserved
25–24
DO_TRIM_PADN
do_trim_padn Field
Select one out of next values for pad: DRAM_SDCLK0_P
00
DO_TRIM_PADN_0_min_delay — min delay
01
DO_TRIM_PADN_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_PADN_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_PADN_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
23–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_SDCLK0_P
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_SDCLK0_P
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_SDCLK0_P
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Read Only Field
10
PUS — 100K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Read Only Field
0
PUE — Keeper
12
PKE
Pull / Keep Enable Field
Read Only Field
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1765

<!-- page 1766 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDCLK0_P field descriptions (continued)
Field
Description
0
PKE — Pull/Keeper Disabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_SDCLK0_P
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for pad: DRAM_SDCLK0_P
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1766
NXP Semiconductors

<!-- page 1767 -->

32.6.144
SW_PAD_CTL_PAD_DRAM_SDQS0_P SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS0_P)
SW_PAD_CTL Register
Address: 20E_0000h base + 280h offset = 20E_0280h
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
DO_TRIM_
PADN
Reserved
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1767

<!-- page 1768 -->

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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
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
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS0_P field descriptions
Field
Description
31–26
-
This field is reserved.
Reserved
25–24
DO_TRIM_PADN
do_trim_padn Field
Select one out of next values for pad: DRAM_SDQS0_P
00
DO_TRIM_PADN_0_min_delay — min delay
01
DO_TRIM_PADN_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_PADN_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_PADN_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
23–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_SDQS0_P
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Read Only Field
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1768
NXP Semiconductors

<!-- page 1769 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS0_P field descriptions (continued)
Field
Description
0
DDR_INPUT — CMOS input type
16
HYS
Hyst. Enable Field
Read Only Field
0
HYS — Hysteresis Disabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: DRAM_SDQS0_P
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: DRAM_SDQS0_P
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: DRAM_SDQS0_P
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Read Only Field
0
ODT — off
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for pad: DRAM_SDQS0_P
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1769

<!-- page 1770 -->

32.6.145
SW_PAD_CTL_PAD_DRAM_SDQS1_P SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS1_P)
SW_PAD_CTL Register
Address: 20E_0000h base + 284h offset = 20E_0284h
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
DO_TRIM_
PADN
Reserved
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1770
NXP Semiconductors

<!-- page 1771 -->

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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
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
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS1_P field descriptions
Field
Description
31–26
-
This field is reserved.
Reserved
25–24
DO_TRIM_PADN
do_trim_padn Field
Select one out of next values for pad: DRAM_SDQS1_P
00
DO_TRIM_PADN_0_min_delay — min delay
01
DO_TRIM_PADN_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_PADN_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_PADN_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
23–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_SDQS1_P
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Read Only Field
0
DDR_SEL — RESERVED
17
DDR_INPUT
DDR / CMOS Input Mode Field
Read Only Field
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1771

<!-- page 1772 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_SDQS1_P field descriptions (continued)
Field
Description
0
DDR_INPUT — CMOS input type
16
HYS
Hyst. Enable Field
Read Only Field
0
HYS — Hysteresis Disabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: DRAM_SDQS1_P
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: DRAM_SDQS1_P
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: DRAM_SDQS1_P
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Read Only Field
0
ODT — off
7–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for pad: DRAM_SDQS1_P
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1772
NXP Semiconductors

<!-- page 1773 -->

32.6.146
SW_PAD_CTL_PAD_DRAM_RESET SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_DRAM_RESET)
SW_PAD_CTL Register
Address: 20E_0000h base + 288h offset = 20E_0288h
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
DO_TRIM
DDR_SEL
DDR_INPUT
HYS
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
PUS
PUE
PKE
Reserved
ODT
Reserved
DSE
Reserved
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
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_DRAM_RESET field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved
21–20
DO_TRIM
do_trim Field
Select one out of next values for pad: DRAM_RESET
00
DO_TRIM_0_min_delay — min delay
01
DO_TRIM_1_____50ps__ipp_do____pad_delay — + ~50ps ipp_do -> pad delay
10
DO_TRIM_2_____100ps_ipp_do____pad_delay — + ~100ps ipp_do -> pad delay
11
DO_TRIM_3_____150ps_ipp_do____pad_delay — + ~150ps ipp_do -> pad delay
19–18
DDR_SEL
ddr_sel Field
Select one out of next values for pad: DRAM_RESET
00
DDR_SEL_0_RESERVED — RESERVED
01
DDR_SEL_1_RESERVED — RESERVED
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1773

<!-- page 1774 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_RESET field descriptions (continued)
Field
Description
10
DDR_SEL_2_LPDDR2_mode — LPDDR2 mode
11
DDR_SEL_3_DDR3_mode — DDR3 mode
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for pad: DRAM_RESET
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
16
HYS
Hyst. Enable Field
Select one out of next values for pad: DRAM_RESET
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: DRAM_RESET
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: DRAM_RESET
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: DRAM_RESET
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
-
This field is reserved.
Reserved
10–8
ODT
On Die Termination Field
Select one out of next values for pad: DRAM_RESET
000
ODT_0_off — off
001
ODT_1_120_Ohm_ODT — 120 Ohm ODT
010
ODT_2_60_Ohm_ODT — 60 Ohm ODT
011
ODT_3_40_Ohm_ODT — 40 Ohm ODT
100
ODT_4_30_Ohm_ODT — 30 Ohm ODT
101
ODT_5_24_Ohm_ODT — 24 Ohm ODT
110
ODT_6_20_Ohm_ODT — 20 Ohm ODT
111
ODT_7_17_Ohm_ODT — 17 Ohm ODT
7–6
-
This field is reserved.
Reserved
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1774
NXP Semiconductors

<!-- page 1775 -->

IOMUXC_SW_PAD_CTL_PAD_DRAM_RESET field descriptions (continued)
Field
Description
5–3
DSE
Drive Strength Field
Select one out of next values for pad: DRAM_RESET
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
32.6.147
SW_PAD_CTL_PAD_JTAG_MOD SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_JTAG_MOD)
SW_PAD_CTL Register
Address: 20E_0000h base + 2D0h offset = 20E_02D0h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
W
Reset
1
0
1
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
0
0
IOMUXC_SW_PAD_CTL_PAD_JTAG_MOD field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: JTAG_MOD
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1775

<!-- page 1776 -->

IOMUXC_SW_PAD_CTL_PAD_JTAG_MOD field descriptions (continued)
Field
Description
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: JTAG_MOD
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: JTAG_MOD
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: JTAG_MOD
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: JTAG_MOD
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: JTAG_MOD
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: JTAG_MOD
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1776
NXP Semiconductors

<!-- page 1777 -->

IOMUXC_SW_PAD_CTL_PAD_JTAG_MOD field descriptions (continued)
Field
Description
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
32.6.148
SW_PAD_CTL_PAD_JTAG_TMS SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_JTAG_TMS)
SW_PAD_CTL Register
Address: 20E_0000h base + 2D4h offset = 20E_02D4h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
W
Reset
0
1
1
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
0
0
IOMUXC_SW_PAD_CTL_PAD_JTAG_TMS field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: JTAG_TMS
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: JTAG_TMS
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: JTAG_TMS
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1777

<!-- page 1778 -->

IOMUXC_SW_PAD_CTL_PAD_JTAG_TMS field descriptions (continued)
Field
Description
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: JTAG_TMS
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: JTAG_TMS
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: JTAG_TMS
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: JTAG_TMS
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1778
NXP Semiconductors

<!-- page 1779 -->

32.6.149
SW_PAD_CTL_PAD_JTAG_TDO SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_JTAG_TDO)
SW_PAD_CTL Register
Address: 20E_0000h base + 2D8h offset = 20E_02D8h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
W
Reset
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
1
1
0
0
0
1
IOMUXC_SW_PAD_CTL_PAD_JTAG_TDO field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: JTAG_TDO
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: JTAG_TDO
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: JTAG_TDO
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: JTAG_TDO
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1779

<!-- page 1780 -->

IOMUXC_SW_PAD_CTL_PAD_JTAG_TDO field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: JTAG_TDO
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: JTAG_TDO
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: JTAG_TDO
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1780
NXP Semiconductors

<!-- page 1781 -->

32.6.150
SW_PAD_CTL_PAD_JTAG_TDI SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_JTAG_TDI)
SW_PAD_CTL Register
Address: 20E_0000h base + 2DCh offset = 20E_02DCh
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
W
Reset
0
1
1
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
0
0
IOMUXC_SW_PAD_CTL_PAD_JTAG_TDI field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: JTAG_TDI
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: JTAG_TDI
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: JTAG_TDI
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: JTAG_TDI
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1781

<!-- page 1782 -->

IOMUXC_SW_PAD_CTL_PAD_JTAG_TDI field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: JTAG_TDI
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: JTAG_TDI
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: JTAG_TDI
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1782
NXP Semiconductors

<!-- page 1783 -->

32.6.151
SW_PAD_CTL_PAD_JTAG_TCK SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_JTAG_TCK)
SW_PAD_CTL Register
Address: 20E_0000h base + 2E0h offset = 20E_02E0h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
W
Reset
0
1
1
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
0
0
IOMUXC_SW_PAD_CTL_PAD_JTAG_TCK field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: JTAG_TCK
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: JTAG_TCK
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: JTAG_TCK
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: JTAG_TCK
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1783

<!-- page 1784 -->

IOMUXC_SW_PAD_CTL_PAD_JTAG_TCK field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: JTAG_TCK
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: JTAG_TCK
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: JTAG_TCK
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1784
NXP Semiconductors

<!-- page 1785 -->

32.6.152
SW_PAD_CTL_PAD_JTAG_TRST_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_JTAG_TRST_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 2E4h offset = 20E_02E4h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
W
Reset
0
1
1
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
0
0
IOMUXC_SW_PAD_CTL_PAD_JTAG_TRST_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: JTAG_TRST_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: JTAG_TRST_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: JTAG_TRST_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: JTAG_TRST_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1785

<!-- page 1786 -->

IOMUXC_SW_PAD_CTL_PAD_JTAG_TRST_B field descriptions (continued)
Field
Description
11
ODE
Open Drain Enable Field
Select one out of next values for pad: JTAG_TRST_B
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Read Only Field
10
SPEED — medium(100MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: JTAG_TRST_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: JTAG_TRST_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1786
NXP Semiconductors

<!-- page 1787 -->

32.6.153
SW_PAD_CTL_PAD_GPIO1_IO00 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO00)
SW_PAD_CTL Register
Address: 20E_0000h base + 2E8h offset = 20E_02E8h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO00 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: GPIO1_IO00
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: GPIO1_IO00
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: GPIO1_IO00
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: GPIO1_IO00
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: GPIO1_IO00
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1787

<!-- page 1788 -->

IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO00 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: GPIO1_IO00
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: GPIO1_IO00
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: GPIO1_IO00
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1788
NXP Semiconductors

<!-- page 1789 -->

32.6.154
SW_PAD_CTL_PAD_GPIO1_IO01 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO01)
SW_PAD_CTL Register
Address: 20E_0000h base + 2ECh offset = 20E_02ECh
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO01 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: GPIO1_IO01
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: GPIO1_IO01
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: GPIO1_IO01
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: GPIO1_IO01
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: GPIO1_IO01
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1789

<!-- page 1790 -->

IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO01 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: GPIO1_IO01
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: GPIO1_IO01
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: GPIO1_IO01
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1790
NXP Semiconductors

<!-- page 1791 -->

32.6.155
SW_PAD_CTL_PAD_GPIO1_IO02 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO02)
SW_PAD_CTL Register
Address: 20E_0000h base + 2F0h offset = 20E_02F0h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO02 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: GPIO1_IO02
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: GPIO1_IO02
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: GPIO1_IO02
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: GPIO1_IO02
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: GPIO1_IO02
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1791

<!-- page 1792 -->

IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO02 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: GPIO1_IO02
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: GPIO1_IO02
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: GPIO1_IO02
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1792
NXP Semiconductors

<!-- page 1793 -->

32.6.156
SW_PAD_CTL_PAD_GPIO1_IO03 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO03)
SW_PAD_CTL Register
Address: 20E_0000h base + 2F4h offset = 20E_02F4h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO03 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: GPIO1_IO03
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: GPIO1_IO03
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: GPIO1_IO03
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: GPIO1_IO03
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: GPIO1_IO03
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1793

<!-- page 1794 -->

IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO03 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: GPIO1_IO03
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: GPIO1_IO03
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: GPIO1_IO03
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1794
NXP Semiconductors

<!-- page 1795 -->

32.6.157
SW_PAD_CTL_PAD_GPIO1_IO04 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO04)
SW_PAD_CTL Register
Address: 20E_0000h base + 2F8h offset = 20E_02F8h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO04 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: GPIO1_IO04
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: GPIO1_IO04
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: GPIO1_IO04
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: GPIO1_IO04
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: GPIO1_IO04
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1795

<!-- page 1796 -->

IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO04 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: GPIO1_IO04
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: GPIO1_IO04
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: GPIO1_IO04
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1796
NXP Semiconductors

<!-- page 1797 -->

32.6.158
SW_PAD_CTL_PAD_GPIO1_IO05 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO05)
SW_PAD_CTL Register
Address: 20E_0000h base + 2FCh offset = 20E_02FCh
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO05 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: GPIO1_IO05
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: GPIO1_IO05
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: GPIO1_IO05
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: GPIO1_IO05
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: GPIO1_IO05
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1797

<!-- page 1798 -->

IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO05 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: GPIO1_IO05
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: GPIO1_IO05
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: GPIO1_IO05
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1798
NXP Semiconductors

<!-- page 1799 -->

32.6.159
SW_PAD_CTL_PAD_GPIO1_IO06 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO06)
SW_PAD_CTL Register
Address: 20E_0000h base + 300h offset = 20E_0300h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO06 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: GPIO1_IO06
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: GPIO1_IO06
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: GPIO1_IO06
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: GPIO1_IO06
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: GPIO1_IO06
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1799

<!-- page 1800 -->

IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO06 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: GPIO1_IO06
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: GPIO1_IO06
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: GPIO1_IO06
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1800
NXP Semiconductors

<!-- page 1801 -->

32.6.160
SW_PAD_CTL_PAD_GPIO1_IO07 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO07)
SW_PAD_CTL Register
Address: 20E_0000h base + 304h offset = 20E_0304h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO07 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: GPIO1_IO07
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: GPIO1_IO07
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: GPIO1_IO07
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: GPIO1_IO07
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: GPIO1_IO07
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1801

<!-- page 1802 -->

IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO07 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: GPIO1_IO07
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: GPIO1_IO07
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: GPIO1_IO07
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1802
NXP Semiconductors

<!-- page 1803 -->

32.6.161
SW_PAD_CTL_PAD_GPIO1_IO08 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO08)
SW_PAD_CTL Register
Address: 20E_0000h base + 308h offset = 20E_0308h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO08 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: GPIO1_IO08
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: GPIO1_IO08
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: GPIO1_IO08
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: GPIO1_IO08
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: GPIO1_IO08
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1803

<!-- page 1804 -->

IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO08 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: GPIO1_IO08
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: GPIO1_IO08
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: GPIO1_IO08
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1804
NXP Semiconductors

<!-- page 1805 -->

32.6.162
SW_PAD_CTL_PAD_GPIO1_IO09 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO09)
SW_PAD_CTL Register
Address: 20E_0000h base + 30Ch offset = 20E_030Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO09 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: GPIO1_IO09
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: GPIO1_IO09
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: GPIO1_IO09
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: GPIO1_IO09
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: GPIO1_IO09
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1805

<!-- page 1806 -->

IOMUXC_SW_PAD_CTL_PAD_GPIO1_IO09 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: GPIO1_IO09
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: GPIO1_IO09
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: GPIO1_IO09
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1806
NXP Semiconductors

<!-- page 1807 -->

32.6.163
SW_PAD_CTL_PAD_UART1_TX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART1_TX_DATA)
SW_PAD_CTL Register
Address: 20E_0000h base + 310h offset = 20E_0310h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART1_TX_DATA field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART1_TX_DATA
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART1_TX_DATA
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART1_TX_DATA
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART1_TX_DATA
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART1_TX_DATA
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1807

<!-- page 1808 -->

IOMUXC_SW_PAD_CTL_PAD_UART1_TX_DATA field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART1_TX_DATA
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART1_TX_DATA
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART1_TX_DATA
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1808
NXP Semiconductors

<!-- page 1809 -->

32.6.164
SW_PAD_CTL_PAD_UART1_RX_DATA SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_UART1_RX_DATA)
SW_PAD_CTL Register
Address: 20E_0000h base + 314h offset = 20E_0314h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART1_RX_DATA field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART1_RX_DATA
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART1_RX_DATA
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART1_RX_DATA
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART1_RX_DATA
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART1_RX_DATA
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1809

<!-- page 1810 -->

IOMUXC_SW_PAD_CTL_PAD_UART1_RX_DATA field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART1_RX_DATA
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART1_RX_DATA
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART1_RX_DATA
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1810
NXP Semiconductors

<!-- page 1811 -->

32.6.165
SW_PAD_CTL_PAD_UART1_CTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART1_CTS_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 318h offset = 20E_0318h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART1_CTS_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART1_CTS_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART1_CTS_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART1_CTS_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART1_CTS_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART1_CTS_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1811

<!-- page 1812 -->

IOMUXC_SW_PAD_CTL_PAD_UART1_CTS_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART1_CTS_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART1_CTS_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART1_CTS_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1812
NXP Semiconductors

<!-- page 1813 -->

32.6.166
SW_PAD_CTL_PAD_UART1_RTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART1_RTS_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 31Ch offset = 20E_031Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART1_RTS_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART1_RTS_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART1_RTS_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART1_RTS_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART1_RTS_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART1_RTS_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1813

<!-- page 1814 -->

IOMUXC_SW_PAD_CTL_PAD_UART1_RTS_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART1_RTS_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART1_RTS_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART1_RTS_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1814
NXP Semiconductors

<!-- page 1815 -->

32.6.167
SW_PAD_CTL_PAD_UART2_TX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART2_TX_DATA)
SW_PAD_CTL Register
Address: 20E_0000h base + 320h offset = 20E_0320h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART2_TX_DATA field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART2_TX_DATA
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART2_TX_DATA
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART2_TX_DATA
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART2_TX_DATA
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART2_TX_DATA
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1815

<!-- page 1816 -->

IOMUXC_SW_PAD_CTL_PAD_UART2_TX_DATA field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART2_TX_DATA
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART2_TX_DATA
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART2_TX_DATA
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1816
NXP Semiconductors

<!-- page 1817 -->

32.6.168
SW_PAD_CTL_PAD_UART2_RX_DATA SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_UART2_RX_DATA)
SW_PAD_CTL Register
Address: 20E_0000h base + 324h offset = 20E_0324h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART2_RX_DATA field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART2_RX_DATA
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART2_RX_DATA
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART2_RX_DATA
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART2_RX_DATA
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART2_RX_DATA
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1817

<!-- page 1818 -->

IOMUXC_SW_PAD_CTL_PAD_UART2_RX_DATA field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART2_RX_DATA
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART2_RX_DATA
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART2_RX_DATA
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1818
NXP Semiconductors

<!-- page 1819 -->

32.6.169
SW_PAD_CTL_PAD_UART2_CTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART2_CTS_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 328h offset = 20E_0328h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART2_CTS_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART2_CTS_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART2_CTS_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART2_CTS_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART2_CTS_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART2_CTS_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1819

<!-- page 1820 -->

IOMUXC_SW_PAD_CTL_PAD_UART2_CTS_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART2_CTS_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART2_CTS_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART2_CTS_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1820
NXP Semiconductors

<!-- page 1821 -->

32.6.170
SW_PAD_CTL_PAD_UART2_RTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART2_RTS_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 32Ch offset = 20E_032Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART2_RTS_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART2_RTS_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART2_RTS_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART2_RTS_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART2_RTS_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART2_RTS_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1821

<!-- page 1822 -->

IOMUXC_SW_PAD_CTL_PAD_UART2_RTS_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART2_RTS_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART2_RTS_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART2_RTS_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1822
NXP Semiconductors

<!-- page 1823 -->

32.6.171
SW_PAD_CTL_PAD_UART3_TX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART3_TX_DATA)
SW_PAD_CTL Register
Address: 20E_0000h base + 330h offset = 20E_0330h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART3_TX_DATA field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART3_TX_DATA
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART3_TX_DATA
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART3_TX_DATA
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART3_TX_DATA
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART3_TX_DATA
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1823

<!-- page 1824 -->

IOMUXC_SW_PAD_CTL_PAD_UART3_TX_DATA field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART3_TX_DATA
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART3_TX_DATA
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART3_TX_DATA
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1824
NXP Semiconductors

<!-- page 1825 -->

32.6.172
SW_PAD_CTL_PAD_UART3_RX_DATA SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_UART3_RX_DATA)
SW_PAD_CTL Register
Address: 20E_0000h base + 334h offset = 20E_0334h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART3_RX_DATA field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART3_RX_DATA
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART3_RX_DATA
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART3_RX_DATA
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART3_RX_DATA
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART3_RX_DATA
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1825

<!-- page 1826 -->

IOMUXC_SW_PAD_CTL_PAD_UART3_RX_DATA field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART3_RX_DATA
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART3_RX_DATA
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART3_RX_DATA
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1826
NXP Semiconductors

<!-- page 1827 -->

32.6.173
SW_PAD_CTL_PAD_UART3_CTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART3_CTS_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 338h offset = 20E_0338h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART3_CTS_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART3_CTS_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART3_CTS_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART3_CTS_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART3_CTS_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART3_CTS_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1827

<!-- page 1828 -->

IOMUXC_SW_PAD_CTL_PAD_UART3_CTS_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART3_CTS_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART3_CTS_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART3_CTS_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1828
NXP Semiconductors

<!-- page 1829 -->

32.6.174
SW_PAD_CTL_PAD_UART3_RTS_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_UART3_RTS_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 33Ch offset = 20E_033Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART3_RTS_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART3_RTS_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART3_RTS_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART3_RTS_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART3_RTS_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART3_RTS_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1829

<!-- page 1830 -->

IOMUXC_SW_PAD_CTL_PAD_UART3_RTS_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART3_RTS_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART3_RTS_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART3_RTS_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1830
NXP Semiconductors

<!-- page 1831 -->

32.6.175
SW_PAD_CTL_PAD_UART4_TX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART4_TX_DATA)
SW_PAD_CTL Register
Address: 20E_0000h base + 340h offset = 20E_0340h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART4_TX_DATA field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART4_TX_DATA
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART4_TX_DATA
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART4_TX_DATA
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART4_TX_DATA
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART4_TX_DATA
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1831

<!-- page 1832 -->

IOMUXC_SW_PAD_CTL_PAD_UART4_TX_DATA field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART4_TX_DATA
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART4_TX_DATA
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART4_TX_DATA
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1832
NXP Semiconductors

<!-- page 1833 -->

32.6.176
SW_PAD_CTL_PAD_UART4_RX_DATA SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_UART4_RX_DATA)
SW_PAD_CTL Register
Address: 20E_0000h base + 344h offset = 20E_0344h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART4_RX_DATA field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART4_RX_DATA
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART4_RX_DATA
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART4_RX_DATA
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART4_RX_DATA
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART4_RX_DATA
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1833

<!-- page 1834 -->

IOMUXC_SW_PAD_CTL_PAD_UART4_RX_DATA field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART4_RX_DATA
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART4_RX_DATA
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART4_RX_DATA
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1834
NXP Semiconductors

<!-- page 1835 -->

32.6.177
SW_PAD_CTL_PAD_UART5_TX_DATA SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_UART5_TX_DATA)
SW_PAD_CTL Register
Address: 20E_0000h base + 348h offset = 20E_0348h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART5_TX_DATA field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART5_TX_DATA
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART5_TX_DATA
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART5_TX_DATA
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART5_TX_DATA
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART5_TX_DATA
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1835

<!-- page 1836 -->

IOMUXC_SW_PAD_CTL_PAD_UART5_TX_DATA field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART5_TX_DATA
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART5_TX_DATA
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART5_TX_DATA
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1836
NXP Semiconductors

<!-- page 1837 -->

32.6.178
SW_PAD_CTL_PAD_UART5_RX_DATA SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_UART5_RX_DATA)
SW_PAD_CTL Register
Address: 20E_0000h base + 34Ch offset = 20E_034Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_UART5_RX_DATA field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: UART5_RX_DATA
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: UART5_RX_DATA
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: UART5_RX_DATA
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: UART5_RX_DATA
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: UART5_RX_DATA
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1837

<!-- page 1838 -->

IOMUXC_SW_PAD_CTL_PAD_UART5_RX_DATA field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: UART5_RX_DATA
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: UART5_RX_DATA
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: UART5_RX_DATA
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1838
NXP Semiconductors

<!-- page 1839 -->

32.6.179
SW_PAD_CTL_PAD_ENET1_RX_DATA0 SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_DATA0)
SW_PAD_CTL Register
Address: 20E_0000h base + 350h offset = 20E_0350h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_DATA0 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET1_RX_DATA0
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET1_RX_DATA0
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET1_RX_DATA0
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET1_RX_DATA0
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET1_RX_DATA0
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1839

<!-- page 1840 -->

IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_DATA0 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET1_RX_DATA0
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET1_RX_DATA0
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET1_RX_DATA0
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1840
NXP Semiconductors

<!-- page 1841 -->

32.6.180
SW_PAD_CTL_PAD_ENET1_RX_DATA1 SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_DATA1)
SW_PAD_CTL Register
Address: 20E_0000h base + 354h offset = 20E_0354h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_DATA1 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET1_RX_DATA1
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET1_RX_DATA1
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET1_RX_DATA1
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET1_RX_DATA1
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET1_RX_DATA1
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1841

<!-- page 1842 -->

IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_DATA1 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET1_RX_DATA1
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET1_RX_DATA1
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET1_RX_DATA1
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1842
NXP Semiconductors

<!-- page 1843 -->

32.6.181
SW_PAD_CTL_PAD_ENET1_RX_EN SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_EN)
SW_PAD_CTL Register
Address: 20E_0000h base + 358h offset = 20E_0358h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_EN field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET1_RX_EN
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET1_RX_EN
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET1_RX_EN
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET1_RX_EN
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET1_RX_EN
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1843

<!-- page 1844 -->

IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_EN field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET1_RX_EN
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET1_RX_EN
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET1_RX_EN
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1844
NXP Semiconductors

<!-- page 1845 -->

32.6.182
SW_PAD_CTL_PAD_ENET1_TX_DATA0 SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_DATA0)
SW_PAD_CTL Register
Address: 20E_0000h base + 35Ch offset = 20E_035Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_DATA0 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET1_TX_DATA0
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET1_TX_DATA0
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET1_TX_DATA0
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET1_TX_DATA0
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET1_TX_DATA0
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1845

<!-- page 1846 -->

IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_DATA0 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET1_TX_DATA0
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET1_TX_DATA0
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET1_TX_DATA0
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1846
NXP Semiconductors

<!-- page 1847 -->

32.6.183
SW_PAD_CTL_PAD_ENET1_TX_DATA1 SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_DATA1)
SW_PAD_CTL Register
Address: 20E_0000h base + 360h offset = 20E_0360h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_DATA1 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET1_TX_DATA1
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET1_TX_DATA1
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET1_TX_DATA1
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET1_TX_DATA1
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET1_TX_DATA1
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1847

<!-- page 1848 -->

IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_DATA1 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET1_TX_DATA1
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET1_TX_DATA1
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET1_TX_DATA1
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1848
NXP Semiconductors

<!-- page 1849 -->

32.6.184
SW_PAD_CTL_PAD_ENET1_TX_EN SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_EN)
SW_PAD_CTL Register
Address: 20E_0000h base + 364h offset = 20E_0364h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_EN field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET1_TX_EN
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET1_TX_EN
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET1_TX_EN
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET1_TX_EN
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET1_TX_EN
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1849

<!-- page 1850 -->

IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_EN field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET1_TX_EN
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET1_TX_EN
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET1_TX_EN
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1850
NXP Semiconductors

<!-- page 1851 -->

32.6.185
SW_PAD_CTL_PAD_ENET1_TX_CLK SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_CLK)
SW_PAD_CTL Register
Address: 20E_0000h base + 368h offset = 20E_0368h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_CLK field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET1_TX_CLK
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET1_TX_CLK
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET1_TX_CLK
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET1_TX_CLK
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET1_TX_CLK
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1851

<!-- page 1852 -->

IOMUXC_SW_PAD_CTL_PAD_ENET1_TX_CLK field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET1_TX_CLK
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET1_TX_CLK
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET1_TX_CLK
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1852
NXP Semiconductors

<!-- page 1853 -->

32.6.186
SW_PAD_CTL_PAD_ENET1_RX_ER SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_ER)
SW_PAD_CTL Register
Address: 20E_0000h base + 36Ch offset = 20E_036Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_ER field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET1_RX_ER
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET1_RX_ER
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET1_RX_ER
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET1_RX_ER
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET1_RX_ER
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1853

<!-- page 1854 -->

IOMUXC_SW_PAD_CTL_PAD_ENET1_RX_ER field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET1_RX_ER
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET1_RX_ER
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET1_RX_ER
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1854
NXP Semiconductors

<!-- page 1855 -->

32.6.187
SW_PAD_CTL_PAD_ENET2_RX_DATA0 SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_DATA0)
SW_PAD_CTL Register
Address: 20E_0000h base + 370h offset = 20E_0370h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_DATA0 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET2_RX_DATA0
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET2_RX_DATA0
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET2_RX_DATA0
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET2_RX_DATA0
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET2_RX_DATA0
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1855

<!-- page 1856 -->

IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_DATA0 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET2_RX_DATA0
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET2_RX_DATA0
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET2_RX_DATA0
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1856
NXP Semiconductors

<!-- page 1857 -->

32.6.188
SW_PAD_CTL_PAD_ENET2_RX_DATA1 SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_DATA1)
SW_PAD_CTL Register
Address: 20E_0000h base + 374h offset = 20E_0374h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_DATA1 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET2_RX_DATA1
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET2_RX_DATA1
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET2_RX_DATA1
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET2_RX_DATA1
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET2_RX_DATA1
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1857

<!-- page 1858 -->

IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_DATA1 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET2_RX_DATA1
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET2_RX_DATA1
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET2_RX_DATA1
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1858
NXP Semiconductors

<!-- page 1859 -->

32.6.189
SW_PAD_CTL_PAD_ENET2_RX_EN SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_EN)
SW_PAD_CTL Register
Address: 20E_0000h base + 378h offset = 20E_0378h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_EN field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET2_RX_EN
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET2_RX_EN
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET2_RX_EN
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET2_RX_EN
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET2_RX_EN
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1859

<!-- page 1860 -->

IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_EN field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET2_RX_EN
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET2_RX_EN
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET2_RX_EN
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1860
NXP Semiconductors

<!-- page 1861 -->

32.6.190
SW_PAD_CTL_PAD_ENET2_TX_DATA0 SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_DATA0)
SW_PAD_CTL Register
Address: 20E_0000h base + 37Ch offset = 20E_037Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_DATA0 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET2_TX_DATA0
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET2_TX_DATA0
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET2_TX_DATA0
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET2_TX_DATA0
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET2_TX_DATA0
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1861

<!-- page 1862 -->

IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_DATA0 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET2_TX_DATA0
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET2_TX_DATA0
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET2_TX_DATA0
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1862
NXP Semiconductors

<!-- page 1863 -->

32.6.191
SW_PAD_CTL_PAD_ENET2_TX_DATA1 SW PAD
Control Register
(IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_DATA1)
SW_PAD_CTL Register
Address: 20E_0000h base + 380h offset = 20E_0380h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_DATA1 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET2_TX_DATA1
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET2_TX_DATA1
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET2_TX_DATA1
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET2_TX_DATA1
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET2_TX_DATA1
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1863

<!-- page 1864 -->

IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_DATA1 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET2_TX_DATA1
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET2_TX_DATA1
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET2_TX_DATA1
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1864
NXP Semiconductors

<!-- page 1865 -->

32.6.192
SW_PAD_CTL_PAD_ENET2_TX_EN SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_EN)
SW_PAD_CTL Register
Address: 20E_0000h base + 384h offset = 20E_0384h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_EN field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET2_TX_EN
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET2_TX_EN
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET2_TX_EN
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET2_TX_EN
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET2_TX_EN
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1865

<!-- page 1866 -->

IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_EN field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET2_TX_EN
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET2_TX_EN
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET2_TX_EN
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1866
NXP Semiconductors

<!-- page 1867 -->

32.6.193
SW_PAD_CTL_PAD_ENET2_TX_CLK SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_CLK)
SW_PAD_CTL Register
Address: 20E_0000h base + 388h offset = 20E_0388h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_CLK field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET2_TX_CLK
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET2_TX_CLK
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET2_TX_CLK
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET2_TX_CLK
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET2_TX_CLK
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1867

<!-- page 1868 -->

IOMUXC_SW_PAD_CTL_PAD_ENET2_TX_CLK field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET2_TX_CLK
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET2_TX_CLK
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET2_TX_CLK
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1868
NXP Semiconductors

<!-- page 1869 -->

32.6.194
SW_PAD_CTL_PAD_ENET2_RX_ER SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_ER)
SW_PAD_CTL Register
Address: 20E_0000h base + 38Ch offset = 20E_038Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_ER field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: ENET2_RX_ER
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: ENET2_RX_ER
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: ENET2_RX_ER
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: ENET2_RX_ER
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: ENET2_RX_ER
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1869

<!-- page 1870 -->

IOMUXC_SW_PAD_CTL_PAD_ENET2_RX_ER field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: ENET2_RX_ER
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: ENET2_RX_ER
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: ENET2_RX_ER
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1870
NXP Semiconductors

<!-- page 1871 -->

32.6.195
SW_PAD_CTL_PAD_LCD_CLK SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_CLK)
SW_PAD_CTL Register
Address: 20E_0000h base + 390h offset = 20E_0390h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_CLK field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_CLK
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_CLK
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_CLK
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_CLK
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_CLK
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1871

<!-- page 1872 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_CLK field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_CLK
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_CLK
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_CLK
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1872
NXP Semiconductors

<!-- page 1873 -->

32.6.196
SW_PAD_CTL_PAD_LCD_ENABLE SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_ENABLE)
SW_PAD_CTL Register
Address: 20E_0000h base + 394h offset = 20E_0394h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_ENABLE field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_ENABLE
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_ENABLE
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_ENABLE
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_ENABLE
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_ENABLE
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1873

<!-- page 1874 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_ENABLE field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_ENABLE
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_ENABLE
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_ENABLE
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1874
NXP Semiconductors

<!-- page 1875 -->

32.6.197
SW_PAD_CTL_PAD_LCD_HSYNC SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_HSYNC)
SW_PAD_CTL Register
Address: 20E_0000h base + 398h offset = 20E_0398h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_HSYNC field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_HSYNC
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_HSYNC
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_HSYNC
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_HSYNC
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_HSYNC
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1875

<!-- page 1876 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_HSYNC field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_HSYNC
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_HSYNC
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_HSYNC
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1876
NXP Semiconductors

<!-- page 1877 -->

32.6.198
SW_PAD_CTL_PAD_LCD_VSYNC SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_VSYNC)
SW_PAD_CTL Register
Address: 20E_0000h base + 39Ch offset = 20E_039Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_VSYNC field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_VSYNC
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_VSYNC
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_VSYNC
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_VSYNC
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_VSYNC
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1877

<!-- page 1878 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_VSYNC field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_VSYNC
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_VSYNC
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_VSYNC
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1878
NXP Semiconductors

<!-- page 1879 -->

32.6.199
SW_PAD_CTL_PAD_LCD_RESET SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_RESET)
SW_PAD_CTL Register
Address: 20E_0000h base + 3A0h offset = 20E_03A0h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_RESET field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_RESET
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_RESET
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_RESET
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_RESET
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_RESET
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1879

<!-- page 1880 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_RESET field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_RESET
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_RESET
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_RESET
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1880
NXP Semiconductors

<!-- page 1881 -->

32.6.200
SW_PAD_CTL_PAD_LCD_DATA00 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA00)
SW_PAD_CTL Register
Address: 20E_0000h base + 3A4h offset = 20E_03A4h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA00 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA00
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA00
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA00
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA00
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA00
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1881

<!-- page 1882 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA00 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA00
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA00
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA00
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1882
NXP Semiconductors

<!-- page 1883 -->

32.6.201
SW_PAD_CTL_PAD_LCD_DATA01 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA01)
SW_PAD_CTL Register
Address: 20E_0000h base + 3A8h offset = 20E_03A8h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA01 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA01
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA01
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA01
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA01
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA01
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1883

<!-- page 1884 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA01 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA01
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA01
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA01
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1884
NXP Semiconductors

<!-- page 1885 -->

32.6.202
SW_PAD_CTL_PAD_LCD_DATA02 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA02)
SW_PAD_CTL Register
Address: 20E_0000h base + 3ACh offset = 20E_03ACh
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA02 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA02
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA02
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA02
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA02
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA02
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1885

<!-- page 1886 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA02 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA02
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA02
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA02
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1886
NXP Semiconductors

<!-- page 1887 -->

32.6.203
SW_PAD_CTL_PAD_LCD_DATA03 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA03)
SW_PAD_CTL Register
Address: 20E_0000h base + 3B0h offset = 20E_03B0h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA03 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA03
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA03
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA03
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA03
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA03
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1887

<!-- page 1888 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA03 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA03
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA03
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA03
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1888
NXP Semiconductors

<!-- page 1889 -->

32.6.204
SW_PAD_CTL_PAD_LCD_DATA04 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA04)
SW_PAD_CTL Register
Address: 20E_0000h base + 3B4h offset = 20E_03B4h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA04 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA04
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA04
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA04
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA04
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA04
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1889

<!-- page 1890 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA04 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA04
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA04
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA04
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1890
NXP Semiconductors

<!-- page 1891 -->

32.6.205
SW_PAD_CTL_PAD_LCD_DATA05 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA05)
SW_PAD_CTL Register
Address: 20E_0000h base + 3B8h offset = 20E_03B8h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA05 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA05
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA05
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA05
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA05
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA05
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1891

<!-- page 1892 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA05 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA05
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA05
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA05
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1892
NXP Semiconductors

<!-- page 1893 -->

32.6.206
SW_PAD_CTL_PAD_LCD_DATA06 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA06)
SW_PAD_CTL Register
Address: 20E_0000h base + 3BCh offset = 20E_03BCh
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA06 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA06
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA06
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA06
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA06
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA06
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1893

<!-- page 1894 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA06 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA06
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA06
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA06
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1894
NXP Semiconductors

<!-- page 1895 -->

32.6.207
SW_PAD_CTL_PAD_LCD_DATA07 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA07)
SW_PAD_CTL Register
Address: 20E_0000h base + 3C0h offset = 20E_03C0h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA07 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA07
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA07
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA07
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA07
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA07
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1895

<!-- page 1896 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA07 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA07
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA07
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA07
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1896
NXP Semiconductors

<!-- page 1897 -->

32.6.208
SW_PAD_CTL_PAD_LCD_DATA08 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA08)
SW_PAD_CTL Register
Address: 20E_0000h base + 3C4h offset = 20E_03C4h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA08 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA08
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA08
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA08
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA08
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA08
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1897

<!-- page 1898 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA08 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA08
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA08
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA08
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1898
NXP Semiconductors

<!-- page 1899 -->

32.6.209
SW_PAD_CTL_PAD_LCD_DATA09 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA09)
SW_PAD_CTL Register
Address: 20E_0000h base + 3C8h offset = 20E_03C8h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA09 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA09
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA09
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA09
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA09
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA09
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1899

<!-- page 1900 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA09 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA09
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA09
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA09
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1900
NXP Semiconductors

<!-- page 1901 -->

32.6.210
SW_PAD_CTL_PAD_LCD_DATA10 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA10)
SW_PAD_CTL Register
Address: 20E_0000h base + 3CCh offset = 20E_03CCh
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA10 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA10
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA10
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA10
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA10
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA10
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1901

<!-- page 1902 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA10 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA10
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA10
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA10
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1902
NXP Semiconductors

<!-- page 1903 -->

32.6.211
SW_PAD_CTL_PAD_LCD_DATA11 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA11)
SW_PAD_CTL Register
Address: 20E_0000h base + 3D0h offset = 20E_03D0h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA11 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA11
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA11
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA11
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA11
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA11
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1903

<!-- page 1904 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA11 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA11
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA11
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA11
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1904
NXP Semiconductors

<!-- page 1905 -->

32.6.212
SW_PAD_CTL_PAD_LCD_DATA12 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA12)
SW_PAD_CTL Register
Address: 20E_0000h base + 3D4h offset = 20E_03D4h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA12 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA12
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA12
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA12
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA12
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA12
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1905

<!-- page 1906 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA12 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA12
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA12
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA12
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1906
NXP Semiconductors

<!-- page 1907 -->

32.6.213
SW_PAD_CTL_PAD_LCD_DATA13 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA13)
SW_PAD_CTL Register
Address: 20E_0000h base + 3D8h offset = 20E_03D8h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA13 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA13
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA13
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA13
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA13
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA13
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1907

<!-- page 1908 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA13 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA13
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA13
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA13
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1908
NXP Semiconductors

<!-- page 1909 -->

32.6.214
SW_PAD_CTL_PAD_LCD_DATA14 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA14)
SW_PAD_CTL Register
Address: 20E_0000h base + 3DCh offset = 20E_03DCh
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA14 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA14
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA14
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA14
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA14
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA14
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1909

<!-- page 1910 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA14 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA14
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA14
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA14
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1910
NXP Semiconductors

<!-- page 1911 -->

32.6.215
SW_PAD_CTL_PAD_LCD_DATA15 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA15)
SW_PAD_CTL Register
Address: 20E_0000h base + 3E0h offset = 20E_03E0h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA15 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA15
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA15
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA15
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA15
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA15
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1911

<!-- page 1912 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA15 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA15
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA15
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA15
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1912
NXP Semiconductors

<!-- page 1913 -->

32.6.216
SW_PAD_CTL_PAD_LCD_DATA16 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA16)
SW_PAD_CTL Register
Address: 20E_0000h base + 3E4h offset = 20E_03E4h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA16 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA16
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA16
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA16
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA16
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA16
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1913

<!-- page 1914 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA16 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA16
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA16
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA16
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1914
NXP Semiconductors

<!-- page 1915 -->

32.6.217
SW_PAD_CTL_PAD_LCD_DATA17 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA17)
SW_PAD_CTL Register
Address: 20E_0000h base + 3E8h offset = 20E_03E8h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA17 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA17
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA17
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA17
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA17
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA17
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1915

<!-- page 1916 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA17 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA17
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA17
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA17
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1916
NXP Semiconductors

<!-- page 1917 -->

32.6.218
SW_PAD_CTL_PAD_LCD_DATA18 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA18)
SW_PAD_CTL Register
Address: 20E_0000h base + 3ECh offset = 20E_03ECh
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA18 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA18
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA18
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA18
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA18
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA18
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1917

<!-- page 1918 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA18 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA18
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA18
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA18
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1918
NXP Semiconductors

<!-- page 1919 -->

32.6.219
SW_PAD_CTL_PAD_LCD_DATA19 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA19)
SW_PAD_CTL Register
Address: 20E_0000h base + 3F0h offset = 20E_03F0h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA19 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA19
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA19
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA19
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA19
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA19
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1919

<!-- page 1920 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA19 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA19
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA19
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA19
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1920
NXP Semiconductors

<!-- page 1921 -->

32.6.220
SW_PAD_CTL_PAD_LCD_DATA20 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA20)
SW_PAD_CTL Register
Address: 20E_0000h base + 3F4h offset = 20E_03F4h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA20 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA20
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA20
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA20
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA20
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA20
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1921

<!-- page 1922 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA20 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA20
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA20
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA20
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1922
NXP Semiconductors

<!-- page 1923 -->

32.6.221
SW_PAD_CTL_PAD_LCD_DATA21 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA21)
SW_PAD_CTL Register
Address: 20E_0000h base + 3F8h offset = 20E_03F8h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA21 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA21
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA21
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA21
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA21
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA21
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1923

<!-- page 1924 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA21 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA21
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA21
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA21
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1924
NXP Semiconductors

<!-- page 1925 -->

32.6.222
SW_PAD_CTL_PAD_LCD_DATA22 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA22)
SW_PAD_CTL Register
Address: 20E_0000h base + 3FCh offset = 20E_03FCh
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA22 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA22
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA22
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA22
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA22
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA22
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1925

<!-- page 1926 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA22 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA22
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA22
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA22
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1926
NXP Semiconductors

<!-- page 1927 -->

32.6.223
SW_PAD_CTL_PAD_LCD_DATA23 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_LCD_DATA23)
SW_PAD_CTL Register
Address: 20E_0000h base + 400h offset = 20E_0400h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_LCD_DATA23 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: LCD_DATA23
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: LCD_DATA23
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: LCD_DATA23
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: LCD_DATA23
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: LCD_DATA23
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1927

<!-- page 1928 -->

IOMUXC_SW_PAD_CTL_PAD_LCD_DATA23 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: LCD_DATA23
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: LCD_DATA23
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: LCD_DATA23
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1928
NXP Semiconductors

<!-- page 1929 -->

32.6.224
SW_PAD_CTL_PAD_NAND_RE_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_RE_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 404h offset = 20E_0404h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_RE_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_RE_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_RE_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_RE_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_RE_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_RE_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1929

<!-- page 1930 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_RE_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_RE_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_RE_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_RE_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1930
NXP Semiconductors

<!-- page 1931 -->

32.6.225
SW_PAD_CTL_PAD_NAND_WE_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_WE_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 408h offset = 20E_0408h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_WE_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_WE_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_WE_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_WE_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_WE_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_WE_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1931

<!-- page 1932 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_WE_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_WE_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_WE_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_WE_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1932
NXP Semiconductors

<!-- page 1933 -->

32.6.226
SW_PAD_CTL_PAD_NAND_DATA00 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_DATA00)
SW_PAD_CTL Register
Address: 20E_0000h base + 40Ch offset = 20E_040Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_DATA00 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_DATA00
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_DATA00
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_DATA00
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_DATA00
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_DATA00
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1933

<!-- page 1934 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_DATA00 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_DATA00
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_DATA00
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_DATA00
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1934
NXP Semiconductors

<!-- page 1935 -->

32.6.227
SW_PAD_CTL_PAD_NAND_DATA01 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_DATA01)
SW_PAD_CTL Register
Address: 20E_0000h base + 410h offset = 20E_0410h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_DATA01 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_DATA01
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_DATA01
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_DATA01
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_DATA01
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_DATA01
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1935

<!-- page 1936 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_DATA01 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_DATA01
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_DATA01
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_DATA01
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1936
NXP Semiconductors

<!-- page 1937 -->

32.6.228
SW_PAD_CTL_PAD_NAND_DATA02 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_DATA02)
SW_PAD_CTL Register
Address: 20E_0000h base + 414h offset = 20E_0414h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_DATA02 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_DATA02
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_DATA02
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_DATA02
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_DATA02
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_DATA02
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1937

<!-- page 1938 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_DATA02 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_DATA02
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_DATA02
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_DATA02
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1938
NXP Semiconductors

<!-- page 1939 -->

32.6.229
SW_PAD_CTL_PAD_NAND_DATA03 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_DATA03)
SW_PAD_CTL Register
Address: 20E_0000h base + 418h offset = 20E_0418h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_DATA03 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_DATA03
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_DATA03
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_DATA03
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_DATA03
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_DATA03
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1939

<!-- page 1940 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_DATA03 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_DATA03
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_DATA03
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_DATA03
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1940
NXP Semiconductors

<!-- page 1941 -->

32.6.230
SW_PAD_CTL_PAD_NAND_DATA04 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_DATA04)
SW_PAD_CTL Register
Address: 20E_0000h base + 41Ch offset = 20E_041Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_DATA04 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_DATA04
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_DATA04
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_DATA04
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_DATA04
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_DATA04
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1941

<!-- page 1942 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_DATA04 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_DATA04
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_DATA04
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_DATA04
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1942
NXP Semiconductors

<!-- page 1943 -->

32.6.231
SW_PAD_CTL_PAD_NAND_DATA05 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_DATA05)
SW_PAD_CTL Register
Address: 20E_0000h base + 420h offset = 20E_0420h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_DATA05 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_DATA05
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_DATA05
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_DATA05
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_DATA05
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_DATA05
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1943

<!-- page 1944 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_DATA05 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_DATA05
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_DATA05
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_DATA05
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1944
NXP Semiconductors

<!-- page 1945 -->

32.6.232
SW_PAD_CTL_PAD_NAND_DATA06 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_DATA06)
SW_PAD_CTL Register
Address: 20E_0000h base + 424h offset = 20E_0424h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_DATA06 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_DATA06
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_DATA06
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_DATA06
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_DATA06
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_DATA06
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1945

<!-- page 1946 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_DATA06 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_DATA06
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_DATA06
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_DATA06
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1946
NXP Semiconductors

<!-- page 1947 -->

32.6.233
SW_PAD_CTL_PAD_NAND_DATA07 SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_DATA07)
SW_PAD_CTL Register
Address: 20E_0000h base + 428h offset = 20E_0428h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_DATA07 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_DATA07
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_DATA07
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_DATA07
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_DATA07
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_DATA07
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1947

<!-- page 1948 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_DATA07 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_DATA07
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_DATA07
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_DATA07
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1948
NXP Semiconductors

<!-- page 1949 -->

32.6.234
SW_PAD_CTL_PAD_NAND_ALE SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_ALE)
SW_PAD_CTL Register
Address: 20E_0000h base + 42Ch offset = 20E_042Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_ALE field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_ALE
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_ALE
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_ALE
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_ALE
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_ALE
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1949

<!-- page 1950 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_ALE field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_ALE
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_ALE
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_ALE
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1950
NXP Semiconductors

<!-- page 1951 -->

32.6.235
SW_PAD_CTL_PAD_NAND_WP_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_WP_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 430h offset = 20E_0430h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_WP_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_WP_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_WP_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_WP_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_WP_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_WP_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1951

<!-- page 1952 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_WP_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_WP_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_WP_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_WP_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1952
NXP Semiconductors

<!-- page 1953 -->

32.6.236
SW_PAD_CTL_PAD_NAND_READY_B SW PAD Control
Register
(IOMUXC_SW_PAD_CTL_PAD_NAND_READY_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 434h offset = 20E_0434h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_READY_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_READY_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_READY_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_READY_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_READY_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_READY_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1953

<!-- page 1954 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_READY_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_READY_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_READY_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_READY_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1954
NXP Semiconductors

<!-- page 1955 -->

32.6.237
SW_PAD_CTL_PAD_NAND_CE0_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_CE0_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 438h offset = 20E_0438h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_CE0_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_CE0_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_CE0_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_CE0_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_CE0_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_CE0_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1955

<!-- page 1956 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_CE0_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_CE0_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_CE0_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_CE0_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1956
NXP Semiconductors

<!-- page 1957 -->

32.6.238
SW_PAD_CTL_PAD_NAND_CE1_B SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_CE1_B)
SW_PAD_CTL Register
Address: 20E_0000h base + 43Ch offset = 20E_043Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_CE1_B field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_CE1_B
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_CE1_B
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_CE1_B
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_CE1_B
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_CE1_B
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1957

<!-- page 1958 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_CE1_B field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_CE1_B
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_CE1_B
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_CE1_B
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1958
NXP Semiconductors

<!-- page 1959 -->

32.6.239
SW_PAD_CTL_PAD_NAND_CLE SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_CLE)
SW_PAD_CTL Register
Address: 20E_0000h base + 440h offset = 20E_0440h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_CLE field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_CLE
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_CLE
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_CLE
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_CLE
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_CLE
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1959

<!-- page 1960 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_CLE field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_CLE
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_CLE
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_CLE
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1960
NXP Semiconductors

<!-- page 1961 -->

32.6.240
SW_PAD_CTL_PAD_NAND_DQS SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_NAND_DQS)
SW_PAD_CTL Register
Address: 20E_0000h base + 444h offset = 20E_0444h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_NAND_DQS field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: NAND_DQS
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: NAND_DQS
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: NAND_DQS
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: NAND_DQS
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: NAND_DQS
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1961

<!-- page 1962 -->

IOMUXC_SW_PAD_CTL_PAD_NAND_DQS field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: NAND_DQS
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: NAND_DQS
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: NAND_DQS
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1962
NXP Semiconductors

<!-- page 1963 -->

32.6.241
SW_PAD_CTL_PAD_SD1_CMD SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_SD1_CMD)
SW_PAD_CTL Register
Address: 20E_0000h base + 448h offset = 20E_0448h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_SD1_CMD field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SD1_CMD
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SD1_CMD
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SD1_CMD
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SD1_CMD
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SD1_CMD
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1963

<!-- page 1964 -->

IOMUXC_SW_PAD_CTL_PAD_SD1_CMD field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: SD1_CMD
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SD1_CMD
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SD1_CMD
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1964
NXP Semiconductors

<!-- page 1965 -->

32.6.242
SW_PAD_CTL_PAD_SD1_CLK SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_SD1_CLK)
SW_PAD_CTL Register
Address: 20E_0000h base + 44Ch offset = 20E_044Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_SD1_CLK field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SD1_CLK
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SD1_CLK
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SD1_CLK
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SD1_CLK
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SD1_CLK
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1965

<!-- page 1966 -->

IOMUXC_SW_PAD_CTL_PAD_SD1_CLK field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: SD1_CLK
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SD1_CLK
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SD1_CLK
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1966
NXP Semiconductors

<!-- page 1967 -->

32.6.243
SW_PAD_CTL_PAD_SD1_DATA0 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_SD1_DATA0)
SW_PAD_CTL Register
Address: 20E_0000h base + 450h offset = 20E_0450h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_SD1_DATA0 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SD1_DATA0
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SD1_DATA0
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SD1_DATA0
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SD1_DATA0
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SD1_DATA0
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1967

<!-- page 1968 -->

IOMUXC_SW_PAD_CTL_PAD_SD1_DATA0 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: SD1_DATA0
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SD1_DATA0
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SD1_DATA0
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1968
NXP Semiconductors

<!-- page 1969 -->

32.6.244
SW_PAD_CTL_PAD_SD1_DATA1 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_SD1_DATA1)
SW_PAD_CTL Register
Address: 20E_0000h base + 454h offset = 20E_0454h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_SD1_DATA1 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SD1_DATA1
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SD1_DATA1
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SD1_DATA1
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SD1_DATA1
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SD1_DATA1
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1969

<!-- page 1970 -->

IOMUXC_SW_PAD_CTL_PAD_SD1_DATA1 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: SD1_DATA1
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SD1_DATA1
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SD1_DATA1
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1970
NXP Semiconductors

<!-- page 1971 -->

32.6.245
SW_PAD_CTL_PAD_SD1_DATA2 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_SD1_DATA2)
SW_PAD_CTL Register
Address: 20E_0000h base + 458h offset = 20E_0458h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_SD1_DATA2 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SD1_DATA2
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SD1_DATA2
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SD1_DATA2
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SD1_DATA2
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SD1_DATA2
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1971

<!-- page 1972 -->

IOMUXC_SW_PAD_CTL_PAD_SD1_DATA2 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: SD1_DATA2
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SD1_DATA2
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SD1_DATA2
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1972
NXP Semiconductors

<!-- page 1973 -->

32.6.246
SW_PAD_CTL_PAD_SD1_DATA3 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_SD1_DATA3)
SW_PAD_CTL Register
Address: 20E_0000h base + 45Ch offset = 20E_045Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_SD1_DATA3 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: SD1_DATA3
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: SD1_DATA3
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: SD1_DATA3
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: SD1_DATA3
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: SD1_DATA3
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1973

<!-- page 1974 -->

IOMUXC_SW_PAD_CTL_PAD_SD1_DATA3 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: SD1_DATA3
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: SD1_DATA3
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: SD1_DATA3
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1974
NXP Semiconductors

<!-- page 1975 -->

32.6.247
SW_PAD_CTL_PAD_CSI_MCLK SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_MCLK)
SW_PAD_CTL Register
Address: 20E_0000h base + 460h offset = 20E_0460h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_MCLK field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_MCLK
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_MCLK
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_MCLK
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_MCLK
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_MCLK
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1975

<!-- page 1976 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_MCLK field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_MCLK
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_MCLK
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_MCLK
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1976
NXP Semiconductors

<!-- page 1977 -->

32.6.248
SW_PAD_CTL_PAD_CSI_PIXCLK SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_PIXCLK)
SW_PAD_CTL Register
Address: 20E_0000h base + 464h offset = 20E_0464h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_PIXCLK field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_PIXCLK
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_PIXCLK
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_PIXCLK
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_PIXCLK
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_PIXCLK
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1977

<!-- page 1978 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_PIXCLK field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_PIXCLK
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_PIXCLK
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_PIXCLK
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1978
NXP Semiconductors

<!-- page 1979 -->

32.6.249
SW_PAD_CTL_PAD_CSI_VSYNC SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_VSYNC)
SW_PAD_CTL Register
Address: 20E_0000h base + 468h offset = 20E_0468h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_VSYNC field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_VSYNC
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_VSYNC
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_VSYNC
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_VSYNC
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_VSYNC
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1979

<!-- page 1980 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_VSYNC field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_VSYNC
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_VSYNC
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_VSYNC
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1980
NXP Semiconductors

<!-- page 1981 -->

32.6.250
SW_PAD_CTL_PAD_CSI_HSYNC SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_HSYNC)
SW_PAD_CTL Register
Address: 20E_0000h base + 46Ch offset = 20E_046Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_HSYNC field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_HSYNC
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_HSYNC
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_HSYNC
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_HSYNC
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_HSYNC
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1981

<!-- page 1982 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_HSYNC field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_HSYNC
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_HSYNC
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_HSYNC
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1982
NXP Semiconductors

<!-- page 1983 -->

32.6.251
SW_PAD_CTL_PAD_CSI_DATA00 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA00)
SW_PAD_CTL Register
Address: 20E_0000h base + 470h offset = 20E_0470h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_DATA00 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_DATA00
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_DATA00
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_DATA00
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_DATA00
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_DATA00
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1983

<!-- page 1984 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_DATA00 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_DATA00
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_DATA00
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_DATA00
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1984
NXP Semiconductors

<!-- page 1985 -->

32.6.252
SW_PAD_CTL_PAD_CSI_DATA01 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA01)
SW_PAD_CTL Register
Address: 20E_0000h base + 474h offset = 20E_0474h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_DATA01 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_DATA01
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_DATA01
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_DATA01
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_DATA01
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_DATA01
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1985

<!-- page 1986 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_DATA01 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_DATA01
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_DATA01
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_DATA01
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1986
NXP Semiconductors

<!-- page 1987 -->

32.6.253
SW_PAD_CTL_PAD_CSI_DATA02 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA02)
SW_PAD_CTL Register
Address: 20E_0000h base + 478h offset = 20E_0478h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_DATA02 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_DATA02
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_DATA02
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_DATA02
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_DATA02
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_DATA02
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1987

<!-- page 1988 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_DATA02 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_DATA02
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_DATA02
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_DATA02
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1988
NXP Semiconductors

<!-- page 1989 -->

32.6.254
SW_PAD_CTL_PAD_CSI_DATA03 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA03)
SW_PAD_CTL Register
Address: 20E_0000h base + 47Ch offset = 20E_047Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_DATA03 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_DATA03
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_DATA03
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_DATA03
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_DATA03
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_DATA03
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1989

<!-- page 1990 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_DATA03 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_DATA03
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_DATA03
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_DATA03
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1990
NXP Semiconductors

<!-- page 1991 -->

32.6.255
SW_PAD_CTL_PAD_CSI_DATA04 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA04)
SW_PAD_CTL Register
Address: 20E_0000h base + 480h offset = 20E_0480h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_DATA04 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_DATA04
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_DATA04
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_DATA04
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_DATA04
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_DATA04
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1991

<!-- page 1992 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_DATA04 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_DATA04
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_DATA04
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_DATA04
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1992
NXP Semiconductors

<!-- page 1993 -->

32.6.256
SW_PAD_CTL_PAD_CSI_DATA05 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA05)
SW_PAD_CTL Register
Address: 20E_0000h base + 484h offset = 20E_0484h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_DATA05 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_DATA05
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_DATA05
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_DATA05
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_DATA05
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_DATA05
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1993

<!-- page 1994 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_DATA05 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_DATA05
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_DATA05
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_DATA05
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1994
NXP Semiconductors

<!-- page 1995 -->

32.6.257
SW_PAD_CTL_PAD_CSI_DATA06 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA06)
SW_PAD_CTL Register
Address: 20E_0000h base + 488h offset = 20E_0488h
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_DATA06 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_DATA06
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_DATA06
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_DATA06
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_DATA06
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_DATA06
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1995

<!-- page 1996 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_DATA06 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_DATA06
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_DATA06
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_DATA06
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1996
NXP Semiconductors

<!-- page 1997 -->

32.6.258
SW_PAD_CTL_PAD_CSI_DATA07 SW PAD Control
Register (IOMUXC_SW_PAD_CTL_PAD_CSI_DATA07)
SW_PAD_CTL Register
Address: 20E_0000h base + 48Ch offset = 20E_048Ch
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
HYS
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
PUS
PUE
PKE
ODE
Reserved
SPEED
DSE
Reserved
SRE
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
1
0
1
1
0
0
0
0
IOMUXC_SW_PAD_CTL_PAD_CSI_DATA07 field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for pad: CSI_DATA07
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
15–14
PUS
Pull Up / Down Config. Field
Select one out of next values for pad: CSI_DATA07
00
PUS_0_100K_Ohm_Pull_Down — 100K Ohm Pull Down
01
PUS_1_47K_Ohm_Pull_Up — 47K Ohm Pull Up
10
PUS_2_100K_Ohm_Pull_Up — 100K Ohm Pull Up
11
PUS_3_22K_Ohm_Pull_Up — 22K Ohm Pull Up
13
PUE
Pull / Keep Select Field
Select one out of next values for pad: CSI_DATA07
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
12
PKE
Pull / Keep Enable Field
Select one out of next values for pad: CSI_DATA07
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
11
ODE
Open Drain Enable Field
Select one out of next values for pad: CSI_DATA07
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1997

<!-- page 1998 -->

IOMUXC_SW_PAD_CTL_PAD_CSI_DATA07 field descriptions (continued)
Field
Description
0
ODE_0_Open_Drain_Disabled — Open Drain Disabled
1
ODE_1_Open_Drain_Enabled — Open Drain Enabled
10–8
-
This field is reserved.
Reserved
7–6
SPEED
Speed Field
Select one out of next values for pad: CSI_DATA07
00
SPEED_0_low_50MHz_ — low(50MHz)
01
SPEED_1_medium_100MHz_ — medium(100MHz)
10
SPEED_2_medium_100MHz_ — medium(100MHz)
11
SPEED_3_max_200MHz_ — max(200MHz)
5–3
DSE
Drive Strength Field
Select one out of next values for pad: CSI_DATA07
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
2–1
-
This field is reserved.
Reserved
0
SRE
Slew Rate Field
Select one out of next values for pad: CSI_DATA07
0
SRE_0_Slow_Slew_Rate — Slow Slew Rate
1
SRE_1_Fast_Slew_Rate — Fast Slew Rate
32.6.259
SW_PAD_CTL_GRP_ADDDS SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_ADDDS)
SW_GRP Register
Address: 20E_0000h base + 490h offset = 20E_0490h
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
Reserved
DSE
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
0
0
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
0
0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1998
NXP Semiconductors

<!-- page 1999 -->

IOMUXC_SW_PAD_CTL_GRP_ADDDS field descriptions
Field
Description
31–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for group: ADDDS (Pads: DRAM_ADDR00 DRAM_ADDR01
DRAM_ADDR02 DRAM_ADDR03 DRAM_ADDR04 DRAM_ADDR05 DRAM_ADDR06 DRAM_ADDR07
DRAM_ADDR08 DRAM_ADDR09 DRAM_ADDR10 DRAM_ADDR11 DRAM_ADDR12 DRAM_ADDR13
DRAM_ADDR14 DRAM_ADDR15 DRAM_SDBA0 DRAM_SDBA1)
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
32.6.260
SW_PAD_CTL_GRP_DDRMODE_CTL SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDRMODE_CTL)
SW_GRP Register
Address: 20E_0000h base + 494h offset = 20E_0494h
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
DDR_INPUT
Reserv
ed
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1999

<!-- page 2000 -->

IOMUXC_SW_PAD_CTL_GRP_DDRMODE_CTL field descriptions
Field
Description
31–18
-
This field is reserved.
Reserved
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for group: DDRMODE_CTL (Pads: DRAM_SDQS0_P DRAM_SDQS1_P)
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
-
This field is reserved.
Reserved
32.6.261
SW_PAD_CTL_GRP_B0DS SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_B0DS)
SW_GRP Register
Address: 20E_0000h base + 498h offset = 20E_0498h
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
Reserved
DSE
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
0
0
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
0
0
IOMUXC_SW_PAD_CTL_GRP_B0DS field descriptions
Field
Description
31–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for group: B0DS (Pads: DRAM_DATA00 DRAM_DATA01 DRAM_DATA02
DRAM_DATA03 DRAM_DATA04 DRAM_DATA05 DRAM_DATA06 DRAM_DATA07)
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2000
NXP Semiconductors

<!-- page 2001 -->

32.6.262
SW_PAD_CTL_GRP_DDRPK SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDRPK)
SW_GRP Register
Address: 20E_0000h base + 49Ch offset = 20E_049Ch
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
PUE
Reserved
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
IOMUXC_SW_PAD_CTL_GRP_DDRPK field descriptions
Field
Description
31–14
-
This field is reserved.
Reserved
13
PUE
Pull / Keep Select Field
Select one out of next values for group: DDRPK (Pads: DRAM_ADDR00 DRAM_ADDR01
DRAM_ADDR02 DRAM_ADDR03 DRAM_ADDR04 DRAM_ADDR05 DRAM_ADDR06 DRAM_ADDR07
DRAM_ADDR08 DRAM_ADDR09 DRAM_ADDR10 DRAM_ADDR11 DRAM_ADDR12 DRAM_ADDR13
DRAM_ADDR14 DRAM_ADDR15 DRAM_CAS_B DRAM_CS0_B DRAM_CS1_B DRAM_DATA00
DRAM_DATA01 DRAM_DATA02 DRAM_DATA03 DRAM_DATA04 DRAM_DATA05 DRAM_DATA06
DRAM_DATA07 DRAM_DATA08 DRAM_DATA09 DRAM_DATA10 DRAM_DATA11 DRAM_DATA12
DRAM_DATA13 DRAM_DATA14 DRAM_DATA15 DRAM_DQM0 DRAM_DQM1 DRAM_RAS_B
DRAM_SDBA0 DRAM_SDBA1 DRAM_SDCLK0_P DRAM_SDWE_B)
0
PUE_0_Keeper — Keeper
1
PUE_1_Pull — Pull
-
This field is reserved.
Reserved
32.6.263
SW_PAD_CTL_GRP_CTLDS SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_CTLDS)
SW_GRP Register
Address: 20E_0000h base + 4A0h offset = 20E_04A0h
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
Reserved
DSE
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
0
0
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
0
0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2001

<!-- page 2002 -->

IOMUXC_SW_PAD_CTL_GRP_CTLDS field descriptions
Field
Description
31–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for group: CTLDS (Pads: DRAM_CS0_B DRAM_CS1_B DRAM_SDBA2
DRAM_SDCKE0 DRAM_SDCKE1 DRAM_SDWE_B)
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
32.6.264
SW_PAD_CTL_GRP_B1DS SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_B1DS)
SW_GRP Register
Address: 20E_0000h base + 4A4h offset = 20E_04A4h
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
Reserved
DSE
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
0
0
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
0
0
IOMUXC_SW_PAD_CTL_GRP_B1DS field descriptions
Field
Description
31–6
-
This field is reserved.
Reserved
5–3
DSE
Drive Strength Field
Select one out of next values for group: B1DS (Pads: DRAM_DATA08 DRAM_DATA09 DRAM_DATA10
DRAM_DATA11 DRAM_DATA12 DRAM_DATA13 DRAM_DATA14 DRAM_DATA15)
000
DSE_0_output_driver_disabled_ — output driver disabled;
001
DSE_1_R0_260_Ohm___3_3V__150_Ohm_1_8V__240_Ohm_for_DDR_ — R0(260 Ohm @
3.3V, 150 Ohm@1.8V, 240 Ohm for DDR)
010
DSE_2_R0_2 — R0/2
011
DSE_3_R0_3 — R0/3
100
DSE_4_R0_4 — R0/4
Table continues on the next page...
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2002
NXP Semiconductors

<!-- page 2003 -->

IOMUXC_SW_PAD_CTL_GRP_B1DS field descriptions (continued)
Field
Description
101
DSE_5_R0_5 — R0/5
110
DSE_6_R0_6 — R0/6
111
DSE_7_R0_7 — R0/7
-
This field is reserved.
Reserved
32.6.265
SW_PAD_CTL_GRP_DDRHYS SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDRHYS)
SW_GRP Register
Address: 20E_0000h base + 4A8h offset = 20E_04A8h
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
HYS
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
IOMUXC_SW_PAD_CTL_GRP_DDRHYS field descriptions
Field
Description
31–17
-
This field is reserved.
Reserved
16
HYS
Hyst. Enable Field
Select one out of next values for group: DDRHYS (Pads: DRAM_DATA00 DRAM_DATA01
DRAM_DATA02 DRAM_DATA03 DRAM_DATA04 DRAM_DATA05 DRAM_DATA06 DRAM_DATA07
DRAM_DATA08 DRAM_DATA09 DRAM_DATA10 DRAM_DATA11 DRAM_DATA12 DRAM_DATA13
DRAM_DATA14 DRAM_DATA15 DRAM_SDQS0_P DRAM_SDQS1_P)
0
HYS_0_Hysteresis_Disabled — Hysteresis Disabled
1
HYS_1_Hysteresis_Enabled — Hysteresis Enabled
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2003

<!-- page 2004 -->

32.6.266
SW_PAD_CTL_GRP_DDRPKE SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDRPKE)
SW_GRP Register
Address: 20E_0000h base + 4ACh offset = 20E_04ACh
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
PKE
Reserved
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
0
IOMUXC_SW_PAD_CTL_GRP_DDRPKE field descriptions
Field
Description
31–13
-
This field is reserved.
Reserved
12
PKE
Pull / Keep Enable Field
Select one out of next values for group: DDRPKE (Pads: DRAM_ADDR00 DRAM_ADDR01
DRAM_ADDR02 DRAM_ADDR03 DRAM_ADDR04 DRAM_ADDR05 DRAM_ADDR06 DRAM_ADDR07
DRAM_ADDR08 DRAM_ADDR09 DRAM_ADDR10 DRAM_ADDR11 DRAM_ADDR12 DRAM_ADDR13
DRAM_ADDR14 DRAM_ADDR15 DRAM_CAS_B DRAM_CS0_B DRAM_CS1_B DRAM_DATA00
DRAM_DATA01 DRAM_DATA02 DRAM_DATA03 DRAM_DATA04 DRAM_DATA05 DRAM_DATA06
DRAM_DATA07 DRAM_DATA08 DRAM_DATA09 DRAM_DATA10 DRAM_DATA11 DRAM_DATA12
DRAM_DATA13 DRAM_DATA14 DRAM_DATA15 DRAM_DQM0 DRAM_DQM1 DRAM_RAS_B
DRAM_SDBA0 DRAM_SDBA1 DRAM_SDCLK0_P DRAM_SDWE_B)
0
PKE_0_Pull_Keeper_Disabled — Pull/Keeper Disabled
1
PKE_1_Pull_Keeper_Enabled — Pull/Keeper Enabled
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2004
NXP Semiconductors

<!-- page 2005 -->

32.6.267
SW_PAD_CTL_GRP_DDRMODE SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDRMODE)
SW_GRP Register
Address: 20E_0000h base + 4B0h offset = 20E_04B0h
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
DDR_INPUT
Reserv
ed
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
IOMUXC_SW_PAD_CTL_GRP_DDRMODE field descriptions
Field
Description
31–18
-
This field is reserved.
Reserved
17
DDR_INPUT
DDR / CMOS Input Mode Field
Select one out of next values for group: DDRMODE (Pads: DRAM_DATA00 DRAM_DATA01
DRAM_DATA02 DRAM_DATA03 DRAM_DATA04 DRAM_DATA05 DRAM_DATA06 DRAM_DATA07
DRAM_DATA08 DRAM_DATA09 DRAM_DATA10 DRAM_DATA11 DRAM_DATA12 DRAM_DATA13
DRAM_DATA14 DRAM_DATA15)
0
DDR_INPUT_0_CMOS_input_type — CMOS input type
1
DDR_INPUT_1_Differential_input_mode — Differential input mode
-
This field is reserved.
Reserved
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2005

<!-- page 2006 -->

32.6.268
SW_PAD_CTL_GRP_DDR_TYPE SW GRP Register
(IOMUXC_SW_PAD_CTL_GRP_DDR_TYPE)
SW_GRP Register
Address: 20E_0000h base + 4B4h offset = 20E_04B4h
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
DDR_SEL
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
IOMUXC_SW_PAD_CTL_GRP_DDR_TYPE field descriptions
Field
Description
31–20
-
This field is reserved.
Reserved
19–18
DDR_SEL
ddr_sel Field
Select one out of next values for group: DDR_TYPE (Pads: DRAM_ADDR00 DRAM_ADDR01
DRAM_ADDR02 DRAM_ADDR03 DRAM_ADDR04 DRAM_ADDR05 DRAM_ADDR06 DRAM_ADDR07
DRAM_ADDR08 DRAM_ADDR09 DRAM_ADDR10 DRAM_ADDR11 DRAM_ADDR12 DRAM_ADDR13
DRAM_ADDR14 DRAM_ADDR15 DRAM_CAS_B DRAM_CS0_B DRAM_CS1_B DRAM_DATA00
DRAM_DATA01 DRAM_DATA02 DRAM_DATA03 DRAM_DATA04 DRAM_DATA05 DRAM_DATA06
DRAM_DATA07 DRAM_DATA08 DRAM_DATA09 DRAM_DATA10 DRAM_DATA11 DRAM_DATA12
DRAM_DATA13 DRAM_DATA14 DRAM_DATA15 DRAM_DQM0 DRAM_DQM1 DRAM_ODT0
DRAM_ODT1 DRAM_RAS_B DRAM_SDBA0 DRAM_SDBA1 DRAM_SDBA2 DRAM_SDCKE0
DRAM_SDCKE1 DRAM_SDCLK0_P DRAM_SDQS0_P DRAM_SDQS1_P DRAM_SDWE_B)
00
DDR_SEL_0_RESERVED — RESERVED
01
DDR_SEL_1_RESERVED — RESERVED
10
DDR_SEL_2_LPDDR2_mode — LPDDR2 mode
11
DDR_SEL_3_DDR3_mode — DDR3 mode
-
This field is reserved.
Reserved
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2006
NXP Semiconductors

<!-- page 2007 -->

32.6.269
USB_OTG1_ID_SELECT_INPUT DAISY Register
(IOMUXC_ANATOP_USB_OTG_ID_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4B8h offset = 20E_04B8h
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
DAISY
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
IOMUXC_ANATOP_USB_OTG_ID_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: anatop, In Pin: usb_otg_id
00
GPIO1_IO00_ALT2 — Selecting Pad: GPIO1_IO00 for Mode: ALT2
01
UART3_TX_DATA_ALT8 — Selecting Pad: UART3_TX_DATA for Mode: ALT8
10
SD1_DATA0_ALT8 — Selecting Pad: SD1_DATA0 for Mode: ALT8
32.6.270
USB_OTG2_ID_SELECT_INPUT DAISY Register
(IOMUXC_USB_OTG2_ID_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4BCh offset = 20E_04BCh
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2007

<!-- page 2008 -->

IOMUXC_USB_OTG2_ID_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: anatop, In Pin: usb_uh1_id
00
GPIO1_IO05_ALT2 — Selecting Pad: GPIO1_IO05 for Mode: ALT2
01
ENET2_TX_CLK_ALT8 — Selecting Pad: ENET2_TX_CLK for Mode: ALT8
10
SD1_DATA3_ALT8 — Selecting Pad: SD1_DATA3 for Mode: ALT8
32.6.271
CCM_PMIC_READY_SELECT_INPUT DAISY Register
(IOMUXC_CCM_PMIC_READY_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4C0h offset = 20E_04C0h
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
DAISY
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
IOMUXC_CCM_PMIC_READY_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ccm, In Pin: pmic_ready
0
JTAG_MOD_ALT4 — Selecting Pad: JTAG_MOD for Mode: ALT4
1
GPIO1_IO08_ALT6 — Selecting Pad: GPIO1_IO08 for Mode: ALT6
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2008
NXP Semiconductors

<!-- page 2009 -->

32.6.272
CSI_DATA02_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA02_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4C4h offset = 20E_04C4h
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
DAISY
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
IOMUXC_CSI_DATA02_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d2
0
CSI_DATA00_ALT0 — Selecting Pad: CSI_DATA00 for Mode: ALT0
1
UART1_TX_DATA_ALT3 — Selecting Pad: UART1_TX_DATA for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2009

<!-- page 2010 -->

32.6.273
CSI_DATA03_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA03_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4C8h offset = 20E_04C8h
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
DAISY
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
IOMUXC_CSI_DATA03_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d3
0
CSI_DATA01_ALT0 — Selecting Pad: CSI_DATA01 for Mode: ALT0
1
UART1_RX_DATA_ALT3 — Selecting Pad: UART1_RX_DATA for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2010
NXP Semiconductors

<!-- page 2011 -->

32.6.274
CSI_DATA05_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA05_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4CCh offset = 20E_04CCh
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
DAISY
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
IOMUXC_CSI_DATA05_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d5
0
CSI_DATA03_ALT0 — Selecting Pad: CSI_DATA03 for Mode: ALT0
1
UART1_RTS_B_ALT3 — Selecting Pad: UART1_RTS_B for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2011

<!-- page 2012 -->

32.6.275
CSI_DATA00_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA00_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4D0h offset = 20E_04D0h
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
DAISY
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
IOMUXC_CSI_DATA00_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d0
0
UART3_RX_DATA_ALT3 — Selecting Pad: UART3_RX_DATA for Mode: ALT3
1
LCD_DATA17_ALT3 — Selecting Pad: LCD_DATA17 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2012
NXP Semiconductors

<!-- page 2013 -->

32.6.276
CSI_DATA01_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA01_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4D4h offset = 20E_04D4h
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
DAISY
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
IOMUXC_CSI_DATA01_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d1
0
UART3_TX_DATA_ALT3 — Selecting Pad: UART3_TX_DATA for Mode: ALT3
1
LCD_DATA16_ALT3 — Selecting Pad: LCD_DATA16 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2013

<!-- page 2014 -->

32.6.277
CSI_DATA04_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA04_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4D8h offset = 20E_04D8h
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
DAISY
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
IOMUXC_CSI_DATA04_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d4
0
UART1_CTS_B_ALT3 — Selecting Pad: UART1_CTS_B for Mode: ALT3
1
CSI_DATA02_ALT0 — Selecting Pad: CSI_DATA02 for Mode: ALT0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2014
NXP Semiconductors

<!-- page 2015 -->

32.6.278
CSI_DATA06_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA06_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4DCh offset = 20E_04DCh
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
DAISY
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
IOMUXC_CSI_DATA06_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d6
0
UART2_TX_DATA_ALT3 — Selecting Pad: UART2_TX_DATA for Mode: ALT3
1
CSI_DATA04_ALT0 — Selecting Pad: CSI_DATA04 for Mode: ALT0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2015

<!-- page 2016 -->

32.6.279
CSI_DATA07_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA07_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4E0h offset = 20E_04E0h
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
DAISY
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
IOMUXC_CSI_DATA07_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d7
0
UART2_RX_DATA_ALT3 — Selecting Pad: UART2_RX_DATA for Mode: ALT3
1
CSI_DATA05_ALT0 — Selecting Pad: CSI_DATA05 for Mode: ALT0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2016
NXP Semiconductors

<!-- page 2017 -->

32.6.280
CSI_DATA08_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA08_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4E4h offset = 20E_04E4h
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
DAISY
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
IOMUXC_CSI_DATA08_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d8
0
UART2_CTS_B_ALT3 — Selecting Pad: UART2_CTS_B for Mode: ALT3
1
CSI_DATA06_ALT0 — Selecting Pad: CSI_DATA06 for Mode: ALT0
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2017

<!-- page 2018 -->

32.6.281
CSI_DATA09_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA09_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4E8h offset = 20E_04E8h
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
DAISY
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
IOMUXC_CSI_DATA09_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d9
0
UART2_RTS_B_ALT3 — Selecting Pad: UART2_RTS_B for Mode: ALT3
1
CSI_DATA07_ALT0 — Selecting Pad: CSI_DATA07 for Mode: ALT0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2018
NXP Semiconductors

<!-- page 2019 -->

32.6.282
CSI_DATA10_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA10_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4ECh offset = 20E_04ECh
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
DAISY
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
IOMUXC_CSI_DATA10_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d10
0
UART3_CTS_B_ALT3 — Selecting Pad: UART3_CTS_B for Mode: ALT3
1
LCD_DATA18_ALT3 — Selecting Pad: LCD_DATA18 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2019

<!-- page 2020 -->

32.6.283
CSI_DATA11_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA11_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4F0h offset = 20E_04F0h
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
DAISY
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
IOMUXC_CSI_DATA11_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d11
0
UART3_RTS_B_ALT3 — Selecting Pad: UART3_RTS_B for Mode: ALT3
1
LCD_DATA19_ALT3 — Selecting Pad: LCD_DATA19 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2020
NXP Semiconductors

<!-- page 2021 -->

32.6.284
CSI_DATA12_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA12_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4F4h offset = 20E_04F4h
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
DAISY
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
IOMUXC_CSI_DATA12_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d12
0
UART4_TX_DATA_ALT3 — Selecting Pad: UART4_TX_DATA for Mode: ALT3
1
LCD_DATA20_ALT3 — Selecting Pad: LCD_DATA20 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2021

<!-- page 2022 -->

32.6.285
CSI_DATA13_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA13_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4F8h offset = 20E_04F8h
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
DAISY
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
IOMUXC_CSI_DATA13_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d13
0
UART4_RX_DATA_ALT3 — Selecting Pad: UART4_RX_DATA for Mode: ALT3
1
LCD_DATA21_ALT3 — Selecting Pad: LCD_DATA21 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2022
NXP Semiconductors

<!-- page 2023 -->

32.6.286
CSI_DATA14_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA14_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 4FCh offset = 20E_04FCh
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
DAISY
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
IOMUXC_CSI_DATA14_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d14
0
UART5_TX_DATA_ALT3 — Selecting Pad: UART5_TX_DATA for Mode: ALT3
1
LCD_DATA22_ALT3 — Selecting Pad: LCD_DATA22 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2023

<!-- page 2024 -->

32.6.287
CSI_DATA15_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA15_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 500h offset = 20E_0500h
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
DAISY
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
IOMUXC_CSI_DATA15_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d15
0
UART5_RX_DATA_ALT3 — Selecting Pad: UART5_RX_DATA for Mode: ALT3
1
LCD_DATA23_ALT3 — Selecting Pad: LCD_DATA23 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2024
NXP Semiconductors

<!-- page 2025 -->

32.6.288
CSI_DATA16_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA16_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 504h offset = 20E_0504h
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
DAISY
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
IOMUXC_CSI_DATA16_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d16
0
ENET1_RX_DATA0_ALT3 — Selecting Pad: ENET1_RX_DATA0 for Mode: ALT3
1
LCD_DATA08_ALT3 — Selecting Pad: LCD_DATA08 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2025

<!-- page 2026 -->

32.6.289
CSI_DATA17_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA17_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 508h offset = 20E_0508h
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
DAISY
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
IOMUXC_CSI_DATA17_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d17
0
ENET1_RX_DATA1_ALT3 — Selecting Pad: ENET1_RX_DATA1 for Mode: ALT3
1
LCD_DATA09_ALT3 — Selecting Pad: LCD_DATA09 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2026
NXP Semiconductors

<!-- page 2027 -->

32.6.290
CSI_DATA18_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA18_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 50Ch offset = 20E_050Ch
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
DAISY
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
IOMUXC_CSI_DATA18_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d18
0
ENET1_RX_EN_ALT3 — Selecting Pad: ENET1_RX_EN for Mode: ALT3
1
LCD_DATA10_ALT3 — Selecting Pad: LCD_DATA10 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2027

<!-- page 2028 -->

32.6.291
CSI_DATA19_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA19_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 510h offset = 20E_0510h
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
DAISY
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
IOMUXC_CSI_DATA19_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d19
0
ENET1_TX_DATA0_ALT3 — Selecting Pad: ENET1_TX_DATA0 for Mode: ALT3
1
LCD_DATA11_ALT3 — Selecting Pad: LCD_DATA11 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2028
NXP Semiconductors

<!-- page 2029 -->

32.6.292
CSI_DATA20_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA20_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 514h offset = 20E_0514h
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
DAISY
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
IOMUXC_CSI_DATA20_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d20
0
ENET1_TX_DATA1_ALT3 — Selecting Pad: ENET1_TX_DATA1 for Mode: ALT3
1
LCD_DATA12_ALT3 — Selecting Pad: LCD_DATA12 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2029

<!-- page 2030 -->

32.6.293
CSI_DATA21_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA21_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 518h offset = 20E_0518h
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
DAISY
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
IOMUXC_CSI_DATA21_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d21
0
ENET1_TX_EN_ALT3 — Selecting Pad: ENET1_TX_EN for Mode: ALT3
1
LCD_DATA13_ALT3 — Selecting Pad: LCD_DATA13 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2030
NXP Semiconductors

<!-- page 2031 -->

32.6.294
CSI_DATA22_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA22_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 51Ch offset = 20E_051Ch
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
DAISY
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
IOMUXC_CSI_DATA22_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d22
0
ENET1_TX_CLK_ALT3 — Selecting Pad: ENET1_TX_CLK for Mode: ALT3
1
LCD_DATA14_ALT3 — Selecting Pad: LCD_DATA14 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2031

<!-- page 2032 -->

32.6.295
CSI_DATA23_SELECT_INPUT DAISY Register
(IOMUXC_CSI_DATA23_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 520h offset = 20E_0520h
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
DAISY
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
IOMUXC_CSI_DATA23_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_d23
0
ENET1_RX_ER_ALT3 — Selecting Pad: ENET1_RX_ER for Mode: ALT3
1
LCD_DATA15_ALT3 — Selecting Pad: LCD_DATA15 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2032
NXP Semiconductors

<!-- page 2033 -->

32.6.296
CSI_HSYNC_SELECT_INPUT DAISY Register
(IOMUXC_CSI_HSYNC_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 524h offset = 20E_0524h
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
DAISY
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
IOMUXC_CSI_HSYNC_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_hsync
0
CSI_HSYNC_ALT0 — Selecting Pad: CSI_HSYNC for Mode: ALT0
1
GPIO1_IO09_ALT3 — Selecting Pad: GPIO1_IO09 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2033

<!-- page 2034 -->

32.6.297
CSI_PIXCLK_SELECT_INPUT DAISY Register
(IOMUXC_CSI_PIXCLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 528h offset = 20E_0528h
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
DAISY
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
IOMUXC_CSI_PIXCLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_pixclk
0
GPIO1_IO07_ALT3 — Selecting Pad: GPIO1_IO07 for Mode: ALT3
1
CSI_PIXCLK_ALT0 — Selecting Pad: CSI_PIXCLK for Mode: ALT0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2034
NXP Semiconductors

<!-- page 2035 -->

32.6.298
CSI_VSYNC_SELECT_INPUT DAISY Register
(IOMUXC_CSI_VSYNC_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 52Ch offset = 20E_052Ch
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
DAISY
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
IOMUXC_CSI_VSYNC_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: csi_vsync
0
CSI_VSYNC_ALT0 — Selecting Pad: CSI_VSYNC for Mode: ALT0
1
GPIO1_IO08_ALT3 — Selecting Pad: GPIO1_IO08 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2035

<!-- page 2036 -->

32.6.299
CSI_FIELD_SELECT_INPUT DAISY Register
(IOMUXC_CSI_FIELD_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 530h offset = 20E_0530h
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
DAISY
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
IOMUXC_CSI_FIELD_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: csi, In Pin: tvdecoder_in_field
0
GPIO1_IO05_ALT3 — Selecting Pad: GPIO1_IO05 for Mode: ALT3
1
NAND_DQS_ALT1 — Selecting Pad: NAND_DQS for Mode: ALT1
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2036
NXP Semiconductors

<!-- page 2037 -->

32.6.300
ECSPI1_SCLK_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI1_SCLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 534h offset = 20E_0534h
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
DAISY
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
IOMUXC_ECSPI1_SCLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi1, In Pin: cspi_clk_in
0
LCD_DATA20_ALT2 — Selecting Pad: LCD_DATA20 for Mode: ALT2
1
CSI_DATA04_ALT3 — Selecting Pad: CSI_DATA04 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2037

<!-- page 2038 -->

32.6.301
ECSPI1_MISO_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI1_MISO_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 538h offset = 20E_0538h
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
DAISY
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
IOMUXC_ECSPI1_MISO_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi1, In Pin: miso
0
LCD_DATA23_ALT2 — Selecting Pad: LCD_DATA23 for Mode: ALT2
1
CSI_DATA07_ALT3 — Selecting Pad: CSI_DATA07 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2038
NXP Semiconductors

<!-- page 2039 -->

32.6.302
ECSPI1_MOSI_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI1_MOSI_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 53Ch offset = 20E_053Ch
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
DAISY
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
IOMUXC_ECSPI1_MOSI_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi1, In Pin: mosi
0
LCD_DATA22_ALT2 — Selecting Pad: LCD_DATA22 for Mode: ALT2
1
CSI_DATA06_ALT3 — Selecting Pad: CSI_DATA06 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2039

<!-- page 2040 -->

32.6.303
ECSPI1_SS0_B_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI1_SS0_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 540h offset = 20E_0540h
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
DAISY
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
IOMUXC_ECSPI1_SS0_B_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi1, In Pin: ss_b0
0
LCD_DATA21_ALT2 — Selecting Pad: LCD_DATA21 for Mode: ALT2
1
CSI_DATA05_ALT3 — Selecting Pad: CSI_DATA05 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2040
NXP Semiconductors

<!-- page 2041 -->

32.6.304
ECSPI2_SCLK_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI2_SCLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 544h offset = 20E_0544h
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
DAISY
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
IOMUXC_ECSPI2_SCLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi2, In Pin: cspi_clk_in
0
CSI_DATA00_ALT3 — Selecting Pad: CSI_DATA00 for Mode: ALT3
1
UART4_TX_DATA_ALT8 — Selecting Pad: UART4_TX_DATA for Mode: ALT8
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2041

<!-- page 2042 -->

32.6.305
ECSPI2_MISO_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI2_MISO_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 548h offset = 20E_0548h
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
DAISY
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
IOMUXC_ECSPI2_MISO_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi2, In Pin: miso
0
CSI_DATA03_ALT3 — Selecting Pad: CSI_DATA03 for Mode: ALT3
1
UART5_RX_DATA_ALT8 — Selecting Pad: UART5_RX_DATA for Mode: ALT8
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2042
NXP Semiconductors

<!-- page 2043 -->

32.6.306
ECSPI2_MOSI_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI2_MOSI_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 54Ch offset = 20E_054Ch
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
DAISY
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
IOMUXC_ECSPI2_MOSI_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi2, In Pin: mosi
0
UART5_TX_DATA_ALT8 — Selecting Pad: UART5_TX_DATA for Mode: ALT8
1
CSI_DATA02_ALT3 — Selecting Pad: CSI_DATA02 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2043

<!-- page 2044 -->

32.6.307
ECSPI2_SS0_B_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI2_SS0_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 550h offset = 20E_0550h
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
DAISY
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
IOMUXC_ECSPI2_SS0_B_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi2, In Pin: ss_b0
0
CSI_DATA01_ALT3 — Selecting Pad: CSI_DATA01 for Mode: ALT3
1
UART4_RX_DATA_ALT8 — Selecting Pad: UART4_RX_DATA for Mode: ALT8
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2044
NXP Semiconductors

<!-- page 2045 -->

32.6.308
ECSPI3_SCLK_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI3_SCLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 554h offset = 20E_0554h
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
DAISY
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
IOMUXC_ECSPI3_SCLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi3, In Pin: cspi_clk_in
0
UART2_RX_DATA_ALT8 — Selecting Pad: UART2_RX_DATA for Mode: ALT8
1
NAND_CE0_B_ALT3 — Selecting Pad: NAND_CE0_B for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2045

<!-- page 2046 -->

32.6.309
ECSPI3_MISO_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI3_MISO_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 558h offset = 20E_0558h
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
DAISY
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
IOMUXC_ECSPI3_MISO_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi3, In Pin: miso
0
UART2_RTS_B_ALT8 — Selecting Pad: UART2_RTS_B for Mode: ALT8
1
NAND_CLE_ALT3 — Selecting Pad: NAND_CLE for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2046
NXP Semiconductors

<!-- page 2047 -->

32.6.310
ECSPI3_MOSI_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI3_MOSI_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 55Ch offset = 20E_055Ch
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
DAISY
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
IOMUXC_ECSPI3_MOSI_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi3, In Pin: mosi
0
UART2_CTS_B_ALT8 — Selecting Pad: UART2_CTS_B for Mode: ALT8
1
NAND_CE1_B_ALT3 — Selecting Pad: NAND_CE1_B for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2047

<!-- page 2048 -->

32.6.311
ECSPI3_SS0_B_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI3_SS0_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 560h offset = 20E_0560h
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
DAISY
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
IOMUXC_ECSPI3_SS0_B_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi3, In Pin: ss_b0
0
UART2_TX_DATA_ALT8 — Selecting Pad: UART2_TX_DATA for Mode: ALT8
1
NAND_READY_B_ALT3 — Selecting Pad: NAND_READY_B for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2048
NXP Semiconductors

<!-- page 2049 -->

32.6.312
ECSPI4_SCLK_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI4_SCLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 564h offset = 20E_0564h
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
DAISY
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
IOMUXC_ECSPI4_SCLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi4, In Pin: cspi_clk_in
0
ENET2_TX_DATA1_ALT3 — Selecting Pad: ENET2_TX_DATA1 for Mode: ALT3
1
NAND_DATA04_ALT3 — Selecting Pad: NAND_DATA04 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2049

<!-- page 2050 -->

32.6.313
ECSPI4_MISO_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI4_MISO_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 568h offset = 20E_0568h
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
DAISY
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
IOMUXC_ECSPI4_MISO_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi4, In Pin: miso
0
ENET2_TX_CLK_ALT3 — Selecting Pad: ENET2_TX_CLK for Mode: ALT3
1
NAND_DATA06_ALT3 — Selecting Pad: NAND_DATA06 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2050
NXP Semiconductors

<!-- page 2051 -->

32.6.314
ECSPI4_MOSI_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI4_MOSI_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 56Ch offset = 20E_056Ch
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
DAISY
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
IOMUXC_ECSPI4_MOSI_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi4, In Pin: mosi
0
ENET2_TX_EN_ALT3 — Selecting Pad: ENET2_TX_EN for Mode: ALT3
1
NAND_DATA05_ALT3 — Selecting Pad: NAND_DATA05 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2051

<!-- page 2052 -->

32.6.315
ECSPI4_SS0_B_SELECT_INPUT DAISY Register
(IOMUXC_ECSPI4_SS0_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 570h offset = 20E_0570h
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
DAISY
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
IOMUXC_ECSPI4_SS0_B_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: ecspi4, In Pin: ss_b0
0
ENET2_RX_ER_ALT3 — Selecting Pad: ENET2_RX_ER for Mode: ALT3
1
NAND_DATA07_ALT3 — Selecting Pad: NAND_DATA07 for Mode: ALT3
32.6.316
ENET1_REF_CLK1_SELECT_INPUT DAISY Register
(IOMUXC_ENET1_REF_CLK1_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 574h offset = 20E_0574h
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
DAISY
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
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2052
NXP Semiconductors

<!-- page 2053 -->

IOMUXC_ENET1_REF_CLK1_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: enet1, In Pin: rmii
00
GPIO1_IO00_ALT3 — Selecting Pad: GPIO1_IO00 for Mode: ALT3
01
GPIO1_IO04_ALT0 — Selecting Pad: GPIO1_IO04 for Mode: ALT0
10
ENET1_TX_CLK_ALT4 — Selecting Pad: ENET1_TX_CLK for Mode: ALT4
32.6.317
ENET1_MAC0_MDIO_SELECT_INPUT DAISY Register
(IOMUXC_ENET1_MAC0_MDIO_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 578h offset = 20E_0578h
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
DAISY
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
IOMUXC_ENET1_MAC0_MDIO_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: enet1, In Pin: mac0_mdio
0
GPIO1_IO06_ALT0 — Selecting Pad: GPIO1_IO06 for Mode: ALT0
1
ENET2_RX_DATA0_ALT4 — Selecting Pad: ENET2_RX_DATA0 for Mode: ALT4
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2053

<!-- page 2054 -->

32.6.318
ENET2_REF_CLK2_SELECT_INPUT DAISY Register
(IOMUXC_ENET2_REF_CLK2_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 57Ch offset = 20E_057Ch
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
DAISY
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
IOMUXC_ENET2_REF_CLK2_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: enet2, In Pin: rmii
00
GPIO1_IO01_ALT3 — Selecting Pad: GPIO1_IO01 for Mode: ALT3
01
GPIO1_IO05_ALT0 — Selecting Pad: GPIO1_IO05 for Mode: ALT0
10
ENET2_TX_CLK_ALT4 — Selecting Pad: ENET2_TX_CLK for Mode: ALT4
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2054
NXP Semiconductors

<!-- page 2055 -->

32.6.319
ENET2_MAC0_MDIO_SELECT_INPUT DAISY Register
(IOMUXC_ENET2_MAC0_MDIO_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 580h offset = 20E_0580h
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
DAISY
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
IOMUXC_ENET2_MAC0_MDIO_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: enet2, In Pin: mac0_mdio
0
GPIO1_IO06_ALT1 — Selecting Pad: GPIO1_IO06 for Mode: ALT1
1
ENET1_TX_DATA1_ALT4 — Selecting Pad: ENET1_TX_DATA1 for Mode: ALT4
32.6.320
FLEXCAN1_RX_SELECT_INPUT DAISY Register
(IOMUXC_FLEXCAN1_RX_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 584h offset = 20E_0584h
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2055

<!-- page 2056 -->

IOMUXC_FLEXCAN1_RX_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: flexcan1, In Pin: RX
00
UART3_RTS_B_ALT2 — Selecting Pad: UART3_RTS_B for Mode: ALT2
01
ENET1_RX_DATA1_ALT4 — Selecting Pad: ENET1_RX_DATA1 for Mode: ALT4
10
LCD_DATA09_ALT8 — Selecting Pad: LCD_DATA09 for Mode: ALT8
11
SD1_DATA1_ALT3 — Selecting Pad: SD1_DATA1 for Mode: ALT3
32.6.321
FLEXCAN2_RX_SELECT_INPUT DAISY Register
(IOMUXC_FLEXCAN2_RX_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 588h offset = 20E_0588h
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
DAISY
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
IOMUXC_FLEXCAN2_RX_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: flexcan2, In Pin: RX
00
UART2_RTS_B_ALT2 — Selecting Pad: UART2_RTS_B for Mode: ALT2
01
ENET1_TX_DATA0_ALT4 — Selecting Pad: ENET1_TX_DATA0 for Mode: ALT4
10
LCD_DATA11_ALT8 — Selecting Pad: LCD_DATA11 for Mode: ALT8
11
SD1_DATA3_ALT3 — Selecting Pad: SD1_DATA3 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2056
NXP Semiconductors

<!-- page 2057 -->

32.6.322
GPT1_CAPTURE1_SELECT_INPUT DAISY Register
(IOMUXC_GPT1_CAPTURE1_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 58Ch offset = 20E_058Ch
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
DAISY
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
IOMUXC_GPT1_CAPTURE1_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: gpt1, In Pin: CAPTURE1
0
GPIO1_IO00_ALT1 — Selecting Pad: GPIO1_IO00 for Mode: ALT1
1
UART2_TX_DATA_ALT4 — Selecting Pad: UART2_TX_DATA for Mode: ALT4
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2057

<!-- page 2058 -->

32.6.323
GPT1_CAPTURE2_SELECT_INPUT DAISY Register
(IOMUXC_GPT1_CAPTURE2_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 590h offset = 20E_0590h
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
DAISY
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
IOMUXC_GPT1_CAPTURE2_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: gpt1, In Pin: CAPTURE2
0
UART2_RX_DATA_ALT4 — Selecting Pad: UART2_RX_DATA for Mode: ALT4
1
ENET1_RX_ER_ALT8 — Selecting Pad: ENET1_RX_ER for Mode: ALT8
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2058
NXP Semiconductors

<!-- page 2059 -->

32.6.324
GPT1_CLK_SELECT_INPUT DAISY Register
(IOMUXC_GPT1_CLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 594h offset = 20E_0594h
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
DAISY
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
IOMUXC_GPT1_CLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: gpt1, In Pin: CLK
0
UART1_RX_DATA_ALT4 — Selecting Pad: UART1_RX_DATA for Mode: ALT4
1
ENET1_TX_CLK_ALT8 — Selecting Pad: ENET1_TX_CLK for Mode: ALT8
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2059

<!-- page 2060 -->

32.6.325
GPT2_CAPTURE1_SELECT_INPUT DAISY Register
(IOMUXC_GPT2_CAPTURE1_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 598h offset = 20E_0598h
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
DAISY
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
IOMUXC_GPT2_CAPTURE1_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: gpt2, In Pin: CAPTURE1
0
JTAG_TMS_ALT1 — Selecting Pad: JTAG_TMS for Mode: ALT1
1
SD1_DATA2_ALT1 — Selecting Pad: SD1_DATA2 for Mode: ALT1
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2060
NXP Semiconductors

<!-- page 2061 -->

32.6.326
GPT2_CAPTURE2_SELECT_INPUT DAISY Register
(IOMUXC_GPT2_CAPTURE2_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 59Ch offset = 20E_059Ch
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
DAISY
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
IOMUXC_GPT2_CAPTURE2_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: gpt2, In Pin: CAPTURE2
0
JTAG_TDO_ALT1 — Selecting Pad: JTAG_TDO for Mode: ALT1
1
SD1_DATA3_ALT1 — Selecting Pad: SD1_DATA3 for Mode: ALT1
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2061

<!-- page 2062 -->

32.6.327
GPT2_CLK_SELECT_INPUT DAISY Register
(IOMUXC_GPT2_CLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5A0h offset = 20E_05A0h
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
DAISY
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
IOMUXC_GPT2_CLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: gpt2, In Pin: CLK
0
JTAG_MOD_ALT1 — Selecting Pad: JTAG_MOD for Mode: ALT1
1
SD1_DATA1_ALT1 — Selecting Pad: SD1_DATA1 for Mode: ALT1
32.6.328
I2C1_SCL_SELECT_INPUT DAISY Register
(IOMUXC_I2C1_SCL_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5A4h offset = 20E_05A4h
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
DAISY
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
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2062
NXP Semiconductors

<!-- page 2063 -->

IOMUXC_I2C1_SCL_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: i2c1, In Pin: scl_in
00
GPIO1_IO02_ALT0 — Selecting Pad: GPIO1_IO02 for Mode: ALT0
01
UART4_TX_DATA_ALT2 — Selecting Pad: UART4_TX_DATA for Mode: ALT2
10
CSI_PIXCLK_ALT3 — Selecting Pad: CSI_PIXCLK for Mode: ALT3
32.6.329
I2C1_SDA_SELECT_INPUT DAISY Register
(IOMUXC_I2C1_SDA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5A8h offset = 20E_05A8h
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
DAISY
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
IOMUXC_I2C1_SDA_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: i2c1, In Pin: sda_in
00
CSI_MCLK_ALT3 — Selecting Pad: CSI_MCLK for Mode: ALT3
01
GPIO1_IO03_ALT0 — Selecting Pad: GPIO1_IO03 for Mode: ALT0
10
UART4_RX_DATA_ALT2 — Selecting Pad: UART4_RX_DATA for Mode: ALT2
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2063

<!-- page 2064 -->

32.6.330
I2C2_SCL_SELECT_INPUT DAISY Register
(IOMUXC_I2C2_SCL_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5ACh offset = 20E_05ACh
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
DAISY
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
IOMUXC_I2C2_SCL_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: i2c2, In Pin: scl_in
00
CSI_HSYNC_ALT3 — Selecting Pad: CSI_HSYNC for Mode: ALT3
01
GPIO1_IO00_ALT0 — Selecting Pad: GPIO1_IO00 for Mode: ALT0
10
UART5_TX_DATA_ALT2 — Selecting Pad: UART5_TX_DATA for Mode: ALT2
32.6.331
I2C2_SDA_SELECT_INPUT DAISY Register
(IOMUXC_I2C2_SDA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5B0h offset = 20E_05B0h
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
DAISY
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
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2064
NXP Semiconductors

<!-- page 2065 -->

IOMUXC_I2C2_SDA_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: i2c2, In Pin: sda_in
00
CSI_VSYNC_ALT3 — Selecting Pad: CSI_VSYNC for Mode: ALT3
01
GPIO1_IO01_ALT0 — Selecting Pad: GPIO1_IO01 for Mode: ALT0
10
UART5_RX_DATA_ALT2 — Selecting Pad: UART5_RX_DATA for Mode: ALT2
32.6.332
I2C3_SCL_SELECT_INPUT DAISY Register
(IOMUXC_I2C3_SCL_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5B4h offset = 20E_05B4h
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
DAISY
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
IOMUXC_I2C3_SCL_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: i2c3, In Pin: scl_in
00
UART1_TX_DATA_ALT2 — Selecting Pad: UART1_TX_DATA for Mode: ALT2
01
ENET2_RX_DATA0_ALT3 — Selecting Pad: ENET2_RX_DATA0 for Mode: ALT3
10
LCD_DATA01_ALT4 — Selecting Pad: LCD_DATA01 for Mode: ALT4
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2065

<!-- page 2066 -->

32.6.333
I2C3_SDA_SELECT_INPUT DAISY Register
(IOMUXC_I2C3_SDA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5B8h offset = 20E_05B8h
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
DAISY
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
IOMUXC_I2C3_SDA_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: i2c3, In Pin: sda_in
00
UART1_RX_DATA_ALT2 — Selecting Pad: UART1_RX_DATA for Mode: ALT2
01
ENET2_RX_DATA1_ALT3 — Selecting Pad: ENET2_RX_DATA1 for Mode: ALT3
10
LCD_DATA00_ALT4 — Selecting Pad: LCD_DATA00 for Mode: ALT4
32.6.334
I2C4_SCL_SELECT_INPUT DAISY Register
(IOMUXC_I2C4_SCL_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5BCh offset = 20E_05BCh
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
DAISY
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
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2066
NXP Semiconductors

<!-- page 2067 -->

IOMUXC_I2C4_SCL_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: i2c4, In Pin: scl_in
00
UART2_TX_DATA_ALT2 — Selecting Pad: UART2_TX_DATA for Mode: ALT2
01
ENET2_RX_EN_ALT3 — Selecting Pad: ENET2_RX_EN for Mode: ALT3
10
LCD_DATA03_ALT4 — Selecting Pad: LCD_DATA03 for Mode: ALT4
32.6.335
I2C4_SDA_SELECT_INPUT DAISY Register
(IOMUXC_I2C4_SDA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5C0h offset = 20E_05C0h
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
DAISY
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
IOMUXC_I2C4_SDA_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: i2c4, In Pin: sda_in
00
UART2_RX_DATA_ALT2 — Selecting Pad: UART2_RX_DATA for Mode: ALT2
01
ENET2_TX_DATA0_ALT3 — Selecting Pad: ENET2_TX_DATA0 for Mode: ALT3
10
LCD_DATA02_ALT4 — Selecting Pad: LCD_DATA02 for Mode: ALT4
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2067

<!-- page 2068 -->

32.6.336
KPP_COL0_SELECT_INPUT DAISY Register
(IOMUXC_KPP_COL0_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5C4h offset = 20E_05C4h
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
DAISY
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
IOMUXC_KPP_COL0_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: kpp, In Pin: col0
0
ENET1_RX_DATA1_ALT6 — Selecting Pad: ENET1_RX_DATA1 for Mode: ALT6
1
NAND_WE_B_ALT3 — Selecting Pad: NAND_WE_B for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2068
NXP Semiconductors

<!-- page 2069 -->

32.6.337
KPP_COL1_SELECT_INPUT DAISY Register
(IOMUXC_KPP_COL1_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5C8h offset = 20E_05C8h
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
DAISY
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
IOMUXC_KPP_COL1_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: kpp, In Pin: col1
0
ENET1_TX_DATA0_ALT6 — Selecting Pad: ENET1_TX_DATA0 for Mode: ALT6
1
NAND_DATA01_ALT3 — Selecting Pad: NAND_DATA01 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2069

<!-- page 2070 -->

32.6.338
KPP_COL2_SELECT_INPUT DAISY Register
(IOMUXC_KPP_COL2_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5CCh offset = 20E_05CCh
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
DAISY
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
IOMUXC_KPP_COL2_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: kpp, In Pin: col2
0
ENET1_TX_EN_ALT6 — Selecting Pad: ENET1_TX_EN for Mode: ALT6
1
NAND_DATA03_ALT3 — Selecting Pad: NAND_DATA03 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2070
NXP Semiconductors

<!-- page 2071 -->

32.6.339
KPP_ROW0_SELECT_INPUT DAISY Register
(IOMUXC_KPP_ROW0_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5D0h offset = 20E_05D0h
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
DAISY
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
IOMUXC_KPP_ROW0_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: kpp, In Pin: row0
0
ENET1_RX_DATA0_ALT6 — Selecting Pad: ENET1_RX_DATA0 for Mode: ALT6
1
NAND_RE_B_ALT3 — Selecting Pad: NAND_RE_B for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2071

<!-- page 2072 -->

32.6.340
KPP_ROW1_SELECT_INPUT DAISY Register
(IOMUXC_KPP_ROW1_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5D4h offset = 20E_05D4h
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
DAISY
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
IOMUXC_KPP_ROW1_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: kpp, In Pin: row1
0
ENET1_RX_EN_ALT6 — Selecting Pad: ENET1_RX_EN for Mode: ALT6
1
NAND_DATA00_ALT3 — Selecting Pad: NAND_DATA00 for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2072
NXP Semiconductors

<!-- page 2073 -->

32.6.341
KPP_ROW2_SELECT_INPUT DAISY Register
(IOMUXC_KPP_ROW2_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5D8h offset = 20E_05D8h
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
DAISY
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
IOMUXC_KPP_ROW2_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: kpp, In Pin: row2
0
ENET1_TX_DATA1_ALT6 — Selecting Pad: ENET1_TX_DATA1 for Mode: ALT6
1
NAND_DATA02_ALT3 — Selecting Pad: NAND_DATA02 for Mode: ALT3
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2073

<!-- page 2074 -->

32.6.342
LCD_BUSY_SELECT_INPUT DAISY Register
(IOMUXC_LCD_BUSY_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5DCh offset = 20E_05DCh
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
DAISY
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
IOMUXC_LCD_BUSY_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: lcdif, In Pin: lcdif_busy
0
LCD_HSYNC_ALT0 — Selecting Pad: LCD_HSYNC for Mode: ALT0
1
LCD_VSYNC_ALT1 — Selecting Pad: LCD_VSYNC for Mode: ALT1
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2074
NXP Semiconductors

<!-- page 2075 -->

32.6.343
SAI1_MCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI1_MCLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5E0h offset = 20E_05E0h
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
DAISY
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
IOMUXC_SAI1_MCLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai1, In Pin: mclk2
0
CSI_DATA01_ALT6 — Selecting Pad: CSI_DATA01 for Mode: ALT6
1
LCD_DATA00_ALT8 — Selecting Pad: LCD_DATA00 for Mode: ALT8
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2075

<!-- page 2076 -->

32.6.344
SAI1_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_SAI1_RX_DATA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5E4h offset = 20E_05E4h
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
DAISY
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
IOMUXC_SAI1_RX_DATA_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai1, In Pin: RX_DATA0
0
LCD_DATA03_ALT8 — Selecting Pad: LCD_DATA03 for Mode: ALT8
1
CSI_DATA06_ALT6 — Selecting Pad: CSI_DATA06 for Mode: ALT6
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2076
NXP Semiconductors

<!-- page 2077 -->

32.6.345
SAI1_TX_BCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI1_TX_BCLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5E8h offset = 20E_05E8h
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
DAISY
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
IOMUXC_SAI1_TX_BCLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai1, In Pin: TX_BCLK
0
LCD_DATA02_ALT8 — Selecting Pad: LCD_DATA02 for Mode: ALT8
1
CSI_DATA05_ALT6 — Selecting Pad: CSI_DATA05 for Mode: ALT6
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2077

<!-- page 2078 -->

32.6.346
SAI1_TX_SYNC_SELECT_INPUT DAISY Register
(IOMUXC_SAI1_TX_SYNC_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5ECh offset = 20E_05ECh
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
DAISY
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
IOMUXC_SAI1_TX_SYNC_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai1, In Pin: TX_SYNC
0
LCD_DATA01_ALT8 — Selecting Pad: LCD_DATA01 for Mode: ALT8
1
CSI_DATA04_ALT6 — Selecting Pad: CSI_DATA04 for Mode: ALT6
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2078
NXP Semiconductors

<!-- page 2079 -->

32.6.347
SAI2_MCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI2_MCLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5F0h offset = 20E_05F0h
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
DAISY
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
IOMUXC_SAI2_MCLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai2, In Pin: mclk2
0
JTAG_TMS_ALT2 — Selecting Pad: JTAG_TMS for Mode: ALT2
1
SD1_CLK_ALT2 — Selecting Pad: SD1_CLK for Mode: ALT2
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2079

<!-- page 2080 -->

32.6.348
SAI2_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_SAI2_RX_DATA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5F4h offset = 20E_05F4h
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
DAISY
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
IOMUXC_SAI2_RX_DATA_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai2, In Pin: RX_DATA0
0
JTAG_TCK_ALT2 — Selecting Pad: JTAG_TCK for Mode: ALT2
1
SD1_DATA2_ALT2 — Selecting Pad: SD1_DATA2 for Mode: ALT2
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2080
NXP Semiconductors

<!-- page 2081 -->

32.6.349
SAI2_TX_BCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI2_TX_BCLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5F8h offset = 20E_05F8h
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
DAISY
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
IOMUXC_SAI2_TX_BCLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai2, In Pin: TX_BCLK
0
JTAG_TDI_ALT2 — Selecting Pad: JTAG_TDI for Mode: ALT2
1
SD1_DATA1_ALT2 — Selecting Pad: SD1_DATA1 for Mode: ALT2
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2081

<!-- page 2082 -->

32.6.350
SAI2_TX_SYNC_SELECT_INPUT DAISY Register
(IOMUXC_SAI2_TX_SYNC_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 5FCh offset = 20E_05FCh
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
DAISY
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
IOMUXC_SAI2_TX_SYNC_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai2, In Pin: TX_SYNC
0
JTAG_TDO_ALT2 — Selecting Pad: JTAG_TDO for Mode: ALT2
1
SD1_DATA0_ALT2 — Selecting Pad: SD1_DATA0 for Mode: ALT2
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2082
NXP Semiconductors

<!-- page 2083 -->

32.6.351
SAI3_MCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI3_MCLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 600h offset = 20E_0600h
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
DAISY
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
IOMUXC_SAI3_MCLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai3, In Pin: mclk2
0
LCD_CLK_ALT3 — Selecting Pad: LCD_CLK for Mode: ALT3
1
LCD_DATA09_ALT1 — Selecting Pad: LCD_DATA09 for Mode: ALT1
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2083

<!-- page 2084 -->

32.6.352
SAI3_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_SAI3_RX_DATA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 604h offset = 20E_0604h
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
DAISY
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
IOMUXC_SAI3_RX_DATA_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai3, In Pin: RX_DATA0
0
LCD_VSYNC_ALT3 — Selecting Pad: LCD_VSYNC for Mode: ALT3
1
LCD_DATA14_ALT1 — Selecting Pad: LCD_DATA14 for Mode: ALT1
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2084
NXP Semiconductors

<!-- page 2085 -->

32.6.353
SAI3_TX_BCLK_SELECT_INPUT DAISY Register
(IOMUXC_SAI3_TX_BCLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 608h offset = 20E_0608h
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
DAISY
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
IOMUXC_SAI3_TX_BCLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai3, In Pin: TX_BCLK
0
LCD_HSYNC_ALT3 — Selecting Pad: LCD_HSYNC for Mode: ALT3
1
LCD_DATA13_ALT1 — Selecting Pad: LCD_DATA13 for Mode: ALT1
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2085

<!-- page 2086 -->

32.6.354
SAI3_TX_SYNC_SELECT_INPUT DAISY Register
(IOMUXC_SAI3_TX_SYNC_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 60Ch offset = 20E_060Ch
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
DAISY
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
IOMUXC_SAI3_TX_SYNC_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sai3, In Pin: TX_SYNC
0
LCD_ENABLE_ALT3 — Selecting Pad: LCD_ENABLE for Mode: ALT3
1
LCD_DATA12_ALT1 — Selecting Pad: LCD_DATA12 for Mode: ALT1
32.6.355
SDMA_EVENTS0_SELECT_INPUT DAISY Register
(IOMUXC_SDMA_EVENTS0_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 610h offset = 20E_0610h
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
DAISY
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
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2086
NXP Semiconductors

<!-- page 2087 -->

IOMUXC_SDMA_EVENTS0_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sdma, In Pin: events14
00
JTAG_MOD_ALT6 — Selecting Pad: JTAG_MOD for Mode: ALT6
01
GPIO1_IO02_ALT6 — Selecting Pad: GPIO1_IO02 for Mode: ALT6
10
SD1_CMD_ALT6 — Selecting Pad: SD1_CMD for Mode: ALT6
32.6.356
SDMA_EVENTS1_SELECT_INPUT DAISY Register
(IOMUXC_SDMA_EVENTS1_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 614h offset = 20E_0614h
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
DAISY
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
IOMUXC_SDMA_EVENTS1_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: sdma, In Pin: events15
0
JTAG_TMS_ALT6 — Selecting Pad: JTAG_TMS for Mode: ALT6
1
NAND_DQS_ALT6 — Selecting Pad: NAND_DQS for Mode: ALT6
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2087

<!-- page 2088 -->

32.6.357
SPDIF_IN_SELECT_INPUT DAISY Register
(IOMUXC_SPDIF_IN_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 618h offset = 20E_0618h
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
DAISY
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
IOMUXC_SPDIF_IN_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: spdif, In Pin: spdif_in1
00
GPIO1_IO09_ALT2 — Selecting Pad: GPIO1_IO09 for Mode: ALT2
01
UART1_RX_DATA_ALT8 — Selecting Pad: UART1_RX_DATA for Mode: ALT8
10
LCD_DATA08_ALT1 — Selecting Pad: LCD_DATA08 for Mode: ALT1
11
SD1_CLK_ALT3 — Selecting Pad: SD1_CLK for Mode: ALT3
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2088
NXP Semiconductors

<!-- page 2089 -->

32.6.358
SPDIF_EXT_CLK_SELECT_INPUT DAISY Register
(IOMUXC_SPDIF_EXT_CLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 61Ch offset = 20E_061Ch
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
DAISY
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
IOMUXC_SPDIF_EXT_CLK_SELECT_INPUT field descriptions
Field
Description
31–1
-
This field is reserved.
Reserved
0
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: spdif, In Pin: tx_clk2
0
LCD_DATA07_ALT4 — Selecting Pad: LCD_DATA07 for Mode: ALT4
1
NAND_DQS_ALT8 — Selecting Pad: NAND_DQS for Mode: ALT8
32.6.359
UART1_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART1_RTS_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 620h offset = 20E_0620h
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2089

<!-- page 2090 -->

IOMUXC_UART1_RTS_B_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart1, In Pin: uart_rts_b
00
GPIO1_IO06_ALT8 — Selecting Pad: GPIO1_IO06 for Mode: ALT8
01
GPIO1_IO07_ALT8 — Selecting Pad: GPIO1_IO07 for Mode: ALT8
10
UART1_CTS_B_ALT0 — Selecting Pad: UART1_CTS_B for Mode: ALT0
11
UART1_RTS_B_ALT0 — Selecting Pad: UART1_RTS_B for Mode: ALT0
32.6.360
UART1_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART1_RX_DATA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 624h offset = 20E_0624h
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
DAISY
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
IOMUXC_UART1_RX_DATA_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart1, In Pin: uart_RX_DATA
00
GPIO1_IO02_ALT8 — Selecting Pad: GPIO1_IO02 for Mode: ALT8
01
GPIO1_IO03_ALT8 — Selecting Pad: GPIO1_IO03 for Mode: ALT8
10
UART1_TX_DATA_ALT0 — Selecting Pad: UART1_TX_DATA for Mode: ALT0
11
UART1_RX_DATA_ALT0 — Selecting Pad: UART1_RX_DATA for Mode: ALT0
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2090
NXP Semiconductors

<!-- page 2091 -->

32.6.361
UART2_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART2_RTS_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 628h offset = 20E_0628h
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
Reserved
DAISY
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
IOMUXC_UART2_RTS_B_SELECT_INPUT field descriptions
Field
Description
31–3
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart2, In Pin: uart_rts_b
000
UART2_CTS_B_ALT0 — Selecting Pad: UART2_CTS_B for Mode: ALT0
001
UART2_RTS_B_ALT0 — Selecting Pad: UART2_RTS_B for Mode: ALT0
010
UART3_TX_DATA_ALT4 — Selecting Pad: UART3_TX_DATA for Mode: ALT4
011
UART3_RX_DATA_ALT4 — Selecting Pad: UART3_RX_DATA for Mode: ALT4
100
NAND_DATA06_ALT8 — Selecting Pad: NAND_DATA06 for Mode: ALT8
101
NAND_DATA07_ALT8 — Selecting Pad: NAND_DATA07 for Mode: ALT8
32.6.362
UART2_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART2_RX_DATA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 62Ch offset = 20E_062Ch
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2091

<!-- page 2092 -->

IOMUXC_UART2_RX_DATA_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart2, In Pin: uart_RX_DATA
00
UART2_TX_DATA_ALT0 — Selecting Pad: UART2_TX_DATA for Mode: ALT0
01
UART2_RX_DATA_ALT0 — Selecting Pad: UART2_RX_DATA for Mode: ALT0
10
NAND_DATA04_ALT8 — Selecting Pad: NAND_DATA04 for Mode: ALT8
11
NAND_DATA05_ALT8 — Selecting Pad: NAND_DATA05 for Mode: ALT8
32.6.363
UART3_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART3_RTS_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 630h offset = 20E_0630h
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
DAISY
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
IOMUXC_UART3_RTS_B_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart3, In Pin: uart_rts_b
00
UART3_CTS_B_ALT0 — Selecting Pad: UART3_CTS_B for Mode: ALT0
01
UART3_RTS_B_ALT0 — Selecting Pad: UART3_RTS_B for Mode: ALT0
10
NAND_CE1_B_ALT8 — Selecting Pad: NAND_CE1_B for Mode: ALT8
11
NAND_CLE_ALT8 — Selecting Pad: NAND_CLE for Mode: ALT8
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2092
NXP Semiconductors

<!-- page 2093 -->

32.6.364
UART3_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART3_RX_DATA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 634h offset = 20E_0634h
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
DAISY
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
IOMUXC_UART3_RX_DATA_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart3, In Pin: uart_RX_DATA
00
UART3_TX_DATA_ALT0 — Selecting Pad: UART3_TX_DATA for Mode: ALT0
01
UART3_RX_DATA_ALT0 — Selecting Pad: UART3_RX_DATA for Mode: ALT0
10
NAND_READY_B_ALT8 — Selecting Pad: NAND_READY_B for Mode: ALT8
11
NAND_CE0_B_ALT8 — Selecting Pad: NAND_CE0_B for Mode: ALT8
32.6.365
UART4_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART4_RTS_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 638h offset = 20E_0638h
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2093

<!-- page 2094 -->

IOMUXC_UART4_RTS_B_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart4, In Pin: uart_rts_b
00
ENET1_RX_DATA0_ALT1 — Selecting Pad: ENET1_RX_DATA0 for Mode: ALT1
01
ENET1_RX_DATA1_ALT1 — Selecting Pad: ENET1_RX_DATA1 for Mode: ALT1
10
LCD_HSYNC_ALT2 — Selecting Pad: LCD_HSYNC for Mode: ALT2
11
LCD_VSYNC_ALT2 — Selecting Pad: LCD_VSYNC for Mode: ALT2
32.6.366
UART4_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART4_RX_DATA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 63Ch offset = 20E_063Ch
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
DAISY
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
IOMUXC_UART4_RX_DATA_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart4, In Pin: uart_RX_DATA
00
UART4_TX_DATA_ALT0 — Selecting Pad: UART4_TX_DATA for Mode: ALT0
01
UART4_RX_DATA_ALT0 — Selecting Pad: UART4_RX_DATA for Mode: ALT0
10
LCD_CLK_ALT2 — Selecting Pad: LCD_CLK for Mode: ALT2
11
LCD_ENABLE_ALT2 — Selecting Pad: LCD_ENABLE for Mode: ALT2
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2094
NXP Semiconductors

<!-- page 2095 -->

32.6.367
UART5_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART5_RTS_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 640h offset = 20E_0640h
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
Reserved
DAISY
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
IOMUXC_UART5_RTS_B_SELECT_INPUT field descriptions
Field
Description
31–3
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart5, In Pin: uart_rts_b
000
CSI_DATA03_ALT8 — Selecting Pad: CSI_DATA03 for Mode: ALT8
001
GPIO1_IO08_ALT8 — Selecting Pad: GPIO1_IO08 for Mode: ALT8
010
GPIO1_IO09_ALT8 — Selecting Pad: GPIO1_IO09 for Mode: ALT8
011
UART1_CTS_B_ALT9 — Selecting Pad: UART1_CTS_B for Mode: ALT9
100
UART1_RTS_B_ALT9 — Selecting Pad: UART1_RTS_B for Mode: ALT9
101
ENET1_RX_EN_ALT1 — Selecting Pad: ENET1_RX_EN for Mode: ALT1
110
ENET1_TX_DATA0_ALT1 — Selecting Pad: ENET1_TX_DATA0 for Mode: ALT1
111
CSI_DATA02_ALT8 — Selecting Pad: CSI_DATA02 for Mode: ALT8
32.6.368
UART5_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART5_RX_DATA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 644h offset = 20E_0644h
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
Reserved
DAISY
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
IOMUXC_UART5_RX_DATA_SELECT_INPUT field descriptions
Field
Description
31–3
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Table continues on the next page...
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2095

<!-- page 2096 -->

IOMUXC_UART5_RX_DATA_SELECT_INPUT field descriptions (continued)
Field
Description
Instance: uart5, In Pin: uart_RX_DATA
000
CSI_DATA00_ALT8 — Selecting Pad: CSI_DATA00 for Mode: ALT8
001
CSI_DATA01_ALT8 — Selecting Pad: CSI_DATA01 for Mode: ALT8
010
GPIO1_IO04_ALT8 — Selecting Pad: GPIO1_IO04 for Mode: ALT8
011
GPIO1_IO05_ALT8 — Selecting Pad: GPIO1_IO05 for Mode: ALT8
100
UART1_TX_DATA_ALT9 — Selecting Pad: UART1_TX_DATA for Mode: ALT9
101
UART1_RX_DATA_ALT9 — Selecting Pad: UART1_RX_DATA for Mode: ALT9
110
UART5_TX_DATA_ALT0 — Selecting Pad: UART5_TX_DATA for Mode: ALT0
111
UART5_RX_DATA_ALT0 — Selecting Pad: UART5_RX_DATA for Mode: ALT0
32.6.369
UART6_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART6_RTS_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 648h offset = 20E_0648h
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
DAISY
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
IOMUXC_UART6_RTS_B_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart6, In Pin: uart_rts_b
00
CSI_VSYNC_ALT8 — Selecting Pad: CSI_VSYNC for Mode: ALT8
01
CSI_HSYNC_ALT8 — Selecting Pad: CSI_HSYNC for Mode: ALT8
10
ENET1_TX_DATA1_ALT1 — Selecting Pad: ENET1_TX_DATA1 for Mode: ALT1
11
ENET1_TX_EN_ALT1 — Selecting Pad: ENET1_TX_EN for Mode: ALT1
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2096
NXP Semiconductors

<!-- page 2097 -->

32.6.370
UART6_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART6_RX_DATA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 64Ch offset = 20E_064Ch
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
DAISY
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
IOMUXC_UART6_RX_DATA_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart6, In Pin: uart_RX_DATA
00
CSI_MCLK_ALT8 — Selecting Pad: CSI_MCLK for Mode: ALT8
01
ENET2_RX_DATA0_ALT1 — Selecting Pad: ENET2_RX_DATA0 for Mode: ALT1
10
ENET2_RX_DATA1_ALT1 — Selecting Pad: ENET2_RX_DATA1 for Mode: ALT1
11
CSI_PIXCLK_ALT8 — Selecting Pad: CSI_PIXCLK for Mode: ALT8
32.6.371
UART7_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART7_RTS_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 650h offset = 20E_0650h
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2097

<!-- page 2098 -->

IOMUXC_UART7_RTS_B_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart7, In Pin: uart_rts_b
00
ENET1_TX_CLK_ALT1 — Selecting Pad: ENET1_TX_CLK for Mode: ALT1
01
ENET1_RX_ER_ALT1 — Selecting Pad: ENET1_RX_ER for Mode: ALT1
10
LCD_DATA06_ALT1 — Selecting Pad: LCD_DATA06 for Mode: ALT1
11
LCD_DATA07_ALT1 — Selecting Pad: LCD_DATA07 for Mode: ALT1
32.6.372
UART7_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART7_RX_DATA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 654h offset = 20E_0654h
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
DAISY
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
IOMUXC_UART7_RX_DATA_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart7, In Pin: uart_RX_DATA
00
ENET2_RX_EN_ALT1 — Selecting Pad: ENET2_RX_EN for Mode: ALT1
01
ENET2_TX_DATA0_ALT1 — Selecting Pad: ENET2_TX_DATA0 for Mode: ALT1
10
LCD_DATA16_ALT1 — Selecting Pad: LCD_DATA16 for Mode: ALT1
11
LCD_DATA17_ALT1 — Selecting Pad: LCD_DATA17 for Mode: ALT1
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2098
NXP Semiconductors

<!-- page 2099 -->

32.6.373
UART8_RTS_B_SELECT_INPUT DAISY Register
(IOMUXC_UART8_RTS_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 658h offset = 20E_0658h
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
DAISY
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
IOMUXC_UART8_RTS_B_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart8, In Pin: uart_rts_b
00
ENET2_TX_CLK_ALT1 — Selecting Pad: ENET2_TX_CLK for Mode: ALT1
01
ENET2_RX_ER_ALT1 — Selecting Pad: ENET2_RX_ER for Mode: ALT1
10
LCD_DATA04_ALT1 — Selecting Pad: LCD_DATA04 for Mode: ALT1
11
LCD_DATA05_ALT1 — Selecting Pad: LCD_DATA05 for Mode: ALT1
32.6.374
UART8_RX_DATA_SELECT_INPUT DAISY Register
(IOMUXC_UART8_RX_DATA_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 65Ch offset = 20E_065Ch
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2099

<!-- page 2100 -->

IOMUXC_UART8_RX_DATA_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: uart8, In Pin: uart_RX_DATA
00
ENET2_TX_DATA1_ALT1 — Selecting Pad: ENET2_TX_DATA1 for Mode: ALT1
01
ENET2_TX_EN_ALT1 — Selecting Pad: ENET2_TX_EN for Mode: ALT1
10
LCD_DATA20_ALT1 — Selecting Pad: LCD_DATA20 for Mode: ALT1
11
LCD_DATA21_ALT1 — Selecting Pad: LCD_DATA21 for Mode: ALT1
32.6.375
USB_OTG2_OC_SELECT_INPUT DAISY Register
(IOMUXC_USB_OTG2_OC_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 660h offset = 20E_0660h
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
DAISY
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
IOMUXC_USB_OTG2_OC_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usb, In Pin: otg2_oc
00
GPIO1_IO03_ALT2 — Selecting Pad: GPIO1_IO03 for Mode: ALT2
01
ENET2_TX_EN_ALT8 — Selecting Pad: ENET2_TX_EN for Mode: ALT8
10
SD1_DATA2_ALT8 — Selecting Pad: SD1_DATA2 for Mode: ALT8
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2100
NXP Semiconductors

<!-- page 2101 -->

32.6.376
USB_OTG_OC_SELECT_INPUT DAISY Register
(IOMUXC_USB_OTG_OC_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 664h offset = 20E_0664h
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
DAISY
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
IOMUXC_USB_OTG_OC_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usb, In Pin: otg_oc
00
GPIO1_IO01_ALT2 — Selecting Pad: GPIO1_IO01 for Mode: ALT2
01
ENET2_RX_DATA1_ALT8 — Selecting Pad: ENET2_RX_DATA1 for Mode: ALT8
10
SD1_CLK_ALT8 — Selecting Pad: SD1_CLK for Mode: ALT8
32.6.377
USDHC1_CD_B_SELECT_INPUT DAISY Register
(IOMUXC_USDHC1_CD_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 668h offset = 20E_0668h
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2101

<!-- page 2102 -->

IOMUXC_USDHC1_CD_B_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc1, In Pin: card_det
00
GPIO1_IO03_ALT4 — Selecting Pad: GPIO1_IO03 for Mode: ALT4
01
UART1_RTS_B_ALT2 — Selecting Pad: UART1_RTS_B for Mode: ALT2
10
CSI_DATA05_ALT8 — Selecting Pad: CSI_DATA05 for Mode: ALT8
32.6.378
USDHC1_WP_SELECT_INPUT DAISY Register
(IOMUXC_USDHC1_WP_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 66Ch offset = 20E_066Ch
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
DAISY
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
IOMUXC_USDHC1_WP_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc1, In Pin: wp_on
00
GPIO1_IO02_ALT4 — Selecting Pad: GPIO1_IO02 for Mode: ALT4
01
UART1_CTS_B_ALT2 — Selecting Pad: UART1_CTS_B for Mode: ALT2
10
CSI_DATA04_ALT8 — Selecting Pad: CSI_DATA04 for Mode: ALT8
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2102
NXP Semiconductors

<!-- page 2103 -->

32.6.379
USDHC2_CLK_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_CLK_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 670h offset = 20E_0670h
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
DAISY
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
IOMUXC_USDHC2_CLK_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: CLK_in
00
CSI_VSYNC_ALT1 — Selecting Pad: CSI_VSYNC for Mode: ALT1
01
LCD_DATA19_ALT8 — Selecting Pad: LCD_DATA19 for Mode: ALT8
10
NAND_RE_B_ALT1 — Selecting Pad: NAND_RE_B for Mode: ALT1
32.6.380
USDHC2_CD_B_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_CD_B_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 674h offset = 20E_0674h
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2103

<!-- page 2104 -->

IOMUXC_USDHC2_CD_B_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: card_det
00
CSI_MCLK_ALT1 — Selecting Pad: CSI_MCLK for Mode: ALT1
01
GPIO1_IO07_ALT4 — Selecting Pad: GPIO1_IO07 for Mode: ALT4
10
UART1_RTS_B_ALT8 — Selecting Pad: UART1_RTS_B for Mode: ALT8
32.6.381
USDHC2_CMD_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_CMD_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 678h offset = 20E_0678h
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
DAISY
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
IOMUXC_USDHC2_CMD_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: cmd_in
00
CSI_HSYNC_ALT1 — Selecting Pad: CSI_HSYNC for Mode: ALT1
01
LCD_DATA18_ALT8 — Selecting Pad: LCD_DATA18 for Mode: ALT8
10
NAND_WE_B_ALT1 — Selecting Pad: NAND_WE_B for Mode: ALT1
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2104
NXP Semiconductors

<!-- page 2105 -->

32.6.382
USDHC2_DATA0_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA0_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 67Ch offset = 20E_067Ch
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
DAISY
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
IOMUXC_USDHC2_DATA0_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: DATA0_in
00
CSI_DATA00_ALT1 — Selecting Pad: CSI_DATA00 for Mode: ALT1
01
LCD_DATA20_ALT8 — Selecting Pad: LCD_DATA20 for Mode: ALT8
10
NAND_DATA00_ALT1 — Selecting Pad: NAND_DATA00 for Mode: ALT1
32.6.383
USDHC2_DATA1_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA1_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 680h offset = 20E_0680h
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2105

<!-- page 2106 -->

IOMUXC_USDHC2_DATA1_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: DATA1_in
00
CSI_DATA01_ALT1 — Selecting Pad: CSI_DATA01 for Mode: ALT1
01
LCD_DATA21_ALT8 — Selecting Pad: LCD_DATA21 for Mode: ALT8
10
NAND_DATA01_ALT1 — Selecting Pad: NAND_DATA01 for Mode: ALT1
32.6.384
USDHC2_DATA2_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA2_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 684h offset = 20E_0684h
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
DAISY
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
IOMUXC_USDHC2_DATA2_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: DATA2_in
00
LCD_DATA22_ALT8 — Selecting Pad: LCD_DATA22 for Mode: ALT8
01
NAND_DATA02_ALT1 — Selecting Pad: NAND_DATA02 for Mode: ALT1
10
CSI_DATA02_ALT1 — Selecting Pad: CSI_DATA02 for Mode: ALT1
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2106
NXP Semiconductors

<!-- page 2107 -->

32.6.385
USDHC2_DATA3_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA3_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 688h offset = 20E_0688h
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
DAISY
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
IOMUXC_USDHC2_DATA3_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: DATA3_in
00
CSI_DATA03_ALT1 — Selecting Pad: CSI_DATA03 for Mode: ALT1
01
LCD_DATA23_ALT8 — Selecting Pad: LCD_DATA23 for Mode: ALT8
10
NAND_DATA03_ALT1 — Selecting Pad: NAND_DATA03 for Mode: ALT1
32.6.386
USDHC2_DATA4_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA4_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 68Ch offset = 20E_068Ch
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2107

<!-- page 2108 -->

IOMUXC_USDHC2_DATA4_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: DATA4_in
00
LCD_DATA14_ALT8 — Selecting Pad: LCD_DATA14 for Mode: ALT8
01
NAND_DATA04_ALT1 — Selecting Pad: NAND_DATA04 for Mode: ALT1
10
CSI_DATA04_ALT1 — Selecting Pad: CSI_DATA04 for Mode: ALT1
32.6.387
USDHC2_DATA5_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA5_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 690h offset = 20E_0690h
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
DAISY
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
IOMUXC_USDHC2_DATA5_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: DATA5_in
00
LCD_DATA15_ALT8 — Selecting Pad: LCD_DATA15 for Mode: ALT8
01
NAND_DATA05_ALT1 — Selecting Pad: NAND_DATA05 for Mode: ALT1
10
CSI_DATA05_ALT1 — Selecting Pad: CSI_DATA05 for Mode: ALT1
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2108
NXP Semiconductors

<!-- page 2109 -->

32.6.388
USDHC2_DATA6_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA6_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 694h offset = 20E_0694h
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
DAISY
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
IOMUXC_USDHC2_DATA6_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: DATA6_in
00
LCD_DATA16_ALT8 — Selecting Pad: LCD_DATA16 for Mode: ALT8
01
NAND_DATA06_ALT1 — Selecting Pad: NAND_DATA06 for Mode: ALT1
10
CSI_DATA06_ALT1 — Selecting Pad: CSI_DATA06 for Mode: ALT1
32.6.389
USDHC2_DATA7_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_DATA7_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 698h offset = 20E_0698h
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
DAISY
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
Chapter 32 IOMUX Controller (IOMUXC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2109

<!-- page 2110 -->

IOMUXC_USDHC2_DATA7_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: DATA7_in
00
LCD_DATA17_ALT8 — Selecting Pad: LCD_DATA17 for Mode: ALT8
01
NAND_DATA07_ALT1 — Selecting Pad: NAND_DATA07 for Mode: ALT1
10
CSI_DATA07_ALT1 — Selecting Pad: CSI_DATA07 for Mode: ALT1
32.6.390
USDHC2_WP_SELECT_INPUT DAISY Register
(IOMUXC_USDHC2_WP_SELECT_INPUT)
DAISY Register
Address: 20E_0000h base + 69Ch offset = 20E_069Ch
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
DAISY
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
IOMUXC_USDHC2_WP_SELECT_INPUT field descriptions
Field
Description
31–2
-
This field is reserved.
Reserved
DAISY
Selecting Pads Involved in Daisy Chain.
Instance: usdhc2, In Pin: wp_on
00
GPIO1_IO06_ALT4 — Selecting Pad: GPIO1_IO06 for Mode: ALT4
01
UART1_CTS_B_ALT8 — Selecting Pad: UART1_CTS_B for Mode: ALT8
10
CSI_PIXCLK_ALT1 — Selecting Pad: CSI_PIXCLK for Mode: ALT1
IOMUXC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2110
NXP Semiconductors

