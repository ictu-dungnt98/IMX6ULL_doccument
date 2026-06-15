# Chapter 25: Enhanced Serial Audio Interface (ESAI)

> Nguồn: `IMX6ULLRM.pdf` — trang 1179–1244

<!-- page 1179 -->

Chapter 25
Enhanced Serial Audio Interface (ESAI)
25.1
Overview
The Enhanced Serial Audio Interface (ESAI) provides a full-duplex serial port for serial
communication with a variety of serial devices, including industry-standard codecs,
Sony/Phillips Digital Interface (SPDIF) transceivers, and other DSPs.
The ESAI consists of independent transmitter and receiver sections, each section with its
own clock generator. It is a superset of the 56300 Family ESSI peripheral and of the
56000 Family SAI peripheral.
All serial transfers in the module are synchronized to a clock. Additional synchronization
signals are used to delineate the word frames. The normal mode of operation is used to
transfer data at a periodic rate, one word per period. The network mode is similar in that
it is also intended for periodic transfers; however, it supports up to 32 words (time slots)
per period. This mode can be used to build time division multiplexed (TDM) networks. In
contrast, the on-demand mode is intended for non-periodic transfers of data and to
transfer data serially at high speed when the data becomes available.
The following figure shows the ESAI block diagram.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1179

<!-- page 1180 -->

ESAI_TX0
RCLK
TCLK
Clock/Frame Sync
Generators
and
Control Logic
[PC3] SCKT
[PC4] FST
[PC5] HCKT
[PC0] SCKR
[PC1] FSR
[PC2] HCKR
TX
FIFO
RX
FIFO
IP Bus
ESAI_RSMA
ESAI_RSMB
Shift Register
ESAI_TSMA
ESAI_TSMB
ESAI_TX1
Shift Register
ESAI_TX2
Shift Register
ESAI_RX3
ESAI_RCCR
ESAI_RCR
ESAI_TCCR
ESAI_TCR
ESAI_SAICR
ESAI_SAISR
ESAI_TX3
Shift Register
ESAI_RX2
ESAI_TX4
Shift Register
ESAI_RX1
ESAI_TSR
ESAI_TX5
Shift Register
ESAI_RX0
TX0 [PC11]
TX1 [PC10]
TX2_RX3 [PC9]
TX3_RX2 [PC8]
TX4_RX1 [PC7]
TX5_RX0 [PC6]
Figure 25-1. ESAI Block Diagram
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1180
NXP Semiconductors

<!-- page 1181 -->

25.1.1
Features
• Independent (asynchronous mode) or shared (synchronous mode) transmit and
receive sections with separate or shared internal/external clocks and frame syncs,
operating in Master or Slave mode.
• Up to six transmitters and four receivers with TX2_RX3, TX3_RX2, TX4_RX1, and
TX5_RX0 pins shared by transmitters 2 to 5 and receivers 0 to 3. TX0 AND TX1
pins are used by transmitters 0 and 1 only.
• Programmable data interface modes such as I2S, LSB aligned, MSB aligned
• Programmable word length (8, 12, 16, 20 or 24bits)
• Flexible selection between system clock or external oscillator as input clock source,
programmable internal clock divider and frame sync generation
• AC97 support
• Time Slot Mask Registers for reduced ARM platform overhead (for both Transmit
and Receive)
• 128-word Transmit FIFO shared by six transmitters
• 128-word Receive FIFO shared by four receivers
25.1.2
Modes of Operation
ESAI has three basic operating modes and many data/operation formats.
ESAI operating mode are selected by the ESAI control registers (ESAI_TCCR,
ESAI_TCR, ESAI_RCCR, ESAI_RCR, and ESAI_SAICR). The main operating modes
are described in the following section.
25.1.2.1
Normal/Network/On-Demand Mode Selection
Selecting between the normal mode and network mode is accomplished by clearing or
setting the TMOD0-TMOD1 bits in the ESAI_TCR register for the transmitter section, as
well as in the RMOD0-RMOD1 bits in the ESAI_RCR register for the receiver section.
For normal mode, the ESAI functions with one data word of I/O per frame (per enabled
transmitter or receiver). The normal mode is typically used to transfer data to or from a
single device.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1181

<!-- page 1182 -->

For the network mode, 2 to 32 time slots per frame may be selected. During each frame, 0
to 32 data words of I/O may be received or transmitted. In either case, the transfers are
periodic. The frame sync signal indicates the first time slot in the frame. Network mode is
typically used in time division multiplexed (TDM) networks of codecs, DSPs with
multiple words per frame, or multi-channel devices.
Selecting the network mode and setting the frame rate divider to zero (DC=00000) selects
the on-demand mode. This special case does not generate a periodic frame sync. A frame
sync pulse is generated only when data is available to transmit. The on-demand mode
requires that the transmit frame sync be internal (output) and the receive frame sync be
external (input). Therefore, for simplex operation, the synchronous mode could be used;
however, for full-duplex operation, the asynchronous mode must be used. Data
transmission that is data driven is enabled by writing data into each TX. Although the
ESAI is double buffered, only one word can be written to each TX, even if the transmit
shift register is empty. The receive and transmit interrupts function as usual using TDE
and RDF; however, transmit underruns are impossible for on-demand transmission and
are disabled.
25.1.2.2
Synchronous/Asynchronous Operating Modes
The transmit and receive sections of the ESAI may be synchronous or asynchronous, that
is, the transmitter and receiver sections may use common clock and synchronization
signals (synchronous operating mode), or they may have their own separate clock and
sync signals (asynchronous operating mode).
The SYN bit in the ESAI_SAICR register selects synchronous or asynchronous
operation. Because the ESAI is designed to operate either synchronously or
asynchronously, separate receive and transmit interrupts are provided.
When SYN is cleared, the ESAI transmitter and receiver clocks and frame sync sources
are independent. If SYN is set, the ESAI transmitter and receiver clocks and frame sync
come from the transmitter section (either external or internal sources).
Data clock and frame sync signals can be generated internally by the ARM Core or may
be obtained from external sources. If internally generated, the ESAI clock generator is
used to derive high frequency clock, bit clock and frame sync signals from the ARM
Core internal system clock.
25.1.2.3
Frame Sync Selection
The frame sync can be either a bit-long or word-long signal.
Overview
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1182
NXP Semiconductors

<!-- page 1183 -->

The transmitter frame format is defined by the TFSL bit in the ESAI_TCR register. The
receiver frame format is defined by the RFSL bit in the ESAI_RCR register.
1. In the word-long frame sync format, the frame sync signal is asserted during the
entire word data transfer period. This frame sync length is compatible with codecs,
SPI serial peripherals, serial A/D and D/A converters, shift registers and
telecommunication PCM serial I/O.
2. In the bit-long frame sync format, the frame sync signal is asserted for one bit clock
immediately before the data transfer period. This frame sync length is compatible
with Intel and National components, codecs and telecommunication PCM serial I/O.
The relative timing of the word length frame sync as referred to the data word is specified
by the TFSR bit in the ESAI_TCR register for the transmitter section and by the RFSR
bit in the ESAI_RCR register for the receive section. The word length frame sync may be
generated (or expected) with the first bit of the data word, or with the last bit of the
previous word. TFSR and RFSR are ignored when a bit length frame sync is selected.
Polarity of the frame sync signal may be defined as positive (asserted high) or negative
(asserted low). The TFSP bit in the ESAI_TCCR register specifies the polarity of the
frame sync for the transmitter section. The RFSP bit in the ESAI_RCCR register
specifies the polarity of the frame sync for the receiver section.
The ESAI receiver looks for a receive frame sync leading edge (trailing edge if RFSP is
set) only when the previous frame is completed. If the frame sync goes high before the
frame is completed (or before the last bit of the frame is received in the case of a bit
frame sync or a word length frame sync with RFSR set), the current frame sync is not
recognized, and the receiver is internally disabled until the next frame sync. Frames do
not have to be adjacent, that is, a new frame sync does not have to immediately follow
the previous frame. Gaps of arbitrary periods can occur between frames. Enabled
transmitters are tri-stated during these gaps.
When operating in the synchronous mode (SYN=1), all clocks including the frame sync
are generated by the transmitter section.
25.1.2.4
Shift Direction Selection
Some data formats, such as those used by codecs, specify MSB first while other data
formats, such as the AES-EBU digital audio interface, specify LSB first.
The MSB/LSB first selection is made by programming RSHFD bit in the ESAI_RCR
register for the receiver section and by programming the TSHFD bit in the ESAI_TCR
register for the transmitter section.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1183

<!-- page 1184 -->

25.2
External Signals
Three to twelve pins are required for operation, depending on the operating mode
selected and the number of transmitters and receivers enabled.
The TX0 and TX1 pins are used by transmitters 0 and 1 only. The TX2_RX3, TX3_RX2,
TX4_RX1, and TX5_RX0 pins are shared by transmitters 2 to 5 with receivers 0 to 3.
The actual mode of operation is selected under software control. All transmitters operate
fully synchronized under control of the same transmitter clock signals. All receivers
operate fully synchronized under control of the same receiver clock signals.
The following table describes the external signals of ESAI:
25.2.1
Serial Transmit 0 Data Pin
TX0 is used for transmitting data from the ESAI_TX0 serial transmit shift register.
TX0 is an output when data is being transmitted from the ESAI_TX0 shift register. In the
on-demand mode with an internally generated bit clock, the TX0 pin becomes high
impedance for a full clock period after the last data bit has been transmitted, assuming
another data word does not follow immediately. If a data word follows immediately,
there is no high-impedance interval.
TX0 may be programmed as a disconnected pin (PC11) when the ESAI TX0 function is
not being used. See Table 25-13.
25.2.2
Serial Transmit 1 Data Pin
TX1 is used for transmitting data from the ESAI_TX1 serial transmit shift register.
TX1 is an output when data is being transmitted from the ESAI_TX1 shift register. In the
on-demand mode with an internally generated bit clock, the TX1 pin becomes high
impedance for a full clock period after the last data bit has been transmitted, assuming
another data word does not follow immediately. If a data word follows immediately,
there is no high-impedance interval.
TX1 may be programmed as a disconnected pin (PC10) when the ESAI TX1 function is
not being used. See Table 25-13.
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1184
NXP Semiconductors

<!-- page 1185 -->

25.2.3
Serial Transmit 2/Receive 3 Data Pin
TX2_RX3 is used as the TX2 for transmitting data from the ESAI_TX2 serial transmit
shift register when programmed as a transmitter pin, or as the RX3 signal for receiving
serial data to the ESAI_RX3 serial receive shift register when programmed as a receiver
pin.
TX2_RX3 is an input when data is being received by the ESAI_RX3 shift register.
TX2_RX3 is an output when data is being transmitted from the ESAI_TX2 shift register.
In the on-demand mode with an internally generated bit clock, the TX2_RX3 pin
becomes high impedance for a full clock period after the last data bit has been
transmitted, assuming another data word does not follow immediately. If a data word
follows immediately, there is no high-impedance interval.
TX2_RX3 may be programmed as a disconnected pin (PC9) when the ESAI TX2 and
RX3 functions are not being used. See Table 25-13.
25.2.4
Serial Transmit 3/Receive 2 Data Pin
TX3_RX2 is used as the TX3 signal for transmitting data from the ESAI_TX3 serial
transmit shift register when programmed as a transmitter pin, or as the RX2 signal for
receiving serial data to the ESAI_RX2 serial receive shift register when programmed as a
receiver pin.
TX3_RX2 is an input when data is being received by the ESAI_RX2 shift register.
TX3_RX2 is an output when data is being transmitted from the ESAI_TX3 shift register.
In the on-demand mode with an internally generated bit clock, the TX3_RX2 pin
becomes high impedance for a full clock period after the last data bit has been
transmitted, assuming another data word does not follow immediately. If a data word
follows immediately, there is no high-impedance interval.
TX3_RX2 may be programmed as a disconnected pin (PC8) when the ESAI TX3 and
RX2 functions are not being used. See Table 25-13.
25.2.5
Serial Transmit 4/Receive 1 Data Pin
TX4_RX1 is used as the TX4 signal for transmitting data from the ESAI_TX4 serial
transmit shift register when programmed as transmitter pin, or as the RX1 signal for
receiving serial data to the RX1 serial receive shift register when programmed as a
receiver pin.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1185

<!-- page 1186 -->

TX4_RX1 is an input when data is being received by the ESAI_RX1 shift register.
TX4_RX1 is an output when data is being transmitted from the ESAI_TX4 shift register.
In the on-demand mode with an internally generated bit clock, the TX4_RX1 pin
becomes high impedance for a full clock period after the last data bit has been
transmitted, assuming another data word does not follow immediately. If a data word
follows immediately, there is no high-impedance interval.
TX4_RX1 may be programmed as a disconnected pin (PC7) when the ESAI TX4 and
RX1 functions are not being used. See Table 25-13.
25.2.6
Serial Transmit 5/Receive 0 Data Pin
TX5_RX0 is used as the TX5 signal for transmitting data from the ESAI_TX5 serial
transmit shift register when programmed as transmitter pin, or as the RX0 signal for
receiving serial data to the ESAI_RX0 serial shift register when programmed as a
receiver pin.
TX5_RX0 is an input when data is being received by the ESAI_RX0 shift register.
TX5_RX0 is an output when data is being transmitted from the ESAI_TX5 shift register.
In the on-demand mode with an internally generated bit clock, the TX5_RX0 pin
becomes high impedance for a full clock period after the last data bit has been
transmitted, assuming another data word does not follow immediately. If a data word
follows immediately, there is no high-impedance interval.
TX5_RX0 may be programmed as a disconnected pin (PC6) when the ESAI TX5 and
RX0 functions are not being used. See Table 25-13.
25.2.7
Receiver Serial Clock
SCKR is a bidirectional pin providing the receivers serial bit clock for the ESAI
interface.
The direction of this pin is determined by the RCKD bit in the ESAI_RCCR register. The
SCKR operates as a clock input or output used by all the enabled receivers in the
asynchronous mode (SYN = 0), or as serial flag 0 pin in the synchronous mode (SYN =
1).
When this pin is configured as serial flag pin, its direction is determined by the RCKD bit
in the ESAI_RCCR register. When configured as the output flag OF0, this pin reflects the
value of the OF0 bit in the ESAI_SAICR register, and the data in the OF0 bit shows up at
the pin synchronized to the frame sync being used by the transmitter and receiver
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1186
NXP Semiconductors

<!-- page 1187 -->

sections. When this pin is configured as the input flag IF0, the data value at the pin is
stored in the IF0 bit in the ESAI_SAISR register, synchronized by the frame sync in
normal mode or the slot in network mode.
SCKR may be programmed as a disconnected pin (PC0) when the ESAI SCKR function
is not being used. See Table 25-13.
NOTE
Although the external ESAI serial clocks can be independent of
and asynchronous to the internal ESAI system clock, the
external ESAI serial clock cannot exceed the internal ESAI
system clock divided by 6.
For SCKR pin mode definitions, see Table 25-10.
The table below provides a list of asynchronous-mode receiver clock sources. For more
information about EXTAL/ESAI clocking control bits (ERI, ERO), refer to ESAI Control
Register (ESAI_ECR).
Table 25-1. Receiver Clock Sources (Asynchronous Mode Only)
RHCKD
RFSD
RCKD
ERI
ERO
Receiver
Bit Clock
Source
OUTPUTS
0
0
0
N/A
N/A
SCKR
-
-
-
0
0
1
N/A
N/A
HCKR
-
-
SCKR
0
1
0
N/A
N/A
SCKR
-
FSR
-
0
1
1
N/A
N/A
HCKR
-
FSR
SCKR
1
0
0
0
0
SCKR
HCKR
-
-
1
0
0
0
1
SCKR
HCKR
-
-
1
0
0
1
0
SCKR
HCKR
-
-
1
0
0
1
1
SCKR
HCKR
-
-
1
0
1
0
0
Fsys1
HCKR
-
SCKR
1
0
1
0
1
Fsys
HCKR
-
SCKR
1
0
1
1
0
EXTAL2
HCKR
-
SCKR
1
0
1
1
1
EXTAL
HCKR
-
SCKR
1
1
0
0
0
SCKR
HCKR
FSR
-
1
1
0
0
1
SCKR
HCKR
FSR
-
1
1
0
1
0
SCKR
HCKR
FSR
-
1
1
0
1
1
SCKR
HCKR
FSR
-
1
1
1
0
0
Fsys
HCKR
FSR
SCKR
1
1
1
0
1
Fsys
HCKR
FSR
SCKR
1
1
1
1
0
EXTAL
HCKR
FSR
SCKR
1
1
1
1
1
EXTAL
HCKR
FSR
SCKR
Fsys = ipg_clk_esai
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1187

<!-- page 1188 -->

Table 25-1. Receiver Clock Sources (Asynchronous Mode Only)
RHCKD
RFSD
RCKD
ERI
ERO
Receiver
Bit Clock
Source
OUTPUTS
EXTAL is the on-chip clock source other than ipg_clk_esai ESAI system clock, and it is from esai_clk_root in CCM.
25.2.8
Transmitter Serial Clock
SCKT is a bidirectional pin providing the transmitters serial bit clock for the ESAI
interface.
The direction of this pin is determined by the TCKD bit in the ESAI_TCCR register. The
SCKT is a clock input or output used by all the enabled transmitters in the asynchronous
mode (SYN = 0) or by all the enabled transmitters and receivers in the synchronous mode
(SYN = 1).
The following table provides a list of asynchronous-mode transmitter clock sources.
Table 25-2. Transmitter Clock Sources (Asynchronous Mode Only)
THCKD
TFSD
TCKD
ETI
ETO
Transmitte
r Bit Clock
Source
OUTPUTS
0
0
0
N/A
N/A
SCKT
-
-
-
0
0
1
N/A
N/A
HCKT
-
-
SCKT
0
1
0
N/A
N/A
SCKT
-
FST
-
0
1
1
N/A
N/A
HCKT
-
FST
SCKT
1
0
0
0
0
SCKT
HCKT
-
-
1
0
0
0
1
SCKT
HCKT
-
-
1
0
0
1
0
SCKT
HCKT
-
-
1
0
0
1
1
SCKT
HCKT
-
-
1
0
1
0
0
Fsys1
HCKT
-
SCKT
1
0
1
0
1
Fsys
HCKT
-
SCKT
1
0
1
1
0
EXTAL2
HCKT
-
SCKT
1
0
1
1
1
EXTAL
HCKT
-
SCKT
1
1
0
0
0
SCKR
HCKT
FST
-
1
1
0
0
1
SCKR
HCKT
FST
-
1
1
0
1
0
SCKR
HCKT
FST
-
1
1
0
1
1
SCKR
HCKT
FST
-
1
1
1
0
0
Fsys
HCKT
FST
SCKT
1
1
1
0
1
Fsys
HCKT
FST
SCKT
1
1
1
1
0
EXTAL
HCKT
FST
SCKT
Table continues on the next page...
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1188
NXP Semiconductors

<!-- page 1189 -->

Table 25-2. Transmitter Clock Sources (Asynchronous Mode Only)
(continued)
THCKD
TFSD
TCKD
ETI
ETO
Transmitte
r Bit Clock
Source
OUTPUTS
1
1
1
1
1
EXTAL
HCKT
FST
SCKT
Fsys = ipg_clk_esai
EXTAL is the on-chip clock sources other than ipg_clk_easi ESAI system clock, and it is from esai_clk_root in CCM
SCKT may be programmed as a disconnected pin (PC3) when the ESAI SCKT function
is not being used. See Table 25-13.
For more information about EXTAL/ESAI clocking control bits (ETI, ETO), see ESAI
Control Register (ESAI_ECR).
NOTE
Although the external ESAI serial clocks can be independent of
and asynchronous to the internal ESAI system clock, the
external ESAI serial clock cannot exceed the internal ESAI
system clock divided by 6.
25.2.9
Frame Sync for Receiver
FSR is a bidirectional pin providing the receivers frame sync signal for the ESAI
interface. The direction of this pin is determined by the RFSD bit in ESAI_RCR register.
In the asynchronous mode (SYN=0), the FSR pin operates as the frame sync input or
output used by all the enabled receivers. In the synchronous mode (SYN=1), it operates
as either the serial flag 1 pin (TEBE=0), or as the transmitter external buffer enable
control (TEBE=1, RFSD=1). For FSR pin mode definitions, see Table 25-11; for receiver
clock signals, see Table 25-1.
When this pin is configured as serial flag pin, its direction is determined by the RFSD bit
in the ESAI_RCCR register. When configured as the output flag OF1, this pin reflects the
value of the OF1 bit in the ESAI_SAICR register, and the data in the OF1 bit shows up at
the pin synchronized to the frame sync being used by the transmitter and receiver
sections. When configured as the input flag IF1, the data value at the pin is stored in the
IF1 bit in the ESAI_SAISR register, synchronized by the frame sync in normal mode or
the slot in network mode.
FSR may be programmed as a disconnected pin (PC1) when the ESAI FSR function is
not being used. See Table 25-13.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1189

<!-- page 1190 -->

25.2.10
Frame Sync for Transmitter
FST is a bidirectional pin providing the frame sync for both the transmitters and receivers
in the synchronous mode (SYN=1) and for the transmitters only in asynchronous mode
(SYN=0).
See Table 25-2. The direction of this pin is determined by the TFSD bit in the
ESAI_TCCR register. When configured as an output, this pin is the internally generated
frame sync signal. When configured as an input, this pin receives an external frame sync
signal for the transmitters (and the receivers in synchronous mode).
FST may be programmed as a disconnected pin (PC4) when the ESAI FST function is
not being used. See Table 25-13.
25.2.11
High Frequency Clock for Transmitter
HCKT is a bidirectional pin providing the transmitters high frequency clock for the ESAI
interface.
The direction of this pin is determined by the THCKD bit in the ESAI_TCCR register. In
the asynchronous mode (SYN=0), the HCKT pin operates as the high frequency clock
input or output used by all enabled transmitters. In the synchronous mode (SYN=1), it
operates as the high frequency clock input or output used by all enabled transmitters and
receivers. When programmed as input this pin is used as an alternative high frequency
clock source to the ESAI transmitter rather than the ARM Core main clock. When
programmed as output it can serve as a high frequency sample clock (to external DACs
for example) or as an additional system clock (see Table 25-2).
HCKT may be programmed as a disconnected pin (PC5) when the ESAI HCKT function
is not being used. See Table 25-13.
25.2.12
High Frequency Clock for Receiver
HCKR is a bidirectional pin providing the receivers high frequency clock for the ESAI
interface.
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1190
NXP Semiconductors

<!-- page 1191 -->

The direction of this pin is determined by the RHCKD bit in the ESAI_RCCR register. In
the asynchronous mode (SYN=0), the HCKR pin operates as the high frequency clock
input or output used by all the enabled receivers. In the synchronous mode (SYN=1), it
operates as the serial flag 2 pin. For HCKR pin mode definitions, see Table 25-12; for
receiver clock signals, see Table 25-1.
When this pin is configured as serial flag pin, its direction is determined by the RHCKD
bit in the ESAI_RCCR register. When configured as the output flag OF2, this pin reflects
the value of the OF2 bit in the ESAI_SAICR register, and the data in the OF2 bit shows
up at the pin synchronized to the frame sync being used by the transmitter and receiver
sections. When configured as the input flag IF2, the data value at the pin is stored in the
IF2 bit in the ESAI_SAISR register, synchronized by the frame sync in normal mode or
the slot in network mode.
HCKR may be programmed as a disconnected pin (PC2) when the ESAI HCKR function
is not being used. See Table 25-13.
25.2.13
Serial I/O Flags
Three ESAI pins (FSR, SCKR and HCKR) are available as serial I/O flags when the
ESAI is operating in the synchronous mode (SYN=1).
Their operation is controlled by RCKD, RFSD, TEBE bits in the ESAI_RCR,
ESAI_RCCR and ESAI_SAICR registers.The output data bits (OF2, OF1 and OF0) and
the input data bits (IF2, IF1 and IF0) are double buffered to/from the HCKR, FSR and
SCKR pins. Double buffering the flags keeps them in sync with the TX and RX data
lines.
Each flag can be separately programmed. Flag 0 (SCKR pin) direction is selected by
RCKD, RCKD=1 for output and RCKD=0 for input. Flag 1 (FSR pin) is enabled when
the pin is not configured as external transmitter buffer enable (TEBE=0) and its direction
is selected by RFSD, RFSD=1 for output and RFSD=0 for input. Flag 2 (HCKR pin)
direction is selected by RHCKD, RHCKD=1 for output and RHCKD=0 for input.
When programmed as input flags, the SCKR, FSR and HCKR logic values, respectively,
are latched at the same time as the first bit of the receive data word is sampled. Because
the input was latched, the signal on the input flag pin (SCKR, FSR or HCKR) can change
without affecting the input flag until the first bit of the next receive data word. When the
received data words are transferred to the receive data registers, the input flag latched
values are then transferred to the IF0, IF1 and IF2 bits in the SAISR register, where they
may be read by software.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1191

<!-- page 1192 -->

When programmed as output flags, the SCKR, FSR and HCKR logic values are driven by
the contents of the OF0, OF1 and OF2 bits in the ESAI_SAICR register respectively, and
they are driven when the transmit data registers are transferred to the transmit shift
registers. The value on SCKR, FSR and HCKR is stable from the time the first bit of the
transmit data word is transmitted until the first bit of the next transmit data word is
transmitted. Software may change the OF0-OF2 values thus controlling the SCKR, FSR
and HCKR pin values for each transmitted word. The normal sequence for setting output
flags when transmitting data is as follows: wait for TDE (transmitter empty) to be set;
first write the flags, and then write the transmit data to the transmit registers. OF0, OF1,
and OF2 are double buffered so that the flag states appear on the pins when the transmit
data is transferred to the transmit shift register, that is, the flags are synchronous with the
data.
25.3
Clocks
The table found here describes the clock sources for ESAI.
Please see clock control block for clock setting, configuration and gating information.
Table 25-3. ESAI Clocks
Clock name
Clock Root
Description
extal_clk
esai_clk_root
ESAI system clock
ipg_clk_esai
ahb_clk_root
Bus clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
mem_clk
ahb_clk_root
Mem clock
25.4
Functional Description
This section provides a complete functional description of the block.
25.4.1
ESAI After Reset
Hardware or software reset clears the port control register bits and the port direction
control register bits, which configure all ESAI I/O pins as disconnected and both ESAI
FIFOs are also in reset state.
The ESAI is in personal reset state while all ESAI pins are programmed as disconnected,
and it is active only if at least one of the ESAI I/O pins is programmed as an ESAI pin.
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1192
NXP Semiconductors

<!-- page 1193 -->

25.4.2
ESAI Interrupt Requests
The ESAI can generate eight different interrupt requests.
Ordered from the highest to the lowest priority):
1. ESAI Receive Data with Exception Status
Occurs when the receive exception interrupt is enabled (REIE=1 in the RCR
register), at least one of the enabled receive data registers is full (RDF=1) and a
receiver overrun error has occurred (ROE=1 in the SAISR register). ROE is cleared
by first reading the SAISR and then reading all the enabled receive data registers.
2. ESAI Receive Even Data
Occurs when the receive even slot data interrupt is enabled (REDIE=1), at least one
of the enabled receive data registers is full (RDF=1), the data is from an even slot
(REDF=1) and no exception has occurred (ROE=0 or REIE=0).
Reading all enabled receiver data registers clears RDF and REDF.
3. ESAI Receive Data
Occurs when the receive interrupt is enabled (RIE=1), at least one of the enabled
receive data registers is full (RDF=1), no exception has occurred (ROE=0 or
REIE=0) and no even slot interrupt has occurred (REDF=0 or REDIE=0). Reading
all enabled receiver data registers clears RDF.
4. ESAI Receive Last Slot Interrupt
Occurs, if enabled (RLIE=1), after the last slot of the frame ended (in network mode
only) regardless of the receive mask register setting. The receive last slot interrupt
may be used for resetting the receive mask slot register, reconfiguring the DMA
channels and reassigning data memory pointers. Using the receive last slot interrupt
guarantees that the previous frame was serviced with the previous setting and the
new frame is serviced with the new setting without synchronization problems. Note
that the maximum receive last slot interrupt service time should not exceed N-1
ESAI bits service time (where N is the number of bits in a slot).
5. ESAI Transmit Data with Exception Status
Occurs when the transmit exception interrupt is enabled (TEIE=1), at least one
transmit data register of the enabled transmitters is empty (TDE=1) and a transmitter
underrun error has occurred (TUE=1). TUE is cleared by first reading the SAISR and
then writing to all the enabled transmit data registers, or to the TSR register.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1193

<!-- page 1194 -->

6. ESAI Transmit Last Slot Interrupt
Occurs, if enabled (TLIE=1), at the start of the last slot of the frame in network mode
regardless of the transmit mask register setting. The transmit last slot interrupt may
be used for resetting the transmit mask slot register, reconfiguring the DMA channels
and reassigning data memory pointers. Using the transmit last slot interrupt
guarantees that the previous frame was serviced with the previous setting and the
new frame is serviced with the new setting without synchronization problems. Note
that the maximum transmit last slot interrupt service time should not exceed N-1
ESAI bits service time (where N is the number of bits in a slot).
7. ESAI Transmit Even Data
Occurs when the transmit even slot data interrupt is enabled (TEDIE=1), at least one
of the enabled transmit data registers is empty (TDE=1), the slot is an even slot
(TEDE=1) and no exception has occurred (TUE=0 or TEIE=0). Writing to all the TX
registers of the enabled transmitters or to TSR clears this interrupt request.
8. ESAI Transmit Data
Occurs when the transmit interrupt is enabled (TIE=1), at least one of the enabled
transmit data registers is empty (TDE=1), no exception has occurred (TUE=0 or
TEIE=0) and no even slot interrupt has occurred (TEDE=0 or TEDIE=0). Writing to
all the TX registers of the enabled transmitters, or to the TSR clears this interrupt
request.
25.4.3
ESAI DMA Requests from the FIFOs
The ESAI can generate two different DMA requests:
1. ESAI Transmit FIFO Empty - Asserts when the number of empty slots in the ESAI
transmit FIFO exceeds the threshold programmed in the ESAI Transmit FIFO
Configuration Register (TFCR). Automatically negates when the number of empty
slots is less than the threshold programmed in the ESAI Transmit FIFO
Configuration Register.
2. ESAI Receive FIFO Full - Asserts when the number of data words in the ESAI
receive FIFO exceeds the threshold programmed in the ESAI Receive FIFO
Configuration Register (RFCR). Automatically negates when the number of words is
less than the threshold programmed in the ESAI Receive FIFO Configuration
Register.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1194
NXP Semiconductors

<!-- page 1195 -->

25.4.4
ESAI Transmit and Receive Shift Registers
25.4.4.1
ESAI Transmit Shift Registers
The transmit shift registers contain the data being transmitted.
See Figure 25-2 and Figure 25-3.
Data is shifted out to the serial transmit data pins by the selected (internal/external) bit
clock when the associated frame sync I/O is asserted.
The number of bits shifted out before the shift registers are considered empty and may be
written to again can be 8, 12, 16, 20, 24 or 32 bits (determined by the slot length control
bits in the TCR register). Data is shifted out of these registers MSB first if TSHFD=0 and
LSB first if TSHFD=1.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1195

<!-- page 1196 -->

(a) Receive Registers
SERIAL
RECEIVE
SHIFT
REGISTER
23
16 15
8
7
0
7
0
7
0
7
0
23
16 15
8
7
0
7
0
7
0
7
0
ESAI RECEIVE DATA REGISTER
(READ ONLY)
RSWS4-
RSW0
20 BIT
16 BIT
12 BIT
8 BIT
24 BIT
RX
RECEIVE HIGH BYTE
RECEIVE MIDDLE BYTE
RECEIVE LOW BYTE
RECEIVE HIGH BYTE
RECEIVE MIDDLE BYTE
RECEIVE LOW BYTE
8-BIT DATA
12-BIT DATA
16-BIT DATA
20-BIT DATA
24-BIT DATA
0
0
0
0
LEAST SIGNIFICANT
ZERO FILL
LSB
LSB
LSB
LSB
LSB
MSB
MSB
MSB
MSB
MSB
(b) Transmit Registers
23
16 15
8
7
0
7
0
7
0
7
0
23
16 15
8
7
0
7
0
7
0
7
0
TRANSMIT HIGH BYTE
TRANSMIT MIDDLE BYTE
TRANSMIT LOW BYTE
TRANSMIT HIGH BYTE
TRANSMIT MIDDLE BYTE
TRANSMIT LOW BYTE
8-BIT DATA
12-BIT DATA
16-BIT DATA
20-BIT DATA
24-BIT DATA
*
*
*
*
* - LEAST SIGNIFICANT
BIT FILL
LSB
LSB
LSB
LSB
LSB
MSB
MSB
MSB
MSB
MSB
TX
NOTES:
1. Data is received MSB first if RSHFD=0.
2. 24-bit fractional format (ALC=0).
3. 32-bit mode is not shown
ESAI TRANSMIT DATA
REGISTER
(WRITE ONLY)
ESAI TRANSMIT
SHIFT REGISTER
NOTES:
1. Data is sent MSB first if TSHFD=0.
2. 24-bit fractional format (ALC=0).
3. 32-bit mode is not shown.
4. Data word is left-aligned (TWA=0, PADC=0).
Figure 25-2. ESAI Data Path Programming Model ([R/T]SHFD=0)
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1196
NXP Semiconductors

<!-- page 1197 -->

(b) Transmit Registers
23
16 15
8
7
0
7
0
7
0
7
0
23
16 15
8
7
0
7
0
7
0
7
0
ESAI TRANSMIT DATA REGISTER
(WRITE ONLY)
TSWS4-
TSW0
20 BIT
16 BIT
12 BIT
8 BIT
24 BIT
TX
TRANSMIT HIGH BYTE
TRANSMIT MIDDLE BYTE
TRANSMIT LOW BYTE
TRANSMIT HIGH BYTE
TRANSMIT MIDDLE BYTE
TRANSMIT LOW BYTE
8-BIT DATA
12-BIT DATA
16-BIT DATA
20-BIT DATA
24-BIT DATA
0
0
0
0
LSB
LSB
LSB
LSB
LSB
MSB
MSB
MSB
MSB
MSB
(a) Receive Registers
23
16 15
8
7
0
7
0
7
0
7
0
23
16 15
8
7
0
7
0
7
0
7
0
RECEIVE HIGH BYTE
RECEIVE MIDDLE BYTE
RECEIVE LOW BYTE
RECEIVE HIGH BYTE
RECEIVE MIDDLE BYTE
RECEIVE LOW BYTE
8-BIT DATA
12-BIT DATA
16-BIT DATA
20-BIT DATA
24-BIT DATA
0
0
0
0
LEAST SIGNIFICANT
ZERO FILL
LSB
LSB
LSB
LSB
LSB
MSB
MSB
MSB
MSB
MSB
NOTES:
1. Data is sent LSB first if TSHFD=1.
2. 24-bit fractional format (ALC=0).
3. 32-bit mode is not shown.
ESAI RECEIVE DATA
REGISTER
(READ ONLY)
ESAI RECEIVE
SHIFT REGISTER
NOTES:
1. Data is received LSB first if RSHFD=1.
2. 24-bit fractional format (ALC=0).
3. 32-bit mode is not shown.
RX
ESAI TRANSMIT 
SHIFT REGISTER
4. Data word is left aligned (TWA=0,PADC=0).
Figure 25-3. ESAI Data Path Programming Model ([R/T]SHFD=1)
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1197

<!-- page 1198 -->

25.4.4.2
ESAI Receive Shift Registers
The receive shift registers (Figure 25-2 and Figure 25-3) receive the incoming data from
the serial receive data pins. Data is shifted in by the selected (internal/external) bit clock
when the associated frame sync I/O is asserted. Data is assumed to be received MSB first
if RSHFD=0 and LSB first if RSHFD=1. Data is transferred to the ESAI receive data
registers after 8, 12, 16, 20, 24, or 32 serial clock cycles were counted, depending on the
slot length control bits in the ESAI_RCR register.
25.5
Initialization Information
25.5.1
ESAI Initialization
The correct way to initialize the ESAI is as follows:
1. Enable the ESAI logic clock by asserting bit 0 of ESAI Control Register
(ESAI_ECR[0]).
2. Hardware, software, ESAI individual reset. Note that asserting bit 1 of ESAI Control
Register only reset the ESAI core logic, including configuration registers, but not the
ESAI FIFOs.
3. Reset ESAI FIFOs by asserting bit 1 of ESAI_TFCR and ESAI_RFCR.
4. Clear the ESAI_TSMA/ESAI_TSMB.
5. Program ESAI control registers. (The transmit/receive enable bits of TCR/RCR
should not be set.)
6. Program ESAI FIFOs via TFCR and RFCR. (Enable Transmit/Receive FIFO, enable
transmitters/receivers, transmit initialization and set Transmit FIFO/Receive FIFO
watermark.)
7. Write initial words to ESAI Transmit Data Register (ESAI_ETDR), at least one word
per enabled transmitter slot but as many as desired. For example 4 channels with 2
slot-per-channel are enabled, then 8 words need to be written into ESAI_ETDR
8. Remove ESAI personal reset by configuring ESAI_PCRC and ESAI_PRRC.
9. Enabled Transmitters/Receivers in ESAI_TCR/ESAI_RCR.
10. Configure time slot registers, first set ESAI_TSMB, then ESAI_TSMA.
During program execution, all ESAI pins may be defined disconnected, causing the ESAI
to stop serial activity and enter the individual reset state.
Initialization Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1198
NXP Semiconductors

<!-- page 1199 -->

All status bits of the interface are set to their reset state however, the control bits are not
affected. This procedure allows the programmer to reset the ESAI separately from the
other internal peripherals. During individual reset, internal DMA accesses to the data
registers of the ESAI are not valid and data read is undefined.
The programmer must use an individual ESAI reset when changing the ESAI control
registers (except for TEIE, REIE, TLIE, RLIE, TIE, RIE, TE0-TE5, RE0-RE3) to ensure
proper operation of the interface.
NOTE
If the ESAI receiver section is already operating with some of
the receivers and enabling additional receivers on the fly, that
is, without first putting the ESAI receiver in the personal reset
state by setting their REx control bits, it will result in erroneous
data being received as the first data word for the newly enabled
receivers.
25.5.2
ESAI Initialization Examples
25.5.2.1
Initializing the ESAI using Personal Reset
1. Enable the ESAI logic clock by setting bit 0 of ESAI Control
Register(ESAI_ECR[0]).
2. The ESAI should be in its personal reset state (ESAI_PCRC = 0x000 and
ESAI_PRRC = 0x000). In the personal reset state, both the transmitter and receiver
sections of the ESAI are simultaneously reset. The TPR bit in the ESAI_TCR register
may be used to reset just the transmitter section. The RPR bit in the ESAI_RCR
register may be used to reset just the receiver section.
3. Clear the ESAI_TSMA/ESAI_TSMB and ESAI_RSMA/ESAI_RSMB.
4. Configure the control registers (ESAI_TCCR, ESAI_TCR, ESAI_RCCR,
ESAI_RCR) and ESAI FIFOs configuration Registers (ESAI_TFCR, ESAI_RFCR)
according to the operating mode, but do not enable transmitters (TE5-TE0 = 0x0) or
receivers (RE3-RE0 = 0x0). It is possible to set the interrupt enable bits which are in
use during the operation (no interrupt occurs).
5. Enable the ESAI by setting the ESAI_PCRC and ESAI_PRRC register bits according
to pins which are in use during operation.
6. Write initial words to ESAI Transmit Data Register (ESAI_ETDR), at least one word
per enabled transmitter slot but as many as desired. For example 4 channels with 2
slot-per-channel are enabled, then 8 words need to be written into ESAI_ETDR. This
step is needed even if DMA is used to service the transmitters.
7. Enable the transmitters and receivers.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1199

<!-- page 1200 -->

8. Configure time slot registers, first set ESAI_TSMB, then ESAI_TSMA, then
ESAI_RSMB, then ESAI_RSMA.
9. From now on ESAI can be serviced either by polling, interrupts, or DMA.
Operation proceeds as follows:
• For internally generated clock and frame sync, these signals are active immediately
after ESAI is enabled (step 4 above).
• Data is received only when one of the receive enable (REx) bits is set and after the
occurrence of frame sync signal (either internally or externally generated).
• Data is transmitted only when the transmitter enable (TEx) bit is set and after the
occurrence of frame sync signal (either internally or externally generated). The
transmitter outputs remain tri-stated after TEx bit is set until the frame sync occurs.
25.5.2.2
Initializing the ESAI Transmitter Section
1. It is assumed that the ESAI is operational; that is, at least one pin is defined as an
ESAI pin.
2. Enable the ESAI logic clock by setting bit 0 of ESAI Control
Register(ESAI_ECR[0])
3. The transmitter section should be in its individual reset state (TPR = 1) and also reset
the ESAI Transmit FIFO (ESAI_TFCR[1] = 1).
4. Clear the ESAI_TSMA/ESAI_TSMB.
5. Configure the control registers ESAI_TCCR and ESAI_TCR according to the
operating mode, configure the Transmit FIFO Configuration Register (bring transmit
FIFO out of reset, enable Transmit FIFO, enable transmitters, transmit initialization
and set watermark). Make sure to clear the transmitter enable bits (TE0-TE5). TPR
must remain set.
6. Take the transmitter section out of the individual reset state by clearing TPR.
7. Write initial words to ESAI Transmit Data Register (ESAI_ETDR), at least one word
per enabled transmitter slot but as many as desired. For example 4 channels with 2
slot-per-channel are enabled, then 8 words need to be written into ESAI_ETDR
8. Enable the transmitters by setting their TE bits.
9. Configure time slot registers, first set ESAI_TSMB, then ESAI_TSMA.
10. Data is transmitted only when the transmitter enable (TEx) bit is set and after the
occurrence of frame sync signal (either internally or externally generated). The
transmitter outputs remain tri-stated after TEx bit is set until the frame sync occurs.
11. From now on the transmitters are operating and can be serviced either by polling,
interrupts, or DMA.
Initialization Information
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1200
NXP Semiconductors

<!-- page 1201 -->

25.5.2.3
Initializing the ESAI Receiver Section
1. It is assumed that the ESAI is operational; that is, at least one pin is defined as an
ESAI pin.
2. Enable the ESAI logic clock by setting bit 0 of ESAI Control Register
(ESAI_ECR[0])
3. The receiver section should be in its individual reset state (RPR = 1) and also reset
the ESAI Receive FIFO (ESAI_RFCR[1] = 1).
4. Clear the ESAI_RSMA/ESAI_RSMB.
5. Configure the control registers ESAI_RCCR and ESAI_RCR according to the
operating mode, configure the Receive FIFO Configuration Register (bring receive
FIFO out of reset, enable Receive FIFO, receivers, and set watermark). Making sure
to clear the receiver enable bits (RE0-RE3). RPR must remain set.
6. Take the receiver section out of the individual reset state by clearing RPR.
7. Enable the receivers by setting their RE bits.
8. Configure time slot registers, first set ESAI_RSMB, then set ESAI_RSMA.
9. From now on the receivers are operating and can be serviced either by polling,
interrupts, or DMA.
25.6
ESAI Memory Map/Register Definition
ESAI memory map
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
202_4000
ESAI Transmit Data Register (ESAI_ETDR)
32
W
(always
reads 0)
0000_0000h
25.6.1/1203
202_4004
ESAI Receive Data Register (ESAI_ERDR)
32
R
0000_0000h
25.6.2/1203
202_4008
ESAI Control Register (ESAI_ECR)
32
R/W
0000_0000h
25.6.3/1204
202_400C
ESAI Status Register (ESAI_ESR)
32
R
0000_0000h
25.6.4/1205
202_4010
Transmit FIFO Configuration Register (ESAI_TFCR)
32
R/W
0000_0000h
25.6.5/1206
202_4014
Transmit FIFO Status Register (ESAI_TFSR)
32
R
0000_0000h
25.6.6/1208
202_4018
Receive FIFO Configuration Register (ESAI_RFCR)
32
R/W
0000_0000h
25.6.7/1209
202_401C
Receive FIFO Status Register (ESAI_RFSR)
32
R
0000_0000h
25.6.8/1211
202_4080
Transmit Data Register n (ESAI_TX0)
32
W
(always
reads 0)
0000_0000h
25.6.9/1212
202_4084
Transmit Data Register n (ESAI_TX1)
32
W
(always
reads 0)
0000_0000h
25.6.9/1212
Table continues on the next page...
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1201

<!-- page 1202 -->

ESAI memory map (continued)
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
202_4088
Transmit Data Register n (ESAI_TX2)
32
W
(always
reads 0)
0000_0000h
25.6.9/1212
202_408C
Transmit Data Register n (ESAI_TX3)
32
W
(always
reads 0)
0000_0000h
25.6.9/1212
202_4090
Transmit Data Register n (ESAI_TX4)
32
W
(always
reads 0)
0000_0000h
25.6.9/1212
202_4094
Transmit Data Register n (ESAI_TX5)
32
W
(always
reads 0)
0000_0000h
25.6.9/1212
202_4098
ESAI Transmit Slot Register (ESAI_TSR)
32
W
(always
reads 0)
0000_0000h
25.6.10/
1212
202_40A0
Receive Data Register n (ESAI_RX0)
32
R
0000_0000h
25.6.11/
1213
202_40A4
Receive Data Register n (ESAI_RX1)
32
R
0000_0000h
25.6.11/
1213
202_40A8
Receive Data Register n (ESAI_RX2)
32
R
0000_0000h
25.6.11/
1213
202_40AC
Receive Data Register n (ESAI_RX3)
32
R
0000_0000h
25.6.11/
1213
202_40CC
Serial Audio Interface Status Register (ESAI_SAISR)
32
R
0000_0000h
25.6.12/
1214
202_40D0
Serial Audio Interface Control Register (ESAI_SAICR)
32
R/W
0000_0000h
25.6.13/
1216
202_40D4
Transmit Control Register (ESAI_TCR)
32
R/W
0000_0000h
25.6.14/
1219
202_40D8
Transmit Clock Control Register (ESAI_TCCR)
32
R/W
0000_0000h
25.6.15/
1227
202_40DC
Receive Control Register (ESAI_RCR)
32
R/W
0000_0000h
25.6.16/
1231
202_40E0
Receive Clock Control Register (ESAI_RCCR)
32
R/W
0000_0000h
25.6.17/
1235
202_40E4
Transmit Slot Mask Register A (ESAI_TSMA)
32
R/W
0000_FFFFh
25.6.18/
1238
202_40E8
Transmit Slot Mask Register B (ESAI_TSMB)
32
R/W
0000_FFFFh
25.6.19/
1239
202_40EC
Receive Slot Mask Register A (ESAI_RSMA)
32
R/W
0000_FFFFh
25.6.20/
1240
202_40F0
Receive Slot Mask Register B (ESAI_RSMB)
32
R/W
0000_FFFFh
25.6.21/
1241
202_40F8
Port C Direction Register (ESAI_PRRC)
32
R/W
0000_0000h
25.6.22/
1242
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1202
NXP Semiconductors

<!-- page 1203 -->

ESAI memory map (continued)
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
202_40FC
Port C Control Register (ESAI_PCRC)
32
R/W
0000_0000h
25.6.23/
1242
25.6.1
ESAI Transmit Data Register (ESAI_ETDR)
Address: 202_4000h base + 0h offset = 202_4000h
Bit
31
30
29
28
27
26
25
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
W
ETDR
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
ESAI_ETDR field descriptions
Field
Description
ETDR
ESAI Transmit Data Register. Writing to this register stores the data written into the ESAI Transmit FIFO.
Writing to this register when the Transmit FIFO is full causes the data written to be lost (the existing data
within the FIFO is not overwritten). When multiple ESAI transmitters are enabled, the data for each
transmitter must be interleaved from lowest transmitter to highest transmitter (for example, if transmitters
0, 2 and 3 are enabled then data must be written as follows: transmitter #0, transmitter #2, transmitter #3,
transmitter #0, transmitter #2, transmitter #3, transmitter #0, etc). Data within the ESAI Transmit FIFO is
passed to the ESAI transmit shifter registers as defined by the Transmit Word Alignment configuration bits.
25.6.2
ESAI Receive Data Register (ESAI_ERDR)
Address: 202_4000h base + 4h offset = 202_4004h
Bit
31
30
29
28
27
26
25
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
ERDR
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
ESAI_ERDR field descriptions
Field
Description
ERDR
ESAI Receive Data Register. Reading this register returns the data within the ESAI Receive FIFO.
Reading this register when the Receive FIFO is empty returns the last valid data word. When multiple
ESAI receivers are enabled, the data for each receiver is interleaved from lowest receiver to highest
receiver (for example, if receivers 0, 2 and 3 are enabled then data is returned as follows: receiver #0,
receiver #2, receiver #3, receiver #0, receiver #2, receiver #3, receiver #0, etc). Data is passed from the
ESAI receive shift registers to the ESAI Receive FIFO as defined by the Receiver Word Alignment
configuration bits either zero or sign-extended based on the Receive Extension control bit.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1203

<!-- page 1204 -->

25.6.3
ESAI Control Register (ESAI_ECR)
Address: 202_4000h base + 8h offset = 202_4008h
Bit
31
30
29
28
27
26
25
24
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
ETI
ETO
ERI
ERO
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
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
ERST
ESAIEN
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI_ECR field descriptions
Field
Description
31–20
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
19
ETI
EXTAL Transmitter In. Mux EXTAL in place of the High Frequency Transmitter Clock input pin. HCKT can
still be used to drive a divided down EXTAL or as GPIO.
0
HCKT pin has normal function.
1
EXTAL muxed into HCKT input.
18
ETO
EXTAL Transmitter Out. Drive the EXTAL input on the High Frequency Transmitter Clock pin.
0
HCKT pin has normal function.
1
EXTAL driven onto HCKT pin.
17
ERI
EXTAL Receiver In. Mux EXTAL in place of the High Frequency Receiver Clock input pin. HCKR can still
be used to drive a divided down EXTAL or as GPIO.
0
HCKR pin has normal function.
1
EXTAL muxed into HCKR input.
16
ERO
EXTAL Receiver Out. Drive the EXTAL input on the High Frequency Receiver Clock pin.
0
HCKR pin has normal function.
1
EXTAL driven onto HCKR pin.
15–2
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
1
ERST
ESAI Reset. Reset the ESAI core logic (including configuration registers) but not the ESAI FIFOs.
0
ESAI not reset.
1
ESAI reset.
0
ESAIEN
ESAI Enable. Enables/disables the ESAI logic clock. Enable the ESAI before reading or writing other ESAI
registers.
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1204
NXP Semiconductors

<!-- page 1205 -->

ESAI_ECR field descriptions (continued)
Field
Description
0
ESAI disabled.
1
ESAI enabled.
25.6.4
ESAI Status Register (ESAI_ESR)
Address: 202_4000h base + Ch offset = 202_400Ch
Bit
31
30
29
28
27
26
25
24
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
TINIT
RFF
TFE
TLS
TDE
TED
TD
RLS
RDE
RED
RD
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI_ESR field descriptions
Field
Description
31–11
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
10
TINIT
Transmit Initialization. Indicates that the Transmit FIFO is writing the first word for each enabled
transmitter into the Transmit Data Registers. This bit sets when the Transmit FIFO is enabled (provided
Transmit Initialization is enabled) and clears after the Transmit Data Registers have been initialized. The
Transmit Enable bits in the Transmit Control Register should not be set until this flag has cleared.
0
Transmitter has finished initializing the Transmit Data Registers (or Transmit FIFO is not enabled or
Transmit Initialization is not enabled).
1
Transmitter has not finished initializing the Transmit Data Registers.
9
RFF
Receive FIFO Full. Indicates that the number of data words in the Receive FIFO has equaled or exceeded
the Receive FIFO Watermark. This flag also drives the ESAI Receiver DMA request line. ESAI FIFO DMA
requests see ESAI DMA Requests from the FIFOs.
0
Number of words in Receive FIFO less than Receive FIFO watermark.
1
Number of words in Receive FIFO is equal to or greater than Receive FIFO watermark.
8
TFE
Transmit FIFO Empty. Indicates that the number of empty slots in the Transmit FIFO has met or exceeded
the Transmit FIFO Watermark. This flag also drives the ESAI Transmitter DMA request line. ESAI FIFO
DMA request see ESAI DMA Requests from the FIFOs.
0
Number of empty slots in Transmit FIFO less than Transmit FIFO watermark.
1
Number of empty slots in Transmit FIFO is equal to or greater than Transmit FIFO watermark.
7
TLS
Transmit Last Slot. Reading this register when TLS is set will negate the Transmit Last Slot interrupt.
0
TLS is not the highest priority active interrupt.
1
TLS is the highest priority active interrupt.
Table continues on the next page...
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1205

<!-- page 1206 -->

ESAI_ESR field descriptions (continued)
Field
Description
6
TDE
Transmit Data Exception.
0
TDE is not the highest priority active interrupt.
1
TDE is the highest priority active interrupt.
5
TED
Transmit Even Data.
0
TED is not the highest priority active interrupt.
1
TED is the highest priority active interrupt.
4
TD
Transmit Data.
0
TD is not the highest priority active interrupt.
1
TD is the highest priority active interrupt.
3
RLS
Receive Last Slot. Reading this register when RLS is set will negate the Receive Last Slot interrupt.
0
RLS is not the highest priority active interrupt.
1
RLS is the highest priority active interrupt.
2
RDE
Receive Data Exception.
0
RDE is not the highest priority active interrupt.
1
RDE is the highest priority active interrupt.
1
RED
Receive Even Data.
0
RED is not the highest priority active interrupt.
1
RED is the highest priority active interrupt.
0
RD
Receive Data.
0
RD is not the highest priority active interrupt.
1
RD is the highest priority active interrupt.
25.6.5
Transmit FIFO Configuration Register (ESAI_TFCR)
Address: 202_4000h base + 10h offset = 202_4010h
Bit
31
30
29
28
27
26
25
24
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
TFIN
TAENB
TIEN
TWA
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
TFWM
TE5
TE4
TE3
TE2
TE1
TE0
TFR
TFE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1206
NXP Semiconductors

<!-- page 1207 -->

ESAI_TFCR field descriptions
Field
Description
31–22
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
21
TFIN
Tx FIFO Interrupt Enable
Generate an interrupt if the "Tx FIFO Empty" flag is set. Indicate the number of empty slots in the Tx FIFO
has met or exceed watermark.
20
TAENB
Tx FIFO Align Enable
Disable Tx FIFO slot align function when set.
19
TIEN
Transmitter Initialization Enable. Enables the initialization of the Transmit Data Registers when the
Transmitter FIFO is enabled. TIEN=1 is recommended.
0
Transmit Data Registers are not initialized from the FIFO once the Transmit FIFO is enabled. Software
must manually initialize the Transmit Data Registers separately.
1
Transmit Data Registers are initialized from the FIFO once the Transmit FIFO is enabled.
18–16
TWA
Transmit Word Alignment. Configures the alignment of the data written into the ESAI Transmit Data
Register and then passed to the relevant 24 bit Transmit shift register.
NOTE: The settings shown below assume TCR[TWA]=0, TCR[PADC]=1 and TCR[TSHFD]=0.
000
MSB of data is bit 31. Data bits 7-0 are ignored when passed to transmit shift register.
001
MSB of data is bit 27. Data bits 3-0 are ignored when passed to transmit shift register.
010
MSB of data is bit 23.
011
MSB of data is bit 19. Bottom 4 bits of transmit shift register are zeroed.
100
MSB of data is bit 15. Bottom 8 bits of transmit shift register are zeroed.
101
MSB of data is bit 11. Bottom 12 bits of transmit shift register are zeroed.
110
MSB of data is bit 7. Bottom 16 bits of transmit shift register are zeroed.
111
MSB of data is bit 3. Bottom 20 bits of transmit shift register are zeroed.
15–8
TFWM
Transmit FIFO Watermark. These bits configure the threshold at which the Transmit FIFO Empty flag will
set. The TFE is set when the number of empty slots in the Transmit FIFO equal or exceed the selected
threshold.
7
TE5
Transmitter #5 FIFO Enable. This bit enables transmitter #5 to use the Transmit FIFO. Do not change this
bit when the Transmitter FIFO is enabled.
0
Transmitter #5 is not using the Transmit FIFO.
1
Transmitter #5 is using the Transmit FIFO.
6
TE4
Transmitter #4 FIFO Enable. This bit enables transmitter #4 to use the Transmit FIFO. Do not change this
bit when the Transmitter FIFO is enabled.
0
Transmitter #4 is not using the Transmit FIFO.
1
Transmitter #4 is using the Transmit FIFO.
5
TE3
Transmitter #3 FIFO Enable. This bit enables transmitter #3 to use the Transmit FIFO. Do not change this
bit when the Transmitter FIFO is enabled.
0
Transmitter #3 is not using the Transmit FIFO.
1
Transmitter #3 is using the Transmit FIFO.
4
TE2
Transmitter #2 FIFO Enable. This bit enables transmitter #2 to use the Transmit FIFO. Do not change this
bit when the Transmitter FIFO is enabled.
0
Transmitter #2 is not using the Transmit FIFO.
1
Transmitter #2 is using the Transmit FIFO.
Table continues on the next page...
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1207

<!-- page 1208 -->

ESAI_TFCR field descriptions (continued)
Field
Description
3
TE1
Transmitter #1 FIFO Enable. This bit enables transmitter #1 to use the Transmit FIFO. Do not change this
bit when the Transmitter FIFO is enabled.
0
Transmitter #1 is not using the Transmit FIFO.
1
Transmitter #1 is using the Transmit FIFO.
2
TE0
Transmitter #0 FIFO Enable. This bit enables transmitter #0 to use the Transmit FIFO. Do not change this
bit when the Transmitter FIFO is enabled.
0
Transmitter #0 is not using the Transmit FIFO.
1
Transmitter #0 is using the Transmit FIFO.
1
TFR
Transmit FIFO Reset. This bit resets the Transmit FIFO pointers.
0
Transmit FIFO not reset.
1
Transmit FIFO reset.
0
TFE
Transmit FIFO Enable. This bit enables the use of the Transmit FIFO.
0
Transmit FIFO disabled.
1
Transmit FIFO enabled.
25.6.6
Transmit FIFO Status Register (ESAI_TFSR)
Address: 202_4000h base + 14h offset = 202_4014h
Bit
31
30
29
28
27
26
25
24
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
NTFO
0
NTFI
TFCNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI_TFSR field descriptions
Field
Description
31–15
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
14–12
NTFO
Next Transmitter FIFO Out. Indicates which Transmit Data Register receives the top word of the Transmit
FIFO. This will usually equal the lowest enabled transmitter, unless the transmit FIFO is empty.
000
Transmitter #0 receives next word from the Transmit FIFO.
001
Transmitter #1 receives next word from the Transmit FIFO.
010
Transmitter #2 receives next word from the Transmit FIFO.
011
Transmitter #3 receives next word from the Transmit FIFO.
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1208
NXP Semiconductors

<!-- page 1209 -->

ESAI_TFSR field descriptions (continued)
Field
Description
100
Transmitter #4 receives next word from the Transmit FIFO.
101
Transmitter #5 receives next word from the Transmit FIFO.
110
Reserved.
111
Reserved.
11
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
10–8
NTFI
Next Transmitter FIFO In. Indicates which transmitter receives the next word written to the FIFO.
000
Transmitter #0 receives next word written to the Transmit FIFO.
001
Transmitter #1 receives next word written to the Transmit FIFO.
010
Transmitter #2 receives next word written to the Transmit FIFO.
011
Transmitter #3 receives next word written to the Transmit FIFO.
100
Transmitter #4 receives next word written to the Transmit FIFO.
101
Transmitter #5 receives next word written to the Transmit FIFO.
110
Reserved.
111
Reserved.
TFCNT
Transmit FIFO Counter. These bits indicate the number of data words stored in the Transmit FIFO.
25.6.7
Receive FIFO Configuration Register (ESAI_RFCR)
Address: 202_4000h base + 18h offset = 202_4018h
Bit
31
30
29
28
27
26
25
24
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
RFIN
RAENB
REXT
RWA
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
RFWM
0
RE3
RE2
RE1
RE0
RFR
RFE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI_RFCR field descriptions
Field
Description
31–22
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
21
RFIN
Rx FIFO Interrupt Enable
Generate an interrupt if the "Rx FIFO Empty" flag is set. Indicate the number of data in the Rx FIFO has
met or exceed water mark.
Table continues on the next page...
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1209

<!-- page 1210 -->

ESAI_RFCR field descriptions (continued)
Field
Description
20
RAENB
Rx FIFO Align Enable
Disable Rx FIFO slot align function when set.
19
REXT
Receive Extension. Enables the receive data to be returned sign extended when the Receive Word
Alignment is configured to return data where the MSB is not aligned with bit 31.
0
Receive data is zero extended.
1
Receive data is sign extended.
18–16
RWA
Receive Word Alignment. Configures the alignment of the data passed from the relevant 24 bit Receive
shift register and read out the ESAI Receive Data Register.
000
MSB of data is at bit 31. Data bits 7-0 are zeroed.
001
MSB of data is at bit 27. Data bits 3-0 are zeroed.
010
MSB of data is at bit 23.
011
MSB of data is at bit 19. Data bits 3-0 from receive shift register are ignored.
100
MSB of data is at bit 15. Data bits 7-0 from receive shift register are ignored.
101
MSB of data is at bit 11. Data bits 11-0 from receive shift register are ignored.
110
MSB of data is at bit 7. Data bits 15-0 from receive shift register are ignored.
111
MSB of data is at bit 3. Data bits 19-0 from receive shift register are ignored.
15–8
RFWM
Receive FIFO Watermark. These bits configure the threshold at which the Receive FIFO Full flag will set.
The RFF is set when the number of words in the Receive FIFO equal or exceed the selected threshold. It
can be set to a non-zero value.
7–6
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
5
RE3
Receiver #3 FIFO Enable. This bit enables receiver #3 to use the Receive FIFO. Do not change this bit
when the Receiver FIFO is enabled.
0
Receiver #3 is not using the Receive FIFO.
1
Receiver #3 is using the Receive FIFO.
4
RE2
Receiver #2 FIFO Enable. This bit enables receiver #2 to use the Receive FIFO. Do not change this bit
when the Receiver FIFO is enabled.
0
Receiver #2 is not using the Receive FIFO.
1
Receiver #2 is using the Receive FIFO.
3
RE1
Receiver #1 FIFO Enable. This bit enables receiver #1 to use the Receive FIFO. Do not change this bit
when the Receiver FIFO is enabled.
0
Receiver #1 is not using the Receive FIFO.
1
Receiver #1 is using the Receive FIFO.
2
RE0
Receiver #0 FIFO Enable. This bit enables receiver #0 to use the Receive FIFO. Do not change this bit
when the Receiver FIFO is enabled.
0
Receiver #0 is not using the Receive FIFO.
1
Receiver #0 is using the Receive FIFO.
1
RFR
Receive FIFO Reset. This bit resets the Receive FIFO pointers.
0
Receive FIFO not reset.
1
Receive FIFO reset.
0
RFE
Receive FIFO Enable. This bit enables the use of the Receive FIFO.
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1210
NXP Semiconductors

<!-- page 1211 -->

ESAI_RFCR field descriptions (continued)
Field
Description
0
Receive FIFO disabled.
1
Receive FIFO enabled.
25.6.8
Receive FIFO Status Register (ESAI_RFSR)
Address: 202_4000h base + 1Ch offset = 202_401Ch
Bit
31
30
29
28
27
26
25
24
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
NRFI
0
NRFO
RFCNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI_RFSR field descriptions
Field
Description
31–14
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
13–12
NRFI
Next Receiver FIFO In. Indicates which Receiver Data Register the Receive FIFO will load next. This will
usually equal the lowest enabled receiver, unless the receive FIFO is full.
00
Receiver #0 returns next word to the Receive FIFO.
01
Receiver #1 returns next word to the Receive FIFO.
10
Receiver #2 returns next word to the Receive FIFO.
11
Receiver #3 returns next word to the Receive FIFO.
11–10
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
9–8
NRFO
Next Receiver FIFO Out. Indicates which receiver returns the top word of the Receive FIFO.
00
Receiver #0 returns next word from the Receive FIFO.
01
Receiver #1 returns next word from the Receive FIFO.
10
Receiver #2 returns next word from the Receive FIFO.
11
Receiver #3 returns next word from the Receive FIFO.
RFCNT
Receive FIFO Counter. These bits indicate the number of data words stored in the Receive FIFO.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1211

<!-- page 1212 -->

25.6.9
Transmit Data Register n (ESAI_TXn)
ESAI_TX5, ESAI_TX4, ESAI_TX3, ESAI_TX2, ESAI_TX1 and ESAI_TX0 are 32-bit
write-only registers. Data to be transmitted is written into these registers and is
automatically transferred to the transmit shift registers (Figure 25-2 and Figure 25-3).
The data written (8, 12, 16, 20, or 24 bits) should occupy the most significant portion of
the TXn according to the ALC control bit setting. The unused bits (least significant
portion and the 8 most significant bits when ALC=1) of the TXn are don't care bits. The
Core is interrupted whenever the TXn becomes empty if the transmit data register empty
interrupt has been enabled.
Address: 202_4000h base + 80h offset + (4d × i), where i=0d to 5d
Bit
31
30
29
28
27
26
25
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
0
W
TXn
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
ESAI_TXn field descriptions
Field
Description
31–24
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
TXn
Stores the data to be transmitted and is automatically transferred to the transmit shift registers.
See ESAI Transmit Shift Registers.
25.6.10
ESAI Transmit Slot Register (ESAI_TSR)
Address: 202_4000h base + 98h offset = 202_4098h
Bit
31
30
29
28
27
26
25
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
0
W
TSR
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
ESAI_TSR field descriptions
Field
Description
31–24
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1212
NXP Semiconductors

<!-- page 1213 -->

ESAI_TSR field descriptions (continued)
Field
Description
TSR
The write-only Transmit Slot Register (ESAI_TSR) is effectively a null data register that is used when the
data is not to be transmitted in the available transmit time slot. The transmit data pins of all the enabled
transmitters are in the high-impedance state for the respective time slot where TSR has been written. The
Transmitter External Buffer Enable pin (FSR pin when SYN=1, TEBE=1, RFSD=1) disables the external
buffers during the slot when the ESAI_TSR register has been written.
25.6.11
Receive Data Register n (ESAI_RXn)
ESAI_RX3, ESAI_RX2, ESAI_RX1, and ESAI_RX0 are 32-bit read-only registers that
accept data from the receive shift registers when they become full (Figure 25-2 and
Figure 25-3). The data occupies the most significant portion of the receive data registers,
according to the ALC control bit setting. The unused bits (least significant portion and 8
most significant bits when ALC=1) read as zeros. The Core is interrupted whenever RXn
becomes full if the associated interrupt is enabled.
Address: 202_4000h base + A0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
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
RXn
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
ESAI_RXn field descriptions
Field
Description
31–24
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
RXn
Accept data from the receive shift registers when they become full
See ESAI Receive Shift Registers
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1213

<!-- page 1214 -->

25.6.12
Serial Audio Interface Status Register (ESAI_SAISR)
The Status Register (ESAI_SAISR) is a read-only status register used by the ARM Core
to read the status and serial input flags of the ESAI.
Address: 202_4000h base + CCh offset = 202_40CCh
Bit
31
30
29
28
27
26
25
24
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
TODFE
TEDE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
TDE
TUE
TFS
0
RODF
REDF
RDF
ROE
RFS
0
IF2
IF1
IF0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI_SAISR field descriptions
Field
Description
31–18
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
17
TODFE
ESAI_SAISR Transmit Odd-Data Register Empty. When set, TODFE indicates that the enabled
transmitter data registers became empty at the beginning of an odd time slot. Odd time slots are all odd-
numbered slots (1, 3, 5, and so on). Time slots are numbered from zero to N-1, where N is the number of
time slots in the frame. This flag is set when the contents of the transmit data register of all the enabled
transmitters are transferred to the transmit shift registers; it is also set for a TSR disabled time slot period
in network mode (as if data were being transmitted after the TSR was written). When set, TODFE
indicates that data should be written to all the TX registers of the enabled transmitters or to the transmit
slot register (ESAI_TSR). TODE is cleared when the Core writes to all the transmit data registers of the
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1214
NXP Semiconductors

<!-- page 1215 -->

ESAI_SAISR field descriptions (continued)
Field
Description
enabled transmitters, or when the Core writes to the TSR to disable transmission of the next time slot. If
TIE is set, an ESAI transmit data interrupt request is issued when TODFE is set. Hardware, software,
ESAI individual reset clear TODFE.
16
TEDE
ESAI_SAISR Transmit Even-DataRegister Empty. When set, TEDE indicates that the enabled transmitter
data registers became empty at the beginning of an even time slot. Even time slots are all even-numbered
slots (0, 2, 4, 6, etc.). Time slots are numbered from zero to N-1, where N is the number of time slots in
the frame. The zero time slot is considered even. This flag is set when the contents of the transmit data
register of all the enabled transmitters are transferred to the transmit shift registers; it is also set for a TSR
disabled time slot period in network mode (as if data were being transmitted after the TSR was written).
When set, TEDE indicates that data should be written to all the TX registers of the enabled transmitters or
to the transmit slot register (ESAI_TSR). TEDE is cleared when the Core writes to all the transmit data
registers of the enabled transmitters, or when the Core writes to the TSR to disable transmission of the
next time slot. If TIE is set, an ESAI transmit data interrupt request is issued when TEDE is set. Hardware,
software, ESAI individual reset clear TEDE.
15
TDE
ESAI_SAISR Transmit Data Register Empty. TDE is set when the contents of the transmit data register of
all the enabled transmitters are transferred to the transmit shift registers; it is also set for a TSR disabled
time slot period in network mode (as if data were being transmitted after the TSR was written). When set,
TDE indicates that data should be written to all the TX registers of the enabled transmitters or to the
transmit slot register (ESAI_TSR). TDE is cleared when the Core writes to all the transmit data registers of
the enabled transmitters, or when the Core writes to the TSR to disable transmission of the next time slot.
If TIE is set, an ESAI transmit data interrupt request is issued when TDE is set. Hardware, software, ESAI
individual reset clear TDE.
14
TUE
ESAI_SAISR Transmit Underrun Error Flag. TUE is set when at least one of the enabled serial transmit
shift registers is empty (no new data to be transmitted) and a transmit time slot occurs. When a transmit
underrun error occurs, the previous data (which is still present in the TX registers that were not written) is
retransmitted. If TEIE is set, an ESAI transmit data with exception (underrun error) interrupt request is
issued when TUE is set. Hardware, software, ESAI individual reset clear TUE. TUE is also cleared by
reading the ESAI_SAISR with TUE set, followed by writing to all the enabled transmit data registers or to
ESAI_TSR.
13
TFS
ESAI_SAISR Transmit Frame Sync Flag. When set, TFS indicates that a transmit frame sync occurred in
the current time slot. TFS is set at the start of the first time slot in the frame and cleared during all other
time slots. Data written to a transmit data register during the time slot when TFS is set is transmitted (in
network mode), if the transmitter is enabled, during the second time slot in the frame. TFS is useful in
network mode to identify the start of a frame. TFS is cleared by hardware, software, ESAI individual reset.
TFS is valid only if at least one transmitter is enabled, that is, one or more of TE0, TE1, TE2, TE3, TE4
and TE5 are set. (In normal mode, TFS always reads as a one when transmitting data because there is
only one time slot per frame - the "frame sync" time slot)
12–11
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
10
RODF
ESAI_SAISR Receive Odd-Data Register Full. When set, RODF indicates that the received data in the
receive data registers of the enabled receivers have arrived during an odd time slot when operating in the
network mode. Odd time slots are all odd-numbered slots (1, 3, 5, and so on). Time slots are numbered
from zero to N-1, where N is the number of time slots in the frame. RODF is set when the contents of the
receive shift registers are transferred to the receive data registers. RODF is cleared when the Core reads
all the enabled receive data registers or cleared by hardware, software, ESAI individual resets.
9
REDF
ESAI_SAISR Receive Even-Data Register Full. When set, REDF indicates that the received data in the
receive data registers of the enabled receivers have arrived during an even time slot when operating in the
network mode. Even time slots are all even-numbered slots (0, 2, 4, 6, and so on). Time slots are
numbered from zero to N-1, where N is the number of time slots in the frame. The zero time slot is
considered even. REDF is set when the contents of the receive shift registers are transferred to the
receive data registers. REDF is cleared when the Core reads all the enabled receive data registers or
Table continues on the next page...
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1215

<!-- page 1216 -->

ESAI_SAISR field descriptions (continued)
Field
Description
cleared by hardware, software, ESAI individual resets. If REDIE is set, an ESAI receive even slot data
interrupt request is issued when REDF is set.
8
RDF
ESAI_SAISR Receive Data Register Full. RDF is set when the contents of the receive shift register of an
enabled receiver is transferred to the respective receive data register. RDF is cleared when the Core
reads the receive data register of all enabled receivers or cleared by hardware, software, ESAI individual
reset. If RIE is set, an ESAI receive data interrupt request is issued when RDF is set.
7
ROE
ESAI_SAISR Receive Overrun Error Flag. The ROE flag is set when the serial receive shift register of an
enabled receiver is full and ready to transfer to its receiver data register (RXn) and the register is already
full (RDF=1). If REIE is set, an ESAI receive data with exception (overrun error) interrupt request is issued
when ROE is set. Hardware, software, ESAI individual reset clear ROE. ROE is also cleared by reading
the SAISR with ROE set, followed by reading all the enabled receive data registers.
6
RFS
ESAI_SAISR Receive Frame Sync Flag. When set, RFS indicates that a receive frame sync occurred
during reception of the words in the receiver data registers. This indicates that the data words are from the
first slot in the frame. When RFS is clear and a word is received, it indicates (only in the network mode)
that the frame sync did not occur during reception of that word. RFS is cleared by hardware, software,
ESAI individual reset. RFS is valid only if at least one of the receivers is enabled (REx=1). (In normal
mode, RFS always reads as a one when reading data because there is only one time slot per frame - the
"frame sync" time slot)
5–3
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
2
IF2
ESAI_SAISR Serial Input Flag 2. The IF2 bit is enabled only when the HCKR pin is defined as ESAI in the
Port Control Register, SYN=1 and RHCKD=0, indicating that HCKR is an input flag and the synchronous
mode is selected. Data present on the HCKR pin is latched during reception of the first received data bit
after frame sync is detected. The IF2 bit is updated with this data when the receive shift registers are
transferred into the receiver data registers. IF2 reads as a zero when it is not enabled. Hardware,
software, ESAI individual reset clear IF2.
1
IF1
ESAI_SAISR Serial Inout Flag 1. The IF1 bit is enabled only when the FSR pin is defined as ESAI in the
Port Control Register, SYN =1, RFSD=0 and TEBE=0, indicating that FSR is an input flag and the
synchronous mode is selected. Data present on the FSR pin is latched during reception of the first
received data bit after frame sync is detected. The IF1 bit is updated with this data when the receiver shift
registers are transferred into the receiver data registers. IF1 reads as a zero when it is not enabled.
Hardware, software, ESAI individual reset clear IF1.
0
IF0
ESAI_SAISR Serial Input Flag 0. The IF0 bit is enabled only when the SCKR pin is defined as ESAI in the
Port Control Register, SYN=1 and RCKD=0, indicating that SCKR is an input flag and the synchronous
mode is selected. Data present on the SCKR pin is latched during reception of the first received data bit
after frame sync is detected. The IF0 bit is updated with this data when the receiver shift registers are
transferred into the receiver data registers. IF0 reads as a zero when it is not enabled. Hardware,
software, ESAI individual reset clear IF0.
25.6.13
Serial Audio Interface Control Register (ESAI_SAICR)
The read/write Common Control Register (ESAI_SAICR) contains control bits for
functions that affect both the receive and transmit sections of the ESAI.
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1216
NXP Semiconductors

<!-- page 1217 -->

ASYNCHRONOUS (SYN=0)
ESAI BIT
CLOCK
SCKR
SCKT
EXTERNAL TRANSMIT CLOCK
INTERNAL CLOCK
EXTERNAL RECEIVE CLOCK
EXTERNAL TRANSMIT FRAME SYNC
INTERNAL FRAME SYNC
EXTERNAL RECEIVE FRAME SYNC
TRANSMITTER
CLOCK
FRAME
SYNC
SDO
FST
FSR
SDI
CLOCK
FRAME
SYNC
RECEIVER
NOTE: Transmitter and receiver may have different clocks and frame syncs.
SYNCHRONOUS (SYN=1)
EXTERNAL FRAME SYNC
INTERNAL FRAME SYNC
TRANSMITTER
CLOCK
FRAME
SYNC
SDO
FST
SDI
CLOCK
FRAME
SYNC
RECEIVER
NOTE: Transmitter and receiver have the same clocks and frame syncs.
EXTERNAL CLOCK
INTERNAL CLOCK
SCKT
ESAI BIT
CLOCK
Figure 25-4. SAICR SYN Bit Operation
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1217

<!-- page 1218 -->

Address: 202_4000h base + D0h offset = 202_40D0h
Bit
31
30
29
28
27
26
25
24
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
ALC
TEBE
SYN
0
OF2
OF1
OF0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI_SAICR field descriptions
Field
Description
31–9
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
8
ALC
ESAI_SAICR Alignment Control. The ESAI is designed for 24-bit fractional data, thus shorter data words
are left aligned to the MSB (bit 23). Some applications use 16-bit fractional data. In those cases, shorter
data words may be left aligned to bit 15. The Alignment Control (ALC) bit supports these applications.
If ALC is set, transmitted and received words are left aligned to bit 15 in the transmit and receive shift
registers. If ALC is cleared, transmitted and received word are left aligned to bit 23 in the transmit and
receive shift registers.
While ALC is set, 20-bit and 24-bit words may not be used, and word length control should specify 8-, 12-,
or 16-bit words; otherwise, results are unpredictable.
7
TEBE
ESAI_SAICR Transmit External Buffer Enable. The Transmitter External Buffer Enable (TEBE) bit controls
the function of the FSR pin when in the synchronous mode. If the ESAI is configured for operation in the
synchronous mode (SYN=1), and TEBE is set while FSR pin is configured as an output (RFSD=1), the
FSR pin functions as the transmitter external buffer enable control to enable the use of an external buffers
on the transmitter outputs. If TEBE is cleared, the FSR pin functions as the serial I/O flag 1. See Port C
Control Register for a summary of the effects of TEBE on the FSR pin.
6
SYN
ESAI_SAICR Synchronous Mode Selection. The Synchronous Mode Selection (SYN) bit controls whether
the receiver and transmitter sections of the ESAI operate synchronously or asynchronously with respect to
each other (see Port C Control Register ). When SYN is cleared, the asynchronous mode is chosen and
independent clock and frame sync signals are used for the transmit and receive sections. When SYN is
set, the synchronous mode is chosen and the transmit and receive sections use common clock and frame
sync signals.
When in the synchronous mode (SYN=1), the transmit and receive sections use the transmitter section
clock generator as the source of the clock and frame sync for both sections. Also, the receiver clock pins
SCKR, FSR and HCKR now operate as I/O flags. Refer to Table 25-10, Table 25-11, and Table 25-12 for
the effects of SYN on the receiver clock pins.
5–3
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
2
OF2
ESAI_SAICR Serial Output Flag 2. The Serial Output Flag 2 (OF2) is a data bit used to hold data to be
send to the OF2 pin. When the ESAI is in the synchronous clock mode (SYN=1), the HCKR pin is
configured as the ESAI flag 2. If the receiver high frequency clock direction bit (RHCKD) is set, the HCKR
pin is the output flag OF2, and data present in the OF2 bit is written to the OF2 pin at the beginning of the
frame in normal mode or at the beginning of the next time slot in network mode.
1
OF1
ESAI_SAICR Serial Output Flag 1. The Serial Output Flag 1 (OF1) is a data bit used to hold data to be
send to the OF1 pin. When the ESAI is in the synchronous clock mode (SYN=1), the FSR pin is
configured as the ESAI flag 1. If the receiver frame sync direction bit (RFSD) is set and the TEBE bit is
cleared, the FSR pin is the output flag OF1, and data present in the OF1 bit is written to the OF1 pin at the
beginning of the frame in normal mode or at the beginning of the next time slot in network mode.
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1218
NXP Semiconductors

<!-- page 1219 -->

ESAI_SAICR field descriptions (continued)
Field
Description
0
OF0
ESAI_SAICR Serial Output Flag 0. The Serial Output Flag 0 (OF0) is a data bit used to hold data to be
send to the OF0 pin. When the ESAI is in the synchronous clock mode (SYN=1), the SCKR pin is
configured as the ESAI flag 0. If the receiver serial clock direction bit (RCKD) is set, the SCKR pin is the
output flag OF0, and data present in the OF0 bit is written to the OF0 pin at the beginning of the frame in
normal mode or at the beginning of the next time slot in network mode.
25.6.14
Transmit Control Register (ESAI_TCR)
The read/write Transmit Control Register (ESAI_TCR) controls the ESAI transmitter
section. Interrupt enable bits for the transmitter section are provided in this control
register. Operating modes are also selected in this register.
Table 25-4. Transmit Network Mode Selection
TMOD1
TMOD0
TDC4-TDC0
Transmitter Network Mode
0
0
0x0-0x1F
Normal Mode
0
1
0x0
On-Demand Mode
0
1
0x1-0x1F
Network Mode
1
0
X
Reserved
1
1
0x0C
AC97
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1219

<!-- page 1220 -->

SERIAL CLOCK
FRAME SYNC
SERIAL DATA
NORMAL MODE
TRANSMITTER INTERRUPT (OR DMA REQUEST)
AND FLAGS SET
RECEIVER INTERRUPT (OR DMA
REQUEST) AND FLAGS SET
NETWORK MODE
TRANSMITTER INTERRUPT (OR DMA REQUEST)
AND FLAGS SET
RECEIVER INTERRUPT (OR DMA
REQUEST) AND FLAGS SET
DATA
DATA
SLOT 0
SLOT 1
SLOT 2
SLOT 0
SLOT 1
SERIAL CLOCK
FRAME SYNC
SERIAL DATA
NOTE: Interrupts occur and data is transferred once per frame sync.
NOTE: Interrupts occur and a word may be transferred at every time slot.
Figure 25-5. Normal and Network Operation
Table 25-5. ESAI Transmit Slot and Word Length Selection
TSWS4
TSWS3
TSWS2
TSWS1
TSWS0
SLOT LENGTH
WORD
LENGTH
0
0
0
0
0
8
8
0
0
1
0
0
12
8
0
0
0
0
1
12
0
1
0
0
0
16
8
0
0
1
0
1
12
0
0
0
1
0
16
0
1
1
0
0
20
8
0
1
0
0
1
12
0
0
1
1
0
16
0
0
0
1
1
20
1
0
0
0
0
24
8
0
1
1
0
1
12
0
1
0
1
0
16
0
0
1
1
1
20
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1220
NXP Semiconductors

<!-- page 1221 -->

Table 25-5. ESAI Transmit Slot and Word Length Selection
(continued)
TSWS4
TSWS3
TSWS2
TSWS1
TSWS0
SLOT LENGTH
WORD
LENGTH
1
1
1
1
0
24
1
1
0
0
0
32
8
1
0
1
0
1
12
1
0
0
1
0
16
0
1
1
1
1
20
1
1
1
1
1
24
0
1
0
1
1
Reserved
0
1
1
1
0
1
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
1
0
0
1
0
1
1
0
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
1
0
1
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
1
0
1
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1221

<!-- page 1222 -->

DATA
DATA
SERIAL CLOCK
RX, TX SERIAL DATA
SERIAL CLOCK
RX, TX FRAME SYNC
RX, TX SERIAL DATA
DATA
DATA
WORD LENGTH: TFSL=0, RFSL=0
ONE BIT LENGTH: TFSL=1, RFSL=1
DATA
DATA
SERIAL CLOCK
MIXED FRAME LENGTH: TFSL=0, RFSL=1
DATA
DATA
RX FRAME SYNC
RX SERIAL DATA
TX FRAME SYNC
TX SERIAL DATA
DATA
DATA
NOTE: Frame sync occurs while data is valid.
NOTE: Frame sync occurs for one bit time preceding the data.
SERIAL CLOCK
MIXED FRAME LENGTH: TFSL=1, RFSL=0
DATA
DATA
DATA
DATA
RX, TX FRAME SYNC
RX FRAME SYNC
RX SERIAL DATA
TX FRAME SYNC
TX SERIAL DATA
SERIAL CLOCK
RX, TX SERIAL DATA
SERIAL CLOCK
Figure 25-6. Frame Length Selection
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1222
NXP Semiconductors

<!-- page 1223 -->

Address: 202_4000h base + D4h offset = 202_40D4h
Bit
31
30
29
28
27
26
25
24
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
TLIE
TIE
TEDIE
TEIE
TPR
0
PADC
TFSR
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
TFSL
TSWS
TMOD
TWA
TSHFD
TE5
TE4
TE3
TE2
TE1
TE0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI_TCR field descriptions
Field
Description
31–24
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
23
TLIE
ESAI_TCR Transmit Last Slot Interrupt Enable. TLIE enables an interrupt at the beginning of last slot of a
frame in network mode. When TLIE is set the Core is interrupted at the start of the last slot in a frame in
network mode regardless of the transmit mask register setting. When TLIE is cleared the transmit last slot
interrupt is disabled. TLIE is disabled when TDC=0x00000 (on-demand mode). The use of the transmit
last slot interrupt is described in ESAI Interrupt Requests.
22
TIE
ESAI_TCR Transmit Interrupt Enable. The Core is interrupted when TIE and the TDE flag in the
ESAI_SAISR status register are set. When TIE is cleared, this interrupt is disabled. Writing data to all the
data registers of the enabled transmitters or to ESAI_TSR clears TDE, thus clearing the interrupt.
Transmit interrupts with exception have higher priority than normal transmit data interrupts, therefore if
exception occurs (TUE is set) and TEIE is set, the ESAI requests an ESAI transmit data with exception
interrupt from the interrupt controller.
21
TEDIE
ESAI_TCR Transmit Even Slot Data Interrupt Enable. The TEDIE control bit is used to enable the transmit
even slot data interrupts. If TEDIE is set, the transmit even slot data interrupts are enabled. If TEDIE is
cleared, the transmit even slot data interrupts are disabled. A transmit even slot data interrupt request is
generated if TEDIE is set and the TEDE status flag in the ESAI_SAISR status register is set. Even time
slots are all even-numbered time slots (0, 2, 4, etc.) when operating in network mode. The zero time slot in
the frame is marked by the frame sync signal and is considered to be even. Writing data to all the data
registers of the enabled transmitters or to ESAI_TSR clears the TEDE flag, thus servicing the interrupt.
Transmit interrupts with exception have higher priority than transmit even slot data interrupts, therefore if
exception occurs (TUE is set) and TEIE is set, the ESAI requests an ESAI transmit data with exception
interrupt from the interrupt controller.
20
TEIE
ESAI_TCR Transmit Exception Interrupt Enable. When TEIE is set, the Core is interrupted when both TDE
and TUE in the ESAI_SAISR status register are set. When TEIE is cleared, this interrupt is disabled.
Reading the ESAI_SAISR status register followed by writing to all the data registers of the enabled
transmitters clears TUE, thus clearing the pending interrupt.
19
TPR
ESAI_TCR Transmit Section Personal Reset. The TPR control bit is used to put the transmitter section of
the ESAI in the personal reset state. The receiver section is not affected. When TPR is cleared, the
transmitter section may operate normally. When TPR is set, the transmitter section enters the personal
reset state immediately. When in the personal reset state, the status bits are reset to the same state as
after hardware reset. The control bits are not affected by the personal reset state. The transmitter data
pins are tri-stated while in the personal reset state; if a stable logic level is desired, the transmitter data
pins should be defined as GPIO outputs, or external pull-up or pull-down resistors should be used. The
Table continues on the next page...
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1223

<!-- page 1224 -->

ESAI_TCR field descriptions (continued)
Field
Description
transmitter clock outputs drive zeroes while in the personal reset state. Note that to leave the personal
reset state by clearing TPR, the procedure described in ESAI Initialization Examples should be followed.
18
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
17
PADC
ESAI_TCR Transmit Zero Padding Control. When PADC is cleared, zero padding is disabled. When
PADC is set, zero padding is enabled. PADC, in conjunction with the TCR[TWA] control bit, determines
the way that padding is done for operating modes where the word length is less than the slot length. See
the TCR[TWA] bit description in bit 7 for more details.
Because the data word is shorter than the slot length, the data word is extended until achieving the slot
length, according to the following rule:
If the data word is left-aligned (TCR[TWA]=0), and zero padding is disabled (PADC=0), the last data bit is
repeated after the data word has been transmitted. If zero padding is enabled (PADC=1), zeroes are
transmitted after the data word has been transmitted.
If the data word is right-aligned (TCR[TWA]=1), and zero padding is disabled (PADC=0), the first data bit
is repeated before the transmission of the data word. If zero padding is enabled (PADC=1), zeroes are
transmitted before the transmission of the data word.
16
TFSR
ESAI_TCR Transmit Frame Sync Relative Timing. TFSR determines the relative timing of the transmit
frame sync signal as referred to the serial data lines, for a word length frame sync only (TFSL=0). When
TFSR is cleared the word length frame sync occurs together with the first bit of the data word of the first
slot. When TFSR is set the word length frame sync starts one serial clock cycle earlier, that is, together
with the last bit of the previous data word.
15
TFSL
ESAI_TCR Transmit Frame Sync Length. The TFSL bit selects the length of frame sync to be generated
or recognized. If TFSL is cleared, a word-length frame sync is selected. If TFSL is set, a 1-bit clock period
frame sync is selected. See Figure 1-21 for examples of frame length selection.
14–10
TSWS
ESAI_TCR Tx Slot and Word Length Select (TSWS4-TSWS0). The TSWS4-TSWS0 bits are used to
select the length of the slot and the length of the data words being transferred through the ESAI. The word
length must be equal to or shorter than the slot length. The possible combinations are shown in Table
25-5. See also the ESAI data path programming model in Figure 25-2 and Figure 25-3.
9–8
TMOD
ESAI_TCR Transmit Network Mode Control (TMOD1-TMOD0). The TMOD1 and TMOD0 bits are used to
define the network mode of ESAI transmitters, as shown in Table 25-5. In the normal mode, the frame rate
divider determines the word transfer rate - one word is transferred per frame sync during the frame sync
time slot, as shown in Figure 25-5. In network mode, it is possible to transfer a word for every time slot, as
shown in Figure 25-5. For further details, refer to Modes of Operation
In order to comply with AC-97 specifications, TSWS4-TSWS0 should be set to 00011 (20-bit slot, 20-bit
word length), TFSL and TFSR should be cleared, and TDC4-TDC0 should be set to 0x0C (13 words in
frame). If TMOD=0b11 and the above recommendations are followed, the first slot and word will be 16 bits
long, and the next 12 slots and words will be 20 bits long, as required by the AC97 protocol.
7
TWA
ESAI_TCR Transmit Word Alignment Control. The Transmitter Word Alignment Control (TCR[TWA]) bit
defines the alignment of the data word in relation to the slot. This is relevant for the cases where the word
length is shorter than the slot length. If TCR[TWA] is cleared, the data word is left-aligned in the slot frame
during transmission. If TCR[TWA] is set, the data word is right-aligned in the slot frame during
transmission.
Because the data word is shorter than the slot length, the data word is extended until achieving the slot
length, according to the following rule:
If the data word is left-aligned (TCR[TWA]=0), and zero padding is disabled (PADC=0), the last data bit is
repeated after the data word has been transmitted. If zero padding is enabled (PADC=1), zeroes are
transmitted after the data word has been transmitted.
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1224
NXP Semiconductors

<!-- page 1225 -->

ESAI_TCR field descriptions (continued)
Field
Description
If the data word is right-aligned (TCR[TWA]=1), and zero padding is disabled (PADC=0), the first data bit
is repeated before the transmission of the data word. If zero padding is enabled (PADC=1), zeroes are
transmitted before the transmission of the data word.
6
TSHFD
ESAI_TCR Transmit Shift Direction. The TSHFD bit causes the transmit shift registers to shift data out
MSB first when TSHFD equals zero or LSB first when TSHFD equals one (see Figure 25-2 and Figure
25-3 .
5
TE5
ESAI_TCR ESAI Transmit 5 Enable. TE5 enables the transfer of data from ESAI_TX5 to the transmit shift
register #5. When TE5 is set and a frame sync is detected, the transmit #5 portion of the ESAI is enabled
for that frame. When TE5 is cleared, the transmitter #5 is disabled after completing transmission of data
currently in the ESAI transmit shift register. Data can be written to ESAI_TX5 when TE5 is cleared but the
data is not transferred to the transmit shift register #5.
The SDO5/SDI0 pin is the data input pin for ESAI_RX0 if TE5 is cleared and RE0 in the ESAI_RCR
register is set. If both RE0 and TE5 are cleared, the transmitter and receiver are disabled, and the pin is
tri-stated. Both RE0 and TE5 should not be set at the same time.
The normal mode transmit enable sequence is to write data to one or more transmit data registers before
setting TEx. The normal transmit disable sequence is to clear TEx, TIE and TEIE after TDE equals one.
In the network mode, the operation of clearing TE5 and setting it again disables the transmitter #5 after
completing transmission of the current data word until the beginning of the next frame. During that time
period, the SDO5/SDI0 pin remains in the high-impedance state. The on-demand mode transmit enable
sequence can be the same as the normal mode, or TE5 can be left enabled.
4
TE4
ESAI_TCR ESAI Transmit 4 Enable. TE4 enables the transfer of data from ESAI_TX4 to the transmit shift
register #4. When TE4 is set and a frame sync is detected, the transmit #4 portion of the ESAI is enabled
for that frame. When TE4 is cleared, the transmitter #4 is disabled after completing transmission of data
currently in the ESAI transmit shift register. Data can be written to ESAI_TX4 when TE4 is cleared but the
data is not transferred to the transmit shift register #4.
The SDO4/SDI1 pin is the data input pin for ESAI_RX1 if TE4 is cleared and RE1 in the RCR register is
set. If both RE1 and TE4 are cleared, the transmitter and receiver are disabled, and the pin is tri-stated.
Both RE1 and TE4 should not be set at the same time.
The normal mode transmit enable sequence is to write data to one or more transmit data registers before
setting TEx. The normal transmit disable sequence is to clear TEx, TIE and TEIE after TDE equals one.
In the network mode, the operation of clearing TE4 and setting it again disables the transmitter #4 after
completing transmission of the current data word until the beginning of the next frame. During that time
period, the SDO4/SDI1 pin remains in the high-impedance state. The on-demand mode transmit enable
sequence can be the same as the normal mode, or TE4 can be left enabled.
3
TE3
ESAI_TCR ESAI Transmit 3 Enable. TE3 enables the transfer of data from ESAI_TX3 to the transmit shift
register #3. When TE3 is set and a frame sync is detected, the transmit #3 portion of the ESAI is enabled
for that frame. When TE3 is cleared, the transmitter #3 is disabled after completing transmission of data
currently in the ESAI transmit shift register. Data can be written to ESAI_TX3 when TE3 is cleared but the
data is not transferred to the transmit shift register #3.
The SDO3/SDI2 pin is the data input pin for ESAI_RX2 if TE3 is cleared and RE2 in the ESAI_RCR
register is set. If both RE2 and TE3 are cleared, the transmitter and receiver are disabled, and the pin is
tri-stated. Both RE2 and TE3 should not be set at the same time.
The normal mode transmit enable sequence is to write data to one or more transmit data registers before
setting TEx. The normal transmit disable sequence is to clear TEx, TIE and TEIE after TDE equals one.
In the network mode, the operation of clearing TE3 and setting it again disables the transmitter #3 after
completing transmission of the current data word until the beginning of the next frame. During that time
period, the SDO3/SDI2 pin remains in the high-impedance state. The on-demand mode transmit enable
sequence can be the same as the normal mode, or TE3 can be left enabled.
Table continues on the next page...
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1225

<!-- page 1226 -->

ESAI_TCR field descriptions (continued)
Field
Description
2
TE2
ESAI_TCR ESAI Transmit 2 Enable. TE2 enables the transfer of data from ESAI_TX2 to the transmit shift
register #2. When TE2 is set and a frame sync is detected, the transmit #2 portion of the ESAI is enabled
for that frame. When TE2 is cleared, the transmitter #2 is disabled after completing transmission of data
currently in the ESAI transmit shift register. Data can be written to ESAI_TX2 when TE2 is cleared but the
data is not transferred to the transmit shift register #2.
The SDO2/SDI3 pin is the data input pin for ESAI_RX3 if TE2 is cleared and RE3 in the ESAI_RCR
register is set. If both RE3 and TE2 are cleared, the transmitter and receiver are disabled, and the pin is
tri-stated. Both RE3 and TE2 should not be set at the same time.
The normal mode transmit enable sequence is to write data to one or more transmit data registers before
setting TEx. The normal transmit disable sequence is to clear TEx, TIE and TEIE after TDE equals one.
In the network mode, the operation of clearing TE2 and setting it again disables the transmitter #2 after
completing transmission of the current data word until the beginning of the next frame. During that time
period, the SDO2/SDI3 pin remains in the high-impedance state. The on-demand mode transmit enable
sequence can be the same as the normal mode, or TE2 can be left enabled.
1
TE1
ESAI_TCR ESAI Transmit 1 Enable. TE1 enables the transfer of data from TX1 to the transmit shift
register #1. When TE1 is set and a frame sync is detected, the transmit #1 portion of the ESAI is enabled
for that frame. When TE1 is cleared, the transmitter #1 is disabled after completing transmission of data
currently in the ESAI transmit shift register. The SDO1 output is tri-stated, and any data present in TX1 is
not transmitted, that is, data can be written to TX1 with TE1 cleared, but data is not transferred to the
transmit shift register #1.
The normal mode transmit enable sequence is to write data to one or more transmit data registers before
setting TEx. The normal transmit disable sequence is to clear TEx, TIE and TEIE after TDE equals one.
In the network mode, the operation of clearing TE1 and setting it again disables the transmitter #1 after
completing transmission of the current data word until the beginning of the next frame. During that time
period, the SDO1 pin remains in the high-impedance state. The on-demand mode transmit enable
sequence can be the same as the normal mode, or TE1 can be left enabled.
0
TE0
ESAI_TCR ESAI Transmit 0 Enable. TE0 enables the transfer of data from ESAI_TX0 to the transmit shift
register #0. When TE0 is set and a frame sync is detected, the transmit #0 portion of the ESAI is enabled
for that frame. When TE0 is cleared, the transmitter #0 is disabled after completing transmission of data
currently in the ESAI transmit shift register. The SDO0 output is tri-stated, and any data present in
ESAI_TX0 is not transmitted, that is, data can be written to ESAI_TX0 with TE0 cleared, but data is not
transferred to the transmit shift register #0.
The normal mode transmit enable sequence is to write data to one or more transmit data registers before
setting TEx. The normal transmit disable sequence is to clear TEx, TIE and TEIE after TDE equals one.
In the network mode, the operation of clearing TE0 and setting it again disables the transmitter #0 after
completing transmission of the current data word until the beginning of the next frame. During that time
period, the SDO0 pin remains in the high-impedance state.The on-demand mode transmit enable
sequence can be the same as the normal mode, or TE0 can be left enabled.
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1226
NXP Semiconductors

<!-- page 1227 -->

25.6.15
Transmit Clock Control Register (ESAI_TCCR)
The read/write Transmitter Clock Control Register (ESAI_TCCR) controls the ESAI
transmitter clock generator bit and frame sync rates, the bit clock and high frequency
clock sources and the directions of the HCKT, FST and SCKT signals. In the
synchronous mode (SYN=1), the bit clock defined for the transmitter determines the
receiver bit clock as well. ESAI_TCCR also controls the number of words per frame for
the serial data. Hardware and software reset clear all the bits of the ESAI_TCCR register.
Care should be taken in asynchronous mode whenever the frame sync clock (FSR, FST)
is not sourced directly from its associated bit clock (SCKR, SCKT). Proper phase
relationships must be maintained between these clocks in order to guarantee proper
operation of the ESAI.
NOTE
ARM Core clock is ipg_clk_esai in block ESAI which is from
CCM's ahb_clk_root.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1227

<!-- page 1228 -->

FLAG0 OUT
(SYNC MODE)
FLAG0 IN
(SYNC MODE)
SCKR
SCKT
RCKD
TCKD
SYN=1
SYN=0
RCLOCK
TCLOCK
INTERNAL BIT CLOCK
SYN=1
RSWS4-RSWS0
TSWS4-TSWS0
RX WORD
LENGTH DIVIDER
TX WORD
LENGTH DIVIDER
RX SHIFT REGISTER
TX SHIFT REGISTER
DIVIDE
BY 2
PRESCALE
DIVIDE BY 1
OR
DIVIDE BY 8
DIVIDER
DIVIDE BY 1
TO DIVIDE BY 
256
TPSR
RX WORD
CLOCK
TX WORD
CLOCK
SYN=0
DIVIDE
BY 2
PRESCALE
DIVIDE BY 1
OR
DIVIDE BY 8
DIVIDER
DIVIDE BY 1
TO DIVIDE BY 
256
Fsys
RPSR
RHCKD=1
RHCKD=0
HCKR
RHCKD
DIVIDER
DIVIDE BY 1
TO DIVIDE BY 
16
THCKD=1
THCKD=0
HCKT
THCKD
DIVIDER
DIVIDE BY 1
TO DIVIDE BY 
16
INTERNAL BIT CLOCK
EXTAL
ERI=1
ERI=0
ERO=0
ERO=1
Fsys
EXTAL
ETI=1
ETI=0
EXTAL
ETO=0
ETO=1
EXTAL
To SPDIF Xmt
RPM0-RPM7
TPM0-TPM7
TFP0-TFP3
RFP0-RFP3
See HCKR Pin Definition 
Table (ESAI_RCCR) for
options when SYN=1
HCKR FLAG2 IN/OUT
Figure 25-7. ESAI Clock Generator Functional Block Diagram
NOTE
1. ETI, ETO, ERI and ERO bit descriptions are covered in
ESAI Control Register (ESAI_ECR). 2. Fsys is the ESAI
system 133 MHz clock. 3. EXTAL is the on-chip clock sources
other than ESAI system 133MHz clock.
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1228
NXP Semiconductors

<!-- page 1229 -->

RX WORD
CLOCK
RECEIVER
FRAME RATE
DIVIDER
SYNC
TYPE
RECEIVE
CONTROL 
LOGIC
RECEIVE
FRAME SYNC
SYN= 0
RFSD= 0
FLAG1 IN
(SYNC mODE)
FLAG1 OUT
(SYNC MODE)
SYN=1
SYN=0
FSR
RFSD
FST
TFSD
RFSD= 1
INTERNAL RX FRAME CLOCK
RFSL
RDC0- RDC4
TX WORD
CLOCK
TDC0- TDC4
TFSL
TRANSMITTER
FRAME RATE
DIVIDER
TRANSMIT
CONTROL 
LOGIC
TRANSMIT
FRAME SYNC
SYNC
TYPE
SYN=1
INTERNAL TX FRAME CLOCK
Figure 25-8. ESAI Frame Sync Generator Functional Block Diagram
Table 25-6. Transmitter High Frequency Clock Divider
TFP3-TFP0
Divide Ratio
0x0
1
0x1
2
0x2
3
0x3
4
...
...
0xF
16
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1229

<!-- page 1230 -->

Address: 202_4000h base + D8h offset = 202_40D8h
Bit
31
30
29
28
27
26
25
24
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
THCKD
TFSD
TCKD
THCKP
TFSP
TCKP
TFP
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
TFP
TDC
TPSR
TPM
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI_TCCR field descriptions
Field
Description
31–24
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
23
THCKD
ESAI_TCCR Transmit High Frequency Clock Direction. THCKD controls the direction of the HCKT pin.
When THCKD is cleared, HCKT is an input; when THCKD is set, HCKT is an output (see Table 25-2).
22
TFSD
ESAI_TCCR Transmit Frame Sync Signal Direction. TFSD controls the direction of the FST pin. When
TFSD is cleared, FST is an input; when TFSD is set, FST is an output (see Table 25-2).
21
TCKD
ESAI_TCCR Transmit Clock Source Direction. The Transmitter Clock Source Direction (TCKD) bit selects
the source of the clock signal used to clock the transmit shift registers in the asynchronous mode (SYN=0)
and the transmit shift registers and the receive shift registers in the synchronous mode (SYN=1). When
TCKD is set, the internal clock source becomes the bit clock for the transmit shift registers and word
length divider and is the output on the SCKT pin. When TCKD is cleared, the clock source is external; the
internal clock generator is disconnected from the SCKT pin, and an external clock source may drive this
pin (see Table 25-2).
20
THCKP
ESAI_TCCR Transmit High Frequency Clock Polarity
The Transmitter High Frequency Clock Polarity (THCKP) bit controls the polarity of the HCKT.
0 - Normal polarity
1 - Inverted polarity
19
TFSP
ESAI_TCCR Transmit Frame Sync Polarity. The Transmitter Frame Sync Polarity (TFSP) bit determines
the polarity of the transmit frame sync signal. When TFSP is cleared, the frame sync signal polarity is
positive, that is, the frame start is indicated by a high level on the frame sync pin. When TFSP is set, the
frame sync signal polarity is negative, that is, the frame start is indicated by a low level on the frame sync
pin.
18
TCKP
ESAI_TCCR Transmit Clock Polarity. The Transmitter Clock Polarity (TCKP) bit controls on which bit clock
edge data and frame sync are clocked out and latched in. If TCKP is cleared the data and the frame sync
are clocked out on the rising edge of the transmit bit clock and latched in on the falling edge of the transmit
bit clock. If TCKP is set the falling edge of the transmit clock is used to clock the data out and frame sync
and the rising edge of the transmit clock is used to latch the data and frame sync in.
17–14
TFP
ESAI_TCCR Tx High Frequency Clock Divider. The TFP3-TFP0 bits control the divide ratio of the
transmitter high frequency clock to the transmitter serial bit clock when the source of the high frequency
clock and the bit clock is the internal ARM Core clock. When the HCKT input is being driven from an
external high frequency clock, the TFP3-TFP0 bits specify an additional division ratio in the clock divider
chain. Table 25-6 shows the specification for the divide ratio. Figure 25-7 shows the ESAI high frequency
clock generator functional diagram.
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1230
NXP Semiconductors

<!-- page 1231 -->

ESAI_TCCR field descriptions (continued)
Field
Description
13–9
TDC
ESAI_TCCR Tx Frame Rate Divider Control. The TDC4-TDC0 bits control the divide ratio for the
programmable frame rate dividers used to generate the transmitter frame clocks.
In network mode, this ratio may be interpreted as the number of words per frame minus one. The divide
ratio may range from 2 to 32 (TDC=0x00001 to 0x11111) for network mode. A divide ratio of one
(TDC=0x00000) in network mode is a special case (on-demand mode).
In normal mode, this ratio determines the word transfer rate. The divide ratio may range from 1 to 32
(TDC=0x00000 to 0x11111) for normal mode. In normal mode, a divide ratio of 1 (TDC=0x00000) provides
continuous periodic data word transfers. A bit-length frame sync (TFSL=1) must be used in this case.
The ESAI frame sync generator functional diagram is shown in Figure 25-8
8
TPSR
ESAI_TCCR Transmit Prescaler Range. The TPSR bit controls a fixed divide-by-eight prescaler in series
with the variable prescaler. This bit is used to extend the range of the prescaler for those cases where a
slower bit clock is desired. When TPSR is set, the fixed prescaler is bypassed. When TPSR is cleared, the
fixed divide-by-eight prescaler is operational (see Figure 25-7). The maximum internally generated bit
clock frequency is Fsys/6; the minimum internally generated bit clock frequency is Fsys/(2 x 8 x 256 x
16)=Fsys/65536.
NOTE: Do not use the combination TPSR = 1 and TPM7-RPM0 = 0x00, which causes synchronization
problems when using the internal core clock as source (THCKD = 1 or TCKD = 1).
TPM
ESAI_TCCR Transmit Prescale Modulus Select. The TPM7-TPM0 bits specify the divide ratio of the
prescale divider in the ESAI transmitter clock generator. A divide ratio from 1 to 256 (TPM=0x00 to 0xFF)
may be selected. The bit clock output is available at the transmit serial bit clock (SCKT) pin. The bit clock
output is also available internally for use as the bit clock to shift the transmit and receive shift registers.
The ESAI transmit clock generator functional diagram is shown in Figure 25-7.
25.6.16
Receive Control Register (ESAI_RCR)
The read/write Receive Control Register (ESAI_RCR) controls the ESAI receiver
section. Interrupt enable bits for the receivers are provided in this control register. The
receivers are enabled in this register (0,1,2 or 3 receivers can be enabled) if the input data
pin is not used by a transmitter. Operating modes are also selected in this register.
Table 25-7. ESAI Receive Network Mode Selection
RMOD1
RMOD0
RDC4-RDC0
Receiver Network Mode
0
0
0x0-0x1F
Normal Mode
0
1
0x0
On-Demand Mode
0
1
0x1-0x1F
Network Mode
1
0
X
Reserved
1
1
0x0C
AC97
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1231

<!-- page 1232 -->

Table 25-8. ESAI Receive Slot and Word Length Selection
RSWS4
RSWS3
RSWS2
RSWS1
RSWS0
SLOT LENGTH
WORD
LENGTH
0
0
0
0
0
8
8
0
0
1
0
0
12
8
0
0
0
0
1
12
0
1
0
0
0
16
8
0
0
1
0
1
12
0
0
0
1
0
16
0
1
1
0
0
20
8
0
1
0
0
1
12
0
0
1
1
0
16
0
0
0
1
1
20
1
0
0
0
0
24
8
0
1
1
0
1
12
0
1
0
1
0
16
0
0
1
1
1
20
1
1
1
1
0
24
1
1
0
0
0
32
8
1
0
1
0
1
12
1
0
0
1
0
16
0
1
1
1
1
20
1
1
1
1
1
24
0
1
0
1
1
Reserved
0
1
1
1
0
1
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
1
0
0
1
0
1
1
0
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
1
0
1
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
1
0
1
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1232
NXP Semiconductors

<!-- page 1233 -->

Address: 202_4000h base + DCh offset = 202_40DCh
Bit
31
30
29
28
27
26
25
24
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
RLIE
RIE
REDIE
REIE
RPR
0
RFSR
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
RFSL
RSWS
RMOD
RWA
RSHFD
0
RE3
RE2
RE1
RE0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI_RCR field descriptions
Field
Description
31–24
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
23
RLIE
ESAI_RCR Receive Last Slot Interrupt Enable. RLIE enables an interrupt after the last slot of a frame
ended in network mode only. When RLIE is set the Core is interrupted after the last slot in a frame ended
regardless of the receive mask register setting. When RLIE is cleared the receive last slot interrupt is
disabled. Hardware and software reset clear RLIE. RLIE is disabled when RDC=00000 (on-demand
mode). The use of the receive last slot interrupt is described in ESAI Interrupt Requests.
22
RIE
ESAI_RCR Receive Interrupt Enable. The Core is interrupted when RIE and the RDF flag in the
ESAI_SAISR status register are set. When RIE is cleared, this interrupt is disabled. Reading the receive
data registers of the enabled receivers clears RDF, thus clearing the interrupt.
Receive interrupts with exception have higher priority than normal receive data interrupts, therefore if
exception occurs (ROE is set) and REIE is set, the ESAI requests an ESAI receive data with exception
interrupt from the interrupt controller.
21
REDIE
ESAI_RCR Receive Even Slot Data Interrupt Enable. The REDIE control bit is used to enable the receive
even slot data interrupts. If REDIE is set, the receive even slot data interrupts are enabled. If REDIE is
cleared, the receive even slot data interrupts are disabled. A receive even slot data interrupt request is
generated if REDIE is set and the REDF status flag in the ESAI_SAISR status register is set. Even time
slots are all even-numbered time slots (0, 2, 4, etc.) when operating in network mode. The zero time slot is
marked by the frame sync signal and is considered to be even. Reading all the data registers of the
enabled receivers clears the REDF flag, thus servicing the interrupt.
Receive interrupts with exception have higher priority than receive even slot data interrupts, therefore if
exception occurs (ROE is set) and REIE is set, the ESAI requests an ESAI receive data with exception
interrupt from the interrupt controller.
20
REIE
ESAI_RCR Receive Exception Interrupt Enable. When REIE is set, the Core is interrupted when both RDF
and ROE in the ESAI_SAISR status register are set. When REIE is cleared, this interrupt is disabled.
Reading the ESAI_SAISR status register followed by reading the enabled receivers data registers clears
ROE, thus clearing the pending interrupt.
19
RPR
ESAI_RCR Receiver Section Personal Reset. The RPR control bit is used to put the receiver section of
the ESAI in the personal reset state. The transmitter section is not affected. When RPR is cleared, the
receiver section may operate normally. When RPR is set, the receiver section enters the personal reset
state immediately. When in the personal reset state, the status bits are reset to the same state as after
hardware reset.The control bits are not affected by the personal reset state.The receiver data pins are
disconnected while in the personal reset state.
Table continues on the next page...
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1233

<!-- page 1234 -->

ESAI_RCR field descriptions (continued)
Field
Description
NOTE: To leave the personal reset state by clearing RPR, the procedure described in ESAI Initialization
Examples should be followed.
18–17
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
16
RFSR
ESAI_RCR Receiver Frame Sync Relative Timing. RFSR determines the relative timing of the receive
frame sync signal as referred to the serial data lines, for a word length frame sync only. When RFSR is
cleared the word length frame sync occurs together with the first bit of the data word of the first slot. When
RFSR is set the word length frame sync starts one serial clock cycle earlier, that is, together with the last
bit of the previous data word.
15
RFSL
ESAI_RCR Receiver Frame Sync Length. The RFSL bit selects the length of the receive frame sync to be
generated or recognized. If RFSL is cleared, a word-length frame sync is selected. If RFSL is set, a 1-bit
clock period frame sync is selected. Refer to Figure 25-6 for examples of frame length selection.
14–10
RSWS
ESAI_RCR Receiver Slot and Word Select. The RSWS4-RSWS0 bits are used to select the length of the
slot and the length of the data words being received through the ESAI. The word length must be equal to
or shorter than the slot length. The possible combinations are shown in Table 25-8. See also the ESAI
data path programming model in Figure 25-2 and Figure 25-3.
9–8
RMOD
ESAI_RCR Receiver Network Mode Control. The RMOD1 and RMOD0 bits are used to define the network
mode of the ESAI receivers, as shown in Table 25-7. In the normal mode, the frame rate divider
determines the word transfer rate - one word is transferred per frame sync during the frame sync time slot,
as shown in Figure 25-5. In network mode, it is possible to transfer a word for every time slot, as shown in
Figure 25-5. For more details, see Modes of Operation.
In order to comply with AC-97 specifications, RSWS4-RSWS0 should be set to 0x00011 (20-bit slot, 20-bit
word); RFSL and RFSR should be cleared, and RDC4-RDC0 should be set to 0x0C (13 words in frame).
7
RWA
ESAI_RCR Receiver Word Alignment Control. The Receiver Word Alignment Control (RWA) bit defines
the alignment of the data word in relation to the slot. This is relevant for the cases where the word length is
shorter than the slot length. If RWA is cleared, the data word is assumed to be left-aligned in the slot
frame. If RWA is set, the data word is assumed to be right-aligned in the slot frame.
If the data word is shorter than the slot length, the data bits which are not in the data word field are
ignored.
For data word lengths of less than 24 bits, the data word is right-extended with zeroes before being stored
in the receive data registers.
6
RSHFD
ESAI_RCR Receiver Shift Direction. The RSHFD bit causes the receiver shift registers to shift data in
MSB first when RSHFD is cleared or LSB first when RSHFD is set (see Figure 25-2 and Figure 25-3).
5–4
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
3
RE3
ESAI_RCR ESAI Receiver 3 Enable. When RE3 is set and TE2 is cleared, the ESAI receiver 3 is enabled
and samples data at the SDO2/SDI3 pin. ESAI_TX2 and ESAI_RX3 should not be enabled at the same
time (RE3=1 and TE2=1). When RE3 is cleared, receiver 3 is disabled by inhibiting data transfer into
ESAI_RX3. If this bit is cleared while receiving a data word, the remainder of the word is shifted in and
transferred to the ESAI_RX3 data register.
If RE3 is set while some of the other receivers are already in operation, the first data word received in
ESAI_RX3 will be invalid and must be discarded.
2
RE2
ESAI_RCR ESAI Receiver 2 Enable. When RE2 is set and TE3 is cleared, the ESAI receiver 2 is enabled
and samples data at the SDO3/SDI2 pin. ESAI_TX3 and ESAI_RX2 should not be enabled at the same
time (RE2=1 and TE3=1). When RE2 is cleared, receiver 2 is disabled by inhibiting data transfer into
ESAI_RX2. If this bit is cleared while receiving a data word, the remainder of the word is shifted in and
transferred to the ESAI_RX2 data register.
If RE2 is set while some of the other receivers are already in operation, the first data word received in
ESAI_RX2 will be invalid and must be discarded.
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1234
NXP Semiconductors

<!-- page 1235 -->

ESAI_RCR field descriptions (continued)
Field
Description
1
RE1
ESAI_RCR ESAI Receiver 1 Enable. When RE1 is set and TE4 is cleared, the ESAI receiver 1 is enabled
and samples data at the SDO4/SDI1 pin. ESAI_TX4 and ESAI_RX1 should not be enabled at the same
time (RE1=1 and TE4=1). When RE1 is cleared, receiver 1 is disabled by inhibiting data transfer into
ESAI_RX1. If this bit is cleared while receiving a data word, the remainder of the word is shifted in and
transferred to the ESAI_RX1 data register.
If RE1 is set while some of the other receivers are already in operation, the first data word received in
ESAI_RX1 will be invalid and must be discarded.
0
RE0
ESAI_RCR ESAI Receiver 0 Enable. When RE0 is set and TE5 is cleared, the ESAI receiver 0 is enabled
and samples data at the SDO5/SDI0 pin. ESAI_TX5 and ESAI_RX0 should not be enabled at the same
time (RE0=1 and TE5=1). When RE0 is cleared, receiver 0 is disabled by inhibiting data transfer into
ESAI_RX0. If this bit is cleared while receiving a data word, the remainder of the word is shifted in and
transferred to the ESAI_RX0 data register.
If RE0 is set while some of the other receivers are already in operation, the first data word received in
ESAI_RX0 will be invalid and must be discarded.
25.6.17
Receive Clock Control Register (ESAI_RCCR)
The read/write Receiver Clock Control Register (ESAI_RCCR) controls the ESAI
receiver clock generator bit and frame sync rates, word length, and number of words per
frame for the serial data. The ESAI_RCCR control bits are described in the following
paragraphs.
NOTE
ARM Core clock is ipg_clk_esai in block ESAI which is from
CCM's ahb_clk_root.
Table 25-9. Receiver High Frequency Clock Divider
RFP3-RFP0
Divide Ratio
0x0
1
0x1
2
0x2
3
0x3
4
...
...
0xF
16
Table 25-10. SCKR Pin Definition Table
Control Bits
SCKR PIN
SYN
RCKD
0
0
SCKR input
Table continues on the next page...
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1235

<!-- page 1236 -->

Table 25-10. SCKR Pin Definition Table (continued)
Control Bits
SCKR PIN
SYN
RCKD
0
1
SCKR output
1
0
IF0
1
1
OF0
Table 25-11. FSR Pin Definition Table
Control Bits
FSR Pin
SYN
TEBE
RFSD
0
X
0
FSR input
0
X
1
FSR output
1
0
0
IF1
1
0
1
OF1
1
1
0
reserved
1
1
1
Transmitter Buffer Enable
Table 25-12. HCKR Pin Definition Table
Control Bits
HCKR PIN
SYN
RHCKD
0
0
HCKR input
0
1
HCKR output
1
0
IF2
1
1
OF2
Address: 202_4000h base + E0h offset = 202_40E0h
Bit
31
30
29
28
27
26
25
24
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
RHCKD
RFSD
RCKD
RHCKP
RFSP
RCKP
RFP
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
RFP
RDC
RPSR
RPM
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1236
NXP Semiconductors

<!-- page 1237 -->

ESAI_RCCR field descriptions
Field
Description
31–24
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
23
RHCKD
ESAI_RCCR Receiver High Frequency Clock Direction. The Receiver High Frequency Clock Direction
(RHCKD) bit selects the source of the receiver high frequency clock when in the asynchronous mode
(SYN=0) and the IF2/OF2 flag direction in the synchronous mode (SYN=1).
In the asynchronous mode, when RHCKD is set, the internal clock generator becomes the source of the
receiver high frequency clock and is the output on the HCKR pin. In the asynchronous mode, when
RHCKD is cleared, the receiver high frequency clock source is external; the internal clock generator is
disconnected from the HCKR pin, and an external clock source may drive this pin.
When RHCKD is cleared, HCKR is an input; when RHCKD is set, HCKR is an output.
In the synchronous mode when RHCKD is set, the HCKR pin becomes the OF2 output flag. If RHCKD is
cleared, the HCKR pin becomes the IF2 input flag. Refer to Table 25-1 and Table 25-12.
22
RFSD
ESAI_RCCR Receiver Frame Sync Signal Direction. The Receiver Frame Sync Signal Direction (RFSD)
bit selects the source of the receiver frame sync signal when in the asynchronous mode (SYN=0) and the
IF1/OF1/Transmitter Buffer Enable flag direction in the synchronous mode (SYN=1).
In the asynchronous mode, when RFSD is set, the internal clock generator becomes the source of the
receiver frame sync and is the output on the FSR pin. In the asynchronous mode, when RFSD is cleared,
the receiver frame sync source is external; the internal clock generator is disconnected from the FSR pin,
and an external clock source may drive this pin.
In the synchronous mode when RFSD is set, the FSR pin becomes the OF1 output flag or the Transmitter
Buffer Enable, according to the TEBE control bit. If RFSD is cleared, the FSR pin becomes the IF1 input
flag. Refer to Table 25-1 and Table 25-11 .
21
RCKD
ESAI_RCCR Receiver Clock Source Direction. The Receiver Clock Source Direction (RCKD) bit selects
the source of the clock signal used to clock the receive shift register in the asynchronous mode (SYN=0)
and the IF0/OF0 flag direction in the synchronous mode (SYN=1).
In the asynchronous mode, when RCKD is set, the internal clock source becomes the bit clock for the
receive shift registers and word length divider and is the output on the SCKR pin. In the asynchronous
mode when RCKD is cleared, the clock source is external; the internal clock generator is disconnected
from the SCKR pin, and an external clock source may drive this pin.
In the synchronous mode when RCKD is set, the SCKR pin becomes the OF0 output flag. If RCKD is
cleared, the SCKR pin becomes the IF0 input flag. Refer to Table 25-1 and Table 25-10.
20
RHCKP
ESAI_RCCR Receiver High Frequency Clock Polarity. The Receiver High Frequency Clock Polarity
(RHCKP) bit controls on which bit clock edge data and frame sync are clocked out and latched in. If
RHCKP is cleared the data and the frame sync are clocked out on the rising edge of the receive high
frequency bit clock and the frame sync is latched in on the falling edge of the receive bit clock. If RHCKP
is set the falling edge of the receive clock is used to clock the data and frame sync out and the rising edge
of the receive clock is used to latch the frame sync in.
19
RFSP
ESAI_RCCR Receiver Frame Sync Polarity. The Receiver Frame Sync Polarity (RFSP) determines the
polarity of the receive frame sync signal. When RFSP is cleared the frame sync signal polarity is positive,
that is, the frame start is indicated by a high level on the frame sync pin. When RFSP is set the frame sync
signal polarity is negative, that is, the frame start is indicated by a low level on the frame sync pin.
18
RCKP
The Receiver Clock Polarity (RCKP) bit controls on which bit clock edge data and frame sync are clocked
out and latched in. If RCKP is cleared the data and the frame sync are clocked out on the rising edge of
the receive bit clock and the frame sync is latched in on the falling edge of the receive bit clock. If RCKP is
set the falling edge of the receive clock is used to clock the data and frame sync out and the rising edge of
the receive clock is used to latch the frame sync in.
17–14
RFP
ESAI_RCCR Rx High Frequency Clock Divider. The RFP3-RFP0 bits control the divide ratio of the
receiver high frequency clock to the receiver serial bit clock when the source of the receiver high
frequency clock and the bit clock is the internal Arm Core clock. When the HCKR input is being driven
Table continues on the next page...
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1237

<!-- page 1238 -->

ESAI_RCCR field descriptions (continued)
Field
Description
from an external high frequency clock, the RFP3-RFP0 bits specify an additional division ration in the
clock divider chain. Table 25-9 provides the specification of the divide ratio. Figure 25-7 shows the ESAI
high frequency generator functional diagram.
13–9
RDC
ESAI_RCCR Rx Frame Rate Divider Control. The RDC4-RDC0 bits control the divide ratio for the
programmable frame rate dividers used to generate the receiver frame clocks.
In network mode, this ratio may be interpreted as the number of words per frame minus one. The divide
ratio may range from 2 to 32 (RDC=0x00001 to 0x11111) for network mode. A divide ratio of one
(RDC=0x00000) in network mode is a special case (on-demand mode).
In normal mode, this ratio determines the word transfer rate. The divide ratio may range from 1 to 32
(RDC=0x00000 to 0x11111) for normal mode. In normal mode, a divide ratio of one (RDC=0x00000)
provides continuous periodic data word transfers. A bit-length frame sync (RFSL=1) must be used in this
case.
The ESAI frame sync generator functional diagram is shown in Figure 25-8 .
8
RPSR
ESAI_RCCR Receiver Prescaler Range. The RPSR controls a fixed divide-by-eight prescaler in series
with the variable prescaler. This bit is used to extend the range of the prescaler for those cases where a
slower bit clock is desired. When RPSR is set, the fixed prescaler is bypassed. When RPSR is cleared,
the fixed divide-by-eight prescaler is operational (see Figure 25-7). The maximum internally generated bit
clock frequency is Fsys/6, the minimum internally generated bit clock frequency is Fsys/(2 x 8 x 256 x
16)=Fsys/65536. (Do not use the combination RPSR=1 and RPM7-RPM0 =0x00, which causes
synchronization problems when using the internal Core clock as source (RHCKD=1 or RCKD=1))
RPM
ESAI_RCCR Receiver Prescale Modulus Select. The RPM7-RPM0 bits specify the divide ratio of the
prescale divider in the ESAI receiver clock generator. A divide ratio from 1 to 256 (RPM=0x00 to 0xFF)
may be selected. The bit clock output is available at the receiver serial bit clock (SCKR) pin. The bit clock
output is also available internally for use as the bit clock to shift the receive shift registers. The ESAI
receive clock generator functional diagram is shown in Figure 25-7.
25.6.18
Transmit Slot Mask Register A (ESAI_TSMA)
The Transmit Slot Mask Register A together with Transmit Slot Mask Register B
(ESAI_TSMA and ESAI_TSMB) are two read/write registers used by the transmitters in
network mode to determine for each slot whether to transmit a data word and generate a
transmitter empty condition (TDE=1), or to tri-state the transmitter data pins. Fields
ESAI_TSMA[TS] and ESAI_TSMB[TS] are concatenated to form the 32-bit field
TS[31:0]. Bit number n in TS is the enable/disable control bit for transmission in slot
number n.
Address: 202_4000h base + E4h offset = 202_40E4h
Bit
31
30
29
28
27
26
25
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
TS
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
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1238
NXP Semiconductors

<!-- page 1239 -->

ESAI_TSMA field descriptions
Field
Description
31–16
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
TS
Lower 16 bits of TS
When bit number N in ESAI_TSMA is cleared, all the transmit data pins of the enabled transmitters are tri-
stated during transmit time slot number N. The data is still transferred from the transmit data registers to
the transmit shift registers but neither the TDE nor the TUE flags are set. This means that during a
disabled slot, no transmitter empty interrupt is generated. The Core is interrupted only for enabled slots.
Data that is written to the transmit data registers when servicing this request is transmitted in the next
enabled transmit time slot.
When bit number N in ESAI_TSMA register is set, the transmit sequence is as usual: data is transferred
from the TX registers to the shift registers and transmitted during slot number N, and the TDE flag is set.
Using the slot mask in ESAI_TSMA does not conflict with using TSR. Even if a slot is enabled in
ESAI_TSMA, the user may choose to write to TSR instead of writing to the transmit data registers TXn.
This causes all the transmit data pins of the enabled transmitters to be tri-stated during the next slot.
Data written to the ESAI_TSMA affects the next frame transmission. The frame being transmitted is not
affected by this data and would comply to the last ESAI_TSMA setting. Data read from ESAI_TSMA
returns the last written data.
After hardware or software reset, the ESAI_TSMA register is preset to 0x0000FFFF, which means that all
16 possible slots are enabled for data transmission.
When operating in normal mode, bit 0 of the ESAI_TSMA register must be set, otherwise no output is
generated.
25.6.19
Transmit Slot Mask Register B (ESAI_TSMB)
The Transmit Slot Mask Register B together with Transmit Slot Mask Register A
(ESAI_TSMA and ESAI_TSMB) are two read/write registers used by the transmitters in
network mode to determine for each slot whether to transmit a data word and generate a
transmitter empty condition (TDE=1), or to tri-state the transmitter data pins. Fields
ESAI_TSMA[TS] and ESAI_TSMB[TS] are concatenated to form the 32-bit field
TS[31:0]. Bit number n in TS is the enable/disable control bit for transmission in slot
number n.
Address: 202_4000h base + E8h offset = 202_40E8h
Bit
31
30
29
28
27
26
25
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
TS
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
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1239

<!-- page 1240 -->

ESAI_TSMB field descriptions
Field
Description
31–16
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
TS
When bit number N in ESAI_TSMB is cleared, all the transmit data pins of the enabled transmitters are tri-
stated during transmit time slot number N. The data is still transferred from the transmit data registers to
the transmit shift registers but neither the TDE nor the TUE flags are set. This means that during a
disabled slot, no transmitter empty interrupt is generated. The Core is interrupted only for enabled slots.
Data that is written to the transmit data registers when servicing this request is transmitted in the next
enabled transmit time slot.
When bit number N in ESAI_TSMB register is set, the transmit sequence is as usual: data is transferred
from the TX registers to the shift registers and transmitted during slot number N, and the TDE flag is set.
Using the slot mask in ESAI_TSMB does not conflict with using TSR. Even if a slot is enabled in TSMB,
the user may chose to write to TSR instead of writing to the transmit data registers TXn. This causes all
the transmit data pins of the enabled transmitters to be tri-stated during the next slot.
Data written to the ESAI_TSMB affects the next frame transmission. The frame being transmitted is not
affected by this data and would comply to the last ESAI_TSMB setting. Data read from ESAI_TSMB
returns the last written data.
After hardware or software reset, the ESAI_TSMB register is preset to 0x0000FFFF, which means that all
16 possible slots are enabled for data transmission.
25.6.20
Receive Slot Mask Register A (ESAI_RSMA)
The Receive Slot Mask Register A together with Receive Slot Mask Register B
(ESAI_RSMA and ESAI_RSMB) are two read/write registers used by the receiver in
network mode to determine for each slot whether to receive a data word and generate a
receiver full condition (RDF=1), or to ignore the received data. Fields ESAI_RSMA[RS]
and ESAI_RSMB[RS] are concatenated to form the 32-bit field RS[31:0]. Bit number n
in RS is an enable/disable control bit for receiving data in slot number n.
Address: 202_4000h base + ECh offset = 202_40ECh
Bit
31
30
29
28
27
26
25
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
RS
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
ESAI_RSMA field descriptions
Field
Description
31–16
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
RS
When bit number N in the ESAI_RSMA register is cleared, the data from the enabled receivers input pins
are shifted into their receive shift registers during slot number N. The data is not transferred from the
receive shift registers to the receive data registers, and neither the RDF nor the ROE flag is set. This
Table continues on the next page...
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1240
NXP Semiconductors

<!-- page 1241 -->

ESAI_RSMA field descriptions (continued)
Field
Description
means that during a disabled slot, no receiver full interrupt is generated. The Core is interrupted only for
enabled slots.
When bit number N in the ESAI_RSMA is set, the receive sequence is as usual: data which is shifted into
the enabled receivers shift registers is transferred to the receive data registers and the RDF flag is set.
Data written to the ESAI_RSMA affects the next received frame. The frame being received is not affected
by this data and would comply to the last ESAI_RSMA setting. Data read from ESAI_RSMA returns the
last written data.
After hardware or software reset, the ESAI_RSMA register is preset to 0x0000FFFF, which means that all
16 possible slots are enabled for data reception.
When operating in normal mode, bit 0 of the ESAI_RSMA register must be set to one, otherwise no input
is received.
25.6.21
Receive Slot Mask Register B (ESAI_RSMB)
The Receive Slot Mask Register B together with Receive Slot Mask Register A
(ESAI_RSMA and ESAI_RSMB) are two read/write registers used by the receiver in
network mode to determine for each slot whether to receive a data word and generate a
receiver full condition (RDF=1), or to ignore the received data. Fields ESAI_RSMA[RS]
and ESAI_RSMB[RS] are concatenated to form the 32-bit field RS[31:0]. Bit number n
in RS is an enable/disable control bit for receiving data in slot number n.
Address: 202_4000h base + F0h offset = 202_40F0h
Bit
31
30
29
28
27
26
25
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
RS
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
ESAI_RSMB field descriptions
Field
Description
31–16
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
RS
When bit number N in the ESAI_RSMB register is cleared, the data from the enabled receivers input pins
are shifted into their receive shift registers during slot number N. The data is not transferred from the
receive shift registers to the receive data registers, and neither the RDF nor the ROE flag is set. This
means that during a disabled slot, no receiver full interrupt is generated. The Core is interrupted only for
enabled slots.
When bit number N in the ESAI_RSMB is set, the receive sequence is as usual: data which is shifted into
the enabled receivers shift registers is transferred to the receive data registers and the RDF flag is set.
Data written to the ESAI_RSMB affects the next received frame. The frame being received is not affected
by this data and would comply to the last ESAI_RSMB setting. Data read from ESAI_RSMB returns the
last written data.
Table continues on the next page...
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1241

<!-- page 1242 -->

ESAI_RSMB field descriptions (continued)
Field
Description
After hardware or software reset, the ESAI_RSMB register is preset to 0x0000FFFF, which means that all
16 possible slots are enabled for data reception.
25.6.22
Port C Direction Register (ESAI_PRRC)
There are two registers to control the ESAI personal reset status: Port C Direction
Register (ESAI_PRRC) and Port C Control Register (ESAI_PCRC).
The read/write 32-bit Port C Direction Register (ESAI_PRRC) in conjunction with the
Port C Control Register (ESAI_PCRC) controls the functionality of the ESAI personal
reset state. Table 25-13 provides the port pin configurations. Hardware and software reset
clear all ESAI_PRRC bits.
Address: 202_4000h base + F8h offset = 202_40F8h
Bit
31
30
29
28
27
26
25
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
PDC
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
ESAI_PRRC field descriptions
Field
Description
31–12
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
PDC
See Table 25-13.
25.6.23
Port C Control Register (ESAI_PCRC)
The read/write 32-bit Port C Control Register (ESAI_PCRC) in conjunction with the Port
C Direction Register (ESAI_PRRC) controls the functionality of the ESAI personal reset
state. Each of the PC(11:0) bits controls the functionality of the corresponding port pin.
Table 25-13 provides the port pin configurations. Hardware and software reset clear all
ESAI_PCRC bits.
Table 25-13. PCRC and PRRC Bits Functionality
PDC[i]
PC[i]
Port Pin[i] Function
0
0
Disconnected
1
1
ESAI
ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1242
NXP Semiconductors

<!-- page 1243 -->

Address: 202_4000h base + FCh offset = 202_40FCh
Bit
31
30
29
28
27
26
25
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
PC
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
ESAI_PCRC field descriptions
Field
Description
31–12
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
PC
See Table 25-13.
Chapter 25 Enhanced Serial Audio Interface (ESAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
1243

<!-- page 1244 -->

ESAI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
1244
NXP Semiconductors

