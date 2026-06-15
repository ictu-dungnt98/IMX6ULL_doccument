# Chapter 19: CMOS Sensor Interface (CSI)

> Nguồn: `IMX6ULLRM.pdf` — trang 751–790

<!-- page 751 -->

Chapter 19
CMOS Sensor Interface (CSI)
19.1
Overview
This chapter presents the CMOS Sensor Interface (CSI) architecture, operation principles,
and programming model.
The CSI enables the chip to connect directly to external CMOS image sensors. CMOS
image sensors are separated into two classes, dumb and smart. Dumb sensors are those
that support only traditional sensor timing (Vertical SYNC and Horizontal SYNC) and
output only Bayer and statistics data, while smart sensors support CCIR656 video
decoder formats and perform additional processing of the image (for example, image
compression, image pre-filtering, and various data output formats).
The capabilities of the CSI include:
• Configurable interface logic to support most commonly available CMOS sensors.
• Support for CCIR656 video interface as well as traditional sensor interface.
• 8-bit / 16-bit / 24-bit data port for YCbCr, YUV, or RGB data input.
• 8-bit / 10-bit / 16-bit data port for Bayer data input.
• Full control of 8-bit/pixel, 10-bit/pixel or 16-bit / pixel data format to receive FIFO
packing.
• 256 x 64 FIFO to store received image pixel data.
• Reveive FIFO overrun protection mechanism.
• Embedded DMA controllers to transfer data from receive FIFO or statistic FIFO
through AHB bus.
• Support 2D DMA transfer from the receive FIFO to the frame buffers in the external
memory.
• Support double bufferring two frames in the external memory.
• Single interrupt source to interrupt controller from maskable interrupt sources: Start
of Frame, End of Frame, Change of Field, FIFO full, FIFO overrun, DMA transfer
done, CCIR error and AHB bus response error.
• Configurable master clock frequency output to sensor.
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
751

<!-- page 752 -->

• Statistic data generation for Auto Exposure (AE) and Auto White Balance (AWB)
control of the camera (only for Bayer data and 8-bit/pixel format).
• Supports simple deinterlacing of interlaced input.
19.2
External Signals
The table below describes the external signals for the CSI. The external signals are tied
between the CSI module and an external CMOS sensor.
Table 19-1. CSI External Signals
Signal
Description
Pad
Mode
Direction
DATA0
Data Sensor Signal 0, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
LCD_DATA17
ALT3
I
UART3_RX_DATA
ALT3
I
DATA1
Data Sensor Signal 1, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
LCD_DATA16
ALT3
I
UART3_TX_DATA
ALT3
I
DATA2
Data Sensor Signal 2, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
CSI_DATA00
ALT0
I
UART1_TX_DATA
ALT3
I
DATA3
Data Sensor Signal 3 part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
CSI_DATA01
ALT0
I
UART1_RX_DATA
ALT3
I
DATA4
Data Sensor Signal 4, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
CSI_DATA02
ALT0
I
UART1_CTS_B
ALT3
I
DATA5
Data Sensor Signal 5, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
CSI_DATA03
ALT0
I
UART1_RTS_B
ALT3
I
DATA6
Data Sensor Signal 6, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
CSI_DATA04
ALT0
I
UART2_TX_DATA
ALT3
I
DATA7
Data Sensor Signal 7 part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
CSI_DATA05
ALT0
I
UART2_RX_DATA
ALT3
I
DATA8
Data Sensor Signal 8, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
CSI_DATA06
ALT0
I
UART2_CTS_B
ALT3
I
DATA9
Data Sensor Signal 9 part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
CSI_DATA07
ALT0
I
UART2_RTS_B
ALT3
I
DATA10
Data Sensor Signal 10, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
LCD_DATA18
ALT3
I
UART3_CTS_B
ALT3
I
DATA11
Data Sensor Signal 11, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
LCD_DATA19
ALT3
I
UART3_RTS_B
ALT3
I
Table continues on the next page...
External Signals
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
752
NXP Semiconductors

<!-- page 753 -->

Table 19-1. CSI External Signals (continued)
Signal
Description
Pad
Mode
Direction
DATA12
Data Sensor Signal 12, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
LCD_DATA20
ALT3
I
UART4_TX_DATA
ALT3
I
DATA13
Data Sensor Signal 13, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
LCD_DATA21
ALT3
I
UART4_RX_DATA
ALT3
I
DATA14
Data Sensor Signal 14, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
LCD_DATA22
ALT3
I
UART5_TX_DATA
ALT3
I
DATA15
Data Sensor Signal 15, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
LCD_DATA23
ALT3
I
UART5_RX_DATA
ALT3
I
DATA16
Data Sensor Signal 16, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
ENET1_RX_DATA0
ALT3
I
LCD_DATA08
ALT3
I
DATA17
Data Sensor Signal 17 part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
ENET1_RX_DATA1
ALT3
I
LCD_DATA09
ALT3
I
DATA18
Data Sensor Signal 18, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
ENET1_RX_EN
ALT3
I
LCD_DATA10
ALT3
I
DATA19
Data Sensor Signal 19 part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
ENET1_TX_DATA0
ALT3
I
LCD_DATA11
ALT3
I
DATA20
Data Sensor Signal 20, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
ENET1_TX_DATA1
ALT3
I
LCD_DATA12
ALT3
I
DATA21
Data Sensor Signal 21, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
ENET1_TX_EN
ALT3
I
LCD_DATA13
ALT3
I
DATA22
Data Sensor Signal 22, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
ENET1_TX_CLK
ALT3
I
LCD_DATA14
ALT3
I
DATA23
Data Sensor Signal 23, part of 24-bit
Sensor Data Bus (Bayer, YUV,
YCrCb, RGB)
ENET1_RX_ER
ALT3
I
LCD_DATA15
ALT3
I
FIELD
CSI Field Signal
GPIO1_IO05
ALT3
I
NAND_DQS
ALT1
I
HSYNC
Horizontal Sync (Blank Signal)
CSI_HSYNC
ALT0
I
GPIO1_IO09
ALT3
I
MCLK
"CMOS Sensor Master Clock *Note:
MCLK is provided by the CCM
module directly, not from the CSI
module itself"
CSI_MCLK
ALT0
O
GPIO1_IO06
ALT3
O
PIXCLK
Pixel Clock
CSI_PIXCLK
ALT0
I
GPIO1_IO07
ALT3
I
VSYNC
Vertical Sync (Start Of Frame)
CSI_VSYNC
ALT0
I
Table continues on the next page...
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
753

<!-- page 754 -->

Table 19-1. CSI External Signals (continued)
Signal
Description
Pad
Mode
Direction
GPIO1_IO08
ALT3
I
19.3
Clocks
The following table describes the clock sources for CSI. Please see Clock Controller
Module (CCM) for clock setting, configuration and gating information.
Table 19-2. CSI Clocks
Clock name
Clock Root
Description
csi_hclk
ahb_clk_root
Module clock
ipg_clk
ipg_clk_root
Peripheral clock
ipg_clk_s
ipg_clk_root
Peripheral access clock
ipg_clk_s_raw
ipg_clk_root
Peripheral raw data clock
19.4
Principles of Operation
The information found here describes the modes of operation of the sensor interface.
The CSI is designed to support generic sensor interface timing as well as CCIR656 video
interface timing. Traditional CMOS sensors typically use VSYNC (SOF), HSYNC
(BLANK), and PIXCLK signals to output Bayer or YUV data. Smart CMOS sensors, that
come with on-chip imaging processing, usually support video mode transfer. They use an
embedded timing codec to replace the VSYNC and HSYNC signal. The timing codec is
defined by the CCIR656 standard.
The CSI can support connection with the sensor as follows.
• To connect with one 8-bit sensor, the sensor data interface should connect to
CSI_DATA[9:2].
• To connect with one 10-bit sensor, the sensor data interface should connect to
CSI_DATA[9:0].
• To connect with one 16-bit sensor, the sensor data interface should connect to
CSI_DATA[15:0].
Clocks
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
754
NXP Semiconductors

<!-- page 755 -->

• To connect with one 24-bit sensor, connect either the video pass-through, TV
Decoder input, or the sensor data interface to CSI_DATA[23:0].
• To connect with two 8-bit sensors, the sensor data interfaces should connect to
CSI_DATA[7:0] and CSI_DATA[15:8].
Table 19-3. CSI input data format
Signal
Name
TVdecode
r YCbCr 1
Cycle
RGB888 1
Cycle
RGB888/
YUV4444
3 Cycle
RGB666 1
Cycle
RGB565 1
Cycle
YCbCr422
1 Cycle
YCbCr422
2 Cycle
Generic
10 bit
CCIR656
ipp_csi_d[2
3]
Y[7]
R[7]
R[5]
ipp_csi_d[2
2]
Y[6]
R[6]
R[4]
ipp_csi_d[2
1]
Y[5]
R[5]
R[3]
ipp_csi_d[2
0]
Y[4]
R[4]
R[2]
ipp_csi_d[1
9]
Y[3]
R[3]
R[1]
ipp_csi_d[1
8]
Y[2]
R[2]
R[0]
ipp_csi_d[1
7]
Y[1]
R[1]
Y[5]
ipp_csi_d[1
6]
Y[0]
R[0]
R[4]
ipp_csi_d[1
5]
Cb[7]
G[7]
G[5]
R[4]
Y[7]
ipp_csi_d[1
4]
Cb[6]
G[6]
G[4]
R[3]
Y[6]
ipp_csi_d[1
3]
Cb[5]
G[5]
G[3]
R[2]
Y[5]
ipp_csi_d[1
2]
Cb[4]
G[4]
G[2]
R[1]
Y[4]
ipp_csi_d[1
1]
Cb[3]
G[3]
G[1]
R[0]
Y[3]
ipp_csi_d[1
0]
Cb[2]
G[2]
G[0]
G[5]
Y[2]
ipp_csi_d[9
]
Cb[1]
G[1]
R/G/B[7]
G[5]
G[4]
Y[1]
Y/C[7]
Ge[9]
C/Y[7]
ipp_csi_d[8
]
Cb[0]
G[0]
R/G/B[6]
G[4]
G[3]
Y[0]
Y/C[6]
Ge[8]
C/Y[6]
ipp_csi_d[7
]
Cr[7]
B[7]
R/G/B[5]
B[5]
G[2]
C[7]
Y/C[5]
Ge[7]
C/Y[5]
ipp_csi_d[6
]
Cr[6]
B[6]
R/G/B[4]
B[4]
G[1]
C[6]
Y/C[4]
Ge[6]
C/Y[4]
ipp_csi_d[5
]
Cr[5]
B[5]
R/G/B[3]
B[3]
G[0]
C[5]
Y/C[3]
Ge[5]
C/Y[3]
Table continues on the next page...
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
755

<!-- page 756 -->

Table 19-3. CSI input data format (continued)
Signal
Name
TVdecode
r YCbCr 1
Cycle
RGB888 1
Cycle
RGB888/
YUV4444
3 Cycle
RGB666 1
Cycle
RGB565 1
Cycle
YCbCr422
1 Cycle
YCbCr422
2 Cycle
Generic
10 bit
CCIR656
ipp_csi_d[4
]
Cr[4]
B[4]
R/G/B[2]
B[2]
B[4]
C[4]
Y/C[2]
Ge[4]
C/Y[2]
ipp_csi_d[3
]
Cr[3]
B[3]
R/G/B[1]
B[1]
B[3]
C[3]
Y/C[1]
Ge[3]
C/Y[1]
ipp_csi_d[2
]
Cr[2]
B[2]
R/G/B[0]
B[0]
B[2]
C[2]
Y/C[0]
Ge[2]
C/Y[0]
ipp_csi_d[1
]
Cr[1]
B[1]
B[5]
B[1]
C[1]
Ge[1]
ipp_csi_d[0
]
Cr[0]
B[0]
B[4]
B[0]
C[0]
Ge[0]
19.4.1
Data Transfer with the Embedded DMA Controllers
The CSI has two embedded DMA controllers, one for the receive FIFO and the other for
the statistic FIFO. It supports 2D DMA transfer from the receive FIFO to the frame
buffers in the external memory and linear DMA transfer from the statistic FIFO.
To transfer data from the RxFIFO to the external memory, the user should set the start
address in the frame buffer where the transferred data is stored, the parameters of the
frame buffers, and the parameters of the image coming from the sensor. The user can
have two frame buffers in the external memory. Each one will store a frame of image
coming from the sensor. The embedded DMA controller will first write the frame buffer1
and then frame buffer2. These two frame buffers will be written by turns. The start
address should be aligned in and set in the CSIDMASA-FB1 and CSIDMASA-FB2
registers. In the CSIFBUF_PARA register, the user should set the stride of the frame
buffer to show how many to skip before starting to write the next row of the image. In the
CSIIMAG_PARA register, the user should set the width and height of the image coming
from the sensor. The RxFF_LEVEL and DMA_REQ_EN_RFF bits in CSICR3 registers
also need to be set before the data transfer starts. When the number of the data in the
RxFIFO reaches the trigger level, a DMA request will be sent to the embedded DMA
controller and the data will be read out from the RxFIFO and written through AHB bus
into the external frame buffers. The burst type of transfer can be INCR4, INCR8 and
INCR16 by setting DMA_BURST_TYPE_RFF bits in CSICR2 register. After all data in
an image frame are transferred, the DMA_TSF_DONE_FB1 or DMA_TSF_DONE_FB2
bit will be set in CSISR register and the interrupt can be triggered if the corresponding
enable bit is set in CSICR1 register. The DMA_REFLASH_RFF bit in CSICR3 can be
used to activate or restart the embedded DMA controller.
Principles of Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
756
NXP Semiconductors

<!-- page 757 -->

The RxFIFO has the overrun protection mechanism in case the RxFIFO is overrun during
data transfer. If the RxFIFO is full and more data needs to be received during the data
transfer, the RxFIFO will be overwritten continuously and all 128 words of data in the
RxFIFO before overrun occurred will be discarded; the corresponding 128 words
memory space in the frame buffer will keep the previous values.
To transfer data from the statistic FIFO to the external memory, the user should set the
start address of the externl memory where the transferred data is stored and the total
transfer sizes. The start address and the transfer sizes are all aligned in and should be set
in the CSIDMASA-STATFIFO and CSIDMATS-STATFIFO registers. The
STATFF_LEVEL and DMA_REQ_EN_SFF bits in CSICR3 registers should also be set
before the data transfer starts. When the number of the data in the STATFIFO reaches the
trigger level, a dma request will be sent to the embedded DMA controller and the data
will be read out from the STATFIFO and written through AHB bus into the external
memory. The burst type of transfer can be INCR4, INCR8 and INCR16 by setting
DMA_BURST_TYPE_SFF bits in CSICR2 register. After all expected data (defined by
the total transfer sizes) are transferred, the DMA_TSF_DONE_SFF bit will be set in
CSISR register and an interrupt can be triggered if the SFF_DMA_DONE_INTEN is
enabled in CSICR1 register. The DMA_REFLASH_SFF bit in CSICR3 can be used to
activate or re-start the embedded DMA controller.
19.4.2
Gated Clock Mode
VSYNC, HSYNC, and PIXCLK signals are used in gated clock mode.
A frame starts with an active edge on VSYNC, then HSYNC asserts and holds for the
entire line. The Pixel clock is valid as long as HSYNC is asserted. Data is latched at the
active edge of the valid pixel clocks. HSYNC deasserts at the end of line. Pixel clocks
then become invalid and CSI stops receiving data from the stream. For the next line the
HSYNC timing repeats. For the next frame the VSYNC timing repeats.
19.4.3
Non-Gated Clock Mode
In non-gated clock mode, only the VSYNC and PIXCLK signals are used; the HSYNC
signal is ignored.
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
757

<!-- page 758 -->

DATA[23:00]
PIXCLK
VSYNC
invalid
n+1 Frame
n Frame
Start of Frame
invalid
Figure 19-1. Non-Gated Clock Mode Timing Diagram
The overall timing of non-gated mode is the same as the gated-clock mode, except for the
HSYNC signal. HSYNC signal is ignored by the CSI. All incoming pixel clocks are valid
and cause data to be latched into RxFIFO. The PIXCLK signal is inactive (states low)
until valid data is ready to be transmitted over the bus.
Figure 19-1 shows the timing of a typical sensor. Other sensors may have the slightly
different timing from that shown. The CSI can be programed to support rising/falling-
edge triggered VSYNC, active-high/low HSYNC, and rising/falling-edge triggered
PIXCLK.
19.4.4
CCIR656 Interlace Mode
In CCIR656 interlace mode, only the PIXCLK and CSI_DATA[9:2] signals are used.
The start of frame and blank signals are replaced by a timing codec which is embedded in
the data stream. Each active line starts with an Start of Active Video (SAV) code and
ends with an End of Active Video (EAV) code. In some cases, digital blanking is inserted
in between EAV and SAV code. The CSI decodes and filters out the timing-coding from
the data stream, recovering VSYNC and HSYNC signals for internal use, such as
statistical block control. Data is forwarded to the data receive and packing block in a
sequential manner without reordering-that is, field 1 followed by field 2. The fields must
be reordered in software to get back the original image.
Change of Field (COF) interrupt is triggered upon every field change. The interrupt
service routine reads the status register to check for the current field.
Principles of Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
758
NXP Semiconductors

<!-- page 759 -->

According to the CCIR656 specification, the image must be in 625/50 PAL or 525/60
NTSC format. In addition, the image is interlaced into odd and even fields with vertical
and horizontal blank data being filled into certain lines. Data must be in YCbCr422
format, each pixel contains 2 bytes, either Y + Cr or Y + Cb. These requirements are set
for TV systems. The CSI module supports PAL and NTSC format only.
The following figure describes the frame structure in PAL system, showing vertical and
horizontal blanking.
Figure 19-2. CCIR656 Interlace Mode (PAL)
The following figure describes the general timing for a single line, showing SAV and
EAV.
Figure 19-3. CCIR656 General Line Timing
The coding tables recommended by the CCIR656 specification are shown below. It is
used in the CCIR656 mode to decode the video stream. An interrupt is generated for
SOF, which is decoded from the embedded timing codec.
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
759

<!-- page 760 -->

Table 19-4. Coding for SAV and EAV
Data Bit Number
1st Byte
0xFF
2nd Byte
0x00
3rd Byte
0x00
4th Byte
0xXY
7 (MSB)
1
0
0
1
6
1
0
0
F
5
1
0
0
V
4
1
0
0
H
3
1
0
0
P3
2
1
0
0
P2
1
1
0
0
P1
0
1
0
0
P0
Table 19-5. Codes with Protection bits for Error Detection/Correction
F
V
H
P3
P2
P1
P0
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
0
1
0
1
0
1
0
1
1
0
1
1
0
1
1
0
1
0
0
0
1
1
1
1
0
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
0
0
1
1
1
0
0
0
1
Table 19-6. Representations by F-Bit
F-Bit
Representations
0
ODD FIELD (FIELD 1)
1
EVEN FIELD (FIELD 2)
19.4.5
CCIR656 Progressive Mode
For a CMOS camera system of VGA or CIF resolution, strict adherence to the interlace
requirements stated in the CIR standard is not required.
The image is considered to have only 1 active field which is scanned in a progressive
manner. This active field is regarded as field 1 and the F-bit in the timing codec is
ignored by the decoder. Most sensors support CCIR timing in this mode (progressive) by
default.
The following figure shows the typical flow of progressive mode.
Principles of Operation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
760
NXP Semiconductors

<!-- page 761 -->

Figure 19-4. CCIR656 Progressive Mode (General Case)
An interrupt is generated for SOF but not for COF. In the general case, when SOF
information is retrieved from the embedded coding, it is known as internal VSYNC
mode. In other cases, when the VSYNC signal is provided by the sensor, it is known as
external VSYNC mode. The CSI can be operated in internal or external VSYNC mode.
19.4.6
Error Correction for CCIR656 Coding
According to the algorithm for CCIR coding, protection bits in the SAV and EAV are
encoded in the way that allows a 1-bit error to be corrected, or a 2-bit error to be detected
by the decoder. This feature is supported by the interlace mode CCIR decoder in CSI.
For the 1-bit error case, users can select the error to be corrected automatically, or simply
shown as a status flag instead. For the 2-bit error case, because the decoder is unable to
make a correction, the error would be shown as a status flag only.
An interrupt can be generated upon the detection of an error. This signal can be enabled
or disabled without affecting the operation of the status bit.
19.4.7
Deinterlacer
Deinterlacing is the process of converting interlaced video, such as CCIR656 input, into a
non-interlaced form.
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
761

<!-- page 762 -->

The CSI uses the weaving method to do deinterlacing. Weaving is done by adding
consecutive fields together. CSI uses top-field detection function. No matter input is
NTSC or PAL mode, the combined frame will always put the top-field first and then
bottom-field.
19.5
Interrupt Generation
The information found here describes CSI events that generate interrupts.
19.5.1
Start Of Frame Interrupt (SOF_INT)
The source of an SOF interrupt is dependent on the mode of operation.
In traditional mode, VSYNC signal is taken from sensor and SOF_INT is generated at the
rising or falling edge (programmable) of VSYNC.
In CCIR interlace mode, the SOF interrupt information is retrieved from the embedded
coding and SOF_INT is generated.
In CCIR progressive mode, there are two sources of an SOF interrupt:
• In internal VSYNC mode, SOF is retrieved from the embedded coding.
• In external VSYNC mode, VSYNC is taken from the sensor and SOF is generated at
the rising edge of VSYNC.
19.5.2
End Of Frame Interrupt (EOF_INT)
An EOF interrupt is generated when the frame ends and the complete frame data in
RXFIFO is read.
The EOF event triggering works with the RX count register (CSIRXCNT). Software sets
the RX count register to the frame size (in words). The CSI RX logic then counts the
number of pixel data being received and compares it with the RX count. If the preset
value is reached, an EOF interrupt is generated and the data in the RXFIFO are read. If a
SOF event is detected before this happens, the EOF interrupt is not generated.
Interrupt Generation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
762
NXP Semiconductors

<!-- page 763 -->

19.5.3
Change Of Field Interrupt (COF_INT)
The Change of Field interrupt is only valid in CCIR Interlace mode. The COF interrupt is
generated when the field toggles, either from field 1 to field 2, or field 2 to field 1.
Software should first check COF_INT bit in the CSI Status Register (CSISTAT) before
checking that F1_INT or F2_INT is turned on.
In PAL systems, the field changes at the beginning of the frame and coincides with SOF.
For the first field, a COF interrupt is not generated, only an SOF. The COF interrupt is
generated for the second field.
19.5.4
CCIR Error Interrupt (ECC_INT)
The CCIR Error Interrupt is only valid for CCIR Interlace mode. An ECC interrupt is
generated when an error is found on the SAV or EAV codes in the incoming stream.
When this happens, the ECC_INT status bit is set.
19.5.5
RxFIFO Full Interrupt (RxFF_INT)
A RxFIFO full interrupt is generated when the number of data in RXFIFO reaches the
water mark defined by RxFF_LEVEL in CSICR3.
19.5.6
Statistic FIFO Full Interrupt (STATFF_INT)
A StatFIFO full interrupt is generated when the number of data in STATFIFO reaches the
water mark defined by STATFF_LEVEL in CSICR3.
19.5.7
RxFIFO Overrun Interrupt (RFF_OR_INT)
A RxFIFO Overrun interrupt is generated when the RxFIFO has 128 words data and
more data is being written in.
19.5.8
Statistic FIFO Overrun Interrupt (SFF_OR_INT)
A StatFIFO Overrun interrupt is generated when the STATFIFO has 64 words data and
more data is being written in.
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
763

<!-- page 764 -->

19.5.9
Frame Buffer1 DMA Transfer Done Interrupt
(DMA_TSF_DONE_FB1)
A DMA transfer done interrupt of frame buffer1 is generated when one frame of data are
transferred from RxFIFO to the frame buffer1 in the external memory.
19.5.10
Frame Buffer2 DMA Transfer Done Interrupt
(DMA_TSF_DONE_FB2)
A DMA transfer done interrupt of frame buffer2 is generated when one frame of data are
transferred from RxFIFO to the frame buffer2 in the external memory.
19.5.11
Statistic FIFO DMA Transfer Done Interrupt
(DMA_TSF_DONE_SFF)
A StatFIFO DMA transfer done interrupt is generated when all the data are transferred
from StatFIFO to the external memory. The transfer size is defined in the STATFIFO
DMA Transfer Size Register.
19.5.12
AHB Bus Response Error Interrupt (HRESP_ERR_INT)
An AHB Bus response error interrupt is generated when a bus error is detected.
19.5.13
DMA Field 0 Transfer Done Interrupt
(DMA_FIELD0_DONE)
A DMA transfer done interrupt of field 0 is generated when one field of data are
transferred from RxFIFO to the frame buffer in external memory. This signal should
work on interlaced mode.
Interrupt Generation
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
764
NXP Semiconductors

<!-- page 765 -->

19.5.14
DMA Field 1 Transfer Done Interrupt
(DMA_FIELD1_DONE)
A DMA transfer done interrupt of field 1 is generated when one field of data are
transferred from RxFIFO to the frame buffer in external memory. This signal should
work on interlaced mode.
19.5.15
Base Address Change Error Interrupt
(BASEADDR_CHANGE_ERROR)
A Base Address change error is generated when the base address changed while the last
frame data transfer are not finished.
19.6
Data Packing Style
Careful attention to endianess is needed given the different port sizes at different stages
of the image capture path.
To enable flexible packing of image data before storage in the FIFOs, the CSI module
can swap data fields by use of the PACK_DIR and the SWAP16_EN bit in CSI Control
Register 1 (CSICR1).
The CSI module accepts 8-bit, 10-bit or 16-bit data from the sensor by configuring
PIXEL_BIT bit in CSI Control Register 1 (CSICR1) and TWO_8BIT_SENSOR bit in
CSI Control Register3 (CSICR3). The input data is packed according to the setting of
PACK_DIR bit. The packed data is stored in the RX FIFO according to the setting of the
SWAP16_EN bit.
For 10-bit per pixel data format, each pixel is expanded to 16 bits by appending 6 zeros
bits to the most significant bit. For 16-bit data format, the data path can be a combination
by two 8-bit sensors. One sensor is connected to the CSI_DATA[7:0]. The other sensor is
connected to CSI_DATA[15:8].
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
765

<!-- page 766 -->

RX FIFO Path
19.6.1.1
Bayer Data
Bayer data is a type of raw data from the image sensor. This byte-wide data must be
converted to the RGB space or YUV space by software. The data path for Bayer data is
from the CSI to memory. If the system is in little endian, then the PACK_DIR bit should
be set to 0. 8-bit data format from a sensor is packed to bits as , where P0 is the pixel
coming in time slot 0 (first data) and P3 is the pixel coming in time slot 3 (the last data in
the word). When the data is addressed as bytes by software, P0 is transferred first, P1 is
transferred next, and so on. 10-bit data format is packed to bits as , where P0 is the 10-bit
data coming in time slot 0 (first pixel) and is the 10-bit data coming in time ( pixel). 16-
bit data, from two sensors, is packed to bits as , where P0 and P1 are the two 8-bit data
coming in time slot 0 (P0 is the first pixel of the sensor connected with CSI_DATA[7:0]
and P1 is the first pixel of the sensor connected with CSI_DATA[15:8]). P2 and P3 are
the two 8-bit data coming in time slot 1 (second pixels of the two sensors).
19.6.1.2
RGB565 Data
RGB565 data is processed data from the image sensor, which can be put directly into the
display buffer. The data is 16 bits wide. The data path is from CSI to memory to the
display controller. On the sensor side, data must be transmitted as P0 first, followed by
P1, and so on. For each pixel, whether the MSB or LSB is sent first depends on the
endianness of the sensor. Data is 16 bits wide with the MSB labeled RG, and the LSB
labeled GB. P0 is represented as RG0 and GB0.
CSI receives data in one of the following sequence:
• RG0, GB0, RG1, GB1, while RG0 comes out at time slot 0 (first data), and GB1
comes out at time slot 3 (last data)
• GB0, RG0, GB1, RG1
Using the first sequence as an example, and assuming the system is running in little
endian, the data is presented as:
• 8-bit data from sensor: RG0, GB0, RG1, GB1, …
• data before storage in the CSI RX FIFO (PACK_DIR bit = 1):
• data in CSI RX FIFO (SWAP16_EN bit enabled):
• transfer to system memory:
• 16-bit read by display controller: RG0GB0, RG1GB1
19.6.1
RX FIFO Path
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
766
NXP Semiconductors

<!-- page 767 -->

19.6.1.3
RGB888 Data
This is another kind of processed data from image sensor, which can be used for further
image processing directly. Each of the data consist of 8-bit Red, 8-bit Green, and 8-bit
Blue data. An example of timing scheme is shown in the following figure.
Figure 19-5. Sample Timing Diagram for RGB888 8 bits/cycle Data
R0G0B0 R1G1B1 R2G2B2
R3G3B3 R4G4B4 R5G5B5
B0G0R0 B1G1R1 B2G2R2
B3G3R3 B4G4R4 B5G5R5
PIXCLK
FORMAT1
FORMAT2
Figure 19-6. Sample Timing Diagram for RGB888 24 bits/cycle Data
An optional scheme to pack a dummy byte is provided. For every group of 3 bytes data, a
dummy zero is packed to form a 32-bit word as shown in the following figure. The
dummy zero can be packed at the LSB position or MSB position. Using
RGB888A_FORMAT_SEL in CSI_CSICR18[18] to determine to put the dummy bytes
packed at LSB or MSB position.
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
767

<!-- page 768 -->

Fi
O
i
l D
B
P
ki
S h
RX FIFO Path
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
768
NXP Semiconductors

<!-- page 769 -->

19.6.2
STAT FIFO Path
Statistics only works for Bayer data in 8-bit per pixel format. It generates 16-bit statistical
output from the 8-bit Bayer input (CSI_DATA[13:6]). The outputs are Sum of Green (G),
Sum of Red (R), Sum of Blue (B), and Auto Focus (F). Each output is 16-bits wide.
The settings of PACK_DIR and SWAP16_EN bits in the CSICR1 register have no effect
on the input path. The PACK_DIR only controls how the 16-bit stat output is packed into
the 32-bit STAT FIFO.
When the PACK_DIR bit = 1, the stat data is packed as:
First 32-bit: RG
Second 32-bit: BF
…
When the PACK_DIR bit = 0, the stat data is packed as:
First 32-bit GR
Second 32-bit: FB
...
19.7
CSI Memory Map/Register Definition
All the 32-bit registers of the CSI module are summarized in the Memory Map below:
CSI memory map
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
21C_4000
CSI Control Register 1 (CSI_CSICR1)
32
R/W
4000_0800h
19.7.1/771
21C_4004
CSI Control Register 2 (CSI_CSICR2)
32
R/W
0000_0000h
19.7.2/775
21C_4008
CSI Control Register 3 (CSI_CSICR3)
32
R/W
0000_0000h
19.7.3/777
21C_400C
CSI Statistic FIFO Register (CSI_CSISTATFIFO)
32
R
0000_0000h
19.7.4/779
21C_4010
CSI RX FIFO Register (CSI_CSIRFIFO)
32
R
0000_0000h
19.7.5/780
21C_4014
CSI RX Count Register (CSI_CSIRXCNT)
32
R/W
0000_9600h
19.7.6/780
21C_4018
CSI Status Register (CSI_CSISR)
32
R/W
0000_4000h
19.7.7/781
Table continues on the next page...
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
769

<!-- page 770 -->

CSI memory map (continued)
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
21C_4020
CSI DMA Start Address Register - for STATFIFO
(CSI_CSIDMASA_STATFIFO)
32
R/W
0000_0000h
19.7.8/784
21C_4024
CSI DMA Transfer Size Register - for STATFIFO
(CSI_CSIDMATS_STATFIFO)
32
R/W
0000_0000h
19.7.9/784
21C_4028
CSI DMA Start Address Register - for Frame Buffer1
(CSI_CSIDMASA_FB1)
32
R/W
0000_0000h
19.7.10/
785
21C_402C
CSI DMA Transfer Size Register - for Frame Buffer2
(CSI_CSIDMASA_FB2)
32
R/W
0000_0000h
19.7.11/
786
21C_4030
CSI Frame Buffer Parameter Register
(CSI_CSIFBUF_PARA)
32
R/W
0000_0000h
19.7.12/
786
21C_4034
CSI Image Parameter Register (CSI_CSIIMAG_PARA)
32
R/W
0000_0000h
19.7.13/
787
21C_4048
CSI Control Register 18 (CSI_CSICR18)
32
R/W
0002_D000h
19.7.14/
788
21C_404C
CSI Control Register 19 (CSI_CSICR19)
32
R/W
0000_0000h
19.7.15/
790
CSI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
770
NXP Semiconductors

<!-- page 771 -->

19.7.1
CSI Control Register 1 (CSI_CSICR1)
This register controls the sensor interface timing and interrupt generation. The interrupt
enable bits in this register control the interrupt signals and the status bits. That means
status bits will only function when the corresponding interrupt bits are enabled.
Address: 21C_4000h base + 0h offset = 21C_4000h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
SWAP16_EN
EXT_VSYNC
EOF_
INT_
EN
PrP_IF_EN
VIDEO_MODE
COF_INT_EN
SF_OR_INTEN
RF_OR_INTEN
Reserved
SFF_DMA_DONE_INTEN
STATFF_INTEN
FB2_DMA_DONE_INTEN
FB1_DMA_DONE_INTEN
RXFF_INTEN
SOF_
POL
SOF_INTEN
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
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
Reserved
HSYNC_POL
CCIR_EN
Reserved
FCC
PACK_DIR
CLR_STATFIFO
CLR_RXFIFO
GCLK_MODE
INV_DATA
INV_PCLK
REDGE
PIXEL_BIT
W
Reset
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
CSI_CSICR1 field descriptions
Field
Description
31
SWAP16_EN
SWAP 16-Bit Enable. This bit enables the swapping of 16-bit data. Data is packed from 8-bit or 10-bit to
32-bit first (according to the setting of PACK_DIR) and then swapped as 16-bit words before being put into
the RX FIFO. The action of the bit only affects the RX FIFO and has no affect on the STAT FIFO.
NOTE: Example of swapping enabled:
Data input to FIFO = 0x11223344
Data in RX FIFO = 0x 33441122
NOTE: Example of swapping disabled:
Data input to FIFO = 0x11223344
Data in RX FIFO = 0x11223344
Table continues on the next page...
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
771

<!-- page 772 -->

CSI_CSICR1 field descriptions (continued)
Field
Description
0
Disable swapping
1
Enable swapping
30
EXT_VSYNC
External VSYNC Enable. This bit controls the operational VSYNC mode.
NOTE: This only works when the CSI is in CCIR progressive mode.
0
Internal VSYNC mode
1
External VSYNC mode
29
EOF_INT_EN
End-of-Frame Interrupt Enable. This bit enables and disables the EOF interrupt.
0
EOF interrupt is disabled.
1
EOF interrupt is generated when RX count value is reached.
28
PrP_IF_EN
CSI-PrP Interface Enable. This bit controls the CSI to PrP bus. When enabled the RxFIFO is detached
from the AHB bus and connected to PrP. All CPU reads or DMA accesses to the RxFIFO register are
ignored. All CSI interrupts are also masked.
0
CSI to PrP bus is disabled
1
CSI to PrP bus is enabled
27
VIDEO_MODE
Video mode select. This bit controls the video mode in CCIR mode.
0
Progressive mode is selected
1
Interlace mode is selected
26
COF_INT_EN
Change Of Image Field (COF) Interrupt Enable. This bit enables the COF interrupt.
This bit works only in CCIR interlace mode which is when CCIR_EN = 1 and CCIR_MODE = 1.
0
COF interrupt is disabled
1
COF interrupt is enabled
25
SF_OR_INTEN
STAT FIFO Overrun Interrupt Enable. This bit enables the STATFIFO overrun interrupt.
0
STATFIFO overrun interrupt is disabled
1
STATFIFO overrun interrupt is enabled
24
RF_OR_INTEN
RxFIFO Overrun Interrupt Enable. This bit enables the RX FIFO overrun interrupt.
0
RxFIFO overrun interrupt is disabled
1
RxFIFO overrun interrupt is enabled
23
-
This field is reserved.
Reserved. This bit is reserved and should read 0.
22
SFF_DMA_
DONE_INTEN
STATFIFO DMA Transfer Done Interrupt Enable. This bit enables the interrupt of STATFIFO DMA transfer
done.
0
STATFIFO DMA Transfer Done interrupt disable
1
STATFIFO DMA Transfer Done interrupt enable
21
STATFF_INTEN
STATFIFO Full Interrupt Enable. This bit enables the STAT FIFO interrupt.
0
STATFIFO full interrupt disable
1
STATFIFO full interrupt enable
20
FB2_DMA_
DONE_INTEN
Frame Buffer2 DMA Transfer Done Interrupt Enable. This bit enables the interrupt of Frame Buffer2 DMA
transfer done.
Table continues on the next page...
CSI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
772
NXP Semiconductors

<!-- page 773 -->

CSI_CSICR1 field descriptions (continued)
Field
Description
0
Frame Buffer2 DMA Transfer Done interrupt disable
1
Frame Buffer2 DMA Transfer Done interrupt enable
19
FB1_DMA_
DONE_INTEN
Frame Buffer1 DMA Transfer Done Interrupt Enable. This bit enables the interrupt of Frame Buffer1 DMA
transfer done.
0
Frame Buffer1 DMA Transfer Done interrupt disable
1
Frame Buffer1 DMA Transfer Done interrupt enable
18
RXFF_INTEN
RxFIFO Full Interrupt Enable. This bit enables the RxFIFO full interrupt.
0
RxFIFO full interrupt disable
1
RxFIFO full interrupt enable
17
SOF_POL
SOF Interrupt Polarity. This bit controls the condition that generates an SOF interrupt.
0
SOF interrupt is generated on SOF falling edge
1
SOF interrupt is generated on SOF rising edge
16
SOF_INTEN
Start Of Frame (SOF) Interrupt Enable. This bit enables the SOF interrupt.
0
SOF interrupt disable
1
SOF interrupt enable
15–12
Reserved
This field is reserved.
Reserved.
This field is reserved.
11
HSYNC_POL
HSYNC Polarity Select. This bit controls the polarity of HSYNC.
This bit only works in gated-clock-that is, GCLK_MODE = 1 and CCIR_EN = 0.
0
HSYNC is active low
1
HSYNC is active high
10
CCIR_EN
CCIR656 Interface Enable. This bit selects the type of interface used. When the CCIR656 timing decoder
is enabled, it replaces the function of timing interface logic.
0
Traditional interface is selected. Timing interface logic is used to latch data.
1
CCIR656 interface is selected.
9
Reserved
This field is reserved.
This field is reserved.
8
FCC
FIFO Clear Control. This bit determines how the RXFIFO and STATFIFO are cleared. When Synchronous
FIFO clear is selected the RXFIFO and STATFIFO are cleared, and STAT block is reset, on every SOF.
FIFOs and STAT block restarts immediately after reset. For information on the operation when
Asynchronous FIFO clear is selected, refer to the descriptions for the CLR_RXFIFO and CLR_STATFIFO
bits.
0
Asynchronous FIFO clear is selected.
1
Synchronous FIFO clear is selected.
7
PACK_DIR
Data Packing Direction. This bit Controls how 8-bit/10-bit image data is packed into 32-bit RX FIFO, and
how 16-bit statistical data is packed into 32-bit STAT FIFO.
0
Pack from LSB first. For image data, 0x11, 0x22, 0x33, 0x44, it will appear as 0x44332211 in RX
FIFO. For stat data, 0xAAAA, 0xBBBB, it will appear as 0xBBBBAAAA in STAT FIFO.
1
Pack from MSB first. For image data, 0x11, 0x22, 0x33, 0x44, it will appear as 0x11223344 in RX
FIFO. For stat data, 0xAAAA, 0xBBBB, it will appear as 0xAAAABBBB in STAT FIFO.
Table continues on the next page...
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
773

<!-- page 774 -->

CSI_CSICR1 field descriptions (continued)
Field
Description
6
CLR_STATFIFO
Asynchronous STATFIFO Clear. This bit clears the STATFIFO and Reset STAT block.
This bit works only in async FIFO clear mode-that is, FCC = 0. Otherwise this bit is ignored.
Writing 1 will clear STATFIFO and reset STAT block immediately, STATFIFO and STAT block then wait
and restart after the arrival of next SOF.
The bit is restored to 0 automatically after finish. Normally reads 0.
5
CLR_RXFIFO
Asynchronous RXFIFO Clear. This bit clears the RXFIFO.
This bit works only in async FIFO clear mode-that is, FCC = 0. Otherwise this bit is ignored.
Writing 1 clears the RXFIFO immediately, RXFIFO restarts immediately after that.
The bit is restored to 0 automatically after finish. Normally reads 0.
4
GCLK_MODE
Gated Clock Mode Enable. Controls if CSI is working in gated or non-gated mode.
This bit works only in traditional mode-that is, CCIR_EN = 0. Otherwise this bit is ignored.
0
Non-gated clock mode. All incoming pixel clocks are valid. HSYNC is ignored.
1
Gated clock mode. Pixel clock signal is valid only when HSYNC is active.
3
INV_DATA
Invert Data Input. This bit enables or disables internal inverters on the data lines.
0
CSI_D[7:0] data lines are directly applied to internal circuitry
1
CSI_D[7:0] data lines are inverted before applied to internal circuitry
2
INV_PCLK
Invert Pixel Clock Input. This bit determines if the Pixel Clock (CSI_PIXCLK) is inverted before it is applied
to the CSI module.
0
CSI_PIXCLK is directly applied to internal circuitry
1
CSI_PIXCLK is inverted before applied to internal circuitry
1
REDGE
Valid Pixel Clock Edge Select. Selects which edge of the CSI_PIXCLK is used to latch the pixel data.
0
Pixel data is latched at the falling edge of CSI_PIXCLK
1
Pixel data is latched at the rising edge of CSI_PIXCLK
0
PIXEL_BIT
Pixel Bit. This bit indicates the bayer data width for each pixel. This bit should be configured before
activating or re-starting the embedded DMA controller.
0
8-bit data for each pixel
1
10-bit data for each pixel
CSI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
774
NXP Semiconductors

<!-- page 775 -->

19.7.2
CSI Control Register 2 (CSI_CSICR2)
This register provides the statistic block with data about which live view resolution is
being used, and the starting sensor pixel of the Bayer pattern. It also contains the
horizontal and vertical count used to determine the number of pixels to skip between the
64 x 64 blocks of statistics when generating statistics on live view image that are greater
than 512 x 384.
Address: 21C_4000h base + 4h offset = 21C_4004h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
DMA_
BURST_
TYPE_RFF
DMA_
BURST_
TYPE_SFF
Reserved
DRM
AFS
SCE
Reserved
BTS
LVRM
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
VSC
HSC
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
CSI_CSICR2 field descriptions
Field
Description
31–30
DMA_BURST_
TYPE_RFF
Burst Type of DMA Transfer from RxFIFO. Selects the burst type of DMA transfer from RxFIFO.
X0
INCR8
01
INCR4
11
INCR16
29–28
DMA_BURST_
TYPE_SFF
Burst Type of DMA Transfer from STATFIFO. Selects the burst type of DMA transfer from STATFIFO.
X0
INCR8
01
INCR4
11
INCR16
Table continues on the next page...
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
775

<!-- page 776 -->

CSI_CSICR2 field descriptions (continued)
Field
Description
27
-
This field is reserved.
Reserved. These bit is reserved and should read 0.
26
DRM
Double Resolution Mode. Controls size of statistics grid.
0
Stats grid of 8 x 6
1
Stats grid of 8 x 12
25–24
AFS
Auto Focus Spread. Selects which green pixels are used for auto-focus.
00
Abs Diff on consecutive green pixels
01
Abs Diff on every third green pixels
1x
Abs Diff on every four green pixels
23
SCE
Skip Count Enable. Enables or disables the skip count feature.
0
Skip count disable
1
Skip count enable
22–21
-
This field is reserved.
Reserved. These bits are reserved and should read 0.
20–19
BTS
Bayer Tile Start. Controls the Bayer pattern starting point.
00
GR
01
RG
10
BG
11
GB
18–16
LVRM
Live View Resolution Mode. Selects the grid size used for live view resolution.
0
512 x 384
1
448 x 336
2
384 x 288
3
384 x 256
4
320 x 240
5
288 x 216
6
400 x 300
15–8
VSC
Vertical Skip Count. Contains the number of rows to skip.
SCE must be 1, otherwise VSC is ignored.
0-255
Number of rows to skip minus 1
HSC
Horizontal Skip Count. Contains the number of pixels to skip.
SCE must be 1, otherwise HSC is ignored.
0-255
Number of pixels to skip minus 1
CSI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
776
NXP Semiconductors

<!-- page 777 -->

19.7.3
CSI Control Register 3 (CSI_CSICR3)
This read/write register acts as an extension of the functionality of the CSI Control
register 1, adding additional control and features.
Address: 21C_4000h base + 8h offset = 21C_4008h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
FRMCNT
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
FRMCNT_RST
DMA_REFLASH_
RFF
DMA_REFLASH_
SFF
DMA_REQ_EN_
RFF
DMA_REQ_EN_
SFF
STATFF_LEVEL
HRESP_ERR_
EN
RxFF_LEVEL
TWO_8BIT_
SENSOR
ZERO_PACK_
EN
ECC_INT_EN
ECC_AUTO_EN
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
CSI_CSICR3 field descriptions
Field
Description
31–16
FRMCNT
Frame Counter. This is a 16-bit Frame Counter
(Wraps around automatically after reaching the maximum)
15
FRMCNT_RST
Frame Count Reset. Resets the Frame Counter. (Cleared automatically after reset is done)
0
Do not reset
1
Reset frame counter immediately
14
DMA_REFLASH_
RFF
Reflash DMA Controller for RxFIFO. This bit reflash the embedded DMA controller for RxFIFO. It should
be reflashed before the embedded DMA controller starts to work. (Cleared automatically after reflashing is
done)
0
No reflashing
1
Reflash the embedded DMA controller
13
DMA_REFLASH_
SFF
Reflash DMA Controller for STATFIFO. This bit reflash the embedded DMA controller for STATFIFO. It
should be reflashed before the embedded DMA controller starts to work. (Cleared automatically after
reflashing is done)
0
No reflashing
1
Reflash the embedded DMA controller
Table continues on the next page...
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
777

<!-- page 778 -->

CSI_CSICR3 field descriptions (continued)
Field
Description
12
DMA_REQ_EN_
RFF
DMA Request Enable for RxFIFO. This bit enables the dma request from RxFIFO to the embedded DMA
controller.
0
Disable the dma request
1
Enable the dma request
11
DMA_REQ_EN_
SFF
DMA Request Enable for STATFIFO. This bit enables the dma request from STATFIFO to the embedded
DMA controller.
0
Disable the dma request
1
Enable the dma request
10–8
STATFF_LEVEL
STATFIFO Full Level. When the number of data in STATFIFO reach this level, STATFIFO full interrupt is
generated, or STATFIFO DMA request is sent.
000
4
001
8
010
12
011
16
100
24
101
32
110
48
111
64
7
HRESP_ERR_
EN
Hresponse Error Enable. This bit enables the hresponse error interrupt.
0
Disable hresponse error interrupt
1
Enable hresponse error interrupt
6–4
RxFF_LEVEL
RxFIFO Full Level. When the number of data in RxFIFO reaches this level, a RxFIFO full interrupt is
generated, or an RXFIFO DMA request is sent.
000
4
001
8
010
16
011
24
100
32
101
48
110
64
111
96
3
TWO_8BIT_
SENSOR
Two 8-bit Sensor Mode. This bit indicates one 16-bit sensor or two 8-bit sensors are connected to the 16-
bit data ports. This bit should be set if there is one 16-bit sensor or two 8-bit sensors are connected. This
bit should be configured before activating or restarting the embedded DMA controller.
0
Only one sensor is connected.
1
Two 8-bit sensors are connected or one 16-bit sensor is connected.
2
ZERO_PACK_
EN
Dummy Zero Packing Enable. This bit causes a dummy zero to be packed with every 3 incoming bytes,
forming a 32-bit word. The dummy zero is always packed to the LSB position. This packing function is only
available in 8-bit/pixel mode.
0
Zero packing disabled
1
Zero packing enabled
Table continues on the next page...
CSI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
778
NXP Semiconductors

<!-- page 779 -->

CSI_CSICR3 field descriptions (continued)
Field
Description
1
ECC_INT_EN
Error Detection Interrupt Enable. This bit enables and disables the error detection interrupt. This feature
only works in CCIR interlace mode.
0
No interrupt is generated when error is detected. Only the status bit ECC_INT is set.
1
Interrupt is generated when error is detected.
0
ECC_AUTO_EN
Automatic Error Correction Enable. This bit enables and disables the automatic error correction. If an error
occurs and error correction is disabled only the ECC_INT status bit is set. This feature only works in CCIR
interlace mode.
0
Auto Error correction is disabled.
1
Auto Error correction is enabled.
19.7.4
CSI Statistic FIFO Register (CSI_CSISTATFIFO)
The StatFIFO is a read-only register containing statistic data from the sensor. Writing to
this register has no effect.
Address: 21C_4000h base + Ch offset = 21C_400Ch
Bit
31
30
29
28
27
26
25
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
STAT
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
CSI_CSISTATFIFO field descriptions
Field
Description
STAT
Static data from sensor
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
779

<!-- page 780 -->

19.7.5
CSI RX FIFO Register (CSI_CSIRFIFO)
This read-only register contains received image data. Writing to this register has no
effect.
Address: 21C_4000h base + 10h offset = 21C_4010h
Bit
31
30
29
28
27
26
25
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
IMAGE
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
CSI_CSIRFIFO field descriptions
Field
Description
IMAGE
Received image data
19.7.6
CSI RX Count Register (CSI_CSIRXCNT)
This register works for EOF interrupt generation. It should be set to the number of words
to receive that would generate an EOF interrupt.
There is an internal counter that counts the number of words read from the RX FIFO.
Whenever the RX FIFO is being read, by either the CPU or the embedded DMA
controller, the counter value is updated and compared with this register. If the values
match, then an EOF interrupt is triggered.
Address: 21C_4000h base + 14h offset = 21C_4014h
Bit
31
30
29
28
27
26
25
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
RXCNT
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
0
0
0
0
0
CSI_CSIRXCNT field descriptions
Field
Description
31–22
-
This field is reserved.
Reserved. These bits are reserved and should read 0.
RXCNT
RxFIFO Count. This 22-bit counter for RXFIFO is updated each time the RXFIFO is read by CPU or
DMA.This counter should be set to the expected number of words to receive that would generate an EOF
interrupt.
CSI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
780
NXP Semiconductors

<!-- page 781 -->

19.7.7
CSI Status Register (CSI_CSISR)
This read/write register shows sensor interface status, and which kind of interrupt is being
generated. The corresponding interrupt bits must be set for the status bit to function.
Status bits should function normally even if the corresponding interrupt enable bits are
not enabled.
Address: 21C_4000h base + 18h offset = 21C_4018h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
-
BASEADDR_CHHANGE_
ERROR
DMA_FIELD0_DONE
DMA_FIELD1_DONE
SF_OR_INT
RF_OR_INT
Reserved
DMA_TSF_DONE_SFF
STATFF_INT
DMA_TSF_DONE_FB2
DMA_TSF_DONE_FB1
RxFF_INT
EOF_INT
SOF_INT
W
-
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
F2_
INT
F1_
INT
COF_INT
Reserved
HRESP_ERR_INT
Reserved
ECC_INT
DRDY
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
0
0
0
0
CSI_CSISR field descriptions
Field
Description
31–29
-
Reserved. These bits are reserved and should read 0.
28
BASEADDR_
CHHANGE_
ERROR
When using base address switching enable, this bit will be 1 when switching occur before DMA complete.
This bit will be clear by writing 1.
When this interrupt happens, follow the steps listed below.
1. Unassert the CSI enable, CSIx_CSICR18 bit31,
2. Reflash the DMA, assert the CSIX_CSICR3 bit 14,
3. Assert the CSI enable, CSIx_CSICR18 bit31.
27
DMA_FIELD0_
DONE
When DMA field 0 is complete, this bit will be set to 1(clear by writing 1).
Table continues on the next page...
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
781

<!-- page 782 -->

CSI_CSISR field descriptions (continued)
Field
Description
26
DMA_FIELD1_
DONE
When DMA field 0 is complete, this bit will be set to 1(clear by writing 1).
25
SF_OR_INT
STATFIFO Overrun Interrupt Status. Indicates the overflow status of the STATFIFO register. (Cleared by
writing 1)
0
STATFIFO has not overflowed.
1
STATFIFO has overflowed.
24
RF_OR_INT
RxFIFO Overrun Interrupt Status. Indicates the overflow status of the RxFIFO register. (Cleared by writing
1)
0
RXFIFO has not overflowed.
1
RXFIFO has overflowed.
23
-
This field is reserved.
Reserved. This bit is reserved and should read 0.
22
DMA_TSF_
DONE_SFF
DMA Transfer Done from StatFIFO. Indicates that the dma transfer from StatFIFO is completed. It can
trigger an interrupt if the corresponding enable bit is set in CSICR1. This bit can be cleared by writting 1 or
reflashing the StatFIFO dma controller in CSICR3.(Cleared by writing 1)
0
DMA transfer is not completed.
1
DMA transfer is completed.
21
STATFF_INT
STATFIFO Full Interrupt Status. Indicates the number of data in the STATFIFO reaches the trigger level.
(this bit is cleared automatically by reading the STATFIFO)
0
STATFIFO is not full.
1
STATFIFO is full.
20
DMA_TSF_
DONE_FB2
DMA Transfer Done in Frame Buffer2. Indicates that the DMA transfer from RxFIFO to Frame Buffer2 is
completed. It can trigger an interrupt if the corresponding enable bit is set in CSICR1. This bit can be
cleared by by writting 1 or reflashing the RxFIFO dma controller in CSICR3. (Cleared by writing 1)
0
DMA transfer is not completed.
1
DMA transfer is completed.
19
DMA_TSF_
DONE_FB1
DMA Transfer Done in Frame Buffer1. Indicates that the DMA transfer from RxFIFO to Frame Buffer1 is
completed. It can trigger an interrupt if the corresponding enable bit is set in CSICR1. This bit can be
cleared by by writting 1 or reflashing the RxFIFO dma controller in CSICR3. (Cleared by writing 1)
0
DMA transfer is not completed.
1
DMA transfer is completed.
18
RxFF_INT
RXFIFO Full Interrupt Status. Indicates the number of data in the RxFIFO reaches the trigger level. (this
bit is cleared automatically by reading the RxFIFO)
0
RxFIFO is not full.
1
RxFIFO is full.
17
EOF_INT
End of Frame (EOF) Interrupt Status. Indicates when EOF is detected. (Cleared by writing 1)
0
EOF is not detected.
1
EOF is detected.
16
SOF_INT
Start of Frame Interrupt Status. Indicates when SOF is detected. (Cleared by writing 1)
Table continues on the next page...
CSI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
782
NXP Semiconductors

<!-- page 783 -->

CSI_CSISR field descriptions (continued)
Field
Description
0
SOF is not detected.
1
SOF is detected.
15
F2_INT
CCIR Field 2 Interrupt Status. Indicates the presence of field 2 of video in CCIR mode. (Cleared
automatically when current field does not match)
NOTE: Only works in CCIR Interlace mode.
0
Field 2 of video is not detected
1
Field 2 of video is about to start
14
F1_INT
CCIR Field 1 Interrupt Status. Indicates the presence of field 1 of video in CCIR mode. (Cleared
automatically when current field does not match)
NOTE: Only works in CCIR Interlace mode.
0
Field 1 of video is not detected.
1
Field 1 of video is about to start.
13
COF_INT
Change Of Field Interrupt Status. Indicates that a change of the video field has been detected.
Only works in CCIR Interlace mode. Software should read this bit first and then dispatch the new field from
F1_INT and F2_INT. (Cleared by writing 1)
0
Video field has no change.
1
Change of video field is detected.
12–8
-
This field is reserved.
Reserved. These bits are reserved and should read 0.
7
HRESP_ERR_
INT
Hresponse Error Interrupt Status. Indicates that a hresponse error has been detected. (Cleared by writing
1)
0
No hresponse error.
1
Hresponse error is detected.
6–2
-
This field is reserved.
Reserved. These bits are reserved and should read 0.
1
ECC_INT
CCIR Error Interrupt. This bit indicates an error has occurred. This only works in CCIR Interlace mode.
(Cleared by writing 1)
0
No error detected
1
Error is detected in CCIR coding
0
DRDY
RXFIFO Data Ready. Indicates the presence of data that is ready for transfer in the RxFIFO. (Cleared
automatically by reading FIFO)
0
No data (word) is ready
1
At least 1 datum (word) is ready in RXFIFO.
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
783

<!-- page 784 -->

19.7.8
CSI DMA Start Address Register - for STATFIFO
(CSI_CSIDMASA_STATFIFO)
This register provides the start address for the embedded DMA controller of STATFIFO.
The embedded DMA controller will read data from STATFIFO and write it to the
external memory from the start address. This register should be configured before
activating or restarting the embedded DMA controller.
Address: 21C_4000h base + 20h offset = 21C_4020h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
DMA_START_ADDR_SFF
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
DMA_START_ADDR_SFF
Reserved
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
CSI_CSIDMASA_STATFIFO field descriptions
Field
Description
31–2
DMA_START_
ADDR_SFF
DMA Start Address for STATFIFO. Indicates the start address to write data. The embedded DMA
controller will read data from STATFIFO and write it from this address through AHB bus. The address
should be aligned.
-
This field is reserved.
Reserved. These bits are reserved and should read 0.
19.7.9
CSI DMA Transfer Size Register - for STATFIFO
(CSI_CSIDMATS_STATFIFO)
This register provides the total transfer size for the embedded DMA controller of
STATFIFO. This register should be configured before activating or restarting the
embedded DMA controller.
Address: 21C_4000h base + 24h offset = 21C_4024h
Bit
31
30
29
28
27
26
25
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
DMA_TSF_SIZE_SFF
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
CSI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
784
NXP Semiconductors

<!-- page 785 -->

CSI_CSIDMATS_STATFIFO field descriptions
Field
Description
DMA_TSF_
SIZE_SFF
DMA Transfer Size for STATFIFO. Indicates how many words to be transfered by the embedded DMA
controller. The size should be aligned.
19.7.10
CSI DMA Start Address Register - for Frame Buffer1
(CSI_CSIDMASA_FB1)
This register provides the start address in the frame buffer1 for the embedded DMA
controller of RxFIFO. The embedded DMA controller will read data from RxFIFO and
write it to the frame buffer1 from the start address. This register should be configured
before activating or restarting the embedded DMA controller.
Address: 21C_4000h base + 28h offset = 21C_4028h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
DMA_START_ADDR_FB1
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
DMA_START_ADDR_FB1
Reserved
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
CSI_CSIDMASA_FB1 field descriptions
Field
Description
31–2
DMA_START_
ADDR_FB1
DMA Start Address in Frame Buffer1. Indicates the start address to write data. The embedded DMA
controller will read data from RxFIFO and write it from this address through AHB bus. The address should
be aligned.
-
This field is reserved.
Reserved. These bits are reserved and should read 0.
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
785

<!-- page 786 -->

19.7.11
CSI DMA Transfer Size Register - for Frame Buffer2
(CSI_CSIDMASA_FB2)
This register provides the start address in the frame buffer2 for the embedded DMA
controller of RxFIFO. The embedded DMA controller will read data from RxFIFO and
write it to the frame buffer2 from the start address. This register should be configured
before activating or restarting the embedded DMA controller.
Address: 21C_4000h base + 2Ch offset = 21C_402Ch
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
DMA_START_ADDR_FB2
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
DMA_START_ADDR_FB2
Reserved
W
Reset
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
CSI_CSIDMASA_FB2 field descriptions
Field
Description
31–2
DMA_START_
ADDR_FB2
DMA Start Address in Frame Buffer2. Indicates the start address to write data. The embedded DMA
controller will read data from RxFIFO and write it from this address through AHB bus. The address should
be aligned.
-
This field is reserved.
Reserved. These bits are reserved and should read 0.
19.7.12
CSI Frame Buffer Parameter Register
(CSI_CSIFBUF_PARA)
This register provides the stride of the frame buffer to show how many words to skip
before starting to write the next row of the image. The width of the frame buffer minus
the width of the image is the stride. This register should be configured before activating
or restarting the embedded DMA controller.
Address: 21C_4000h base + 30h offset = 21C_4030h
Bit
31
30
29
28
27
26
25
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
DEINTERLACE_STRIDE
FBUF_STRIDE
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
CSI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
786
NXP Semiconductors

<!-- page 787 -->

CSI_CSIFBUF_PARA field descriptions
Field
Description
31–16
DEINTERLACE_
STRIDE
DEINTERLACE_STRIDE is only used in the deinterlace mode. If line stride feature is supported in
deinterlace mode, FBUF_STRIDE and DEINTERLACE_STRIDE need to be configured at the same time.
DEINTERLACE_STRIDE is configured the same as line width. In normal line stride feature, only
FBUF_STRIDE needs to be configured.
 
DEINTERLACE_STRIDE
DEINTERLACE_STRIDE
FBUF_STRIDE
FBUF_STRIDE
line0
line0
line1
line1
FBUF_STRIDE
Frame Buffer Parameter. Indicates the stride of the frame buffer. The width of the frame buffer(in ) minus
the width of the image(in ) is the stride. The stride should be aligned. The embedded DMA controller will
skip the stride before starting to write the next row of the image.
19.7.13
CSI Image Parameter Register (CSI_CSIIMAG_PARA)
This register provides the width and the height of the image from the sensor. The width
and height should be aligned in pixel. The width of the image multiplied by the height is
the total pixel size that will be transfered in a frame by the embedded DMA controller.
This register should be configured before activating or restarting the embedded DMA
controller.
Address: 21C_4000h base + 34h offset = 21C_4034h
Bit
31
30
29
28
27
26
25
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
IMAGE_WIDTH
IMAGE_HEIGHT
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
CSI_CSIIMAG_PARA field descriptions
Field
Description
31–16
IMAGE_WIDTH
Image Width. Indicates how many pixels in a line of the image from the sensor.
If the input data from the sensor is 8-bit/pixel format, the IMAGE_WIDTH should be a multiple of pixels.
If the input data from the sensor is 10-bit/pixel or 16-bit/pixel format, the IMAGE_WIDTH should be a
multiple of pixels.
IMAGE_HEIGHT Image Height. Indicates how many pixels in a column of the image from the sensor.
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
787

<!-- page 788 -->

19.7.14
CSI Control Register 18 (CSI_CSICR18)
This read/write register acts as an extension of the functionality of the CSI Control
register 1
Address: 21C_4000h base + 48h offset = 21C_4048h
Bit
31
30
29
28
27
26
25
24
23
22
21
20
19
18
17
16
R
CSI_ENABLE
Reserved
MASK_
OPTION
CSI_LCDIF_
BUFFER_
LINES
W
Reset
0
0
0
0
0
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
Bit
15
14
13
12
11
10
9
8
7
6
5
4
3
2
1
0
R
AHB_HPROT
Reserved
RGB888A_FORMAT_SEL
BASEADDR_CHANGE_
ERROR_IE
LAST_DMA_REQ_SEL
DMA_FIELD1_DONE_IE
FIELD0_DONE_IE
BASEADDR_SWITCH_
SEL
BASEADDR_SWITCH_EN
PARALLEL24_EN
DEINTERLACE_EN
Reserved
W
Reset
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
0
0
0
0
0
0
CSI_CSICR18 field descriptions
Field
Description
31
CSI_ENABLE
CSI global enable signal. Only when this bit is 1, CSI can start to receive the data and store to memory.
30–20
-
This field is reserved.
19–18
MASK_OPTION
These bits used to choose the method to mask the CSI input.
00
Writing to memory from first completely frame, when using this option, the CSI_ENABLE should be
1.
01
Writing to memory when CSI_ENABLE is 1.
02
Writing to memory from second completely frame, when using this option, the CSI_ENABLE should
be 1.
03
Writing to memory when data comes in, not matter the CSI_ENABLE is 1 or 0.
Table continues on the next page...
CSI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
788
NXP Semiconductors

<!-- page 789 -->

CSI_CSICR18 field descriptions (continued)
Field
Description
17–16
CSI_LCDIF_
BUFFER_LINES
The number of lines are used in handshake mode with LCDIF.
00
4 lines
01
8 lines
02
16 lines
03
16 lines
15–12
AHB_HPROT
Hprot value in AHB bus protocol.
11
-
This field is reserved.
10
RGB888A_
FORMAT_SEL
Output is 32-bit format.
0
{8’h0, data[23:0]}
1
{data[23:0], 8’h0}
9
BASEADDR_
CHANGE_
ERROR_IE
Base address change error interrupt enable signal.
8
LAST_DMA_
REQ_SEL
Choosing the last DMA request condition.
0
fifo_full_level
1
hburst_length
7
DMA_FIELD1_
DONE_IE
When in interlace mode, field 1 done interrupt enable.
0
Interrupt disabled
1
Interrupt enabled
6
FIELD0_DONE_
IE
In interlace mode, fileld 0 means interrupt enabled.
0
Interrupt disabled
1
Interrupt enabled
5
BASEADDR_
SWITCH_SEL
CSI 2 base addresses switching method. When using this bit, BASEADDR_SWITCH_EN is 1.
0
Switching base address at the edge of the vsync
1
Switching base address at the edge of the first data of each frame
4
BASEADDR_
SWITCH_EN
When this bit is enabled, CSI DMA will switch the base address according to BASEADDR_SWITCH_SEL
rather than atomically by DMA completed.
3
PARALLEL24_
EN
When input is parallel rgb888/yuv444 24bit, this bit can be enabled.
2
DEINTERLACE_
EN
This bit is used to select the output method When input is standard CCIR656 video.
0
Deinterlace disabled
1
Deinterlace enabled
-
This field is reserved.
Reserved.
Chapter 19 CMOS Sensor Interface (CSI)
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
NXP Semiconductors
789

<!-- page 790 -->

19.7.15
CSI Control Register 19 (CSI_CSICR19)
This read/write register acts as an extension of the functionality of the CSI Control
register 1
Address: 21C_4000h base + 4Ch offset = 21C_404Ch
Bit
31
30
29
28
27
26
25
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
DMA_RFIFO_HIGHEST_
FIFO_LEVEL
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
CSI_CSICR19 field descriptions
Field
Description
31–8
-
This field is reserved.
DMA_RFIFO_
HIGHEST_FIFO_
LEVEL
This byte stores the highest FIFO level achieved by CSI FIFO timely and will be clear by writing 8’ff to it.
CSI Memory Map/Register Definition
i.MX 6ULL Applications Processor Reference Manual, Rev. 1, 11/2017
790
NXP Semiconductors

