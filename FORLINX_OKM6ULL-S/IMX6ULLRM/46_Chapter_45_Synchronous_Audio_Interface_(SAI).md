# Chapter 45: Synchronous Audio Interface (SAI)

> Nguồn: `IMX6ULLRM.pdf` — trang 3107–3144

<!-- page 3107 -->

Chapter 45
Synchronous Audio Interface (SAI)
45.1
Overview
The synchronous audio interface (SAI) supports full-duplex serial interfaces with frame
synchronization such as I2S, AC97, TDM, and codec/DSP interfaces.
45.1.1
Features
Note that some of the features are not supported across all SAI instances; see the chip-
specific information in the first section of this chapter.
• Transmitter with independent bit clock and frame sync supporting 1 data line
• Receiver with independent bit clock and frame sync supporting 1 data line
• Maximum Frame Size of 32 words
• Word size of between 8-bits and 32-bits
• Word size configured separately for first word and remaining words in frame
• Asynchronous 32 × 32-bit FIFO for each transmit and receive channel
• Supports graceful restart after FIFO error
45.1.2
Block diagram
The following block diagram also shows the module clocks.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3107

<!-- page 3108 -->

Write
FIFO
Control
 FIFO
Read
FIFO
Control
Shift
Register
Control
Registers
Bit Clock
Generation
Frame
Sync
Control
Control
Registers
Bit Clock
Generation
Frame
Sync
Control
Read
FIFO
Control
 FIFO
Write
FIFO
Control
Shift
Register
Bus
Clock
Audio
Clock
Bit
Clock
Bus
Clock
Transmitter
Receiver
Synchronous Mode
SAI_TX_DATA
SAI_TX_BCLK
SAI_TX_SYNC
SAI_RX_SYNC
SAI_RX_BCLK
SAI_RX_DATA
Bit
Clock
Figure 45-1. I2S/SAI block diagram
45.1.3
Modes of operation
Available power modes include: Run mode, Stop mode.
45.1.3.1
Run mode
In Run mode, the SAI transmitter and receiver operate normally.
45.1.3.2
Stop mode
In Stop mode, the transmitter is disabled after completing the current transmit frame, and,
the receiver is disabled after completing the current receive frame. Entry into Stop mode
is prevented–not acknowledged–while waiting for the transmitter and receiver to be
disabled at the end of the current frame.
45.2
External Signals
The following table describes the external signals of SAI:
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3108
NXP Semiconductors

<!-- page 3109 -->

Table 45-1. SAI External Signals
Signal
Description
Pad
Mode
Direction
SAI1_MCLK
Audio Master Clock. The master
clock is an input when externally
generated and an output when
internally generated.
CSI_DATA01
ALT6
IO
LCD_DATA00
ALT8
SAI1_RX_BCLK
Receive Bit Clock. The bit clock is
an input when externally generated
and an output when internally
generated.
CSI_DATA03
ALT6
IO
SAI1_RX_DATA
Receive Data. The receive data is
sampled synchronously by the bit
clock.
CSI_DATA06
ALT6
I
LCD_DATA03
ALT8
SAI1_RX_SYNC
Receive Frame Sync. The frame
sync is an input sampled
synchronously by the bit clock when
externally generated and an output
generated synchronously by the bit
clock when internally generated.
CSI_DATA02
ALT6
IO
SAI1_TX_BCLK
Transmit Bit Clock. The bit clock is
an input when externally generated
and an output when internally
generated.
CSI_DATA05
ALT6
IO
LCD_DATA02
ALT8
SAI1_TX_DATA
Transmit Data. The transmit data is
generated synchronously by the bit
clock and is tristated whenever not
transmitting a word.
CSI_DATA07
ALT6
O
LCD_DATA04
ALT8
SAI1_TX_SYNC
Transmit Frame Sync. The frame
sync is an input sampled
synchronously by the bit clock when
externally generated and an output
generated synchronously by the bit
clock when internally generated.
CSI_DATA04
ALT6
IO
LCD_DATA01
ALT8
SAI2_MCLK
Audio Master Clock. The master
clock is an input when externally
generated and an output when
internally generated.
JTAG_TMS
ALT2
IO
SD1_CLK
ALT2
SAI2_RX_BCLK
Receive Bit Clock. The bit clock is
an input when externally generated
and an output when internally
generated.
NAND_DATA06
ALT2
IO
SAI2_RX_DATA
Receive Data. The receive data is
sampled synchronously by the bit
clock.
JTAG_TCK
ALT2
I
SD1_DATA2
ALT2
SAI2_RX_SYNC
Receive Frame Sync. The frame
sync is an input sampled
synchronously by the bit clock when
externally generated and an output
generated synchronously by the bit
clock when internally generated.
SD1_CMD
ALT2
IO
SAI2_TX_BCLK
Transmit Bit Clock. The bit clock is
an input when externally generated
JTAG_TDI
ALT2
IO
SD1_DATA1
ALT2
Table continues on the next page...
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3109

<!-- page 3110 -->

Table 45-1. SAI External Signals (continued)
Signal
Description
Pad
Mode
Direction
and an output when internally
generated.
SAI2_TX_DATA
Transmit Data. The transmit data is
generated synchronously by the bit
clock and is tristated whenever not
transmitting a word.
JTAG_TRST_B
ALT2
O
SD1_DATA3
ALT2
SAI2_TX_SYNC
Transmit Frame Sync. The frame
sync is an input sampled
synchronously by the bit clock when
externally generated and an output
generated synchronously by the bit
clock when internally generated.
JTAG_TDO
ALT2
IO
SD1_DATA0
ALT2
SAI3_MCLK
Audio Master Clock. The master
clock is an input when externally
generated and an output when
internally generated.
LCD_CLK
ALT3
IO
LCD_DATA09
ALT1
SAI3_RX_BCLK
Receive Bit Clock. The bit clock is
an input when externally generated
and an output when internally
generated.
LCD_DATA11
ALT1
IO
SAI3_RX_DATA
Receive Data. The receive data is
sampled synchronously by the bit
clock.
LCD_DATA14
ALT1
I
SAI3_RX_SYNC
LCD_VSYNC
ALT3
IO
Receive Frame Sync. The frame
sync is an input sampled
synchronously by the bit clock when
externally generated and an output
generated synchronously by the bit
clock when internally generated.
LCD_DATA10
ALT1
SAI3_TX_BCLK
Transmit Bit Clock. The bit clock is
an input when externally generated
and an output when internally
generated.
LCD_DATA13
ALT1
IO
LCD_HSYNC
ALT3
SAI3_TX_DATA
Transmit Data. The transmit data is
generated synchronously by the bit
clock and is tristated whenever not
transmitting a word.
LCD_DATA15
ALT1
O
LCD_RESET
ALT3
SAI3_TX_SYNC
Transmit Frame Sync. The frame
sync is an input sampled
synchronously by the bit clock when
externally generated and an output
generated synchronously by the bit
clock when internally generated.
LCD_DATA12
ALT1
IO
LCD_ENABLE
ALT3
45.3
Functional description
This section provides a complete functional description of the block.
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3110
NXP Semiconductors

<!-- page 3111 -->

45.3.1
SAI clocking
The SAI clocks include:
• The audio master clock
• The bit clock
• The bus clock
45.3.1.1
Audio master clock
The audio master clock is used to generate the bit clock when the receiver or transmitter
is configured for an internally generated bit clock. The transmitter and receiver can
independently select between the bus clock and up to three audio master clocks to
generate the bit clock.
Each SAI peripheral can control the input clock selection, pin direction and divide ratio
of one audio master clock. The input clock selection and pin direction cannot be altered if
an SAI module using that audio master clock has been enabled. The MCLK divide ratio
can be altered while an SAI is using that master clock, although the change in the divide
ratio takes several cycles. MCR[DUF] can be polled to determine when the divide ratio
change has completed.
The audio master clock generation and selection is chip-specific. Refer to chip-specific
clocking information about how the audio master clocks are generated. A typical
implementation appears in the following figure.
Fractional 
Clock 
Divider
1
0
11
01
10
00
EXTAL
PLL_OUT
ALT_CLK
SYS_CLK
SAI_MOE
MCLK
MCLK_OUT
MCLK_IN
11
01
10
00
SAI_CLKMODE
Bit 
Clock 
Divider
1
0
BCLK_IN
SAI
BCLK_OUT
SAI_BCD
BCLK
SAI_FRACT/SAI_DIVIDE
SAI_MICS
MCLK (other SAIs)
CLKGEN
Figure 45-2. SAI master clock generation
The MCLK fractional clock divider uses both clock edges from the input clock to
generate a divided down clock that will approximate the output frequency, but without
creating any new clock edges. Configuring FRACT and DIVIDE to the same value will
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3111

<!-- page 3112 -->

result in a divide by 1 clock, while configuring FRACT higher than DIVIDE is not
supported. The duty cycle can range from 66/33 when FRACT is set to one less than
DIVIDE down to 50/50 for integer divide ratios, and will approach 50/50 for large non-
integer divide ratios. There is no cycle to cycle jitter or duty cycle variance when the
divide ratio is an integer or half integer, otherwise the divider output will oscillate
between the two divided frequencies that are the closest integer or half integer divisors of
the divider input clock frequency. The maximum jitter is therefore equal to half the
divider input clock period, since both edges of the input clock are used in generating the
divided clock.
45.3.1.2
Bit clock
The SAI transmitter and receiver support asynchronous free-running bit clocks that can
be generated internally from an audio master clock or supplied externally. There is also
the option for synchronous bit clock and frame sync operation between the receiver and
transmitter or between multiple SAI peripherals.
• If both transmitter and receiver are configured for asynchronous operation, then the
transmitter and receiver will each use their own bit clock and frame sync.
• If the transmitter is configured for asynchronous mode and the receiver is configured
for synchronous mode, then both transmitter and receiver will use the transmitter bit
clock and frame sync.
• If the receiver is configured for asynchronous mode and the transmitter is configured
for synchronous mode, then both transmitter and receiver will use the receiver bit
clock and frame sync.
Note that the software configures synchronous or asynchronous mode, and that choice
selects the bit clock/frame sync used.
Externally generated bit clocks must be:
• Enabled before the SAI transmitter or receiver is enabled
• Disabled after the SAI transmitter or receiver is disabled and completes its current
frames
If the SAI transmitter or receiver is using an externally generated bit clock in
asynchronous mode and that bit clock is generated by an SAI that is disabled in stop
mode, then the transmitter or receiver should be disabled by software before entering stop
mode. This issue does not apply when the transmitter or receiver is in a synchronous
mode because all synchronous SAIs are enabled and disabled simultaneously.
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3112
NXP Semiconductors

<!-- page 3113 -->

45.3.1.3
Bus clock
The bus clock is used by the control and configuration registers and to generate
synchronous interrupts and DMA requests.
NOTE
Although there is no specific minimum bus clock frequency
specified, the bus clock frequency must be fast enough (relative
to the bit clock frequency) to ensure that the FIFOs can be
serviced, without generating either a transmitter FIFO underrun
or receiver FIFO overflow condition.
45.3.2
SAI resets
The SAI is asynchronously reset on system reset. The SAI has a software reset and a
FIFO reset.
45.3.2.1
Software reset
The SAI transmitter includes a software reset that resets all transmitter internal logic,
including the bit clock generation, status flags, and FIFO pointers. It does not reset the
configuration registers. The software reset remains asserted until cleared by software.
The SAI receiver includes a software reset that resets all receiver internal logic, including
the bit clock generation, status flags and FIFO pointers. It does not reset the configuration
registers. The software reset remains asserted until cleared by software.
45.3.2.2
FIFO reset
The SAI transmitter includes a FIFO reset that synchronizes the FIFO write pointer to the
same value as the FIFO read pointer. This empties the FIFO contents and is to be used
after TCSR[FEF] is set, and before the FIFO is re-initialized and TCSR[FEF] is cleared.
The FIFO reset is asserted for one cycle only.
The SAI receiver includes a FIFO reset that synchronizes the FIFO read pointer to the
same value as the FIFO write pointer. This empties the FIFO contents and is to be used
after the RCSR[FEF] is set and any remaining data has been read from the FIFO, and
before the RCSR[FEF] is cleared. The FIFO reset is asserted for one cycle only.
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3113

<!-- page 3114 -->

45.3.3
Synchronous modes
The SAI transmitter and receiver can operate synchronously to each other.
45.3.3.1
Synchronous mode
The SAI transmitter and receiver can be configured to operate with synchronous bit clock
and frame sync.
If the transmitter bit clock and frame sync are to be used by both the transmitter and
receiver:
• The transmitter must be configured for asynchronous operation and the receiver for
synchronous operation.
• In synchronous mode, the receiver is enabled only when both the transmitter and
receiver are enabled.
• It is recommended that the transmitter is the last enabled and the first disabled.
If the receiver bit clock and frame sync are to be used by both the transmitter and
receiver:
• The receiver must be configured for asynchronous operation and the transmitter for
synchronous operation.
• In synchronous mode, the transmitter is enabled only when both the receiver and
transmitter are both enabled.
• It is recommended that the receiver is the last enabled and the first disabled.
When operating in synchronous mode, only the bit clock, frame sync, and transmitter/
receiver enable are shared. The transmitter and receiver otherwise operate independently,
although configuration registers must be configured consistently across both the
transmitter and receiver.
45.3.4
Frame sync configuration
When enabled, the SAI continuously transmits and/or receives frames of data. Each
frame consists of a fixed number of words and each word consists of a fixed number of
bits. Within each frame, any given word can be masked causing the receiver to ignore
that word and the transmitter to tri-state for the duration of that word.
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3114
NXP Semiconductors

<!-- page 3115 -->

The frame sync signal is used to indicate the start of each frame. A valid frame sync
requires a rising edge (if active high) or falling edge (if active low) to be detected and the
transmitter or receiver cannot be busy with a previous frame. A valid frame sync is also
ignored (slave mode) or not generated (master mode) for the first four bit clock cycles
after enabling the transmitter or receiver.
The transmitter and receiver frame sync can be configured independently with any of the
following options:
• Externally generated or internally generated
• Active high or active low
• Assert with the first bit in frame or asserts one bit early
• Assert for a duration between 1 bit clock and the first word length
• Frame length from 1 to 32 words per frame
• Word length to support 8 to 32 bits per word
• First word length and remaining word lengths can be configured separately
• Words can be configured to transmit/receive MSB first or LSB first
These configuration options cannot be changed after the SAI transmitter or receiver is
enabled.
45.3.5
Data FIFO
Each transmit and receive channel includes a FIFO of size 32 × 32-bit. The FIFO data is
accessed using the SAI Transmit/Receive Data Registers.
45.3.5.1
Data alignment
Data in the FIFO can be aligned anywhere within the 32-bit wide register through the use
of the First Bit Shifted configuration field, which selects the bit index (between 31 and 0)
of the first bit shifted.
Examples of supported data alignment and the required First Bit Shifted configuration are
illustrated in Figure 45-3 for LSB First configurations and Figure 45-4 for MSB First
configurations.
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3115

<!-- page 3116 -->

Figure 45-3. SAI first bit shifted, LSB first
Figure 45-4. SAI first bit shifted, MSB first
45.3.5.2
FIFO pointers
When writing to a TDR, the WFP of the corresponding TFR increments after each valid
write. The SAI supports 8-bit, 16-bit and 32-bit writes to the TDR and the FIFO pointer
will increment after each individual write. Note that 8-bit writes should only be used
when transmitting up to 8-bit data and 16-bit writes should only be used when
transmitting up to 16-bit data.
Writes to a TDR are ignored if the corresponding bit of TCR3[TCE] is clear or if the
FIFO is full. If the Transmit FIFO is empty, the TDR must be written at least three bit
clocks before the start of the next unmasked word to avoid a FIFO underrun.
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3116
NXP Semiconductors

<!-- page 3117 -->

When reading an RDR, the RFP of the corresponding RFR increments after each valid
read. The SAI supports 8-bit, 16-bit and 32-bit reads from the RDR and the FIFO pointer
will increment after each individual read. Note that 8-bit reads should only be used when
receiving up to 8-bit data and 16-bit reads should only be used when receiving up to 16-
bit data.
Reads from an RDR are ignored if the corresponding bit of RCR3[RCE] is clear or if the
FIFO is empty. If the Receive FIFO is full, the RDR must be read at least three bit clocks
before the end of an unmasked word to avoid a FIFO overrun.
45.3.6
Word mask register
The SAI transmitter and receiver each contain a word mask register, namely TMR and
RMR, that can be used to mask any word in the frame. Because the word mask register is
double buffered, software can update it before the end of each frame to mask a particular
word in the next frame.
The TMR causes the Transmit Data pin to be tri-stated for the length of each selected
word and the transmit FIFO is not read for masked words.
The RMR causes the received data for each selected word to be discarded and not written
to the receive FIFO.
45.3.7
Interrupts and DMA requests
The SAI transmitter and receiver generate separate interrupts and separate DMA requests,
but support the same status flags.
45.3.7.1
FIFO request flag
The FIFO request flag is set based on the number of entries in the FIFO and the FIFO
watermark configuration.
The transmit FIFO request flag is set when the number of entries in any of the enabled
transmit FIFOs is less than or equal to the transmit FIFO watermark configuration and is
cleared when the number of entries in each enabled transmit FIFO is greater than the
transmit FIFO watermark configuration.
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3117

<!-- page 3118 -->

The receive FIFO request flag is set when the number of entries in any of the enabled
receive FIFOs is greater than the receive FIFO watermark configuration and is cleared
when the number of entries in each enabled receive FIFO is less than or equal to the
receive FIFO watermark configuration.
The FIFO request flag can generate an interrupt or a DMA request.
45.3.7.2
FIFO warning flag
The FIFO warning flag is set based on the number of entries in the FIFO.
The transmit warning flag is set when the number of entries in any of the enabled
transmit FIFOs is empty and is cleared when the number of entries in each enabled
transmit FIFO is not empty.
The receive warning flag is set when the number of entries in any of the enabled receive
FIFOs is full and is cleared when the number of entries in each enabled receive FIFO is
not full.
The FIFO warning flag can generate an Interrupt or a DMA request.
45.3.7.3
FIFO error flag
The transmit FIFO error flag is set when the any of the enabled transmit FIFOs
underflow. After it is set, all enabled transmit channels repeat the last valid word read
from the transmit FIFO until TCSR[FEF] is cleared and the next transmit frame starts.
All enabled transmit FIFOs must be reset and initialized with new data before
TCSR[FEF] is cleared.
RCSR[FEF] is set when the any of the enabled receive FIFOs overflow. After it is set, all
enabled receive channels discard received data until RCSR[FEF] is cleared and the next
next receive frame starts. All enabled receive FIFOs should be emptied before
RCSR[FEF] is cleared.
The FIFO error flag can generate only an interrupt.
Functional description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3118
NXP Semiconductors

<!-- page 3119 -->

45.3.7.4
Sync error flag
The sync error flag, TCSR[SEF] or RCSR[SEF], is set when configured for an externally
generated frame sync and the external frame sync asserts when the transmitter or receiver
is busy with the previous frame. The external frame sync assertion is ignored and the
sync error flag is set. When the sync error flag is set, the transmitter or receiver continues
checking for frame sync assertion when idle or at the end of each frame.
The sync error flag can generate an interrupt only.
45.3.7.5
Word start flag
The word start flag is set at the start of the second bit clock for the selected word, as
configured by the Word Flag register field.
The word start flag can generate an interrupt only.
45.4
Memory map and register definition
A read or write access to an address from offset 0x108 and above will result in a bus
error.
I2S memory map
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
202_8000
SAI Transmit Control Register (I2S1_TCSR)
32
R/W
0000_0000h
45.4.1/3122
202_8004
SAI Transmit Configuration 1 Register (I2S1_TCR1)
32
R/W
0000_0000h
45.4.2/3125
202_8008
SAI Transmit Configuration 2 Register (I2S1_TCR2)
32
R/W
0000_0000h
45.4.3/3125
202_800C
SAI Transmit Configuration 3 Register (I2S1_TCR3)
32
R/W
0000_0000h
45.4.4/3127
202_8010
SAI Transmit Configuration 4 Register (I2S1_TCR4)
32
R/W
0000_0000h
45.4.5/3128
202_8014
SAI Transmit Configuration 5 Register (I2S1_TCR5)
32
R/W
0000_0000h
45.4.6/3129
202_8020
SAI Transmit Data Register (I2S1_TDR0)
32
W
(always
reads 0)
0000_0000h
45.4.7/3130
202_8040
SAI Transmit FIFO Register (I2S1_TFR0)
32
R
0000_0000h
45.4.8/3131
202_8060
SAI Transmit Mask Register (I2S1_TMR)
32
R/W
0000_0000h
45.4.9/3131
202_8080
SAI Receive Control Register (I2S1_RCSR)
32
R/W
0000_0000h
45.4.10/
3132
202_8084
SAI Receive Configuration 1 Register (I2S1_RCR1)
32
R/W
0000_0000h
45.4.11/
3135
Table continues on the next page...
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3119

<!-- page 3120 -->

I2S memory map (continued)
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
202_8088
SAI Receive Configuration 2 Register (I2S1_RCR2)
32
R/W
0000_0000h
45.4.12/
3136
202_808C
SAI Receive Configuration 3 Register (I2S1_RCR3)
32
R/W
0000_0000h
45.4.13/
3137
202_8090
SAI Receive Configuration 4 Register (I2S1_RCR4)
32
R/W
0000_0000h
45.4.14/
3138
202_8094
SAI Receive Configuration 5 Register (I2S1_RCR5)
32
R/W
0000_0000h
45.4.15/
3140
202_80A0
SAI Receive Data Register (I2S1_RDR0)
32
R
0000_0000h
45.4.16/
3140
202_80C0
SAI Receive FIFO Register (I2S1_RFR0)
32
R
0000_0000h
45.4.17/
3141
202_80E0
SAI Receive Mask Register (I2S1_RMR)
32
R/W
0000_0000h
45.4.18/
3141
202_8100
SAI MCLK Control Register (I2S1_MCR)
32
R/W
0000_0000h
45.4.19/
3142
202_C000
SAI Transmit Control Register (I2S2_TCSR)
32
R/W
0000_0000h
45.4.1/3122
202_C004
SAI Transmit Configuration 1 Register (I2S2_TCR1)
32
R/W
0000_0000h
45.4.2/3125
202_C008
SAI Transmit Configuration 2 Register (I2S2_TCR2)
32
R/W
0000_0000h
45.4.3/3125
202_C00C
SAI Transmit Configuration 3 Register (I2S2_TCR3)
32
R/W
0000_0000h
45.4.4/3127
202_C010
SAI Transmit Configuration 4 Register (I2S2_TCR4)
32
R/W
0000_0000h
45.4.5/3128
202_C014
SAI Transmit Configuration 5 Register (I2S2_TCR5)
32
R/W
0000_0000h
45.4.6/3129
202_C020
SAI Transmit Data Register (I2S2_TDR0)
32
W
(always
reads 0)
0000_0000h
45.4.7/3130
202_C040
SAI Transmit FIFO Register (I2S2_TFR0)
32
R
0000_0000h
45.4.8/3131
202_C060
SAI Transmit Mask Register (I2S2_TMR)
32
R/W
0000_0000h
45.4.9/3131
202_C080
SAI Receive Control Register (I2S2_RCSR)
32
R/W
0000_0000h
45.4.10/
3132
202_C084
SAI Receive Configuration 1 Register (I2S2_RCR1)
32
R/W
0000_0000h
45.4.11/
3135
202_C088
SAI Receive Configuration 2 Register (I2S2_RCR2)
32
R/W
0000_0000h
45.4.12/
3136
202_C08C
SAI Receive Configuration 3 Register (I2S2_RCR3)
32
R/W
0000_0000h
45.4.13/
3137
202_C090
SAI Receive Configuration 4 Register (I2S2_RCR4)
32
R/W
0000_0000h
45.4.14/
3138
202_C094
SAI Receive Configuration 5 Register (I2S2_RCR5)
32
R/W
0000_0000h
45.4.15/
3140
202_C0A0
SAI Receive Data Register (I2S2_RDR0)
32
R
0000_0000h
45.4.16/
3140
202_C0C0
SAI Receive FIFO Register (I2S2_RFR0)
32
R
0000_0000h
45.4.17/
3141
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3120
NXP Semiconductors

<!-- page 3121 -->

I2S memory map (continued)
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
202_C0E0
SAI Receive Mask Register (I2S2_RMR)
32
R/W
0000_0000h
45.4.18/
3141
202_C100
SAI MCLK Control Register (I2S2_MCR)
32
R/W
0000_0000h
45.4.19/
3142
203_0000
SAI Transmit Control Register (I2S3_TCSR)
32
R/W
0000_0000h
45.4.1/3122
203_0004
SAI Transmit Configuration 1 Register (I2S3_TCR1)
32
R/W
0000_0000h
45.4.2/3125
203_0008
SAI Transmit Configuration 2 Register (I2S3_TCR2)
32
R/W
0000_0000h
45.4.3/3125
203_000C
SAI Transmit Configuration 3 Register (I2S3_TCR3)
32
R/W
0000_0000h
45.4.4/3127
203_0010
SAI Transmit Configuration 4 Register (I2S3_TCR4)
32
R/W
0000_0000h
45.4.5/3128
203_0014
SAI Transmit Configuration 5 Register (I2S3_TCR5)
32
R/W
0000_0000h
45.4.6/3129
203_0020
SAI Transmit Data Register (I2S3_TDR0)
32
W
(always
reads 0)
0000_0000h
45.4.7/3130
203_0040
SAI Transmit FIFO Register (I2S3_TFR0)
32
R
0000_0000h
45.4.8/3131
203_0060
SAI Transmit Mask Register (I2S3_TMR)
32
R/W
0000_0000h
45.4.9/3131
203_0080
SAI Receive Control Register (I2S3_RCSR)
32
R/W
0000_0000h
45.4.10/
3132
203_0084
SAI Receive Configuration 1 Register (I2S3_RCR1)
32
R/W
0000_0000h
45.4.11/
3135
203_0088
SAI Receive Configuration 2 Register (I2S3_RCR2)
32
R/W
0000_0000h
45.4.12/
3136
203_008C
SAI Receive Configuration 3 Register (I2S3_RCR3)
32
R/W
0000_0000h
45.4.13/
3137
203_0090
SAI Receive Configuration 4 Register (I2S3_RCR4)
32
R/W
0000_0000h
45.4.14/
3138
203_0094
SAI Receive Configuration 5 Register (I2S3_RCR5)
32
R/W
0000_0000h
45.4.15/
3140
203_00A0
SAI Receive Data Register (I2S3_RDR0)
32
R
0000_0000h
45.4.16/
3140
203_00C0
SAI Receive FIFO Register (I2S3_RFR0)
32
R
0000_0000h
45.4.17/
3141
203_00E0
SAI Receive Mask Register (I2S3_RMR)
32
R/W
0000_0000h
45.4.18/
3141
203_0100
SAI MCLK Control Register (I2S3_MCR)
32
R/W
0000_0000h
45.4.19/
3142
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3121

<!-- page 3122 -->

45.4.1
SAI Transmit Control Register (I2Sx_TCSR)
Address: Base address + 0h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
TE
STOPE
0
BCE
0
0
SR
0
WSF
SEF
FEF
FWF
FRF
W
FR
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
WSIE
SEIE
FEIE
FWIE
FRIE
0
0
FWDE
FRDE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
I2Sx_TCSR field descriptions
Field
Description
31
TE
Transmitter Enable
Enables/disables the transmitter. When software clears this field, the transmitter remains enabled, and this
bit remains set, until the end of the current frame.
0
Transmitter is disabled.
1
Transmitter is enabled, or transmitter has been disabled and has not yet reached end of frame.
30
STOPE
Stop Enable
Configures transmitter operation in Stop mode. This field is ignored and the transmitter is disabled in all
stop modes.
0
Transmitter disabled in Stop mode.
1
Transmitter enabled in Stop mode.
29
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3122
NXP Semiconductors

<!-- page 3123 -->

I2Sx_TCSR field descriptions (continued)
Field
Description
28
BCE
Bit Clock Enable
Enables the transmit bit clock, separately from the TE. This field is automatically set whenever TE is set.
When software clears this field, the transmit bit clock remains enabled, and this bit remains set, until the
end of the current frame.
0
Transmit bit clock is disabled.
1
Transmit bit clock is enabled.
27–26
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
25
FR
FIFO Reset
Resets the FIFO pointers. Reading this field will always return zero. FIFO pointers should only be reset
when the transmitter is disabled or the FIFO error flag is set.
0
No effect.
1
FIFO reset.
24
SR
Software Reset
When set, resets the internal transmitter logic including the FIFO pointers. Software-visible registers are
not affected, except for the status registers.
0
No effect.
1
Software reset.
23–21
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
20
WSF
Word Start Flag
Indicates that the start of the configured word has been detected. Write a logic 1 to this field to clear this
flag.
0
Start of word not detected.
1
Start of word detected.
19
SEF
Sync Error Flag
Indicates that an error in the externally-generated frame sync has been detected. Write a logic 1 to this
field to clear this flag.
0
Sync error not detected.
1
Frame sync error detected.
18
FEF
FIFO Error Flag
Indicates that an enabled transmit FIFO has underrun. Write a logic 1 to this field to clear this flag.
0
Transmit underrun not detected.
1
Transmit underrun detected.
17
FWF
FIFO Warning Flag
Indicates that an enabled transmit FIFO is empty.
0
No enabled transmit FIFO is empty.
1
Enabled transmit FIFO is empty.
Table continues on the next page...
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3123

<!-- page 3124 -->

I2Sx_TCSR field descriptions (continued)
Field
Description
16
FRF
FIFO Request Flag
Indicates that the number of words in an enabled transmit channel FIFO is less than or equal to the
transmit FIFO watermark.
0
Transmit FIFO watermark has not been reached.
1
Transmit FIFO watermark has been reached.
15–13
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
12
WSIE
Word Start Interrupt Enable
Enables/disables word start interrupts.
0
Disables interrupt.
1
Enables interrupt.
11
SEIE
Sync Error Interrupt Enable
Enables/disables sync error interrupts.
0
Disables interrupt.
1
Enables interrupt.
10
FEIE
FIFO Error Interrupt Enable
Enables/disables FIFO error interrupts.
0
Disables the interrupt.
1
Enables the interrupt.
9
FWIE
FIFO Warning Interrupt Enable
Enables/disables FIFO warning interrupts.
0
Disables the interrupt.
1
Enables the interrupt.
8
FRIE
FIFO Request Interrupt Enable
Enables/disables FIFO request interrupts.
0
Disables the interrupt.
1
Enables the interrupt.
7–5
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
4–2
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
1
FWDE
FIFO Warning DMA Enable
Enables/disables DMA requests.
0
Disables the DMA request.
1
Enables the DMA request.
0
FRDE
FIFO Request DMA Enable
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3124
NXP Semiconductors

<!-- page 3125 -->

I2Sx_TCSR field descriptions (continued)
Field
Description
Enables/disables DMA requests.
0
Disables the DMA request.
1
Enables the DMA request.
45.4.2
SAI Transmit Configuration 1 Register (I2Sx_TCR1)
Address: Base address + 4h offset
Bit
31
30
29
28
27
26
25
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
TFW
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
I2Sx_TCR1 field descriptions
Field
Description
31–5
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
TFW
Transmit FIFO Watermark
Configures the watermark level for all enabled transmit channels.
45.4.3
SAI Transmit Configuration 2 Register (I2Sx_TCR2)
This register must not be altered when TCSR[TE] is set.
Address: Base address + 8h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
SYNC
BCS
BCI
MSEL
BCP
BCD
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
DIV
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
I2Sx_TCR2 field descriptions
Field
Description
31–30
SYNC
Synchronous Mode
Configures between asynchronous and synchronous modes of operation. When configured for a
synchronous mode of operation, the receiver must be configured for asynchronous operation.
Table continues on the next page...
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3125

<!-- page 3126 -->

I2Sx_TCR2 field descriptions (continued)
Field
Description
00
Asynchronous mode.
01
Synchronous with receiver.
29
BCS
Bit Clock Swap
This field swaps the bit clock used by the transmitter. When the transmitter is configured in asynchronous
mode and this bit is set, the transmitter is clocked by the receiver bit clock (SAI_RX_BCLK). This allows
the transmitter and receiver to share the same bit clock, but the transmitter continues to use the transmit
frame sync (SAI_TX_SYNC).
When the transmitter is configured in synchronous mode, the transmitter BCS field and receiver BCS field
must be set to the same value. When both are set, the transmitter and receiver are both clocked by the
transmitter bit clock (SAI_TX_BCLK) but use the receiver frame sync (SAI_RX_SYNC).
0
Use the normal bit clock source.
1
Swap the bit clock source.
28
BCI
Bit Clock Input
When this field is set and using an internally generated bit clock in either synchronous or asynchronous
mode, the bit clock actually used by the transmitter is delayed by the pad output delay (the transmitter is
clocked by the pad input as if the clock was externally generated). This has the effect of decreasing the
data input setup time, but increasing the data output valid time.
The slave mode timing from the datasheet should be used for the transmitter when this bit is set. In
synchronous mode, this bit allows the transmitter to use the slave mode timing from the datasheet, while
the receiver uses the master mode timing. This field has no effect when configured for an externally
generated bit clock .
0
No effect.
1
Internal logic is clocked as if bit clock was externally generated.
27–26
MSEL
MCLK Select
Selects the audio Master Clock option used to generate an internally generated bit clock. This field has no
effect when configured for an externally generated bit clock.
NOTE: Depending on the device, some Master Clock options might not be available. See the chip-
specific information for the meaning of each option.
00
Master Clock (MCLK) 1 option selected.
01
Master Clock (MCLK) 1 option selected.
10
Master Clock (MCLK) 2 option selected.
11
Master Clock (MCLK) 3 option selected.
25
BCP
Bit Clock Polarity
Configures the polarity of the bit clock.
0
Bit clock is active high with drive outputs on rising edge and sample inputs on falling edge.
1
Bit clock is active low with drive outputs on falling edge and sample inputs on rising edge.
24
BCD
Bit Clock Direction
Configures the direction of the bit clock.
0
Bit clock is generated externally in Slave mode.
1
Bit clock is generated internally in Master mode.
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3126
NXP Semiconductors

<!-- page 3127 -->

I2Sx_TCR2 field descriptions (continued)
Field
Description
23–8
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
DIV
Bit Clock Divide
Divides down the audio master clock to generate the bit clock when configured for an internal bit clock.
The division value is (DIV + 1) * 2.
45.4.4
SAI Transmit Configuration 3 Register (I2Sx_TCR3)
This register must not be altered when TCSR[TE] is set.
Address: Base address + Ch offset
Bit
31
30
29
28
27
26
25
24
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
0
TCE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
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
WDFL
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
I2Sx_TCR3 field descriptions
Field
Description
31–24
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
23–17
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
16
TCE
Transmit Channel Enable
Enables the corresponding data channel for transmit operation. A channel must be enabled before its
FIFO is accessed.
The width of TCE field = the number of transmit channels (call it N). For example, if TCE field is 2 bits
wide, then bit position 16 refers to transmit channel 1 and bit position 17 refers to transmit channel 2.
Setting bit 16 enables transmit channel 1, and setting bit 17 enables transmit channel 2. Setting bit N will
enable transmit channel N.
0
Transmit data channel N is disabled.
1
Transmit data channel N is enabled.
15–5
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
WDFL
Word Flag Configuration
Table continues on the next page...
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3127

<!-- page 3128 -->

I2Sx_TCR3 field descriptions (continued)
Field
Description
Configures which word sets the start of word flag. The value written must be one less than the word
number. For example, writing 0 configures the first word in the frame. When configured to a value greater
than TCR4[FRSZ], then the start of word flag is never set.
45.4.5
SAI Transmit Configuration 4 Register (I2Sx_TCR4)
This register must not be altered when TCSR[TE] is set.
Address: Base address + 10h offset
Bit
31
30
29
28
27
26
25
24
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
0
0
0
0
FRSZ
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
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
SYWD
0
MF
FSE
0
FSP
FSD
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
I2Sx_TCR4 field descriptions
Field
Description
31–29
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
28
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
27–26
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
25–24
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
23–21
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
20–16
FRSZ
Frame size
Configures the number of words in each frame. The value written must be one less than the number of
words in the frame. For example, write 0 for one word per frame. The maximum supported frame size is
32 words.
15–13
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
12–8
SYWD
Sync Width
Configures the length of the frame sync in number of bit clocks. The value written must be one less than
the number of bit clocks. For example, write 0 for the frame sync to assert for one bit clock only. The sync
width cannot be configured longer than the first word of the frame.
7–5
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3128
NXP Semiconductors

<!-- page 3129 -->

I2Sx_TCR4 field descriptions (continued)
Field
Description
4
MF
MSB First
Configures whether the LSB or the MSB is transmitted first.
0
LSB is transmitted first.
1
MSB is transmitted first.
3
FSE
Frame Sync Early
0
Frame sync asserts with the first bit of the frame.
1
Frame sync asserts one bit before the first bit of the frame.
2
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
1
FSP
Frame Sync Polarity
Configures the polarity of the frame sync.
0
Frame sync is active high.
1
Frame sync is active low.
0
FSD
Frame Sync Direction
Configures the direction of the frame sync.
0
Frame sync is generated externally in Slave mode.
1
Frame sync is generated internally in Master mode.
45.4.6
SAI Transmit Configuration 5 Register (I2Sx_TCR5)
This register must not be altered when TCSR[TE] is set.
Address: Base address + 14h offset
Bit
31
30
29
28
27
26
25
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
WNW
0
W0W
0
FBT
0
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
I2Sx_TCR5 field descriptions
Field
Description
31–29
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
28–24
WNW
Word N Width
Configures the number of bits in each word, for each word except the first in the frame. The value written
must be one less than the number of bits per word. Word width of less than 8 bits is not supported.
23–21
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3129

<!-- page 3130 -->

I2Sx_TCR5 field descriptions (continued)
Field
Description
20–16
W0W
Word 0 Width
Configures the number of bits in the first word in each frame. The value written must be one less than the
number of bits in the first word. Word width of less than 8 bits is not supported if there is only one word per
frame.
15–13
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
12–8
FBT
First Bit Shifted
Configures the bit index for the first bit transmitted for each word in the frame. If configured for MSB First,
the index of the next bit transmitted is one less than the current bit transmitted. If configured for LSB First,
the index of the next bit transmitted is one more than the current bit transmitted. The value written must be
greater than or equal to the word width when configured for MSB First. The value written must be less
than or equal to 31-word width when configured for LSB First.
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
45.4.7
SAI Transmit Data Register (I2Sx_TDRn)
Address: Base address + 20h offset + (4d × i), where i=0d to 0d
Bit
31
30
29
28
27
26
25
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
TDR
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
I2Sx_TDRn field descriptions
Field
Description
TDR
Transmit Data Register
The corresponding TCR3[TCE] bit must be set before accessing the channel's transmit data register.
Writes to this register when the transmit FIFO is not full will push the data written into the transmit data
FIFO. Writes to this register when the transmit FIFO is full are ignored.
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3130
NXP Semiconductors

<!-- page 3131 -->

45.4.8
SAI Transmit FIFO Register (I2Sx_TFRn)
The MSB of the read and write pointers is used to distinguish between FIFO full and
empty conditions. If the read and write pointers are identical, then the FIFO is empty. If
the read and write pointers are identical except for the MSB, then the FIFO is full.
Address: Base address + 40h offset + (4d × i), where i=0d to 0d
Bit
31
30
29
28
27
26
25
24
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
0
WFP
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
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
I2Sx_TFRn field descriptions
Field
Description
31
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
30–22
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
21–16
WFP
Write FIFO Pointer
FIFO write pointer for transmit data channel.
15–6
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
RFP
Read FIFO Pointer
FIFO read pointer for transmit data channel.
45.4.9
SAI Transmit Mask Register (I2Sx_TMR)
This register is double-buffered and updates:
1. When TCSR[TE] is first set
2. At the end of each frame.
This allows the masked words in each frame to change from frame to frame.
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3131

<!-- page 3132 -->

Address: Base address + 60h offset
Bit
31
30
29
28
27
26
25
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
TWM
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
I2Sx_TMR field descriptions
Field
Description
TWM
Transmit Word Mask
Configures whether the transmit word is masked (transmit data pin tristated and transmit data not read
from FIFO) for the corresponding word in the frame.
0
Word N is enabled.
1
Word N is masked. The transmit data pins are tri-stated when masked.
45.4.10
SAI Receive Control Register (I2Sx_RCSR)
Address: Base address + 80h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
RE
STOPE
0
BCE
0
0
SR
0
WSF
SEF
FEF
FWF
FRF
W
FR
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
WSIE
SEIE
FEIE
FWIE
FRIE
0
0
FWDE
FRDE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3132
NXP Semiconductors

<!-- page 3133 -->

I2Sx_RCSR field descriptions
Field
Description
31
RE
Receiver Enable
Enables/disables the receiver. When software clears this field, the receiver remains enabled, and this bit
remains set, until the end of the current frame.
0
Receiver is disabled.
1
Receiver is enabled, or receiver has been disabled and has not yet reached end of frame.
30
STOPE
Stop Enable
Configures receiver operation in Stop mode. This bit is ignored and the receiver is disabled in all stop
modes.
0
Receiver disabled in Stop mode.
1
Receiver enabled in Stop mode.
29
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
28
BCE
Bit Clock Enable
Enables the receive bit clock, separately from RE. This field is automatically set whenever RE is set.
When software clears this field, the receive bit clock remains enabled, and this field remains set, until the
end of the current frame.
0
Receive bit clock is disabled.
1
Receive bit clock is enabled.
27–26
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
25
FR
FIFO Reset
Resets the FIFO pointers. Reading this field will always return zero. FIFO pointers should only be reset
when the receiver is disabled or the FIFO error flag is set.
0
No effect.
1
FIFO reset.
24
SR
Software Reset
Resets the internal receiver logic including the FIFO pointers. Software-visible registers are not affected,
except for the status registers.
0
No effect.
1
Software reset.
23–21
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
20
WSF
Word Start Flag
Indicates that the start of the configured word has been detected. Write a logic 1 to this field to clear this
flag.
0
Start of word not detected.
1
Start of word detected.
19
SEF
Sync Error Flag
Table continues on the next page...
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3133

<!-- page 3134 -->

I2Sx_RCSR field descriptions (continued)
Field
Description
Indicates that an error in the externally-generated frame sync has been detected. Write a logic 1 to this
field to clear this flag.
0
Sync error not detected.
1
Frame sync error detected.
18
FEF
FIFO Error Flag
Indicates that an enabled receive FIFO has overflowed. Write a logic 1 to this field to clear this flag.
0
Receive overflow not detected.
1
Receive overflow detected.
17
FWF
FIFO Warning Flag
Indicates that an enabled receive FIFO is full.
0
No enabled receive FIFO is full.
1
Enabled receive FIFO is full.
16
FRF
FIFO Request Flag
Indicates that the number of words in an enabled receive channel FIFO is greater than the receive FIFO
watermark.
0
Receive FIFO watermark not reached.
1
Receive FIFO watermark has been reached.
15–13
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
12
WSIE
Word Start Interrupt Enable
Enables/disables word start interrupts.
0
Disables interrupt.
1
Enables interrupt.
11
SEIE
Sync Error Interrupt Enable
Enables/disables sync error interrupts.
0
Disables interrupt.
1
Enables interrupt.
10
FEIE
FIFO Error Interrupt Enable
Enables/disables FIFO error interrupts.
0
Disables the interrupt.
1
Enables the interrupt.
9
FWIE
FIFO Warning Interrupt Enable
Enables/disables FIFO warning interrupts.
0
Disables the interrupt.
1
Enables the interrupt.
8
FRIE
FIFO Request Interrupt Enable
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3134
NXP Semiconductors

<!-- page 3135 -->

I2Sx_RCSR field descriptions (continued)
Field
Description
Enables/disables FIFO request interrupts.
0
Disables the interrupt.
1
Enables the interrupt.
7–5
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
4–2
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
1
FWDE
FIFO Warning DMA Enable
Enables/disables DMA requests.
0
Disables the DMA request.
1
Enables the DMA request.
0
FRDE
FIFO Request DMA Enable
Enables/disables DMA requests.
0
Disables the DMA request.
1
Enables the DMA request.
45.4.11
SAI Receive Configuration 1 Register (I2Sx_RCR1)
Address: Base address + 84h offset
Bit
31
30
29
28
27
26
25
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
RFW
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
I2Sx_RCR1 field descriptions
Field
Description
31–5
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
RFW
Receive FIFO Watermark
Configures the watermark level for all enabled receiver channels.
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3135

<!-- page 3136 -->

45.4.12
SAI Receive Configuration 2 Register (I2Sx_RCR2)
This register must not be altered when RCSR[RE] is set.
Address: Base address + 88h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
SYNC
BCS
BCI
MSEL
BCP
BCD
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
DIV
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
I2Sx_RCR2 field descriptions
Field
Description
31–30
SYNC
Synchronous Mode
Configures between asynchronous and synchronous modes of operation. When configured for a
synchronous mode of operation, the transmitter must be configured for asynchronous operation.
00
Asynchronous mode.
01
Synchronous with transmitter.
29
BCS
Bit Clock Swap
This field swaps the bit clock used by the receiver. When the receiver is configured in asynchronous mode
and this bit is set, the receiver is clocked by the transmitter bit clock (SAI_TX_BCLK). This allows the
transmitter and receiver to share the same bit clock, but the receiver continues to use the receiver frame
sync (SAI_RX_SYNC).
When the receiver is configured in synchronous mode, the transmitter BCS field and receiver BCS field
must be set to the same value. When both are set, the transmitter and receiver are both clocked by the
receiver bit clock (SAI_RX_BCLK) but use the transmitter frame sync (SAI_TX_SYNC).
0
Use the normal bit clock source.
1
Swap the bit clock source.
28
BCI
Bit Clock Input
When this field is set and using an internally generated bit clock in either synchronous or asynchronous
mode, the bit clock actually used by the receiver is delayed by the pad output delay (the receiver is
clocked by the pad input as if the clock was externally generated). This has the effect of decreasing the
data input setup time, but increasing the data output valid time.
The slave mode timing from the datasheet should be used for the receiver when this bit is set. In
synchronous mode, this bit allows the receiver to use the slave mode timing from the datasheet, while the
transmitter uses the master mode timing. This field has no effect when configured for an externally
generated bit clock .
0
No effect.
1
Internal logic is clocked as if bit clock was externally generated.
27–26
MSEL
MCLK Select
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3136
NXP Semiconductors

<!-- page 3137 -->

I2Sx_RCR2 field descriptions (continued)
Field
Description
Selects the audio Master Clock option used to generate an internally generated bit clock. This field has no
effect when configured for an externally generated bit clock.
NOTE: Depending on the device, some Master Clock options might not be available. See the chip-
specific information for the availability and chip-specific meaning of each option.
00
Bus Clock selected.
01
Master Clock (MCLK) 1 option selected.
10
Master Clock (MCLK) 2 option selected.
11
Master Clock (MCLK) 3 option selected.
25
BCP
Bit Clock Polarity
Configures the polarity of the bit clock.
0
Bit Clock is active high with drive outputs on rising edge and sample inputs on falling edge.
1
Bit Clock is active low with drive outputs on falling edge and sample inputs on rising edge.
24
BCD
Bit Clock Direction
Configures the direction of the bit clock.
0
Bit clock is generated externally in Slave mode.
1
Bit clock is generated internally in Master mode.
23–8
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
DIV
Bit Clock Divide
Divides down the audio master clock to generate the bit clock when configured for an internal bit clock.
The division value is (DIV + 1) * 2.
45.4.13
SAI Receive Configuration 3 Register (I2Sx_RCR3)
This register must not be altered when RCSR[RE] is set.
Address: Base address + 8Ch offset
Bit
31
30
29
28
27
26
25
24
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
0
RCE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
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
WDFL
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3137

<!-- page 3138 -->

I2Sx_RCR3 field descriptions
Field
Description
31–24
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
23–17
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
16
RCE
Receive Channel Enable
Enables the corresponding data channel for receive operation. A channel must be enabled before its FIFO
is accessed.
The width of RCE field = the number of receive channels (call it N). For example, if RCE field is 2 bits
wide, then bit position 16 refers to receive channel 1 and bit position 17 refers to receive channel 2.
Setting bit 16 enables receive channel 1, and setting bit 17 enables receive channel 2. Setting bit N will
enable receive channel N.
0
Receive data channel N is disabled.
1
Receive data channel N is enabled.
15–5
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
WDFL
Word Flag Configuration
Configures which word the start of word flag is set. The value written should be one less than the word
number (for example, write zero to configure for the first word in the frame). When configured to a value
greater than the Frame Size field, then the start of word flag is never set.
45.4.14
SAI Receive Configuration 4 Register (I2Sx_RCR4)
This register must not be altered when RCSR[RE] is set.
Address: Base address + 90h offset
Bit
31
30
29
28
27
26
25
24
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
0
0
0
0
FRSZ
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
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
SYWD
0
MF
FSE
0
FSP
FSD
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
I2Sx_RCR4 field descriptions
Field
Description
31–29
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
28
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
27–26
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3138
NXP Semiconductors

<!-- page 3139 -->

I2Sx_RCR4 field descriptions (continued)
Field
Description
25–24
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
23–21
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
20–16
FRSZ
Frame Size
Configures the number of words in each frame. The value written must be one less than the number of
words in the frame. For example, write 0 for one word per frame. The maximum supported frame size is
32 words.
15–13
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
12–8
SYWD
Sync Width
Configures the length of the frame sync in number of bit clocks. The value written must be one less than
the number of bit clocks. For example, write 0 for the frame sync to assert for one bit clock only. The sync
width cannot be configured longer than the first word of the frame.
7–5
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
4
MF
MSB First
Configures whether the LSB or the MSB is received first.
0
LSB is received first.
1
MSB is received first.
3
FSE
Frame Sync Early
0
Frame sync asserts with the first bit of the frame.
1
Frame sync asserts one bit before the first bit of the frame.
2
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
1
FSP
Frame Sync Polarity
Configures the polarity of the frame sync.
0
Frame sync is active high.
1
Frame sync is active low.
0
FSD
Frame Sync Direction
Configures the direction of the frame sync.
0
Frame Sync is generated externally in Slave mode.
1
Frame Sync is generated internally in Master mode.
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3139

<!-- page 3140 -->

45.4.15
SAI Receive Configuration 5 Register (I2Sx_RCR5)
This register must not be altered when RCSR[RE] is set.
Address: Base address + 94h offset
Bit
31
30
29
28
27
26
25
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
WNW
0
W0W
0
FBT
0
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
I2Sx_RCR5 field descriptions
Field
Description
31–29
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
28–24
WNW
Word N Width
Configures the number of bits in each word, for each word except the first in the frame. The value written
must be one less than the number of bits per word. Word width of less than 8 bits is not supported.
23–21
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
20–16
W0W
Word 0 Width
Configures the number of bits in the first word in each frame. The value written must be one less than the
number of bits in the first word. Word width of less than 8 bits is not supported if there is only one word per
frame.
15–13
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
12–8
FBT
First Bit Shifted
Configures the bit index for the first bit received for each word in the frame. If configured for MSB First, the
index of the next bit received is one less than the current bit received. If configured for LSB First, the index
of the next bit received is one more than the current bit received. The value written must be greater than or
equal to the word width when configured for MSB First. The value written must be less than or equal to 31-
word width when configured for LSB First.
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
45.4.16
SAI Receive Data Register (I2Sx_RDRn)
Reading this register introduces one additional peripheral clock wait state on each read.
Address: Base address + A0h offset + (4d × i), where i=0d to 0d
Bit
31
30
29
28
27
26
25
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
RDR
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
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3140
NXP Semiconductors

<!-- page 3141 -->

I2Sx_RDRn field descriptions
Field
Description
RDR
Receive Data Register
The corresponding RCR3[RCE] bit must be set before accessing the channel's receive data register.
Reads from this register when the receive FIFO is not empty will return the data from the top of the receive
FIFO. Reads from this register when the receive FIFO is empty are ignored.
45.4.17
SAI Receive FIFO Register (I2Sx_RFRn)
The MSB of the read and write pointers is used to distinguish between FIFO full and
empty conditions. If the read and write pointers are identical, then the FIFO is empty. If
the read and write pointers are identical except for the MSB, then the FIFO is full.
Address: Base address + C0h offset + (4d × i), where i=0d to 0d
Bit
31
30
29
28
27
26
25
24
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
WFP
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
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
I2Sx_RFRn field descriptions
Field
Description
31–22
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
21–16
WFP
Write FIFO Pointer
FIFO write pointer for receive data channel.
15
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
14–6
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
RFP
Read FIFO Pointer
FIFO read pointer for receive data channel.
45.4.18
SAI Receive Mask Register (I2Sx_RMR)
This register is double-buffered and updates:
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3141

<!-- page 3142 -->

1. When RCSR[RE] is first set
2. At the end of each frame
This allows the masked words in each frame to change from frame to frame.
Address: Base address + E0h offset
Bit
31
30
29
28
27
26
25
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
RWM
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
I2Sx_RMR field descriptions
Field
Description
RWM
Receive Word Mask
Configures whether the receive word is masked (received data ignored and not written to receive FIFO) for
the corresponding word in the frame.
0
Word N is enabled.
1
Word N is masked.
45.4.19
SAI MCLK Control Register (I2Sx_MCR)
The MCLK Control Register (MCR) controls the clock source and direction of the audio
master clock.
Address: Base address + 100h offset
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
DUF
MOE
0
MICS
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
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
I2Sx_MCR field descriptions
Field
Description
31
DUF
Divider Update Flag
Provides the status of on-the-fly updates to the MCLK divider ratio.
0
MCLK divider ratio is not being updated currently.
1
MCLK divider ratio is updating on-the-fly. Further updates to the MCLK divider ratio are blocked while
this flag remains set.
Table continues on the next page...
Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3142
NXP Semiconductors

<!-- page 3143 -->

I2Sx_MCR field descriptions (continued)
Field
Description
30
MOE
MCLK Output Enable
Enables the MCLK divider and configures the MCLK signal pin as an output. When software clears this
field, it remains set until the MCLK divider is fully disabled.
0
MCLK signal pin is configured as an input that bypasses the MCLK divider.
1
MCLK signal pin is configured as an output from the MCLK divider and the MCLK divider is enabled.
29–26
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
25–24
MICS
MCLK Input Clock Select
Selects the clock input to the MCLK divider. This field cannot be changed while the MCLK divider is
enabled. See the chip-specific information for the connections to these inputs.
00
MCLK divider input clock 0 is selected.
01
Reserved
10
MCLK divider input clock 2 is selected.
11
MCLK divider input clock 3 is selected.
Reserved
This field is reserved.
This read-only field is reserved and always has the value 0.
Chapter 45 Synchronous Audio Interface (SAI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
3143

<!-- page 3144 -->

Memory map and register definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
3144
NXP Semiconductors

