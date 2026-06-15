# Chapter 16: Asynchronous Sample Rate Converter (ASRC)

> Nguồn: `IMX6ULLRM.pdf` — trang 505–562

<!-- page 505 -->

Chapter 16
Asynchronous Sample Rate Converter (ASRC)
16.1
Overview
The Asynchronous Sample Rate Converter (ASRC) converts the sampling rate of a signal
associated with an input clock into a signal associated with a different output clock.
The ASRC supports concurrent sample rate conversion of up to 10 channels of about
-120dB THD+N. The ASRC supports up to three sampling rate pairs.
The incoming audio data to this chip may be received from various sources at different
sampling rates. The outgoing audio data of this chip may have different sampling rates
and it can also be associated with output clocks that are asynchronous to the input clocks.
The ASRC is implemented as a co-processor in hardware, with minimal ARM Platform
intervention required.
The following figure is a system view of the connection between the ASRC block and
other blocks.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
505

<!-- page 506 -->

Peripheral Bus
DMA reqs
Interrupt req
asrck_3
asrck_b
asrck_2
asrck_a
asrck_1
asrck_9
asrck_0
asrck_d
asrck_6
asrck_c
asrck_4
ASRC
SPDIF
asrck_8
SPDIF Tx clock
SPDIF Rx clock
ASRCKI (clock controlled by CCM_CDCDR Register
asrck_5
SPDIF_CLK_PODF and SPDIF1_CLK_PRED bits)
Pad Select: KEY_ROW3 / GPIO_0 / GPIO_18 (configured by 
IOMUXC_ASRC_CLOCK_6_SELECT_INPUT[DAISY])
Figure 16-1. General System Overview
The following figure is the ASRC block diagram.
The red dotted line designates the ASRC block. Objects outside the dotted line represent
SoC-level resources.
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
506
NXP Semiconductors

<!-- page 507 -->

clocks
DMA
reqs.
Interrupt
reqs
Peripheral BUS
ROM
DP RAM
PROM
MEM_IF
interrupt logic
REG_IF
FIFO CTRL
AGU
FP
PCU
ALU
Other small Logic
FP Peripherals
Clock Src
Selector &
Divider
DSL
task queue
gen.
task queue
FIFO
Figure 16-2. ASRC block diagram
16.1.1
Features
Table 16-1. ASRC Specifications
Parameters
Test Conditions
Minimum
Typical
Maximum
Unit
Channels Supported
0 1
n (0-10)
10
Pairs of Rate Conversion
1
-
3
THD+N
120 MHz < FsASRC2
<160 MHz
-120
dB
Dynamic Range
144
dB
Settling Time
40
ms
Comment:
1.
When a pair has zero channels, the pair will be disabled, although the pair enable bit may be set in ASRCTR register.
2.
FsASRC is the processing clock of ASRC block.
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
507

<!-- page 508 -->

Other Features:
• Any number (0-10) of contiguous channels can be associated to one of the sampling
rate pairs.
• Support user-programmable threshold for the input/output FIFOs.
• Support flexible 8/16/24-bit width of input data, and 16/24-bit width of output data.
• Designed for rate conversion between 44.1 kHz, 32 kHz, 48 kHz, 96 kHz, and 192
kHz. The useful signal bandwidth is below 24 kHz.
• Other input sampling rates in the range of 8 kHz to 200 kHz is also supported, but
possibly with less desirable bandwidth.
• Other output sampling rates in the range of 30 kHz to 200 kHz is also supported, but
possibly with less desirable bandwidth.
• Automatic accommodation to slow variations in the incoming and outgoing sampling
rates.
• Linear phase
• Tolerant to sample clock jitter
Clock/Data Connections
• The sampling rate clocks are directly connected to the ASRC block, the ratio
estimation of the input clocks with output clocks are done in ASRC hardware when
both input/output sampling clocks are physically available.
• When both the input sampling clock and the output sampling clock are physically
available, the rate conversion can work by configuring the physical clocks.
• When the input sampling clock is not physically available, the rate conversion can
still work by setting ideal-ratio values into ASRC interface registers.
• The clock signals come from the following blocks:
• Receiving bit clock and transmitting bit clock
• SPDIF, receiving bit clock and transmitting bit clock
• other audio peripherals etc.
• The exchange of audio data is done by the processor accessing ASRC block through
registers defined on shared peripheral bus.
16.1.2
Modes of Operation
See ASRC Memory Map/Register Definition for a definition of the registers and
parameters used in ASRC.
16.1.2.1
Data Transfer Schemes
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
508
NXP Semiconductors

<!-- page 509 -->

16.1.2.1.1
Data Input Modes
The input mode for each of the three channel sets may be set independently. Three modes
of supplying data to the ASRC input FIFOs are available:
• Polling
• Interrupt
• DMA
In all input-data transfer schemes, the ASRC fetches data from each enabled FIFO and
processes the data sample-by-sample after each rising edge of the associated input
sampling clock until the FIFO level reaches a threshold.
After the threshold is reached, the ASRC requests data. The FIFO size for each channel
set is 64 samples and the threshold is set at 32 samples. The threshold can be defined by
interface registers ASRMCRx, x=A, B or C.
If the ASRC attempts to fetch data from an empty FIFO, an error is generated and the
ASRSTR_AOLE bit is set. If the ASRC overload interrupt is enabled (ASRIER_AOLIE
bit is set), an interrupt is generated.
When writing data to an input FIFO, you must ensure that it is in a predefined sequence.
For example, when writing to an input FIFO, the sequence should be: channel_0,
channel_1, channel_2,..., channel_n, channel_0, channel_1, channel_2, etc. Here
channel_n stands for the data intended for the n-th channel. The hardware will re-allocate
each data to its corresponding channel FIFO. The channel being re-allocated is shown by
ASRCCR_ACIx, x=A,B or C.
Mode 1 (Polling Mode)
Polling mode is the default mode following power-on or individual reset, and is selected
by clearing the associated channel set A, B, or C data-input interrupt enable bit
(ASRIER_ADIEx, where x=A, B or C). In this mode, data-input interrupts are disabled.
When the FIFO level is below the threshold, the associated status bit (ASRSTR_AIDEx,
where x=A, B, or C) is set. To clear the status bit, the FIFO must be written with enough
data to raise the level above the threshold.
Mode 2 (Interrupt Mode)
The ASRC input FIFOs can also be serviced by interrupts. To enable interrupts, the
corresponding data-input interrupt enable bits (ASRIER_ADIEx, where x=A, B, or C)
should be set. An interrupt is automatically generated any time the input FIFO level is
below the threshold. The interrupt is cleared when enough data is written to the FIFO to
raise the level above the threshold.
Mode 3 (DMA Mode)
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
509

<!-- page 510 -->

The ASRC input FIFOs can also be filled using DMA. In this mode, the data-input
interrupt-enable bits (ASRIER_ADIEx, where x=A, B, or C) should be cleared and the
DMA controller should be configured to use the ASRC as a request source.
16.1.2.1.2
Data Output Modes
The output mode for each of the 3 channel sets (A, B, and C) may be set independently.
Three modes of retrieving data from the ASRC output FIFOs are available:
• Polling
• Interrupt
• DMA
In all output-data transfer schemes, the ASRC places a processed sample into the
associated output FIFO. After a threshold is reached, the ASRC requests that data be
transferred out of the FIFO.
The FIFO size for each channel set is 64 samples and the threshold is set at 32 samples.
The threshold can be defined by interface registers ASRMCRx, x=A, B or C.
If the ASRC attempts to place data into a FIFO that is already full, an error is generated
and the ASRSTR_AOLE bit is set. If the ASRC overload interrupt is enabled
(ASRIER_AOLIE bit is set), an interrupt is generated.
Each output FIFO is organized in the same channel order in which the associated input
FIFO was written.
Three transfer modes are supported by Interface Block.
Mode 1 (Polling Mode)
The ASRC output FIFOs can be serviced by polling. In this mode, ensure the associated
output-data interrupt enable bit (ASRIER_ADOEx, where x=A, B, or C) is cleared. In
this mode, all output-data interrupts are disabled. Any time the output FIFO exceeds the
threshold the associated status bit (ASRSTR_AODFx, where x=A, B, or C) is set. To
clear the status bit, enough data must be read from the associated output FIFO to lower
the level below the threshold.
Mode 2 (Interrupt Mode)
The ASRC output FIFOs may also be serviced using interrupts. To enable this mode, the
corresponding output-data interrupt-enable bits (ASRIER_ADOEx, where x=A, B, or C)
should be set. Any time the output FIFO level exceeds the threshold, an interrupt is
automatically generated. The interrupt is cleared when enough data is read from the FIFO
to lower the level below the threshold.
Mode 3 (DMA Mode)
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
510
NXP Semiconductors

<!-- page 511 -->

The ASRC output FIFOs can also be read using DMA. In this mode, the output-data
interrupt-enable bits (ASRIER_ADOEx, where x=A, B, or C) should be cleared and the
DMA controller should be configured to use the ASRC as a request source.
16.1.2.2
Word Alignment Supported
16.1.2.2.1
Input Data Alignment Modes
The position and length of input data word to the input data FIFOs ASRDIA, ASRDIB,
ASRDIC are programmable. The control bits are defined in ASRMCR1x {x=A, B, or C}.
It supports the following modes.
Table 16-2. Input Data Alignment
Format
Bit Number
3
1
3
0
2
9
2
8
2
7
2
6
2
5
2
4
2
3
2
2
2
1
2
0
1
9
1
8
1
7
1
6
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
8-bit LSB
Aligned
7
6
5
4
3
2
1
0
8-bit MSB
Aligned
7
6
5
4
3
2
1
0
16-bit LSB
Aligned
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
16-bit MSB
Aligned
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
24-bit LSB
Aligned
2
3
2
2
2
1
2
0
1
9
1
8
1
7
1
6
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
24-bit MSB
Aligned
2
3
2
2
2
1
2
0
1
9
1
8
1
7
1
6
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
16.1.2.2.2
Output Data Alignment Modes
The position and length of output data word from the output data FIFOs ASRDOA,
ASRDOB, ASRDOC are programmable. The control bits are defined in ASRMCR1x
{x=A, B, or C}. It supports the following modes.
Table 16-3. Output Data Alignment
Format
Bit Number
3
1
3
0
2
9
2
8
2
7
2
6
2
5
2
4
2
3
2
2
2
1
2
0
1
9
1
8
1
7
1
6
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
16-bit LSB
Aligned
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
511

<!-- page 512 -->

Table 16-3. Output Data Alignment (continued)
Format
Bit Number
3
1
3
0
2
9
2
8
2
7
2
6
2
5
2
4
2
3
2
2
2
1
2
0
1
9
1
8
1
7
1
6
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
16-bit LSB
Aligned with
Sign Extension
1
5
1
5
1
5
1
5
1
5
1
5
1
5
1
5
1
5
1
5
1
5
1
5
1
5
1
5
1
5
1
5
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
16-bit MSB
Aligned
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
24-bit LSB
Aligned
2
3
2
2
2
1
2
0
1
9
1
8
1
7
1
6
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
24-bit LSB
Aligned with
Sign Extension
2
3
2
3
2
3
2
3
2
3
2
3
2
3
2
3
2
3
2
2
2
1
2
0
1
9
1
8
1
7
1
6
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
24-bit MSB
Aligned
2
3
2
2
2
1
2
0
1
9
1
8
1
7
1
6
1
5
1
4
1
3
1
2
1
1
1
0
9
8
7
6
5
4
3
2
1
0
16.2
Clocks
The table found here describes the clock sources for ASRC.
Please see clock control block for clock setting, configuration and gating information.
Table 16-4. ASRC Clocks
Clock name
Clock Root
Description
asrck_clock_d
spdif1_clk_root
ASRC module clock (SPDIF clock)
ipg_clk
ahb_clk_root
Peripheral clock
mem_clk
ahb_clk_root
Peripheral access clock
16.3
Interrupts
ASRC has several interrupts events.
The priorities are shown in the following table.
Table 16-5. Interrupt Priorities/Vector
Priority
Offset
Description
lowest
0x0
ASRC Pair A input data needed
0x2
ASRC Pair B input data needed
Table continues on the next page...
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
512
NXP Semiconductors

<!-- page 513 -->

Table 16-5. Interrupt Priorities/Vector (continued)
Priority
Offset
Description
0x4
ASRC Pair C input data needed
0x6
ASRC Pair A output data ready
0x8
ASRC Pair B output data ready
0xA
ASRC Pair C output data ready
highest
0xC
ASRC Overload
16.4
DMA requests
ASRC has six DMA requests. They are directly connected to the lowest six status bits in
the ASRSTR register. For some ARM platforms, the six status bits are directly connected
to SDMA or HDMA as DMA event signals.
Table 16-6. DMA requests
Type
Description
0
ASRC Pair A input data needed
1
ASRC Pair B input data needed
2
ASRC Pair C input data needed
3
ASRC Pair A output data ready
4
ASRC Pair B output data ready
5
ASRC Pair C output data ready
16.5
Functional Description
This section provides a complete functional description of the block.
16.5.1
Algorithm Description
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
513

<!-- page 514 -->

16.5.1.1
Signal processing flow
General
Fsin
Pre-Decimation Filter
Low-pass
Half-band
x0.5
Down-
Sampling
x2
UpSampling
(1)
(2)
(3)
Low-Pass
Pre-Filter
Polyphase
Filter
11 taps
Fsppout
x2
UpSampling
Low-Pass
Low-pass
Half-band
x0.5
Down-
Sampling
(1)
(2)
(3)
Fsout
Post Up Sampling Filter
Post Decimation Filter
Figure 16-3. Signal processing configurations
The figure above shows the possible configurations of the ASRC. Each configuration
consists of 2 to 4 stages.
• x2 up-sampling rate expander (zero insertion only) (input branch 1), direct
connection (input branch 2), or low-pass pre decimation filter (consisting of a low-
pass half-band FIR filter with x0.5 downsampling rate decimator) (input branch 3),
• low-pass pre-filter, the low-pass bandwidth is at most 0.25 x Fs, where Fs is the
sampling rate of the input signal to this low-pass pre-filter,
• polyphase filter,
• x2 post upsampling filter (consisting of a x2 up-sampling rate expander (zero
insertion only) with low-pass half-band FIR filter) (output branch 1), direct
connection (output branch 2), or low-pass post decimation filter (consisting of a low-
pass half-band FIR filter with x0.5 downsampling rate decimator) (output branch 3).
By flowing through different processing branches and different setups of the pre-filter,
this ASRC scheme can be used to handle different rate conversion requirements.
• Configuration (a): Input Branch 1+Output Branch 1:
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
514
NXP Semiconductors

<!-- page 515 -->

The signal bandwidth observed before the polyphase filter is at most BWin = Fsin/2.
The signal sampling rate of the polyphase filter output is Fsppout = Fsout/2.
• Configuration (b): Input Branch 1+Output Branch 2:
The signal bandwidth observed before the polyphase filter is at most BWin = Fsin/2.
The signal sampling rate of the polyphase filter output is Fsppout = Fsout.
• Configuration (c): Input Branch 1+Output Branch 3:
The signal bandwidth observed before the polyphase filter is at most BWin = Fsin/2.
The signal sampling rate of the polyphase filter output is Fsppout = 2Fsout.
• Configuration (d): Input Branch 2+Output Branch 1:
The signal bandwidth observed before the polyphase filter is at most BWin = Fsin/4.
The signal sampling rate of the polyphase filter output is Fsppout = Fsout/2.
• Configuration (e): Input Branch 2+Output Branch 2:
The signal bandwidth observed before the polyphase filter is at most BWin = Fsin/4.
The signal sampling rate of the polyphase filter output is Fsppout = Fsout.
• Configuration (f): Input Branch 2+Output Branch 3:
The signal bandwidth observed before the polyphase filter is at most BWin = Fsin/4.
The signal sampling rate of the polyphase filter output is Fsppout = 2Fsout.
• Configuration (g): Input Branch 3+Output Branch 1:
The signal bandwidth observed before the polyphase filter is at most BWin = Fsin/8.
The signal sampling rate of the polyphase filter output is Fsppout = Fsout/2.
• Configuration (h): Input Branch 3+Output Branch 2:
The signal bandwidth observed before the polyphase filter is at most BWin = Fsin/8.
The signal sampling rate of the polyphase filter output is Fsppout = Fsout.
• Configuration (i): Input Branch 3+Output Branch 3:
The signal bandwidth observed before the polyphase filter is at most BWin = Fsin/8.
The signal sampling rate of the polyphase filter output is Fsppout = 2Fsout.
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
515

<!-- page 516 -->

Table 16-7. Pre-processing, post-processing options
{Pre_Proc,
Post_Proc}
Fsout (KHz)
8
12
16
24
32
44.1
48
64
88.2
96
128
192
Fsin
(KHz)
8
{0,1}
{0,1}
{0,1}
{0,0}
{0,0}
{0,0}
{0,0}
{0,0}
{0,0}
{0,0}
{0,0}
{0,0}
12
{0,2}
{0,1}
{0,1}
{0,1}
{0,1}
{0,0}
{0,0}
{0,0}
{0,0}
{0,0}
{0,0}
{0,0}
16
{1,2}
{0,2}
{0,1}
{0,1}
{0,1}
{0,1}
{0,1}
{0,0}
{0,0}
{0,0}
{0,0}
{0,0}
24
{1,2}
{1,2}
{0,2}
{0,1}
{0,1}
{0,1}
{0,1}
{0,1}
{0,0}
{0,0}
{0,0}
{0,0}
32
{1,2}
{1,2}
{1,2}
{0,2}
{0,1}
{0,1}
{0,1}
{0,1}
{0,1}
{0,0}
{0,0}
{0,0}
44.1
{2,2}
{1,2}
{1,2}
{0,2}
{0,2}
{0,1}
{0,1}
{0,1}
{0,1}
{0,1}
{0,0}
{0,0}
48
{2,2}
{1,2}
{1,2}
{1,2}
{0,2}
{0,2}
{0,1}
{0,1}
{0,1}
{0,1}
{0,1}
{0,0}
64
{2,2}
{2,2}
{1,2}
{1,2}
{0,2}
{0,2}
{0,2}
{0,1}
{0,1}
{0,1}
{0,1}
{0,0}
88.2
NA
{2,2}
{2,2}
{1,2}
{1,2}
{1,2}
{1,2}
{1,1}
{1,1}
{1,1}
{1,1}
{1,1}
96
NA
{2,2}
{2,2}
{1,2}
{1,2}
{1,2}
{1,2}
{1,1}
{1,1}
{1,1}
{1,1}
{1,1}
128
NA
NA
{2,2}
{2,2}
{1,2}
{1,2}
{1,2}
{1,1}
{1,1}
{1,1}
{1,1}
{1,1}
192
NA
NA
NA
{2,2}
{2,2}
{2,2}
{2,2}
{2,1}
{2,1}
{2,1}
{2,1}
{2,1}
NOTE: In the {Pre_Proc, Post_Proc} pair, the meaning of the values are:
Pre_Proc:
• 0 --- Pre-processing Branch 1 as shown in Figure 16-3
• 1 --- Pre-processing Branch 2 as shown in Figure 16-3
• 2 --- Pre-processing Branch 3 as shown in Figure 16-3, decimation-by-2
Post_Proc:
• 0 --- Post-processing Branch 1 as shown in Figure 16-3
• 1 --- Post-processing Branch 2 as shown in Figure 16-3
• 2 --- Post-processing Branch 3 as shown in Figure 16-3
The latencies of the different option can be roughly calculated as follows:
• For PreProc = 0, PostProc = 1 : min latency = constant_A / input-sample-rate +
constant_B / output-sample-rate
• For PreProc = 0, PostProc = 0 : min latency = constant_A / input-sample-rate +
constant_C / output-sample-rate
• For PreProc = 1, PostProc = 1 : min latency = constant_D / input-sample-rate +
constant_B / output-sample-rate
The constants above (e.g., constant_A means the Constant for Preproc = 0, constant_B
means the Constant for Postproc = 1, ...) are only influenced by the PreProc/PostProc and
(input/output) sampling rate to which they are connected. Input latencies have no
relationship with the output latencies, but both elements add together to form the total
latencies.
For a rough estimation, the constants can be set as:
• Constant for Preproc = 0: 39
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
516
NXP Semiconductors

<!-- page 517 -->

• Constant for Preproc = 1: 78.5
• Constant for Preproc = 2: 235
• Constant for Postproc = 0: 42.5
• Constant for Postproc = 1: 8.5
• Constant for Postproc = 2: 172
The max latency can be derived from this value by using the following formula (where
32 means the input/output FIFO depth that will arouse data transfer):
• max latency = min latency + 32 / input-sample-rate + 32 / output-sample-rate
16.5.1.2
Operation of the Filter
16.5.1.2.1
Support of Physical Clocks
This design supports physical sampling clocks. The clocks can be provided by:
• Sony/Phillips digital interface (SPDIF)
• Serial Audio Interface (SAI)
• Core master clock derivative as ASRCK1
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
517

<!-- page 518 -->

asrck_clock_0
asrck_clock_1
asrck_clock_2
asrck_clock_3
asrck_clock_4
asrck_clock_5
asrck_clock_6
asrck_clock_7
asrck_clock_8
asrck_clock_9
asrck_clock_a
asrck_clock_b
asrck_clock_c
asrck_clock_d
MUX
AICDA 0 - AICDA2
AICPA 0 - AICPA2
Input Clock
Divider A
Input Clock
Divider B
Input
Prescaler A
Input
Prescaler B
AICDB0 - AICDB2
Input clock A
Input clock B
Input
Prescaler C
Input Clock
Divider C
Input clock C
asrck_clock_0
asrck_clock_1
asrck_clock_2
asrck_clock_3
asrck_clock_4
asrck_clock_5
asrck_clock_6
asrck_clock_7
asrck_clock_8
asrck_clock_9
asrck_clock_a
asrck_clock_b
asrck_clock_c
asrck_clock_d
MUX
Input Clock
Divider A
Input Clock
Divider B
Output
Prescaler A
Output
Prescaler B
Output clock A
Output clock B
Output
Prescaler C
Input Clock
Divider C
Output clock C
AOCSA[3:0]
AOCSB[3:0]
AOCSC[3:0]
AICSA[3:0]
AICSB[3:0]
AICSC[3:0]
AICPB0 - AICPB2
AICDC0 - AICDC2
AICPC0 - AICPC2
AOCDA0 - AOCDA2
AOCPA0 - AOCPA2
AOCDB0 - AOCDB2
AOCPB0 - AOCPB2
AOCDC0 - AOCDC2
AOCPC0 - AOCPC2
Figure 16-4. Clock Source Selector and Divider
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
518
NXP Semiconductors

<!-- page 519 -->

Software can set the ASRC Clock Source Register (ASRCSR) and the Clock Divider
Register to select the desired clock source and divide it to the needed sample rate clock
for use by the ASRC. The clocks have the following restriction. If the prescaler is set to
1, the clock divider can only be set to 1 and the clock source must have a 50% duty cycle.
16.6
Startup Procedure
The following example shows the normal setup procedure for the ASRC block.
 #include "asrc_common.h"
 #include "stdio.h"
 #include "soc_api.h"
 int incnt=0; 
 int outcnt=0; 
 #include "wy_ideal_ratio_dataini_part.h" 
 WORD   IdealRatio_High=0x04; // 
 WORD   IdealRatio_Low=0x0; // 
 void asrc_config_alloc(WORD ASRCTR_VAL, WORD ASRIER_VAL, WORD ASRCNCR_VAL,
                            WORD ASRCFG_VAL, WORD ASRCDR1_VAL, WORD ASRCDR2_VAL,
                            WORD ASRCSR_VAL) 
 {  // Disable ASRC   
     reg32_write(ASRC_ASRCTR,0x0);  
     reg32_write(ASRC_ASRCTR,ASRCTR_VAL);  
     reg32_write(ASRC_ASRIER,ASRIER_VAL);  
     reg32_write(ASRC_ASRIEM,0x0);  
     reg32_write(ASRC_ASRCNCR,ASRCNCR_VAL);  
     reg32_write(ASRC_ASRCFG,ASRCFG_VAL);  
     reg32_write(ASRC_ASRCDR1,ASRCDR1_VAL);  
     reg32_write(ASRC_ASRCDR2,ASRCDR2_VAL);
     reg32_write(ASRC_ASRCSR, ASRCSR_VAL);
     reg32_write(ASRC_ASRPM1, 0x7fffff);
     reg32_write(ASRC_ASRPM2, 0x255555);
     reg32_write(ASRC_ASRPM3, 0xff7280);
     reg32_write(ASRC_ASRPM4, 0xff7280);
     reg32_write(ASRC_ASRPM5, 0xff7280);
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
519

<!-- page 520 -->

     reg32_write(ASRC_ASRQFIFO1,0x001f00);
     reg32_write(ASRC_ASRMCRA,0x001f00);
     reg32_write(ASRC_ASRMCRB,0x001f00);
     reg32_write(ASRC_ASRMCRC,0x001f00);
 }
  void sim_ideal_ratio()
   {
     WORD tmp32bit;
     #define ASRSTR_AIDEA_MASK  0x1
     #define ASRSTR_AODFA_MASK  0x1 <<3
     #define ASRSTR_AOLE_MASK   0x1<<6
     #define ASRCTR_DBG_EN             1<<23
     #define ASRCTR_IDRA               1<<13
     #define ASRCTR_USRA               1<<14
     #define ASRC_CLK_PRED_RSTRICTED 0<<28
     #define ASRC_CLK_PRED_DFLT      1<<28 // default: 596MHz div by 2
     #define ASRC_CLK_PRED_DIV3      2<<28 // 596MHz div by 3
     #define ASRC_CLK_PRED_DIV4      3<<28 // 596MHz div by 4
     #define ASRC_CLK_PRED_DIV5      4<<28 // 596MHz div by 5
     #define ASRC_CLK_PRED_DIV6      5<<28 // 596MHz div by 6
     #define ASRC_CLK_PRED_DIV7      6<<28 // 596MHz div by 7
     #define ASRC_CLK_PRED_DIV8      7<<28 // 596MHz div by 8
     #define ECSPI_CLK_PRED_DFLT     1<<25
     #define ECSPI_CLK_PODF_DFLT     1<<19
     #define ASRC_CLK_PODF_DIV1      0<<9  // pred output divide by 1 again
     #define ASRC_CLK_PODF_DIV2      1<<9  // pred output divide by 2 again
     #define ASRC_CLK_PODF_DIV3      2<<9  // pred output divide by 3 again
     #define ASRC_CLK_PODF_DIV4      3<<9  // pred output divide by 4 again
     #define ASRC_CLK_PODF_DFLT      4<<9  // default: pred output divide by 5 again
     #define ASRC_CLK_PODF_DIV6      5<<9  // pred output divide by 6 again
     #define ASRC_CLK_PODF_DIV7      6<<9  // pred output divide by 7 again
     #define ASRC_CLK_PODF_DIV25     24<<9  // pred output divide by 7 again
     #define IEEE_CLK_PRED_DFLT      1<<6  // 
Startup Procedure
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
520
NXP Semiconductors

<!-- page 521 -->

     #define IEEE_CLK_PODF_DFLT      4     // 
     #define ASR_HFA_HFB         0
     #define ASR_PREMODA_UP2         0<<6
     #define ASR_PREMODA_DIR         1<<6
     #define ASR_PREMODA_DN2         2<<6
     #define ASR_PREMODA_PAS         3<<6
     #define ASR_POSTMODA_UP2         0<<8
     #define ASR_POSTMODA_DIR         1<<8
     #define ASR_POSTMODA_DN2         2<<8
      reg32_write(CCM_CSCDR2, ASRC_CLK_PRED_DIV8|ECSPI_CLK_PRED_DFLT|ECSPI_CLK_PODF_DFLT|
ASRC_CLK_PODF_DIV25|IEEE_CLK_PRED_DFLT|IEEE_CLK_PODF_DFLT);
      // Disable the ASRC
      reg32_write(ASRC_ASRCTR, 0x0);
      // program AHB clocks
      tmp32bit = reg32_read(CCM_CBCDR);
      tmp32bit = tmp32bit & (~0x00001C00); 
      //tmp32bit = tmp32bit | (0x00000C00); // AHB 100MHz // divided-by-4
      //tmp32bit = tmp32bit | (0x00001000); // AHB 80MHz // divided-by-5
      //tmp32bit = tmp32bit | (0x00001400); // AHB 66MHz // divided-by-6
      //tmp32bit = tmp32bit | (0x00001800); // AHB 57MHz // divided-by-7
      tmp32bit = tmp32bit | (0x00001C00); // AHB 50MHz // divided-by-8
      reg32_write(CCM_CBCDR, tmp32bit); // enable all perihperal clocks during all modes, 
except stop mode
      while ( (reg32_read(CCM_CDHIPR) & 0x00008) != 0);
             asrc_config_alloc ( 0x002 | ASRCTR_IDRA | ASRCTR_USRA,    // ASRCTR_VAL, Use 
Ratio input, use ideal ratio, Enable Pair A,
             0x0, //0x09,                                              // ASRIER_VAL, Open 
PairA input and output interrupt
             0x002,     // ASRCNCR_VAL, assign 2 channels to Pair A
             ASR_PREMODA_DIR | ASR_POSTMODA_DIR | ASR_HFA_HFB,         // ASRCFG_VAL,  
POSTMODA=downsampling by 2 ; PREMODA=downsampling by 2
             0x03b03b , // ASRCDR1_VAL, AOCPA=3(FoutA/(2^3)); AICPA=3(FinA/(2^3)); 
AOCDA=7(div 8); AICDA=7(div 8);
             0x0  ,     // ASRCDR2_VAL, 
             0x00d00d   // ASRCSR_VAL,  AOCSA=d: bit clock d: ASRCK1 clk from CCM; AICSA=d: 
bit clock d: ASRCK1 clock from CCM;
             );
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
521

<!-- page 522 -->

      reg32_write(ASRC_ASRIDRHA, 0x04); // 
      reg32_write(ASRC_ASRIDRLA, 0x0); // Ideal Ratio is set to be 1.
      #define OUTFIFO_THRESH_0  8<<12
      #define INFIFO_THRESH_1   32
      reg32_write(ASRC_ASRMCRA, OUTFIFO_THRESH_0 | INFIFO_THRESH_1);
      reg32clrbit(ASRC_ASRMCRA, 23);   // zeroize Pair A buffers
      reg32setbit(ASRC_ASRMCRA, 21);   // stall conversion in case of near full/near empty 
condition
      reg32clrbit(ASRC_ASRMCRA, 20); // Do not bypass polyA filter
      // Set ASRC Interrupt
      //CAPTURE_INTERRUPT(ASRC_INT_ROUTINE, asrc_handler);
      //enable_hdler(ASRC_INT_NUM);
      disable_hdler(ASRC_INT_NUM);
      incnt=0;
      outcnt=0;
      reg32setbit(ASRC_ASRCTR,0); // enable ASRC
      #define ASRCFG_INIA_FINISH  0x1<<21
      while ( (reg32_read(ASRC_ASRCFG) & ASRCFG_INIA_FINISH) == 0); // wait for ini finished.
      // Polling
          while (outcnt < 100) < 
      {   
              int ii;
              if ( (reg32_read(ASRC_ASRSTR) & ASRSTR_AIDEA_MASK) != 0 )
               {
                 for (ii=0;ii<2;ii++)</codeblock
                   { 
                      reg32_write(ASRC_ASRDIA,asrc_input_array[incnt]);     // feed in input 
data
                      reg32_write(ASRC_ASRDIA,asrc_input_array[incnt]);     // feed in input 
data
                      incnt=(incnt+1)%128;
                   }
                }
              if ( (reg32_read(ASRC_ASRSTR) & ASRSTR_AODFA_MASK) != 0 )
               {
Startup Procedure
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
522
NXP Semiconductors

<!-- page 523 -->

                   for (ii=0;ii<2;ii++)<
                     {
                       WORD TempRdOut;
                       TempRdOut=reg32_read(ASRC_ASRDOA);  // get output data
                       TempRdOut=reg32_read(ASRC_ASRDOA);  // get output data
                       outcnt=outcnt+1;
                     }
                 } 
              if ( (reg32_read(ASRC_ASRSTR) & ASRSTR_AOLE_MASK) != 0 )
               {
                   reg32_write(ASRC_ASRSTR,ASRSTR_AOLE_MASK);      // clear overloading 
errors
                }
             }
         reg32clrbit(ASRC_ASRCTR,0); // disable ASRC
   }
16.7
ASRC Memory Map/Register Definition
All useful registers are listed in the memory map below. The access of undefined
registers will behave as normal registers.
All the interface registers are LSB aligned except the input FIFOs and the output FIFOs,
and each register has only 24 effective bits.
The input FIFO and output FIFO word alignment can be defined using
ASRMCR1{A,B,C} registers in 32-bit interface system.
ASRC memory map
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
203_4000
ASRC Control Register (ASRC_ASRCTR)
32
R/W
0000_0000h
16.7.1/526
203_4004
ASRC Interrupt Enable Register (ASRC_ASRIER)
32
R/W
0000_0000h
16.7.2/529
203_400C
ASRC Channel Number Configuration Register
(ASRC_ASRCNCR)
32
R/W
0000_0000h
16.7.3/530
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
523

<!-- page 524 -->

ASRC memory map (continued)
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
203_4010
ASRC Filter Configuration Status Register
(ASRC_ASRCFG)
32
R/W
0000_0000h
16.7.4/532
203_4014
ASRC Clock Source Register (ASRC_ASRCSR)
32
R/W
0000_0000h
16.7.5/534
203_4018
ASRC Clock Divider Register 1 (ASRC_ASRCDR1)
32
R/W
0000_0000h
16.7.6/537
203_401C
ASRC Clock Divider Register 2 (ASRC_ASRCDR2)
32
R/W
0000_0000h
16.7.7/538
203_4020
ASRC Status Register (ASRC_ASRSTR)
32
R
0000_0000h
16.7.8/539
203_4040
ASRC Parameter Register n (ASRC_ASRPMn1)
32
R/W
0000_0000h
16.7.9/542
203_4044
ASRC Parameter Register n (ASRC_ASRPMn2)
32
R/W
0000_0000h
16.7.9/542
203_4048
ASRC Parameter Register n (ASRC_ASRPMn3)
32
R/W
0000_0000h
16.7.9/542
203_404C
ASRC Parameter Register n (ASRC_ASRPMn4)
32
R/W
0000_0000h
16.7.9/542
203_4050
ASRC Parameter Register n (ASRC_ASRPMn5)
32
R/W
0000_0000h
16.7.9/542
203_4054
ASRC ASRC Task Queue FIFO Register 1
(ASRC_ASRTFR1)
32
R/W
0000_0000h
16.7.10/
543
203_405C
ASRC Channel Counter Register (ASRC_ASRCCR)
32
R/W
0000_0000h
16.7.11/
544
203_4060
ASRC Data Input Register for Pair x (ASRC_ASRDIA)
32
W
0000_0000h
16.7.12/
545
203_4064
ASRC Data Output Register for Pair x (ASRC_ASRDOA)
32
R
0000_0000h
16.7.13/
545
203_4068
ASRC Data Input Register for Pair x (ASRC_ASRDIB)
32
W
0000_0000h
16.7.12/
545
203_406C
ASRC Data Output Register for Pair x (ASRC_ASRDOB)
32
R
0000_0000h
16.7.13/
545
203_4070
ASRC Data Input Register for Pair x (ASRC_ASRDIC)
32
W
0000_0000h
16.7.12/
545
203_4074
ASRC Data Output Register for Pair x (ASRC_ASRDOC)
32
R
0000_0000h
16.7.13/
545
203_4080
ASRC Ideal Ratio for Pair A-High Part (ASRC_ASRIDRHA)
32
R/W
0000_0000h
16.7.14/
546
203_4084
ASRC Ideal Ratio for Pair A -Low Part (ASRC_ASRIDRLA)
32
R/W
0000_0000h
16.7.15/
546
203_4088
ASRC Ideal Ratio for Pair B-High Part (ASRC_ASRIDRHB)
32
R/W
0000_0000h
16.7.16/
547
203_408C
ASRC Ideal Ratio for Pair B-Low Part (ASRC_ASRIDRLB)
32
R/W
0000_0000h
16.7.17/
547
203_4090
ASRC Ideal Ratio for Pair C-High Part (ASRC_ASRIDRHC)
32
R/W
0000_0000h
16.7.18/
548
203_4094
ASRC Ideal Ratio for Pair C-Low Part (ASRC_ASRIDRLC)
32
R/W
0000_0000h
16.7.19/
548
203_4098
ASRC 76 kHz Period in terms of ASRC processing clock
(ASRC_ASR76K)
32
R/W
0000_0A47h
16.7.20/
549
203_409C
ASRC 56 kHz Period in terms of ASRC processing clock
(ASRC_ASR56K)
32
R/W
0000_0DF3h
16.7.21/
550
Table continues on the next page...
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
524
NXP Semiconductors

<!-- page 525 -->

ASRC memory map (continued)
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
203_40A0
ASRC Misc Control Register for Pair A (ASRC_ASRMCRA)
32
R/W
0000_0000h
16.7.22/
551
203_40A4
ASRC FIFO Status Register for Pair A (ASRC_ASRFSTA)
32
R
0000_0000h
16.7.23/
553
203_40A8
ASRC Misc Control Register for Pair B (ASRC_ASRMCRB)
32
R/W
0000_0000h
16.7.24/
554
203_40AC
ASRC FIFO Status Register for Pair B (ASRC_ASRFSTB)
32
R
0000_0000h
16.7.25/
556
203_40B0
ASRC Misc Control Register for Pair C (ASRC_ASRMCRC)
32
R/W
0000_0000h
16.7.26/
557
203_40B4
ASRC FIFO Status Register for Pair C (ASRC_ASRFSTC)
32
R
0000_0000h
16.7.27/
559
203_40C0
ASRC Misc Control Register 1 for Pair X
(ASRC_ASRMCR1A)
32
R/W
0000_0000h
16.7.28/
560
203_40C4
ASRC Misc Control Register 1 for Pair X
(ASRC_ASRMCR1B)
32
R/W
0000_0000h
16.7.28/
560
203_40C8
ASRC Misc Control Register 1 for Pair X
(ASRC_ASRMCR1C)
32
R/W
0000_0000h
16.7.28/
560
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
525

<!-- page 526 -->

16.7.1
ASRC Control Register (ASRC_ASRCTR)
The ASRC control register (ASRCTR) is a read/write register that controls the ASRC
operations.
Address: 203_4000h base + 0h offset = 203_4000h
Bit
31
30
29
28
27
26
25
24
23
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
ATSC
ATSB
ATSA
Reserved
USRC
IDRC USRB
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
IDRB
USRA
IDRA
Reserved
ASREC
ASREB
ASREA
ASRCEN
W
SRST
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
526
NXP Semiconductors

<!-- page 527 -->

ASRC_ASRCTR field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
-
This field is reserved.
Reserved. Should be written as zero for compatibility.
22
ATSC
ASRC Pair C Automatic Selection For Processing Options
When this bit is 1, pair C will automatic update its pre-processing and post-processing options (ASRCFG:
PREMODC, ASRCFG:POSTMODC see ASRC Misc Control Register 1 for Pair C) based on the
frequencies it detected. To use this option, the two parameter registers(ASR76K and ASR56K) should be
set correctly (see ASRC Misc Control Register 1 for Pair C and ASRC Misc Control Register 1 for Pair C).
When this bit is 0, the user is responsible for choosing the proper processing options for pair C.
This bit should be disabled when {USRC, IDRC}={1,1}.
21
ATSB
ASRC Pair B Automatic Selection For Processing Options
When this bit is 1, pair B will automatic update its pre-processing and post-processing options (ASRCFG:
PREMODB, ASRCFG:POSTMODB see ASRC Misc Control Register 1 for Pair C) based on the
frequencies it detected. To use this option, the two parameter registers(ASR76K and ASR56K) should be
set correctly (see ASRC Misc Control Register 1 for Pair C and ASRC Misc Control Register 1 for Pair C).
When this bit is 0, the user is responsible for choosing the proper processing options for pair B.
This bit should be disabled when {USRB, IDRB}={1,1}.
20
ATSA
ASRC Pair A Automatic Selection For Processing Options
When this bit is 1, pair A will automatic update its pre-processing and post-processing options (ASRCFG:
PREMODA, ASRCFG:POSTMODA see ASRC Misc Control Register 1 for Pair C) based on the
frequencies it detected. To use this option, the two parameter registers(ASR76K and ASR56K) should be
set correctly (see ASRC Misc Control Register 1 for Pair C and ASRC Misc Control Register 1 for Pair C).
When this bit is 0, the user is responsible for choosing the proper processing options for pair A.
This bit should be disabled when {USRA, IDRA}={1,1}.
19
-
This field is reserved.
Reserved. Should be written as zero for compatibility.
18
USRC
Use Ratio for Pair C
Use ratio as the input to ASRC. This bit is used in conjunction with IDRC control bit.
17
IDRC
Use Ideal Ratio for Pair C
When USRC=0, this bit has no usage.
When USRC=1 and IDRC=0, ASRC internal measured ratio will be used.
When USRC=1 and IDRC=1, the idea ratio from the interface register ASRIDRHC, ASRIDRLC will be
used. It is suggested to manually set ASRCFG:POSTMODC, ASRCFG:PREMODC according to Table
16-7 in this case.
16
USRB
Use Ratio for Pair B
Use ratio as the input to ASRC. This bit is used in conjunction with IDRB control bit.
15
IDRB
Use Ideal Ratio for Pair B
When USRB=0, this bit has no usage.
When USRB=1 and IDRB=0, ASRC internal measured ratio will be used.
When USRB=1 and IDRB=1, the idea ratio from the interface register ASRIDRHB, ASRIDRLB will be
used.It is suggested to manually set ASRCFG:POSTMODB, ASRCFG:PREMODB according to Table
16-7 in this case.
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
527

<!-- page 528 -->

ASRC_ASRCTR field descriptions (continued)
Field
Description
14
USRA
Use Ratio for Pair A
Use ratio as the input to ASRC. This bit is used in conjunction with IDRA control bit.
13
IDRA
Use Ideal Ratio for Pair A
When USRA=0, this bit has no usage.
When USRA=1 and IDRA=0, ASRC internal measured ratio will be used.
When USRA=1 and IDRA=1, the idea ratio from the interface register ASRIDRHA, ASRIDRLA will be
used. It is suggested to manually set ASRCFG:POSTMODA, ASRCFG:PREMODA according to Table
16-7 in this case.
12–5
-
This field is reserved.
Reserved. Should be written as zero for compatibility.
4
SRST
Software Reset
This bit is self-clear bit. Once it is been written as 1, it will generate a software reset signal inside ASRC.
After 9 cycles of the ASRC processing clock, this reset process will stop, and this bit will be cleared
automatically.
3
ASREC
ASRC Enable C
Enable the operation of the conversion C of ASRC. When ASREC is cleared, operation of conversion C is
disabled.
2
ASREB
ASRC Enable B
Enable the operation of the conversion B of ASRC. When ASREB is cleared, operation of conversion B is
disabled.
1
ASREA
ASRC Enable A
Enable the operation of the conversion A of ASRC. When ASREA is cleared, operation of conversion A is
disabled.
0
ASRCEN
ASRC Enable
Enable the operation of ASRC.
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
528
NXP Semiconductors

<!-- page 529 -->

16.7.2
ASRC Interrupt Enable Register (ASRC_ASRIER)
Address: 203_4000h base + 4h offset = 203_4004h
Bit
31
30
29
28
27
26
25
24
23
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
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
AFPWE
AOLIE
ADOEC
ADOEB
ADOEA
ADIEC
ADIEB
ADIEA
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ASRC_ASRIER field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–8
-
This field is reserved.
Reserved. Should be written as zero for compatibility.
7
AFPWE
FP in Wait State Interrupt Enable
Enables the FP in wait state interrupt.
1
interrupt enabled
0
interrupt disabled
6
AOLIE
Overload Interrupt Enable
Enables the overload interrupt.
1
interrupt enabled
0
interrupt disabled
5
ADOEC
Data Output C Interrupt Enable
Enables the data output C interrupt.
1
interrupt enabled
0
interrupt disabled
4
ADOEB
Data Output B Interrupt Enable
Enables the data output B interrupt.
1
interrupt enabled
0
interrupt disabled
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
529

<!-- page 530 -->

ASRC_ASRIER field descriptions (continued)
Field
Description
3
ADOEA
Data Output A Interrupt Enable
Enables the data output A interrupt.
1
interrupt enabled
0
interrupt disabled
2
ADIEC
Data Input C Interrupt Enable
Enables the data input C interrupt.
1
interrupt enabled
0
interrupt disabled
1
ADIEB
Data Input B Interrupt Enable
Enables the data input B interrupt.
1
interrupt enabled
0
interrupt disabled
0
ADIEA
Data Input A Interrupt Enable
Enables the data input A Interrupt.
1
interrupt enabled
0
interrupt disabled
16.7.3
ASRC Channel Number Configuration Register
(ASRC_ASRCNCR)
The ASRC channel number configuration register (ASRCNCR) is a read/write register
that sets the number of channels used by each ASRC conversion pair.
There are 10 channels available for distribution among 3 conversion pairs, they are
ordered as 0,1,...,9. The bottom [0, ANCA-1] channels are used for pair A, the top [10-
ANCC, 9] channels are used for pair C, and the [ANCA, ANCA+ANCB-1] channels are
allocated for pair B. In case that ANCA=0, then the [0, ANCB-1] channels are assigned
for pair B.
Address: 203_4000h base + Ch offset = 203_400Ch
Bit
31
30
29
28
27
26
25
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
Reserved
ANCC
ANCB
ANCA
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
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
530
NXP Semiconductors

<!-- page 531 -->

ASRC_ASRCNCR field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–12
-
This field is reserved.
Reserved. Should be written as zero for compatibility.
11–8
ANCC
Number of C Channels1
0000
0 channels in C (Pair C is disabled)
0001
1 channel in C
0010
2 channels in C
0011
3 channels in C
0100
4 channels in C
0101
5 channels in C
0110
6 channels in C
0111
7 channels in C
1000
8 channels in C
1001
9 channels in C
1010
10 channels in C
1011-1111
Should not be used.
7–4
ANCB
Number of B Channels
0000
0 channels in B (Pair B is disabled)
0001
1 channel in B
0010
2 channels in B
0011
3 channels in B
0100
4 channels in B
0101
5 channels in B
0110
6 channels in B
0111
7 channels in B
1000
8 channels in B
1001
9 channels in B
1010
10 channels in B
1011-1111
Should not be used.
ANCA
Number of A Channels
0000
0 channels in A (Pair A is disabled)
0001
1 channel in A
0010
2 channels in A
0011
3 channels in A
0100
4 channels in A
0101
5 channels in A
0110
6 channels in A
0111
7 channels in A
1000
8 channels in A
1001
9 channels in A
1010
10 channels in A
1011-1111
Should not be used.
1. ANCC+ANCB+ANCA<=10. Hardware is not checking the constraint. Programmer should take the responsibility to ensure
the constraint is satisfied.
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
531

<!-- page 532 -->

16.7.4
ASRC Filter Configuration Status Register
(ASRC_ASRCFG)
The ASRC configuration status register (ASRCFG) is a read/write register that sets
and/or automatically senses the ASRC operations.
Address: 203_4000h base + 10h offset = 203_4010h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
INIRQC
INIRQB
INIRQA
NDPRC
NDPRB
NDPRA
POSTMODC
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
PREMODC
POSTMODB
PREMODB
POSTMODA
PREMODA
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
ASRC_ASRCFG field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
INIRQC
Initialization for Conversion Pair C is served
When this bit is 1, it means the initialization for conversion pair C is served. This bit is cleared by disabling
the ASRC conversion pair (ASRCTR:ASREC=0 or ASRCTR:ASRCEN=0).
22
INIRQB
Initialization for Conversion Pair B is served
When this bit is 1, it means the initialization for conversion pair B is served. This bit is cleared by disabling
the ASRC conversion pair (ASRCTR:ASREB=0 or ASRCTR:ASRCEN=0).
Table continues on the next page...
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
532
NXP Semiconductors

<!-- page 533 -->

ASRC_ASRCFG field descriptions (continued)
Field
Description
21
INIRQA
Initialization for Conversion Pair A is served
When this bit is 1, it means the initialization for conversion pair A is served. This bit is cleared by disabling
the ASRC conversion pair (ASRCTR:ASREA=0 or ASRCTR:ASRCEN=0).
20
NDPRC
Not Use Default Parameters for RAM-stored Parameters For Conversion Pair C
0
Use default parameters for RAM-stored parameters. Override any parameters already in RAM.
1
Don't use default parameters for RAM-stored parameters. Use the parameters already stored in RAM.
19
NDPRB
Not Use Default Parameters for RAM-stored Parameters For Conversion Pair B
0
Use default parameters for RAM-stored parameters. Override any parameters already in RAM.
1
Don't use default parameters for RAM-stored parameter. Use the parameters already stored in RAM.
18
NDPRA
Not Use Default Parameters for RAM-stored Parameters For Conversion Pair A
0
Use default parameters for RAM-stored parameters. Override any parameters already in RAM.
1
Don't use default parameters for RAM-stored parameters. Use the parameters already stored in RAM.
17–16
POSTMODC
Post-Processing Configuration for Conversion Pair C
These bits will be read/write by user if ASRCTR:ATSC=0, and can also be automatically updated by the
ASRC internal logic if ASRCTR:ATSC=1 (see ASRC Misc Control Register 1 for Pair C). These bits set
the selection of the post-processing configuration.
00
Select Upsampling-by-2 as defined in Signal Processing Flow.
01
Select Direct-Connection as defined in Signal Processing Flow.
10
Select Downsampling-by-2 as defined in Signal Processing Flow.
15–14
PREMODC
Pre-Processing Configuration for Conversion Pair C
These bits will be read/write by user if ASRCTR:ATSC=0, and can also be automatically updated by the
ASRC internal logic if ASRCTR:ATSC=1 (see ASRC Misc Control Register 1 for Pair C). These bits set
the selection of the pre-processing configuration.
00
Select Upsampling-by-2 as defined in Signal processing flow
01
Select Direct-Connection as defined in Signal processing flow
10
Select Downsampling-by-2 as defined in Signal processing flow
11
Select passthrough mode. In this case, POSTMODC[1-0] have no use.
13–12
POSTMODB
Post-Processing Configuration for Conversion Pair B
These bits will be read/write by user if ASRCTR:ATSB=0, and can also be automatically updated by the
ASRC internal logic if ASRCTR:ATSB=1 (see ASRC Misc Control Register 1 for Pair C). These bits set the
selection of the post-processing configuration.
00
Select Upsampling-by-2 as defined in Signal processing flow
01
Select Direct-Connection as defined in Signal processing flow
10
Select Downsampling-by-2 as defined in Signal processing flow
11–10
PREMODB
Pre-Processing Configuration for Conversion Pair B
These bits will be read/write by user if ASRCTR:ATSB=0, and can also be automatically updated by the
ASRC internal logic if ASRCTR:ATSB=1 (see ASRC Misc Control Register 1 for Pair C). These bits set the
selection of the pre-processing configuration.
00
Select Upsampling-by-2 as defined in Signal processing flow
01
Select Direct-Connection as defined in Signal processing flow
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
533

<!-- page 534 -->

ASRC_ASRCFG field descriptions (continued)
Field
Description
10
Select Downsampling-by-2 as defined in Signal processing flow
11
Select passthrough mode. In this case, POSTMODB[1-0] have no use.
9–8
POSTMODA
Post-Processing Configuration for Conversion Pair A
These bits will be read/write by user if ASRCTR:ATSA=0, and can also be automatically updated by the
ASRC internal logic if ASRCTR:ATSA=1 (see ASRC Misc Control Register 1 for Pair C). These bits set the
selection of the post-processing configuration.
00
Select Upsampling-by-2 as defined in Signal processing flow
01
Select Direct-Connection as defined in Signal processing flow
10
Select Downsampling-by-2 as defined in Signal processing flow
7–6
PREMODA
Pre-Processing Configuration for Conversion Pair A
These bits will be read/write by user if ASRCTR:ATSA=0, and can also be automatically updated by the
ASRC internal logic if ASRCTR:ATSA=1 (see ASRC Misc Control Register 1 for Pair C). These bits set the
selection of the pre-processing configuration.
00
Select Upsampling-by-2 as defined in Signal processing flow
01
Select Direct-Connection as defined in Signal processing flow
10
Select Downsampling-by-2 as defined in Signal processing flow
11
Select passthrough mode. In this case, POSTMODA[1-0] have no use.
-
This field is reserved.
Reserved. Should be written as zero for compatibility.
16.7.5
ASRC Clock Source Register (ASRC_ASRCSR)
The ASRC clock source register (ASRCSR) is a read/write register that controls the
sources of the input and output clocks of the ASRC.
Address: 203_4000h base + 14h offset = 203_4014h
Bit
31
30
29
28
27
26
25
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
AOCSC
AOCSB
AOCSA
AICSC
AICSB
AICSA
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
ASRC_ASRCSR field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–20
AOCSC
Output Clock Source C
0000
bit clock 0
0001
bit clock 1
0010
bit clock 2
Table continues on the next page...
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
534
NXP Semiconductors

<!-- page 535 -->

ASRC_ASRCSR field descriptions (continued)
Field
Description
0011
bit clock 3
0100
bit clock 4
0101
bit clock 5
0110
bit clock 6
0111
bit clock 7
1000
bit clock 8
1001
bit clock 9
1010
bit clock A
1011
bit clock B
1100
bit clock C
1101
bit clock D
1110
bit clock E
1111
clock disabled, connected to zero
19–16
AOCSB
Output Clock Source B
0000
bit clock 0
0001
bit clock 1
0010
bit clock 2
0011
bit clock 3
0100
bit clock 4
0101
bit clock 5
0110
bit clock 6
0111
bit clock 7
1000
bit clock 8
1001
bit clock 9
1010
bit clock A
1011
bit clock B
1100
bit clock C
1101
bit clock D
1110
bit clock E
1111
clock disabled, connected to zero
15–12
AOCSA
Output Clock Source A
0000
bit clock 0
0001
bit clock 1
0010
bit clock 2
0011
bit clock 3
0100
bit clock 4
0101
bit clock 5
0110
bit clock 6
0111
bit clock 7
1000
bit clock 8
1001
bit clock 9
1010
bit clock A
1011
bit clock B
1100
bit clock C
1101
bit clock D
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
535

<!-- page 536 -->

ASRC_ASRCSR field descriptions (continued)
Field
Description
1110
bit clock E
1111
clock disabled, connected to zero
11–8
AICSC
Input Clock Source C
0000
bit clock 0
0001
bit clock 1
0010
bit clock 2
0011
bit clock 3
0100
bit clock 4
0101
bit clock 5
0110
bit clock 6
0111
bit clock 7
1000
bit clock 8
1001
bit clock 9
1010
bit clock A
1011
bit clock B
1100
bit clock C
1101
bit clock D
1110
bit clock E
1111
clock disabled, connected to zero
7–4
AICSB
Input Clock Source B
0000
bit clock 0
0001
bit clock 1
0010
bit clock 2
0011
bit clock 3
0100
bit clock 4
0101
bit clock 5
0110
bit clock 6
0111
bit clock 7
1000
bit clock 8
1001
bit clock 9
1010
bit clock A
1011
bit clock B
1100
bit clock C
1101
bit clock D
1110
bit clock E
1111
clock disabled, connected to zero
AICSA
Input Clock Source A
0000
bit clock 0
0001
bit clock 1
0010
bit clock 2
0011
bit clock 3
0100
bit clock 4
0101
bit clock 5
0110
bit clock 6
Table continues on the next page...
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
536
NXP Semiconductors

<!-- page 537 -->

ASRC_ASRCSR field descriptions (continued)
Field
Description
0111
bit clock 7
1000
bit clock 8
1001
bit clock 9
1010
bit clock A
1011
bit clock B
1100
bit clock C
1101
bit clock D
1110
bit clock E
1111
clock disabled, connected to zero
16.7.6
ASRC Clock Divider Register 1 (ASRC_ASRCDR1)
The ASRC clock divider register (ASRCDR1) is a read/write register that controls the
division factors of the ASRC input and output clock sources.
Address: 203_4000h base + 18h offset = 203_4018h
Bit
31
30
29
28
27
26
25
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
AOCDB
AOCPB
AOCDA
AOCPA
AICDB
AICPB
AICDA
AICPA
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
ASRC_ASRCDR1 field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–21
AOCDB
Output Clock Divider B
Specify the divide ratio of the output clock divider B. The divide ratio may range from 1 to 8 (AOCDB[2:0] =
000 to 111).
20–18
AOCPB
Output Clock Prescaler B
Specify the prescaling factor of the output prescaler B. The prescaling ratio may be any power of 2 from 1
to 128.
17–15
AOCDA
Output Clock Divider A
Specify the divide ratio of the output clock divider A. The divide ratio may range from 1 to 8 (AOCDA[2:0] =
000 to 111).
14–12
AOCPA
Output Clock Prescaler A
Specify the prescaling factor of the output prescaler A. The prescaling ratio may be any power of 2 from 1
to 128.
11–9
AICDB
Input Clock Divider B
Specify the divide ratio of the input clock divider B. The divide ratio may range from 1 to 8 (AICDB[2:0] =
000 to 111).
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
537

<!-- page 538 -->

ASRC_ASRCDR1 field descriptions (continued)
Field
Description
8–6
AICPB
Input Clock Prescaler B
Specify the prescaling factor of the input prescaler B. The prescaling ratio may be any power of 2 from 1 to
128.
5–3
AICDA
Input Clock Divider A
Specify the divide ratio of the input clock divider A. The divide ratio may range from 1 to 8 (AICDA[2:0] =
000 to 111).
AICPA
Input Clock Prescaler A
Specify the prescaling factor of the input prescaler A. The prescaling ratio may be any power of 2 from 1 to
128.
16.7.7
ASRC Clock Divider Register 2 (ASRC_ASRCDR2)
The ASRC clock divider register (ASRCDR2) is a read/write register that controls the
division factors of the ASRC input and output clock sources.
Address: 203_4000h base + 1Ch offset = 203_401Ch
Bit
31
30
29
28
27
26
25
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
Reserved
AOCDC
AOCPC
AICDC
AICPC
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
ASRC_ASRCDR2 field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–12
-
This field is reserved.
Reserved. Should be written as zero for compatibility.
11–9
AOCDC
Output Clock Divider C
Specify the divide ratio of the output clock divider C. The divide ratio may range from 1 to 8 (AOCDC[2:0]
= 000 to 111).
8–6
AOCPC
Output Clock Prescaler C
Specify the prescaling factor of the output prescaler C. The prescaling ratio may be any power of 2 from 1
to 128.
5–3
AICDC
Input Clock Divider C
Specify the divide ratio of the input clock divider C. The divide ratio may range from 1 to 8 (AICDC[2:0] =
000 to 111).
AICPC
Input Clock Prescaler C
Specify the prescaling factor of the input prescaler C. The prescaling ratio may be any power of 2 from 1
to 128.
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
538
NXP Semiconductors

<!-- page 539 -->

16.7.8
ASRC Status Register (ASRC_ASRSTR)
The ASRC status register (ASRSTR) is a read/write register used by the processor core to
examine the status of the ASRC block and clear the overload interrupt request and AOLE
flag bit. Read the status register will return the current state of ASRC.
Address: 203_4000h base + 20h offset = 203_4020h
Bit
31
30
29
28
27
26
25
24
23
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
DSLCNT
ATQOL
AOOLC
AOOLB
AOOLA
AIOLC
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
AIOLB
AIOLA
AODOC
AODOB
AODOA
AIDUC
AIDUB
AIDUA
FPWT
AOLE
AODFC
AODFB
AODFA
AIDEC
AIDEB
AIDEA
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ASRC_ASRSTR field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–22
-
This field is reserved.
Reserved. Should be written as zero for compatibility.
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
539

<!-- page 540 -->

ASRC_ASRSTR field descriptions (continued)
Field
Description
21
DSLCNT
DSL Counter Input to FIFO ready
When set, this bit indicates that new DSL counter information is stored in the internal ASRC FIFO. When
clear, this bit indicates that new DSL counter information is in the process of storage into the internal
ASRC FIFO.
When ASRIER:AFPWE=1, the rising edge of this signal will propose an interrupt request.
Writing any value with this bit set will clear the interrupt request proposed by the rising edge of this bit.
20
ATQOL
Task Queue FIFO overload
When set, this bit indicates that task queue FIFO logic is oveloaded. This may help to check the reason
why overload interrupt happens.
The bit is cleared when writing ASRSTR:AOLE as 1.
19
AOOLC
Pair C Output Task Overload
When set, this bit indicates that pair C output task is oveloaded. This may help to check the reason why
overload interrupt happens.
The bit is cleared when writing ASRSTR:AOLE as 1.
18
AOOLB
Pair B Output Task Overload
When set, this bit indicates that pair B output task is oveloaded. This may help to check the reason why
overload interrupt happens.
The bit is cleared when writing ASRSTR:AOLE as 1.
17
AOOLA
Pair A Output Task Overload
When set, this bit indicates that pair A output task is oveloaded. This may help to check the reason why
overload interrupt happens.
The bit is cleared when writing ASRSTR:AOLE as 1.
16
AIOLC
Pair C Input Task Overload
When set, this bit indicates that pair C input task is oveloaded. This may help to check the reason why
overload interrupt happens.
The bit is cleared when writing ASRSTR:AOLE as 1.
15
AIOLB
Pair B Input Task Overload
When set, this bit indicates that pair B input task is oveloaded. This may help to check the reason why
overload interrupt happens.
The bit is cleared when writing ASRSTR:AOLE as 1.
14
AIOLA
Pair A Input Task Overload
When set, this bit indicates that pair A input task is oveloaded. This may help to check the reason why
overload interrupt happens.
The bit is cleared when writing ASRSTR:AOLE as 1.
13
AODOC
Output Data Buffer C has overflowed
When set, this bit indicates that output data buffer C has overflowed. When clear, this bit indicates that
output data buffer C has not overflowed
The bit is cleared when writing ASRSTR:AOLE as 1.
12
AODOB
Output Data Buffer B has overflowed
When set, this bit indicates that output data buffer B has overflowed. When clear, this bit indicates that
output data buffer B has not overflowed
Table continues on the next page...
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
540
NXP Semiconductors

<!-- page 541 -->

ASRC_ASRSTR field descriptions (continued)
Field
Description
The bit is cleared when writing ASRSTR:AOLE as 1.
11
AODOA
Output Data Buffer A has overflowed
When set, this bit indicates that output data buffer A has overflowed. When clear, this bit indicates that
output data buffer A has not overflowed
The bit is cleared when writing ASRSTR:AOLE as 1.
10
AIDUC
Input Data Buffer C has underflowed
When set, this bit indicates that input data buffer C has underflowed.
When clear, this bit indicates that input data buffer C has not underflowed.
The bit is cleared when writing ASRSTR:AOLE as 1.
9
AIDUB
Input Data Buffer B has underflowed
When set, this bit indicates that input data buffer B has underflowed.
When clear, this bit indicates that input data buffer B has not underflowed.
The bit is cleared when writing ASRSTR:AOLE as 1.
8
AIDUA
Input Data Buffer A has underflowed
When set, this bit indicates that input data buffer A has underflowed.
When clear, this bit indicates that input data buffer A has not underflowed.
The bit is cleared when writing ASRSTR:AOLE as 1.
7
FPWT
FP is in wait states
This bit is for debug only.
When set, this bit indicates that ASRC is in wait states.
When clear, this bit indicates that ASRC is not in wait states.
6
AOLE
Overload Error Flag
When set, this bit indicates that the task rate is too high for the ASRC to handle. The reasons for overload
may be:
- too high input clock frequency,
- too high output clock frequency,
- incorrect selection of the pre-filter,
- low ASRC processing clock,
- too many channels,
- underrun,
- or any combination of the reasons above.
Since the ASRC uses the same hardware resources to perform various tasks, the real reason for the
overload is not straight forward, and it should be carefully analyzed by the programmer.
If ASRIER:AOLIE=1, an interrupt will be proposed when this bit is set.
Write any value with this bit set as one into the status register will clear this bit and the interrupt request
proposed by this bit.
5
AODFC
Number of data in Output Data Buffer C is greater than threshold
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
541

<!-- page 542 -->

ASRC_ASRSTR field descriptions (continued)
Field
Description
When set, this bit indicates that number of data already existing in ASRDORC is greater than threshold
and the processor can read data from ASRDORC. When AODFC is set, the ASRC generates data output
C interrupt request to the processor, if enabled (that is, ASRIER:ADOEC = 1). A DMA request is always
generated when the AODFC bit is set, but a DMA transfer takes place only if a DMA channel is active and
triggered by this event.
4
AODFB
Number of data in Output Data Buffer B is greater than threshold
When set, this bit indicates that number of data already existing in ASRDORB is greater than threshold
and the processor can read data from ASRDORB. When AODFB is set, the ASRC generates data output
B interrupt request to the processor, if enabled (that is, ASRIER:ADOEB = 1). A DMA request is always
generated when the AODFB bit is set, but a DMA transfer takes place only if a DMA channel is active and
triggered by this event.
3
AODFA
Number of data in Output Data Buffer A is greater than threshold
When set, this bit indicates that number of data already existing in ASRDORA is greater than threshold
and the processor can read data from ASRDORA. When AODFA is set, the ASRC generates data output
A interrupt request to the processor, if enabled (that is, ASRIER:ADOEA = 1). A DMA request is always
generated when the AODFA bit is set, but a DMA transfer takes place only if a DMA channel is active and
triggered by this event.
2
AIDEC
Number of data in Input Data Buffer C is less than threshold
When set, this bit indicates that number of data still available in ASRDIRC is less than threshold and the
processor can write data to ASRDIRC. When AIDEC is set, the ASRC generates data input C interrupt
request to the processor, if enabled (that is, ASRIER:ADIEC = 1). A DMA request is always generated
when the AIDEC bit is set, but a DMA transfer takes place only if a DMA channel is active and triggered by
this event.
1
AIDEB
Number of data in Input Data Buffer B is less than threshold
When set, this bit indicates that number of data still available in ASRDIRB is less than threshold and the
processor can write data to ASRDIRB. When AIDEB is set, the ASRC generates data input B interrupt
request to the processor, if enabled (that is, ASRIER:ADIEB = 1). A DMA request is always generated
when the AIDEB bit is set, but a DMA transfer takes place only if a DMA channel is active and triggered by
this event.
0
AIDEA
Number of data in Input Data Buffer A is less than threshold
When set, this bit indicates that number of data still available in ASRDIRA is less than threshold and the
processor can write data to ASRDIRA. When AIDEA is set, the ASRC generates data input A interrupt
request to the processor, if enabled (that is, ASRIER:ADIEA = 1). A DMA request is always generated
when the AIDEA bit is set, but a DMA transfer takes place only if a DMA channel is active and triggered by
this event.
16.7.9
ASRC Parameter Register n (ASRC_ASRPMnn)
Parameter registers determine the performance of ASRC.
The parameter registers must be initialized by software before ASRC is enabled.
Recommended values are given in ASRC Misc Control Register 1 for Pair C below,
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
542
NXP Semiconductors

<!-- page 543 -->

Table 16-8. ASRC Parameter Registers (ASRPM1~ASRPM5)
Register
Offset
Access
Reset Value
Recommend Value
asrcpm1
0x40
R/W
0x00_0000
0x7fffff
asrcpm2
0x44
R/W
0x00_0000
0x255555
asrcpm3
0x48
R/W
0x00_0000
0xff7280
asrcpm4
0x4C
R/W
0x00_0000
0xff7280
asrcpm5
0x50
R/W
0x00_0000
0xff7280
Address: 203_4000h base + 40h offset + (4d × i), where i=0d to 4d
Bit
31
30
29
28
27
26
25
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
PARAMETER_VALUE
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
ASRC_ASRPMnn field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
PARAMETER_
VALUE
See recommended values table.
16.7.10
ASRC ASRC Task Queue FIFO Register 1
(ASRC_ASRTFR1)
The register defines and shows the parameters for ASRC inner task queue FIFOs.
Address: 203_4000h base + 54h offset = 203_4054h
Bit
31
30
29
28
27
26
25
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
Reserved
TF_FILL
TF_BASE
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
0
0
0
0
0
0
ASRC_ASRTFR1 field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–20
-
This field is reserved.
Reserved. Should be written as zero for compatibility.
19–13
TF_FILL
Current number of entries in task queue FIFO.
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
543

<!-- page 544 -->

ASRC_ASRTFR1 field descriptions (continued)
Field
Description
12–6
TF_BASE
Base address for task queue FIFO. Set to 0x7C.
-
This field is reserved.
Reserved. Should be written as zero for compatibility.
16.7.11
ASRC Channel Counter Register (ASRC_ASRCCR)
The ASRC channel counter register (ASRCCR) is a read/write register that sets and
reflects the current specific input/output FIFO being accessed through shared peripheral
bus for each ASRC conversion pair.
Address: 203_4000h base + 5Ch offset = 203_405Ch
Bit
31
30
29
28
27
26
25
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
ACOC
ACOB
ACOA
ACIC
ACIB
ACIA
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
ASRC_ASRCCR field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–20
ACOC
The channel counter for Pair C's output FIFO
These bits stand for the current channel being accessed through shared peripheral bus for Pair C's output
FIFO's usage. The value can be any value between [0, ANCC-1]
19–16
ACOB
The channel counter for Pair B's output FIFO
These bits stand for the current channel being accessed through shared peripheral bus for Pair B's output
FIFO's usage. The value can be any value between [0, ANCB-1]
15–12
ACOA
The channel counter for Pair A's output FIFO
These bits stand for the current channel being accessed through shared peripheral bus for Pair A's output
FIFO's usage. The value can be any value between [0, ANCA-1]
11–8
ACIC
The channel counter for Pair C's input FIFO
These bits stand for the current channel being accessed through shared peripheral bus for Pair C's input
FIFO's usage. The value can be any value between [0, ANCC-1]
7–4
ACIB
The channel counter for Pair B's input FIFO
These bits stand for the current channel being accessed through shared peripheral bus for Pair B's input
FIFO's usage. The value can be any value between [0, ANCB-1]
ACIA
The channel counter for Pair A's input FIFO
These bits stand for the current channel being accessed through shared peripheral bus for Pair A's input
FIFO's usage. The value can be any value between [0, ANCA-1]
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
544
NXP Semiconductors

<!-- page 545 -->

16.7.12
ASRC Data Input Register for Pair x (ASRC_ASRDIn)
These registers are the interface registers for the audio data input of pair A,B,C
respectively. They are backed by FIFOs.
Address: 203_4000h base + 60h offset + (8d × i), where i=0d to 2d
Bit
31
30
29
28
27
26
25
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
W
DATA
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
ASRC_ASRDIn field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
DATA
Audio data input
16.7.13
ASRC Data Output Register for Pair x (ASRC_ASRDOn)
These registers are the interface registers for the audio data output of pair A,B,C
respectively. They are backed by FIFOs.
Address: 203_4000h base + 64h offset + (8d × i), where i=0d to 2d
Bit
31
30
29
28
27
26
25
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
DATA
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
ASRC_ASRDOn field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
DATA
Audio data output
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
545

<!-- page 546 -->

16.7.14
ASRC Ideal Ratio for Pair A-High Part
(ASRC_ASRIDRHA)
The ideal ratio registers (ASRIDRHA, ASRIDRLA) hold the ratio value IDRATIOA.
IDRATIOA = FsinA/FsoutA = TsoutA/TsinA is a 32-bit fixed point value with 26 fractional
bits. This value is only useful when ASRCTR:{USRA, IDRA}=2'b11.
Address: 203_4000h base + 80h offset = 203_4080h
Bit
31
30
29
28
27
26
25
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
Reserved
IDRATIOA_H
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
ASRC_ASRIDRHA field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–8
-
This field is reserved.
Reserved
IDRATIOA_H
IDRATIOA[31:24]. High part of ideal ratio value for pair A
16.7.15
ASRC Ideal Ratio for Pair A -Low Part
(ASRC_ASRIDRLA)
The ideal ratio registers (ASRIDRHA, ASRIDRLA) hold the ratio value IDRATIOA.
IDRATIOA = FsinA/FsoutA = TsoutA/TsinA is a 32-bit fixed point value with 26 fractional
bits. This value is only useful when ASRCTR:{USRA, IDRA}=2'b11.
Address: 203_4000h base + 84h offset = 203_4084h
Bit
31
30
29
28
27
26
25
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
IDRATIOA_L
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
ASRC_ASRIDRLA field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
IDRATIOA_L
IDRATIOA[23:0]. Low part of ideal ratio value for pair A
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
546
NXP Semiconductors

<!-- page 547 -->

16.7.16
ASRC Ideal Ratio for Pair B-High Part
(ASRC_ASRIDRHB)
The ideal ratio registers (ASRIDRHB, ASRIDRLB) hold the ratio value IDRATIOB.
IDRATIOB = FsinB/FsoutB = TsoutB/TsinB is a 32-bit fixed point value with 26 fractional
bits. This value is only useful when ASRCTR:{USRB, IDRB}=2'b11.
Address: 203_4000h base + 88h offset = 203_4088h
Bit
31
30
29
28
27
26
25
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
Reserved
IDRATIOB_H
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
ASRC_ASRIDRHB field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–8
-
This field is reserved.
Reserved
IDRATIOB_H
IDRATIOB[31:24]. High part of ideal ratio value for pair B.
16.7.17
ASRC Ideal Ratio for Pair B-Low Part (ASRC_ASRIDRLB)
The ideal ratio registers (ASRIDRHB, ASRIDRLB) hold the ratio value IDRATIOB.
IDRATIOB = FsinB/FsoutB = TsoutB/TsinB is a 32-bit fixed point value with 26 fractional
bits. This value is only useful when ASRCTR:{USRB, IDRB}=2'b11.
Address: 203_4000h base + 8Ch offset = 203_408Ch
Bit
31
30
29
28
27
26
25
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
IDRATIOB_L
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
ASRC_ASRIDRLB field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
IDRATIOB_L
IDRATIOB[23:0]. Low part of ideal ratio value for pair B.
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
547

<!-- page 548 -->

16.7.18
ASRC Ideal Ratio for Pair C-High Part
(ASRC_ASRIDRHC)
The ideal ratio registers (ASRIDRHC, ASRIDRLC) hold the ratio value IDRATIOC.
IDRATIOC = FsinC/FsoutC = TsoutC/TsinC is a 32-bit fixed point value with 26 fractional
bits. This value is only useful when ASRCTR:{USRC, IDRC}=2'b11.
Address: 203_4000h base + 90h offset = 203_4090h
Bit
31
30
29
28
27
26
25
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
Reserved
IDRATIOC_H
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
ASRC_ASRIDRHC field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–8
-
This field is reserved.
Reserved
IDRATIOC_H
IDRATIOC[31:24]. High part of ideal ratio value for pair C.
16.7.19
ASRC Ideal Ratio for Pair C-Low Part (ASRC_ASRIDRLC)
The ideal ratio registers (ASRIDRHC, ASRIDRLC) hold the ratio value IDRATIOC.
IDRATIOC = FsinC/FsoutC = TsoutC/TsinC is a 32-bit fixed point value with 26 fractional
bits. This value is only useful when ASRCTR:{USRC, IDRC}=2'b11.
Address: 203_4000h base + 94h offset = 203_4094h
Bit
31
30
29
28
27
26
25
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
IDRATIOC_L
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
ASRC_ASRIDRLC field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
IDRATIOC_L
IDRATIOC[23:0]. Low part of ideal ratio value for pair C.
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
548
NXP Semiconductors

<!-- page 549 -->

16.7.20
ASRC 76 kHz Period in terms of ASRC processing clock
(ASRC_ASR76K)
The register (ASR76K) holds the period of the 76 kHz sampling clock in terms of the
ASRC processing clock with frequency FsASRC. ASR76K = FsASRC/Fs76k. Reset value is
0x0A47 which assumes that FsASRC=200 MHz. This register is used to help the ASRC
internal logic to decide the pre-processing and the post-processing options automatically
(see ASRC Misc Control Register 1 for Pair C and ASRC Misc Control Register 1 for
Pair C). In a system when FsASRC = 133 MHz, the value should be assigned explicitly as
0x06D6 in user application code.
Address: 203_4000h base + 98h offset = 203_4098h
Bit
31
30
29
28
27
26
25
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
Reserved
ASR76K
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
1
1
ASRC_ASR76K field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–17
-
This field is reserved.
Reserved
ASR76K
Value for the period of the 76 kHz sampling clock.
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
549

<!-- page 550 -->

16.7.21
ASRC 56 kHz Period in terms of ASRC processing clock
(ASRC_ASR56K)
The register (ASR56K) holds the period of the 56 kHz sampling clock in terms of the
ASRC processing clock with frequency FsASRC. ASR56K = FsASRC/Fs56k. Reset value is
0x0DF3 which assumes that FsASRC = 200 MHz. This register is used to help the ASRC
internal logic to decide the pre-processing and the post-processing options automatically
(see ASRC Misc Control Register 1 for Pair C and ASRC Misc Control Register 1 for
Pair C). In a system when FsASRC = 133 MHz, the value should be assigned explicitly as
0x0947 in user application code.
Address: 203_4000h base + 9Ch offset = 203_409Ch
Bit
31
30
29
28
27
26
25
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
Reserved
ASR56K
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
1
1
0
1
1
1
1
1
0
0
1
1
ASRC_ASR56K field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–17
-
This field is reserved.
Reserved
ASR56K
Value for the period of the 56 kHz sampling clock
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
550
NXP Semiconductors

<!-- page 551 -->

16.7.22
ASRC Misc Control Register for Pair A
(ASRC_ASRMCRA)
The register (ASRMCRA) is used to control Pair A internal logic.
Address: 203_4000h base + A0h offset = 203_40A0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
ZEROBUFA
EXTTHRSHA
BUFSTALLA
BYPASSPOLY
A
Reserved
OUTFIFO_
THRESHOL
DA
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
OUTFIFO_THRESHOLDA
RSYNIFA
RSYNOFA
Reserved
INFIFO_THRESHOLDA
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ASRC_ASRMCRA field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
ZEROBUFA
Initialize buf of Pair A when pair A is enabled. Always clear option.
This bit is used to control whether the buffer is to be zeroized when pair A is enabled.
1
Don't zeroize the buffer
0
Zeroize the buffer
22
EXTTHRSHA
Use external thresholds for FIFO control of Pair A
This bit will determine whether the FIFO thresholds externally defined in this register is used to control
ASRC internal FIFO logic for pair A.
1
Use external defined thresholds.
0
Use default thresholds.
21
BUFSTALLA
Stall Pair A conversion in case of Buffer Near Empty/Full Condition
This bit will determine whether the near empty/full FIFO condition will stall the rate conversion for pair A.
This option can only work when external ratio is used.
Near empty condition is the condition when input FIFO has less than 4 useful samples per channel.
Near full condition is the condition when the output FIFO has less than 4 vacant sample words to fill per
channel.
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
551

<!-- page 552 -->

ASRC_ASRMCRA field descriptions (continued)
Field
Description
1
Stall Pair A conversion in case of near empty/full FIFO conditions.
0
Don't stall Pair A conversion even in case of near empty/full FIFO conditions.
20
BYPASSPOLYA
Bypass Polyphase Filtering for Pair A
This bit will determine whether the polyphase filtering part of Pair A conversion will be bypassed.
1
Bypass polyphase filtering.
0
Don't bypass polyphase filtering.
19–18
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
17–12
OUTFIFO_
THRESHOLDA
The threshold for Pair A's output FIFO per channel
These bits stand for the threshold for Pair A's output FIFO per channel. Possible range is [0,63].
When the value is n, it means that:
when the number of output FIFO fillings of the pair is greater than n samples per channel, the output data
ready flag is set;
when the number of output FIFO fillings of the pair is less than or equal to n samples per channel, the
output data ready flag is automatically cleared.
11
RSYNIFA
Re-sync Input FIFO Channel Counter
If bit set, force ASRCCR:ACIA=0. If bit clear, untouch ASRCCR:ACIA.
10
RSYNOFA
Re-sync Output FIFO Channel Counter
If bit set, force ASRCCR:ACOA=0. If bit clear, untouch ASRCCR:ACOA.
9–6
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
INFIFO_
THRESHOLDA
The threshold for Pair A's input FIFO per channel
These bits stand for the threshold for Pair A's input FIFO per channel. Possible range is [0,63].
When the value is n, it means that:
when the number of input FIFO fillings of the pair is less than n samples per channel, the input data
needed flag is set;
when the number of input FIFO fillings of the pair is greater than or equal to n samples per channel, the
input data needed flag is automatically cleared.
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
552
NXP Semiconductors

<!-- page 553 -->

16.7.23
ASRC FIFO Status Register for Pair A (ASRC_ASRFSTA)
The register (ASRFSTA) is used to show Pair A internal FIFO conditions.
Address: 203_4000h base + A4h offset = 203_40A4h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
OAFA
Reserved
OUTFIFO_FILLA
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
OUTFIFO_FILLA
IAEA
Reserved
INFIFO_FILLA
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ASRC_ASRFSTA field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
OAFA
Output FIFO is near Full for Pair A
This bit is to indicate whether the output FIFO of Pair A is near full.
22–19
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
18–12
OUTFIFO_FILLA
The fillings for Pair A's output FIFO per channel
These bits stand for the fillings for Pair A's output FIFO per channel. Possible range is [0,64].
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
553

<!-- page 554 -->

ASRC_ASRFSTA field descriptions (continued)
Field
Description
11
IAEA
Input FIFO is near Empty for Pair A
This bit is to indicate whether the input FIFO of Pair A is near empty.
10–7
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
INFIFO_FILLA
The fillings for Pair A's input FIFO per channel
These bits stand for the fillings for Pair A's input FIFO per channel. Possible range is [0,64].
16.7.24
ASRC Misc Control Register for Pair B
(ASRC_ASRMCRB)
The register (ASRMCRB) is used to control Pair B internal logic.
Address: 203_4000h base + A8h offset = 203_40A8h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
ZEROBUFB
EXTTHRSHB
BUFSTALLB
BYPASSPOLY
B
Reserved
OUTFIFO_
THRESHOL
DB
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
OUTFIFO_THRESHOLDB
RSYNIFB
RSYNOFB
Reserved
INFIFO_THRESHOLDB
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ASRC_ASRMCRB field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
ZEROBUFB
Initialize buf of Pair B when pair B is enabled
This bit is used to control whether the buffer is to be zeroized when pair B is enabled.
1
Don't zeroize the buffer
0
Zeroize the buffer
22
EXTTHRSHB
Use external thresholds for FIFO control of Pair B
Table continues on the next page...
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
554
NXP Semiconductors

<!-- page 555 -->

ASRC_ASRMCRB field descriptions (continued)
Field
Description
This bit will determine whether the FIFO thresholds externally defined in this register is used to control
ASRC internal FIFO logic for pair B.
1
Use external defined thresholds.
0
Use default thresholds.
21
BUFSTALLB
Stall Pair B conversion in case of Buffer Near Empty/Full Condition
This bit will determine whether the near empty/full FIFO condition will stall the rate conversion for pair B.
This option can only work when external ratio is used.
Near empty condition is the condition when input FIFO has less than 4 useful samples per channel.
Near full condition is the condition when the output FIFO has less than 4 vacant sample words to fill per
channel.
1
Stall Pair B conversion in case of near empty/full FIFO conditions.
0
Don't stall Pair B conversion even in case of near empty/full FIFO conditions.
20
BYPASSPOLYB
Bypass Polyphase Filtering for Pair B
This bit will determine whether the polyphase filtering part of Pair B conversion will be bypassed.
1
Bypass polyphase filtering.
0
Don't bypass polyphase filtering.
19–18
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
17–12
OUTFIFO_
THRESHOLDB
The threshold for Pair B's output FIFO per channel
These bits stand for the threshold for Pair B's output FIFO per channel. Possible range is [0,63].
When the value is n, it means that:
when the number of output FIFO fillings of the pair is greater than n samples per channel, the output data
ready flag is set;
when the number of output FIFO fillings of the pair is less than or equal to n samples per channel, the
output data ready flag is automatically cleared.
11
RSYNIFB
Re-sync Input FIFO Channel Counter
If bit set, force ASRCCR:ACIB=0. If bit clear, untouch ASRCCR:ACIB.
10
RSYNOFB
Re-sync Output FIFO Channel Counter
If bit set, force ASRCCR:ACOB=0. If bit clear, untouch ASRCCR:ACOB.
9–6
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
INFIFO_
THRESHOLDB
The threshold for Pair B's input FIFO per channel
These bits stand for the threshold for Pair B's input FIFO per channel. Possible range is [0,63].
When the value is n, it means that:
when the number of input FIFO fillings of the pair is less than n samples per channel, the input data
needed flag is set;
when the number of input FIFO fillings of the pair is greater than or equal to n samples per channel, the
input data needed flag is automatically cleared.
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
555

<!-- page 556 -->

16.7.25
ASRC FIFO Status Register for Pair B (ASRC_ASRFSTB)
The register (ASRFSTB) is used to show Pair B internal FIFO conditions.
Address: 203_4000h base + ACh offset = 203_40ACh
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
OAFB
Reserved
OUTFIFO_FILLB
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
OUTFIFO_FILLB
IAEB
Reserved
INFIFO_FILLB
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ASRC_ASRFSTB field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
OAFB
Output FIFO is near Full for Pair B
This bit is to indicate whether the output FIFO of Pair B is near full.
22–19
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
18–12
OUTFIFO_FILLB
The fillings for Pair B's output FIFO per channel
These bits stand for the fillings for Pair B's output FIFO per channel. Possible range is [0,64].
Table continues on the next page...
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
556
NXP Semiconductors

<!-- page 557 -->

ASRC_ASRFSTB field descriptions (continued)
Field
Description
11
IAEB
Input FIFO is near Empty for Pair B
This bit is to indicate whether the input FIFO of Pair B is near empty.
10–7
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
INFIFO_FILLB
The fillings for Pair B's input FIFO per channel
These bits stand for the fillings for Pair B's input FIFO per channel. Possible range is [0,64].
16.7.26
ASRC Misc Control Register for Pair C
(ASRC_ASRMCRC)
The register (ASRMCRC) is used to control Pair C internal logic.
Address: 203_4000h base + B0h offset = 203_40B0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
ZEROBUFC
EXTTHRSHC
BUFSTALLC
BYPASSPOLY
C
Reserved
OUTFIFO_
THRESHOL
DC
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
OUTFIFO_THRESHOLDC
RSYNIFC
RSYNOFC
Reserved
INFIFO_THRESHOLDC
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ASRC_ASRMCRC field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
ZEROBUFC
Initialize buf of Pair C when pair C is enabled
This bit is used to control whether the buffer is to be zeroized when pair C is enabled.
1
Don't zeroize the buffer
0
Zeroize the buffer
22
EXTTHRSHC
Use external thresholds for FIFO control of Pair C
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
557

<!-- page 558 -->

ASRC_ASRMCRC field descriptions (continued)
Field
Description
This bit will determine whether the FIFO thresholds externally defined in this register is used to control
ASRC internal FIFO logic for pair C.
1
Use external defined thresholds.
0
Use default thresholds.
21
BUFSTALLC
Stall Pair C conversion in case of Buffer Near Empty/Full Condition
This bit will determine whether the near empty/full FIFO condition will stall the rate conversion for pair C.
This option can only work when external ratio is used.
Near empty condition is the condition when input FIFO has less than 4 useful samples per channel.
Near full condition is the condition when the output FIFO has less than 4 vacant sample words to fill per
channel.
1
Stall Pair C conversion in case of near empty/full FIFO conditions.
0
Don't stall Pair C conversion even in case of near empty/full FIFO conditions.
20
BYPASSPOLYC
Bypass Polyphase Filtering for Pair C
This bit will determine whether the polyphase filtering part of Pair C conversion will be bypassed.
1
Bypass polyphase filtering.
0
Don't bypass polyphase filtering.
19–18
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
17–12
OUTFIFO_
THRESHOLDC
The threshold for Pair C's output FIFO per channel
These bits stand for the threshold for Pair C's output FIFO per channel. Possible range is [0,63].
When the value is n, it means that:
when the number of output FIFO fillings of the pair is greater than n samples per channel, the output data
ready flag is set;
when the number of output FIFO fillings of the pair is less than or equal to n samples per channel, the
output data ready flag is automatically cleared.
11
RSYNIFC
Re-sync Input FIFO Channel Counter
If bit set, force ASRCCR:ACIC=0. If bit clear, untouch ASRCCR:ACIC.
10
RSYNOFC
Re-sync Output FIFO Channel Counter
If bit set, force ASRCCR:ACOC=0. If bit clear, untouch ASRCCR:ACOC.
9–6
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
INFIFO_
THRESHOLDC
The threshold for Pair C's input FIFO per channel
These bits stand for the threshold for Pair C's input FIFO per channel. Possible range is [0,63].
When the value is n, it means that:
when the number of input FIFO fillings of the pair is less than n samples per channel, the input data
needed flag is set;
when the number of input FIFO fillings of the pair is greater than or equal to n samples per channel, the
input data needed flag is automatically cleared.
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
558
NXP Semiconductors

<!-- page 559 -->

16.7.27
ASRC FIFO Status Register for Pair C (ASRC_ASRFSTC)
The register (ASRFSTC) is used to show Pair C internal FIFO conditions.
Address: 203_4000h base + B4h offset = 203_40B4h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
OAFC
Reserved
OUTFIFO_FILLC
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
OUTFIFO_FILLC
IAEC
Reserved
INFIFO_FILLC
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ASRC_ASRFSTC field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23
OAFC
Output FIFO is near Full for Pair C
This bit is to indicate whether the output FIFO of Pair C is near full.
22–19
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
18–12
OUTFIFO_FILLC
The fillings for Pair C's output FIFO per channel
These bits stand for the fillings for Pair C's output FIFO per channel. Possible range is [0,64].
Table continues on the next page...
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
559

<!-- page 560 -->

ASRC_ASRFSTC field descriptions (continued)
Field
Description
11
IAEC
Input FIFO is near Empty for Pair C
This bit is to indicate whether the input FIFO of Pair C is near empty.
10–7
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
INFIFO_FILLC
The fillings for Pair C's input FIFO per channel
These bits stand for the fillings for Pair C's input FIFO per channel. Possible range is [0,64].
16.7.28
ASRC Misc Control Register 1 for Pair X
(ASRC_ASRMCR1n)
The register (ASRMCR1x) is used to control Pair x internal logic (for data alignment
etc.).
The bit assignment for all the input data formats is the same as that supported by the SAI.
Address: 203_4000h base + C0h offset + (4d × i), where i=0d to 2d
Bit
31
30
29
28
27
26
25
24
23
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
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
IWD
IMSB
Reserved
OMSB
OSGN
OW16
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ASRC_ASRMCR1n field descriptions
Field
Description
31–24
-
This field is reserved.
Reserved
23–12
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
11–9
IWD
Data Width of the input FIFO
These three bits will determine the bitwidth for the audio data into ASRC
All other settings not shown are reserved.
3'b000 24-bit audio data.
3'b001 16-bit audio data.
Table continues on the next page...
ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
560
NXP Semiconductors

<!-- page 561 -->

ASRC_ASRMCR1n field descriptions (continued)
Field
Description
3'b010 8-bit audio data.
8
IMSB
Data Alignment of the input FIFO
This bit will determine the data alignment of the input FIFO.
1
MSB aligned.
0
LSB aligned.
7–3
-
This field is reserved.
Reserved. Should be written as zero for future compatibility.
2
OMSB
Data Alignment of the output FIFO
This bit will determine the data alignment of the output FIFO.
1
MSB aligned.
0
LSB aligned.
1
OSGN
Sign Extension Option of the output FIFO
This bit will determine the sign extension option of the output FIFO.
1
Sign extension.
0
No sign extension.
0
OW16
Bit Width Option of the output FIFO
This bit will determine the bit width option of the output FIFO.
1
16-bit output data
0
24-bit output data.
Chapter 16 Asynchronous Sample Rate Converter (ASRC)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
561

<!-- page 562 -->

ASRC Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
562
NXP Semiconductors

