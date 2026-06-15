# Chapter 34: Enhanced LCD Interface (eLCDIF)

> Nguồn: `IMX6ULLRM.pdf` — trang 2131–2202

<!-- page 2131 -->

Chapter 34
Enhanced LCD Interface (eLCDIF)
34.1
Overview
The enhanced Liquid Crystal Display Interface (eLCDIF) is a general purpose display
controller used to drive a wide range of display devices varying in size and capability.
The eLCDIF block supports the following:
• Displays with an asynchronous parallel MPU interface for command and data
transfer to an integrated frame buffer.
• Displays that support moving pictures and require the RGB interface mode
(DOTCLK interface).
• VSYNC mode for high-speed data transfers.
• Digital video encoders that accept ITU-R BT.656 format 4:2:2 YCbCr digital
component video and convert it to analog TV signals.
The eLCDIF provides fully programmable functionality to supported interfaces:
• Bus master interface to source frame buffer data for display refresh. This interface
can also be used to drive data for "Smart" displays.
• PIO interface to manage data transfers between "Smart" displays and SoC.
• 8/16/18/24/32 bit LCD data bus support available depending on I/O mux options.
• Programmable timing and parameters for MPU, VSYNC, and DOTCLK LCD
interfaces to support a wide variety of displays.
• ITU-R BT.656 mode (called Digital Video Interface or DVI mode here) including
progressive-to-interlace feature and RGB to YCbCr 4:2:2 color space conversion to
support 525/60 and 625/50 operation.
34.2
External Signals
The following table describes the external signals of LCD:
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2131

<!-- page 2132 -->

Table 34-1. LCD External Signals
Signal
Description
Pad
Mode
Direction
LCD_BUSY
Busy Signal
LCD_VSYNC
ALT1
I
LCD_CLK
Clock signal
LCD_CLK
ALT0
I
LCD_CS
Chip select
LCD_RESET
ALT1
O
LCD_DATA0
Data signals
LCD_DATA00
ALT0
IO
LCD_DATA1
LCD_DATA01
ALT0
LCD_DATA2
LCD_DATA02
ALT0
LCD_DATA3
LCD_DATA03
ALT0
LCD_DATA4
LCD_DATA04
ALT0
LCD_DATA5
LCD_DATA05
ALT0
LCD_DATA6
LCD_DATA06
ALT0
LCD_DATA7
LCD_DATA07
ALT0
LCD_DATA8
LCD_DATA08
ALT0
LCD_DATA9
LCD_DATA09
ALT0
LCD_DATA10
LCD_DATA10
ALT0
LCD_DATA11
LCD_DATA11
ALT0
LCD_DATA12
LCD_DATA12
ALT0
LCD_DATA13
LCD_DATA13
ALT0
LCD_DATA14
LCD_DATA14
ALT0
LCD_DATA15
LCD_DATA15
ALT0
LCD_DATA16
LCD_DATA16
ALT0
LCD_DATA17
LCD_DATA17
ALT0
LCD_DATA18
LCD_DATA18
ALT0
LCD_DATA19
LCD_DATA19
ALT0
LCD_DATA20
LCD_DATA20
ALT0
LCD_DATA21
LCD_DATA21
ALT0
LCD_DATA22
LCD_DATA22
ALT0
LCD_DATA23
LCD_DATA23
ALT0
LCD_ENABLE
Enable signal
LCD_ENABLE
ALT0
IO
LCD_HSYNC
HSYNC signal
LCD_HSYNC
ALT0
I
LCD_RD_E
RD_E signal
LCD_ENABLE
ALT1
IO
LCD_RESET
Reset signal
LCD_RESET
ALT0
IO
LCD_RS
RS signal
LCD_HSYNC
ALT1
O
LCD_VSYNC
VSYNC signal
LCD_VSYNC
ALT0
I
LCD_WR_RWN
WR signal
LCD_CLK
ALT1
IO
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2132
NXP Semiconductors

<!-- page 2133 -->

34.3
Clocks
The following table describes the clock sources for eLCDIF. Please see Clock Controller
Module (CCM) for clock setting, configuration and gating information.
Table 34-2. eLCDIF Clocks
Clock name
Clock Root
Description
apb_clk
axi_clk_root
AXI clock
pix_clk
lcdif_pix_clk_root
Pixel clock
34.4
Functional Description
Bus Interface Mechanisms through Initializing the eLCDIF, describe the internal pipeline
for the eLCDIF interfaces. Differences for each mode are then described in separate
sections, as follows:
• MPU Interface
• VSYNC Interface
• DOTCLK Interface
• ITU-R BT.656 Digital Video Interface (DVI)
eLCDIF pin usage by interface mode is described in eLCDIF Pin Usage by Interface
Mode.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2133

<!-- page 2134 -->

32x16
RXFIFO
System Bus
Control Bus
AXI Master
HW_LCDIF_CTRL and
_DATA Registers and
DMA Slave
AXI
APB
LCDIF
LCD
Interface
76x256 LFIFO
38x2 INTFIFO
38x16 TXFIFO
Digital Video
Interface
APBH Ctrl
Write Data
Read Data
To/From LCD Pins
BUS CLOCK
(apb_clk)
DISPLAY CLOCK
(pix_clk)
BUS CLOCK
Domain
DISPLAY CLOCK
Domain
Figure 34-1. Top-Level Block Diagram of eLCDIF subsystem
34.4.1
Bus Interface Mechanisms
The LCDIF module has memory-mapped control, data and status registers. It provides
several interfaces to transfer data between the display and SoC.
The bus master interface is used to initiate the requests to transfer data from external
memory to the display. It is completely autonomous, or no CPU intervention is required,
to manage the cyclical nature of refreshing standard display types. Bus mastering can also
be used for MPU mode data writes.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2134
NXP Semiconductors

<!-- page 2135 -->

The PIO interface is used to interface to "Smart" displays to transfer frame buffer data
and control information to/from the external display. The host CPU executes display
drivers to manage the display solution. The following sections describe the system bus
interface mechanisms.
34.4.1.1
Bus Master Operation in Write/Display Modes
The eLCDIF block has a bus master interface that initiates requests for data to drive the
display. The LCDIF_MASTER bit must be set to 1 to enable the bus master interface.
Software should program all control registers required to transfer the frame sequence.
In the MPU and VSYNC mode, single frames are transferred. When a complete frame is
transferred, eLCDIF enters idle and clears the RUN bit in the CTRL register. For
subsequent frame transmission, the eLCDIF setup sequence should be repeated.
The DOTCLK and DVI mode are used to refresh the display at the desired refresh rate
and resolution, and drive displays that don't integrate a display buffer memory. When the
display is refreshed, the eLCDIF will automatically update the
LCDIF_CUR_BUF_ADDR register with the value in LCDIF_NEXT_BUF_ADDR at the
end of current frame and start fetching the next frame from the new address. If the
LCDIF_NEXT_BUF_ADDR register was not updated within a frame refresh cycle,
eLCDIF will keep transmitting the last frame until a new value is programmed into that
register.
eLCDIF also provides the capability of interlacing a progressive frame by fetching odd
lines in the first field and then fetching even lines in the second field. This feature can be
used in the DVI mode and can be turned on by setting the INTERLACE_FIELDS bit in
the LCDIF_CTRL1 register.
34.4.1.2
System Bus Master Performance
The performance of the eLCDIF block can be controlled by changing the burst length and
the outstanding cycle issuing capability depending on the memory bandwidth
requirements. Two fields in the LCDIF_CTRL2 register will throttle system memory
requests. The LCDIF_CTRL2_OUTSTANDING_REQS field will control how many
requests the eLCDIF can have in flight on any given clock cycle. This should be
programmed based on the expected system bus latency for returned read data. Also, the
LCDIF_CTRL2_BURST_LEN_8 bit will set the number of 64 bit words requested for
each eLCDIF system bus request to either 8 or 16 QWORDS. Generally, 4 outstanding
requests of length 16 will provide enough performance to drive any standard display
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2135

<!-- page 2136 -->

resolution. These configuration bits are intended to change the access pattern of the
eLCDIF to optimize system bus throughput when other system masters will contend for
system memory resources.
The LCDIF_THRES register can also be used to optimize bus throughput and power
consumption. The LCDIF_THRES_FASTCLOCK value can be used to change the
BUS_CLK frequency when the number of pixels in the LFIFO is below this programmed
threshold. The BUS_CLK should be set to a frequency that will exceed the bandwidth
requirements of the desired display. In systems supporting the dynamic frequency
modulation of the bus clock frequency, the BUS_CLK will be driven at the desired
frequency when the number of pixels is below the FASTCLOCK threshold. When the
number of pixels is above this threshold, the BUS_CLK will be reduced by a divide
factor selected in the centralized clock control module. This will provide an average
clock frequency that will exactly meet the pixel bandwidth requirements over time, and
minimize power consumption to meet the display bandwidth requirements. During
horizontal or vertical blanking intervals, when the LFIFO is full with data for the next
active display interval, the clock can be reduced to a slow frequency for extended periods
to reduce power consumption.
The LCDIF_THRES_PANIC value can be used to raise the priority of requests initiated
by the eLCDIF to alter how the eLCDIF requests are arbitrated by the system bus
infrastructure. The panic output control signal is raised when the number of 32bpp pixel
equivalents in the LFIFO is less than this programmed value. Since the LFIFO is
arranged as a 256x64bit quadword FIFO, it contains two 32bpp pixels per quadword, or
512 32bpp pixels total. To set the panic output when 3/4s of the LFIFO is empty, set the
LCDIF_THRES_PANIC value to 3/4 * 512, or 128. The panic signal output is used to
assess higher priority to eLCDIF system requests to avoid eLCDIF under run errors
during periods of high system bandwidth utilization.
The features available with the LCDIF_THRES register require support from system
clocking and dynamic priority control. Refer to the appropriate block documentation to
assess the system support for these features.
34.4.2
Write Data Path
eLCDIF supports raster based frame buffers and there is no support for tiled buffers.
There are several options to accommodate endianness of display buffers in memory
before the data is processed for the external display. The
LCDIF_CTRL[INPUT_DATA_SWIZZLE] field provides the following options for data
word multiplexing:
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2136
NXP Semiconductors

<!-- page 2137 -->

00 (0): No swizzle (little-endian)
01 (1): Swap bytes 0 and 3, swap bytes 1 and 2 (big-endian)
10 (2): Swap half-words
11 (3): Swap bytes within each half-word
The LCDIF_CTRL[WORD_LENGTH] field indicates the input data/pixel format.
LCDIF_TRANSFER_COUNT register denotes how much data is contained in each
frame. The LCDIF_TRANSFER_COUNT[H_COUNT] field indicates the number of
pixels per line and LCDIF_TRANSFER_COUNT[V_COUNT] indicates the total number
of lines per frame. The LCDIF_CTRL1[BYTE_PACKING_FORMAT] field can be used
to specify which bytes within the 32-bit word are going to be valid. For example, if the
entire 32-bit word is valid, LCDIF_CTRL1[BYTE_PACKING_FORMAT] should be set
to 0xF, if only lower 3 bytes of each word in the frame buffer are valid, then
LCDIF_CTRL1[BYTE_PACKING_FORMAT] should be set to 0x7.
The LCDIF_CTRL[LCD_DATABUS_WIDTH] field suggests the width of the bus going
to the display controller. There is an option to source all 32 bits of the input word and
transfer it to the output I/O display interface. If the
LCDIF_CTRL[LCD_DATABUS_WIDTH] is not the same as
LCDIF_CTRL[WORD_LENGTH], eLCDIF will perform RGB to RGB color space
conversion. For example, if the input frame has fewer bits per pixel than the display, as in
a 16 bpp input frame going to 24 bpp LCD, eLCDIF will pad the MSBs of each color to
the LSBs of the same color for each pixel. If the input frame has more bits per pixel than
the display, for example, 24 bpp input frame going to 16 bpp LCD, eLCDIF will drop the
LSBs of each color channel to convert to the lower color depth. eLCDIF also has the
capability to support delta pixel displays by swizzling the R, G and B colors of each pixel
in the odd and even lines of the frame separately by programming the
LCDIF_CTRL2[ODD_LINE_PATTERN] and the
LCDIF_CTRL2[EVEN_LINE_PATTERN] bit fields. This operation occurs after the
RGB-to-RGB color space conversion operation.
eLCDIF also supports RGB to YCbCr 4:2:2 color space conversion. This is useful in the
DVI mode since the TV encoder requires input in YCbCr 4:2:2 format. The
LCDIF_CSC* registers have complete programmability over the CSC coefficients and
offsets. The values must be written into these registers in the signed two's complement
format.
The following list shows how the different input/output combinations can be obtained:
• LCDIF_CTRL[WORD_LENGTH]=1 indicates that the input is 8-bit data. This is
most likely going to be used for sending commands in MPU interface, or maybe a
gray scale image. Any combination of
LCDIF_CTRL1[BYTE_PACKING_FORMAT] is permissible.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2137

<!-- page 2138 -->

Limitation: LCDIF_TRANSFER_COUNT[H_COUNT] must be a multiple of the
sum of BYTE_PACKING_FORMAT [3], BYTE_PACKING_FORMAT [2],
BYTE_PACKING_FORMAT [1] and BYTE_PACKING_FORMAT [0].
LCDIF_CTRL[LCD_DATABUS_WIDTH] must be 1, indicating an 8-bit data bus.
• LCDIF_CTRL[WORD_LENGTH]=0 implies the input frame buffer is RGB 16 bits
per pixel. LCDIF_CTRL[DATA_FORMAT_16_BIT] field determines the pixels are
RGB 555 or RGB 565.
Limitation: LCDIF_CTRL1[BYTE_PACKING_FORMAT] should be 0x3 or 0xC if
there is only one pixel per word. If there are two pixels per word, it should be 0xF
and LCDIF_TRANSFER_COUNT[H_COUNT] will be restricted to be a multiple of
2 pixels.
• LCDIF_CTRL[WORD_LENGTH]=2 indicates that input frame buffer is RGB 18
bits per pixel, that is, RGB 666. The valid RGB values can be left-aligned or right-
aligned within a 32-bit word. The alignment of the valid 18 bits within a word is
indicated by the LCDIF_CTRL[DATA_FORMAT_18_BIT] bit.
Limitation: LCDIF_CTRL1[BYTE_PACKING_FORMAT] can be 0x7, 0xE or 0xF.
Packed pixels are not supported in this case.
LCDIF_TRANSFER_COUNT[H_COUNT] can be any number.
• LCDIF_CTRL[WORD_LENGTH]=3 indicates that the input frame-buffer is RGB
24 bits per pixel (RGB 888). If LCDIF_CTRL1[BYTE_PACKING_FORMAT] is
0x7, it indicates that there is only one pixel per 32-bit word and there is no restriction
on LCDIF_TRANSFER_COUNT[H_COUNT]. This is also the option that provides
32 bit output depending on the I/O muxing options available. The fourth byte, or bits
[31:24], and connected to the I/Os if this muxing is available in the chip package.
Limitation: If LCDIF_CTRL1[BYTE_PACKING_FORMAT] is 0xF, it indicates
that the pixels are packed, that is, there are 4 pixels in 3 words or 12 bytes and
LCDIF_TRANSFER_COUNT[H_COUNT] must be a multiple of 4 pixels.
• LCDIF_CTRL1[YCBCR422_INPUT]=1 implies that the input frame is in YCbCr
4:2:2 format. LCDIF_CTRL1[BYTE_PACKING_FORMAT] must be 0xF.
Limitation: LCDIF_CTRL[LCD_DATABUS_WIDTH] must be 8-bit and
LCDIF_TRANSFER_COUNT[H_COUNT] must be a multiple of 2 pixels.
LCDIF_CTRL2[ODD_LINE_PATTERN] and
LCDIF_CTRL2[EVEN_LINE_PATTERN] must be 0 when any of
LCDIF_CTRL[RGB_TO_YCBCR422_CSC] or
LCDIF_CTRL1[INTERLACE_FIELDS] or LCDIF_CTRL[YCBCR422_INPUT]
bits is 1.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2138
NXP Semiconductors

<!-- page 2139 -->

After the RGB to RGB or RGB to YCbCr 4:2:2 color space conversions, there is one
more opportunity to swizzle the data before sending it out to the display or the encoder.
This can be done with the LCDIF_CTRL[CSC_DATA_SWIZZLE] field, and it provides
the same options as the LCDIF_CTRL[INPUT_DATA_SWIZZLE] register.
Finally, there is an option to shift the output data before sending it out to the display. This
is done based on the LCDIF_CTRL[SHIFT_DIR] and
LCDIF_CTRL[SHIFT_NUM_BITS] fields.
AXI 
MST
Control
Byte
Packing
Swizzle
Count
Catch
76x
256
LFIFO
Serialize,
Unpack
& RGB
to RGB
888 CSC
Delta
Pixel
38x2
IntFIFO
RGB to
YCbCr
4:2:2
38x16
TxFIFO
Transfer
Control
Signal
Gen
Shift
Write Control
Xmit Data
64
64
8
8
8
FIFO Status
FIFO Status
FIFO in Byte Enables
76
38
38
38
38
38
32
32
4
LCD Control
LCD Data
8/16/18/24/32
Read
Control
BUS CLOCK
  Domain
DISPLAY CLOCK
  Domain
Mode
Control
Figure 34-2. General Operations in Write Data Path
The examples in the following figures illustrate some different combinations of register
programming for write mode. Assume that the data transferred over the system bus
within a 32 bit word is organized as {A7-A0, B7-B0, C7-C0, D7-D0} in 8-bit mode and
{A15-A0, B15-B0} in 16-bit mode.
In this example, all 32 bits of the input word are transferred out over an 8 bit display bus.
Each byte within the 32 bit word is shifted to the right with zeros appended to bits D[7:6].
The input data bits [7:2] are shifted to the right by 2 bits and presented on the D[5:0].
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2139

<!-- page 2140 -->

WORD_LENGTH = 1
BYTE_PACKING_FORMAT[3:0] = 1111
DATA_SWIZZLE[1:0] = 00
SHIFT_DIR = 1, SHIFT_NUM_BITS[1:0] = 10
32 Bit Word
LCD_DATA[7:0] Pins
A7-A0
B7-B0
C7-C0
D7-D0
A7-A0
B7-B0
C7-C0
D7-D0
A7-A0
B7-B0
C7-C0
D7-D0
{0, 0, D7-D2}
{0, 0, C7-C2}
{0, 0, B7-B2}
{0, 0, A7-A2}
{0, 0, A7-A2}
{0, 0, B7-B2}
{0, 0, C7-C2} {0, 0, D7-D2}
Figure 34-3. Register programming for write mode
In this 8 bit display interface example, one byte of the input word is deleted and not
transferred over the external 8 bit display interface. This mode could be used to transfer
24bpp pixels over the 8 bit interface. In this case, the 4th unused byte is not transferred.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2140
NXP Semiconductors

<!-- page 2141 -->

WORD_LENGTH = 1
BYTE_PACKING_FORMAT[3:0] = 1111
DATA_SWIZZLE[1:0] = 00
SHIFT_DIR = 1, SHIFT_NUM_BITS[1:0] = 00
32 Bit Word
LCD_DATA[7:0] Pins
A7-A0
B7-B0
C7-C0
D7-D0
B7-B0
C7-C0
D7-D0
X
B7-B0
C7-C0
D7-D0
X
B7-B0
C7-C0
D7-D0
X
B7-B0
C7-C0
D7-D0
Figure 34-4. Register programming for write mode
The following example uses a 16 bit display interface. Each 16 bit half word is shifted to
the right by two bits with zeros appended to the most significant two bits.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2141

<!-- page 2142 -->

WORD_LENGTH = 1
BYTE_PACKING_FORMAT[3:0] = 1111
DATA_SWIZZLE[1:0] = 00
SHIFT_DIR = 1, SHIFT_NUM_BITS[1:0] = 10
32 Bit Word
LCD_DATA[15:0] Pins
A15-A0
B15-B0
A15-A0
B15-B0
A15-A0
B15-B0
{0, 0, A15-A2}
{0, 0, B15-B2}
{0, 0, A15-A2}
{0, 0, B15-B2}
Figure 34-5. Register programming for write mode
This example indicates how an unpacked frame buffer can sourced for display. Only a
single 16 bit half word within the 32 bit word is tranferred out via the 16 display bus.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2142
NXP Semiconductors

<!-- page 2143 -->

WORD_LENGTH = 0
BYTE_PACKING_FORMAT[3:0] = 1100
DATA_SWIZZLE[1:0] = 01
SHIFT_DIR = 1, SHIFT_NUM_BITS[1:0] = 00
32 Bit Word
LCD_DATA[15:0] Pins
A15-A0
B15-B0
A15-A0
X
A15-A0
X
A15-A0
X
A15-A0
Figure 34-6. Register programming for write mode
34.4.3
Read Data Path
Figure 34-7 shows the MPU read data path in detail.
eLCDIF can read from an external display that follows the 6800/8080 MPU protocol.
The display bus width is determined by the LCD_DATABUS_WIDTH bit field. The data
sampled at every read strobe is called a subword and the number of subwords that can be
packed in a 32-bit word is given by the READ_MODE_NUM_PACKED_SUBWORDS
bit field. The INITIAL_DUMMY_READ bit field directs the eLCDIF to skip the number
of programmed subwords before starting to process read data. This feature is useful in the
case of an LCD controller that returns the last written data the first time a read is issued,
and then sends the correct data thereafter. SHIFT_DIR and SHIFT_NUM_BITS bit fields
indicate whether the data needs to be shifted before getting stored in the internal registers.
For example, a value of 2 in READ_MODE_NUM_PACKED_SUBWORDS if lcd
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2143

<!-- page 2144 -->

databus width is 8 bits indicates two bytes should be packed in a 32-bit word, while if the
lcd databus width is 16 bits, it indicates that two half words (or 4 bytes) should be
packed.
LCD DMA
Control
Swizzle
Count
Calculation
32x16
RXFIFO
Transfer
Control
Signal
Gen
Temp Reg and Valid
Subword Packing
Shifting
RGB to 
RGB
CSC
WORD_LENGTH
READ_MODE_OUTPUT
_IN_RGB_FORMAT
BUS CLOCK Domain
DISPLAY CLOCK Domain
32
32
32
32
32
32
32
32
32
Read Control
FIFO Status
Write Control
8/16
LCD Data
8/16/18/24
LCD Control
8/16
8/16
Figure 34-7. MPU Read Data Path
After the last subword within a word is reached, the block looks at the
READ_PACK_DIR in the HW_LCDIF_CTRL2 register. If this bit is set, the block will
swizzle the data, but only within the valid bytes, unlike in the write mode, where swizzle
occurs across all 4 bytes. If the READ_MODE_OUTPUT_IN_RGB_FORMAT bit is set,
eLCDIF will convert the data obtained from the READ_PACK_DIR operation into 24-bit
unpacked RGB and then re-convert it into 16/18/24 bpp RGB depending on the
WORD_LENGTH field. The DATA_FORMAT_16/18/24_BIT bit fields are also
considered while converting to 24-bit unpacked RGB format. For example, if
DATA_FORMAT_18_BIT is 1, the RGB666 data will be packed in the upper bits
[31:4]of a 32-bit word, and that bit is 0, the data will be packed in the lower bits [17:0].
After all these operations, the data gets written into the RXFIFO.
The following figures show some examples of how data is handled in different MPU read
modes.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2144
NXP Semiconductors

<!-- page 2145 -->

24 BPP
24 BPP
18 BPP
18 BPP
16 BPP
16 BPP
WORD_LENGTH
READ_MODE_OUTPUT_IN
_RGB_FORMAT
RXF FC
DATA_SWIZZLE
READ_PACK_DIR
SHIFT
00
00
B7-B0
A7-A0
00
C0
A7-A0
B7-B0 
00
00
{R4-R0, G5-G4} {G2-G0, B4-B0}
00
{R4-R0, R4-R2}
{G5-G0, G5-G4}
{B4-B0, B4-B2}
00
{2'h0, R4-R0, R4}
{2'h0, G5-G0}
{2'h0, B4-B0, B4}
00
{6'h0, R4-R3}
{R2-R0, R4, G5} {G1-G0, G5, B4-B0, B4}
{R4-R0, R4, G5-G4}
{G3-G0, B4-B1}
{B0, B4, 6'h0}
00
00
00
{R4-R0, G5-G3}
{G2-G0, B4}
00
00
{1'ho, R4-R0, G5}
{G3-G1, B4-B0}
TO DMA
In the case of 
LCD_DATABUS_WIDTH = 8 bits. 
Input is stored in little endian format, 
with the first incoming byte stored in 
byte 0
READ_MODE_NUM_PACKED_SUBWORDS = 2 AND LCD_DATABUS_WIDTH = 8 BITS
OR
READ_MODE_NUM_PACKED_SUBWORDS = 1 AND LCD_DATABUS_WIDTH = 16 BITS
1
1
0
0
Figure 34-8. Data in MPU read mode
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2145

<!-- page 2146 -->

24 BPP
24 BPP
18 BPP
18 BPP
16 BPP
16 BPP
WORD_LENGTH
READ_MODE_OUTPUT_IN
_RGB_FORMAT
RXF FC
DATA_SWIZZLE
READ_PACK_DIR
SHIFT
00
C7-C0
B7-B0
A7-A0
00
R7-R0
G7-G0
B7-B0
00
{R7-R0}
{G7-G0}
{B7-B0}
00
{2'h0, R7-R2}
{2'h0, G7-G2}
{2'h0, B7-B2}
00
{6'h0, R7-R6}
{R5-R2, G7-G4}
{G3-G2, B7-B2}
{R7-R2, G7-G6}
{G5-G2, B7-B4}
{B3-B2, 6'h0}
00
00
00
{R7-R3, G7-G5}
{G4-G2, B7-B3}
00
00
{1'h0, R7-R3, 
G5-G7}
{G5-G3, B7-B3}
TO DMA
In the case of 
LCD_DATABUS_WIDTH = 8 bits. 
Input is stored in little endian format, 
with the first incoming byte stored in 
byte 0
READ_MODE_NUM_PACKED_SUBWORDS = 3 AND LCD_DATABUS_WIDTH = 8 BITS
OR
READ_MODE_NUM_PACKED_SUBWORDS = 1 AND LCD_DATABUS_WIDTH = 24 BITS
8/24
1
1
0
0
00
A7-A0
B7-B0 
C7-C0
Figure 34-9. Data in MPU read mode
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2146
NXP Semiconductors

<!-- page 2147 -->

24 BPP
24 BPP
18 BPP
18 BPP
16 BPP
16 BPP
WORD_LENGTH
READ_MODE_OUTPUT_IN
_RGB_FORMAT
RXF FC
DATA_SWIZZLE
READ_PACK_DIR
SHIFT
00
C7-C0
B7-B0
A7-A0
00
{6'h0, R5-R4}
{R3-R0, G5-G2} {G1-G0, B5-B0}
00
{R5-R0, R5-R4} {G5-G0, G5-G4} {B5-B0, B5-B4}
00
{2'h0, R5-R0}
{2'h0, G5-G0}
{2'h0, B5-B0}
00
{6'h0, R5-R4}
{R3-R0, G5-G2}
{G1-G0, B5-B0}
{R5-R0, G5-G4}
{G3-G0, B5-B2}
{B1-B0, 6'h0}
00
00
00
{R5-R1, G5-G3}
{G2-G0, B5-B1}
00
00
{1'h0, R5-R1, 
G5-G4}
{G3-G1, B5-B1}
TO DMA
In the case of 
LCD_DATABUS_WIDTH = 8 bits. 
Input is stored in little endian format, 
with the first incoming byte stored in 
byte 0
READ_MODE_NUM_PACKED_SUBWORDS = 1 AND LCD_DATABUS_WIDTH = 18 BITS
18
1
1
0
0
00
A7-A0
B7-B0 
C7-C0
Figure 34-10. Data in MPU read mode
Restrictions:
READ_PACK_DIR should only be used if it is required to swizzle the subwords before
doing RGB to RGB CSC, otherwise the DATA_SWIZZLE field should be used to
swizzle across bytes.
READ_PACK_DIR must be 0 if LCD_DATABUS_WIDTH is 8 bits and
READ_MODE_NUM_PACKED_SUBWORDS =1
If READ_MODE_OUTPUT_IN_RGB_FORMAT bit is set, the following restrictions
should be followed:
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2147

<!-- page 2148 -->

• If LCD_DATABUS_WIDTH = 8 bits, then
READ_MODE_NUM_PACKED_SUBWORDS <= 3.
• If LCD_DATABUS_WIDTH = 16/18/24 bits, then
READ_MODE_NUM_PACKED_SUBWORDS = 1.
34.4.4
eLCDIF Interrupts
eLCDIF supports a number of interrupts to aid controlling and status reporting of the
block.
All the interrupts have individual mask bits for enabling or disabling each of them. They
all get funneled through a single interrupt line connected to the interrupt collector
(ICOLL).
The following list describes the different interrupts supported by eLCDIF:
• Underflow interrupt is asserted when the clock domain crossing FIFO (TXFIFO)
becomes empty but the block is in active display portion during that time. Software
should take corrective action to make sure that this does not happen.
• In the bus master mode, the overflow interrupt will be asserted if the block has
requested more data than it's FIFOs could hold. In the read mode, it will be asserted
if the RxFIFO becomes full and the block reads more data.
• VSYNC edge interrupt will be asserted every time a leading VSYNC edge occurs.
• Cur_frame_done interrupt occurs at the end of every frame in all modes except DVI.
In DVI mode, if IRQ_ON_ALTERNATE_FIELDS bit is set, it will occur at the end
of every frame, otherwise it will occur at the end of every field.
34.4.5
Initializing the eLCDIF
This section describes write modes and MPU read mode.
34.4.5.1
Write Modes
The following initialization steps are common to all eLCDIF write modes of operation
before entering any particular mode.
Initialization steps:
1. Configure the external I/Os to correctly interface the external display, when required.
2. Start the DISPLAY CLOCK (pix_clk) clock and set the appropriate frequency by
programming the registers in CCM.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2148
NXP Semiconductors

<!-- page 2149 -->

3. Start the BUS CLOCK (apb_clk) and set the appropriate frequency by programming
the registers in CCM.
4. Bring the eLCDIF out of soft reset and disable the clock gate bit.
5. Reset the LCD controller by setting LCDIF_CTRL1[RESET] bit appropriately, being
careful to observe the reset requirements of the controller. See Behavior During
Reset for more information on Reset requirements.
6. Make sure LCDIF_CTRL[READ_WRITEB] bit is 0.
7. Select the transfer mode of operation. The LCDIF_CTRL[MASTER] bit determines
the transfer mode selected. Bus master (LCDIF_CTRL[MASTER] =1), or PIO
(LCDIF_CTRL[MASTER] =0) mode are the transfer modes to select.
8. Set the LCDIF_CTRL[INPUT_DATA_SWIZZLE] according to the endianness of
the LCD controller. Also, set the LCDIF_CTRL[DATA_SHIFT_DIR] and
LCDIF_CTRL[SHIFT_NUM_BITS] if it is required to shift the data left or right
before it is output.
9. Set the LCDIF_CTRL[WORD_LENGTH] field appropriately: 0 = 16-bit input, 1 =
8-bit input, 2 = 18-bit input, 3 = 24/32-bit input. Also, select the correct 16/18/24 bit
data format with the corresponding fields in LCDIF_CTRL register.
10. Set the LCDIF_CTRL1[BYTE_PACKING_FORMAT] field according to the input
frame.
11. Set the LCDIF_CTRL[LCD_DATABUS_WIDTH] appropriately: 0 = 16-bit output,
1 = 8-bit output, 2 = 18-bit output, 3 = 24/32-bit output.
12. Enable the necessary IRQs.
34.4.5.2
MPU Read Mode
The following initialization steps should be done to enter the MPU read mode of
operation:
Initialization steps:
1. Configure the external I/Os to correctly interface the external display.
2. Start the DISPLAY CLOCK (pix_clk) and set the appropriate frequency by
programming the registers in CCM.
3. Start the BUS CLOCK (apb_clk) and set the appropriate frequency by programming
the registers in CCM.
4. Bring the eLCDIF out of soft reset and clock gate.
5. Reset the LCD controller by setting LCDIF_CTRL1_RESET bit appropriately, being
careful to observe the reset requirements of the controller.
6. Set the READ_WRITEB bit in LCDIF_CTRL register to 1.
7. Set the LCDIF_MASTER bit in LCDIF_CTRL register to 0. Bus master mode is not
supported for reading data from the display.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2149

<!-- page 2150 -->

8. Also, set the DATA_SHIFT_DIR and SHIFT_NUM_BITS if it is required to shift
the data left or right before it is output.
9. Indicate if the read data needs to color-space-converted and stored in a different RGB
format by setting the READ_MODE_OUTPUT_IN_RGB_FORMAT field
accordingly.
10. Set the WORD_LENGTH field appropriately: 0 = 16-bit input, 1 = 8-bit input, 2 =
18-bit input, 3 = 24-bit input if READ_MODE_OUTPUT_IN_RGB_FORMAT is
required. Also, select the correct 16/18/24 bit data format with the corresponding
fields in LCDIF_CTRL register.
11. Set the READ_MODE_NUM_PACKED_SUBWORDS field in LCDIF_CTRL2
according to the number of subwords per word required to be packed.
12. Set the READ_PACK_DIR to 1 if it is required to store the data in big-endian
format.
13. Set the LCD_DATABUS_WIDTH appropriately: 0 = 16-bit output, 1 = 8-bit output,
2 = 18-bit output, 3 = 24-bit output.
14. Enable the necessary IRQs.
34.4.6
MPU Interface
The MPU interface is used to transfer data and commands between the SoC via the
eLCDIF and the external display at modest data rates.
Bus master or PIO transactions using the LCDIF_DATA register can be used for MPU
mode write operations. For MPU mode read operations, only PIO can be used. eLCDIF
can support the 6800 as well as the 8080 MPU protocol. If DOTCLK_MODE,
DVI_MODE and VSYNC_MODE bits in LCDIF_CTRL registers are 0, it implies that
the block is in MPU interface mode of operation. The LCDIF MPU mode has four basic
timing parameters: Setup and Hold for the Command/Data register selection (TCS, TCH)
and Setup and Hold for the Data bus (TDS, TDH). These parameters are expressed in
DISPLAY CLOCK (pix_clk) cycles. The LCD_WR signal is used as the write strobe
while LCD_RS signal is typically used to switch between command and data modes.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2150
NXP Semiconductors

<!-- page 2151 -->

LCD_VSYNC
LCD_RS
LCD_CS
LCD_RD_E
(8080)
LCD_WR_RWn
(8080)
LCD_RD_E
(6800)
LCD_WR_RWn
(6800)
LCD_DATA[n:0]
IDLE
START
W1+
W3
WR/RD
LATCH
W2
WR/RD
STOP
LATCH
IDLE
VSYNC PULSE WIDTH
TCS
TCH
TDSW
TDHW
TDSW
TDHW
Data 0
Data 1
Figure 34-11. Timing in write mode of 6800 and 8080 protocols
LCD_RS
LCD_CS
LCD_RD_E
(8080)
LCD_WR_RWn
(8080)
LCD_RD_E
(6800)
LCD_WR_RWn
(6800)
LCD_DATA[n:0]
IDLE
START
W1+
W3
WR/RD
LATCH
W2
WR/RD
STOP
LATCH
IDLE
TCS
TCH
TDSR
TDHR
TDSR
TDHR
Data 0
Data 1
Figure 34-12. Read timing interface in 6800 and 8080 protocols
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2151

<!-- page 2152 -->

The eLCDIF has flexible pin and strobe timings which enable it to optimally support a
wide range of LCDs. The minimum cycle time is two DISPLAY CLOCK (pix_clk)
cycles (TDS=TDH=1). For example, this results in a maximum LCD data rate of 12
MB/s when DISPLAY CLOCK (pix_clk) is 24 MHz. TDS and TDH are 8-bit values, so
the minimum eLCDIF period is 510 DISPLAY CLOCK (pix_clk) cycles (47 KHz with a
24 MHz DISPLAY CLOCK (pix_clk)). The timings are not automatically adjusted if the
DISPLAY CLOCK (pix_clk) frequency changes, so it may be necessary to adjust the
timings if DISPLAY CLOCK (pix_clk) changes.
In the MPU interface mode, the LCDIF_CTRL_ BYPASS_COUNT bit must be 0. The
RUN bit is cleared automatically once the eLCDIF has received/transmitted all the data
as per the LCDIF_TRANSFER_COUNT register and has completed the transfer to the
panel. The current transfer can be cancelled/aborted if the RUN bit is manually made 0.
34.4.6.1
Code Example to Initialize the eLCDIF in MPU Write Mode
// Note: Common initialization steps in Initializing the eLCDIF must also be
// executed along with the following code
BF_CS1(LCDIF_CTRL, DATA_SELECT, 1); // 0 if sending command, 1 if sending data. Note that the
                                  // idle state for LCD_RS signal is high, regardless of the
                                   // programming of the DATA_SELECT register.
BF_CS1 (LCDIF_CTRL, MODE86, 8080_MODE); 
BF_CS1 (LCDIF_CTRL, READ_WRITEB, 0); 
BF_CS1 (LCDIF_CTRL, BYPASS_COUNT, 0); //Must be 0 in MPU mode
BF_CS1 (LCDIF_CTRL1, BUSY_ENABLE, 1);//Only if LCD controller implements a busy line
BF_CS4 (LCDIF_TIMING, CMD_HOLD, 2, CMD_SETUP, 2, DATA_HOLD, 2, DATA_SETUP, 2);  //Values 
based 
                             // on DISPLAY CLOCK (pix_clk) frequency and timing requirements 
of controller.
                            // Note that these register must be non-zero for correct 
operation.
BF_CS2 (LCDIF_TRANSFER_COUNT, H_COUNT, 320, V_COUNT, 240); //For a 320 RGB x 240 display
BF_CS1 (LCDIF_CTRL, RUN, 1);
The eLCDIF is now ready to receive data via bus master PIO write transactions using the
LCDIF_DATA register. Note that when using the PIO write operations to the
LCDIF_DATA register, the software will need to poll the FIFO STATUS bits to ensure
that it does not overflow the eLCDIF data buffers. When eLCDIF is done transmitting
H_COUNT x V_COUNT pixels, it will stop, turn off the RUN bit and assert the
cur_frame_done interrupt.
34.4.7
VSYNC Interface
The VSYNC interface uses the same protocol as the MPU interface, with an additional
signal VSYNC at the frame rate of the display, as shown in the figure given in MPU
Interface section.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2152
NXP Semiconductors

<!-- page 2153 -->

It is used in the moving picture display mode where data has to be written to the internal
LCD buffer at a speed higher than the display rate and displayed in synchronization with
the VSYNC signal. This mode is selected by setting the VSYNC_MODE bit in
LCDIF_CTRL register. The VSYNC signal is programmable for period, polarity and
direction. Many other programmable parameters are shared with the MPU interface. The
VSYNC_OEB bit in LCDIF_VDCTRL0 register indicates whether the display controller
will send the VSYNC signal, or whether it should be generated by eLCDIF. The timing
of the VSYNC signal is based on the DISPLAY CLOCK (pix_clk) (make sure
VSYNC_PULSE_WIDTH_UNIT = VSYNC_PERIOD_UNIT = 0 and VSYNC_ONLY
= 1) and it is determined by the VSYNC_PERIOD, VSYNC_PULSE_WIDTH and
VSYNC_POL fields in LCDIF_VDCTRL0-4 registers. The SYNC_SIGNALS_ON bit in
LCDIF_VDCTRL4 register must be set if the target requires the VSYNC signal to be
generated by eLCDIF. If the WAIT_FOR_VSYNC_EDGE bit in LCDIF_CTRL register
is set, it indicates that the hardware should wait until it sees the leading VSYNC edge
before starting the data transfer. The VERITCAL_WAIT_CNT indicates the number of
DISPLAY CLOCK (pix_clk) cycles from the leading VSYNC edge after which data
transfer will be started on the interface.
In the VSYNC interface mode, the LCDIF_CTRL_ BYPASS_COUNT bit must be 0.
The RUN bit is cleared automatically once the eLCDIF has received/transmitted all the
data as per the LCDIF_TRANSFER_COUNT register and has completed the transfer to
the panel. The current transfer can be cancelled/aborted if the RUN bit is manually made
0.
34.4.7.1
Code Example to Initialize eLCDIF in VSYNC Mode
// Note: Common initialization steps in Initializing the eLCDIF must also be
// executed along with the following code
BF_CS1 (LCDIF_CTRL, DATA_SELECT, 1); // 0 if sending command, 1 if sending data. Note that 
//the idle state for LCD_RS signal is high, regardless of the programming of the DATA_SELECT
//register.
BF_CS1 (LCDIF_CTRL, MODE86, 8080_MODE); 
BF_CS1 (LCDIF_CTRL, BYPASS_COUNT, 0); //Must be 0 in MPU mode
BF_CS1 (LCDIF_CTRL1, BUSY_ENABLE, 0);
BF_CS4 (LCDIF_TIMING, CMD_HOLD, 2, CMD_SETUP, 2, DATA_HOLD, 2, DATA_SETUP, 2);  //Values 
//based on DISPLAY CLOCK (pix_clk) frequency and timing requirements of controller. Note 
that these  
//register must be non-zero for the MPU and VSYNC modes.
BF_CS2 (LCDIF_TRANSFER_COUNT, H_COUNT, 320, V_COUNT, 240);//For a 320 RGB x 240 display
//The following section indicates setting up the VSYNC signal timing when VSYNC is an output
BF_CS1 (LCDIF_VDCTRL0, VSYNC_OEB, 0); //Making VSYNC signal an output
BF_CS1 (LCDIF_VDCTRL4, VSYNC_ONLY, 1); //Only need to generate VSYNC signal
BF_CS1 (VDCTRL0, VSYNC_POL, 0); //Setting the polarity of VSYNC signal to be low during
//VSYNC_PULSE_WIDTH time
BF_CS2 (LCDIF_VDCTRL0, VSYNC_PERIOD_UNIT, 0, VSYNC_PULSE_WIDTH_UNIT, 0);
BF_CS2 (LCDIF_VDCTRL1, VSYNC_PERIOD, 400000, VSYNC_PULSE_WIDTH, 100);//Frame display rate in
//terms of number of DISPLAY CLOCKS (pix_clk).
BF_CS2 (LCDIF_VDCTRL2, HSYNC_PULSE_WIDTH, 0, HSYNC_PERIOD, 0);
BF_CS1 (LCDIF_VDCTRL3, VERTICAL_WAIT_CNT, 50);
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2153

<!-- page 2154 -->

BF_CS1 (LCDIF_VDCTRL4, SYNC_SIGNALS_ON, 1);
BF_CS2 (LCDIF_CTRL, VSYNC_MODE, 1, WAIT_FOR_VSYNC_EDGE, 1); //set WAIT_FOR_VSYNC_EDGE if 
//software wishes to transfer the next frame after the VSYNC edge occurs.
BF_CS1 (LCDIF_CTRL, RUN, 1);
The eLCDIF is now ready to receive data via bus master requests or PIO writes to the
LCDIF_DATA register. When eLCDIF is done transmitting H_COUNT x V_COUNT
pixels, it will stop, turn off the RUN bit and assert the cur_frame_done interrupt.
34.4.8
DOTCLK Interface
The DOTCLK interface is another mode used in moving picture displays.
It includes the VSYNC, HSYNC, DOTCLK and (optional) ENABLE signals. The
interface is popularly called the RGB interface if the ENABLE signal is present.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2154
NXP Semiconductors

<!-- page 2155 -->

One Frame (VSYNC) Period
Vertical Back Porch
Vertical Front Porch
VSYNC Pulse Width 
Vertical Valid Data Count
VSYNC Wait Count
One Line (HSYNC) Period
HSYNC Pulse Width
HYSNC Wait Count
Horizontal Valid Data Count
HSYNC
DOTCLK
ENABLE
DATA[7:0]
VSYNC
HSYNC
DOTCLK
ENABLE
DATA[7:0]
VSYNC_POL = 0
HSYNC_POL = 0
DOTCLK_POL = 0
ENABLE_POL = 0
Figure 34-13. DOTCLK protocol with programmable parameters
The DOTCLK mode writes data at high speed to the LCD, and the display operation is
synchronized with the VSYNC, HSYNC, ENABLE and DOTCLK signals. The
polarities, periods and pulse-widths of the sync signals are programmable using the
LCDIF_VDCTRL0-4 registers. The units for the VSYNC signal must be number of
horizontal lines and can be selected using the VSYNC_PULSE_WIDTH_UNIT and
VSYNC_PERIOD_UNIT bit fields. The VERTICAL_WAIT_CNT is by default given
the same unit as the VSYNC_PERIOD. The DISPLAY CLOCK (pix_clk) frequency is
managed by the CCM.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2155

<!-- page 2156 -->

In DOTCLK mode, LCDIF_CTRL_BYPASS_COUNT bit must be set to 1. To end the
current transfer, the software should make the DOTCLK_MODE bit 0, so that all data
that is currently in the LCDIF LFIFO and TXFIFO is transmitted. Once that transfer is
complete, the block will automatically clear the RUN bit and issue the cur_frame_done
interrupt.
34.4.8.1
Code Example
The following code shows an example for programming a 320x240 display.
NOTE
Setting up the display must be done through the MPU mode or
via SPI.
// Note: Common initialization steps in Initializing the eLCDIF must also be
// executed along with the following code
BF_CS1 (LCDIF_CTRL, DOTCLK_MODE, 1); 
BF_CS1 (LCDIF_CTRL, BYPASS_COUNT, 1); //Always for DOTCLK mode
BF_CS1 (LCDIF_VDCTRL0, VSYNC_OEB, 0); //Vsync is always an output in the DOTCLK mode
BF_CS4 (LCDIF_VDCTRL0, VSYNC_POL, 0, HSYNC_POL, 0, DOTCLK_POL, 0, ENABLE_POL, 0);
BF_CS1 (LCDIF_VDCTRL0, ENABLE_PRESENT, 1);
BF_CS2 (LCDIF_VDCTRL0, VSYNC_PERIOD_UNIT, 1, VSYNC_PULSE_WIDTH_UNIT, 1);
BF_CS1 (LCDIF_VDCTRL0, VSYNC_PULSE_WIDTH, 2);
BF_CS1 (LCDIF_VDCTRL1, VSYNC_PERIOD, 280);
BF_CS2 (LCDIF_VDCTRL2, HSYNC_PULSE_WIDTH, 10, HSYNC_PERIOD, 360); //Assuming  
                                                       //  LCD_DATABUS_WIDTH is 24bit
BF_CS2 (LCDIF_VDCTRL3, VSYNC_ONLY, 0);
BF_CS2 (LCDIF_VDCTRL3, HORIZONTAL_WAIT_CNT, 20, VERTICAL_WAIT_CNT, 20);
BF_CS1 (LCDIF_VDCTRL4, DOTCLK_H_VALID_DATA_CNT, 320);//Note that DOTCLK_V_VALID_DATA_CNT is
                                 //implicitly assumed to be HW_LCDIF_TRANSFER_COUNT_V_COUNT
BF_CS1 (LCDIF_VDCTRL4, SYNC_SIGNALS_ON, 1);
BF_CS1 (LCDIF_CTRL, RUN, 1);    
To stop the transfer completely, the ideal way is to make DOTCLK_MODE = 0. In that
case, the block will transmit the contents in the FIFO and reset the RUN bit.
34.4.9
CSI HANDSHAKE INTERFACE
The LCDIF and CSI support a pipeline mode to use double buffers inside OCRAM for
the video pass through from CSI to LCDIF, the pipeline buffer size can be 8 line or 16
line as configurable. The pipeline will be handle by hardware handshake signals between
CSI and LCDIF. The LCDIF will have the capability to synchronize display with CSI
based on the VSYNC signal from CSI. When LCDIF is enabled to start display,it can
optionally wait for the VSYNC edge from CSI before it starts the display for next
frame,The delay from VSYNC input to the start of next frame is programmable by
LCDIF_SYNC_DELAY register.
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2156
NXP Semiconductors

<!-- page 2157 -->

VS
VB1
FB0
FB1
FB0
FB1
VB2
VS
CSI_IN
VS
VB1
FB0
FB1
FB0
FB1
VB2
VS
LCD_OUT
csi_ready0
csi_ready1
lcdif_done0
lcdif_done1
CSI_WR
LCD_RD
Figure 34-14. CSI HandShake Interface
When this mode is enabled ,The hardware handshake protocol will process. At the start of
CSI with camera input,the CSI will put the input data to one frame buffer.When the
frame buffer is ready for LCDIF display,CSI will assert csi_ready signal to indicate
LCDIF to read the buffer and LCDIF will display data in this buffer.When one frame
buffer reading finished ,LCDIF will set the lcdif_done signal to indicate CSI this buffer
has been displayed and can be written again.With this double buffer handshake mode,the
LCDIF can display the video input within very short delay and minimize DRAM
bandwidth.
34.4.10
Alpha Blending Interface
The LCDIF have the capability to add an extra overlay on the normal display
buffer,LCDIF can fetch data from two buffers and combine them before display,one
buffer data can have the alpha value with the RGB pixels. With
LCDIF_AS_CTRL[AS_ENABLE] is set, the LCDIF will start fetching alpha surface
buffer data in bus master mode and combine it with another buffer.
The LCDIF_AS_CTRL[ALPHA_CTRL] bits determines how the alpha value is
constructed for the alpha surface and alpha blending process is as same as in PXP block,
for the alpha blend and color key process refer to the PXP block descriptions.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2157

<!-- page 2158 -->

34.4.11
ITU-R BT.656 Digital Video Interface (DVI)
ITU-R BT.656 Digital Video Interface shown below transmits 4:2:2 YCbCr digital
component video to a digital video encoder that can translate it into 525/60 or 625/50
analog TV signal.
Unique timing codes (timing reference signals) are embedded within the video stream to
indicate the different timing events that would have been otherwise indicated by VSYNC,
HSYNC and BLANK signals. The hardware supports 8-bit data transfers; the pins are
shared with the lower 8 bits of LCD data bus. The LCD_RS pin is shared with the clock
signal of the interface (called CCIRCLK here for uniqueness). CCIRCLK also can be
obtained on the LCD_DOTCLK pin. The mode shares the write FIFO with the LCD
interface and the associated pipeline. The programmable parameters in registers
LCDIF_DVICTRL0-3 allow setting the total number of horizontal lines per frame,
vertical and horizontal blanking interval, odd and even field start and end positions, and
so on. In short, these parameters are provided to ensure that the hardware has enough
flexibility to generate the right 525/60 or 625/50 data streams. Most of the initialization
steps in Initializing the eLCDIF such as data shifting, swizzle, and so on, are applicable
to DVI mode also. The register descriptions in the programmable registers section at the
end of this chapter include example code for programming the DVICTRL0-3 registers.
In DVI mode, LCDIF_CTRL_BYPASS_COUNT bit must be set to 1. To end the current
transfer, the software should make the DVI_MODE bit the value 0, so that all data that is
currently in the LCDIF LFIFO and TXFIFO is transmitted. Once that transfer is
complete, the block will automatically clear the RUN bit and assert the cur_frame_done
interrupt.
Y
Y
Y
Y
Y
EAV Code
Blanking
SAV Code
Co-Sited
Co-Sited
4
268 (280)
4
1440
Start of Digital Line
Start of Digital Active Line
Next Line
Digital
Video
Stream
1716 (1728)
H Control Signal
F
F
F
F
F
F
0
0
0
0
0
0
0
0
X
Y
X
Y
8
0
8
0
8
0
1
0
1
0
1
0
C
B
C
B
C
B
C
R
C
R
Figure 34-15. Digital Video Interface
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2158
NXP Semiconductors

<!-- page 2159 -->

34.4.12
eLCDIF Pin Usage by Interface Mode
The following tables detail how the eLCDIF level interface pins are used based on the
desired mode of operation. The chip level I/Os should also be configured to be consistent
with the desired eLCDIF operating mode.
The VSYNC signal has been mapped onto two pins, LCD_BUSY and LCD_VSYNC.
The pin multiplexing can be programmed to select either of those pins to function as
VSYN.
NOTE
There is an option to internally mux the HSYNC, DOTCLK
and ENABLE signals in the DOTCLK mode by setting the
MUX_SYNC_SIGNALS bit in the VDCTRL0 register.
Table 34-3. Pin use in MPU Mode
PIN NAME
8-bit
MPU
LCD IF
16-bit
MPU
LCD IF
18-bit
MPU
LCD IF
24-bit
MPU
LCD IF
LCD_RS
LCD_ RS
LCD_ RS
LCD_ RS
LCD_RS
LCD_CS
LCD_CS
LCD_CS
LCD_ CS
LCD_CS
LCD_WR
_RWn
LCD_WR
_RWn
LCD_WR
_RWn
LCD_WR
_RWn
LCD_WR
_RWn
LCD_RD_E
LCD_RD_E
LCD_RD_E
LCD_RD_E
LCD_RD_E
LCD_VSYNC*
(Two options)
X
X
X
X
LCD_HSYNC
X
X
X
X
LCD_DOTCLK
X
X
X
X
LCD_ENABLE
X
X
X
X
LCD_DATA23
(LCD_D23)
X
X
X
LCD_DATA23
LCD_DATA22
(LCD_D22)
X
X
X
LCD_DATA22
LCD_DATA21
(LCD_D21)
X
X
X
LCD_DATA21
LCD_DATA20
(LCD_D20)
X
X
X
LCD_DATA20
LCD_DATA19
(LCD_D19)
X
X
X
LCD_DATA19
LCD_DATA18
(LCD_D18)
X
X
X
LCD_DATA18
LCD_DATA17
(LCD_D17)
X
X
LCD_DATA17
LCD_DATA17
Table continues on the next page...
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2159

<!-- page 2160 -->

Table 34-3. Pin use in MPU Mode (continued)
PIN NAME
8-bit
MPU
LCD IF
16-bit
MPU
LCD IF
18-bit
MPU
LCD IF
24-bit
MPU
LCD IF
LCD_DATA16
(LCD_D16)
X
X
LCD_DATA16
LCD_DATA16
LCD_DATA15
(LCD_D15) /
VSYNC*
X
LCD_DATA15
LCD_DATA15
LCD_DATA15
LCD_DATA14
(LCD_D14) /
HSYNC**
X
LCD_DATA14
LCD_DATA14
LCD_DATA14
LCD_DATA13
(LCD_D13) /
LCD_DOTCLK**
X
LCD_DATA13
LCD_DATA13
LCD_DATA13
LCD_DATA12
(LCD_D12) /
ENABLE**
X
LCD_DATA12
LCD_DATA12
LCD_DATA12
LCD_DATA11
(LCD_D11)
X
LCD_DATA11
LCD_DATA11
LCD_DATA11
LCD_DATA10
(LCD_D10)
X
LCD_DATA10
LCD_DATA10
LCD_DATA10
LCD_DATA09 (LCD_D9)
X
LCD_DATA09
LCD_DATA09
LCD_DATA09
LCD_DATA08 (LCD_D8)
X
LCD_DATA08
LCD_DATA08
LCD_DATA08
LCD_DATA07 (LCD_D7)
LCD_DATA07
LCD_DATA07
LCD_DATA07
LCD_DATA07
LCD_DATA06 (LCD_D6)
LCD_DATA06
LCD_DATA06
LCD_DATA06
LCD_DATA06
LCD_DATA05 (LCD_D5)
LCD_DATA05
LCD_DATA05
LCD_DATA05
LCD_DATA05
LCD_DATA04 (LCD_D4)
LCD_DATA04
LCD_DATA04
LCD_DATA04
LCD_DATA04
LCD_DATA03 (LCD_D3)
LCD_DATA03
LCD_DATA03
LCD_DATA03
LCD_DATA03
LCD_DATA02 (LCD_D2)
LCD_DATA02
LCD_DATA02
LCD_DATA02
LCD_DATA02
LCD_DATA01 (LCD_D1)
LCD_DATA01
LCD_DATA01
LCD_DATA01
LCD_DATA01
LCD_DATA00 (LCD_D0)
LCD_DATA00
LCD_DATA00
LCD_DATA00
LCD_DATA00
LCD_RESET
LCD_RESET
LCD_RESET
LCD_RESET
LCD_RESET
LCD_BUSY /
LCD_VSYNC
LCD_BUSY
LCD_BUSY
LCD_BUSY
LCD_BUSY
Table 34-4. Pin use in VSYNC Mode
PIN NAME
8-bit
VSYNC
LCD IF
16-bit
VSYNC
LCD IF
18-bit
VSYNC
LCD IF
24-bit
VSYNC
LCD IF
LCD_RS
LCD_RS
LCD_ RS
LCD_RS
LCD_RS
LCD_CS
LCD_CS
LCD_CS
LCD_ CS
LCD_CS
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2160
NXP Semiconductors

<!-- page 2161 -->

Table 34-4. Pin use in VSYNC Mode (continued)
PIN NAME
8-bit
VSYNC
LCD IF
16-bit
VSYNC
LCD IF
18-bit
VSYNC
LCD IF
24-bit
VSYNC
LCD IF
LCD_WR
_RWn
LCD_WR
_RWn
LCD_WR
_RWn
LCD_WR
_RWn
LCD_WR
_RWn
LCD_RD_E
LCD_RD_E
LCD_RD_E
LCD_RD_E
LCD_RD_E
LCD_VSYNC*
(Two options)
LCD_
VSYNC
LCD_
VSYNC
LCD_
VSYNC
LCD_
VSYNC
LCD_HSYNC
X
X
X
X
LCD_DOTCLK
X
X
X
X
LCD_ENABLE
X
X
X
X
LCD_DATA23
(LCD_D23)
X
X
X
LCD_DATA23
LCD_DATA22
(LCD_D22)
X
X
X
LCD_DATA22
LCD_DATA21
(LCD_D21)
X
X
X
LCD_DATA21
LCD_DATA20
(LCD_D20)
X
X
X
LCD_DATA20
LCD_DATA19
(LCD_D19)
X
X
X
LCD_DATA19
LCD_DATA18
(LCD_D18)
X
X
X
LCD_DATA18
LCD_DATA17
(LCD_D17)
X
X
LCD_DATA17
LCD_DATA17
LCD_DATA16
(LCD_D16)
X
X
LCD_DATA16
LCD_DATA16
LCD_DATA15
(LCD_D15) /
VSYNC*
VSYNC
(optional)
LCD_DATA15
VSYNC
(optional)
LCD_DATA15
LCD_DATA14
(LCD_D14) /
HSYNC**
X
LCD_DATA14
X
LCD_DATA14
LCD_DATA13
(LCD_D13) /
LCD_DOTCLK**
X
LCD_DATA13
X
LCD_DATA13
LCD_DATA12
(LCD_D12) /
ENABLE**
X
LCD_DATA12
X
LCD_DATA12
LCD_DATA11
(LCD_D11)
X
LCD_DATA11
X
LCD_DATA11
LCD_DATA10
(LCD_D10)
X
LCD_DATA10
X
LCD_DATA10
LCD_DATA09 (LCD_D9)
X
LCD_DATA09
X
LCD_DATA09
Table continues on the next page...
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2161

<!-- page 2162 -->

Table 34-4. Pin use in VSYNC Mode (continued)
PIN NAME
8-bit
VSYNC
LCD IF
16-bit
VSYNC
LCD IF
18-bit
VSYNC
LCD IF
24-bit
VSYNC
LCD IF
LCD_DATA08 (LCD_D8)
X
LCD_DATA08
X
LCD_DATA08
LCD_DATA07 (LCD_D7)
LCD_DATA07
LCD_DATA07
LCD_DATA07
LCD_DATA07
LCD_DATA06 (LCD_D6)
LCD_DATA06
LCD_DATA06
LCD_DATA06
LCD_DATA06
LCD_DATA05 (LCD_D5)
LCD_DATA05
LCD_DATA05
LCD_DATA05
LCD_DATA05
LCD_DATA04 (LCD_D4)
LCD_DATA04
LCD_DATA04
LCD_DATA04
LCD_DATA04
LCD_DATA03 (LCD_D3)
LCD_DATA03
LCD_DATA03
LCD_DATA03
LCD_DATA03
LCD_DATA02 (LCD_D2)
LCD_DATA02
LCD_DATA02
LCD_DATA02
LCD_DATA02
LCD_DATA01 (LCD_D1)
LCD_DATA01
LCD_DATA01
LCD_DATA01
LCD_DATA01
LCD_DATA00 (LCD_D0)
LCD_DATA00
LCD_DATA00
LCD_DATA00
LCD_DATA00
LCD_RESET
LCD_RESET
LCD_RESET
LCD_RESET
LCD_RESET
LCD_BUSY /
LCD_VSYNC
LCD_BUSY
(OR optional
LCD_VSYNC)
LCD_BUSY
(OR optional
LCD_VSYNC)
LCD_BUSY
(OR optional
LCD_VSYNC)
LCD_BUSY
(OR optional
LCD_VSYNC)
Table 34-5. Pin use in DOTCLK Mode
PIN NAME
8-bit DOTCLK
LCD IF
16-bit DOTCLK
LCD IF
18-bit DOTCLK
LCD IF
24-bit DOTCLK
LCD IF
LCD_VSYNC
LCD_VSYNC
LCD_VSYNC
LCD_VSYNC
LCD_VSYNC
LCD_HSYNC
LCD_HSYNC
LCD_HSYNC
LCD_HSYNC
LCD_HSYNC
LCD_DOTCLK
LCD_DOTCLK
LCD_DOTCLK
LCD_DOTCLK
LCD_DOTCLK
LCD_ENABLE
LCD_ENABLE
LCD_ENABLE
LCD_ENABLE
LCD_ENABLE
LCD_DATA23
(LCD_D23)
X
X
X
LCD_DATA23
LCD_DATA22
(LCD_D22)
X
X
X
LCD_DATA22
LCD_DATA21
(LCD_D21)
X
X
X
LCD_DATA21
LCD_DATA20
(LCD_D20)
X
X
X
LCD_DATA20
LCD_DATA19
(LCD_D19)
X
X
X
LCD_DATA19
LCD_DATA18
(LCD_D18)
X
X
X
LCD_DATA18
LCD_DATA17
(LCD_D17)
X
X
LCD_DATA17
LCD_DATA17
LCD_DATA16
(LCD_D16)
X
X
LCD_DATA16
LCD_DATA16
LCD_DATA15
(LCD_D15)
X
LCD_DATA15
LCD_DATA15
LCD_DATA15
Table continues on the next page...
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2162
NXP Semiconductors

<!-- page 2163 -->

Table 34-5. Pin use in DOTCLK Mode (continued)
PIN NAME
8-bit DOTCLK
LCD IF
16-bit DOTCLK
LCD IF
18-bit DOTCLK
LCD IF
24-bit DOTCLK
LCD IF
LCD_DATA14
(LCD_D14)
X
LCD_DATA14
LCD_DATA14
LCD_DATA14
LCD_DATA13
(LCD_D13)
X
LCD_DATA13
LCD_DATA13
LCD_DATA13
LCD_DATA12
(LCD_D12)
X
LCD_DATA12
LCD_DATA12
LCD_DATA12
LCD_DATA11
(LCD_D11)
X
LCD_DATA11
LCD_DATA11
LCD_DATA11
LCD_DATA10
(LCD_D10)
X
LCD_DATA10
LCD_DATA10
LCD_DATA10
LCD_DATA09
(LCD_D9)
X
LCD_DATA09
LCD_DATA09
LCD_DATA09
LCD_DATA08
(LCD_D8)
X
LCD_DATA08
LCD_DATA08
LCD_DATA08
LCD_DATA07
(LCD_D7)
LCD_DATA07
LCD_DATA07
LCD_DATA07
LCD_DATA07
LCD_DATA06
(LCD_D6)
LCD_DATA06
LCD_DATA06
LCD_DATA06
LCD_DATA06
LCD_DATA05
(LCD_D5)
LCD_DATA05
LCD_DATA05
LCD_DATA05
LCD_DATA05
LCD_DATA04
(LCD_D4)
LCD_DATA04
LCD_DATA04
LCD_DATA04
LCD_DATA04
LCD_DATA03
(LCD_D3)
LCD_DATA03
LCD_DATA03
LCD_DATA03
LCD_DATA03
LCD_DATA02
(LCD_D2)
LCD_DATA02
LCD_DATA02
LCD_DATA02
LCD_DATA02
LCD_DATA01
(LCD_D1)
LCD_DATA01
LCD_DATA01
LCD_DATA01
LCD_DATA01
LCD_DATA00
(LCD_D0)
LCD_DATA00
LCD_DATA00
LCD_DATA00
LCD_DATA00
LCD_RESET
LCD_RESET
LCD_RESET
LCD_RESET
LCD_RESET
LCD_BUSY /
LCD_VSYNC
LCD_BUSY
(OR optional
LCD_VSYNC)
LCD_BUSY
(OR optional
LCD_VSYNC)
LCD_BUSY
(OR optional
LCD_VSYNC)
LCD_BUSY
(OR optional
LCD_VSYNC)
Table 34-6. Pin use in DVI Mode
PIN NAME
8-bit DVI
LCD IF
LCD_RS
CCIR_CLK
LCD_CS
X
LCD_WR_RWn
X
Table continues on the next page...
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2163

<!-- page 2164 -->

Table 34-6. Pin use in DVI Mode (continued)
PIN NAME
8-bit DVI
LCD IF
LCD_RD_E
X
LCD_VSYNC*
(Two options)
X
LCD_HSYNC
X
LCD_DOTCLK
X
LCD_ENABLE
X
LCD_DATA23 (LCD_D23)
X
LCD_DATA22 (LCD_D22)
X
LCD_DATA21 (LCD_D21)
X
LCD_DATA20 (LCD_D20)
X
LCD_DATA19 (LCD_D19)
X
LCD_DATA18 (LCD_D18)
X
LCD_DATA17 (LCD_D17)
X
LCD_DATA16 (LCD_D16)
X
LCD_DATA15 (LCD_D15) /
VSYNC*
X
LCD_DATA14 (LCD_D14) /
HSYNC**
X
LCD_DATA13 (LCD_D13) /
LCD_DOTCLK**
X
LCD_DATA12 (LCD_D12) / ENABLE**
X
LCD_DATA11 (LCD_D11)
X
LCD_DATA10 (LCD_D10)
X
LCD_DATA09 (LCD_D9)
X
LCD_DATA08 (LCD_D8)
X
LCD_DATA07 (LCD_D7)
LCD_DATA07
LCD_DATA06 (LCD_D6)
LCD_DATA06
LCD_DATA05 (LCD_D5)
LCD_DATA05
LCD_DATA04 (LCD_D4)
LCD_DATA04
LCD_DATA03 (LCD_D3)
LCD_DATA03
LCD_DATA02 (LCD_D2)
LCD_DATA02
LCD_DATA01 (LCD_D1)
LCD_DATA01
LCD_DATA00 (LCD_D0)
LCD_DATA00
LCD_RESET
X
LCD_BUSY /
LCD_VSYNC
X
Functional Description
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2164
NXP Semiconductors

<!-- page 2165 -->

34.5
Behavior During Reset
BUS CLOCK (apb_clk) and DISPLAY CLOCK (pix_clk) must be running before
making any changes to SFTRST or CLKGATE bits.
A soft reset (SFTRST) can take multiple clock periods to complete, so do not set
CLKGATE when setting SFTRST.
The reset process gates the clocks automatically.
34.6
eLCDIF Memory Map/Register Definition
Some of the LCDIF registers (XXX_SET, XXX_CLR, and XXX_TOG) allow direct bit
field masking and access.
• When writing 1 to XXX_SET bit fields, these registers allow setting the masked 1 bit
fields, while keeping unchanged all bit fields which remain on 0 logic state.
• When writing 1 to XXX_CLR bit fields, these registers allow clearing the masked 1
bit fields, while keeping unchanged all other bit fields which remained on 0 logic
state.
• When writing 1 to XXX_TOG bit fields, these registers allow inverting the logic
state of all masked 1 bit fields, while they keep unchanged the remaining bit fields
which were kept on 0 logic state.
eLCDIF Hardware Register Format Summary
LCDIF memory map
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
21C_8000
eLCDIF General Control Register (LCDIF_CTRL)
32
R/W
C000_0000h
34.6.1/2168
21C_8004
eLCDIF General Control Register (LCDIF_CTRL_SET)
32
R/W
C000_0000h
34.6.1/2168
21C_8008
eLCDIF General Control Register (LCDIF_CTRL_CLR)
32
R/W
C000_0000h
34.6.1/2168
21C_800C
eLCDIF General Control Register (LCDIF_CTRL_TOG)
32
R/W
C000_0000h
34.6.1/2168
21C_8010
eLCDIF General Control1 Register (LCDIF_CTRL1)
32
R/W
000F_0000h
34.6.2/2171
21C_8014
eLCDIF General Control1 Register (LCDIF_CTRL1_SET)
32
R/W
000F_0000h
34.6.2/2171
21C_8018
eLCDIF General Control1 Register (LCDIF_CTRL1_CLR)
32
R/W
000F_0000h
34.6.2/2171
21C_801C
eLCDIF General Control1 Register (LCDIF_CTRL1_TOG)
32
R/W
000F_0000h
34.6.2/2171
Table continues on the next page...
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2165

<!-- page 2166 -->

LCDIF memory map (continued)
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
21C_8020
eLCDIF General Control2 Register (LCDIF_CTRL2)
32
R/W
0020_0000h
34.6.3/2173
21C_8024
eLCDIF General Control2 Register (LCDIF_CTRL2_SET)
32
R/W
0020_0000h
34.6.3/2173
21C_8028
eLCDIF General Control2 Register (LCDIF_CTRL2_CLR)
32
R/W
0020_0000h
34.6.3/2173
21C_802C
eLCDIF General Control2 Register (LCDIF_CTRL2_TOG)
32
R/W
0020_0000h
34.6.3/2173
21C_8030
eLCDIF Horizontal and Vertical Valid Data Count Register
(LCDIF_TRANSFER_COUNT)
32
R/W
0001_0000h
34.6.4/2176
21C_8040
LCD Interface Current Buffer Address Register
(LCDIF_CUR_BUF)
32
R/W
0000_0000h
34.6.5/2176
21C_8050
LCD Interface Next Buffer Address Register
(LCDIF_NEXT_BUF)
32
R/W
0000_0000h
34.6.6/2177
21C_8060
LCD Interface Timing Register (LCDIF_TIMING)
32
R/W
0000_0000h
34.6.7/2177
21C_8070
eLCDIF VSYNC Mode and Dotclk Mode Control Register0
(LCDIF_VDCTRL0)
32
R/W
0000_0000h
34.6.8/2178
21C_8074
eLCDIF VSYNC Mode and Dotclk Mode Control Register0
(LCDIF_VDCTRL0_SET)
32
R/W
0000_0000h
34.6.8/2178
21C_8078
eLCDIF VSYNC Mode and Dotclk Mode Control Register0
(LCDIF_VDCTRL0_CLR)
32
R/W
0000_0000h
34.6.8/2178
21C_807C
eLCDIF VSYNC Mode and Dotclk Mode Control Register0
(LCDIF_VDCTRL0_TOG)
32
R/W
0000_0000h
34.6.8/2178
21C_8080
eLCDIF VSYNC Mode and Dotclk Mode Control Register1
(LCDIF_VDCTRL1)
32
R/W
0000_0000h
34.6.9/2180
21C_8090
LCDIF VSYNC Mode and Dotclk Mode Control Register2
(LCDIF_VDCTRL2)
32
R/W
0000_0000h
34.6.10/
2180
21C_80A0
eLCDIF VSYNC Mode and Dotclk Mode Control Register3
(LCDIF_VDCTRL3)
32
R/W
0000_0000h
34.6.11/
2181
21C_80B0
eLCDIF VSYNC Mode and Dotclk Mode Control Register4
(LCDIF_VDCTRL4)
32
R/W
0000_0000h
34.6.12/
2182
21C_80C0
Digital Video Interface Control0 Register
(LCDIF_DVICTRL0)
32
R/W
0000_0000h
34.6.13/
2183
21C_80D0
Digital Video Interface Control1 Register
(LCDIF_DVICTRL1)
32
R/W
0000_0000h
34.6.14/
2183
21C_80E0
Digital Video Interface Control2 Register
(LCDIF_DVICTRL2)
32
R/W
0000_0000h
34.6.15/
2184
21C_80F0
Digital Video Interface Control3 Register
(LCDIF_DVICTRL3)
32
R/W
0000_0000h
34.6.16/
2185
21C_8100
Digital Video Interface Control4 Register
(LCDIF_DVICTRL4)
32
R/W
0000_0000h
34.6.17/
2186
21C_8110
RGB to YCbCr 4:2:2 CSC Coefficient0 Register
(LCDIF_CSC_COEFF0)
32
R/W
0000_0000h
34.6.18/
2187
21C_8120
RGB to YCbCr 4:2:2 CSC Coefficient1 Register
(LCDIF_CSC_COEFF1)
32
R/W
0000_0000h
34.6.19/
2188
21C_8130
RGB to YCbCr 4:2:2 CSC Coefficent2 Register
(LCDIF_CSC_COEFF2)
32
R/W
0000_0000h
34.6.20/
2189
Table continues on the next page...
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2166
NXP Semiconductors

<!-- page 2167 -->

LCDIF memory map (continued)
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
21C_8140
RGB to YCbCr 4:2:2 CSC Coefficient3 Register
(LCDIF_CSC_COEFF3)
32
R/W
0000_0000h
34.6.21/
2189
21C_8150
RGB to YCbCr 4:2:2 CSC Coefficient4 Register
(LCDIF_CSC_COEFF4)
32
R/W
0000_0000h
34.6.22/
2190
21C_8160
RGB to YCbCr 4:2:2 CSC Offset Register
(LCDIF_CSC_OFFSET)
32
R/W
0080_0010h
34.6.23/
2191
21C_8170
RGB to YCbCr 4:2:2 CSC Limit Register
(LCDIF_CSC_LIMIT)
32
R/W
00FF_00FFh
34.6.24/
2191
21C_8180
LCD Interface Data Register (LCDIF_DATA)
32
R/W
0000_0000h
34.6.25/
2192
21C_8190
Bus Master Error Status Register
(LCDIF_BM_ERROR_STAT)
32
R/W
0000_0000h
34.6.26/
2193
21C_81A0
CRC Status Register (LCDIF_CRC_STAT)
32
R/W
0000_0000h
34.6.27/
2193
21C_81B0
LCD Interface Status Register (LCDIF_STAT)
32
R
9500_0000h
34.6.28/
2194
21C_8200
eLCDIF Threshold Register (LCDIF_THRES)
32
R/W
0100_000Fh
34.6.29/
2196
21C_8210
eLCDIF AS Buffer Control Register (LCDIF_AS_CTRL)
32
R/W
0000_0000h
34.6.30/
2197
21C_8220
Alpha Surface Buffer Pointer (LCDIF_AS_BUF)
32
R/W
0000_0000h
34.6.31/
2199
21C_8230
LCDIF_AS_NEXT_BUF
32
R/W
0000_0000h
34.6.32/
2200
21C_8240
eLCDIF Overlay Color Key Low (LCDIF_AS_CLRKEYLOW)
32
R/W
00FF_FFFFh
34.6.33/
2200
21C_8250
eLCDIF Overlay Color Key High
(LCDIF_AS_CLRKEYHIGH)
32
R/W
0000_0000h
34.6.34/
2201
21C_8260
LCD working insync mode with CSI for VSYNC delay
(LCDIF_SYNC_DELAY)
32
R/W
0000_0000h
34.6.35/
2201
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2167

<!-- page 2168 -->

34.6.1
eLCDIF General Control Register (LCDIF_CTRLn)
The LCD Interface Control Register provides overall control of the eLCDIF block. The
eLCDIF Control Register provides a variety of control functions to the programmer.
These functions allow the interface to be very flexible to work with a variety of LCD
controllers, and to minimize overhead and increase performance of LCD programming.
The register has been organized such that switching between the different LCD modes
can be done with minimum PIO writes.
Address: 21C_8000h base + 0h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
SFTRST
CLKGATE
YCBCR422_INPUT
READ_WRITEB
WAIT_FOR_VSYNC_
EDGE
DATA_SHIFT_DIR
SHIFT_NUM_BITS
DVI_MODE
BYPASS_COUNT
VSYNC_MODE
DOTCLK_MODE
DATA_SELECT
W
Reset
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
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
INPUT_
DATA_
SWIZZLE
CSC_DATA_SWIZZLE
LCD_
DATABUS_
WIDTH
WORD_
LENGTH
RGB_TO_YCBCR422_
CSC
ENABLE_PXP_
HANDSHAKE
MASTER
Reserved
DATA_FORMAT_16_BIT
DATA_FORMAT_18_BIT
DATA_FORMAT_24_BIT
RUN
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_CTRLn field descriptions
Field
Description
31
SFTRST
This bit must be set to zero to enable normal operation of the eLCDIF. When set to one, it forces a block
level reset.
30
CLKGATE
This bit must be set to zero for normal operation. When set to one it gates off the clocks to the block.
29
YCBCR422_
INPUT
Zero implies input data is in RGB color space. One implies input data is in YCbCr 4:2:2 format, such that
YCbYCr are packed in a 32-bit word. It also means that there are 2 pixels in 4 bytes. If this bit is set,
software should program the H_COUNT field in the TRANSFER_COUNT register to the total number of
pixels that will have to be fetched by the eLCDIF block per line and the BYTE_PACKING_FORMAT
should be 0xF. The WORD_LENGTH does not matter in this case.
Table continues on the next page...
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2168
NXP Semiconductors

<!-- page 2169 -->

LCDIF_CTRLn field descriptions (continued)
Field
Description
28
READ_WRITEB
By default, eLCDIF is in the write mode. Setting this bit to 1 will make the hardware go into 6800/8080
MPU read mode. The LCDIF_MASTER bit must be 0, since bus master mode can only be used for writing
the display.
27
WAIT_FOR_
VSYNC_EDGE
Setting this bit to 1 will make the hardware wait for the triggering VSYNC edge before starting write
transfers to the LCD. Used only in the VSYNC mode of operation.
26
DATA_SHIFT_
DIR
Use this bit to determine the direction of shift of transmit data. In the DVI mode, it works only on the active
data, not on the timing codes and ancillary data.
0x0
TXDATA_SHIFT_LEFT — Data to be transmitted is shifted LEFT by SHIFT_NUM_BITS bits.
0x1
TXDATA_SHIFT_RIGHT — Data to be transmitted is shifted RIGHT by SHIFT_NUM_BITS bits.
25–21
SHIFT_NUM_
BITS
The data to be transmitted is shifted left or right by this number of bits.
20
DVI_MODE
Set this bit to 1 to get into the ITU-R BT.656 digital video interface mode. Toggle this bit from 1 to 0 to
make the hardware go out of DVI mode after completing all data transfer and after the RUN bit has been
deasserted.
19
BYPASS_
COUNT
When this bit is 0, it means that eLCDIF will stop the block operation and turn off the RUN bit after the
amount of data indicated by the LCDIF_TRANSFER_COUNT register has been transferred out. When this
bit is set to 1, the block will continue normal operation indefinitely until it is told to stop. This bit must be 0
in MPU and VSYNC modes, and must be 1 in DOTCLK and DVI modes of operation.
18
VSYNC_MODE
Setting this bit to 1 will make the eLCDIF hardware go into VSYNC mode. WAIT_FOR_VSYNC_EDGE
can be used only if this bit is set. If VSYNC signal is required to be an output from the block,
SYNC_SIGNALS_ON bit in LCDIF_VDCTRL4 register must be set.
17
DOTCLK_MODE
Set this bit to 1 to make the hardware go into the DOTCLK mode, i.e. VSYNC/HSYNC/DOTCLK/ENABLE
interface mode. ENABLE is optional, selected by the ENABLE_PRESENT bit. Toggle this bit from 1 to 0 to
make the hardware go out of DOTCLK mode after completing all data transfer and deasserting the RUN
bit.
16
DATA_SELECT
Command Mode polarity bit. This bit should only be changed when RUN is 0.
0x0
CMD_MODE — Command Mode. LCD_RS signal is Low.
0x1
DATA_MODE — Data Mode. LCD_RS signal is High.
15–14
INPUT_DATA_
SWIZZLE
This field specifies how to swap the bytes fetched by the bus master interface. The swizzle function is
independent of the WORD_LENGTH bit. The supported swizzle configurations are:
0x0
NO_SWAP — No byte swapping.(Little endian)
0x0
LITTLE_ENDIAN — Little Endian byte ordering (same as NO_SWAP).
0x1
BIG_ENDIAN_SWAP — Big Endian swap (swap bytes 0,3 and 1,2).
0x1
SWAP_ALL_BYTES — Swizzle all bytes, swap bytes 0,3 and 1,2 (aka Big Endian).
0x2
HWD_SWAP — Swap half-words.
0x3
HWD_BYTE_SWAP — Swap bytes within each half-word.
13–12
CSC_DATA_
SWIZZLE
This field specifies how to swap the bytes after the data has been converted into an internal representation
of 24 bits per pixel and before it is transmitted over the LCD interface bus. The data is always transmitted
with the least significant byte/hword (half word) first after the swizzle takes place. So,
INPUT_DATA_SWIZZLE takes place first on the incoming data, and then CSC_DATA_SWIZZLE is
applied. The swizzle function is independent of the WORD_LENGTH or the LCD_DATABUS_WIDTH
fields. If RGB_TO_YCRCB422_CSC bit is set, the swizzle occurs on the Y, Cb, Cr values. The supported
swizzle configurations are:
0x0
NO_SWAP — No byte swapping.(Little endian)
Table continues on the next page...
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2169

<!-- page 2170 -->

LCDIF_CTRLn field descriptions (continued)
Field
Description
0x0
LITTLE_ENDIAN — Little Endian byte ordering (same as NO_SWAP).
0x1
BIG_ENDIAN_SWAP — Big Endian swap (swap bytes 0,3 and 1,2).
0x1
SWAP_ALL_BYTES — Swizzle all bytes, swap bytes 0,3 and 1,2 (aka Big Endian).
0x2
HWD_SWAP — Swap half-words.
0x3
HWD_BYTE_SWAP — Swap bytes within each half-word.
11–10
LCD_DATABUS_
WIDTH
LCD Data bus transfer width.
0x0
16_BIT — 16-bit data bus mode.
0x1
8_BIT — 8-bit data bus mode.
0x2
18_BIT — 18-bit data bus mode.
0x3
24_BIT — 24-bit data bus mode.
9–8
WORD_LENGTH
Input data format.
0x0
16_BIT — Input data is 16 bits per pixel.
0x1
8_BIT — Input data is 8 bits wide.
0x2
18_BIT — Input data is 18 bits per pixel.
0x3
24_BIT — Input data is 24 bits per pixel.
7
RGB_TO_
YCBCR422_CSC
Set this bit to 1 to enable conversion from RGB to YCbCr colorspace. See the LCDIF_CSC_ registers for
further details.
6
ENABLE_PXP_
HANDSHAKE
If this bit is set and LCDIF_MASTER bit is set, the eLCDIF will act as bus master and the handshake
mechanism between eLCDIF and PXP will be turned on. If LCDIF_MASTER bit is not set, this bit becomes
a don't care.
5
MASTER
Set this bit to make the eLCDIF act as a bus master.
4
RSRVD0
This field is reserved.
Reserved bits. Write as 0.
3
DATA_
FORMAT_16_
BIT
When this bit is 1 and WORD_LENGTH = 0, it implies that the 16-bit data is in ARGB555 format. When
this bit is 0 and WORD_LENGTH = 0, it implies that the 16-bit data is in RGB565 format. When
WORD_LENGTH is not 0, this bit does not care.
2
DATA_
FORMAT_18_
BIT
Used only when WORD_LENGTH = 2, i.e. 18-bit.
0x0
LOWER_18_BITS_VALID — Data input to the block is in 18 bpp format, such that lower 18 bits
contain RGB 666 and upper 14 bits do not contain any useful data.
0x1
UPPER_18_BITS_VALID — Data input to the block is in 18 bpp format, such that upper 18 bits
contain RGB 666 and lower 14 bits do not contain any useful data.
1
DATA_
FORMAT_24_
BIT
Used only when WORD_LENGTH = 3, i.e. 24-bit. Note that this applies to both packed and unpacked 24-
bit data.
0x0
ALL_24_BITS_VALID — Data input to the block is in 24 bpp format, such that all RGB 888 data is
contained in 24 bits.
0x1
DROP_UPPER_2_BITS_PER_BYTE — Data input to the block is actually RGB 18 bpp, but there is
1 color per byte, hence the upper 2 bits in each byte do not contain any useful data, and should be
dropped.
0
RUN
When this bit is set by software, the eLCDIF will begin transferring data between the SoC and the display.
This bit must remain set until the operation is complete.
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2170
NXP Semiconductors

<!-- page 2171 -->

34.6.2
eLCDIF General Control1 Register (LCDIF_CTRL1n)
The eLCDIF Control Register provides overall control of the eLCDIF block.
The eLCDIF Control1 Register provides additional programming to the eLCDIF. It
implements some bits which are unlikely to change often in a particular application. It
also carries interrupt-related bits which are common across more than one mode of
operation.
Address: 21C_8000h base + 10h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
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
Reserved
COMBINE_MPU_WR_
STRB
BM_ERROR_IRQ_EN
BM_ERROR_IRQ
RECOVER_ON_
UNDERFLOW
INTERLACE_FIELDS
START_INTERLACE_
FROM_SECOND_FIELD
FIFO_CLEAR
IRQ_ON_ALTERNATE_
FIELDS
BYTE_PACKING_
FORMAT
W
Reset
0
0
0
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
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
OVERFLOW_IRQ_EN
UNDERFLOW_IRQ_EN
CUR_FRAME_DONE_
IRQ_EN
VSYNC_EDGE_IRQ_EN
OVERFLOW_IRQ
UNDERFLOW_IRQ
CUR_FRAME_DONE_
IRQ
VSYNC_EDGE_IRQ
Reserved
BUSY_ENABLE
MODE86
RESET
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_CTRL1n field descriptions
Field
Description
31
-
This field is reserved.
Reserved bits. Write as 0.
30
-
This field is reserved.
Reserved bits. Write as 0.
29–28
-
This field is reserved.
Reserved bits. Write as 0.
27
COMBINE_
MPU_WR_STRB
If this bit is not set, the write strobe will be driven on LCD_WR_RWn pin in the 8080 mode and on the
LCD_RD_E pin in the 6800 mode. If it is set, the write strobe of both the 6800 and 8080 modes will be
driven only on the LCD_WR_RWn pin. Note that this does not work for read strobe.
Table continues on the next page...
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2171

<!-- page 2172 -->

LCDIF_CTRL1n field descriptions (continued)
Field
Description
26
BM_ERROR_
IRQ_EN
This bit is set to enable bus master error interrupt in the eLCDIF master mode.
25
BM_ERROR_
IRQ
This bit is set to indicate that an interrupt is requested by the eLCDIF block. This bit is cleared by software
by writing a one to its SCT clear address. This bit will be set when the eLCDIF is in master mode and an
error response was returned by the slave.
0x0
NO_REQUEST — No Interrupt Request Pending.
0x1
REQUEST — Interrupt Request Pending.
24
RECOVER_ON_
UNDERFLOW
Set this bit to enable the eLCDIF block to recover in the next field/frame if there was an underflow in the
current field/frame.
23
INTERLACE_
FIELDS
Set this bit if it is required that the eLCDIF block fetches odd lines in one field and even lines in the other
field. It will work only in LCDIF_MASTER is set to 1.
22
START_
INTERLACE_
FROM_
SECOND_FIELD
The default is to grab the odd lines first and then the even lines. Set this bit if it is required to grab the even
lines first and then the odd lines. (Line numbers start from 1, so odd lines are 1,3,5,etc. and even lines are
2,4,6, etc.)
21
FIFO_CLEAR
Set this bit to clear all the data in the latency FIFO (LFIFO), TXFIFO and the RXFIFO.
20
IRQ_ON_
ALTERNATE_
FIELDS
If this bit is set, the eLCDIF block will assert the cur_frame_done interrupt only on alternate fields,
otherwise it will issue the interrupt on both odd and even field. This bit is mostly relevant if
INTERLACE_FIELDS is set.
19–16
BYTE_
PACKING_
FORMAT
This bitfield is used to show which data bytes in a 32-bit word are valid. Default value 0xf indicates that all
bytes are valid. For 8-bit transfers, any combination in this bitfield will mean valid data is present in the
corresponding bytes. In the 16-bit mode, a 16-bit half-word is valid only if adjacent bits [1:0] or [3:2] or both
are 1. A value of 0x0 will mean that none of the bytes are valid and should not be used. For example, set
the bit field value to 0x7 if the display data is arranged in the 24-bit unpacked format (A-R-G-B where A
value does not have be transmitted). When input data is in YCbCr 4:2:2 format (YCBCR422_INPUT is 1),
H_COUNT should be the number of pixels that should be fetched by the block and the
BYTE_PACKING_FORMAT should be 0xF.(Note - YCBCR422_INPUT = 1 implies 2 pixels per 32 bits).
15
OVERFLOW_
IRQ_EN
This bit is set to enable an overflow interrupt in the TXFIFO in the write mode.
14
UNDERFLOW_
IRQ_EN
This bit is set to enable an underflow interrupt in the TXFIFO in the write mode.
13
CUR_FRAME_
DONE_IRQ_EN
This bit is set to 1 enable an interrupt every time the hardware enters in the vertical blanking state.
12
VSYNC_EDGE_
IRQ_EN
This bit is set to enable an interrupt every time the hardware encounters the leading VSYNC edge in the
VSYNC and DOTCLK modes, or the beginning of every field in DVI mode.
11
OVERFLOW_
IRQ
This bit is set to indicate that an interrupt is requested by the eLCDIF block. This bit is cleared by software
by writing a one to its SCT clear address. A latency FIFO (LFIFO) overflow in the write mode (MPU/
VSYNC/DOTCLK/DVI mode) was detected, data samples have been lost.
Table continues on the next page...
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2172
NXP Semiconductors

<!-- page 2173 -->

LCDIF_CTRL1n field descriptions (continued)
Field
Description
0x0
NO_REQUEST — No Interrupt Request Pending.
0x1
REQUEST — Interrupt Request Pending.
10
UNDERFLOW_
IRQ
This bit is set to indicate that an interrupt is requested by the eLCDIF block. This bit is cleared by software
by writing a one to its SCT clear address. A TXFIFO underflow in the write mode (MPU/VSYNC/
DOTCLK/DVI mode) was detected. Could produce an error in the DOTCLK / DVI modes.
0x0
NO_REQUEST — No Interrupt Request Pending.
0x1
REQUEST — Interrupt Request Pending.
9
CUR_FRAME_
DONE_IRQ
This bit is set to indicate that an interrupt is requested by the eLCDIF block. This bit is cleared by software
by writing a one to its SCT clear address. It indicates that the hardware has completed transmitting the
current frame and is in the vertical blanking period in the DOTCLK/DVI modes. In the MPU and VSYNC
modes, this IRQ is asserted at the end of the data transfer indicated by LCDIF_TRANSFER_COUNT
register.
0x0
NO_REQUEST — No Interrupt Request Pending.
0x1
REQUEST — Interrupt Request Pending.
8
VSYNC_EDGE_
IRQ
This bit is set to indicate that an interrupt is requested by the eLCDIF block. This bit is cleared by software
by writing a one to its SCT clear address. It is set whenever the leading VSYNC edge is detected in the
VSYNC and DOTCLK modes. In the DVI mode, it is asserted every time the block enters a new field.
0x0
NO_REQUEST — No Interrupt Request Pending.
0x1
REQUEST — Interrupt Request Pending.
7–3
RSRVD0
This field is reserved.
Reserved bits. Write as 0.
2
BUSY_ENABLE
This bit enables the use of the interface's busy signal input. This should be enabled for LCD controllers
that implement a busy line (to stall the eLCDIF from sending more data until ready). Otherwise this bit
should be cleared.
0x0
BUSY_DISABLED — The busy signal from the LCD controller will be ignored.
0x1
BUSY_ENABLED — Enable the use of the busy signal from the LCD controller.
1
MODE86
This bit is used to select between the 8080 and 6800 series of microprocessor modes. This bit should only
be changed when RUN is 0.
0x0
8080_MODE — Pins LCD_WR_RWn and LCD_RD_E function as active low WR and active low RD
signals respectively.
0x1
6800_MODE — Pins LCD_WR_RWn and LCD_RD_E function as Read/Write and active high
Enable signals respectively.
0
RESET
Reset bit for the external LCD controller. This bit can be changed at any time. It CANNOT be reset by
SFTRST.
0x0
LCDRESET_LOW — LCD_RESET output signal is low.
0x1
LCDRESET_HIGH — LCD_RESET output signal is high.
34.6.3
eLCDIF General Control2 Register (LCDIF_CTRL2n)
The eLCDIF Control Register provides overall control of the eLCDIF block.
The eLCDIF Control2 Register provides additional programming to the eLCDIF. It
implements some bits which are unlikely to change often in a particular application.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2173

<!-- page 2174 -->

Address: 21C_8000h base + 20h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
OUTSTANDING_
REQS
BURST_LEN_8
Reserved
ODD_LINE_
PATTERN
W
Reset
0
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
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
EVEN_LINE_
PATTERN
Reserved
READ_PACK_DIR
READ_MODE_OUTPUT_
IN_RGB_FORMAT
READ_MODE_6_BIT_
INPUT
Reserved
READ_MODE_
NUM_PACKED_
SUBWORDS
INITIAL_DUMMY_
READ
Reserved
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_CTRL2n field descriptions
Field
Description
31–24
RSRVD5
This field is reserved.
Reserved bits. Write as 0.
23–21
OUTSTANDING_
REQS
This bitfield indicates the maximum number of outstanding transactions that eLCDIF should request
when it is acting as a bus master. Default is 2 outstanding transactions.
0x0
REQ_1 —
0x1
REQ_2 —
0x2
REQ_4 —
0x3
REQ_8 —
0x4
REQ_16 —
20
BURST_LEN_8
By default, when the eLCDIF is in the bus master mode, it will issue AXI bursts of length 16 (except
when in packed 24 bpp mode, it will issue bursts of length 15). When this bit is set to 1, the block will
issue bursts of length 8 (except when in packed 24 bpp mode, it will issue bursts of length 9). Note that
this bitfield is only applicable when LCDIF_MASTER is set to 1.
19
RSRVD4
This field is reserved.
Reserved bits. Write as 0.
18–16
ODD_LINE_
PATTERN
This field determines the order of the RGB components of each pixel in ODD lines (line numbers
1,3,5,..). This bitfield must be 0 in DVI mode.
0x0
RGB —
0x1
RBG —
0x2
GBR —
0x3
GRB —
Table continues on the next page...
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2174
NXP Semiconductors

<!-- page 2175 -->

LCDIF_CTRL2n field descriptions (continued)
Field
Description
0x4
BRG —
0x5
BGR —
15
RSRVD3
This field is reserved.
Reserved bits. Write as 0.
14–12
EVEN_LINE_
PATTERN
This field determines the order of the RGB components of each pixel in EVEN lines (line numbers
2,4,6,..). This bitfield must be 0 in DVI mode.
0x0
RGB —
0x1
RBG —
0x2
GBR —
0x3
GRB —
0x4
BRG —
0x5
BGR —
11
RSRVD2
This field is reserved.
Reserved bits. Write as 0.
10
READ_PACK_DIR
The default value of 0 indicates data is stored in the little endian format. When LCD_DATABUS_WIDTH
is 8-bit, this bit provides the option of rearranging the data byte-wise in the big endian format. For
example, if READ_MODE_NUM_PACKED_SUBWORDS = 3 and the order of incoming data is 0x11,
0x22 and 0x33, then setting this bit to 1 will cause the data to be stored as 0x00112233 as opposed to
the default 0x00332211. This operation occurs after the shifting operation done by SHIFT_NUM_BITS
bitfield.
9
READ_MODE_
OUTPUT_IN_
RGB_FORMAT
Setting this bit will enable the eLCDIF to convert the incoming data to the RGB format given by
WORD_LENGTH bitfield. This feature is not available when WORD_LENGTH is set to 8 bits. eLCDIF
performs this operation of converting to RGB format after the endianness has been determined by the
READ_PACK_DIR bitfield.
8
READ_MODE_6_
BIT_INPUT
Setting this bit to 1 indicates to eLCDIF that even though LCD_DATABUS_WIDTH is set to 8 bits, the
input data is actually only 6 bits wide and exists on D5-D0.
7
RSRVD1
This field is reserved.
Reserved bits. Write as 0.
6–4
READ_MODE_
NUM_PACKED_
SUBWORDS
Indicates the number of valid 8/16/18/24-bit subwords that will be packed into the 32-bit word in read
mode. The subword size (8,16, 18 or 24 bits) is determined by the LCD_DATABUS_WIDTH field. The
swizzle operation is performed after READ_MODE_NUM_PACKED_SUBWORDS number of subwords
has been received and stored in little-endian format. For example, if LCD_DATABUS_WIDTH is set to 8-
bit and data to be read back has to be stored in memory in 24-bit unpacked RGB format, set
READ_MODE_NUM_PACKED_SUBWORDS to 0x3 so that each 32-bit word will contain only 3 valid
bytes (RGB). Maximum value of READ_MODE_NUM_PACKED_SUBWORDS is 4 for 8-bit databus, 2
for 16-bit databus and 1 for 18/24-bit databus.
3–1
INITIAL_DUMMY_
READ
The value in this field determines the number of dummy 8/16/18/24-bit subwords that have to be read
back from the LCD panel/controller. They will then not be stored in the read FIFO.
0
RSRVD0
This field is reserved.
Reserved bits. Write as 0.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2175

<!-- page 2176 -->

34.6.4
eLCDIF Horizontal and Vertical Valid Data Count Register
(LCDIF_TRANSFER_COUNT)
This register tells the eLCDIF how much data will be sent for this frame, or transaction.
The total number of words is a product of the V_COUNT and H_COUNT fields. The
word size is specified by the WORD_LENGTH field.
This register gives the dimensions of the input frame. For normal operation, but
V_COUNT and H_COUNT should be non-zero.
Address: 21C_8000h base + 30h offset = 21C_8030h
Bit
31
30
29
28
27
26
25
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
V_COUNT
H_COUNT
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
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_TRANSFER_COUNT field descriptions
Field
Description
31–16
V_COUNT
Number of horizontal lines per frame which contain valid data. In DOTCLK mode, V_COUNT should be
the same as the number of active horizontal lines in a progressive frame. In DVI mode, V_COUNT should
be the number of active horizontal lines per frame, and not per field.
H_COUNT
Total valid data (pixels) in each horizontal line. The data size is given by the WORD_LENGTH. When
input data is in YCbCr 4:2:2 format (YCBCR422_INPUT is 1), H_COUNT should be the number of 32-bit
words that should be fetched by the block and the BYTE_PACKING_FORMAT should be 0xF. In 24-bit
packed format (WORD_LENGTH=0x3, BYTE_PACKING_FORMAT=0xF), the H_COUNT must be a
multiple of 4 pixels. In 16-bit packed format (WORD_LENGTH=0x0, BYTE_PACKING_FORMAT=0xF),
the H_COUNT must be a multiple of 2 pixels.
34.6.5
LCD Interface Current Buffer Address Register
(LCDIF_CUR_BUF)
This register indicates the address of the current frame being transmitted by eLCDIF.
When the eLCDIF is behaving as a master, this address points to the address of the
current frame of data being sent out via the LCDIF. When the current frame is done, the
LCDIF block will assert the cur_frame_done interrupt for software to take action. The
block will also copy the LCDIF_NEXT_BUF_ADDR into this bitfield so that the
software can program the next frame address into the LCDIF_NEXT_BUF_ADDR
bitfield. This address must always be double-word aligned.
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2176
NXP Semiconductors

<!-- page 2177 -->

Address: 21C_8000h base + 40h offset = 21C_8040h
Bit
31
30
29
28
27
26
25
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
ADDR
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
LCDIF_CUR_BUF field descriptions
Field
Description
ADDR
Address of the current frame being transmitted by eLCDIF.
34.6.6
LCD Interface Next Buffer Address Register
(LCDIF_NEXT_BUF)
This register indicates the address of next frame that will be transmitted by eLCDIF.
When the eLCDIF is behaving as a master, this address points to the address of the next
frame of data that will be sent out via the eLCDIF. It is up to the software to make sure
that this register is programmed before the end of the current frame, otherwise it might
result in old data going out the eLCDIF. This address must always be double-word
aligned.
Address: 21C_8000h base + 50h offset = 21C_8050h
Bit
31
30
29
28
27
26
25
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
ADDR
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
LCDIF_NEXT_BUF field descriptions
Field
Description
ADDR
Address of the next frame that will be transmitted by eLCDIF.
34.6.7
LCD Interface Timing Register (LCDIF_TIMING)
The LCD interface timing register controls the various setup and hold times enforced by
the LCD interface in the 6800/8080 MPU and VSYNC modes of operation.
The values used in this register are dependent on the particular LCD controller used,
consult the users manual for the particular controller for required timings. Each field of
the register must be non-zero, therefore the minimum value is: 0x01010101. NOTE: the
timings are not automatically adjusted if the DISPLAY CLOCK (pix_clk) frequency
changes—it may be necessary to adjust the timings if DISPLAY CLOCK (pix_clk)
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2177

<!-- page 2178 -->

changes. NOTE: Each field in this register must be non-zero for the MPU and VSYNC
modes to function. The settings in this register do not affect the DOTCLK and DVI
modes.
Address: 21C_8000h base + 60h offset = 21C_8060h
Bit
31
30
29
28
27
26
25
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
CMD_HOLD
CMD_SETUP
DATA_HOLD
DATA_SETUP
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
LCDIF_TIMING field descriptions
Field
Description
31–24
CMD_HOLD
Number of DISPLAY CLOCK (pix_clk) cycles that the LCD_RS signal is active after LCD_CS is
deasserted.
23–16
CMD_SETUP
Number of DISPLAY CLOCK (pix_clk) cycles that the LCD_RS signal is active before LCD_CS is
asserted.
15–8
DATA_HOLD
Data bus hold time in DISPLAY CLOCK (pix_clk) cycles. Also the time that the data strobe is deasserted
in a cycle
DATA_SETUP
Data bus setup time in DISPLAY CLOCK (pix_clk) cycles. Also the time that the data strobe is asserted in
a cycle.
34.6.8
eLCDIF VSYNC Mode and Dotclk Mode Control Register0
(LCDIF_VDCTRL0n)
This register is used to control the VSYNC and DOTCLK modes of the LCDIF so as to
work with different types of LCDs like moving picture displays and delta pixel displays.
This register gives general programmability to the VSYNC signal including polarity,
direction, pulse width, etc.
Address: 21C_8000h base + 70h offset + (4d × i), where i=0d to 3d
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
VSYNC_OEB
ENABLE_PRESENT
VSYNC_POL
HSYNC_POL
DOTCLK_POL
ENABLE_POL
Reserved
VSYNC_PERIOD_
UNIT
VSYNC_PULSE_
WIDTH_UNIT
HALF_LINE
HALF_LINE_MODE
VSYNC_
PULSE_
WIDTH
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2178
NXP Semiconductors

<!-- page 2179 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
VSYNC_PULSE_WIDTH
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_VDCTRL0n field descriptions
Field
Description
31–30
RSRVD2
This field is reserved.
Reserved bits. Write as 0.
29
VSYNC_OEB
0 means the VSYNC signal is an output, 1 means it is an input. Should be set to 0 in the DOTCLK mode.
0x0
VSYNC_OUTPUT — The VSYNC pin is in the output mode and the VSYNC signal has to be
generated by the eLCDIF block.
0x1
VSYNC_INPUT — The VSYNC pin is in the input mode and the LCD controller sends the VSYNC
signal to the block.
28
ENABLE_
PRESENT
Setting this bit to 1 will make the hardware generate the ENABLE signal in the DOTCLK mode, thereby
making it the true RGB interface along with the remaining three signals VSYNC, HSYNC and DOTCLK.
27
VSYNC_POL
Default 0 active low during VSYNC_PULSE_WIDTH time and will be high during the rest of the VSYNC
period. Set it to 1 to invert the polarity.
26
HSYNC_POL
Default 0 active low during HSYNC_PULSE_WIDTH time and will be high during the rest of the HSYNC
period. Set it to 1 to invert the polarity.
25
DOTCLK_POL
Default is data launched at negative edge of DOTCLK and captured at positive edge. Set it to 1 to invert
the polarity. Set it to 0 in DVI mode.
24
ENABLE_POL
Default 0 active low during valid data transfer on each horizontal line.
23–22
RSRVD1
This field is reserved.
Reserved bits. Write as 0.
21
VSYNC_
PERIOD_UNIT
Default 0 for counting VSYNC_PERIOD in terms of DISPLAY CLOCK (pix_clk) cycles. Set it to 1 to count
in terms of complete horizontal lines. DISPLAY CLOCK (pix_clk) cycles should be used in the VSYNC
mode, while horizontal line should be used in the DOTCLK mode.
20
VSYNC_PULSE_
WIDTH_UNIT
Default 0 for counting VSYNC_PULSE_WIDTH in terms of DISPLAY CLOCK (pix_clk) cycles. Set it to 1 to
count in terms of complete horizontal lines.
19
HALF_LINE
Setting this bit to 1 will make the total VSYNC period equal to the VSYNC_PERIOD field plus half the
HORIZONTAL_PERIOD field (i.e. VSYNC_PERIOD field plus half horizontal line), otherwise it is just
VSYNC_PERIOD. Should be only used in the DOTCLK mode, not in the VSYNC interface mode.
18
HALF_LINE_
MODE
When this bit is 0, the first field (VSYNC period) will end in half a horizontal line and the second field will
begin with half a horizontal line. When this bit is 1, all fields will end with half a horizontal line, and none
will begin with half a horizontal line.
VSYNC_PULSE_
WIDTH
Number of units for which VSYNC signal is active. For the DOTCLK mode, the unit is determined by the
VSYNC_PULSE_WIDTH_UNIT. If the VSYNC_PULSE_WIDTH_UNIT is 0 for DOTCLK mode,
VSYNC_PULSE_WIDTH must be less than HSYNC_PERIOD. For the VSYNC interface mode, it should
be in terms of number of DISPLAY CLOCK (pix_clk) cycles only.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2179

<!-- page 2180 -->

34.6.9
eLCDIF VSYNC Mode and Dotclk Mode Control Register1
(LCDIF_VDCTRL1)
This register is used to control the VSYNC signal in the VSYNC and DOTCLK modes of
the block.
This register determines the period and duty cycle of the VSYNC signal when it is
generated in the block.
Address: 21C_8000h base + 80h offset = 21C_8080h
Bit
31
30
29
28
27
26
25
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
VSYNC_PERIOD
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
LCDIF_VDCTRL1 field descriptions
Field
Description
VSYNC_PERIOD Total number of units between two positive or two negative edges of the VSYNC signal. If HALF_LINE is
set, it is implicitly calculated to be VSYNC_PERIOD plus half HSYNC_PERIOD.
34.6.10
LCDIF VSYNC Mode and Dotclk Mode Control Register2
(LCDIF_VDCTRL2)
This register is used to control the HSYNC signal in the DOTCLK mode of the block.
This register determines the period and duty cycle of the HSYNC signal when it is
generated in the block.
Address: 21C_8000h base + 90h offset = 21C_8090h
Bit
31
30
29
28
27
26
25
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
HSYNC_PULSE_WIDTH
HSYNC_PERIOD
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
LCDIF_VDCTRL2 field descriptions
Field
Description
31–18
HSYNC_PULSE_
WIDTH
Number of DISPLAY CLOCK (pix_clk) cycles for which HSYNC signal is active.
HSYNC_PERIOD Total number of DISPLAY CLOCK (pix_clk) cycles between two positive or two negative edges of the
HSYNC signal.
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2180
NXP Semiconductors

<!-- page 2181 -->

34.6.11
eLCDIF VSYNC Mode and Dotclk Mode Control Register3
(LCDIF_VDCTRL3)
This register is used to determine the vertical and horizontal wait counts.
This register determines the back porches of HSYNC and VSYNC signals when they are
generated by the block.
Address: 21C_8000h base + A0h offset = 21C_80A0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
MUX_SYNC_
SIGNALS
VSYNC_ONLY
HORIZONTAL_WAIT_CNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
VERTICAL_WAIT_CNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_VDCTRL3 field descriptions
Field
Description
31–30
RSRVD0
This field is reserved.
Reserved bits, write as 0.
29
MUX_SYNC_
SIGNALS
When this bit is set, the eLCDIF block will internally mux HSYNC with LCD_D14, DOTCLK with LCD_D13
and ENABLE with LCD_D12, otherwise these signals will go out on separate pins. This feature can be
used to maintain backward compatible with 37xx.
28
VSYNC_ONLY
This bit must be set to 1 in the VSYNC mode of operation, and 0 in the DOTCLK mode of operation.
27–16
HORIZONTAL_
WAIT_CNT
In the DOTCLK mode, wait for this number of clocks from falling edge (or rising if HSYNC_POL is 1) of
HSYNC signal to account for horizontal back porch plus the number of DOTCLKs before the moving
picture information begins.
VERTICAL_
WAIT_CNT
In the VSYNC interface mode, wait for this number of DISPLAY CLOCK (pix_clk) cycles from the falling
VSYNC edge (or rising if VSYNC_POL is 1) before starting LCD transactions and is applicable only if
WAIT_FOR_VSYNC_EDGE is set. Minimum is CMD_SETUP+5. In the DOTCLK mode, it accounts for the
vertical back porch lines plus the number of horizontal lines before the moving picture begins. The unit for
this parameter is inherently the same as the VSYNC_PERIOD_UNIT.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2181

<!-- page 2182 -->

34.6.12
eLCDIF VSYNC Mode and Dotclk Mode Control Register4
(LCDIF_VDCTRL4)
This register is used to control the DOTCLK mode of the block.
This register determines the active data in each horizontal line in the DOTCLK mode.
Note that the total number of active horizontal lines in the DOTCLK mode is the same as
the V_COUNT bitfield in the LCDIF_TRANSFER_COUNT register.
Address: 21C_8000h base + B0h offset = 21C_80B0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
DOTCLK_DLY_SEL
Reserved
SYNC_
SIGNALS_ON
DOTCLK_H_
VALID_
DATA_CNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
DOTCLK_H_VALID_DATA_CNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_VDCTRL4 field descriptions
Field
Description
31–29
DOTCLK_DLY_
SEL
This bitfield selects the amount of time by which the DOTCLK signal should be delayed before coming out
of the LCD_DOTCK pin. 0 = 2ns; 1=4ns;2=6ns;3=8ns. Remaining values are reserved.
28–19
RSRVD0
This field is reserved.
Reserved bits, write as 0.
18
SYNC_
SIGNALS_ON
Set this field to 1 if the LCD controller requires that the VSYNC or VSYNC/HSYNC/DOTCLK control
signals should be active at least one frame before the data transfers actually start and remain active at
least one frame after the data transfers end. The hardware does not count the number of frames
automatically. Rather, the VSYNC edge interrupt can be monitored by software to count the number of
frames that have occurred after this bit is set and then the RUN bit can be set to start the data
transactions. This bit must always be set in the DOTCLK mode of operation, and it must be set in the
VSYNC mode of operation when VSYNC signal is an output.
DOTCLK_H_
VALID_DATA_
CNT
Total number of DISPLAY CLOCK (pix_clk) cycles on each horizontal line that carry valid data in DOTCLK
mode.
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2182
NXP Semiconductors

<!-- page 2183 -->

34.6.13
Digital Video Interface Control0 Register
(LCDIF_DVICTRL0)
The Digital Video interface Control0 register provides the overall control of the Digital
Video interface.
This register gives information about the horizontal active, horizontal blanking and total
number of lines in the ITU-R BT.656 interface.
EXAMPLE
         //525/60 video system
         HW_LCDIF_DVICTRL0_H_ACTIVE_CNT_WR(0x5A0);//1440
         HW_LCDIF_DVICTRL0_H_BLANKING_CNT_WR(0x106);//262
         //625/50 video system
         HW_LCDIF_DVICTRL0_H_ACTIVE_CNT_WR(0x5A0);//1440
         HW_LCDIF_DVICTRL0_H_BLANKING_CNT_WR(0x112);//274
         
Address: 21C_8000h base + C0h offset = 21C_80C0h
Bit
31
30
29
28
27
26
25
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
H_ACTIVE_CNT
Reserved
H_BLANKING_CNT
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
LCDIF_DVICTRL0 field descriptions
Field
Description
31–28
RSRVD1
This field is reserved.
Reserved bits, write as 0.
27–16
H_ACTIVE_CNT
Number of active video samples to be transmitted. (Mostly will be 1440 for both PAL and NTSC). Must
always be a multiple of 4.
15–12
RSRVD0
This field is reserved.
Reserved bits, write as 0.
H_BLANKING_
CNT
Number of blanking samples to be inserted between EAV and SAV during horizontal blanking interval.
34.6.14
Digital Video Interface Control1 Register
(LCDIF_DVICTRL1)
The Digital Video interface Control1 register provides the overall control of the Digital
Video interface.
This register contains information about the Field1 start and end, and the Field2 start in
the ITU-R BT.656 interface.
EXAMPLE
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2183

<!-- page 2184 -->

         //525/60 video system
         HW_LCDIF_DVICTRL1_F1_START_LINE_WR(0x4);//4
         HW_LCDIF_DVICTRL1_F1_END_LINE_WR(0x109);//265
         HW_LCDIF_DVICTRL1_F2_START_LINE_WR(0x10A);//266
         //625/50 video system
         HW_LCDIF_DVICTRL1_F1_START_LINE_WR(0x1);//1
         HW_LCDIF_DVICTRL1_F1_END_LINE_WR(0x138);//312
         HW_LCDIF_DVICTRL1_F2_START_LINE_WR(0x139);//313
         
Address: 21C_8000h base + D0h offset = 21C_80D0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
F1_START_LINE
F1_END_LINE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
F1_END_LINE
F2_START_LINE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_DVICTRL1 field descriptions
Field
Description
31–30
RSRVD0
This field is reserved.
Reserved bits, write as 0.
29–20
F1_START_LINE
Vertical line number from which Field 1 begins.
19–10
F1_END_LINE
Vertical line number at which Field1 ends.
F2_START_LINE Vertical line number from which Field 2 begins.
34.6.15
Digital Video Interface Control2 Register
(LCDIF_DVICTRL2)
The Digital Video interface Control2 register provides the overall control of the Digital
Video interface.
This register contains information about the Field2 end, and the Vertical Blanking1
interval in the ITU-R BT.656 interface.
EXAMPLE
         //525/60 video system
         HW_LCDIF_DVICTRL2_F2_END_LINE_WR(0x3);//3
         HW_LCDIF_DVICTRL2_V1_BLANK_START_LINE_WR(0x108);//264
         HW_LCDIF_DVICTRL2_V1_BLANK_END_LINE_WR(0x11A);//282
         //625/50 video system
         HW_LCDIF_DVICTRL2_F2_END_LINE_WR(0x271);//625
         HW_LCDIF_DVICTRL2_V1_BLANK_START_LINE_WR(0x137);//311
         HW_LCDIF_DVICTRL2_V1_BLANK_END_LINE_WR(0x14F);//335
         
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2184
NXP Semiconductors

<!-- page 2185 -->

Address: 21C_8000h base + E0h offset = 21C_80E0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
F2_END_LINE
V1_BLANK_START_LINE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
V1_BLANK_START_LINE
V1_BLANK_END_LINE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_DVICTRL2 field descriptions
Field
Description
31–30
RSRVD0
This field is reserved.
Reserved bits, write as 0.
29–20
F2_END_LINE
Vertical line number at which Field 2 ends.
19–10
V1_BLANK_
START_LINE
Vertical line number towards the end of Field1 where first Vertical Blanking interval starts.
V1_BLANK_
END_LINE
Vertical line number in the beginning part of Field2 where first Vertical Blanking interval ends.
34.6.16
Digital Video Interface Control3 Register
(LCDIF_DVICTRL3)
The Digital Video interface Control3 register provides the overall control of the Digital
Video interface.
This register contains information about the Vertical Blanking2 interval in the ITU-R BT.
656 interface.
EXAMPLE
         //525/60 video system
         HW_LCDIF_DVICTRL3_V2_BLANK_START_LINE_WR(0x1);//1
         HW_LCDIF_DVICTRL3_V2_BLANK_END_LINE_WR(0x13);//19
         HW_LCDIF_DVICTRL0_V_LINES_CNT_WR(0x20D);//525
         //625/50 video system
         HW_LCDIF_DVICTRL3_V2_BLANK_START_LINE_WR(0x270);//624
         HW_LCDIF_DVICTRL3_V2_BLANK_END_LINE_WR(0x16);//22
         HW_LCDIF_DVICTRL0_V_LINES_CNT_WR(0x271);//625
         
Address: 21C_8000h base + F0h offset = 21C_80F0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
V2_BLANK_START_LINE
V2_BLANK_END_LINE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2185

<!-- page 2186 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
V2_BLANK_END_LINE
V_LINES_CNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_DVICTRL3 field descriptions
Field
Description
31–30
RSRVD0
This field is reserved.
Reserved bits, write as 0.
29–20
V2_BLANK_
START_LINE
Vertical line number towards the end of Field2 where second Vertical Blanking interval starts.
19–10
V2_BLANK_
END_LINE
Vertical line number in the beginning part of Field1 where second Vertical Blanking interval ends.
V_LINES_CNT
Total number of vertical lines per frame (generally 525 or 625)
34.6.17
Digital Video Interface Control4 Register
(LCDIF_DVICTRL4)
The Digital Video interface Control4 register provides the overall control of the Digital
Video interface.
This register is used to add side borders to the output if the input frame width is less than
720 pixels.
EXAMPLE
               //If input frame has only 640 pixels per line, but output is supposed to have 
720 pixels per line.
               HW_LCDIF_DVICTRL4_H_FILL_CNT_WR(0x50);//80
               HW_LCDIF_DVICTRL4_Y_FILL_VALUE_WR(0x10);//16
               HW_LCDIF_DVICTRL4_CB_FILL_VALUE_WR(0x80);//128
               HW_LCDIF_DVICTRL4_CR_FILL_VALUE_WR(0x80);//128
           
Address: 21C_8000h base + 100h offset = 21C_8100h
Bit
31
30
29
28
27
26
25
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
Y_FILL_VALUE
CB_FILL_VALUE
CR_FILL_VALUE
H_FILL_CNT
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
LCDIF_DVICTRL4 field descriptions
Field
Description
31–24
Y_FILL_VALUE
Value of Y component of filler data
Table continues on the next page...
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2186
NXP Semiconductors

<!-- page 2187 -->

LCDIF_DVICTRL4 field descriptions (continued)
Field
Description
23–16
CB_FILL_VALUE
Value of CB component of filler data
15–8
CR_FILL_VALUE
Value of CR component of filler data.
H_FILL_CNT
Number of active video samples that have to be filled with the filler data in the front and back portions of
the active horizontal interval. Must be a multiple of 4. This field will have to be programmed if the input
frame has less than 720 pixels per line.
34.6.18
RGB to YCbCr 4:2:2 CSC Coefficient0 Register
(LCDIF_CSC_COEFF0)
LCDIF_CSC_COEFF0 register provides overall control over color space conversion
from RGB to 4:2:2 YCbCr. The equations for the conversion are given by: Y = C0*R +
C1*G + C2*B + Y_offset Cb= C3*R + C4*G + C5*B + CbCr_offset Cr= C6*R + C7*G
+ C8*B + CbCr_offset
This register carries programming information about RGB to YCbCr 4:2:2 CSC.
EXAMPLE
               HW_LCDIF_CSC_COEFF0_C0_WR(0x41);//0.257x256=65
               HW_LCDIF_CSC_COEFF0_CSC_SUBSAMPLE_FILTER_WR(0x3);
           
Address: 21C_8000h base + 110h offset = 21C_8110h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
Reserved
C0
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
CSC_
SUBSAMPL
E_FILTER
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_CSC_COEFF0 field descriptions
Field
Description
31–26
RSRVD1
This field is reserved.
Reserved bits, write as 0.
25–16
C0
Two's complement red multiplier coefficient for Y
15–2
RSRVD0
This field is reserved.
Reserved bits, write as 0.
Table continues on the next page...
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2187

<!-- page 2188 -->

LCDIF_CSC_COEFF0 field descriptions (continued)
Field
Description
CSC_
SUBSAMPLE_
FILTER
This register describes the filtering and subsampling scheme to be performed on the chroma components
in order to convert from YCbCr 4:4:4 to YCbCr 4:2:2 space. Note that the following descriptions apply
individually to Cb and Cr.
0x0
SAMPLE_AND_HOLD — No filtering, simply keep every chroma value for samples numbered 2n
and discard chroma values associated with all samples numbered 2n+1.
0x1
RSRVD — Reserved
0x2
INTERSTITIAL — Chroma samples numbered 2n and 2n+1 are averaged (weights 1/2, 1/2) and
that chroma value replaces the two chroma values at 2n and 2n+1. This chroma now exists
horizontally halfway between the two luma samples.
0x3
COSITED — Chroma samples numbered 2n-1, 2n, and 2n+1 are averaged (weights 1/4, 1/2, 1/4)
and that chroma value exists at the same site as the luma sample numbered 2n and the chroma
samples at 2n+1 are discarded.
34.6.19
RGB to YCbCr 4:2:2 CSC Coefficient1 Register
(LCDIF_CSC_COEFF1)
LCDIF_CSC_COEFF1 register provides overall control over color space conversion
from RGB to 4:2:2 YCbCr. The equations for the conversion are given by: Y = C0*R +
C1*G + C2*B + Y_offset Cb= C3*R + C4*G + C5*B + CbCr_offset Cr= C6*R + C7*G
+ C8*B + CbCr_offset
This register carries programming information about RGB to YCbCr 4:2:2 CSC.
EXAMPLE
               HW_LCDIF_CSC_COEFF1_C1_WR(0x81);//0.504x256=129
               HW_LCDIF_CSC_COEFF1_C2_WR(0x19);//0.098x256=25
           
Address: 21C_8000h base + 120h offset = 21C_8120h
Bit
31
30
29
28
27
26
25
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
C2
Reserved
C1
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
LCDIF_CSC_COEFF1 field descriptions
Field
Description
31–26
RSRVD1
This field is reserved.
Reserved bits, write as 0.
25–16
C2
Two's complement blue multiplier coefficient for Y
15–10
RSRVD0
This field is reserved.
Reserved bits, write as 0.
C1
Two's complement green multiplier coefficient for Y
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2188
NXP Semiconductors

<!-- page 2189 -->

34.6.20
RGB to YCbCr 4:2:2 CSC Coefficent2 Register
(LCDIF_CSC_COEFF2)
LCDIF_CSC_COEFF2 register provides overall control over color space conversion
from RGB to 4:2:2 YCbCr. The equations for the conversion are given by: Y = C0*R +
C1*G + C2*B + Y_offset Cb= C3*R + C4*G + C5*B + CbCr_offset Cr= C6*R + C7*G
+ C8*B + CbCr_offset
This register carries programming information about RGB to YCbCr 4:2:2 CSC.
EXAMPLE
               HW_LCDIF_CSC_COEFF2_C3_WR(0x3DB);//-0.148x256=-37
               HW_LCDIF_CSC_COEFF2_C4_WR(0x3B6);//-0.291x256=-74
           
Address: 21C_8000h base + 130h offset = 21C_8130h
Bit
31
30
29
28
27
26
25
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
C4
Reserved
C3
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
LCDIF_CSC_COEFF2 field descriptions
Field
Description
31–26
RSRVD1
This field is reserved.
Reserved bits, write as 0.
25–16
C4
Two's complement green multiplier coefficient for Cb
15–10
RSRVD0
This field is reserved.
Reserved bits, write as 0.
C3
Two's complement red multiplier coefficient for Cb
34.6.21
RGB to YCbCr 4:2:2 CSC Coefficient3 Register
(LCDIF_CSC_COEFF3)
LCDIF_CSC_COEFF3 register provides overall control over color space conversion
from RGB to 4:2:2 YCbCr. The equations for the conversion are given by: Y = C0*R +
C1*G + C2*B + Y_offset Cb= C3*R + C4*G + C5*B + CbCr_offset Cr= C6*R + C7*G
+ C8*B + CbCr_offset
This register carries programming information about RGB to YCbCr 4:2:2 CSC.
EXAMPLE
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2189

<!-- page 2190 -->

               HW_LCDIF_CSC_COEFF3_C5_WR(0x70);//0.439x256=112
               HW_LCDIF_CSC_COEFF3_C6_WR(0x70);//0.439x256=112
           
Address: 21C_8000h base + 140h offset = 21C_8140h
Bit
31
30
29
28
27
26
25
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
C6
Reserved
C5
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
LCDIF_CSC_COEFF3 field descriptions
Field
Description
31–26
RSRVD1
This field is reserved.
Reserved bits, write as 0.
25–16
C6
Two's complement red multiplier coefficient for Cr
15–10
RSRVD0
This field is reserved.
Reserved bits, write as 0.
C5
Two's complement blue multiplier coefficient for Cb
34.6.22
RGB to YCbCr 4:2:2 CSC Coefficient4 Register
(LCDIF_CSC_COEFF4)
LCDIF_CSC_COEFF4 register provides overall control over color space conversion
from RGB to 4:2:2 YCbCr. The equations for the conversion are given by: Y = C0*R +
C1*G + C2*B + Y_offset Cb= C3*R + C4*G + C5*B + CbCr_offset Cr= C6*R + C7*G
+ C8*B + CbCr_offset
This register carries programming information about RGB to YCbCr 4:2:2 CSC.
EXAMPLE
               HW_LCDIF_CSC_COEFF4_C7_WR(0x3A2);//-0.368x256=-94
               HW_LCDIF_CSC_COEFF4_C8_WR(0x3EE);//-0.071x256=-18
           
Address: 21C_8000h base + 150h offset = 21C_8150h
Bit
31
30
29
28
27
26
25
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
C8
Reserved
C7
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
LCDIF_CSC_COEFF4 field descriptions
Field
Description
31–26
RSRVD1
This field is reserved.
Reserved bits, write as 0.
Table continues on the next page...
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2190
NXP Semiconductors

<!-- page 2191 -->

LCDIF_CSC_COEFF4 field descriptions (continued)
Field
Description
25–16
C8
Two's complement blue multiplier coefficient for Cr
15–10
RSRVD0
This field is reserved.
Reserved bits, write as 0.
C7
Two's complement green multiplier coefficient for Cr
34.6.23
RGB to YCbCr 4:2:2 CSC Offset Register
(LCDIF_CSC_OFFSET)
LCDIF_CSC_ register provides overall control over color space conversion from RGB to
4:2:2 YCbCr. The equations for the conversion are given by: Y = C0*R + C1*G + C2*B
+ Y_offset Cb= C3*R + C4*G + C5*B + CbCr_offset Cr= C6*R + C7*G + C8*B +
CbCr_offset
This register carries programming information about RGB to YCbCr 4:2:2 CSC.
Address: 21C_8000h base + 160h offset = 21C_8160h
Bit
31
30
29
28
27
26
25
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
CBCR_OFFSET
Reserved
Y_OFFSET
W
Reset 0
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
0
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
LCDIF_CSC_OFFSET field descriptions
Field
Description
31–25
RSRVD1
This field is reserved.
Reserved bits, write as 0.
24–16
CBCR_OFFSET
Two's complement offset for the Cb and Cr components
15–9
RSRVD0
This field is reserved.
Reserved bits, write as 0.
Y_OFFSET
Two's complement offset for the Y component
34.6.24
RGB to YCbCr 4:2:2 CSC Limit Register
(LCDIF_CSC_LIMIT)
LCDIF_CSC_CTRL0 register provides overall control over color space conversion from
RGB to 4:2:2 YCbCr. The equations for the conversion are given by: Y = C0*R + C1*G
+ C2*B + Y_offset Cb= C3*R + C4*G + C5*B + CbCr_offset Cr= C6*R + C7*G +
C8*B + CbCr_offset
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2191

<!-- page 2192 -->

This register carries programming information about RGB to YCbCr 4:2:2 CSC. Note
that the values in this register are unsigned.
EXAMPLE
               HW_LCDIF_CSC_LIMIT_CBCR_MIN_WR(0x10);//16
               HW_LCDIF_CSC_LIMIT_CBCR_MAX_WR(0xF0);//240
               HW_LCDIF_CSC_LIMIT_Y_MIN_WR(0x10);//16
               HW_LCDIF_CSC_LIMIT_Y_MAX_WR(0xEB);//235
           
Address: 21C_8000h base + 170h offset = 21C_8170h
Bit
31
30
29
28
27
26
25
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
CBCR_MIN
CBCR_MAX
Y_MIN
Y_MAX
W
Reset 0
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
LCDIF_CSC_LIMIT field descriptions
Field
Description
31–24
CBCR_MIN
Lower limit of Cb and Cr after RGB to 4:2:2 YCbCr conversion
23–16
CBCR_MAX
Upper limit of Cb and Cr after RGB to 4:2:2 YCbCr conversion
15–8
Y_MIN
Lower limit of Y after RGB to 4:2:2 YCbCr conversion
Y_MAX
Upper limit of Y after RGB to 4:2:2 YCbCr conversion
34.6.25
LCD Interface Data Register (LCDIF_DATA)
This register is used to transfer data using the PIO interface mode of operation. In MPU
mode, data written to this register will be transferred out to the display device. When
receiving data from the display, data is read from this register using PIO operations.
During write operations, data can be written to this register (from the processor's
perspective) as bytes, half-words (16 bits), or words (32 bits) as desired.
This register holds the 32-bit word written by the ARM platform into LCDIF. This data
then gets sent out by the block across the interface.
Address: 21C_8000h base + 180h offset = 21C_8180h
Bit
31
30
29
28
27
26
25
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
DATA_THREE
DATA_TWO
DATA_ONE
DATA_ZERO
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
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2192
NXP Semiconductors

<!-- page 2193 -->

LCDIF_DATA field descriptions
Field
Description
31–24
DATA_THREE
Byte 3 (most significant byte) of data written to LCDIF.
23–16
DATA_TWO
Byte 2 of data written to eLCDIF.
15–8
DATA_ONE
Byte 1 of data written to eLCDIF.
DATA_ZERO
Byte 0 (least significant byte) of data written to eLCDIF.
34.6.26
Bus Master Error Status Register
(LCDIF_BM_ERROR_STAT)
This register reflects the virtual address at which the AXI master received an error
response from the slave.
When the BM_ERROR_IRQ is asserted, the address of the bus error is updated in the
register.
Address: 21C_8000h base + 190h offset = 21C_8190h
Bit
31
30
29
28
27
26
25
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
ADDR
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
LCDIF_BM_ERROR_STAT field descriptions
Field
Description
ADDR
Virtual address at which bus master error occurred.
34.6.27
CRC Status Register (LCDIF_CRC_STAT)
This register reflects the CRC value of each frame sent out by eLCDIF. The CRC is done
on the final output bus, so the value will be dependent on the LCD_DATABUS_WIDTH
bitfield even if the input data is the same.
This register will be updated when the CUR_FRAME_DONE_IRQ is asserted. In the
case of DVI mode, the CRC is calculated for the entire frame, not separately for each
field in the frame.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2193

<!-- page 2194 -->

Address: 21C_8000h base + 1A0h offset = 21C_81A0h
Bit
31
30
29
28
27
26
25
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
CRC_VALUE
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
LCDIF_CRC_STAT field descriptions
Field
Description
CRC_VALUE
Calculated CRC value.
34.6.28
LCD Interface Status Register (LCDIF_STAT)
The LCD interface status register can be used to check the current status of the eLCDIF
block.
The LCD interface status register that contains read only views of some parameters or
current state of the block.
Address: 21C_8000h base + 1B0h offset = 21C_81B0h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
PRESENT
Reserved
LFIFO_FULL
LFIFO_EMPTY
TXFIFO_FULL
TXFIFO_EMPTY
BUSY
DVI_CURRENT_FIELD
Reserved
W
Reset
1
0
0
1
0
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
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2194
NXP Semiconductors

<!-- page 2195 -->

Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
LFIFO_COUNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_STAT field descriptions
Field
Description
31
PRESENT
0: eLCDIF not present on this product
1: eLCDIF is present.
30
-
This field is reserved.
Reserved.
29
LFIFO_FULL
Read only view of the signals that indicates LCD LFIFO is full.
28
LFIFO_EMPTY
Read only view of the signals that indicates LCD LFIFO is empty.
27
TXFIFO_FULL
Read only view of the signals that indicates LCD TXFIFO is full.
26
TXFIFO_EMPTY
Read only view of the signals that indicates LCD TXFIFO is empty.
25
BUSY
Read only view of the input busy signal from the external LCD controller.
24
DVI_CURRENT_
FIELD
Read only view of the current field being transmitted. DVI_CURRENT_FIELD = 0 means field 1.
DVI_CURRENT_FIELD = 1 means field 2.
23–9
RSRVD0
This field is reserved.
Reserved bits. Write as 0.
LFIFO_COUNT
Read only view of the current count in Latency buffer (LFIFO).
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2195

<!-- page 2196 -->

34.6.29
eLCDIF Threshold Register (LCDIF_THRES)
This register is used to activate control signals when the number of pixels reaches the
programmed threshold. These control signals, in turn, can be used to manipulate access
priority or dynamically change the input clock frequency to meet the required pixel
throughput.
Memory request priority threshold register.
Address: 21C_8000h base + 200h offset = 21C_8200h
Bit
31
30
29
28
27
26
25
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
FASTCLOCK
Reserved
PANIC
W
Reset 0
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
0
0
0
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
LCDIF_THRES field descriptions
Field
Description
31–25
RSRVD2
This field is reserved.
Reserved bits. Write as 0.
24–16
FASTCLOCK
This value should be set to a value of pixels, from 0 to 511. When the number of pixels in the input pixel
FIFO is LESS than this value, the fast clock control output will be raised. This signal can be used to
reduce the system bus clock frequency to save power during horizontal or vertical blanking intervals. This
value should also be programmed to a value that is greater than the "PANIC" threshold value. This will
allow a faster clock to recover the number of pixels in the FIFO before a "panic" level is encountered.
15–9
RSRVD1
This field is reserved.
Reserved bits. Write as 0.
PANIC
This value should be set to a value of pixels from 0 to 511. When the number of pixels in the input pixel
FIFO is less than this value, the internal panic control output will be raised. This signal can be used to
raise the access eLCDIF's access priority.
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2196
NXP Semiconductors

<!-- page 2197 -->

34.6.30
eLCDIF AS Buffer Control Register (LCDIF_AS_CTRL)
The Alpha Surface Parameter register provides additional controls for AS.
Address: 21C_8000h base + 210h offset = 21C_8210h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
CSI_VSYNC_ENABLE
CSI_VSYNC_POL
CSI_VSYNC_MODE
CSI_SYNC_ON_IRQ_EN
CSI_SYNC_ON_IRQ
RVDS1
PS_DISABLE
INPUT_
DATA_
SWIZZLE
ALPHA_INVERT
ROP
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
ALPHA
FORMAT
ENABLE_COLORKEY
ALPHA_
CTRL
AS_ENABLE
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
LCDIF_AS_CTRL field descriptions
Field
Description
31
CSI_VSYNC_
ENABLE
When this bit is set by software, the LCDIF work as sync mode with CSI input.
30
CSI_VSYNC_
POL
Default 0 active low during VSYNC_PULSE_WIDTH time and will be high during the rest of the VSYNC
period. Set it to 1 to invert the polarity.
Table continues on the next page...
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2197

<!-- page 2198 -->

LCDIF_AS_CTRL field descriptions (continued)
Field
Description
29
CSI_VSYNC_
MODE
this bit is set by software to decide which vsync generate mode. LCDIF vsync generate by internal counter
when set to 0, LCDIF vsync delayed by each csi_vsync_in when set to 1;
INT_SYNC_MODE = 0x0 LCDIF vsync generate by internal counter.
EXT_SYNC_MODE = 0x1 LCDIF vsync delayed by each csi_vsync_in.
28
CSI_SYNC_ON_
IRQ_EN
This bit is set to enable an interrupt when LCDIF lock with CSI vsync input.
27
CSI_SYNC_ON_
IRQ
this bit is set by software to decide which vsync generate mode. LCDIF vsync generate by internal counter
when set to 0, LCDIF vsync delayed by each csi_vsync_in when set to 1;
INT_SYNC_MODE = 0x0 LCDIF vsync generate by internal counter.
EXT_SYNC_MODE = 0x1 LCDIF vsync delayed by each csi_vsync_in.
26–24
RVDS1
Reserved, always set to zero.
23
PS_DISABLE
When this bit is set by software, the LCDIF will disable PS buffer data.
22–21
INPUT_DATA_
SWIZZLE
This field specifies how to swap the bytes either in the HW_LCDIF_DATA register or those fetched by the
AXI master part of LCDIF. The swizzle function is independent of the WORD_LENGTH bit. See the
explanation of the HW_LCDIF_DATA below for names and definitions of data register fields. The
supported swizzle configurations are:
NO_SWAP = 0x0 No byte swapping.(Little endian)
LITTLE_ENDIAN = 0x0 Little Endian byte ordering (same as NO_SWAP).
BIG_ENDIAN_SWAP = 0x1 Big Endian swap (swap bytes 0, 3 and 1, 2).
SWAP_ALL_BYTES = 0x1 Swizzle all bytes, swap bytes 0, 3 and 1, 2 (aka Big Endian).
HWD_SWAP = 0x2 Swap half-words.
HWD_BYTE_SWAP = 0x3 Swap bytes within each half-word.
20
ALPHA_INVERT
Setting this bit to logic 0 will not alter the alpha value. A logic 1 will invert the alpha value and apply (1-
alpha) for image composition.
19–16
ROP
Indicates a raster operation to perform when enabled. Raster operations are enabled through the
ALPHA_CTRL field.
MASKAS = 0x0 AS AND PS
MASKNOTAS = 0x1 nAS AND PS
MASKASNOT = 0x2 AS AND nPS
MERGEAS = 0x3 AS OR PS
MERGENOTAS = 0x4 nAS OR PS
MERGEASNOT = 0x5 AS OR nPS
NOTCOPYAS = 0x6 nAS
NOT = 0x7 nPS
NOTMASKAS = 0x8 AS NAND PS
NOTMERGEAS = 0x9 AS NOR PS
XORAS = 0xA AS XOR PS
NOTXORAS = 0xB AS XNOR PS
Table continues on the next page...
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2198
NXP Semiconductors

<!-- page 2199 -->

LCDIF_AS_CTRL field descriptions (continued)
Field
Description
15–8
ALPHA
Alpha modifier used when the ALPHA_MULTIPLY or ALPHA_OVERRIDE values are programmed in
REG_AS_CTRL[ALPHA_CTRL]. The output alpha value will either be replaced (ALPHA_OVERRIDE) or
scaled (ALPHA_MULTIPLY) when selected.
7–4
FORMAT
Indicates the input buffer format for AS.
ARGB8888 = 0x0 32-bit pixels with alpha
RGB888 = 0x4 32-bit pixels without alpha (unpacked 24-bit format)
ARGB1555 = 0x8 16-bit pixels with alpha
ARGB4444 = 0x9 16-bit pixels with alpha
RGB555 = 0xC 16-bit pixels without alpha
RGB444 = 0xD 16-bit pixels without alpha
RGB565 = 0xE 16-bit pixels without alpha
3
ENABLE_
COLORKEY
Indicates that colorkey functionality is enabled for this alpha surface. Pixels found in the alpha surface
colorkey range will be displayed as transparent (the PS pixel will be used).
2–1
ALPHA_CTRL
Determines how the alpha value is constructed for this alpha surface. Indicates that the value in the
ALPHA field should be used instead of the alpha values present in the input pixels.
Embedded = 0x0 Indicates that the AS pixel alpha value will be used to blend the AS with PS. The ALPHA
field is ignored.
Override = 0x1 Indicates that the value in the ALPHA field should be used instead of the alpha values
present in the input pixels.
Multiply = 0x2 Indicates that the value in the ALPHA field should be used to scale all pixel alpha values.
Each pixel alpha is multiplied by the value in the ALPHA field.
ROPs = 0x3 Enable ROPs. The ROP field indicates an operation to be performed on the alpha surface
and PS pixels.
0
AS_ENABLE
When this bit is set by software, the LCDIF will start fetching AS buffer data in bus master mode and
combine it with another buffer.
34.6.31
Alpha Surface Buffer Pointer (LCDIF_AS_BUF)
This register is used to indicate the base address of the AS buffer.
Address: 21C_8000h base + 220h offset = 21C_8220h
Bit
31
30
29
28
27
26
25
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
ADDR
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
LCDIF_AS_BUF field descriptions
Field
Description
ADDR
Address pointer for the alpha surface 0 buffer.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2199

<!-- page 2200 -->

34.6.32
LCDIF_AS_NEXT_BUF
When the LCDIF is behaving as a master, this address points to the address of the next
frame of data that will be sent out via the LCDIF. It is upto the software to make sure that
this register is programmed before the end of the current frame, otherwise it might result
in old data going out the LCDIF. This address must always be double-word aligned.
Address: 21C_8000h base + 230h offset = 21C_8230h
Bit
31
30
29
28
27
26
25
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
ADDR
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
LCDIF_AS_NEXT_BUF field descriptions
Field
Description
ADDR
Address of the next frame that will be transmitted by eLCDIF.
34.6.33
eLCDIF Overlay Color Key Low
(LCDIF_AS_CLRKEYLOW)
If a pixel in the current overlay image with a color that falls in the range from the
ASCOLORKEYLOW to ASCOLORKEYHIGH range, it will use the PS pixel value for
that location. Colorkey operations are higher priority than alpha or ROP operations.
Address: 21C_8000h base + 240h offset = 21C_8240h
Bit
31
30
29
28
27
26
25
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
RSVD1
PIXEL
W
Reset 0
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
1
1
1
1
1
1
1
1
LCDIF_AS_CLRKEYLOW field descriptions
Field
Description
31–24
RSVD1
Reserved, always set to zero.
PIXEL
Low range of RGB color key applied to AS buffer
eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2200
NXP Semiconductors

<!-- page 2201 -->

34.6.34
eLCDIF Overlay Color Key High
(LCDIF_AS_CLRKEYHIGH)
If a pixel in the current overlay image with a color that falls in the range from the
ASCOLORKEYLOW to ASCOLORKEYHIGH range, it will use the PS pixel value for
that location. Colorkey operations are higher priority than alpha or ROP operations.
Address: 21C_8000h base + 250h offset = 21C_8250h
Bit
31
30
29
28
27
26
25
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
RSVD1
PIXEL
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
LCDIF_AS_CLRKEYHIGH field descriptions
Field
Description
31–24
RSVD1
Reserved, always set to zero.
PIXEL
High range of RGB color key applied to AS buffer
34.6.35
LCD working insync mode with CSI for VSYNC delay
(LCDIF_SYNC_DELAY)
The LCDIF DOTCLK mode VSYNC will delay from CSI_VSYNC as
( V_COUNT_DELAY * HSYNC_PERIOD + H_COUNT_DELAY) PIXCLK cycles
Address: 21C_8000h base + 260h offset = 21C_8260h
Bit
31
30
29
28
27
26
25
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
V_COUNT_DELAY
H_COUNT_DELAY
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
LCDIF_SYNC_DELAY field descriptions
Field
Description
31–16
V_COUNT_
DELAY
LCDIF VSYNC delayed counter for CSI_VSYNC.
H_COUNT_
DELAY
LCDIF VSYNC delayed counter for CSI_VSYNC.
Chapter 34 Enhanced LCD Interface (eLCDIF)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
2201

<!-- page 2202 -->

eLCDIF Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
2202
NXP Semiconductors

