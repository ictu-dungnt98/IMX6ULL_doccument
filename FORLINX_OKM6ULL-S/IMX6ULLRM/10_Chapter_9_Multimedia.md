# Chapter 9: Multimedia

> Nguồn: `IMX6ULLRM.pdf` — trang 335–344

<!-- page 335 -->

Chapter 9
Multimedia
9.1
Display and graphics subsystem
The chip display and graphics subsystem consists of the dedicated modules found here.
• EPDC (electrophoretic display controller): display controller for E-INK EPD panel
• LCD Interface (LCDIF): 24-bit parallel RGB LCD interface
• PXP pixel pipeline: pixel/image processing engine for LCD display
• Camera Sensor Interface (CSI): up to 24-bit parallel interface for image sensor
The following figure shows the high-level integration scheme of the chip display and
graphics system.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
335

<!-- page 336 -->

EPDC
LCDIF
CSI
PXP
DRAM Interface
EPD Panel 
Display
LCD Panel 
Display
Camera 
Input
DRAM
Chip
        (E-INK)
Figure 9-1. Chip display and graphics subsystem
9.1.1
Electrophoretic Display Controller
The EPDC is a feature-rich, low power, and high-performance direct-drive active matrix
EPD controller. It is specifically designed to drive E•INK™ EPD panels supporting a
wide variety of TFT backplanes. The goal of the EPDC is to provide an efficient SoC
integration of this functionality for e-paper applications, allowing a significant BOM cost
saving over an external solution whilst reaching much higher levels of performance and
lower power. The EPDC module is defined in the context of an optimized HW/SW
partitioning and works in conjunction with the ePXP IP module to form a complete
display processing solution.
The key features of the EPDC are as follows:
• Supports direct-driver for E-Ink EPD panels, with up to 2048x1536 resolution at 106
Hz refresh rate (or 4096x4096 resolution at 20 Hz refresh rate)
• Supports up to 64 LUT for concurrent update
• Supports automatic waveform selection based on both input image and current panel
content
• Supports collision detection
• Supports both PVI panels and LGD GIP panels.
Display and graphics subsystem
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
336
NXP Semiconductors

<!-- page 337 -->

9.1.2
PiXel Processing Pipeline (PXP)
The pixel processing pipeline is used to perform image processing on image/video
buffers before sending to an LCD display.
The main features of PXP include:
• Multiple input/output format support, including YUV/RGB/Grayscale
• Supports both RGB/YUV scaling
• Supports overlay with Alpha blending
9.1.3
LCD Interface (LCDIF)
The LCDIF is a general purpose display controller that is used to drive a wide range of
display devices. These displays can vary in size and capability. Many of these displays
have had an asynchronous parallel MPU interface for command and data transfer to an
integrated frame buffer. There are other popular displays that support moving pictures
and require the RGB interface mode (called DOTCLK interface in this document) or the
VSYNC mode for high-speed data transfers. In addition to these displays, it is also
common to provide support for digital video encoders that accept ITU-R BT.656 format
4:2:2 YCbCr digital component video and convert it to analog TV signals. The LCDIF
block supports these different interfaces by providing fully programmable functionality.
The block has several major features:
• Bus master interface to source frame buffer data for display refresh and a DMA
interface to manage input data transfers from the LCD requiring minimal CPU
overhead.
• 8/16/18/24 bit LCD data bus support available depending on I/O mux options.
• Programmable timing and parameters for MPU, VSYNC and DOTCLK LCD
interfaces to support a wide variety of displays.
• ITU-R BT.656 mode (called Digital Video Interface or DVI mode here) including
progressive-to-interlace feature and RGB to YCbCr 4:2:2 color space conversion to
support 525/60 and 625/50 operation.
9.1.4
CMOS Sensor Interface (CSI)
Chapter 9 Multimedia
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
337

<!-- page 338 -->

The CSI enables the chip to connect directly to external CMOS image sensors. CMOS
image sensors are separated into two classes, dumb and smart. Dumb sensors are those
that support only traditional sensor timing (Vertical SYNC and Horizontal SYNC) and
output only Bayer and statistics data, while smart sensors support CCIR656 video
decoder formats and perform additional processing of the image (for example, image
compression, image pre-filtering, and various data output formats).
The capabilities of the CSI include:
• Configurable interface logic to support most commonly available CMOS sensors.
• Support for CCIR656 video interface as well as traditional sensor interface.
• 8-bit data port for YCC, YUV, or RGB data input.
• 8-bit/10-bit/16-bit data port for Bayer data input.
• Embedded DMA controllers to transfer data from receive FIFO or statistic FIFO
through AHB bus.
• Support for 2D DMA transfer from the receive FIFO to the frame buffers in the
external memory.
• Support for double buffering two frames in the external memory.
• Single interrupt source to interrupt controller from maskable interrupt sources:
• Start of Frame
• End of Frame
• Change of Field
• FIFO full
• FIFO overrun
• DMA transfer done
• CCIR error
• AHB bus response error
• Configurable master clock frequency output to sensor.
• Statistic data generation for Auto Exposure (AE) and Auto White Balance (AWB)
control of the camera (only for Bayer data and 8-bit/pixel format).
9.2
Audio subsystem
Audio Subsystem Module Overview provides an overview of each of the audio
subsystem component modules, followed by a module-specific section.
9.2.1
Audio Subsystem Module Overview
The following figure shows a high level block diagram of the audio subsystem.
Audio subsystem
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
338
NXP Semiconductors

<!-- page 339 -->

SPDIF
SAI1_3
SPBA
SDMA
System Bus
ARM
MQS
R
L
Audio on 
PWM
ASRC
ESAI
Figure 9-2. Audio subsystem block diagram
AUDMUX routes audio data (and even splices together multiple time-multiplexed audio
streams) but does not decode or process audio data itself. The ARM controls AUDMUX,
but AUDMUX can route data even when the ARM is in a low-power mode.
The SPDIF (Sony/Philips digital interface) audio module is a stereo transceiver that
allows the processor to receive and transmit digital audio over it. The SPDIF receiver
section includes a frequency measurement block that allows the precise measurement of
an incoming sampling frequency. A recovered clock is provided by the SPDIF receiver
section and may be used to drive both internal and external components in the system.
SPDIF is connected to the shared peripheral bus.
ASRC (asynchronous sample rate converter) converts the sampling rate of a signal
associated to an input clock into a signal associated to a different output clock. ASRC
supports concurrent sample rate conversion of up to 10 channels of over 120dB THD+N.
Chapter 9 Multimedia
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
339

<!-- page 340 -->

The sample rate conversion of each channel is associated to a pair of incoming and
outgoing sampling rates. ASRC supports up to 3 sampling rate pairs. ASRC is connected
to the shared peripheral bus.
9.2.2
Medium Quality Sound (MQS)
MQS is used to generate medium quality audio via a standard GPIO in the pinmux. The
user can connect stereo speakers or headphones to a power amplifier without an
additional DAC chip.
• 2-channel, MSB-valid 16 bit, MSB first
• Frame sync aligned with the left channel data
• 44.1 kHz or 48 kHz I2S signals from SAI1
• SNR target as no more than 20 dB for the signals below 10 kHz
• Signals Over 10 kHz have worse THD + N values
9.2.3
Synchronous Audio Interface (SAI)
• Transmitter with independent Bit Clock and Frame Sync supporting 1 data line
• Receiver with independent Bit Clock and Frame Sync supporting 1 data line
• Maximum Frame Size of 32 Words
• Word size programmable from 8-bits to 32-bits
• Word size configured separately for first word and remaining words in frame
• Asynchronous FIFO for each Transmit and Receive data line
• Graceful restart after FIFO Error
9.2.4
Enhanced Serial Audio Interface (ESAI)
The Enhanced Serial Audio Interface (ESAI) provides a full-duplex serial port for serial
communication with a variety of serial devices, including industry-standard codecs,
SPDIF transceivers, and other processors.
The ESAI consists of independent transmitter and receiver sections, each section with its
own clock generator. All serial transfers are synchronized to a clock. Additional
synchronization signals are used to delineate the word frames. The normal mode of
operation is used to transfer data at a periodic rate, one word per period. The network
mode is also intended for periodic transfers; however, it supports up to 32 words (time
slots) per period. This mode can be used to build time division multiplexed (TDM)
networks. In contrast, the on-demand mode is intended for non-periodic transfers of data
and to transfer data serially at high speed when the data becomes available.
Audio subsystem
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
340
NXP Semiconductors

<!-- page 341 -->

The ESAI has 12 pins for data and clocking connection to external devices. The ESAI is
internally connected to the ESAI_BIFIFO, and does not connect directly to the shared
peripheral bus. The ESAI interface is designed for a 24-bit data bus, while the shared
peripheral data bus is 32-bit wide. Also, the ESAI data paths are only double buffered,
not allowing efficient DMA service in the applications processor environment. The
ESAI_BIFIFO allows increasing the data buffering and data width matching to the shared
peripheral bus.
9.2.5
Sony/Philips Digital Interface (SPDIF)
The SPDIF module is a stereo that allows the processor transmit digital audio over it
using the IEC60958 standard, consumer format. The chip provides one SPDIF transmitter
with one output and one SPDIF receiver with four inputs.
The SPDIF allows the handling of both SPDIF channel status (CS) and User (U) data.
For the SPDIF transmitter, the audio data is provided by the processor via the
SPDIFTxLeft and SPDIFTxRight registers, and the data is stored in two 16-word-deep
FIFOs, one for the right channel, the other for the left channel. The FIFOs support
programmable watermark levels so that FIFO Empty service request can be triggered
when the combined number of empty data words locations in both FIFOs is 8, 16, 24 or
32 words. It is recommended to program the watermark level to trigger a FIFO Empty
service request when 16 word locations are empty. For optimal performance when
servicing the FIFO Empty service request, the FIFOs should be written alternately,
starting with the left channel FIFO. The Channel Status bits are also provided via the
corresponding registers. The SPDIF transmitter generates an SPDIF output bitstream in
the biphase mark format (IEC 60958), which consists of audio data, channel status and
user bits.
The data handled by the SPDIF module is 24-bit wide. The 24-bit SPDIF data is aligned
in the 24 least significant bits of the 32-bit shared peripheral bus data word. The 8 most
significant bits of the 32-bit word are ignored by the SPDIF Transmitter when data is
being stored in the Transmit FIFOs from the peripheral bus. The 8 most significant bits of
the 32-bit word are zeroed by the SPDIF Receiver module when the data is being read
from the Receiver FIFOs to the peripheral bus.
Note that 16-bit data is left-aligned in the 24-bit word format of the SPDIF. When 16-bit
data is to be transmitted, the 32-bit word to be written to the SPDIF Transmit FIFOs
should be created as follows: the 16-bit data should be located in the middle two bytes of
the 32-bit data word and the 8 bits of the LSB must be set to zero, while the 8 bits of the
MSB will be ignored.
Chapter 9 Multimedia
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
341

<!-- page 342 -->

The SPDIF Transmit clock is generated by the SPDIF internal clock generator module
and the clock sources are from outside of the SPDIF block. The clock sources should
provide a clock that is at least 64 x Fs, where Fs is the sampling frequency. The external
clock source should provide at least 128 x Fs. Clocks of higher frequency may be
provided as long as the multiplication factor is a power of 2 (for example, 128x, 256x or
512x). Also, clock frequency precision of 100ppm or better should be provided.
9.2.6
Asynchronous Sample Rate Converter (ASRC)
The incoming audio data may be received from various sources at different sampling
rates. The outgoing audio data may have different sampling rates, and it can also be
associated to output clocks that are asynchronous to the input clocks.
ASRC converts the sampling rate of a signal associated to an input clock into a signal
associated to a different output clock. ASRC supports concurrent sample rate conversion
of up to 10 channels of about -120dB THD+N. The sampling rate conversion of each
channel is associated to a pair of incoming and outgoing sampling rates. ASRC supports
up to 3 sampling rate pairs.
In the real-time audio use case, both input/output sampling rate clocks are activated. Both
sampling rate clocks are directly connected to ASRC, and the ratio estimation of the input
clocks to output clocks is used to perform the sample rate conversion in ASRC hardware.
The SAI1, SAI2, SAI3, and SPDIF audio modules can act as either a clock master or a
clock slave. Multiplexors are provided on a chip level to select which of the module's
clock signal, input or output, will be connected to ASRC input in dependence of the
module's operational mode as it is shown in Figure 9-3 and Table 9-1. Figure 9-3 presents
the multiplexor cell used for all ASRC input clocks. Table 9-1 shows the detailed clocks,
multiplexor control and data bits for each ASRC input clock. For the audio blocks clocks
that are directly conected to ASRC (without the multiplexor scheme) see Table 9-2.
In the non-real time streaming audio use case, the input sampling rate clock does not need
to be provided. Instead the ideal-ratio value conversion is set in the ASRC interface
registers. In this case only the output sampling rate clock must be provided, and the fixed
ratio of the input to the output in the register is used to perform the sample rate
conversion.
Audio subsystem
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
342
NXP Semiconductors

<!-- page 343 -->

Clock direction control
Clock Out
Clock In
Bit Clock
Audio Block
1
0
11
00
10
01
asrck_clock_x
ASRC
Multiplexor
From GPR register (in IOMUXC)
Figure 9-3. Muxing scheme template for ASRC input clocks
Table 9-1. ASRC Muxed Input Clocks
ASRC
Clock
Input
Audio
block
source
MUX2:1
Control
MUX2:1
Input 0
MUX2:1
Input 1
MUX4:1
Control
MUX4:1
Input 00
MUX4:1
Input 01
MUX4:1
Input 10
MUX4:1
Input 11
asrck_cloc
k_1
SAI1-Rx
SRCR[RX
DIR]1
External
SRCK
InternalSR
CK
GPR0[17:1
6]2
MUX2:1
output
External
SRCK
InternalSR
CK
RX bit
clock
asrck_cloc
k_4
SAI1-Rx
SRCR[RX
DIR]
External
SRCK
InternalSR
CK
GPR0[17:1
6]
MUX2:1
output
InternalSR
CK
InternalSR
CK
RX bit
clock
asrck_cloc
k_7
SAI2-Rx
SRCR[RX
DIR]
External
SRCK
InternalSR
CK
GPR0[19:1
8]
MUX2:1
output
External
SRCK
InternalSR
CK
RX bit
clock
asrck_cloc
k_9
SAI1-Tx
STCR[TXD
IR]
External
STCK
InternalST
CK
GPR0[19:1
8]
MUX2:1
output
External
STCK
InternalST
CK
TX bit
clock
asrck_cloc
k_c
SAI1-Tx
STCR[TXD
IR]
External
STCK
InternalST
CK
GPR0[21:2
0]
MUX2:1
output
External
STCK
InternalST
CK
TX bit
clock
asrck_cloc
k_d
spdif_clk_r
oot
STCR[TXD
IR]
External
STCK
InternalST
CK
GPR0[21:2
0]
MUX2:1
output
External
STCK
InternalST
CK
SPDIF bit
clock
asrck_cloc
k_e
SAI2-Tx
STCR[TXD
IR]
External
STCK
InternalST
CK
GPR0[23:2
2]
MUX2:1
output
External
STCK
InternalST
CK
TX bit
clock
1.
Register[bit] format, SRCR is the regsiter name in the block specified in the "Audio block source" column, while RXDIR is
name field/bit in the register.
Chapter 9 Multimedia
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
343

<!-- page 344 -->

2.
GPR0 is the General Register 0 in the IOMUX controller. See IOMUXC chapter for more details.
Table 9-2. ASRC Direct Clocks
ASRC Clock Input
Block driving clock source
Block output clock
asrck_clock_4
SPDIF (Rx)
SPDIF Rx Clock
asrck_clock_c
SPDIF (Tx)
SPDIF Tx Clock
asrck_clock_6
External (from PAD)
Via IOMUX (from PAD)
KEY_ROW3 (ALT1) [default]
GPIO_0 (ALT3)
GPIO_18 (ALT4)
asrck_clock_7
Reserved
Reserved1
asrck_clock_d
CCM
SPDIF1 clock root
1.
Not in used, the clock value is "0".
Audio subsystem
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
344
NXP Semiconductors

