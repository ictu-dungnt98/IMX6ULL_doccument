# Appendix A: i.MX 6ULL Revision History

> Nguồn: `IMX6ULLRM.pdf` — trang 4117–4127

<!-- page 4117 -->

Appendix A
i.MX 6ULL Revision History
A.1
Substantive changes from revision 0 to revision 1
Substantive changes from revision 0 to revision 1 are as follows:
A.1.1
Reference Manual Revision History
No substantive changes
A.1.2
Introduction Revision History
No substantive changes
A.1.3
Memory Maps Revision History
No substantive changes
A.1.4
Interrupts and DMA Events Revision History
Topic Cross-Reference
Change Description
Cortex A7 interrupts
New IRQ table
A.1.5
External Signals Revision History
No substantive changes
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4117

<!-- page 4118 -->

A.1.6
Fusemap Revision History
Topic Cross-Reference
Change Description
Fusemap Descriptions Table
SPEED_GRADING values updated
A.1.7
External Memory Controllers Revision History
No substantive changes
A.1.8
System Debug Revision History
Topic Cross-Reference
Change Description
Clock/Reset/Power
Removed the statement about the debug system being
capable of generating a system reset via a request bit in the
MDM-AP register.
A.1.9
System Boot Revision History
Topic Cross-Reference
Change Description
Boot security settings
Removed Note "If the DIR_BT_DIS eFuse is not blown
authentication may be bypassed..."
Boot eFUSE descriptions
For the Fuse, DIR_BT_DIS; removed from the Definition,
"must be set for secure boot". Added to the Setting; "This
fuse must be blown to 1 for normal operation."
MMC and eMMC boot
In the table row, eMMC4.3 or eMMC4.4 device supporting
special boot mode, removed sentence; "The eMMC4.3/
eMMC4.4 device with the "boot mode" feature can only be
supported via the ESDHCV3-3 and with or without the BOOT
ACK."
A.1.10
Multimedia Revision History
Topic Cross-Reference
Change Description
Feature summary
VPU decoding/encoding capabilities table: AVS row,
removed On2 VP6 and Theora standards.
Substantive changes from revision 0 to revision 1
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4118
NXP Semiconductors

<!-- page 4119 -->

A.1.11
Power Management Revision History
Topic Cross-Reference
Change Description
Static
In the Static section, removed sub-section Voltage Domain
Dependencies and IO Voltage.
A.1.12
System Security Revision History
No substantive changes
A.1.13
ARM A7 Revision History
No substantive changes
A.1.14
ADC Revision History
No substantive changes
A.1.15
AIPSTZ Revision History
No substantive changes
A.1.16
APBH Revision History
No substantive changes
A.1.17
ASRC Revision History
No substantive changes
A.1.18
BCH Revision History
No substantive changes
Appendix A i.MX 6ULL Revision History
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4119

<!-- page 4120 -->

A.1.19
CCM Revision History
Topic Cross-Reference
Change Description
CCM Memory Map/Register Definition
CHSCCDR reset value updated to 0x29148
System Clocks
Changed within the System Clock Frequency Values table:
ACLK_EIM_SLOW_CLK_ROOT Default Freq MHz column
from 396MHz to 132MHz.
CCM Memory Map/Register Definition
CLPCR[BYPASS_MMDC_CH0_LPM_HS] bit added with
note to user to always set to 1.
Clock Switching Multiplexers
Penultimate paragraph: Clarified output clocks are required to
be gated before switching. Previously the statement included
input and output.
Divider change handshake
Added new content to explain the dividers designed with a
handshake and to describe steps for dividers without a
handshake design.
CCM Memory Map/Register Definition
Updates to ENFC_CLK_SEL, ESAI_CLK_SEL, and CCGRs.
System Clocks
Updates to reflect changes to CCGR assignments.
A.1.20
CSI Revision History
No substantive changes
A.1.21
DCP revision history
No substantive changes
A.1.22
ECSPI Revision History
No substantive changes
A.1.23
EIM Revision History
No substantive changes
A.1.24
ENET Revision History
No substantive changes
Substantive changes from revision 0 to revision 1
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4120
NXP Semiconductors

<!-- page 4121 -->

A.1.25
EPDC Revision History
No substantive changes
A.1.26
EPIT Revision History
No substantive changes
A.1.27
ESAI Revision History
No substantive changes
A.1.28
FLEXCAN3 Revision History
No substantive changes
A.1.29
GPC Revision History
No substantive changes
A.1.30
GPIO Revision History
Topic Cross-Reference
Change Description
GPIO Memory Map/Register Definition
Updated IMR register.
A.1.31
GPMI Revision History
No substantive changes
A.1.32
GPT Revision History
No substantive changes
Appendix A i.MX 6ULL Revision History
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4121

<!-- page 4122 -->

A.1.33
I2C Revision History
No substantive changes
A.1.34
IOMUXC Revision History
Topic Cross-Reference
Change Description
IOMUXC_GPR
Updated GPR0 register.
A.1.35
KPP Revision History
No substantive changes
A.1.36
eLCDIF Revision History
Topic Cross-Reference
Customer-facing Description
eLCDIF Memory Map/Register Definition
Updated bit field definitions for LFIFO_FULL, LFIFO_EMPTY,
TXFIFO_FULL, and TXFIFO_EMPTY in the STAT register.
A.1.37
MMDC Revision History
Topic Cross-Reference
Change Description
ZQ automatic Pull-down calibration
Corrected Step 6 to read "MMCD repeats steps 2-5 ..."
instead of "MMDC repeats steps 12-15 ...".
MMDC
Switched bit field values in MAPSR[6] and MAPSR[5].
Changes bit field access to reserved, read-only in
MDMISC[29:22], , and MDMISC[2].
A.1.38
MQS Revision History
No substantive changes
Substantive changes from revision 0 to revision 1
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4122
NXP Semiconductors

<!-- page 4123 -->

A.1.39
OCOTP Revision History
No substantive changes
A.1.40
OCRAM Revision History
No substantive changes
A.1.41
PMU Revision History
Topic Cross-Reference
Change Description
PMU
Added Register dimensions for 1P1, 3P0, 2P5, and Core
A.1.42
PWM Revision History
No substantive changes
A.1.43
PXP Revision History
Topic Cross-Reference
Change Description
PXP
New register set for V3 pipeline with Set/Clear/Toggle
functionality
PXP
Porter-Duff Alpha Blend
Removed PXP_HW_PXP_HANDSHAKE_READY_MUX1
and PXP_HW_PXP_HANDSHAKE_DONE_MUX1; updated
PXP_HW_PXP_HANDSHAKE_READY_MUX0 and
PXP_HW_PXP_HANDSHAKE_DONE_MUX0 ; updated the
figure Porter-Duff Alpha Blend.
A.1.44
QSPI Revision History
No substantive changes
A.1.45
ROMCP Revision History
No substantive changes
Appendix A i.MX 6ULL Revision History
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4123

<!-- page 4124 -->

A.1.46
SAI Revision History
No substantive changes
A.1.47
SDMA Revision History
No substantive changes
A.1.48
SJC Revision History
No substantive changes
A.1.49
SNVS Revision History
No substantive changes
A.1.50
SPBA Revision History
No substantive changes
A.1.51
SPDIF Revision History
No substantive changes
A.1.52
SRC Revision History
No substantive changes
A.1.53
TEMPMON Revision History
No substantive changes
Substantive changes from revision 0 to revision 1
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4124
NXP Semiconductors

<!-- page 4125 -->

A.1.54
TSC Revision History
No substantive changes
A.1.55
TZASC Revision History
No substantive changes
A.1.56
UART Revision History
No substantive changes
A.1.57
USB Revision History
No substantive changes
A.1.58
USB PHY Revision History
Topic Cross-Reference
Change Description
USB_ANALOG
Reformatted USB_ANALOG_DIGPROG register.
A.1.59
USDHC Revision History
No substantive changes
A.1.60
WDOG Revision History
No substantive changes
Appendix A i.MX 6ULL Revision History
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4125

<!-- page 4126 -->

A.1.61
XTALOSC Revision History
Topic Cross-Reference
Change Description
Oscillator Configuration (32 kHz)
Updates to second paragraph, final sentences: clarifying the
requirement of an external 32 kHz clock source for
production systems.
XTALOSC24M
XTALOSC24M_MISC0 register, RTC_XTAL_SOURCE field
[29] correction to Read Only.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4126
NXP Semiconductors

<!-- page 4127 -->

Information in this document is provided solely to enable system and software 
implementers to use NXP products. There are no express or implied copyright licenses 
granted hereunder to design or fabricate any integrated circuits based on the 
information in this document. NXP reserves the right to make changes without further 
notice to any products herein.
NXP makes no warranty, representation, or guarantee regarding the suitability of its 
products for any particular purpose, nor does NXP assume any liability arising out of 
the application or use of any product or circuit, and specifically disclaims any and all 
liability, including without limitation consequential or incidental damages. “Typical” 
parameters that may be provided in NXP data sheets and/or specifications can and do 
vary in different applications, and actual performance may vary over time. All operating 
parameters, including “typicals” must be validated for each customer application by 
customer‚ customer’s technical experts. NXP does not convey any license under its 
patent rights nor the rights of others. NXP sells products pursuant to standard terms 
and conditions of sale, which can be found at the following address: 
nxp.com/SalesTermsandConditions.
How to Reach Us:
Home Page: 
nxp.com 
Web Support: 
nxp.com/support
NXP, the NXP logo, Freescale, the Freescale logo, and the Energy Efficient Solutions 
logo are trademarks of NXP B.V. All other product or service names are the property 
of their respective owners. Arm and Cortex are trademarks of Arm Limited (or its 
subsidiaries) in the EU and/or elsewhere. All rights reserved. 
© 2017 NXP B.V.
Document Number: IMX6ULLRM 
Rev. 1
11/2017

