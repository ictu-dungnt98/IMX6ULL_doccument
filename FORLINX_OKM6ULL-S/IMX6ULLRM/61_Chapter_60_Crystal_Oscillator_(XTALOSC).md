# Chapter 60: Crystal Oscillator (XTALOSC)

> Nguồn: `IMX6ULLRM.pdf` — trang 4099–4116

<!-- page 4099 -->

Chapter 60
Crystal Oscillator (XTALOSC)
60.1
Overview
This block comprises both the 24 MHz and 32 kHz implementation of a biased amplifier
that when combined with a suitable external quartz crystal and external load capacitors,
implements an oscillator.
The block includes means to:
• Accept an external clock source.
• Detect if the crystal frequency is close to 24 MHz or 32 kHz.
• Reduce the operating current via software after the oscillator has started (24 MHz
specific feature)
• Supply another ~32 kHz clock source based off an independent internal oscillator if
there is no oscillation sensed on the RTC_XTAL bumps(contacts) (32 kHz specific
feature). The internal oscillator will provide clocks to the same on-chip modules as
the external 32 kHz oscillator.
• Automatically switch to the external oscillation source when sensed on the
RTC_XTAL bumps(contacts) (32 kHz specific feature).
60.2
External Signals
The table found here describes the external signals of XTALOSC:
Table 60-1. XTALOSC External Signals
Signal
Description
Pad
Mode
Direction
XTALOSC_REF_CLK_
32K
32 kHz reference clock
ENET1_RX_EN
ALT2
O
GPIO1_IO03
ALT3
JTAG_TCK
ALT6
Table continues on the next page...
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4099

<!-- page 4100 -->

Table 60-1. XTALOSC External Signals
(continued)
Signal
Description
Pad
Mode
Direction
XTALOSC_REF_CLK_
24M
24 MHz reference clock
ENET1_TX_DATA0
ALT2
O
ENET2_TX_DATA0
ALT8
GPIO1_IO04
ALT3
JTAG_TRST_B
ALT6
XTALOSC_REF_CLK_
25M
25 MHz reference clock
ENET2_RX_EN
ALT8
O
GPIO1_IO02
ALT3
JTAG_MOD
ALT3
XTALOSC_REF_CLK1
XTALOSC reference clock 1
ENET1_TX_CLK
ALT4
O
GPIO1_IO00
ALT3
GPIO1_IO04
ALT0
XTALOSC_REF_CLK2
XTALOSC reference clock 2
ENET2_TX_CLK
ALT4
O
GPIO1_IO01
ALT3
GPIO1_IO05
ALT0
Table 60-2. XTALOSC External Signals
Signal
Description
Pad
Mode
Direction
REF_CLK_32K
32 kHz reference clock
GPIO_AD_B0_00
ALT2
O
REF_CLK_24M
24 MHz reference clock GPIO_AD_B0_01
ALT2
O
GPIO_AD_B0_03
ALT6
GPIO_AD_B0_13
ALT7
XTALI
Crystal oscillator input
signal
XTALI
No Muxing
O
XTALO
Crystal oscillator output
signal
XTALO
No Muxing
O
60.3
Crystal Oscillator 24 MHz
60.3.1
Oscillator Configuration (24 MHz)
The basic block diagram of the 24 MHz module configured as a crystal oscillator is
shown below.
Crystal Oscillator 24 MHz
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4100
NXP Semiconductors

<!-- page 4101 -->

 
Solder bump 
XTALO
Solder bump 
XTALI
i.MX Series Processor
Rbias
Inverting 
Amplifier
Internal
Circuitry
+
_
Figure 60-1. Oscillator Configuration (24 MHz)
This integrated biased amplifier can be used to create different frequency oscillators with
different external component selection. However, care should be taken as many of the
serial IO modules depend on the fixed frequency of 24 MHz. Please consult the sections
of the document pertaining to the USB, ENET interfaces, for example. Once a healthy
oscillation is established, then the bias current of the oscillator can generally be reduced
to save power. This is accomplished through the XTALOSC24M_MISC0[OSC_I] bits,
defined in the MISC0 register later in this chapter. Restore the
XTALOSC24M_MISC0[OSC_I] bits before going into a power mode where the
XTALOSC24 is powered down or oscillator startup may become an issue. The power
down of the XTALOSC24 module is controlled by the CCM. See this section of the
manual for more details.
60.3.2
RC Oscillator (24 MHz)
A lower-power RC oscillator module is available on-chip as a possible alternative to the
24 MHz crystal oscillator after a successful power-up sequence.
Chapter 60 Crystal Oscillator (XTALOSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4101

<!-- page 4102 -->

The 24 MHz RC oscillator is a self-tuning circuit that will output the programmed
frequency value by using the RTC clock as it’s reference. This oscillator is intended for
normal operation and not fast boot.
While the power consumption of this RC oscillator is much lower than the 24 MHz
crystal oscillator, one limitation of this RC oscillator module is that its clock frequency is
not as accurate. Therefore, care should be observed when using this oscillator as the
reference for the on-chip PLLs as their output clock frequency will be lower/higher than
when using the 24 MHz crystal oscillator clock.
For more details on the possible usage of this module please contact a NXP FAE for
pertinent application-notes.
60.3.3
Crystal Frequency Detection(24 MHz)
A submodule exists that gives a fairly crude (relative to the accuracy of a crystal)
estimation of whether the clock frequency is correct.
This function may be enabled by setting the
XTALOSC24M_MISC0[OSC_XTALOK_EN] bit. It is disabled at system reset. When
the oscillator is stable and the correct frequency is detected, the
XTALOSC24M_MISC0[OSC_XTALOK] bit will be set. Note that the correct frequency
will be observed before the oscillator fully blooms(the oscillation waveform build-up is
completed).
60.4
Crystal Oscillator 32 kHz
60.4.1
Oscillator Configuration (32 kHz)
The basic block diagram of the 32 kHz module configured as a crystal oscillator is shown
below.
Crystal Oscillator 32 kHz
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4102
NXP Semiconductors

<!-- page 4103 -->

 
Solder bump 
RTC_XTALO
Solder bump 
RTC_XTALI
 
i.MX Series Processor
Rbias
Oscillation 
Amplifier
Internal
Circuitry
+
_
Sensing 
Amplifier
Internal 
Oscillator
Automatic
Mux
Figure 60-2. Oscillator Configuration (32 kHz)
This integrated biased amplifier can be used to create different frequency oscillators with
different external component selection. Generally, RTC oscillators are either
implemented with 32 kHz or 32.768 kHz crystals. Please consult the Security Reference
Manual for appropriate frequency selection and configuration. Care must be taken to
limit external leakage as this may debias the amplifier and degrade the gain.
The internal oscillator is automatically multiplexed in the clocking system when the
system detects a loss of clock. The internal oscillator will provide clocks to the same on-
chip modules as the external 32 kHz oscillator. The internal oscillator is not precise
relative to a crystal. While it will provide a clock to the system, it generally will not be
precise enough for long term time keeping. The internal oscillator is anticipated to be
useful for quicker startup times and tampering prevention, but should not be used as the
exclusive source for the 32 kHz clocks. An external 32 kHz clock source must be used
for production systems.
60.4.2
Bypass Configuration (32 kHz)
If it is desired to drive the chip with an external clock source, then the 32 kHz oscillator
could be driven in one of three configurations using a nominal 1.1V source.
Chapter 60 Crystal Oscillator (XTALOSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4103

<!-- page 4104 -->

1. A single ended external clock source can be used to overdrive the output of the
amplifier (RTC_XTALO). Since the oscillation sensing amplifier is differential, the
RTC_XTALI pin should be externally floating and capacitively loaded. The
combination of the internal biasing resistor and the external capacitor will filter the
signal applied to the RTC_XTALO pin and develop a rough reference for the sensing
amplifier to compare to.
2. A single ended external clock source can be used to drive RTC_XTALI. In this
configuration, RTC_XTALO should be left externally floating.
3. A differential external clock source can be used to drive both RTC_XTALI and
RTC_XTALO.
Generally, configuration 2 is anticipated to be the most used configuration, but all three
configurations may be utilized.
60.5
XTALOSC 24MHz Memory Map/Register Definition
NOTE
The register content is mixed with analog functions not related
to the oscillator function. These bits are noted.
XTALOSC24M memory map
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
20C_8150
Miscellaneous Register 0 (XTALOSC24M_MISC0)
32
R/W
0400_0000h
60.5.1/4106
20C_8154
Miscellaneous Register 0 (XTALOSC24M_MISC0_SET)
32
R/W
0400_0000h
60.5.1/4106
20C_8158
Miscellaneous Register 0 (XTALOSC24M_MISC0_CLR)
32
R/W
0400_0000h
60.5.1/4106
20C_815C
Miscellaneous Register 0 (XTALOSC24M_MISC0_TOG)
32
R/W
0400_0000h
60.5.1/4106
20C_8270
XTAL OSC (LP) Control Register
(XTALOSC24M_LOWPWR_CTRL)
32
R/W
0000_4009h
60.5.2/4110
20C_8274
XTAL OSC (LP) Control Register
(XTALOSC24M_LOWPWR_CTRL_SET)
32
R/W
0000_4009h
60.5.2/4110
20C_8278
XTAL OSC (LP) Control Register
(XTALOSC24M_LOWPWR_CTRL_CLR)
32
R/W
0000_4009h
60.5.2/4110
20C_827C
XTAL OSC (LP) Control Register
(XTALOSC24M_LOWPWR_CTRL_TOG)
32
R/W
0000_4009h
60.5.2/4110
20C_82A0
XTAL OSC Configuration 0 Register
(XTALOSC24M_OSC_CONFIG0)
32
R/W
0000_1020h
60.5.3/4113
20C_82A4
XTAL OSC Configuration 0 Register
(XTALOSC24M_OSC_CONFIG0_SET)
32
R/W
0000_1020h
60.5.3/4113
Table continues on the next page...
XTALOSC 24MHz Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4104
NXP Semiconductors

<!-- page 4105 -->

XTALOSC24M memory map (continued)
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
20C_82A8
XTAL OSC Configuration 0 Register
(XTALOSC24M_OSC_CONFIG0_CLR)
32
R/W
0000_1020h
60.5.3/4113
20C_82AC
XTAL OSC Configuration 0 Register
(XTALOSC24M_OSC_CONFIG0_TOG)
32
R/W
0000_1020h
60.5.3/4113
20C_82B0
XTAL OSC Configuration 1 Register
(XTALOSC24M_OSC_CONFIG1)
32
R/W
0000_02EEh
60.5.4/4114
20C_82B4
XTAL OSC Configuration 1 Register
(XTALOSC24M_OSC_CONFIG1_SET)
32
R/W
0000_02EEh
60.5.4/4114
20C_82B8
XTAL OSC Configuration 1 Register
(XTALOSC24M_OSC_CONFIG1_CLR)
32
R/W
0000_02EEh
60.5.4/4114
20C_82BC
XTAL OSC Configuration 1 Register
(XTALOSC24M_OSC_CONFIG1_TOG)
32
R/W
0000_02EEh
60.5.4/4114
20C_82C0
XTAL OSC Configuration 2 Register
(XTALOSC24M_OSC_CONFIG2)
32
R/W
0001_02E2h
60.5.5/4115
20C_82C4
XTAL OSC Configuration 2 Register
(XTALOSC24M_OSC_CONFIG2_SET)
32
R/W
0001_02E2h
60.5.5/4115
20C_82C8
XTAL OSC Configuration 2 Register
(XTALOSC24M_OSC_CONFIG2_CLR)
32
R/W
0001_02E2h
60.5.5/4115
20C_82CC
XTAL OSC Configuration 2 Register
(XTALOSC24M_OSC_CONFIG2_TOG)
32
R/W
0001_02E2h
60.5.5/4115
Chapter 60 Crystal Oscillator (XTALOSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4105

<!-- page 4106 -->

60.5.1
Miscellaneous Register 0 (XTALOSC24M_MISC0n)
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
XTALOSC 24MHz Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4106
NXP Semiconductors

<!-- page 4107 -->

Bit
15
14
13
12
11
10
9
8
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
XTALOSC24M_MISC0n field descriptions
Field
Description
31
VID_PLL_
PREDIV
Predivider for the source clock of the PLL's.
NOTE: Not related to oscillator.
0
Divide by 1
1
Divide by 2
30
XTAL_24M_PWD
This field powers down the 24M crystal oscillator if set true.
29
RTC_XTAL_
SOURCE
This field indicates which chip source is being used for the rtc clock.
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
Table continues on the next page...
Chapter 60 Crystal Oscillator (XTALOSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4107

<!-- page 4108 -->

XTALOSC24M_MISC0n field descriptions (continued)
Field
Description
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
15
OSC_XTALOK
Status bit that signals that the output of the 24-MHz crystal oscillator is stable. Generated from a timer and
active detection of the actual frequency.
14–13
OSC_I
This field determines the bias current in the 24MHz oscillator. The aim is to start up with the highest bias
current, which can be decreased after startup if it is determined to be acceptable.
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
NOTE: Not related to oscillator.
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
NOTE: Not related to oscillator.
6–4
REFTOP_
VBGADJ
NOTE: Not related to oscillator.
000
Nominal VBG
Table continues on the next page...
XTALOSC 24MHz Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4108
NXP Semiconductors

<!-- page 4109 -->

XTALOSC24M_MISC0n field descriptions (continued)
Field
Description
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
NOTE: Not related to oscillator.
0
Uses coarse bias currents for startup
1
Uses bandgap-based bias currents for best performance.
2–1
-
This field is reserved.
0
REFTOP_PWD
Control bit to power-down the analog bandgap reference circuitry.
NOTE: A note of caution, the bandgap is necessary for correct operation of most of the LDO, pll, and
other analog functions on the die.
NOTE: Not related to oscillator.
Chapter 60 Crystal Oscillator (XTALOSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4109

<!-- page 4110 -->

60.5.2
XTAL OSC (LP) Control Register
(XTALOSC24M_LOWPWR_CTRLn)
This register defines xtal osc and low power configuration.
Address: 20C_8000h base + 270h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
Reserved
MIX_PWRGATE
XTALOSC_PWRUP_STAT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
XTALOSC 24MHz Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4110
NXP Semiconductors

<!-- page 4111 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
XTALOSC_
PWRUP_
DELAY
RCOSC_CG_OVERRIDE
-
DISPLAY_PWRGATE
CPU_PWRGATE
L2_PWRGATE
L1_PWRGATE
REFTOP_IBIAS_OFF
LPBG_TEST
LPBG_SEL
OSC_SEL
RC_OSC_PROG
RC_OSC_EN
W
Reset
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
1
0
0
1
XTALOSC24M_LOWPWR_CTRLn field descriptions
Field
Description
31–19
-
This field is reserved.
18
-
This field is reserved.
17
MIX_PWRGATE
Display power gate control. Used as software mask. Set to zero to force ungated.
16
XTALOSC_
PWRUP_STAT
Status of the 24MHz xtal oscillator.
0
Not stable
1
Stable and ready to use
15–14
XTALOSC_
PWRUP_DELAY
Specifies the time delay between when the 24MHz xtal is powered up until it is stable and ready to use.
00
0.25ms
01
0.5ms
10
1ms
11
2ms
13
RCOSC_CG_
OVERRIDE
For debug purposes only. This bit effects clock gating of certain digital logic clocked by the 24MHz clk.
12
-
Reserved
11
DISPLAY_
PWRGATE
Display logic power gate control. Used as software override.
NOTE: Not related to oscillator.
10
CPU_PWRGATE CPU power gate control. Used as software override.
Table continues on the next page...
Chapter 60 Crystal Oscillator (XTALOSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4111

<!-- page 4112 -->

XTALOSC24M_LOWPWR_CTRLn field descriptions (continued)
Field
Description
Attention: Test purpose only
NOTE: Not related to oscillator.
9
L2_PWRGATE
L2 power gate control. Used as software override.
NOTE: Not related to oscillator.
8
L1_PWRGATE
L1 power gate control. Used as software override.
NOTE: Not related to oscillator.
7
REFTOP_IBIAS_
OFF
Low power reftop ibias disable.
NOTE: Not related to oscillator.
6
LPBG_TEST
Low power bandgap test bit.
NOTE: Not related to oscillator.
5
LPBG_SEL
Bandgap select.
NOTE: Not related to oscillator.
0
Normal power bandgap
1
Low power bandgap
4
OSC_SEL
Select the source for the 24MHz clock.
0
XTAL OSC
1
RC OSC
3–1
RC_OSC_PROG
RC osc. tuning values.
0
RC_OSC_EN
RC Osc. enable control.
0
Use XTAL OSC to source the 24MHz clock
1
Use RC OSC
XTALOSC 24MHz Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4112
NXP Semiconductors

<!-- page 4113 -->

60.5.3
XTAL OSC Configuration 0 Register
(XTALOSC24M_OSC_CONFIG0n)
This register is used to configure the 24MHz RC oscillator.
Address: 20C_8000h base + 2A0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
RC_OSC_PROG_CUR
-
HYST_MINUS
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
HYST_PLUS
RC_OSC_PROG
INVERT
BYPASS
ENABLE
START
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
1
0
0
0
0
0
XTALOSC24M_OSC_CONFIG0n field descriptions
Field
Description
31–24
RC_OSC_
PROG_CUR
The current tuning value in use.
23–20
-
Reserved.
19–16
HYST_MINUS
Negative hysteresis value. Subtracted from target value before comparison. This, along with HYST_PLUS
creates a range.
15–12
HYST_PLUS
Positive hysteresis value. Added to target value before comparison. This, along with HYST_MINUS
creates a range.
11–4
RC_OSC_PROG
RC osc. tuning values.
3
INVERT
Invert the stepping of the calculated RC tuning value.
Table continues on the next page...
Chapter 60 Crystal Oscillator (XTALOSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4113

<!-- page 4114 -->

XTALOSC24M_OSC_CONFIG0n field descriptions (continued)
Field
Description
2
BYPASS
Bypasses any calculated RC tuning value and uses the programmed register value.
1
ENABLE
Enables the tuning logic to calculate new RC tuning values. Disabling essentially freezes the state of the
calculation.
0
START
Start/stop bit for the RC tuning calculation logic. If stopped the tuning logic is reset.
60.5.4
XTAL OSC Configuration 1 Register
(XTALOSC24M_OSC_CONFIG1n)
This register is used to configure the 24MHz RC oscillator.
Address: 20C_8000h base + 2B0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
COUNT_RC_CUR
-
COUNT_RC_TRG
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
1
0
1
1
1
0
1
1
1
0
XTALOSC24M_OSC_CONFIG1n field descriptions
Field
Description
31–20
COUNT_RC_
CUR
The current tuning value in use.
19–12
-
Reserved
COUNT_RC_
TRG
The target count used to tune the RC OSC frequency. Essentially the number of desired RC Osc clock
cycles within 1 32KHz clock cycle.
XTALOSC 24MHz Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4114
NXP Semiconductors

<!-- page 4115 -->

60.5.5
XTAL OSC Configuration 2 Register
(XTALOSC24M_OSC_CONFIG2n)
This register is used to configure the 24MHz RC oscillator.
Address: 20C_8000h base + 2C0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
CLK_1M_ERR_FL
-
MUX_1M
ENABLE_1M
W
Reset
0
0
0
0
0
0
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
-
COUNT_1M_TRG
W
Reset
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
1
0
0
0
1
0
XTALOSC24M_OSC_CONFIG2n field descriptions
Field
Description
31
CLK_1M_ERR_
FL
Flag indicates that the count_1m count wasn't reached within 1 32KHz period. This is intended as
feedback to software that the HW_ANADIG_OSC_CONFIG2_COUNT_1M_TRG value is too high for the
RC Osc frequency.
30–18
-
Reserved.
17
MUX_1M
Mux the corrected or uncorrected 1MHz clock to the output.
Table continues on the next page...
Chapter 60 Crystal Oscillator (XTALOSC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
4115

<!-- page 4116 -->

XTALOSC24M_OSC_CONFIG2n field descriptions (continued)
Field
Description
16
ENABLE_1M
Enable the 1MHz clock output. 0 - disabled; 1 - enabled.
15–12
-
Reserved
COUNT_1M_
TRG
The target count used to tune the RC OSC frequency. Essentially the number of desired RC Osc clock
cycles within 1 32KHz clock cycles.
XTALOSC 24MHz Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
4116
NXP Semiconductors

