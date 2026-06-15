# Extended Temperature Usage

> Nguồn: `4Gb_automotive_DDR3L(MT41K256M16TW).pdf` — trang 167–168

<!-- page 167 -->

Figure 93: Self Refresh Entry/Exit Timing
CK
CK#
Command
NOP
NOP4
SRE (REF)3
Address
CKE
ODT2
RESET#2
Valid
Valid6
SRX (NOP)
NOP5
tRP8
tXSDLL7, 9
ODTL
tIS
tCPDED
tIS
tIS
Enter self refresh mode
(synchronous)
Exit self refresh mode
(asynchronous)
T0
T1
T2
Tc0
Tc1
Td0
Tb0
Don’t Care
Te0
Valid
Valid7
Valid
Valid
Valid
tIH
Ta0
Tf0
Indicates break
in time scale
tCKSRX1
tCKSRE1
tXS6, 9
tCKESR (MIN)1
Notes:
1. The clock must be valid and stable, meeting tCK specifications at least tCKSRE after en-
tering self refresh mode, and at least tCKSRX prior to exiting self refresh mode, if the
clock is stopped or altered between states Ta0 and Tb0. If the clock remains valid and
unchanged from entry and during self refresh mode, then tCKSRE and tCKSRX do not
apply; however, tCKESR must be satisfied prior to exiting at SRX.
2. ODT must be disabled and RTT off prior to entering self refresh at state T1. If both
RTT,nom and RTT(WR) are disabled in the mode registers, ODT can be a “Don’t Care.”
3. Self refresh entry (SRE) is synchronous via a REFRESH command with CKE LOW.
4. A NOP or DES command is required at T2 after the SRE command is issued prior to the
inputs becoming “Don’t Care.”
5. NOP or DES commands are required prior to exiting self refresh mode until state Te0.
6.
tXS is required before any commands not requiring a locked DLL.
7.
tXSDLL is required before any commands requiring a locked DLL.
8. The device must be in the all banks idle state prior to entering self refresh mode. For
example, all banks must be precharged, tRP must be met, and no data bursts can be in
progress.
9. Self refresh exit is asynchronous; however, tXS and tXSDLL timings start at the first rising
clock edge where CKE HIGH satisfies tISXR at Tc1. tCKSRX timing is also measured so that
tISXR is satisfied at Tc1.
Extended Temperature Usage
Micron’s DDR3 SDRAM support the optional extended case temperature (TC) range of
0°C to 125°C. Thus, the SRT and ASR options must be used at a minimum for tempera-
tures above 85°C (and does not exceed 105°C).
The extended temperature range DRAM must be refreshed externally at 2x (double re-
fresh) anytime the case temperature is above 85°C (and does not exceed 105°C) and 8x
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Extended Temperature Usage
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
167
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

<!-- page 168 -->

anytime the case temperature is above 105°C (and does not exceed 125°C). The external
refresh requirement is accomplished by reducing the refresh period from 64ms to 32ms
or 8ms respectively. However, self refresh mode requires either ASR or SRT to support
the extended temperatures between 85°C and 105°C and is not supported for tempera-
tures above 105°C. 
Table 76: Self Refresh Temperature and Auto Self Refresh Description
Field
MR2 Bits
Description
Self Refresh Temperature (SRT)
SRT
7
If ASR is disabled (MR2[6] = 0), SRT must be programmed to indicate TOPER during self refresh:
*MR2[7] = 0: Normal operating temperature range (0°C to 85°C)
*MR2[7] = 1: Extended operating temperature range (0°C to 105°C)
If ASR is enabled (MR2[7] = 1), SRT must be set to 0, even if the extended temperature range is
supported
*MR2[7] = 0: SRT is disabled
Auto Self Refresh (ASR)
ASR
6
When ASR is enabled, the DRAM automatically provides SELF REFRESH power management func-
tions, (refresh rate for all supported operating temperature values)
* MR2[6] = 1: ASR is enabled (M7 must = 0)
When ASR is not enabled, the SRT bit must be programmed to indicate TOPER during SELF REFRESH
operation
* MR2[6] = 0: ASR is disabled; must use manual self refresh temperature (SRT)
Table 77: Self Refresh Mode Summary
MR2[6]
(ASR)
MR2[7]
(SRT)
SELF REFRESH Operation
Permitted Operating Temperature
Range for Self Refresh Mode
0
0
Self refresh mode is supported in the normal temperature
range
Normal (0°C to 85°C)
0
1
Self refresh mode is supported in normal and extended temper-
ature ranges; When SRT is enabled, it increases self refresh
power consumption
Normal and extended (0°C to 105°C)
1
0
Self refresh mode is supported in normal and extended temper-
ature ranges; Self refresh power consumption may be tempera-
ture-dependent
Normal and extended (0°C to 105°C)
1
1
Illegal
Preliminary
4Gb: x8, x16 Automotive DDR3L SDRAM
Extended Temperature Usage
PDF: X26P4QTWDSPK-13-10208
automotive_4gb_ddr3l_v00h.pdf - Rev. A 12/15 EN
168
Micron Technology, Inc. reserves the right to change products or specifications without notice.
© 2015 Micron Technology, Inc. All rights reserved.

