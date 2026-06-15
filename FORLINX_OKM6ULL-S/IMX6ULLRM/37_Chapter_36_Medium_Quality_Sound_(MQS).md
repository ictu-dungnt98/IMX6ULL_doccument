# Chapter 36: Medium Quality Sound (MQS)

> Nguồn: `IMX6ULLRM.pdf` — trang 2377–2380

<!-- page 2377 -->

Chapter 36
Medium Quality Sound (MQS)
36.1
Overview
Medium quality sound (MQS) is used to generate medium quality audio via a standard
GPIO in the pinmux, allowing the user to connect stereo speakers or headphones to a
power amplifier without an additional DAC chip.
MQS accepts the following inputs:
• 2-channel, LSB-valid 16-bit, MSB shift-out first serial data (sdata)
• Frame sync asserting with the first bit of the frame (fs)
• Bit clock used to shift data out on the positive clock edge (bclk)
The 44 kHz or 48 kHz input signals from SAI1 are in left_justified format. MQS provides
the SNR target as no more than 20 dB for the signals below 10 kHz. The signals above 10
kHz will have worse THD+N values.
MQS provides only simple audio reproduction. No internal pop, click or distortion
artifact reduction methods are provided.
36.1.1
Block Diagram
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2377

<!-- page 2378 -->

Channel 
Split
Noise
Shaping
PWM 
Generation
mclk
generation
mclk control
Reset and Enable
bclk
fs
sdata
hmclk
hmclk_divide
pwm_ovr
reset_b
software_reset
mqs_enable
mclk
Left Data
Right Data
Lowres 
Left Data
MQS_LEFT
MQS_RIGHT
Lowres 
Right Data
Figure 36-1. Block Diagram
MQS has the following sub-modules:
1. Channel Split: Splits the I2S signals into separate left channel and right channel
audio data.
2. Noise Shaping: Uses the sigma-delta algorithm to generate low-resolution, very high
sampling audio, while the audio sampling rate is increased.
3. PWM generation: Generates the bit stream to the GPIO, which is then used to drive
the amplifier and then to drive the external speakers or headphones.
4. mclk generation: Used to generate the master clock (mclk). The frequency of mclk is
determined by the final bit duration of PWM generation module.
5. mclk control:Used as a metronome to co-ordinate the different functional blocks
working synchronously.
6. Reset and Enable: Used to generate the reset and enable logic to different clock
domains.
36.2
External Signals
The following table describes the external signals of MQS:
Table 36-1. MQS External Signals
Signal
Description
Pad
Mode
Direction
MQS_LEFT
Left signal output
GPIO1_IO01
ALT4
O
JTAG_TDI
ALT6
Table continues on the next page...
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2378
NXP Semiconductors

<!-- page 2379 -->

Table 36-1. MQS External Signals (continued)
Signal
Description
Pad
Mode
Direction
LCD_DATA23
ALT1
MQS_RIGHT
Right signal output
GPIO1_IO00
ALT4
O
JTAG_TDO
ALT6
LCD_DATA22
ALT1
36.3
Interface Signals
MQS module has the following interface signals.
Signal Name
In/Out
BitWidth
Description
Comments
reset_b
In
1
asynchronous reset
software_reset
In
1
Software reset
From GPR
mqs_enable
In
1
module enable
From GPR
pwm_ovr
In
1
PWM oversampling
ratio1—64, 0--32
From GPR
hmclk
In
1
Maximum bit clock,
used to generate the
mclk, divider ratio is
controlled by
mqs_hmclk_divide
Max 66.5MHzTypical
24.576MHz
hmclk_divide
In
8
Divider ration control for
mclk from hmclk
From GPR
bclk
In
1
bit clock from I2S signal
fs
In
1
frame sync clock from
I2S signal
sdata
In
1
serial audio data from
I2S signal
36.4
Programming Considerations
MQS has no internal programmable registers. But it does have some programmability
from IOMUXC_GPR2.
Register Bits
Name
Description
IOMUXC_GPR2[26]
MQS_OVERSAMPLE
Used to control the PWM oversampling
rate compared with mclk.
1—64,
Table continues on the next page...
Chapter 36 Medium Quality Sound (MQS)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2379

<!-- page 2380 -->

Register Bits
Name
Description
0—32.
IOMUXC_GPR2[25]
MQS_EN
MQS enable.
1—Enable MQS,
0—Disable MQS
IOMUXC_GPR2[24]
MQS_SW_RST
MQS software reset.
1—Enable software reset for MQS
0—Exit software reset for MQS
IOMUXC_GPR2[23:16]
MQS_CLK_DIV[7:0]
Divider ration control for mclk from
hmclk.
0—mclk frequency = hmclk frequency;
1—mclk frequency = ½*hmclk
frequency;
2—mclk frequency = 1/3*hmclk
frequency;
…;
n—mclk frequency = 1/(n+1)*hmclk
frequency
36.4.1
Usage Model
The user needs to program SAI1 to output 2-channel MSB-16 bit active I2S signal, and
then program the related IOMUXC_GPR2 bits.
Due to the different devices connected to MQS, and different high frequency behaviors of
the connected analog circuits, the user needs choose the appropriate MQS_CLK_DIV and
MQS_OVERSAMPLE values for the best audible effects.
Programming Considerations
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2380
NXP Semiconductors

